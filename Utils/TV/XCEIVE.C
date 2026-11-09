/*-----------------------------Includes-----------------------------------*/

#include <stdio.h>
#include <conio.h>
#include <dos.h>

/*-----------------------------Defines------------------------------------*/
#define	XOFF	19
#define XON		17
#define bufend	8192
/*-----------------------------Variables----------------------------------*/
	far						*screenmem;
	int						attr,xpos,ypos;
    int						tmpx,tmpy,tmpp;
	char					tmpstr[256];
	struct		REGPACK		regs;
	unsigned	char		PIC_EOI   = 0x20;
	unsigned	char		PIC_MASK  = 0x21;
    int						COMM_DATA = 0x03F8;
	int						COMM_IER  = 0x03F9;
	int						COMM_MCR  = 0x03FC;
	int						COMM_STAT = 0x03FD;
	int		 				COMM_INT  = 0x0C;
	unsigned	char		INT_MASK  = 0x10;
	int						oldvectseg;
	int						oldvectofs;
	char					buffer[bufend+1];
	char					*buf;
	int						point1,point2;
	char					keys;
	int						locecho   = 0;
	int						XOUT	  = 0;
	int						XIN		  = 0;

/*-----------------------------Declarations--------------------------------*/

	void		interrupt	introutine(void);
	void					setcomms(void);
	void					restcomms(void);
	void					trancieve(void);
	void					getvector(void);
	void					setvector(void);
	int						txchr(char outchr);
	int						breakhandle(void);
	void					pc(char outchar);
	void 					scrdn(void);
	void 					scrup(void);

/*-----------------------------Definitions---------------------------------*/

main() {
	screenmem=MK_FP(0xB800,0);
	attr=0x0700;
	xpos=0;
	ypos=0;
	ctrlbrk(breakhandle);
	buf=buffer;
	point1=point2=0;
	setcomms();
	keys=0;
	gotoxy(1,25);
	cprintf("Press [F10] to exit");
	window(1,1,80,24);
	gotoxy(1,1);
	trancieve();
	restcomms();
	return(1);
}
/*-------------------------------------------------------------------------*/
void	interrupt	introutine(void){

	enable();
	buffer[point2]=inportb(COMM_DATA);
	disable();
	point2++;
	if (point2==bufend) point2=0;
	enable();
	outportb(PIC_EOI,0x20);
}
/*-------------------------------------------------------------------------*/
void	setcomms(void) {

	regs.r_ax=0x00EA;			/*  set baud rate     */
	regs.r_dx=0;				/*  for comms port 1  */
	intr(0x14,&regs);			/*  using int 14h     */
	getvector();
	setvect(COMM_INT,introutine);
	outportb(COMM_MCR,0x00);
	delay(100);
	outportb(COMM_MCR,0x0B);
	outportb(COMM_IER,0x01);
	outportb(PIC_MASK,(inportb(PIC_MASK)&(INT_MASK^0xFF)));
}
/*-------------------------------------------------------------------------*/
void	restcomms(void) {

	outportb(PIC_MASK,(inportb(PIC_MASK)|INT_MASK));
	setvector();

}
/*-------------------------------------------------------------------------*/
void	trancieve(void) {
	do {
		if (point1!=point2) {
			pc(*(buf+point1++));
			if (point1==bufend) point1=0;
		}
		if (kbhit()) {
			keys=getch();
			while (XOUT==1);
			if (!(txchr(keys))) {
				cprintf("TX error - %04X\n",inportb(COMM_STAT));
				exit(-1);
			}
		}
	} while (keys!=27);
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
	if (locecho) cprintf("%c",outchr);
	for (i=0;i<30000;i++){
		if ((inportb(COMM_STAT)&0x20)!=0) {
			outportb(COMM_DATA,outchr);
			return(1);
		}
	}
	return(0);
}
/*-------------------------------------------------------------------------*/
int	breakhandle (void){
	txchr(3);
    return(1);
}
/*-------------------------------------------------------------------------*/
void	pc(char outchar) {

	switch(outchar) {
		case 13 : xpos=1; break;
		case 10 : ypos++; break;
		case 8	: xpos--; break;
		case 27	: break;
		default : {
			*(screenmem+((xpos-1)+(ypos-1)*80))=attr|outchar;
			xpos++;
		}
	}
	if(xpos==81) {
		xpos=1;
		ypos++;
	}
	if (ypos==25) {
		ypos--;
		scrup();
    }
	gotoxy(xpos,ypos);
}
/*-------------------------------------------------------------------------*/
void scrup(void){
	regs.r_ax=0x0601;
	regs.r_bx=0x0007;
	regs.r_cx=0x0000;
	regs.r_dx=0x174F;
	intr(0x10,&regs);
}
/*-------------------------------------------------------------------------*/
void scrdn(void){
	regs.r_ax=0x0701;
	regs.r_bx=0x0007;
	regs.r_cx=0x0000;
	regs.r_dx=0x174F;
	intr(0x10,&regs);
}
/*-------------------------------------------------------------------------*/
