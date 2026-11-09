#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <ctype.h>
#ifdef __BORLANDC__
#include <dir.h>
#else
#include <direct.h>
#include <stdlib.h>   /* Microsoft _psp */
#endif
#include <process.h>

#define SIG(x) (0xF200|(x))

/* To make this a stub program define WINRUN_STUB */

char cmd[129];

void help(void);
void timedout(void);


void main(int argc,char *argv[])
  {
  union REGS r;
  char _far *p=cmd;
  unsigned timeout=0xFFFF;
/* Check for WINX server */
  r.x.ax=SIG(0);
  int86(0x2f,&r,&r);
  if (r.h.al==0)
    {
    printf("Error: WINX or Windows not loaded\n");
    exit(2);
    }
/* Set current directory */
  getcwd(cmd,sizeof(cmd));
  while (timeout--)
    {
/* Send to server */
    r.x.ax=SIG(2);
    r.x.bx=FP_SEG(p);
    r.x.cx=FP_OFF(p);
    int86(0x2f,&r,&r);
    if (r.x.ax!=0xFFFF) break;
    }
  if (r.x.ax==0xFFFF)
    timedout();

  timeout=0xFFFF;
#ifdef WINRUN_STUB
  strcpy(cmd,argv[0]);
  strcat(cmd," ");
#else
  if (argc==1) help();
#endif
  if (argc!=1)
    {
    int count;
    unsigned char _far *cmdline;
#ifdef WINRUN_STUB
    unsigned char *d=cmd+strlen(cmd);
#else
    unsigned char *d=cmd;
#endif
/* get program name and command line */
    FP_SEG(cmdline)=_psp;
    FP_OFF(cmdline)=0x80;
    count=*cmdline++;
    while (isspace(*cmdline))
      {
      cmdline++;
      if (!count) break;
      }
    while (--count) *d++=*cmdline++;
    *d='\0';
    }
/* Send to server */
  while (timeout--)
    {
    r.x.ax=SIG(3);
    r.x.bx=FP_SEG(p);
    r.x.cx=FP_OFF(p);
    int86(0x2f,&r,&r);
    if (r.x.ax!=0xFFFF) break;
    }
  if (r.x.ax==0xFFFF) timedout();
  if (r.x.bx<32)
    {
    printf("Can't execute (error %d).\n",r.x.bx);
    r.x.bx++;
    }
  else r.x.bx=0;
  exit(r.x.bx);
  }

void timedout()
  {
  printf("WINX server is busy");
  exit(3);
  }


#ifndef WINRUN_STUB
void help()
  {
  printf("Usage: WINRUN program [arguments...]\n");
  exit(1);
  }
#endif
