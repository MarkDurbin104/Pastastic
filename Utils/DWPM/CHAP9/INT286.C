/* INT286.C - Replace interrupt 0x10 with Phar Lap | 286
   Borland: bcc286 int286.c
   Microsoft: cl -AL -G2 -Lp int286.c */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <phapi.h>

#ifdef __BORLANDC__
#define INT_REGS REGS_BINT
#else
#define INT_REGS REGS16
#endif

/* prototype for new ISR */
void _interrupt _far new_int10(INT_REGS r);

/* place to store old ISR addresses -- global so
   new_int10() can get at oldrint10 */
PIHANDLER oldpint10;
REALPTR   oldrint10;


void main()
  {
/* capture both real and protected vectors and pass them
   to new_int10() */
  DosSetPassToProtVec(0x10,
          (PIHANDLER)new_int10,&oldpint10,&oldrint10);
/* print from protected mode */
  printf("hello from protected mode\n");
/* run command.com in real mode to print */
  system("command /cecho hello from real mode");
/* restore previous vectors */
  DosSetRealProtVec(0x10,oldpint10,oldrint10,NULL,NULL);
  }

void _interrupt _far new_int10(INT_REGS r)
  {
  unsigned int ah=(r.ax&0xFF00)>>8;
/* If it is an output call shift character up */
  if (ah==9||ah==0xa||ah==0xe)
    r.ax=(r.ax&0xFF00)|toupper(r.ax&0xFF);
/* go to original handler */
  DosChainToRealIntr(oldrint10);
  }

