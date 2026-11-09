/***********************************************************************
*
*   File:           dvtcomm.c
*
*   Purpose:        communications ports test
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 12-01-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTCOMM.C_V  $
*  
*     Rev 1.8   22 Feb 1991 17:02:58   AJW
*  Turned on watchdog in test_com function.
*  
*     Rev 1.7   01 Feb 1991 16:10:26   PJE
*  Fix bug with external loopback test that caused test to pass even if
*  there is no loopback connector.  It works now, however, on the
*  prototype units, Port 5 (3E0h) still passes, probably due to
*  conductance(?) on the ribbon cable going to the distribution panel.
*  
*     Rev 1.6   15 Jan 1991 11:33:48   PJE
*  Added function fifo_capable() to test if DUART/UART is fifo capable
*  before doing the fifo test.  If capable, the fifo test is performed
*  assuming a 16 byte RX and TX fifo.
*  
*     Rev 1.5   11 Jan 1991 17:15:00   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.4   07 Jan 1991 18:19:54   PJE
*  Removed use of RS232.ASM -- all comm test code is now in this module. 
*  Also added test for FIFO component of chips.  If FIFO not supported,
*  SKIP is returned otherwise, FIFO mode is tested in polling mode.
*  
*     Rev 1.3   03 Jan 1991 17:09:48   AJW
*  Function test_comms divided to two functions:
*  test_internal_comms and test_external_comms.
*  
*     Rev 1.2   02 Jan 1991 10:11:34   AJW
*  Added log_error prototype.
*  
*     Rev 1.1   14 Dec 1990 10:55:42   PJE
*  Added activation of WDT port;
*   Removed PORT8 (Barcode) from ports to test as this socket
*   will not be populated on the production units.
*
*   Removed explicit Lan Test function, uses Test_Comm now, as
*   it is just a simple INTERNAL/EXTERNAL loopback test, just as
*   the others, rather than LAN IN to LAN OUT.
*
*   Skip EXTERNAL of PORT 4 if running on CT so that it doesn't
*   fail, as a serial printer is expected to be on that port.
*  
*     Rev 1.0   10 Dec 1990 10:34:36   PJE
*  Initial revision.
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"


/**********************
 Function Declarations 
***********************/

static STATUS Test_Comm(int port, char mode);

/*****************************
 Defines, Structures & Macros
******************************/

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
};

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
int test_com (int port, PORT_PARAMS *param, int buffer_size)
{
    PORT_PARAMS portp;
    int i;
    int testdata;
    int status;
    int data;
    STATUS result = PASSED;
    char tmp[80];

    activate_wdt();

    /* save the port configuration */
    portp.ier = inp (port + IER);
    portp.lcr = inp (port + LCR);
    portp.mcr = inp (port + MCR);

    outp (port + LCR, DLAB );               /* DLAB on */

    portp.baud_lo = inp (port  );
    portp.baud_hi = inp (port+1);

    outp (port + LCR, portp.lcr & ~DLAB);    /* DLAB off */

    /* initialize the comm port */

    outp (port + LCR, DLAB);                /* DLAB on */
    outp (port  , param->baud_lo );
    outp (port+1, param->baud_hi );

    outp (port + LCR, param->lcr & ~DLAB);  /* LCR and DLAB off */
    outp (port + IER, param->ier );         /* Interrupt Enable Register */
    outp (port + MCR, param->mcr );         /* Modem Control Register */

    /* test if port exists by checking lcr */
    if (inp (port + LCR) != param->lcr )
    {
        result = FAILED;
    } else
    {
        /* test data transfer */

        /* flush receive buffer(s) */
        while (wait_for (port+LSR, DATA_READY))
            inp (port + DATA);

        for (testdata = 0; testdata < (256 - buffer_size); testdata++)
        {
            /* transmit the data */
            for (i=testdata; i < testdata+buffer_size; i++)
            {
                if (wait_for (port + LSR, THRE))
                {
                    outp (port + DATA, (char)i );
                } else
                {
                    result = FAILED;
                    break;
                }
            }
            /* receive and check the data */
            for (i=testdata; (i < testdata+buffer_size) && (result == PASSED); i++)
            {
                if (wait_for (port + LSR, DATA_READY))
                {
                    data = inp (port + DATA);
                    if (data != i)
                    {
                        result = FAILED;
                        break;
                    }
                } else
                {
                    result = FAILED;
                }
            }
            if (result == FAILED) {
                break;
            }
        }
    }

    /* restore port configuration */
    outp (port + LCR, DLAB);                /* DLAB on */
    outp (port  , portp.baud_lo );
    outp (port+1, portp.baud_hi );

    outp (port + LCR, portp.lcr & ~DLAB);  /* LCR and DLAB off */
    outp (port + IER, portp.ier );         /* Interrupt Enable Register */
    outp (port + MCR, portp.mcr );         /* Modem Control Register */

    return (result);
}

/***********************************************************************
*
*   Function:   fifo_capable
*
*   Purpose:    determines if the chip supports fifo mode of operation
*
*   Arguments:  port address
*
*   Returns:    TRUE    - supports fifo
*               FALSE   - no fifo support
*
***********************************************************************/
int fifo_capable (int port )
{
    int capable = FALSE;
    int iir;

    outp (portaddr[port] + FCR, 0);           /* make sure fifo off */
    iir = inp (portaddr[port] + IIR);         /* check IIR state */
    if ((iir & 0xC0) == 0x00)       /* bits 6 and 7 set indicate fifo mode */
    {
        outp (portaddr[port] + FCR, 1);       /* activate fifo */
        iir = inp (portaddr[port] + IIR);     /* check IIR state */
        if ((iir & 0xC0) == 0xC0)   /* bits 6 and 7 set indicate fifo mode */
        {
            capable = TRUE;
            outp (portaddr[port] + FCR, 0);   /* turn off fifo */
        }
    }
    return (capable);
}

/***********************************************************************
*
*   Function:   test_fifo
*
*   Purpose:    tests for the presence of a FIFO (WD16C552 chip)
*               and tests it in FIFO mode
*
*   Arguments:  port address
*               mode -> INTERNAL | EXTERNAL
*
*   Returns:    PASSED  if successful;
*               FAILED  if failed;
*               SKIPPED if not fifo capable;
*
***********************************************************************/
int test_fifo (int port, int mode)
{
    int iir;
    PORT_PARAMS param;
    STATUS result;

    /* first determine if it is fifo-capable; port assumed to exist */
    if (fifo_capable(port ))
    {
        outp (portaddr[port] + FCR, 1);   /* activate fifo */
        iir = inp (portaddr[port] + IIR);     /* check IIR state */
        if ((iir & 0xC0) == 0xC0)   /* bits 6 and 7 set indicate fifo mode */
        {
            /* FIFO mode enabled - test with 16 byte buffer size */
            result = test_com (portaddr[port], &(portconfig[mode]), FIFO_BUFF);
            outp (portaddr[port] + FCR, 0);   /* deactivate fifo */
        } else
        {
            result = SKIPPED;
        }
    } else
    {
        result = SKIPPED;
    }
    return (result);
}


/***************************************************************************
*
*       function:               test_internal_comms()
*
*       purpose:                check out multi-function board's  comm ports
*                               (PORT 1, 2, 3, 4, 5, LANIN, LANOUT)
*
*       arguments:              none
*
*       returns:                int
*
*                               PASSED if test passed
*                               FAILED, if test failed
*                               SKIPPED if test was skipped
*
****************************************************************************/
int test_internal_comms()
{
    int     status;
    STATUS  result, tresult;
    BOOLEAN done;
    int     port;
    char    pr_line[80];

    result = PASSED;              /* assume we're going to pass this test */

    /*  Display the banner      */

    clear_all_windows();
    disp_title (menuopt[17]);
    disp_inst (NULL, NULL);


    /*  Now the COM ports will be checked - */
    /*      PORT1, PORT2, PORT3, PORT4, PORT5, LANIN, LANOUT */

    /*
     *  Internal Loopback Tests
     */
    
    v_stpl ( 1, 0, text[TXT_COMM_01], wnp);

    for (port = PORT1; port <= LANOUT; port++)
    {
        tresult = test_com (portaddr[port], &(portconfig[INTERNAL]), NORMAL_BUFF);

        if (tresult == FAILED) {
            result  = tresult;
            v_printf  (wnp, text[TXT_COMM_02], portname[port]);
            sprintf   (pr_line, text[TXT_COMM_09], portname[port] );
#ifdef FACTORY
            log_error (pr_line);
#endif
        } else
        {
            v_printf  (wnp, text[TXT_COMM_03], portname[port]);
        }
    }
    v_printf (wnp, text[TXT_COMM_08]);

    for (port = PORT1; port <= LANOUT; port++)
    {
        if (port_exists(portaddr[port]))
        {
            tresult = test_fifo (port, INTERNAL);
            switch (tresult)
            {
                case PASSED:
                    v_printf  (wnp, text[TXT_COMM_03], portname[port]);
                    break;
                case FAILED:
                    result  = tresult;
                    v_printf  (wnp, text[TXT_COMM_02], portname[port]);
                    sprintf   (pr_line, text[TXT_COMM_11], portname[port] );
#ifdef FACTORY
                    log_error (pr_line);
#endif
                    break;
                case SKIPPED:
                    v_printf  (wnp, text[TXT_COMM_07], portname[port]);
                    break;
            }
        } else
        {
            sprintf (pr_line, text[TXT_COMM_13], portname[port]);
            v_printf (wnp, pr_line);
        }
    }

    key_or_timeout (SHORT_DELAY);

    return(result);
}


/***************************************************************************
*
*       function:               test_external_comms()
*
*       purpose:                check out multi-function board's  comm ports
*                               (PORT1, 2, 3, 4, LANIN, LANOUT, PORT7, PORT8)
*
*       arguments:              none
*
*       returns:                int
*
*                               PASSED if test passed
*                               FAILED, if test failed
*                               SKIPPED if test was skipped
*
****************************************************************************/
int test_external_comms()
{
    int     status;
    STATUS  result, tresult;
    BOOLEAN done;
    int     port;
    char    pr_line[80];

    result = PASSED;              /* assume we're going to pass this test */

    /*  Display the banner      */

    clear_all_windows();
    disp_title (menuopt[18]);
    disp_inst (NULL, NULL);


    /*  Now the COM ports will be checked - */
    /*      PORT1, PORT2, PORT3, PORT4, PORT5, LANIN, LANOUT */

    /*
     *  External Loopback Tests
     */
    v_stpl ( 1, 0, text[TXT_COMM_04], wnp);

    for (port = PORT1; port <= LANOUT; port++)
    {
        if (!((Location == CT) && (port == PORT4)))
        /* don't do external loopback on Port 4 if CT, as
         * a serial printer is expected to be there
         */
        {
            tresult =   test_com (portaddr[port], &(portconfig[EXTERNAL]), NORMAL_BUFF);

            if (tresult == FAILED) {
                result = tresult;
                v_printf  (wnp, text[TXT_COMM_05], portname[port]);
                sprintf   (pr_line, text[TXT_COMM_10], portname[port] );
#ifdef FACTORY
                log_error (pr_line);
#endif
            } else
            {
                v_printf  (wnp, text[TXT_COMM_06], portname[port]);
            }
        }
    } 
    v_printf (wnp, text[TXT_COMM_08]);

    for (port = PORT1; port <= LANOUT; port++)
    {
        if (!((Location == CT) && (port == PORT4)))
        /* don't do external loopback on Port 4 if CT, as
         * a serial printer is expected to be there
         */
        {
            if (port_exists(portaddr[port]))
            {
                tresult = test_fifo (port, EXTERNAL);
                switch (tresult)
                {
                    case PASSED:
                        v_printf  (wnp, text[TXT_COMM_06], portname[port]);
                        break;
                    case FAILED:
                        result  = tresult;
                        v_printf  (wnp, text[TXT_COMM_05], portname[port]);
                        sprintf   (pr_line, text[TXT_COMM_12], portname[port] );
#ifdef FACTORY
                        log_error (pr_line);
#endif
                        break;
                    case SKIPPED:
                        v_printf  (wnp, text[TXT_COMM_07], portname[port]);
                        break;
                }
            } else
            {
                sprintf (pr_line, text[TXT_COMM_13], portname[port]);
                v_printf (wnp, pr_line);
            }
        }
    } 
    key_or_timeout (SHORT_DELAY);

    return(result);
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
int modemcom (int port, PORT_PARAMS *param, int buffer_size,char *buffer)
{
    PORT_PARAMS portp;
    int i,j;
    int status;
    int data;
    STATUS result = PASSED;
    char tmp[80];

    /* save the port configuration */
    portp.ier = inp (port + IER);
    portp.lcr = inp (port + LCR);
    portp.mcr = inp (port + MCR);

    outp (port + LCR, DLAB );               /* DLAB on */

    portp.baud_lo = inp (port  );
    portp.baud_hi = inp (port+1);
    outp (port + LCR, portp.lcr & ~DLAB);    /* DLAB off */

    /* initialize the comm port */

    outp (port + LCR, DLAB);                /* DLAB on */
    outp (port  , param->baud_lo );
    outp (port+1, param->baud_hi );

    outp (port + LCR, param->lcr & ~DLAB);  /* LCR and DLAB off */
    outp (port + IER, param->ier );         /* Interrupt Enable Register */
    outp (port + MCR, param->mcr );         /* Modem Control Register */

    /* test if port exists by checking lcr */
    if ((inp(port + LCR)&param->lcr) != param->lcr ) {
        result=FAILED;
    } else {
        while (wait_for (port+LSR, DATA_READY)) inp(port + DATA);

//  		  v_printf (wnp,buffer);
        for (i=0;i<buffer_size;i++) {
            if (wait_for (port + LSR, THRE)) {
                outp(port+DATA,buffer[i]);
            } else {
                result=FAILED;
                break;
            }
        }
        if (result!=FAILED) {
				i=0;
				j=0;
            while (i<9) {
					if (wait_for (port + LSR, DATA_READY)) {
					    buffer[j++]=inp(port + DATA);
						 i=8;
					}
					i++;
            }
            buffer[j]=0;
				if (j==0) result=FAILED;
//            v_printf (wnp,buffer);
        }
    }

    outp (port + LCR, DLAB);                /* DLAB on */
    outp (port  , portp.baud_lo );
    outp (port+1, portp.baud_hi );

    outp (port + LCR, portp.lcr & ~DLAB);  /* LCR and DLAB off */
    outp (port + IER, portp.ier );         /* Interrupt Enable Register */
    outp (port + MCR, portp.mcr );         /* Modem Control Register */

    return (result);
}
int setupmodem(int p)
{
	 int r;
    char tmp[10];
    strcpy(tmp,"ATX4E0V0\r");
    r=modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
    if ((r==FAILED)||(tmp[0]!='0')) return(FAILED);
    return(r);    
}
int modemlb(int p)
{
    char tmp[10];
	 int r;
    int i;
    strcpy(tmp,"ATE1\r");
    modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
    tmp[1]=0;
    for (i='A';i<='Z';i++) {
        tmp[0]=i;
        r=modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
        if ((r==FAILED)||(tmp[0]!=i)) return(FAILED);
    }
    return(r);    
}
int modemdt(int p)
{
    char tmp[12];
	 int r;

    strcpy(tmp,"ATE0\r");
    modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
    strcpy(tmp,"ATTD9;\r");
    r=modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
    strcpy(tmp,"ATH0E0V0X3\r");
    modemcom(portaddr[p],&(portconfig[MODEMTEST]),strlen(tmp),tmp);
    if ((r==FAILED)||(tmp[0]!='0')) return(FAILED);
    return(r);    
}

/***************************************************************************
*
*       function:               test_modem()
*
*       purpose:                test modem connected to port ?
*
*       arguments:              none
*
*       returns:                int
*
*                               PASSED if test passed
*                               FAILED, if test failed
*                               SKIPPED if test was skipped
*
****************************************************************************/
int test_modem()
{
	 int fd;
    int     status;
    STATUS  result, tresult;
    BOOLEAN done;
    int     port=1;
    char    pr_line[80];

    result = PASSED;              /* assume we're going to pass this test */

    /*  Display the banner      */

    clear_all_windows();
    disp_title (menuopt[16]);
    disp_inst (NULL, NULL);
	 fd=open("COMMPORT.NUM",O_RDONLY|O_BINARY);
	 if (fd!=(-1)) read(fd,pr_line,1);
	 close(fd);
	 port=pr_line[0]-'0';
	 if ((port<0)||(port>8)) port=1;

    v_stpl ( 1, 0, text[TXT_MODEM], wnp);
	 v_printf(wnp," RUNNING ON PORT - COM%d:\n",port+1);
    v_printf (wnp, text[TXT_MODEMR]);
    setupmodem(port);
    if (setupmodem(port)==PASSED) {
        v_printf (wnp, "PASSED\n");
    } else {
        v_printf (wnp, "FAILED\n");
        result = FAILED;
    }
    v_printf (wnp, text[TXT_MODEMLB]);
    if (modemlb(port)==PASSED) {
        v_printf (wnp, "PASSED\n");
    } else {
        v_printf (wnp, "FAILED\n");
        result = FAILED;
    }
    v_printf (wnp, text[TXT_MODEMDT]);
    if (modemdt(port)==PASSED) {
        v_printf (wnp, "PASSED\n");
    } else {
        v_printf (wnp, "FAILED\n");
        result = FAILED;
    }
    key_or_timeout (SHORT_DELAY);

    return(result);
}
