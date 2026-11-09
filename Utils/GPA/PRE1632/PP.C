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
extern ACTMAP G_ufunc[];
extern ACTMAP G_actmap[];
#if (M_DEBUG==1)
extern void setbase(void);
#endif

#ifdef __TURBOC__
#define I asm
#else
#define I __asm
#endif
#define FC      //_fastcall

#define MAXSPACE 300000L
#define MAXNAME  2000
#define MAXSTAT  100

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

INT     FC near match           (CHAR *t);
void    FC near error           (CHAR *err);
void    FC near oper            (void);
void    FC near expr            (void);
void    FC near term            (void);
void    FC near fact            (void);
void    FC near part            (void);
void    FC near cons            (void);
INT     FC near varib           (void);
INT     FC near func            (void);
INT     FC near value           (void);
INT     FC near cond            (void);

void near cdprintf(CHAR *fmt,...)
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
        if ((buf=MALLOC(LCOMPLEN))==NULL) {printf("Memory Error 1.\n"); return; }
        memcpy(buf,mem,LCOMPLEN);
        if ((map=MALLOC(COMPLEN))==NULL) {printf("Memory Error 2.\n"); return; }
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
INT FC near getline(void)
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
void FC near includefile(CHAR *name)
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
CHAR * near remspace(CHAR *s)
{
    CHAR l;
    if (!*s) return(s);
I { push ds
    push si
    lds si,s
    mov cx,-1
    xor ah,ah
}
mloop:
I { lodsb
    cmp al,32
    je next
    cmp al,9
    jne fin
}
next:
I { inc ah
    loop mloop
}
fin:
I { mov l,ah
    pop si
    pop ds
}
    return(s+l);
}
CHAR * FC near gettok(void)
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
CHAR * FC near getconststr(void)
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
void FC near skiptok(void)
{
    G_str=remspace(G_str);
    while ((*G_str)&&isalnum(*G_str)) G_str++;
}

INT FC near findfield(void)
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
INT FC near match(CHAR *t)  
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
void FC near error(CHAR *err)
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
INT FC near addname(CHAR *name,INT t)
{
    INT i;
    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(0);
    }
    G_actnbuf[G_numan  ].n=strdup(name);
    G_actnbuf[G_numan  ].t=t;
    G_actnbuf[G_numan++].o=G_sp;
    return(1);
}
INT FC near findname(CHAR *name)
{
    INT i=0;

    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(i);
    }
    return(-1);
}
UCHAR FC near tokenval(ULONG o)
{
    static UCHAR tok[2];
	restpblk("TOKBUFFER",tok,o,2);
    return(tok[0]);
}
void FC near tokcpy(ULONG o,void *b,INT len)
{
	savepblk("TOKBUFFER",(CHAR *)b,o,len);
}
void FC near settoken(ULONG o,UCHAR v)
{
    tokcpy(o,(void*)&v,1);
}
void FC near settokeni(ULONG o,UINT v)
{
    tokcpy(o,(void*)&v,sizeof(INT));
}
void FC near settokenl(ULONG o,ULONG v)
{
    tokcpy(o,(void*)&v,sizeof(LONG));
}
void FC near settokend(ULONG o,double v)
{
    tokcpy(o,(void*)&v,sizeof(double));
}
void FC near settokens(ULONG o,UCHAR *v)
{
    tokcpy(o,(void*)v,strlen((CHAR *)v)+1);
}
void FC near settokenf(ULONG o,UCHAR *v,INT l)
{
    tokcpy(o,(void*)v,l);
}

void FC near placetok(CHAR t,double v)
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
            settokeni(G_sp+1,(UINT)v);
            G_sp+=sizeof(INT);
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
void FC near placevp(INT np,INT tok)
{
    INT i;
    expr(); for (i=1;i<np;i++) { match(","); expr(); } placetok((CHAR)tok,0);
}
void FC near ptok(UCHAR *p)
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
//        case TVARIABLE : cdprintf("TV ");                            break;
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
        case SETCURITM : cdprintf("@CF ");                           break;
        case ACTIONN   : cdprintf("ACT ");                           break;
        case RANGE     : cdprintf("<-> ");                           break;
        case RESULT    : cdprintf("ð ");                             break;
        case LOOKUP    : cdprintf("LOOK ");                          break;
        case USERVAR   : cdprintf("UVAR ");                          break;
        case SETUSRVAR : cdprintf("@UVAR ");                         break;
        case STATICS   : cdprintf("STATIC ");                        break;
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
		case PSHKEY	   : cdprintf("PSHKEY ");                        break;
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
        case TOTALBOX  : cdprintf("TOTALBOX ");                      break;
        case PRLINE    : cdprintf("PRLINE ");                        break;
        case PREOL     : cdprintf("PREOL ");                         break;
        case PREOF     : cdprintf("PREOF ");                         break;
        case PRAGAIN   : cdprintf("PRAGAIN ");                       break;
        case SENDLINE  : cdprintf("SENDLINE ");                      break;
        case SENDEOL   : cdprintf("SENDEOL ");                       break;
        case MOVEPLN   : cdprintf("MOVEPLN ");                       break;
        case JUMPTO    : cdprintf("JUMPTO ");                        break;
        case MOVETCUR  : cdprintf("MOVETCUR ");                      break;
        case SETDSKEY  : cdprintf("SETDSKEY ");                      break;
        case RUNCOPY   : cdprintf("RUNCOPY ");                       break;
        case RUNSRCH   : cdprintf("RUNSRCH ");                       break;
        case DISPHOT   : cdprintf("DISPHOT ");                       break;
        case BLANKREC  : cdprintf("BLANKREC ");                      break;
        case VARARGS   : cdprintf("VARARGS ");                       break;
        case WAITFLAG  : cdprintf("WAITFLAG ");                      break;
        case WAITTEST  : cdprintf("WAITTEST ");                      break;
        default        : cdprintf("Error Unknown Instruction %d ",*p);
    }
}
/*
void FC near pstack(void)
{
    UCHAR *s,*p;
    p=G_tokspace;
    while (p<(&tokenval(G_sp))) {
        s=p;
        switch (*p) {
            case TCONSTANT : p++;                         break;
            case SCONSTANT : p+=sizeof(INT);              break;
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
LONG FC near statadd(CHAR *name)
{
	INT i;
	static CHAR tmp[81];
	memset(tmp,32,81);
	for (i=0;i<G_numstat;i++) {
		if (!strcmp(name,G_statbuf[i])) {
			strcpy(tmp,G_statval[i]);
			tmp[strlen(tmp)]=32;
			break;
		}
	}
	tmp[79]=0;
	return((LONG)tmp);
}
void FC near oper(void)
{
    if (match("VARIABLE")) {
        if (!addname(gettok(),VARIABLE)) error("duplicate name");
        placetok(CCONSTANT,(LONG)G_emptystr);
        skiptok();
    } else if (match("STATIC")) {
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
//            	else  if (tokenval(G_sp-1)==TVARIABLE) settoken(G_sp-1,SETTVARIB);
            	else  if (tokenval(G_sp-1)==DATASTORE) settoken(G_sp-1,SETDATAST);
            	else  if (tokenval(G_sp-1)==CURFIELD ) settoken(G_sp-1,SETCURITM);
            	else  if (tokenval(G_sp-1)==USERVAR  ) settoken(G_sp-1,SETUSRVAR);
            	else  if (tokenval(G_sp-1)==STATICS  ) settoken(G_sp-1,SETSTATIC);
            	else  if (tokenval(G_sp-1)==GLOBVAR  ) settoken(G_sp-1,SETGLOBVR);
            	placevp(1,EQUAL);
        	} else break;
		}
    }
}
void FC near expr(void)
{
    term();
    if (strchr("&| \t",*G_str)==NULL) return;

    for (;;) {
        if      (match("&&")) { term(); placetok(LOGIC_AND,0); }
        else if (match("||")) { term(); placetok(LOGIC_OR ,0); }
        else break;
    }
}
void FC near term(void)
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
void FC near fact(void)
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
void FC near part(void)
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
INT FC near iscaction(CHAR *name)
{
    INT i=0;
    while (G_actmap[i].name!=NULL) {
        if (!strcmp(name,G_actmap[i].name)) {
            return(i+1);
        }
        i++;
    }
    i=0;
    while (G_ufunc[i].name!=NULL) {
        if (!strcmp(name,G_ufunc[i].name)) {
            return(i+1000);
        }
        i++;
    }
    return(0);
}
void FC near cons(void)
{
    double tf;
    ULONG tl;
    LONG lval;
    INT i,val;

    
    match("IN");

    if (match("NAME*")) {
        if (!addname(gettok(),ANAME)) error("duplicate name");
        i=findname(gettok());
        G_actnbuf[i].d=1;
        placetok(SCONSTANT,i);
        placetok(ANAME,0);
        skiptok();
    }
    if (match("NAME")) {
        if (!addname(gettok(),ANAME)) error("duplicate name");
        i=findname(gettok());
        G_actnbuf[i].d=0;
        placetok(SCONSTANT,i);
        placetok(ANAME,0);
        skiptok();
    }
    if (match("TABLE")) {
        if (!addname(gettok(),TABLE)) error("duplicate name");
        i=findname(gettok());
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
                    if ((val=findname(gettok()))==(-1)) {
                        if ((val=findfield())==(-1)) {
                            if ((val=snum(gettok()))==(-1)) {
                                if ((val=iscaction(gettok()))==0) {
                                    if ((lval=isform(gettok()))==(-1L)) {
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
                                        placetok(LCONSTANT,lval);
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
                                placetok(SCONSTANT,val);
                                placetok(DSNAME,0);
                            }
                        } else {
                            placetok(SCONSTANT,val/100);
                            placetok(SCONSTANT,val%100);
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
INT FC near varib(void)
{
    if (strchr("FVLfvl \t",*G_str)==NULL) return(0);
    if      (match("F["))      { expr(); placetok(FORMVAR ,0); }
    else if (match("V["))      { expr(); placetok(VARIABLE,0); }
    else if (match("LOGQTY[")) { expr(); placetok(LOGQNTY ,0); }
    else if (match("LOGVAL[")) { expr(); placetok(LOGVALUE,0); }
    else if (match("LOGNAM[")) { expr(); placetok(LOGNAME ,0); }
    else return(0);

    if (!match("]")) error("missing ']'");
    return(1);
}
void FC near varargs(INT m,INT tok)
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
INT FC near func(void)
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
    else if (match( "PUSHKEY("  )) placevp(1,PSHKEY);
    else if (match( "SAVESCR("  )) placevp(1,SAVESCR);
    else if (match( "XTIMER("   )) placevp(1,XTIMER);
    else if (match( "SWAPTO("   )) placevp(1,SWAPTO);
    else if (match( "RUN("      )) placevp(1,RUN); 
    else if (match( "OUTPUT(" )) placevp(5,TOTALBOX);
    else if (match( "JUMPTO("   )) placevp(1,JUMPTO);
    else if (match( "MOVETCUR(" )) placevp(1,MOVETCUR);
    else if (match( "PRLINE("   )) placevp(2,PRLINE);
    else if (match( "PREOL("    )) placetok((CHAR)PREOL,0);
    else if (match( "PREOF("    )) placetok((CHAR)PREOF,0);
    else if (match( "PRAGAIN("  )) placetok((CHAR)PRAGAIN,0);
    else if (match( "SENDLINE(" )) placevp(3,SENDLINE);
    else if (match( "SENDEOL("  )) placevp(1,SENDEOL);
    else if (match( "PRADVTO("  )) placevp(1,MOVEPLN);
    else if (match( "STEMPTY("  )) placevp(1,STEMPTY);
    else if (match( "STDELREC(" )) placevp(1,STDELREC);
    else if (match( "PROMPT("   )) placevp(2,PROMPT);
    else if (match( "RUNFORM("  )) { placetok(RUNFORM,0); placevp(3,RUNFORM); }
    else if (match( "RUNCOPY("  )) placevp(3,RUNCOPY);
    else if (match( "RUNSRCH("  )) placevp(3,RUNSRCH);
    else if (match( "DISPHOT("  )) placetok((CHAR)DISPHOT,0);
    else if (match( "BLANKREC(" )) placevp(1,BLANKREC);
    else if (match( "WAITFLAG(" )) placevp(1,WAITFLAG);
    else if (match( "WAITTEST(" )) placetok(WAITTEST,0);
    else if (match( "HOTKEY("   )) varargs(2,HOTKEY);
    else if (match( "SETDSKEY(" )) varargs(2,SETDSKEY);
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
INT FC near value(void)
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
    else if (match("\"")) {
        placetok(CCONSTANT,(LONG)getconststr());
        if (!match("\"")) error("missing '\"'");
    }
    else return(0);
    return(1);
}
INT FC near cond(void)
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
void near outputtoks(void) // FC 
{
    ULONG l,tl;
    UINT l1;
    CHAR tmp[100];
    CHAR *buf;
    INT i,fd;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		cdprintf("Can't Open Output File %s\n",tmp);
		return;
	}
    i=0x5A5A;
    write(fd,&i,sizeof(INT));
    write(fd,&G_numan,sizeof(INT));
    for (i=0;i<G_numan;i++) {
//        printf("%-10.10s",G_actnbuf[i].n);
        write(fd,&G_actnbuf[i].d,sizeof(CHAR));
        write(fd,&G_actnbuf[i].t,sizeof(CHAR));
        write(fd,&G_actnbuf[i].o,sizeof(LONG));
        write(fd,G_actnbuf[i].n,9);
    }
    write(fd,&G_sp,sizeof(LONG));
//    printf("\n");
    l=G_sp;
    l1=10000;
    tl=0L;
    buf=MALLOC(10000);
    if (buf!=NULL) {
        while (tl<l) {
            if ((tl+(LONG)l1)>l) l1=(INT)(l-tl);
//            printf("%ld-%d ",tl,l1);
            if (l1>0L) {
        	    restpblk("TOKBUFFER",buf,tl,l1);
                write(fd,buf,l1);
                tl+=l1;
            }
        }
        FREE(buf);
    }
//    printf("G_sp=%ld G_numan=%d\n",G_sp,G_numan);
    close(fd);
}
void FC near inputstats(void)
{
    CHAR tmp[100];
    INT i,fd;
    UINT j;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDONLY|O_BINARY);
	if (fd==(-1)) return;
    read(fd,&G_numan,sizeof(INT));
    if (G_numan==0x5A5A) {
        read(fd,&G_numan,sizeof(INT));
        for (i=0;i<G_numan;i++) {
            read(fd,&(G_actnbuf[i].d),sizeof(CHAR));
            read(fd,&(G_actnbuf[i].t),sizeof(CHAR));
            read(fd,&(G_actnbuf[i].o),sizeof(LONG));
            read(fd,tmp,9);
		    G_actnbuf[i].n=strdup(tmp);
        }
        read(fd,&G_sp,sizeof(INT));
//        read(fd,G_tokspace,G_sp);
    } else {
        for (i=0;i<G_numan;i++) {
            read(fd,&(G_actnbuf[i].d),sizeof(CHAR));
            read(fd,&(G_actnbuf[i].t),sizeof(CHAR));
            read(fd,&j,sizeof(INT));
            G_actnbuf[i].o=(ULONG)j;
            read(fd,tmp,9);
		    G_actnbuf[i].n=strdup(tmp);
        }
        read(fd,&j,sizeof(INT));
        G_sp=(ULONG)j;
//        read(fd,G_tokspace,j);
    }
    close(fd);
	G_numstat=0;
    for (i=0;i<G_numan;i++) {
		if (G_actnbuf[i].t==STATNAME) G_numstat++;
	}
	G_statbuf=MALLOC(G_numstat*sizeof(CHAR *));
	G_numstat=0;
	if (G_statbuf==NULL) {
		cdprintf("Can't Load Old Statics - Not Enough Memory\n");
		return;
	}
    for (i=0;i<G_numan;i++) {
		if (G_actnbuf[i].t==STATNAME) {
			G_statbuf[G_numstat]=G_actnbuf[i].n;
			G_statval[G_numstat]=MALLOC(81);
			if (G_statval[G_numstat]!=NULL) {
//				memcpy(G_statval[G_numstat++],&(G_tokspace[G_actnbuf[i].o+1]),80);
			} else {
				cdprintf("Can't Load Old Static %d - Not Enough Memory\n",G_numstat);
			}
		}
	}
	G_sp=0;
	G_numan=0;
//	memset(G_tokspace,0,MAXSPACE);
	memset(G_actnbuf,0,MAXNAME*sizeof(NAMEIDX));
}




INT _cdecl main(INT argc,CHAR *argv[])
{
	INT i;
    CHAR tmp[100],*t;
#if (M_DEBUG==1)
	setbase();
#endif
	strcpy(tmp,getenv("GPACFG"));
    if (argc<2) {
		if (tmp==NULL) {
			cleanupblks(0);
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
//    if (!loadtext(G_system)) {
//        cdprintf("Can't load text for %s\n",G_system);
//		chdir(G_curdir);
//        return(-1);
//    }
 	G_actnbuf=MALLOC(MAXNAME*sizeof(NAMEIDX));
	if (G_actnbuf==NULL) {
		cdprintf("Not enough memory\n");
		RETURNV(-1);
	}
	setupblk("TOKBUFFER",MAXSPACE);
//	inputstats();

    sprintf(G_file,"%s%sR.DAT",G_config,G_system);
    cdprintf("Unisys Action Pre-Parser  Version 2.0 - Copyright (c) 1993/4 Unisys Ltd.\n%s:\n",G_file);
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
		cleanupblks(1);
	} else {
		cdprintf("G_sp=%ld G_numan=%d\n",G_sp,G_numan); // if (G_nume) 
		cleanupblks(0);
	}
	chdir(G_curdir);
    return(G_nume);
}

