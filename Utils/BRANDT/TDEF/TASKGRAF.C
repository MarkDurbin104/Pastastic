#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include "\tc\tv.h"

void grafix(void) {
	int errormode;
	GraphDriver = VGA;
	GraphMode = VGAHI;
	errormode=registerbgidriver(EGAVGA_driver);
	if( errormode < 0 ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	initgraph( &GraphDriver, &GraphMode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	maxx=getmaxx();
	maxy=getmaxy();
}
/*void grafix(void) {
	int ErrorCode;
	GraphDriver = DETECT;
	initgraph( &GraphDriver, &GraphMode, "" );
	ErrorCode = graphresult();
	if( ErrorCode != grOk ){
		printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
		exit(1);
	}
	maxx=getmaxx();
	maxy=getmaxy()-15;
	aspect=(double)(maxx/4)/(double)(maxy/3);
}*/
void blancdisp(void) {
	char nop[5];
	setcolor(14);
	setviewport(0,0,maxx,maxy+15,0);
	cleardevice();
	line(0,maxy+1,maxx,maxy+1);
	putimage(400,maxy+1,copyimg,COPY_PUT);
#ifdef CPNO   /*	print part No. on console							*/
#ifndef WPNO	0   /*	print part No. on console at top level		*/
	if (G_zoom!=(-1)) {
#endif
		setcolor(15);
		setfillstyle(0,1);
		bar(10,maxy+3,170,maxy+11);
		outtextxy(10,maxy+3,G_partnumb[pickno]);
		sprintf(nop,"%d",nopolys[pickno]);
		outtextxy(200,maxy+3,nop);
#ifndef WPNO
	}
#endif
#endif
#ifdef CPNPE   /*	print number of parts expected on console			*/
	if (G_zoom!=(-1)) {
		setcolor(15);
		itoa(G_numbparts[1][pickno],nop,10);
		outtextxy(200,maxy+3,nop);
	}
#endif
	setviewport(0,0,maxx,maxy,1);
}
int cursor(int cpos){
	int x,y,x1,y1;
	if (G_zoom==(-1)) {
		cpos%=(crossbdn*crossbdn);
		x=(maxx/crossbdn)*(cpos%crossbdn);
		y=(maxy/crossbdn)*(cpos/crossbdn);
		x1=(maxx/crossbdn)*((cpos%crossbdn)+1)-20;
		y1=(maxy/crossbdn)*((cpos/crossbdn)+1)-20;
		putimage(x,y,bitmap[0],XOR_PUT);
		putimage(x1,y,bitmap[1],XOR_PUT);
		putimage(x1,y1,bitmap[2],XOR_PUT);
		putimage(x,y1,bitmap[3],XOR_PUT);
#ifdef WPNO	0   /*	print part No. on console at top level		*/
		setviewport(0,0,maxx,maxy+15,0);
		setcolor(15);
		setfillstyle(0,1);
		bar(10,maxy+3,170,maxy+11);
		outtextxy(10,maxy+3,G_partnumb[pickno]);
		setviewport(0,0,maxx,maxy,1);
#endif
	}
	else {
		putimage(maxx/4,maxy/4,bitmap[0],XOR_PUT);
		putimage((maxx/4)*3-20,maxy/4,bitmap[1],XOR_PUT);
		putimage((maxx/4)*3-20,(maxy/4)*3-20,bitmap[2],XOR_PUT);
		putimage(maxx/4,(maxy/4)*3-20,bitmap[3],XOR_PUT);
	}
	return(1);
}
int prtv(int x,int y,int zoom,int col) {
	int i,j;
	setcolor(col);
	setfillstyle(1,col);
	for (i=0;i<9;i++) {
		moveto(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom),y+(p[0+noln[i][0]][1]*zoom));
		for (j=1;j<noln[i][1];j++) {
			lineto(x+((p[j+noln[i][0]][0]+(chpos[i]*8))*zoom),y+(p[j+noln[i][0]][1]*zoom));
			if (kbhit()) {
				getch();
				return(1);
			}
		}
	}
	return(0);
}
int pltv(int x,int y,int zoom) {
	int i,j,xp=0,yp=10;
	for (i=0;i<9;i++) {
		moveto(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom),y+(p[0+noln[i][0]][1]*zoom));
		if (i==0) {
			do {
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				if (xp<(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp++;
				if (xp>(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp--;
				if (yp<(y+(p[0+noln[i][0]][1]*zoom))) yp++;
				if (yp>(y+(p[0+noln[i][0]][1]*zoom))) yp--;
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				if (kbhit()) {
					getch();
					return(1);
				}
			} while ((xp!=(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom)))||(yp!=(y+(p[0+noln[i][0]][1]*zoom))));
		}
		else {
			do {
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				if (xp<(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp+=zoom;
				if (xp>(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp-=zoom;
				if (yp<(y+(p[0+noln[i][0]][1]*zoom))) yp+=zoom;
				if (yp>(y+(p[0+noln[i][0]][1]*zoom))) yp-=zoom;
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				dela(12);
				if (kbhit()) {
					getch();
					return(1);
				}
			} while ((xp!=(x+((p[0+noln[i][0]][0]+(chpos[i]*8))*zoom)))||(yp!=(y+(p[0+noln[i][0]][1]*zoom))));
		}
		for (j=1;j<noln[i][1];j++) {
			do {
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				if (xp<(x+((p[j+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp+=zoom;
				if (xp>(x+((p[j+noln[i][0]][0]+(chpos[i]*8))*zoom))) xp-=zoom;
				if (yp<(y+(p[j+noln[i][0]][1]*zoom))) yp+=zoom;
				if (yp>(y+(p[j+noln[i][0]][1]*zoom))) yp-=zoom;
				putimage(xp,yp-10,bitmap[0],XOR_PUT);
				dela(12);
				if (kbhit()) {
					getch();
					return(1);
				}
			} while ((xp!=(x+((p[j+noln[i][0]][0]+(chpos[i]*8))*zoom)))||(yp!=(y+(p[j+noln[i][0]][1]*zoom))));
			putimage(xp,yp-10,bitmap[0],XOR_PUT);
			lineto(x+((p[j+noln[i][0]][0]+(chpos[i]*8))*zoom),y+(p[j+noln[i][0]][1]*zoom));
			putimage(xp,yp-10,bitmap[0],XOR_PUT);
		}
	}
	putimage(xp,yp-10,bitmap[0],XOR_PUT);
	for (i=0;i<9;i++) {
		if (i!=1) {
			floodfill(1+(x+((p[(noln[i][1]-1)+noln[i][0]][0]+(chpos[i]*8))*zoom)),1+(y+(p[(noln[i][1]-1)+noln[i][0]][1]*zoom)),14);
		}
    }
	return(0);
}
