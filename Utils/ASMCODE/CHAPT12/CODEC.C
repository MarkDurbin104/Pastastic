
/**********************************************************************
*
*  Determining the video adapter type and output the code of a key pressed
*
*  Author:  A.I.Sopin   Voronezh, 1992
*
*  External functions used (the library C60S.LIB):
*
*  DIAM04,  CCOLOR, CVIDEO, CCURS
*
**********************************************************************/
#include <stdio.h>
#include <dos.h>
extern void CCOLOR (int  M, int  N, int  C);
extern void DIAM04 (int OP, int M, int N, char *Tp, int L, int U, int V,
                    int *Qp, int *Sp, unsigned char *Wp, char *Ip);
extern void CVIDEO (char *VTYPE);
extern void CCURS (int U, int V);
union  REGS  regs;

void main ()
{
static int   U = 5, V = 1, Q = 1, S;
static unsigned  char W[4], Fin[ ] = {" ***  End of job (press"
                                      "any key to exit)  *** " };
static char I [5] = { 48, 16, 0, 0x74, 0 }, Nregim, VT [4], Inp;
/*-------------------------------------------------------------------------*/
    regs.h.ah = 0x0f;                /*  function 0Fh - get video mode     */
    regs.h.bh = 0;                   /*  BH - video page number            */
    int86 (0x10, &regs, &regs);      /* BIOS/DOS service call (interrupt)  */
    Nregim = regs.h.al;              /*  save video mode                   */
    CCOLOR (1, 25, 0x1e);            /*  clear screen and set color        */
    CVIDEO (VT);                     /*  determine video adapter type      */
    CCURS (2, 1);                    /*  position cursor for printf ( )    */
    printf ("Adapter type =%s", VT); /*  output video adapter type (line 2)*/
    printf (" (Press any key)");     /*  output prompt                     */
    gets (&Inp);                     /*  wait for key pressing             */
/*-------------------------------------------------------------------------*/
/*  This cycle outputs 24 lines onto the screen                            */

    *(W+1) = 0;                      /*  clear key code                    */
    while (Q <= 24)                  /*  until 24 lines aren't output...   */
    {
      DIAM04 (1, 3, -3, "DIAM04 testing (\"ESC\" - exit)    ",
              80, U, V, &Q, &S, W, 0);
      DIAM04 (10, 3, -3, "  ", 80, U, V, &Q, &S, W, 0);
      printf ("Code: ASCII=%02X  SCAN=%02X  0:417=%02X  0:418=%02X",
               *W, *(W+1), *(W+2), *(W+3));
      if (*(W+1) == 0x01)             /* ESC - finish work                 */
        {
           putch (0x07);              /*  generate sound signal            */
           DIAM04 (1, 3, -3, "  ", 80, U, V, &Q, &S, W, 0);
           break;                     /*  cycle "while" ends here          */
        }
      U++;
      V++;
    } /* End  while (Q <= 24) */
/*-------------------------------------------------------------------------*/
/*  Restore video mode and exit                                            */
    CCOLOR (1, 25, 0x1e);             /*  Clear screen (lines 1-25)        */
    I[0] =48;                         /*  creating array of screen         */
    I[1] =16;                         /*  control codes                    */
    I[2] =0;
    I[3] =0x74;                       /*  red characters on grey           */
    I[4] =0;                          /*  (see description of DIAM04)      */
    DIAM04 (2,12,-12, Fin, 80, 0, 0, &Q, &S, W, I);
    regs.h.ah = 0x00;                 /*  function 0 - set video mode      */
    regs.h.al = Nregim;               /*  saved video mode into AL         */
    int86 (0x10, &regs, &regs);       /* BIOS/DOS service call (interrupt)  */
    return;
}

