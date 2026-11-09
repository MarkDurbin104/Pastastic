/***************************************************
 *                                                 *
 * FPMC.C - C language routines for FPM32          *
 *                                                 *
 ***************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "fpm32.h"

/* convert fpm to float */
FIXED floattofix(CVTTYPE f)
  {
  FIXED ans;
  unsigned long i,whole,frac=0L;
  CVTTYPE fp=.5;
  ans.sign=0;
/* special case */
  if (f==0.0)
    {
    ans.scale=0;
    ans.num=0L;
    return ans;
    }
  if (f<0.0)
    {
    ans.sign=0xff;
    f=-f;
    }
  whole=(unsigned long)f;
  f-=whole;
/* scale is number bits in whole */
  ans.scale=32-bitscan(1,(unsigned long)whole);
  ans.num=(unsigned long)whole<<ans.scale;
  if (ans.scale)
/* compute fractional part */
    for (i=1L<<(ans.scale-1);i!=0&&f!=0.0;fp/=2)
      {
      if (f>=fp)
        {
        f-=fp;
        frac|=i;
        }
      if (!frac&&!whole)
        ans.scale++;
      else
        i>>=1;
      }
  ans.num|=frac;
  return ans;
  }



/* convert FPM32 number to float */
/* Uses SFACTOR for rounding (see FPM.H) */
CVTTYPE fixtofloat(FIXED f)
  {
  unsigned long i;
  CVTTYPE fp=0.5,res,sg=1.0;
  if (f.sign)
    {
    sg=-1.0;
    }
  if (f.scale<0)
    res=(CVTTYPE)(f.num<<-f.scale);
  else
    {
    res=(CVTTYPE)(f.num>>f.scale);
    while (f.scale>>5)
      {
      f.scale--;
      fp/=2.0;
      }
    for (i=1L<<f.scale-1;i!=0;i>>=1,fp/=2)
      if (f.num&i) res+=fp;

    }
  return floor(sg*res*SFACTOR+.5)/SFACTOR;
  }

/* convert FPM32 number to int (truncate fraction) */
int fixtoint(FIXED f)
  {
  int r;
  if (f.scale>=0) r=f.num>>f.scale; else r=0;
  if (f.sign) r=-r;
  return r;
  }

