/* CB386.C - main file for CopyBuilder 386
   See makefile for compile directives
*/
#include <stdio.h>
#include <dos.h>
#include <ctype.h>
#include "cb386.h"
#include "display.h"

/* current drive number */
int driveno;

/* current bios parameter block */
struct _bpb bpb;

/* size of disk */
unsigned disksize;

/* information about buffer */
struct _bufinfo bufinfo;


/* number of sectors */
unsigned sectorct;

/* storage for disk image */
unsigned char *diskbuf;

/* set when a critical error occurs */
int critical_err;

/* DOS buffer for disk BIOS reads and writes */
char *dosbuf;
unsigned dosbufsiz;

/* text of format command */
char fmtcmd[129];

/* set when a critical error occurs */
int critical_err;

/* critical error messages */
static char *cmsgs[]=
  {
  "Write protect",
  "Unknown unit",
  "Drive not ready",
  "Unknown command",
  "CRC error",
  "Bad Request",
  "Seek error",
  "Unknown media",
  "Sector not found",
  "Out of paper",
  "Write error",
  "Read error",
  "General failure",
  "Unknown",
  "Unknown",
  "Invalid change"
  };


/* Critical error handler */
void cerror(int dev,int code)
  {
  char msg[81];
  int choice;
  critical_err=code&=0xFF;
  sprintf(msg,"Critical error: %s (Retry, Fail, Ignore)",
          cmsgs[code]);
  choice=prompt(msg,"RIF",ERRCOLOR);
  if (choice==0) choice=_HARDERR_RETRY;
  else if (choice==1) choice=_HARDERR_IGNORE;
  else choice=_HARDERR_FAIL;  /* F or ESC */
  _hardresume(choice);
  }



/* main program */
main(int argc,char *argv[])
  {
/* set up critical error handler */
  _harderr(cerror);
/* Turn break on */
  if (argc>2||argv[1][0]=='?'||argv[1][1]=='?')
    error("CopyBuilder 386 by Al Williams\n"
          "A diskette duplication system\n"
          "Usage: CB386 [drive]\n");
/* save current drive/directory */
  cdsave();
/* set up video mode and detect monitor type */
  vidmode();
/* if mono monitor, set up neutral colors */
  if (mono)
    {
    TEXTCOLOR=7;
    SOCOLOR=0x70;
    ERRCOLOR=1;
    HELPCOLOR=7;
    }
/* reset title, etc. */
  strcpy(bufinfo.title,"<EMPTY>");
  strcpy(bufinfo.source,"N/A");
  strcpy(fmtcmd,"format");
  noreboot();
/* if user asked for a disk on the command line, read it */
  if (argc==2)
    {
/* show a display */
    disp();
/* read the disk */
    read_disk(*argv[1]);
    }
/* goto main menu */
  menu();
  }



/* Non-interactive error routine */
error(char *s)
  {
  printf("\n%s\n",s);
  cdrestore();
  exit(1);
  }


/* compute checksum
   add sixteen bit words and wrap carry around */
checksum()
  {
  unsigned char *bufp=diskbuf;
  int i=bufinfo.size;
  unsigned short cksum=0;
  unsigned cksum1;
  while (i--)
    {
    cksum1=cksum;
    cksum1+=*bufp++;
    cksum=cksum1&0xFFFF;
    if (cksum1&0xFFFF0000)
      cksum++;
    }
  bufinfo.ccsum=cksum;
  return cksum;
  }


/* Format a disk in the indicated drive */
format(int driveno)
  {
  char fcmd[80];
  int stat;
/* build command line */
  sprintf(fcmd,"%s %c:",fmtcmd,driveno+'A');
/* save video */
  vidsave();
  cls();
/* execute command */
  stat=system(fcmd);
  vidrestore();
  if (stat==-1) advise("Unable to execute format program");
  }

/* turn the blinking -wait- on at bottom of screen */
wait_on()
  {
  int ocolor=color;
  color=SOCOLOR|0x80;   /* make it blink */
  goxy(0,24);
  clreol();
  goxy(37,24);
  printfc("-WAIT-");
  curshide();
  color=ocolor;
  }

/* turn the blinking -wait- off at bottom of screen */
wait_off()
  {
  goxy(0,24);
  clreol();
  }
