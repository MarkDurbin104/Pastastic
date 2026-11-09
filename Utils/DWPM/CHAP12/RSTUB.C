/* Replacement Stub for Rational 4GW -- adds additional
   argument to command line. This is a real mode program.

   Borland: bcc rstub.c
   Microsoft: cl rstub.c */

#include <stdio.h>
#include <process.h>
#include <string.h>
#include <stdlib.h>

main(int argc, char *argv[])
  {
  char *p,**newargv;
  int nextarg=3;
/* set up new argv */
  newargv=(char **)malloc((argc+3)*sizeof(char *));
/* and new program name */
  p=strdup(argv[0]);
  if (p&&newargv)
    {
/* name of extender (must be in current directory or
   on DOS path */
    newargv[0]="dos4gw.exe";
    newargv[1]=argv[0];
/* ADD NEW ARGUMENT */
    newargv[2]="FROM_STUB";
/* copy any other arguments */
    while (argc--)
      newargv[nextarg++]=*++argv;
    newargv[nextarg]=NULL;
/* Execute extender */
    execvp(newargv[0],newargv);
    }
/* If we ever get here, something is wrong! */
  printf("Fatal error loading RHELLO.EXT\n");
  exit(1);
  }
