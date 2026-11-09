#define SPRNDEV_C
#define SPRNDEVICE
//___________________________________________________________________________

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <ctype.h>
#include "types.h"
#include "control.h"
#include "sprndev.h"
#include "config.h"

FILE *G_sprinter;

// initialise the serial printer port via int 14h call
int setcomms(int port,int baud,char parity,char bits,char stop)
{
    union REGS regs;                /* set of register variables            */
    unsigned char bitmap;           /* used to build up parameters for call */

    regs.x.dx=port;                 /* set port to access                   */

    switch (baud) {                 /* set bits 7, 6 & 5 for baud rate      */
        case 9600 : bitmap=0xE0; break;
        case 4800 : bitmap=0xC0; break;
        case 2400 : bitmap=0xA0; break;
        case 1200 : bitmap=0x80; break;
        case  600 : bitmap=0x60; break;
        case  300 : bitmap=0x40; break;
        case  150 : bitmap=0x20; break;
        case  110 : bitmap=0x00; break;
        default   : bitmap=0xE0;        /* default to 9600 baud             */
    }
    switch (parity) {                   /* set bits 3 & 4 for parity        */
        case 'O' :
        case 'o' : bitmap|=0x08; break;
        case 'E' :
        case 'e' : bitmap|=0x18; break;
        case 'N' :
        case 'n' : break;
        default  : break;               /* default to None                  */
    }
    switch (bits) {                     /* set bits 0 & 1 for data bits     */
        case 8  : bitmap|=0x03; break;
        case 7  : bitmap|=0x02; break;
        case 6  : bitmap|=0x01; break;
        case 5  : break;
        default : bitmap|=0x03;         /* default to 8 bits                */
    }
    switch (stop) {                     /* set bit 2 for stop bits          */
        case 2  : bitmap|=0x04; break;
        case 1  : break;                
        default : break;                /* default to 1 stop bit            */
    }

    regs.h.ah=0;                        /* function 0                       */
    regs.h.al=bitmap;

    int86(14,&regs,&regs);              /* Call INT 14h                     */

    return(regs.x.ax);                  /* Return serial port status        */
}
// printer character output routine
void spoutch(int x,int y,char c)
{
    G_sprn[x+80*y]=c;
}
// printer formated output routine
int spprat(int x,int y,char *fmt, ... )
{
    unsigned char str[140],*s;
    va_list ap;
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
    s=str;
    if (x==(-1)) {
        while (*s) {
            if (*s>127) {
                switch (*s) {
                    case 189 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x96,0x9A,0x92,0xB2,0xD2,0x00)==(-1)) return(0);
                        break;
                    case 141 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x23,0x25,0x39,0xB1,0xA1,0x00)==(-1)) return(0);
                        break;
                    case 164 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x3E,0x50,0x90,0x52,0x3F,0x01)==(-1)) return(0);
                        break;
                    case 143 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x1E,0x21,0x21,0xA1,0x92,0x00)==(-1)) return(0);
                        break;
                    case 168 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0xFE,0x92,0x92,0x92,0x83,0x01)==(-1)) return(0);
                        break;
                    case 157 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x08,0xFE,0x22,0x42,0x02,0x00)==(-1)) return(0);
                        break;
                    case 227 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x3F,0x10,0x0C,0x82,0xBF,0x00)==(-1)) return(0);
                        break;
                    case 224 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x1E,0x21,0x21,0xA1,0x9E,0x00)==(-1)) return(0);
                        break;
                    case 151 :
                        if (fprintf(G_sprinter,"%c*%c%c%c",27,0,6,0)==(-1)) return(0);
                        if (fprintf(G_sprinter,"%c%c%c%c%c%c",0x32,0x49,0x49,0xC9,0xA6,0x00)==(-1)) return(0);
                        break;
                }
                s++;
            }
            else {
                if (fprintf(G_sprinter,"%c",*(s++))==(-1)) return(0);
            }
        }
    }
    else {
        if (x==(-2)) {
            while (y) {
                if (fprintf(G_sprinter,"%c",*(s++))==(-1)) return(0);
                y--;
            }
        }
        else {
            while (*s) spoutch(x++,y,*(s++));
        }
    }
    return(1);
}
// printer output routine
int sprn_output(int x,int y,char *fmt,...)
{
    char tmp[160];
    va_list ap;

    va_start(ap,fmt);
    vsprintf(tmp,fmt,ap);
    va_end(ap);
    if (!spprat(x,y,"%s",tmp)) return(0);
    return(1);
} 
// printer shutdown routine
int sprn_shutdown(void)
{
//    fclose(G_sprinter);
    return(1);                 
}
// printer startup routine
int sprn_startup(void)
{
    int *port=(int *)0x00400000L;
    union REGS r;
    G_sprinter=stdaux;
//    G_sprinter=fopen("print.log","w");

    *port=0x310;
    r.x.ax=0x00E3;
    r.x.dx=0;
    int86(0x14,&r,&r);

    return(1);
}
// printer control routine
int sprn_control(int type,va_list ap)
{
    int retval=0;
	int x,y;
	char *f,tmp[160];
    switch (type) {
		case 'o' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
			retval=sprn_output(x,y,"%s",tmp);
			break;

        case 'I' :
            sprn_startup();
            break;

        case 'E' :
            sprn_shutdown();
            break;
    }
    return(retval);
} 
//___________________________________________________________________________

