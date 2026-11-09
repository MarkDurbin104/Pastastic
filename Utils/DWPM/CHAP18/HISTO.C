/* HISTO.C display histograms for CB386
   Uses DISPLAY.C functions
*/
#include <stdio.h>
#include "display.h"

/* main function

First time: call histogram(-1,maximum_screen_columns);
Next time: call histogram(value,maximum_value);

Draws starting at cursor position in effect when first call
is made */

void histogram(int n,int maxm)
  {
  static nrcols;
  static int x0,y0;
  int x,y;
  int i,t;
  if (n==-1)  /* first time */
    {
    /* in this case, maxm=# of columns */
    nrcols=maxm;
    writes("Percent complete:\n\r");
    getxy(&x0,&y0);
    writecc((unsigned char)'\260',maxm);  /* empty bar */
    goxy(x0+maxm+1,y0);
    writes("100%");
    return;
    }
/* subsequent calls... save x,y */
  getxy(&x,&y);
/* restore our x,y */
  goxy(x0,y0);
/* draw bar */
  writecc((unsigned char)'\333',(n*nrcols)/maxm);
/* restore user's x,y */
  goxy(x,y);
  return;
  }
