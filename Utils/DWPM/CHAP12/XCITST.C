/* Example XCI DLL
   See MAKEFILE for compile instructions */
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "xci.h"

/* Dummy definition */
struct udata
  {
  int dummy;
  };

#define EXPORT _far _loadds _export


/* uppercase print */
XCICMD EXPORT uprint(int cmd, char far *cmds,
                     struct udata *data)
  {
  if (cmd)
    {
    printf("UPRINT [string]\n");
    if (cmd==1)
      {
      printf("The UPRINT command displays the string\n");
      printf("on the screen in upper case.\n");
      }
    }
  else
    printf("%s\n",strupr(cmds));
  }

/* lower case print */
XCICMD EXPORT lprint(int cmd, char far *cmds,
                     struct udata *data)
  {
  if (cmd)
    {
    printf("LPRINT [string]\n");
    if (cmd==1)
      {
      printf("The LPRINT command displays the string\n");
      printf("on the screen in lower case.\n");
      }
     }
    else
     printf("%s\n",strlwr(cmds));
  }


/* Init DLL so we can use C library (MICROSOFT ONLY) */
unsigned far pascal _loadds dllstart()
  {
#ifndef __BORLANDC__
  extern void far pascal C_INIT(void);
/* Init Microsoft C library */
  C_INIT();
#endif
  return 1;
  }
