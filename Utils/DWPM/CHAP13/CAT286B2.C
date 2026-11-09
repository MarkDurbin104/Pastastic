/* Example break handler for cat286.c. Uses
   interrupts. See cat286.c for instructions */

#pragma check_stack(off)
#include <stdio.h>
#include <phapi.h>
#include <dos.h>
#include <conio.h>
#include <ctype.h>

/* Break vectors */
static PIHANDLER oldbreak;
static REALPTR oldbreal;
static PIHANDLER old1b;
static REALPTR old1breal;
static PIHANDLER old24;
static REALPTR old24real;

/* break flag -- declared volatile since
an interrupt routine might change it. The volatile
keyword tells the compiler that the value could
change at any time. */
int volatile broke=0;

/* Bios segment (you can't call DosGetBIOSseg from ISR) */
static USHORT biosseg;

#include "common.h"

/* The following define hides the fact that Borland and
   Microsoft push the registers in a different order for
   interrupt functions */
#ifdef __BORLANDC__
#define REGS_16 REGS_BINT
#else
#define REGS_16 REGS16
#endif



/* ^Break handlers */
void _interrupt _far new_int1b(REGS_16 r)
  {
  union REGS rr;
  unsigned int *keyhead,*keytail;
/* get pointers to keyboard buffer */
  keyhead=MAKEP(biosseg,0x1A);
  keytail=MAKEP(biosseg,0x1C);
/* set break flag */
  broke=1;
/* purge keyboard buffer */
  *keyhead=*keytail;
/* push ^C at head */
  rr.h.ah=5;
  rr.x.cx=3;
  int86(0x16,&rr,&rr);
  }

/* new keyboard int */
void _interrupt _far new_int16(REGS_16 r)
  {
  REGS16 r1;
  unsigned ah=r.ax>>8;
  _enable();
  if (ah==0||ah==0x10||ah==1||ah==0x11)
    {
    do
      {
      r1.ax=0x100;
      r1.flags=0;
/* Simulate interrupt to old INT 16H handler */
      DosRealFarCall(oldbreal,&r1,0,-1,r1.flags);
/* if char not ready... */
      if ((r1.flags&ZFLAG)&&(ah==1||ah==0x11))
        {
        r.flags=r1.flags;
        return;
        }
      } while (r1.flags&ZFLAG); /* while char not ready */
/* If break character -- replace it with a carriage return
   3==^C  0x300==^2 -- ^2 (control-2) generates a break...
   its true! Try it from the DOS prompt. */
      if ((r1.ax&0xff)==3||r1.ax==0x300)
        {
        unsigned int *keyhead;
/* Find 1st byte of keyboard typeahead buffer */
        keyhead=MAKEP(biosseg,0x1A);
        keyhead=MAKEP(biosseg,*keyhead);
        *keyhead='\r';
/* set break flag */
        broke=1;
        }
    }
/* continue with old INT 16 handler */
  DosChainToRealIntr(oldbreal);
  }


void _interrupt _far new_int24(REGS_16 r)
  {
  int status;
/* status == 0 for ignore, 1 for retry, 3 for fail */
  status=critical(r.ax,r.di);   /* see common.h */
  r.ax|=status;
  return;
  }


/* function to clean up -- installed with DosExitList */
void pascal x_clean(USHORT arg)
  {
  DosSetRealProtVec(0x16,oldbreak,oldbreal,NULL,NULL);
  DosSetRealProtVec(0x1b,old1b,old1breal,NULL,NULL);
  DosSetRealProtVec(0x24,old24,old24real,NULL,NULL);
  DosExitList(EXLST_EXIT,NULL);
  }


/* setup */
void x_init(void)
  {
  DosGetBIOSSeg(&biosseg);
/* Due to a bug in versions prior to 1.4, you must set
   the INT 16H ProtVec before using PassToProtVec... */
  DosSetProtVec(0x16,(PIHANDLER)new_int16,&oldbreak);
  DosSetPassToProtVec(0x16,(PIHANDLER)new_int16,NULL,
                      &oldbreal);
  DosSetPassToProtVec(0x1b,(PIHANDLER)new_int1b,
                      &old1b,&old1breal);
  DosSetPassToProtVec(0x24,(PIHANDLER)new_int24,
                      &old24,&old24real);
  DosExitList(EXLST_ADD,x_clean);
  }


