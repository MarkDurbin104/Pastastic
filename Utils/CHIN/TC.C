#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <conio.h>
#include <sys\types.h>
#include <sys\stat.h>

#define I asm
#define SOMAP 0x56

typedef unsigned char uchar;
typedef unsigned int  uint;
int G_fwid=24,G_fhgt=24,G_fbw=3;

void grafix(void) { I { mov ax,0x0012; int 0x10 } }
void closegraf(void) { I { mov ax,0x0003; int 0x10 } }
void cls(void) { I { mov ax,0xA000; mov es,ax; mov ax,0x0F02; mov dx,0x3C4; out dx,ax; mov ax,0; xor di,di; mov cx,19200; rep stosw } }
void putup(int x,int y,uchar *b,int nc)
{
	uint j;
	uchar *scr=(uchar *)0xA0000000L+(y*80)+(x>>3);
	outpw(0x3C4,0x0F02);
	for (j=0;j<G_fhgt;j++) {
		memcpy(scr,b,nc);
		b+=nc;
	    scr+=80;	
	}
}
long getofs(uchar **s)
{
	long ret=0L;
	uchar *t;
	uchar a,b;
	t=*s;
	if (*t<0xA0) {
		(*s)++;
		return((*t)*G_fhgt*(G_fbw-1));
	}
	a=*t-0xA1;
	ret=256L*G_fhgt*(G_fbw-1);
	if (a<0xA4) {
		;
	} else if (a<0xC7) {
		ret+=408L*G_fhgt*G_fbw;
	} else if ((a>0xC8)&&(a<0xFA)) {
		ret+=5809L*G_fhgt*(G_fbw-1)
	} else {
		(*s)++;
		return(-1L);
	}
	t++;
	a=*t;
	if ((a<0x40)||((a>0x7F)&&(a<0xa1))) {
		(*s)++;
		return(-1L);
	}
	a-=0x40;
	if (a>0x3F) a-=0x21;
	ret+=((long)a)*G_fhgt*G_fbw;
	(*s)++;
	return(ret);
}
void *mymalloc(size_t size)
{
    void *tmp;
	if (size==0) return(NULL);
    tmp=malloc(size);
    if (tmp==NULL) {
        printf("Memory Error\n");
		exit(-1);
    }
    memset(tmp,0,size);
    return(tmp);
}
void prat(int x,int y,char *fmt,...)
{
	char str[80];
	char *s;
	long ofs;
	va_list ap;
	s=str;
	gotoxy(x+1,y+2);
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
	while (*s) {
		if ((ofs=getofs(&s))>0) {
			
		}
	}
}
int main(int argc,char *argv[])
{
	int i,j,k,fd;
	FILE *fp;
	long l;
	uchar ch[24*3],tmp;
	
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	G_fwid=24;
	G_fhgt=24;
	G_fbw=(G_fwid+7)/8;
	l=filelength(fd);
	i=(int)(l/(G_fhgt*G_fbw));
	grafix();
	cls();
	while ((!kbhit())&&(k!=27)) {
		lseek(fd,0L,SEEK_SET);
		for (j=0;j<i;j++) {
			read(fd,ch,G_fhgt*G_fbw);
			putup(((j%300)%20)*32,((j%300)/20)*32,ch,G_fbw);
			if ((j%300)==299) {
				k=getch();
				cls();
			}
			if (k==27) break;
		}
 		if ((k!=27)&&((j%300)!=299)) {
			k=getch();
		}
	}
	close(fd);
	closegraf();
	return(1);
}


