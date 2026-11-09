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
typedef struct {
	uchar len;
	uchar type;
	uchar fc;
	uchar lc;
	union {
		long ofs;
		uchar far *f;
	} add;
} FMAP;
typedef struct {
	FMAP b;
	uchar len;
	uchar type;
	uchar fc;
	uchar lc;
} FMAP1;

FMAP  G_fonts[100];
FMAP1 G_bfont;
uchar G_fwid=16,G_fhgt=16,G_fbw=2;
void grafix(void) { I { mov ax,0x0012; int 0x10 } }
void closegraf(void) { I { mov ax,0x0003; int 0x10 } }
void cls(void) { I { mov ax,0xA000; mov es,ax; mov ax,0x0F02; mov dx,0x3C4; out dx,ax; mov ax,0xFFFF; xor di,di; mov cx,19200; rep stosw } }

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
void prln(int x,int y,uchar *s)
{
	uchar c;
	int ofs;
	x*=8;
	y*=G_fhgt;
	if ((y>(480-G_fhgt))||(x>(640-G_fwid))) return;

	while (*s) {
		if (*s>0xA0) {
			c=*(s++)-0xA1;
			if ((*s)&&(G_fonts[c].fc<=*s)&&(G_fonts[c].lc>=*s)) {
				ofs=(*s-0xA1)*(G_fbw*G_fhgt);
				putup(x,y,&(G_fonts[c].add.f[ofs]),G_fbw);
				x+=G_fwid;
			}
		} else {
			if (*s>31) {
				ofs=(*s*((G_fbw-1)*G_fhgt));
				putup(x,y,&(G_bfont.b.add.f[ofs]),G_fbw-1);
				x+=G_fwid-8;
			}
		}
		if (x>640-G_fwid) return;
		s++;
	}
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
int main(int argc,char *argv[])
{
	int i,j,k,fd;
	FILE *fp;
	uchar *ch,tmp;
	
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	lseek(fd,0x3E,SEEK_SET);
	read(fd,&G_fwid,1); read(fd,&G_fhgt,1); G_fbw=G_fwid/8;
	lseek(fd,SOMAP,SEEK_SET);
	read(fd,&G_bfont,sizeof(FMAP1));
	read(fd,G_fonts,G_bfont.len*sizeof(FMAP));

	ch=mymalloc(G_bfont.b.len*((G_fbw-1)*G_fhgt));
	lseek(fd,G_bfont.b.add.ofs,SEEK_SET);
	for (j=0;j<G_bfont.b.len;j++) {
		read(fd,&tmp,1);
		read(fd,ch+j*((G_fbw-1)*G_fhgt),((G_fbw-1)*G_fhgt));
		for (k=0;k<((G_fbw-1)*G_fhgt);k++) *(ch+j*((G_fbw-1)*G_fhgt)+k)^=0xFF;
	}
	G_bfont.b.add.f=ch;

	for (i=0;i<G_bfont.len;i++) {
 		ch=mymalloc(G_fonts[i].len*G_fbw*G_fhgt);
		lseek(fd,G_fonts[i].add.ofs,SEEK_SET);
		for (j=0;j<G_fonts[i].len;j++) {
			read(fd,&tmp,1);
			read(fd,ch+j*G_fbw*G_fhgt,G_fbw*G_fhgt);
			for (k=0;k<G_fbw*G_fhgt;k++) *(ch+j*G_fbw*G_fhgt+k)^=0xFF;
		}
		G_fonts[i].add.f=ch;
	}
    close(fd);

	grafix();
	cls();
	fp=fopen(argv[2],"r");
 	ch=mymalloc(80);
	i=0;
	k=0;
	while (fgets(ch,80,fp)!=NULL) {
		prln(0,i++,ch);
		if (i==(480/G_fhgt)) {
			if ((k=getch())==27) {
				fclose(fp);
			} else {
				i=0;
				cls();
			}
		}
	}
	if (k!=27) getch();
	fclose(fp);
	closegraf();
	return(1);
}


