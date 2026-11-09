/****************************************************************************
* Project     : GPA
* File        : arith.c
* Description : Functions related to arithmetic and stack control
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:52  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/arith.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:52   JGRAY
*  
* 
****************************************************************************/
#define ARITH_C

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <malloc.h>
#include <memory.h>

#include "gpasizes.h"
#include "types.h"
#include "control.h"
#include "arith.h"

//************************************************************
//S Push a number or string on to the stack
//D N.B. If the stack is already full just does nothing! :JGQ 23/10
//D N.B. If the string supplied is more than 81 char (incl delim) blows out. :JGQ 23/10
//P type, number or string
//P (numb==long) value or char *

void  push(CHAR type, NUMB v)
{
	ENTRY(1990);
    if (G_nstk>=MAXSTACK)
        RETURN;

    *(G_stackt++)=type;
    switch (type)
        {
        case 'n' :
            *((NUMB *)G_stack[G_nstk++])=v;
            break;
        case 's':
            if (v)
                {
                strcpy(G_stack[G_nstk++],(CHAR*)v);
                }
            else
                {
                G_stack[G_nstk++][0]=0;
                }
            break;
    }
	RETURN;
}

//************************************************************
//S Pop a number or string from the stack to our private location
//P address to place returned value
//R char type of item being returned or null (0)  on empty stack

CHAR  pop(void *var)
{
    CHAR type;
	ENTRY(2000);
    if (!G_nstk)
        RETURNV(0);
    G_nstk--;
    switch (type=*(--G_stackt))
        {
        case 'n' :
            *((NUMB *)var)=*((NUMB *)G_stack[G_nstk]);
            break;
        case 's' :
            if (G_stack[G_nstk]) // testing a static address for non zero doesn't make sense :JGQ 23/10
                {
                strcpy(((CHAR *)var),(CHAR *)G_stack[G_nstk]);
                }
            else
                {
                if (var)
                    *((CHAR *)var)=0;
                }
            break;
    }
    RETURNV(type);
}

//************************************************************
//S Return the type of the n'th item on the stack
//D where n=0 is the most recent pushed item.
//D N.B. There is no check against a request off the end of the stack (n=negative) :JGQ 23/10
//P integer place on stack
//R char type of item OR null (0) if request is off start of stack 

CHAR  stktype(INT place)
{
	ENTRY(2010);
    if (place>=G_nstk)
        RETURNV(0);
    place++;
    RETURNV(*(G_stackt-place));
}

//************************************************************
//S Get the n'th item on the stack as a number to our private location
//P integer place on stack where 0 = most recent pushed item
//P address to place returned number
//R returns the type of the item ('n' or 's')

CHAR  stknum(INT place, NUMB *n)
{
    CHAR t;
	ENTRY(2020);
    switch (t=stktype(place))
        {
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
//S Get the n'th item on the stack as a string to our private buffer
//P integer place on stack
//P address to place returned string
//R returns the type of the item ('n' or 's')

CHAR  stkstr(INT place,CHAR *s)
{
    CHAR t;
	ENTRY(2030);
    switch (t=stktype(place))
        {
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
//S Return the current size of the stack 
//R returns the integer no. of items on the stack (0 = none)

INT  stksize(void)
{
	ENTRY(2040);
    RETURNV(G_nstk);
}

//************************************************************
//S Pop the top item off the stack as a LONG and give as reply
//D n.b. if the stack was empty you get the last number item processed
//R return long integer reply

LONG  popl(void)
{
	ENTRY(2050);
    getnum();
    RETURNV((LONG)G_n1);
}

//************************************************************
//S pop the top two items on the stack as strings in to vars
//D note: latest pushed item becomes ???2 and older item ???1

void  get2strs(void)
{
    CHAR t1,t0;
	ENTRY(2060);
    t1=stktype(1);
    if (!t1)
        RETURN;             // n.b. assumes if there is two items on the stack then there must be 1 too!
    t0=stktype(0);
    if (t0==t1)             // see if they're both the same type
        {
        if (t0=='n')        // both same and numeric
            {
            POP(&G_n2);
            NTOA(G_s2,G_n2);
            POP(&G_n1);
            NTOA(G_s1,G_n1);
            }
        else                // both same and string
            {
            POP(&G_s2);
            POP(&G_s1);
            }
        }
    else
        {
        if (t0=='s')
            {
            POP(&G_s2);
            POP(&G_n1);
            NTOA(G_s1,G_n1);
            }
        else
            {
            POP(&G_n2);
            NTOA(G_s2,G_n2);
            POP(&G_s1);
            }
    }
	RETURN;

}

//************************************************************
//S pop the top two items on the stack as numbers in to vars
//D note: latest pushed item becomes ???2 and older item ???1

void  get2nums(void)
{
    CHAR t1,t0;
	ENTRY(2070);
    t1=stktype(1);
    if (!t1)
        RETURN;
    t0=stktype(0);
    if (t0==t1)
        {
        if (t0=='n')
            {
            POP(&G_n2);
            POP(&G_n1);
            }
        else
            {
            POP(&G_s2);
            G_n2=ATON(G_s2);
            POP(&G_s1);
            G_n1=ATON(G_s1);
            }
        }
    else
        {
        if (t0=='s')
            {
            POP(&G_s2);
            G_n2=ATON(G_s2);
            POP(&G_n1);
            }
        else
            {
            POP(&G_n2);
            POP(&G_s1);
            G_n1=ATON(G_s1);
            }
    }
	RETURN;
}

//************************************************************
//F getnum
//S pop the top item on the stack as a number in to var

void getnum(void)
{
    CHAR t;
	ENTRY(2080);
    t=stktype(0);
    if (!t)
        RETURN;
    if (t=='n')
        {
        POP(&G_n1);
        }
    else
        {
        POP(&G_s1);
        G_n1=ATON(G_s1);
        }
	RETURN;
}
//************************************************************
//S pop the top item on the stack as a string
//D n.b. if the stack was empty you get the last string item processed
//R returns char pointer to G_s1 - the fixed pop string location

CHAR *pops(void)
{
	ENTRY(2090);
    getstr();
    RETURNV(G_s1);
}

//************************************************************
//S pop the top item on the stack as a string in to var

void getstr(void)
{
    CHAR t;
	ENTRY(2100);
    t=stktype(0);
    if (!t)
        RETURN;
    if (t=='n')
        {
        POP(&G_n1);
        NTOA(G_s1,G_n1);
        }
    else
        {
        POP(&G_s1);
        }
	RETURN;
}

//************************************************************
//S pop the two latest items off the stack, add them, and push the result

void  add(void)
{
	ENTRY(2110);
    get2nums();
    PUSHN((G_n1+G_n2));
	RETURN;
}

//************************************************************
//S pop two off stack, sub latest from older, and push the result

void sub(void)
{
	ENTRY(2120);
    get2nums();
    PUSHN((G_n1-G_n2));
	RETURN;
}

//************************************************************
//S pop two off stack, multiply them, and push the result

void  mul(void)
{
	ENTRY(2130);
    get2nums();
    PUSHN((G_n1*G_n2));
	RETURN;
}

//************************************************************
//S pop two off stack, divide older by latest, and push the result
//D if latest push item is zero result is set to zero

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
//S pop two off, and push the remainder of dividing the older by the newer

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
//S pop two off the stack, and push the logical AND of them as NUMBERS 

void  land(void)
{
	ENTRY(2160);
    get2nums();
    PUSHN((G_n1&&G_n2));
	RETURN;
}

//************************************************************
//S pop two off the stack, and push the logical OR of them as NUMBERS 

void  lor(void)
{
	ENTRY(2170);
    get2nums();
    PUSHN((G_n1||G_n2));
	RETURN;
}

//************************************************************
//S pop two off the stack, and push the logical XOR of them as NUMBERS 

void  lxor(void)
{
	ENTRY(2180);
    get2nums();
    PUSHN((((LONG)G_n1^(LONG)G_n2)!=0));
	RETURN;
}

//************************************************************
//S pop one off the stack, and push the BOOLEAN NOT of it.

void  lnot(void)
{
	ENTRY(2190);
    getnum();
    PUSHN((!G_n1));
	RETURN;
}

//************************************************************
//S pop two off the stack, check for exact equality push the BOOLEAN result 

void  equal(void)
{
	ENTRY(2200);
    get2nums();
    PUSHN((G_n1==G_n2));
	RETURN;
}

//************************************************************
//S pop two off the stack, check for exact INequality push the BOOLEAN result 

void  notequal(void)
{
	ENTRY(2210);
    get2nums();
    PUSHN((G_n1!=G_n2));
	RETURN;
}

//************************************************************
//S pop two off the stack, push the BOOLEAN of older being less than newer

void  less(void)
{
	ENTRY(2220);
    get2nums();
    PUSHN((G_n1<G_n2));
	RETURN;
}
//************************************************************
//S pop two off the stack, push the BOOLEAN of older being less|equal to newer

void  lessequal(void)
{
	ENTRY(2230);
    get2nums();
    PUSHN((G_n1<=G_n2));
	RETURN;
}

//************************************************************
//S pop two off the stack, push the BOOLEAN of older being greater than newer

void  great(void)
{
	ENTRY(2240);
    get2nums();
    PUSHN((G_n1>G_n2));
	RETURN;
}
//************************************************************
//S pop two off the stack, push the BOOLEAN of older being greater|equal to newer

void  greatequal(void)
{
	ENTRY(2250);
    get2nums();
    PUSHN((G_n1>=G_n2));
	RETURN;
}

//************************************************************
//S pop one off the stack and push the bitwise NOT of it.

void  not(void)
{
	ENTRY(2260);
    getnum();
    PUSHN((~(LONG)G_n1));
	RETURN;
}

//************************************************************
//S pop one off the stack and push the unary negative of it.

void  neg(void)
{
	ENTRY(2270);
    getnum();
    PUSHN((-G_n1));
	RETURN;
}
//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if equal

void  sequal(void)
{
	ENTRY(2280);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)==0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if NOT equal

void  snotequal(void)
{
	ENTRY(2290);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)!=0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if older is less than newer

void  sless(void)
{
	ENTRY(2300);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)<0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if older is less than or matches newer

void  slessequal(void)
{
	ENTRY(2310);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)<=0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if older is greater than newer

void  sgreat(void)
{
	ENTRY(2320);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)>0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a BOOLEAN TRUE if older is greater than or equal to newer

void  sgreatequal(void)
{
	ENTRY(2330);
    get2strs();
    PUSHN((strcmp(G_s1,G_s2)>=0));
	RETURN;
}

//************************************************************
//S pop two strings, and push a concatenation of them

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
//S pop start and end of desired cut, and string to cut from. push resultant cut
//D expects user to have pushed start then end then string
//D puts back on the stack a string cut from this using the start and end points.
//D N.B. if start is after the end it swaps them round. - defensive codeing.
//D N.B. if start is beyond end of string will pick garbage - offensive coding. :JGQ 23/10
//D N.B. if start is beyond max but less than end will point illegal : JGQ 23/10 

void  scut(void)
{
	ENTRY(2350);
    get2nums();
    if (G_n1>G_n2)
        {
        G_n0=G_n1;
        G_n1=G_n2;
        G_n2=G_n0;
        }
    if (G_n2>=MAXSTRLEN)
        G_n2=MAXSTRLEN-1;

    getstr();
    G_s1[(INT)(G_n2)+1]=0;
    PUSHS(&G_s1[(INT)(G_n1)]);
	RETURN;
}

//************************************************************
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

