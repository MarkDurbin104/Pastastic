/* Calling real mode TSR from Windows
   Compile:
   Borland: BWINCOMP PLAYWIN
   Microsoft: MWINCOMP PLAYWIN
*/
#include <dos.h>
#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
//#include <windows.h>
//#include "winpmode.h"
int setnotes(void);

/* Multiplex interrupt used to communicate with TSRs */
#define MUXINT    0x2f


/* DPMI register structure */
struct RM_REGS
        {
        unsigned long EDI, ESI, EBP,
           reserved, EBX, EDX, ECX, EAX;
        unsigned short flags, ES, DS, FS,
           GS, IP, CS,SP, SS;
        };

/* DPMI real interrupt */
real_int(int intno,struct RM_REGS *r)
  {
  union REGS pr;
  struct SREGS s;
  void _far *fp=(void _far *)r;
  segread(&s);

/* DPMI real interrupt function */
  pr.x.ax=0x300;
  pr.x.bx=intno;
  pr.x.cx=0;
  s.es=FP_SEG(fp);
  pr.x.di=FP_OFF(fp);

/* ask for default stack */
  r->SS=0;
  r->SP=0;

/* set flags to something appropriate */
  r->flags=0;
  int86x(0x31,&pr,&pr,&s);
  return pr.x.cflag;
  }

/* DPMI real mode call (return w/IRET) */
real_icall(struct RM_REGS *r)
  {
  union REGS pr;
  struct SREGS s;
  void _far *fp=(void _far *)r;
  segread(&s);

/* DPMI real mode call function */
  pr.x.ax=0x302;
  pr.h.bh=0;
  pr.x.cx=0;
  s.es=FP_SEG(fp);
  pr.x.di=FP_OFF(fp);

/* ask for default stack */
  r->SS=0;
  r->SP=0;

/* set flags to harmless value */
  r->flags=0;
  int86x(0x31,&pr,&pr,&s);
  return pr.x.cflag;
  }

/* allocate a real mode callback */
alloc_callbk(void _far *f,struct RM_REGS _far *r,
              void _far **cb)
  {
  union REGS pr;
  struct SREGS s;
  void _far *p;
  segread(&s);

/* DPMI Allocate callback function */
  pr.x.ax=0x0303;
  pr.x.si=FP_OFF(f);
  s.ds=FP_SEG(f);
  s.es=FP_SEG(r);
  pr.x.di=FP_OFF(r);
  int86x(0x31,&pr,&pr,&s);
  if (!pr.x.cflag)
    {
    FP_SEG(p)=pr.x.cx;
    FP_OFF(p)=pr.x.dx;
    *cb=p;
    }
  return pr.x.cflag;
  }

/* Free real mode callback */
free_callbk(void _far *p)
  {
  union REGS r;

/* DPMI callback free function */
  r.x.ax=0x0304;
  r.x.cx=FP_SEG(p);
  r.x.dx=FP_OFF(p);
  int86(0x31,&r,&r);
  return r.x.cflag;
  }

char *input(char *a,char *b,...)
{
    va_list ap;
    static char tmp[1000],*t;
    int k;
    va_start(ap,b);
    vsprintf(tmp,b,ap);
    va_end(ap);

    printf("%s\n%s ",a,tmp);
    
    t=tmp;
    *t=0;
    while ((k=getch())!='\r') {
        printf("%c",k);
        *(t++)=k;
        *t=0;
    }
    printf("\n");
    return(tmp);
}

/* Table of musical notes */
int notes[6][12]=
  {
     {18357,17292,16345,15297,14551,13715,12830,12175,
     11473,10847,10198,9701},
     {9108,8584,8117,7649,7231,6818,6450,6088,5736,5424,
     5121,4811},
     {4554,4308,4058,3837,3616,3419,3225,3044,2875,2712,
     2560,2415},
     {2281,2154,2033,1918,1811,1709,1612,1522,1436,1356,
     1280,1208},
     {1147,1082,1015,961,910,858,802,761,718,678,639,605},
     {570,538,508,479,452,427,403,380,359,339,320,302}
  };

/* Musical notes */
char xlat[]="CDEFGAB";

/* MUSIC command */
#define M_STOP    0xaa00
#define M_PLAY    0xaa01
#define M_RESET   0xaa02
#define M_SETNOTE 0xaa03
#define M_DELAY   0xaa04
#define M_CALLBK  0xaa05
#define M_LOADED  0xF700


/* number of times tones have played
  (updated by callback) */
int ctr=0;

/* Define callback routine. The real mode TSR can
   call this function. DPMI treats this
   function like an interrupt, so you must use the
   _interrupt attribute. The register order differs
   between Borland C++ and Microsoft C */
#ifdef __BORLANDC__
void _far _interrupt callback(unsigned bp,unsigned di,
                              unsigned si, unsigned ds,
                              unsigned es)
#else
void _far _interrupt callback(unsigned es,unsigned ds,
                              unsigned di, unsigned si)

#endif
  {
  struct RM_REGS _far *rmregs; /* real mode registers */
  unsigned _far *stack;  /* pointer to real mode stack */
  FP_SEG(rmregs)=es;   /* calculate pointer to registers */
  FP_OFF(rmregs)=di;
  FP_SEG(stack)=ds; /* calculate pointer to real mode stack */
  FP_OFF(stack)=si;
  ctr++; /* increment counter */

/* simulate far return -- "pop" return address
   from stack and adjust SP */
  rmregs->CS=stack[1];
  rmregs->IP=stack[0];
  rmregs->SP+=4;
  }


char *cmd;

char *test(void)
  {
/* Allocate two structures for real mode registers
  rmregs holds registers passed to the callback
  routine and r holds registers for real mode
  interrupts and calls */
  struct RM_REGS rmregs,r;
/* real mode pointer to callback address */
  void _far *cb;

/* alternate entry point for MUSIC TSR */
  int music_ip,music_cs;

/* see if MUSIC is loaded */
  r.EAX=0xF700;
  real_int(MUXINT,&r);
  if ((r.EAX&0xFF)!=0xFF)
    {
    printf("Error","Music TSR not found!\n");
    return "Done";
    }

/* save entry point */
  music_ip=r.ECX&0xFFFF;
  music_cs=r.EBX&0xFFFF;

/* Reset MUSIC */
  r.EAX=M_RESET;
  real_int(0x15,&r);

/* Set replay delay to 1 second */
  r.EAX=M_DELAY;
  r.ECX=18;

/* Call entry point instead of using
   INT 15H -- both are equivalent */
  r.IP=music_ip;
  r.CS=music_cs;
  real_icall(&r);

/* set callback address */
  alloc_callbk(callback,&rmregs,&cb);
  r.EDX=FP_SEG(cb);
  r.ECX=FP_OFF(cb);
  r.EAX=M_CALLBK;
  real_int(0x15,&r);

  while (1)
    {
    int n=0;
/* read command */
     cmd=input("Main Menu","(%d) "
         "E=enter notes, P=play, S=stop, R=reset, Q=quit",ctr);
     while (isspace(cmd[n])) n++;
     if (!cmd[n]) continue;
     switch (toupper(*cmd))
       {
       case 'E':
          setnotes();
          break;

       case 'P':
/* play notes (use alternate entry point */
          r.EAX=M_PLAY;  /* Music play command */
          r.IP=music_ip;
          r.CS=music_cs;
          real_icall(&r);
          break;

       case 'S':
/* stop notes */
          r.EAX=M_STOP;  /* Music stop command */
          real_int(0x15,&r);
          break;

       case 'R':
/* reset notes */
          r.EAX=M_RESET;  /* Music reset command */
          real_int(0x15,&r);
          r.EAX=M_DELAY;  /* Music set delay */
          r.ECX=18;
          real_int(0x15,&r);
          break;

       case 'Q':
/* quit (but release callback first) */
          r.EAX=M_CALLBK;
          r.EDX=r.ECX=0;
          real_int(0x15,&r);
          free_callbk(cb);
          return "Done";

       default:
          printf("Error","I don't understand!\n");
          break;
       }
    }
  }


/* Read notes and pass to MUSIC TSR */
setnotes()
  {
  struct RM_REGS r;
  int beat=8;
  int octave=3;
  printf("Instructions",
         "Enter notes using the following notation:\n"
         "1C - Whole note C\n"
         "2D - 1/2 note D\n"
         "4E - 1/4 note E\n"
         "E  - 1/4 note E\n"
         "8F - 1/8 note F\n"
         "G# - 1/4 G sharp\n"
         "A- - 1/4 A flat\n"
         ".  - 1/4 rest\n"
         "@2 - Change octaves (1-6)\n"
         "Enter a blank line to return to the main menu\n");
   while (*(cmd=input("Enter Notes","Notes:")))
    {
    int i,n=strlen(cmd);
    for (i=0;i<n;i++)
      {
      int c;
      int noteindex;
      int newbeat;
      c=toupper(cmd[i]);
      if (c=='@')
        {
        c=cmd[++i]-'1';
        if (c>=0&&c<=6) octave=c;
        continue;
        }
      newbeat=beat/4;
      if (isdigit(cmd[i]))
        {
        newbeat=beat/(cmd[i++]-'0');
        c=cmd[i];
        }
/* rest? */
      if (c=='.')
        {
        noteindex=999;
        }
      else
        {
/* ignore non-notes */
        if (!strchr(xlat,c)) continue;
        noteindex=strchr(xlat,c)-xlat;
        noteindex*=2;
        if (noteindex>4) noteindex--;
        }
      if (cmd[i+1]=='#')
        {
        noteindex++;
        i++;
        }
      else if (cmd[i+1]=='-')
        {
        noteindex--;
        i++;
        }
/* send note to MUSIC */
      r.EAX=M_SETNOTE;
      r.EDX=noteindex<900?notes[octave][noteindex]:0;
      r.ECX=newbeat;
      real_int(0x15,&r);
      }
    }
  return 0;
  }
int main(void)
{
    printf("Here we go... \n");
    printf("%s\n",test());
    return(0);
}
