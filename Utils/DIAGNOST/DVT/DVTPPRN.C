/***********************************************************************
*
*   File:           dvtpprn.c
*
*   Purpose:        printer test
*
*   Author:         Andrew Wnuk
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-29-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTPPRN.C_V  $
*  
*     Rev 1.2   11 Jan 1991 17:55:34   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.1   14 Dec 1990 12:46:00   PJE
*  Fixed a message display bug.
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

/**********************
 Function Declarations 
***********************/

static int print_char(char ch);
int print_str(char * str);
static int printer_test();

/**********************
 Global Data 
***********************/

static char * test_pattern[] = {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789",
    "BCDEFGHIJKLMNOPQRSTUVWXYZ123456789A",
    "CDEFGHIJKLMNOPQRSTUVWXYZ123456789AB",
    "DEFGHIJKLMNOPQRSTUVWXYZ123456789ABC",
    "EFGHIJKLMNOPQRSTUVWXYZ123456789ABCD",
    "FGHIJKLMNOPQRSTUVWXYZ123456789ABCDE",
    "GHIJKLMNOPQRSTUVWXYZ123456789ABCDEF",
    "HIJKLMNOPQRSTUVWXYZ123456789ABCDEFG",
    "IJKLMNOPQRSTUVWXYZ123456789ABCDEFGH",
    "JKLMNOPQRSTUVWXYZ123456789ABCDEFGHI",
    "KLMNOPQRSTUVWXYZ123456789ABCDEFGHIJ",
    "LMNOPQRSTUVWXYZ123456789ABCDEFGHIJK",
    "MNOPQRSTUVWXYZ123456789ABCDEFGHIJKL",
    "NOPQRSTUVWXYZ123456789ABCDEFGHIJKLM",
    "OPQRSTUVWXYZ123456789ABCDEFGHIJKLMN",
    "PQRSTUVWXYZ123456789ABCDEFGHIJKLMNO",
    "QRSTUVWXYZ123456789ABCDEFGHIJKLMNOP",
    "RSTUVWXYZ123456789ABCDEFGHIJKLMNOPQ",
    "STUVWXYZ123456789ABCDEFGHIJKLMNOPQR",
    "TUVWXYZ123456789ABCDEFGHIJKLMNOPQRS",
    0 };



/************************************************************************
*
*		function:      print_char()
*
*		purpose:       sends character to the printer
*
*		arguments:     nothing
*
*		returns:       TRUE if printer returns status 0x90 otherwise FALSE
*
*************************************************************************/

static int print_char(char ch)
{
	int    i, result;
	union  REGS inregs, outregs;

   inregs.h.ah = 0;
   inregs.h.al = ch;
   inregs.x.dx = 0;
   int86(0x17, &inregs, &outregs);

   if ((outregs.h.ah == 0x90) || (outregs.h.ah == 0x10)) {
      result = TRUE;
   } else {
      result = FALSE;
//      v_printf (wnp, "\nprinter status = 0x%02x\n", outregs.h.ah); /* PJE */
   }

   return (result);
}


/************************************************************************
*
*		function:      print_str()
*
*		purpose:       sends string to the printer
*
*		arguments:     string
*
*		returns:       TRUE if printer returns status 0x90 otherwise FALSE
*
*************************************************************************/

int print_str(char * str)
{
	int i, result;

   result = TRUE;
   for (i = 0; str[i] && result; i++)
		result = print_char(str[i]);
   if (result)
		result = print_char(13);
   if (result)
		result = print_char(10);

   return (result);
}


/************************************************************************
*
*		function:      printer_test()
*
*		purpose:       sends few strings to the printer
*
*		arguments:     array of strings
*
*		returns:       TRUE if printer returns status 0x90 otherwise FALSE
*
*************************************************************************/

static int printer_test()
{
	int i, result;

   result = TRUE;
   for (i = 0; test_pattern[i] && result; i++)
		result = print_str(test_pattern[i]);

   return (result);
}


/************************************************************************
*
*		function:      test_parallp()
*
*		purpose:       sends character to the printer
*
*		arguments:     nothing
*
*		returns:       TRUE if printer returns status 0x90 otherwise FALSE
*
*************************************************************************/

int test_parallp(void)
{
   STATUS  result;
	union   REGS inregs, outregs;
   int     key;

   clear_all_windows();
   disp_title (menuopt[12]);
   disp_inst (NULL, NULL);
    
   v_stpl ( 1, 0, text[TXT_PPRN_01], wnp);
   if (Location == CT) {
      result = SKIPPED;
   } else {
      cs_mv(2, 0, wnp);          /* move cursor */

//      inregs.h.ah = 1;
//      inregs.x.dx = 0;
//      int86(0x17, &inregs, &outregs);
      inregs.h.ah = 2;
      inregs.x.dx = 0;
      int86(0x17, &inregs, &outregs);
      if ((outregs.h.ah == 0x90) ||(outregs.h.ah == 0x10)) {
         if (printer_test()) {
            key = disp_exit(text[TXT_SPRN_02], text[TXT_SPRN_03], ENTER_MASK | VOID_MASK);
            if (key == ENTER_KEY) {
               result = PASSED;
            } else if (key == 0) {
               result = SKIPPED;
            } else {
               result = FAILED;
            }
         } else {
            result = FAILED;
         }
      } else {
//         v_printf (wnp, "\nprinter status = 0x%02x\n", outregs.h.ah); /* PJE */
         result = FAILED;
      }
   }

   if (result == PASSED) {
	   v_stpl(1, 25, Statstr[PASSED], wnp);
   } else if (result == FAILED) {
	   v_stpl(1, 25, Statstr[FAILED], wnp);
   } else {
	   v_stpl(1, 25, Statstr[SKIPPED], wnp);
      v_st(text[TXT_PPRN_02], wnp);
   }
   delay_ticks(SHORT_DELAY);

   return (result);   
}

