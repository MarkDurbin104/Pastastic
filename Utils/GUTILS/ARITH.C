#define ARITH_C

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <alloc.h>
#include <mem.h>

#include "arith.h"
// Push a number or string on to the stack
void push(char type,...)
{
    va_list ap;

    if (G_nstk>=MAXSTACK) return;

    G_stack[G_nstk]=malloc(sizeof(STACK));
    if (G_stack[G_nstk]==NULL) return;

    va_start(ap,type);
    G_stack[G_nstk]->t=type;
    switch (type) {
        case 'n' :
            G_stack[G_nstk]->u.n=va_arg(ap,NUMB);
            break;
        case 's' :
            strncpy(G_stack[G_nstk]->u.s,va_arg(ap,char *),MAXSTRLEN-1);
            break;
        default :
            free(G_stack[G_nstk]);
            G_nstk--;
    }
    G_nstk++;
    va_end(ap);
}
// Pop a number or string from the stack
char pop(void *var)
{
    static STACK ss;
    if (!G_nstk) return(0);
    G_nstk--;
    memcpy(&ss,G_stack[G_nstk],sizeof(STACK));
    free(G_stack[G_nstk]);
    switch (ss.t) {
        case 'n' :
            *((NUMB *)var)=ss.u.n;
            break;
        case 's' :
            strcpy(((char *)var),ss.u.s);
            break;
    }
    return(ss.t);
}
// Return the type on the n'th item on the stack
char stktype(int place)
{
    if (place>=G_nstk) return(0);
    return(G_stack[G_nstk-(place+1)]->t);
}
// Return the n'th item on the stack as a number
char stknum(int place,NUMB *n)
{
    int t;
    if (place>=G_nstk) return(0);
    t=G_stack[G_nstk-(place+1)]->t;
    if (t=='n')
        *n=G_stack[G_nstk-(place+1)]->u.n;
    else
        *n=ATON(G_stack[G_nstk-(place+1)]->u.s);
    return(t);
}
// Return the n'th item on the stack as a string
char stkstr(int place,char *s)
{
    int t;
    if (place>=G_nstk) return(0);
    t=G_stack[G_nstk-(place+1)]->t;
    if (t=='s')
        strcpy(s,G_stack[G_nstk-(place+1)]->u.s);
    else
        NTOA(s,G_stack[G_nstk-(place+1)]->u.n);
    return(t);
}
// Return the current size of the stack 
int stksize(void)
{
    return(G_nstk);
}
// Return the top item on the stack as a long
long popl(void)
{
    getnum();
    return((long)G_n[1]);
}
// get the top two items on the stack as strings in to vars
void get2strs(void)
{
    if (!stktype(1)) return;

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
}
// get the top two items on the stack as numbers in to vars
void get2nums(void)
{
    if (!stktype(1)) return;

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
}
// get the top item on the stack as a number in to var
void getnum(void)
{
    if (!stktype(0)) return;

    if (stktype(0)=='n') {
        POP(&G_n[1]);
    } else {
        POP(&G_s[1]);
        G_n[1]=ATON(G_s[1]);
    }
}
// Return the top item on the stack as a string
char *pops(void)
{
    getstr();
    return(G_s[1]);
}
// get the top item on the stack as a string in to var
void getstr(void)
{
    if (!stktype(0)) return;

    if (stktype(0)=='n') {
        POP(&G_n[1]);
        NTOA(G_s[1],G_n[1]);
    } else {
        POP(&G_s[1]);
    }
}
// push pop+pop
void add(void)
{
    get2nums();
    PUSHN((G_n[1]+G_n[2]));
}
// push pop-pop
void sub(void)
{
    get2nums();
    PUSHN((G_n[1]-G_n[2]));
}
// push pop*pop
void mul(void)
{
    get2nums();
    PUSHN((G_n[1]*G_n[2]));
}
// push pop/pop
void divide(void)
{
    get2nums();
    if (G_n[2])
        PUSHN((G_n[1]/G_n[2]));
    else
        PUSHN(0);
}
// push pop%pop
void mod(void)
{
    get2nums();
    if (G_n[2])
        PUSHN(((long)G_n[1]%(long)G_n[2]));
    else
        PUSHN(0);
}
// push pop&&pop
void land(void)
{
    get2nums();
    PUSHN((G_n[1]&&G_n[2]));
}
// push pop||pop
void lor(void)
{
    get2nums();
    PUSHN((G_n[1]||G_n[2]));
}
// push pop^pop!=0
void lxor(void)
{
    get2nums();
    PUSHN((((long)G_n[1]^(long)G_n[2])!=0));
}
// push !pop
void lnot(void)
{
    getnum();
    PUSHN((!G_n[1]));
}
// push pop==pop
void equal(void)
{
    get2nums();
    PUSHN((G_n[1]==G_n[2]));
}
// push pop!=pop
void notequal(void)
{
    get2nums();
    PUSHN((G_n[1]!=G_n[2]));
}
// push pop<pop
void less(void)
{
    get2nums();
    PUSHN((G_n[1]<G_n[2]));
}
// push pop<=pop
void lessequal(void)
{
    get2nums();
    PUSHN((G_n[1]<=G_n[2]));
}
// push pop>pop
void great(void)
{
    get2nums();
    PUSHN((G_n[1]>G_n[2]));
}
// push pop>=pop
void greatequal(void)
{
    get2nums();
    PUSHN((G_n[1]>=G_n[2]));
}
// push ~pop
void not(void)
{
    getnum();
    PUSHN((~(long)G_n[1]));
}
// push -pop
void neg(void)
{
    getnum();
    PUSHN((-G_n[1]));
}
// push pop==pop
void sequal(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])==0));
}
// push pop!=pop
void snotequal(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])!=0));
}
// push pop<pop
void sless(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])<0));
}
// push pop<=pop
void slessequal(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])<=0));
}
// push pop>pop
void sgreat(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])>0));
}
// push pop>=pop
void sgreatequal(void)
{
    get2strs();
    PUSHN((strcmp(G_s[1],G_s[2])>=0));
}
// push pop++pop
void sjoin(void)
{
    char tmp[MAXSTRLEN*2];
    get2strs();
    strcpy(tmp,G_s[1]);
    strcat(tmp,G_s[2]);
    PUSHS(tmp);
}
// push pop from pop to pop
void scut(void)
{
    get2nums();
    if (G_n[1]>G_n[2]) { G_n[0]=G_n[1]; G_n[1]=G_n[2]; G_n[2]=G_n[0]; }
    if (G_n[2]>=MAXSTRLEN) G_n[2]=MAXSTRLEN-1;

    getstr();
    G_s[1][G_n[2]+1]=0;
    PUSHS(&G_s[1][G_n[1]]);
}
