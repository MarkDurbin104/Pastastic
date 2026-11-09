/* Detecting DPMI with Phar Lap 286 | DOS Extender
   Borland: bcc286 dpmit.c
   Microsoft: cl -AL -G2 -Lp dpmit.c

   Note: Some DPMI hosts turn off when they detect
   the Phar Lap extender start up to prevent conflicts.
   (QDPMI does this when its XCHK flag is set, for example).
   In these cases, it will appear that DPMI is not present
   unless you disable this behavior in the host.
*/

#include <stdio.h>
#include <phapi.h>
#include <string.h>

void main()
  {
  REGS16 r;
/* zero out registers */
  memset(&r,0,sizeof(REGS16));
/* set AX to 0x1687 and issue real mode INT 0x2F */
  r.ax=0x1687;
  DosRealIntr(0x2f,&r,0,0);
/* return status in AX */
  if (r.ax)
    printf("No DPMI host detected\n");
  else
    printf("DPMI present\n");
/* See DPMI.C for more info on return values */
  }
