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
//************************************************************
//F push
//S Push a number or string on to the stack
//P type, number or string
//P value
void  push(CHAR type,NUMB v)
{
	ENTRY(1990);
    if (G_nstk>=MAXSTACK) RETURN;

    *(G_stackt++)=type;
    switch (type) {
        case 'n' :
            *((NUMB *)G_stack[G_nstk++])=v;
            break;
        case 's':
            if (v) {
                strcpy(G_stack[G_nstk++],(CHAR*)v);
            } else {
                G_stack[G_nstk++][0]=0;
            }
            break;
    }
	RETURN;
}
//************************************************************
//F pop
//S Pop a number or string from the stack
//P address to place returned value
CHAR  pop(void *var)
{
    CHAR type;
	ENTRY(2000);
    if (!G_nstk) RETURNV(0);
    G_nstk--;
    switch (type=*(--G_stackt)) {
        case 'n' :
            *((NUMB *)var)=*((NUMB *)G_stack[G_nstk]);
            break;
        case 's' :
            if (G_stack[G_nstk]) {
                strcpy(((CHAR *)var),(CHAR *)G_stack[G_nstk]);
            } else {
                if (var) *((CHAR *)var)=0;
            }
            break;
    }
    RETURNV(type);
}
//************************************************************
//F stktype
//S Return the type on the n'th item on the stack
//P place on stack
CHAR  stktype(INT place)
{
	ENTRY(2010);
    if (place>=G_nstk) RETURNV(0);
    place++;
    RETURNV(*(G_stackt-place));
}
//************************************************************
//F stknum
//S Return the n'th item on the stack as a number
//P place on stack
//P address to place returned number
CHAR  stknum(INT place,NUMB *n)
{
    CHAR t;
	ENTRY(2020);
    switch (t=stktype(place)) {
        case 'n' :
            *n=*((NUMB *)G_stack[G_nstk-(place+1)]);
            break;
        case 's' :
            *n=ATON(G_stack[G_nstk-(place+1)]);
            break;
    }
    RETURNV(t);
}
//************************************************************
//F stkstr
//S Return the n'th item on the stack as a string
//P place on stack
//P address to place returned string
CHAR  stkstr(INT place,CHAR *s)
{
    CHAR t;
	ENTRY(2030);
    switch (t=stktype(place)) {
        case 's' :
            strcpy(s,G_stack[G_nstk-(place+1)]);
            break;
        case 'n' :
            NTOA(s,*((NUMB *)G_stack[G_nstk-(place+1)]));
            break;
    }
    RETURNV(t);
}
//************************************************************
//F stksize
//S Return the current size of the stack 
INT  stksize(void)
{
	ENTRY(2040);
    RETURNV(G_nstk);
}
//************************************************************
//F popl
//S Return the top item on the stack as a LONG
LONG  popl(void)
{
	ENTRY(2050);
    getnum();
    RETURNV((LONG)G_n1);
}
//************************************************************
//F get2strs
//S get the top two items on the stack as strings in to vars
void  get2strs(void)
{
    char t1,t0;
	ENTRY(2060);
    t1=stktype(1);
    if (!t1) RETURN;
    t0=stktype(0);
    if (t0==t1) {
        if (t0=='n') {
            POP(&G_n2);
            NTOA(G_s2,G_n2);
            POP(&G_n1);
            NTOA(G_s1,G_n1);
        } else {
            POP(&G_s2);
            POP(&G_s1);
        }
    } else {
        if (t0=='s') {
            POP(&G_s2);
            POP(&G_n1);
            NTOA(G_s1,G_n1);
        } else {
            POP(&G_n2);
            NTOA(G_s2,G_n2);
            POP(&G_s1);
        }
    }
	RETURN;
}
//************************************************************
//F get2nums
//S get the top two items on the stack as numbers in to vars
void  get2nums(void)
{
    char t1,t0;
	ENTRY(2070);
    t1=stktype(1);
    if (!t1) RETURN;
    t0=stktype(0);

    if (t0==t1) {
        if (t0=='n') {
            POP(&G_n2);
            POP(&G_n1);
        } else {
            POP(&G_s2);
            G_n2=ATON(G_s2);
            POP(&G_s1);
            G_n1=ATON(G_s1);
        }
    } else {
        if (t0=='s') {
            POP(&G_s2);
            G_n2=ATON(G_s2);
            POP(&G_n1);
        } else {
            POP(&G_n2);
            POP(&G_s1);
            G_n1=ATON(G_s1);
        }
    }
	RETURN;
}
//************************************************************
//F getnum
//S get the top item on the stack as a number in to var
void getnum(void)
{
    char t;
	ENTRY(2080);
    t=stktype(0);
    if (!t) RETURN;

    if (t=='n') {
        POP(&G_n1);
    } else {
        POP(&G_s1);
        G_n1=ATON(G_s1);
    }
	RETURN;
}
//************************************************************
//F pops
//S Return the top item on the stack as a string
CHAR *pops(void)
{
	ENTRY(2090);
    getstr();
    RETURNV(G_s1);
}
//************************************************************
//F getstr
//S get the top item on the stack as a string in to var
void getstr(void)
{
    char t;
	ENTRY(2100);
    t=stktype(0);
    if (!t) RETURN;

    if (t=='n') {
        POP(&G_n1);
        NTOA(G_s1,G_n1);
    } else {
        POP(&G_s1);
    }
	RETURN;
}
//************************************************************
//F add
//S push pop+pop
void  add(void)
{
	ENTRY(2110);
    get2nums();
    PUSHN((G_n1+G_n2));
	RETURN;
}
//************************************************************
//F sub
//S push pop-pop
void sub(void)
{
	ENTRY(2120);
    get2nums();
    PUSHN((G_n1-G_n2));
	RETURN;
}
//************************************************************
//F mul
//S push pop*pop
void  mul(void)
{
	ENTRY(2130);
    get2nums();
    PUSHN((G_n1*G_n2));
	RETURN;
}
//************************************************************
//F divide
//S push pop/pop
void  divide(void)
{
	ENTRY(2140);
    get2nums();
    if (G_n2)
        PUSHN((G_n1/G_n2));
    else
        PUSHN(0);
	RETURN;
}
//************************************************************
//F mod
//S push pop%pop
void  mod(void)
{
	ENTRY(2150);
    get2nums();
    if (G_n2)
        PUSHN(((LONG)G_n1%(LONG)G_n2));
    else
        PUSHN(0);
	RETURN;
}
//************************************************************
//F land
//S push pop&&pop
void  land(void)
{
	ENTRY(2160);
    get2nums();
    PUSHN((G_n1&&G_n2));
	RETURN;
}
//************************************************************
//F lor
//S push pop||pop
void  lor(void)
{
	ENTRY(2170);
    get2nums();
    PUSHN((G_n1||G_n2));
	RETURN;
}
//************************************************************
//F lxor
//S push pop^pop!=0
void  lxor(void)
{
	ENTRY(2180);
    get2nums();
    PUSHN((((LONG)G_n1^(LONG)G_n2)!=0));
	RETURN;
}
//************************************************************
//F lnot
//S push !pop
void  lnot(void)
{
	ENTRY(2190);
    getnum();
    PUSHN((!G_n1));
	RETURN;
}
//************************************************************
//F equal
//S push pop==pop
void  equal(void)
{
	ENTRY(2200);
    get2nums();
    PUSHN((G_n1==G_n2));
	RETURN;
}
//************************************************************
//F notequal
//S push pop!=pop
void  notequal(void)
{
	ENTRY(2210);
    get2nums();
    PUSHN((G_n1!=G_n2));
	RETURN;
}
//************************************************************
//F less
//S push pop<pop
void  less(void)
{
	ENTRY(2220);
    get2nums();
    PUSHN((G_n1<G_n2));
	RETURN;
}
//************************************************************
//F lessequal
//S push pop<=pop
void  lessequal(void)
{
	ENTRY(2230);
    get2nums();
    PUSHN((G_n1<=G_n2));
	RETURN;
}
//************************************************************
//F great
//S push pop>pop
void  great(void)
{
	ENTRY(2240);
    get2nums();
    PUSHN((G_n1>G_n2));
	RETURN;
}
//************************************************************
//F greatequal
//S push pop>=pop
void  greatequal(void)
{
	ENTRY(2250);
    get2nums();
    PUSHN((G_n1>=G_n2));
	RETURN;
}
//************************************************************
//F not
//S push ~pop
void  not(void)
{
	ENTRY(2260);
    getnum();
    PUSHN((~(LONG)G_n1));
	RETURN;
}
//************************************************************
//F neg
//S push -pop
void  neg(void)
{
	ENTRY(2270);
    getnum();
    PUSHN((-G_n1));
	RETURN;
}
//************************************************************
//F sequal
//S push pop==pop
void  sequal(void)
{
	ENTRY(2280);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)==0));
	RETURN;
}
//************************************************************
//F snotequal
//S push pop!=pop
void  snotequal(void)
{
	ENTRY(2290);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)!=0));
	RETURN;
}
//************************************************************
//F sless
//S push pop<pop
void  sless(void)
{
	ENTRY(2300);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)<0));
	RETURN;
}
//************************************************************
//F slessequal
//S push pop<=pop
void  slessequal(void)
{
	ENTRY(2310);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)<=0));
	RETURN;
}
//************************************************************
//F sgreat
//S push pop>pop
void  sgreat(void)
{
	ENTRY(2320);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)>0));
	RETURN;
}
//************************************************************
//F sgreatequal
//S push pop>=pop
void  sgreatequal(void)
{
	ENTRY(2330);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)>=0));
	RETURN;
}
//************************************************************
//F sjoin
//S push pop++pop
void  sjoin(void)
{
    CHAR tmp[MAXSTRLEN*2];
	ENTRY(2340);
    get2strs();
    strcpy(tmp,G_s1);
    strcat(tmp,G_s2);
    PUSHS(tmp);
	RETURN;
}
//************************************************************
//F scut
//S push pop from pop to pop
void  scut(void)
{
	ENTRY(2350);
    get2nums();
    if (G_n1>G_n2) { G_n0=G_n1; G_n1=G_n2; G_n2=G_n0; }
    if (G_n2>=MAXSTRLEN) G_n2=MAXSTRLEN-1;

    getstr();
    G_s1[(INT)(G_n2)+1]=0;
    PUSHS(&G_s1[(INT)(G_n1)]);
	RETURN;
}
//************************************************************
//F arithend
//S If anything is left on the stack pop it and print it 
void arithend(void)
{
	ENTRY(2360);
 	while (G_nstk) {
		getstr();
		printf("%s",G_s1);
	}
	RETURN;
}
//************************************************************
// End of File - ARITH.C

