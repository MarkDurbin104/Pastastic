/* Simple program to test RSTUB.C
   Watcom: wcl386 rhello.c @rhello.def
*/

#include <stdio.h>

main(int argc, char *argv[])
  {
  printf("Hello!\n");
/* echo arguments */
  while (--argc) printf("%s\n",*++argv);
  }
