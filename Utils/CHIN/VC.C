#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <mem.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <conio.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "xms.h"

#define I asm
#define SOMAP 0x56

typedef unsigned char uchar;
typedef unsigned int  uint;
int G_fwid=24,G_fhgt=24,G_fbw=3;
uchar buf[32000];
uint G_h,G_k;

void grafix(void) { I { mov ax,0x0012; int 0x10 } }
void closegraf(void) { I { mov ax,0x0003; int 0x10 } }
void cls(void) { I { mov ax,0xA000; mov es,ax; mov ax,0x0F02; mov dx,0x3C4; out dx,ax; mov ax,0; xor di,di; mov cx,19200; rep stosw } }
void putup(int x,int y,long o,int nc)
{
	uint j;
	uchar *scr=(uchar *)0xA0000000L+(y*80)+x,*b=buf;
	xms2mem(buf,G_h,o,nc*G_fhgt);

	outpw(0x3C4,0x0F02);
	for (j=0;j<G_fhgt;j++) {
		memcpy(scr,b,nc);
		b+=nc;
	    scr+=80;	
	}
}
long getofs(uchar **s,int hgt,int wid)
{
	long ret=0L,sw=hgt*(wid-1),lw=hgt*wid;
	uchar *t=*s,a;
	(*s)++;

	a=*t;
	if (a<0x80) return(a*sw);
								 ret=256L*sw;
	if       (a<0xA4)			 ret+=(157L*(a-0xA1))*lw;
	else if  (a<0xC7) 			 ret+=(157L*(a-0xA4))*lw+(408L*lw);
	else if ((a>0xC8)&&(a<0xFA)) ret+=(157L*(a-0xC9))*lw+(5809L*lw);
	else return(-1L);

	a=*(++t); (*s)++;
	if ((a<0x40)||((a>0x7F)&&(a<0xa1))) return(-1L);
	a-=0x40; if (a>0x3F) a-=0x22;
	lw*=a;
	return(ret+lw);
}
void prat(int *x,int *y,char *fmt,...)
{
	uchar str[80];
	uchar *s;
	long ofs;
	va_list ap;
	s=str;
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
	while (*s) {
		if ((*s==10)||(*s==13)) {
			*x=0;
			*y+=G_fhgt;
			if (*y>480) {
				getch();
				*x=0;
				*y=0;
				cls();
			}
			s++;
		} else {
			if ((ofs=getofs(&s,G_fhgt,G_fbw))>0) {
				if (ofs<=256L*G_fhgt*(G_fbw-1)) {
					putup(*x,*y,ofs,G_fbw-1);
					*x+=G_fbw-1;
				} else {
					putup(*x,*y,ofs,G_fbw);
					*x+=G_fbw;
				}
				if (*x+G_fbw>80) {
					*x=0;
					*y+=G_fhgt;
					if (*y>480) {
						G_k=getch();
						*x=0;
						*y=0;
						cls();
					}
				}
			}
		}
	}
}
int main(int argc,char *argv[])
{
	int i,j,k,fd,x=0,y=0;
	FILE *fp;
	long l,o;
	uchar ch[200],tmp;
	
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	G_fwid=24;
	G_fhgt=24;
	G_fbw=(G_fwid+7)/8;
	l=filelength(fd);
	G_h=XMSalloc((l+1023L)/1024L);
	if (!G_h) {printf("No Xms\n"); return(1); }
	o=0L;
	while ((l=read(fd,buf,32000))>0) { mem2xms(buf,G_h,o,l); o+=l; }
	close(fd);
	grafix();
	cls();
	fp=fopen(argv[2],"r");
	i=0;
	while (fgets(ch,200,fp)!=NULL) {
		prat(&x,&y,"%s",ch);
//		x=0;
//		y+=G_fhgt;
//		if (y>480) {
//			G_k=getch();
//			cls();
//			y=0;
//		}
		if (G_k==27) break;
	}
	fclose(fp);
	closegraf();
	XMSfree(G_h);
	return(1);
}


