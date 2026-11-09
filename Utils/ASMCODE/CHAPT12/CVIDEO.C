
/***************************************************************
*                                                              *
*   Determining the type of video adapter used                 *
*                                                              *
*   Author: A.I.Sopin,  Voronezh, 1992                         *
*                                                              *
*   The adapter type is returned as character string           *
*   char VTYPE [4] and can have the following values:          *
*                                                              *
*   "MDA", "CGA", "EGA", "MCGA" or "VGA"                       *
*                                                              *
****************************************************************/

#include <dos.h>

int EGACGA ();

int MCGAVGA ();

void  CVIDEO (char *VTYPE)

{

union  REGS  regs;

char  AL, BL;

      regs.x.ax = 0x1a00;        /*  get current mode                     */

      int86 (0x10, &regs, &regs);

      AL = regs.h.al;

      BL = regs.h.bl;

/*-------------------------------------------------------------------------*/

/*  Check for adapters other than MCGA or VGA                              */

    strcpy (VTYPE, "MDA ");

    if (AL != 0x1a)              /*  not VGA  or  not MCGA ?               */
      {

/*  Check for adapters MDA, CGA, EGA                                       */

       if (EGACGA () == 0)  return;

        if (EGACGA () == 1)
          {
            strcpy (VTYPE, "CGA ");  return;
          }

        if (EGACGA () == 3)
          {
            strcpy (VTYPE, "EGA ");  return;
          }
      }

/*-------------------------------------------------------------------------*/

/*  Check for adapters MDA, VGA or MCGA                                    */

    else      /* AL == 0x1a                                                */

      {
         if (BL < 2)  return;               /*  MDA                        */

         if (BL == 2)                       /*  CGA                        */ 
          {
            strcpy (VTYPE, "CGA ");  return;
          }

         if (BL <= 5)
           {
            if (EGACGA () == 0)  return;    /*  MDA                        */

            if (EGACGA () == 1)             /*  CGA                        */
              {
                strcpy (VTYPE, "CGA ");  return;
              }

            if (EGACGA () == 3)            /*  EGA                         */ 
              {
                strcpy (VTYPE, "EGA ");  return;
              }
           }

         else
           {

            if (MCGAVGA (BL) == 2)         /*  MCGA                        */
              {
                strcpy (VTYPE, "MCGA");  return;
              }

            if (MCGAVGA (BL) == 4)        /*  VGA                          */
              {
                strcpy (VTYPE, "VGA ");  return;
              }
           }

      }

}  /*  End  CVIDEO  */

/***************************************************************
*                                                              *
*   Determining whether adapters MCGA or VGA installed         *
*                                                              *
*   Returned value:                                            *
*                                                              *
*   2  - adapter is MCGA                                       *
*                                                              *
*   4  - adapter is VGA                                        *
*                                                              *
****************************************************************/

int  MCGAVGA (char  BL)

{
     if (BL >  8)    return (2);

     else   return (4);
}

/***************************************************************
*                                                              *
*   Determining whether adapters EGA or CGA installed          *
*                                                              *
*   Returned value:                                            *
*                                                              *
*   0  - adapter is MDA                                        *
*                                                              *
*   1  - adapter is CGA                                        *
*                                                              *
*   3  - adapter is EGA                                        *
*                                                              *
****************************************************************/

int  EGACGA (void)

{

union  REGS  regs;

int  AL;

      regs.h.ah = 0x12;

      regs.h.bl = 0x10;

      regs.x.cx = 0;

      int86 (0x10, &regs, &regs);

      if (regs.x.cx != 0)  return (3);

      else
          {
              int86 (0x11, &regs, &regs);

              AL = regs.h.al & 0x30;

              if (AL == 0x30)  return (0);    /*  MDA  */

              else   return (1);
          }

}