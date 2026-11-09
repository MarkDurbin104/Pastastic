#ifndef COMMDEV_H

#define COMMDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef COMMDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef COMMDEV_C
INT comm_control(INT type,va_list ap);
#endif
// PUBLIC SYMBOLS S

PUBLIC DEVHEADER dev_comm
#if INIT
= {
	DEVSIG,
    "Serial Device Copyright (c) Unisys Ltd 1994 Version 1.00",
    "INOUT 01",
    "COMM",
    "iOIE",
    NULL,
    NULL,
    (DFPTR)comm_control,
    NULL,
	DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef COMMDEV_C

#define RDR           0              // receive CHAR buffer
#define TDR           0              // xmit CHAR buffer
#define IER           1              // interrupt enable register
#define IIR           2              // interrupt id register
#define LCR           3              // line control register
#define MCR           4              // modem control register
#define LSR           5              // line status register
#define MSR           6              // modem control register

// interrupt enable register IER / IIR

#define RXINT         1              // enable rec data avail INT
#define TXINT         2              // enable xmit buffer empty INT
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

#define TIMEOUT       4  			 // timeout counter max


void setbaud    (INT port,INT speed,INT bits,CHAR parity,INT stop);
INT  initport   (INT port,INT r,INT b,CHAR p,INT s);
INT  endport    (INT p);
INT  txnotready (INT p);
INT  rxnotready (INT p);
void outchar    (INT p,CHAR c);
CHAR inchar     (INT p);
INT  rxchar     (INT p,CHAR *c);
INT  txchar     (INT p,CHAR *c);
INT  rxstr		(INT p,CHAR *s,INT maxlen,UCHAR eot,INT over,INT to);
INT  txstr		(INT p,CHAR *s,INT l);

INT G_port[]={0x03F8,0x02F8,0x03E8,0x02A0,0x02A8,0x02B0,0x02B8,0x310};
INT G_ticks;		 
INT *com4addr=(INT *)0x00400006L;
#endif  //  def COMMDEV_C

#endif  //  ndef COMMDEV_H


