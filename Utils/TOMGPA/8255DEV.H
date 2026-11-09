/****************************************************************************
* Project     : GPA
* File        : 8255dev.h
* Description : support for coin handling device 8255
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:34  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/8255dev.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:34   JGRAY
 * Annotations
* 
****************************************************************************/
#ifndef DEV_8255_H

#define DEV_8255_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef DEV_8255_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef DEV_8255_C
LONG control_8255(INT type,va_list ap);
#endif
// PUBLIC SYMBOLS S

PUBLIC DEVHEADER dev_8255
#if INIT
= {
    DEVSIG,
    "Coin Handling Device Copyright (c) Unisys Ltd 1994 Version 1.00",
    "OUTPUT 04",
    "8255",
    "IEir",
    NULL,
    NULL,
    (DFPTR)control_8255,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef DEV_8255_C



typedef struct {
    UINT p;        // penny
    UINT n;        // nickel
    UINT d;        // dime
    UINT q;        // quarter
    UINT h;        // dollar (hundred cents)
    UINT t;        // total value in pennies
    UINT pd;    // penny   delay
    UINT nd;     // nickel  delay
    UINT dd;    // dime    delay 
    UINT qd;    // quarter delay
    UINT hd;    // dollar  delay
    UCHAR pe;    // penny   error
    UCHAR ne;    // nickel  error
    UCHAR de;    // dime    error
    UCHAR qe;    // quarter error
    UCHAR he;    // dollar  error
} COINS;


#define EOI          0x20
#define PIC          0x21
#define PORT_A11  0x01E0
#define PORT_B11  0x01E1
#define PORT_C11  0x01E2
#define PORT_Q11  0x01E3
#define PORT_A12  0x01E4
#define PORT_B12  0x01E5
#define PORT_C12  0x01E6
#define PORT_Q12  0x01E7
#define PORT_A21  0x01A0
#define PORT_B21  0x01A1
#define PORT_C21  0x01A2
#define PORT_Q21  0x01A3
#define PORT_A22  0x01A4
#define PORT_B22  0x01A5
#define PORT_C22  0x01A6
#define PORT_Q22  0x01A7

#define Q11_SETUP         0x83      // 10000011b
#define Q12_SETUP         0x8B      // 10001011b
#define Q21_SETUP         0x90      // 10010000b
#define Q22_SETUP         0x80      // 10000000b

#define A11_SETUP         0x00    // O - dispense, coins inhibit
#define B11_SETUP         0xFF    // I - coins output, dispensing
#define C11_SETUP         0x0F    // I/O - dispensing, hopper / coins inhibit, alarm
#define A12_SETUP         0x9F    // O - routes inhibit, hopper reset
#define B12_SETUP         0xFF    // I - hoppers
#define C12_SETUP         0x7C    // I - jacpots
#define A21_SETUP         0x0F    // I - alarm info
#define B21_SETUP         0x0A    // O - dispense gate, interrupt reset
#define C21_SETUP         0x00    // O - spare
#define A22_SETUP         0x00    // O - spare
#define B22_SETUP         0x00    // O - spare
#define C22_SETUP         0x00    // O - spare

//   -----   8255 PINS   

// ---- coin outputs
#define B_COIN            0x20       // penny
#define C_COIN            0x08       // nickel
#define D_COIN            0x10       // dime
#define E_COIN            0x80       // quarter
#define F_COIN            0x40       // dollar

// ----- coin inhibits
#define B_INHIBIT         0x20       // penny   - C11
#define C_INHIBIT         0x20       // nickel  - A11
#define D_INHIBIT         0x40       // dime    - A11
#define E_INHIBIT         0x80       // quarter - A11
#define F_INHIBIT         0x10       // dollar  - C11
#define C1_INHIBIT        0x70       // A11 - nickel, dime, quarter
#define C2_INHIBIT        0x30       // C11 - dollar, penny

// ---- route 6 & 7 are n  (1 & 2)
#define B_ROUTE           0x10       // A12  5 (3-04h) - penny
#define C_ROUTE           0x04       // A12  3 (5-10h) - nickel
#define D_ROUTE           0x02       // A12  2 (6-20h) - dime
#define E_ROUTE           0x01       // A12  1 (7-40h) - quarter
#define F_ROUTE           0x08       // A12  4 - dollar

#define ALARM_ON          0x40           // C11
#define ALARM_OFF         (~ALARM_ON)    // C11
#define ALARM_RESET       0x80           // C11
#define ALARM_SET         (~ALARM_RESET) // C11

#define MAJOR_ALARM_ACT   0x01       // A21
#define MINOR_ALARM_ACT   0x02       // A21
#define MAJOR_ALARM_LAT   0x04       // A21
#define MINOR_ALARM_LAT   0x08       // A21
#define MAJOR_ALARMS      0x05       // A21
#define MINOR_ALARMS      0x0A       // A21
#define ALL_ALARMS        0x0F       // A21

#define DISPENSE_GATE     0x01       // B21
#define INT_RESET         0x0A       // B21
#define OPEN_CM_DOOR      0x20       // B21

#define B_DISPENSE        0x08       // penny   - A11
#define C_DISPENSE        0x04       // nickel  - A11
#define D_DISPENSE        0x02       // dime    - A11
#define E_DISPENSE        0x01       // quarter - A11
#define F_DISPENSE        0x10       // dollar  - A11

#define B_DISPENSING      0x02       // penny   - C11
#define C_DISPENSING      0x04       // nickel  - B11
#define D_DISPENSING      0x02       // dime    - B11
#define E_DISPENSING      0x01       // quarter - B11
#define F_DISPENSING      0x01       // dollar  - C11

#define RESET_HOPPER      0x80       // A12

#define B_LO_HOPPER       0x200       // penny   - B12
#define B_HI_HOPPER       0x100       // penny   - B12
#define C_LO_HOPPER       0x080       // nickel  - B12
#define C_HI_HOPPER       0x040       // nickel  - B12
#define D_LO_HOPPER       0x020       // dime    - B12
#define D_HI_HOPPER       0x010       // dime    - B12
#define E_LO_HOPPER       0x008       // quarter - B12
#define E_HI_HOPPER       0x004       // quarter - B12
#define F_LO_HOPPER       0x002       // dollar  - C11
#define F_HI_HOPPER       0x001       // dollar  - C11

#define B_JACKPOT         0x04       // C12
#define C_JACKPOT         0x08       // C12
#define D_JACKPOT         0x10       // C12
#define E_JACKPOT         0x20       // C12
#define F_JACKPOT         0x40       // C12

#define PENNY             0x01
#define NICKEL            0x02
#define DIME              0x04
#define QUARTER           0x08
#define DOLLAR            0x10
#define HOPPER_HIGH       0x01
#define HOPPER_LOW        0x02
#define DISPENSING        0x04
#define COIN_JACKPOT      0x08
#define ANY_JACKPOT       0x10

#define R_QUARTER         D_ROUTE  
#define R_DIME            C_ROUTE
#define R_NICKEL          B_ROUTE 
#define R_DOLLAR          E_ROUTE
#define R_PENNY           F_ROUTE

#define DOOR_DELAY          91
#define COIN_VAL_DELAY    3
#define DISPENSE_DELAY    6
#define DISPENSED_DELAY   18

volatile LONG     G_cticker=0L;
volatile LONG     G_lcctr=0L;
volatile LONG     G_mjt=0L;
volatile LONG     G_mnt=0L;
UCHAR             G_jackpot=0;
UCHAR             G_alarm=0;
UINT              G_hopps=0;
UCHAR             G_csA11=A11_SETUP;
UCHAR             G_csA12=A12_SETUP;
UCHAR             G_csB21=B21_SETUP;
COINS             G_coins;
void interrupt  (*oldint0A)(void);
void interrupt  (*oldticker)(void);

void              putp(INT a,UCHAR b);
UCHAR             getp(INT a);
UCHAR             getalarmsensors(void);
UCHAR             isactive(UCHAR type);
INT               setalarm(INT onoff);
INT               resetalarm(void);
INT               setalarmreset(INT onoff);
LONG              getalarmtime(INT type);
INT               operatecmdoor(INT open);
INT               setcoininhibit(UCHAR type,INT onoff);
UCHAR             getcoininhibit(void);
INT               setaltcoinroute(UCHAR type,INT onoff);
UCHAR             getaltcoinroute(void);
UINT              getcoin(UINT *p,UINT *n,UINT *d,UINT *q,UINT *h);
INT               clrcoins(void);
INT               dispensecoins(UCHAR type,INT q,INT *e);
INT               getdispensestatus(UCHAR type);
INT               resetcoinhopper(void);
void interrupt     ticker2(void);
void interrupt     coinint(void);
INT              startup_8255(void);
INT               shutdown_8255(void);
INT             payout(INT a);

#endif  //  def DEV_8255_C

#endif  //  ndef DEV_8255_H

// **************************************************************************
// 8255dev.h <end-of-file>

