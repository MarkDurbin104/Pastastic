#define DEV_8255_C
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <memory.h>
#include "types.h"
#include "control.h"
#include "config.h"
#include "8255dev.h"


void putp(INT a,UCHAR b)
{
	switch (a) {
		case PORT_A11 : G_csA11=b; break;
		case PORT_A12 : G_csA12=b; break;
		case PORT_B21 : G_csB21=b; break;
	}
	OUTPB(a,b);
}
UCHAR getp(INT a)
{
	switch (a) {
		case PORT_A11 : return(G_csA11);
		case PORT_A12 : return(G_csA12);
		case PORT_B21 : return(G_csB21);
	}
	return(inp(a));
}
UCHAR getalarmsensors(void)
{
	return(getp(PORT_A21)&ALL_ALARMS);
}
UCHAR isactive(UCHAR type)
{
	return((getalarmsensors()|type)==type);
}
INT setalarm(INT onoff)
{
	UCHAR o;
	o=getp(PORT_C11)&ALARM_SET;
	if (onoff) {
		putp(PORT_C11,o|ALARM_ON);
	} else {
		putp(PORT_C11,o&ALARM_OFF);
	}
	return(1);
}
INT resetalarm(void)
{
	UCHAR o;
	o=(getp(PORT_C11)&(ALARM_OFF&ALARM_SET));
	putp(PORT_C11,o|ALARM_RESET);
	delay(1);
	putp(PORT_C11,o);
	return(1);
}
INT setalarmreset(INT onoff)
{
	UCHAR o;
	o=(getp(PORT_C11)&(ALARM_OFF&ALARM_SET));
	putp(PORT_C11,o|ALARM_RESET);
	if (!onoff) {
		delay(1);
		putp(PORT_C11,o);
	}
	return(1);
}
LONG getalarmtime(INT type)
{
	if (type) return(G_mjt);
	return(G_mnt);
}
LONG gettick(void)
{
	LONG t;
	disable();
	t=G_cticker;
	enable();
	return(t);
}
void settick(INT t)
{
	disable();
	G_cticker=t;
	enable();
}
INT operatecmdoor(INT open)
{
	UCHAR o;
	o=getp(PORT_B21);
	setalarmreset(1);

	settick(DOOR_DELAY);
	putp(PORT_B21,o|OPEN_CM_DOOR);
	while ((!isactive(MAJOR_ALARM_LAT))&&(gettick()));
	delay(150);
	putp(PORT_B21,o);

	if (isactive(MAJOR_ALARM_LAT)) return(open);

	setalarmreset(0);
	return(!open);
}
INT setcoininhibit(UCHAR type,INT onoff)
{
	UCHAR c,a;
	if (!type) return(0);
	c=getp(PORT_C11);
	a=getp(PORT_A11);
	if (onoff) {
		if ((type&PENNY  )!=0) c|=B_INHIBIT;
		if ((type&NICKEL )!=0) a|=C_INHIBIT;
		if ((type&DIME   )!=0) a|=D_INHIBIT;
		if ((type&QUARTER)!=0) a|=E_INHIBIT;
		if ((type&DOLLAR )!=0) c|=F_INHIBIT;
	} else {
		if ((type&PENNY  )!=0) c&=~B_INHIBIT;
		if ((type&NICKEL )!=0) a&=~C_INHIBIT;
		if ((type&DIME   )!=0) a&=~D_INHIBIT;
		if ((type&QUARTER)!=0) a&=~E_INHIBIT;
		if ((type&DOLLAR )!=0) c&=~F_INHIBIT;
	}
	putp(PORT_C11,c);
	putp(PORT_A11,a);
	return(1);
}
UCHAR getcoininhibit(void)
{
	UCHAR c,a,ret=0;
	c=getp(PORT_C11);
	a=getp(PORT_A11);
	if ((c&B_INHIBIT)!=0) ret|=PENNY  ;
	if ((a&C_INHIBIT)!=0) ret|=NICKEL ;
	if ((a&D_INHIBIT)!=0) ret|=DIME   ;
	if ((a&E_INHIBIT)!=0) ret|=QUARTER;
	if ((c&F_INHIBIT)!=0) ret|=DOLLAR ;
	return(ret);	
}
INT setaltcoinroute(UCHAR type,INT onoff)
{
	UCHAR a;
	if (!type) return(0);
	a=getp(PORT_A12);
	if (onoff) {
		if ((type&PENNY  )!=0) a|=B_ROUTE;
		if ((type&NICKEL )!=0) a|=C_ROUTE;
		if ((type&DIME   )!=0) a|=D_ROUTE;
		if ((type&QUARTER)!=0) a|=E_ROUTE;
		if ((type&DOLLAR )!=0) a|=F_ROUTE;
	} else {
		if ((type&PENNY  )!=0) a&=~B_ROUTE;
		if ((type&NICKEL )!=0) a&=~C_ROUTE;
		if ((type&DIME   )!=0) a&=~D_ROUTE;
		if ((type&QUARTER)!=0) a&=~E_ROUTE;
		if ((type&DOLLAR )!=0) a&=~F_ROUTE;
	}
	putp(PORT_A12,a);
	return(1);
}
UCHAR getaltcoinroute(void)
{
	UCHAR a,ret=0;
	a=getp(PORT_A12);
	if ((a&B_INHIBIT)!=0) ret|=PENNY  ;
	if ((a&C_INHIBIT)!=0) ret|=NICKEL ;
	if ((a&D_INHIBIT)!=0) ret|=DIME   ;
	if ((a&E_INHIBIT)!=0) ret|=QUARTER;
	if ((a&F_INHIBIT)!=0) ret|=DOLLAR ;
	return(ret);	
}
UINT getcoin(UINT *p,UINT *n,UINT *d,UINT *q,UINT *h)
{
	*p=G_coins.p;
	*n=G_coins.n;
	*d=G_coins.d;
	*q=G_coins.q;
	*h=G_coins.h;
	return(G_coins.t);
}
INT clrcoins(void)
{
	memset(&G_coins,0,sizeof(COINS));
	return(1);
}
INT dispensecoins(UCHAR type,INT q,INT *e)
{
	INT sq=q,cp,hlp;
	INT xit=0;
	UCHAR a,b,cb,hlf,step;

	switch (type) { // TAIWAN
		case PENNY   : a=F_DISPENSE; cb=F_DISPENSING; hlf=F_LO_HOPPER; cp=PORT_C11; hlp=PORT_C11; break;
		case NICKEL  : a=B_DISPENSE; cb=B_DISPENSING; hlf=B_LO_HOPPER; cp=PORT_C11; hlp=PORT_B12; break;
		case DIME    : a=C_DISPENSE; cb=C_DISPENSING; hlf=C_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
		case QUARTER : a=D_DISPENSE; cb=D_DISPENSING; hlf=D_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
		case DOLLAR  : a=E_DISPENSE; cb=E_DISPENSING; hlf=E_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
					// NORMAL
//		case PENNY   : a=B_DISPENSE; cb=B_DISPENSING; hlf=B_LO_HOPPER; cp=PORT_C11; hlp=PORT_B12; break;
//		case NICKEL  : a=C_DISPENSE; cb=C_DISPENSING; hlf=C_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
//		case DIME    : a=D_DISPENSE; cb=D_DISPENSING; hlf=D_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
//		case QUARTER : a=E_DISPENSE; cb=E_DISPENSING; hlf=E_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
//		case DOLLAR  : a=F_DISPENSE; cb=F_DISPENSING; hlf=F_LO_HOPPER; cp=PORT_C11; hlp=PORT_C11; break;
		default      : *e=1; return(0);
	}

	b=getp(PORT_A11);

	while ((q)&&(xit<2)) {
		step=0;
		putp(PORT_B21,getp(PORT_B21)|DISPENSE_GATE);
		putp(PORT_A11,b|a);
		settick(DISPENSE_DELAY);
		while ((gettick())&&(step==0)) {
			if ((getp(cp)&cb)==0) step=1;
		}
		putp(PORT_A11,b);
		putp(PORT_B21,getp(PORT_B21)&(~DISPENSE_GATE));
		if (step==1) {
			settick(DISPENSED_DELAY);
			while ((gettick())&&(step==1)) {
				if ((getp(cp)&cb)!=0) step=2;
			}
			if (step==2) {
				xit=0;
				q--;
			} else {
				xit++;
			}
		} else {
			xit++;
		}
		putp(PORT_A12,getp(PORT_A12)&(~RESET_HOPPER));
		delay(2);
		putp(PORT_A12,getp(PORT_A12)|RESET_HOPPER);
	}
	if (q) {
		switch (type) {
			case PENNY   : G_coins.pe|=1; break;
			case NICKEL  : G_coins.ne|=1; break;
			case DIME    : G_coins.de|=1; break;
			case QUARTER : G_coins.qe|=1; break;
			case DOLLAR  : G_coins.he|=1; break;
		}
		*e=2;
	} else {
		switch (type) {
			case PENNY   : G_coins.pe&=0xFE; break;
			case NICKEL  : G_coins.ne&=0xFE; break;
			case DIME    : G_coins.de&=0xFE; break;
			case QUARTER : G_coins.qe&=0xFE; break;
			case DOLLAR  : G_coins.he&=0xFE; break;
		}
		if (G_jackpot!=0) *e=4;
		if ((getp(hlp)|hlf)==0) *e=8;
	}
	return(sq-q);
}
INT payout(INT a)
{
	INT i;
	UCHAR m=0x10;
	INT b;
	for (i=(G_numhopp-1);i>=0;i--) {
		if (G_denoms[i]) {
			if (a/G_denoms[i]!=0)
				a-=dispensecoins(m,a/G_denoms[i],&b)*G_denoms[i];
		}
		m>>=1;
	}
	return(a);
}
INT getdispensestatus(UCHAR type)
{
	INT stat=0;
	switch (type) {
		case PENNY   :
			if      ((getp(PORT_B12)|B_HI_HOPPER )==0) stat|=HOPPER_HIGH;
			else if ((getp(PORT_B12)|B_LO_HOPPER )==0) stat|=HOPPER_LOW;
			if      ((getp(PORT_C11)|B_DISPENSING)==0) stat|=DISPENSING;
			if      ((G_jackpot&type             )!=0) stat|=COIN_JACKPOT;
			else if ((G_jackpot&0x1F             )!=0) stat|=ANY_JACKPOT;
			break;
		case NICKEL  :
			if      ((getp(PORT_B12)|C_HI_HOPPER )==0) stat|=HOPPER_HIGH;
			else if ((getp(PORT_B12)|C_LO_HOPPER )==0) stat|=HOPPER_LOW;
			if      ((getp(PORT_B11)|C_DISPENSING)==0) stat|=DISPENSING;
			if      ((G_jackpot&type             )!=0) stat|=COIN_JACKPOT;
			else if ((G_jackpot&0x1F             )!=0) stat|=ANY_JACKPOT;
			break;
		case DIME    :
			if      ((getp(PORT_B12)|D_HI_HOPPER )==0) stat|=HOPPER_HIGH;
			else if ((getp(PORT_B12)|D_LO_HOPPER )==0) stat|=HOPPER_LOW;
			if      ((getp(PORT_B11)|D_DISPENSING)==0) stat|=DISPENSING;
			if      ((G_jackpot&type             )!=0) stat|=COIN_JACKPOT;
			else if ((G_jackpot&0x1F             )!=0) stat|=ANY_JACKPOT;
			break;
		case QUARTER :
			if      ((getp(PORT_B12)|E_HI_HOPPER )==0) stat|=HOPPER_HIGH;
			else if ((getp(PORT_B12)|E_LO_HOPPER )==0) stat|=HOPPER_LOW;
			if      ((getp(PORT_B11)|E_DISPENSING)==0) stat|=DISPENSING;
			if      ((G_jackpot&type             )!=0) stat|=COIN_JACKPOT;
			else if ((G_jackpot&0x1F             )!=0) stat|=ANY_JACKPOT;
			break;
		case DOLLAR  :
			if      ((getp(PORT_C11)|F_HI_HOPPER )==0) stat|=HOPPER_HIGH;
			else if ((getp(PORT_C11)|F_LO_HOPPER )==0) stat|=HOPPER_LOW;
			if      ((getp(PORT_C11)|F_DISPENSING)==0) stat|=DISPENSING;
			if      ((G_jackpot&type             )!=0) stat|=COIN_JACKPOT;
			else if ((G_jackpot&0x1F             )!=0) stat|=ANY_JACKPOT;
			break;
	}
	return(stat);
}
INT resetcoinhopper(void)
{
	putp(PORT_A12,getp(PORT_A12)&(~RESET_HOPPER));
	delay(2);
	putp(PORT_A12,getp(PORT_A12)|RESET_HOPPER);
	G_jackpot=0;
	return(1);
}
void interrupt ticker2(void)
{
	if (G_cticker>0) G_cticker--;
	if (G_coins.pd>0) G_coins.pd--;
	if (G_coins.nd>0) G_coins.nd--;
	if (G_coins.dd>0) G_coins.dd--;
	if (G_coins.qd>0) G_coins.qd--;
	if (G_coins.hd>0) G_coins.hd--;
	(oldticker)();
}
void flaghopp(UINT hopps)
{
	INT on=0;
	G_hopps=hopps;
	on=getp(PORT_A12);
	if ((hopps&B_HI_HOPPER)!=0) {
		G_coins.pe|=2;	on|=R_PENNY;
	} else {
		G_coins.pe&=~2;	on&=~R_PENNY;
	}
	if ((hopps&B_LO_HOPPER)!=0) G_coins.pe|=4; else G_coins.pe&=~4;
	if ((hopps&C_HI_HOPPER)!=0) {
		G_coins.ne|=2;	on|=R_NICKEL;
	} else {
		G_coins.ne&=~2;	on&=~R_NICKEL;
	}
	if ((hopps&C_LO_HOPPER)!=0) G_coins.ne|=4; else G_coins.ne&=~4;
	if ((hopps&D_HI_HOPPER)!=0) {
		G_coins.de|=2;	on|=R_DIME;
	} else {
		G_coins.de&=~2;	on&=~R_DIME;
	}
	if ((hopps&D_LO_HOPPER)!=0) G_coins.de|=4; else G_coins.de&=~4;
	if ((hopps&E_HI_HOPPER)!=0) {
		G_coins.qe|=2;	on|=R_QUARTER;
	} else {
		G_coins.qe&=~2;	on&=~R_QUARTER;
	}
	if ((hopps&E_LO_HOPPER)!=0) G_coins.qe|=4; else G_coins.qe&=~4;
	if ((hopps&F_HI_HOPPER)!=0) {
		G_coins.he|=2;  on|=R_DOLLAR;		
	} else {
		G_coins.he&=~2; on&=~R_DOLLAR;	
	}
	if ((hopps&F_LO_HOPPER)!=0) G_coins.he|=4; else G_coins.he&=~4;
	putp(PORT_A12,on);
}
void interrupt coinint(void)
{
	UINT i,done=0,hopps;
	UCHAR t,coins,jacks;
 	disable();
	t=(getp(PORT_B11)&0xF8)>>3;
	coins=((t&4)>>2)|((t&3)<<1)|((t&0x10)>>1)|((t&8)<<1);
	jacks=(getp(PORT_C12)&0xEC)>>2;
	G_alarm=getp(PORT_A21)&0x0F;
//	t=(getp(PORT_C11)&0x0C)>>2;
//	hopps=(((UINT)getp(PORT_B12))<<2)|((UINT)t);
	hopps=(UINT)getp(PORT_B12); // taiwan
	if (!coins) coins=0x1D;           // ?????????????????????????????
	if ((coins&0x1F)!=0x1F) {
		if ((coins&PENNY)==0) {								   
			if (!G_coins.pd) {							  
				done=1;									    
				G_coins.pd=COIN_VAL_DELAY;				 
				G_coins.p++;
				G_coins.t+=G_denoms[(G_numhopp-5)+0];
			}
		}
		if ((!done)&&((coins&NICKEL)==0)) {
			if (!G_coins.nd) {
				done=1;
				G_coins.nd=COIN_VAL_DELAY;
				G_coins.n++;
				G_coins.t+=G_denoms[(G_numhopp-5)+1];
			}
		}
		if ((!done)&&((coins&DIME)==0)) {
			if (!G_coins.dd) {
				done=1;
				G_coins.dd=COIN_VAL_DELAY;
				G_coins.d++;
				G_coins.t+=G_denoms[(G_numhopp-5)+2];
			}
		}
		if ((!done)&&((coins&QUARTER)==0)) {					 
			if (!G_coins.qd) {							  
				done=1;
				G_coins.qd=COIN_VAL_DELAY;
				G_coins.q++;
				G_coins.t+=G_denoms[(G_numhopp-5)+3];
			}
		}
		if ((!done)&&((coins&DOLLAR)==0)) {
			if (!G_coins.hd) {
				done=1;
				G_coins.hd=COIN_VAL_DELAY;
				G_coins.h++;
				G_coins.t+=G_denoms[(G_numhopp-5)+4];
			}
		}
		flaghopp(hopps);
	}
	if ((!done)&&((G_alarm&MAJOR_ALARMS)!=MAJOR_ALARMS)) {
		G_mjt=*((LONG *)0x0040006CL);
		done=1;
	}
	if ((!done)&&((G_alarm&MINOR_ALARMS)!=MINOR_ALARMS)) {
		G_mnt=*((LONG *)0x0040006CL);
		done=1;
	}
	if ((!done)&&((jacks&0x1F)!=0x1F)) {
		done=1;
		G_jackpot|=jacks;
	}
	putp(PORT_B21,getp(PORT_B21)&(~INT_RESET));
	for (i=0;i<30;i++);
	putp(PORT_B21,getp(PORT_B21)|INT_RESET);
	OUTPB(EOI,EOI);
	enable();
}
INT getstatstr(INT t) 	// Taiwan version
{
	INT on=0;
	UCHAR hopps=getp(PORT_B12);
	switch (t) {
		case PENNY   : 
			if ((hopps&B_LO_HOPPER)!=0) on=1;
			if ((hopps&B_HI_HOPPER)==0) on=2;
			break;
		case NICKEL  : 
			if ((hopps&C_LO_HOPPER)!=0) on=1; 
			if ((hopps&C_HI_HOPPER)==0) on=2; 
			break;
		case DIME    : 
			if ((hopps&D_LO_HOPPER)!=0) on=1; 
			if ((hopps&D_HI_HOPPER)==0) on=2; 
			break;
		case QUARTER : 
			if ((hopps&E_LO_HOPPER)!=0) on=1; 
			if ((hopps&E_HI_HOPPER)==0) on=2; 
			break;
		case DOLLAR : 
			if ((hopps&F_LO_HOPPER)!=0) on=1; 
			if ((hopps&F_HI_HOPPER)==0) on=2; 
			break;
	}
	return(on);
}
INT startup_8255(void)
{
	INT i;
	putp(PORT_Q11,Q11_SETUP);
	putp(PORT_A11,A11_SETUP);
	putp(PORT_C11,C11_SETUP);
	putp(PORT_Q12,Q12_SETUP);
	putp(PORT_A12,A12_SETUP);
	putp(PORT_Q21,Q21_SETUP);
	putp(PORT_B21,B21_SETUP);
	putp(PORT_C21,C21_SETUP);
	putp(PORT_Q22,Q22_SETUP);
	putp(PORT_A22,A22_SETUP);
	putp(PORT_B22,B22_SETUP);
	putp(PORT_C22,C22_SETUP);
	putp(PORT_A12,0);
	for (i=0;i<10;i++);
	putp(PORT_A12,A12_SETUP);
    oldticker=getvect(0x08);
    setvect(0x08,ticker2);
    oldint0A=getvect(0x0A);
    setvect(0x0A,coinint);
	disable();
	putp(PORT_B21,0);
	for (i=0;i<10;i++);
	putp(PORT_B21,B21_SETUP);
	OUTPB(PIC,inp(PIC)&0xFB);
	OUTPB(EOI,EOI);
	enable();
	memset(&G_coins,0,sizeof(G_coins));
	return(1);
}
INT shutdown_8255(void)
{
    setvect(0x08,oldticker);
    setvect(0x0A,oldint0A);
	disable();
	putp(PORT_B21,0);			// ???????????????????????
	OUTPB(PIC,inp(PIC)|0x04);
	OUTPB(EOI,EOI);
	enable();
	return(1);
}
INT control_8255(INT type,va_list ap)
{
    INT retval=1;
    UINT *a,*b,*c,*d,*e;
	UCHAR t;
	INT f;

    switch (type) {
        case 'I' :
			retval=startup_8255();
			break;
        case 'E' :
			retval=shutdown_8255();
			break;
        case 'GA' :
			retval=getalarmsensors();
			break;
        case 'IA' :
			retval=isactive(va_arg(ap,UCHAR));
			break;
        case 'SA' :
			retval=setalarm(va_arg(ap,INT));
			break;
        case 'RA' :
			retval=resetalarm();
			break;
        case 'SR' :
			retval=setalarmreset(va_arg(ap,INT));
			break;
        case 'OD' :
			retval=operatecmdoor(va_arg(ap,INT));
			break;
        case 'SI' :
			t=va_arg(ap,UCHAR);
			retval=setcoininhibit(t,va_arg(ap,INT));
			break;
        case 'GI' :
			retval=getcoininhibit();
			break;
        case 'Sa' :
			t=va_arg(ap,UCHAR);
			retval=setaltcoinroute(t,va_arg(ap,INT));
			break;
        case 'Ga' :
			retval=getaltcoinroute();
			break;
        case 'i' :
        case 'GC' :
			a=va_arg(ap,UINT *);
			b=va_arg(ap,UINT *);
			c=va_arg(ap,UINT *);
			d=va_arg(ap,UINT *);
			e=va_arg(ap,UINT *);
//			G_coins.t+=2;
			retval=getcoin(a,b,c,d,e);
			break;
		case 'RC' :
			f=va_arg(ap,UINT);
			retval=1;
			if (f<=G_coins.t) G_coins.t-=f; else retval=0;
			break;
        case 'r' :
        case 'CC' :
			retval=clrcoins();
			break;
        case 'DC' :
			t=va_arg(ap,UCHAR);
			f=va_arg(ap,INT);
			retval=dispensecoins(t,f,va_arg(ap,INT *));
			break;
        case 'PO' :
			retval=payout(va_arg(ap,INT));
			break;
        case 'GD' :
			retval=getdispensestatus(va_arg(ap,UCHAR));
			break;
        case 'RH' :
			retval=resetcoinhopper();
			break;
        case 'GT' :
			retval=(INT)getalarmtime(va_arg(ap,INT));
			break;
        case 'GS' :
			f=va_arg(ap,INT);
			retval=getstatstr(f);
    }
    return(retval);
}

