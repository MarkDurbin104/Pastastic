#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "driver.h"
#include "drvserv.h"

#ifndef DRIVER_CODE
#endif

#define VER_MAJOR	1
#define VER_MINOR	0

void interrupt (*oldtick)(void);
volatile int G_ticker=0;

char *G_signon="\r\nSerial device driver Version ";

int drvinit(INITBLK far *ibp);

void interrupt ticker(void)
{
	(oldtick)();
	if ((++G_ticker)>10000) G_ticker=0;
}

void pascal drventry(PARMBLK far *req)
{
    int res;
    switch (req->r.cmd) {
        case INIT    :
            res=drvinit(&(req->p.ini));
            break;
		case MEDCHK  :
		case BLDBPB  :
		case IOCRLTI :
		case INPUT   :
		case IPNOWT  :
		case IPSTAT  :
		case IPFLSH  :
		case OUTPUT  :
		case OPVERI  :
		case OPSTAT  :
		case OPFLSH  :
		case IOCRLTO :
            res=0;
            break;
        default:
            res=0;
    }
    req->r.stat=res|DONE;
}

int drvinit(INITBLK far *ibp)
{
	int i;
	char tmp[2];
	char far *t;
	ibp->brk[0]=0x2000;
    ibp->brk[1]=_CS;

    oldtick=getvect(0x1C);
    setvect(0x1C,ticker);

    print(G_signon);
	printx(VER_MAJOR); print(".0"); printx(VER_MINOR); print("\r\n");
    prat("%s","Copyright (c) Unisys Ltd. 1994\r\n");
	t=ibp->bpb;
	tmp[1]=0;
	for (i=0;i<80;i++) {
		if ((!*t)||(*t=='\r')) break;
		tmp[0]=*(t++);
		print(tmp);
	}
    print("\r\n\r\n");
/*	i=0;
	while (i<36) {
		if (i!=G_ticker) print(".");
		i=G_ticker;
	}*/
    return(0);
}
#ifndef DRIVER_CODE
UINT calldriver(char *args,char cmd)
{
	PARMBLK p;
	p.r.cmd=cmd;
	p.p.ini.bpb=args;
	drventry(&p);
	return(p.r.stat);
}
int main(int argc,char *argv[])
{
	char tmp[160];
	int i;
	tmp[0]=0;
	for (i=0;i<argc;i++) { strcat(tmp,argv[i]); strcat(tmp," "); }
	printf("%04X\n",calldriver(tmp,INIT));
	return(0);
} 
#endif
