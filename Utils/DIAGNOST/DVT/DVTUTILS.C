/***********************************************************************
*
*   File:           dvtutils.c
*
*   Purpose:        utilities for dvt
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-23-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTUTILS.C_V  $
*  
*     Rev 1.0   10 Dec 1990 10:11:42   PJE
*  Initial revision.
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>
#include "eccodefs.h"

/**
*   CSU:        is_mos
*
*   purpose:    Informs the program whether MOS is the operating
*               system running, or DOS.  This call is useful to
*               envelope around MOS-specific functions and calls
*               so that initial testing can be done on the development
*               systems running DOS.
*
*   inputs:     none
*
*   outputs:    TRUE if operating system is PC-MOS
*               FALSE if operating system is DOS
*
**/
int ismos (void)
{
    union REGS regs;
    int ax;

    regs.x.dx=regs.x.cx=regs.x.bx=regs.x.ax=0x3000;
    intdos(&regs,&regs);
    ax=regs.x.ax;
    regs.x.ax=0x30ff;             /* Make AX different */
    intdos(&regs,&regs);

    return(ax!=regs.x.ax);       /* If different, then MOS, else DOS */
}
int mos_sleep (unsigned int ticks)
{
    union REGS regs;
    
    regs.x.ax=0x0702;
    regs.x.bx=ticks;
    int86(0xD4,&regs,&regs);

    if (regs.x.cflag) return(regs.x.ax);

    return(0);
}
int dos_sleep (unsigned int ticks)
{
    union REGS regs;
    long hi, lo;
    long tick_val, tick_limit;

    regs.h.ah = 0x00;       /* read timer count */

    int86 (0x1A, &regs, &regs);

    /* extract the returned values */
    hi = (long)regs.x.cx;
    lo = (long)regs.x.dx;

    tick_val = (lo + hi*65535);
    tick_limit = tick_val + ticks;

    do
    {
        regs.h.ah = 0x00;       /* read timer count */

        int86 (0x1A, &regs, &regs);

        hi = (long)regs.x.cx;
        lo = (long)regs.x.dx;

        tick_val = (lo + hi*65535);
    }
    while (tick_val < tick_limit);

    return (0);
}
/**
*
*   CSU:        delay_ticks
*
*   purpose:    This function is provided simply to allow a
*               substitute for the mos_sleep call when testing
*               under the DOS operating system.
*
*   inputs:     ticks to sleep
*
*   outputs:    0
*
**/
void delay_ticks(unsigned int ticks)
{
    if (ismos())
        mos_sleep(ticks);
    else
        dos_sleep(ticks);
}
/***********************************************************************
*
*   Function:   key_or_timeout
*
*   Purpose:    gets a key or a timeout
*
*   Arguments:  timeout value in ticks
*
*   Returns:    Vermont Views key value or 0 if timeout
*
***********************************************************************/
int key_or_timeout (int ticks)
{

    while ((!ki_chk()) && (ticks!=0)) {
        delay_ticks(1);
        ticks--;
    }

    if (ticks) return(ki());

    return(0);
}


/**
*
*        function:        time_stamp
*
*        purpose:        return system date and time
*
*        arguments:        ptrs to storage for date and time
*
*        returns:        nothing
*
**/


void time_stamp(date, time, day)

DATE *date, *day;
TIME *time;

{
    int    flags;
    union REGS regs;

    regs.h.ah = 0x2A;                    /* Get Date                  */
    flags = intdos(&regs, &regs);
    *date = regs.x.cx % 100;            /* Year                 */
    *date = (10000 * *date) + (100 * regs.h.dh) + regs.h.dl;
    *day  = regs.h.al;

    regs.h.ah = 0x2C;                    /* Get Time             */
    flags = intdos(&regs, &regs);
    *time = regs.h.ch;                    /* Hour                 */
    *time = (10000 * *time) + (100 * regs.h.cl) + regs.h.dh;

}


