#include <conio.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <mem.h>
#include <alloc.h>
#include "tv.h"
#include "comms.h"

	/* Some Keyboard Defines "Just For Tracy" M.J.D. */
#define UP   'H'
#define DOWN 'P'
#define LEFT 'K'
#define RGHT 'M'
#define F1   ';'
#define F2   '<'
#define F3   '='
#define F4   '>'
#define F5   '?'
#define F6   '@'
#define F7   'A'
#define F8   'B'
#define F9   'C'
#define F10  'D'
#define SF1  'T'
#define SF2  'U'
#define SF3  'V'
#define SF4  'W'
#define SF5  'X'
#define SF6  'Y'
#define SF7  'Z'
#define SF8  '['
#define SF9  '\\'
#define SF10 ']'
#define CF1  '^'
#define CF2  '_'
#define CF3  '`'
#define CF4  'a'
#define CF5  'b'
#define CF6  'c'
#define CF7  'd'
#define CF8  'e'
#define CF9  'f'
#define CF10 'g'
#define AF1  'h'
#define AF2  'i'
#define AF3  'j'
#define AF4  'k'
#define AF5  'l'
#define AF6  'm'
#define AF7  'n'
#define AF8  'o'
#define AF9  'p'
#define AF10 'q'
#define INS  'R'
#define DEL  'S'
#define PGUP 'I'
#define PGDN 'Q'
#define HOME 'G'
#define END  'O'

void scrollup(int noln);
int  getkeyp(void);
void setupvt100(void);
void outch(char ch);
void callfunc(int funcno);
int  findln(void);
void addrxln(int funcno,char *ln);
int  pop(void);
void push(int val);
int  rxnumb(char seper);
void getrxvals(void);
int strfzcmp(char *s1,char *s2,int len);

int G_getnumb=0;
int G_sp=0,G_nopram=0,G_count=0;
int G_stack[50],G_param[50],G_val[50];
int G_savx=0,G_savy=0;
char G_keybuf[20];
char G_transstr[256][7];
char G_rxstrs[256][7];
typedef struct {
	char ln[80];
	int  funcno;
} escseq;
int G_norxln;
escseq *G_rxtree;
char *G_tabstop;
int G_cols;
int G_lines;
int G_inittabs;
char G_inln[50];
int G_inpos;

void placrx(char ch) {
	int j;
	int rxf;
	G_inln[G_inpos++]=ch;
	rxf=findln();
	if (rxf==(-1)) {
		for (j=0;j<G_inpos;j++) outch(G_inln[j]);
		G_inpos=0;
	}
	else {
		if (rxf!=0) {
			callfunc(rxf);
			G_inpos=0;
		}
	}
	gotoxy(termx,termy+1);
}
void switchscr(void) {
	int i,xit=0;
	char ch,k;
	interm=1;
	setupvt100();
	LOADCSFROM(terminal);
	textcolor(termattr);
	textbackground(0);
	gotoxy(termx,termy+1);
	do {
		while ((k=getkeyp())==(-1)) {
			if ((ch=getrx())!=(-1)) placrx(ch);
		}
		if (k==(-2)) xit=1; else txstr(G_keybuf);
		if (locecho) for (i=0;i<k;i++) placrx(G_keybuf[i]);
	} while (!xit);
	SAVECSTO(terminal);
	interm=0;
	grafix();
	if (G_zoom<0) {
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
void scrollup(int noln) {
	int far *t,i;
	if (interm) t=scr; else t=terminal;
	memmove(t+80,t+(noln*80)+80,3840-(noln*160));
	for (i=0;i<noln*80;i++) *(t+(1999-i))=termattr<<8;
}
int getkeyp(void) {
	char k;
	if (!kbhit()) return(-1);
	switch (k=getch()) {
		case 0   : {
			switch (k=getch()) {
				case UP   :	case DOWN :	case LEFT :	case RGHT :
				case INS  :	case DEL  :
				case HOME :	case END  :	case PGUP :	case PGDN :
				case F1   :	case F2   :	case F3   :	case F4   :	case F5   :
				case F6   :	case F7   :	case F8   :	case F9   :	case F10  :
				case SF1  :	case SF2  :	case SF3  :	case SF4  :	case SF5  :
				case SF6  :	case SF7  :	case SF8  :	case SF9  :	case SF10 :
				case CF1  :	case CF2  :	case CF3  :	case CF4  :	case CF5  :
				case CF6  :	case CF7  :	case CF8  :	case CF9  :	case CF10 :
				case AF1  :	case AF2  :	case AF3  :	case AF4  :	case AF5  :
				case AF6  :	case AF7  :	case AF8  :	case AF9  :	{
					strcpy(G_keybuf,G_transstr[k]);
					return(strlen(G_transstr[k]));
				}
				case AF10 : {
					return(-2);
				}
				default : {
					strcpy(G_keybuf,G_transstr[BEL]);
					return(strlen(G_transstr[BEL]));
				}
			}
		}
		case BS  : case CR  : case HT  : case BEL : {
			strcpy(G_keybuf,G_transstr[k]);
			return(strlen(G_transstr[k]));
		}
		default : {
			G_keybuf[0]=k;
			G_keybuf[1]=0;
			return(1);
		}
	}
}
void setupvt100(void) {
	int i;

	G_cols=80;
	G_lines=24;
	G_inittabs=8;

	G_tabstop=malloc(G_cols);
	for (i=0;i<G_cols;i++) if (i%G_inittabs) G_tabstop[i]=0; else G_tabstop[i]=1;
	strcpy(G_transstr[BEL ],"");
	strcpy(G_transstr[BS  ],"\b");
	strcpy(G_transstr[CR  ],"\r");
	strcpy(G_transstr[HT  ],"\t");

	strcpy(G_transstr[UP  ],"0A");
	strcpy(G_transstr[DOWN],"0B");
	strcpy(G_transstr[RGHT],"0C");
	strcpy(G_transstr[LEFT],"0D");

	strcpy(G_transstr[HOME],"[H");
	strcpy(G_transstr[END ],"");
	strcpy(G_transstr[PGUP],"");
	strcpy(G_transstr[PGDN],"");

	strcpy(G_transstr[F1  ],"0P");
	strcpy(G_transstr[F2  ],"0Q");
	strcpy(G_transstr[F3  ],"0R");
	strcpy(G_transstr[F4  ],"0S");
	strcpy(G_transstr[F5  ],"0t");
	strcpy(G_transstr[F6  ],"0u");
	strcpy(G_transstr[F7  ],"0v");
	strcpy(G_transstr[F8  ],"0l");
	strcpy(G_transstr[F9  ],"0w");
	strcpy(G_transstr[F10 ],"0x");

	strcpy(G_transstr[SF1 ],"0y");
	strcpy(G_transstr[SF2 ],"");
	strcpy(G_transstr[SF3 ],"");
	strcpy(G_transstr[SF4 ],"");
	strcpy(G_transstr[SF5 ],"");
	strcpy(G_transstr[SF6 ],"");
	strcpy(G_transstr[SF7 ],"");
	strcpy(G_transstr[SF8 ],"");
	strcpy(G_transstr[SF9 ],"");
	strcpy(G_transstr[SF10],"");

	strcpy(G_transstr[CF1 ],"");
	strcpy(G_transstr[CF2 ],"");
	strcpy(G_transstr[CF3 ],"");
	strcpy(G_transstr[CF4 ],"");
	strcpy(G_transstr[CF5 ],"");
	strcpy(G_transstr[CF6 ],"");
	strcpy(G_transstr[CF7 ],"");
	strcpy(G_transstr[CF8 ],"");
	strcpy(G_transstr[CF9 ],"");
	strcpy(G_transstr[CF10],"");

	strcpy(G_transstr[AF1 ],"");
	strcpy(G_transstr[AF2 ],"");
	strcpy(G_transstr[AF3 ],"");
	strcpy(G_transstr[AF4 ],"");
	strcpy(G_transstr[AF5 ],"");
	strcpy(G_transstr[AF6 ],"");
	strcpy(G_transstr[AF7 ],"");
	strcpy(G_transstr[AF8 ],"");
	strcpy(G_transstr[AF9 ],"");

	G_rxtree=malloc(1);
	G_norxln=0;
	addrxln( 1,"\r"    );				/* carriage_return */
	addrxln( 2,"\b"    );				/* key_backspace   */
	addrxln( 3,"\t"    );				/* tab */
	addrxln( 4,"[H"   );				/* cursor_home */
	addrxln( 5,"[J"   );				/* clr_eos */
	addrxln( 6,"[K"   );				/* clr_eol */
	addrxln( 7,"[1K"  );				/* clr_bol */
	addrxln( 8,""     );				/* bell */
	addrxln( 9,"[3g"  );				/* clear_all_tabs */
	addrxln(10,"H"    );				/* set_tab */
	addrxln(11,"[A"   );				/* cursor_up */
	addrxln(12,"\n"    );				/* cursor_down */
	addrxln(13,"[C"   );				/* cursor_right */
	addrxln(14,"\b"    );				/* cursor_left */
	addrxln(15,"7"    );				/* save_cursor */
	addrxln(16,"8"    );				/* restore_cursor */
	addrxln(17,"[%i%p1%d;%p2%dH" );	/* cursor_address */
/*	for (i=0;i<G_norxln;i++) {
		cprintf("%s %d\r\n",G_rxtree[i].ln,G_rxtree[i].funcno);
	}
	getch();*/
}
void addrxln(int funcno,char *ln) {
	G_norxln++;
	G_rxtree=realloc(G_rxtree,sizeof(escseq)*G_norxln);
	G_rxtree[G_norxln-1].funcno=funcno;
	strcpy(G_rxtree[G_norxln-1].ln,ln);
	qsort(G_rxtree,G_norxln,sizeof(escseq),strcmp);
}
int findln(void) {
	int i,a;
	char sep;
	static char tmpln[40];
	G_inln[G_inpos]=0;
	for (i=0;i<G_norxln;i++) {
		a=strfzcmp(G_rxtree[i].ln,G_inln,G_inpos);
		if (a>1) {
			return(-1);
		}
		if (a==0) {
			if (strlen(G_rxtree[i].ln)==G_inpos) {
				return(G_rxtree[i].funcno);
			}
			else {
				if (G_rxtree[i].ln[G_inpos]=='%') {
					strcat(tmpln,"%");
					switch(G_rxtree[i].ln[G_inpos+1]) {
						case 'd' : {
							strcat(tmpln,"d");
							if (G_rxtree[i].ln[G_inpos+2]!='%')	G_getnumb=1;
						} break;
						case 'i' : {
							strcat(tmpln,"i");
							if (G_rxtree[i].ln[G_inpos+2]!='%')	G_getnumb=1;
						} break;
						case 'p' : {
							sprintf(&tmpln[strlen(tmpln)],"p%c",G_rxtree[i].ln[G_inpos+2]);
							if (G_rxtree[i].ln[G_inpos+3]!='%')	G_getnumb=1;
						} break;
					}
				}
				else {
					if (G_getnumb) {
						G_getnumb=0;
						sep=G_rxtree[i].ln[G_inpos+strlen(tmpln)];
						if (rxnumb(sep)) {
							strcpy(&G_inln[G_inpos],tmpln);
							G_inpos=strlen(G_inln);
							tmpln[0]=0;
							G_inln[G_inpos++]=sep;
						}
					}
				}
				return(0);
			}
		}
	}
	return(-1);
}
void outch(char ch) {
	int far *t;
	if (ch>31&&ch<=127) {
		if (interm) t=scr; else t=terminal;
		*(t+(termx-1)+(termy*80))=(termattr<<8)+ch;
		termx++;
		if (termx>80) {
			termx=1;
			termy++;
		}
	}
}
void callfunc(int funcno) {
	int far *t,i;
	if (interm) t=scr; else t=terminal;
	switch(funcno) {
		case 1 : {		/* Carriage Return */
			termx=1;
			termy++;
			if (termy>24) {
				termy=24;
				scrollup(1);
			}
		} break;
		case 2 : {		/* Back Space */
			if (termx>1) termx--;
		} break;
		case 3 : {		/* Horizontal Tab */
			for (i=termx;i<80;i++) {
				if (G_tabstop[i]==1) {
					termx=i+1;
					break;
				}
			}
		} break;
		case 4 : {		/* Home */
			termx=1;
			termy=1;
		} break;
		case 5 : {		/* Clear to EOS */
			for (i=(termx-1)+(termy*80);i<2000;i++) *(t+i)=termattr<<8;
		} break;
		case 6 : {		/* Clear to EOL */
			for (i=(termx-1)+(termy*80);i<((termy+1)*80);i++) *(t+i)=termattr<<8;
		} break;
		case 7 : {		/* Clear from BOL */
			for (i=(termy*80);i<(termx-1)+(termy*80);i++) *(t+i)=termattr<<8;
		} break;
		case 8 : {		/* Bell */
			sound(1000);
			for (i=0;i<8000;i++);
			nosound();
		} break;
		case 9 : {		/* Clear All Tabs */
			for (i=0;i<80;i++) G_tabstop[i]=0;
		} break;
		case 10 : {		/* Set Tab */
			G_tabstop[termx-1]=1;
		} break;
		case 11 : {		/* Up */
			if (termy>1) termy--;
		} break;
		case 12 : {		/* Down */
			if (termy<G_lines) termy++;
		} break;
		case 13 : {		/* Right */
			if (termx<G_cols) termx++;
		} break;
		case 14 : {		/* Left */
			if (termx>1) termx--;
		} break;
		case 15 : {		/* save cursor pos*/
			G_savx=termx;
			G_savy=termy;
		} break;
		case 16 : {		/* restore cursor pos */
			termx=G_savx;
			termy=G_savy;
		} break;
		case 17 : {		/* cursor address */
			getrxvals();
			termy=G_val[0];
			termx=G_val[1];
			G_count=0;
			G_sp=0;
			G_nopram=0;
		} break;
		default : {		/* Error */
			sound(1000);
			for (i=0;i<8000;i++);
			nosound();
		}
	}
}
int rxnumb(char seper) {
	char str[6];
	int i=0,xit=0,j;

	while (!xit) {
		if (isdigit(buffer[point1+i])) {
			i++;
		}
		else {
			xit=1;
		}
		if (seper==buffer[point1+i]) {
			for (j=0;j<i;j++) str[j]=getrx();
			str[j]=0;
			G_param[G_nopram++]=atoi(str);
			getrx();
			return(1);
		}
	}
	return(0);
}
void push(int val) {
	G_sp++;
	G_stack[G_sp]=val;
}
int pop(void) {
	G_sp--;
	return(G_stack[G_sp+1]);
}
void getrxvals(void) {
	int j;
	for (j=0;j<G_inpos;j++) {
		switch(G_inln[j]) {
			case '%' : {
				j++;
				switch(G_inln[j]) {
					case 'i' : {
						if (G_nopram==1) {
							G_param[0]--;
						}
						if (G_nopram==2) {
							G_param[0]--;
							G_param[1]--;
						}
					} break;
					case 'p' : {
						j++;
						push(G_param[G_inln[j]-'0']);
					} break;
					case 'd' : {
						G_val[G_count++]=pop();
					} break;
					case '+' : {
						push(pop()+pop());
					} break;
					case '-' : {
						push(pop()-pop());
					} break;
					case '*' : {
						push(pop()*pop());
					} break;
					case '/' : {
						push(pop()/pop());
					} break;
					case 'm' : {
						push(pop()%pop());
					} break;
					case '&' : {
						push(pop()&pop());
					} break;
					case '|' : {
						push(pop()|pop());
					} break;
					case '^' : {
						push(pop()^pop());
					} break;
					case '=' : {
						push(pop()==pop());
					} break;
					case '>' : {
						push(pop()>pop());
					} break;
					case '<' : {
						push(pop()<pop());
					} break;
					case 'A' : {
						push(pop()&&pop());
					} break;
					case 'O' : {
						push(pop()||pop());
					} break;
					case '!' : {
						push(!pop());
					} break;
					case '~' : {
						push(abs(pop()));
					} break;
				}
			} break;
		}
	}
}
int strfzcmp(char *s1,char *s2,int len) {
	int i,j=0,k=0,xit=0;
	if (!strncmp(s1,s2,len)) return(0);
	for (i=0;i<len;i++) {
		if (isdigit(s1[j])) {
			if (s2[k]=='%') {
				while(isdigit(s1[j])) j++;
				while (!xit) {
					switch (s2[k]) {
						case '%' :
							k++;
							switch (s2[k]) {
								case 'd' : k++; break;
								case 'i' : k++; break;
								case 'p' : k+=2; break;
								default : xit=1;
							}
							break;
						default :	xit=1;
					}
				}
				xit=0;
			}
		}
		else {
			if (isdigit(s2[k])) {
				if (s1[j]=='%') {
					while(isdigit(s2[k])) k++;
					while (!xit) {
						switch (s1[j]) {
							case '%' :
								j++;
								switch (s1[j]) {
									case 'd' : j++; break;
									case 'i' : j++; break;
									case 'p' : j+=2; break;
									default : xit=1;
								}
								break;
							default : 	xit=1;
						}
					}
					xit=0;
				}
			}
			else {
				if (s1[j]>s2[k]) return(1);
				if (s1[j]<s2[k]) return(-1);
			}
		}
		k++;
		j++;
	}
	return(0);
}