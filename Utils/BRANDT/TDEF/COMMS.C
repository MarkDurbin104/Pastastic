/*-----------------------------Includes-----------------------------------*/


#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include "comms.h"

struct		REGPACK		regs;
int						oldvectseg;
int						oldvectofs;
char					buffer[bufend+1];
char					*buf;
int						point1,point2;
int						xoff;

/*-----------------------------Definitions---------------------------------*/
void	interrupt	introutine(void){
	enable();
	buffer[point2]=inportb(COMM_DATA);
	disable();
	point2++;
	if (point2==bufend) point2=0;
	if (((bufend-finddiff())<MIN_FREE_BUF)&&(!xoff)) {
		xoff=1;
		txchr(DC3);
	}
	enable();
	outportb(PIC_EOI,0x20);
}
/*-------------------------------------------------------------------------*/
void	setcomms(void) {
	getvector();
	setvect(COMM_INT,introutine);
	outportb(COMM_MCR,0x00);
	outportb(COMM_MCR,0x0B);
	outportb(COMM_IER,0x01);
	outportb(PIC_MASK,(inportb(PIC_MASK)&(INT_MASK^0xFF)));
}
/************************************************************************
	set baud takes baudrate, No.bits, parity and stop bits
	and places them in a byte for a DOS interupt routine 0x14
	in the following format :

		Bits			Value

		7,6,5 			0 =  110 baud
						1 =  150 baud
						2 =  300 baud
						3 =  600 baud
						4 = 1200 baud
						5 = 2400 baud
						6 = 4800 baud
						7 = 9600 baud  --- DEFAULT

		4,3				3 = Even Parity
						2 = Undefined     (NOT USED)
						1 = Odd Parity
						0 = No Parity  --- DEFAULT

		2				1 = 2 stop bits
						0 = 1 stop bit --- DEFAULT

		1,0				3 = 8 bit word --- DEFAULT
						2 = 7 bit word
						1 = 6 bit word
						0 = 5 bit word

************************************************************************/
void setbaud(int speed,int bits,char parity,int stop) {
	int comln=0;								/* set of flags		       */
	xoff=0;										/* reset XON/XOFF flag     */
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

	regs.r_ax=comln&0xFF;						/*  set baud rate          */
	regs.r_dx=0;								/*  for port_2 use 1       */
	intr(0x14,&regs);							/*  using int 14h          */
}
/*-------------------------------------------------------------------------*/
void	restcomms(void) {
	outportb(PIC_MASK,(inportb(PIC_MASK)|INT_MASK));
	setvector();
}
/*-------------------------------------------------------------------------*/
int	getrx(void) {
	int pt;
	if (point1!=point2) {
		pt=point1;
		point1++;
		if (point1==bufend) point1=0;
		if ((bufend-(finddiff())>MAX_FREE_BUF)&&(xoff)) {
			xoff=0;
			txchr(DC1);
		}
		return(buffer[pt]);
	}
	return(-1);
}
/*-------------------------------------------------------------------------*/
void	getvector(void) {

	regs.r_ax=0x3500|COMM_INT;
	intr(0x21,&regs);
	oldvectseg=regs.r_es;
	oldvectofs=regs.r_bx;
}
/*-------------------------------------------------------------------------*/
void	setvector(void) {

	regs.r_ax=0x2500|COMM_INT;
	regs.r_ds=oldvectseg;
	regs.r_dx=oldvectofs;
	intr(0x21,&regs);
}
/*-------------------------------------------------------------------------*/
int	txchr(char outchr){
	int	i;
	for (i=0;i<30000;i++){
		if ((inportb(COMM_STAT)&0x20)!=0) {
			outportb(COMM_DATA,outchr);
			return(1);
		}
	}
	return(0);
}
/*-------------------------------------------------------------------------*/
int txstr(char *string) {
	int i;
	for (i=0;i<strlen(string);i++) {
		if(!(txchr(string[i]))) {
			return(0);
		}
/*		cprintf("%c-%d\r\n",string[i],string[i]);*/
	}
	return(1);
}
/*-------------------------------------------------------------------------*/
int txint(int number) {
	static char tmpstr[10];
	itoa(number,tmpstr,10);
	if (txstr(tmpstr)) return(1); else return(0);
}
/*-------------------------------------------------------------------------*/
int finddiff(void) {
	if (point1>point2) {
		return((bufend-point1)+point2);
	}
	else {
		return(point2-point1);
	}
}