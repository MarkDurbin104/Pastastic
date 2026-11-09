
/*---------------------------------------------------------------------*
*                                                                      *
*  The line editing with the insert/overriding modes usage             *
*                                                                      *
*                                                                      *
*  Parameters (the same as for program DIAM04)                         *
*                                                                      *
*  M  - number of row (1 - 50)                                         *
*                                                                      *
*  T  - the address of the prompt string                               *
*                                                                      *
*  L  - the length of the string (1 - 80)                              *
*                                                                      *
*  V  - initial position of the cursor within prompt string            *
*                                                                      *
*  Q  - command line enterd by user                                    *
*                                                                      *
*  S  - the cursor position within the command line when ENTER pressed *
*                                                                      *
*  W  - the array containing ASCII and scan codes for key pressed and  *
*       values of bytes 417h and 418h (keyboard flags)                 * 
*                                                                      *
*  I  - array containing the screen parameters                         *
*                                                                      *
*                                                                      *
*  Additional parametrs:                                               *
*                                                                      *
*  RL - left bound of the cursor within the command line               *
*                                                                      *
*  RR - right bound of the cursor within the command line              *
*                                                                      *
*  If RR = 0  or LL = 0  the whole string is processed                 *
*                                                                      *
*                                                                      *
*  The exit is performed when ESC or Enter key is pressed              *
*                                                                      *
*---------------------------------------------------------------------*/


extern void DIAM04 (int OP, int M, int N, char *T, int L, int U, int V,
                    int *Q, int *S, char *W, char *I);


void WINC07 (int M, char *T, int L, int V, int *Q, int *S, char *W,
             char *I, int RL, int RR)

{

int  D0, j;

/* ----------------------------------------------------------------------- */
/*  Waiting for a key and processing the code of key pressed              */

      *W = *(W+1) = 0;
      D0 = (I == 0) ? 0 : *(I+1);
      RL = (RL == 0) ? D0+1 : RL;
      RR = (RR == 0) ? L+D0 : RR;
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      while ((*(W+1) != 1) && (*(W+1) != 0x1c))
 {
      DIAM14 (W);            /*  check keyboard buffer                     */
      switch (*(W+1))        /*  process the code of key pressed           */
  {
/*----------------------------------------------------------------------
    Processing the keys which must be ignored
-----------------------------------------------------------------------*/

case  0x45:                  /*  "Num Lock"                                */
case  0x46:                  /*  "Scroll Lock"                             */
case  0x48:                  /*  Up Arrow                                  */
case  0x50:                  /*  Down Arrow                                */
case  0x52:                  /*  "Ins"                                     */
             break;
/* ----------------------------------------------------------------------- */
case  0x0f:                  /*  the Tab key                               */

      if (*W != 0)           /*  Tab to the right (Tab)                    */
         break;
      else                   /*  Tab to the left  (Shift + Tab)            */
         break;
/* ----------------------------------------------------------------------- */
case  0x4d:                  /*  Right Arrow                               */
      V = (V == RR) ? V : ++V;
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/* ----------------------------------------------------------------------- */
case  0x4b:                  /*  Left Arrow                                */
      V = (V == RL) ? V : --V;
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/* ----------------------------------------------------------------------- */
case  0x47:                  /*  The "Home" key - beginning of the string  */
      V = RL;
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/* ----------------------------------------------------------------------- */
case  0x4f:                  /*  The "End" key - end of the string         */
      V = RR;
      while ((*(T -D0 -1 +(--V))) <= ' ') 
         ;
      ++V;
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/* ----------------------------------------------------------------------- */
case  0x0e:                  /*  the "<--" key - Backspace                 */
      if (V == RL)   break;
      --V;
      for (j = V -D0; j < RR -D0; j++)  *(T+j-1) = *(T+j);
      *(T+j-1) = ' ';
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/* ----------------------------------------------------------------------- */
case  0x53:                  /*  the Del key - delete character            */
      for (j = V -D0; j < RR -D0; j++)  *(T+j-1) = *(T+j);
      *(T+j-1) = ' ';
      DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
      break;
/*----------------------------------------------------------------------
    Processing keys that generate ASCII characters
-----------------------------------------------------------------------*/
default:                             /* ASCII  codes except Enter and ESC */
  if ((*W != 0) && (*W != 0x0d) && (*W != 0x1b))
     {
       for (j = RR-D0-2; j >= V -D0 -1; j--)  *(T+j+1) = *(T+j);
       *(T+j+1) = *W;
       V = (V == RR) ? V : ++V;
       DIAM05 (1, M, M, T, L, M, V, Q, S, W, I);
     }
       break;                /*  if other keys - exit                    */
  }   /*  end    switch (*(W+1))  */
 }    /*  end    while    */
       return;
}     /*  end    WINC07    */

