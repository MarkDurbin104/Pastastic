/***********************************************************************
*
*   File:           disk.c
*
*   Purpose:        disk functions
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DISK.C_V  $
*  
*     Rev 1.1   11 Jan 1991 17:44:22   AJW
*  Small upgrade.
*  
*     Rev 1.0   14 Dec 1990 11:22:10   AJW
*  
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
#if 0
#define RESET               0x00    /* see INT13 BIOS spec for these codes */
#define READ                0x02
#define WRITE               0x03
#define VERIFY              0x04
#define FORMAT              0x05
#define GETPARAMS           0x08
#define MEDIA               0x18

#define RETRY               5       /* retry count before aborting disk command -- same value as DOS */

#define HIDDEN_TRACK        80      /* CTD status hidden on this track */
#define HIDDEN_SECTOR       1       /* .. and sector */
#define HIDDEN_SIDE         0       /* .. and side */

#define BYTES_PER_SECT      512     /* standard for DOS */
#define CODE_512            0x02    /* sector size code -- 512 bytes/sect */

#define M_SEG(x)      ((UINT)(((ULONG)((void _far *)(x))) >> 16))
#define M_OFF(x)      ((UINT)((ULONG)((void _far *)(x))))

typedef struct
{
    unsigned char track;
    unsigned char head;
    unsigned char sector;
    unsigned char size_code;
} ADDRFLDLIST;
#endif

#define  DEFAULT_SECTOR_SIZE  512
// TRUE  defined in VV_SYS.H as 1
// FALSE defined in VV_SYS.H as 0
#define  OUT_OF_MEM      (-2)
#define  OK                0
#define  WRITE_PROTECTION  3
#define  RESET_NO          7
#define  DISK_IO_NO        5

static   char  tmp_buf1[80];
static   char  tmp_buf2[80];

struct T_DISK_INFO {
    uint  max_cyl_no;
    uint  max_sector_no;
    uint  max_no_heads;
} disk_info;

/**********
 Functions
**********/

int get_disk_info(uint drive);

int check_drive(uint drive);

int read_sectors (uint drive, uint head, uint cylinder, 
                  uint start_sector, uint no_of_sectors,
                  char far *sectors_buffer);

int read_cylinder (uint drive, uint cylinder, 
                   char far *cylinder_buffer);

int write_sectors (uint drive, uint head, uint cylinder, 
                   uint start_sector, uint no_of_sectors,
                   char far *sectors_buffer, uint pflag);

int write_cylinder (uint drive, uint cylinder, 
                    char far *cylinder_buffer);

int format_track (uint drive, uint head, uint cylinder);


/**************************************************************************
*
*     function:         get_disk_info()
*
*     purpose:          getting informafion about disk 
*
*     arguments:        none
*
*     returns:          int
*
*                       0           if you get info
*                       error code  otherwise 
*
***************************************************************************/

int get_disk_info(uint drive)
{
    int      i, j;
    BOOLEAN  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = FALSE;

    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

        /* reset disk drive */
        inregs.h.ah = 0x00;           /* function 0x00 (reset drive) */
        inregs.h.dl = drive & 0xff;   /* disk drive */

        /* interrupt 13 */
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;
            /* get floppy disk drive parameters */
            inregs.h.ah = 0x08;          /* function 0x8 (get drive parameters) */
            inregs.h.dl = drive & 0xff;  /* disk drive */

            /* interrupt 13 */
            int86(0x13, &inregs, &outregs);

            /* if error, report error number */
            if (outregs.x.cflag == 0)
            {
                done = TRUE;

                /* add 1 to reported max cylinder number as reserved cylinder is not */
                /* reported */

                disk_info.max_cyl_no = (((outregs.h.cl & 0xc0) << 2) | outregs.h.ch); // + 1;
                disk_info.max_sector_no = outregs.h.cl & 0x3f;
                disk_info.max_no_heads = outregs.h.dh;
                v_printf(wnp, text[TXT_DRV_08], drive, 
                                                (disk_info.max_no_heads)+1,
                                                (disk_info.max_cyl_no)+1,
                                                disk_info.max_sector_no);
            }
        }
    }

    if (!done) {
        sprintf(tmp_buf1, text[TXT_DRV_01], outregs.h.ah);
        disp_exit (tmp_buf1, NULL, ANY_MASK);
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}

/**************************************************************************
*
*     function:         check_drive()
*
*     purpose:          getting informafion if disk is present
*
*     arguments:        none
*
*     returns:          int
*
*                       0           if you get info
*                       error code  otherwise 
*
***************************************************************************/

int check_drive(uint drive)
{
    int      i, j;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;


    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO; i++) {

        /* reset disk drive */
        inregs.h.ah = 0x00;           /* function 0x00 (reset drive) */
        inregs.h.dl = drive & 0xff;   /* disk drive */

        /* interrupt 13 */
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;
            /* get floppy disk drive parameters */
            inregs.h.ah = 0x15;          /* function 0x15 (check drive) */
            inregs.h.dl = drive & 0xff;  /* disk drive */

            /* interrupt 13 */
            int86(0x13, &inregs, &outregs);

            /* if error, report error number */
            if (outregs.x.cflag == 0)
            {
                if (outregs.h.ah == 0) {
                    return (FALSE);
                    if (drive == 0x80) {
                       v_st(text[TXT_DRV_09], wnp);
                    }
                } else if ((outregs.h.ah == 1 || outregs.h.ah == 2) && drive == 0) {
                    return (TRUE);
                } else if (outregs.h.ah == 3 && drive == 0x80) {
                    return (TRUE);
                } else {
                    return (FALSE);
                }
            }
        }
    }

    if (drive == 0x80) {
       v_st(text[TXT_DRV_09], wnp);
    }

    return (FALSE);
}

/**************************************************************************
*
*     function:         read_sectors()
*
*     purpose:          read sector form disk
*
*     arguments:        drive, head, cylinder, start_sector, no_of_sectors,
*                       sectors_buffer
*
*     returns:          int
*
*                       0           if sectors are read
*                       error code  otherwise 
*
***************************************************************************/

int read_sectors (uint drive, uint head, uint cylinder, 
                  uint start_sector, uint no_of_sectors,
                  char far *sectors_buffer)
{
    int      i, j;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    BOOLEAN  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = FALSE;

    if (head > disk_info.max_no_heads ||
        cylinder > disk_info.max_cyl_no + 1 ||
        start_sector > disk_info.max_sector_no ||
        no_of_sectors > disk_info.max_sector_no) 
    {
       sprintf(tmp_buf1, text[TXT_DRV_03], 
               head, cylinder, start_sector, no_of_sectors);
       disp_exit (text[TXT_DRV_02], tmp_buf1, ANY_MASK);
       return (1);
    }

    /* isolate most significant 2 bits of 10-bit cylinder number and shift */
    /* them into the upper two bits of a byte in preparation for oring with */
    /* sector number for CL register for write operation */

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    /* get segment and offset of buffer pointer */
    seg_buf = FP_SEG(sectors_buffer);
    off_buf = FP_OFF(sectors_buffer);
    off_4 = off_buf;
    seg_buf += ((off_4 >> 4) & 0x0FFF);
    off_buf = (off_buf & 0x000F);
    segread(&segregs);

    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

        /* reset floppy disk drive */
        inregs.h.ah = 0x00;   /* function 0x00 (reset drive) */
        inregs.h.dl = 0x00;   /* floppy disk drive 0 */

        /* interrupt 13 */
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;

            /* read sectors */
            inregs.h.ah = 0x02;                       /* read function     */
            inregs.h.al = no_of_sectors;              /* number of sectors */
            inregs.h.ch = cylinder & 0xff;            /* cylinder number   */
            inregs.h.cl = start_sector | ms2b_cyl_no; /* sector number     */
            inregs.h.dh = (char)(head & 0xff);        /* head number       */
            inregs.h.dl = drive & 0xff;               /* drive number      */
            segregs.es  = seg_buf;                    /* segment of buffer */
            inregs.x.bx = off_buf;                    /* offset of buffer  */

            /* disk interrupt 13 */
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0)
            {
                done = TRUE;
            }
        }
    }

    if (!done) {
        sprintf(tmp_buf1, text[TXT_DRV_03],
                head, cylinder, start_sector, no_of_sectors);
        sprintf(tmp_buf2, text[TXT_DRV_04], outregs.h.ah);
        disp_exit (tmp_buf2, tmp_buf1, ANY_MASK);
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}

/**************************************************************************
*
*     function:         read_cylinder()
*
*     purpose:          read cylinder form disk
*
*     arguments:        drive, head, cylinder, cylinder_buffer
*
*     returns:          int
*
*                       0           if cylinder is read
*                       error code  otherwise 
*
***************************************************************************/

int read_cylinder (uint drive, uint cylinder, 
                   char far *cylinder_buffer)
{
    int      i, j;
    int      head;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    BOOLEAN  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;


    if (cylinder > disk_info.max_cyl_no + 1)
    {
       sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
       disp_exit (text[TXT_DRV_02], tmp_buf1, ANY_MASK);
       return (1);
    }

    /* isolate most significant 2 bits of 10-bit cylinder number and shift */
    /* them into the upper two bits of a byte in preparation for oring with */
    /* sector number for CL register for write operation */

    ms2b_cyl_no = (cylinder >> 2) & 0xC0;

    /* get segment and offset of buffer pointer */
    seg_buf = FP_SEG(cylinder_buffer);
    off_buf = FP_OFF(cylinder_buffer);
    off_4 = off_buf;
    seg_buf += ((off_4 >> 4) & 0x0FFF);
    off_buf = (off_buf & 0x000F);
    segread(&segregs);

    done = TRUE;
    /* for each head (reported offset 0) */
    for (head = 0; head <= disk_info.max_no_heads && done; head++)
    {
         done = FALSE;
         for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

            /* reset floppy disk drive */
            inregs.h.ah = 0x00;   /* function 0x00 (reset drive) */
            inregs.h.dl = 0x00;   /* floppy disk drive 0 */

            /* interrupt 13 */
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0)
            {
                  j++;

                  /* read sectors */
                  inregs.h.ah = 0x02;                       /* read function     */
                  inregs.h.al = disk_info.max_sector_no;    /* number of sectors */
                  inregs.h.ch = cylinder & 0xff;            /* cylinder number   */
                  inregs.h.cl = 0x01 | ms2b_cyl_no;         /* sector number     */
                  inregs.h.dh = (char)(head & 0xff);        /* head number       */
                  inregs.h.dl = drive & 0xff;               /* drive number      */
                  segregs.es  = seg_buf;                    /* segment of buffer */
                  inregs.x.bx = off_buf;                    /* offset of buffer  */

                  /* disk interrupt 13 */
                  int86x(0x13, &inregs, &outregs, &segregs);

                  if (outregs.x.cflag == 0)
                  {
                     done = TRUE;
                  }
            }
         }
         off_buf += disk_info.max_sector_no * DEFAULT_SECTOR_SIZE;
    }

    if (!done) {
        sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
        sprintf(tmp_buf2, text[TXT_DRV_04], outregs.h.ah);
        disp_exit (tmp_buf2, tmp_buf1, ANY_MASK);
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}

/**************************************************************************
*
*     function:         write_sector()
*
*     purpose:          write sector to disk
*
*     arguments:        drive, head, cylinder, start_sector, no_of_sectors,
*                       sectors_buffer
*
*     returns:          int
*
*                       0           if sectors are written
*                       error code  otherwise 
*
***************************************************************************/

int write_sectors (uint drive, uint head, uint cylinder, 
                   uint start_sector, uint no_of_sectors,
                   char far *sectors_buffer, uint pflag)
{
    int      i, j;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    BOOLEAN  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = FALSE;

    if (head > disk_info.max_no_heads ||
        cylinder > disk_info.max_cyl_no + 1 ||
        start_sector > disk_info.max_sector_no ||
        no_of_sectors > disk_info.max_sector_no) 
    {
       sprintf(tmp_buf1, text[TXT_DRV_03],
               head, cylinder, start_sector, no_of_sectors);
       disp_exit (text[TXT_DRV_02], tmp_buf1, ANY_MASK);
       return (1);
    }

    /* isolate most significant 2 bits of 10-bit cylinder number and shift */
    /* them into the upper two bits of a byte in preparation for oring with */
    /* sector number for CL register for write operation */

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    /* get segment and offset of buffer pointer */
    seg_buf = FP_SEG(sectors_buffer);
    off_buf = FP_OFF(sectors_buffer);
    off_4 = off_buf;
    seg_buf += ((off_4 >> 4) & 0x0FFF);
    off_buf = (off_buf & 0x000F);
    segread(&segregs);

    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

        /* reset floppy disk drive */
        inregs.h.ah = 0x00;   /* function 0x00 (reset drive) */
        inregs.h.dl = 0x00;   /* floppy disk drive 0 */

        /* interrupt 13 */
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;

            /* read sectors */
            inregs.h.ah = 0x03;                       /* write function    */
            inregs.h.al = no_of_sectors;              /* number of sectors */
            inregs.h.ch = cylinder & 0xff;            /* cylinder number   */
            inregs.h.cl = start_sector | ms2b_cyl_no; /* sector number     */
            inregs.h.dh = (char)(head & 0xff);        /* head number       */
            inregs.h.dl = drive & 0xff;               /* drive number      */
            segregs.es  = seg_buf;                    /* segment of buffer */
            inregs.x.bx = off_buf;                    /* offset of buffer  */

            /* disk interrupt 13 */
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0)
            {
                done = TRUE;
            }
        }
    }

    if (!done) {
        i = outregs.h.ah;
        if (!(pflag && i == WRITE_PROTECTION)) {
            sprintf(tmp_buf1, text[TXT_DRV_03],
                    head, cylinder, start_sector, no_of_sectors);
            sprintf(tmp_buf2, text[TXT_DRV_05], outregs.h.ah);
            disp_exit (tmp_buf2, tmp_buf1, ANY_MASK);
        }
    } else {
        i = OK;
    }

    return (i);
}

/**************************************************************************
*
*     function:         write_cylinder()
*
*     purpose:          write cylinder form disk
*
*     arguments:        drive, cylinder, cylinder_buffer
*
*     returns:          int
*
*                       0           if cylinder is written
*                       error code  otherwise 
*
***************************************************************************/

int write_cylinder (uint drive, uint cylinder, 
                    char far *cylinder_buffer)
{         
    int      i, j;
    int      head;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    BOOLEAN  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;


    if (cylinder > disk_info.max_cyl_no + 1)
    {
       sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
       disp_exit (text[TXT_DRV_02], tmp_buf1, ANY_MASK);
       return (1);
    }

    /* isolate most significant 2 bits of 10-bit cylinder number and shift */
    /* them into the upper two bits of a byte in preparation for oring with */
    /* sector number for CL register for write operation */

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    /* get segment and offset of buffer pointer */
    seg_buf = FP_SEG(cylinder_buffer);
    off_buf = FP_OFF(cylinder_buffer);
    off_4 = off_buf;
    seg_buf += ((off_4 >> 4) & 0x0FFF);
    off_buf = (off_buf & 0x000F);
    segread(&segregs);

    done = TRUE;
    /* for each head (reported offset 0) */
    for (head = 0; head <= disk_info.max_no_heads && done; head++)
    {
         done = FALSE;
         for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

            /* reset floppy disk drive */
            inregs.h.ah = 0x00;   /* function 0x00 (reset drive) */
            inregs.h.dl = 0x00;   /* floppy disk drive 0 */

            /* interrupt 13 */
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0)
            {
                  j++;

                  /* read sectors */
                  inregs.h.ah = 0x03;                       /* write function    */
                  inregs.h.al = disk_info.max_sector_no;    /* number of sectors */
                  inregs.h.ch = cylinder & 0xff;            /* cylinder number   */
                  inregs.h.cl = 0x01 | ms2b_cyl_no;         /* sector number     */
                  inregs.h.dh = (char)(head & 0xff);        /* head number       */
                  inregs.h.dl = drive & 0xff;               /* drive number      */
                  segregs.es  = seg_buf;                    /* segment of buffer */
                  inregs.x.bx = off_buf;                    /* offset of buffer  */

                  /* disk interrupt 13 */
                  int86x(0x13, &inregs, &outregs, &segregs);

                  if (outregs.x.cflag == 0)
                  {
                     done = TRUE;
                  }
            }
         }
         off_buf += disk_info.max_sector_no * DEFAULT_SECTOR_SIZE;
    }

    if (!done) {
        sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
        sprintf(tmp_buf2, text[TXT_DRV_05], outregs.h.ah);
        disp_exit (tmp_buf2, tmp_buf1, ANY_MASK);
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}

/**************************************************************************
*
*     function:         format_track()
*
*     purpose:          format track on disk
*
*     arguments:        drive, head, cylinder, track_buffer
*
*     returns:          int
*
*                       0           if track is formated
*                       error code  otherwise 
*
***************************************************************************/

int format_track (uint drive, uint head, uint cylinder)
{
    int      i, j, k, l, l1, l2, l3;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    BOOLEAN  done;
    char far *afl_buffer;      // address field list
    char far *afl_ptr;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = FALSE;

    if (head > disk_info.max_no_heads ||
        cylinder > disk_info.max_cyl_no + 1) 
    {
        sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
        disp_exit (text[TXT_DRV_02], tmp_buf1, ANY_MASK);
        return (1);
    }

    /* isolate most significant 2 bits of 10-bit cylinder number and shift */
    /* them into the upper two bits of a byte in preparation for oring with */
    /* sector number for CL register for write operation */

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    /* allocate buffer space */
    afl_buffer   = _fmalloc(DEFAULT_SECTOR_SIZE);

    /* if buffer space allocated successfully, proceed with write test */
    if (afl_buffer != NULL) {
        /* get segment and offset of buffer pointer */
        seg_buf = FP_SEG(afl_buffer);
        off_buf = FP_OFF(afl_buffer);
        off_4 = off_buf;
        seg_buf += ((off_4 >> 4) & 0x0FFF);
        off_buf = (off_buf & 0x000F);
        segread(&segregs);

        if (drive < 0x80) {
            for (k = 1, afl_ptr = afl_buffer; k <= disk_info.max_sector_no; k++) {
               *afl_ptr = cylinder & 0xff;
               afl_ptr++;
               *afl_ptr = head;
               afl_ptr++;
               *afl_ptr = k;
               afl_ptr++;
               *afl_ptr = 2;
               afl_ptr++;
            }
        } else {
            l1 = 1;
            l2 = (disk_info.max_sector_no % 3)? 
                 ((disk_info.max_sector_no / 3) + 2): 
                 ((disk_info.max_sector_no / 3) + 1);
            l3 = (2 * l1) - 1;
            for (k = 1, afl_ptr = afl_buffer; k <= disk_info.max_sector_no; k++) {
               *afl_ptr = 0x00;
               afl_ptr++;
               if (k % 3 == 1)
                  l = l1++;
               else if (k % 3 == 2)
                  l = l2++;
               else
                  l = l3++;
               *afl_ptr = l;
               afl_ptr++;
            }
        }

        for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {
            /* reset floppy disk drive */
            inregs.h.ah = 0x00;   /* function 0x00 (reset drive) */
            inregs.h.dl = 0x00;   /* floppy disk drive 0 */

            /* interrupt 13 */
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0) {
                j++;

                /* read sectors */
                inregs.h.ah = 0x05;                        /* format function   */
                inregs.h.al = (drive < 0x80)?  
                               disk_info.max_sector_no: 3; /* number of sectors or interleave */
                inregs.h.ch = cylinder & 0xff;             /* cylinder number   */
                inregs.h.cl = ms2b_cyl_no;                 /* ms 2b of cyl no   */
                inregs.h.dh = (char)(head & 0xff);         /* head number       */
                inregs.h.dl = drive & 0xff;                /* drive number      */
                segregs.es  = seg_buf;                     /* segment of buffer */
                inregs.x.bx = off_buf;                     /* offset of buffer  */

                /* disk interrupt 13 */
                int86x(0x13, &inregs, &outregs, &segregs);

                if (outregs.x.cflag == 0)
                   done = TRUE;
            }
        }

        /* free allocated buffer */
        _ffree(afl_buffer);

        if (!done) {
            sprintf(tmp_buf1, text[TXT_DRV_06], head, cylinder);
            sprintf(tmp_buf2, text[TXT_DRV_07], outregs.h.ah);
            disp_exit (tmp_buf2, tmp_buf1, ANY_MASK);
            i = outregs.h.ah;
        } else {
            i = OK;
        }

    /* otherwise, buffer memory allocation error, so skip write test */
    } else {
        disp_exit (text[TXT_MEM_01], NULL, ANY_MASK);   /* this result from a real error */
        i = OUT_OF_MEM;
    }

    return (i);
}
