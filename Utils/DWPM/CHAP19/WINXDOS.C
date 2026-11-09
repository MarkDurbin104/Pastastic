/* DOS portion of WINX server
   see MAKEFILE for details */
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <process.h>

/* MUX interrupt signal */
#define SIG 0xF200

#define RT unsigned short
#ifdef __BORLANDC__
#define INTREGS RT Rbp, RT Rdi, RT Rsi, RT Rds, \
                RT Res, RT Rdx, RT Rcx, RT Rbx, \
                RT Rax, RT Rip, RT Rcs, RT Rfl

unsigned _stklen=1024;
unsigned _heaplen=1024;
#else
#define INTREGS RT Res,RT Rds,RT Rdi,RT Rsi, \
                RT Rbp,RT Rsp,RT Rbx,RT Rdx, \
                RT Rcx,RT Rax,RT Rip,RT Rcs,RT Rfl
#endif

void (_interrupt _far *old2f)();
char buffer[512];

/* MUX interrupt handler */
void _far _interrupt new2f(INTREGS)
  {
/* If not SIG then this isn't for us */
  if ((Rax&0xFF00)!=SIG) _chain_intr(old2f);
/* process command */
  switch (Rax&0xFF)
    {
/* Install check */
    case 0:
      Rax=0xFF;
      return;

/* Get address */
    case 1:
      {
      char _far *b=(char _far *)buffer;
      Rbx=FP_SEG(b);
      Rcx=FP_OFF(b);
      return;
      }

/* Send string to Windows portion */
    case 2:    /* Change drive/directory */
    case 3:    /* Call WINEXEC */
    if (!*buffer)
      {
      char _far *s;
      char _far *d=buffer+1;
      unsigned timeout=0x8000;
      FP_SEG(s)=Rbx;
      FP_OFF(s)=Rcx;
      while (*d++=*s++);
      *buffer=Rax&0xFF;
      _enable();
      while (*buffer!=1&&timeout--)
        {
/* tell Windows we are idle -- calling INT 2F with AX=1680
   gives Windows a chance to do something else before returning
   to us. */
        union REGS r;
        r.x.ax=0x1680;
        int86(0x2F,&r,&r);
        }
/* Mark success */
      Rax=(*buffer==1)?0:0xFFFF;
      Rbx=*(unsigned short *)(buffer+1);
      Rcx=*(unsigned short *)(buffer+3);
      *buffer=0;
      return;
      }
    else
      Rax=0xFFFF;
    return;

    default:
    Rfl|=1;
    return;
    }
  }



void main(int argc,char *argv[])
  {
  union REGS r;
  int stat;
  r.x.ax=SIG;
  int86(0x2f,&r,&r);
  if (r.h.al==0xFF)
    {
    puts(
    "WINX already active or multiplex interrupt in use.\n");
    exit(1);
    }
/* Check for Windows 3.0 in real or std mode */
  r.x.ax=0x4680;
  int86(0x2f,&r,&r);
  stat=r.x.ax;
/* Check for enhanced mode (al!=0 and al!=0x80 if true) */
  r.x.ax=0x1600;
  int86(0x2f,&r,&r);
  if (r.h.al!=0&&r.h.al!=0x80&&stat!=0)
    {
    puts("Can't start WINX from a Windows DOS box.\n");
    exit(1);
    }
  old2f=_dos_getvect(0x2f);
  _dos_setvect(0x2f,new2f);
/* Set environment to contain WINX=YES */
  putenv("WINX=YES");
  if (spawnlp(P_WAIT,"win","win",NULL)==-1)
     puts("Couldn't execute Microsoft Windows\n");
  _dos_setvect(0x2f,old2f);
  exit(0);
  }

