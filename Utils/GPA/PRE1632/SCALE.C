#include <conio.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

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
#define OUT1          4              // user outportbut 1
#define OUT2          8              // user outportbut 2

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

#define TIMEOUT			64000L
#define PORT1			0
#define PORT2			1
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
unsigned long G_timlim=TIMEOUT;
int *com4addr=(int *)0x00400006L;
int G_port[]={0x03F8,0x02F8,0x03E8,0x02E8,0x02A8,0x02B0,0x02B8,0x310};
int G_io,G_oo;
#define PEN     (8)
#define EPS     (0x10)
#define StickParity  (0x20)
#define DLAB    (0x80)

void setbaud(int port,int speed,int bits,char parity,int stop)
{
    int tmp;
    unsigned divisor;

    if (speed <= 1) return;  //baud too slow, --> divisor > 65535U
    divisor = (unsigned) ((1843200L/speed + 8) / 16);
    if ((bits < 5) || (bits > 8)) return;
    tmp = bits - 5;
    switch (stop) {
        case 1: tmp |= 0; break;
        case 2: tmp |= 4; break;
        default:return;
    }
    parity &= ~0x20;  //force to uppercase
    switch (parity) {
        case 'N': tmp |= 0; break;
        case 'O': tmp |= PEN; break;
        case 'E': tmp |= PEN | EPS; break;
        case 'S': tmp |= PEN | StickParity; break;
        case 'M': tmp |= PEN | EPS | StickParity; break;
        default:  return;
    }
   
    outportb(G_port[port]+LCR,tmp | DLAB);
    outportb(G_port[port]+0,(unsigned char) divisor);
    outportb(G_port[port]+1,(unsigned char) (divisor>>8));
    outportb(G_port[port]+LCR,tmp);
   
}  
// initialise serial port
int initport(int port,int r,int b,char p,int s)
{
	setbaud(port,r,b,p,s);
    outportb(G_port[port]+IER,0);                          // disable all interrupts
    outportb(G_port[port]+MCR,inportb(G_port[port]+MCR)|(DTR|RTS)); // set DTR & RTS
	return(1);
}
int endport(int p)
{
    outportb(G_port[p]+MCR,inportb(G_port[p]+MCR)&~(DTR|RTS));    // clear DTR & RTS
	return(1);
}
// check transmit not ready
int txnotready(int p)
{
    if ((G_checkstat)&&((inportb(G_port[p]+MSR)&(DSR|CTS))!=(DSR|CTS))) return(-1);       // line not ready
    if (!(inportb(G_port[p]+LSR)&THRE))                return(1);        // buf not ready
    return(0);
}
// check receive not ready
int rxnotready(int p)
{
    if ((G_checkstat)&&((inportb(G_port[p]+MSR)&DSR)!=DSR)) return(-1);       // line not ready
    if (!(inportb(G_port[p]+LSR)&DATR))                     return(1);        // buf not ready
    return(0);
}
// outportbut a character to the serial port
void outchar(int p,char c)
{
    outportb(G_port[p]+TDR,c);
	return;
}
// inportbut a character from the serial port
char inchar(int p)
{
    return(inportb(G_port[p]+RDR));
}
// inportbut a character from the serial port with timeout
int rxchar(int p,char *c)
{
    unsigned int ticks=0;
    while (rxnotready(p))  {
		if ((ticks++)>G_timlim) {
//            printf("TIMEOUT\n");
			return(0);
		}
	}
	*c=inchar(p);
    return(1);
}
// outportbut a character to the serial port with timeout
int txchar(int p,char *c)
{
    unsigned int ticks=0;
//    printf("Out %d\n",(int)*c);
    while (txnotready(p)) {
		if ((ticks++)>G_timlim) {
//            printf("TIMEOUT\n");
			return(0);
		}
	}
    outchar(p,*c);
	delay(1);
    return(1);
}
// receive a string from the serial prot
int rxstr(int p,char *s,int maxlen)
{
    int i=0;
    while (i<maxlen) {
		if (!rxchar(p,s++)) return(0);
        i++;
	}
    return(1);
}
// transmit a string to the serial prot
int txstr(int p,char *s,int len)
{
    if (len==0) {
		while (*s) if (!txchar(p,s++)) return(0);
	} else {
		while (len--) if (!txchar(p,s++)) return(0);
	}
    return(1);
}

int bauds[10]={19200,9600,4800,2400,1200,600,300,150,110,75};
char parts[3]={'n','e','o'};
int bits[3]={8,7,7};

int main(int argc,char *argv[])
{
    char buf[100],*s;
    int i,j,k,l;
    float w,wlb;
    memset(buf,0,100);
    G_checkstat=0;
    if (argc < 2) return 1;
    for (j=0;j<10;j++) {
        for (k=0;k<3;k++) {
            setbaud(atoi(argv[1]),bauds[j],bits[k],parts[k],1);
            for (l=0;l<4;l++) {
                if (txstr(atoi(argv[1]),"W\r",0)) {
                    for (i=0;i<2;i++) {
                        if (kbhit()) return(0);
                        rxstr(atoi(argv[1]),buf,100);
                        if (buf[0] != '\0') {
                            s=buf;
                            while (*s++) printf("%02X ",*s);
                            printf("                \n");
                            buf[11]=0;
                            w=atof(&buf[1]);
                            wlb=w*2.204585537919;
                            w*=1000;
                            fprintf(stdout,"   %5.0f g   %3.3f lb    %d %c %s\r",w,wlb,bauds[j],parts[k],&buf[1]);
                            memset(buf,0,100);
                            break;
                        }
                    }
                    if (i==2) 
                        fprintf(stdout,"T %d %c\n",bauds[j],parts[k]);
                    else
                        l--;
                }
            }
        }
    }
    endport(atoi(argv[1]));
	return(0);
}
