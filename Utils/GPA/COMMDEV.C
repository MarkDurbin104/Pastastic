#define COMMDEV_C
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <dos.h>
#include "types.h"
#include "control.h"
#include "message.h"
#include "commdev.h"
INT G_checkstat=1;
INT G_timlim=TIMEOUT;
INT G_commticker=0;
void interrupt (*coldtick)(void);

void setbaud(INT port,INT speed,INT bits,CHAR parity,INT stop)
{
	INT comln=0;								/* set of flags		       */
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
		default   : comln=0xE0;					/* default to 9600         */
	}
	if ((bits>4)&&(bits<9)) {
		comln|=(bits-5);
	}
	else {
		comln|=3;								/* default to 8 bits       */
	}
	switch(parity) {
		case 'E' :
		case 'e' : comln|=0x18; break;
		case 'O' :
		case 'o' : comln|=0x08; break;			/* default to no parity    */
	}
	if (stop==2) comln|=4;						/* default to 1 stop bit   */
	comln&=0xFF;
    r.x.ax=comln;
	r.x.dx=port;
	int86(0x14,&r,&r);
}
// initialise serial port
INT initport(INT port,INT r,INT b,CHAR p,INT s)
{
	ENTRY(5180);
	setbaud(port,r,b,p,s);
    OUTPB(G_port[port]+IER,0);                          // disable all interrupts
    OUTPB(G_port[port]+MCR,inp(G_port[port]+MCR)|(DTR|RTS)); // set DTR & RTS
	RETURNV(1);
}
INT endport(INT p)
{
    OUTPB(G_port[p]+MCR,inp(G_port[p]+MCR)&~(DTR|RTS));    // clear DTR & RTS
	RETURNV(1);
}
// check transmit not ready
INT txnotready(INT p)
{
	ENTRY(5190);
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&(DSR|CTS))!=(DSR|CTS))) RETURNV(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&THRE))                RETURNV(1);        // buf not ready
    RETURNV(0);
}
// check receive not ready
INT rxnotready(INT p)
{
	ENTRY(5200);
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&DSR)!=DSR)) RETURNV(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&DATR))                     RETURNV(1);        // buf not ready
    RETURNV(0);
}
// output a character to the serial port
void outchar(INT p,CHAR c)
{
	ENTRY(5210);
    OUTPB(G_port[p]+TDR,c);
	RETURN;
}
// input a character from the serial port
CHAR inchar(INT p)
{
	ENTRY(5220);
    RETURNV(inp(G_port[p]+RDR));
}
// input a character from the serial port with timeout
void interrupt cticker(void)
{
	(coldtick)();
	if ((++G_commticker)>10000) G_commticker=0;
}
int timeout(int limit)
{
    static int c,l;
    int t;
    if (!limit) { c=0; return(0); }
   	disable(); t=G_commticker; enable();
    if (l!=t) c++;
    l=t;
    return(c>=limit);
}
INT rxchar(INT p,CHAR *c)
{
    timeout(0);
    while (rxnotready(p)) {
		if (timeout(G_timlim)) RETURNV(0);
	}
    *c=inchar(p);
    RETURNV(1);
}
// output a character to the serial port with timeout
INT txchar(INT p,CHAR *c)
{
    timeout(0);
    while (txnotready(p)) {
		if (timeout(G_timlim)) RETURNV(0);
	}
    outchar(p,*c);
    RETURNV(1);
}
// receive a string from the serial prot
INT rxstr(INT p,CHAR *s,INT maxlen,UCHAR eot,INT over,INT to)
{
    INT i=0,t,xit=0;
    INT stat,cd=0;
	ENTRY(5250);

//	fprintf(stdout,"\nRX ");
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
// transmit a string to the serial port
INT txstr(INT p,CHAR *s,INT l)
{
	ENTRY(5260);
//	fprintf(stdout,"\nTX ");
	if (!l) {
	    while (*s) if (!txchar(p,s++)) RETURNV(0);
	} else {
	    while (l--) if (!txchar(p,s++)) RETURNV(0);
	}
    RETURNV(1);
}
// scale control routine
INT comm_control(INT type,va_list ap)
{
    INT port,rate,bits,par,stop,retval=0;
    CHAR *t;
	UCHAR eot;

    switch (type) {
        case 'in' :                     // input
			G_checkstat=0;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
			rate=va_arg(ap,INT);
			eot=va_arg(ap,UCHAR);
			bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,bits,0);
			break;
        case 'i' :                      // input
			G_checkstat=0;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
			rate=va_arg(ap,INT);
			eot=va_arg(ap,UCHAR);
			bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,bits,0);
			break;
        case 'it' :                      // input
			G_checkstat=0;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
			rate=va_arg(ap,INT);
			eot=va_arg(ap,UCHAR);
			bits=va_arg(ap,INT);
            retval=rxstr(port,t,rate,eot,bits,va_arg(ap,INT));
			break;
        case 'O' :                      // output check stat
			G_checkstat=1;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
            retval=txstr(port,t,0);
            break;
        case 'On' :                      // output dont check stat
			G_checkstat=0;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
            retval=txstr(port,t,0);
            break;
        case 'Ol' :                      // output fixed length
			G_checkstat=0;
			G_timlim=TIMEOUT;
			port=va_arg(ap,INT);
			t=va_arg(ap,CHAR *);
			stop=va_arg(ap,INT);
            retval=txstr(port,t,stop);
            break;
        case 'SI' :                      // Start up init
		    coldtick=getvect(0x1C);
		    setvect(0x1C,cticker);
			break;
        case 'SE' :                      // Start up EXIT
		    setvect(0x1C,coldtick);
			break;
        case 'I' :                       // init
			port=va_arg(ap,INT);
			rate=va_arg(ap,INT);
			bits=va_arg(ap,INT);
			par=va_arg(ap,INT);
			stop=va_arg(ap,INT);
            retval=initport(port,rate,bits,par,stop);
            break;
        case 'E' :                      // end
			port=va_arg(ap,INT);
            retval=endport(port);
            break;
    }
    RETURNV(retval);
}

