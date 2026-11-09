//******************************************************************************
// FILENAME:  labeldev.c
//------------------------------------------------------------------------------
// DESCRIPTION: This file contains the device driver for the Axiohm Label
//              Printer.
//------------------------------------------------------------------------------
// TODO:: 1) Integrate with GPA.
//        2) Write up of command definitions for label printing.
//
//******************************************************************************
#define LABELDEV_C
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <conio.h>
#include <mem.h>
#include <string.h>
#include "control.h"
#include "types.h"
#include "message.h"
#include <time.h>
#include "labeldev.h"
#include "config.h"

//******************************************************************************
// FUNCTION NAME:  init_label()
//------------------------------------------------------------------------------
// DESCRIPTION: This function performs a reset on the printer and verifies the
//              status returned is ok (NO paper out errors, busy, etc.)
//******************************************************************************
int init_label(unsigned char *ch)
{
  clock_t time1;

  //----------------------------------------------------------------------------
  // Reset printer by sending PC code to reset printer and character mode reset.
  //----------------------------------------------------------------------------
  if ((ch[0] = reset_prn()) != 0x90)    // Send a reset to the printer and verify
    return(0);                          // status != 0x90.
  ch[0] = RESET;
  if (outpch(ch, 1) == 0)            // Reset to default character mode values
    return(0);
  delay(100);                           // Delay for reset to occur

  //----------------------------------------------------------------------------
  // Verify status port is ready and no errors detected.
  //----------------------------------------------------------------------------
  time1 = clock() + (CLK_TCK * 2);
  while(time1 >= clock())  {
    if ((ch[0]=prtrdy()) == PRTRDY)
      return(1);
  }
  return(0);
}

//******************************************************************************
// FUNCTION NAME: outpch()
//------------------------------------------------------------------------------
// DESCRIPTION: This function sends num_bytes to printer.  Status is verified
//              to make sure printer is ready before each character.
//******************************************************************************
int outpch(unsigned char *str, int num_bytes)
{
  unsigned char ch;
  int index=0;
  clock_t time1;

  time1 = clock() + (CLK_TCK * 2);
  while (time1 >= clock()) {            // Set timeout using for loop.
    if ((ch=prtrdy()) == PRTRDY) {      // If printer ready, then print ch.
      outportb(LP,*str);                // Set port data to *str
      outportb(LP_CONT,STROBE);         // Set and clear strobe.
      outportb(LP_CONT,NO_STROBE);
      str++; index++;                   // Adjust control values and pointers
    }
    if (index == num_bytes)             // If all characters sent, then return
      return(1);                        // good status.
  }
  str[0] = ch;                          // Store return status in command string
  return(0);                            // Timeout, return error (0)
}

//******************************************************************************
// FUNCTION NAME: label_control()
//------------------------------------------------------------------------------
// DESCRIPTION: This function handles all commands sent to it from the GPA that
//              can control the label printer and its operation.
//******************************************************************************
int label_control(int type, va_list ap)
{
  int retval, i, val1;
  unsigned char *cmd, xout;

  cmd = va_arg(ap, unsigned char *);

  //----------------------------------------------------------------------------
  // Process C commands for setting character modes.
  //----------------------------------------------------------------------------
  if ((type & 0xff) == 'C') {
    xout = 1;
    switch(type) {
      case 'CT':                        // Tab Horizontally 8 characters
	cmd[0] = HORIZONTAL_TAB;        // No extra arguments
	break;
      case 'CV':                        // Vertical Tab requires parameter
	cmd[1] = va_arg(ap, unsigned char); // Parameter1 = # of vertical LF's
	cmd[0] = VERTICAL_TAB;
	xout=2;
	break;
      case 'CW':                        // Enable double wide writing
	val1 = va_arg(ap, int);         // Get ON/OFF argument
	if (val1 == 1)                  // If val1 = 1, then ON.
	  cmd[0] = DBL_WIDE;
	else if (val1 == 0)             // If val1 = 0, then OFF.
	  cmd[0] = NO_DBL_WIDE;
	else
	  return(-1);
	break;
      case 'CR':                        // Reset character mode to default
	cmd[0] = RESET;                 // No extra arguments
	break;
      case 'CG':                        // Set graphic character mode
	xout = va_arg(ap, unsigned char); // Param1 = # of bytes after graphic
	memmove(&cmd[1], cmd, xout);      // command code.
	cmd[0] = GRAPHIC_MODE;
	break;
      case 'CH':                        // Set char to double high
	val1 = va_arg(ap, int);         // Get ON/OFF argument
	if (val1 == 1)                  // If val1 = 1, then ON.
	  cmd[0] = DBL_HI;
	else if (val1 == 0)             // If val1 = 0, then OFF.
	  cmd[0] = NO_DBL_HI;
	else
	  return(-1);
	break;
      case 'CU':                        // Set char to underline mode
	val1 = va_arg(ap, int);         // Get ON/OFF argument
	if (val1 == 1)                  // If val1 = 1, then ON.
	  cmd[0] = UNDERLINE;
	else if (val1 == 0)             // If val1 = 0, then OFF.
	  cmd[0] = NO_UNDERLINE;
	else
	  return(-1);
	break;
      case 'CI':                        // Set char mode to inverse
	val1 = va_arg(ap, int);         // Get ON/OFF argument
	if (val1 == 1)                  // If val1 = 1, then ON.
	  cmd[0] = INVERSE;
	else if (val1 == 0)             // If val1 = 0, then OFF.
	  cmd[0] = NO_INVERSE;
	else
	  return(-1);
	break;
      default:
	return(-1);
    }

  //----------------------------------------------------------------------------
  // Process H commands for manipulating certain hardware features.
  //----------------------------------------------------------------------------
  }else if ((type & 0xff) == 'H') {
    switch(type) {
      case 'HC':                        // Cut paper at current position
	cmd[0] = PAPER_CUT;             // No extra arguments
	xout=1;
	break;
      case 'HA':                        // Download ASCII character to memory
	xout = va_arg(ap, unsigned char); // Param1 = # of download bytes
	memmove(&cmd[2], cmd, xout);      // including type code.
	memmove(cmd, ASCII_DOWNLOAD, 2);
	break;
      case 'HP':                        // Print X number of lines from buffer
	memmove(cmd, PRINT_BUFFER, 2);
	cmd[2] = va_arg(ap, unsigned char); // Param1 = number of lines to print
	xout=3;
	break;
      case 'HL':                        // Set side-writing mode line length
	memmove(cmd, SIDE_CHARS,2);
	cmd[2] = va_arg(ap, unsigned char); // Param1 = line length for side write
	if ((cmd[2] < 1) || (cmd[2] > 44))
	  return(-1);
	xout=3;
	break;
      case 'HS':                        // Set side writing mode
	memmove(cmd, SIDE_WRITE_MODE,2); // No extra parameters
	xout=2;
	break;
      case 'HM':                        // Advance motor for 1/3 of a second
	memmove(cmd, MOTOR_ADVANCE, 2); // No extra parameters
	xout=2;
	break;
      case 'HT':                        // Disable ticket output sensor
	memmove(cmd, DISABLE_SENSOR, 2); // No extra parameters
	xout=2;
	break;
      default:                          // Bad command format
	return(-1);
    }

  //----------------------------------------------------------------------------
  // Process single letter commands for initalize and exit and string output.
  //----------------------------------------------------------------------------
  }else if ((type >> 8) == 0) {
    switch(type) {
      case 'I':                         // Initialize label printer
	return(init_label(cmd));
      case 'E':                         // Exit (Shutdown) label printer
	return(1);
      case 'L':                         // Return line status on LPT
	cmd[0] = prtrdy();
	return(1);
      case 'O':                         // Output a string to printer.
	xout = strlen(cmd);
	break;
      default:
	return(-1);
    }

  //----------------------------------------------------------------------------
  // Process B commands for writing and setting barcode paramaters
  //----------------------------------------------------------------------------
  }else if ((type & 0xff) == 'B') {
    switch(type) {
      case 'BL':                        // Set up bar code location
	memmove(cmd, BAR_POSITION, 2);
	cmd[2] = va_arg(ap, unsigned char); // X position = n1 * 256 + n2
	cmd[3] = va_arg(ap, unsigned char); // Param 1 = n1, Param2 = n2
	xout=4;
	break;
      case 'BH':                        // Set bar code height
	memmove(cmd, BAR_HEIGHT, 2);
	cmd[2] = va_arg(ap, unsigned char); // Param1 = height in pixels
	if (cmd[2] < 1)                 // If < 1, illegal format.
	  return(-1);
	xout=3;
	break;
      case 'BP':                        // Select and print bar code
	xout = va_arg(ap, unsigned char); // Param1 = # of bar code data bytes
	memmove(&cmd[2], cmd, xout);      // including type code.
	memmove(cmd, BAR_PRINT, 2);
	xout += 2;
	break;
      case 'BO':                        // Set mode to vertical bar code
	memmove(cmd, BAR_ORIENT_VERT, 3);
	xout=3;
	break;
      case 'BV':                        // Set mode to side bar code
	memmove(cmd, BAR_ORIENT_SIDE, 3);
	xout=3;
	break;
      case 'B1':                        // Set bar code pass to one
	memmove(cmd, BAR_SIDE_PASS_1, 3);
	xout=3;
	break;
      case 'B2':                        // Set bar code pas to two
	memmove(cmd, BAR_SIDE_PASS_2, 3);
	xout=3;
	break;
      case 'BW':                        // Select bar code width
	cmd[2] = va_arg(ap, unsigned char); // Param1 = thin line width
	cmd[3] = va_arg(ap, unsigned char); // Param2 = thick line width
	memmove(cmd, BAR_SIZE, 2);
	xout=4;
	break;
      default:
	return(-1);
    }
  }else
    return(-1);
  return(outpch(cmd, xout));
}

//******************************************************************************
// FUNCTION NAME: prtrdy()
//------------------------------------------------------------------------------
// DESCRIPTION: This function returns the current status of the port.
//******************************************************************************
unsigned char prtrdy(void)
{
  union REGS regs;

  regs.h.ah = 2;
  regs.x.dx = 0;
  int86(PRINTER, &regs, &regs);
  return(regs.h.ah & 0xff);
}

//******************************************************************************
// FUNCTION NAME: reset_prn()
//------------------------------------------------------------------------------
// DESCRIPTION: This function sends a reset to the printer.
//******************************************************************************
unsigned char reset_prn()
{
  union REGS regs;

  regs.h.ah = 1;
  regs.x.dx = 0;
  int86(PRINTER, &regs, &regs);
  return(regs.h.ah & 0xff);
}
