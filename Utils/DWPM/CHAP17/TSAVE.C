/* TSAVE.C   Save DLL for TURTLE.EXE
  These functions link with DLLSTART.ASM to form TSAVE.DLL.
  See MAKEFILE for complete compile instructions.

*/

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "xci.h"
#include "turtle.h"

#define EXPORT _far _loadds _export

/* locate which buffer number is indicated. 0-9 is user
   buffer.
   buffer 10 is the screen. fn gets the file name from the
   command line */
getbuf(char *line,char **fn)
  {
  char *fnn,*buf;
  int bufno;
  bufno=11;        /* default to screen (11-1=10) */
/* read file name */
  fnn=strtok(line," \t");
  if (!fnn) { printf("Syntax error\n"); return -1; }
/* get buffer # (maybe) */
  buf=strtok(NULL," \t");
/* Call getval() in TCMDS.C (imported) to read number */
  if (buf) if (getval(buf,0,1,10,&bufno)) return -1;
  *fn=fnn;
  return --bufno;
  }


/* save buffer to file */
XCICMD EXPORT save(int cmd, char far *cmds,
                   struct udata *data)
  {
  FILE *f;
  char *fn;
  int bufno,i;
  if (cmd)
    {
    printf("Save the screen (or buffer) to disk\n");
    if (cmd==1)
      printf("Usage: save filename [buffer]\n");
    return;
    }
/* get arguments */
  bufno=getbuf(cmds,&fn);
  if (bufno==-1) return;
/* if in text mode, get screen from buffer
   if in graphics mode, get screen directly from screen */
  if (bufno==10) bufno+=data->textgraph;
/* insure buffer not empty */
  if (!data->store[bufno])
    {
    printf("Buffer %d is empty\n",bufno+1);
    return;
    }
/* open file for writing -- same as DOS program */
  f=fopen(fn,"wb");
/* write in one chunk */
  if (fwrite(data->store[bufno],(unsigned)SCREEN_SIZE,1,f)!=1)
     {
     printf("Error writing to file\n");
     }
  if (fclose(f)) printf("Can't close file\n");
  }

/* load command in */
XCICMD EXPORT load(int cmd, char far *cmds,
                   struct udata *data)
  {
  int bufno;
  FILE *f;
  char *fn;
  if (cmd)
    {
    printf("Load the screen (or buffer) from disk\n");
    if (cmd==1)
      printf("Usage: load filename [buffer]\n");
    return;
    }
/* call getbuf to interpret arguments */
  bufno=getbuf(cmds,&fn);
  if (bufno==-1) return;
/* if in text mode, get screen from buffer
   if in graphics mode, get screen directly from screen */
  if (bufno==10) bufno+=data->textgraph;
/* if buffer empty allocate space for it */
  if (!data->store[bufno])
    {
    if (!(data->store[bufno]=malloc((unsigned)SCREEN_SIZE)))
      {
      printf("Out of memory",bufno+1);
      return;
      }
    }
/* read buffer in one big chunk */
  f=fopen(fn,"rb");
  if (fread(data->store[bufno],(unsigned)SCREEN_SIZE,1,f)!=1)
     {
     printf("Error reading file\n");
     }
  fclose(f);
  }


/* Init DLL so we can use C library  -- Microsoft only */
unsigned far pascal _loadds dllstart()
  {
#ifndef __BORLANDC__
  extern void far pascal C_INIT(void);
  C_INIT();
#endif
  return 1;
  }
