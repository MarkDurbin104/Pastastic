/* SHOARY for Phar Lap/MetaWare C
   HC386 SHOARYPL.C
*/
#include <conio.h>
#include "ptrset.h"

#define SCREEN_SIZE (80*25)

unsigned short new_screen[SCREEN_SIZE];


main()
  {
  short i;
  for (i=0;i<SCREEN_SIZE;i++)
     new_screen[i]=0x7040;   /* Inverse @ sign */
  fill_screen();
/* wait for a key */
  if (!getch()) getch();
  return 0;
  }

fill_screen()
  {
  unsigned short _far *scrptr;
  unsigned short *aryptr;  /* near pointer */
  short i;
  FP_SEG(scrptr)=0x1C;          /* Phar Lap video segment */
  FP_OFF(scrptr)=0;
  aryptr=new_screen;
  for (i=0;i<SCREEN_SIZE;i++)
    *scrptr++=*aryptr++;
  return 0;
  }

