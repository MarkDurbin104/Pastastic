#include <conio.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

void prat(int x,int y,char *fmt,...);
typedef unsigned char uchar;
typedef unsigned int  uint;
#define RDR           0              // receive char buffer
#define TDR           0              // xmit char buffer
#define IER           1              // interrupt enable register
#define IIR           2              // interrupt id register
#define LCR           3              // line control register
#define MCR           4              // modem control register
#define LSR           5              // line status register
#define MSR           6              // modem control register

// interrupt enable register IER / IIR

#define RXINT         1              // enable rec data avail int
#define TXINT         2              // enable xmit buffer empty int
#define LININT        4              // enable line status interrupt
#define MODINT        8              // enable modem status interrupt

// modem control register MCR 

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

// modem status register MSR
#define DCTS          1              // delta clear to send
#define DDSR          2              // delta data set ready
#define RDET          4              // trailing edge ring detect
#define DCD           8              // delta carrier detect
#define CTS           16             // clear to send
#define DSR           32             // data set ready
#define RING          64             // ring indicator
#define CD            128            // carrier detect

#define TIMEOUT			64000
#define PORT1			0
#define PORT2			6
#define STX 			2
#define ETX 			3
#define NAK 			0x15
#define ACK 			6
#define STAMP_SER		0x80
#define STAMP_CNT		0x81
#define STAMP_PRNT		0x82
#define STAMP_STAT		0x83
#define STAMP_RES		0x84
#define STAMP_VOID		0x85
#define STAMP_WSER		0x86
#define STAMP_MULT		0x87

unsigned int crca[16]={
	0x0000,0x1081,0x2102,0x3183,0x4204,0x5285,0x6306,0x7387,
	0x8408,0x9489,0xA50A,0xB58B,0xC60C,0xD68D,0xE70E,0xF78F
};
unsigned int crcb[16]={
	0x0000,0x1189,0x2312,0x329B,0x4624,0x57AD,0x6536,0x74BF,
	0x8C48,0x9DC1,0xAF5A,0xBED3,0xCA6C,0xDBE5,0xE97E,0xF8F7
};
int G_curport=(-1);
int G_del=0;

int G_checkstat=1;
unsigned int G_timlim=TIMEOUT;
int *com4addr=(int *)0x00400006L;
int G_port[]={0x03F8,0x02F8,0x03E8,0x02A0,0x02A8,0x02B0,0x02B8,0x310};
int G_io,G_oo;
void setbaud(int port,int speed,int bits,char parity,int stop)
{
	int comln=0;								/* set of flags		       */
	*com4addr=G_port[port];
	port=3;
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
	asm {
		mov ax,comln
		mov dx,port
		int 0x14
	}
}
// initialise serial port
int initport(int port,int r,int b,char p,int s)
{
	setbaud(port,r,b,p,s);
    outp(G_port[port]+IER,0);                          // disable all interrupts
    outp(G_port[port]+MCR,inp(G_port[port]+MCR)|(DTR|RTS)); // set DTR & RTS
	return(1);
}
int endport(int p)
{
    outp(G_port[p]+MCR,inp(G_port[p]+MCR)&~(DTR|RTS));    // clear DTR & RTS
	return(1);
}
// check transmit not ready
int txnotready(int p)
{
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&(DSR|CTS))!=(DSR|CTS))) return(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&THRE))                return(1);        // buf not ready
    return(0);
}
// check receive not ready
int rxnotready(int p)
{
    if ((G_checkstat)&&((inp(G_port[p]+MSR)&DSR)!=DSR)) return(-1);       // line not ready
    if (!(inp(G_port[p]+LSR)&DATR))                     return(1);        // buf not ready
    return(0);
}
// output a character to the serial port
void outchar(int p,char c)
{
    outp(G_port[p]+TDR,c);
	return;
}
// input a character from the serial port
char inchar(int p)
{
    return(inp(G_port[p]+RDR));
}
// input a character from the serial port with timeout
int rxchar(int p,char *c)
{
    unsigned int ticks=0;
    while (rxnotready(p))  {
		if ((ticks++)>G_timlim) {
//			prat(11+G_io*3,15,"TIMEOUT");
			return(0);
		}
	}
	*c=inchar(p);
//	prat(11+G_io*3,15,"%02X ",(*c&0xFF)); if ((++G_io)>20) G_io=0;
//	fprintf(stdout,"%02X ",(*c&0xFF));
//	if (G_io==0) fprintf(stdout,"\n");
    return(1);
}
// output a character to the serial port with timeout
int txchar(int p,char *c)
{
    unsigned int ticks=0;
    while (txnotready(p)) {
		if ((ticks++)>G_timlim) {
//			prat(11+G_io*3,14,"TIMEOUT");
			return(0);
		}
	}
    outchar(p,*c);
//	prat(11+G_oo*3,14,"%02X ",(*c&0xFF)); if ((++G_oo)>20) G_oo=0;
	delay(1);
    return(1);
}
// receive a string from the serial prot
int rxstr(int p,char *s,int maxlen,unsigned char eot,int over,int to)
{
    int i=0,t,xit=0;
    int stat,cd=0;

    while (!xit) {
		t=to; 
		while (((stat=rxchar(p,s))==0)&&(t>=0)) t--;
		if (t>=0) {
			if (i>=maxlen) return(i);
			if ((eot)&&(eot==*s)) cd=1;
			if (cd) {
				if (over==0) return(1);
				over--;
			}
			i++;
			s++;
		} else {
			xit=1;
		}
	}
    return(stat);
}
// transmit a string to the serial prot
int txstr(int p,char *s,int len)
{
	int i;
    if (len==0) {
		while (*s) if (!txchar(p,s++)) return(0);
	} else {
		while (len--) if (!txchar(p,s++)) return(0);
	}
    return(1);
}
unsigned int calccrc(unsigned char *s)
{
	long crc=0L;
	unsigned char c;
	int xit=0;
	if (*s==STX) s++;
	while (!xit) {
		c=*s;
		c^=crc&0xFF;
		crc>>=8;
		crc^=(crca[c>>4]^crcb[c&15]);
		if (*(s++)==ETX) xit=1;
	}
	return(crc&0xFFFF);
}
int sendstr(unsigned char *s)
{
	static char tmp[100];
	char *d;
	int len=4;
	unsigned int c;
	d=tmp;
	*(d++)=STX;
	while (*s) { *(d++)=*(s++); len++; }
	*(d++)=ETX;
	c=calccrc(tmp);
	*(d++)=(c>>8)&0xFF;
	*(d++)=(c   )&0xFF;
	*d=0;
	return(txstr(G_curport,tmp,len));
}
char *verifystr(unsigned char *s)
{
	unsigned int c,i;
	unsigned char *a;
	while ((*s)&&(*s!=STX)) s++;
	a=s;
	c=calccrc(s);
	while ((*a)&&(*a!=ETX)) a++;
	*a=0;
	a++;
	i=(*(a++)&0xFF);
	i<<=8;
	i|=(*a&0xFF);
	if (c==i) return(s+1);
	return(NULL);
}
int receivestr(unsigned char **s,int l)
{
	int i;
	if (rxstr(G_curport,*s,l,ETX,2,2)) {
		if ((*s=verifystr(*s))!=NULL) return(1);
	}
	return(0);
}
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
	gotoxy(x+1,y+1);
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
	cprintf("%s",str);
}
int main(void)
{
    char buf[200], e;
    int i,l;
    clrscr();
    G_checkstat=0;
    e=5;
    initport(0,1200,8,'n',1);
    while (!kbhit()) {
        txchar(0,&e);
        if ((l=rxstr(0,buf,200,0,0,0))!=0) {
            for (i=0;i<l;i++) {
                printf("%02X%c ",buf[i]&0xFF,buf[i]&0xFF);
            }
            printf("\n");
        }
    }
    getch();
	return(0);
}
