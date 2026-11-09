#include <graphics.h>
#include <dos.h>
#include <math.h>
#include <mem.h>
#include <alloc.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <conio.h>
#include <stdlib.h>

#define DEGREE 180.0/M_PI
#define sign(x) ((x<0)?(-1):1)
struct {
	int x1;
	int x2;
	int y1;
	int y2;
} G_line;
int Gm,Gd;
int G_linx,G_liny;
int G_buf[250];
double far *alook,*xlook,*ylook;
void linto(int x,int y);
void circ(int xc,int yc,int rad,int col);
void movto(int x,int y);
void putpix(int x,int y,int col,int type);
int rotapoly(int x,int y,int np,int *pp,double a,double z);
void setuplook(void);
void dump(void);
void drloc(int x,int y,int size,char *locid,int col);
void plot(int x,int y,char c);
void bopit(int x,int y,unsigned char b,char c);
void qlinto(int x,int y);
int size=3;
main() {
	int i,j;
	char tmp[20];
	Gd=DETECT;
	initgraph(&Gm,&Gd,"");
/*	setuplook();*/
/*	setcolor(14);*/
	for (i=200;i<240;i++) {
		circ(320,240,i,i&15);
	}
/*	for (i=0;i<160;i++) {
		setcolor(i&15);
		circle(480,240,i);
	}*/
	setcolor(15);
	for (i=0;i<120;i+=2) { movto(i,0); qlinto(i+240,479); }
/*	for (i=240;i<360;i+=2) { moveto(0,i); lineto(639,i+240); }*/
	for (j=0;j<50;j++) {
/*		cleardevice();
		for (i=0;i<30;i++) {
			itoa(i+100,tmp,10);
			drloc(j*10+i%6*80,i/6*80,4,tmp,11);
		}*/
	}
	getch();
	return(1);
}
void plot(int x,int y,char c) {
	char *scr=(char *)0xA0000000L+((y<<6L)+(y<<4L)+(x>>3));
	outportb(0x03CE,8); outportb(0x03CF,0x80>>(x&7));
	outportb(0x03CE,3); outportb(0x03CF,0);
	x=*scr;
	outportb(0x3C4,2);
	outportb(0x3C5,0x0F);
	*scr=0;
	outportb(0x3C5,c);
	*scr=0xFF;
	outportb(0x3C5,0x0F);
	outportb(0x03CE,3); outportb(0x03CF,0);
	outportb(0x03CE,8); outportb(0x03CF,0xFF);
}
void bopit(int x,int y,unsigned char b,char c) {
	char *scr=(char *)0xA0000000L+((y<<6L)+(y<<4L)+x);
	outportb(0x03CE,8); outportb(0x03CF,b);
	outportb(0x03CE,3); outportb(0x03CF,0);
	x=*scr;
	outportb(0x3C4,2);
	outportb(0x3C5,0x0F);
	*scr=0;
	outportb(0x3C5,c);
	*scr=0xFF;
	outportb(0x3C5,0x0F);
	outportb(0x03CE,3); outportb(0x03CF,0);
	outportb(0x03CE,8); outportb(0x03CF,0xFF);
}
void linto(int x,int y) {
	int i=0,col,lim;
	unsigned char mask,word=0;
	int sx,sy,dx,dy;
	register int e;
	int x1,x2,y1,y2;
	x1=G_line.x2;
	x2=x;
	y1=G_line.y2;
	y2=y;
	col=getcolor();
	dx=abs(x2-x1); sx=sign(x2-x1);
	dy=abs(y2-y1); sy=sign(y2-y1);
	mask=0x80>>(x1&7);
	if (dx<dy) {
		dx<<=1;	e=dx-dy; lim=dy+1; dy<<=1;
		while (i++<lim) {
			plot(x1,y1,col);
			while (e>=0) { x1+=sx; e-=dy; }
			y1+=sy; e+=dx;
		}
	}
	else {
		dy<<=1;	e=dy-dx; lim=dx+1; dx<<=1;
		while (i++<lim) {
			word|=mask;
			mask>>=1;
			if (!mask) {
				bopit(x1>>3,y1,word,col);
				word=0;
				mask=0x80;
			}
/*			plot(x1,y1,col);*/
			while (e>=0) {
				bopit(x1>>3,y1,word,col);
				word=0;
				y1+=sy;
				e-=dx;
			}
			x1+=sx;	e+=dy;
		}
	}
	plot(x2,y2,col);
	G_line.x1=G_line.x2;
	G_line.y1=G_line.y2;
	G_line.x2=x;
	G_line.y2=y;
}
void movto(int x,int y) {
	G_line.x1=G_line.x2;
	G_line.y1=G_line.y2;
	G_line.x2=x;
	G_line.y2=y;
}
int rotapoly(int x,int y,int np,int *pp,double a,double z) {
	int j;
	double ang,len;
	double xpos,ypos;

	if ((a!=0)||(z!=0)) {
		for (j=0;j<np;j++) {
			if ((*(pp+(j*2)+0)!=x)||(*(pp+(j*2)+1)!=y)) {
				ypos=(double)((double)*(pp+(j*2)+0)-(double)x);
				xpos=(double)((double)*(pp+(j*2)+1))-(double)y;
				len=sqrt((xpos*xpos)+(ypos*ypos));
				ang=(int)((double)a+(atan2(ypos,xpos)+M_PI)*(double)DEGREE);
				while (ang<0) ang+=360;
				while (ang>=360) ang-=360;
				*(pp+(j*2)+0)=x-len*cos(((2.0*M_PI)/360.0)*(double)z)*alook[ang];
				*(pp+(j*2)+1)=y-len*ylook[ang];
			}
		}
	}
	return(1);
}
void setuplook(void) {

	int i;
	double degree;
	alook=farmalloc(361*sizeof(degree));
	xlook=farmalloc(361*sizeof(degree));
	ylook=farmalloc(361*sizeof(degree));
	degree=(180.0/M_PI);
	for (i=0;i<90;i++) {
		xlook[i]=(double)sin((double)i/(double)degree);
		ylook[i]=(double)cos((double)i/(double)degree);
		xlook[i+90]=ylook[i];
		ylook[i+90]=0-xlook[i];
		xlook[i+180]=0-xlook[i];
		ylook[i+180]=0-ylook[i];
		xlook[i+270]=0-ylook[i];
		ylook[i+270]=xlook[i];
	}
	for (i=0;i<360;i++) alook[i]=xlook[i];
}
void dump() {
	int i,j,l,prbyte;
	FILE *printer;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (i=0;i<479-1;i+=8) {
			fprintf(printer,"%cZ%c%c",27,(639*3)%256,(639*3)/256);
			for (j=0;j<639;j++) {
				prbyte=0;
				for (l=0;l<8;l++) {
					prbyte|=((getpixel(j,i+l)&0x0F)!=0)<<(7-l);
				}
				switch(prbyte) {
					case 26 : {
						fprintf(printer,"%c%c%c",24,22,24);
					} break;
					case 10 : {
						fprintf(printer,"%c%c%c",11,9,11);
					} break;
					default : {
						fprintf(printer,"%c%c%c",prbyte,prbyte,prbyte);
					}
				}
			}
			fprintf(printer,"\n");
			if (kbhit()) break;
		}
		if (kbhit()) getch();
		fprintf(printer,"%c",12);
		fclose(printer);
	}
}
void putpix(int x,int y,int col,int type) {
	int i;
	char *scr=MK_FP(0xA000,0);
	char old;
	unsigned int ofs;

	if (type) {
		outportb(0x3CE,4);   /*set read plane */
		outportb(0x3CF,col); /* 0,1,2,3 */
		outportb(0x3C4,2);   /* set write plane */
		outportb(0x3C5,col); /* 1,2,4,8 */
		ofs=y*80+x/8;
		old=*(scr+ofs);
		*(scr+ofs)=old|(0x80>>(x%8));
	}
	else {
		putpixel(x,y,col);
	}
}
void circ(int xc,int yc,int rad,int col) {
	int x=0,y=rad+1,d=(1-rad)<<1;
	while (x<y+1) {
		plot(xc+x,yc+y,col);
		plot(xc+x,yc-y,col);
		plot(xc-x,yc+y,col);
		plot(xc-x,yc-y,col);
		plot(xc+y,yc+x,col);
		plot(xc+y,yc-x,col);
		plot(xc-y,yc+x,col);
		plot(xc-y,yc-x,col);
		if (d+y>0) { y--; d-=(y<<1)+1; }
		if (x>d)   { x++; d+=(x<<1)+1; }
	}
}
void drloc(int x,int y,int size,char *locid,int col) {
	setcolor(col);
	setfillstyle(1,col);
	line(x+size   ,y+0      ,x+size*19,y+0      );
	line(x+size*19,y+0      ,x+size*20,y+size   );
	line(x+size*20,y+size   ,x+size*20,y+size*19);
	line(x+size*20,y+size*19,x+size*19,y+size*20);
	line(x+size*19,y+size*20,x+size   ,y+size*20);
	line(x+size   ,y+size*20,x+0      ,y+size*19);
	line(x+0      ,y+size*19,x+0      ,y+size   );
	line(x+0      ,y+size   ,x+size   ,y+0      );
	bar(x,y+size*18,x+size*10,y+size*20);
	setcolor(0);
	settextjustify(1,2);
	settextstyle(2,0,4);
	outtextxy(x+size*5,(y+size*18)-1,locid);
}
void qlinto(int x,int y) {
	char *scr;
	int i=0,col,lim;
	unsigned char mask,word=0;
	int sx,sy,dx,dy;
	register int e;
	int x1,x2,y1,y2;
	x1=G_line.x2;
	x2=x;
	y1=G_line.y2;
	y2=y;
	scr=(char *)0xA0000000L+((y1<<6L)+(y1<<4L)+(x1>>3));
	col=getcolor();
	dx=abs(x2-x1); sx=sign(x2-x1);
	dy=abs(y2-y1); sy=sign(y2-y1);
	mask=0x80>>(x1&7);
	outportb(0x3C4,2);
	outportb(0x03CE,3); outportb(0x03CF,0);
	if (dx<dy) {
		dx<<=1;	e=dx-dy; lim=dy+1; dy<<=1;
		while (i++<lim) {
			outportb(0x03CE,8); outportb(0x03CF,mask);
			word=*scr;
			outportb(0x3C5,0x0F);
			*scr=0;
			outportb(0x3C5,col);
			*scr=0xFF;
			mask>>=1;
			if (!mask) {
				mask=0x80;
				scr++;
			}
			while (e>=0) { x1+=sx; e-=dy;}
			y1+=sy; e+=dx; scr+=80;
		}
	}
	else {
		dy<<=1;	e=dy-dx; lim=dx+1; dx<<=1;
		while (i++<lim) {
			word|=mask;
			mask>>=1;
			if (!mask) {
				outportb(0x03CE,8); outportb(0x03CF,word);
				word=*scr;
				outportb(0x3C5,0x0F);
				*scr=0x0;
				outportb(0x3C5,col);
				*scr=0xFF;
				scr++;
				word=0;
				mask=0x80;
			}
			while (e>=0) {
				outportb(0x03CE,8); outportb(0x03CF,word);
				word=*scr;
				outportb(0x3C5,0x0F);
				*scr=0;
				outportb(0x3C5,col);
				*scr=0xFF;
				scr+=80;
				word=0;
				y1+=sy;
				e-=dx;
			}
			x1+=sx;	e+=dy;
		}
	}
	outportb(0x03CE,8); outportb(0x03CF,mask);
	word=*scr;
	outportb(0x3C5,0x0F);
	*scr=0;
	outportb(0x3C5,col);
	*scr=0xFF;
	G_line.x1=G_line.x2;
	G_line.y1=G_line.y2;
	G_line.x2=x;
	G_line.y2=y;
	outportb(0x03CE,3); outportb(0x03CF,0);
	outportb(0x03CE,8); outportb(0x03CF,0xFF);
}
