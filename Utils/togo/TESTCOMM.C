#include <dos.h>
#include <string.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>

/*****************************
 Defines, Structures & Macros
******************************/

#define FALSE 0
#define TRUE  1
typedef int STATUS;

#define FAILED 1
#define PASSED 2
#define SKIPPED 3

#define DIM(a) (sizeof(a)/sizeof(a[0]))  /* dimension of known array */

/*  8250 / 16C552 Register Offsets */

#define DATA        0
#define IER         1
#define IIR         2   // RO
#define FCR         2   // WO
#define LCR         3
#define MCR         4
#define LSR         5
#define MSR         6

/*  IER Register Bits */

#define RX_INT      0x01
#define TX_INT      0x02
#define LINE_INT    0x04
#define MODEM_INT   0x08

/*  MCR Register Bits   */

#define DTR         0x01
#define RTS         0x02
#define OUT1        0x04
#define OUT2        0x08
#define LOOP        0x10

/*  LSR Register Bits   */

#define DATA_READY  0x01
#define OVERRUN     0x02
#define PARITY      0x04
#define FRAMING     0x08
#define BREAK_INT   0x10
#define THRE        0x20
#define TSRE        0x40

/* MSR Register Bits    */

#define DELTA_CTS   0x01
#define DELTA_DSR   0x02
#define RING_EDGE   0x04
#define DELTA_CD    0x08
#define CTS         0x10
#define DSR         0x20
#define RING        0x40
#define CD          0x80

/* LCR Register Bits    */

#define DATA5       0x00
#define DATA6       0x01
#define DATA7       0x02
#define DATA8       0x03

#define STOP1       0x00
#define STOP2       0x04

#define PARITY_NONE 0x00
#define PARITY_EVEN 0x18
#define PARITY_ODD  0x08

#define DLAB        0x80

#define NORMAL_BUFF 1
#define FIFO_BUFF   16

typedef struct {
    unsigned char ier;
    unsigned char lcr;
    unsigned char mcr;
    unsigned char baud_hi;
    unsigned char baud_lo;
} PORT_PARAMS;

enum {INTERNAL=0, EXTERNAL, MODEMTEST};
enum {PORT1=0, PORT2, PORT3, PORT4, PORT5, LANIN, LANOUT};

int portaddr[] = {
    0x3F8,          // port 1
    0x2F8,          // port 2
    0x2E8,          // port 3
    0x310,          // port 4
    0x3E0,          // port 5
    0x300,          // LAN in
    0x260           // LAN out
};
/*
static char *portname[] = {
    "PORT #1 (3F8)",
    "PORT #2 (2F8)",
    "PORT #3 (2E8)",
    "PORT #4 (310)",
    "PORT #5 (3E0)",
    "LAN IN  (300)",
    "LAN OUT (260)",
};

static PORT_PARAMS portconfig[3] = {
    {0, PARITY_NONE | DATA8 | STOP1, DTR | RTS | LOOP, 0, 1   },
    {0, PARITY_NONE | DATA8 | STOP1, DTR | RTS       , 0, 1   },
    {0, PARITY_NONE | DATA8 | STOP1, DTR | RTS       , 0, 0x30},
};*/

/***********************************************************************
*
*   Function:   wait_for
*
*   Purpose:    
*
*   Arguments:  Register address, status bits to wait for
*
*   Returns:    0 if timeout ; 1 if ok  
*
***********************************************************************/
int wait_for (int reg, int statbits)
{
    int i;
    int status;
    int result = 0;

    for (i=0; i < 30000; i++)
    {
        status = inp (reg);
        if ((status & statbits) == statbits)
        {
            result = 1;
            break;
        }
        /* timeout if exits from here */
    }
    return (result);
}

#ifdef FACTORY
extern  int   log_error (char *message);
#endif

/***********************************************************************
*
*   Function:   activate_wdt
*
*   Purpose:    This activates the watchdog timer
*
*   Arguments:  none
*
*   Returns:    none
*
***********************************************************************/
void activate_wdt()
{
    outp (0x200, 0xff);         /* turn on WDT for maximum duration */
}

/***********************************************************************
*
*   Function:   port_exists
*
*   Purpose:    determines if a port exists
*
*   Arguments:  port address
*
*   Returns:    TRUE | FALSE
*
***********************************************************************/
int port_exists(int port)
{
    int lcr;
    int exists = FALSE;

    lcr = inp (port + LCR);             /* save LCR setting     */
    outp (port + LCR, 0x55);            /* write a test value   */
    if (inp(port + LCR) == 0x55)        /* test the value       */
    {
        outp (port + LCR, 0x0F);        /* write 2nd test value */
        if (inp(port + LCR) == 0x0F)    /* test the value       */
        {
            exists = TRUE;
        }
    }
    outp (port + LCR, lcr);             /* restore the setting  */

    return (exists);
}

/***********************************************************************
*
*   Function:   test_com
*
*   Purpose:    tests specified comm port
*
*   Arguments:  port address, PORT_PARAMS params, int buffer_size
*
*   Returns:    PASSED | FAILED
*
***********************************************************************/
void portstat(int port)
{
    PORT_PARAMS portp;
    /* get the port configuration */
    portp.ier = inp (port + IER);
    portp.lcr = inp (port + LCR);
    portp.mcr = inp (port + MSR);
    outp (port + LCR, DLAB );               /* DLAB on */
    portp.baud_lo = inp (port  );
    portp.baud_hi = inp (port+1);
    outp (port + LCR, portp.lcr & ~DLAB);    /* DLAB off */
    portp.lcr = inp (port + LSR);

    printf("Port 0x%03X\n",port);
    printf("IER %02X\n",portp.ier);
    if ((portp.ier&RX_INT   )==RX_INT   )  printf("    RX INT   \n");
    if ((portp.ier&TX_INT   )==TX_INT   )  printf("    TX INT   \n");
    if ((portp.ier&LINE_INT )==LINE_INT )  printf("    LINE INT \n");
    if ((portp.ier&MODEM_INT)==MODEM_INT)  printf("    MODEM INT\n");

    printf("LSR %02X\n",portp.lcr);
    if ((portp.lcr&DATA_READY)==DATA_READY)  printf("    DATA_READY\n");
    if ((portp.lcr&OVERRUN   )==OVERRUN   )  printf("    OVERRUN   \n");
    if ((portp.lcr&PARITY    )==PARITY    )  printf("    PARITY    \n");
    if ((portp.lcr&FRAMING   )==FRAMING   )  printf("    FRAMING   \n");
    if ((portp.lcr&BREAK_INT )==BREAK_INT )  printf("    BREAK_INT \n");
    if ((portp.lcr&THRE      )==THRE      )  printf("    THRE      \n");
    if ((portp.lcr&TSRE      )==TSRE      )  printf("    TSRE      \n");

    printf("MSR %02X\n",portp.mcr);
    if ((portp.mcr&DELTA_CTS)==DELTA_CTS)  printf("    DELTA_CTS\n");
    if ((portp.mcr&DELTA_DSR)==DELTA_DSR)  printf("    DELTA_DSR\n");
    if ((portp.mcr&RING_EDGE)==RING_EDGE)  printf("    RING_EDGE\n");
    if ((portp.mcr&DELTA_CD )==DELTA_CD )  printf("    DELTA_CD \n");
    if ((portp.mcr&CTS      )==CTS      )  printf("    CTS      \n");
    if ((portp.mcr&DSR      )==DSR      )  printf("    DSR      \n");
    if ((portp.mcr&RING     )==RING     )  printf("    RING     \n");
    if ((portp.mcr&CD       )==CD       )  printf("    CD       \n");

    printf("BAUD LO %02X\n",portp.baud_lo);
    printf("BAUD HI %02X\n\n",portp.baud_hi);
}
int hextoi(char *buf)
{
    int ret=0;
    while (*buf) {
        if (*buf>'9') (*buf)-='A'-10; else (*buf)-='0';
        ret+=*(buf++);
        if (*buf) ret<<=4;
    }
    return ret;
}
int main(int argc,char *argv[])
{
    if (argc<2) {
        portstat(portaddr[0]);
        portstat(portaddr[1]);
    } else {
        portstat(hextoi(strupr(argv[1])));
    }
    return 1;
}
