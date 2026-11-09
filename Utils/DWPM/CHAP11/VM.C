/* VM.C - Exercise malloc() with virtual memory
   (or without, for that matter)

   Compile with most any compiler -- some versions of
   High C won't work with very large mallocs --
   adjust the maximum number (ULONG_MAX, below) to
   a smaller number, if you get run time errors when
   using High C.

   Some early DPMI hosts will cause a page fault
   when you try to malloc near the upper limit
   of the swap file.

   Sixteen-bit compilers can only malloc <64K so
   this is pretty uninteresting with these compilers.

   Examples:
   Borland: bcc vm.c
   Microsoft: cl vm.c
   High C: hc386 vm.c
   Intel: icc vm.c
   Watcom: wcl386 /l=dos4gw vm.c

*/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

void main()
  {
  size_t amt=0,lo=0,lo0,a1;
  void *p=NULL;

/* Figure out if we are on a 16 or 32 bit compiler */
#if sizeof(size_t)==sizeof(long)
      a1=amt=ULONG_MAX;
#else
      a1=amt=USHRT_MAX;
#endif

/* do forever */
  while (1)
    {
/* the unsigned long casts are required for 16 bit compile */
    printf("high=%08lX\ttry=%08lX\tlow=%08lX\t",
      (unsigned long)a1,(unsigned long)amt,
                        (unsigned long)lo);
    lo0=lo;
/* allocate memory */
    p=malloc(amt);

/* if successful */
    if (p)
      {
      printf("success\n");
/* free it, and establish new lo limit */
      free(p);
      lo=amt;
      }
    else
      {
/* otherwise establish new hi limit */
      printf("fail\n");
      a1=amt;
      }
/* when the hi and lo marks are 1 apart, we are done */
    if (amt-lo0<=1) break;

/* compute new attempt */
    if (p)
      amt+=(a1-lo)/2;
    else
      amt-=(a1-lo)/2;
    }

/* DONE! */

  if (lo)
    {
    printf("Allocated %lu bytes\n",(unsigned long)lo);
    }
  else
    {
    printf("Couldn't allocate any memory!\n");
    }
  }



