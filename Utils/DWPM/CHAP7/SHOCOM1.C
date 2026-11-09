/* SHOCOM1 - Show serial port addresses using Windows
   test bed.
   Alternate version: uses predefined selector _0040H

   Compile with:
   Borland: BWINCOMP SHOCOM1
   Microsoft: MWINCOMP SHOCOM1 */

#include "winpmode.h"
#include <dos.h>


/* Windows predefined selectors */
extern unsigned _near _0040H, _near _0000H;

char *test()
  {
  union REGS r;
  unsigned short _far *p,i;
/* create far pointer to BIOS data segment */
  FP_SEG(p)=(unsigned)&_0040H;
  FP_OFF(p)=0;

/* As an alternate, you could use:
 * FP_SEG(p)=(unsigned)&_0000H;
 * FP_OFF(p)=0x400; */

/* read COM port addresses from BIOS table */
  for (i=0;i<=3;i++)
    win_printf("COM Port I/O Address","COM%d: "
              "%04X",i+1,p[i]);
  return "Done";
  }
