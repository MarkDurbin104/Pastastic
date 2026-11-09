/***********************************************************************
*
*   File:           dvtrom.c
*
*   Purpose:        rom checksum test
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTROM.C_V  $
*  
*     Rev 1.2   11 Jan 1991 17:07:20   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.1   02 Jan 1991  9:46:12   AJW
*  Added log_error calls.
*  
*     Rev 1.0   10 Dec 1990 10:13:02   PJE
*  Initial revision.
*
***********************************************************************/


/**************
 Include Files            
***************/

#include <dos.h>
#include <stdlib.h>
#include <malloc.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"

#define ROM_LENGTH_TO_VER  65536L          /* 64K ROM */
//#define ROM_LENGTH_TO_VER  32768L           /* 32K ROM */

#ifdef FACTORY
extern  int   log_error (char *message);
#endif

/***********************************************************************
*
*   Function:   test_rom
*
*   Purpose:    ROM checksum test
*
*   Arguments:  none
*
*   Returns:    status (PASSED, FAILED, SKIPPED)
*
***********************************************************************/

int test_rom(void)
{
    unsigned char far *ptr;
    unsigned char checksum;
    unsigned long i;
    STATUS   result;
    char     tmp_str[80];

    result = PASSED;       /* default to PASS */

    clear_all_windows();
    disp_title (menuopt[0]);
    disp_inst (NULL, NULL);
    
    v_stpl ( 1, 0, text[TXT_ROM_01], wnp);

//    ptr = (unsigned char far *)(0xF8000000L);   /* start address */
    ptr = (unsigned char far *)(0xF0000000L);   /* start address */

    for (i = 0, checksum = 0; i < ROM_LENGTH_TO_VER; i++) {
            checksum += *ptr;
            ptr++;
    }

    if (checksum != 0) {
        cs_mv(2, 1, wnp);          /* move cursor to beginning */
        v_printf(wnp, text[TXT_ROM_02], checksum);
        v_stpl ( 1, 15, Statstr[FAILED], wnp);
        if (Location != CT)
            beep_vv(20,1200);
        else
            kbd_buzz();
        sprintf(tmp_str, "%s     CS = 0x%04x", text[TXT_ROM_01], checksum);
#ifdef FACTORY
        log_error(tmp_str);
#endif
        result = FAILED;
    } else {
        v_stpl ( 1, 15, Statstr[PASSED], wnp);
    }

    delay_ticks(SHORT_DELAY);

    return(result);
}
