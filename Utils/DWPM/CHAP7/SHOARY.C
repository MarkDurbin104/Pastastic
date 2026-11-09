/* Example of mixed model programming -- use small model
   Borland:   BCC -ms SHOARY.C
   Microsoft: CL -AS SHOARY.C
*/
#include <stdio.h>
#include <conio.h>
#define SCREEN_SIZE (80*25)

unsigned short new_screen[SCREEN_SIZE];
void fill_screen(void);

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

void fill_screen(void)
  {
/* far pointer */
  unsigned short _far *scrptr=
           (unsigned short _far *)0xb8000000;
  unsigned short *aryptr;  /* near pointer */
  short i;
  aryptr=new_screen;
  for (i=0;i<SCREEN_SIZE;i++)
    *scrptr++=*aryptr++;
  }

