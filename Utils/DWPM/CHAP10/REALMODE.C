/* Real mode program that interfaces with
   286 | DOS Extender
   Borland: bcc realmode.c
   Microsoft: cl realmode.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <process.h>
#include <dos.h>

#define SET 1
#define RESET 0

int hookint(int);

main()
  {
  int intno,rc;
  char tempstr[16];
/* hook interrupt */
  if ((intno=hookint(SET))!=-1)
    {
/* if successful, call run286 and pass it interrupt number
   as command line argument */
    rc=spawnlp(P_WAIT,"run286.exe","run286.exe",
                      "protmode.exe",itoa(intno,tempstr,10),
                      NULL);
    if (rc==-1)
      printf("Can't find RUN286.EXE or PROTMODE.EXE\n");
/* unhook interrupt */
    hookint(RESET);
    }
  return rc;
  }


/* clear screen in real mode (for no good reason) */
void _far _interrupt isr()
  {
/* set constant to 0xb0000000 if using mono monitor */
  int i;
  int _far *video=(int _far *)0xb8000000;
  for (i=0;i<2000;i++) *video++=0x720;
  return;
  }

/* hook and unhook a user interrupt
   (from 0x60-0x67) */
int hookint(int action)
  {
/* interrupt number used */
  static int intno=-1;
  void (_far _interrupt *oldvector)();
  int i;
  if (action==SET)
    {
    for (i=0x60;i<=0x67;i++)
      {
      oldvector=_dos_getvect(i);
      if (!oldvector)
        {
/* found unused interrupt */
        intno=i;
        _dos_setvect(i,isr);
        break;
        }
      }
    return intno;
    }
  else
    {
/* mark vector as unused */
    _dos_setvect(intno,NULL);
    intno=-1;
    return -1;
    }
  }
