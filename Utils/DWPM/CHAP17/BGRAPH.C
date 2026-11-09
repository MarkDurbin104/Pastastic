/* BGRAPH.C - Emulate small subset of Microsoft graphics
   using Borland C. These routines use the BIOS, so they
   are not very fast, but they have the virtue of
   simplicity

  See MAKEFILE for TURTLE.EXE for instructions
*/

#include <dos.h>
#include "pgraph.h"

static int mode;
static int x=0,y=0,textx=0,texty=0,color=1,textcolor=1;

void _setvideomode(int md)
  {
  union REGS r;
  mode=md;
  r.x.ax=md;
  int86(0x10,&r,&r);
  }

void _clearscreen(int dummy)
  {
/* cheat! */
  _setvideomode(mode);
  }

void _setcolor(int clr)
  {
  color=clr;
  }

unsigned long _remappalette(int index,unsigned long color)
  {
  union REGS r;
  unsigned long rv;
  r.x.ax=0x1015;
  r.x.bx=index;
  int86(0x10,&r,&r);
  rv=(unsigned long)r.h.cl<<16;
  rv|=(unsigned long)r.h.ch<<8;
  rv|=r.h.dh;
  r.x.ax=0x1010;
  r.x.bx=index;
  r.h.ch=(color&0xFF00)>>8;
  r.h.dh=color&0xFF;
  r.h.cl=(color&0xFF0000)>>16;
  int86(0x10,&r,&r);
  return rv;
  }

void _setbkcolor(unsigned long clr)
  {
  _remappalette(0,clr);
  }

void _moveto(int x0,int y0)
  {
  x=x0;
  y=y0;
  }

void _settextcolor(int clr)
  {
  textcolor=clr;
  }

void _settextposition(int r,int c)
  {
  texty=r;
  textx=c;
  }

void _outtext(char *s)
  {
  union REGS r;
  r.h.ah=0xE;
  r.x.bx=textcolor;
  while (*s)
    {
    r.h.al=*s++;
    int86(0x10,&r,&r);
    }
  }

void _plot(int x,int y)
  {
  static int first=1;
  static union REGS r;
  union REGS r1;
  if (first)
    {
    r.h.bh=0;
    r.h.ah=0xC;
    first=0;
    }
  if (x<0||x>319) return;
  if (y<0||y>199) return;
  r.h.al=color;
  r.x.cx=x;
  r.x.dx=y;
  int86(0x10,&r,&r1);
  }

void _lineto(int x1,int y1)
  {
  int xup=1,yup=1,  /* updates */
  sx,sy,            /* straight updates */
  dely,delx,        /* deltas */
  xx=x,yy=y,        /* current x,y */
  err,              /* accumulated error */
  err_diag,         /* diagonal error */
  err_str;          /* straight error */
/* find |delta y| */
  dely=y1-y;
  if (dely<0)
    {
    dely=-dely;
    yup=-1;
    }

/* find |delta x| */
  delx=x1-x;
  if (delx<0)
    {
    delx=-delx;
    xup=-1;
    }

/* select largest delta */
  if (delx<dely)
    {
    int t;
    sx=0;
    sy=yup;
    t=delx;
    delx=dely;
    dely=t;
    }
  else
    {
    sy=0;
    sx=xup;
    }
/* compute error terms and inital values */
  err_str=dely*2;
  err=err_str-delx;
  err_diag=err-delx++;

/* draw line */
  while (delx--)
    {
    _plot(xx,yy);
    if (err>=0)
      {
/* diagonal */
      xx+=xup;
      yy+=yup;
      err+=err_diag;
      }
    else
      {
/* straight */
      xx+=sx;
      yy+=sy;
      err+=err_str;
      }
    }
/* set current position */
  x=x1;
  y=y1;
  }


struct xycoord _getcurrentposition(void)
    {
    struct xycoord xy;
    xy.xcoord=x;
    xy.ycoord=y;
    return xy;
    }

