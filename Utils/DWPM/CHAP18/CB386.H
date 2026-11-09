/* CB386.H - include file for CopyBuilder 386
   See makefile for compile directives
*/
/* number of times to retry disk ops */
#define NRTRIES 3

/* force codebuilder to not align */
#pragma align(_bpb=1)

/* structre of disk BPB */
extern struct _bpb
  {
  unsigned char jump[3];
  char oemname[8];
  unsigned short bytespersec;
  unsigned char secperclust;
  unsigned short ressectors;
  unsigned char nrfats;
  unsigned short rootsize;
  unsigned short nrsectors;
  char media;
  unsigned short fatsectors;
  unsigned short secpertrack;
  unsigned short nrheads;
  unsigned int hiddensecs;
  unsigned int hugesectors;
  unsigned char physdrive;
  char notused;
  unsigned char signature;      /* should be 0x29 */
  unsigned int serno;
  char label[11];
  char type[8];
  char pad[512-60];          /* rest of 512 byte sector */
  } bpb;

/* various globals */
extern int driveno;
extern unsigned disksize;
extern unsigned sectorct;

/* disk image buffer */
extern unsigned char *diskbuf;
/* DOS buffer used to communicate with BIOS */
extern char *dosbuf;
extern unsigned int dosbufsiz;
/* set by critical errors */
extern int critical_err;

/* information on buffer */
extern struct _bufinfo
  {
  char title[65];
  unsigned size;
  unsigned short copies;
  char source[13];
/* checksums (stored and computed) */
  unsigned short csum, ccsum;
  short dirty;
  } bufinfo;

extern void (*slbreak)(); /* place to hook break handler */

/* holds disk format command */
extern char fmtcmd[];

/* additional break handler */
extern void (*when_break)();

/* prototypes for break handlers */
void load_break();
void save_break();

/* general prototypes */
int sector_read(int head, int track, int sector, int drive,
            unsigned char *buf,unsigned count);

int sector_write(int head, int track, int sector, int drive,
            unsigned char *buf,unsigned count);

/* disable reboot */
void noreboot(void);
void okreboot(void);
