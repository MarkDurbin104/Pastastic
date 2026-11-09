/***********************************************************************
*
*   File:           dvtram.c
*
*   Purpose:        ram test
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-26-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTRAM.C_V  $
*  
*     Rev 1.2   11 Jan 1991 17:11:04   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.1   02 Jan 1991  9:52:12   AJW
*  Added log_error calls.
*  
*     Rev 1.0   10 Dec 1990 10:14:12   PJE
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

/**************
 Definitions
**************/

#define TRUE        1
#define FALSE       0

char tmp_str[80];

/**********************
 Function Declarations 
***********************/

void steal_nmi(void);
restore_nmi(void);
unsigned test32K(int , char *);

static  int  test_ext_mem(void);
#ifdef FACTORY
extern  int   log_error (char *message);
#endif


/***********************************************************************
*
*   Function:   test_ram
*
*   Purpose:    RAM test for main and extended memory
*
*   Arguments:  none
*
*   Returns:    status (PASSED, FAILED, SKIPPED)
*
***********************************************************************/

int test_ram(void)
{
    int      i, max_segs, r, c;
    STATUS   result, resulte;
    union    REGS regs;
    unsigned status;                /* ram test return codes */
    char     chip_map[36];          /* map of chip errors */
    int      key;

    for (i = 0; i < 36; i++) chip_map[i] = 0;
    
    clear_all_windows();
    disp_title (menuopt[1]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_RAM_01], wnp);
    v_stpl ( 3, 0, text[TXT_RAM_02], wnp);

    int86(0x12, &regs, &regs);                  /* get amount of memory in k */
    max_segs = regs.x.ax / 32;                  /* convert to segments */

    cs_mv(4, 0, wnp);          /* move cursor */
    v_printf (wnp, text[TXT_RAM_03], regs.x.ax);

    steal_nmi();

    result = PASSED;

    v_stpl ( 5, 0, text[TXT_RAM_04], wnp);
    for (i = 0; (i < max_segs) && (result == PASSED); i++) {
        cs_mv(5, 20, wnp);          /* move cursor */
        v_printf (wnp, "%.3dK", (i + 1) * 32);
        status = test32K (i * 2048, chip_map);

        if (status != 0) {
            result = FAILED;
            sprintf (tmp_str, "%s    %s  %.3dK",
                     text[TXT_RAM_01], text[TXT_RAM_04], (i + 1) * 32);
#ifdef FACTORY
            log_error(tmp_str);
#endif
        }
        if (ki_chk()) {
            if (ki() == EXIT_KEY) {
                result = SKIPPED;
                v_stpl ( 3, 20, Statstr[SKIPPED], wnp);
                restore_nmi();
                delay_ticks(SHORT_DELAY);
    	   	    return (result);
            }
        }
    }

    if (result == PASSED) {
         v_stpl ( 3, 20, Statstr[PASSED], wnp);
    } else {
         v_stpl ( 3, 20, Statstr[FAILED], wnp);
    }

    resulte = test_ext_mem();
    restore_nmi();

    delay_ticks(SHORT_DELAY);

    /*------------------------------------------------------------------*/ 
    /* if result is fail, display the chip map showing the bad chips    */
    /*------------------------------------------------------------------*/ 


    if (result == FAILED || resulte == FAILED) {
        result = FAILED;
    } else if (result == SKIPPED) {
        result = SKIPPED;
    } else if (result == PASSED || resulte == SKIPPED) {
        result = PASSED;
    } else {
        result = PASSED;
    }

    return (result);
}


/***********************************************************************
*
*   Function:   test_ext_mem
*
*   Purpose:    test for extended memory
*
*   Arguments:  none
*
*   Returns:    status (PASSED, FAILED, SKIPPED)
*
***********************************************************************/

static int test_ext_mem(void)
{
    int     block;
    int     max_segs;
    int     result;
    struct  SREGS   sregs;
    union   REGS    regs;

    /* set default return value */
    result = PASSED;

    /* display header */
    v_stpl ( 7, 0, text[TXT_RAM_05], wnp);

    /* ascertain how much extended memory is resident */
    regs.h.ah = 0x88;
    int86 (0x15, &regs, &regs);

    cs_mv(8, 0, wnp);          /* move cursor */
    v_printf (wnp, text[TXT_RAM_06], regs.x.ax);
    
    /* if no extended memory is present, skip the test */
    if (regs.x.ax == 0)
    {
        result = SKIPPED;
    }

    /* otherwise, test it */
    else
    {
        /* divide into 32K blocks for test */
        max_segs = regs.x.ax / 32;                  /* convert to 32 KB blocks   */

        v_stpl ( 9, 0, text[TXT_RAM_04], wnp);
        /* test each 32K block of extended memory */
        for (block = 0;  (block < max_segs) && (result == PASSED); block++)
        {
            cs_mv(9, 24, wnp);          /* move cursor */
            v_printf (wnp, "%.4dK", (block + 1) * 32);

            if (test_extended(block) != TRUE) {
                result = FAILED;
                sprintf (tmp_str, "%s    %s  %.3dK",
                         text[TXT_RAM_05], text[TXT_RAM_04], (block + 1) * 32);
#ifdef FACTORY
                log_error(tmp_str);
#endif
            }
        }
    }    
    if (result == PASSED) {
         v_stpl ( 7, 24, Statstr[PASSED], wnp);
    } else if (result == FAILED) {
         v_stpl ( 7, 24, Statstr[FAILED], wnp);
    } else {
         v_stpl ( 7, 16, Statstr[SKIPPED], wnp);
    }
    return(result);
}  

