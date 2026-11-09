/***********************************************************************
*
*   File:           dvtfixed.c
*
*   Purpose:        fixed disk tests
*
*   Author:         Andrew Wnuk
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 12-14-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTFIXED.C_V  $
*  
*     Rev 1.3   11 Jan 1991 17:33:54   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.2   02 Jan 1991 10:02:28   AJW
*  Added log_error calls.
*  
*     Rev 1.1   14 Dec 1990 11:17:56   AJW
*  Transfered to work with new interface on DISK.C
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>
#include <malloc.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"


/**********
 Defines
**********/

#define  DEFAULT_SECTOR_SIZE  512
// TRUE  defined in VV_SYS.H as 1
// FALSE defined in VV_SYS.H as 0
#define  OUT_OF_MEM      (-2)
#define  OK                0
#define  HARD_DISK_0       0x80

struct T_DISK_INFO {
    uint  max_cyl_no;
    uint  max_sector_no;
    uint  max_no_heads;
};

extern   struct  T_DISK_INFO  disk_info;

char tmp_str[80];


/**********
 Functions
**********/

extern   int get_disk_info(uint drive);

extern   int check_drive(uint drive);

extern   int read_sectors (uint drive, uint head, uint cylinder, 
                           uint start_sector, uint no_of_sectors,
                           char far *sectors_buffer);

extern   int read_cylinder (uint drive, uint cylinder, 
                            char far *cylinder_buffer);

extern   int write_sectors (uint drive, uint head, uint cylinder, 
                            uint start_sector, uint no_of_sectors,
                            char far *sectors_buffer, uint pflag);

extern   int write_cylinder (uint drive, uint cylinder, 
                             char far *cylinder_buffer);

extern   int format_track (uint drive, uint head, uint cylinder);

#ifdef FACTORY
extern   int log_error (char *message);
#endif


/**************************************************************************
*
*    function:          test_fdread()
*
*    purpose:           read 1 sector of last cylinder on fixed drive 0 
*
*    arguments:         none
*
*    returns:           int
*
*                       PASSED if test passed
*                       FAILED, if test failed
*                       SKIPPED if test was skipped
*
***************************************************************************/

int test_fdread()

{
    uint         i;
    STATUS       result;
    char far     *sector_buffer;

    clear_all_windows();
    disp_title (menuopt[13]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FIX_01], wnp);

    result = SKIPPED;

    if (Location == CT) {
       v_printf(wnp, text[TXT_FIX_07], Statstr[SKIPPED]);
       delay_ticks (SHORT_DELAY);
       return(result);
    }

    if (!check_drive(HARD_DISK_0)) {
        delay_ticks (SHORT_DELAY);
        return(SKIPPED);
    }

    if (get_disk_info(HARD_DISK_0)) 
        return(FAILED);

    /* allocate buffer space */
    sector_buffer = _fmalloc(DEFAULT_SECTOR_SIZE);

    /* if buffer space allocated successfully, proceed with read test */
    if (sector_buffer != NULL) 
    {
        cs_mv(8, 0, wnp);          /* move cursor */
        /* for each head (reported offset 0) */
        for (i = 0; i <= disk_info.max_no_heads; i++)
        {
            v_printf (wnp, text[TXT_FIX_02], i);

            if (read_sectors (HARD_DISK_0, i, (disk_info.max_cyl_no)+1, 
                              1, 1, sector_buffer)) {
                result = FAILED;
                v_st (Statstr[FAILED], wnp);
                sprintf (tmp_str, text[TXT_FIX_02], i);
#ifdef FACTORY
                log_error (tmp_str);
#endif
                break;
            } else {   /* otherwise, read passed */
                result = PASSED;
                v_st (Statstr[PASSED], wnp);
            }

            /* short delay so user can read results */
            delay_ticks (SHORT_DELAY/4);
        }

        /* free allocated buffer */
        _ffree(sector_buffer);       

    }

    /* otherwise, buffer memory allocation error, so skip read test */
    else
    {
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

/**************************************************************************
*
*     function:         test_fdwrite()
*
*     purpose:          write 1 sectore of last cylinder on fixed drive 0 
*
*     arguments:        none
*
*     returns:          int
*
*                       PASSED if test passed
*                       FAILED, if test failed
*                       SKIPPED if test was skipped
*
***************************************************************************/

int test_fdwrite()

{
    UINT         i;
    STATUS       result;
    BOOLEAN      not_saved;
    char far     *sector_buffer;

    clear_all_windows();
    disp_title (menuopt[14]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FIX_03], wnp);

    result = SKIPPED;

    if (Location == CT) {
       v_printf(wnp, text[TXT_FIX_07], Statstr[SKIPPED]);
       delay_ticks (SHORT_DELAY);
       return(result);
    }

    if (!check_drive(HARD_DISK_0)) {
        delay_ticks (SHORT_DELAY);
        return(SKIPPED);
    }

    if (get_disk_info(HARD_DISK_0)) 
        return(FAILED);

    /* allocate buffer space */
    sector_buffer = _fmalloc(DEFAULT_SECTOR_SIZE);

    /* if buffer space allocated successfully, proceed with write test */
    if (sector_buffer != NULL) 
    {
        cs_mv(8, 0, wnp);          /* move cursor */
        /* for each head (reported offset 0) */
        for (i = 0; i <= disk_info.max_no_heads; i++)
        {
            v_printf (wnp, text[TXT_FIX_04], i);

            if (write_sectors (HARD_DISK_0, i, (disk_info.max_cyl_no)+1,
                               1, 1, sector_buffer, 0)) {
                result = FAILED;
                v_st (Statstr[FAILED], wnp);
                sprintf (tmp_str, text[TXT_FIX_04], i);
#ifdef FACTORY
                log_error (tmp_str);
#endif
                break;
            } else {    /* otherwise, write passed */
                result = PASSED;
                v_st (Statstr[PASSED], wnp);
            }

            /* short delay so user can read results */
            delay_ticks (SHORT_DELAY/4);
        }

        /* free allocated buffer */
        _ffree(sector_buffer);       

    }

    /* otherwise, buffer memory allocation error, so skip write test */
    else
    {
        disp_error (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

/**************************************************************************
*
*     function:         test_fdformat()
*
*     purpose:          write 1 sectore of last cylinder on fixed drive 0 
*
*     arguments:        none
*
*     returns:          int
*
*                       PASSED if test passed
*                       FAILED, if test failed
*                       SKIPPED if test was skipped
*
***************************************************************************/

int test_fdformat()

{
    UINT         i, l, k;
    UINT         mem_size;
    STATUS       result;
    int          format_result;
    BOOLEAN      not_saved;
    char far     *cylinder_buffer;    // cylinder buffer

    clear_all_windows(); 
    disp_title (menuopt[15]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FIX_05], wnp);

    if (Location == CT) {
       v_printf(wnp, text[TXT_FIX_07], Statstr[SKIPPED]);
       delay_ticks (SHORT_DELAY);
       return(SKIPPED);
    }

    if (!check_drive(HARD_DISK_0)) {
        delay_ticks (SHORT_DELAY);
        return(SKIPPED);
    }

    if (get_disk_info(HARD_DISK_0)) 
        return(FAILED);

    /* allocate buffer space */
    mem_size = (disk_info.max_sector_no) * 
               (disk_info.max_no_heads + 1) * 
               DEFAULT_SECTOR_SIZE;
    cylinder_buffer = _fmalloc( mem_size );

    /* if buffer space allocated successfully, proceed with write test */
    if (cylinder_buffer != NULL) 
    {
        cs_mv(8, 0, wnp);          /* move cursor */

        result = PASSED;

        /* for each head (reported offset 0) */
        for (i = 0; i <= disk_info.max_no_heads; i++)
        {
            v_printf (wnp, text[TXT_FIX_06], i);

            format_result = format_track (HARD_DISK_0, i, 
                                          disk_info.max_cyl_no + 1);
            if (format_result == OK) {
                v_st (Statstr[PASSED], wnp);
            } else if (format_result == OUT_OF_MEM) {
                v_st (Statstr[SKIPPED], wnp);
                if (result != FAILED) result = SKIPPED;
                break;
            } else {
                v_st (Statstr[FAILED], wnp);
                result = FAILED;
                sprintf (tmp_str, text[TXT_FIX_06], i);
#ifdef FACTORY
                log_error (tmp_str);
#endif
                break;
            }
        
            /* short delay so user can read results */
            delay_ticks (SHORT_DELAY/4);
        }

        /* free allocated buffer */
        _ffree(cylinder_buffer);       

    }

    /* otherwise, buffer memory allocation error, so skip write test */
    else
    {
        disp_error (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

