#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <dos.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>

#ifndef HUGE
#ifndef EMS
#error Must define HUGE=_huge or HUGE= or EMS
#endif
#endif

/* info about files */
extern struct file_entry
  {
/* name of file -- no directory */
  char name[13];
/* size of file in bytes */
  unsigned long size;
#ifdef EMS
/* starting page number (EMS only) */
  int pageno;
#else
/* pointer to start of data -- non-EMS */
  char HUGE *data;
#endif
/* set to 1 when written out */
  char write;
  } *files, read_file();

/* number of entries/maximum entries in files[] */
extern int nrfiles,maxfiles;

/* target drive */
extern char drive;

struct file_entry read_file(char *path,char *name,
       unsigned long siz);
void write_files(void);
void help(void);
unsigned long freebytes(void);
int prompt(char *prmt,char *valid);
int proc_files(char *spec);
void errabt(int nr,char *string);
