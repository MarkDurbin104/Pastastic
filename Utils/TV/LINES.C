#include <graphics.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <mem.h>
#include <conio.h>
#include <dos.h>

#define swap(a,b) c=a; a=b; b=c
#define sign(x) ((x<0)?(-1):1)

void lin(int x,int y,int x2,int y2);
void putpix(int x,int y,int col);
void grafix(void);
void loadimage(void);
void saveimage(void);

int G_driver,G_mode;
void scroll(char updn,int dist);
void pan(char rtlt,int dist);

main() {
	int i;
	grafix();
	setcolor(15);
//	loadimage();
    for (i=0;i<480;i++) {
        setcolor(i);
        lin(0,i,640,i);
    }
	rectangle(80,0,639,399);
	circle(240,240,240);
	circle(400,240,240);
	while (!kbhit()) {
		scroll(0,120);
		getch();
		pan(0,160);
		getch();
		scroll(1,120);
		getch();
		pan(1,160);
		getch();
	}
	getch();
    closegraph();
	return(1);
}
void grafix(void) {
	G_driver = DETECT;
	initgraph( &G_driver, &G_mode, "\\bc\\bgi" );
}
void lin(int x,int y,int x2,int y2) {
	int i,c,sx,sy,dx,dy,e,steep,col=getcolor();
	dx=abs(x2-x); sx=sign(x2-x);
	dy=abs(y2-y); sy=sign(y2-y);
	steep=(dx<dy);
	if (steep) { swap(dx,dy); swap(sx,sy); swap(x,y); }
	e=2*dy-dx;
	for (i=1;i<=dx;i++) {
		if (steep) putpix(y,x,col); else putpix(x,y,col);
		while (e>=0) { y+=sy; e-=2*dx; }
		x+=sx; e+=2*dy;
	}
	putpix(x2,y2,col);
}
void putpix(int x,int y,int col) {
	int i;
	char *scr=MK_FP(0xA000,0);
	char plnm,old;
	unsigned int ofs;

	for (i=0;i<4;i++) {
		plnm=1<<i;
		outportb(0x3CE,4);
		outportb(0x3CF,i);
		outportb(0x3C4,2);
		outportb(0x3C5,plnm);
		ofs=y*80+x/8;
		old=*(scr+ofs);
		if (plnm&col) *(scr+ofs)=old|(0x80>>(x%8)); else *(scr+ofs)=old&((0x80>>(x%8))^0xFF);
	}
}
void saveimage(void) {
	int i,fd;
	char *scr=MK_FP(0xA000,0);
	fd=open("scr.sav",O_BINARY|O_WRONLY|O_CREAT|O_TRUNC,0777);
	for (i=0;i<4;i++) {
		outportb(0x3CE,4);
		outportb(0x3CF,i);
		write(fd,scr,38400U);
	}
	close(fd);
}
void loadimage(void) {
	int i,fd;
	char *buf[4];
	char *scr=MK_FP(0xA000,0);
	for (i=0;i<4;i++) {
		buf[i]=malloc(38400U);
	}
	fd=open("scr.sav",O_RDONLY|O_BINARY);
	for (i=0;i<4;i++) {
		outportb(0x3C4,2);
		outportb(0x3C5,(1<<i));
		read(fd,buf[i],38400U);
	}
	close(fd);
	for (i=0;i<4;i++) {
		outportb(0x3C4,2);
		outportb(0x3C5,(1<<i));
		memcpy(scr,buf[i],38400U);
	}
	for (i=0;i<4;i++) {
		free(buf[i]);
	}
}
void scroll(char updn,int dist) {
	int i;
	char *scr=MK_FP(0xA000,0);
	if (updn) {
		for (i=0;i<4;i++) {
			outportb(0x3C4,2);
			outportb(0x3C5,(1<<i));
			outportb(0x3CE,4);
			outportb(0x3CF,i);
			memcpy(scr,scr+dist*80,38400U-dist*80);
			memset(scr+(38400U-dist*80),0,dist*80);
		}
	}
	else {
		for (i=0;i<4;i++) {
			outportb(0x3C4,2);
			outportb(0x3C5,(1<<i));
			outportb(0x3CE,4);
			outportb(0x3CF,i);
			movmem(scr,scr+dist*80,38400U-dist*80);
			memset(scr,0,dist*80);
		}
	}
}
void pan(char rtlt,int dist) {
	int i,j;
	char *scr=MK_FP(0xA000,0);
	if (rtlt) {
		for (i=0;i<4;i++) {
			outportb(0x3C4,2);
			outportb(0x3C5,(1<<i));
			outportb(0x3CE,4);
			outportb(0x3CF,i);
			for (j=0;j<480;j++) {
				movmem(scr+j*80,scr+j*80+dist/8,80-dist/8);
				memset(scr+j*80,0,dist/8);
			}
		}
	}
	else {
		for (i=0;i<4;i++) {
			outportb(0x3C4,2);
			outportb(0x3C5,(1<<i));
			outportb(0x3CE,4);
			outportb(0x3CF,i);
			for (j=0;j<480;j++) {
				memcpy(scr+j*80,scr+j*80+dist/8,80-dist/8);
				memset(scr+j*80+(80-dist/8),0,dist/8);
			}
		}
	}
}

