/* XCITEST.C -- example using XCI interpreter
   see MAKEFILE for compile instructions
*/
#include <stdio.h>
#include <phapi.h>
#include "xci.h"

/* XCI client's application data */
struct udata
  {
  int dummy;
  } appdata;

/* built-in print command */
XCICMD print_cmd(int cmd, char far *cmds, struct udata *data)
  {
  if (cmd)
    {
    printf("PRINT [string]\n");
    if (cmd==1)
      {
      printf("The PRINT command displays the string\n");
      printf("on the screen.\n");
      }
    }
  else
    printf("%s\n",cmds);
  }

/* XCI startup command */
XCICMD startup(int cmd, char far *dummy)
  {
  if (cmd) return;
  addcmd("print",print_cmd);
  return;
  }


/* MAIN PROGRAM */
main()
  {
/* Print banner */
  printf("XCITEST by Al Williams\n"
         "Type HELP for help\n");

  command("XCITST.DLL",NULL,0,
          &appdata,(XCICMDP)startup);
  }




