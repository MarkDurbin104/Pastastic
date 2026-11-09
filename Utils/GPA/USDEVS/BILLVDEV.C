//******************************************************************************
// FILENAME:  billvdev.c
//------------------------------------------------------------------------------
// DESCRIPTION: This file contains the device driver for the Model IVO Bill
//              Validator.
//------------------------------------------------------------------------------
// TODO:: 1) Integrate with GPA.
//        2) Write up of command definitions for bill validator.
//
//******************************************************************************
#define BILLVDEV_C
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <conio.h>
#include "control.h"
#include "types.h"
#include "message.h"
#include "billvdev.h"
#include "config.h"

//******************************************************************************
// FUNCTION NAME:  init_billv()
//------------------------------------------------------------------------------
// DESCRIPTION: This function sets up initial remote parameters, then verifies
//              communication with the bill validator, and initializes the vali-
//              dator.
//******************************************************************************
int init_billv(void)
{
  int stat;
  unsigned char cmd[10];

  //============================================================================
  // Perform initial read of port to verify no extraneous data on the lines from
  // a power-up.
  //============================================================================
  inportb(LSR);
  inportb(COM);

  //============================================================================
  // Set up baud rate, stop bits, etc. for remote operation.
  //============================================================================
  outportb(LCR,0x80);       // Enable baud divisor register
  outportb(COM,0x80);       // Set up for 300, n, 8, 1 parameters
  outportb(COM+1,0x01);
  outportb(LCR,0x03);

  //============================================================================
  // Possible TODO:  Read up a configuration file with parameters to set up the
  // bill validator hardware.
  //============================================================================
  //
  //

  //============================================================================
  // Set up to request status to COM2 and verify response.
  //============================================================================
  cmd[0] = REQ_UNIT_STATUS;
  if (proc_cmd(cmd, 1, 2) == 0)
    return(0);
  else
    return(1);
}

//******************************************************************************
// FUNCTION NAME: send2port()
//------------------------------------------------------------------------------
// DESCRIPTION: This function sends num_bytes to validator if transmitting is
//              functional.  If THR is active continuously, this routine will
//              return and error status.
//******************************************************************************
int send2port(unsigned char *cmd, int num_bytes)
{
  unsigned long i;
  int index = 0;

  for (i=0L; i<1000000L; i++) {         // Set timeout using for loop for now.
    if (inportb(LSR) & THRRDY) {        // Could be enhanced to use tick_cnt or
      outportb(COM,cmd[index]);         // some other timer.
      ++index;
      i = 0;
    }
    if (index == num_bytes)         // Make sure all bytes are transmitted.
      return(1);                    // Return success (1) if all transmitted.
  }
  return(0);                        // Timeout, return error (0)
}

//******************************************************************************
// FUNCTION NAME: get_response()
//------------------------------------------------------------------------------
// DESCRIPTION: This function gets an expected response of num_bytes from the
//              remote.
//******************************************************************************
int get_response(unsigned char *cmd, int num_bytes)
{
  unsigned long i;
  int index = 0;

  for (i=0L; i<1000000L; i++) {
    if (inportb(LSR) & DTARDY) {
      cmd[index] = inportb(COM);
      ++index;
      i = 0;
    }
    if (index == num_bytes)            // Make sure all expected bytes are in.
      return(1);                       // Return succcess (1) if all received.
  }
  return(0);                           // Timeout, return error(0)
}

//******************************************************************************
// FUNCTION NAME:  proc_cmd()
//------------------------------------------------------------------------------
// DESCRIPTION: This function will handle commands that require a response from
//              the validator after being sent. (Request status returned, etc.)
//******************************************************************************
int proc_cmd(unsigned char *cmd, int out_num_bytes, int in_num_bytes)
{
  unsigned char save_cmd0 = cmd[0];
  unsigned char save_cmd1 = cmd[1];

  //============================================================================
  // Send command out to validator.
  //============================================================================
  if (send2port(cmd, out_num_bytes) == 0) {     // send2port will update

#ifdef DEBUG_BILLV
    printf("TIMEOUT -- THR is stuck\n");  // DEBUG
#endif

    return(0);                            // Return 0 if a transmit timeout.
  }

  //============================================================================
  // Respond to command coming back in from validator.
  //============================================================================
  if (get_response(cmd, in_num_bytes) == 0) {

#ifdef DEBUG_BILLV
    if (cmd[0] == 0x88)
      printf("\nIllegal Command - Function not Implemented!\n"); // DEBUG
    else
      printf("\nThe Bill Validator is not responding!\n"); // DEBUG
#endif

    return(0);                          // Return 0 if a read timeout.
  }else if (cmd[0] == save_cmd0) {
    if (out_num_bytes == 2) {
      if (cmd[1] != save_cmd1)
	return(0);
    }
    return(1);
  }else if (save_cmd0 == REPEAT_DENOMINATION) {
    if (cmd[0] <= 100)
      return(1);

#ifdef DEBUG_BILLV
//    else
//      printf("\nUnexpected data received = %X\n", cmd[0]);  // DEBUG
#endif

    return(0);
  }else{

#ifdef DEBUG_BILLV
//    if (cmd[0] == 0x88)
//      printf("\nIllegal Command - Function not Implemented!\n");
//    else
//      printf("\nUnexpected data received = %X\n", cmd[0]);  // DEBUG
#endif

    return(0);
  }
}

//******************************************************************************
// FUNCTION NAME: billv_control()
//
//------------------------------------------------------------------------------
// DESCRIPTION: This function handles all commands sent to it from the GPA that
//              can control the validator and its operation.
//
//******************************************************************************
int billv_control(int type,va_list ap)
{
  int retval, xout, xin;
  unsigned char *cmd;

  cmd = va_arg(ap, unsigned char *);
  //============================================================================
  // Process R commands for requesting data and status from the validator.
  //============================================================================
  if ((type & 0xff) == 'R') {
    switch(type) {
      case 'RS':                        // Request status of validator.
	cmd[0] = REQ_UNIT_STATUS;
	xout=1; xin=2;
	break;
      case 'RE':                        // Request bill enable status
	cmd[0] = REQ_BILL_EN_STATUS;
	xout=1; xin=2;
	break;
      case 'RR':                        // Request relay status
	cmd[0] = REQ_RELAY_STATUS;
	xout=1; xin=2;
	break;
      case 'RL':                        // Request bill security levels
	cmd[0] = REQ_BILL_SECURITY;
	xout=1; xin=2;
	break;
      case 'RI':                        // Request system ID value.
	cmd[0] = REQ_SYSTEM_ID;
	xout=1; xin=2;
	break;
      case 'RD':                        // Request date code
	cmd[0] = REQ_DATE_CODE;
	xout=1; xin=3;
	break;
      case 'RC':                        // Request total bill count
	cmd[0] = REQ_BILL_COUNT;
	xout=1; xin=9;
	break;
      case 'RF':                        // Request factory serial number
	cmd[0] = REQ_FACTORY_SERIAL;
	xout=1; xin=3;
	break;
      case 'RT':                        // Request stacker serial number
	cmd[0] = REQ_STACKER_SERIAL;
	xout=1; xin=7;
	break;
      case 'RK':                        // Read stacker bill count
	cmd[0] = RD_STACKER_COUNT;
	xout=1; xin=2;
	break;
      default:
	return(-1);
    }

  //============================================================================
  // Process H commands for manipulating certain hardware features.
  //============================================================================
  }else if ((type & 0xff) == 'H') {
    switch(type) {
      case 'HD':                        // Disable DIP switch and program card
	cmd[0] = DISABLE_DIP_CARD;
	xout=1; xin=1;
	break;
      case 'HE':                        // Enable DIP switch and program card
	cmd[0] = ENABLE_DIP_CARD;
	xout=1; xin=1;
	break;
      case 'HC':                        // Set stacker normally closed
	cmd[0] = SET_STACKER_CLOSED;
	xout=1; xin=1;
	break;
      case 'HO':                        // Set stacker normally open
	cmd[0] = SET_STACKER_OPEN;
	xout=1; xin=1;
	break;
      case 'HV':                        // Read video setup from NVRAM
	cmd[0] = RD_VIDEO_SETUP;
	xout=1; xin=5;
	break;
      case 'H1':                        // Accept currency only one way
	cmd[0] = ACCEPT_ONE_WAY;
	xout=1; xin=1;
	break;
      case 'H2':                        // Accept currency both ways
	cmd[0] = ACCEPT_BOTH_WAYS;
	xout=1; xin=1;
	break;
      case 'HN':                        // Disable security level 2 for all bills
	cmd[0] = DISABLE_SECURITY_L2;
	xout=1; xin=1;
	break;
      case 'HS':                        // Enable security level 2 for all bills
	cmd[0] = ENABLE_SECURITY_L2;
	xout=1; xin=1;
	break;
      case 'HW':                        // Write NVRAM with setup
	cmd[0] = WRITE_NVRAM;
	xout=1; xin=1;
	break;
      default:
	return(-1);
    }

  //============================================================================
  // Process single letter commands for initalize and exit.
  //============================================================================
  }else if ((type >> 8) == 0) {
    switch(type) {
      case 'I':                         // Initialize bill validator.
	return(init_billv());
       // break;
      case 'E':                         // Exit (Shutdown) bill validator.
	return(1);
      //  break;

      case 'P':                         // Poll for validator-initiated commands

	if (inportb(LSR) & DTARDY) {    // received. (cmd[0] = valid code or 0.)
	  cmd[0] = inportb(COM);
	  //("INSIDE OF BILLVDEV.C CMD = '%x'\n",cmd[0]);
	  retval = 1;
	}else
	  retval = 0;
	return(retval);
	//break;
      default:
	return(-1);
    }

  //============================================================================
  // Process W commands for writing ID values to validator.
  //============================================================================
  }else if ((type & 0xff) == 'W') {
    switch(type) {
      case 'WT':                        // Write stacker serial number
	cmd[0] = WR_STACKER_SERIAL;
	xout=6; xin=6;
	break;
      case 'WI':                        // Write system ID.
	cmd[0] = WR_SYSTEM_ID;
	xout=2; xin=2;
	break;
      default:
	return(-1);
    }

  //============================================================================
  // Process C commands for special commands that do not have anything to do with
  // set up or initialization.
  //============================================================================
  }else if ((type & 0xff) == 'C') {
    switch(type) {
      case 'CA':                        // Accept bill (active mode)
	cmd[0] = ACCEPT_BILL;
	xout=1; xin=1;
	break;
      case 'CE':                        // Eject bill (active mode)
	cmd[0] = EJECT_BILL;
	xout=1; xin=1;
	break;
      case 'CH':                        // Wait hold bill (active mode)
	cmd[0] = WAIT_HOLD_BILL;
	xout=1; xin=1;
	break;
      case 'CR':                        // Repeat denomination (active mode)
	cmd[0] = REPEAT_DENOMINATION;
	xout=1; xin=1;
	break;
      default:
	return(-1);
    }

  //============================================================================
  // Process S commands for setting up operating modes and validator behavior.
  //============================================================================
  }else if ((type & 0xff) == 'S') {
    switch(type) {
      case 'SD':                        // Initialize stacker dollar counter
	cmd[0] = INIT_STACKER_COUNT;
	xout=1; xin=1;
	break;
      case 'ST':                        // Write time/dollar
	cmd[0] = WR_TIME_DOLLAR;
	xout=2; xin=2;
	break;
      case 'SR':
	cmd[0] = CHG_RELAY_FUNCTION;    // Change relays function
	xout=2; xin=2;
	break;
      case 'SL':
	cmd[0] = CHG_BILL_SECURITY;     // Change bill security levels
	xout=2; xin=2;
	break;
      case 'SI':                        // Inhibit acceptance of all bills
	cmd[0] = INH_ALL_BILLS;
	xout=1; xin=1;
	break;
      case 'SU':                        // Uninhibit acceptance of all bills
	cmd[0] = UNINH_ALL_BILLS;
	xout=1; xin=1;
	break;
      case 'SA':                        // Set operating mode to ACTIVE
	cmd[0] = SET_MODE_ACTIVE;
	xout=1; xin=1;
	break;
      case 'SP':                        // Set operating mode to PASSIVE.
	cmd[0] = SET_MODE_PASSIVE;
	xout=1; xin=1;
	break;
      case 'SE':                        // Change the bill enables
	cmd[0] = CHG_BILL_ENABLES;
	xout=2; xin=2;
	break;
      default:
	return(-1);
    }
  }else
    return(-1);

  return(proc_cmd(cmd, xout, xin));
}
