/***********************************************************************
*
*   File:           dvtprot.h
*
*   Purpose:        function prototypes
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTPROT.H_V  $
*  
*     Rev 1.2   24 Jan 1991 11:41:30   PJE
*  Added prototype for hd_format() to do low-level format of harddisk.
*  
*     Rev 1.1   03 Jan 1991 17:00:14   AJW
*  Exchanged prototypes:
*      removed - test_comms
*      added   - test_internal_comms, test_external_comms
*  
*  
*     Rev 1.0   10 Dec 1990 11:59:02   PJE
*  Initial revision.
*
***********************************************************************/

/* diagnostic functions */

int test_rom (void );
int test_ram (void );
int test_cmos (void );
int test_keyboard (void );
int test_video (void );
int test_flformat (void );
int test_flwrite (void );
int test_flread (void );
int test_flprotect (void );
int test_flchange (void );
int test_clock (void );
int test_internal_comms (void );
int test_external_comms (void );
int test_serialp (void );
int test_parallp (void );
int test_fdread (void );
int test_fdwrite (void );
int test_fdformat (void );
int hd_format (void );
int kbd_buzz (void );
int test_modem (void );

