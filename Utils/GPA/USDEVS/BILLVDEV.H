//******************************************************************************
// FILENAME: billvdev.h
//------------------------------------------------------------------------------
// DESCRIPTION: Header file for defines and equates and prototypes for the
//              bill validator device driver.
//
//
//******************************************************************************
#ifndef BILLVDEV_H
#define BILLVDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef BILLVDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S  
#ifdef BILLVDEV_C
int billv_control(int type, va_list ap);
#endif


PUBLIC DEVHEADER dev_billv
#if INIT
= {
  DEVSIG,
  "IVO Bill Validator Device Copyright (c) Unisys 1994 version 1.00",
  "INPUT 02",
  "BILLV",
  "IEP",
  NULL,
  NULL,
  (DFPTR)billv_control,
  NULL,
  DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef BILLVDEV_C

//===========================================================================
// Defines for the commands sent to the bill validator.
//===========================================================================
#define ACCEPT_BILL         0x80
#define EJECT_BILL          0x81
#define WAIT_HOLD_BILL      0x82
#define REPEAT_DENOMINATION 0x85

#define CHG_BILL_ENABLES    0x91
#define CHG_RELAY_FUNCTION  0x92
#define CHG_BILL_SECURITY   0x93
#define WR_SYSTEM_ID        0x94
#define WR_TIME_DOLLAR      0x95

#define REQ_UNIT_STATUS     0xC0
#define REQ_BILL_EN_STATUS  0xC1
#define REQ_RELAY_STATUS    0xC2
#define REQ_BILL_SECURITY   0xC3
#define REQ_SYSTEM_ID       0xC4
#define REQ_DATE_CODE       0xC5
#define REQ_BILL_COUNT      0xC6
#define REQ_FACTORY_SERIAL  0xC7
#define REQ_STACKER_SERIAL  0xC8
#define WR_STACKER_SERIAL   0xC9
#define INIT_STACKER_COUNT  0xCA
#define RD_STACKER_COUNT    0xCB

#define INH_ALL_BILLS       0xF0
#define UNINH_ALL_BILLS     0xF1
#define SET_MODE_ACTIVE     0xF2
#define SET_MODE_PASSIVE    0xF3
#define DISABLE_DIP_CARD    0xF4
#define ENABLE_DIP_CARD     0xF5
#define SET_STACKER_CLOSED  0xF6
#define SET_STACKER_OPEN    0xF7
#define RD_VIDEO_SETUP      0xF8
#define WRITE_NVRAM         0xF9
#define ACCEPT_ONE_WAY      0xFA
#define ACCEPT_BOTH_WAYS    0xFB
#define DISABLE_SECURITY_L2 0xFE
#define ENABLE_SECURITY_L2  0xFF

//==============================================================================
// Defines for the bill validator initiated commands.
//==============================================================================
#define BILL_1          0x1
#define BILL_2          0x2
#define BILL_5          0x5
#define BILL_10         0xA
#define BILL_20         0x14
#define BILL_50         0x32
#define BILL_100        0x64

#define BILL_REJECTED   0x86
#define BILL_JAM        0x87
#define STACKER_JAM     0x8A
#define STACKER_OPEN    0x8B

//==============================================================================
// Defines for Serial Communications. Bill will be Validator Assigned to Port 2.
//==============================================================================
#define COM     0x2F8
#define LCR     (COM+3)
#define MCR     (COM+4)
#define LSR     (COM+5)
#define DTARDY  0x01
#define RDR     0
#define MASK    0x7f
#define THR     0
#define THRRDY  0x20
#define COM_SET 0x43

//==============================================================================
// Prototypes for the internal bill validator driver.
//==============================================================================
int init_billv(void);
int send2port(unsigned char *cmd, int num_bytes);
int get_response(unsigned char *cmd, int num_bytes);
int proc_cmd(unsigned char *cmd, int out_num_bytes, int in_num_bytes);

#endif  // def BILLVDEV_C
#endif  // def BILLVDEV_H
