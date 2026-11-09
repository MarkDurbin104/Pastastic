#ifndef NETDEV_H    // stop multiple includes

#define NETDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef NETDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------

// PUBLIC SYMBOLS S

#ifdef NETDEV_C
INT net_control(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_net
#if INIT
= {
	DEVSIG,
    "Lan Device Copyright (c) Unisys Ltd 1992 Version 1.00",
    "LAN   01",
    "NETBIOS",
    "I CR",
    NULL,
    NULL,
    (DFPTR)net_control,
    NULL,
	DEVSIG
}
#endif
;

//------------------------PRIVATE Prototypes & Variables-------------------
// PUBLIC SYMBOLS E

#ifdef NETDEV_C

#define CLRNCB(a) memset(a,0,sizeof(NCB))

#define MAX_ADAPTER_NUMBER           1
#define MAX_SESSION_COUNT          254
#define MAX_NAMES                  254
#define MAX_COMMAND_COUNT          255

#define NO_WAIT                   ((UCHAR) 0x80)

#define NBIOS_RESET             ((UCHAR) 0x32)
#define NBIOS_CANCEL            ((UCHAR) 0x35)
#define NBIOS_ADAPTER_STATUS    ((UCHAR) 0x33)
#define NBIOS_UNLINK            ((UCHAR) 0x70)
#define NBIOS_TRACE             ((UCHAR) 0x79)

#define NBIOS_ADD_NAME          ((UCHAR) 0x30)
#define NBIOS_ADD_GROUP_NAME    ((UCHAR) 0x36)
#define NBIOS_DELETE_NAME       ((UCHAR) 0x31)
#define NBIOS_FIND_NAME         ((UCHAR) 0x78)

#define NBIOS_CALL              ((UCHAR) 0x10)
#define NBIOS_LISTEN            ((UCHAR) 0x11)
#define NBIOS_HANG_UP           ((UCHAR) 0x12)
#define NBIOS_SEND              ((UCHAR) 0x14)
#define NBIOS_SEND_NO_ACK       ((UCHAR) 0x71)
#define NBIOS_CHAIN_SEND        ((UCHAR) 0x17)
#define NBIOS_CHAIN_SEND_NO_ACK ((UCHAR) 0x72)
#define NBIOS_RECEIVE           ((UCHAR) 0x15)
#define NBIOS_RECEIVE_ANY       ((UCHAR) 0x16)
#define NBIOS_SESSION_STATUS    ((UCHAR) 0x34)

#define NBIOS_SEND_DATAGRAM     ((UCHAR) 0x20)
#define NBIOS_RECEIVE_DATAGRAM  ((UCHAR) 0x21)
#define NBIOS_SEND_BDATAGRAM    ((UCHAR) 0x22)
#define NBIOS_RECEIVE_BDATAGRAM ((UCHAR) 0x23)

#define NBIOS_INVALID_COMMAND   ((UCHAR) 0x7F)

/* LAN Adapter Types */

#define TOKEN_RING_ADAPTER ((UCHAR) 0xFF)
#define PC_NETWORK_ADAPTER ((UCHAR) 0xFE)

/* NBIOS Version Numbers */

#define VERSION_MASK ((UCHAR) 0x0F)

#define PARM_MASK ((UCHAR) 0xF0)
#define OLD_PARMS ((UCHAR) 0x10)
#define NEW_PARMS ((UCHAR) 0x20)

#define MIN_NAME_NUM       2
#define MAX_NAME_NUM     254
#define ILLEGAL_NAME_NUM   0

#define MIN_LSN       1
#define MAX_LSN     254
#define ILLEGAL_LSN   0

#define NB_ILLEGAL_BUFFER_LENGTH       0x01
#define NB_INVALID_COMMAND             0x03
#define NB_COMMAND_TIMED_OUT           0x05
#define NB_MESSAGE_INCOMPLETE          0x06
#define NB_NO_ACK_FAILURE              0x07
#define NB_ILLEGAL_LSN                 0x08
#define NB_NO_RESOURCE_AVAILABLE       0x09
#define NB_SESSION_CLOSED              0x0A
#define NB_COMMAND_CANCELED            0x0B
#define NB_DUPLICATE_LOCAL_NAME        0x0D
#define NB_NAME_TABLE_FULL             0x0E
#define NB_NAME_HAS_ACTIVE_SESSIONS    0x0F

#define NB_LOCAL_SESSION_TABLE_FULL    0x11
#define NB_SESSION_OPEN_REJECTED       0x12
#define NB_ILLEGAL_NAME_NUMBER         0x13
#define NB_CANNOT_FIND_CALLED_NAME     0x14
#define NB_NAME_NOT_FOUND_OR_ILLEGAL   0x15
#define NB_NAME_USED_ON_RMT_ADAPTER    0x16
#define NB_NAME_DELETED                0x17
#define NB_SESSION_ENDED_ABNORMALLY    0x18
#define NB_NAME_CONFLICT_DETECTED      0x19
#define NB_INCOMPATIBLE_RMT_DEVICE     0x1A

#define NB_intERFACE_BUSY              0x21
#define NB_TOO_MANY_COMMANDS_PENDING   0x22
#define NB_INVALID_ADAPTER_NUMBER      0x23
#define NB_CMD_COMPLETED_DURING_CANCEL 0x24
#define NB_RESERVED_NAME_SPECIFIED     0x25
#define NB_CMD_NOT_VALID_TO_CANCEL     0x26

#define NB_LANA_SYSTEM_ERROR           0x40
#define NB_LANA_REMOTE_HOT_CARRIER     0x41
#define NB_LANA_LOCAL_HOT_CARRIER      0x42
#define NB_LANA_NO_CARRIER_DETECTED    0x43
#define NB_UNUSUAL_NETWORK_CONDITION   0x44

#define NB_ADAPTER_MALFUNCTION         0x50

#define NB_COMMAND_PENDING             0xFF

typedef struct {
     UCHAR   cmd;         /* command code                   */
     UCHAR   ret;         /* return code                    */
     UCHAR   lsn;         /* local session number           */
     UCHAR   num;         /* Datagram ADD NAME table entry  */
     void *          buf;         /* buffer */
     UINT    len;         /* length of data in I/O buffer   */
     UCHAR   cnam[16];    /* remote system name for CALL    */
     UCHAR   anam[16];    /* local adapter network name     */
     UCHAR   rto;         /* receive timeouts in 1/2 second units */
     UCHAR   sto;         /* send    timeouts in 1/2 second units */
     void *          post;        /* post routine */
     UCHAR   anum;        /* network adapter number to execute cmd  */
     UCHAR   comp;        /* 0xFF ==> command pending, else cmplted */
     UCHAR   res[14];     /* work area for network card     */
   } NCB;                         /* prototype NCB for sizeof calcs */

typedef struct {
    UCHAR name[16];     /* symbolic network name     */
    UCHAR num;          /* associated name number    */
    UCHAR stat;        /* & with 0x0087 for status  */
} NAMEENT;

typedef struct {
    UCHAR id[6];
    UCHAR jump;
    UCHAR post;
    UCHAR major;
    UCHAR minor;
    UINT  inter;
    UINT  crcerr;
    UINT  algerr;
    UINT  colerr;
    UINT  abterr;
    ULONG tcnt;
    ULONG rcnt;
    UINT  retran;
    UINT  xresrc;
    UCHAR res0[8];
    UINT  free;
    UINT  max;
    UINT  maxhw;
    UCHAR res1[4];
    UINT  pending;
    UINT  msp;
    UINT  maxses;
    UINT  bufsiz;
    UINT  names;
    NAMEENT       name[16];
} ASTAT;

void            cleardgb      (INT index);
INT             finddgb       (INT len);
INT             dgklf         (void);
INT             nbiosrst      (void);
INT             nbiosastat    (UCHAR *name,ASTAT *a);
INT             nbiosaddname  (CHAR *name);
INT             nbiosdelname  (CHAR *name);
INT             nbioscancel   (NCB *cn);
INT             nbiosaddgname (CHAR *name);
INT             nbiossdgram   (INT index);
INT             nbiospdgram   (CHAR *name,INT num,INT len,CHAR *buf,INT type);
void interrupt  postroutine   (void);
INT             nbiosrdgram   (void);
INT             nbiosgdgram   (INT *len,CHAR *buf);
INT             nbiosopen     (CHAR *name,INT cl);
INT             nbiosclose    (INT lsn);
INT             nbioswrite    (INT lsn,CHAR *buf,INT len);
INT             nbiosread     (INT lsn,CHAR *buf,INT len);
INT             nbiosgetfile  (CHAR *name,CHAR *file,CHAR *path);
INT             nbiosputfile  (CHAR *name,CHAR *file,CHAR *path);

typedef struct {
    NCB   *n;   // network control block pointer
    CHAR  sn;   // number of sends
    CHAR  s;    // status - 'r'=ready for rx  'R'=rx'ed 'S'=sent
    INT   t;    // timout - 0=timed out
    CHAR  *b;   // buffer
} DGRAMBUF;
typedef struct {
	INT   s;
	CHAR *fl[50];
	INT  numf;
	INT  curf;
	CHAR *buf;
	INT   len;
	INT   fd;
	INT   nd;
	INT   er;
	INT   pl;
	INT   pos;
} FILEXMIT;
typedef void (interrupt *IFPTR)(void);

volatile INT G_donepost=0;
volatile INT G_inpost=0;
INT          G_numdgb=0;
DGRAMBUF     *G_dgb=NULL;
CHAR         G_nodename[17];
CHAR         G_sessname[17];

FILEXMIT G_ftx;
INT 	 G_infrtxpost=0;
INT		 G_bufuse=0;
CHAR    *G_txrxbuf=NULL;
CHAR    *G_frxfilep=NULL;
CHAR 	*G_frxfile=NULL;
NCB  	*G_ftrxncb=NULL;
NCB  	*G_retry=NULL;
IFPTR    G_postrout=NULL;

NCB 	 G_ackncb;
INT 	 G_ackpak[3]={DGRAMACK,0,0};
INT 	 G_rdgb=0;
INT 	 G_ldgb=0;


#endif  //  def NETDEV_C

#endif  //  ndef NETDEV_H
