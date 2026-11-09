#ifndef ARC_H
#define ARC_H

typedef unsigned char  uchar;   
typedef unsigned int   uint;    
typedef unsigned short ushort;  
typedef unsigned long  ulong;   
typedef short node;

#define INIT_CRC        0  
#define BITBUFSIZ       (CHAR_BIT * sizeof bitbuf)
#define DICBIT          13    
#define DICSIZ          (1U<<DICBIT)
#define MATCHBIT        8    
#define MAXMATCH        256    
#define THRESHOLD       3    
#define PERC_FLAG       0x8000U
#define NC              (UCHAR_MAX+MAXMATCH+2-THRESHOLD)
#define CBIT            9  
#define CODE_BIT        16  
#define CRCPOLY         0xA001  
#define UPDATE_CRC(c)   crc=crctable[(crc^(c))&0xFF]^(crc>>CHAR_BIT)
#define PERCOLATE       1
#define NIL             0
#define MAX_HASH_VAL    (3*DICSIZ+(DICSIZ/512+1)*UCHAR_MAX)
#define HASH(p,c)       ((p)+((c)<<(DICBIT-9))+DICSIZ*2)
#define NP              (DICBIT+1)
#define NT              (CODE_BIT+3)
#define PBIT            4 
#define TBIT            5 
#define FNAME_MAX       (255-25)
#define namelen         header[19]
#define filename        ((char *)&header[20])

#if NT>NP
#define NPT             NT
#else
#define NPT             NP
#endif


int     unpackable;
ulong   origsize, compsize;
FILE    *arcfile, *infile, *outfile;
uint    crc, bitbuf;
ushort  left[], right[];
int     unpackable;
ulong   compsize,origsize;
uchar   buffer[DICSIZ];
uchar   header[255];
uchar   headersize,headersum;
uint    filecrc;
char    *tempname;
FILE    *arcfile,*infile,*outfile;
uint    crc,bitbuf;
ushort  crctable[UCHAR_MAX+1];
uint    subbitbuf;
int     bitcount;
uchar   *text,*childcount;
node    pos,matchpos,avail,*position,*parent,*prev,*next=NULL;
int     remainder,matchlen;
#if MAXMATCH<=(UCHAR_MAX+1)
	uchar *level;
#else
	ushort *level;
#endif
int     n,heapsize;
short   heap[NC+1];
ushort  *freq,*sortptr,lencnt[17];
uchar   *len;
ushort  left[2*NC-1],right[2*NC-1];
uchar   *buf,clen[NC],ptlen[NPT];
uint    bufsiz=0,blocksize;
ushort  cfreq[2*NC-1],ctable[4096],ccode[NC];
ushort  pfreq[2*NP-1],pttable[256],ptcode[NPT],tfreq[2*NT-1];
uint    outputpos,outputmask;
int     j;
char    *usage="Usage: ar command archive [file ...]\n"
               "Commands:\n"
               "   a: Add files to archive (replace if present)\n"
               "   x: Extract files from archive\n"
               "   r: Replace files in archive\n"
               "   d: Delete files from archive\n"
               "   p: Print files on standard output\n"
               "   l: List contents of archive\n";

void    error          (char *fmt, ...);
void    makecrctable   (void);
void    fillbuf        (int n);
uint    getbits        (int n);
void    putbits        (int n, uint x);
int     freadcrc       (uchar *p, int n, FILE *f);
void    fwritecrc      (uchar *p, int n, FILE *f);
void    initgetbits    (void);
void    initputbits    (void);
void    encode         (void);
void    decodestart    (void);
void    decode         (uint count, uchar text[]);
void    hufencodestart (void);
void    hufdecodestart (void);
uint    decodec        (void);
uint    decodep        (void);
void    output         (uint c, uint p);
void    hufencodeend   (void);
void    maketable      (int nchar, uchar bitlen[],int tablebits, ushort table[]);
int     maketree       (int nparm, ushort freqparm[],uchar lenparm[], ushort codeparm[]);

#endif // ndef ARC_H
