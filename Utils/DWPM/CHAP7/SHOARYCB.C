/* SHOARY for CodeBuilder
   ICC SHOARYCB.C
*/
#include <stdio.h>
#include <conio.h>
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
  unsigned short *scrptr=(unsigned short *)0xb8000;
  unsigned short *aryptr;
  short i;
  aryptr=new_screen;
  for (i=0;i<SCREEN_SIZE;i++)
    *scrptr++=*aryptr++;
  return 0;
  }

