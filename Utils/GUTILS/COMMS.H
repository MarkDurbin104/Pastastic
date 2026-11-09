/*-----------------------------Defines------------------------------------*/
			/* Receive Buffer Size */
#define bufend			0x4000				/* buffer size				  */
			/* Programerble Interrupt Controller */
#define	PIC_EOI			0x20				/* see hardware manual		  */
#define	PIC_MASK		0x21				/* see hardware manual		  */
			/* Comms Port 1 Addresses	   For Comms Port 2 change to :-  */
#define COMM_DATA		0x03F8				/* 0x2F8 					  */
#define	COMM_IER		0x03F9				/* 0x2F9 					  */
#define	COMM_MCR		0x03FC				/* 0x2FC 					  */
#define	COMM_STAT		0x03FD				/* 0x2FD 					  */
			/* Interrupt masks */
#define	COMM_INT		0x0C				/* see hardware manual		  */
#define	INT_MASK		0x10				/* see hardware manual		  */
			/* Flow Control Toggle Points */
#define MIN_FREE_BUF	0x100				/* size free before XOFF	  */
#define MAX_FREE_BUF	0x200				/* size free before XON		  */
			/* Standard Notation For Control Characters 00-32 */
#define	 NUL	0x00			/* Null */
#define	 SOH	0x01			/* Start Of Header */
#define	 STX	0x02			/* Start transmission */
#define	 ETX	0x03			/* End transmission */
#define	 EOT	0x04			/* End of Text */
#define	 ENQ	0x05			/* Enquire */
#define	 ACK	0x06			/* Acknoledge */
#define	 BEL	0x07			/* Bell */
#define	 BS 	0x08			/* Back Space */
#define	 HT 	0x09			/* Horizontal Tab */
#define	 LF 	0x0A			/* Line Feed */
#define	 VT 	0x0B			/* Vertical Tab */
#define	 FF 	0x0C			/* Form Feed */
#define	 CR 	0x0D			/* Carriage Return */
#define	 SO 	0x0E			/* Shift Out */
#define	 SI 	0x0F			/* Shift In */
#define	 DLE	0x10			/* Data Line Enable */
#define	 DC1	0x11			/* Data Control 1 */
#define	 DC2	0x12			/* Data Control 2 */
#define	 DC3	0x13			/* Data Control 3 */
#define	 DC4	0x14			/* Data Control 4 */
#define	 NAK	0x15			/* Negative Acknoledge */
#define	 SYN	0x16			/* Sync */
#define	 ETB	0x17			/* End Transmit Block */
#define	 CAN	0x18			/* Cancel */
#define	 EM 	0x19			/* ????? */
#define	 SUB	0x1A			/* ????? */
#define	 ESC	0x1B			/* Escape */
#define	 FS 	0x1C			/* ????? */
#define	 GS 	0x1D			/* ????? */
#define	 RS 	0x1E			/* ????? */
#define	 US 	0x1F			/* ????? */
#define	 SP 	0x20            /* Space */

/*-----------------------------Variables----------------------------------*/
extern	int		oldvectseg;			/* save segment for old interrupt vector */
extern	int		oldvectofs;			/* save offset for old interrupt vector */
extern	char	buffer[bufend+1];	/* Receive Buffer */
extern	char	*buf;				/* pointer for input to buffer */
extern	int		point1,point2;		/* two wrap-round buffer pointers */
extern	int		xoff;				/* 0=XON 1=XOFF */
/*-----------------------------Declarations--------------------------------*/

void			getvector(void);		/* get rx int vector */
void			setvector(void);		/* set rx int vector */
void interrupt	introutine(void);		/* called on rx-interrupt */
void			setcomms(void);			/* set int. vector to point to ^ */
void			restcomms(void);		/* restore int vector */
int 			getrx(void);			/* get a char from rx buffer */
int				txchr(char outchr);		/* tx a char */
int				txstr(char *string);	/* tx a string */
int				txint(int number);		/* tx an int */
int				finddiff(void);			/* find No. bytes in rx buffer */
void 			setbaud(int speed,int bits,char parity,int stop);

/*-------------------------------End--------------------------------------*/