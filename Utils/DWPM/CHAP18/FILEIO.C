/* FILEIO.C File oriented I/O routines for CB386
*/
#include <stdio.h>
#include <malloc.h>
#include <errno.h>
#include "cb386.h"
#include "display.h"

void (*slbreak)();   /* place to hook break handler */

/* ^C handler when saving -- used in DISKIO.C too */
void save_break()
  {
  advise("\aOperation aborted");
  }

/* ^C handler when loading -- used in DISKIO.C too */
void load_break()
  {
  cleanup();
  }

/* Clean up an aborted load */
cleanup()
  {
  if (diskbuf) free(diskbuf);
  diskbuf=NULL;
  memset(&bufinfo,0,sizeof(bufinfo));
  strcpy(bufinfo.title,"<EMPTY>");
  strcpy(bufinfo.source,"N/A");
  }

/* save disk image to a file */
m_save()
  {
  slbreak=when_break;
  when_break=save_break;
  saveit();
  when_break=slbreak;
  slbreak=NULL;
  }

/* load disk image to a file */
m_load()
  {
  slbreak=when_break;
  when_break=load_break;
  loadit();
  when_break=slbreak;
  slbreak=NULL;
  }

/* actual routine to save data */
saveit()
  {
  char fn[66];
  FILE *f=NULL;
  int cnt1;
/* if no data to save, forget it */
  if (!diskbuf)
    {
    advise("No disk image in memory");
    return;
    }
/* get a file name */
  if (!getfilen(fn,65)) return;
  critical_err=0;
/* check if the file already exists */
  if (!access(fn,0))
    {
    if (prompt("\aFile exists. Overwrite? (Y/N)"
               ,"NY",TEXTCOLOR)<=0)
      return;
    }
/* if checking for the file caused a critical error,
   don't even try to open the file */
  if (!critical_err) f=fopen(fn,"wb");

/* if the file can't be opened (or wasn't because of
   a critical error, forget it */
  if (!f)
    {
    advise("Can't open file for writing");
    return;
    }

/* Get a title */
  if (ask("Title: ",NULL,TEXTCOLOR,64,fn,NULL)==-1) return;
/* only change title if new one was entered */
  if (*fn) strcpy(bufinfo.title,fn);
/* Turn the wait indicator on */
  wait_on();
  /* set dirty bit in image.
    copies/source/csum are meaningless */
  bufinfo.dirty=1;
/* write signature */
  putw('C386',f);
/* write size of bufinfo */
  putw(sizeof(struct _bufinfo),f);
/* write bufinfo */
  fwrite(&bufinfo,1,sizeof(struct _bufinfo),f);

/***************************************
 * write entire buffer in one swoop    *
 * This is a BIG advantage of a 32-bit *
 * extender!.                          *
 ***************************************/
  cnt1=fwrite(diskbuf,1,bufinfo.size,f);
/* one | is deliberate here -- we always want to fclose */
  if (ferror(f)|fclose(f)|(cnt1!=bufinfo.size))
    advise("\aError writing to file");
  else
    bufinfo.dirty=0;
  wait_off();
  }

/* routine to actually load file to disk image */
loadit()
  {
  char fn[66];
  FILE *f;
  int cnt,cnt1;
/* if buffer is full, confirm */
  if (!dirtyquery()) return;
/* get file name */
  if (!getfilen(fn,65)) return;
/* open it */
  f=fopen(fn,"rb");
/* can't open it, forget it */
  if (!f)
    {
    advise("Can't open file");
    return;
    }
/* Turn wait indicator on */
  wait_on();
/* check file type */
  cnt=getw(f);
  if (cnt!='C386')
    {
    advise("Not a C386 image file");
    return;
    }
/* get size of bufinfo structure */
  cnt=getw(f);
/* new versions of C386 can't make bufinfo smaller, only
   larger at the end */
  fread(&bufinfo,1,cnt,f);
/* kill old image */
  if (diskbuf) free(diskbuf);
/* allocate new image based on size */
  diskbuf=malloc(bufinfo.size);
  if (!diskbuf)
    {
    advise("Insufficient memory");
    cleanup();
    fclose(f);
    return;
    }


/***************************************
 * read entire buffer in one swoop     *
 * This is a BIG advantage of a 32-bit *
 * extender!.                          *
 ***************************************/
  cnt1=fread(diskbuf,1,bufinfo.size,f);
/* one | is deliberate here also (see saveit(), above */
  if (ferror(f)|fclose(f)|(cnt1!=bufinfo.size))
    {
    advise("Error reading file");
    cleanup();
    return;
    }
  checksum();
  strcpy(bufinfo.source,fn);
  bufinfo.copies=0;
  wait_off();
  }

