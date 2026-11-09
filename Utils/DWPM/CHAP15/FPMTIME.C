/* FPMTIME.C - Timing example for FPM32
   Compile:
   Borland: MAKE
   Microsoft: NMAKE */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "fpm32.h"
#include "winpmode.h"


void test1(int i,FIXED a,FIXED b);
void test2(int i,float a,float b);

char retstr[64];  /* return string */
char *test()
  {
  FIXED a,b;
  float a1,b1;
  int i=10000,op;
  clock_t s,e,t1;
  a1=100.25;
  b1=33.17;
  a=floattofix(a1);
  b=floattofix(b1);
  s=clock();
  test1(i,a,b);
  e=clock();
  win_printf("FPM32 Time (in ticks)","%lu",t1=e-s);
  i=10000;
  s=clock();
  test2(i,a1,b1);
  e=clock();
  win_printf("FLOAT Time (in ticks)","%lu",e-s);
  sprintf(retstr,"Time difference: %ld (%3.1f:1)",
                                   (e-s)-t1,
                                   (e-s)/(float)t1);
  return retstr;
  }


void test1(int i,FIXED a,FIXED b)
  {
  while (i--)
    {
    faddxy(a,b);
    fmulxy(a,b);
    fdivxy(a,b);
    fsubxy(a,b);
    }
   }

/* Declare c1 volatile -- this tells compiler it might
   change unexpectedly and prevents the compiler from
   optimizing it away since we really don't use it */
volatile int c1;

void test2(int i,float a1,float b1)
  {
  while (i--)
    {
    c1=a1+b1;
    c1=a1*b1;
    c1=a1/b1;
    c1=a1-b1;
    }
  }
