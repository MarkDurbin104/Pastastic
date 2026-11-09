/****************************************************************************
* Project     : GPA
* File        : commdev.c
* Description : Comm port support routines
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:14:52  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/commdev.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:14:52   JGRAY
*  
* 
****************************************************************************/
#define COMMDEV_C
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <dos.h>
#include "gpasizes.h"
#include "types.h"
#include "control.h"
#include "message.h"
#include "commdev.h"
INT G_checkstat=1;
INT G_timlim=TIMEOUT;
//INT G_commticker=0;
//void interrupt (*coldtick)(void);

//************************************************************
//S Set baud rate for the specified port
//P integer port no.
//P integer speed (baud) Max of 9600 - Maybe needs updating ?:JGQ 25/10
//P integer bits
//P integer parity
//P integer stop bits

void setbaud(INT port,INT speed,INT bits,CHAR parity,INT stop)
{
    INT comln=0;                                /* set of flags               */
    union REGS r;
    *com4addr=G_port[port];
    port=3;
    switch(speed) {
        case 9600 : comln=0xE0; break;
        case 4800 : comln=0xC0; break;
        case 2400 : comln=0xA0; break;
        case 1200 : comln=0x80; break;
        case  600 : comln=0x60; break;
        case  300 : comln=0x40; break;
        case  150 : comln=0x20; break;
        case  110 : comln=0x00; break;
        default   : comln=0xE0;                    /* default to 9600         */
    }
    if ((bits>4)&&(bits<9)) {
        comln|=(bits-5);
    }
    else {
        comln|=3;                                /* default to 8 bits       */
    }
    switch(parity) {
        case 'E' :
        case 'e' : comln|=0x18; break;
        case 'O' :
        case 'o' : comln|=0x08; break;            /* default to no parity    */
    }
    if (stop==2) comln|=4;                        /* default to 1 stop bit   */
    comln&=0xFF;
    r.x.ax=comln;
    r.x.dx=port;
    int86(0x14,&r,&r);
}

//************************************************************
//S initialise serial port - sets dtr, rts and disables interrupts
//P integer port no.
//P integer speed (baud) 
//P integer bits
//P integer parity
//P integer stop bits
//R TRUE

INT initport(INT port,INT r,INT b,CHAR p,INT s)
{
    ENTRY(5180);
    setbaud(port,r,b,p,s);
    OUTPB(G_port[port]+IER,0);                          // disable all interrupts
    OUTPB(G_port[port]+MCR,inp(G_port[port]+MCR)|(DTR|RTS)); // set DTR & RTS
    RETURNV(1);
}

//************************************************************
//S releases port by clearing dtr & rts
//P integer port no.
//R TRUE

INT endport(INT p)
{
    OUTPB(G_port[p]+MCR,inp(G_port[p]+MCR)&~(DTR|RTS));    // clear DTR & RTS
    RETURNV(1);
}

//************************************************************
//S check transmit not ready
//D provided status is checkable will look at dsr and rts
//D otherwise just checks for output buffer full
//P integer port no.
//R integer -1 for line not ready, +1 for buffer not ready, 0 for ok

INT txnotready(INT p)
{
    ENTRY(5190);
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&(DSR|CTS))!=(DSR|CTS)))
        RETURNV(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&THRE))
        RETURNV(1);        // buf not ready
    RETURNV(0);
}

//************************************************************
//S check receive not ready
//D provided status is checkable will look at dsr
//D otherwise just checks for data in input buffer
//P integer port no.
//R integer -1 for line not ready, +1 for no data in buffer, 0 for ok

INT rxnotready(INT p)
{
    ENTRY(5200);
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&DSR)!=DSR))
        RETURNV(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&DATR))
        RETURNV(1);        // buf not ready
    RETURNV(0);
}

//************************************************************
//S output a character to the serial port
//P integer port no.
//P char to send

void outchar(INT p,CHAR c)
{
    ENTRY(5210);
    OUTPB(G_port[p]+TDR,c);
    RETURN;
}

//************************************************************
//S input a character from the serial port
//P integer port no.
//R char from port

CHAR inchar(INT p)
{
    ENTRY(5220);
    RETURNV(inp(G_port[p]+RDR));
}

// input a character from the serial port with timeout
//void interrupt cticker(void)
//{
//    (coldtick)();
//    if ((++G_commticker)>10000) G_commticker=0;
//}

//************************************************************
//S determine if timer has tripped
//P integer no. of iterations trip size - zero resets and returns FALSE
//R TRUE if tripped

INT timeout(INT limit)
{
    static INT c;
    static LONG l;
    LONG t;
    if (!limit)
        {
        c=0;
        l=0;
        return(0);
        }
    t=sendmsg("INPUT1",MESSAGE_tc);     // get time for trip check in seconds?
//       disable(); t=G_commticker; enable();
    if (l!=t)
        c++;
    l=t;
    return(c>=limit);
}

//************************************************************
//S wait for a character with timeout
//D relies on G_timlim to determine max time to wait
//P integer port no.
//P address where to put the char received
//R TRUE if a char received, FALSE if timed out waiting

INT rxchar(INT p,CHAR *c)
{
    timeout(0);
    while (rxnotready(p)) {
        if (timeout(G_timlim)) RETURNV(0);
    }
    *c=inchar(p);
    RETURNV(1);
}

//************************************************************
//S output a character to the serial port with timeout
//D relies on same G_timlim as for rx char timeout
//P integer port no.
//P address of char to send
//R FALSE if failed to send, TRUE if succeeded

INT txchar(INT p,CHAR *c)
{
    timeout(0);
    while (txnotready(p)) {
        if (timeout(G_timlim)) RETURNV(0);
    }
    outchar(p,*c);
    RETURNV(1);
}

//************************************************************
//S receive a string from the serial prot
//D doesn't really mean 'STRING' - 'cos doesn't set a null delim!
//P integer port no.
//P char address of target string
//P integer maximum length to receive
//P eot char to scan for - if specified qty of them is received exits
//P iifp control char to enable receipt of eot chars
//P no. of eots to allow before exiting
//P no. of times to timeout before giving up
//R no. of chars received

INT rxstr(INT p,CHAR *s,INT maxlen,UCHAR eot,UCHAR iifp,INT over,INT to)
{
    INT i=0,t,xit=0;
    INT stat,cd=0;
    INT nocontrol=0;

    while (!xit) {
        t=to; 
        while (((stat=rxchar(p,s))==0)&&(t>=0))
            t--;
        if ((t>=0)||(stat))
            {
            if (i>=maxlen)
                return(i);
            if ((!nocontrol)&&(iifp)&&(*s==iifp)&&(!cd))
                {
                nocontrol=1;
                }
            else
                {
                if (nocontrol==1)
                    {
                    nocontrol=0;
                    }
                else
                    {
                    if ((eot)&&(eot==*s))
                        cd=1;
                    }
                }
            if (cd)
                {
                if (over==0)
                    return(i);
                over--;
                }
            i++;
            s++;
            }
        else
            {
            xit=1;
            }
        }
    return(i);
}

/*
INT rxstr(INT p,CHAR *s,INT maxlen,UCHAR eot,INT over,INT to)
{
    INT i=0,t,xit=0;
    INT stat,cd=0;
    ENTRY(5250);

    while (!xit) {
        t=to;
        *(s+1)=0;
        while (((stat=rxchar(p,s))==0)&&(t)) t--;
        if (stat!=0) {
            if (i>=maxlen) RETURNV(1);
            if ((eot)&&(eot==*s)) cd=1;
            if (cd) {
                if (over==0) RETURNV(1);
                over--;
            }
            i++;
            s++;
        } else {
            xit=1;
        }
    }
    RETURNV(stat);
}
*/

//************************************************************
//S transmit a string to the serial port
//P integer port no.
//P char string address
//P integer length of string to transmit - 0 means transmit until null char encountered
//R TRUE for tx ok, FALSE if timeout during attempt

INT txstr(INT p,CHAR *s,INT l)
{
    ENTRY(5260);
//    fprintf(stdout,"\nTX ");
    if (!l)
        {
        while (*s)
            {
            if (!txchar(p,s++))
                {
                RETURNV(0);
                }
            }
        }
    else
        {
        while (l--)
            {
            if (!txchar(p,s++))
                {
                RETURNV(0);
                }
            }
        }
    RETURNV(1);
}

//************************************************************
//S scale control routine
//P integer type
//P variable list
//R BOOL TRUE for Ok, FALSE for FAILED

// 
INT comm_control(INT type,va_list ap)
{
    INT port,rate,bits,par,stop,retval=0;
    CHAR *t;
    UCHAR eot,dle;

    switch (type)
        {
        case MESSAGE_in :                     // input
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            rate=va_arg(ap,INT);
            eot=va_arg(ap,UCHAR);
            bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,0,bits,0);
            break;
        case MESSAGE_i :                      // input
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            rate=va_arg(ap,INT);
            eot=va_arg(ap,UCHAR);
            bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,0,bits,0);
            break;
        case MESSAGE_it :                      // input
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            rate=va_arg(ap,INT);
            eot=va_arg(ap,UCHAR);
            bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,0,bits,va_arg(ap,INT));
            break;
        case MESSAGE_P :                      // PDF i.e. DLE preceeds STX.ETX & DLE in data
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            rate=va_arg(ap,INT);
            eot=va_arg(ap,UCHAR);
            dle=va_arg(ap,UCHAR);
            bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,dle,bits,va_arg(ap,INT));
            break;
        case MESSAGE_O :                      // output check stat
            G_checkstat=1;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            retval=txstr(port,t,0);
            break;
        case MESSAGE_On :                      // output dont check stat
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            retval=txstr(port,t,0);
            break;
        case MESSAGE_Ol :                      // output fixed length
            G_checkstat=0;
            G_timlim=TIMEOUT;
            port=va_arg(ap,INT);
            t=va_arg(ap,CHAR *);
            stop=va_arg(ap,INT);
            retval=txstr(port,t,stop);
            break;
        case MESSAGE_SI :                      // Start up init
//            coldtick=getvect(0x1C);
//            setvect(0x1C,cticker);
            break;
        case MESSAGE_SE :                      // Start up EXIT
//            setvect(0x1C,coldtick);
            break;
        case MESSAGE_I :                       // init
            port=va_arg(ap,INT);
            rate=va_arg(ap,INT);
            bits=va_arg(ap,INT);
            par=va_arg(ap,INT);
            stop=va_arg(ap,INT);
            retval=initport(port,rate,bits,par,stop);
            break;
        case MESSAGE_E :                      // end
            port=va_arg(ap,INT);
            retval=endport(port);
            break;
    }
    RETURNV(retval);
}
// **************************************************************************
// commdev.c <end-of-file>

