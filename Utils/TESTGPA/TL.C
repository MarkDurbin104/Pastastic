#include <stdio.h>
#include <dos.h>
#include <conio.h>

#define RDR           0              // receive CHAR buffer
#define TDR           0              // xmit CHAR buffer
#define IER           1              // interrupt enable register
#define IIR           2              // interrupt id register
#define LCR           3              // line control register
#define MCR           4              // modem control register
#define LSR           5              // line status register
#define MSR           6              // modem control register

#define DTR           1              // data terminal ready
#define RTS           2              // request to send
#define OUT1          4              // user output 1
#define OUT2          8              // user output 2

// line status register LSR
#define DATR          1              // rec data ready
#define OVER          2              // data overrun error
#define PAER          4              // parity error
#define FRER          8              // framing error
#define BKNT          16             // break interrupt
#define THRE          32             // xmit holding reg empty
#define TSRE          64             // xmit shift reg empty

#define RED     0
#define REDAMB  1
#define GREEN   2
#define AMBER   3
#define ALLTEST 4

int G_port[]={0x03F8,0x02F8,0x03E8,0x02E8};
int *com4addr=(int *)0x00400006L;

void setbaud(int port,int speed,int bits,char parity,int stop)
{
	int comln=0;								/* set of flags		       */
    union REGS r;
//	*com4addr=G_port[port];
//	port=3;
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

void setlight(int ln,int len)
{
    int i;
    unsigned char ov;
    outportb(G_port[0]+MCR,inportb(G_port[0]+MCR)|DTR|RTS);
    switch (ln) {
        case GREEN :
            ov=0xFF;
            break;
        case AMBER :
            outportb(G_port[0]+MCR,inportb(G_port[0]+MCR)&~RTS);
            ov=0;
            break;
        case RED :
            outportb(G_port[0]+MCR,inportb(G_port[0]+MCR)&~DTR);
            ov=0;
            break;
        case REDAMB :
            outportb(G_port[0]+MCR,inportb(G_port[0]+MCR)&~(DTR|RTS));
            ov=0;
            break;
        default :
            outportb(G_port[0]+MCR,inportb(G_port[0]+MCR)&~(DTR|RTS));
            getch();
            outportb(G_port[0]+MCR,inp(G_port[0]+MCR)|DTR|RTS);
    }
    for (i=0;i<len;i++) {
        while (!(inportb(G_port[0]+LSR)&THRE));
        outportb(G_port[0]+TDR,ov);
        if (kbhit()) break;
    }
    outportb(G_port[0]+MCR,inp(G_port[0]+MCR)|DTR|RTS);
}
int main(void)
{
    int i;
    setbaud(0,600,8,'n',1);
    while (!kbhit()) {
        setlight(RED   ,200);
        setlight(REDAMB,50);
        setlight(GREEN ,200);
        setlight(AMBER ,50);
    }
    getch();
    setlight(ALLTEST,100);
    return 1;
}
