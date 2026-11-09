
/**********************************************************************
*
*  Issuing an MS-DOS command from within C program
*
*  Author: A.I.Sopin, Voronezh University, Voronezh, Russia  1992
*
*  External functions used (the C60S.LIB library):
*
*  DIAM04,  CCOLOR, WINC07, DOSCOM
*
**********************************************************************/

#include <stdio.h>
#include <dos.h>

extern void CCOLOR (int  M, int  N, int  C);
extern void DIAM04 (int OP, int M, int N, char *Tp, int L, int U, int V,
                    int *Qp, int *Sp, unsigned char *Wp, char *Ip);
extern void DIAM24 (unsigned char *Wp);
extern int  DOSCOM (char *Comand);
extern void WINC07 (int M, char *T, int L, int V, int *Q, int *S, char *W,
             char *I, int RL, int RR);

union  REGS  regs;

void main ()

{
static int  Q, S, j;
static unsigned  char W[4];
static char  TEXT23 [ ] ={ "Enter command line or press ESC to exit " };
static char  TEXT1 [ ] ={  "Input and processing an MS-DOS command   "
                           "  Author:  A.I.Sopin,   Voronezh, 1992   "  };
static char  COMSTR [81];
/*-------------------------------------------------------------------------*/
/*  Input a command line                                                   */

    *(W+1) = 0;                      /*  clear the code of the key pressed */
    while (1)                        /*  permanent cycle (wait for key)    */
    {
      CCOLOR (1, 25, 0x07);          /*  clear screen and set up color    */
      DIAM04 (1, 1, 1, TEXT1, 80, 0, 0, &Q, &S, W, 0);
      DIAM04 (1, 23, -23, TEXT23, 80, 24, 2, &Q, &S, W, 0);
      for (j = 1; j <= 79; j++)  *(COMSTR + j) = ' ';    /*  clear command
                                                             line buffer   */

      *COMSTR = '>';                 /*  output command prompt             */
      WINC07 (24, COMSTR, 80, 2, &Q, &S, W, 0, 2, 80);
      if (*(W+1) == 1)  break;       /*  Esc - end of program's work       */
/*-------------------------------------------------------------------------*/
/*  Processing the command entered  (ESC - exit)                           */
      DOSCOM (COMSTR+1);             /* enter and process an MS-DOS command */
      DIAM04 (1, 25, -25, "Press any Key (Esc -Exit)",
      80, 0, 0, &Q, &S, W, 0);
      DIAM24 (W);                    /*  waiting for pressing any key      */
      if (*(W+1) == 1)  break;       /*  Esc - exit program                */
    } /* End  while (*(W+1) != 1) */
/*-------------------------------------------------------------------------*/
/*  Completion of the work (after pressing Esc)                            */
      exit (0);
}  /* End  main  */

