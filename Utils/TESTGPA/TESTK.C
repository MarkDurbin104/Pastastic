#define INSL        0x80
#define CAPSL       0x40 
#define NUML        0x20 
#define SCROLLL     0x10
#define ALT         0x08
#define CTRL        0x04
#define LSHIFT      0x02
#define RSHIFT      0x01

#include <dos.h>
#include <stdio.h>
#include <conio.h>

#include "keydef.h"

unsigned char far *G_shiftstat;
int sendkbdata(unsigned char d)
{
    int to,retry=3;
    disable();
    while (retry) {
        to=32000;
        while (((inp(0x64)&2)==2)&&(to)) to--;
        if (to) {
            outp(0x60,d);
            enable();
            delay(10);
            return(1);
        }
        retry--;
    }
    enable();
    return(0);
}
void setflags(void)
{
	static unsigned char ss=0;
    int to;
	unsigned char s=0,gss;
    gss=*G_shiftstat;
	if (ss!=(gss&(CAPSL|NUML|SCROLLL))) {
		ss=(gss&(CAPSL|NUML|SCROLLL));
		if ((gss&CAPSL  )!=0) s|=4;
		if ((gss&NUML   )!=0) s|=2;
		if ((gss&SCROLLL)!=0) s|=1;

        if (sendkbdata(0xED)) {
            sendkbdata(s);
        }
        sendkbdata(0xF4);
	}
}

void main(void)
{
    char tmp;
    G_shiftstat=(char far *)(0x000000417L);
    while (!kbhit()) {
        printf("%02X",*G_shiftstat);
        *G_shiftstat^=NUML;     setflags();
        delay(20);
        *G_shiftstat^=CAPSL;    setflags();
        delay(20);
        *G_shiftstat^=SCROLLL;  setflags();
        delay(20);
        *G_shiftstat^=SCROLLL;  setflags();
        delay(20);
        *G_shiftstat^=CAPSL;    setflags();
        delay(20);
        *G_shiftstat^=NUML;     setflags();
        delay(20);
    }
}
