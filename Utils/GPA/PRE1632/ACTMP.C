#define ACTIONS_C

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <conio.h>
#include <string.h>
#include <ctype.h>
#include <memory.h>
#include <malloc.h>
#include <math.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>

#include "types.h"
#include "config.h"
#include "message.h"
#include "fldproc.h"
#include "formproc.h"
#include "menuproc.h"
#include "formhand.h"
#include "translog.h"
#include "function.h"
#include "actions.h"
#include "control.h"
#include "instruct.h"
#include "arith.h"
#include "dst.h"
#include "global.h"
#include "lang.h"
#include "memory.h"
#include "money.h"

extern char *G_keyname[];
#define ABUFSIZE 200
int G_depth=0;
char *G_a[5];
long l,m,n,G_buffofs,G_forvars=0L;
unsigned char G_asbuff[ABUFSIZE];
long G_ofb=0L;
int G_argcnt=0;
int G_prinprog=0;
int loadnewform(char *name,long index,char *n1,char *n2,int w);

#ifdef __TURBOC__
#define I asm
#else
#define I __asm
#endif

// Push a value onto the CALL stack
void cpush(unsigned long c)
{
	ENTRY(1750);
    G_cstack[G_csp++]=c;
	RETURN;
}
// Pop a value from the CALL stack
unsigned long cpop(void)
{
	ENTRY(1760);
    RETURNV(G_cstack[--G_csp]);
}

// replacement cprintf command (only writes to top half of screen)
void mprintf(char *fmt, ... )
{
    unsigned char *scr=(unsigned char *)0xB8000000L;
    unsigned char str[140],*s;
    va_list ap;
    static int x=0;
    static int y=0;
	ENTRY(1770);

	if (!G_debug) RETURN;

    va_start(ap,fmt);
    vsprintf((char *)str,fmt,ap);
    va_end(ap);

    if (((unsigned char)(str[0]))==(unsigned char)'þ') { x=0; y=0; RETURN; }

    s=str;
    while (*s) { 
        *(scr+x*2+y*160)=*s;
        *(scr+x*2+y*160+1)=G_attr;
        s++;
        x++;
        if (x==80) {
            y++;
            x=0;
        }
        if (y==10) {
            y--;
            memcpy(scr,scr+160,1600);
        }
    }
	RETURN;
}
void transfer(unsigned long o)
{
	ENTRY(1771);
   	restpblk(G_afilename,G_asbuff,o,ABUFSIZE);
	G_ofb=o;
    RETURN;
}
unsigned char gettok(unsigned long o)
{
	ENTRY(1772);
//	if ((o<G_ofb)||(o>=G_ofb+(ABUFSIZE-10))) {
		transfer(o);
//	}
    RETURNV(G_asbuff[(int)(o-G_ofb)]);
}
unsigned int gettiny(unsigned long o)
{
	ENTRY(1773);
//	if ((o<G_ofb)||(o>=G_ofb+(ABUFSIZE-10))) {
		transfer(o);
//	}
    RETURNV(G_asbuff[(int)(o-G_ofb)]);
}
unsigned int getint(unsigned long o)
{
	ENTRY(1774);
//	if ((o<G_ofb)||(o>=G_ofb+((ABUFSIZE-10)-sizeof(int)))) {
		transfer(o);
//	}
    RETURNV( *((int *)(&(G_asbuff[(int)(o-G_ofb)]))) );
}
unsigned long getlong(unsigned long o)
{
	ENTRY(1775);
//	if ((o<G_ofb)||(o>=G_ofb+((ABUFSIZE-10)-sizeof(long)))) {
		transfer(o);
//	}
    RETURNV( *((long *)(&(G_asbuff[(int)(o-G_ofb)]))) );
}
double getdoub(unsigned long o)
{
	ENTRY(1776);
//	if ((o<G_ofb)||(o>=G_ofb+((ABUFSIZE-10)-sizeof(double)))) {
		transfer(o);
//	}
    RETURNV( *((double *)(&(G_asbuff[(int)(o-G_ofb)]))) );
}
unsigned char *getstrg(unsigned long o)
{
	ENTRY(1777);
	transfer(o);
    RETURNV(G_asbuff);
}
// prints all the stack and variable information
void pstack(void)
{
    int i,j,k;
    char t,tmp[MAXSTRLEN];
	ENTRY(1780);

    j=stksize();
    if (j>10) j=10;
#ifdef __TURBOC__
    textattr(0x0B);
#endif
    for (i=0;i<j;i++) {
#ifdef __TURBOC__
        gotoxy(1,i+13);
#endif
        t=stkstr(i,tmp);
        cprintf("%-10.10s %c",tmp,t);
    }
    for (;i<10;i++) {
#ifdef __TURBOC__
        gotoxy(1,i+13);
#endif
        cprintf("            ");
    }
#ifdef __TURBOC__
    textattr(0x0D);
#endif
    for (i=0;i<10;i++) {
#ifdef __TURBOC__
        gotoxy(14,i+13);
#endif
        cprintf("%10ld",G_vars[i]);
    }
    j=G_form.numitem;
    if (j>30) j=30;
    k=0;
    for (i=0;i<j;i++) {
        if (G_formvars[i]!=NULL) {
#ifdef __TURBOC__
            if (i==G_form.curitem) textattr(0x0C); else textattr(0x0E);
            gotoxy(25+((k/10)*11),(k%10)+13);
#endif
            cprintf("%10.10s",G_formvars[i]);
            k++;
        }
    }
    for (;k<30;k++) {
#ifdef __TURBOC__
        gotoxy(25+((k/10)*11),(k%10)+13);
#endif
        cprintf("          ");
    }
	RETURN;
}

// print the name of token p 
void ptok(unsigned long o)
{
	ENTRY(1790);
    switch (gettok(o)) {
        case TCONSTANT : mprintf("%d " ,gettiny(o+1));  break;
        case SCONSTANT : mprintf("%d " ,getint(o+1) );   break;
        case LCONSTANT : mprintf("%ld ",getlong(o+1)); break;
        case DCONSTANT : mprintf("%f " ,getdoub(o+1));         break;
        case CCONSTANT : mprintf("%s " ,getstrg(o+1) );  break;
        case TABLE     : mprintf("TABLE ");                         break;
        case ANAME     : mprintf("ACTION ");                        break;
        case EQUAL     : mprintf("= ");                             break;
        case LOGIC_AND : mprintf("&& ");                            break;
        case LOGIC_OR  : mprintf("|| ");                            break;
        case LOGIC_NOT : mprintf("! ");                             break;
        case LESSEQUAL : mprintf("<= ");                            break;
        case LESS      : mprintf("< ");                             break;
        case GREATEQUAL: mprintf(">= ");                            break;
        case GREAT     : mprintf("> ");                             break;
        case EQUALITY  : mprintf("== ");                            break;
        case NOTEQUAL  : mprintf("!= ");                            break;
        case PLUS      : mprintf("+ ");                             break;
        case MINUS     : mprintf("- ");                             break;
        case MULTIPLY  : mprintf("* ");                             break;
        case MODULUS   : mprintf("% ");                             break;
        case DEVIDE    : mprintf("/ ");                             break;
        case NEGATE    : mprintf("N ");                             break;
        case OCURLY    : mprintf("{ ");                             break;
        case CCURLY    : mprintf("} ");                             break;
        case FORMVAR   : mprintf("F ");                             break;
        case GLOBVAR   : mprintf("G ");                             break;
        case VARIABLE  : mprintf("V ");                             break;
        case ABS       : mprintf("ABS ");                           break;
        case ACOS      : mprintf("ACOS ");                          break;
        case ASIN      : mprintf("ASIN ");                          break;
        case ATAN      : mprintf("ATAN ");                          break;
        case COSH      : mprintf("COSH ");                          break;
        case COS       : mprintf("COS ");                           break;
        case EXP       : mprintf("EXP ");                           break;
        case LOG10     : mprintf("LOG10 ");                         break;
        case LOGAR     : mprintf("LOG ");                           break;
        case ROUND     : mprintf("ROUND ");                         break;
        case POW10     : mprintf("POW10 ");                         break;
        case SINH      : mprintf("SINH ");                          break;
        case SIN       : mprintf("SIN ");                           break;
        case SQRT      : mprintf("SQRT ");                          break;
        case SQR       : mprintf("SQR ");                           break;
        case TANH      : mprintf("TANH ");                          break;
        case TAN       : mprintf("TAN ");                           break;
        case TRUNC     : mprintf("TRUNC ");                         break;
        case GOTOXY    : mprintf("XY ");                            break;
        case MARKER    : mprintf("*** ");                           break;
        case WHILE     : mprintf("WH ");                            break;
        case IF        : mprintf("IF ");                            break;
        case ELSE      : mprintf("EL ");                            break;
        case SETFMVAR  : mprintf("@F ");                            break;
        case SETGLOBVR : mprintf("@G ");                            break;
        case SETCURITM : mprintf("@C ");                            break;
        case SETVARIAB : mprintf("@V ");                            break;
        case ACTIONN   : mprintf("ACT ");                           break;
        case RANGE     : mprintf("<-> ");                           break;
        case RESULT    : mprintf("ð ");                             break;
        case LOOKUP    : mprintf("LOOK ");                          break;
        case LOOKTAB   : mprintf("INTAB ");                         break;
        case USERVAR   : mprintf("UVAR ");                          break;
        case STATICS   : mprintf("STATIC ");                        break;
        case SETUSRVAR : mprintf("@UVAR ");                         break;
        case SETSTATIC : mprintf("@STATIC ");                       break;
        case PASSEDVAL : mprintf("PASSED ");                        break;
        case LOGQNTY   : mprintf("LQ ");                            break;
        case LOGVALUE  : mprintf("LV ");                            break;
        case LOGNAME   : mprintf("LN ");                            break;
        case DATASTORE : mprintf("DS ");                            break;
        case DSNAME    : mprintf("FILE ");                          break;
        case SETDATAST : mprintf("@DS ");                           break;
        case ADDTOLOG  : mprintf("A2L ");                           break;
        case CURFIELD  : mprintf("CF ");                            break;
        case FORMNAME  : mprintf("FORM ");                          break;
        case UFUNC     : mprintf("USERFUNC ");                      break;
        case CFUNC     : mprintf("CFUNC ");                         break;
        case USING     : mprintf("USING ");                         break;
        case UPDATE    : mprintf("UPDATE ");                        break;
        case ACCESSL   : mprintf("ALEVEL ");                        break;
        case SJOIN     : mprintf("STR+ ");                          break;
        case SCUT      : mprintf("STRCUT ");                        break;
        case SEQU      : mprintf("STR== ");                         break;
        case SNEQU     : mprintf("STR!= ");                         break;
        case SLESS     : mprintf("STR< ");                          break;
        case SLEQU     : mprintf("STR<= ");                         break;
        case SGREAT    : mprintf("STR> ");                          break;
        case SGEQU     : mprintf("STR>= ");                         break;
        case SUPPER    : mprintf("SUPPER ");                        break;
		case HOTKEY	   : mprintf("HOTKEY ");                        break;
		case PICKKEY   : mprintf("PICKKEY ");                        break;
		case PSHKEY	   : mprintf("PSHKEY ");                        break;
		case SAVESCR   : mprintf("SAVESCR ");                       break;
		case XTIMER	   : mprintf("XTIMER ");                        break;
		case SWAPTO   : mprintf("SWAPTO");                        break;
		case SETDEV	   : mprintf("SETDEV ");                        break;
		case SAVEDEV   : mprintf("SAVEDEV ");                       break;
		case RESTDEV   : mprintf("RESTDEV ");                       break;
        case DUEDOM    : mprintf("DUEDOM  ");                       break;
        case GETYEAR   : mprintf("GETYEAR ");                       break;
        case GETPROD   : mprintf("GETPROD ");                       break;
        case INRANGE   : mprintf("INRANGE ");                       break;
        case NMONTHS   : mprintf("NMONTHS ");                       break;
        case NDAYS     : mprintf("NDAYS ");                         break;
        case DUEHALF   : mprintf("DUEHALF ");                       break;
        case ERRLINE   : mprintf("ERRLINE ");                       break;
        case SLOWER    : mprintf("SLOWER ");                        break;
        case DATESTR   : mprintf("DATE ");                          break;
        case DAYOFWK   : mprintf("DAYOFWK ");                       break;
        case FMTMATCH  : mprintf("FMTMATCH ");                      break;
        case WHERE     : mprintf("WHERE ");                         break;
        case DUPDSFMT  : mprintf("DUPDSFMT ");                      break;
        case REMDSFMT  : mprintf("REMDSFMT ");                      break;
        case COPYREC   : mprintf("COPYREC  ");                      break;
        case RUNFORM   : mprintf("RUNFORM  ");                      break;
        case STSRCH    : mprintf("STSRCH ");                        break;
        case STSRCHP   : mprintf("STSRCHP ");                       break;
        case RECNUM    : mprintf("RECNUM ");                        break;
        case STREAD    : mprintf("STREAD  ");                       break;
        case STWRITE   : mprintf("STWRITE ");                       break;
        case STDELREC  : mprintf("STDELREC ");                      break;
        case PROMPT    : mprintf("PROMPT ");                        break;
        case CREC      : mprintf("CREC ");                          break;
        case NREC      : mprintf("NREC ");                          break;
        case PREC      : mprintf("PREC ");                          break;
        case FREC      : mprintf("FREC ");                          break;
        case LREC      : mprintf("LREC ");                          break;
        case CLREC     : mprintf("CLREC ");                         break;
        case RUN       : mprintf("RUN ");                           break;
        case STEMPTY   : mprintf("STEMPTY ");                       break;
        case TOTALBOX  : mprintf("TOTALBOX ");                      break;
        case PRLINE    : mprintf("PRLINE ");                        break;
        case PREOL     : mprintf("PREOL ");                         break;
        case PREOF     : mprintf("PREOF ");                         break;
        case PRAGAIN   : mprintf("PRAGAIN ");                       break;
        case MOVEPLN   : mprintf("MOVEPLN ");                       break;
        case SENDLINE  : mprintf("SENDLINE ");                      break;
        case SENDEOL   : mprintf("SENDEOL ");                       break;
        case JUMPTO    : mprintf("JUMPTO ");                        break;
        case MOVETCUR  : mprintf("MOVETCUR ");                      break;
        case SETDSKEY  : mprintf("SETDSKEY ");                      break;
        case RUNCOPY   : mprintf("RUNCOPY ");                       break;
        case RUNSRCH   : mprintf("RUNSRCH ");                       break;
        case DISPHOT   : mprintf("DISPHOT ");                       break;
        case BLANKREC  : mprintf("BLANKREC ");                      break;
        case VARARGS   : mprintf("VARARGS ");                       break;
        case WAITFLAG  : mprintf("WAITFLAG ");                      break;
        case WAITTEST  : mprintf("WAITTEST ");                      break;
        default        : mprintf("Error Unknown Instruction %d ",gettok(o));
    }
	RETURN;
} 
// skip the token buffer until the matching '}' 
unsigned long skip(unsigned long o)
{
    int xit=0;
    unsigned long s;
    int curly=0;
	ENTRY(1800);
    G_attr=8;
    o++;
    while (!xit) {
        s=o;
        switch (gettok(o)) {
            case TCONSTANT : o++;                         break;
            case SCONSTANT : o+=sizeof(int);              break;
            case LCONSTANT : o+=sizeof(long);             break;
            case DCONSTANT : o+=sizeof(double);           break;
            case CCONSTANT : while (gettiny(o+1)) o++; o++;     break;
            case OCURLY    : curly++;                     break;
            case CCURLY    : curly--; if (curly<1) xit=1; break;
        }
        if ((G_run<2)&&(!xit)) ptok(s);
        o++;
    }
    G_attr=10;
    RETURNV(o);
}
// RETURN the  CALL stack tos as a long (passed value)
long psd(void)
{
	ENTRY(1810);
    RETURNV((long)G_cstack[G_csp-1]);
}
void fmtmatch(void)
{
    char fmt[80];
    char str[80];
    int type,l,i;
	ENTRY(1820);

    getnum();
    type=(int)G_n[1];
    getstr();
    strcpy(fmt,G_s[1]);
    getstr();
    strcpy(str,G_s[1]);

    switch (type) {
        case 1 :
            l=strlen(fmt);
            if (l!=strlen(str)) {
                PUSHN(0);
                RETURN;
            }
            break;
        default :
            l=min(strlen(fmt),strlen(str));
    }
    strupr(fmt);
    for (i=0;i<l;i++) {
        switch (fmt[i]) {
            case 'A' :                      // Alpha
                if (!isalpha(str[i])) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            case 'P' :                      // Password
            case 'X' :                      // Alpha-Numeric with spaces
                if ((!isalnum(str[i]))&&(!isspace(str[i]))) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            case 'Z' :                      // Alpha-Numeric without spaces
                if (!isalnum(str[i])) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            case 'U' :                      // Uppercase with spaces
                if (!isupper(str[i])) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            case 'L' :                      // Lowercase with spaces
                if (!islower(str[i])) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            case 'M' :                      // Money
            case 'W' :                      // Weight
            case '9' :                      // Numeric
            case 'T' :                      // Time
            case 'D' :                      // Date
                if (!isdigit(str[i])) {
                    PUSHN(0);
                    RETURN;
                }
                break;
            default :
                if (str[i]!=fmt[i])  {
                    PUSHN(0);
                    RETURN;
                }
        }
    }
    PUSHN(1);
	RETURN;
}
void equals(void)
{
    char t=stktype(0);
	int i,fd,j;
	char tmp[81],*s,*e;
	ENTRY(1830);

    if (t=='n') {
        getnum();
        G_n[0]=G_n[1];
    }
    else {
        getstr();
        strcpy(G_s[0],G_s[1]);
    }
    getstr();
    if (G_s[1][0]=='F') { // STACK - idx F val = TOS
        getnum();
		if ((G_form.numitem>G_n[1])&&(G_form.items[(int)G_n[1]].class!=FF_TEXT)) {
        	if (t=='n') 
             	NTOA(G_formvars[(int)G_n[1]],G_n[0]);
        	else 
            	strncpy(G_formvars[(int)G_n[1]],G_s[0],80);
		} else {
        	if (t=='n') {
             	NTOA(tmp,G_n[0]);
				if (strlen(tmp)>1) {
#ifdef __TURBOC__
					for (i=5000;i>1000;i-=100) { sound(i); delay(10); }
					delay(100);
					nosound();
#endif
				} else {
					strcpy(G_formvars[(int)G_n[1]],tmp);
				}
        	} else {
            	strncpy(tmp,G_s[0],80);
				if (strlen(tmp)>1) {
#ifdef __TURBOC__
					for (i=5000;i>1000;i-=100) { sound(i); delay(10); }
					delay(100);
					nosound();
#endif
				} else {
					strcpy(G_formvars[(int)G_n[1]],tmp);
				}
			}
		}
    } else if (G_s[1][0]=='D') {  // STACK - sidx fidx D val = TOS
        get2nums();
        if (t=='n') NTOA(G_s[0],G_n[0]);
        sendmsg("DBM",'p',G_store[(int)G_n[1]].name,G_lib[G_store[(int)G_n[1]].li[(int)G_n[2]]].name,G_s[0]);
    } else if (G_s[1][0]=='V') {  // STACK - idx V val = TOS
        getnum();
        if (t=='n') 
            G_vars[(int)G_n[1]]=(long)G_n[0];
        else
            G_vars[(int)G_n[1]]=(long)(ATON(G_s[0]));
    } else if (G_s[1][0]=='G') {  // STACK - idx G val = TOS
        getnum();
        if (t=='n') NTOA(G_s[0],G_n[0]);
        setglobal((int)G_n[1],G_s[0]);
    } else if (G_s[1][0]=='U') {  // STACK - idx U val = TOS
        getnum();
        if (t=='n') NTOA(G_s[0],G_n[0]);
        e=STRDUP(G_s[0]);
		if (G_nbuf[(int)G_n[1]].b!=NULL) {
            s=(char *)G_nbuf[(int)G_n[1]].b;
            for (i=0;i<G_form.numitem;i++) {
                if (G_formvars[i]==s) G_formvars[i]=e;
            }
            for (i=0;i<G_numsf;i++) {
                for (j=0;j<G_savedf[i].nitem;j++) {
                   if (G_savedf[i].vars[j]==s) G_savedf[i].vars[j]=e;
                }
            }
            FREE(G_nbuf[(int)G_n[1]].b);
        }
		(char *)(G_nbuf[(int)G_n[1]].b)=e;
    } else if (G_s[1][0]=='S') {  // STACK - idx S val = TOS
        getnum();
        if (t=='n') NTOA(G_s[0],G_n[0]);
        e=STRDUP(G_s[0]);
		if (G_nbuf[(int)G_n[1]].b!=NULL) {
            s=(char *)G_nbuf[(int)G_n[1]].b;
            for (i=0;i<G_form.numitem;i++) {
                if (G_formvars[i]==s) G_formvars[i]=e;
            }
            for (i=0;i<G_numsf;i++) {
                for (j=0;j<G_savedf[i].nitem;j++) {
                   if (G_savedf[i].vars[j]==s) G_savedf[i].vars[j]=e;
                }
            }
            FREE(G_nbuf[(int)G_n[1]].b);
        }
		(char *)(G_nbuf[(int)G_n[1]].b)=e;
		if (e!=NULL) {
			fd=open(G_afilename,O_RDWR|O_BINARY);
			if (fd!=(-1)) {
				lseek(fd,G_buffofs+G_nbuf[(int)G_n[1]].o+1,SEEK_SET);
				write(fd,e,80);
				close(fd);
			}
		}
    } else {  // STACK - C val = TOS
        if (t=='n') {
            G_form.curitem=(int)G_n[0];
        }
        else {
            G_form.curitem=(int)(ATON(G_s[0]));
        }
    }
	RETURN;
}
void delst(char *name)
{
    int s=snum(name);
	ENTRY(1840);
    if (s==(-1)) RETURN;
    sendmsg("DBM",'D',name);
    memcpy(&G_store[s],&G_store[s+1],sizeof(STORE)*((G_nums-1)-s));
    G_nums--;
    sendmsg("DBM",'RI');
	RETURN;
}
unsigned char *isdefstr(char *s)
{
	int i;
	ENTRY(1850);
	for (i=0;i<G_tcnt;i++) {
		if (!strcmp(G_tname[i],s))
            RETURNV((unsigned char *)atextstr(i));
		if (*G_tname[i]=='~') break;
	}
	RETURNV((unsigned char *)s);
}
int keystroke(char *s)
{
	int retval=0;
	int l,i;
	ENTRY(1851);
	l=strlen(s);
	if (l==1) {
		retval=(int)*s;
	} else {
		i=0;
		while (G_keyname[i]!=NULL) {
			if (!strncmp(s,G_keyname[i],l)) {
				retval=i-176;
				break;
			}
			i++;
		}
	}
	RETURNV(retval);
}

// interpret the tokens at address p
int near inttok(unsigned long o)
{
    unsigned char *t;
    unsigned long *varspace;
    unsigned long s;
    unsigned int inwhere=0;
	unsigned char rform=0;
    unsigned char xit=0;
    unsigned char curly=0;
    NUMB numb;
    int k,j;
	ENTRY(1860);

    G_attr=10;
//	memset(G_vars,0,sizeof(long)*10);

    while (!xit) {
        if (G_run<2) {
#ifdef __TURBOC__
            textattr(9);
            gotoxy(1,12);
#endif
            cprintf("DEPTH [%d]   %s [%s]     ",G_depth,(G_nbuf[G_ca].t==ANAME?"ACTION":" TABLE"),G_nbuf[G_ca].n);
            ptok(o);
        }
        switch (gettok(o)) {
            case TCONSTANT : PUSHN(gettiny(o+1)); o++;               break;
            case SCONSTANT : PUSHN(getint (o+1)); o+=sizeof(int);    break;
            case LCONSTANT : PUSHN(getlong(o+1)); o+=sizeof(long);   break;
            case DCONSTANT : PUSHN(getdoub(o+1)); o+=sizeof(double); break;
            case CCONSTANT :
				PUSHS(isdefstr((char *)getstrg(o+1)));
				while (gettiny(o+1)) o++;
				o++;
				break;
            case TABLE     : popl();                                                break;
            case ANAME     : popl();                                                break;
            case LOGIC_AND : land();                                               break;
            case LOGIC_OR  : lor();                                                break;
            case LOGIC_NOT : lnot();                                               break;
            case PLUS      : add();                                                break;
            case NEGATE    : neg();                                                break;
            case EQUAL     : equals();                                             break;
            case LESSEQUAL : lessequal();                                          break;
            case LESS      : less();                                               break;
            case GREATEQUAL: greatequal();                                         break;
            case GREAT     : great();                                              break;
            case EQUALITY  : equal();                                              break;
            case NOTEQUAL  : notequal();                                           break;
            case MINUS     : sub();                                                break;
            case MULTIPLY  : mul();                                                break;
            case MODULUS   : mod();                                                break;
            case DEVIDE    : divide();                                             break;
            case OCURLY    : curly++;                                              break;
            case CCURLY    : curly--; if (curly==0) xit=1;                         break;
            case ELSE      : o=skip(o)-1;                                          break;
            case MARKER    : cpush(o);                                             break;
            case FORMVAR   : 
                PUSHS(G_formvars[(int)popl()]);
                break;
            case GLOBVAR   : PUSHS(getglobal((int)popl()));                             break;
            case VARIABLE  : PUSHN(G_vars[(int)popl()]);                                break;
            case CURFIELD  : PUSHN(G_form.curitem);                                break;
            case SETGLOBVR : PUSHS("G");                                           break;
            case SETFMVAR  : PUSHS("F");                                           break;
            case SETVARIAB : PUSHS("V");                                           break;
            case SETCURITM : PUSHS("C");                                           break;
            case SETUSRVAR : PUSHS("U");                                           break;
            case SETSTATIC : PUSHS("S");                                           break;
            case STATICS   : PUSHS(G_nbuf[(int)popl()].b);                   		   break;
            case USERVAR   : PUSHS(G_nbuf[(int)popl()].b);                   		   break;
            case LOOKTAB   :              
            case ACTIONN   :
				G_depth++;
				varspace=MALLOC(10*sizeof(long));
				if (varspace!=NULL) {
					memcpy(varspace,G_vars,10*sizeof(long));
					memset(G_vars,0,10*sizeof(long));
					if (!inttok(G_nbuf[G_ca=(int)popl()].o)) xit=2;
					memcpy(G_vars,varspace,10*sizeof(long));
					FREE(varspace);
				} else {
#ifdef __TURBOC__
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					nosound();
#endif
				}
				G_depth--;
				break;
            case ACCESSL   : if (G_access<popl()) xit=2;                           break;
            case LOOKUP    : cpush(popl());                       break;
            case PASSEDVAL : PUSHN(psd());                                         break;
            case RANGE     :
                l=popl();
                m=popl();
                if (l==0x7FFFFFFFL) {
                    if (psd()>=m) PUSHN(1); else PUSHN(0);
                }
                else {
                    if ((psd()<=l)&&(psd()>=m)) PUSHN(1); else PUSHN(0);
                }
                break;
            case RESULT    :
                getnum(); G_n[0]=G_n[1];
                if (popl()) {
                    cpop();
                    PUSHN(G_n[0]);
                    o=skip(o)-2;
                }
                break;
            case IF        :
                s=skip(o);
                if (gettok(s)==ELSE) {
                    if (!popl()) o=s;
                } else {
                    if (!popl()) o=s-1;
                }
                break;
            case WHILE     :
                if (popl()) {
                    if (!inttok(o+1)) xit=2;
                    o=cpop()-1;
                }
                else {
                    cpop();
                    o=skip(o)-1;
                }
                break;
            case WHERE     :
                if (!inwhere) {
                    inwhere++;
                    l=popl();
                    if (sendmsg("DBM",'r',G_store[(int)l].name,inwhere)) {
                        popl();
                        o=cpop()-1;
                    } else {
                        cpop();
                        o=skip(o)-1;
                        inwhere=0;
                    }
                } else {
                    inwhere++;
                    k=(int)popl();
                    if (popl()) if (!inttok(o+1)) xit=2;
                    if (sendmsg("DBM",'r',G_store[(int)k].name,inwhere)) {
                        o=cpop()-1;
                    }
                    else {
                        cpop();
                        o=skip(o)-1;
                        inwhere=0;
                    }
                }
                break;
            case FORMNAME  : 
                if (!rform) {
                    if (G_debug) {
                        sendmsg("OUTPUT1",'RI');
                        sendmsg("OUTPUT1",'R');
                        sendmsg("INPUT1",'RI');
                    }
                   	l=loadnewform(NULL,popl(),NULL,NULL,0);
                    if (G_debug) {
                        sendmsg("OUTPUT1",'TE');
                        sendmsg("INPUT1",'TE');
                    }
                    if (!l) xit=2;
                }
                break;
            case UFUNC     : 
                l=popl();
                if (G_ufunc[(int)l].savescr) {
                    if (G_debug) {
                        sendmsg("OUTPUT1",'RI');
                        sendmsg("OUTPUT1",'R');
                        sendmsg("INPUT1",'RI');
                    }
                }
                l=(long)subaction(G_ufunc[(int)l].name,0);
                if (G_ufunc[(int)l].savescr) {
                    if (G_debug) {
                        sendmsg("OUTPUT1",'TE');
                        sendmsg("INPUT1",'TE');
                    }
                }
                if (!l) xit=2;
                break;
            case CFUNC     :
                l=popl();
                if (G_actmap[(int)l].savescr) {
                    if (G_debug) {
                        sendmsg("OUTPUT1",'RI');
                        sendmsg("OUTPUT1",'R');
                        sendmsg("INPUT1",'RI');
                    }
                }
                l=(long)subaction(G_actmap[(int)l].name,0);
                if (G_actmap[(int)l].savescr) {
                    if (G_debug) {
                        sendmsg("OUTPUT1",'TE');
                        sendmsg("INPUT1",'TE');
                    }
                }
                if (!l) xit=2;
                break;
            case SJOIN     : sjoin();                                              break;
            case SCUT      : scut();                                               break;
            case SEQU      : sequal();                                             break;
            case SNEQU     : snotequal();                                          break;
            case SLESS     : sless();                                              break;
            case SLEQU     : slessequal();                                         break;
            case SGREAT    : sgreat();                                             break;
            case SGEQU     : sgreatequal();                                        break;
            case SUPPER    : getstr(); PUSHS(strupr(G_s[1]));                      break;
            case SLOWER    : getstr(); PUSHS(strlwr(G_s[1]) );                      break;
			case XTIMER	   : sendmsg("INPUT1",'xt',(int)popl());						   break;
			case SWAPTO    :
                    getstr();
                    if (!loadnewform(G_s[1],-1L,NULL,NULL,1)) xit=2;
				break;
			case PICKKEY : 
				getstr();
				G_pickkey=keystroke(G_s[1]);
				break;
			case PSHKEY	   : 
				getstr();
				if ((k=keystroke(G_s[1]))!=0) sendmsg("INPUT1",'P',k);
				break;
            case JUMPTO    :
				getstr();
//				sendmsg("INPUT1",'F');
				(char *)t=strtok(G_s[1],"^");
				while (t!=NULL) {
					if ((k=keystroke((char *)t))!=0) sendmsg("INPUT1",'P',k);
					(char *)t=strtok(NULL,"^");
				}
				sendmsg("INPUT1",'P',-500);
				sendmsg("INPUT1",'DT',-500);
				sendmsg("OUTPUT1",'OF');
				break;
            case MOVETCUR :
				get2strs();
                switch (toupper(G_s[1][0])) {
                    case 'U' : G_tabmovet=1; break;
                    case 'D' : G_tabmovet=2; break;
                    case 'V' : G_tabmovet=5; break;
                    case 'L' : G_tabmovet=3; break;
                    case 'R' : G_tabmovet=4; break;
                    case 'H' : G_tabmovet=6; break;
                }
                G_tabmoved=atoi(G_s[2]);
				break;
			case SAVESCR : popl(); break; //sendmsg("OUTPUT1",'0'+(int)popl());  break;
			case SAVEDEV   : savedevices();                        				   break;
			case RESTDEV   : restdevices();                        				   break;
			case SETDEV	   :
				getstr();
				strcpy(G_s[0],G_s[1]);
				get2strs();
				asigndev(G_s[1],G_s[2],G_s[0][0]);
				break;
            case DUEDOM    : PUSHS(duedom((int)popl()));                                break;
            case DAYOFWK   :
				getstr();
				PUSHS(G_days[(datetonum(G_s[1])+2)%7]);
				break;
            case DATESTR   : PUSHS(datestr((int)popl()));                               break;
            case FMTMATCH  : fmtmatch();                                           break;
            case GETYEAR   : getstr();   PUSHN(getyear(G_s[1]));                   break;
            case GETPROD   : getprod((int)popl());                                      break;
            case INRANGE   : get2strs(); PUSHN(inrange(G_s[1],G_s[2]));            break;
            case NMONTHS   : get2strs(); PUSHN(months (G_s[1],G_s[2]));            break;
            case NDAYS     : get2strs(); PUSHN(days   (G_s[1],G_s[2]));            break;
            case DUEHALF   : get2strs(); PUSHS(duehalf(G_s[1],G_s[2]));            break;
            case RUN 	   : getstr(); runaction(G_s[1]);                          break;
            case RECNUM    : l=popl(); PUSHN(sendmsg("DBM",'rn',G_store[(int)l].name)); break;
            case STEMPTY   : getstr(); sendmsg("DBM",'e',G_s[1]);                  break;
            case TOTALBOX  :
				get2strs();
				l=popl();
				m=popl();
				n=popl();
				k=G_form.type;
				G_form.type=F_NORM;
				output((int)n,(int)m,G_s[2],(int)l,G_s[1],1);
				G_form.type=k;
				break;
            case PRLINE    :
				if (!G_prinprog) {
					G_pagenum=1;
					sendmsg("OUTPUT2",'SP',2,1);
					G_prinprog=1;
				}
                get2strs();
                switch (G_s[2][0]) {
                    case 0 :
                        break;
                    case 'M' :
                        strcpy(G_s[1],mstr(G_s[1],strlen(G_s[2])));
                        break;
                    default :
                        strcpy(G_s[1],applyformat(G_s[1],&(G_s[2][0]),1));
                }
                sendmsg("OUTPUT2",'o',-1,0,"%s",G_s[1]);
                break;
            case PREOL     : sendmsg("OUTPUT2",'OL'); 				   			   break;
            case PREOF     : sendmsg("OUTPUT2",'OF'); G_pagenum++;	   			   break;
            case PRAGAIN   : G_pagenum--; sendmsg("OUTPUT2",'RP'); G_pagenum++;    break;
			case MOVEPLN   : 
                getnum();
				sendmsg("OUTPUT2",'MY',(int)G_n[1]);
				break;
            case SENDLINE    :
                get2strs();
                switch (G_s[2][0]) {
                    case 0 :
                        break;
                    case 'M' :
                        strcpy(G_s[1],mstr(G_s[1],strlen(G_s[2])));
                        break;
                    default :
                        strcpy(G_s[1],applyformat(G_s[1],&(G_s[2][0]),1));
                }
                strcpy(G_s[0],G_s[1]);
                sendmsg("COMM",'O',(int)popl(),G_s[0]);
                break;
            case SENDEOL     : sendmsg("COMM",(int)popl(),"\r\n"); 				   			   break;

			case STDELREC  : getstr();   sendmsg("DBM",'dr',G_s[1],CURR); 		   break;
// typechek case STDELREC  : sendmsg("DBM",'dr',G_store[popl()].name,CURR); 	   break;
            case PROMPT :
                get2strs();
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'S',1);
                sendmsg("OUTPUT1",'o',1,G_elineat,"%s",G_s[1]);
                G_s[0][0]=0;
                k=G_form.curitem;
                inputstr(1+strlen(G_s[1])+1,G_elineat,G_s[0],G_s[2],0);
                G_form.curitem=k;
                G_exitkey=0;
                k=strlen(G_s[1])+strlen(G_s[2])+3;
                sendmsg("OUTPUT1",'o',1,G_elineat,"%*.*s",k,k,"");
                PUSHS(G_s[0]);
                break;
            case ERRLINE   :
                getnum();
                getstr();
                G_n[0]=G_n[1];
                if (G_debug) {
                    sendmsg("OUTPUT1",'RI');
                    sendmsg("OUTPUT1",'R');
                    sendmsg("INPUT1",'RI');
                }
                errorline(G_s[1],(int)G_n[0]);
                if (G_debug) {
                    sendmsg("OUTPUT1",'TE');
                    sendmsg("INPUT1",'TE');
                }
                break;
            case LOGQNTY   : PUSHN(G_log[(int)popl()].qty);                             break;
            case LOGVALUE  : PUSHS(G_log[(int)popl()].val);                             break;
            case LOGNAME   : PUSHS(G_log[(int)popl()].desc);                            break;
            case SETDATAST : PUSHS("D");                                           break;
            case DATASTORE :
                m=popl();
                l=popl();
				k=0;
				G_s[0][0]=0;
				mprintf("Get %s.%s",G_store[(int)l].name,G_lib[G_store[(int)l].li[(int)m]].name,G_s[0],k);
                k=sendmsg("DBM",'g',G_store[(int)l].name,G_lib[G_store[(int)l].li[(int)m]].name,G_s[0]);
                PUSHS(G_s[0]);
				mprintf("=\"%s\" Return=%d ",G_s[0],k);
                break;
            case ADDTOLOG  :
				for (n=0;n<5;n++) { getstr(); G_a[(int)n]=STRDUP(G_s[1]); }
                add2log(G_a[4],G_a[3],G_a[2],G_a[1],G_a[0]);
				for (n=0;n<5;n++) FREE(G_a[(int)n]);
                break;
            case DSNAME    : break;
            case USING     : break;
            case UPDATE    : break;
            case DUPDSFMT  :
                l=popl();
                getstr();
                if (!sendmsg("DBM",'x',G_s[1])) {
                    memcpy(&G_store[G_nums],&G_store[(int)l],sizeof(STORE));
                    strcpy(G_store[G_nums].name,G_s[1]);
                    G_nums++;
                    if (sendmsg("DBM",'x',G_store[G_nums-1].name)) {
                        sendmsg("DBM",'D',G_store[G_nums-1].name);
                    } 
                }
                break;
            case REMDSFMT  : getstr(); delst(G_s[1]); break;
            case COPYREC   :
                l=popl();
                getstr();
                sendmsg("DBM",'cr',G_store[(int)l].name,G_s[1]);
                break;
            case RUNFORM   :
                if (rform) {
                    l=popl();
                    getstr();
                    strcpy(G_s[0],G_s[1]);
                    rform=0;
                    if (G_debug) {
                        sendmsg("OUTPUT1",'RI');
                        sendmsg("OUTPUT1",'R');
                        sendmsg("INPUT1",'RI');
                    }
                    if (!loadnewform(NULL,popl(),G_store[(int)l].name,G_s[0],0)) xit=2;
                    if (G_debug) {
                        sendmsg("OUTPUT1",'TE');
                        sendmsg("INPUT1",'TE');
                    }
                } else {
                    rform=1;
                }
                break;
            case STSRCH    :
                l=popl(); m=popl(); n=popl();
//                mprintf("%s %s %d",G_store[n].name,G_lib[G_store[(int)n].li[(int)m]].name,(int)l);
                l=(long)sendmsg("DBM",'s',G_store[(int)n].name,G_lib[G_store[(int)n].li[(int)m]].name,(int)l);
                if (l) {
                    sendmsg("DBM",'r',G_store[(int)n].name,CURR);
                }
                PUSHN(l);
                break;
            case STSRCHP   :
                l=popl(); m=popl(); n=popl();
                mprintf("%s %s %d",G_store[(int)n].name,G_lib[G_store[(int)n].li[(int)m]].name,(int)l);
                l=sendmsg("DBM",'sp',G_store[(int)n].name,(int)m,(int)l);
                if (l) {
                    sendmsg("DBM",'r',G_store[(int)n].name,CURR);
                }
                PUSHN(l);
                break;
            case STREAD    : l=popl(); sendmsg("DBM",'r',G_store[(int)popl()].name,(int)l); break;
            case STWRITE   : sendmsg("DBM",'w',G_store[(int)popl()].name); break;
            case CREC      : PUSHN(CURR); break;
            case NREC      : PUSHN(NEXT); break;
            case PREC      : PUSHN(PREV); break;
            case FREC      : PUSHN(FRST); break;
            case LREC      : PUSHN(LAST); break;
            case CLREC     : PUSHN(CLSE); break;
            case BLANKREC  : sendmsg("DBM",'b',G_store[(int)popl()].name); break;
            case RUNSRCH   :
                getstr(); // ACTION
                strcpy(G_s[0],G_s[1]);
                getstr(); // GSREC OR GSFNAME
                m=popl(); // GSCOND
				G_depth++;
				varspace=MALLOC(10*sizeof(long));
				if (varspace!=NULL) {
					memcpy(varspace,G_vars,10*sizeof(long));
					memset(G_vars,0,10*sizeof(long));
                    t=MALLOC(11);
    				if (t!=NULL) strcpy((char *)t,G_sfname);
                    j=G_scond;
                    k=G_srec;
                    G_scond=(int)m;
                    switch (m) {
                        case 1  :
                            numb=ATON(G_s[1]);
                            G_srec=(int)numb;
                            break;
                        case 2  :
                            strcpy(G_sfname,G_s[1]);
                            break;
                    }
                    runaction(G_s[0]);
                    G_scond=j;
                    G_srec =k;
    				if (t!=NULL) { strcpy(G_sfname,(char *)t); FREE(t); }
					memcpy(G_vars,varspace,10*sizeof(long));
					FREE(varspace);
				} else {
#ifdef __TURBOC__
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					nosound();
#endif
				}
				G_depth--;
				break;
            case VARARGS   : G_argcnt=(int)popl(); break;
			case HOTKEY	: 
                if (G_argcnt!=0) {
                    if (G_argcnt==3) {
    				    getstr();
                        strcpy(G_s[0],G_s[1]);
                    } else {
                        strcpy(G_s[0]," ");
                    }
    				get2strs();
    				if ((k=keystroke(G_s[1]))!=0) sendmsg("INPUT1",'K',k,G_s[2],G_s[0]);
                }
                G_argcnt=0;
				break;
            case WAITFLAG  :
                l=popl(); 
                if (l) {
                    sendmsg("OUTPUT1",'AN',71,20,3,(int)((l*182L)/80L),"CLOCK.BMP");
                    G_waiting=1;
                } else {
                    sendmsg("OUTPUT1",'DA',"CLOCK.BMP");
                    G_waiting=0;
                }
                break;
            case WAITTEST  : sendmsg("INPUT1",'RK'); break;
            case SETDSKEY  :
                if (G_argcnt!=0) {
                    stknum(G_argcnt-1,&numb);
                    j=(int)numb;
                    for (k=G_argcnt-2;k>=0;k--) {
                        getstr();
                        if (k<G_store[j].numitem) {
                            sendmsg("DBM",'p',G_store[j].name,G_lib[G_store[j].li[k]].name,G_s[1]);
                        }
                    }
                    popl();
                }
                G_argcnt=0;
                break;
            case RUNCOPY   :
                l=popl(); 
                getstr(); 
                strcpy(G_s[0],G_s[1]);
                getstr(); 
				G_depth++;
				varspace=MALLOC(10*sizeof(long));
				if (varspace!=NULL) {
					memcpy(varspace,G_vars,10*sizeof(long));
					memset(G_vars,0,10*sizeof(long));
                    k=(int)l;
                    (char *)t=STRDUP(G_s[0]);
                    sendmsg("DISK",'s',G_database,t,G_store[k].name);
                    runaction(G_s[1]);
                    sendmsg("DISK",'s',G_database,t,G_store[k].name);
					memcpy(G_vars,varspace,10*sizeof(long));
					FREE(varspace);
				} else {
#ifdef __TURBOC__
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					sound(5000); delay(200); sound(1000); delay(100);
					nosound();
#endif
				}
                break;
            case DISPHOT   :
                k=sendmsg("INPUT1",'NH');
                if (k>0) {
                    for (j=0;((j<k)&&(j<30));j++) {
                        strcpy(G_s[0],keyname(sendmsg("INPUT1",'HN',j)));
                        sendmsg("INPUT1",'HD',j,G_s[1]);
                        sendmsg("OUTPUT1",'o',(j/15)*40,(j%15)+7," [%-5.5s] %-30.30s ",G_s[0],G_s[1]);
                    }
                } else {
                    sendmsg("OUTPUT1",'o',0,7," [-----] No Hot Heys Found ");
                }
                sendmsg("INPUT1",'i');
                break;
            default : 
#ifdef __TURBOC__
                sound(1000);
                delay(100);
                sound(5000);
                delay(100);
                sound(2000);
                delay(100);
                sound(6000);
                delay(100);
                sound(3000);
                delay(100);
                nosound();
#else
                ;
#endif

        }
        o++;
        if (G_run<2) {
			pstack();
        	if (!xit) {
            	if (G_run) {
                	if (kbhit()) {
                    	G_run=0;
                    	getch();
                	}
            	}
            	else {
                	k=getch();
                	if (k==27) {
#ifdef __TURBOC__
						textattr(0x07);
                    	clrscr();
#endif
                    	sendmsg("DBM",'ca');
                    	printf("GPA Abort.\n");
						cleanupblks(1);
                    	exit(-1);
                	}
                	if (k=='r') G_run=1;
                	if (k=='s') G_run=2;
                	if (k=='c') {
I                         mov ax,3
I                         int 0x10
                    }
            	}
        	}
		}
		if ((bm[0]==(-1))&&(xit==2)) xit=0;
    }
    if (xit==2) RETURNV(0);
    RETURNV(1);
}
// find the name of an action and RETURN it's number offset ( -1 = not found )
int findname(char *name)
{
    int i=0;
	ENTRY(1870);

    for (i=0;i<G_numn;i++) {
        if (!strcmp(name,G_nbuf[i].n)) RETURNV(i);
    }
    RETURNV(-1);
}
// run the tokens associated with name
int runtokens(char *name)
{
    int ret;
	long *varspace;
	ENTRY(1880);

    if ((G_ca=findname(name))==(-1)) RETURNV(0);
    if (G_debug) {
        G_run=0;
        sendmsg("OUTPUT1",'TE');
        sendmsg("INPUT1",'TE');
#ifdef __TURBOC__
        textattr(0x07);
        clrscr();
#endif
        mprintf("þ");
		G_depth++;
		varspace=MALLOC(10*sizeof(long));
		if (varspace!=NULL) {
			memcpy(varspace,G_vars,10*sizeof(long));
			memset(G_vars,0,10*sizeof(long));
	        ret=inttok(G_nbuf[G_ca].o);
			memcpy(G_vars,varspace,10*sizeof(long));
			FREE(varspace);
		} else {
#ifdef __TURBOC__
			sound(5000); delay(200); sound(1000); delay(100);
			sound(5000); delay(200); sound(1000); delay(100);
			sound(5000); delay(200); sound(1000); delay(100);
			nosound();
#endif
		}
		G_depth--;
        pstack();
#ifdef __TURBOC__
        textattr(0x1F);
        gotoxy(1,12);
        cprintf("                        COMPLETE  -  PRESS SPACE                                ");
        gotoxy(79,25);
#endif
        while (getch()!=32);
        sendmsg("OUTPUT1",'RI');
        sendmsg("OUTPUT1",'R');
        sendmsg("INPUT1",'RI');
    } else {
//		beep();
        G_run=2;
		G_depth++;
		varspace=MALLOC(10*sizeof(long));
		if (varspace!=NULL) {
			memcpy(varspace,G_vars,10*sizeof(long));
			memset(G_vars,0,10*sizeof(long));
	        ret=inttok(G_nbuf[G_ca].o);
			memcpy(G_vars,varspace,10*sizeof(long));
			FREE(varspace);
		} else {
#ifdef __TURBOC__
			sound(5000); delay(200); sound(1000); delay(100);
			sound(5000); delay(200); sound(1000); delay(100);
			sound(5000); delay(200); sound(1000); delay(100);
			nosound();
#endif
		}
		G_depth--;
    }
    RETURNV(ret);
}
// free the token list from memory
void freeactions(void)
{
	int i;
	ENTRY(1900);
    if (G_nbuf!=NULL) {
	    for (i=0;i<G_numn;i++) {
			if (((G_nbuf[i].t==STATNAME)||(G_nbuf[i].t==VARIABLE))&&(G_nbuf[i].b!=NULL)) {
				FREE(G_nbuf[i].b);
			}
		}	
		FREE(G_nbuf);
	}
	G_nbuf=NULL;
	RETURN;
}
// load the token list into memory
int loadactions(char *sys)
{
    unsigned long l,tl,l1;
    int i,fd;
    unsigned int j;
	char tmp[100];

	ENTRY(1890);
	memset(G_vars,0,sizeof(G_vars));
    sprintf(G_afilename,"%s%sI.DAT",G_config,sys);

    if ((fd=open(G_afilename,O_RDONLY|O_BINARY))==(-1)) RETURNV(0);
    read(fd,&G_numn,sizeof(int));
    if (G_numn==0x5A5A) {
        read(fd,&G_numn,sizeof(int));
	    G_nbuf=MALLOC(G_numn*sizeof(NAMEINDEX));
        if (G_nbuf==NULL) {
            close(fd);
            RETURNV(0);
        }
        for (i=0;i<G_numn;i++) {
            read(fd,&G_nbuf[i].d,sizeof(char));
            read(fd,&G_nbuf[i].t,sizeof(char));
            read(fd,&G_nbuf[i].o,sizeof(long));
            read(fd,&G_nbuf[i].n,9);
        }
        read(fd,&l,sizeof(long));
    } else {
	    G_nbuf=MALLOC(G_numn*sizeof(NAMEINDEX));
        if (G_nbuf==NULL) {
            close(fd);
            RETURNV(0);
        }
        for (i=0;i<G_numn;i++) {
            read(fd,&G_nbuf[i].d,sizeof(char));
            read(fd,&G_nbuf[i].t,sizeof(char));
            read(fd,&j,sizeof(int));
            G_nbuf[i].o=(unsigned long)j;
            read(fd,&G_nbuf[i].n,9);
        }
        read(fd,&j,sizeof(int));
        l=(unsigned long)j;
    }
	G_buffofs=lseek(fd,0L,SEEK_CUR);
    for (i=0;i<G_numn;i++) {
		if ((G_nbuf[i].t==STATNAME)||(G_nbuf[i].t==VARIABLE)) {
			lseek(fd,G_buffofs+G_nbuf[i].o+1,SEEK_SET);
			read(fd,tmp,80);
			(char *)G_nbuf[i].b=STRDUP(tmp);
            G_forvars+=strlen(tmp);
		}
	}
    G_buff=MALLOC(10000);
    if (G_buff==NULL) {
		printf("Can't Load Actions - Not Enough Memory\n");
		freeactions();
        close(fd);
        RETURNV(0);
	}
	setupblk(G_afilename,l);
	lseek(fd,G_buffofs,SEEK_SET);
    tl=0;
    while (tl<l) {
        l1=read(fd,G_buff,10000);
        if (l1<=0) {
            tl=l;
        } else {
			savepblk(G_afilename,G_buff,tl,l1);
            tl+=l1;
        }
	}
	close(fd);
	FREE(G_buff);
	G_buff=NULL;
    transfer(0L);
    RETURNV(1);
}
// dump the state of the previosly loaded forms ( Critical memory error )
void dumpstate(int from)
{
    int i;
	ENTRY(1910);
    sendmsg("OUTPUT1",'TE');
    sendmsg("INPUT1",'TE');
    printf("Critical Error - Exit point %d\n",from);
    for (i=0;i<G_numsf;i++) printf("%-10s",G_savedf[i].name);
    printf("\n");
    exit(0);
}
// save the state of the previosly loaded form
int savestate(void)
{
	ENTRY(1920);

    if (G_numsf==MAXRECURSE) RETURNV(0);

    strcpy(G_savedf[G_numsf].name,G_form.name);
    G_savedf[G_numsf].item=G_form.curitem;
    G_savedf[G_numsf].nitem=G_form.numitem;
    G_savedf[G_numsf].vars=G_formvars;
    G_savedf[G_numsf].mark=G_formmark;
    G_savedf[G_numsf].tflds=G_tflds;
    G_tflds=NULL;
    G_formvars=NULL;
    G_numsf++;
    freeform(&G_form);
    RETURNV(1);
}
// restore the state of the previosly loaded form
int reststate(void)
{
	ENTRY(1930);


    if (G_numsf==0) RETURNV(0);

    G_numsf--;

    clrform(&G_form);
    freeform(&G_form);
    strcpy(G_form.name,G_savedf[G_numsf].name);

    if (!loadform(&G_form)) RETURNV(0);
    if (G_form.type==F_MENU) {
        orderform(&G_form,1);
    }
    else {
        if ((G_form.type==F_PROMPT)||(G_form.type==F_SERVE)||(G_form.type==F_NORM)) {
            orderform(&G_form,0);
        } else {
            orderform(&G_form,1);
        }
    }
    G_form.curitem=G_savedf[G_numsf].item;
    G_formvars=G_savedf[G_numsf].vars;
    G_tflds=G_savedf[G_numsf].tflds;

	if ((G_exit2mrk==1)&&(G_savedf[G_numsf].mark==1)) G_exit2mrk=0;
    RETURNV(1);
}
void setdsacc(char *n1,char *n2)
{
    int i;
    char *t,tmp[18];
    PFORMF f;
	ENTRY(1940);
    if ((n1==NULL)||(n2==NULL)) RETURN;

    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if ((f->class!=FF_TEXT)&&(f->class!=FF_TABL)){
            t=f->item;
            while (isspace(*t)) t++;
            if (!strncmp(n1,t,strlen(n1))) {
                sprintf(tmp,"%8s.%-8s",n2,&(f->item[9]));
                strcpy(f->item,tmp);
            }
        }
    }
	RETURN;
}
// load a new form to the screen.  Saving the old
int loadnewform(char *name,long index,char *n1,char *n2,int w)
{
	FSAVE savedf;
	int i;
	ENTRY(1950);
	if (w) {
    	savedf.nitem=G_form.numitem;
    	savedf.item=G_form.curitem;
    	savedf.vars=G_formvars;
    	G_formvars=NULL;
	} else {
    	if (!savestate()) dumpstate(0);
	}

    clrform(&G_form);
    freeform(&G_form);
    if (index>(-1L)) {
        if (!loadformidx(&G_form,index)) {
		    if (!reststate()) dumpstate(1);
			RETURNV(0);
		}
    }
    else {
        strcpy(G_form.name,name);
        if (!loadform(&G_form)) {
		    if (!reststate()) dumpstate(1);
			RETURNV(0);
		}
    }
    if (G_form.access<=G_access) {
    
        if (G_form.type==F_MENU) {
            orderform(&G_form,1);
            runmenu();
        }
        else {
            if ((G_form.type==F_PROMPT)||(G_form.type==F_SERVE)||(G_form.type==F_NORM)) {
                orderform(&G_form,0);
                if (!initform(&G_form)) {
                    clrform(&G_form);
                    freeform(&G_form);
				    if (!reststate()) dumpstate(1);
                    RETURNV(0);
                }
                setdsacc(n1,n2);
				G_formmark=0;
				if (w) {
					for (i=0;i<savedf.nitem;i++) {
						if ((G_form.items[i].class!=FF_TEXT)&&(G_formvars[i]!=NULL)&&(savedf.vars[i]!=NULL)) {
							if (i<=savedf.item)
								strcpy(G_formvars[i],savedf.vars[i]);
							FREE(savedf.vars[i]);
						}
					}
					G_form.curitem=savedf.item;
					FREE(savedf.vars[i]);
				} else {
                	runform(1);
	                clrform(&G_form);
				}
            } else {
                orderform(&G_form,1);
                if (!initform(&G_form)) {
                    clrform(&G_form);
                    freeform(&G_form);
				    if (!reststate()) dumpstate(1);
                    RETURNV(0);
                }
                setdsacc(n1,n2);
				G_formmark=0;
				if (w) {
					for (i=0;i<savedf.nitem;i++) {
						if ((G_form.items[i].class!=FF_TEXT)&&(G_formvars[i]!=NULL)&&(savedf.vars[i]!=NULL)) {
							if (i<=savedf.item)
								strcpy(G_formvars[i],savedf.vars[i]);
							FREE(savedf.vars[i]);
						}
					}
					G_form.curitem=savedf.item;
					FREE(savedf.vars[i]);
				} else {
	                runform(1);
	                clrform(&G_form);
				}
            }
        }
		G_formloaded++;
    }
    else {
        errorline(G_noacc,1);
    }
	if (!w) {
    	freeform(&G_form);
		if (!reststate()) dumpstate(1);
	}
    RETURNV(1);
}
// save the state if the screen will be modified and then run an action 
int runaction(char *name)
{
    char newname[9],*e;
	long fl;
	int t;
	ENTRY(1960);

    e=&name[strlen(name)-1];
    while ((e!=name)&&(isspace(*e))) e--;
    if (e!=name) *(e+1)=0;

    strncpy(newname,name,9);

    name=newname;

    if ((!strcmp(name,"NONE"))
     || (name[0]==0)
     || (name==NULL)) RETURNV(0);

	fl=G_formloaded;
    subaction(name,0);
	if (fl!=G_formloaded) {
		if ((!G_exit2top)&&(!G_exit2mrk)) restoreform();
	} else {
		t=G_form.type;
        if (((t==F_PROMPT)||(t==F_SERVE)||(t==F_NORM))) // &&(!G_intable)
			fillfields(&G_form);
//			fillform(&G_form);
	}
	RETURNV(1);
}
// RETURNs true if name is an action <0 token list, >0 cfunc, >1000 ufunc.
int isaction(char *name)
{
    int i=0;
    char *e;
	ENTRY(1970);

    e=&name[strlen(name)-1];
    while ((e!=name)&&(isspace(*e))) e--;
    if (e!=name) *(e+1)=0;

    if ((i=findname(name))!=(-1)) {
        RETURNV(0-(i+1));
    }
    i=0;
    while (G_ufunc[i].name!=NULL) {
        if (!strcmp(name,G_ufunc[i].name)) {
            RETURNV(i+1000);
        }
        i++;
    }
    i=0;
    while (G_actmap[i].name!=NULL) {
        if (!strcmp(name,G_actmap[i].name)) {
            RETURNV(i+1);
        }
        i++;
    }
    RETURNV(0);
}
// called to run any action ( FORM CFUNC UFUNC ACTION )
int subaction(char *name,int depth)
{
    int i;
	ENTRY(1980);

    if (depth==MAXRECURSE) {
        beep();
        sendmsg("OUTPUT1",'o',0,23,"Tried to run action \"%s\" - recurse too deep!",name);
        sendmsg("OUTPUT1",'o',0,24,"Press Any Key");
        sendmsg("INPUT1",'i');
        RETURNV(0);
    }
    if (!strcmp(name,"NONE    ")) RETURNV(0);

    if (((i=isaction(name))==0)&&(isform(name)==(-1L))) RETURNV(0);

    if (i==0) {
        if (!loadnewform(name,(-1L),NULL,NULL,0)) {
            beep();
            sendmsg("OUTPUT1",'o',0,23,"Tried to run form \"%s\" - Non-existent!",name);
            sendmsg("OUTPUT1",'o',0,24,"Press Any Key");
            sendmsg("INPUT1",'i');
        }
    }
    else {
        if (i>0) {
            if (i>999) {
                if (G_ufunc[i-1000].access<=G_access) {
                    if ((G_ufunc[i-1000].func)()==0) RETURNV(0);
                }
                else {
                    errorline(G_noacc,1);
                    RETURNV(0);
                }
            }
            else {
                if (G_actmap[i-1].access<=G_access) {
                    if ((G_actmap[i-1].func)()==0) RETURNV(0);
                }
                else {
                    errorline(G_noacc,1);
                    RETURNV(0);
                }
            }
        }
        else {
			G_prinprog=0;
			if (bm[0]==(-1)) {
				runtokens(name);
			} else {
            	if (!runtokens(name)) errorline(G_noacc,1);
			}
			if (G_prinprog) {
				sendmsg("OUTPUT2",'SP',0,0);
				G_prinprog=0;
				G_pagenum=0;
			}
        }
    }
    RETURNV(1);
}

