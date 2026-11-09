#define GPA_C
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <math.h>
#include <ctype.h>
#include <errno.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpa.h"
char G_emptystr[80];
extern ACTMAP G_ufunc[];
extern ACTMAP G_actmap[];

#define MAXSPACE 30000
#define MAXNAME  1000
#define MAXSTAT  100

typedef struct {
    char  d;
    char  t;
    char *n;
    int   o;
} NAMEIDX;

NAMEIDX     *G_statbuf;
char        *G_statval[MAXSTAT];
int         G_numstat=0;
NAMEIDX     *G_actnbuf;
int         G_numan=0;
int G_inwhere=(-2);
int G_instsrch=0;
int G_lastst=0;
FILE *G_fp;
char *G_tokspace;
int G_sp=0;


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

int getline(void)
{
    G_startstr=G_str=fgets(G_linein,255,G_fp);
//	printf("%s",G_str);
    G_lnum++;
    return(G_startstr!=NULL);
}
char *gettok(void)
{
    int i=0;
    char *p;
    static char s[100];

    p=G_str;
    while ((*p)&&isspace(*p)) p++;
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
    char *p;
    G_nume++;
    textattr(0x07);
    printf("Error %-20s %3d : ",err,G_lnum);

    for (p=G_linein;p<G_str;p++) printf("%c",*p);
    textattr(0x1E);
    if (isalnum(*p)) {
        while (isalnum(*p)) printf("%c",*(p++));
    } else {
        while ((!isalnum(*p))&&(!isspace(*p))&&(*p)) printf("%c",*(p++));
    }
    G_str=p;

    textattr(0x07);
    printf("%s\r",G_str);
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
void placetok(char t,double v)
{
    char *p=&G_tokspace[G_sp];
    char *s;
    switch (t) {
        case TCONSTANT :
		    *p=t;
            p++;
            *p=(unsigned char)v;
            G_sp++;
            break;
        case SCONSTANT :
		    *p=t;
            p++;
            *((unsigned int *)p)=(unsigned int)v;
            G_sp+=sizeof(int);
            break;
        case LCONSTANT :
		    *p=t;
            p++;
            *((unsigned long *)p)=(unsigned long)v;
            G_sp+=sizeof(long);
            break;
        case DCONSTANT :
		    *p=t;
            p++;
            *((double *)p)=v;
            G_sp+=sizeof(double);
            break;
        case CCONSTANT :
		    *p=t;
            p++;
            s=(unsigned char *)(unsigned long)v;
            strcpy(p,s);
            G_sp+=strlen(s)+1;
            break;
        case STATNAME :
		    *p=CCONSTANT;
            p++;
            s=(unsigned char *)(unsigned long)v;
            memcpy(p,s,80);
			*(p+79)=0;
            G_sp+=80;
            break;
		default :
			*p=t;
    }
    G_sp++;
}
void placevp(int np,int tok)
{
    int i;
    expr(); for (i=1;i<np;i++) { match(","); expr(); } placetok(tok,0);
}
void ptok(unsigned char *p)
{
    switch (*p) {
        case TCONSTANT : printf("%d " ,*((unsigned char *)(p+1))); break;
        case SCONSTANT : printf("%d " ,*((unsigned int *) (p+1))); break;
        case LCONSTANT : printf("%ld ",*((unsigned long *)(p+1))); break;
        case DCONSTANT : printf("%f " ,*((double *)       (p+1))); break;
        case CCONSTANT : printf("%s " ,  (unsigned char *)(p+1));  break;
        case TABLE     : printf("TABLE ");                         break;
        case ANAME     : printf("ACTION ");                        break;
        case STATNAME  : printf("STATNAME ");                      break;
        case EQUAL     : printf("= ");                             break;
        case LOGIC_AND : printf("&& ");                            break;
        case LOGIC_OR  : printf("|| ");                            break;
        case LOGIC_NOT : printf("! ");                             break;
        case LESSEQUAL : printf("<= ");                            break;
        case LESS      : printf("< ");                             break;
        case GREATEQUAL: printf(">= ");                            break;
        case GREAT     : printf("> ");                             break;
        case EQUALITY  : printf("== ");                            break;
        case NOTEQUAL  : printf("!= ");                            break;
        case PLUS      : printf("+ ");                             break;
        case MINUS     : printf("- ");                             break;
        case MULTIPLY  : printf("* ");                             break;
        case MODULUS   : printf("% ");                             break;
        case DEVIDE    : printf("/ ");                             break;
        case NEGATE    : printf("N ");                             break;
        case OCURLY    : printf("{ ");                             break;
        case CCURLY    : printf("} ");                             break;
        case FORMVAR   : printf("F ");                             break;
        case GLOBVAR   : printf("G ");                             break;
        case VARIABLE  : printf("V ");                             break;
        case ABS       : printf("ABS ");                           break;
        case ACOS      : printf("ACOS ");                          break;
        case ASIN      : printf("ASIN ");                          break;
        case ATAN      : printf("ATAN ");                          break;
        case COSH      : printf("COSH ");                          break;
        case COS       : printf("COS ");                           break;
        case EXP       : printf("EXP ");                           break;
        case LOG10     : printf("LOG10 ");                         break;
        case LOGAR     : printf("LOG ");                           break;
        case ROUND     : printf("ROUND ");                         break;
        case POW10     : printf("POW10 ");                         break;
        case SINH      : printf("SINH ");                          break;
        case SIN       : printf("SIN ");                           break;
        case SQRT      : printf("SQRT ");                          break;
        case SQR       : printf("SQR ");                           break;
        case TANH      : printf("TANH ");                          break;
        case TAN       : printf("TAN ");                           break;
        case TRUNC     : printf("TRUNC ");                         break;
        case GOTOXY    : printf("XY ");                            break;
        case MARKER    : printf("*** ");                           break;
        case WHILE     : printf("WH ");                            break;
        case IF        : printf("IF ");                            break;
        case ELSE      : printf("EL ");                            break;
        case SETFMVAR  : printf("@F ");                            break;
        case SETGLOBVR : printf("@G ");                            break;
        case SETVARIAB : printf("@V ");                            break;
        case SETCURITM : printf("@CF ");                           break;
        case ACTIONN   : printf("ACT ");                           break;
        case RANGE     : printf("<-> ");                           break;
        case RESULT    : printf("ð ");                             break;
        case LOOKUP    : printf("LOOK ");                          break;
        case USERVAR   : printf("UVAR ");                          break;
        case SETUSRVAR : printf("@UVAR ");                         break;
        case STATICS   : printf("STATIC ");                        break;
        case SETSTATIC : printf("@STATIC ");                       break;
        case LOOKTAB   : printf("INTAB ");                         break;
        case PASSEDVAL : printf("PASSED ");                        break;
        case LOGQNTY   : printf("LQ ");                            break;
        case LOGVALUE  : printf("LV ");                            break;
        case LOGNAME   : printf("LN ");                            break;
        case DATASTORE : printf("DS ");                            break;
        case DSNAME    : printf("FILE ");                          break;
        case SETDATAST : printf("@DS ");                           break;
        case ADDTOLOG  : printf("A2L ");                           break;
        case CURFIELD  : printf("CF ");                            break;
        case FORMNAME  : printf("FORM ");                          break;
        case UFUNC     : printf("USERFUNC ");                      break;
        case CFUNC     : printf("CFUNC ");                         break;
        case USING     : printf("USING ");                         break;
        case UPDATE    : printf("UPDATE ");                        break;
        case ACCESSL   : printf("ALEVEL ");                        break;
        case SJOIN     : printf("STR+ ");                          break;
        case SCUT      : printf("STRCUT ");                        break;
        case SEQU      : printf("STR== ");                         break;
        case SNEQU     : printf("STR!= ");                         break;
        case SLESS     : printf("STR< ");                          break;
        case SLEQU     : printf("STR<= ");                         break;
        case SGREAT    : printf("STR> ");                          break;
        case SGEQU     : printf("STR>= ");                         break;
        case SUPPER    : printf("SUPPER ");                        break;
        case SLOWER    : printf("SLOWER ");                        break;
		case HOTKEY	   : printf("HOTKEY ");                        break;
		case PICKKEY   : printf("PICKKEY ");                       break;
		case PSHKEY	   : printf("PSHKEY ");                        break;
		case SAVESCR   : printf("SAVESCR ");                       break;
		case XTIMER	   : printf("XTIMER ");                        break;
		case SWAPTO    : printf("SWAPTO");                         break;
		case SETDEV	   : printf("SETDEV ");                        break;
		case SAVEDEV   : printf("SAVEDEV ");                       break;
		case RESTDEV   : printf("RESTDEV ");                       break;
        case DATESTR   : printf("DATE ");                          break;
        case FMTMATCH  : printf("FMTMATCH ");                      break;
        case INRANGE   : printf("INRANGE ");                       break;
        case NMONTHS   : printf("NMONTHS ");                       break;
        case GETYEAR   : printf("GETYEAR ");                       break;
        case NDAYS     : printf("NDAYS ");                         break;
        case DUEDOM    : printf("DUEDOM  ");                       break;
        case DUEHALF   : printf("DUEHALF ");                       break;
        case GETPROD   : printf("GETPROD ");                       break;
        case ERRLINE   : printf("ERRLINE ");                       break;
        case WHERE     : printf("WHERE ");                         break;
        case COPYREC   : printf("COPYREC ");                       break;
        case DUPDSFMT  : printf("DUPDSFMT ");                      break;
        case REMDSFMT  : printf("REMDSFMT ");                      break;
        case RUNFORM   : printf("RUNFORM ");                       break;
        case STSRCH    : printf("STSRCH ");                        break;
        case STSRCHP   : printf("STSRCHP ");                       break;
        case STREAD    : printf("STREAD  ");                       break;
        case STWRITE   : printf("STWRITE ");                       break;
        case STDELREC  : printf("STDELREC ");                      break;
        case RUN       : printf("RUN ");                           break;
        case STEMPTY   : printf("STEMPTY ");                       break;
        case CREC      : printf("CREC ");                          break;
        case NREC      : printf("NREC ");                          break;
        case PREC      : printf("PREC ");                          break;
        case FREC      : printf("FREC ");                          break;
        case LREC      : printf("LREC ");                          break;
        case CLREC     : printf("CLREC ");                         break;
        case TOTALBOX  : printf("TOTALBOX ");                      break;
        case PRLINE    : printf("PRLINE ");                        break;
        case PREOL     : printf("PREOL ");                         break;
        case PREOF     : printf("PREOF ");                         break;
        case JUMPTO    : printf("JUMPTO ");                        break;
        case MOVETCUR  : printf("MOVETCUR ");                      break;
        default        : printf("Error Unknown Instruction %d ",*p);
    }
}    
void pstack(void)
{
    unsigned char *s,*p;
    p=G_tokspace;
    while (p<(&G_tokspace[G_sp])) {
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
            case TABLE     : printf("\n");                break;
            case ANAME     : printf("\n");                break;
            case STATNAME  : printf("\n");                break;
        }
        ptok(s);
    }
}
long statadd(char *name)
{
	int i;
	static char tmp[81];
	memset(tmp,32,81);
	for (i=0;i<G_numstat;i++) {
		if (!strcmp(name,G_statbuf[i].n)) {
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
    } else {
    	expr();

    	for (;;) {
        	if (match("=")) {
            	if       (G_tokspace[G_sp-1]==FORMVAR  ) G_tokspace[G_sp-1]=SETFMVAR;
            	else  if (G_tokspace[G_sp-1]==VARIABLE ) G_tokspace[G_sp-1]=SETVARIAB;
            	else  if (G_tokspace[G_sp-1]==DATASTORE) G_tokspace[G_sp-1]=SETDATAST;
            	else  if (G_tokspace[G_sp-1]==CURFIELD ) G_tokspace[G_sp-1]=SETCURITM;
            	else  if (G_tokspace[G_sp-1]==USERVAR  ) G_tokspace[G_sp-1]=SETUSRVAR;
            	else  if (G_tokspace[G_sp-1]==STATICS  ) G_tokspace[G_sp-1]=SETSTATIC;
            	else  if (G_tokspace[G_sp-1]==GLOBVAR  ) G_tokspace[G_sp-1]=SETGLOBVR;
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
    else if (match( "ERRLINE("  )) placevp(2,ERRLINE); 
    else if (match( "COPYREC("  )) placevp(2,COPYREC); 
    else if (match( "DUPDSFMT(" )) placevp(2,DUPDSFMT);
    else if (match( "REMDSFMT(" )) placevp(1,REMDSFMT); 
    else if (match( "STSRCH("   )) { G_instsrch=1; placevp(2,STSRCH); G_instsrch=0; }
    else if (match( "STSRCHP("  )) placevp(3,STSRCHP); 
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
    else if (match( "PREOL("    )) placetok(PREOL,0);
    else if (match( "PREOF("    )) placetok(PREOF,0);
    else if (match( "STEMPTY("  )) placevp(1,STEMPTY);
    else if (match( "STDELREC(" )) placevp(1,STDELREC);
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
    if      (match("PI"))  placetok(DCONSTANT,M_PI);
    else if (match("YES")) placetok(CCONSTANT,(long)"GYES");
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
    char tmp[100];
    int i,fd;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		printf("Can't Open Output File %s\n",tmp);
		return;
	}
    write(fd,&G_numan,sizeof(int));
    for (i=0;i<G_numan;i++) {
        write(fd,&G_actnbuf[i].d,sizeof(char));
        write(fd,&G_actnbuf[i].t,sizeof(char));
        write(fd,&G_actnbuf[i].o,sizeof(int));
        write(fd,G_actnbuf[i].n,9);
    }
    write(fd,&G_sp,sizeof(int));
    write(fd,G_tokspace,G_sp);
    close(fd);
}
void inputstats(void)
{
    char tmp[100];
    int i,fd;
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);
    fd=open(tmp,O_RDONLY|O_BINARY);
	if (fd==(-1)) return;
    read(fd,&G_numan,sizeof(int));
    for (i=0;i<G_numan;i++) {
        read(fd,&(G_actnbuf[i].d),sizeof(char));
        read(fd,&(G_actnbuf[i].t),sizeof(char));
        read(fd,&(G_actnbuf[i].o),sizeof(int));
        read(fd,tmp,9);
		G_actnbuf[i].n=strdup(tmp);
    }
    read(fd,&G_sp,sizeof(int));
    read(fd,G_tokspace,G_sp);
    close(fd);
	G_numstat=0;
    for (i=0;i<G_numan;i++) {
		if (G_actnbuf[i].t==STATNAME) G_numstat++;
	}
	G_statbuf=MALLOC(G_numstat*sizeof(NAMEIDX));
	G_numstat=0;
	if (G_statbuf==NULL) return;
    for (i=0;i<G_numan;i++) {
		if (G_actnbuf[i].t==STATNAME) {
			G_statbuf[G_numstat].n=G_actnbuf[i].n;
			G_statval[G_numstat]=MALLOC(81);
			if (G_statval[G_numstat]!=NULL) {
				memcpy(G_statval[G_numstat++],&(G_tokspace[G_actnbuf[i].o+1]),80);
			}
		}
	}
	G_sp=0;
	G_numan=0;
	memset(G_tokspace,0,MAXSPACE);
	memset(G_actnbuf,0,MAXNAME*sizeof(NAMEIDX));
}
int _cdecl main(int argc,char *argv[])
{
    FILE *fp;
	int i;
    char tmp[100];

	memset(G_emptystr,32,80);
	G_emptystr[79]=0;
 	G_tokspace=MALLOC(MAXSPACE);
	if (G_tokspace==NULL) {
		printf("Not enough memory\n");
		RETURNV(0);
	}
 	G_actnbuf=MALLOC(MAXNAME*sizeof(NAMEIDX));
	if (G_actnbuf==NULL) {
		printf("Not enough memory\n");
		RETURNV(0);
	}
    if (argc<2) readconfig("GPA"); else readconfig(argv[1]);

    if (!loadsdata(G_system)) {
        printf("Can't load store data for %s\n",G_system);
        return(1);
    }
    if (!loadtext(G_system)) {
        printf("Can't load text for %s\n",G_system);
        return(2);
    }
	inputstats();

    sprintf(tmp,"%s%sR.DAT",G_config,G_system);
    printf("Unisys Action Pre-Parser  Version 1.0 - Copyright (c) 1993 Unisys Ltd.\r\n%s:\r\n",tmp);
	G_lnum=0;
	if ((G_fp=fopen(tmp,"r"))!=NULL) {
        while (getline()) while ((G_str)&&(*G_str)) oper();
    }
    fclose(fp);
    if (G_open) error("missing }");
    textattr(0x07);
    if (G_nume) {
        printf("\r\n%d Error%c found in %s\r\n",G_nume,((G_nume!=1)?'s':' '),tmp);
		printf("\r\nOutput file not generated\r\n");
    } else {
       	printf("No Errors found in %s\r\n",tmp);
    	sprintf(tmp,"%s%sA.DAT",G_config,G_system);
	    printf("%s:\r\n",tmp);
		G_lnum=0;
    	if ((G_fp=fopen(tmp,"r"))!=NULL) {
        	while (getline()) while ((G_str)&&(*G_str)) oper();
    	}
    	fclose(fp);

    	if (G_open) error("missing }");
    	textattr(0x07);
    	if (G_nume) {
        	printf("\r\n%d Error%c found in %s\r\n",G_nume,((G_nume!=1)?'s':' '),tmp);
    	} else {
        	printf("No Errors found in %s\r\n",tmp);
    	}
	    outputtoks();
    }
    if (argc==3) {
		pstack();
	    for (i=0;i<G_numan;i++) {
			printf("%c %c %d %s\n",
				G_actnbuf[i].d,
				G_actnbuf[i].t,
				G_actnbuf[i].o,
				G_actnbuf[i].n);
	    }
		printf("G_sp=%d\n",G_sp);
//		printf("G_numstat=%d\n",G_numstat);
//		for (i=0;i<G_numstat;i++) {
//			printf("Static %s %s\n",G_statbuf[i].n,G_statval[i]);
//		}
		cleanupblks(1);
	} else {
		cleanupblks(0);
	}
    return(0);
}

