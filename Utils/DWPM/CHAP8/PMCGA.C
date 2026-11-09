/* Example of direct memory access
   This program works with Code Builder, DOS, Ergo OS/386,
   Ergo DPM16, GNU C++, Phar Lap 286, Phar Lap 386, or
   Rational. You must set one of the #define statements
   below for your extender.
   (Ergo and Rational assume Watcom C).

   For specific compiler directives, see the comment
   preceding each #define.
*/

/* icc /znoansi cga.c  */
#define CODEBUILDER 0

/*  bcc pmcga.c
or: cl pmcga.c */
#define DOS 0

/* generic DPMI (tested with DPM/16):
cl -AL -G2 pmcga.c ergo.def
(note: you can't test with Code Builder since it
doesn't support far pointers) */
#define DPMI 0

/* wcl386 -l=ergo pmcga.c */
#define ERGO 0

/* cl -AL -G2 pmcga.c ergo.def ergoapi.lib */
#define ERGODPMI 0

/* gcc -o cga cga.c
  == NOTE == You must press ENTER to continue if compiled
  with GNU */
#define GNU 0

/* cl -AL -G2 -Lp pmcga.c llibpe.lib (versions before 2.5 -- */
/* cl -AL -G2 -Lp pmcga.c (version 2.5 and later */
/* bcc286 pmcga.c */
#define PHARLAP286  1

/* HC386 pmcga.c */
#define PHARLAP386 0

/* wcl386 -l=dos4g pmcga.c */
#define RATIONAL4GW 0

#if RATIONAL4GW || ERGO
#define WATCOM 1
#endif

#if \
    CODEBUILDER+DOS+DPMI+ERGO+ERGODPMI+GNU+\
    PHARLAP386+PHARLAP286+RATIONAL4GW!=1
#error One and only one extender must be defined
#endif

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>


/* Extender/Compiler specific things */
#if PHARLAP286
#include <phapi.h>
#endif

#if GNU
#define _far
#define wait4key() getchar();
#else
#include <conio.h>
#define wait4key()  { if (!getch()) getch(); }
#endif

#if WATCOM
#define int86 int386
#define x w
#endif


/* prototype for setptr function
   int is deliberate here -- we want 64K for 16-bit
   and 4G for 32-bit */
char _far *setptr(long base,unsigned int limit);
/* free pointer when done, if required */
void freeptr(char _far *);
int setmode(int);
int draw(void);


/* pointer to cga buffer */
char _far *cgaptr;


main()
  {
/* change video mode */
  setmode(4);
/* draw a picture */
  draw();
/* wait for a key */
  wait4key();
/* return to 80X25 mode */
  setmode(3);
/* quit */
  freeptr(cgaptr);
  exit(0);
  }

/* Set the specified mode using INT 0x10 (BIOS call) */
int setmode(int mode)
  {
  union REGS r;
  r.x.ax=mode;
  int86(0x10,&r,&r);
  return 0;
  }


/* plot a point at (x,y) using color */
void plot(int x,int y,int color)
  {
  int offset,bitno,mask;
/* if 1st time, make pointer */
  if (!cgaptr) cgaptr=setptr(0xb8000L,0x7FFF);
  if (!cgaptr)
    {
    printf("Can't create pointer\n");
    exit(1);
    }
/* compute offset */
  offset=((y&1)<<13)+(80*(y>>1))+(x>>2);
/* compute bit position of pixel */
  bitno=(~x&3)<<1;
  mask=3<<bitno;
/* clear any bits in that position */
  cgaptr[offset]&=~mask;
/* set the right bits */
  cgaptr[offset]|=color<<bitno;
  }

/* draw a simple line */
int draw()
  {
  int x,y;
  y=120;
  for (x=0;x<150;x++) plot(x,y,1);
  return 0;
  }

/* The following routines compute the cgaptr variable
   for various extenders */

#if CODEBUILDER||RATIONAL4GW
/* limit ignored */
/* _far is only to match prototype -- no "far"
   in these compilers */
char _far *setptr(long add,unsigned limit)
  {
  char *val;
/* simple case -- use linear address */
  val=(char *)add;
  return val;
  }

/* No freeptr */
void freeptr(char *p)
  {
  }

#endif

#if GNU
/* limit ignored */
char *setptr(long add,unsigned limit)
  {
  char *val;
/* linear address + 0xE0000000 */
  val=(char *)add+0xE0000000;
  return val;
  }

/* No freeptr */
void freeptr(char *p)
  {
  }

#endif

#if PHARLAP386
char _far *setptr(long add,unsigned limit)
  {
  void _far *p;
  union REGS r;
  struct SREGS s;
/* init segment registers */
  segread(&s);
/* allocate 0 length segment */
  r.h.ah=0x48;
  r.w.ebx=0;
  int86(0x21,&r,&r);
/* check for error */
  if (r.x.cflag)  return NULL;
/* modify base/length of segment */
  s.es=r.x.ax;
  r.x.ax=0x250a;
/* new address */
  r.w.ebx=add;
/* map 4K pages */
  r.w.ecx=((limit+1)+4095)/4096;
  int86x(0x21,&r,&r,&s);
/* error check */
  if (r.x.cflag) return NULL;
/* Set pointer using macros in DOS.H */
/* Note these macros don't work as lvalues in WATCOM.C
   use p=MK_FP(s.es,r.w.eax); instead */
  FP_SEG(p)=s.es;
  FP_OFF(p)=r.w.eax;
  return p;
  }

void freeptr(char _far *p)
  {
  union REGS r;
  struct SREGS s;
  segread(&s);
  s.es=FP_SEG(p);
  r.h.ah=0x49;
  int86x(0x21,&r,&r,&s);
  }

#endif

#if PHARLAP286
char _far *setptr(long add,unsigned limit)
  {
  void _far *p;
  int seg,off,sel;
/* compute segment and offset of address */
  seg=add>>4;
  off=add-(seg<<4);
/* make segment */
  if (DosMapRealSeg(seg,limit+1,&sel)) return NULL;
/* make pointer if successful */
  FP_SEG(p)=sel;
  FP_OFF(p)=off;
  return p;
  }

/* No freeptr required for DosMapRealSeg() */
void freeptr(char _far *p)
  {
  }

#endif

#if ERGODPMI
/* limit ignored */
char _far *setptr(long add,unsigned limit)
  {
  void _far *p;
  int sel,seg;
/* compute segment */
  seg=add>>4;
/* make segment */
  ParaToSel(seg,&sel);
/* construct pointer */
  FP_SEG(p)=sel;
  FP_OFF(p)=add-(seg<<4);
  return p;
  }

/* Freeing selector from ParaToSel is unwise since they
   are a global resource */
void freeptr(char _far *p)
  {
  }


#endif

#if ERGO
/* Size must be <64K for this function */
char _far *setptr(long add,unsigned limit)
  {
  union REGS r;
  char _far *p;
/* use create real window function */
  r.x.ax=0xe803;
/* cx:dx is limit */
  r.x.cx=0;
  r.x.dx=limit;
/* si:bx is address */
  r.x.si=add>>16;
  r.x.bx=add&0xFFFF;
  int86(0x21,&r,&r);
/* construct pointer */
  p=MK_FP(r.x.ax,0);
  return p;
  }


void freeptr(char _far *p)
  {
  union REGS r;
  struct SREGS s;
  segread(&s);
  s.es=FP_SEG(p);
  r.h.ah=0x49;
  int86x(0x21,&r,&r,&s);
  }



#endif


#if DOS
/* limit ignored */
char _far *setptr(long add,unsigned limit)
  {
  void _far *p;
/* DOS is easy case, compute segment and offset */
  int seg=add>>4;
  FP_SEG(p)=seg;
  FP_OFF(p)=add-(seg<<4);
  return p;
  }

/* no free required, of course */
void freeptr(char _far *p)
  {
  }


#endif

#if DPMI
/* siz<64K for this function */
char _far *setptr(long add,unsigned limit)
  {
  void _far *p;
  union REGS r;
/* allocate 1 descriptor */
  r.x.ax=0;
  r.x.cx=1;
  int86(0x31,&r,&r);
  if (r.x.cflag) return NULL;
/* set base address */
  r.x.bx=r.x.ax;
  r.x.ax=7;
  r.x.cx=add>>16;
  r.x.dx=add&0xFFFF;
  int86(0x31,&r,&r);
  if (r.x.cflag) return NULL;
/* set limit  */
  r.x.ax=8;
  r.x.cx=0;
  r.x.dx=limit;
  int86(0x31,&r,&r);
  if (r.x.cflag) return NULL;
  FP_SEG(p)=r.x.bx;
  FP_OFF(p)=0;
  return p;
  }

void freeptr(char _far *p)
  {
  union REGS r;
  r.x.ax=1;
  r.x.bx=FP_SEG(p);
  int86(0x31,&r,&r);
  }


#endif


