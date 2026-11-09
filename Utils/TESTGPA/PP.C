#define GPA_C
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <math.h>
#include <direct.h>
#include <ctype.h>
#include <errno.h>
#include <io.h>
#include <fcntl.h>
#include <malloc.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpa.h"

extern unsigned _stklen=8192;

CHAR G_emptystr[80];
char **G_ufunclst;
char **G_actmaplst;
#if (M_DEBUG==1)
extern void setbase(void);
#endif

#define MAXSPACE 512000L
#define MAXNAME  0x3000L
#define MAXSTAT  0x3000L

typedef struct {
    CHAR  d;
    CHAR  t;
    CHAR *n;
    ULONG  o;
} NAMEIDX;

CHAR        **G_statbuf;
CHAR        *G_statval[MAXSTAT];
INT         G_numstat=0;
NAMEIDX     *G_actnbuf;
INT         G_numan=0;
INT G_inwhere=(-2);
INT G_instsrch=0;
INT G_lastst=0;
FILE *G_fp;
ULONG G_headlimit=0L;
ULONG G_sp=0L;
CHAR G_file[100];

INT G_open=0;
INT G_lnum=0;
INT G_nume=0;
INT G_curitem=3;
CHAR *G_str;
CHAR G_linein[256];
CHAR G_tlinein[256];
CHAR *G_tokbuffer;

INT      match           (CHAR *t);
void     error           (CHAR *err);
void     oper            (void);
void     expr            (void);
void     term            (void);
void     fact            (void);
void     part            (void);
void     cons            (void);
INT      varib           (void);
INT      func            (void);
INT      value           (void);
INT      cond            (void);

void cdprintf(CHAR *fmt,...)
{
	va_list ap;
	chdir(G_curdir);
    va_start(ap,fmt);
    vfprintf(stdout,fmt,ap);
    va_end(ap);
	chdir(G_cfgdir);
}
#define COMPLEN  0x2000
#define LCOMPLEN (COMPLEN*sizeof(LONG))
void checkseg(void)
{
    INT i;
    static LONG *buf=NULL;
    static CHAR *map=NULL;
    LONG *mem=(LONG *)0x00008000L;
    INT newa,la,upto;
    if (buf==NULL) {
        if ((buf=malloc(LCOMPLEN))==NULL) {printf("Memory Error 1.\n"); return; }
        memcpy(buf,mem,LCOMPLEN);
        if ((map=malloc(COMPLEN))==NULL) {printf("Memory Error 2.\n"); return; }
        memset(map,0,COMPLEN);
    } else {
        if (memcmp(buf,mem,LCOMPLEN)) {
            la=-2;
            newa=upto=0;
            for (i=0;i<COMPLEN;i++) {
                if ((*(mem+i)!=*(buf+i))&&(*(map+i)==0)) {
                    if (!newa) {
                        newa=1;
                    }
                    if (la==i-1) {
                        upto=i;
                    } else {
                        printf("%04lX ",(LONG)(mem+i));
                    }
                    la=i;
                    *(map+i)=1;
                }
                if ((upto)&&(upto!=i)) { printf("-%04lX ",(LONG)(mem+upto)); upto=0; }
            }
            if (newa) printf("%s\n",G_linein); 
            memcpy(buf,mem,LCOMPLEN);
        }
    }
}
INT  getline(void)
{
//    checkseg();
    G_str=fgets(G_linein,255,G_fp);
    if (G_str==NULL) {
        memset(G_linein,0,255);
        G_str=G_linein;
        return(0);
    }
    if (!*G_str) return(1);

    *(G_str+strlen(G_str)-1)=0;
    G_lnum++;
    return(1);
}
void  includefile(CHAR *name)
{
    CHAR of[100];
    FILE *ofp;
    CHAR *s;
    INT oln;

    ofp=G_fp;
    oln=G_lnum;
    strcpy(of,G_file);

    G_fp=0;
  	G_lnum=0;
    s=&(name[strlen(name)-1]);
    while ((isspace(*s)||(*s=='\n')||(*s=='\r'))&&(s!=name)) *(s--)=0;
    
    strcpy(G_file,name);

    if ((G_fp=fopen(G_file,"r"))!=NULL) {
    	while (getline()) while ((G_str)&&(*G_str)) oper();
        fclose(G_fp);
    } else {
	    cdprintf("Error %s %d: Can't include file (%s)\n",of,oln,name);
        G_nume++;
    }

    strcpy(G_file,of);
    G_lnum=oln;
    G_fp=ofp;

    getline();
}
CHAR * remspace(CHAR *s)
{
    if (!*s) return(s);
    while (*s&&((*s==' ')||(*s==9))) s++;
    return(s);
}
CHAR *  gettok(void)
{
    INT i=0;
    CHAR *p;
    static CHAR s[100];
    G_str=remspace(G_str);
    p=G_str;
    while ((*p)&&isalnum(*p)&&i<100) s[i++]=*(p++);
    s[i]=0;
    return(s);
}
CHAR *  getconststr(void)
{
    INT i=0;
    CHAR *p;
    static CHAR s[100];

    p=G_str;
    while ((*p)&&(*p!='"')&&(i<100)) s[i++]=*(p++);
    s[i]=0;
    G_str+=i;
    return(s);
}
void  skiptok(void)
{
    G_str=remspace(G_str);
    while ((*G_str)&&isalnum(*G_str)) G_str++;
}

INT  findfield(void)
{
    INT i=0;
    INT j;
    CHAR *p,sn[10],fn[10];

    p=G_str;
    while ((*p)&&isalnum(*p)&&i<9) sn[i++]=*(p++);
    sn[i]=0;
    if (sn[0]==0) return(-1);
    i=0;
    p++;
    while ((*p)&&isalnum(*p)&&i<9) fn[i++]=*(p++);
    fn[i]=0;
    if (fn[0]==0) return(-1);
    if ((i=snum(sn))==(-1)) return(i);
    if ((j=fnum(sn,fn))==(-1)) return(j);
    G_str=p;
    return(i*100+j);
}
INT  match(CHAR *t)  
{                   
    INT len=strlen(t);
#ifndef __TURBOC__
    CHAR *p;
#endif

    if (isspace(*G_str)) G_str=remspace(G_str);
    while (!(*G_str)) {
        if (!getline()) return(0);
        if (isspace(*G_str)) G_str=remspace(G_str);
    }
#ifdef __TURBOC__
    if (strncmpi(t,G_str,len)) return(0);
    if (isalpha(*(t+len-1))&&isalpha(*(G_str+len))) return(0);
    G_str+=len;
#else
    p=G_str;
    while ((*t)&&(*t==toupper(*(p++)))) t++;
    if (*t==0) {
        if (isalpha(*(t-1))&&isalpha(*(G_str+len))) return(0);
        G_str+=len;
        return(1);
    }
#endif
    return(1);
}
void  error(CHAR *err)
{
    static INT ll=0;
    CHAR *p;
	p=G_str;
    if (ll!=G_lnum) {
        if (G_str!=NULL) {
            G_nume++;
		    if ((G_file[0]=='\\')||(G_file[1]==':')) {
	            cdprintf("Error %s %d: %s (",G_file,G_lnum,err);
		    } else {
	            cdprintf("Error %s\\%s %d: %s (",G_cfgdir,G_file,G_lnum,err);
		    }
            if (isalnum(*p)) {
                while (isalnum(*p)&&(*p)) {
                    cdprintf("%c",*p);
                    p++;
                }
            } else {
                while ((!isalnum(*p))&&(!isspace(*p))&&(*p)) {
                    cdprintf("%c",*p);
                    p++;
                }
            }
            cdprintf(")\n");
            ll=G_lnum;
            G_str=p;
            return;
        }
    }
    if (isalnum(*p)) {
        while (isalnum(*p)&&(*p)) {
            p++;
        }
    } else {
        while ((!isalnum(*p))&&(!isspace(*p))&&(*p)) {
            p++;
        }
    }
    ll=G_lnum;
    G_str=p;
}
INT  addname(CHAR *name,INT t)
{
    INT i;
    if (strlen(name)>8) error("Action name > 8 Characters");
    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(0);
    }
    G_actnbuf[G_numan  ].n=strdup(name);
    G_actnbuf[G_numan  ].t=(CHAR)t;
    G_actnbuf[G_numan++].o=G_sp;
    return(1);
}
INT  findaname(CHAR *name)
{
    INT i;

    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(i);
    }
    return(-1);
}
UCHAR  tokenval(ULONG o)
{
    return(*(G_tokbuffer+o));
}
void  settoken(ULONG o,UCHAR v)
{
    *(G_tokbuffer+o)=v;
}
void  settokeni(ULONG o,UINT16 v)
{
    UINT16 *r=(UINT16 *)(G_tokbuffer+o);
    *r=v;
}
void  settokenl(ULONG o,ULONG v)
{
    ULONG *r=(ULONG *)(G_tokbuffer+o);
    *r=v;
}
void  settokend(ULONG o,double v)
{
    double *r=(double *)(G_tokbuffer+o);
    *r=v;
}
void  settokens(ULONG o,UCHAR *v)
{
    strcpy(G_tokbuffer+o,(CHAR *)v);
}
void  settokenf(ULONG o,UCHAR *v,INT l)
{
    memcpy(G_tokbuffer+o,v,l);
}

void  placetok(CHAR t,double v)
{
    CHAR *s;
    switch (t) {
        case TCONSTANT :
            settoken(G_sp,t);
            settoken(G_sp+1,(UCHAR)v);
            G_sp++;
            break;
        case SCONSTANT :
            settoken(G_sp,t);
            settokeni(G_sp+1,(UINT16)v);
            G_sp+=sizeof(INT16);
            break;
        case LCONSTANT :
            settoken(G_sp,t);
            settokenl(G_sp+1,(ULONG)v);
            G_sp+=sizeof(LONG);
            break;
        case DCONSTANT :
            settoken(G_sp,t);
            settokend(G_sp+1,(double)v);
            G_sp+=sizeof(double);
            break;
        case CCONSTANT :
            settoken(G_sp,t);
            s=(CHAR *)(ULONG)v;
            settokens(G_sp+1,(UCHAR *)s);
            G_sp+=strlen(s)+1L;
            break;
        case STATNAME :
            settoken(G_sp,t);
            s=(CHAR *)(ULONG)v;
            settokenf(G_sp+1,(UCHAR *)s,80);
            G_sp+=80L;
            break;
		default :
            settoken(G_sp,t);
    }
    G_sp++;
}
void  placevp(INT np,INT tok)
{
    INT i;
    expr(); for (i=1;i<np;i++) { match(","); expr(); } placetok((CHAR)tok,0);
}
void  ptok(UCHAR *p)
{
    switch (*p) {
        case TCONSTANT : cdprintf("%d " ,*((UCHAR *)(p+1))); break;
        case SCONSTANT : cdprintf("%d " ,*((UINT *) (p+1))); break;
        case LCONSTANT : cdprintf("%ld ",*((ULONG *)(p+1))); break;
        case DCONSTANT : cdprintf("%f " ,*((double *)       (p+1))); break;
        case CCONSTANT : cdprintf("%s " ,  (UCHAR *)(p+1));  break;
        case TABLE     : cdprintf("TABLE ");                         break;
        case ANAME     : cdprintf("ACTION ");                        break;
        case STATNAME  : cdprintf("STATNAME ");                      break;
        case EQUAL     : cdprintf("= ");                             break;
        case DSEQUAL   : cdprintf("DS= ");                           break;
        case LOGIC_AND : cdprintf("&& ");                            break;
        case LOGIC_OR  : cdprintf("|| ");                            break;
        case LOGIC_NOT : cdprintf("! ");                             break;
        case LESSEQUAL : cdprintf("<= ");                            break;
        case LESS      : cdprintf("< ");                             break;
        case GREATEQUAL: cdprintf(">= ");                            break;
        case GREAT     : cdprintf("> ");                             break;
        case EQUALITY  : cdprintf("== ");                            break;
        case NOTEQUAL  : cdprintf("!= ");                            break;
        case PLUS      : cdprintf("+ ");                             break;
        case MINUS     : cdprintf("- ");                             break;
        case MULTIPLY  : cdprintf("* ");                             break;
        case MODULUS   : cdprintf("% ");                             break;
        case DEVIDE    : cdprintf("/ ");                             break;
        case NEGATE    : cdprintf("N ");                             break;
        case OCURLY    : cdprintf("{ ");                             break;
        case CCURLY    : cdprintf("} ");                             break;
        case FORMVAR   : cdprintf("F ");                             break;
        case GLOBVAR   : cdprintf("G ");                             break;
        case VARIABLE  : cdprintf("V ");                             break;
        case TVARIABLE : cdprintf("TV ");                            break;
        case ABS       : cdprintf("ABS ");                           break;
        case ACOS      : cdprintf("ACOS ");                          break;
        case ASIN      : cdprintf("ASIN ");                          break;
        case ATAN      : cdprintf("ATAN ");                          break;
        case COSH      : cdprintf("COSH ");                          break;
        case COS       : cdprintf("COS ");                           break;
        case EXP       : cdprintf("EXP ");                           break;
        case LOG10     : cdprintf("LOG10 ");                         break;
        case LOGAR     : cdprintf("LOG ");                           break;
        case ROUND     : cdprintf("ROUND ");                         break;
        case POW10     : cdprintf("POW10 ");                         break;
        case SINH      : cdprintf("SINH ");                          break;
        case SIN       : cdprintf("SIN ");                           break;
        case SQRT      : cdprintf("SQRT ");                          break;
        case SQR       : cdprintf("SQR ");                           break;
        case TANH      : cdprintf("TANH ");                          break;
        case TAN       : cdprintf("TAN ");                           break;
        case TRUNC     : cdprintf("TRUNC ");                         break;
        case GOTOXY    : cdprintf("XY ");                            break;
        case MARKER    : cdprintf("*** ");                           break;
        case WHILE     : cdprintf("WH ");                            break;
        case IF        : cdprintf("IF ");                            break;
        case ELSE      : cdprintf("EL ");                            break;
        case SETFMVAR  : cdprintf("@F ");                            break;
        case SETGLOBVR : cdprintf("@G ");                            break;
        case SETVARIAB : cdprintf("@V ");                            break;
        case SETTVARIB : cdprintf("@TV ");                           break;
        case SETCURITM : cdprintf("@CF ");                           break;
        case ACTIONN   : cdprintf("ACT ");                           break;
        case RANGE     : cdprintf("<-> ");                           break;
        case RESULT    : cdprintf("ð ");                             break;
        case LOOKUP    : cdprintf("LOOK ");                          break;
        case USERVAR   : cdprintf("UVAR ");                          break;
        case SETUSRVAR : cdprintf("@UVAR ");                         break;
        case STATICS   : cdprintf("STATIC ");                        break;
        case SAVESTAT  : cdprintf("SAVESTAT ");                      break;
        case RESTSTAT  : cdprintf("RESTSTAT ");                      break;
        case SETSTATIC : cdprintf("@STATIC ");                       break;
        case LOOKTAB   : cdprintf("INTAB ");                         break;
        case PASSEDVAL : cdprintf("PASSED ");                        break;
        case LOGQNTY   : cdprintf("LQ ");                            break;
        case LOGVALUE  : cdprintf("LV ");                            break;
        case LOGNAME   : cdprintf("LN ");                            break;
        case DATASTORE : cdprintf("DS ");                            break;
        case DSNAME    : cdprintf("FILE ");                          break;
        case SETDATAST : cdprintf("@DS ");                           break;
        case ADDTOLOG  : cdprintf("A2L ");                           break;
        case CURFIELD  : cdprintf("CF ");                            break;
        case FORMNAME  : cdprintf("FORM ");                          break;
        case UFUNC     : cdprintf("USERFUNC ");                      break;
        case CFUNC     : cdprintf("CFUNC ");                         break;
        case USING     : cdprintf("USING ");                         break;
        case UPDATE    : cdprintf("UPDATE ");                        break;
        case DATESWAP  : cdprintf("DATESWAP ");                      break;
        case ACCESSL   : cdprintf("ALEVEL ");                        break;
        case SJOIN     : cdprintf("STR+ ");                          break;
        case SCUT      : cdprintf("STRCUT ");                        break;
        case SEQU      : cdprintf("STR== ");                         break;
        case SNEQU     : cdprintf("STR!= ");                         break;
        case SLESS     : cdprintf("STR< ");                          break;
        case SLEQU     : cdprintf("STR<= ");                         break;
        case SGREAT    : cdprintf("STR> ");                          break;
        case SGEQU     : cdprintf("STR>= ");                         break;
        case SUPPER    : cdprintf("SUPPER ");                        break;
        case SLOWER    : cdprintf("SLOWER ");                        break;
		case HOTKEY	   : cdprintf("HOTKEY ");                        break;
		case PICKKEY   : cdprintf("PICKKEY ");                       break;
		case SAVESCR   : cdprintf("SAVESCR ");                       break;
		case XTIMER	   : cdprintf("XTIMER ");                        break;
		case SWAPTO    : cdprintf("SWAPTO");                         break;
		case SETDEV	   : cdprintf("SETDEV ");                        break;
		case SAVEDEV   : cdprintf("SAVEDEV ");                       break;
		case RESTDEV   : cdprintf("RESTDEV ");                       break;
        case DAYOFWK   : cdprintf("DAYOFWK ");                       break;
        case DATESTR   : cdprintf("DATE ");                          break;
        case FMTMATCH  : cdprintf("FMTMATCH ");                      break;
        case INRANGE   : cdprintf("INRANGE ");                       break;
        case NMONTHS   : cdprintf("NMONTHS ");                       break;
        case GETYEAR   : cdprintf("GETYEAR ");                       break;
        case NDAYS     : cdprintf("NDAYS ");                         break;
        case DUEDOM    : cdprintf("DUEDOM  ");                       break;
        case DUEHALF   : cdprintf("DUEHALF ");                       break;
        case GETPROD   : cdprintf("GETPROD ");                       break;
        case ERRLINE   : cdprintf("ERRLINE ");                       break;
        case WHERE     : cdprintf("WHERE ");                         break;
        case COPYREC   : cdprintf("COPYREC ");                       break;
        case DUPDSFMT  : cdprintf("DUPDSFMT ");                      break;
        case REMDSFMT  : cdprintf("REMDSFMT ");                      break;
        case RUNFORM   : cdprintf("RUNFORM ");                       break;
        case STSRCH    : cdprintf("STSRCH ");                        break;
        case STSRCHP   : cdprintf("STSRCHP ");                       break;
        case RECNUM    : cdprintf("RECNUM ");                        break;
        case STREAD    : cdprintf("STREAD  ");                       break;
        case STWRITE   : cdprintf("STWRITE ");                       break;
        case STDELREC  : cdprintf("STDELREC ");                      break;
        case PROMPT    : cdprintf("PROMPT ");                        break;
        case RUN       : cdprintf("RUN ");                           break;
        case STEMPTY   : cdprintf("STEMPTY ");                       break;
        case CREC      : cdprintf("CREC ");                          break;
        case NREC      : cdprintf("NREC ");                          break;
        case PREC      : cdprintf("PREC ");                          break;
        case FREC      : cdprintf("FREC ");                          break;
        case LREC      : cdprintf("LREC ");                          break;
        case CLREC     : cdprintf("CLREC ");                         break;
        case PRLINE    : cdprintf("PRLINE ");                        break;
        case PREOL     : cdprintf("PREOL ");                         break;
        case PREOF     : cdprintf("PREOF ");                         break;
        case PRAGAIN   : cdprintf("PRAGAIN ");                       break;
        case PRSEQNCE  : cdprintf("PRSEQNCE ");                      break;
        case USEPRDEF  : cdprintf("USEPRDEF ");                      break;
        case SENDLINE  : cdprintf("SENDLINE ");                      break;
        case SENDEOL   : cdprintf("SENDEOL ");                       break;
        case MOVEPLN   : cdprintf("MOVEPLN ");                       break;
        case JUMPTO    : cdprintf("JUMPTO ");                        break;
        case MOVETCUR  : cdprintf("MOVETCUR ");                      break;
        case SETDSKEY  : cdprintf("SETDSKEY ");                      break;
        case MODIFIED  : cdprintf("MODIFIED ");                      break;
        case RUNDUMMY  : cdprintf("RUNDUMMY ");                      break;
        case RUNCOPY   : cdprintf("RUNCOPY ");                       break;
        case RUNSRCH   : cdprintf("RUNSRCH ");                       break;
        case BLDSLIST  : cdprintf("BLDSLIST ");                      break;
        case BLDTLIST  : cdprintf("BLDTLIST ");                      break;
        case DRAWTABL  : cdprintf("DRAWTABL ");                      break;
        case USESLIST  : cdprintf("USESLIST ");                      break;
        case DISPHOT   : cdprintf("DISPHOT ");                       break;
        case BLANKREC  : cdprintf("BLANKREC ");                      break;
        case VARARGS   : cdprintf("VARARGS ");                       break;
        case WAITFLAG  : cdprintf("WAITFLAG ");                      break;
        case WAITTEST  : cdprintf("WAITTEST ");                      break;
        case DIVSPEC   : cdprintf("DIVSPEC ");                       break;
        case STCLOSE   : cdprintf("STCLOSE ");                       break;
        case FCDCODE   : cdprintf("FCDCODE ");                       break;
        case SWAPKBD   : cdprintf("SWAPKBD ");                       break;
        case CUSTDISP  : cdprintf("CUSTDISP ");                      break;
        case APPLYFMT  : cdprintf("APPLYFMT ");                      break;
        case STDELETE  : cdprintf("STDELETE ");                      break;
        default        : cdprintf("Error Unknown Instruction %d ",*p);
    }
}
/*
void  pstack(void)
{
    UCHAR *s,*p;
    p=G_tokspace;
    while (p<(&tokenval(G_sp))) {
        s=p;
        switch (*p) {
            case TCONSTANT : p++;                         break;
            case SCONSTANT : p+=sizeof(INT16);            break;
            case LCONSTANT : p+=sizeof(LONG);             break;
            case DCONSTANT : p+=sizeof(double);           break;
            case CCONSTANT : while (*(p+1)) p++; p++;     break;
        }
        p++;
        switch (*p) {
            case TABLE     : cdprintf("\n");                break;
            case ANAME     : cdprintf("\n");                break;
            case STATNAME  : cdprintf("\n");                break;
        }
        ptok(s);
    }
} */
LONG  statadd(CHAR *name)
{
	INT i;
	static CHAR tmp[81];
	memset(tmp,32,81);
	for (i=0;i<G_numstat;i++) {
		if (!strcmp(name,G_statbuf[i])) {
			strcpy(tmp,G_statval[i]);
//			tmp[strlen(tmp)]=32;
			break;
		}
	}
	tmp[79]=0;
	return((LONG)tmp);
}
void  oper(void)
{
    if (match("VARIABLE")) {
        if (G_open) error("VARIABLE not allowed in action");
        if (!addname(gettok(),VARIABLE)) error("duplicate name");
        placetok(CCONSTANT,(LONG)G_emptystr);
        skiptok();
    } else if (match("STATIC")) {
        if (G_open) error("STATIC not allowed in action");
        if (!addname(gettok(),STATNAME)) error("duplicate name");
        placetok(STATNAME,statadd(gettok()));
        skiptok();
    } else if (match("INCLUDE")) {
        gettok();
        includefile(G_str);
    } else {
    	expr();

    	for (;;) {
        	if (match("=")) {
            	if       (tokenval(G_sp-1)==FORMVAR  ) settoken(G_sp-1,SETFMVAR );
            	else  if (tokenval(G_sp-1)==VARIABLE ) settoken(G_sp-1,SETVARIAB);
            	else  if (tokenval(G_sp-1)==TVARIABLE) settoken(G_sp-1,SETTVARIB);
            	else  if (tokenval(G_sp-1)==CURFIELD ) settoken(G_sp-1,SETCURITM);
            	else  if (tokenval(G_sp-1)==USERVAR  ) settoken(G_sp-1,SETUSRVAR);
            	else  if (tokenval(G_sp-1)==STATICS  ) settoken(G_sp-1,SETSTATIC);
            	else  if (tokenval(G_sp-1)==GLOBVAR  ) settoken(G_sp-1,SETGLOBVR);
            	else  if (tokenval(G_sp-1)==DATASTORE) settoken(G_sp-1,SETDATAST);
                if ((tokenval(G_sp-1)==SETDATAST)&&(tokenval(G_sp-4)==DATASTORE)) {
                    settoken(G_sp-4,tokenval(G_sp-3));
                    settoken(G_sp-3,tokenval(G_sp-2));
                    settoken(G_sp-2,DSEQUAL);
                    G_sp--;
                } else {
                	placevp(1,EQUAL);
                }
        	} else break;
		}
    }
}
void  expr(void)
{
    term();
    if (strchr("&| \t",*G_str)==NULL) return;

    for (;;) {
        if      (match("&&")) { term(); placetok(LOGIC_AND,0); }
        else if (match("||")) { term(); placetok(LOGIC_OR ,0); }
        else break;
    }
}
void  term(void)
{
    fact();
    if (strchr("<>=!sS \t",*G_str)==NULL) return;

    for (;;) {
        if      (match("<="))  { fact(); placetok(LESSEQUAL ,0); }
        else if (match("<"))   { fact(); placetok(LESS      ,0); }
        else if (match(">="))  { fact(); placetok(GREATEQUAL,0); }
        else if (match(">"))   { fact(); placetok(GREAT     ,0); }
        else if (match("=="))  { fact(); placetok(EQUALITY  ,0); }
        else if (match("!="))  { fact(); placetok(NOTEQUAL  ,0); }
        else if (match("S<=")) { fact(); placetok(SLEQU     ,0); }
        else if (match("S<"))  { fact(); placetok(SLESS     ,0); }
        else if (match("S>=")) { fact(); placetok(SGEQU     ,0); }
        else if (match("S>"))  { fact(); placetok(SGREAT    ,0); }
        else if (match("S==")) { fact(); placetok(SEQU      ,0); }
        else if (match("S!=")) { fact(); placetok(SNEQU     ,0); }
        else break;
    }
}
void  fact(void)
{
    part();
    if (strchr("+-Ss \t",*G_str)==NULL) return;

    for (;;) {
        if      (match("+")) {  part(); placetok(PLUS,0); }
        else if (match("-")) {  part(); placetok(MINUS,0); }
        else if (match("S+")) { part(); placetok(SJOIN,0); }
        else break;
    }
}
void  part(void)
{
    cons();
    if (strchr("*%/Tt \t",*G_str)==NULL) return;

    for (;;) {
        if      (match("*"))  { part(); placetok(MULTIPLY,0); }
        else if (match("%"))  { part(); placetok(MODULUS ,0); }
        else if (match("/"))  { part(); placetok(DEVIDE  ,0); }
        else if (match("TO")) { part(); placetok(RANGE   ,0); }
        else break;
    }
}
INT  iscaction(CHAR *name)
{
    INT i=0;
    while (G_actmaplst[i]!=NULL) {
        if (!strcmp(name,G_actmaplst[i])) {
            return(i+1);
        }
        i++;
    }
    i=0;
    while (G_ufunclst[i]!=NULL) {
        if (!strcmp(name,G_ufunclst[i])) {
            return(i+1000);
        }
        i++;
    }
    return(0);
}
void  cons(void)
{
    double tf;
    ULONG tl;
    INT i,val;

    
    match("IN");

    if (match("NAME*")) {
        if (G_open) error("ACTION not allowed in action");
        if (!addname(gettok(),ANAME)) error("duplicate name");
        i=findaname(gettok());
        G_actnbuf[i].d=1;
        placetok(SCONSTANT,i);
        placetok(ANAME,0);
        skiptok();
    }
    if (match("NAME")) {
        if (G_open) error("ACTION not allowed in action");
        if (!addname(gettok(),ANAME)) error("duplicate name");
        i=findaname(gettok());
        G_actnbuf[i].d=0;
        placetok(SCONSTANT,i);
        placetok(ANAME,0);
        skiptok();
    }
    if (match("TABLE")) {
        if (G_open) error("TABLE not allowed in action");
        if (!addname(gettok(),TABLE)) error("duplicate name");
        i=findaname(gettok());
        placetok(SCONSTANT,i);
        placetok(TABLE,0);
        skiptok();
    }
    if (match("-")) {       placevp(1,NEGATE);            }
    else if (match("!"))  { placevp(1,LOGIC_NOT);         }
    else if (match("{"))  { G_open++; placetok(OCURLY,0); }
    else if (match("}"))  { G_open--; placetok(CCURLY,0); }
    else if (match("IS")) { placevp(1,RESULT);            }
    else if (match("(")) {
        expr();
        if (!match(")")) error("missing ')'");
    } else if ((!varib())&&(!func())&&(!value())&&(!cond())) {
        if (isdigit(*G_str)||(*G_str=='.')) {
            tf=atof(G_str);
            if (tf!=(double)((ULONG)tf)) {
                placetok(DCONSTANT,tf);
            }  else {
                tl=(ULONG)tf;
                if      (tl<=0x007FL) placetok(TCONSTANT,tf);
                else if (tl<=0x7FFFL) placetok(SCONSTANT,tf);
                else                  placetok(LCONSTANT,tf);
            }
            while (isdigit(*G_str)||(*G_str=='.')) G_str++;
        } else {
            if (*G_str) {
                if (*G_str==':') {
                    while (*G_str) G_str++;
                } else {
                    if ((val=findaname(gettok()))==(-1)) {
                        if ((val=findfield())==(-1)) {
                            if ((val=snum(gettok()))==(-1)) {
                                if ((val=iscaction(gettok()))==0) {
                                    if ((val=isform(gettok()))==(-1)) {
                                        if (!isglobal(gettok())) {
                                            error("unrecognised action");
                                        } else {
                                            placetok(SCONSTANT,findgname(gettok()));
                                            placetok(GLOBVAR,0);
                                            skiptok();
                                        }
                                    } else {
										G_actnbuf[G_numan-1].d|=0x80;
                                        skiptok();
                                        placetok(SCONSTANT,val);
                                        placetok(FORMNAME,0);
                                    }
                                } else {
                                    skiptok();
                                    if (val>999) {
                                        placetok(SCONSTANT,val-1000);
                                        placetok(UFUNC,0);
                                    } else {
                                        placetok(SCONSTANT,val-1);
                                        placetok(CFUNC,0);
                                    }
                                }
                            } else {
                                skiptok();
                                placetok(TCONSTANT,val);
                                placetok(DSNAME,0);
                            }
                        } else {
                            placetok(TCONSTANT,val/100);
                            placetok(TCONSTANT,val%100);
                            if (G_inwhere==(-1)) G_inwhere=(val/100);
                            if ((G_inwhere>(-2))&&(G_inwhere!=(val/100))) {
                                error("One Store Only");
                            }
                            if (!G_instsrch) placetok(DATASTORE,0);
                        }
                    }
                    else {
                        skiptok();
                        placetok(SCONSTANT,val);
                        switch (G_actnbuf[val].t) {
							case ANAME :
	                            placetok(ACTIONN,0);
								break;
							case TABLE :
	                            placetok(LOOKTAB,0);
								break;
							case VARIABLE :
	                            placetok(USERVAR,0);
								break;
							case STATNAME :
	                            placetok(STATICS,0);
								break;
						}
                    }
                }
            }
        }
    }
}
INT  varib(void)
{
    if (strchr("FVLTfvlt \t",*G_str)==NULL) return(0);
    if      (match("F["))      { expr(); placetok(FORMVAR ,0); }
    else if (match("V["))      { expr(); placetok(VARIABLE,0); }
    else if (match("T["))      { expr(); placetok(TVARIABLE,0); }
    else if (match("LOGQTY[")) { expr(); placetok(LOGQNTY ,0); }
    else if (match("LOGVAL[")) { expr(); placetok(LOGVALUE,0); }
    else if (match("LOGNAM[")) { expr(); placetok(LOGNAME ,0); }
    else return(0);

    if (!match("]")) error("missing ']'");
    return(1);
}
void  varargs(INT m,INT tok)
{
    CHAR *p;
    LONG pos,fp;
    INT r=1;

    p=G_str;
    pos=G_sp;
    strcpy(G_tlinein,G_linein);
    fgetpos(G_fp,&fp);
    expr();
    while (match(",")) {
        expr();
        r++;
    }

    G_str=p;
    G_sp=pos;
    strcpy(G_linein,G_tlinein);
    fseek(G_fp,fp,SEEK_SET);

    if (r<m) error("Too few arguments");

    placetok((CHAR)TCONSTANT,r);
    placetok((CHAR)VARARGS  ,0);
    placevp(r,tok);
}   
INT  func(void)
{
    if (!isalpha(*G_str)&&!isspace(*G_str)) return(0);

    if      (match( "SUPPER("   )) placevp(1,SUPPER);  
    else if (match( "SLOWER("   )) placevp(1,SLOWER);
    else if (match( "DAYOFWK("  )) placevp(1,DAYOFWK); 
    else if (match( "DATE("     )) placevp(1,DATESTR);
    else if (match( "DATESWAP(" )) placevp(1,DATESWAP);
    else if (match( "UPDATE("   )) placevp(1,UPDATE);  
    else if (match( "ACCESS("   )) placevp(1,ACCESSL); 
    else if (match( "FMTMATCH(" )) placevp(3,FMTMATCH);
    else if (match( "SCUT("     )) placevp(3,SCUT);
    else if (match( "SETDEV("   )) placevp(3,SETDEV);
    else if (match( "SAVEDEV("  )) placetok(SAVEDEV,0);
    else if (match( "RESTDEV("  )) placetok(RESTDEV,0);
    else if (match( "GOTOXY("   )) placevp(2,GOTOXY);
    else if (match( "ADDTOLOG(" )) placevp(5,ADDTOLOG);
    else if (match( "BETWEEN("  )) placevp(2,INRANGE); 
    else if (match( "NMONTHS("  )) placevp(2,NMONTHS); 
    else if (match( "GETYEAR("  )) placevp(1,GETYEAR); 
    else if (match( "NDAYS("    )) placevp(2,NDAYS);   
    else if (match( "DUEDOM("   )) placevp(1,DUEDOM);  
    else if (match( "DUEHALF("  )) placevp(2,DUEHALF); 
    else if (match( "GETPROD("  )) placevp(1,GETPROD); 
    else if (match( "PROMPT("   )) placevp(2,PROMPT); 
    else if (match( "ERRLINE("  )) placevp(2,ERRLINE); 
    else if (match( "COPYREC("  )) placevp(2,COPYREC); 
    else if (match( "DUPDSFMT(" )) placevp(2,DUPDSFMT);
    else if (match( "REMDSFMT(" )) placevp(1,REMDSFMT); 
    else if (match( "STSRCH("   )) { G_instsrch=1; placevp(2,STSRCH); G_instsrch=0; }
    else if (match( "STSRCHP("  )) placevp(3,STSRCHP); 
    else if (match( "RECNUM("   )) placevp(1,RECNUM); 
    else if (match( "STREAD("   )) placevp(2,STREAD); 
    else if (match( "STWRITE("  )) placevp(1,STWRITE); 
    else if (match( "PICKKEY("  )) placevp(1,PICKKEY);
    else if (match( "SAVESCR("  )) placevp(1,SAVESCR);
    else if (match( "XTIMER("   )) placevp(1,XTIMER);
    else if (match( "SWAPTO("   )) placevp(1,SWAPTO);
    else if (match( "RUN("      )) placevp(1,RUN); 
    else if (match( "JUMPTO("   )) placevp(1,JUMPTO);
    else if (match( "MOVETCUR(" )) placevp(1,MOVETCUR);
    else if (match( "PRLINE("   )) placevp(2,PRLINE);
    else if (match( "PREOL("    )) placetok((CHAR)PREOL,0);
    else if (match( "PREOF("    )) placetok((CHAR)PREOF,0);
    else if (match( "PRAGAIN("  )) placetok((CHAR)PRAGAIN,0);
    else if (match( "PRSEQNCE(" )) placevp(2,PRSEQNCE);
    else if (match( "USEPRDEF(" )) placevp(1,USEPRDEF);
    else if (match( "SENDLINE(" )) placevp(3,SENDLINE);
    else if (match( "SENDEOL("  )) placevp(1,SENDEOL);
    else if (match( "PRADVTO("  )) placevp(1,MOVEPLN);
    else if (match( "STEMPTY("  )) placevp(1,STEMPTY);
    else if (match( "STDELREC(" )) placevp(1,STDELREC);
    else if (match( "PROMPT("   )) placevp(2,PROMPT);
    else if (match( "RUNFORM("  )) { placetok(RUNFORM,0); placevp(3,RUNFORM); }
    else if (match( "MODIFIED(" )) placevp(1,MODIFIED);
    else if (match( "RUNDUMMY(" )) placevp(3,RUNDUMMY);
    else if (match( "RUNCOPY("  )) placevp(3,RUNCOPY);
    else if (match( "RUNSRCH("  )) placevp(3,RUNSRCH);
    else if (match( "BLDSLIST(" )) varargs(3,BLDSLIST);
    else if (match( "BLDTLIST(" )) placevp(3,BLDTLIST);
    else if (match( "DRAWTABL(" )) placetok((CHAR)DRAWTABL,0);
    else if (match( "USESLIST(" )) placevp(1,USESLIST);
    else if (match( "DISPHOT("  )) placetok((CHAR)DISPHOT,0);
    else if (match( "BLANKREC(" )) placevp(1,BLANKREC);
    else if (match( "WAITFLAG(" )) placevp(1,WAITFLAG);
    else if (match( "WAITTEST(" )) placetok(WAITTEST,0);
    else if (match( "HOTKEY("   )) varargs(2,HOTKEY);
    else if (match( "SETDSKEY(" )) varargs(2,SETDSKEY);
    else if (match( "DIVSPEC("  )) placevp(2,DIVSPEC); 
    else if (match( "STCLOSE("  )) placevp(1,STCLOSE);
    else if (match( "FCDCODE("  )) placevp(1,FCDCODE);
    else if (match( "SWAPKBD("  )) placevp(1,SWAPKBD);
    else if (match( "CUSTDISP(" )) placevp(4,CUSTDISP); 
    else if (match( "APPLYFMT(" )) placevp(3,APPLYFMT);
    else if (match( "SAVESTAT(" )) placevp(1,SAVESTAT); 
    else if (match( "RESTSTAT(" )) placetok((CHAR)RESTSTAT,0);
    else if (match( "STDELETE(" )) placevp(1,STDELETE);
//    else if (match( "ABS("      )) placevp(1,ABS  );
//    else if (match( "ACOS("     )) placevp(1,ACOS );
//    else if (match( "ASIN("     )) placevp(1,ASIN );
//    else if (match( "ATAN("     )) placevp(1,ATAN );
//    else if (match( "COSH("     )) placevp(1,COSH );
//    else if (match( "COS("      )) placevp(1,COS  );
//    else if (match( "EXP("      )) placevp(1,EXP  );
//    else if (match( "LOG10("    )) placevp(1,LOG10);
//    else if (match( "LOG("      )) placevp(1,LOGAR);
//    else if (match( "ROUND("    )) placevp(1,ROUND);
//    else if (match( "POW10("    )) placevp(1,POW10);
//    else if (match( "SINH("     )) placevp(1,SINH );
//    else if (match( "SIN("      )) placevp(1,SIN  );
//    else if (match( "SQRT("     )) placevp(1,SQRT );
//    else if (match( "SQR("      )) placevp(1,SQR  );
//    else if (match( "TANH("     )) placevp(1,TANH );
//    else if (match( "TAN("      )) placevp(1,TAN  );
//    else if (match( "TRUNC("    )) placevp(1,TRUNC); 
    else return(0);

    if       (!match(")"          )) error("missing ')'");
    return(1);
}
INT  value(void)
{
    if ((!isspace(*G_str))&&(!isalpha(*G_str))&&(*G_str!='\"')) return(0);
//    if      (match("PI"))  placetok(DCONSTANT,M_PI);
    if      (match("YES")) placetok(CCONSTANT,(LONG)"GYES");
    else if (match("NO"))  placetok(CCONSTANT,(LONG)"GNO");
    else if (match("CF"))  placetok(CURFIELD,0);
    else if (match("MIN")) placetok(SCONSTANT,0);
    else if (match("MAX")) placetok(LCONSTANT,0x7FFFFFFFL);
    else if (match("VAL")) placetok(PASSEDVAL,0);
    else if (match("CREC")) placetok(CREC,0);
    else if (match("NREC")) placetok(NREC,0);
    else if (match("PREC")) placetok(PREC,0);
    else if (match("FREC")) placetok(FREC,0);
    else if (match("LREC")) placetok(LREC,0);
    else if (match("CLREC")) placetok(CLREC,0);
    else if (match("EXITKEY")) placetok(SCONSTANT,(UINT16)F10);
    else if (match("\"")) {
        placetok(CCONSTANT,(LONG)getconststr());
        if (!match("\"")) error("missing '\"'");
    }
    else return(0);
    return(1);
}
INT  cond(void)
{
    if (!isalpha(*G_str)&&(!isspace(*G_str))) return(0);
    if (match("WHILE"))  {
        placetok(MARKER,0);
        expr();
        placetok(WHILE,0);
        oper();
    } else if (match("WHERE"))  {
        G_inwhere=(-1);
        placetok(MARKER,0);
        expr();
        if (G_inwhere==(-1)) error("No Store specified");
        placetok(SCONSTANT,G_inwhere);
        placetok(WHERE,0);
        G_inwhere=(-2);
        oper();
    } else if (match("IF"))  {
        expr();
        placetok(IF,0);
        oper();
    } else if (match("ELSE"))  {
        placetok(ELSE,0);
        oper();
    } else if (match("LOOKUP")) {
        expr();
        placetok(LOOKUP,0);
        oper();
    } else if (match("USING")) {
        while (!match("{")) expr();
        placetok(USING,0);
        placetok(OCURLY,0);
        G_open++;
        oper();
    } else return(0);
    return(1);
}
void outputtoks(void) 
{
    CHAR tmp[100];
    INT fd,i;
    INT16 j;

    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		cdprintf("Can't Open Output File %s\n",tmp);
		return;
	}
    j=0x5A5A;
    write(fd,&j,sizeof(INT16));
    j=(INT16)G_numan;
    write(fd,&j,sizeof(INT16));
    for (i=0;i<G_numan;i++) {
        write(fd,&G_actnbuf[i].d,sizeof(CHAR));
        write(fd,&G_actnbuf[i].t,sizeof(CHAR));
        write(fd,&G_actnbuf[i].o,sizeof(LONG));
        write(fd,G_actnbuf[i].n,9*sizeof(CHAR));
    }
    write(fd,&G_sp,sizeof(LONG));
    write(fd,G_tokbuffer,G_sp);
    close(fd);
}
void  inputstats(void)
{
    CHAR tmp[100];
    INT i,fd;
    INT16 j;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDONLY|O_BINARY);
	if (fd==(-1)) return;
    read(fd,&j,sizeof(INT16));
    if (j==0x5A5A) {
        read(fd,&j,sizeof(INT16));
        G_numan=j;
        for (i=0;i<G_numan;i++) {
            read(fd,&(G_actnbuf[i].d),sizeof(CHAR));
            read(fd,&(G_actnbuf[i].t),sizeof(CHAR));
            read(fd,&(G_actnbuf[i].o),sizeof(LONG));
            read(fd,tmp,9);
		    G_actnbuf[i].n=strdup(tmp);
        }
        read(fd,&G_sp,sizeof(INT));
        read(fd,G_tokbuffer,G_sp);
    } else {
    	G_numstat=0;
        return;
    }
    close(fd);
	G_numstat=0;
    for (i=0;i<G_numan;i++) {
		if ((G_actnbuf[i].t==STATNAME)&&(strcmp(G_actnbuf[i].n,"VERSION"))) G_numstat++;
	}
    if (G_numstat!=0) {
	    G_statbuf=malloc(G_numstat*sizeof(CHAR *));
	    G_numstat=0;
	    if (G_statbuf==NULL) {
		    cdprintf("Can't Load Old Statics - Not Enough Memory\n");
	    } else {
            for (i=0;i<G_numan;i++) {
		        if ((G_actnbuf[i].t==STATNAME)&&(strcmp(G_actnbuf[i].n,"VERSION"))) {
			        G_statbuf[G_numstat]=G_actnbuf[i].n;
			        G_statval[G_numstat]=malloc(81);
                    if (!(strcmp(G_actnbuf[i].n,"PRINTER"))) {
                        // set the PRINTER static to a 0 length string
				        memcpy(G_statval[G_numstat++],"\0",1);
                    } else if (!(strcmp(G_actnbuf[i].n,"MVLSERNM"))) {
                        // set MVL serial number static to a 0 length string
				        memcpy(G_statval[G_numstat++],"\0",1);
                    } else if (!(strcmp(G_actnbuf[i].n,"BVPSERNM"))) {
                        // set BVP serial number static to a 0 length string
				        memcpy(G_statval[G_numstat++],"\0",1);
                    } else if (G_statval[G_numstat]!=NULL) {
				        memcpy(G_statval[G_numstat++],&(G_tokbuffer[G_actnbuf[i].o+1]),80);
			        } else {
				        cdprintf("Can't Load Old Static %d - Not Enough Memory\n",G_numstat);
			        }
		        } else {
                    free(G_actnbuf[i].n);
                }
            }
	    }
    }
	G_sp=0;
	G_numan=0;
	memset(G_tokbuffer,0,MAXSPACE);
	memset(G_actnbuf,0,MAXNAME*sizeof(NAMEIDX));
}
void readcfuncs(void)
{
    FILE *fp;
    CHAR tmp[256];
    int i,j;
    fp=fopen("GPAFUNC.LST","r");
    if (fp==NULL) {
        G_actmaplst=malloc(sizeof(CHAR *));
        G_actmaplst[0]=NULL;
        G_ufunclst=malloc(sizeof(CHAR *));
        G_ufunclst[0]=NULL;
    } else {
        G_actmaplst=malloc(sizeof(CHAR *)*0x1000);
        G_ufunclst=malloc(sizeof(CHAR *)*0x1000);
        i=j=0;
        while (fgets(tmp,255,fp)!=NULL) {
            while ((tmp[strlen(tmp)-1]==10)||(tmp[strlen(tmp)-1]==13)) tmp[strlen(tmp)-1]=0;
            if (tmp[0]=='G') {
                G_actmaplst[i++]=strdup(&tmp[2]);
            } else if (tmp[0]=='U') {
                G_ufunclst[j++]=strdup(&tmp[2]);
            }
        }
        fclose(fp);
        G_actmaplst[i++]=NULL;
        G_ufunclst[j++]=NULL;
        G_actmaplst=realloc(G_actmaplst,sizeof(CHAR *)*i);
        G_ufunclst =realloc(G_ufunclst ,sizeof(CHAR *)*j);
    }
}
INT _cdecl main(INT argc,CHAR *argv[])
{
	INT i;
    CHAR tmp[100],*t;
    printf("Started With %ld\n",farcoreleft());
#if (M_DEBUG==1)
	setbase();
#endif
	strcpy(tmp,getenv("GPACFG"));
    if (argc<2) {
		if (tmp==NULL) {
			printf("PP Config\n");
			return(-1);
		}
	} else {
		t=strrchr(argv[1],'.');
		if (t==NULL) strcpy(tmp,argv[1]);
	}
	G_curdir[0]='\\';
#ifdef __TURBOC__
	getcurdir(0,&G_curdir[1]);
#else
	getcwd(&G_curdir[1],78);
#endif 
	t=strrchr(tmp,'\\');
	if (t!=NULL) {
		*t=0;
		t++;
		strcpy(G_cfgdir,tmp);
	} else {
		t=tmp;
		strcpy(G_cfgdir,G_curdir);
	}
	chdir(G_cfgdir);
	if (!readconfig(t)) {
		cdprintf("Error Reading Config for %s\n",t);
		chdir(G_curdir);
		return(-1);
	}
	memset(G_emptystr,32,80);
	G_emptystr[1]=0;
    if (!loadsdata(G_system)) {
        cdprintf("Can't load store data for %s\n",G_system);
		chdir(G_curdir);
        return(-1);
    }
 	G_actnbuf=malloc(MAXNAME*sizeof(NAMEIDX));
	if (G_actnbuf==NULL) {
		cdprintf("Not enough memory\n");
		RETURNV(-1);
	}
    G_tokbuffer=malloc(MAXSPACE);
    readcfuncs();
	inputstats();

    sprintf(G_file,"%s%sR.DAT",G_config,G_system);
    cdprintf("Unisys 32 bit Action Pre-Parser  Version 2.1 - Copyright (c) 1993/4 Unisys Ltd.\n%s:\n",G_file);
	G_lnum=0;
	if ((G_fp=fopen(G_file,"r"))!=NULL) {
        while (getline()) while ((G_str)&&(*G_str)) oper();
        fclose(G_fp);
    }
    if (G_open) error("missing }");
    if (G_nume) {
        cdprintf("\n*** %d Error%c found ***\n",G_nume,((G_nume!=1)?'s':' '));
		cdprintf("\nOutput file not generated\n");
    } else {
        cdprintf("*** No Errors found ***\n");
    	sprintf(G_file,"%s%sA.DAT",G_config,G_system);
	    cdprintf("%s:\n",G_file);
		G_lnum=0;
    	if ((G_fp=fopen(G_file,"r"))!=NULL) {
        	while (getline()) while ((G_str)&&(*G_str)) oper();
        	fclose(G_fp);
    	}

    	if (G_open) error("missing }");
    	if (G_nume) {
	        cdprintf("\n*** %d Error%c found ***\n",G_nume,((G_nume!=1)?'s':' '));
    	} else {
        	cdprintf("*** No Errors found ***\n");
    	}
	    outputtoks();
    }
    if (argc==3) {
//		pstack();
	    for (i=0;i<G_numan;i++) {
			cdprintf("%c %c %d %s\n",
				G_actnbuf[i].d,
				G_actnbuf[i].t,
				G_actnbuf[i].o,
				G_actnbuf[i].n);
	    }
        cdprintf("G_sp=%ld G_numan=%d\n",G_sp,G_numan);
	} else {
		cdprintf("G_sp=%ld G_numan=%d\n",G_sp,G_numan); // if (G_nume) 
	}
	chdir(G_curdir);
    printf("Ended With %ld\n",farcoreleft());
    free(G_tokbuffer);
    return(G_nume);
}

