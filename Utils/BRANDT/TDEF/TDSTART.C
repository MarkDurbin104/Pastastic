#include <graphics.h>
#include <math.h>
#include <mem.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>

#define DEGREE 180.0/M_PI

int Gm,Gd;
int G_buf[120]={
	/*T*/		100,100,130,100,130,110,120,110,120,160,110,160,110,110,100,110,100,100,
	/*A*/		145,100,165,100,170,105,170,160,160,160,160,135,150,135,150,160,140,160,140,105,145,100,
	/*A*/		150,110,160,110,160,125,150,125,150,110,
	/*S*/		185,100,205,100,210,105,210,115,200,115,200,110,190,110,190,125,205,125,210,130,210,155,
	/*S*/		205,160,185,160,180,155,180,145,190,145,190,150,200,150,200,135,185,135,180,130,180,105,185,100,
	/*K*/		220,100,230,100,230,125,240,100,250,100,240,130,250,160,240,160,230,135,230,160,220,160,220,100};
double *xlook,*ylook;
int rotapoly(int x,int y,int np,int *pp,double a,double z);
void setuplook(void);

int main(int argc,char **argv) {
	int i,j;
	char fil[30];
	char ver[20];
	int buf[120];
	int buf2[120];
	if (argc>1) strcpy(fil,argv[1]); else strcpy(fil,"DEFINE");
	if (argc>2) strcpy(ver,argv[2]); else strcpy(ver,"0.1");
	Gd=DETECT;
	setuplook();
	initgraph(&Gm,&Gd,"");
	memcpy(buf,G_buf,240);
	memcpy(buf2,buf,240);
	for (j=0;j<120;j+=2) {
		buf[j]+=360;
		buf[j+1]+=180;
	}
	for (i=90;i>(-1);i--) {
		cleardevice();
		setcolor(0);
		drawpoly(60,(int *)buf2);
		rotapoly(175+(i<<2),130+(i<<1),60,(int *)buf,i<<4,i<<3);
		setcolor(11);
		drawpoly(60,(int *)buf);
		memcpy(buf2,buf,240);
		for (j=0;j<8000-(i<<6);j++);
		memcpy(buf,G_buf,240);
		if (kbhit()) {
			cleardevice();
			drawpoly(60,(int *)buf);
			break;
		}
		for (j=0;j<120;j+=2) {
			buf[j]+=(i<<2);
			buf[j+1]+=(i<<1);
		}
	}
	if (kbhit()) getch();
	setfillstyle(9,9);
	floodfill(110,105,11);
	floodfill(150,105,11);
	floodfill(190,105,11);
	floodfill(225,105,11);
	setcolor(9);
	settextstyle(1,0,8);
	settextjustify(1,1);
	outtextxy(410,120,fil);
	for (i=0;i<87;i++) {
		setcolor(0);
		rectangle((-10)+i,(-10)+i,649-i,269-i);
		setcolor(1);
		rectangle(0+i,0+i,639-i,260-i);
	}
	setcolor(9);
	for (;i<90;i++) {
		rectangle((-10)+i,(-10)+i,649-i,269-i);
		rectangle(0+i,0+i,639-i,260-i);
	}
	setcolor(11);
	rectangle((-14)+i,(-14)+i,653-i,273-i);
	rectangle(0+i,0+i,639-i,260-i);
	settextstyle(0,0,1);
	settextjustify(1,1);
	setcolor(14);
	sprintf(fil,"Version %s",ver);
	outtextxy(320,200,fil);
	outtextxy(320,220,"Copyright (c) PMA 1990");
	getch();
	closegraph();
	clrscr();
	return(1);
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
				*(pp+(j*2)+0)=x-len*cos(((2.0*M_PI)/360.0)*(double)z)*xlook[ang];
				*(pp+(j*2)+1)=y-len*ylook[ang];
			}
		}
	}
	return(1);
}
void setuplook(void) {

	int i;
	double degree;
	xlook=malloc(361*sizeof(degree));
	ylook=malloc(361*sizeof(degree));
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
}
