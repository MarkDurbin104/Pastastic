/* DISP.C - menus, etc. for CopyBuilder 386
*/
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <ctype.h>
#include <direct.h>
#include <setjmp.h>
#include <signal.h>
#include "cb386.h"
#include "display.h"


/* display information screen */
disp()
  {
  color=TEXTCOLOR;
  cls();
  color=SOCOLOR;
  clreol();
  writes(" Read  Write  Load  Save  Options  Dos  Exit");
  goxy(73,0);
  writes("F1=Help");
  color=TEXTCOLOR;
  goxy(33,1);
  writes("386 CopyBuilder");
  goxy(1,3);
  writes("Current status:\n\n\r");
  printfc(" Title: %s\n\n\r",bufinfo.title);
  printfc(" Size: %-8d  Copies: %-6d  Source: %s\n\n\r",
      bufinfo.size,bufinfo.copies,bufinfo.source);
  printfc(" Checksums: Stored=%04X  Computed=%04X\n\n\r",
      bufinfo.csum,bufinfo.ccsum);
  writecc(0xc4,80);
  curshide();
  }

/* Jump buffer for break handling */
jmp_buf onbreak;
/* pointer to extra break function */
void (*when_break)()=NULL;

/* primary break function */
void breakfunc(int sig)
  {
/* recapture break key */
  signal(SIGINT,breakfunc);
/* do extra break function if present */
  if (when_break) when_break();
  when_break=slbreak=NULL;
/* go back to top of menu loop */
  longjmp(onbreak,1);
  }

static int oldbreakflag;

/* Set break flag -- returns old value */
int set_breakflag(int val)
  {
  int old;
  union REGS r;
  r.x.ax=0x3300;
  int86(0x21,&r,&r);
  old=r.h.dl;
  r.h.dl=val;
  r.x.a0x3301;
  int86(0x21,&r,&r);
  return old;
  }

#define reset_breakflag() set_breakflag(oldbreakflag)

/* main menu */
menu()
  {
  int c;
  char tfmtcmd[129];
/* Turn break on */
  oldbreakflag=set_breakflag(1);
/* catch ^C -- signal is OK since we redraw the whole
   screen first thing. */
  signal(SIGINT,breakfunc);
/* return here when ^C pressed */
  setjmp(onbreak);
/* display screen */
  disp();
/* main loop */
  while (1)
    {
/* get command */
    curshide();
    c=getch();
    if (!c) c=-getch();
/* process commands (extended keys are negative) */
    switch (c>0?(int)toupper(c):c)
      {
      char fn[66];
/* For each command the letter and ALT-letter are OK */
case -0x12:  /* ALT-E */
case 'E':
      m_exit();
      break;

case -0x20:   /* ALT-D */
case 'D':
      m_dos();
      disp();
      break;

case -0x13:   /* ALT-R */
case 'R':
      m_read();
      disp();
      break;

case -0x11:   /* ALT-W */
case 'W':
      m_write();
      disp();
      break;

case -0x1f:   /* ALT-S */
case 'S':
      m_save();
      disp();
      break;

case -0x26:   /* ALT-L */
case 'L':
      m_load();
      disp();
      break;

case -0x18:    /* ALT-O */
case 'O':
      goxy(0,23);
      printfc("Current: %-64.64s",fmtcmd);
      ask("Format command:",NULL,TEXTCOLOR,
          sizeof(tfmtcmd)-1,
          tfmtcmd,
          "Enter the format command string. CB386 appends"
          " the drive letter.");
      if (*tfmtcmd) strcpy(fmtcmd,tfmtcmd);
      goxy(0,23);
      clreol();
      break;

case -0x23:    /* ALT-H */
case 'H':
case -59:
      help();
      break;


default:
/* ring bell for unknown command */
      writec('\a');
      }
    }
  }


/* exit */
m_exit()
  {
/* confirm if buffer is full and hasn't been written */
  if (dirtyquery())
    {
    vidmode();
    cdrestore();
    okreboot();
    reset_breakflag();
    exit(0);
    }
  }

/* read a disk */
m_read()
  {
  int disk;
  if (!dirtyquery()) return;
  disk=prompt("Source drive: ",NULL,TEXTCOLOR);
  if (disk==-1) return;
  if (prompt(
    "\aInsert disk. Press <SPACE> to continue or"
    " <ESC> to exit.",
    " \r",TEXTCOLOR)==-1) return;
/* hook ^C handler to do load_break (in FILEIO.C) if ^C) */
  slbreak=when_break;
  when_break=load_break;
  read_disk(disk);
  when_break=slbreak;
  slbreak=NULL;
  }

/* write to disk */
m_write()
  {
  int disk;
  int copies=1;
  char buf[4];
  if (!diskbuf)
    {
    advise("No disk image in memory");
    return;
    }
  disk=prompt("Destination drive: ",NULL,TEXTCOLOR);
  if (disk==-1) return;
  /* prompt for copies */
  if (ask("Number of copies (default=1): "
          ,"0123456789",TEXTCOLOR,3,buf,
          " Enter the number of copies you want.")==-1)
      return;
  copies=atoi(buf);
  if (!copies) copies=1;
  while (copies--)
    {
    if (prompt(
    "\a\aInsert disk. Press <SPACE> to continue or"
    " <ESC> to exit.",
    " \r",TEXTCOLOR)==-1) return;
/* hook ^C handler to save_break (in FILEIO.C) */
    slbreak=when_break;
    when_break=save_break;
    if (write_disk(disk)) bufinfo.copies++;
    when_break=slbreak;
    slbreak=NULL;
    disp();
    }
  }


/* prompt user if buffer is "dirty" */
dirtyquery()
  {
  int stat=1;
  if (bufinfo.dirty)
    {
    stat=prompt("\aBuffer not saved. Discard (Y/N)",
                "NY",ERRCOLOR);
    if (stat==-1) stat=0;
    }
  return stat;
  }

/* Run DOS -- some old versions of Codebuilder won't set the
   prompt correctly (bug fixed in later versions) */
m_dos()
  {
/* clear screen and reset color */
  vidmode();
  putenv("PROMPT=Enter \"Exit\" to return to 386 "
         "CopyBuilder\r\n$p$g");
  if (system("command")<0)
    advise("Could not execute COMMAND.COM");
/* reset screen mode just in case */
  vidmode();
  curshide();
  }


/* main menu help screen */
help()
  {
  vidsave();
  color=TEXTCOLOR;
  cls();
  color=SOCOLOR;
  clreol();
  writes(" Read  Write  Load  Save  Options  Dos  Exit");
  goxy(73,0);
  writes("F1=Help");
  color=TEXTCOLOR;
  goxy(0,1);
  writes("                                   \n\r");
  writes("  ³      ³     ³     ³       ³      ³    ³\n\r");
  writes("  ³      ³     ³     ³       ³      ³    ÀÄ"
  " Exit CB386\n\r");
  writes("  ³      ³     ³     ³       ³      ³\n\r");
  writes("  ³      ³     ³     ³       ³      ÀÄ "
  "Shell to DOS\n\r");
  writes("  ³      ³     ³     ³       ³\n\r");
  writes("  ³      ³     ³     ³       ÀÄ Set options\n\r");
  writes("  ³      ³     ³     ³\n\r");
  writes("  ³      ³     ³     ÀÄ "
  "Save working image to a disk file\n\r");
  writes("  ³      ³     ³\n\r");
  writes("  ³      ³     ÀÄ "
  "Load working image from a disk file\n\r");
  writes("  ³      ³\n\r");
  writes("  ³      ÀÄ Write working image to a floppy\n\r");
  writes("  ³\n\r");
  writes("  ÀÄ Read working image from a floppy\n\n\n\r");
  goxy(25,23);
  writes("CopyBuilder 386 by Al Williams");
  prompt("Press any key to continue","",SOCOLOR);
  vidrestore();
  }
