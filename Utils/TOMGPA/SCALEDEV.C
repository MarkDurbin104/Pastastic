#define SCALEDEV_C
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <dos.h>
#include "types.h"
#include "control.h"
#include "message.h"
#include "scaledev.h"
#include "config.h"

#ifdef ONLY_ME
#include <conio.h>
#endif // def ONLY_ME

#define GRAMS           0
#define THOZ            1
#define G_PER_10TH_OZ   2.835
#define G_PER_100TH_OZ  0.2835
//#define PORT			0  // PMC-TAIWAN - WRU
#define PORT			7  // PMC-US/UK
//#define PORT			5  // IRT
#define ETX 			3

INT G_otype=GRAMS;
// check rx'ed string format
INT checkstr(CHAR *r)
{
    static CHAR cmps[]="\n99LB 99.9OZ\rX@\r";
    INT i;
	ENTRY(5130);
    for (i=0;i<16;i++) {
        switch (cmps[i]) {
            case '9' :
                if ((r[i]<'0')||(r[i]>'9')) RETURNV(0);
                break;
            case 'X' :
                if ((r[i]<'A')||(r[i]>'Z')) RETURNV(0);
                break;
            default :
                if (r[i]!=cmps[i]) RETURNV(0);
        }
    }
    RETURNV(1);
}
// scale input routine
INT sca_input(void)
{
    CHAR tmp[30];
    CHAR tmp1[30];
    CHAR retry=5;
    INT grams=0;
    INT thoz=0;
    double res;
	ENTRY(5140);

    do {
	    if (!sendmsg("INOUT1",MESSAGE_On,PORT,"W\r")) RETURNV(-1);
	    if (!sendmsg("INOUT1",MESSAGE_in,PORT,tmp,19,ETX,0)) RETURNV(-2);
        if (!checkstr(tmp)) {
			tmp[13]='A';
		} else {
        	sprintf(tmp1,"%c%c",tmp[1],tmp[2]);
        	res=atof(tmp1)*160;
        	sprintf(tmp1,"%c%c%c",tmp[6],tmp[7],tmp[9]);
        	res+=atof(tmp1);
        	thoz=(INT)res;
        	grams=(INT)(res*G_PER_10TH_OZ);
		}
        retry--;
    } while ((tmp[13]!='H')&&(tmp[13]!='J')&&(tmp[13]!='Z')&&(retry));
    if (G_otype==GRAMS) RETURNV(grams);
    RETURNV(thoz);
} 
// scale input routine
INT sca_hinput(void)
{
    CHAR tmp[30];
    CHAR tmp2[30];
    CHAR tmp1[30];
    CHAR retry=0;
    INT grams=0;
    INT thoz=0;
    double res;
	ENTRY(5150);

    do {
	    if (!sendmsg("INOUT1",MESSAGE_On,PORT,"T\r")) RETURNV(-1);
	    sendmsg("INOUT1",MESSAGE_in,PORT,tmp2,8,ETX,0);
	    if (!sendmsg("INOUT1",MESSAGE_On,PORT,"W\r")) RETURNV(-1);
	    if (!sendmsg("INOUT1",MESSAGE_in,PORT,tmp,19,ETX,0)) RETURNV(-2);
	    if (!sendmsg("INOUT1",MESSAGE_On,PORT,"N\r")) RETURNV(-1);
	    sendmsg("INOUT1",MESSAGE_in,PORT,tmp2,8,ETX,0);
        sprintf(tmp1,"%c%c",tmp[1],tmp[2]);
        res=atof(tmp1)*1600.0;
        sprintf(tmp1,"%c%c%c%c",tmp[6],tmp[7],tmp[9],tmp[10]);
        res+=atof(tmp1);
        thoz=(INT)res;
        grams=(INT)((res*G_PER_100TH_OZ)+0.5);
        retry++;
    } while ((tmp[14]!='H')&&(tmp[14]!='J')&&(tmp[14]!='Z')&&(retry<10));
    sendmsg("INOUT1",MESSAGE_On,PORT,"W\r");
    sendmsg("INOUT1",MESSAGE_in,PORT,tmp2,19,ETX,0);
    if (G_otype==GRAMS) RETURNV(grams);
    RETURNV(thoz);
} 
// scale reset routine
INT sca_reset(void)
{
    CHAR tmp[20];
    INT i;
	ENTRY(5160);
    for (i=0;i<3;i++) {
        if (!sendmsg("INOUT1",MESSAGE_On,PORT,"Z\r")) RETURNV(0);
        delay(500);
        if (!sendmsg("INOUT1",MESSAGE_in,PORT,tmp,19,ETX,0)) RETURNV(0);
        if (checkstr(tmp)) RETURNV(1);
    }
    RETURNV(0);
} 
// scale control routine
LONG sca_control(INT type,va_list ap)
{
    LONG retval=0L;
    CHAR tmp[20];
	ENTRY(5170);
	
    switch (type) {
        case MESSAGE_i :                      // input
			retval=(LONG)sca_input();
//			if ((retval>100L)&&(retval<1000L)) {
//				retval=(LONG)sca_hinput();
//			}
//			G_scaleout++;
//			retval=(LONG)G_scaleout;
            if (retval<0) retval=0;
			G_scaleout=(INT)retval;
			break;
        case MESSAGE_R :                      // reset
        case MESSAGE_Z :                      // zero
            retval=(LONG)sca_reset();
            break;
        case MESSAGE_O :                      // output type - GRAMS / THOZ
            G_otype=(va_arg(ap,INT)&1);
            retval=1L;
            break;
        case MESSAGE_I :                      // init
            sendmsg("INOUT1",MESSAGE_I,PORT,1200,7,'e',1);
            delay(300);
            sendmsg("INOUT1",MESSAGE_in,PORT,tmp,19,ETX,0);
            retval=(LONG)sca_reset();
            break;
        case MESSAGE_E :                      // end
            retval=(LONG)sendmsg("INOUT1",MESSAGE_E,PORT);
            break;
    }
    RETURNV(retval);
}
