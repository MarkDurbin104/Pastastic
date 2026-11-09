#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <conio.h>
//#include "types.h"
//#include "8255dev.h"


int G_numhopp=4;

typedef unsigned char uchar;
typedef unsigned int  uint;

typedef struct {
	uint p;		// penny
	uint pd;	// penny delay
	uint n;		// nickel
	uint nd; 	// nickel delay
	uint d;		// dime
	uint dd;	// dime delay 
	uint q;		// quarter
	uint qd;	// quarter delay
	uint h;		// dollar (hundred cents)
	uint hd;	// dollar delay
	uint t;		// total value in pennies
} COINS;

int G_denoms[5]={1,5,10,25,100};

#define EOI		  0x20
#define PIC		  0x21
#define PORT_A11  0x01E0
#define PORT_B11  0x01E1
#define PORT_C11  0x01E2
#define PORT_Q11  0x01E3
#define PORT_A12  0x01E4
#define PORT_B12  0x01E5
#define PORT_C12  0x01E6
#define PORT_Q12  0x01E7
#define PORT_A21  0x01A0
#define PORT_B21  0x01A1
#define PORT_C21  0x01A2
#define PORT_Q21  0x01A3
#define PORT_A22  0x01A4
#define PORT_B22  0x01A5
#define PORT_C22  0x01A6
#define PORT_Q22  0x01A7

#define Q11_SETUP         0x83      // 10000011b
#define Q12_SETUP         0x8B      // 10001011b
#define Q21_SETUP         0x90      // 10010000b
#define Q22_SETUP         0x80      // 10000000b

#define A11_SETUP         0x00    // O - dispense, coins inhibit
#define B11_SETUP         0xFF    // I - coins output, dispensing
#define C11_SETUP         0x0F    // I/O - dispensing, hopper / coins inhibit, alarm
#define A12_SETUP         0x9F    // O - routes inhibit, hopper reset
#define B12_SETUP         0xFF    // I - hoppers
#define C12_SETUP         0x7C    // I - jacpots
#define A21_SETUP         0x0F    // I - alarm info
#define B21_SETUP         0x0A    // O - dispense gate, interrupt reset
#define C21_SETUP         0x00    // O - spare
#define A22_SETUP         0x00    // O - spare
#define B22_SETUP         0x00    // O - spare
#define C22_SETUP         0x00    // O - spare

//   -----   8255 PINS   

// ---- coin outputs
#define B_COIN            0x20       // penny
#define C_COIN            0x08       // nickel
#define D_COIN            0x10       // dime
#define E_COIN            0x80       // quarter
#define F_COIN            0x40       // dollar

// ----- coin inhibits
#define B_INHIBIT         0x20       // penny   - C11
#define C_INHIBIT         0x20       // nickel  - A11
#define D_INHIBIT         0x40       // dime    - A11
#define E_INHIBIT         0x80       // quarter - A11
#define F_INHIBIT         0x10       // dollar  - C11
#define C1_INHIBIT        0x70       // A11 - nickel, dime, quarter
#define C2_INHIBIT        0x30       // C11 - dollar, penny

// ---- route 6 & 7 are n  (1 & 2)
#define B_ROUTE           0x10       // A12  5 (3-04h) - penny
#define C_ROUTE           0x04       // A12  3 (5-10h) - nickel
#define D_ROUTE           0x02       // A12  2 (6-20h) - dime
#define E_ROUTE           0x01       // A12  1 (7-40h) - quarter
#define F_ROUTE           0x08       // A12  4 - dollar

#define ALARM_ON          0x40           // C11
#define ALARM_OFF         (~ALARM_ON)    // C11
#define ALARM_RESET       0x80           // C11
#define ALARM_SET         (~ALARM_RESET) // C11

#define MAJOR_ALARM_ACT   0x01       // A21
#define MINOR_ALARM_ACT   0x02       // A21
#define MAJOR_ALARM_LAT   0x04       // A21
#define MINOR_ALARM_LAT   0x08       // A21
#define MAJOR_ALARMS      0x05       // A21
#define MINOR_ALARMS      0x0A       // A21
#define ALL_ALARMS        0x0F       // A21

#define DISPENSE_GATE     0x01       // B21
#define INT_RESET         0x0A       // B21
#define OPEN_CM_DOOR      0x20       // B21

#define B_DISPENSE        0x08       // penny   - A11
#define C_DISPENSE        0x04       // nickel  - A11
#define D_DISPENSE        0x02       // dime    - A11
#define E_DISPENSE        0x01       // quarter - A11
#define F_DISPENSE        0x10       // dollar  - A11

#define B_DISPENSING      0x02       // penny   - C11
#define C_DISPENSING      0x04       // nickel  - B11
#define D_DISPENSING      0x02       // dime    - B11
#define E_DISPENSING      0x01       // quarter - B11
#define F_DISPENSING      0x01       // dollar  - C11

#define RESET_HOPPER      0x80       // A12

#define B_HI_HOPPER       0x40       // penny   - B12
#define B_LO_HOPPER       0x80       // penny   - B12
#define C_HI_HOPPER       0x10       // nickel  - B12
#define C_LO_HOPPER       0x20       // nickel  - B12
#define D_HI_HOPPER       0x04       // dime    - B12
#define D_LO_HOPPER       0x08       // dime    - B12
#define E_HI_HOPPER       0x01       // quarter - B12
#define E_LO_HOPPER       0x02       // quarter - B12
#define F_HI_HOPPER       0x04       // dollar  - C11
#define F_LO_HOPPER       0x08       // dollar  - C11

#define B_JACKPOT         0x04       // C12
#define C_JACKPOT         0x08       // C12
#define D_JACKPOT         0x10       // C12
#define E_JACKPOT         0x20       // C12
#define F_JACKPOT         0x40       // C12

#define PENNY             0x01
#define NICKEL            0x02
#define DIME              0x04
#define QUARTER           0x08
#define DOLLAR            0x10
#define HOPPER_HIGH       0x01
#define HOPPER_LOW        0x02
#define DISPENSING        0x04
#define COIN_JACKPOT      0x08
#define ANY_JACKPOT       0x10

#define DOOR_DELAY		  273
#define COIN_VAL_DELAY    3
#define DISPENSE_DELAY    6
#define DISPENSED_DELAY   18

extern long 	G_cticker;
extern long 	G_lcctr;
extern long 	G_mjt;
extern long 	G_mnt;
extern uchar 			G_jackpot;
extern uchar 			G_csA11;
extern uchar 			G_csA12;
extern uchar 			G_csB21;
extern COINS 			G_coins;

extern void  putp(int a,uchar b);
extern uchar getp(int a);
extern uchar getalarmsensors(void);
extern uchar isactive(uchar type);
extern int   setalarm(int onoff);
extern int   resetalarm(void);
extern int   setalarmreset(int onoff);
extern long  getalarmtime(int type);
extern int   operatecmdoor(int open);
extern int   setcoininhibit(uchar type,int onoff);
extern uchar getcoininhibit(void);
extern int   setaltcoinroute(uchar type,int onoff);
extern uchar getaltcoinroute(void);
extern uint  getcoin(uint *p,uint *n,uint *d,uint *q,uint *h);
extern int   clrcoins(void);
extern int   dispensecoins(uchar type,int q,int *e);
extern int   getdispensestatus(uchar type);
extern int   resetcoinhopper(void);
extern int   startup_8255(void);
extern int   shutdown_8255(void);
extern int payout(int a);
int G_s=0;

char *binary(uchar c)
{
	static char tmp[10];
	int i;
	for (i=0;i<8;i++) tmp[i]='0'+((c&(0x80>>i))!=0);
	tmp[i]=0;
	return(tmp);
}
void prat(int x,int y,char *fmt,...)
{
	char str[80];
	va_list ap;
	gotoxy(x+1,y+2);
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
	cprintf("%s",str);
}
void prstat(void)
{
	if (!G_s) return;
	prat(64, 0,"A11 = %s",binary(getp(PORT_A11)));
	prat(64, 1,"B11 = %s",binary(getp(PORT_B11)));
	prat(64, 2,"C11 = %s",binary(getp(PORT_C11)));
	prat(64, 3,"A12 = %s",binary(getp(PORT_A12)));
	prat(64, 4,"B12 = %s",binary(getp(PORT_B12)));
	prat(64, 5,"C12 = %s",binary(getp(PORT_C12)));
	prat(64, 6,"A21 = %s",binary(getp(PORT_A21)));
	prat(64, 7,"B21 = %s",binary(getp(PORT_B21)));
	prat(64, 8,"C21 = %s",binary(getp(PORT_C21)));
	prat(64, 9,"A22 = %s",binary(getp(PORT_A22)));
	prat(64,10,"B22 = %s",binary(getp(PORT_B22)));
	prat(64,11,"C22 = %s",binary(getp(PORT_C22)));
}

int dispense(uchar type,int q,int *e)
{
	int sq=q,cp,hlp,i;
	int xit=0;
	uchar a,b,cb,hlf,step;

	switch (type) {
		case PENNY   : a=B_DISPENSE; cb=B_DISPENSING; hlf=B_LO_HOPPER; cp=PORT_C11; hlp=PORT_B12; break;
		case NICKEL  : a=C_DISPENSE; cb=C_DISPENSING; hlf=C_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
		case DIME    : a=D_DISPENSE; cb=D_DISPENSING; hlf=D_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
		case QUARTER : a=E_DISPENSE; cb=E_DISPENSING; hlf=E_LO_HOPPER; cp=PORT_B11; hlp=PORT_B12; break;
		case DOLLAR  : a=F_DISPENSE; cb=F_DISPENSING; hlf=F_LO_HOPPER; cp=PORT_C11; hlp=PORT_C11; break;
		default      : *e=1; return(0);
	}

	b=getp(PORT_A11);

	while ((q)&&(xit<2)) {
		step=0;
		putp(PORT_B21,getp(PORT_B21)|DISPENSE_GATE);
		putp(PORT_A11,b|a);
		G_cticker=DISPENSE_DELAY;
		while ((G_cticker)&&(step==0)) {
			if ((getp(cp)&cb)==0) step=1;
			prstat();
		}
		putp(PORT_A11,b);
		putp(PORT_B21,getp(PORT_B21)&(~DISPENSE_GATE));
		if (step==1) {
			G_cticker=DISPENSED_DELAY;
			while ((G_cticker)&&(step==1)) {
				if ((getp(cp)&cb)!=0) step=2;
				prstat();
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
		*e=10+step;
	} else {
		if (G_jackpot!=0) *e=4;
		if ((getp(hlp)|hlf)==0) *e=8;
	}
	return(sq-q);
}
int operatedoor(int open)
{
	uchar o;
	o=getp(PORT_B21);
	setalarmreset(1);

	G_cticker=DOOR_DELAY;
	putp(PORT_B21,o|OPEN_CM_DOOR);
	while ((!isactive(MAJOR_ALARM_ACT))&&(G_cticker))
		prstat();
	delay(150);
	putp(PORT_B21,o);

	if (isactive(MAJOR_ALARM_ACT)) return(open);

	setalarmreset(0);
	return(!open);
}
int main(void)
{
	uint k,a,b,c,d,f,o,xit=0,t;
	int qty=1,e;
	clrscr();
	prat(0,0,"8255 Startup %d",startup_8255());
	while (!xit) {
		if (kbhit()) {
			k=getch();
			switch (k) {
				case 'a' : f=dispense(0x01,qty,&e); break;
				case 'b' : f=dispense(0x02,qty,&e); break;
				case 'c' : f=dispense(0x04,qty,&e); break;
				case 'd' : f=dispense(0x08,qty,&e); break;
				case 'e' : f=dispense(0x10,qty,&e); break;
				case 'p' : f=t-payout(t); e=(f!=t); clrcoins(); break;
				case 'O' : o=operatedoor(1); break;
				case 'C' : o=operatedoor(0); break;
				case '+' : qty++; break;
				case '-' : qty--; break;
				case '=' : qty+=100; break;
				case '_' : qty-=100; break;
				case 's' : G_s^=1; break;
				case 27  : xit=1; break;
			}
			prat(0,1,"Dispensing %d Dispensed %d Error %d     ",qty,f,e);
			prat(0,2,"Door %d",o);
		}
		prstat();
		t=getcoin(&a,&b,&c,&d,&o);
		prat(0,3,"Received qty   %03d.%02d",t/100,t%100);
		prat(0,4,"%03d %03d %03d %03d %03d",a,b,c,d,o);
		prstat();
	}									 
	prat(0,10,"8255 Shutdown %d\n",shutdown_8255());
	return(0);
}
