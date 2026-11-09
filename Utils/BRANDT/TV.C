#include <dos.h>
#include <math.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <graphics.h>
#include <ctype.h>
#include "tv.h"		/* taskview main include file */
#include "comms.h"  /* communications */

#define NUMDRGS 64		/* number of drawings in the table */

int		GraphDriver; 	/* ega cga etc */
int 	GraphMode;		/* screen mode ie 2 for text */
double	aspect;			/* so we can get a square, used for printing */
char 	far		*textlns[NUMDRGS];	/* text associated with each drg */
int		maxtext[NUMDRGS];			/* length of each text line */
int		textpos[NUMDRGS];			/* cursor position in text */
char	overtext=0;				/* opaque or transparent defaults to opaque*/
int		textcol=EGA_WHITE;				/* defaults to white */
int		G_tno=0;        		/* is text on or off default off or 1 to 9 for position of text */
char	helplns[2000];			/* Help text */
int		maxhelp;				/* Number of help chars */
int		helppos;				/* current position within help */
char	overhelp=0;				/* opaque or transparent defaults to opaque */
int		helpcol=EGA_WHITE;				/* defaults to white */
int		G_hno=0;			/* is help on or off default off or 1 to 9 for position of help */
int		maxx,maxy;		/* maximum number of x and y pixels set by grafix() */
int		pickno;			/* current drawing */
char	G_partnumb[NUMDRGS +2][20];	/* part numbers of each drawing */
char	G_filename[80];           	/* current file */
int		G_numbparts[2][NUMDRGS + 2];/* number of parts required,number of parts remaining */
int		G_notosel;		/* number of files we can select from */
char	G_omitlev;		/* colour which will not be shown */
char	G_steplev;		/* colour reached on a step through colours */
char	G_onlylev;		/* only colour that was shown. High Priority */
char	maxlevel[NUMDRGS + 2];	/* number of colours available */
int		difx[66];				/* width of drawing */
int		dify[66];				/* height of drawing */
int		minx[66];				/* lowest x position */
int		miny[66];				/* lowest y position */
int		curposx,curposy;
int		nopolys[66];            /* number of polygons in each diagram */
int		maxpoints[66];			/* the maximum number of points ****** */
int		maxnopps;				/* the maximum number of poly points */
int		nofiles;				/* the number of drawings on the screen */
int		G_swap[66];				/******************/
int		crossbdn;				/* number drawings across grid */
int		G_level1;				/******************/
char    bars[51][10]={			/* bit maps for series 39 bar codes */
	"010101000",		/*$*/
	"000101010",		/*%*/
	"010010100",		/***/
	"010001010",		/*+*/
	"011000100",		/* */
	"010000101",		/*-*/
	"110000100",		/*.*/
	"010100010",		/*/*/
	"000110100",		/*0*/
	"100100001",		/*1*/
	"001100001",		/*2*/
	"101100000",		/*3*/
	"000110001",		/*4*/
	"100110000",		/*5*/
	"011100000",		/*6*/
	"000100101",		/*7*/
	"100100100",		/*8*/
	"001100100",		/*9*/
	"100001001",		/*A*/
	"001001001",		/*B*/
	"101001000",		/*C*/
	"000011001",		/*D*/
	"100011000",		/*E*/
	"001011000",		/*F*/
	"000001101",		/*G*/
	"100001100",		/*H*/
	"001001100",		/*I*/
	"000011100",		/*J*/
	"100000011",		/*K*/
	"001000011",		/*L*/
	"101000010",		/*M*/
	"000010011",		/*N*/
	"100010010",		/*O*/
	"001010010",		/*P*/
	"000000111",		/*Q*/
	"100000110",		/*R*/
	"001000110",		/*S*/
	"000010110",		/*T*/
	"110000001",		/*U*/
	"011000001",		/*V*/
	"111000000",		/*W*/
	"010010001",		/*X*/
	"110010000",		/*Y*/
	"011010000"};		/*Z*/

int estat,estat1=1;             /* exit status from keyboard routines */
int screen[2000];				/* save the current screen before starting up */
int terminal[2160];				/* holds data that came in while displaying drg */
struct pnts far **polp[NUMDRGS+2];	/* pointers to the polygon points */
char bitmap[4][1000];           /* contains corner images */
char copyimg[2000];				/* copyright image */
char copymsg[30];				/* copyright message */
int G_zoom;						/* current zoom level */
int colours[16];	/* the sixteen colours are copied from config file  into this array */
int G_winpos[36];   /* ************************/
struct text_info scrsave;		/* screen save structure described in conio.h */
struct term_info G_term;		/* same as above for terminal */
int		termx;					/* terminal x and y positions */
int		termy;                  
int		termattr;				/* terminal attribute */
int		interm;                 /* 1 = in terminal emulator, 0 = use buffer */
int		locecho=0;				/* says if there should be an echo on term emulator */
int far *scr=MK_FP(0xB800,0);	/* makes a far pointer to screen */
								/* NOTE if PC is monocrome 0xB000 */
char chpos[10]={(-4),(-3),(-3),(-2),(-1),0,1,2,3,4}; /* TASKVIEW positions */
char noln[9][2]={{0,9},{20,7},{9,11},{27,29},{56,15},{71,13},{84,13},{97,13},{110,19}};
char p[129][2]={
	/*T*/		{0,0},{7,0},{7,1},{4,1},{4,9},{3,9},{3,1},{0,1},{0,0},
	/*A*/		{0,2},{2,0},{5,0},{7,2},{7,9},{6,9},{6,5},{1,5},{1,9},{0,9},{0,2},
				{1,3},{3,1},{4,1},{6,3},{6,4},{1,4},{1,3},
	/*S*/		{0,1},{1,0},{6,0},{7,1},{7,3},{6,3},{6,2},{5,1},{2,1},{1,2},{1,3},
				{2,4},{6,4},{7,5},{7,8},{6,9},{1,9},{0,8},{0,6},{1,6},{1,7},{2,8},
				{5,8},{6,7},{6,6},{5,5},{1,5},{0,4},{0,1},
	/*K*/		{0,0},{1,0},{1,4},{5,0},{6,0},{6,1},{3,4},{3,5},{6,8},{6,9},{5,9},
				{1,5},{1,9},{0,9},{0,0},
	/*V*/		{0,0},{1,0},{1,5},{3,7},{4,7},{6,5},{6,0},{7,0},{7,6},{4,9},{3,9},
				{0,6},{0,0},
	/*I*/		{0,0},{7,0},{7,1},{4,1},{4,8},{7,8},{7,9},{0,9},{0,8},{3,8},{3,1},
				{0,1},{0,0},
	/*E*/		{0,0},{7,0},{7,1},{1,1},{1,4},{5,4},{5,5},{1,5},{1,8},{7,8},{7,9},
				{0,9},{0,0},
	/*W*/		{0,0},{1,0},{1,7},{2,7},{3,6},{4,6},{5,7},{6,7},{6,0},{7,0},{7,8},
				{6,9},{5,9},{4,8},{3,8},{2,9},{1,9},{0,8},{0,0}};
char G_keycode[255];	/* loaded from the config file. Which key press calls which func */

int  brkrout();
char keyfunc(void);
void getconfig(void);
void kup(int step);
void kdown(int step);
void kleft(int step);
void kright(int step);
void kzoomin(void);
void kzoomout(void);
void prpart(void);
void dump(void);
void prbar(void);
void reinstate(void);
void inslev(void);
void omitlev(void);
void steplev(void);
void restlev(void);
void tmode(void);
void ttop(void);
void tbot(void);
void tup(void);
void tdn(void);
void hmode(void);
void htop(void);
void hbot(void);
void hup(void);
void hdn(void);
int menu(void);
void form(void);
/*================================= main ==================================*/
main (int argc,char **argv) {
	int i,fdes;
	ctrlbrk(brkrout); /* sets ctrl brk up to go to application routine */
	getconfig();	  /* gets the config data */
	for(i=0;i<NUMDRGS;i++) textpos[i]=0;	/* set text cursors to top of text */
	for(i=48;i<58;i++) G_keycode[i]=i;		/* set keycodes 0 -9 to 0 -9. as config changed them */
	gettextinfo(&scrsave);                  /** save current screen **/
	SAVECSTO(screen);

	setupterm();							/* set up terminal emulator */
	setup();								/* initialises variables */
	setcur();								/* gets corner images */
	fdes=open("tv.hlp",O_RDONLY|O_BINARY);  /* open help file */
	if (fdes==(-1))
	{
		printf("Can't Open Help File.\n");
		close(fdes);
		maxhelp=0;					/* number of help chars to zero */
	}
	else
	{
		maxhelp=read(fdes,helplns,2000); /* number of bytes read */
		close(fdes);
		for (i=0;i<maxhelp;i++)
		{
			if (helplns[i]=='\n') helplns[i]=0;   /* null terminate strings */
			if (helplns[i]=='\r') helplns[i]=32;
		}                    				/* sticks blank lines on the end */
		for (i=maxhelp;i<min(maxhelp+20,2000);i++) helplns[i]=0;
	}
	do
	{
		closegraph();		/* closes the graphics screen */
		if (argc<2)			/* file extension */
		{
			if (!(selafile("*.*"))) /* displays all the files */
			{
				printf("Can't access files.\n");
				exit(-1);
			}
		}
		 else
		 {
			if (!(selafile(argv[1])))
			{
				printf("Can't access files.\n");
				exit(-1);
			}
		}
		grafix();
		startup(G_filename);		/* file picked off of list */
		estat=getkeys();			/* keyboard routine */
	} while (!estat);
	reset();         				/* vectors reset , memory cleared etc */
	return(0);
}
/*=============================== getkeys =================================*/
int getkeys(void)
{
	char ch;

	cursor(pickno);					/* sets the current corners */
/*	setupmouse(320,240,0,639,0,439);
	mousecur(0);                    */
	while (!(estat))
	{
		while (!kbhit())
		{ 					/*&&!mousestat()){*/
			if ((ch=getrx())!=(-1)) /* gets one char or -1 from SERIAL PORT */
				placrx(ch);			/* places char on the terminal screen */
			if (estat) return(1);
		}
		cursor(pickno);				/* clears the current corners */
		switch(keyfunc()) {			/* gets char from KEYBOARD */
/*UP*/		case 1  : kup(1);  				break;  /* 1 = 1 step */
/*DOWN*/	case 2  : kdown(1);				break;
/*LEFT*/	case 3  : kleft(1);   			break;
/*RIGHT*/	case 4  : kright(1);   			break;
/*ZM IN*/	case 9  : kzoomin();   			break;
/*ZM OUT*/	case 10 : kzoomout();  			break;
/*T MODE*/	case 11 : tmode();  			break;  /* put it in text mode */
/*T/H TOP*/	case 12 : if (G_tno) ttop(); else if (G_hno) htop();	break;
/*T/H BOT*/	case 13 : if (G_tno) tbot(); else if (G_hno) hbot();	break;
/*T/H PUP*/	case 14 : if (G_tno) tup(); else if (G_hno) hup();		break;
/*T/H PDN*/	case 15 : if (G_tno) tdn(); else if (G_hno) hbot();		break;
/*SC DMP*/	case 16 : dump();      					break; /* screen dump */
/*PR BC*/	case 17 : prbar();     					break; /* print the bar code */
/*PR No*/	case 18 : prpart();    					break; /* print the part number */
/*OMIT*/	case 19 : omitlev();   					break; /* omit a level */
/*STEP*/	case 20 : steplev();   					break; /* step through the levels */
/*INSERT*/	case 21 : inslev();    					break; /* view 1 level only */
/*RESTORE*/	case 22 : restlev();   					break; /* restore to all colours */
/*REIN*/	case 23 : reinstate(); 					break; /* reinstate the part */
/*TERM*/	case 24 : closegraph();			/* close graphics mode */
					  switchscr(); 	break; /* switch to terminal */
/*H MODE*/	case 25 : hmode();  					break; /* help mode */
/*LIST*/	case 26 : if (G_notosel>1)
					  {                 /* go back if more than one file available */
						  G_tno=0;
						  G_hno=0;
						  farfreepolys();
						  return(0);
					  }   							break;
			/** The number indicates where the help is displayed on the screen **/

			case '0' : {
				if (G_tno)					/* if we are in text mode */
				{
					if (overtext)
						overtext=0;
					else
						overtext=1;
					blancdisp();     		/* blanks the display & redraws title bar at bottom */
					drawdiag(pickno,curposx,curposy,G_zoom,0); /* draws a diagram in full */
				}
				if (G_hno)					/* if we are in graphics mode */
				{
					if (overhelp) overhelp=0; else overhelp=1;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0); /* draws a diagram in full */
				}
			} break;
			case '1' : {
				if (G_tno) {
					G_tno=1;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=1;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '2' : {
				if (G_tno) {
					G_tno=2;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=2;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '3' : {
				if (G_tno) {
					G_tno=3;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=3;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '4' : {
				if (G_tno) {
					G_tno=4;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=4;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '5' : {
				if (G_tno) {
					G_tno=5;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=5;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '6' : {
				if (G_tno) {
					G_tno=6;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=6;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '7' : {
				if (G_tno) {
					G_tno=7;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=7;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '8' : {
				if (G_tno) {
					G_tno=8;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=8;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
			case '9' : {
				if (G_tno) {
					G_tno=9;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (G_hno) {
					G_hno=9;
					blancdisp();
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
			} break;
		}
		cursor(pickno);		/* redraws corners */
	}
	return(1);
}
/*============================= setup =====================================*/
int setup(void)
{
	int i;
	grafix(); /* set graphics mode */

	cleardevice();
	setcolor(EGA_YELLOW);
	setfillstyle(SOLID_FILL,EGA_BLUE);
	bar(400,maxy+1,maxx,maxy+15);   /* draws solid  block */
	rectangle(400,maxy+1,maxx,maxy+15);
	setfillstyle(SOLID_FILL,EGA_BLACK);
	strcpy(copymsg,"UBTLWJFX!w1/6!!)d*!QNB!2::1"); /* copyright message */
	for(i=0;i<27;i++) copymsg[i]--; /* subtract 1 from all copyright chars */
	outtextxy(410,maxy+5,copymsg);
	getimage(400,maxy+1,maxx,maxy+15,copyimg); /* sticks image from screen in memory */
	cleardevice();
#ifdef FRONT      /* Does taskview nice writing */
#ifdef DEMOM	  /* Does Demonstration writing */
	setcolor(EGA_LIGHTBLUE);
	settextjustify(CENTER_TEXT,CENTER_TEXT);
	strcpy(copymsg,"Efnpotusbujpo");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,250,copymsg);
	strcpy(copymsg,"Wfstjpo");
	for(i=0;i<7;i++) copymsg[i]--;
	outtextxy(320,260,copymsg);
	strcpy(copymsg,"Dpqzsjhiu!)d*");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,270,copymsg);
	strcpy(copymsg,"Q/N/B/");
	for(i=0;i<6;i++) copymsg[i]--;
	outtextxy(320,280,copymsg);
	strcpy(copymsg,"Dpnqvufs");
	for(i=0;i<8;i++) copymsg[i]--;
	outtextxy(320,290,copymsg);
	strcpy(copymsg,"Dpotvmubout");
	for(i=0;i<11;i++) copymsg[i]--;
	outtextxy(320,300,copymsg);
	strcpy(copymsg,"Mjnjufe/!2::1");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,310,copymsg);
#endif
	setcolor(15);
	moveto(2,10);
	lineto(0,8);		/* Draws the little pencil */
	lineto(8,0);
	lineto(10,2);
	lineto(2,10);
	lineto(0,10);
	lineto(0,8);
	getimage(0,0,10,10,bitmap[0]);	/* saves the little pencil */
	setcolor(8);
	for(i=0;i<66;i++) line(23+(i*9),105,23+(i*9),204);  /* draws the grid */
	for(i=0;i<12;i++) line(23,105+(i*9),607,105+(i*9));
	setcolor(14);
	setfillstyle(1,14);
	if (pltv(320,114,9))		/* plot taskview */
		return(0);				/* exit at keypress */
	dela(250);
	cleardevice();
#ifdef DEMOM
	setcolor(9);
	settextjustify(1,1);
	strcpy(copymsg,"Efnpotusbujpo");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,250,copymsg);
	strcpy(copymsg,"Wfstjpo");
	for(i=0;i<7;i++) copymsg[i]--;
	outtextxy(320,260,copymsg);
	strcpy(copymsg,"Dpqzsjhiu!)d*");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,270,copymsg);
	strcpy(copymsg,"Q/N/B/");
	for(i=0;i<6;i++) copymsg[i]--;
	outtextxy(320,280,copymsg);
	strcpy(copymsg,"Dpnqvufs");
	for(i=0;i<8;i++) copymsg[i]--;
	outtextxy(320,290,copymsg);
	strcpy(copymsg,"Dpotvmubout");
	for(i=0;i<11;i++) copymsg[i]--;
	outtextxy(320,300,copymsg);
	strcpy(copymsg,"Mjnjufe/!2::1");
	for(i=0;i<13;i++) copymsg[i]--;
	outtextxy(320,310,copymsg);
#endif
	prtv(320,114,9,14);                /* draws with fill */
	dela(250);
	for (i=9;i>0;i--) {
		if (prtv(239+(i*9),42+i*8,i,EGA_YELLOW)) return(0);  /* zooms it away in yellow */
	}
	for (i=9;i>0;i--) {
		if (prtv(239+(i*9),42+i*8,i,EGA_BLACK)) return(0);  /* zooms it away in black */
	}
	prtv(242,52,1,14);
	putimage(200,50,copyimg,COPY_PUT); /* put back copyright */
	sleep(1);
#ifdef BSCRL
	putimage(200,50,copyimg,COPY_PUT);
	dela(50);
	for (i=65;i<maxy+1;i+=15) {
		putimage(200,i,copyimg,COPY_PUT);
		dela(5);
		putimage(200,i-15,copyimg,XOR_PUT);
		if (kbhit()) {
			getch();
			return(0);
		}
	}
	putimage(200,i-15,copyimg,XOR_PUT);
	putimage(200,maxy+1,copyimg,COPY_PUT);
	for (i=200;i<380;i+=20) {
		putimage(i,maxy+1,copyimg,XOR_PUT);
		dela(5);
		putimage(i+20,maxy+1,copyimg,COPY_PUT);
	}
#endif
#endif
	if (kbhit()) {
		getch();
		return(0);
	}
	return(1);
}
void setcur(void) {
	cleardevice();
	setcolor(13^BACKCOL);
	line(0,0,0,20);
	line(0,0,20,0);
	getimage(0,0,20,20,bitmap[0]);
	cleardevice();
	line(0,0,20,0);
	line(20,0,20,20);
	getimage(0,0,20,20,bitmap[1]);
	cleardevice();
	line(20,0,20,20);
	line(20,20,0,20);
	getimage(0,0,20,20,bitmap[2]);
	cleardevice();
	line(20,20,0,20);
	line(0,0,0,20);
	getimage(0,0,20,20,bitmap[3]);
}
void startup(char *filename) {
	int i;
	settextstyle(0,0,1);
	settextjustify(0,2);
	maxnopps=0;
	for (i=0;i<NUMDRGS;i++) {
		dify[i]=difx[i]=-32766;
		maxpoints[i]=0;
	}
	G_zoom=-1;
	pickno=0;
	blancdisp();
	loadfiles(filename);
	crossbdn=sqrt(nofiles);
	if ((crossbdn*crossbdn)<nofiles) crossbdn++;
	if (nofiles>1) {
		for (i=0;i<nofiles;i++) drawmini(i,crossbdn);
	}
	else {
		drawmini(0,1);
		G_zoom=0;
		blancdisp();
		curposx=difx[0]/2;
		curposy=dify[0]/2;
		drawdiag(0,curposx,curposy,G_zoom,0);
	}
}
void reset(void) {
	restcomms();
   	closegraph();
	LOADCSFROM(screen);
	textattr(scrsave.attribute);
	gotoxy(scrsave.curx,scrsave.cury);
}
void setupterm(void) {
	setbaud(G_term.baud,G_term.bits,G_term.parity,G_term.stop);
	setcomms();
	textcolor(15);
	textbackground(0);
	clrscr();
	textcolor(14);
	textbackground(1);
	gotoxy(1,1);
	cprintf("  TASKVIEW Terminal Emulator                       ");
	textcolor(12);
	cprintf("%5s ",G_term.type);
	cprintf("%5d ",G_term.baud);
	cprintf("%d ",G_term.bits);
	cprintf("%c ",G_term.parity);
	cprintf("%d ",G_term.stop);
	cprintf("%8s  ",G_term.handshake);
	textcolor(15);
	textbackground(0);
	SAVECSTO(terminal);
	termx=1;
	termy=1;
	termattr=(15);
	interm=0;
	clrscr();
}
void dela(int mili) {
	int i,j;
	for (i=0;i<mili*200;i++) {
		j=i;
	}
	i=j;
}
int brkrout() {
	if (G_tno) {
		G_tno=0;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
	else {
		if (G_hno) {
			G_hno=0;
			blancdisp();
			drawdiag(pickno,curposx,curposy,G_zoom,0);
		}
		else {
			estat=1;
		}
	}
	return(1);
}
char keyfunc(void) {
	char k;
/*	if ((m=(mousetrap()&0xFF))!=0) {
		if (m&4) {
			curposx+=((msex-320)/5)*(difx[pickno]/(CURSTEP*(2*G_zoom+1)));
			setmousexto(320);
			if (curposx>difx[pickno]) curposx=difx[pickno];
			blancdisp();
			if ((curposx+difx[pickno]/(CURSTEP*(2*G_zoom+1)))<difx[pickno]) {
				drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
			}
			else {
				drawdiag(pickno,curposx,curposy,G_zoom,0);
			}
			if (m==4) return(0);
			m&=0x0FB;
		}
		else {
			if (m&8) {
				curposx-=((320-msex)/5)*(difx[pickno]/(CURSTEP*(2*G_zoom+1)));
				setmousexto(320);
				if (curposx<0) curposx=0;
				blancdisp();
				if ((curposx-difx[pickno]/(CURSTEP*(2*G_zoom+1)))>0) {
					drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
				}
				else {
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				if (m==8) return(0);
				m&=0x0F7;
			}
		}
		if (m&1) {
			curposy-=(msey-240)*dify[pickno]/(CURSTEP*(2*G_zoom+1));
			setmouseyto(240);
			if (curposy<0) curposy=0;
			blancdisp();
			if ((curposy+dify[pickno]/(CURSTEP*(2*G_zoom+1)))<dify[pickno]) {
				drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
			}
			else {
				drawdiag(pickno,curposx,curposy,G_zoom,0);
			}
			if (m==1) return(1);
			m&=0x0FE;
		}
		if (m&2) {
			curposy+=(240-msey)*dify[pickno]/(CURSTEP*(2*G_zoom+1));
			setmouseyto(240);
			if (curposy>dify[pickno]) curposy=dify[pickno];
			blancdisp();
			if ((curposy-dify[pickno]/(CURSTEP*(2*G_zoom+1)))>0) {
				drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
			}
			else {
				drawdiag(pickno,curposx,curposy,G_zoom,0);
			}
			if (m==2) return(2);
			m&=0x0FD;
		}
		if (m&16) {
			if (mseb==1) {
				return(9);
			}
			if (mseb==2) {
				return(10);
			}
		}
	}
	if (m) return(0);*/
	k=getch();
	if (k>0) {
		return(G_keycode[k]);
	}
	else {
		k=getch();
		return(G_keycode[k+128]);
	}
}
void kright(int step) {
	if (G_zoom==(-1)) {
		if (pickno<nofiles-1) pickno++;
	}
	else {
		if (curposx>difx[pickno]) curposx=difx[pickno];
		curposx+=difx[pickno]/((CURSTEP/step)*(2*G_zoom+1));
		blancdisp();
		if ((curposx+difx[pickno]/((CURSTEP/step)*(2*G_zoom+1)))<difx[pickno]) {
			drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
		}
		else {
			drawdiag(pickno,curposx,curposy,G_zoom,0);
		}
	}
}
void kleft(int step) {
	if (G_zoom==-1) {
		if (pickno>0) pickno--;
	}
	else {
		if (curposx<0) curposx=0;
		curposx-=difx[pickno]/((CURSTEP/step)*(2*G_zoom+1));
		blancdisp();
		if ((curposx-difx[pickno]/((CURSTEP/step)*(2*G_zoom+1)))>0) {
			drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
		}
		else {
			drawdiag(pickno,curposx,curposy,G_zoom,0);
		}
	}
}
void kdown(int step) {
	if (G_zoom==-1) {
		if (pickno<(crossbdn*(crossbdn-1))) pickno+=crossbdn;
		if (pickno>nofiles-1) pickno=nofiles-1;
	}
	else {
		if (curposy>dify[pickno]) curposy=dify[pickno];
		curposy+=dify[pickno]/((CURSTEP/step)*(2*G_zoom+1));
		blancdisp();
		if ((curposy+dify[pickno]/((CURSTEP/step)*(2*G_zoom+1)))<dify[pickno]) {
			drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
		}
		else {
			drawdiag(pickno,curposx,curposy,G_zoom,0);
		}
	}
}
void kup(int step) {
	if (G_zoom==-1) {
		if (pickno>crossbdn-1) pickno-=crossbdn;
	}
	else {
		if (curposy<0) curposy=0;
		curposy-=dify[pickno]/((CURSTEP/step)*(2*G_zoom+1));
		blancdisp();
		if ((curposy-dify[pickno]/((CURSTEP/step)*(2*G_zoom+1)))>0) {
			drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
		}
		else {
			drawdiag(pickno,curposx,curposy,G_zoom,0);
		}
	}
}
void kzoomin(void) {
	if (G_numbparts[1][pickno]!=0) {
		G_zoom++;
		if (G_zoom>G_swap[pickno]+MAXZOOM) {
			G_zoom=G_swap[pickno]+MAXZOOM;
		}
		else {
			blancdisp();
			if (G_zoom==0) {
				curposx=difx[pickno]/2;
				curposy=dify[pickno]/2;
				drawdiag(pickno,curposx,curposy,G_zoom,0);
			}
			else {
				if ((G_zoom+1)>G_swap[pickno]+MAXZOOM) {
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				else {
					drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
				}
			}
		}
	}
}
void kzoomout(void) {
	int i;
	if (G_zoom!=(-1)) {
		if (!((G_zoom==0)&&(nofiles==1))) {
			G_zoom--;
			if (G_zoom<0) {
				G_omitlev=0;
				G_onlylev=0;
				G_steplev=0;
				G_zoom=-1;
				blancdisp();
				for (i=0;i<nofiles;i++) drawmini(i,crossbdn);
			}
			else {
				blancdisp();
				if (G_zoom==0) {
					drawdiag(pickno,curposx,curposy,G_zoom,0);
				}
				else {
					drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
				}
			}
		}
	}
}
void prpart(void) {
	int i;
	FILE *printer;
#ifdef SPNO   /*	print part No. on serial port	*/
	char tmpstr[80],tmpstr1[80];
#endif
	if (G_zoom!=(-1)) {
		G_numbparts[1][pickno]--;
		G_zoom=-1;
		blancdisp();
		for (i=0;i<nofiles;i++) drawmini(i,crossbdn);
#ifdef PPNO   /*	print part No. on parallel port	*/
		if ((printer=fopen("PRN","w"))!=NULL) {
			fprintf(printer,"%s\n",G_partnumb[pickno]);
			fclose(printer);
		}
#endif
#ifdef SPNO   /*	print part No. on serial port	*/
		strcpy(tmpstr,"COM");
		itoa(SPNO,tmpstr1,10);
		strcat(tmpstr,tmpstr1);
		if ((printer=fopen(tmpstr,"w"))!=NULL) {
			fprintf(printer,"^XA\n^FO30,50^B3,,100,,Y^FD%s\n^XZ\n",G_partnumb[pickno]);
			fclose(printer);
		}
#endif
	}
}
void dump(void) {
	int i,j,l,prbyte;
	FILE *printer;
	if (G_zoom!=(-1)) {
		if ((printer=fopen("PRN","w"))!=NULL) {
			blancdisp();
			if (G_zoom==0) {
				adjdiag(pickno,difx[pickno]/2,dify[pickno]/2,G_zoom);
			}
			else {
				adjdiag(pickno,curposx,curposy,G_zoom);
			}
			fprintf(printer,"Part [%s] Printed From P.M.A. TASKVIEW\n\n",G_partnumb[pickno]);
			fprintf(printer,"%cU1%cA%c",27,27,8);
			for (i=0;i<maxy-1;i+=8) {
				fprintf(printer,"%cZ%c%c",27,(maxx*3)%256,(maxx*3)/256);
				for (j=0;j<maxx;j++) {
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
			blancdisp();
			if (G_zoom==0) {
				drawdiag(pickno,curposx,curposy,G_zoom,0);
			}
			else {
				drawdiag(pickno,curposx,curposy,G_zoom,QUICK);
			}
		}
	}
	else {
		if ((printer=fopen("PRN","w"))!=NULL) {
			fprintf(printer,"Part [%s] Printed From P.M.A. TASKVIEW\n\n",G_partnumb[pickno]);
			fprintf(printer,"%cU1%cA%c",27,27,8);
			for (i=0;i<maxy-1;i+=8) {
				fprintf(printer,"%cZ%c%c",27,(maxx*3)%256,(maxx*3)/256);
				for (j=0;j<maxx;j++) {
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
}
void prbar(void) {
	char pn[30];
	int i,j,l,m;
	FILE *printer;
	if (G_zoom!=(-1)) {
	   G_numbparts[1][pickno]--;
	   G_zoom=-1;
	   blancdisp();
	   for (i=0;i<nofiles;i++) drawmini(i,crossbdn);
	   if ((printer=fopen("PRN","w"))!=NULL) {
		   fprintf(printer,"%cU1%cA%c",27,27,8);
		   fprintf(printer,"PART NUMBER %s\n\n",G_partnumb[pickno]);
		   pn[0]=2;
		   for (l=0;l<strlen(G_partnumb[pickno]);l++) {
			   switch(G_partnumb[pickno][l]) {
				   case 36 : {
					   pn[l+1]=0;
				   }break;
				   case 37 : {
					   pn[l+1]=1;
				   }break;
				   case 32 : {
					   pn[l+1]=4;
				   }break;
				   default : {
					   pn[l+1]=G_partnumb[pickno][l]-40;
				   }
			   }
		   }
		   pn[l+1]=2;
		   pn[l+2]=0;
		   for(l=0;l<5;l++) {
			   m=1;
			   for (i=0;i<strlen(pn);i++) {
				   for (j=0;j<9;j++) {
					   m+=2;
					   if (bars[pn[i]-48][j]==1) m+=4;
				   }
				   m+=2;
			   }
			   fprintf(printer,"%cZ%c%c",27,(m*3)%256,(m*3)/256);
			   for (i=0;i<strlen(pn);i++) {
				   for (j=0;j<9;j++) {
					   if (j&1) {
						   fprintf(printer,"%c%c%c%c",0,0,0,0);
						   if (bars[pn[i]-48][j]=='1') {
							   fprintf(printer,"%c%c%c%c%c%c%c%c",0,0,0,0,0,0,0,0);
						   }
					   }
					   else {
						   fprintf(printer,"%c%c%c%c",255,255,255,255);
						   if (bars[pn[i]-48][j]=='1') {
							   fprintf(printer,"%c%c%c%c%c%c%c%c",255,255,255,255,255,255,255,255);
						   }
					   }
				   }
				   fprintf(printer,"%c%c%c%c",0,0,0,0);
			   }
			   fprintf(printer,"\n");
		   }
		   fprintf(printer,"\n\n");
		   fclose(printer);
	   }
   }
}
void reinstate(void) {
	int i;
	if (G_numbparts[1][pickno]<G_numbparts[0][pickno]) G_numbparts[1][pickno]++;
	G_zoom=-1;
	blancdisp();
	for (i=0;i<nofiles;i++) drawmini(i,crossbdn);
}
void omitlev(void) {
	if (G_zoom!=(-1)) {
		G_omitlev++;
		if (G_omitlev>maxlevel[pickno]) G_omitlev=1;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void steplev(void) {
	if (G_zoom!=(-1)) {
		G_steplev++;
		if (G_steplev>maxlevel[pickno]) G_steplev=1;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void inslev(void) {
	if (G_zoom!=(-1)) {
		G_onlylev++;
		if (G_onlylev>maxlevel[pickno]) G_onlylev=1;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void restlev(void) {
	if (G_zoom!=(-1)) {
		G_omitlev=0;
		G_onlylev=0;
		G_steplev=0;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void getconfig(void) {
	FILE *in;
	char ln[255],*t;
	int i;

	if ((in=fopen("config.tv","r"))==NULL) {
		printf("Can't Open Configuration File\n");
		exit(-1);
	}
	fgets(ln,255,in);
	if (ln==NULL) {
		printf("Can't Read Configuration File\n");
		exit(-1);
	}
	t=strtok(ln,",\n");
	G_level1=atoi(t);
	for (i=0;i<16;i++) {
		t=strtok(NULL,",\n");
		colours[i]=atoi(t);
	}
	t=strtok(NULL,",\n");
	strcpy(G_term.type,t);
	t=strtok(NULL,",\n");
	G_term.baud=atoi(t);
	t=strtok(NULL,",\n");
	G_term.bits=atoi(t);
	t=strtok(NULL,",\n");
	G_term.parity=*t;
	t=strtok(NULL,",\n");
	G_term.stop=atoi(t);
	t=strtok(NULL,",\n");
	strcpy(G_term.handshake,t);
	i=1;
	do {
		t=strtok(NULL,",\n");
		if ((*t)=='F') {
			G_keycode[*(t+1)+128]=i;
		}
		else {
			G_keycode[*(t+1)]=i;
		}
		i++;
    } while (t!=NULL);
	fgets(ln,255,in);
	if (ln==NULL) {
		printf("Can't Read Configuration File\n");
		exit(-1);
	}
	t=strtok(ln,",\n");
	textcol=atoi(t);
	for (i=0;i<36;i++) {
		t=strtok(NULL,",\n");
		G_winpos[i]=atoi(t);
	}
	fclose(in);
}
void tmode(void) {
	if (maxtext[pickno]>0) {
		G_tno=1;
		G_hno=0;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void ttop(void) {
	textpos[pickno]=0;
	if (G_tno) {
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void tbot(void) {
	int i,j;
	if (G_tno) {
		j=maxtext[pickno];
		for (i=0;i<((G_winpos[(G_tno-1)*4+3]-G_winpos[(G_tno-1)*4+1])/8);i++) {
			while(textlns[pickno][j--]);
		}
		textpos[pickno]=j+2;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void tdn(void) {
	int i,j;
	if (G_tno) {
		j=textpos[pickno]+1;
		for (i=4;i<((G_winpos[((G_tno-1)*4)+3]-G_winpos[((G_tno-1)*4)+1])/8);i++) {
			while(textlns[pickno][j++]);
		}
		textpos[pickno]=j;
		if (j>maxtext[pickno]) {
			j=maxtext[pickno];
			for (i=0;i<((G_winpos[(G_tno-1)*4+3]-G_winpos[(G_tno-1)*4+1])/8);i++) {
				while(textlns[pickno][j--]);
			}
		textpos[pickno]=j+2;
		}
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void tup(void) {
	int i,j;
	if (G_tno) {
		j=textpos[pickno];
		for (i=4;i<((G_winpos[((G_tno-1)*4)+3]-G_winpos[((G_tno-1)*4)+1])/8);i++) {
			while(textlns[pickno][j--]);
		}
		while(textlns[pickno][j--]);
		if (j<0) j=0;
		textpos[pickno]=j+2;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void hmode(void) {
	if (maxhelp>0) {
		G_hno=1;
		G_tno=0;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void htop(void) {
	helppos=0;
	if (G_hno) {
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void hbot(void) {
	int i,j;
	if (G_hno) {
		j=maxhelp;
		for (i=0;i<((G_winpos[(G_hno-1)*4+3]-G_winpos[(G_hno-1)*4+1])/8);i++) {
			while(helplns[j--]);
		}
		helppos=j+2;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void hdn(void) {
	int i,j;
	if (G_hno) {
		j=helppos+1;
		for (i=0;i<((G_winpos[((G_hno-1)*4)+3]-G_winpos[((G_hno-1)*4)+1])/8);i++) {
			while(helplns[j++]);
		}
		helppos=j;
		if (j>maxhelp) {
			j=maxhelp;
			for (i=0;i<((G_winpos[(G_hno-1)*4+3]-G_winpos[(G_hno-1)*4+1])/8);i++) {
				while(helplns[j--]);
			}
		helppos=j+2;
		}
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
void hup(void) {
	int i,j;
	if (G_hno) {
		j=helppos;
		for (i=0;i<((G_winpos[((G_hno-1)*4)+3]-G_winpos[((G_hno-1)*4)+1])/8);i++) {
			while(helplns[j--]);
		}
		while(helplns[j--]);
		if (j<0) j=0;
		helppos=j+2;
		blancdisp();
		drawdiag(pickno,curposx,curposy,G_zoom,0);
	}
}
int menu(void) {
	int sel;
	char k;
	closegraph();
	textbackground(1);
	textcolor(14);
	clrscr();
	gotoxy(18,1);
	cprintf("TASKVIEW Demonstration v0.5 Copyright PMA 1989");
	gotoxy(35,3);
	textcolor(12);
	cprintf("Main Menu");
	k=0;
	sel=1;
	while ((k!=13)&&(k!='1')&&(k!='2')) {
		if (sel) {
			textcolor(12);
			textbackground(0);
			gotoxy(26,10);
			cprintf("1   Enter TaskView");
			textbackground(1);
			gotoxy(26,12);
			cprintf("2   Enter Terminal Emulation");
		}
		else {
			textcolor(12);
			textbackground(1);
			gotoxy(26,10);
			cprintf("1   Enter TaskView");
			textbackground(0);
			gotoxy(26,12);
			cprintf("2   Enter Terminal Emulation");
		}
		textbackground(1);
		textcolor(1);
		gotoxy(1,1);
		cprintf(" ");
		gotoxy(1,1);
		k=getch();
		switch(k) {
			case ' ' : {
				sel^=1;
			} break;
			case '1' : {
				sel=1;
			} break;
			case '2' : {
				sel=0;
			} break;
			case 0 : {
                k=getch();
                switch(k) {
                    case 'H' : {
						sel^=1;
                    } break;
                    case 'P' : {
						sel^=1;
                    } break;
				}
            } break;
		}
	}
	return(sel);
}
void form(void) {
	int sel;
	char k;
	char tmp[2][25]={"",""};
	int  nocrs[2]={0,0};
	closegraph();
	textbackground(0);
	textcolor(14);
	clrscr();
	gotoxy(13,1);
	cprintf("TASKVIEW Demonstration v0.5 Copyright PMA 1989");
	gotoxy(35,3);
	textcolor(11);
	cprintf("Job Sheet");
	textcolor(11);
	textbackground(0);
	gotoxy(21,10);
	cprintf("Enter Job Number  ");
	gotoxy(21,12);
	cprintf("Enter Part Number ");
	textcolor(11);
	textbackground(1);
	gotoxy(42,10);
	cprintf("        ");
	gotoxy(42,12);
	cprintf("                ");
	k=0;
	sel=0;
	textcolor(14);
	textbackground(1);
	while (k!=27) {
		gotoxy(42+nocrs[sel],10+(sel*2));
		k=getch();
		gotoxy(42,14);
		textbackground(0);
		cprintf("                                           ");
		textbackground(1);
		gotoxy(42+nocrs[sel],10+(sel*2));
		switch(k) {
			case 27 : {
				strcat(tmp[1],".opt");
				if (!(selafile(tmp[1]))) {
					gotoxy(42,14);
					cprintf("Can't access file %s",tmp[1]);
					k=0;
				}
			} break;
			case 0 :
				k=getch();
			break;
			case '\r' : {
				sel^=1;
			} break;
			case '\n' : {
			} break;
			case 8 : {
				if (nocrs[sel]>0) {
					nocrs[sel]--;
					gotoxy(42+nocrs[sel],10+(sel*2));
					cprintf(" ");
				}
			} break;
			default : {
				if (isalnum(k)) {
					if (sel) {
						if (nocrs[sel]<16) {
							tmp[sel][nocrs[sel]]=k;
							cprintf("%c",k);
							nocrs[sel]++;
							tmp[sel][nocrs[sel]]=0;
						}
					}
					else {
						if (nocrs[sel]<8) {
							tmp[sel][nocrs[sel]]=k;
							cprintf("%c",k);
							nocrs[sel]++;
						}
					}
				}
			}
		}
	}
}
