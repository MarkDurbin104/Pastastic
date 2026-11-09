/***********************************************************************
*
*   File:           dvtmsgs.h
*
*   Purpose:        messages for dvtmain module
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-21-1990
*
*   Copyright (c) 1990, 1991  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTMSGS.H_V  $
*  
*     Rev 1.11   04 Mar 1991 13:47:28   PJE
*  
*  Changed version to 2.06
*  This version supports multiple MCR swipes during the MCR test.
*  
*     Rev 1.10   22 Feb 1991 16:57:26   AJW
*  Changed version to 2.05.
*  
*     Rev 1.9   06 Feb 1991 15:18:02   PJE
*  Changed version to 2.04 - includes fix of external loopback test,
*  recognition of any "+" key to end keyboard test; indicates that EXIT
*  is F10 and VOID is ESC.
*  
*     Rev 1.8   24 Jan 1991 11:23:16   PJE
*  Added messages to support low-level format of hard-disk.  Also
*  modified version message to v2.03.
*  
*     Rev 1.7   15 Jan 1991 11:57:16   PJE
*  Changed version label to 2.02 from 2.01
*  
*  
*     Rev 1.6   14 Jan 1991 15:40:28   AJW
*  Replaced text TXT_KB_08.
*  
*     Rev 1.5   11 Jan 1991 16:55:48   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.4   07 Jan 1991 18:21:34   PJE
*  Added new messages for testing comm ports in FIFO mode.
*  
*     Rev 1.3   03 Jan 1991 16:06:20   AJW
*  Changes to divide communication port test
*  to internal and external tests.
*  
*     Rev 1.2   14 Dec 1990 11:04:44   AJW
*  Deleted TXT_CHK_02
*  
*     Rev 1.1   13 Dec 1990 16:30:18   PJE
*  
*  Added new messages for the keyboard buzzer and MCR test;
*  
*     Rev 1.0   10 Dec 1990 11:55:44   PJE
*  Initial revision.
*
***********************************************************************/
#ifndef DVTMSGS_H
#define DVTMSGS_H

#undef GLOBAL
#undef INIT

#ifdef MAIN_MODULE
#define GLOBAL
#define INIT    1
#else
#define GLOBAL extern
#define INIT    0
#endif

GLOBAL char *menuopt[]
#if INIT
= {           /* DO NOT REDUCE THE LENGTH OF THESE STRINGS */
    "A - ROM Checksum Test",
    "B - RAM Test      ",                    
    "C - CMOS RAM Test ",
    "D - Keyboard Tests",
    "E - Video Tests   ",
    "F - Floppy Disk Format Test",
    "G - Floppy Disk Write Test",
    "H - Floppy Disk Read Test",
    "I - Floppy Write-Protect Test",
    "J - Floppy Disk Change Test",
    "K - Real Time Clock Test",
    "L - CT Printer Test",
    "M - BOP Printer Test",
    "N - Fixed Disk Read Test",
    "O - Fixed Disk Write Test",
    "P - Fixed Disk Format Test",
    "Q - Modem Test     ",
    "R - Internal Com. Ports Test",
#ifdef FACTORY
    "S - External Com. Ports Test",
#endif
    "1 - Run ALL Tests",
    "2 - Run Only Selected Tests",
    "3 - Clear all Selections",
    "4 - Set all Selections",
    "5 - Suppress Results Print",
    "6 - Loop on Tests",
#ifdef FACTORY
    "7 - Format and Partition HD",
    "8 - List Error Log to Screen",
#endif
};
#else
;
#endif

#ifdef FACTORY
#define MAINMENUOPTS    19               /* number of selectable items */
#define RUNALL          (MAINMENUOPTS+0) /* index to Run All message */
#define RUNSEL          (MAINMENUOPTS+1) /* index to Run Selected message */
#define CLEARSEL        (MAINMENUOPTS+2) /* index to Clear Selections     */
#define SETSEL          (MAINMENUOPTS+3) /* index to Set Selections     */
#define SUPPRESS        (MAINMENUOPTS+4) /* suppress printouts */
#define LOOPTESTS       (MAINMENUOPTS+5) /* loop on tests */
#define FORMATHD        (MAINMENUOPTS+6) /* format the hard disk */
#define LISTERROR       (MAINMENUOPTS+7) /* format the hard disk */
#else
#define MAINMENUOPTS    18               /* number of selectable items */
#define RUNALL          (MAINMENUOPTS+0) /* index to Run All message */
#define RUNSEL          (MAINMENUOPTS+1) /* index to Run Selected message */
#define CLEARSEL        (MAINMENUOPTS+2) /* index to Clear Selections     */
#define SETSEL          (MAINMENUOPTS+3) /* index to Set Selections     */
#define SUPPRESS        (MAINMENUOPTS+4) /* suppress printouts */
#define LOOPTESTS       (MAINMENUOPTS+5) /* loop on tests */
#endif

GLOBAL char *message[]
#if INIT
= {
    "S2000 CT Diagnostics Main Menu",
    "S2000 BOP Diagnostics Main Menu",
    "Select Run ALL or",
    "Toggle selections and Run Selected Tests",
    "Press any key to continue",
    "Run Tests",
    "Test Results",
    "S2000 PC Diagnostics Main Menu",
};
#else
;
#endif

/* the following identifiers correspond to the messages above */

enum {
    CTTITLE = 0,
    BOPTITLE,
    MSGRUNALL,
    MSGRUNSEL,
    PRESSKEY,
    MSGRUNTESTS,
    MSGTESTRESULTS,
    PCTITLE,
};

GLOBAL char *Statstr[]
#if INIT
= {
    "PASSED",
    "FAILED",
    "SKIPPED"
};
#else
;
#endif


GLOBAL char *text[]
#if INIT
= {
    "ROM CHECKSUM",                          // ROM test
    "CS=%04x",

    "RAM TEST",                              // RAM test
    "MAIN MEMORY TEST",
    "Main Memory Size:   %.3dK",
    "Tested Memory:",
    "EXTENDED MEMORY TEST",
    "Extended Memory Size:   %.4dK",

    "CMOS RAM CHECK   ",                     // CMOS test
    "PRESS ENTER TO GET CURRENT CMOS DATA",
    "OR VOID/Esc TO SKIP IT",
    "CLOCK TIME:  %02x:%02x:%02x",
    "\nALARM TIME:  %02x:%02x:%02x",
    "\nDATE:        %02x/%02x/%02x%02x",
    "\n\nBASE     MEMORY:  %dK",
    "\nEXTENDED MEMORY:  %dK",
    "\n\nVIDEO TYPE:       %s",
    "\n\n80287 INSTALLED",
    "\n\nNUMBER OF FLOPPIES:  %d",
    "\nDISKETTE DRIVES:     PRIMARY   =  %s",
    "\n                     SECONDARY =  %s",
    "TYPE %d",
    "NONE",
    "\n\nFIXED DISKS:         PRIMARY   =  %s",
    "\n                     SECONDARY =  %s",
    "CMOS CHECKSUM:      %04Xh",
    "DIAGNOSTIC STATUS:  %02Xh",
    "- CHIP LOST POWER",
    "- BAD CHECKSUM",
    "- BAD CONFGURATION BYTE",
    "- BAD MEMORY SIZE",
    "- BAD HARD DISK BYTE",
    "- BAD TIME OF DAY",

    "Depress Keys to Inspect Codes",         // KEYBOARD CODES
    "(+ ENTER to PASS)  (- ENTER to FAIL)",
    "Keycode: [%-20.20s]\n",
    "CONFIRM THAT TRACK DATA IS GOOD",
    "PRESS ENTER TO CONFIRM OR VOID/Esc TO FAIL",
    "CONFIRM THAT KEYBOARD BEEPED",
    "KEYBOARD BUZZER TEST",
    "SWIPE YOUR CARD",
    "TEST MAGNETIC CARD READER ?",
    "ENTER TO TEST, VOID/Esc TO SKIP",
    "KEYBOARD KEY TEST",
    "MAGNETIC CARD READER TEST",
    "\n\nREADING MCR TRACK %d  ...  ",
    "NO OR BAD DATA",
    "TRACK CONTENTS:\n",
    "ANSI ENCODING - ",
    "OR PRESS A KEY TO SKIP TEST",
    "PRESS SAME_CUST TO SWIPE ANOTHER CARD",
    "OR END_CUST TO COMPLETE MCR TEST",

    "FLOPPY DISK  -  FORMAT TEST    NOTE: Does NOT wipe any data from the disk",           // FLOPPY TESTS
    "\nFORMATING:  HEAD: %d       ",
    "FLOPPY DISK  -  WRITE TEST     NOTE: Does NOT wipe any data from the disk",
    "\nWRITING:    HEAD: %d       ",
    "FLOPPY DISK  -  READ TEST",
    "\nREADING:    HEAD: %d       ",
    "FLOPPY DISK  -  WRITE PROTECTION TEST     ",
    "\nCHECKING PROTECTION        ",
    "\nFLOPPY WRITE PROTECTED",
    "\nFLOPPY NOT WRITE PROTECTED",
    "\nOTHER WRITING ERROR",
    "FLOPPY DISK  -  CHANGE DISK TEST",
    "\n\nREMOVE AND RE-INSERT DISKETTE\nTEST  ",
    "YOU HAVE 20 SECONDS TO DO IT",
    "PLACE WRITE PROTECTED DISK IN DRIVE AND PRESS ENTER",
    "OR VOID/Esc IF WANT TO SKIP TEST",
    "PRESS ENTER TO CONTINUE",
    "OR VOID/Esc TO SKIP TEST",
    "\nDATA NOT SAVED",
    "\nDATA NOT RESTORED",
    "SWITCH WRITE PROTECT BACK TO NORMAL",

    "CLOCK TEST",                            // CLOCK test
    "\n\nDATE:  %02ld/%02ld/%02ld",
    "\n\nTIME:  %02ld:%02ld:%02ld",

    "INTERNAL LOOPBACK TEST",                // COM test
    "\nINTERNAL  %-13s  TEST  FAILED",
    "\nINTERNAL  %-13s  TEST  PASSED",
    "EXTERNAL LOOPBACK TEST",
    "\nEXTERNAL  %-13s  TEST  FAILED",
    "\nEXTERNAL  %-13s  TEST  PASSED",
    "\n%-13s            NO FIFO CAPABILITY",
    "\n\nTEST RX/TX FIFO BUFFERS",
    "INTERNAL %-13s FAILED",
    "EXTERNAL %-13s FAILED",
    "INTERNAL %-13s FIFO FAILED",
    "EXTERNAL %-13s FIFO FAILED",
    "\n%-13s            DOESN'T EXIST",

    "CT PRINTER TEST",                   // PRINTER test
    "PRESS ENTER IF TEST PASSED",
    "OR VOID/Esc IF FAILED",
    "Unable to open script file: %s\n",
    "\n\nTEST PASSED\n",
    "\n\nTEST FAILED\n",
    "\n\nTEST SKIPPED - Valid for S2000 CT Diagnostics only\n",
    "End of File\n",
    "Error reading from script file\n",
    "Unrecognized command on line %d: %s\n",
    "^ Error\n",
    "COM%d: Status = %XH\n",
    "BOP PRINTER TEST",
    "\n\nValid for S2000 BOP Diagnostics only\n",

    "FIXED DISK  -  READ TEST",              // FIXED DISK TESTS
    "\nREADING:    HEAD %02d      ",
    "FIXED DISK  -  WRITE TEST",
    "\nWRITING:    HEAD %02d      ",
    "FIXED DISK  -  FORMAT TEST",
    "\nFORMATING:  HEAD %02d      ",
    "\n\nTEST   %s\nValid for S2000 BOP Diagnostics only\n",

    "MEMORY ALLOCATION ERROR",               // TXT_MEM_01
    "CAN'T GET DRIVE PARAMS      ERROR CODE = 0x%02x HEX",  // TXT_DRV_..
    "UNPROPER SECTOR PARAMETERS",
    "HD: %d   CYL: %d   Start SEC: %d   SEC No: %d",
    "ERROR 0x%02x  READING SECTORS",
    "ERROR 0x%02x  WRITING SECTORS",
    "HEAD: %d   CYLINDER: %d",
    "ERROR 0x%02x  FORMATING SECTORS",
    "\n\nDRIVE: 0x%02x\n  heads: %d\n  cylinders: %d\n  sectors per track: %d",
    "\n\nFIXED DISK NOT PRESENT",

    "CAN'T CHECK DRIVE      ERROR CODE = 0x%02x HEX",  // TXT_CHK_01

    "MONOCHROME TEXT 80 COLUMNS",            // VIDEO TESTS
    "COLOUR EMULATION 40 COLUMNS",
    "WHITE ON BLACK TEXT",
    "BLINKING BLACK ON WHITE",
    "BLINKING WHITE ON BLACK",
    "Confirm Video Tests Passed",
    "DDOOUUBBLLEE  WWIIDDTTHH IINN  MMOONNOOCCHHRROOMMEE",
    "MONOCHROME Attribute 0x%02x",
    "COLOUR EMULATION Attribute 0x%02x",
    "ENABLED Enhanced Mode Register",
    "DISABLED Enhanced Mode Register",
    "CHARACTER SET",

    "0x%02x NORMAL",
    "0x%02x INVERSE",
    "0x%02x UNDERLINED",              
    "0x%02x BLINKING NORMAL",       
    "0x%02x BLINKING INVERSE",
    "0x%02x BLINKING UNDERLINED",
    "0x%02x BRIGHT NORMAL",         
    "0x%02x BRIGHT INVERSE",
    "0x%02x BRIGHT UNDERLINED",
    "0x%02x BRIGHT BLINKING NORMAL",
    "0x%02x BRIGHT BLINKING INVERSE",
    "0x%02x BRIGHT BLINKING UNDERLINED",

    "===================================",
    "S2000 Model 2080 Diagnostics",
    "Counter Terminal System",
    "Back Office System",
    "Date %s  Time %s",

#ifdef FACTORY
    "v 2.13 F",
    "S2000 Model 2080 (ECCO+) Diagnostics Program    Version 2.14 F\n",
#else
    "v 2.13 U",
    "S2000 Model 2080 (ECCO+) Diagnostics Program    Version 2.14 U\n",
#endif
    "Copyright (c) 1991  Unisys Corp.\n\n",
    "Usage:\n",
    "DVT CT   - for a Counter Terminal\n",
    "DVT BOP  - for a Back Office System\n\n",

    "Press ENTER to proceed",
    "Press VOID/Esc to abort",

    "Low Level Format the Hard Disk ?",
    "Partition and High Level Format Hard Disk ?",

    "Press SPACE for next page   ESC/VOID to exit",     // view error log
    "MODEM TEST",
    "\nModem Responding      : ",
    "\nModem Loopback Test   : ",
    "\nModem Dialtone Detect : ",
};
#else
;
#endif

/* the following identifiers correspond to the messages above */

enum Text_No {
    TXT_ROM_01 = 0,  //  ROM CHECKSUM
    TXT_ROM_02,      //  CS=%04x

    TXT_RAM_01,      //  RAM TEST
    TXT_RAM_02,      //  MAIN MEMORY TEST
    TXT_RAM_03,      //  Main Memory Size:   %.3dK
    TXT_RAM_04,      //  Tested Memory:
    TXT_RAM_05,      //  EXTENDED MEMORY TEST
    TXT_RAM_06,      //  Extended Memory Size:   %.4dK

    TXT_CMOS_01,     //  CMOS RAM CHECK
    TXT_CMOS_02,     //  PRESS ENTER TO GET CURRENT CMOS DATA
    TXT_CMOS_03,     //  OR VOID/Esc TO SKIP IT
    TXT_CMOS_04,     //  CLOCK TIME:  %02x:%02x:%02x
    TXT_CMOS_05,     //  \nALARM TIME:  %02x:%02x:%02x
    TXT_CMOS_06,     //  \nDATE:        %02x/%02x/%02x%02x
    TXT_CMOS_07,     //  \n\nBASE     MEMORY:  %dK
    TXT_CMOS_08,     //  \nEXTENDED MEMORY:  %dK
    TXT_CMOS_09,     //  \n\nVIDEO TYPE:       %s
    TXT_CMOS_10,     //  \n\n80287 INSTALLED
    TXT_CMOS_11,     //  \n\nNUMBER OF FLOPPIES:  %d
    TXT_CMOS_12,     //  \nDISKETTE DRIVES:     PRIMARY   =  %s
    TXT_CMOS_13,     //  \n                     SECONDARY =  %s
    TXT_CMOS_14,     //  TYPE %d
    TXT_CMOS_15,     //  NONE
    TXT_CMOS_16,     //  \n\nFIXED DISKS:         PRIMARY   =  %s
    TXT_CMOS_17,     //  \n                     SECONDARY =  %s
    TXT_CMOS_18,     //  CMOS CHECKSUM:      %04Xh
    TXT_CMOS_19,     //  DIAGNOSTIC STATUS:  %02Xh
    TXT_CMOS_20,     //  - CHIP LOST POWER
    TXT_CMOS_21,     //  - BAD CHECKSUM
    TXT_CMOS_22,     //  - BAD CONFGURATION BYTE
    TXT_CMOS_23,     //  - BAD MEMORY SIZE
    TXT_CMOS_24,     //  - BAD HARD DISK BYTE
    TXT_CMOS_25,     //  - BAD TIME OF DAY

    TXT_KB_01,       //  Depress Keys to Inspect Codes
    TXT_KB_02,       //  (+ ENTER to PASS)  (- ENTER to FAIL)
    TXT_KB_03,       //  Keycode:  [%-20.20s]\n
    TXT_KB_04,       //  CONFIRM THAT TRACK DATA IS GOOD
    TXT_KB_05,       //  PRESS ENTER TO CONFIRM OR VOID/Esc TO FAIL
    TXT_KB_06,       //  CONFIRM THAT KEYBOARD BEEPED
    TXT_KB_07,       //  KEYBOARD BUZZER TEST
    TXT_KB_08,       //  SWIPE YOUR CARD
    TXT_KB_09,       //  TEST MAGNETIC CARD READER ?
    TXT_KB_10,       //  ENTER TO TEST, VOID/Esc TO SKIP
    TXT_KB_11,       //  KEYBOARD KEY TEST
    TXT_KB_12,       //  MAGNETIC CARD READER TEST
    TXT_KB_13,       //  READING MCR TRACK %d ...
    TXT_KB_14,       //  NO OR BAD DATA
    TXT_KB_15,       //  Track contents:\n
    TXT_KB_16,       //  ANSI Encoding:\n
    TXT_KB_17,       //  OR PRESS A KEY TO SKIP TEST
    TXT_KB_18,       //  PRESS SAME_CUST TO SWIPE ANOTHER CARD
    TXT_KB_19,       //  OR END_CUST TO COMPLETE MCR TEST

    TXT_FLP_01,      //  FLOPPY DISK  -  FORMAT TEST
    TXT_FLP_02,      //  \nFORMATING:  HEAD: %d
    TXT_FLP_03,      //  FLOPPY DISK  -  WRITE TEST
    TXT_FLP_04,      //  \nWRITING:    HEAD: %d      
    TXT_FLP_05,      //  FLOPPY DISK  -  READ TEST
    TXT_FLP_06,      //  \nREADING:    HEAD: %d
    TXT_FLP_07,      //  FLOPPY DISK  -  WRITE PROTECTION TEST    
    TXT_FLP_08,      //  \nCHECKING PROTECTION  
    TXT_FLP_09,      //  \nFLOPPY WRITE PROTECTED
    TXT_FLP_10,      //  \nFLOPPY NOT WRITE PROTECTED
    TXT_FLP_11,      //  \nOTHER WRITING ERROR
    TXT_FLP_12,      //  FLOPPY DISK  -  CHANGE DISK TEST
    TXT_FLP_13,      //  \n\nREMOVE AND RE-INSERT DISKETTE\nTEST  
    TXT_FLP_14,      //  YOU HAVE 20 SECONDS TO DO IT
    TXT_FLP_15,      //  PLACE WRITE PROTECTED DISK IN DRIVE AND PRESS ENTER
    TXT_FLP_16,      //  OR VOID/Esc IF WANT TO SKIP TEST
    TXT_FLP_17,      //  PRESS ENTER TO CONTINUE
    TXT_FLP_18,      //  OR VOID/Esc TO SKIP TEST
    TXT_FLP_19,      //  \nDATA NOT SAVED
    TXT_FLP_20,      //  \nDATA NOT RESTORED
    TXT_FLP_21,      //  SWITCH WRITE PROTECTED BACK TO NORMAL

    TXT_CLOCK_01,    //  CLOCK TEST
    TXT_CLOCK_02,    //  \n\nDATE: %ld
    TXT_CLOCK_03,    //  \n\nTIME: %ld
                       
    TXT_COMM_01,     //  INTERNAL LOOPBACK TEST
    TXT_COMM_02,     //  \nINTERNAL  %-13s  TEST  FAILED
    TXT_COMM_03,     //  \nINTERNAL  %-13s  TEST  PASSED
    TXT_COMM_04,     //  \n\nEXTERNAL LOOPBACK TEST
    TXT_COMM_05,     //  \nEXTERNAL  %-13s  TEST  FAILED
    TXT_COMM_06,     //  \nEXTERNAL  %-13s  TEST  PASSED
    TXT_COMM_07,     //  \n%-13s            NO FIFO CAPABILITY
    TXT_COMM_08,     //  \n\nTEST RX/TX FIFO BUFFERS
    TXT_COMM_09,     //  INTERNAL %-13s FAILED",
    TXT_COMM_10,     //  EXTERNAL %-13s FAILED",
    TXT_COMM_11,     //  INTERNAL %-13s FIFO FAILED
    TXT_COMM_12,     //  EXTERNAL %-13s FIFO FAILED
    TXT_COMM_13,     //  \n%-13s            DOESN'T EXIST

    TXT_SPRN_01,     //  CT PRINTER TEST
    TXT_SPRN_02,     //  PRESS ENTER IF TEST PASSED
    TXT_SPRN_03,     //  OR VOID/Esc IF FAILED
    TXT_SPRN_04,     //  Unable to open script file: %s\n
    TXT_SPRN_05,     //  \n\nTEST PASSED\n
    TXT_SPRN_06,     //  \n\nTEST FAILED\n
    TXT_SPRN_07,     //  \n\nTEST SKIPPED - Valid for S2000 CT Diagnostics only\n
    TXT_SPRN_08,     //  End of File\n
    TXT_SPRN_09,     //  Error reading from script file\n
    TXT_SPRN_10,     //  Unrecognized command on line %d: %s\n
    TXT_SPRN_11,     //  ^ Error\n
    TXT_SPRN_12,     //  COM%d: Status = %XH\n
    TXT_PPRN_01,     //  BOP PRINTER TEST
    TXT_PPRN_02,     //  \n\nValid for S2000 BOP Diagnostics only\n
  
    TXT_FIX_01,      //  FIXED DISK  -  READ TEST
    TXT_FIX_02,      //  \nREADING:    HEAD %02d 
    TXT_FIX_03,      //  FIXED DISK  -  WRITE TEST
    TXT_FIX_04,      //  \nWRITING:    HEAD %02d  
    TXT_FIX_05,      //  FIXED DISK  -  FORMAT TEST
    TXT_FIX_06,      //  \nFORMATING:  HEAD %02d
    TXT_FIX_07,      //  \n\nTEST   %s\nValid for S2000 BOP Diagnostics only\n

    TXT_MEM_01,      //  MEMORY ALLOCATION ERROR

    TXT_DRV_01,      //  CAN'T GET DRIVE PARAMS      ERROR CODE = 0x%02x HEX
    TXT_DRV_02,      //  UNPROPER SECTOR PARAMETERS
    TXT_DRV_03,      //  HD: %d   CYL: %d   Start SEC: %d   SEC No: %d
    TXT_DRV_04,      //  ERROR 0x%02x  READING SECTORS
    TXT_DRV_05,      //  ERROR 0x%02x  WRITING SECTORS
    TXT_DRV_06,      //  HEAD: %d   CYLINDER: %d
    TXT_DRV_07,      //  ERROR 0x%02x  FORMATING SECTORS
    TXT_DRV_08,      //  \n\nDRIVE: 0x%02x\n  heads: %d\n  cylinders: %d\n
    TXT_DRV_09,      //  \n\nFIXED DISK NOT PRESENT
               
    TXT_CHK_01,      //  CAN'T CHECK DRIVE      ERROR CODE = 0x%02x HEX
    
    TXT_VID_01,      //  MONOCHROME TEXT 80 COLUMNS
    TXT_VID_02,      //  COLOUR EMULATION 40 COLUMNS
    TXT_VID_03,      //  WHITE ON BLACK TEXT
    TXT_VID_04,      //  BLINKING BLACK ON WHITE
    TXT_VID_05,      //  BLINKING WHITE ON BLACK
    TXT_VID_06,      //  Confirm Video Tests Passed
    TXT_VID_07,      //  DDOOUUBBLLEE  WWIIDDTTHH IINN  MMOONN
    TXT_VID_08,      //  MONOCHROME Attribute 0x%02x
    TXT_VID_09,      //  COLOUR EMULATION Attribute 0x%02x
    TXT_VID_10,      //  ENABLED Enhanced Mode Register
    TXT_VID_11,      //  DISABLED Enhanced Mode Register
    TXT_VID_12,      //  CHARACTER SET
                        
    TXT_VID_13,      //  0x%02x NORMAL
    TXT_VID_14,      //  0x%02x INVERSE
    TXT_VID_15,      //  0x%02x UNDERLINED
    TXT_VID_16,      //  0x%02x BLINKING NORMAL
    TXT_VID_17,      //  0x%02x BLINKING INVERSE
    TXT_VID_18,      //  0x%02x BLINKING UNDERLINED
    TXT_VID_19,      //  0x%02x BRIGHT NORMAL
    TXT_VID_20,      //  0x%02x BRIGHT INVERSE
    TXT_VID_21,      //  0x%02x BRIGHT UNDERLINED
    TXT_VID_22,      //  0x%02x BRIGHT BLINKING NORMAL
    TXT_VID_23,      //  0x%02x BRIGHT BLINKING INVERSE
    TXT_VID_24,      //  0x%02x BRIGHT BLINKING UNDERLINED
                        
    TXT_RES_01,      //  ===================================
    TXT_RES_02,      //  S2000 Model 2080 Diagnostics
    TXT_RES_03,      //  Counter Terminal System
    TXT_RES_04,      //  Back Office System
    TXT_RES_05,      //  Date %s  Time %s

    TXT_VER_01,      //  v 2.11
    TXT_USE_01,      //  S2000 Model 2080 (ECCO+) Diagnostics Program    Version 2.11
    TXT_USE_02,      //  Copyright (c) 1990  Unisys Corp.
    TXT_USE_03,      //  Usage:
    TXT_USE_04,      //  DVT CT   - for a Counter Terminal
    TXT_USE_05,      //  DVT BOP  - for a Back Office System

    TXT_PROCEED,    //  Press ENTER to proceed
    TXT_ABORT,      //  Press VOID/Esc to abort

    TXT_FORMAT1,     //  Low Level Format Hard Disk ?
    TXT_FORMAT2,     //  Partition and Format Hard Disk ?
    TXT_VERRORL,     //  Press SPACE for next page   ESC/VOID to exit

    TXT_MODEM,       //  Modem Test:
    TXT_MODEMR,      //  Modem Responding:
    TXT_MODEMLB,     //  Modem Loopback Test:
    TXT_MODEMDT,     //  Modem Dialtone Detect:
};                      
                        
                    
#endif  /* DVTMSGS  _H */
                    
