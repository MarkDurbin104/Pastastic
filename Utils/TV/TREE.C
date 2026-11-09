#include <graphics.h>
#include <math.h>
#include <time.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>

#define DEGREE M_PI/180.0
#define FOLIAGE 15

int G_foliage;
void grafix(void);
void lin(int x1,int y1,int x2,int y2,int len);
void fline(int x,int y,int len,int ang);
void tree(int x,int y,int h);
void aline(int x,int y,int len,int ang);

int G_driver,G_mode;
main(int argc,char **argv) {
	int i;
	randomize();
	grafix();
	moveto(320,240);
	if (argv[argc-1][0]=='o') {
		for(i=50;i<640;i+=100) tree(i+10,240,240);
		for(i=50;i<640;i+=100) tree(i+20,360,240);
		for(i=50;i<640;i+=100) tree(i+30,480,240);
	}
	else {
		if (argv[argc-1][0]=='l') {
			for(i=0;i<360;i+=10) aline(320,240,100,i);
			getch();
		}
		else {
			if (argc>1) G_foliage=atoi(argv[argc-1]); else G_foliage=FOLIAGE;
			tree(320,480,300);
		}
	}
	return(1);
}
void tree(int x,int y,int h) {
	fline(x,y,h,180);
}
void fline(int x,int y,int len,int ang) {
	int x2,y2,x3,y3,a,b,c,d,l;
	ang%=360;
	if (len>G_foliage) {
		x3=x+sin(ang*DEGREE)*(len/2);
		y3=y+cos(ang*DEGREE)*(len/2);
		l=(len/2);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		setcolor(6);
		lin(x,y,x3,y3,len);
		a=len/2;
		b=(len*2)/3;
		c=len/3;
		d=len/4;
		fline(x2,y2,random(a/2)+(2*a)/3,ang-45+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(a/2)+(2*a)/3,ang+45+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(b/2)+(2*b)/3,ang+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(b/2)+(2*b)/3,ang-22+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(b/2)+(2*b)/3,ang+22+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(c/2)+(2*c)/3,ang-10+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(c/2)+(2*c)/3,ang+10+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(d/2)+(2*d)/3,ang-20+(20-random(40)));
		l=(len/2)-random(len/4);
		x2=x+sin(ang*DEGREE)*l;
		y2=y+cos(ang*DEGREE)*l;
		fline(x2,y2,random(d/2)+(2*d)/3,ang+20+(20-random(40)));
	}
	else {
		x2=x+sin(ang*DEGREE)*(len/2);
		y2=y+cos(ang*DEGREE)*(len/2);
		if (!random(20)) {
			setcolor(4);
			circle(x2,y2,2);
		}
		setcolor(2);
		line(x,y,x2,y2);
	}
}
void aline(int x,int y,int len,int ang) {
	int x2,y2,l;
	int i;
	float a;
	if (len<50) return;
	setcolor(((x/(ang+1))%14)+1);
	ang%=360;
	a=(float)ang*DEGREE;
	x2=x+sin(a)*len;
	y2=y+cos(a)*len;
/*	line(x,y,x2,y2);*/
	l=len-=10;
	if (l>50) for (i=ang;i<360+ang;i+=10) aline(x2,y2,l--,i); else lineto(x2,y2);
	moveto(x2,y2);
}
void lin(int x1,int y1,int x2,int y2,int len) {
	int i;
	for(i=0;i<len/40;i++) {
		line(x1+i,y1,x2+i,y2);
		line(x1-i,y1,x2-i,y2);
	}
	if (len<40) line(x1,y1,x2,y2);

}
void grafix(void) {					/* sets up graphics mode */
	int errormode;
	G_driver = VGA;
	G_mode = VGAHI;
	errormode=registerbgidriver(EGAVGA_driver);
	if( errormode < 0 ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
}
