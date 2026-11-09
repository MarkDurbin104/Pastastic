/* TEXPR.C   Expression evaluator for TURTLE.EXE
   See MAKEFILE for compile instructions

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>
#include "turtle.h"

int _getnum(int);
int specialvar(void);
int prec(int);
void perform(int);
int e_expr(void);

static char *s;


/* get a numeric value */
int getnum(char *token)
  {
  s=token;
  return _getnum(1);
  }


/* Internal get numeric value -- set allowneg to 1
   if negative numbers are OK */
int _getnum(int allowneg)
  {
  char *span;
  int n,val;
/* process negative number */
  if (allowneg&&*s=='-')
    {
    s++;
    return -getnum(0);
    }

/* is it an internal variable ? */
  if (*s=='%')
    {
    s++;
    return specialvar();
    }

/* Is it a user variable (A-Z)? */
  if (isalpha(*s))
    {
    val=(int)appdata.vars[toupper(*s)-'A'];
    s++;
    return val;
    }

/* Is it a hex number (0x...)? */
  if (*s=='0'&&(*(s+1)=='x'||*(s+1)=='X'))
    {
    span="0123456789ABCDEFabcdef";
    sscanf(s+=2,"%x",&val);
    }
  else
    {
/* normal number */
    val=atoi(s);
    span="0123456789";
    }
/* skip over decimal or hex digits */
  s+=strspn(s,span);
  return val;
  }


/* process special internal variables */
int specialvar(void)
  {
  static seeded=0;   /* has random number been seeded? */
  int op=*s++;
  op=toupper(op);

/* %i numeric input */
  if (op=='I')
    {
    char inbuf[81];
    fgets(inbuf,sizeof(inbuf),stdin);
    return atoi(inbuf);
    }

/* %r random number */
  if (op=='R')
    {
    if (!seeded)
      {
      struct dostime_t dostime;
      seeded=1;
      _dos_gettime(&dostime);
      srand(dostime.hsecond);
      }
    return rand();
    }

/* %x X coordinate */
  if (op=='X')
     return appdata.graphxy.xcoord;

/* %y Y coordinate */
  if (op=='Y')
     return appdata.graphxy.ycoord;

/* %c Color */
  if (op=='C')
     return appdata.color;

/* %h Heading */
  if (op=='H')
     return appdata.heading;

  return 0;
  }



#define LE 256
#define GE 257



/* expression error */
int eerror(void)
  {
  printf("Expression error\n");
  return 0;
  }


/* stack size for expression parse */
#define STKSIZE 100

/* stack for values */
int valstack[STKSIZE];
/* top of valstack */
int valstackp=0;

/* stack for operators */
int opstack[STKSIZE];
/* top of opstack */
int opstackp=0;

/* Push, pop, and get top of stack */
/* The ## operator does "pasting" so:
   push(opstack,10);
   expands to:
   (opstackp<(STKSIZE-1)?opstack[opstackp++]=val:stkerr());
*/

#define push(stk,val) (stk##p<(STKSIZE-1)?stk[stk##p++]=\
                       val:stkerr())
#define pop(stk)      (stk[--stk##p])
#define tos(stk)      (stk[stk##p-1])

/* tell user about stack overflow */
int stkerr(void)
  {
  printf("Expression too complex\n");
  return 0;
  }


/* external interface to evaluate expression in str_in */
int evalexpr(char *str_in)
{
        int val;
        s=str_in;
        val=e_expr();
/* if parser didn't read all of string -- error */
        if (*(s-1)) eerror();
        return val;
}


/* Expression/subexpression parser */
int e_expr(void)
  {
  int op='+';
  int value;
  int topstack=opstackp;
/* Initilize stack */
  push(opstack,'+');
  push(valstack,0);

/* end at end of string or close paren */
  while (op&&op!=')')
    {
/* If open paren do a recursive call to get value */
    if (*s=='(')
      {
      s++;
      value=e_expr();
      if (*(s-1)!=')') ;  /* error if paren not matched */
      }
    else
/* get a number or variable */
      value=_getnum(1);
/* push it on */
    push(valstack,value);
/* read an operator */
    op=*s++;
/* see if two character (>= or <=) */
    if (op=='>'&&*s=='=') { op=GE; s++; }
    if (op=='<'&&*s=='=') { op=LE; s++; }

/* do calculations allowed by precedence */
    while ((opstackp!=topstack)&&prec(tos(opstack))
            >=prec(op))
      perform(pop(opstack));

/* push new operator on stack */
    push(opstack,op);
    }
/* not strictly required */
   pop(opstack);
   return pop(valstack);
   }

/* find precedence for given operator */
prec(int op)
  {
  switch (op)
    {
    case 0:
    case ')': return 0;

    case '<':
    case '>':
    case LE:
    case GE:
    case '=':
    case '#': return 1;

    case '&':
    case '|': return 2;

    case '-':
    case '+': return 3;

    case '/':
    case '%':
    case '*': return 4;
    }
  }

/* carry out operator on two top stack elements */
void perform(int op)
  {
  int value,v1,v2;
  v1=pop(valstack);
  v2=pop(valstack);
  switch (op)
    {
    case '+':
              value=v2+v1;
              break;
    case '-': value=v2-v1;
              break;
    case '*': value=v2*v1;
              break;
    case '/': value=v2/v1;
              break;
    case '%': value=v2%v1;
              break;
    case '=': value=v2==v1;
              break;
    case '#': value=v2!=v1;
              break;
    case '<': value=v2<v1;
              break;
    case '>': value=v2>v1;
              break;
    case LE:  value=v2<=v1;
              break;
    case GE:  value=v2>=v1;
              break;
    case '&': value=v2&&v1;
              break;
    case '|': value=v2||v1;
              break;
    }
  push(valstack,value);
  }




