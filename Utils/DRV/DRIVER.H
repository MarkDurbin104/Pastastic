typedef unsigned int  UINT;
typedef unsigned char UCHAR;

#define INIT        0
#define MEDCHK      1
#define BLDBPB      2
#define IOCRLTI     3
#define INPUT       4
#define IPNOWT      5
#define IPSTAT      6
#define IPFLSH      7
#define OUTPUT      8
#define OPVERI      9
#define OPSTAT      10
#define OPFLSH      11
#define IOCRLTO     12

#define DONE        0x0100
#define BUSY        0x0200

#define ERRWP       0x8000
#define ERRBU       0x8001
#define ERRNR       0x8002
#define ERRBC       0x8003
#define ERRCRC      0x8004
#define ERRBR       0x8005
#define ERRSEEK     0x8006
#define ERRBM       0x8007
#define ERRBS       0x8008
#define ERRNP       0x8009 
#define ERRWRITE    0x800A
#define ERRREAD     0x800B
#define ERRGEN      0x800C


typedef struct {
    char len;
    char unit;
    char cmd;
    UINT stat;
    char res[8];
} REQBLK;

typedef struct {
    char      units;
    int       brk[2];
    char far  *bpb;
} INITBLK;
typedef struct {
    char      med;
    char far *buf;
    int       cnt;
    int       sec;
} IOBLK;

typedef struct {
	REQBLK r;
	union {
		INITBLK ini;
		IOBLK   io;
		char    fcb[9];
	} p;
} PARMBLK;

#ifdef DRIVER_CODE
void abort(void) { ; }
void _terminate(void) { ; }
void _checknull(void) { ; }
void _restorezero(void) { ; }
void _cleanup(void) { ; }
int errno;
int __brklvl;

#endif
