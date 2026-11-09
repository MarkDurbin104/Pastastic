/* SHOCOM2 - Show serial port addresses using Windows
   test bed.
   Alternate version: uses AllocSelector()

   Compile with:
   Borland: BWINCOMP SHOCOM1
   Microsoft: MWINCOMP SHOCOM1 */

#include <windows.h>
#include "winpmode.h"
#include <dos.h>


char *test()
  {
  unsigned sel;
  unsigned short _far *p,i;
  struct SREGS s;
  segread(&s);
/* create far pointer to BIOS data segment
  Use data segment as model since we want
  a data segment anyway. */
  sel=AllocSelector(s.ds);
  if (!sel) return "Can't acquire selector";
  SetSelectorLimit(sel,7);
  SetSelectorBase(sel,0x400);
  FP_SEG(p)=sel;
  FP_OFF(p)=0;

/* read COM port addresses from BIOS table */
  for (i=0;i<=3;i++)
    win_printf("COM Port I/O Address","COM%d: "
              "%04X",i+1,p[i]);
  FreeSelector(sel);
  return "Done";
  }
