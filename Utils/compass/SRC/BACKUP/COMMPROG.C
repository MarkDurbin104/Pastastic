#include <dos.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>

/*****************************
 Defines, Structures & Macros
******************************/

#define BOXTOPLEFT  "⁄…‹" // character for top left corner of box
#define BOXTOPRIGHT "øª‹" // character for top right corner of box
#define BOXBOTLEFT  "¿»ﬂ" // character for bottom left corner of box
#define BOXBOTRIGHT "Ÿºﬂ" // character for bottom right corner of box
#define BOXLEFT     "≥∫€" // character for left (and right) side of box
#define BOXRIGHT    "≥∫€" // character for left (and right) side of box
#define BOXTOP      "ƒÕ‹" // character for top (and bottom) side of box
#define BOXBOTTOM   "ƒÕﬂ" // character for top (and bottom) side of box
#define BOXLEFTIN   "√Ã€" // character for cut in from left side of box
#define BOXTOPIN    "¬À‹" // character for cut in from top side of box
#define BOXRIGHTIN  "¥π€" // character for cut in from right side of box
#define BOXBOTIN    "¡ ﬂ" // character for cut in from bottom side of box
#define BOXCROSS    "≈Œ€" // character for crossing lines in box

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
    0x3E8,          // port 4
};

#define SCREENBASE  MK_FP(__SegB800,0)
typedef void interrupt (*ISRPTR)(void);
ISRPTR                   oldtick;

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
    unsigned int i;
    int status;
    int result = 0;

    for (i=0; i < 1000; i++)
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
void OutChar(int x,int y,int colour,char ch)
{
    unsigned int far *scr=(unsigned int far *)SCREENBASE;  // video memory base address
    scr+=x+y*80;                           // offset to x/y
    *scr=((colour&0xFF)<<8)|(unsigned char)ch;     // place the char and attribute
//    gotoxy(x%80+1,y+x/80);
//    textattr(colour);
//    cprintf("%c",ch);
}
//==========================================================================
//F Rectangle
//S Draw a rectangle
//D Draw a rectangle using the character output device
//P First X Co-ordinate
//P First Y Co-ordinate
//P Second X Co-ordinate
//P Second Y Co-ordinate
//P The attribute of the box characters
//P The type of the box characters i.e. 0 = ⁄ƒ   1 = …Õ   2 = €ﬂ
void Rectangle(int x,int y,int x1,int y1,int colour,int type)
{
    int paramswap;                                 // for swapping params
    int xcount;                                    // counter for x co-ordinate
    int ycount;                                    // counter for y co-ordinate

    if ( (x==x1) || (y==y1) ) return;              // Not Visible return

    if (x>x1) { paramswap=x; x=x1; x1=paramswap; } // swap x & x1 order
    if (y>y1) { paramswap=y; y=y1; y1=paramswap; } // swap y & y1 order

    OutChar(x ,y ,colour,*(BOXTOPLEFT +type));     // output the corners
    OutChar(x1,y ,colour,*(BOXTOPRIGHT+type));         
    OutChar(x ,y1,colour,*(BOXBOTLEFT +type));
    OutChar(x1,y1,colour,*(BOXBOTRIGHT+type));

    for (xcount=x+1;xcount<=x1-1;xcount++) {       // output the top & bottom
        OutChar(xcount,y ,colour,*(BOXTOP   +type));
        OutChar(xcount,y1,colour,*(BOXBOTTOM+type));
    }
    for (ycount=y+1;ycount<=y1-1;ycount++) {       // output the left & right
        OutChar(x ,ycount,colour,*(BOXLEFT+type));
        OutChar(x1,ycount,colour,*(BOXLEFT+type));
    }
}
void OutStr(int x,int y,int colour,char *s)
{
    while (*s) OutChar(x++,y,colour,*(s++));
}
void OutText(int x,int y,int colour,char *fmt,...)
{
    static char str[200];
    char *s;
	va_list ap;
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
    OutStr(x,y,colour,str);
}
char *itobin(unsigned char i)
{
    static char retval[10];
    unsigned char mask=0x80;
    retval[0]='\0';
    while (mask) {
        if ((i&mask)==0) strcat(retval,"0"); else strcat(retval,"1");
        mask>>=1;
    }
    return retval;
}
typedef struct {
    int x;
    int y;
    int cx;
    int cy;
    int w;
    int h;
    char *buffer;
} WINDOW;

void rxtx(int port1,int port2)
{
    unsigned char data;
    int x=0;
    while (!kbhit()) {
        OutText( 1,1,0x1F,"%s",itobin(inp(port1+LSR)));
        OutText(21,1,0x1F,"%s",itobin(inp(port1+MSR)));
        OutText(41,1,0x1F,"%s",itobin(inp(port2+LSR)));
        OutText(61,1,0x1F,"%s",itobin(inp(port2+MSR)));

        if ((inp(port1+LSR)&DATA_READY)==DATA_READY) {
            data=inp(port1+DATA);
            if (wait_for(port2+LSR,THRE)) {
                outp(port2+DATA,data);
                OutChar(x++,2,0x1F,data&0xFF);
            }
        }
        if ((inp(port2+LSR)&DATA_READY)==DATA_READY) {
            data=inp(port2+DATA);
            if (wait_for(port1+LSR,THRE)) {
                outp(port1+DATA,data);
                OutChar(x++,2,0x0F,data&0xFF);
            }
        }
        if (x>1600) { clrscr(); x=0; }
    }
}
void setbaud(int port,long baud)
{
    unsigned int divisor;
    unsigned char lcr;
    if (baud==0)
        divisor=1;
    else
        divisor=(unsigned int)((1843200L/baud + 8) / 16);
 
    lcr=inp(port+LCR);
    disable();
    outportb(port+MCR,DTR|RTS);
    outportb(port+LCR,lcr|DLAB);
    outportb(port+0,(unsigned char) divisor);
    outportb(port+1,(unsigned char) (divisor>>8));
    outportb(port+LCR,lcr);
}
void interrupt ticker(void)
{
    static count=0;
    int i;
	(oldtick)();
    if ((count%9)==0) {
        count=0;
        for (i=0;i<4;i++) {
            OutStr(19,i*6+1,0x0E,itobin(inp(portaddr[i]+IER)));
            OutStr(32,i*6+1,0x0E,itobin(inp(portaddr[i]+LSR)));
            OutStr(45,i*6+1,0x0E,itobin(inp(portaddr[i]+MSR)));
        }
    }
    count++;
}
int main(int argc,char *argv[])
{
    int i;
    long baud;
    int lcr;
    clrscr();

    oldtick=getvect(0x1C);
    setvect(0x1C,ticker);

    setbaud(portaddr[0],9600L);
    setbaud(portaddr[1],19200L);
    for (i=0;i<4;i++) {
        Rectangle(40,i*6+2,79,i*6+6,0x0F,0);
        Rectangle(0,i*6+2,79,i*6+6,0x0F,0);
        OutText(2,i*6+2,0x09,"Transmit");
        OutText(42,i*6+2,0x09,"Recieve");
        lcr=inp(portaddr[i]+LCR);                                                                    
        outportb(portaddr[i]+LCR,lcr|DLAB);                                                          
        baud=inportb(portaddr[i]);                                                                   
        baud|=((long)(inportb(portaddr[i]+1)))<<8;                                                   
        outportb(portaddr[i]+LCR,lcr);                                                               
        OutText( 2,i*6+1,0x0E,"Port %d 0x%3X IER %s ",i+1,portaddr[i],itobin(inp(portaddr[i]+IER))); 
        OutText(28,i*6+1,0x0E,"LSR %s ",itobin(inp(portaddr[i]+LSR)));                               
        OutText(41,i*6+1,0x0E,"MSR %s BAUD %ld",itobin(inp(portaddr[i]+MSR)),1843200L/(16L*baud));   
    }
    getch();
    while (!kbhit()) {
        if (wait_for(portaddr[0]+LSR,THRE)) {
          outportb(portaddr[0]+DATA,'A');
        }
    }
    getch();

    getch();

    setvect(0x1C,oldtick);
    textattr(0x07);
    clrscr();
    return 1;
}

