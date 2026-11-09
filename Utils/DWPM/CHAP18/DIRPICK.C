/* DIRPICK.C - directory pick routine
   Originally for Microsoft C -- easy port to Code Builder
   See CB386.C
*/
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <ctype.h>
#include "display.h"


/* structure to hold directory entries */
struct _dirnames
  {
  char name[13];
  unsigned short attr;
  } dirnames[5][24];

/* pointer to null string */
static char *nulls="";

/* function to print file names for dirpick */
static void pfname(int cursorx,int cursory)
    {
    writes(dirnames[cursorx][cursory].name);
    if (dirnames[cursorx][cursory].name[0]!='.'
       &&
       dirnames[cursorx][cursory].attr
             !=(unsigned short) 0xFFFF
       &&
       dirnames[cursorx][cursory].attr&_A_SUBDIR)
      writes("\\");
    }



/* Set drive safely -- returns 0 for success, 1 for error */
safe_setdrive(unsigned drive)
  {
  unsigned olddrive,maxdrive,newdrive;
  struct DOSERROR err;
/* get old drive in case */
  _dos_getdrive(&olddrive);
/* set new drive */
  _dos_setdrive(drive,&maxdrive);
/* did it take? */
  _dos_getdrive(&newdrive);
/* NO: return 1 */
  if (newdrive!=drive) return 1;
/* If, by some chance, there is a file X on the drive
   return success */
  if (!access("X",0)) return 0;
/* If not, see why not */
  dosexterr(&err);
/* If critical error... */
  if (err.exterror==83)
    {
/* reset old drive and fail */
    _dos_setdrive(olddrive,&maxdrive);
    return 1;
    }
/* No critical error -- there just isn't a file
   named X. return success */
  return 0;
  }


/* MAIN function  -- do a directory on the file spec and
   offer a menu of choices including directories and drives
   maximum of 120 files displayed at once */
char *dirpick(char *spec)
  {
/* set when recursing */
  static int recurse=0;
  int stat=0;
  unsigned nd,nrdrives;
  int x0,y0;
  char *cp,*dirpfx=spec;
  struct find_t info;
  short cursorx=0, cursory=0, x=0, y=0;
/* clear out directory structure */
  memset((void *)dirnames,0,5*24*sizeof(struct _dirnames));
/* check for drive specified */
  if (spec[1]==':')
    {
    unsigned int junk;
/* change to specified drive */
/*    _dos_setdrive(toupper(spec[0])-'A'+1,&junk);
    _dos_getdrive(&junk);
    stat=junk!=toupper(spec[0])-'A'+1; */
    stat=safe_setdrive(toupper(spec[0])-'A'+1);
    dirpfx+=2;
    }
/* see if directory specified */
  if (stat==0 && (cp=strrchr(spec,'\\')))
    {
/* make dirpfx equal to directory. If cp==dirpfx then
   change to root directory */
    *cp='\0';
    stat=chdir(cp==dirpfx?"\\":dirpfx);
    }
/* if stat is non-zero then drive or cd didn't work */
  if (stat) return NULL;
/* chop drive/directory off spec */
  spec=cp?cp+1:dirpfx;

/* find first file */
  if (stat=_dos_findfirst(*spec?spec:"*.*",
                _A_NORMAL|_A_SUBDIR,&info))
     return NULL;
/* save video if not recursive */
  if (!recurse) vidsave();
  color=TEXTCOLOR;
/* clear screen */
  cls();
/* setup psuedo-drives here */
  _dos_getdrive(&nd);
  _dos_setdrive(nd,&nrdrives);
  while (nrdrives--)
    {
    dirnames[cursorx][cursory].name[0]='[';
    dirnames[cursorx][cursory].name[1]=
           cursory*5+cursorx+'A';
    dirnames[cursorx][cursory].name[2]=']';
    dirnames[cursorx][cursory].name[3]='\0';
/* attribute =0xffff means this is a drive */
    dirnames[cursorx][cursory].attr=0xFFFF;
    goxy(x,y);
    writes(dirnames[cursorx][cursory].name);
    x+=16;
    if (++cursorx==5)
      {
      x=cursorx=0;
      cursory++;
      y++;
      }
    }
  x0=cursorx;
  y0=cursory;
/* while file names are found and screen isn't full */
  while (!stat&&cursory!=24)
    {
/* save name and attribute */
    strcpy(dirnames[cursorx][cursory].name,info.name);
    dirnames[cursorx][cursory].attr=info.attrib;
    goxy(x,y);
    x+=16;
    pfname(cursorx,cursory);
    if (++cursorx==5)
      {
      x=cursorx=0;
      cursory++;
      y++;
      }
    stat=_dos_findnext(&info);
    }
/* found all files... print help line */
  goxy(0,24);
  color=SOCOLOR;
  clreol();
  writes("Use arrows to select. Press <ENTER> to accept"
  " or <ESC> to cancel.");
  color=TEXTCOLOR;

/* place cursor on first real file (not drive) */
  cursorx=x0;
  cursory=y0;
  x=cursorx*16;
  y=cursory;

/* main loop */
  while (1)
    {
/* write file name under cursor */
    color=SOCOLOR;
    goxy(x,y);
    pfname(cursorx,cursory);
    color=TEXTCOLOR;
/* get character */
    stat=getch();
    if (stat=='\r'&&
       (dirnames[cursorx][cursory].attr&_A_SUBDIR))
      {
/* pressed enter on subdirectory  or drive */
      char *rc;
/* if drive ... */
      if (dirnames[cursorx][cursory].attr==
                (unsigned short)0xFFFF)
        stat=safe_setdrive((unsigned)cursory*5+cursorx+1);
      else
        stat=chdir(dirnames[cursorx][cursory].name);
/* if dir/drive change was not successful */
      if (stat)
        {
        advise("\aCan't change to that directory");
        continue;
        }
/* recurse */
      recurse++;
      rc=dirpick(spec);
/* restore video */
      if (!recurse) vidrestore();
      recurse--;
/* return file picked */
      return rc;
      }
/* If escape or enter on a file */
    if (stat==27||stat=='\r')
      {
/* restore video
      if (!recurse) vidrestore();
/* return null string (ESC) or file name (ENTER) */
      return stat==27?nulls:dirnames[cursorx][cursory].name;
      }
/* if other normal key, keep going */
    if (stat) continue;
/* get extended scan code */
    stat=getch();
/* reset cursor */
    goxy(x,y);
    pfname(cursorx,cursory);
    switch (stat)
      {
/* up arrow */
case 0x48:
      if (cursory)
        {
        cursory--;
        y--;
        }
      break;

/* down arrow */
case 0x50:
      if (cursory!=23&&*dirnames[cursorx][cursory+1].name)
        {
        cursory++;
        y++;
        }
      break;

/* left */
case 0x4b:
      if (cursorx)
        {
        cursorx--;
        x-=16;
        }
      break;

/* right */
case 0x4d:
      if (cursorx!=4&&*dirnames[cursorx+1][cursory].name)
        {
        cursorx++;
        x+=16;
        }
      break;
      }
    }
  }

/***********************************************************
 routines to save and restore the current working drive and
 directory
 **********************************************************/

/* saved information */
static unsigned save_drive;
static char save_cd[66];

/* save working drive/directory */
void cdsave()
  {
  _dos_getdrive(&save_drive);
  getcwd(save_cd,sizeof(save_cd));
  }

/* restore drive/directory */
void cdrestore()
  {
  unsigned junk;
  _dos_setdrive(save_drive,&junk);
  chdir(save_cd);
  }

/**********************************************************
 prompt for file name -- if file name ends with \ or : or
 contains ? or *, dirpick is called. returns 1 on success
 0 on failure.

 If user types in full name, that is passed to the program.
 If he picks name from dirpick, the current drive/directory
 changes as the user picks them. Only the base name of the
 file returns to the caller
 */
int getfilen_at(int x, int y,char *fn,int len)
  {
   if (ask_at(x,y,"File: ",NULL,TEXTCOLOR,len,fn,
              " Enter a file name. Wildcards (?*) are OK."
              " Default=*.*")==-1) return 0;

/* if file contains wildcards do dirpick */
   if (*fn=='\0'||strchr(fn,'*')||strchr(fn,'?')||
        fn[strlen(fn)-1]=='\\'||fn[strlen(fn)-1]==':')
     {
     char *pick;
     pick=dirpick(fn);
     if (!pick)
       {
       advise_at(x,y,"No matching files");
       return 0;
       }
/* Escape or bad file */
     if (!*pick) return 0;
/* Fail if file name len exceeds buffer space */
     if (strlen(pick)+1>len) return 0;
     strcpy(fn,pick);
     }
   return 1;
   }
