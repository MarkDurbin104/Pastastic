/* Windows portion of WINX server
   See Makefile for compile instructions
*/

#include <windows.h>
#include <dos.h>
#include <ctype.h>
#include <string.h>
#ifdef __BORLANDC__
#include <dir.h>
#else
#include <direct.h>
#endif

/* MUX interrupt signature + command */
#define SIG(n) (0xF200|(n))

/* pointer to DOS buffer */
unsigned char _far *buffer;
/* local buffer */
char nbuffer[512];


/* DPMI register structure */
struct realregs
        {
        unsigned long EDI,ESI,EBP,reserved,
                 EBX,EDX,ECX,EAX;
        unsigned short flags,ES,DS,FS,GS,
                 IP,CS,SP,SS;
        };

/* DPMI real interrupt */
realint86(int intno,struct realregs *r)
  {
  union REGS pr;
  struct SREGS s;
  void _far *rp=(void _far *)r;
  segread(&s);
/* DPMI real interrupt function */
  pr.x.ax=0x300;
  pr.x.bx=intno;
  pr.x.cx=0;
  s.es=FP_SEG(rp);
  pr.x.di=FP_OFF(rp);
/* ask for default stack */
  r->SS=0;
  r->SP=0;
/* set flags to something appropriate */
  r->flags=0;
  int86x(0x31,&pr,&pr,&s);
  return pr.x.cflag;
  }


void _far *map_linear(unsigned long base,unsigned long limit)
  {
  union REGS r1;
  void _far *rv;
/* Get a descriptor (function 0) */
  r1.x.ax=0;
  r1.x.cx=1;
  int86(0x31,&r1,&r1);
  if (r1.x.cflag) ;
/* Set base address (function 7) */
  r1.x.bx=r1.x.ax;
  r1.x.ax=7;
  r1.x.cx=(base&0xF0000)>>16;
  r1.x.dx=base&0xFFFF;
  int86(0x31,&r1,&r1);
/* Set limit (function 8) */
  r1.x.ax=8;
  r1.x.cx=(limit&0xFFFF0000L)>>16;
  r1.x.dx=limit&0xFFFF;
  int86(0x31,&r1,&r1);
/* construct pointer */
  FP_SEG(rv)=r1.x.bx;
  FP_OFF(rv)=0;
  return rv;
  }


int  PASCAL WinMain(HANDLE Inst,HANDLE Prev,
                       LPSTR cmdline,int show)
  {
  char *cmd;
  struct realregs r;
  unsigned long base;
  WORD timer;
  MSG msg;
/* Only one server at a time, please */
  if (Prev)
    {
    MessageBox(NULL,"WINX Server already running!",
               "Error",MB_OK|MB_ICONSTOP);
    return 0;
    }
/* check for WINX */
  r.EAX=SIG(0);
  realint86(0x2f,&r);
  if ((r.EAX&0xFF)!=0xFF)
    {
    MessageBox(NULL,"WINX not loaded!",
            "Error",MB_OK|MB_ICONSTOP);
    return 0;
    }
/* Get buffer address */
  r.EAX=SIG(1);
  realint86(0x2f,&r);
  base=((r.EBX&0xFFFF)<<4)+(r.ECX&0xFFFF);
/* Convert buffer to PM pointer */
  buffer=map_linear(base,512);
  *buffer='\0';     /* buffer is ready */
/* Wait around in 1/4 second intervals */
  timer=SetTimer(NULL,1,250,NULL);
/* if *buffer==0xFF then time to go */

/* This program has no visible window. It has a
   normal message loop (here). Instead of dispatching
   messages to a window, it just processes timer
   and termination messages directly */
  while (*buffer!=0xFF&&GetMessage(&msg,NULL,0,0))
    {
    char _far *s;
    char *d;
    unsigned long rv;
/* only respond to timer messages */
    if (msg.message!=WM_TIMER) continue;
/* No activity in buffer .... */
    if (!*buffer) continue;
/* Something is there! */
    d=nbuffer;
    s=buffer+1;
/* copy to local buffer */
    while (*d++=*s++);
/* Is it command 2 (set working directory)? */
    if (*buffer==2)
      {
      unsigned int dummy;
/* Set drive too if specified */
      if (nbuffer[1]==':')
        _dos_setdrive(toupper(nbuffer[0])-'A'+1,&dummy);
      rv=chdir(nbuffer);
      }
/* Command 3 is WinExec */
    if (*buffer==3) rv=WinExec(nbuffer,1);
/* Command FF is abort server */
    if (*buffer==0xFF) rv=0;
/* store return value */
    *(unsigned long _far *)(buffer+1)=rv;
/* signal other side that task is complete */
    *buffer='\001';
    }

/* When command==0xFF come here to clean up */
  KillTimer(NULL,timer);
  return 0;
  }



