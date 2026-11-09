#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <string.h>
#include <mem.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "keydef.h"

#define FONTSIZE (32+14*256+16*256)
#define I asm

unsigned char   G_font[FONTSIZE];
unsigned char   G_addinfo[256];
unsigned char   G_cmap[768];
unsigned char 	buf[1300];

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
I   mov bx,0x0102
I	mov ax,0xA000
I	mov es,ax
I   mov dx,0x3C4
eachplane:
I	mov ax,bx
I   out dx,ax
I	xor ax,ax
I	xor di,di
I	mov cx,19200
I	rep stosw
I   shl bh,1
I   cmp bh,0x10
I   jne eachplane
}
void outbytes(unsigned char *a,unsigned char *b,unsigned char c,int n)
{
I   push ds
I   mov ax,0x0102
I   mov bx,0x0004
eachplane:
I   push ax
I   mov dx,0x3C4
I   out dx,ax
I   mov ax,bx
I   mov dx,0x3CE
I   out dx,ax
I   pop ax
I	les di,a
I	lds si,b
I   push ax
I   mov cx,n
I   test c,ah
I	jz  dontput
putloop:
I   mov al,ds:[si]
I   mov ah,al
I   not ah
I   and es:[di],ah
I   xor es:[di],al
I   inc di
I   inc si
I   loop putloop
I   jmp contput
dontput:
I   mov al,ds:[si]
I   not al
I   and es:[di],al
I   inc di
I   inc si
I   loop dontput
contput:
I   pop ax
I	shl ah,1
I	inc bh
I   cmp ah,0x10
I   jl  eachplane
I   pop ds
}
void getfdat(unsigned char c,unsigned char *b)
{
	unsigned char *f=&G_font[32];
I   push ds
I	lds si,f
I	les di,b
I	xor ah,ah
I   mov al,c
I   shl ax,4
I   add si,ax
I   mov cx,16
charloop:
I   movsb
I   add di,79
I   loop charloop
I   pop ds
}
void shiftblk(unsigned char *a,int n)
{
	int v;
	unsigned char *b;
	b=a;
	n=8-n;
	b+=1280;
	while (a!=b) {
		v=(int)*b;
		*b=0;
		v<<=n;
		*b=(unsigned char)(v>>8);
		*(b+1)|=(unsigned char)(v&0xFF);
		b--;
	}
}
void printl(int x,int y,unsigned char col,char *fmt,...)
{
	unsigned char cbuf[80],*s=cbuf;
	unsigned char l,*b=buf;
	unsigned char mline[81],*m=mline;
	unsigned char *scr=(unsigned char *)0xA0000000L+(y<<6)+(y<<4)+(x>>3);
	int i=x&7,j;
    va_list ap;

    va_start(ap,fmt);
    vsprintf(s,fmt,ap);
    va_end(ap);

	l=strlen(s);
	if (!l) return;
	memset(buf,0,sizeof(buf));
	while (*s) getfdat(*(s++),b++);
	b=buf;
	memset(m,0xFF,l+1);
	if (i) {
		shiftblk(b,i);
		*m=(0xFF>>i);
		*(m+l)=~(*m);
	}
	for (j=0;j<16;j++) {
		if (i) {
			outbytes(scr,m,col>>4,l+1);
			outbytes(scr,b,col&0x0F,l+1);
		} else {
			outbytes(scr,m,col>>4,l);
			outbytes(scr,b,col&0x0F,l);
		}
		scr+=80;
		b+=80;
	}
}

int readfont(char *file)
{
    int fd;
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    read(fd,G_font,FONTSIZE);
    read(fd,G_addinfo,256);
    read(fd,G_cmap,768);
    close(fd);
    return(1);
}
int writefont(char *file)
{
    int fd;
    fd=open(file,O_RDWR|O_CREAT|O_TRUNC|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) return(0);
    write(fd,G_font,FONTSIZE);
    write(fd,G_addinfo,256);
    write(fd,G_cmap,768);
    close(fd);
    return(1);
}
void bar(int x,int y,unsigned char onoff)
{
	unsigned char *scr=(unsigned char *)0xA0000000L+(y*640)+x,*s;
	unsigned int i,j;
	if (onoff) onoff=0xFF;
	for (i=8;i<12;i++) {
		outpw(0x3C4,(1<<i)+2);
		s=scr;
		for (j=0;j<8;j++) {	*s=onoff; s+=80; }
	}
}
void cursor(int x,int y,int o,int onoff)
{
	if (onoff) onoff=0x10;
	if (o)
		printl(x*40+o*8,y*16,0x0E+onoff,"%c",((G_cmap[x*16+y+(o-1)*256])==0?32:(G_cmap[x*16+y+(o-1)*256])));
	else									 
		printl(x*40+o*8,y*16,0x0F+onoff,"%c",((x*16+y)==0?32:(x*16+y)));
}
void putlc(int x,int y,int c)
{
	unsigned char *fp=&G_font[32+c*16];
	unsigned char mask;
	int i,j;

	for (i=0;i<16;i++) {
		mask=0x80;
		for (j=0;j<8;j++) {
			bar(x+j,y+i,((*fp&mask)!=0));
			mask>>=1;
		}
		fp++;
	}
}
void largec(int i,int o)
{
	printl(8,38*8,12,"%02X %03d",i,i);
	printl(15*8,38*8,15+(0x10*(o==0)),"INDEPENDENT");
	putlc(15,40,i);
	printl(30*8,38*8,15+(0x10*(o==1)),"INITIAL");
	putlc(30,40,G_cmap[i]);
	printl(45*8,38*8,15+(0x10*(o==2)),"MEDIAN");
	putlc(45,40,G_cmap[i+256]);
	printl(60*8,38*8,15+(0x10*(o==3)),"TERMINAL");
	putlc(60,40,G_cmap[i+512]);
}
int main(int argc,char *argv[])
{
	int k,xit=0,m=0;
	int cx=0,cy=0,o=0;
	unsigned char tmp[257];
	int i;
	memset(G_cmap,0,sizeof(G_cmap));
	if (argc<2) {
		printf("fmap fontfile\n");
		return(1);
	}
	readfont(argv[1]);
	grafix();
	for (i=1;i<256;i++) {
		cursor(i/16,i%16,0,0);
		cursor(i/16,i%16,1,0);
		cursor(i/16,i%16,2,0);
		cursor(i/16,i%16,3,0);
	}
	largec(cx*16+cy,o);
	cursor(cx,cy,o,1);
	while (!xit) {
		if (!(k=getch())) k=(0-getch());
		cursor(cx,cy,o,0);
		i=cx*16+cy;
		switch(k) {
			case LEFT : if (cx>0)  cx--; break;
			case RGT  : if (cx<15) cx++; break;
			case UP   : if (cy>0)  cy--; break;
			case DOWN : if (cy<15) cy++; break;
			case CRGT : if (o<3)   o++;  break;
			case CLEFT: if (o>0)   o--;  break;
			case ESC  : xit=1;           break;
			case 'S'  :
			case 's'  :
				m=1;
				if (o==0) {
					G_cmap[i]=i; G_cmap[i+256]=i;G_cmap[i+512]=i;
					cursor(cx,cy,1,0);
					cursor(cx,cy,2,0);
					cursor(cx,cy,3,0);
				} else {
					G_cmap[i+(o-1)*256]=i;
				}
				break;
			case 'C'  :
			case 'c'  :
				m=1;
				if (o==0) {
					G_cmap[i]=0; G_cmap[i+256]=0;G_cmap[i+512]=0;
					cursor(cx,cy,1,0);
					cursor(cx,cy,2,0);
					cursor(cx,cy,3,0);
				} else {
					G_cmap[i+(o-1)*256]=0;
				}
				break;
			case PGUP : if (o) { m=1; G_cmap[i+(o-1)*256]--; } break;
			case PGDN : if (o) { m=1; G_cmap[i+(o-1)*256]++; } break;
		}
		cursor(cx,cy,o,1);
		largec(cx*16+cy,o);
	}
	closegraf();
	if (m) {
		printf("Do you wish to save Y/N? ");
		k=getch();
		if ((k=='Y')||(k=='y')) writefont(argv[1]);
	}
	return(0);
}

