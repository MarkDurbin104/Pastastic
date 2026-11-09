#include <graphics.h>
#include <stdio.h>
#include <conio.h>
#include <fcntl.h>
#include <io.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include "mouse.h"

void grafix(void);
char *remtabs(char *ln,int tabstop);
void textedit(int x,int y,int w,int h,char *t,int col,int bcol);
void prtext(int x,int y,int sx,int sy,int ex,int ey,char *t,int s1,int col,int bcol);
void deltext(int x,int y,int sx,int sy,int ex,int ey,char *t,int s1,int col,int bcol);
void instext(int x,int y,int *sx,int sy,char *t,int s1,int col,char c);

int  G_driver,G_mode;
int  G_maxx,G_maxy;
char lns[100][100];
int  msex,msey,mseb;
int  G_curarray[32];
int  G_fx,G_fy,G_tx,G_ty;

char	test[101]={"Hello There\nThis Is Some Text\nTo Let Me Test\nThe Editing Function\nEBLOCK()"};
#define WINX 20
#define WINY 20
main(int argc,char **argv) {
	grafix();
	cleardevice();
	setcolor(14);
	if (!setupmouse(0,0,21,G_maxx-21,25,G_maxy-25)) {
		closegraph();
		printf("No Mouse Present\n");
		exit(-1);
	}
	setmcurto(2);
	setfillstyle(1,1);
	bar(0,0,G_maxx,G_maxy);
	rectangle(0,0,G_maxx,G_maxy);
	setfillstyle(1,0);
	bar(20,20,G_maxx-20,G_maxy-20);
	rectangle(20,20,G_maxx-20,G_maxy-20);
	setviewport(21,21,G_maxx-21,G_maxy-21,1);
	textedit(100,100,20,5,test,14,4);
	closegraph();
	return(1);
}
void textedit(int x,int y,int w,int h,char *t,int col,int bcol) {
	int ch,cw,cx,cy,sx,sy;
	int a,xit;
	char k;

	ch=textheight("8")+2;
	cw=textwidth("8");
	prtext(x,y,0,0,0,0,t,4,col,bcol);
	mousecur(1);
	xit=0;
	while (!xit) {
		while ((!kbhit())&&(!xit)) {
			if ((a=mousetrap())!=0) {
				if (mseb==1) {
					mousecur(0);
					prtext(x,y,0,0,0,0,t,4,col,bcol);
					mousecur(1);
					sx=((msex-(WINX+1))/cw)*cw;
					sy=((msey-(WINY+1))/ch)*ch;
					if ((sx>(x+((w*cw)/2)))
					||	(sx<(x-((w*cw)/2)))
					||	(sy>(y+(h*ch)))
					||	(sy<y)				) {
						xit=1;
					}
				}
				while (mseb==1) {
					if (a) {
						cx=((msex-(WINX+1))/cw)*cw;
						cy=((msey-(WINY+1))/ch)*ch;
						mousecur(0);
						prtext(x,y,min(sx,cx),min(sy,cy),max(sx,cx),max(sy,cy),t,4,col,bcol);
						setfillstyle(1,15);
						bar(cx,cy+1,cx,cy+ch+1);
						mousecur(1);
					}
					a=mousetrap()&0x0F;
				}
			}
		}
		switch(k=getch()) {
			case 27 : {
				xit=1;
			} break;
			case 8 : {
				mousecur(0);
				deltext(x,y,min(sx,cx),min(sy,cy),max(sx,cx),max(sy,cy),t,4,col,bcol);
				cx=sx;
				cy=sy;
				mousecur(1);
			} break;
			case 13 : {						 /* MUST BE ONE BEFORE default */
				k=10;
			} 								 /* DONT PUT ON A break; */
			default : {
				mousecur(0);
				deltext(x,y,min(sx,cx),min(sy,cy),max(sx,cx),max(sy,cy),t,4,col,bcol);
				a=min(sx,cx);
				instext(x,y,&a,min(sy,cy),t,4,col,k);
				mousecur(1);
			}
		}
	}
}
void prtext(int x,int y,int sx,int sy,int ex,int ey,char *t,int s1,int col,int bcol) {
	char *s,u[2],textln[200];
	int ch,cw;
	int i,j,xx,yy,xp,a;
	u[1]=0;

	settextjustify(1,2);
	settextstyle(2,0,s1);
	ch=textheight("8")+2;
	cw=textwidth("8");
	yy=(y*cw)/cw;
	xx=(x*ch)/ch;
	strcpy(textln,remtabs(t,4));
	s=strtok(textln,"\n");
	i=0;
	a=0;
	while (s!=(char *)NULL) {
		a=max(a,strlen(s)+1);
		s=strtok((char *)NULL,"\n");
		i+=ch;
	}
	setfillstyle(1,0);
	bar(x-((a*cw)/2),y,x+((a*cw)/2),y+i+1);
	strcpy(textln,remtabs(t,4));
	s=strtok(textln,"\n");
	setcolor(col);
	i=0;
	a=0;
	setfillstyle(1,bcol);
	while (s!=(char *)NULL) {
		for(j=0;j<strlen(s);j++) {
			u[0]=s[j];
			xp=(xx-((strlen(s)*cw)/2))+(j*cw);
			if (a<2) {
				if ((yy+i>=sy)&&(xp>=sx)) a=1;
				if ((yy+i>=ey)&&(xp>=ex)) a=2;
			}
			if (a==1) bar(xp-cw/2,yy+i+2,xp+cw/2,yy+i+ch+1);
			outtextxy(xp,yy+i,u);
		}
		s=strtok((char *)NULL,"\n");
		i+=ch;
	}
}
void deltext(int x,int y,int sx,int sy,int ex,int ey,char *t,int s1,int col,int bcol) {
	char *s,textln[200],newln[200];
	int ch,cw;
	int i,j,xx,yy,xp,a,p,b;

	settextjustify(1,2);
	settextstyle(2,0,s1);
	ch=textheight("8")+2;
	cw=textwidth("8");
	yy=(y*cw)/cw;
	xx=(x*ch)/ch;
	strcpy(textln,remtabs(t,4));
	s=strtok(textln,"\n");
	i=a=b=p=0;
	while (s!=(char *)NULL) {
		a=max(a,strlen(s)+1);
		for(j=0;j<strlen(s);j++) {
			xp=(xx-((strlen(s)*cw)/2))+(j*cw);
			if (b<2) {
				if ((yy+i>=sy)&&(xp>=sx)) b=1;
				if ((yy+i>=ey)&&(xp>=ex)) b=2;
			}
			if (b!=1) newln[p++]=s[j];
		}
		if (b!=1) newln[p++]='\n';
		s=strtok((char *)NULL,"\n");
		i+=ch;
	}
	newln[p]=0;
	setfillstyle(1,0);
	bar(x-((a*cw)/2),y,x+((a*cw)/2),y+i+1);
	strcpy(t,newln);
	prtext(x,y,0,0,0,0,t,s1,col,bcol);
}
void instext(int x,int y,int *sx,int sy,char *t,int s1,int col,char c) {
	char *s,textln[200],newln[200];
	int ch,cw;
	int i,j,xx,yy,xp,a,p,b;

	settextjustify(1,2);
	settextstyle(2,0,s1);
	ch=textheight("8")+2;
	cw=textwidth("8");
	yy=(y*cw)/cw;
	xx=(x*ch)/ch;
	strcpy(textln,remtabs(t,4));
	s=strtok(textln,"\n");
	i=a=b=p=0;
	while (s!=(char *)NULL) {
		a=max(a,strlen(s)+1);
		for(j=0;j<strlen(s);j++) {
			xp=(xx-((strlen(s)*cw)/2))+(j*cw);
			if ((yy+i>=sy)&&(xp>=*sx)&&(!b)) {
				newln[p++]=c;
				*sx=xp+2;
				b++;
			}
			newln[p++]=s[j];
		}
		newln[p++]='\n';
		s=strtok((char *)NULL,"\n");
		i+=ch;
	}
	newln[p]=0;
	setfillstyle(1,0);
	bar(x-((a*cw)/2),y,x+((a*cw)/2),y+i+1);
	strcpy(t,newln);
	prtext(x,y,0,0,0,0,t,s1,col,0);
}
char *remtabs(char *ln,int tabstop) {
	int i=0,j,k,l=0;
	char tmp[150];
	for (i=0;i<strlen(ln);i++) {
		if (ln[i]=='\t') {
			k=((l/tabstop)+1)*tabstop;
			for (j=l;j<k;j++) tmp[j]=' ';
			l=k;
		}
		else {
			tmp[l]=ln[i];
			l++;
		}
	}
	tmp[l]=0;
	return(tmp);
}
void grafix(void) {
	int errormode;
	G_driver = DETECT;
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	G_maxx=getmaxx();
	G_maxy=getmaxy();
}
