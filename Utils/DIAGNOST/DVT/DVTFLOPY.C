/***********************************************************************
*
*   File:           dvtflopy.c
*
*   Purpose:        floppy disk tests
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTFLOPY.C_V  $
*  
*     Rev 1.5   08 Feb 1991  8:56:46   PJE
*  Changed method of disk_change detection to use disk change indicator
*  in floppy adapter.  This causes less wear on the drive/diskette.
*  
*     Rev 1.4   14 Jan 1991 15:48:44   AJW
*  Improvements of user interface.
*  
*     Rev 1.3   11 Jan 1991 17:28:46   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.2   02 Jan 1991  9:57:54   AJW
*  Added log_error calls.
*  
*     Rev 1.1   14 Dec 1990 11:11:20   AJW
*  Many changes to save data
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>
#include <malloc.h>
#include <conio.h>
#include <bios.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"

/**********************************************************************
*
*   Definitions
*
***********************************************************************/

#define FC_DOR      0x03F2  /* Floppy Controller Digital Output Register    */
#define FC_COMMAND  0x03F5  /* Floppy Controller Command Register           */
#define FC_COMSTAT  0x03F4  /* Floppy Controller Command Status Reg         */
#define FC_STATUS   0x03F7  /* Floppy Controller Status                     */
#define MOTORON     0x14    /* command byte to turn motor of Drive A on     */
#define MOTOROFF    0x00    /* command byte to turn motor off               */

#define BIOSSEG         (0x40<<4)       /* address of BIOS data segment     */
#define BIOSMOTORCOUNT  (0x40)          /* BIOS data offset of motor count  */
#define BIOSMOTORSTATUS (0x3F)          /* BIOS data offset of motor status */

#define CHANGED_FLAG    (0x80)          /* high bit set                     */

#define  DEFAULT_SECTOR_SIZE  512
#define  OUT_OF_MEM      (-2)
#define  OK                0
#define  WRITE_PROTECTION  3
#define  FLOPPY_DISK_0     0x00


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
extern   int   log_error (char *message);
#endif


/**************************************************************************
*
*     function:         test_flformat()
*
*     purpose:          format last cylinder on flopy drive 0 
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

int test_flformat(void)
{
    int          key;
    UINT         mem_size;
    UINT         off_tr;
    UINT         seg_tr;
    int          i, format_result;
    STATUS       result;
    BOOLEAN      not_saved;
    char far     *cylinder_buffer;    // cylinder buffer

    clear_all_windows();
    disp_title (menuopt[5]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FLP_01], wnp);

    result = PASSED;

    if (get_disk_info(FLOPPY_DISK_0)) {
        return(FAILED);
    }

    /* allocate buffer space */
    mem_size = (disk_info.max_sector_no) *
               (disk_info.max_no_heads + 1) * 
               DEFAULT_SECTOR_SIZE;
    cylinder_buffer = _fmalloc( mem_size);

    /* if buffer space allocated successfully, proceed with write test */
    if (cylinder_buffer != NULL) 
    {
         cs_mv(8, 0, wnp);          /* move cursor */
         not_saved = read_cylinder(FLOPPY_DISK_0, disk_info.max_cyl_no,
                                   cylinder_buffer);
         if (not_saved) {
               log_error("Fail SAVE");
               v_st(text[TXT_FLP_19], wnp);
               if (disp_exit (text[TXT_FLP_17], text[TXT_FLP_18],
                              ENTER_MASK | VOID_MASK) == VOID_KEY) {
                  result = SKIPPED;
               }
         }

         for (i = 0; i <= disk_info.max_no_heads; i++)
         {
            v_printf (wnp, text[TXT_FLP_02], i);

            format_result = format_track (FLOPPY_DISK_0, i,
                                          disk_info.max_cyl_no);
            if (format_result == OK) {
                  v_st (Statstr[PASSED], wnp);
            } else if (format_result == OUT_OF_MEM) {
                  log_error("Fail OMEMORY");
                  v_st (Statstr[SKIPPED], wnp);
                  if (result != FAILED) result = SKIPPED;
                  break;
            } else {
                  log_error("Fail OTHER");
                  v_st (Statstr[FAILED], wnp);
                  sprintf (tmp_str, text[TXT_FLP_02], i);
#ifdef FACTORY
                  log_error (tmp_str);
#endif
                  result = FAILED;
                  break;
            }
         }
        
         if (!not_saved)
             if (write_cylinder (FLOPPY_DISK_0, disk_info.max_cyl_no,
                                 cylinder_buffer))
                  v_st(text[TXT_FLP_20], wnp);

         /* free allocated buffer */
         _ffree(cylinder_buffer);
    }

    /* otherwise, buffer memory allocation error, so skip write test */
    else
    {
        log_error("Fail MEMORY");
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

/**************************************************************************
*
*     function:         test_flwrite()
*
*     purpose:          write 1 sectore of last cylinder on floppy drive 0 
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

int test_flwrite()
{
    UINT         i, k;
    STATUS       result;
    BOOLEAN      not_saved;
    char far     *sector_buffer;

    clear_all_windows();
    disp_title (menuopt[6]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FLP_03], wnp);

    result = SKIPPED;

    if (get_disk_info(FLOPPY_DISK_0)) 
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
            not_saved = read_sectors (FLOPPY_DISK_0, i, disk_info.max_cyl_no, 
                                      1, 1, sector_buffer);
            if (not_saved) {
                v_st(text[TXT_FLP_19], wnp);
                if (disp_exit (text[TXT_FLP_17], text[TXT_FLP_18],
                                ENTER_MASK | VOID_MASK) == VOID_KEY) {
                    result = SKIPPED;
                    break;
                }
            }

            v_printf (wnp, text[TXT_FLP_04], i);

            if (write_sectors (FLOPPY_DISK_0, i, disk_info.max_cyl_no,
                               1, 1, sector_buffer, 0)) {
                result = FAILED;
                v_st (Statstr[FAILED], wnp);
                sprintf (tmp_str, text[TXT_FLP_04], i);
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
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

/**************************************************************************
*
*    function:          test_flread()
*
*    purpose:           read 1 sector of last cylinder on floppy drive 0 
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

int test_flread()
{
    UINT         i;
    STATUS       result;
    char far     *sector_buffer;

    clear_all_windows();
    disp_title (menuopt[7]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FLP_05], wnp);

    result = SKIPPED;

    if (get_disk_info(FLOPPY_DISK_0)) 
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
            v_printf (wnp, text[TXT_FLP_06], i);

            if (read_sectors (FLOPPY_DISK_0, i, disk_info.max_cyl_no,
                              1, 1, sector_buffer)) {
                result = FAILED;
                v_st (Statstr[FAILED], wnp);
                sprintf (tmp_str, text[TXT_FLP_06], i);
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
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    delay_ticks (SHORT_DELAY);

    return(result);
}

/*************************************************************************
*
*     function:               test_flprotect()
*
*     purpose:                prompt user sets write-protect tab, 
*                             then attempt write 
*
*     arguments:              none
*
*     returns:                short
*
*                             PASSED if test passed
*                             FAILED, if test failed
*                             SKIPPED if test was skipped
*
**************************************************************************/

int test_flprotect()
{
    int          key;
    UINT         k;
    STATUS       result;
    char far     *sector_buffer;
    BOOLEAN      not_saved, not_protected;

    clear_all_windows();
    disp_title (menuopt[8]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FLP_07], wnp);

    result = SKIPPED;

    if (get_disk_info(FLOPPY_DISK_0)) 
        return(FAILED);

    /* allocate buffer space */
    sector_buffer = _fmalloc(DEFAULT_SECTOR_SIZE);

    /* if buffer space allocated successfully, proceed with write test */
    if (sector_buffer != NULL) 
    {
        while (ki_chk())                /* flush keyboard buffer */
            ki();
        key = disp_exit(text[TXT_FLP_15], text[TXT_FLP_16],
                        ENTER_MASK | VOID_MASK);
        if (key == VOID_KEY || key == 0) {
           cs_mv(8, 0, wnp);          /* move cursor */
           v_st (text[TXT_FLP_08], wnp);
           v_st (Statstr[SKIPPED], wnp);
           delay_ticks(SHORT_DELAY);
           _ffree(sector_buffer);       
           return(SKIPPED);
        }

        wn_clr(inst_wnp);
        disp_inst(NULL, NULL);

        cs_mv(8, 0, wnp);          /* move cursor */

        not_saved = read_sectors (FLOPPY_DISK_0, 0, disk_info.max_cyl_no, 
                                  1, 1, sector_buffer);
        if (not_saved) {
            v_st(text[TXT_FLP_19], wnp);
            if (disp_exit (text[TXT_FLP_17], text[TXT_FLP_18],
                            ENTER_MASK | VOID_MASK) == VOID_KEY) {
                _ffree(sector_buffer);       
                return (SKIPPED);
            }
        }

        v_st (text[TXT_FLP_08], wnp);

        if (write_sectors (FLOPPY_DISK_0, 0, disk_info.max_cyl_no,
                           1, 1, sector_buffer, 1) == WRITE_PROTECTION) {
            result = PASSED;
            v_st (Statstr[PASSED], wnp);
            v_st (text[TXT_FLP_09], wnp);
        } else {    /* otherwise, protection failed */
            result = FAILED;
            v_st (Statstr[FAILED], wnp);
            v_st (text[TXT_FLP_10], wnp);
        }

        /* free allocated buffer */
        _ffree(sector_buffer);       

    }

    /* otherwise, buffer memory allocation error, so skip write test */
    else
    {
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        result = SKIPPED;
    }

    disp_exit(text[TXT_FLP_21], text[TXT_FLP_17],ENTER_MASK);

    delay_ticks (SHORT_DELAY);

    return(result);
}

/***********************************************************************
*
*   FUNCTION HEADER
*
*   Function Name:      disk_change
*
*   Synopsis:           BOOLEAN disk_change (VOID );
*
*   Input:              none
*
*   Output:             none
*
*   Returns:            TRUE or FALSE
*
*   Description:        This function detects if the floppy disk in
*                       disk drive A: has been removed since the last
*                       access.
*
***********************************************************************/
BOOLEAN disk_change ()
{
    auto int status;
    auto BOOLEAN changedstatus = FALSE;
    auto byte *biosmotorcount;  /* time till motor switches off in ticks    */
    auto byte *biosmotorstatus; /* 4 lower bits indicate that motor is on   */

    /*  set pointers to the BIOS data bytes of interest             */

    biosmotorcount  = (byte *)(BIOSSEG+BIOSMOTORCOUNT);

    /*  biosmotorcount:
     *  This byte contains a numerical value which indicates the time
     *  period until a disk drive motor switches off.  Since BIOS can
     *  only access one disk at a time, this value refers to the drive
     *  last accessed.  Following access to this drive, BIOS places the
     *  value 37 into this register.  Durign every timer interrupt,
     *  the value in this byte is decremented by 1.  When it finally
     *  reaches 0, the disk motor is turned off.
     */

    biosmotorstatus = (byte *)(BIOSSEG+BIOSMOTORSTATUS);

    /*  biosmotorstatus:
     *  The four lower bits of this byte indicate whether the current
     *  disk drive motor is in motion.  A 1 in the corresponding bit
     *  indicates this.  In addition, bit 7 is always set when write
     *  access is in progress.
     */

    /*  test for disk change status                                 */

    _disable();                 /* disable interrupts               */
    outp (FC_DOR, MOTORON);     /* turn on drive motor              */
    status = inp(FC_STATUS);    /* read status                      */
    outp (FC_DOR, MOTOROFF);    /* turn on drive motor              */
    *biosmotorcount = 0;        /* turn off drive immediately       */
    *biosmotorstatus &= 0xf0;   /* indicate motor is off to BIOS    */
    _enable();                  /* re-enable interrupts */


    if (status & CHANGED_FLAG)  /* if disk has been changed         */
        changedstatus = TRUE;

    return (changedstatus);

}

/****************************************************************************
*
*     function:               test_flchange()
*
*     purpose:                Diskette change tests
*
*     arguments:              none
*
*     returns:                short
*
*                             PASSED if test passed
*                             FAILED, if test failed
*                             SKIPPED if test was skipped
*
****************************************************************************/

int test_flchange()
{
    int          key, time_to_wait;
    UINT         i;
    STATUS       result;

    clear_all_windows();
    disp_title (menuopt[9]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_FLP_12], wnp);

    while (ki_chk())                /* flush keyboard buffer */
        ki();

    v_st (text[TXT_FLP_13], wnp);
    disp_inst(text[TXT_FLP_14], NULL);

    result  = FAILED;
    time_to_wait = IDLE_TIME;

    access ("A:\AUTOEXEC.BAT", 0);  /* just do a valid access of the drive */

    do {
        if (disk_change())
        {
            result = PASSED;
            break;
        }
        delay_ticks ( 1 );
        if (ki_chk()) {
            if (ki() == VOID_KEY) {
                result = SKIPPED;
                v_st (Statstr[SKIPPED], wnp);
                break;
            }
        }
    } while (--time_to_wait > 0); 

    wn_clr(inst_wnp);
    disp_inst(NULL, NULL);
    if (result == PASSED) {                               
        v_st (Statstr[PASSED], wnp);
    } else if (result == FAILED) {
        v_st (Statstr[FAILED], wnp);
    }
    delay_ticks (SHORT_DELAY);

    return(result);
}













