/* TURTLE.C     Main program for TURTLE.C

  TURTLE assumes large model -- see MAKEFILE

  Compile:
  Borland: MAKE
  Microsoft: NMAKE

*/

#include <stdio.h>
#define _MAIN_
#include "pgraph.h"
#include <dos.h>
#include <phapi.h>
#include <stdlib.h>
#include "turtle.h"
#include "xci.h"

/* XCI client's application data (see TURTLE.H) */
struct udata appdata;
int installcmds(void);

/* XCI startup command -- install commands */
XCICMD startup(int cmd, char far *dummy)
  {
  if (cmd) return;
  if (installcmds())
    {
    printf("Out of memory\n");
    exit(1);
    }
  }

/* Reset things before normal exit */
void preexit(void)
  {
  _setvideomode(_DEFAULTMODE);
  }


/* MAIN PROGRAM */
main()
  {
  void turtleprompt();
/* register exit routine */
  atexit(preexit);
  _setvideomode(_TEXTC80);
  _setactivepage(0);
  _setvisualpage(0);
  appdata.tcolor=appdata.color=15;
  appdata.pendown=1;
  appdata.backcolor=0x003f0000L;   /* blue background */
/* clear screen */
  clearcmd(0,"",&appdata);
/* Print banner */
  printf("TURTLE VGA by Al Williams\n"
         "Type HELP for help\n");

/* Take over XCI prompt function */
  xcif_prompt=turtleprompt;
  command("TSAVE.DLL","TURTLE.CMD",0,
          &appdata,(XCICMDP) startup);
  }




/* XCI prompt -- if in graphics mode keep
   input on top line */
void turtleprompt(char *s)
  {
  union REGS r;
  if (appdata.textgraph)
    {
/* don't do newline in graphic mode */
    if (*s=='\n')
      {
      printf(" ");
      return;
      }
/* but do clear the line */
     r.h.ah=2;
     r.h.bh=0;
     r.x.dx=0;
     int86(0x10,&r,&r);
     r.x.ax=0x0a00|' ';
     r.x.bx=appdata.tcolor;
     r.x.cx=40;
     int86(0x10,&r,&r);       /* clear to end of line */
    }
  printf("%s",s);
  }
