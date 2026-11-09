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
#include "keydef.h"
#include "xms.h"

#define I asm
typedef unsigned char uchar;
typedef unsigned int  uint ;
void grafix(void)
{
I	mov ax,0x0012
I	int 0x10
}
void closegraf(void)
{
I	mov ax,0x0003
I	int 0x10
}
void cls(void)
{
I	mov ax,0xA000
I	mov es,ax
I   mov ax,0x0F02
I   mov dx,0x3C4
I   out dx,ax
I	xor ax,ax
I	xor di,di
I	mov cx,19200
I	rep stosw
}
void putup(unsigned char *scr,unsigned char *b,int nc,int h)
{
	while (h--) {
		memcpy(scr,b,nc);
		b+=nc;
	    scr+=80;	
	}
}
int getkey(void)
{
	int k;
	if (!(k=getch())) k=0-getch();
	return(k);
}
void reorder(uint *font,int l)
{
	int i,j;
	uint *buf,*f=font;
	if ((buf=malloc(l*32))==NULL) return;
	for (i=0;i<l;i++) {
		for (j=0;j<(l<<4);j+=l) {
			buf[j+i]=*(f++);
		}
	}
	memcpy(font,buf,l*32);
	free(buf);
}
void output(int hand,int j,int i,uchar *buf)
{
	int k,l,c;
	unsigned char *scr=(unsigned char *)0xA0000000L;
	uchar *b;
	long ofs=((long)j)*3008L;

	for (l=0;l<30;l++) {
		c=0x0F02;
//		c=((((l+j)%15)+1)<<8)|2;
		b=buf+i*2;
		xms2mem(buf,hand,ofs,3008);
		for (k=0;k<16;k++) {
			if ((c&0x0F00)!=0) {
				outpw(0x3C4,c);
				memcpy(scr,b,80);
			}
			if ((c&0x0F00)!=0x0F00) {
				outpw(0x3C4,c^0x0F00);
				memset(scr,0,80);
			}
			scr+=80;
			b+=188;
		}
		ofs+=3008;
	}

}
int main(int argc,char *argv[])
{
	unsigned int j,xit=0,nl=0,hand;
	int fd,i;
	unsigned char *buf;
	long ofs;

	if ((buf=malloc(4096))==NULL) {
		printf("Not enough memory \n");
		return(0);
	}
	hand=XMSalloc(240);
	if (hand==0) {
		printf("Out of handles %d\n",nl);
		return(0);
	}

	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	ofs=0L;
	nl=0;
	while (read(fd,buf,3008)>0) {
		reorder((uint*)buf,94);
		mem2xms(buf,hand,ofs,3008);
		ofs+=3008L;
		nl++;
	}
    close(fd);
	
	grafix();
	cls();
	i=j=0;
	while (!xit) {
		output(hand,j,i,buf);
		switch (getkey()) {
 			case LEFT :
				if (i>40) i-=40; else i=0;
				break;
			case RGT  :
				if (i<54) i+=40; else i=54;
				break;
 			case UP   :
				if (j>30) j-=30; else j=0;
				break;
 			case DOWN   :
				if (j<4) j+=30; else j=44;
				break;
			case ESC :
				xit=1;
				break;
		}
	}
	XMSfree(hand);
	free(buf);
	closegraf();
	return(1);
}

