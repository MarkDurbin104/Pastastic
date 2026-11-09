/***********************************************************************
*
*   File:           dvtfmt.c
*
*   Purpose:        DVT Format Module - This module formats
*                   the hard disk and partitions it for PC-MOS
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 1-21-1991
*
*   Copyright (c) 1991  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTFMT.C_V  $
*  
*     Rev 1.0   24 Jan 1991 12:04:00   PJE
*  Initial release (Build version 2.03)
*
***********************************************************************/
#include <stdio.h>
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include <bios.h>
#include <vv_menu.h>
#include "eccodefs.h"
#include "dvtmsgs.h"

/* key definitions for stuffing in buffer */

#define DOWN_CODE    0x5000
#define UP_CODE      0x4800
#define ENTER_CODE   0x1C0D
#define ONE_CODE     0x0231
#define SEVEN_CODE   0x0837
#define YES_CODE     0x1559
#define NULL_CODE    0x0000

#define FORMAT_SEM  "A:\hdformat.sem"

unsigned int llf_keys[] = {
    DOWN_CODE,               // brings up Utilities menu
    ENTER_CODE,              // selects format and validate
    ENTER_CODE,              // validate configuration - affirmative
    NULL_CODE                // enter bad cylinder data here
};

unsigned int hdsetup_keys[] = {
    ONE_CODE,                // partition disk
    YES_CODE,                // create multiple MOS partitions - affirmative
    ENTER_CODE,              // done partitioning
    SEVEN_CODE,              // exit to operating system - saving changes
    NULL_CODE
};

/***********************************************************************
*
*   Function:   kb_stuff
*
*   Purpose:    This function stuffs keys in the keyboard buffer
*
*   Arguments:  keycode to stuff
*
*   Returns:    nothing
*
***********************************************************************/
void kb_stuff (unsigned int keycode)
{
    union REGS regs;

    regs.h.ah = 0x05;           /* push character and scan code */
    regs.x.cx = keycode;        /* scan code and keycode        */
    int86 (0x16, &regs, &regs); /* call interrupt 16h */
}

/***********************************************************************
*
*   Function:   stuff_codes
*
*   Purpose:    stuffs codes in an array to the keyboard buffer
*
*   Arguments:  unsigned int *array
*
*   Returns:    nothing
*
***********************************************************************/
void stuff_codes (unsigned int *codes)
{
    int i;

    while (_bios_keybrd(_KEYBRD_READY))
        _bios_keybrd(_KEYBRD_READ);

    for (i=0; codes[i] != NULL_CODE; i++)
    {
        kb_stuff (codes[i]);        // stuff codes in buffer
    }
}

/***********************************************************************
*
*   Function:   hd_format
*
*   Purpose:    menu option to format hard disk
*
*   Arguments:  none
*
*   Returns:    SAMELEVEL
*
***********************************************************************/
int hd_format ()
{
    WINDOWPTR save_wnp;

    if (confirm_option(text[TXT_FORMAT1]))
    {
        // create semaphore indicating that the disk is to be
        // formatted on the next boot

        creat (FORMAT_SEM, S_IREAD | S_IWRITE);

        save_wnp = wn_def (0, 0, 25, 80, LNORMAL, BDR_NULLP);
        if (save_wnp != NULLP)
            wn_up (save_wnp);           // save the underlying screen

        stuff_codes (llf_keys);         // stuff keys for low-level format
        system ("DTCFMT");              // execute low level format
    
        if (save_wnp != NULLP)
        {
            if (wn_isup(save_wnp))
                wn_dn (save_wnp);       // restore the saved screen
            wn_free (save_wnp);         // free the window
        }

        if (confirm_option(text[TXT_FORMAT2]))
        {
            stuff_codes (hdsetup_keys);     // stuff keys for HD partitioning
            system ("HDSETUP");             // execute hard disk setup

            // HDSETUP will prompt for reboot when done
        } else
        {
            remove (FORMAT_SEM);
        }
    }
    return (SAMELEVEL);
}
