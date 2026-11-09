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
char G_emptystr[80];
extern ACTMAP G_ufunc[];
extern ACTMAP G_actmap[];
#if (M_DEBUG==1)
extern void setbase(void);
#endif

#define MAXSPACE 300000L
#define MAXNAME  1000
#define MAXSTAT  100

typedef struct {
    char  d;
    char  t;
    char *n;
    unsigned long  o;
} NAMEIDX;

char        **G_statbuf;
char        *G_statval[MAXSTAT];
int         G_numstat=0;
NAMEIDX     *G_actnbuf;
int         G_numan=0;
int G_inwhere=(-2);
int G_instsrch=0;
int G_lastst=0;
FILE *G_fp;
unsigned long G_headlimit=0L;
unsigned long G_sp=0L;
char G_file[100];

int G_open=0;
int G_lnum=0;
int G_nume=0;
int G_curitem=3;
char *G_str;
char *G_startstr;
char G_linein[256];

int     match           (char *t);
void    error           (char *err);
void    oper            (void);
void    expr            (void);
void    term            (void);
void    fact            (void);
void    part            (void);
void    cons            (void);
int     varib           (void);
int     func            (void);
int     value           (void);
int     cond            (void);

void cdprintf(unsigned char *fmt,...)
{
	va_list ap;
	chdir(G_curdir);
    va_start(ap,fmt);
    vfprintf(stdout,fmt,ap);
    va_end(ap);
	chdir(G_cfgdir);
}
int getline(void)
{
    memset(G_linein,0,255);
    G_startstr=G_str=fgets(G_linein,255,G_fp);
    G_lnum++;
//	if (G_startstr!=NULL) cdprintf("%s",G_str);
    return(G_startstr!=NULL);
}
void includefile(char *name)
{
    char of[80];
    FILE *ofp;
    char *s;
    int oln;

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
char *gettok(void)
{
    int i=0;
    char *p;
    static char s[100];

    p=G_str;
    while ((*p)&&isspace(*p)) p++;
    G_str=p;
    while ((*p)&&isalnum(*p)&&i<100) s[i++]=*(p++);
    s[i]=0;
    return(s);
}
char *getconststr(void)
{
    int i=0;
    char *p;
    static char s[100];

    p=G_str;
    while ((*p)&&(*p!='"')&&(i<100)) s[i++]=*(p++);
    s[i]=0;
    G_str+=i;
    return(s);
}
void skiptok(void)
{
    while ((*G_str)&&isspace(*G_str)) G_str++;
    while ((*G_str)&&isalnum(*G_str)) G_str++;
}

int findfield(void)
{
    int i=0;
    int j;
    char *p,sn[10],fn[10];

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
int match(char *t)  
{                   
    char *p;        
    int len=strlen(t);
                    
    while (isspace(*G_str)) G_str++;
    while (!(*G_str)) {
        if (!getline()) return(0);
        while (isspace(*G_str)) G_str++;
    }
    p=G_str;
    while ((*t)&&(*t==toupper(*(p++)))) t++;
    if (*t==0) {
        G_str+=len;
        return(1);
    }
    return(0);
}
void error(char *err)
{
    static int ll=0;
    char *p;
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
int addname(char *name,int t)
{
    int i;
    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(0);
    }
    G_actnbuf[G_numan  ].n=strdup(name);
    G_actnbuf[G_numan  ].t=t;
    G_actnbuf[G_numan++].o=G_sp;
    return(1);
}
int findname(char *name)
{
    int i=0;

    for (i=0;i<G_numan;i++) {
        if (!strcmp(name,G_actnbuf[i].n)) return(i);
    }
    return(-1);
}
unsigned char tokenval(unsigned long o)
{
    static unsigned char tok[2];
	restpblk("TOKBUFFER",tok,o,2);
    return(tok[0]);
}
void tokcpy(unsigned long o,void *b,int len)
{
    unsigned long l;
	savepblk("TOKBUFFER",(char *)b,o,len);
}
void settoken(unsigned long o,unsigned char v)
{
    tokcpy(o,&v,1);
}
void settokeni(unsigned long o,unsigned int v)
{
    tokcpy(o,&v,sizeof(int));
}
void settokenl(unsigned long o,unsigned long v)
{
    tokcpy(o,&v,sizeof(long));
}
void settokend(unsigned long o,double v)
{
    tokcpy(o,&v,sizeof(double));
}
void settokens(unsigned long o,unsigned char *v)
{
    tokcpy(o,v,strlen(v)+1);
}
void settokenf(unsigned long o,unsigned char *v,int l)
{
    tokcpy(o,v,l);
}

void placetok(char t,double v)
{
    char *s;
    switch (t) {
        case TCONSTANT :
            settoken(G_sp,t);
            settoken(G_sp+1,(unsigned char)v);
            G_sp++;
            break;
        case SCONSTANT :
            settoken(G_sp,t);
            settokeni(G_sp+1,(unsigned int)v);
            G_sp+=sizeof(int);
            break;
        case LCONSTANT :
            settoken(G_sp,t);
            settokenl(G_sp+1,(unsigned long)v);
            G_sp+=sizeof(long);
            break;
        case DCONSTANT :
            settoken(G_sp,t);
            settokend(G_sp+1,(double)v);
            G_sp+=sizeof(double);
            break;
        case CCONSTANT :
            settoken(G_sp,t);
            s=(unsigned char *)(unsigned long)v;
            settokens(G_sp+1,s);
            G_sp+=strlen(s)+1L;
            break;
        case STATNAME :
            settoken(G_sp,t);
            s=(unsigned char *)(unsigned long)v;
            settokenf(G_sp+1,s,80);
            G_sp+=80L;
            break;
		default :
            settoken(G_sp,t);
    }
    G_sp++;
}
void placevp(int np,int tok)
{
    int i;
    expr(); for (i=1;i<np;i++) { match(","); expr(); } placetok((char)tok,0);
}
void ptok(unsigned char *p)
{
    switch (*p) {
        case TCONSTANT : cdprintf("%d " ,*((unsigned char *)(p+1))); break;
        case SCONSTANT : cdprintf("%d " ,*((unsigned int *) (p+1))); break;
        case LCONSTANT : cdprintf("%ld ",*((unsigned long *)(p+1))); break;
        case DCONSTANT : cdprintf("%f " ,*((double *)       (p+1))); break;
        case CCONSTANT : cdprintf("%s " ,  (unsigned char *)(p+1));  break;
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
        default        : cdprintf("Error Unknown Instruction %d ",*p);
    }
}
/*
void pstack(void)
{
    unsigned char *s,*p;
    p=G_tokspace;
    while (p<(&tokenval(G_sp))) {
        s=p;
        switch (*p) {
            case TCONSTANT : p++;                         break;
            case SCONSTANT : p+=sizeof(int);              break;
            case LCONSTANT : p+=sizeof(long);             break;
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
long statadd(char *name)
{
	int i;
	static char tmp[81];
	memset(tmp,32,81);
	for (i=0;i<G_numstat;i++) {
		if (!strcmp(name,G_statbuf[i])) {
			strcpy(tmp,G_statval[i]);
			tmp[strlen(tmp)]=32;
			break;
		}
	}
	tmp[79]=0;
	return((long)tmp);
}
void oper(void)
{
    if (match("VARIABLE")) {
        if (!addname(gettok(),VARIABLE)) error("duplicate name");
        placetok(CCONSTANT,(long)G_emptystr);
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
void expr(void)
{
    term();

    for (;;) {
        if      (match("&&")) { term(); placetok(LOGIC_AND,0); }
        else if (match("||")) { term(); placetok(LOGIC_OR ,0); }
        else break;
    }
}
void term(void)
{

    fact();

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
void fact(void)
{
    part();

    for (;;) {
        if      (match("+")) {  part(); placetok(PLUS,0); }
        else if (match("-")) {  part(); placetok(MINUS,0); }
        else if (match("S+")) { part(); placetok(SJOIN,0); }
        else break;
    }
}
void part(void)
{
    cons();

    for (;;) {
        if      (match("*"))  { part(); placetok(MULTIPLY,0); }
        else if (match("%"))  { part(); placetok(MODULUS ,0); }
        else if (match("/"))  { part(); placetok(DEVIDE  ,0); }
        else if (match("TO")) { part(); placetok(RANGE   ,0); }
        else break;
    }
}
int iscaction(char *name)
{
    int i=0;
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
void cons(void)
{
    double tf;
    unsigned long tl;
    long lval;
    char *p;
    int i,val;

    
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
            if (tf!=(double)((unsigned long)tf)) {
                placetok(DCONSTANT,tf);
            }  else {
                tl=(unsigned long)tf;
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
int varib(void)
{
    if      (match("F["))      { expr(); placetok(FORMVAR ,0); }
    else if (match("V["))      { expr(); placetok(VARIABLE,0); }
    else if (match("LOGQTY[")) { expr(); placetok(LOGQNTY ,0); }
    else if (match("LOGVAL[")) { expr(); placetok(LOGVALUE,0); }
    else if (match("LOGNAM[")) { expr(); placetok(LOGNAME ,0); }
    else return(0);

    if (!match("]")) error("missing ']'");
    return(1);
}
int func(void)
{
    if      (match( "SUPPER("   )) placevp(1,SUPPER);  
    else if (match( "SLOWER("   )) placevp(1,SLOWER);
    else if (match( "DAYOFWK("  )) placevp(1,DAYOFWK); 
    else if (match( "DATE("     )) placevp(1,DATESTR); 
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
    else if (match( "HOTKEY("   )) placevp(2,HOTKEY);
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
    else if (match( "PREOL("    )) placetok((char)PREOL,0);
    else if (match( "PREOF("    )) placetok((char)PREOF,0);
    else if (match( "PRAGAIN("  )) placetok((char)PRAGAIN,0);
    else if (match( "SENDLINE(" )) placevp(3,SENDLINE);
    else if (match( "SENDEOL("  )) placevp(1,SENDEOL);
    else if (match( "PRADVTO("  )) placevp(1,MOVEPLN);
    else if (match( "STEMPTY("  )) placevp(1,STEMPTY);
    else if (match( "STDELREC(" )) placevp(1,STDELREC);
    else if (match( "PROMPT("   )) placevp(2,PROMPT);
    else if (match( "RUNFORM("  )) { placetok(RUNFORM,0); placevp(3,RUNFORM); }
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
int value(void)
{
//    if      (match("PI"))  placetok(DCONSTANT,M_PI);
    if      (match("YES")) placetok(CCONSTANT,(long)"GYES");
    else if (match("NO"))  placetok(CCONSTANT,(long)"GNO");
    else if (match("CF"))  placetok(CURFIELD,0);
    else if (match("MIN")) placetok(SCONSTANT,0);
    else if (match("MAX")) placetok(LCONSTANT,0x7FFFFFFF);
    else if (match("VAL")) placetok(PASSEDVAL,0);
    else if (match("CREC")) placetok(CREC,0);
    else if (match("NREC")) placetok(NREC,0);
    else if (match("PREC")) placetok(PREC,0);
    else if (match("FREC")) placetok(FREC,0);
    else if (match("LREC")) placetok(LREC,0);
    else if (match("CLREC")) placetok(CLREC,0);
    else if (match("\"")) {
        placetok(CCONSTANT,(long)getconststr());
        if (!match("\"")) error("missing '\"'");
    }
    else return(0);
    return(1);
}
int cond(void)
{
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
    unsigned long l,tl;
    unsigned int l1;
    char tmp[100];
    char *buf;
    int i,fd;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		cdprintf("Can't Open Output File %s\n",tmp);
		return;
	}
    i=0x5A5A;
    write(fd,&i,sizeof(int));
    write(fd,&G_numan,sizeof(int));
    for (i=0;i<G_numan;i++) {
        write(fd,&G_actnbuf[i].d,sizeof(char));
        write(fd,&G_actnbuf[i].t,sizeof(char));
        write(fd,&G_actnbuf[i].o,sizeof(long));
        write(fd,G_actnbuf[i].n,9);
    }
    write(fd,&G_sp,sizeof(long));
    l=G_sp;
    l1=10000;
    tl=0L;
    buf=MALLOC(10000);
    if (buf!=NULL) {
        while (tl<l) {
            if ((tl+l1)>l) l1=l-tl;
        	restpblk("TOKBUFFER",buf,tl,l1);
            write(fd,buf,l1);
            tl+=l1;
        }
    }
    close(fd);
}
void inputstats(void)
{
    char tmp[100];
    int i,fd;
    unsigned int j;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDONLY|O_BINARY);
	if (fd==(-1)) return;
    read(fd,&G_numan,sizeof(int));
    if (G_numan==0x5A5A) {
        read(fd,&G_numan,sizeof(int));
        for (i=0;i<G_numan;i++) {
            read(fd,&(G_actnbuf[i].d),sizeof(char));
            read(fd,&(G_actnbuf[i].t),sizeof(char));
            read(fd,&(G_actnbuf[i].o),sizeof(long));
            read(fd,tmp,9);
		    G_actnbuf[i].n=strdup(tmp);
        }
        read(fd,&G_sp,sizeof(int));
//        read(fd,G_tokspace,G_sp);
    } else {
        for (i=0;i<G_numan;i++) {
            read(fd,&(G_actnbuf[i].d),sizeof(char));
            read(fd,&(G_actnbuf[i].t),sizeof(char));
            read(fd,&j,sizeof(int));
            G_actnbuf[i].o=(unsigned long)j;
            read(fd,tmp,9);
		    G_actnbuf[i].n=strdup(tmp);
        }
        read(fd,&j,sizeof(int));
        G_sp=(unsigned long)j;
//        read(fd,G_tokspace,j);
    }
    close(fd);
	G_numstat=0;
    for (i=0;i<G_numan;i++) {
		if (G_actnbuf[i].t==STATNAME) G_numstat++;
	}
	G_statbuf=MALLOC(G_numstat*sizeof(char *));
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
int _cdecl main(int argc,char *argv[])
{
    FILE *fp;
	int i;
    char tmp[100],*t;
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
	getcurdir(0,&G_curdir[1]);
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
	G_emptystr[79]=0;
    if (!loadsdata(G_system)) {
        cdprintf("Can't load store data for %s\n",G_system);
		chdir(G_curdir);
        return(-1);
    }
    if (!loadtext(G_system)) {
        cdprintf("Can't load text for %s\n",G_system);
		chdir(G_curdir);
        return(-1);
    }
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
    }
    fclose(G_fp);
    if (G_open) error("missing }");
    textattr(0x07);
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
    	}
    	fclose(G_fp);

    	if (G_open) error("missing }");
    	textattr(0x07);
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
		cleanupblks(1);
		cdprintf("G_sp=%ld\n",G_sp);
	} else {
		cleanupblks(0);
		cdprintf("G_sp=%ld\n",G_sp); // if (G_nume) 
	}
	chdir(G_curdir);
    return(G_nume);
}

