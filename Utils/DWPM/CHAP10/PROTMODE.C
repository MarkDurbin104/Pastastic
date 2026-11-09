/* 286 protected mode program for use with realmode.c
   Borland: bcc286 -w-eff protmode.c
   Microsoft: cl -AL -G2 -Lp protmode.c

   Ignore Borland's "code has no effect" message */

#include <stdio.h>
#include <phapi.h>
#include <stdlib.h>

main(int argc,char *argv[])
  {
  int intno;
/* error check */
  if (argc!=2||(intno=atoi(argv[1]))<0x60||intno>0x67)
    {
    printf("Don't run this program directly. "
           "Use REALMODE.EXE.\n");
    exit(1);
    }

/* print a message */
  printf("This message comes to you from protected mode.\n");
  printf("Press <ENTER> to see the real mode ISR clear the "
         "screen.\n");
  printf("Then press <ENTER> again to exit.\n");
/* wait for enter key */
  getchar();
/* call real mode interrupt; if you wanted to pass
 * an integer, say 10, to the ISR, you'd use:
 *       DosRealIntr(intno,NULL,0,sizeof(int),10);
 * but in this case there are no arguments. */
  DosRealIntr(intno,NULL,0,0);
/* wait for enter key again */
  getchar();
  printf("Back in protected mode.\n");
  return 0;
  }
