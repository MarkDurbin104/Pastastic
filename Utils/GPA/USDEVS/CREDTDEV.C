//#define CDEBUG (1)

#define CREDTDEV_C
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <conio.h>
#include "control.h"
#include "types.h"
#include "message.h"
#include "credtdev.h"
#include "config.h"
/***************************************************************************/
/* Level 0: generics */
#define EOF (-1)
#define NUL ('\0');
#define STX ('\2')
#define ETX ('\3')
#define Esc ('\033')
#define CR  ('\r')
#define LF  ('\n');
/***************************************************************************/
/* Level 1: int14 to i/o ports */
/* This should be in a DOS device driver and/or part of the BIOS */
/***************************************************************************/
/* Level 2: logical RS232 to BIOS interrupt 14 i/f */
typedef struct {
  unsigned comport;
  unsigned status;
  } RS232_t;
static int RS232_Open(RS232_t *com,unsigned comport,unsigned baud,unsigned data,unsigned stop,char parity);
static int RS232_Write(RS232_t *com,char c);
static int RS232_WriteString(RS232_t *com,const char *s);
static int RS232_WriteReady(RS232_t *com,int *flag);
static int RS232_Read(RS232_t *com,char *ch);
//static int RS232_ReadString(RS232_t *com,char *str,unsigned size,int endch);
//static int RS232_ReadReady(RS232_t *com,int *flag);
static int RS232_Close(RS232_t *com);
/***************************************************************************/
/* Level 3: MT-215232 Insertion Card Reader to logical RS232 port i/f */

/* Switch table A
	321     Baud
		  0       19200
	1        9600
	2        4800
	3        2400
	4        1200
	5         600
		  6         300
	7         ???

	54      Parity
	00      Space (parity=0)
		  01      Mark (parity=1)
	10      Even
	11      Odd

	6       STX enable
	7       Esc enable
		  8       ETX enable
   Switch table B
	1       CR enable
	2       operating mode 0:unbuffered
			       1:buffered
		  3       driver enable
	4       Command style 0:use '+' & '-' for inquiry and release
			      1:use 'I' & 'R'
	5       factory says should be 0
	6       factory says should be 0,if 1, reader will transmit on card insert
	7       Enable RTS-CTS
		  8       Enable DSR-DTR
*/
/*      SWA from factory:0x93 ETX,Even,2400
	SWB              0xCC DSR,RTS,IR,drivers,unbuffered
*/
#define MAX_CARD_DATA (81+256)
#define SW(sw,index)  ((sw) & (1 << ((index)-1)) )
//Credit card configuration switches in 2 banks :A&B, switches 1-8
typedef struct {
  int error;
  unsigned track;
  char str[3][MAX_CARD_DATA + 9];
  int valid[3];
  unsigned StringSize;
  int driver[2];
  int card;
  RS232_t com;
  unsigned char A;  // Switch Block A
  unsigned char B;  // Switch Block B
  } MT_t;

static int MT_Inquiry(MT_t *mt);
static int MT_Release(MT_t *mt);
static int MT_DriverActivation(MT_t *mt,unsigned driver,int OnOff);
static int MT_Open(MT_t *mt,unsigned comport,char SWA,char SWB);
static int MT_Close(MT_t *mt);
/***************************************************************************/
/* Level 4: The GPA driver to MT i/f */
static int GPAMT_Initilize(void);
static int GPAMT_input(char *t1,unsigned s1,char *t2,unsigned s2,char *t3,unsigned s3);
static int GPAMT_Name(char *str,unsigned size);
static int GPAMT_Exit(void);
/***************************************************************************/
/* Level 5: The world to the GPA driver i/f */
int credit_control(int type,va_list ap);
/***************************************************************************/
























/***************************************************************************/
/* Level 2: logical RS232 to BIOS interrupt 14 i/f */
#if 0
  þ int bioscom(int cmd, char abyte, int port);
  Arg.  ³ What It Is/Does
 ÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
  abyte ³ OR combination of bits that specifies COM port settings
	³ (ignored if cmd = 2 or 3)
  cmd   ³ Specifies the I/O operation to perform
  port  ³ Identifies the I/O port;  0 = COM1, 1 = COM2, etc.

 Return Value:
For all values of cmd, both functions return a 16-bit integer.

The upper 8 bits of the return value are status bits.
  þ If one or more status bits is set to 1, an error has occured.
  þ If no status bits are set to 1, the byte was received without error.

The lower 8 bits of the return value depend on the value of cmd specified:

  Value of cmd     ³ Lower 8 bits of return value
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
  0 (_COM_INIT) or ³ The lower bits are defined as shown
  3 (_COM_STATUS)  ³ in the preceding diagram.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  1 (_COM_SEND)    ³  ...
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  2 (_COM_RECEIVE) ³ The byte read is in the lower bits
						 ³ of the return value--if there is no
		   ³ error (no upper bits are set to 1).
#endif

#include <dos.h>
#include <bios.h>
#include <stdio.h>
#include <time.h>

#define RBaddr   (0) //ReceiveBuffer
#define Haddr    (0) //Holding
#define IEaddr   (1) //InterruptEnable
#define IIRaddr  (2) //InteruptID
#define LCRaddr  (3) //LineControlRegister
#define MCRaddr  (4) //ModemControlRegister
#define LSRaddr  (5) //LineStatusRegister
#define MSRaddr  (6) //ModemStatusRegister
#define DLLSaddr (0) //DivisorLatchLeastSignificant
#define DLMSaddr (1) //DivisorLatchMostSignificant
#define Eaddr    (7) //Extra

#define ERBFI   (1)
#define ETBEI   (2)
#define ELSI    (4)
#define EDSSI   (8)

#define WLS0    (1)
#define WLS1    (2)
#define STB     (4)
#define PEN     (8)
#define EPS     (0x10)
#define StickParity  (0x20)
#define SetBreak     (0x40)
#define DLAB    (0x80)

#define DTR     (1)
#define RTS     (2)
#define OUT1    (4)
#define OUT2    (8)
#define EMASTER (OUT2)
#define LOOPBACK (0x10)

#define DR      (1)
#define OR      (2)
#define PE      (4)
#define FE      (8)
#define BI      (0x10)
#define THRE    (0x20)
#define TSRE    (0x40)
#define TIMEOUT (0x80)

#define DCTS    (0x01)
#define DDSR    (0x02)
#define TERI    (0x04)
#define DRLSD   (0x08)
#define CTS     (0x10)
#define DSR     (0x20)
#define RI      (0x40)
#define RLSD    (0x80)

#define TIMEOUTREAD  (1*CLK_TCK + 1)
#define TIMEOUTWRITE (1*CLK_TCK + 1)
// Wait 18 +/- 1 clock ticks (or about 1 second).
// 1 clock tick = 65536/3600 seconds or about 18.2 per second.
// In Borland 4.0 CLK_TCK = 1000
#define ERRORBITMASK    ((unsigned     ) ((TIMEOUT|BI|FE|PE|OR   )<<8))
#define TIMEOUTBITMASK  ((unsigned     ) ((TIMEOUT               )<<8))
#define READSTATUSMASK  ((unsigned char) ((        BI|FE|PE|OR|DR)   ))

static int RS232_Open(RS232_t *com,unsigned comport,unsigned baud,unsigned data,unsigned stop,char parity) {
  unsigned char LCR;  //LineControlRegister
//  static const char *parities[17] = "nNoOnNeEnNsSnNmM"
//  const char *p;
  unsigned long divisor;

  com->comport = comport;
  RS232_Close(com);
  if ((data < 5) || (data > 8)) return(1);
  LCR = data - 5;
  switch (stop) {
    case 1: LCR |= 0; break;
    case 2: LCR |= 4; break;
    default:return(1);
    }
//  p = strchr(parities,parity);
//  if (!p) return(1);
//  LCR |= ((p - parities) >> 1) << 3;
  parity &= ~0x20;  //force to uppercase
  switch (parity) {
	 case 'N': LCR |= 0; break;
    case 'O': LCR |= PEN; break;
    case 'E': LCR |= PEN | EPS; break;
    case 'S': LCR |= PEN | StickParity; break;
    case 'M': LCR |= PEN | EPS | StickParity; break;
    default:  return(1);
    }
  if (baud <= 1) return(1);  //baud too slow, --> divisor > 65535U
  divisor = (unsigned) ((1843200L/baud + 8) / 16);

  disable();
  outportb(comport+MCRaddr,DTR|RTS);
  outportb(comport+LCRaddr,LCR | DLAB);
  outportb(comport+DLLSaddr,(unsigned char) divisor);
  outportb(comport+DLMSaddr,(unsigned char) (divisor>>8));
  outportb(comport+LCRaddr,LCR);
  enable();

  com->status = inportb(com->comport+LSRaddr) << 8;
  com->status |= inportb(com->comport+MSRaddr);
  return(com->status & ERRORBITMASK);
  }

static int RS232_Write(RS232_t *com,char c) {
  clock_t t0;
  unsigned status;
  t0 = 0;
  while ( !((status = inportb(com->comport+LSRaddr)) & THRE) ) {
    if (t0==0) t0 = clock() + TIMEOUTWRITE;
    if (clock() >= t0) {
		status |= TIMEOUT;
      goto skip_write;
      }
	 }
  outportb(com->comport,c);

  skip_write:
  status <<= 8;
  status |= inportb(com->status+MSRaddr);
  com->status = status;
  return(com->status & TIMEOUTBITMASK);
  }

static int RS232_WriteString(RS232_t *com,const char *s) {
  while (*s) {
    if (RS232_Write(com,*s++)) return(1);
    }
  return(0);
  }

static void RS232_ReadFlush(RS232_t *com) {
  inportb(com->comport+LSRaddr); 
  inportb(com->comport+RBaddr);
  }

static int RS232_Read(RS232_t *com,char *ch) {
  unsigned status;
  clock_t t0;
#if CDEBUG
//  clock_t c0;
#endif
  t0 = 0;
  while ((status = inportb(com->comport+LSRaddr) & READSTATUSMASK) == 0) {
	 if (t0==0) t0 = (/* c0 = */ clock()) + TIMEOUTREAD;
	 if (clock() >= t0) {
#if CDEBUG
//      printf("Timeout %lu %lu\n",c0,clock());
#endif
		status |= TIMEOUT;
		break;
		}
	 }
  status <<= 8;
  if (status & (DR<<8)) {
	 status |= inportb(com->comport);
	 }
  if (ch) {
	 *ch = (char) status;
	 }
  com->status = status;
#if CDEBUG
//  printf("R%4X ",status);
#endif
  return(com->status & ERRORBITMASK);
  }

static int RS232_ReadString(RS232_t *com,char *str,unsigned size,int endch) {
  char ch;
  unsigned i;
  if ((size-- == 0) || (str==NULL)) return(1);  // No place to write anything
  i = 0;
  while (0==RS232_Read(com,(char*) &ch)) {
    if (i++ >= size) break;
    *str++ = ch;
    if (((unsigned char)ch) == endch) { *str=NUL; return(0); }
	 }
  *str=NUL;
  // Timeout only OK if 'endch' was EOF
  if (((com->status & ERRORBITMASK)==TIMEOUTBITMASK) && (endch==EOF)) return(0);
  return(1);
  }

static int RS232_Close(RS232_t *com) {
  unsigned char LCR,i;
  disable();
  outportb(com->comport+IEaddr,0);      // Disable 4 interrupt types
  outportb(com->comport+MCRaddr,0);     // Disbale master enable & DTR RTS
  LCR = inportb(com->comport+LCRaddr);  // Clear DLAB & Break
  outportb(com->comport+LCRaddr,LCR &= ~(DLAB|SetBreak));
  for (i=2; i>0; i--) {
    inportb(com->comport+LSRaddr);      // Clear Status Int
    inportb(com->comport+RBaddr);       // Clear Receive Int
    inportb(com->comport+IIRaddr);      // Clear Xmit Int
	 inportb(com->comport+MSRaddr);      // Clear Modem Int
    }
  enable();
  com->status = inportb(com->comport+LSRaddr) << 8;
  com->status |= inportb(com->comport+MSRaddr);
  return(com->status & ERRORBITMASK);
  }
/***************************************************************************/
/* Level 3: MT-215232 Insertion Card Reader to logical RS232 port i/f */
#include <mem.h>
//local function
static int MT_Command(MT_t *mt,char ch) {
  if (RS232_Write(&mt->com,Esc)) return(1);
  if (RS232_Write(&mt->com,ch )) return(1);
  return(0);
  }
//local function
static int MT_ParseString(MT_t *mt,const char *s) {
  unsigned i;
  unsigned track;

  mt->error = 1;  /* set error flag on */
  mt->track = 0;
  mt->str[0][0] = 0;
  mt->str[1][0] = 0;
  mt->str[2][0] = 0;
  mt->valid[0] =mt->valid[1] =mt->valid[2] = 0;
  mt->driver[0] = 0;
  mt->driver[1] = 0;
  mt->card = 0;
  if (SW(mt->A,6)) {
    if (*s!=STX) return(1);
    s++;
	 }
  if (SW(mt->A,7)) {
    if (*s!=Esc) return(1);
    s++;
	 }
  for (track=0; track<3; track++) {
    switch(*s++) { /* Data type */
      case 'E': mt->error = 0; /* Error: clear error flag */
		break;
      case '%': track = 0; // track 1
		goto SkipComma;
		case ';': if (track==0) track=1;
      SkipComma:mt->valid[track] = 1;
		for (i=0; *s!='?'; i++) {
		  if (i >= (mt->StringSize-1)) return(1);
		  if (*s=='\0') return(1);
//                if (*s=='?') { s++; break; }
		  mt->str[track][i] = *s++;
		  }
		s++;
		mt->str[track][i] = '\0';
		break;
		case '\0':return(1);
      default: s--; break;  /* No Card Read (assume *s = 0,1,2,3) */
      }
    }
  switch (*s++) {   /* user driver status */
    case '0': break;
    case '1': mt->driver[0] = 1; break;
    case '2': mt->driver[1] = 1; break;
    case '3': mt->driver[0] = mt->driver[1] = 1; break;
    default : return(1);
    }
  switch(*s++) { /* Card Sensor Status */
    case '0': break;
    case '1': mt->card = 1; break;
    default : return(1);
	 }
  if (SW(mt->B,1)) {
    if (*s!=CR) return(1);
    s++;
    }
  if (SW(mt->A,8)) {
    if (*s!=ETX) return(1);
	 s++;
    }
  mt->error ^= 1; /* reverse error flag */
  return(0);
  }


static int MT_Inquiry(MT_t *mt) {
  char end;
  char buf[sizeof(mt->str)+9];
  *buf = 0;
  end = (SW(mt->A,8)) ? ETX : ((SW(mt->B,1)) ? CR : EOF);
  RS232_ReadFlush(&mt->com);
  if (MT_Command(mt,SW(mt->B,4) ? 'I' : '+')) return(1);
  if (RS232_ReadString(&mt->com,buf,sizeof(buf),end)) {
#if CDEBUG
    printf("MT_inquiry error '%s'\n",buf);
#endif
    return(1);
    }
#if CDEBUG
//  printf("MT_inquiry '%s'\n",buf);
#endif
  if (MT_ParseString(mt,buf)) return(1);
  return(0);
  }
static int MT_Release(MT_t *mt) {
  if (MT_Command(mt,SW(mt->B,4) ? 'R' : '-')) return(1);
  return(0);
  }
static int MT_DriverActivation(MT_t *mt,unsigned driver,int OnOff) {
  if ((driver >= 1) && (driver <= 2)) {
	 OnOff = !OnOff;  // force OnOff to 0,1
    if (MT_Command(mt,'0' + driver + (OnOff<<1))) return(1);;
    }
  return(0);
  }
static int MT_Open(MT_t *mt,unsigned comport,char SWA,char SWB) {
  static const unsigned bauds[8] = {19200,9600,4800,2400,1200,600,300,0};
  static const char paritys[4] = "SMEO";
  memset(mt,0,sizeof(*mt));
  mt->A = SWA;
  mt->B = SWB;
  if (RS232_Open(&mt->com,comport,bauds[mt->A&7],7,1,paritys[(mt->A>>3)&3])) return(1);
  /* certain SWA & SWB combos are to be illegal for now */
  if (!(SW(mt->A,8) || SW(mt->B,1))) return(1); // Frames must have end char
  if (SW(mt->B,2)==0) return(1);  //Unbuffered mode
  if (SW(mt->B,3)==0);  // Not sure yet about status enable
  if (SW(mt->B,5)==1) return(1);  // Factory says this should be off
  if (SW(mt->B,6)==1) return(1);  // Factory says this should be off
  if (SW(mt->B,7)==0);  // Not sure yet about RTS-CTS
  if (SW(mt->B,8)==0);  // Not sure yet about DTR-DSR
  return(0);
  }
int MT_Close(MT_t *mt) {
  return(RS232_Close(&mt->com));
  }

/***************************************************************************/
/* Level 4: The GPA driver to MT i/f */
#include <string.h>
#include <mem.h>
#include <stdlib.h>
static MT_t mt;
static int GPAMT_Initilize(void) {
  const char *PortStr;
  unsigned port;
  const char *SwitchStr;
  unsigned switches;
  PortStr = getenv("CREDITPORT");
  if (PortStr==NULL) PortStr = "";
  port = (int) strtol(PortStr,0,0);
  if (port==0) port = 0x310;
  SwitchStr = getenv("CREDITSWITCH");
  if (SwitchStr==NULL) SwitchStr = "";
  switches = (int) strtol(SwitchStr,0,0);
  if (switches==0) switches = 0xCE93;
#if CDEBUG
  printf("Using Port %03X   Switches B:%02X A:%02X\n",port,switches >>8,switches&0xFF);
#endif
  MT_Open(&mt,port,switches&0xFF,switches>>8);
  MT_Release(&mt);
  return(0);
  }

static int copy(int valid,const char *src,char *dest,unsigned len) {
  unsigned i;
  if ((src==0) || (dest==0) || (len==0)) return(1);
  len--;
  i = 0;
  if (valid) {
    for (i=0; src[i]; i++) {
      if (i >= len) break;
      dest[i] = src[i];
      }
    }
  dest[i] = 0;
  return(i >= len);
  }

static int GPAMT_input(char *t1,unsigned s1,char *t2,unsigned s2,char *t3,unsigned s3) {
  int retval;
  retval=MT_Inquiry(&mt);
#if CDEBUG
  printf("Track[1]:%i %s\n",mt.valid[0],mt.str[0]);
  printf("Track[2]:%i %s\n",mt.valid[1],mt.str[1]);
  printf("Track[3]:%i %s\n",mt.valid[2],mt.str[2]);
  printf("Card:%i driver[0]:%i driver[1]:%i\n",mt.card,mt.driver[0],mt.driver[1]);
#endif
  retval |= copy(mt.valid[0],mt.str[0],t1,s1);
  retval |= copy(mt.valid[1],mt.str[1],t2,s2);
  retval |= copy(mt.valid[2],mt.str[2],t3,s3);
  retval |= MT_Release(&mt);
  return(retval);
  }

static int GPAMT_name(char *name,unsigned size) {
  int retval;
  int e;
  unsigned l1,l2,f1,f2;
  const char *s;

  if (name && size) *name=0;
  retval=MT_Inquiry(&mt);
#if CDEBUG
  printf("CardInserted:%i driver[0]:%i driver[1]:%i ",mt.card,mt.driver[0],mt.driver[1]);
  printf("Track[1]:%i '%s'\n",mt.valid[0],mt.str[0]);
#endif
  if (mt.valid[0] && name) {
#if 1
    l1 = l2 = f1 = f2 = e = 0;
	 s = mt.str[0];
    sscanf(s,"%*[^^]^%n%*[^/]%n/%n%*[^^]%n^%n",&l1,&l2,&f1,&f2,&e);
    if (e==0) {
      l1 = l2 = f1 = f2 = 0;
      sscanf(s,"%*[^^]^%n%*[^^]%n^%n",&f1,&f2,&e);
      }
    if (e==0) retval = 1;
    while ((l2 > l1) && (s[l2-1]==' ')) l2--;
    while ((f2 > f1) && (s[f2-1]==' ')) f2--;
    if ((l2-l1 + f2-f1 + 2) <= size) {
      sprintf(name,"%.*s%s%.*s",f2-f1,&s[f1],l1==l2 ? "" : " ",l2-l1,&s[l1]);
		}
    else retval = 1;
#if CDEBUG
    printf("name '%s'\n",name);
#endif
    }
#else
#endif
  else retval = 1;
  retval |= MT_Release(&mt);
  return(retval);
  }
static int GPAMT_Exit(void) {
  return(MT_Close(&mt));
  }

/***************************************************************************/
/* Level 5: The world to the GPA driver i/f */
// creditdev control routine

static MT_t mt;

int credit_control(int type,va_list ap) {
//    va_list ap;
    char *str;
    unsigned size;
    int retval;
		   char *t1,*t2,*t3;
		   unsigned l1,l2,l3;

    //va_start(ap,type);
    switch(type) {
	case 'i' : // INPUT                 - Return card data
						 t1 = va_arg(ap,char *);
		   l1 = va_arg(ap,unsigned);
		   t2 = va_arg(ap,char *);
		   l2 = va_arg(ap,unsigned);
		   t3 = va_arg(ap,char *);
		   l3 = va_arg(ap,unsigned);
		   retval = GPAMT_input(t1,l1,t2,l2,t3,l3);
		   break;
	case 'n' : // INPUT                 - Return name on credit card
		   str = va_arg(ap,char *);
		   size = va_arg(ap,unsigned);
#if CDEBUG
//                   printf("Read %s %p %u%s\n","name",str,size,".");
#endif
		   retval = GPAMT_name(str,size);
		   break;
	case 'I' : // INITIALISE DEVICE     - no params
	case 'R' : // RESET                 - no params
		   retval = GPAMT_Initilize();
		   break;
	case 'E' : // END        DEVICE     - no params
		   retval = GPAMT_Exit();
			break;
	default  : retval = 1;
    }
    va_end(ap);
    return(retval);
}
/***************************************************************************/


