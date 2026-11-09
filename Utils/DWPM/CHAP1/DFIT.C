/* DFIT.C - Disk fit program
   Compile with:
-DOS-
Borland:   bcc -ml -DHUGE=_huge dfit.c dfitdos.c
Microsoft:   cl -AL -DHUGE=_huge -F 0F00 dfit.c dfitdos.c

-EMS-
Borland:   bcc -ml -DEMS dfit.c dfitems.c
Microsoft:   cl -AL -DEMS -F 0F00 dfit.c dfitems.c

-286-
Borland: bcc286 -DHUGE=_huge dfit.c dfitdos.c
Microsoft:
286|DOS Extender pre-2.5
   cl -AL -Lp -G2 -DHUGE=_huge -F F00
      dfit.c dfitdos.c llibpe.lib
286|DOS Extender 2.5 and later:
   cl -AL -Lp -G2 -DHUGE=_huge -F F00
      dfit.c dfitdos.c

-386-
Watcom: wcl386 -DHUGE= -ldos4g dfit.c dfit386.c
*/

#include "dfit.h"

/* info about files */
struct file_entry *files, read_file();

/* number of entries in files[] */
int nrfiles,maxfiles;

/* target drive */
char drive;

void main(int argc, char *argv[])
  {
  int i;
  if (argc<2) help();
  drive=toupper(argv[1][0]);
  if (drive<'A'||drive>'Z') help();
/* if no files on command line, prompt for them */
  if (argc==2)
    printf("Enter an empty line to begin copy\n");
  while (argc==2)
    {
    char fn[_MAX_PATH],*p;
    printf("File name or spec? ");
    fgets(fn,sizeof(fn),stdin);
    if (*fn=='\n') break;
    p=strchr(fn,'\n');
    if (p) *p='\0';
/* process them */
    proc_files(fn);
    }
/* if files on command line, process them */
  if (argc!=2)
    {
    for (i=2;i<argc;i++)
      proc_files(argv[i]);
    }

/* write the files out some indefinite number of times */
  do
    {
    write_files();
    } while (prompt("Write files again? (Y/N)","NY")=='Y');

  exit(0);
  }

/* Instructions for malformed command line */
void help()
  {
  printf("DFIT by Al Williams\n"
         "Usage: DFIT drive [file.....]\n"
         "Wildcards are allowed.\n");
  exit(1);
  }

/* compute free space on target disk */
unsigned long freebytes()
  {
  struct diskfree_t frees;
  _dos_getdiskfree(drive-'A'+1,&frees);
  return (unsigned long)frees.bytes_per_sector*
         frees.sectors_per_cluster*
         frees.avail_clusters;
  }

/* print prmt, wait for a key in valid -- shifts key
   to upper case */
int prompt(char *prmt,char *valid)
  {
  int c;
  printf("%s\n",prmt);
  do
    {
    c=getch();
    if (!c)
      {
      getch();
      continue;
      }
    c=toupper(c);
    } while (!strchr(valid,c));
  putchar(c);
  putchar('\n');
  return c;
  }


/* process files (maybe wildcards) */
proc_files(char *spec)
  {
  int n=0,stat;
  struct find_t info;
  char drive[_MAX_DRIVE],sub[_MAX_DIR],
       file[_MAX_FNAME],ext[_MAX_EXT];
/* spit file apart */
  _splitpath(spec,drive,sub,file,ext);
/* search for matching files */
  stat=_dos_findfirst(spec,_A_NORMAL,&info);
  while (!stat)
    {
/* found a file, rebuild complete name */
    char path[_MAX_PATH];
    char *ext=strchr(info.name,'.');
    if (ext) *ext='\0';
    _makepath(path,drive,sub,info.name,ext?ext+1:"");
    if (ext) *ext='.';
/* read file in */
    printf("Reading %s\n",path);
    read_file(path,info.name,info.size);
    n++;
    stat=_dos_findnext(&info);
    }
  return n;
  }


/* error messages */
static char *errfmt[]=
  {
  "Out of memory\n",
  "Can't open %s\n",
  "Read error on %s\n"
  "Write error on %s\n"
  };

/* error routine */
void errabt(int nr,char *string)
  {
  putchar('\n');
  printf(errfmt[nr],string);
  exit(nr+2);
  }
