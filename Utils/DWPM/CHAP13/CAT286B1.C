/* Example break handler for cat286.c. Uses
   signal and _harderr(). See cat286.c for instructions */

#include <stdio.h>
#include <signal.h>
#include <dos.h>
#include <ctype.h>


/* break flag  */
int broke;

/* Common things for break handlers */
#include "common.h"


/* this function happens on a ^C/^Break
   (This is "event driven" code -- not too different
   from Windows. An event (^C) triggers this function */
void on_break(void)
  {
/* reset signal handling */
  signal(SIGINT,on_break);
/* set flag */
  broke=1;
  }

/* this function happens on a critical error */
void on_crit(unsigned int rax,unsigned int rdi,
             unsigned *hdr)
  {
  int status;
  status=critical(rax,rdi);  /* see common.h */
  switch (status)
    {
    case 0:
      _hardresume(_HARDERR_IGNORE);
      break;

    case 1:
      _hardresume(_HARDERR_RETRY);
      break;

    case 3:
      _hardresume(_HARDERR_FAIL);
      break;
    }
  }



/* set up */
void x_init(void)
  {
  signal(SIGINT,on_break);
  _harderr(on_crit);
  }

