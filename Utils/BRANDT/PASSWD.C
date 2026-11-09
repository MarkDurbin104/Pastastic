#include <graphics.h>
#include <conio.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <dos.h>
#define TABSTOP 4
void grafix(void);
void pma(void);
void brandt(void);
void drus(void);
void dru(int x,int y);
void drn(int x,int y);
void dri(int x,int y);

char *back="!ï±±ΩÅ]Ω…±ë≈…Õ—’Ÿ›·Â¡!ï±±ΩÅ]Ω…±ë≈…Õ—’Ÿ›·Â¡";
char *entry="πï›µΩπ•ç";

int G_driver,G_mode;
int ohcomeon(void);
main(int argc,char **argv) {
	int i,j=0,len;
	char k;
	FILE *fp;
	long t;
	char tim[100];
	if (argc==1) len=strlen(entry); else len=strlen(argv[1]);
	grafix();
	ctrlbrk(ohcomeon);
	cleardevice();
	if (argc==3) {
		if (argv[2][0]=='u') drus(); else brandt();
	}
	else {
		pma();
	}
	outtextxy(320,250,"Enter Password");
	while (j!=len) {
		for (i=0;i<len;i++) {
			k=getch();
			if (k==3) ohcomeon();
			k=((((k^0x55)<<3)^0xAA)>>1);
			if (argc==1) {
				if ((k==entry[i])||(k==back[i])) {
					j++;
				}
				else {
					j=0;
					i=(-1);
				}
			}
			else {
				if ((k==argv[1][i])||(k==back[i])) {
					j++;
				}
				else {
					j=0;
					i=(-1);
				}
			}
		}
	}
	closegraph();
	t=time(&t);
	strcpy(tim,ctime(&t));
	fp=fopen("c:\\used.log","a+");
	fprintf(fp,"Last Used %s",tim);
	fclose(fp);
	clrscr();
	i=0;
	fp=fopen("c:\\motd","r");
	if (fp!=NULL) {
		textcolor(14);
		while (fgets(tim,80,fp)!=NULL) {
			int cnt, lpos;
			i++;
			lpos=0;
			gotoxy(1,i);
			len=strlen(tim);
			for (cnt=0;cnt<len;cnt++) {
				if (tim[cnt]!=9) {
					cprintf("%c",tim[cnt]);
					lpos++;
				}
				else {
					int trgt;
					trgt=((lpos/TABSTOP)+1)*TABSTOP;
					for (;lpos<trgt;lpos++) cprintf(" ");
				}
			}
			cprintf("\n");
			if (!(i%22)) {
				textcolor(12);
				gotoxy(1,24);
				cprintf("PRESS A KEY");
				getch();
				textcolor(14);
				clrscr();
				i=0;
			}
		}
	}
	if (i) {
		textcolor(12);
		gotoxy(1,24);
		cprintf("PRESS A KEY");
		getch();
		textcolor(14);
		clrscr();
	}
	fclose(fp);
	textcolor(15);
	clrscr();
	return(1);
}
void grafix(void) {
	int errormode;
	G_driver = VGA;
	G_mode = VGAHI;
	errormode=registerbgidriver(EGAVGA_driver);
	if( errormode < 0 ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		return;
	}
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		return;
	}
}
int ohcomeon(void) {
	int i;
	setcolor(15);
	outtextxy(320,300,"Don't Be A Plonker");
	for (i=0;i<32766;i++);
	for (i=0;i<32766;i++);
	setcolor(0);
	outtextxy(320,300,"Don't Be A Plonker");
	return(1);
}
void pma(void) {
	setcolor(9);
	moveto(320,10);
	lineto(420,80);
	lineto(320,150);
	lineto(220,80);
	lineto(320,10);
	setfillstyle(11,9);
	floodfill(320,80,9);
	setcolor(0);
	setfillstyle(1,0);
	pieslice(320,80,0,360,50);
	setcolor(9);
	circle(320,80,51);
	bar(320,130,380,110);
	moveto(320,131);
	lineto(380,131);
	lineto(380,110);
	lineto(360,110);
	settextstyle(1,0,4);
	settextjustify(1,2);
	setcolor(12);
	outtextxy(320,200,"P.M.A. Computer Consultants Ltd.");
}
void brandt(void) {
	setcolor(14);
	circle(320,80,10);
	moveto(330,80);
	lineto(350,80);
	lineto(350,40);
	lineto(370,40);
	lineto(370,120);
	lineto(390,120);
	lineto(390,40);
	lineto(410,40);
	lineto(410,80);
	lineto(420,80);
	moveto(310,80);
	lineto(300,80);
	lineto(280,150);
	lineto(260,10);
	lineto(245,130);
	lineto(230,30);
	lineto(220,100);
	lineto(210,60);
	lineto(205,80);
	settextstyle(1,0,4);
	settextjustify(1,2);
	setcolor(12);
	outtextxy(320,200,"Brandt Computer Systems Ltd.");
}
void drus(void) {
	dru(100,50);
	drn(178,50);
	dri(260,50);
}
void dru(int x,int y) {
	setcolor(12);
	moveto(x,y);
	lineto(x+38,y);
	lineto(x+38,y+2);
	lineto(x+30,y+2);
	lineto(x+30,y+60);
	ellipse(x+46,y+60,180,0,16,14);
	moveto(x+62,y+60);
	lineto(x+62,y+2);
	lineto(x+54,y+2);
	lineto(x+54,y);
	lineto(x+74,y);
	lineto(x+74,y+2);
	lineto(x+66,y+2);
	lineto(x+66,y+60);
	ellipse(x+46,y+60,270,0,20,18);
	moveto(x+46,y+78);
	lineto(x+28,y+78);
	ellipse(x+28,y+60,180,270,20,18);
	moveto(x+8,y+60);
	lineto(x+8,y+2);
	lineto(x,y+2);
	lineto(x,y);
	setfillstyle(1,12);
	floodfill(x+16,y+10,12);
}
void drn(int x,int y) {
	setcolor(12);
	moveto(x,y);
	lineto(x+34,y);
	lineto(x+62,y+35);
	lineto(x+62,y+2);
	lineto(x+54,y+2);
	lineto(x+54,y);
	lineto(x+74,y);
	lineto(x+74,y+2);
	lineto(x+66,y+2);
	lineto(x+66,y+78);
	lineto(x+58,y+78);
	lineto(x+12,y+20);
	lineto(x+12,y+76);
	lineto(x+20,y+76);
	lineto(x+20,y+78);
	lineto(x,y+78);
	lineto(x,y+76);
	lineto(x+8,y+76);
	lineto(x+8,y+2);
	lineto(x,y+2);
	lineto(x,y);
	setfillstyle(1,12);
	floodfill(x+16,y+10,12);
}
void dri(int x,int y) {
	setcolor(12);
	moveto(x,y);
	lineto(x+38,y);
	lineto(x+38,y+2);
	lineto(x+30,y+2);
	lineto(x+30,y+76);
	lineto(x+38,y+76);
	lineto(x+38,y+78);
	lineto(x,y+78);
	lineto(x,y+76);
	lineto(x+8,y+76);
	lineto(x+8,y+2);
	lineto(x,y+2);
	lineto(x,y);
	circle(x+19,y-25,15);
	setfillstyle(1,12);
	floodfill(x+16,y+10,12);
	floodfill(x+19,y-25,12);
}
