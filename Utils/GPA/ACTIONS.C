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
#include "actionc.h"
#include "actions.h"
#include "control.h"
#include "instruct.h"
#include "arith.h"
#include "dst.h"
#include "global.h"
#include "lang.h"
#include "money.h"

#ifdef WIEN
 #ifdef DOS
 extern INT isbegintxn;
 #endif//DOS
 int gpabegin;
 extern void errorline (CHAR *e,INT type);
#endif//WIEN

INT G_checkresult=0;


extern CHAR *G_keyname[];
LONG test=0;
INT G_depth=0;
CHAR *G_a[5];
LONG l,m,n;
LONG G_ofb=-5000L;
INT G_argcnt=0;
INT G_prinprog=0;
INT loadnewform(CHAR *name,INT index,CHAR *n1,CHAR *n2,INT w);
INT G_lidx=(-100);
// Push a value onto the CALL stack
void cpush(ULONG c)
{
	ENTRY(1750);
    G_cstack[G_csp++]=c;
	RETURN;
}
// Pop a value from the CALL stack
ULONG cpop(void)
{
	ENTRY(1760);
    RETURNV(G_cstack[--G_csp]);
}

// replacement cprintf command (only writes to top half of screen)
void mprintf(CHAR *fmt, ... )
{
    static INT x=0;
    static INT y=0;
    UCHAR *scr;
    UCHAR str[140],*s;
    va_list ap;
	ENTRY(1770);

	if (!*G_debug) RETURN;

    scr=(UCHAR *)TEXTVIDMEM;

    va_start(ap,fmt);
    vsprintf((CHAR *)str,fmt,ap);
    va_end(ap);

    if (((UCHAR)(str[0]))==(UCHAR)'þ') { x=0; y=0; RETURN; }

    s=str;
    while (*s) { 
        *(scr+x*2+y*160)=*s;
        *(scr+x*2+y*160+1)=(UCHAR)G_attr;
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
// prints all the stack and variable information
void pstack(void)
{
    INT i,j,k;
    CHAR t,tmp[MAXSTRLEN];
	ENTRY(1780);

    j=stksize();
    if (j>10) j=10;
    sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x0B);
    for (i=0;i<j;i++) {
        sendmsg("OSSDEV",MESSAGE_xy,1,i+13);
        t=stkstr(i,tmp);
        sendmsg("OSSDEV",MESSAGE_p,"%-10.10s %c",tmp,t);
    }
    for (;i<10;i++) {
        sendmsg("OSSDEV",MESSAGE_xy,1,i+13);
        sendmsg("OSSDEV",MESSAGE_p,"            ");
    }
    sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x0D);
    for (i=0;i<10;i++) {
        sendmsg("OSSDEV",MESSAGE_xy,14,i+13);
        sendmsg("OSSDEV",MESSAGE_p,"%f",G_vars[i]);
    }
    j=G_form.numitem;
    if (j>30) j=30;
    k=0;
    if (G_formvars!=NULL) {
        for (i=0;i<j;i++) {
            if (G_formvars[i]!=NULL) {
                if (i==G_form.curitem) sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x0C); else sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x0E);
                sendmsg("OSSDEV",MESSAGE_xy,25+((k/10)*11),(k%10)+13);
                sendmsg("OSSDEV",MESSAGE_p,"%10.10s",G_formvars[i]);
                k++;
            }
        }
    } else {
        for (i=0;i<30;i++) {
            sendmsg("OSSDEV",MESSAGE_xy,25+((k/10)*11),(k%10)+13);
            sendmsg("OSSDEV",MESSAGE_p,"          ");
        }
    }
    for (;k<30;k++) {
        sendmsg("OSSDEV",MESSAGE_xy,25+((k/10)*11),(k%10)+13);
        sendmsg("OSSDEV",MESSAGE_p,"          ");
    }
	RETURN;
}

// print the name of token o 
void ptok(UCHAR *o)
{
	ENTRY(1790);
    switch (gettoken(o)) {
        case TCONSTANT : mprintf("%d " ,gettiny(o+1));  break;
        case SCONSTANT : mprintf("%d " ,getint (o+1) );   break;
        case LCONSTANT : mprintf("%ld ",getlong(o+1)); break;
        case DCONSTANT : mprintf("%f " ,getdoub(o+1));         break;
        case CCONSTANT : mprintf("%s " ,getstrg(o+1) );  break;
        case TABLE     : mprintf("TABLE ");                         break;
        case ANAME     : mprintf("ACTION ");                        break;
        case EQUAL     : mprintf("= ");                             break;
        case DSEQUAL   : mprintf("DS= ");                           break;
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
        case SETTVARIB : mprintf("@TV ");                           break;
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
        case DATESWAP  : mprintf("DATESWAP ");                      break;
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
        case  DUPDSFMT  : mprintf("DUPDSFMT ");                      break;
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
        case PRSEQNCE  : mprintf("PRSEQNCE ");                      break;
        case USEPRDEF  : mprintf("USEPRDEF ");                      break;
        case MOVEPLN   : mprintf("MOVEPLN ");                       break;
        case SENDLINE  : mprintf("SENDLINE ");                      break;
        case SENDEOL   : mprintf("SENDEOL ");                       break;
        case JUMPTO    : mprintf("JUMPTO ");                        break;
        case MOVETCUR  : mprintf("MOVETCUR ");                      break;
        case SETDSKEY  : mprintf("SETDSKEY ");                      break;
        case RUNCOPY   : mprintf("RUNCOPY ");                       break;
        case RUNSRCH   : mprintf("RUNSRCH ");                       break;
        case BLDSLIST  : mprintf("BLDSLIST ");                      break;
        case BLDTLIST  : mprintf("BLDTLIST ");                      break;
        case DRAWTABL  : mprintf("DRAWTABL ");                      break;
        case USESLIST  : mprintf("USESLIST ");                      break;
        case DISPHOT   : mprintf("DISPHOT ");                       break;
        case BLANKREC  : mprintf("BLANKREC ");                      break;
        case VARARGS   : mprintf("VARARGS ");                       break;
        case WAITFLAG  : mprintf("WAITFLAG ");                      break;
        case WAITTEST  : mprintf("WAITTEST ");                      break;
//#ifdef WIEN
        case DIVSPEC   : mprintf("DIVSPEC ");                       break;
        case STCLOSE   : mprintf("STCLOSE ");                       break;
        case CUSTDISP  : mprintf("CUSTDISP ");                      break;
        case APPLYFMT  : mprintf("APPLYFMT ");                      break;
        case STDELETE  : mprintf("STDELETE ");                      break;
        case HOTDISP   : mprintf("HOTDISP ");                       break;
        case PGOTOXY   : mprintf("PGOTOXY  ");                      break;
        case SLEN      : mprintf("SLEN   ");                        break;
        case ERRLOG    : mprintf("ERRLOG ");                        break;
        case PRLINXY   : mprintf("PRLINXY");                        break;
        case STUPDATE  : mprintf("STUPDATE");                       break;
        case STLOCK    : mprintf("STLOCK ");                        break;
        case ABS       : mprintf("ABS ");                           break;
        case LBLDRUCK  : mprintf("LBLDRUCK ");                      break;
        case LBLINIT   : mprintf("LBLINIT ");                       break;
        case LBLMULTI  : mprintf("LBLMULTI ");                       break;
        case PUTINTO   : mprintf("PUTINTO ");                       break;
        case TRBORFSH  : mprintf("TRBORFSH ");                       break;
        case STQSORT   : mprintf("STQSORT ");                       break;
        case STRSTR    : mprintf("STRSTR ");                       break;
//#endif//WIEN
        default        : mprintf("Error Unknown Instruction %d ",gettoken(o));
    }
	RETURN;
} 
// skip the token buffer until the matching '}' 
UCHAR *skip(UCHAR *o)
{
    INT xit=0;
    UCHAR *s;
    INT curly=0;
	ENTRY(1800);
    G_attr=8;
    o++;
    while (!xit) {
        s=o;
        switch (gettoken(o)) {
            case TCONSTANT : o++;                           break;
            case SCONSTANT : o+=sizeof(INT);                break;
            case LCONSTANT : o+=sizeof(LONG);               break;
            case DCONSTANT : o+=sizeof(double);             break;
            case CCONSTANT : while (gettiny(o+1)) o++; o++; break;
            case OCURLY    : curly++;                       break;
            case CCURLY    : curly--; if (curly<1) xit=1;   break;
        }
        if ((G_run<2)&&(!xit)) ptok(s);
        o++;
    }
    G_attr=10;
    RETURNV(o);
}
// RETURN the  CALL stack tos as a LONG (passed value)
LONG psd(void)
{
	ENTRY(1810);
    RETURNV((LONG)G_cstack[G_csp-1]);
}
void fmtmatch(void)
{
    CHAR fmt[80];
    CHAR str[80];
    INT type,l,i;
	ENTRY(1820);

    getnum();
    type=(INT)G_n1;
    getstr();
    strcpy(fmt,G_s1);
    getstr();
    strcpy(str,G_s1);

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
CHAR *getvarib(INT n)
{
    return((CHAR *)G_nbuf[n].b);
}
CHAR *setvarib(INT n,CHAR *s)
{
    if ((n<0)||(n>=G_numn)) return(NULL);
    strcpy((CHAR *)G_nbuf[n].b,s);
    return((CHAR *)G_nbuf[n].b);
}
void setstatic(INT n,CHAR *s)
{
    INT fd;
	CHAR *e;
    e=setvarib(n,s);
	if (e!=NULL) {
		fd=open(G_afilename,O_RDWR|O_BINARY);
		if (fd!=(-1)) {
			lseek(fd,G_buffofs+actionofs(n)+1,SEEK_SET);
			write(fd,e,80);
			close(fd);
		}
	}
}
void equals(void)
{
    CHAR t=stktype(0);
	CHAR tmp[81];
    int i;
	ENTRY(1830);

    if (t=='n') {
        getnum();
        G_n0=G_n1;
    }
    else {
        getstr();
        strcpy(G_s0,G_s1);
    }
    getstr();
    switch (G_s1[0]) {
        case 'F' : // STACK - idx F val = TOS
            getnum();
		    if ((G_n1>0)&&(G_formvars!=NULL)&&(G_formvars[(INT)G_n1]!=NULL)&&(G_form.numitem>(INT)G_n1)) {
                if (G_form.items[(INT)G_n1].class!=FF_TEXT) {
        	        if (t=='n') {
             	        NTOA(G_formvars[(INT)G_n1],G_n0);
        	        } else {
            	        strncpy(G_formvars[(INT)G_n1],G_s0,80);
                 }
    		    } else {
            	if (t=='n') {
                  NTOA(tmp,G_n0);
            	} else {
                  strncpy(tmp,G_s0,80);
				   }
    				if (strlen(tmp)>1) {
    					for (i=5000;i>1000;i-=100) { sendmsg("OSSDEV",MESSAGE_s,i); sendmsg("OSSDEV",MESSAGE_d,10); }
    					sendmsg("OSSDEV",MESSAGE_d,100);
    					sendmsg("OSSDEV",MESSAGE_ns);
    				} else {
    					strcpy(G_formvars[(INT)G_n1],tmp);
    				}
			    }
			} else {
    			for (i=1000;i<5000;i+=100) { sendmsg("OSSDEV",MESSAGE_s,i); sendmsg("OSSDEV",MESSAGE_d,10); }
    			sendmsg("OSSDEV",MESSAGE_d,100);
    			sendmsg("OSSDEV",MESSAGE_ns);
		    }
            break;
        case 'D' :  // STACK - sidx fidx D val = TOS
            get2nums();
            if (t=='n') NTOA(G_s0,G_n0);
            sendmsg("DBM",MESSAGE_qp,(UCHAR)G_n1,(UCHAR)G_n2,G_s0);
            break;
        case 'V' :  // STACK - idx V val = TOS
            getnum();
            if (t=='n') 
                G_vars[(INT)G_n1]=(VARTYPE)G_n0;
            else
                G_vars[(INT)G_n1]=(VARTYPE)(ATON(G_s0));
            break;
        case 'T' :  // STACK - idx V val = TOS
            getnum();
            if (t=='n') 
                G_tvars[(INT)G_n1]=(LONG)G_n0;
            else
                G_tvars[(INT)G_n1]=(LONG)(ATON(G_s0));
            break;
        case 'G' :  // STACK - idx G val = TOS
            getnum();
            if (t=='n') NTOA(G_s0,G_n0);
            setglobal((INT)G_n1,G_s0);
            break;
        case 'U' :  // STACK - idx U val = TOS
            getnum();
            if (t=='n') NTOA(G_s0,G_n0);
            setvarib((INT)G_n1,G_s0);
            break;
        case 'S' :  // STACK - idx S val = TOS
            getnum();
            if (t=='n') NTOA(G_s0,G_n0);
            setstatic((INT)G_n1,G_s0);
            break;
        default :  // STACK - C val = TOS
            if (t=='n') {
                G_form.curitem=(INT16)G_n0;
            }
            else {
                G_form.curitem=(INT16)(ATON(G_s0));
            }
    }
	RETURN;
}
void delst(CHAR *name)
{
    INT s=snum(name);
	ENTRY(1840);
    if (s==(-1)) RETURN;
    sendmsg("DBM",MESSAGE_D,name);
    memcpy(&G_store[s],&G_store[s+1],sizeof(STORE)*((G_nums-1)-s));
    G_nums--;
    sendmsg("DBM",MESSAGE_RI);
	RETURN;
}
UCHAR *isdefstr(CHAR *s)
{
	INT i;
	ENTRY(1850);
	for (i=0;i<G_nut;i++) {
		if (!strcmp(G_tname[i],s))
            RETURNV((UCHAR *)atextstr(i));
	}
	RETURNV((UCHAR *)s);
}
INT keystroke(CHAR *s)
{
	INT retval=0;
	INT l,i;
	ENTRY(1851);
	l=strlen(s);
	if (l==1) {
		retval=(INT)*s;
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
CHAR *dateswap(CHAR *s)
{
    INT d,m,y;
    static CHAR r[15];
    d=getday(s); m=getmon(s); y=getyear(s);
  	orddfrom(&y,&m,&d);
    sprintf(r,"%02d%02d%02d",d,m,y);
    return(r);
}

INT divspec(INT a,INT b)
{
  INT c=a/b;
  if (a%b) c++;
  return(c*b);
}

// interpret the tokens at address p
INT inttok(UCHAR *o)
{
    UCHAR *t;
    VARTYPE *varspace;
    UCHAR *s;
    ULONG inwhere=0L;
	UCHAR rform=0;
    UCHAR xit=0;
    UCHAR curly=0;
    UCHAR total=0;
    NUMB numb;
    INT k,j,ca;
    LONG m,n;
//    FILE *errorlog;
	ENTRY(1860);
    G_actionrun++;

    G_attr=10;
//	memset(G_vars,0,sizeof(VARTYPE)*10);
    ca=G_ca;
    while (!xit) {
        G_ca=ca;
        switch (gettoken(o)) {
            case TCONSTANT : PUSHN(gettiny(o+1)); o++;               break;
            case SCONSTANT : PUSHN(getint (o+1)); o+=sizeof(INT);    break;
            case LCONSTANT : PUSHN(getlong(o+1)); o+=sizeof(LONG);   break;
            case DCONSTANT : PUSHN(getdoub(o+1)); o+=sizeof(double); break;
            case CCONSTANT :
				PUSHS((CHAR *)isdefstr((CHAR *)getstrg(o+1)));
				while (gettiny(o+1)) o++;
				o++;
				break;
            case PLUS      : add();                                                break;
            case EQUAL     : equals();                                             break;
            case NEGATE    : neg();                                                break;
            case DSEQUAL   :
                l=popl(); m=popl(); n=popl();
                sendmsg("DBM",MESSAGE_md,(UCHAR)l,(UCHAR)m,(UCHAR)n,(UCHAR)popl());
                break;
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
            case TABLE     : popl();                                                break;
            case ANAME     : popl();                                                break;
            case LOGIC_AND : land();                                               break;
            case LOGIC_OR  : lor();                                                break;
            case LOGIC_NOT : lnot();                                               break;
            case ELSE      : o=skip(o)-1;                                          break;
            case MARKER    : cpush((LONG)o);                                             break;
            case FORMVAR   :
                l=popl();
                if ((l>0)&&(l<G_form.numitem)&&(G_formvars!=NULL)&&(G_formvars[(INT)l]!=NULL)) {
                    PUSHS(G_formvars[(INT)l]);
                } else {
					sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,2000); sendmsg("OSSDEV",MESSAGE_d,200);
					sendmsg("OSSDEV",MESSAGE_s,3000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,4000); sendmsg("OSSDEV",MESSAGE_d,200);
					sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200);
					sendmsg("OSSDEV",MESSAGE_ns);
                    PUSHN(0);
                }
                break;
            case GLOBVAR   : PUSHS(getglobal((INT)popl()));                             break;
            case TVARIABLE : PUSHN(G_tvars[(INT)popl()]);                                break;
            case VARIABLE  : PUSHN(G_vars[(INT)popl()]);                                break;
            case CURFIELD  : PUSHN(G_form.curitem);                                break;
            case SETGLOBVR : PUSHS("G");                                           break;
            case SETFMVAR  : PUSHS("F");                                           break;
            case SETVARIAB : PUSHS("V");                                           break;
            case SETTVARIB : PUSHS("T");                                           break;
            case SETCURITM : PUSHS("C");                                           break;
            case SETUSRVAR : PUSHS("U");                                           break;
            case SETSTATIC : PUSHS("S");                                           break;
            case STATICS   : PUSHS(getvarib((INT)popl()));                   		   break;
            case USERVAR   : PUSHS(getvarib((INT)popl()));                   		   break;
            case LOOKTAB   :              
                G_checkresult=1;
            case ACTIONN   :
				G_depth++;
				varspace=MALLOC(10*sizeof(VARTYPE));
				if (varspace!=NULL) {
					memcpy(varspace,G_vars,10*sizeof(VARTYPE));
					memset(G_vars,0,10*sizeof(VARTYPE));
                    G_ca=(INT)popl();
					if (!inttok(actionbuf(G_ca))) xit=2;
					memcpy(G_vars,varspace,10*sizeof(VARTYPE));
					FREE(varspace);
				} else {
					sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
					sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
					sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
					sendmsg("OSSDEV",MESSAGE_ns);
				}
				G_depth--;
                if (G_checkresult) {
                    PUSHN(0); // returned from lookup with no return value
                }
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
                getnum(); G_n0=G_n1;
                if (popl()) {
                    G_checkresult=0;
                    cpop();
                    PUSHN(G_n0);
                    o=skip(o)-2;
                }
                break;
            case IF        :
                s=skip(o);
                if (gettoken(s)==ELSE) {
                    if (!popl()) o=s;
                } else {
                    if (!popl()) o=s-1;
                }
                break;
            case WHILE     :
                if (popl()) {
                    if (!inttok(o+1)) xit=2;
                    o=(UCHAR *)cpop()-1;
                }
                else {
                    cpop();
                    o=skip(o)-1;
                }
                break;
            case WHERE     :
                if (!inwhere) {
                    k=(INT)popl();
                    if (sendmsg("DBM",MESSAGE_r,G_store[k].name,(LONG)FRST)) {
                        inwhere=sendmsg("DBM",MESSAGE_rn,G_store[(INT)k].name);
                        popl();
                        o=(UCHAR *)cpop()-1;
                    } else {
                        cpop();
                        o=skip(o)-1;
                        inwhere=0L;
                    }
                } else {
                    k=(INT)popl();
                    if (popl()) if (!inttok(o+1)) xit=2;
                    if (sendmsg("DBM",MESSAGE_r,G_store[k].name,inwhere)) {
                        if (sendmsg("DBM",MESSAGE_r,G_store[k].name,(LONG)NEXT)) {
                            inwhere=sendmsg("DBM",MESSAGE_rn,G_store[k].name);
                            o=(UCHAR *)cpop()-1;
                        } else {
                            cpop();
                            o=skip(o)-1;
                            inwhere=0L;
                        }
                    } else {
                        cpop();
                        o=skip(o)-1;
                        inwhere=0L;
                    }
                }
                break;
            case FORMNAME  : 
                if (!rform) {
                    if (*G_debug) {
                        sendmsg("OUTPUT1",MESSAGE_RI);
                        sendmsg("OUTPUT1",MESSAGE_R);
                        sendmsg("INPUT1",MESSAGE_RI);
                    }
                   	l=loadnewform(NULL,(INT)popl(),NULL,NULL,0);
                    if (*G_debug) {
                        sendmsg("OUTPUT1",MESSAGE_TE);
                        sendmsg("INPUT1",MESSAGE_TE);
                    }
                    if (!l) xit=2;
                }
                break;
            case UFUNC     : 
                l=popl();
//                if (G_ufunc[(INT)l].savescr) {
//                    if (*G_debug) {
//                        sendmsg("OUTPUT1",MESSAGE_RI);
//                        sendmsg("OUTPUT1",MESSAGE_R);
//                        sendmsg("INPUT1",MESSAGE_RI);
//                    }
//                }
                l=(LONG)subaction(G_ufunc[(INT)l].name,0);
//                if (G_ufunc[(INT)l].savescr) {
//                    if (*G_debug) {
//                        sendmsg("OUTPUT1",MESSAGE_TE);
//                        sendmsg("INPUT1",MESSAGE_TE);
//                    }
//                }
                if (!l) xit=2;
                break;
            case CFUNC     :
                l=popl();
//                if (G_actmap[(INT)l].savescr) {
//                    if (*G_debug) {
//                        sendmsg("OUTPUT1",MESSAGE_RI);
//                        sendmsg("OUTPUT1",MESSAGE_R);
//                        sendmsg("INPUT1",MESSAGE_RI);
//                    }
//                }
                l=(LONG)subaction(G_actmap[(INT)l].name,0);
//                if (G_actmap[(INT)l].savescr) {
//                    if (*G_debug) {
//                        sendmsg("OUTPUT1",MESSAGE_TE);
//                        sendmsg("INPUT1",MESSAGE_TE);
//                    }
//                }
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
            case SUPPER    : getstr(); PUSHS(strupr(G_s1));                      break;
            case SLOWER    : getstr(); PUSHS(strlwr(G_s1) );                      break;
			case XTIMER	   : sendmsg("INPUT1",MESSAGE_xt,(INT)popl());						   break;
			case SWAPTO    :
                    getstr();
                    if (!loadnewform(G_s1,-1,NULL,NULL,1)) xit=2;
				break;
			case PICKKEY : 
				getstr();
				G_pickkey=keystroke(G_s1);
				break;
			case PSHKEY	   : 
				getstr();
				if ((k=keystroke(G_s1))!=0) {
                    sendmsg("INPUT1",MESSAGE_P,k);
    				sendmsg("INPUT1",MESSAGE_P,5000);
                }
				break;
            case JUMPTO    :
				getstr();
				(CHAR *)t=strtok(G_s1,"^");
				while (t!=NULL) {
					if ((k=keystroke((CHAR *)t))!=0) sendmsg("INPUT1",MESSAGE_P,k);
					(CHAR *)t=strtok(NULL,"^");
				}
				sendmsg("INPUT1",MESSAGE_P,5000);
				break;
            case MOVETCUR :
				get2strs();
                switch (toupper(G_s1[0])) {
                    case 'U' : G_tabmovet=1; break;
                    case 'D' : G_tabmovet=2; break;
                    case 'V' : G_tabmovet=5; break;
                    case 'L' : G_tabmovet=3; break;
                    case 'R' : G_tabmovet=4; break;
                    case 'H' : G_tabmovet=6; break;
                }
                G_tabmoved=atoi(G_s2);
				break;
			case SAVESCR : popl(); break; //sendmsg("OUTPUT1",MESSAGE_0+(INT)popl());  break;
			case SAVEDEV   : savedevices();                        				   break;
			case RESTDEV   : restdevices();                        				   break;
			case SETDEV	   :
				getstr();
				strcpy(G_s0,G_s1);
				get2strs();
				asigndev(G_s1,G_s2,G_s0[0]);
				break;
            case DUEDOM    : PUSHS(duedom((INT)popl()));                                break;
            case DAYOFWK   :
				getstr();
				PUSHS(G_days[(datetonum(G_s1)+2)%7]);
				break;
            case DATESTR   : PUSHS(datestr((INT)popl()));                               break;
            case DATESWAP  : getstr(); PUSHS(dateswap(G_s1));                         break;
            case FMTMATCH  : fmtmatch();                                           break;
            case GETYEAR   : getstr();   PUSHN(getyear(G_s1));                   break;
#ifdef WIEN
            case GETPROD   :
//                 PUSHN(getprod((INT)popl()));
                 getprod((INT)popl());
                 break;
#else
            case GETPROD   :
                 getprod((INT)popl());
                 break;
#endif //WIEN
            case INRANGE   : get2strs(); PUSHN(inrange(G_s1,G_s2));            break;
            case NMONTHS   : get2strs(); PUSHN(months (G_s1,G_s2));            break;
            case NDAYS     : get2strs(); PUSHN(days   (G_s1,G_s2));            break;
            case DUEHALF   : get2strs(); PUSHS(duehalf(G_s1,G_s2));            break;
            case RUN 	   : getstr(); runaction(G_s1);                          break;
            case RECNUM    : l=popl(); PUSHN(sendmsg("DBM",MESSAGE_rn,G_store[(INT)l].name)); break;
            case STEMPTY   : 
                 getstr();
#ifdef WIEN
               #ifdef DOS
//                if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
               #endif//DOS
                 PUSHN(sendmsg("DBM",MESSAGE_e,G_s1));
#else //WIEN
                 sendmsg("DBM",MESSAGE_e,G_s1);
#endif//WIEN
                 break;
            case TOTALBOX  :
                 get2strs();
                 l=popl();
                 m=popl();
                 n=popl();
                 k=G_form.type;
                 G_form.type=F_NORM;
                 output((INT)n,(INT)m,G_s2,(INT)l,G_s1,1,0);
                 G_form.type=(INT16)k;
                 break;
            case PRLINE    :
                 if (!G_prinprog) {
                 	G_pagenum=1;
                 	sendmsg("OUTPUT2",MESSAGE_SP,2,1);
                 	G_prinprog=1;
                 }
                     get2strs();
                     switch (G_s2[0]) {
                         case 0 :
                             break;
                         case 'M' :
                             strcpy(G_s1,mstr(G_s1,strlen(G_s2)));
                             break;
                         default :
                             strcpy(G_s1,applyformat(G_s1,&(G_s2[0]),1));
                     }
                     sendmsg("OUTPUT2",MESSAGE_o,-1,0,"%s",G_s1);
                     break;
            case PRLINXY    :
                 if (!G_prinprog) {
                 	G_pagenum=1;
                 	sendmsg("OUTPUT2",MESSAGE_SP,2,1);
                 	G_prinprog=1;
                 }
                     get2strs();//format and textstring
                     l=popl();//y-coordinate
                     m=popl();//x-coordinate
                     switch (G_s2[0]) {
                         case 0 :
                             break;
                         case 'M' :
                             strcpy(G_s1,mstr(G_s1,strlen(G_s2)));
                             break;
                         default :
                             strcpy(G_s1,applyformat(G_s1,&(G_s2[0]),1));
                     }
                     n=G_PrintLocal;
                     G_PrintLocal=2;
                     sendmsg("OUTPUT2",MESSAGE_o,(INT)m,(INT)l,"%s",G_s1);
                     G_PrintLocal=(INT)n;
                     break;
            case PREOL     : sendmsg("OUTPUT2",MESSAGE_OL); 				   			   break;
            case PREOF     : sendmsg("OUTPUT2",MESSAGE_OF); G_pagenum++;	   			   break;
            case PRAGAIN   : G_pagenum--; sendmsg("OUTPUT2",MESSAGE_RP); sendmsg("OUTPUT2",MESSAGE_SP,0,1); G_pagenum++;    break;
            case PRSEQNCE  :
                l=popl();
                getstr();
                sendmsg("OUTPUT2",MESSAGE_SS,G_s1,(INT)l);
                break;
            case USEPRDEF  :
                getstr();
                strncpy(G_printdef,G_s1,20);
                sendmsg("OUTPUT2",MESSAGE_I);
                break;
			case MOVEPLN   : 
                getnum();
				sendmsg("OUTPUT2",MESSAGE_MY,(INT)G_n1);
				break;
            case SENDLINE    :
                get2strs();
                switch (G_s2[0]) {
                    case 0 :
                        break;
                    case 'M' :
                        strcpy(G_s1,mstr(G_s1,strlen(G_s2)));
                        break;
                    default :
                        strcpy(G_s1,applyformat(G_s1,&(G_s2[0]),1));
                }
                strcpy(G_s0,G_s1);
                sendmsg("COMM",MESSAGE_O,(INT)popl(),G_s0);
                break;
            case SENDEOL     : sendmsg("COMM",(INT)popl(),"\r\n"); 				   			   break;

			case STDELREC  :
              getstr();
#ifdef WIEN
             #ifdef DOS
//              if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
             #endif//DOS
              PUSHN(sendmsg("DBM",MESSAGE_dr,G_s1,(LONG)CURR));
#else //WIEN
              sendmsg("DBM",MESSAGE_dr,G_s1,(LONG)CURR);
#endif//WIEN
              break;
            case PROMPT :
                get2strs();
                sendmsg("OUTPUT1",MESSAGE_A,0);
                sendmsg("OUTPUT1",MESSAGE_S,1);
                sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,"%s",G_s1);
                G_s0[0]=0;
                k=G_form.curitem;
                inputstr(1+strlen(G_s1)+1,G_elineat,G_s0,G_s2,0);
                G_form.curitem=(INT16)k;
                G_exitkey=0;
                k=strlen(G_s1)+strlen(G_s2)+3;
                sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,"%*.*s",k,k,"");
                PUSHS(G_s0);
                break;
#ifdef WIEN
            case STCLOSE   :
                PUSHN(sendmsg("DBM",MESSAGE_c,G_store[(int)popl()].name));
                break;
            case DIVSPEC   :
                get2nums();
                PUSHN(divspec((INT)G_n1,(INT)G_n2));
                break;
            case APPLYFMT  :
                getnum();
                get2strs();
                PUSHS(strcpy(G_s1,(applyformat(G_s2,G_s1,(INT)G_n0))));
                break;
            case CUSTDISP  :
				for (n=0;n<5;n++) { getstr(); G_a[(INT)n]=STRDUP(G_s1); }
                switch (G_a[3][0]) {
                    case 'I' :
                        sendmsg("VDU",MESSAGE_CI);
                        break;
                    case 'L' :
                        sendmsg("VDU",MESSAGE_CL);
                        break;
                    case 'C' :
                        sendmsg("VDU",MESSAGE_CC);
                        break;
                    case 'D' :
                        sendmsg("VDU",MESSAGE_CD,G_a[1],atoi(G_a[2]));
                        break;
                }
                for (n=0;n<5;n++) FREE(G_a[(INT)n]);
                break;
            case STDELETE   :
                getstr();
               #ifdef DOS
//                if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
               #endif//DOS
                PUSHN(sendmsg("DBM",MESSAGE_D,G_s1));
                break;
            case HOTDISP  :
				    for (n=0;n<3;n++) {
                  getstr();
                  G_a[(INT)n]=STRDUP(G_s1);
                }
                sendmsg("OUTPUT1",'HD',G_a[2],G_a[1],G_a[0]);
                for (n=0;n<3;n++) FREE(G_a[(INT)n]);
                break;
            case PGOTOXY  :
				    for (n=0;n<2;n++) {
                  getstr();
                  G_a[(INT)n]=STRDUP(G_s1);
                }
                sendmsg("OUTPUT2",MESSAGE_g,G_a[1],G_a[0]);
                for (n=0;n<2;n++) FREE(G_a[(INT)n]);
                break;
            case SLEN   :
                getstr();
                PUSHN(strlen(G_s1));
                break;
            case ERRLOG   :
                getstr();
                myerrorlog(G_s1);
                break;
#endif //WIEN
            case ERRLINE   :
                getnum();
                G_n0=G_n1;
                getstr();
                if (*G_debug) {
                    sendmsg("OUTPUT1",MESSAGE_RI);
                    sendmsg("OUTPUT1",MESSAGE_R);
                    sendmsg("INPUT1",MESSAGE_RI);
                }
                errorline(G_s1,(INT)G_n0);
                if (*G_debug) {
                    sendmsg("OUTPUT1",MESSAGE_TE);
                    sendmsg("INPUT1",MESSAGE_TE);
                }
                break;
            case LOGQNTY   : PUSHN(G_log[(INT)popl()].qty);
                             break;
            case LOGVALUE  : PUSHS(G_log[(INT)popl()].val);
                             break;
            case LOGNAME   : PUSHS(G_log[(INT)popl()].desc);
                             break;
            case SETDATAST : PUSHS("D");
                             break;
            case DATASTORE :
                m=popl();
                l=popl();
                k=(INT)sendmsg("DBM",MESSAGE_qg,(UCHAR)l,(UCHAR)m,G_s0);
//				mprintf("Get %s.%s",G_store[(INT)l].name,G_lib[G_store[(INT)l].li[(INT)m]].name,G_s0,k);
                PUSHS(G_s0);
                break;
            case ADDTOLOG  :
                for (n=0;n<5;n++) {
                  getstr();
                  G_a[(INT)n]=STRDUP(G_s1);
                }
                add2log(G_a[4],G_a[3],G_a[2],G_a[1],G_a[0]);
                for (n=0;n<5;n++) FREE(G_a[(INT)n]);
                break;
            case DSNAME    : break;
            case USING     : break;
            case UPDATE    : break;
            case DUPDSFMT  :
                m=popl();
                l=popl();
                getstr();
                for (n=0;n<G_nums;n++) {
                    if (!strcmp(G_s1,G_store[(INT)n].name)) {
                        break;
                    }
                }
                if (n==G_nums) {
                    memcpy(&G_store[G_nums],&G_store[(INT)l],sizeof(STORE));
                    memcpy(&G_sstat[G_nums],&G_sstat[(INT)l],sizeof(STORESTAT));
                    G_sstat[G_nums].open=0;
                    G_sstat[G_nums].modified=0;
                    G_sstat[G_nums].handle=0;
                    G_sstat[G_nums].rec=0;
#ifdef CTOS
                    G_msmap[G_nums]=m;
#endif
                    if ((G_sstat[G_nums].buf=MALLOC(G_sstat[G_nums].len+1))!=NULL) {
                        memcpy(G_sstat[G_nums].buf,G_sstat[(INT)l].buf,G_sstat[G_nums].len);
                        strcpy(G_store[G_nums].name,G_s1);
                        strcpy(G_sstat[G_nums].name,G_s1);
                        G_nums++;
//                        if (sendmsg("DBM",MESSAGE_x,G_store[G_nums-1].name)) {
//                            sendmsg("DBM",MESSAGE_D,G_store[G_nums-1].name);
//                        }
                    }
                    else {
                        xit=2;
                    }
                }
                break;
            case REMDSFMT  :
                getstr();
                delst(G_s1);
                break;
            case COPYREC   :
                l=popl();
                getstr();
                PUSHN(sendmsg("DBM",MESSAGE_cr,G_store[(INT)l].name,G_s1));
                break;
            case RUNFORM   :
                if (rform) {
                    l=popl();
                    getstr();
                    strcpy(G_s0,G_s1);
                    rform=0;
                    if (*G_debug) {
                        sendmsg("OUTPUT1",MESSAGE_RI);
                        sendmsg("OUTPUT1",MESSAGE_R);
                        sendmsg("INPUT1",MESSAGE_RI);
                    }
                    if (!loadnewform(NULL,(INT)popl(),G_store[(INT)l].name,G_s0,0)) xit=2;
                    if (*G_debug) {
                        sendmsg("OUTPUT1",MESSAGE_TE);
                        sendmsg("INPUT1",MESSAGE_TE);
                    }
                }
                else {
                    rform=1;
                }
                break;
            case STSRCH    :
                l=popl();
                m=popl();
                n=popl();
//                mprintf("%s %s %d",G_store[n].name,G_lib[G_store[(INT)n].li[(INT)m]].name,(INT)l);
                l=(LONG)sendmsg("DBM",MESSAGE_s,G_store[(INT)n].name,G_lib[G_store[(INT)n].li[(INT)m]].name,(INT)l);
                if (l) {
                    sendmsg("DBM",MESSAGE_r,G_store[(INT)n].name,(LONG)CURR);
                }
                PUSHN(l);
                break;
            case STSRCHP   :
                l=popl();
                m=popl();
                n=popl();
//                mprintf("%s %s %d",G_store[(INT)n].name,G_lib[G_store[(INT)n].li[(INT)m]].name,(INT)l);
                l=(INT)sendmsg("DBM",MESSAGE_sp,G_store[(INT)n].name,(INT)m,(INT)l);
                if (l) {
                    sendmsg("DBM",MESSAGE_r,G_store[(INT)n].name,(LONG)CURR);
                }
                PUSHN(l);
                break;
            case STREAD    :
                l=popl();
#ifdef WIEN
                PUSHN(sendmsg("DBM",MESSAGE_r,G_store[(INT)popl()].name,l));
#else //WIEN
                sendmsg("DBM",MESSAGE_r,G_store[(INT)popl()].name,l);
#endif//WIEN
                break;
            case STWRITE   : 
#ifdef WIEN
               #ifdef DOS
//                if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
               #endif//DOS
                PUSHN(sendmsg("DBM",MESSAGE_w,G_store[(INT)popl()].name));
#else //WIEN
                sendmsg("DBM",MESSAGE_w,G_store[(INT)popl()].name);
#endif//WIEN
                break;
#ifdef WIEN
            case STUPDATE   : 
                m=popl(); //Recnum
                n=popl(); //Storenumber
                PUSHN(sendmsg("DBM",MESSAGE_u,G_store[(INT)n].name,m));
                break;
            case STLOCK   : 
                PUSHN(sendmsg("DBM",MESSAGE_L,G_store[(INT)popl()].name));
                break;
            case ABS   :
               PUSHN(labs(popl()));
               break;
            case LBLDRUCK  :
               l=popl();//Betrag
               getstr();//Bearbeiter
#ifdef CTOS
               PUSHN(sendmsg("OUTPUT2",MESSAGE_LP,G_s1,l));
#else //CTOS
               PUSHN(G_vars[49]);
#endif//CTOS
               break;
            case LBLINIT  :
#ifdef CTOS
               sendmsg("OUTPUT2",MESSAGE_FLPI);
#else //CTOS
#endif//CTOS
               break;
            case LBLMULTI  :
               k=(int)popl();//Anzahl
               l=popl();//Betrag
               getstr();//Bearbeiter
#ifdef CTOS
               PUSHN(sendmsg("OUTPUT2",MESSAGE_LP,G_s1,l));
#else //CTOS
               PUSHN(G_vars[49]);
#endif//CTOS
               break;
            case PUTINTO  : //Schreibt einen String in einen Bereich eines
               k=(INT)popl();//Ende des Bereiches
               j=(INT)popl();//Start des Bereiches
    				for (n=0;n<3;n++) { getstr(); G_a[(INT)n]=STRDUP(G_s1); }
               putinto(G_a[2],G_a[1],G_a[0],j,k);
               for (n=0;n<3;n++) FREE(G_a[(INT)n]);
               break;
            case TRBORFSH   : 
                sendmsg("DBM",MESSAGE_rrf,(INT)popl());
                break;
            case STQSORT    : 
                sendmsg("DBM",MESSAGE_rqs,(INT)popl());
                break;
            case STRSTR    : 
                get2strs();
                PUSHS(strstr(G_s1,G_s2));
                break;
#endif//WIEN
            case CREC      :
                PUSHN(CURR);
                break;
            case NREC      :
                PUSHN(NEXT);
                break;
            case PREC      :
                PUSHN(PREV);
                break;
            case FREC      :
                PUSHN(FRST);
                break;
            case LREC      :
                PUSHN(LAST);
                break;
            case CLREC     :
                PUSHN(CLSE);
                break;
            case BLANKREC  :
                sendmsg("DBM",MESSAGE_b,G_store[(INT)popl()].name);
                break;
            case DRAWTABL  :
                G_formloaded++;
                break;
            case BLDTLIST  :
                memset(G_tvars,0,sizeof(G_tvars));
                total=1;
                // NO break;
            case BLDSLIST  : 
                getstr(); // GSREC OR GSFNAME
                strcpy(G_reclistfld,G_s1);
                G_reclisttype=(INT)popl(); // GSCOND
                n=popl(); // STORE
                strcpy(G_reclistname,G_store[(INT)n].name);
                if (G_reclist!=NULL) { FREE(G_reclist); G_reclist=NULL; }
                if (G_reclisttype==3) {
                    G_reclisttype=G_scond;
                    G_reclistlen=G_numrec;
                    G_reclist=G_ridxbuf;
                    G_reclistcur=0;
                }
                if (G_reclist==NULL) {
                    l=sendmsg("DBM",MESSAGE_nr,G_reclistname);
                    G_reclist=MALLOC((INT)l*sizeof(LONG));
                    G_reclistlen=0;
                    G_reclistcur=0;
                    if (G_reclist!=NULL) {
                        switch (G_reclisttype) {
                            case 1  :
                                if (total)
                                    G_reclistlen=(INT)sendmsg("DBM",MESSAGE_tp,G_reclistname,(INT)ATON(G_reclistfld),G_tvars,G_reclist);
                                else
          				            G_reclistlen=(INT)sendmsg("DBM",MESSAGE_bp,G_reclistname,(INT)ATON(G_reclistfld),G_reclist);
                                break;
                            case 2  :
                                if (total)
                                    G_reclistlen=(INT)sendmsg("DBM",MESSAGE_ts,G_reclistname,G_reclistfld,G_tvars,G_reclist);
       				            else
          				            G_reclistlen=(INT)sendmsg("DBM",MESSAGE_bs,G_reclistname,G_reclistfld,G_reclist);
                                break;
                        }
                        if (G_reclistlen) {
                            G_reclist=REALLOC(G_reclist,G_reclistlen*sizeof(LONG));
                            if (G_reclist==NULL) G_reclistlen=0;
                        } else {
                            FREE(G_reclist);
                            G_reclist=NULL;
                        }
                    }
                }
                total=0;
                break;
            case USESLIST  :
                m=popl();
                if ((G_reclist!=NULL)&&(G_reclistlen!=0)) {
                    switch (m) {
                        case FRST :
                            G_reclistcur=0;
                            break;
                        case NEXT :
                            G_reclistcur++;
                            break;
                        default :
                            G_reclistcur=(INT)m-1;
                    }
                    if ((G_reclistcur>=0)&&(G_reclistcur<G_reclistlen)) {
                        PUSHN(sendmsg("DBM",MESSAGE_r,G_reclistname,G_reclist[G_reclistcur]));
                    } else {
                        PUSHN(0);
                    }
                } else {
                    PUSHN(0);
                }
                break;
            case RUNSRCH   :
                getstr(); // ACTION
                strcpy(G_s0,G_s1);
                getstr(); // GSREC OR GSFNAME
                m=popl(); // GSCOND
                G_depth++;
                varspace=MALLOC(10*sizeof(VARTYPE));
                if (varspace!=NULL) {
                	memcpy(varspace,G_vars,10*sizeof(VARTYPE));
                	memset(G_vars,0,10*sizeof(VARTYPE));
                      t=MALLOC(11);
                if (t!=NULL) strcpy((CHAR *)t,G_sfname);
                      j=G_scond;
                      k=G_srec;
                      G_scond=(INT)m;
                      switch (m) {
                          case 1  :
                              numb=ATON(G_s1);
                              G_srec=(INT)numb;
                              break;
                          case 2  :
                              strcpy(G_sfname,G_s1);
                              break;
                      }
                      runaction(G_s0);
                      G_scond=j;
                      G_srec =k;
                if (t!=NULL) { strcpy(G_sfname,(CHAR *)t); FREE(t); }
                	memcpy(G_vars,varspace,10*sizeof(VARTYPE));
                	FREE(varspace);
                } else {
                	sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
                	sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_ns);
                }
                G_depth--;
                break;
            case VARARGS   :
                G_argcnt=(INT)popl();
                break;
			case HOTKEY	: 
                if (G_argcnt!=0) {
                    if (G_argcnt==3) {
    				    getstr();
                        strcpy(G_s0,G_s1);
                    } else {
                        strcpy(G_s0," ");
                    }
    				get2strs();
    				if ((k=keystroke(G_s1))!=0) sendmsg("INPUT1",MESSAGE_K,k,G_s2,G_s0);
                }
                G_argcnt=0;
				break;
            case WAITFLAG  :
                l=popl(); 
                if (l) {
                    if (!G_waiting) {
                        sendmsg("OUTPUT1",MESSAGE_AN,71,22,3,(INT)l,"CLOCK.BMP");
                        G_waiting=1;
                    }
                } else {
                    if (G_waiting) {
                        sendmsg("OUTPUT1",MESSAGE_DA,"CLOCK.BMP");
                        G_waiting=0;
                    }
                }
                break;
            case WAITTEST  : 
                if (G_waiting) sendmsg("INPUT1",MESSAGE_RK);
                break;
            case SETDSKEY  :
                if (G_argcnt!=0) {
                    stknum(G_argcnt-1,&numb);
                    j=(INT)numb;
                    for (k=G_argcnt-2;k>=0;k--) {
                        getstr();
                        if (k<G_store[j].numitem) {
                            sendmsg("DBM",MESSAGE_qp,(UCHAR)j,(UCHAR)k,G_s1);
                        }
                    }
                    popl();
                }
                G_argcnt=0;
                break;
            case RUNCOPY   :
                l=popl(); 
                getstr(); 
                strcpy(G_s0,G_s1);
                getstr(); 
				G_depth++;
				varspace=MALLOC(10*sizeof(VARTYPE));
				if (varspace!=NULL) {
					memcpy(varspace,G_vars,10*sizeof(VARTYPE));
					memset(G_vars,0,10*sizeof(VARTYPE));
                    k=(INT)l;
                    (CHAR *)t=STRDUP(G_s0);
                    sendmsg("DISK",MESSAGE_s,G_database,t,G_store[k].name);
                    runaction(G_s1);
                    sendmsg("DISK",MESSAGE_s,G_database,t,G_store[k].name);
					memcpy(G_vars,varspace,10*sizeof(VARTYPE));
					FREE(varspace);
				} else {
            		sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
        			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
         			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
        			sendmsg("OSSDEV",MESSAGE_ns);
				}
                break;
            case DISPHOT   :
                k=(INT)sendmsg("INPUT1",MESSAGE_NH);
                if (k>0) {
                    for (j=0;((j<k)&&(j<30));j++) {
                        strcpy(G_s0,keyname((INT)sendmsg("INPUT1",MESSAGE_HN,j)));
                        sendmsg("INPUT1",MESSAGE_HD,j,G_s1);
                        sendmsg("OUTPUT1",MESSAGE_S,1);
                        sendmsg("OUTPUT1",MESSAGE_A,0);
                        sendmsg("OUTPUT1",MESSAGE_o,(j/15)*40,(j%15)+7," [%-5.5s] %-30.30s ",G_s0,G_s1);
                    }
                } else {
                    sendmsg("OUTPUT1",MESSAGE_o,0,7," [-----] No Hot Heys Found ");
                }
                sendmsg("INPUT1",MESSAGE_i);
                break;
            default : 
                sendmsg("OSSDEV",MESSAGE_s,1000);
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,5000);
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,2000);
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,6000);
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_s,3000);
                sendmsg("OSSDEV",MESSAGE_d,100);
                sendmsg("OSSDEV",MESSAGE_ns);
        }
        o++;
        if (G_run<2) {
            sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)9);
            sendmsg("OSSDEV",MESSAGE_xy,1,12);
            sendmsg("OSSDEV",MESSAGE_p,"DEPTH [%d]   %s [%s]     ",G_depth,(actiontype(G_ca)==ANAME?"ACTION":" TABLE"),actionname(G_ca));
            ptok(o);
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
						sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x07);
                        sendmsg("OSSDEV",MESSAGE_cs);
                    	sendmsg("DBM",MESSAGE_ca);
                    	printf("GPA Abort.\n");
                    	exit(-1);
                	}
                	if (k=='r') G_run=1;
                	if (k=='s') G_run=2;
                	if (k=='c') {
//I                         mov ax,3
//I                         INT 0x10
                    }
            	}
        	}
		}
		if ((bm[0]==(-1))&&(xit==2)) xit=0;
    }
    if (xit==2) RETURNV(0);
    RETURNV(1);
}
// run the tokens associated with name
INT runtokens(CHAR *name)
{
    INT ret;
	VARTYPE *varspace;
	ENTRY(1880);

    if ((G_ca=findname(name))==(-1)) RETURNV(0);
    if (*G_debug) {
        G_run=0;
        sendmsg("OUTPUT1",MESSAGE_TE);
        sendmsg("INPUT1",MESSAGE_TE);
        sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x07);
        sendmsg("OSSDEV",MESSAGE_cs);
        mprintf("þ");
		G_depth++;
		varspace=MALLOC(10*sizeof(VARTYPE));
		if (varspace!=NULL) {
			memcpy(varspace,G_vars,10*sizeof(VARTYPE));
			memset(G_vars,0,10*sizeof(VARTYPE));
	        ret=inttok(actionbuf(G_ca));
			memcpy(G_vars,varspace,10*sizeof(VARTYPE));
			FREE(varspace);
		} else {
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_ns);
		}
		G_depth--;
        pstack();
        sendmsg("OSSDEV",MESSAGE_ta,(UCHAR)0x1F);
        sendmsg("OSSDEV",MESSAGE_xy,1,12);
        sendmsg("OSSDEV",MESSAGE_p,"                        COMPLETE  -  PRESS SPACE                                ");
        sendmsg("OSSDEV",MESSAGE_xy,79,25);
        while (getch()!=32);
        sendmsg("OUTPUT1",MESSAGE_RI);
        sendmsg("OUTPUT1",MESSAGE_R);
        sendmsg("INPUT1",MESSAGE_RI);
    } else {
//		beep();
        G_run=2;
		G_depth++;
		varspace=MALLOC(10*sizeof(VARTYPE));
		if (varspace!=NULL) {
			memcpy(varspace,G_vars,10*sizeof(VARTYPE));
			memset(G_vars,0,10*sizeof(VARTYPE));
	        ret=inttok(actionbuf(G_ca));
			memcpy(G_vars,varspace,10*sizeof(VARTYPE));
			FREE(varspace);
		} else {
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_s,5000); sendmsg("OSSDEV",MESSAGE_d,200); sendmsg("OSSDEV",MESSAGE_s,1000); sendmsg("OSSDEV",MESSAGE_d,100);
			sendmsg("OSSDEV",MESSAGE_ns);
		}
		G_depth--;
    }
    RETURNV(ret);
}
// dump the state of the previosly loaded forms ( Critical memory error )
void dumpstate(INT from)
{
    INT i;
	ENTRY(1910);
    sendmsg("OUTPUT1",MESSAGE_TE);
    sendmsg("INPUT1",MESSAGE_TE);
    printf("Critical Error - Exit point %d\n",from);
    for (i=0;i<G_numsf;i++) printf("%-10s",G_savedf[i].name);
    printf("\n");
    exit(0);
}
// save the state of the previosly loaded form
INT savestate(void)
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
INT reststate(void)
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
    G_form.curitem=(INT16)G_savedf[G_numsf].item;
    G_formvars=G_savedf[G_numsf].vars;
    G_tflds=G_savedf[G_numsf].tflds;

	if ((G_exit2mrk==1)&&(G_savedf[G_numsf].mark==1)) G_exit2mrk=0;
    RETURNV(1);
}
void setdsacc(CHAR *n1,CHAR *n2)
{
    INT i;
    CHAR *t,tmp[18];
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
INT loadnewform(CHAR *name,INT index,CHAR *n1,CHAR *n2,INT w)
{
	FSAVE savedf;
	INT i;
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
					G_form.curitem=(INT16)savedf.item;
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
					G_form.curitem=(INT16)savedf.item;
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
INT runaction(CHAR *name)
{
    CHAR newname[9],*e;
	LONG fl;
	INT t;
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
INT isaction(CHAR *name)
{
    INT i=0;
    CHAR *e;
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
INT subaction(CHAR *name,INT depth)
{
    INT i;
	ENTRY(1980);

    if (depth==MAXRECURSE) {
        beep();
        sendmsg("OUTPUT1",MESSAGE_o,0,23,"Tried to run action \"%s\" - recurse too deep!",name);
        sendmsg("OUTPUT1",MESSAGE_o,0,24,"Press Any Key");
        sendmsg("INPUT1",MESSAGE_i);
        RETURNV(0);
    }
    if (!strcmp(name,"NONE    ")) RETURNV(0);

    if (((i=isaction(name))==0)&&(isform(name)==(-1L))) RETURNV(0);

    G_actionrun++;
    if (i==0) {
        if (!loadnewform(name,-1,NULL,NULL,0)) {
            beep();
            sendmsg("OUTPUT1",MESSAGE_o,0,23,"Tried to run form \"%s\" - Non-existent!",name);
            sendmsg("OUTPUT1",MESSAGE_o,0,24,"Press Any Key");
            sendmsg("INPUT1",MESSAGE_i);
        }
    }
    else {
        if (i>0) {
            if (i>999) {
//                if (G_ufunc[i-1000].access<=G_access) {
                    if ((G_ufunc[i-1000].func)()==0) RETURNV(0);
//                }
//                else {
//                    errorline(G_noacc,1);
//                    RETURNV(0);
//                }
            }
            else {
//                if (G_actmap[i-1].access<=G_access) {
                    if ((G_actmap[i-1].func)()==0) RETURNV(0);
//                }
//                else {
//                    errorline(G_noacc,1);
//                    RETURNV(0);
//                }
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
				sendmsg("OUTPUT2",MESSAGE_SP,0,0);
				G_prinprog=0;
				G_pagenum=0;
			}
        }
    }
    RETURNV(1);
}

