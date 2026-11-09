#define ARITH_C

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <malloc.h>
#include <memory.h>

#include "types.h"
#include "control.h"
#include "arith.h"
// Push a number or string on to the stack
void push(CHAR type,...)
{
    va_list ap;
	ENTRY(1990);
    if (G_nstk>=MAXSTACK) RETURN;

    G_stack[G_nstk]=MALLOC(sizeof(STACK));
    if (G_stack[G_nstk]==NULL) RETURN;

    va_start(ap,type);
    G_stack[G_nstk]->t=type;
    switch (type) {
        case 'n' :
            G_stack[G_nstk]->u.n=va_arg(ap,NUMB);
            break;
        case 's' :
            strncpy(G_stack[G_nstk]->u.s,va_arg(ap,CHAR *),MAXSTRLEN-1);
            break;
        default :
            FREE(G_stack[G_nstk]);
            G_nstk--;
    }
    G_nstk++;
    va_end(ap);
	RETURN;
}
// Pop a number or string from the stack
CHAR pop(void *var)
{
    static STACK ss;
	ENTRY(2000);
    if (!G_nstk) RETURNV(0);
    G_nstk--;
    memcpy(&ss,G_stack[G_nstk],sizeof(STACK));
    FREE(G_stack[G_nstk]);
    switch (ss.t) {
        case 'n' :
            *((NUMB *)var)=ss.u.n;
            break;
        case 's' :
            strcpy(((CHAR *)var),ss.u.s);
            break;
    }
    RETURNV(ss.t);
}
// Return the type on the n'th item on the stack
CHAR stktype(INT place)
{
	ENTRY(2010);
    if (place>=G_nstk) RETURNV(0);
    RETURNV(G_stack[G_nstk-(place+1)]->t);
}
// Return the n'th item on the stack as a number
CHAR stknum(INT place,NUMB *n)
{
    INT t;
	ENTRY(2020);
    if (place>=G_nstk) RETURNV(0);
    t=G_stack[G_nstk-(place+1)]->t;
    if (t=='n')
        *n=G_stack[G_nstk-(place+1)]->u.n;
    else
        *n=ATON(G_stack[G_nstk-(place+1)]->u.s);
    RETURNV(t);
}
// Return the n'th item on the stack as a string
CHAR stkstr(INT place,CHAR *s)
{
    INT t;
	ENTRY(2030);
    if (place>=G_nstk) RETURNV(0);
    t=G_stack[G_nstk-(place+1)]->t;
    if (t=='s')
        strcpy(s,G_stack[G_nstk-(place+1)]->u.s);
    else
        NTOA(s,G_stack[G_nstk-(place+1)]->u.n);
    RETURNV(t);
}
// Return the current size of the stack 
INT stksize(void)
{
	ENTRY(2040);
    RETURNV(G_nstk);
}
// Return the top item on the stack as a LONG
LONG popl(void)
{
	ENTRY(2050);
    getnum();
    RETURNV((LONG)G_n[1]);
}
// get the top two items on the stack as strings in to vars
void get2strs(void)
{
	ENTRY(2060);
    if (!stktype(1)) RETURN;

    if (stktype(0)==stktype(1)) {
        if (stktype(0)=='n') {
            POP(&G_n[2]);
            NTOA(G_s[2],G_n[2]);
            POP(&G_n[1]);
            NTOA(G_s[1],G_n[1]);
        } else {
            POP(&G_s[2]);
            POP(&G_s[1]);
        }
    } else {
        if (stktype(0)=='s') {
            POP(&G_s[2]);
            POP(&G_n[1]);
            NTOA(G_s[1],G_n[1]);
        } else {
            POP(&G_n[2]);
            NTOA(G_s[2],G_n[2]);
            POP(&G_s[1]);
        }
    }
	RETURN;
}
// get the top two items on the stack as numbers in to vars
void get2nums(void)
{
	ENTRY(2070);
    if (!stktype(1)) RETURN;

    if (stktype(0)==stktype(1)) {
        if (stktype(0)=='n') {
            POP(&G_n[2]);
            POP(&G_n[1]);
        } else {
            POP(&G_s[2]);
            G_n[2]=ATON(G_s[2]);
            POP(&G_s[1]);
            G_n[1]=ATON(G_s[1]);
        }
    } else {
        if (stktype(0)=='s') {
            POP(&G_s[2]);
            G_n[2]=ATON(G_s[2]);
            POP(&G_n[1]);
        } else {
            POP(&G_n[2]);
            POP(&G_s[1]);
            G_n[1]=ATON(G_s[1]);
        }
    }
	RETURN;
}
// get the top item on the stack as a number in to var
void getnum(void)
{
	ENTRY(2080);
    if (!stktype(0)) RETURN;

    if (stktype(0)=='n') {
        POP(&G_n[1]);
    } else {
        POP(&G_s[1]);
        G_n[1]=ATON(G_s[1]);
    }
	RETURN;
}
// Return the top item on the stack as a string
CHAR *pops(void)
{
	ENTRY(2090);
    getstr();
    RETURNV(G_s[1]);
}
// get the top item on the stack as a string in to var
void getstr(void)
{
	ENTRY(2100);
    if (!stktype(0)) RETURN;

    if (stktype(0)=='n') {
        POP(&G_n[1]);
        NTOA(G_s[1],G_n[1]);
    } else {
        POP(&G_s[1]);
    }
	RETURN;
}
// push pop+pop
void add(void)
{
	ENTRY(2110);
    get2nums();
    PUSHN((G_n[1]+G_n[2]));
	RETURN;
}
// push pop-pop
void sub(void)
{
	ENTRY(2120);
    get2nums();
    PUSHN((G_n[1]-G_n[2]));
	RETURN;
}
// push pop*pop
void mul(void)
{
	ENTRY(2130);
    get2nums();
    PUSHN((G_n[1]*G_n[2]));
	RETURN;
}
// push pop/pop
void divide(void)
{
	ENTRY(2140);
    get2nums();
    if (G_n[2])
        PUSHN((G_n[1]/G_n[2]));
    else
        PUSHN(0);
	RETURN;
}
// push pop%pop
void mod(void)
{
	ENTRY(2150);
    get2nums();
    if (G_n[2])
        PUSHN(((LONG)G_n[1]%(LONG)G_n[2]));
    else
        PUSHN(0);
	RETURN;
}
// push pop&&pop
void land(void)
{
	ENTRY(2160);
    get2nums();
    PUSHN((G_n[1]&&G_n[2]));
	RETURN;
}
// push pop||pop
void lor(void)
{
	ENTRY(2170);
    get2nums();
    PUSHN((G_n[1]||G_n[2]));
	RETURN;
}
// push pop^pop!=0
void lxor(void)
{
	ENTRY(2180);
    get2nums();
    PUSHN((((LONG)G_n[1]^(LONG)G_n[2])!=0));
	RETURN;
}
// push !pop
void lnot(void)
{
	ENTRY(2190);
    getnum();
    PUSHN((!G_n[1]));
	RETURN;
}
// push pop==pop
void equal(void)
{
	ENTRY(2200);
    get2nums();
    PUSHN((G_n[1]==G_n[2]));
	RETURN;
}
// push pop!=pop
void notequal(void)
{
	ENTRY(2210);
    get2nums();
    PUSHN((G_n[1]!=G_n[2]));
	RETURN;
}
// push pop<pop
void less(void)
{
	ENTRY(2220);
    get2nums();
    PUSHN((G_n[1]<G_n[2]));
	RETURN;
}
// push pop<=pop
void lessequal(void)
{
	ENTRY(2230);
    get2nums();
    PUSHN((G_n[1]<=G_n[2]));
	RETURN;
}
// push pop>pop
void great(void)
{
	ENTRY(2240);
    get2nums();
    PUSHN((G_n[1]>G_n[2]));
	RETURN;
}
// push pop>=pop
void greatequal(void)
{
	ENTRY(2250);
    get2nums();
    PUSHN((G_n[1]>=G_n[2]));
	RETURN;
}
// push ~pop
void not(void)
{
	ENTRY(2260);
    getnum();
    PUSHN((~(LONG)G_n[1]));
	RETURN;
}
// push -pop
void neg(void)
{
	ENTRY(2270);
    getnum();
    PUSHN((-G_n[1]));
	RETURN;
}
// push pop==pop
void sequal(void)
{
	ENTRY(2280);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])==0));
	RETURN;
}
// push pop!=pop
void snotequal(void)
{
	ENTRY(2290);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])!=0));
	RETURN;
}
// push pop<pop
void sless(void)
{
	ENTRY(2300);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])<0));
	RETURN;
}
// push pop<=pop
void slessequal(void)
{
	ENTRY(2310);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])<=0));
	RETURN;
}
// push pop>pop
void sgreat(void)
{
	ENTRY(2320);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])>0));
	RETURN;
}
// push pop>=pop
void sgreatequal(void)
{
	ENTRY(2330);
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])>=0));
	RETURN;
}
// push pop++pop
void sjoin(void)
{
    CHAR tmp[MAXSTRLEN*2];
	ENTRY(2340);
    get2strs();
    strcpy(tmp,G_s[1]);
    strcat(tmp,G_s[2]);
    PUSHS(tmp);
	RETURN;
}
// push pop from pop to pop
void scut(void)
{
	ENTRY(2350);
    get2nums();
    if (G_n[1]>G_n[2]) { G_n[0]=G_n[1]; G_n[1]=G_n[2]; G_n[2]=G_n[0]; }
    if (G_n[2]>=MAXSTRLEN) G_n[2]=MAXSTRLEN-1;

    getstr();
    G_s[1][(INT)(G_n[2])+1]=0;
    PUSHS(&G_s[1][(INT)(G_n[1])]);
	RETURN;
}
void arithend(void)
{
	ENTRY(2360);
 	while (G_nstk) {
		getstr();
		printf("%s",G_s[1]);
	}
	RETURN;
}

