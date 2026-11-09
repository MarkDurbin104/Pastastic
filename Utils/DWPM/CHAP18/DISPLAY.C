/* DISPLAY.C general purpose C text display library
   Originally written for Microsoft C and ported to
   Code Builder
   For CB386.C
   See also DISPLAY.H DIRPICK.C, and HISTO.C

*/
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <stdarg.h>
#include "display.h"

/* global variable sets color of output */
int color=7;

/* primary colors for color monitor (see display.h) */
int colors[4]={ 0x1e, 0x70, 0x1c, 0x7e };

/* 1=mono monitor, 0=color, -1=unknown */
int mono=-1;

/* set video mode and detect mono monitor
   this should always be called first */
void vidmode()
  {
  union REGS r;
  if (mono<0)
    {
    r.h.ah=0xf;
    int86(0x10,&r,&r);
    mono=r.h.al==7;
    }
  r.x.ax=mono?7:3;
  int86(0x10,&r,&r);
  r.x.ax=0x500;
  int86(0x10,&r,&r);
  }



/* goto point x,y (from 0-79 and 0-24) */
void goxy(int x,int y)
  {
  union REGS r;
  r.h.ah=2;
  r.h.dh=y;
  r.h.dl=x;
  r.h.bh=0;
  int86(0x10,&r,&r);
  }


/* clear screen region */
void clears(int x0, int y0,int x1,int y1)
  {
  union REGS r;
  r.x.ax=0x600;
  r.h.bh=color;
  r.h.ch=y0;
  r.h.cl=x0;
  r.h.dh=y1;
  r.h.dl=x1;
  int86(0x10,&r,&r);
  goxy(0,0);
  }

/* get x,y position */
void getxy(int *x,int *y)
  {
  union REGS r;
  r.h.ah=3;
  r.h.bh=0;
  int86(0x10,&r,&r);
  *x=r.h.dl;
  *y=r.h.dh;
  }

/* write count characters
   -- handle \r, \n, backspace, and \a
   updates the cursor if count==1 (w/o line wrap)
   otherwise, the cursor doesn't move */
void writecc(int c,int count)
  {
  union REGS r;
/* PS/2 BIOS will try to print 0 characters and hang! */
  if (count<=0) return;
/* if bell character... */
  if (c=='\a')
    {
/* use function 0eH to do count bells */
    while (count--)
      {
      r.x.ax=0xe00|'\a';
      r.x.bx=0;
      int86(0x10,&r,&r);
      }
    return;
    }
/* if regular character (not \n or \r or bs) */
  if (c!='\n'&&c!='\r'&&c!=8)
    {
/* print regular character */
    r.h.ah=9;
    r.h.al=c;
    r.h.bh=0;
    r.h.bl=color;
    r.x.cx=count;
    int86(0x10,&r,&r);
/* if count isn't 1 return else do cursor update
   NOTE: \n \r always update cursor */
    if (count!=1) return;
    }
/* get cursor position */
  r.h.ah=3;
  r.h.bh=0;
  int86(0x10,&r,&r);
/* if \r, zero x coordinate
   Note that 100 \r's is the same as 1 */
  if (c=='\r')
    r.h.dl=0;
/* if \n, increment y coordinate by count */
  else if (c=='\n')
    r.h.dh+=count;
/* if backspace back up by count or to start of line */
  else if (c==8)
    r.h.dl-=r.h.dl>count?count:r.h.dl;
  else
/* bump x coordinate. Assume it won't wrap over */
    r.h.dl++;
  r.h.ah=2;
  int86(0x10,&r,&r);
  }

/* write a string using writec, a writecc macro
   (see display.h) */
void writes(char *s)
  {
  while (*s) writec(*s++);
  }

/* printf using writecc max length 99 */
int printfc(char *fmt,...)
  {
  int rc;
  char outbuf[100];
  va_list aptr;
  va_start(aptr,fmt);
  rc=vsprintf(outbuf,fmt,aptr);
  writes(outbuf);
  return rc;
  }


/* prompt for single key @ coordinates x,y
   use str as prompt, resp is valid keys, pcolor
   is the color to use (0 for same color). Alpha characters
   in resp should be upper case. If resp is "" then all
   characters are valid. If resp is NULL then any alpha
   character is valid.

   returns:
   -1 if ESC pressed
   index of character if resp is valid
   character if resp is NULL or ""
   */
int prompt_at(int x, int y, char *str,char *resp,int pcolor)
  {
  int ocolor,c;
  char *index;
  goxy(x,y);
  ocolor=color;
  if (pcolor) color=pcolor;
/* clear to end of line */
  clreol();
  writes(str);
  while (1)
    {
/* get key */
    c=getch();
    if (!c)
      {
/* ignore extended keys */
      getch();
      continue;
      }
/* if esc quit */
    if (c==27) break;
/* shift upper */
    c=toupper(c);
/* if resp in not null, check it */
    if (resp&&(index=strchr(resp,c))) break;
/* if resp is null, check for alpha */
    if (resp==NULL&&isalpha(c)) break;
/* if resp=="" then anything is OK */
    if (resp&&!*resp) break;
    }
  color=ocolor;
  goxy(x,y);
  clreol();
  curshide();
  return c==27?-1:resp&&*resp?index-resp:c;
  }



/* prompt for input @x,y. Prompt with promptstr
   valid is a string of valid input characters
   (if NULL, all characters are OK., clr is the color
   (0 for same), len is the input length, buf is the
   buffer (should be at least len+1 long, and help is an
   optional help string (use NULL for the default help)

   returns: -1 if ESC
            # of characters input otherwise

   You can use the backspace key to edit entries */

int ask_at(int x, int y, char *promptstr,char *valid,
      int clr,int len,char *buf,char *help)
  {
  int count=0,c,ocolor=color;
  char *bp=buf;
/* clear buffer */
  memset(buf,0,len+1);
/* set color, goto input line, and clear it */
  if (clr) color=clr;
  goxy(x,y);
  clreol();
/* write prompt */
  writes(promptstr);

/* main loop */
  while (1)
    {
/* get a character. Extended keys are <0 */
    c=getch();
    if (!c) c=-getch();
/* handle backspace */
    if (c==8)
      {
      if (bp!=buf)
        {
        bp--;
        writec(8);
        writec(' ');
        writec(8);
        *bp='\0';
        count--;
        }
      continue;
      }
/* Escape or enter ends input */
    if (c=='\r'||c==27)
      {
/* restore color */
      color=ocolor;
/* clear line */
      goxy(x,y);
      clreol();
      curshide();
/* return */
      return c==27?-1:count;
      }
/* If F1 give help */
    if (c==-59)
      {
      vidsave();
      prompt(help?help:
      " Use <ENTER> to accept, <ESC> to quit, <Backspace>"
         " to correct.","",SOCOLOR);
      vidrestore();
      continue;
      }
/* ignore other extended keys (c<0) or regular keys if
   at input limit (count==len) */
    if (count==len||c<0) continue;
/* if not valid character, ignore */
    if (valid&&!strchr(valid,c)) continue;
/* echo input character */
    writec(c);
/* store in buffer */
    *bp++=c;
/* update count */
    count++;
    }
  }


/**********************************************
 routines to save and restore the video context
Note: This was the big change for this module
from Microsoft C to Code Builder. The addresses
of the video buffers are different...
 */

/* places to save things */
static char vbuf[4096];
static int save_xy,save_color;

/* save video */
void vidsave()
  {
  union REGS r;
  save_color=color;
  r.h.ah=3;
  r.h.bh=0;
  int86(0x10,&r,&r);
  save_xy=r.x.dx;
/* For Microsoft, you need a far pointer B000:0000 and
   B800:0000 here... */
  memcpy((void *)vbuf,(void *)(mono?0xb0000:0xb8000),4096);
  }

/* restore video */
void vidrestore()
  {
  union REGS r;
/* For Microsoft, you need a far pointer B000:0000 and
   B800:0000 here... */
  memcpy((void *)(mono?0xb0000:0xb8000),(void *)vbuf,4096);
  color=save_color;
  r.h.ah=2;
  r.h.bh=0;
  r.x.dx=save_xy;
  int86(0x10,&r,&r);
  }


