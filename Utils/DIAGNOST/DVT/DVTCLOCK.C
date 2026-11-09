/***********************************************************************
*
*   File:           dvtclock.c
*
*   Purpose:        clock test
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-30-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTCLOCK.C_V  $
*  
*     Rev 1.1   11 Jan 1991 17:22:36   AJW
*  Small upgrade
*  
*     Rev 1.0   10 Dec 1990 10:33:26   PJE
*  Initial revision.
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"

#define CMOS_SEC   0x00        /* CMOS RAM Real-time clock seconds */

/*************************************************************************
*
*               function:               test_clock()
*
*               purpose:                check out motherboards clock
*
*               arguments:              none
*
*               returns:                short
*
*                                       PASSED if test passed
*                                       FAILED, if test failed
*                                       SKIPPED if test was skipped
*
*************************************************************************/

int test_clock()
{
    long il;
    int new_sec, old_sec;
    TIME    current_time;
    DATE    date;
    DATE    day;
    STATUS  result;
    union   REGS regs;

    result = FAILED;                    /* assume we're going to fail this test <EAS> */

    /*  Display the banner      */

    clear_all_windows();
    disp_title (menuopt[10]);
    disp_inst (NULL, NULL);

    /*  Now test the clock      */

    v_stpl ( 1, 0, text[TXT_CLOCK_01], wnp);
    time_stamp (&date, &current_time, &day);
    
    v_printf(wnp, text[TXT_CLOCK_02],
             date/10000L, (date%10000L)/100L, date%100L); 
    v_printf(wnp, text[TXT_CLOCK_03], current_time/10000L,
             (current_time%10000L)/100L, current_time%100L); 

/* If compiling for 2050 get seconds from CMOS */
    old_sec = get_cmos(CMOS_SEC);       /* Read seconds value */
    for (il=0L; il < 300000L; il++) {
        new_sec = get_cmos(CMOS_SEC);   /* Read seconds value again */
        if (new_sec != old_sec) {
            result = PASSED;
            break;
        }
    }
    if (result == PASSED)
       v_stpl ( 1, 15, Statstr[PASSED], wnp);
    else
       v_stpl ( 1, 15, Statstr[FAILED], wnp);

    delay_ticks (SHORT_DELAY);

    return(result);
}


