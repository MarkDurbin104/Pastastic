#include "dfit.h"
#include <malloc.h>

/* EMS variables */
static init=1;
static int ems_handle=0;
static long lastpg=0L;
char far *page_frame;
union REGS r;

void ems_call(union REGS *);
void ems_err(int,int);
void ems_init(void);

/* terminate EMS processing */
void ems_close(void)
  {
  /* free EMS handle */
  if (ems_handle)
    {
    r.h.ah=0x45;
    r.x.dx=ems_handle;
    ems_call(&r);
    }
  }

/* generic EMS call */
void ems_call(union REGS *r)
  {
  int cmd=r->h.ah;
  int86(0x67,r,r);
  if (r->h.ah) ems_err(cmd,r->h.ah);
  }

/* start EMS transaction */
void ems_init()
  {
  FILE *driver;
  init=0;
  /* check for EMS */
  driver=fopen("EMMXXXX0","r");
  if (!driver) ems_err(0,0);
  fclose(driver);
/* get EMS status */
  r.h.ah=0x40;
  ems_call(&r);
/* get version # */
  r.h.ah=0x46;
  ems_call(&r);
/* must have EMS 4.0 */
  if (r.h.al<0x40)
    {
    printf("EMS 4.0 or better required.\n");
    exit(9);
    }
  /* get & store page frame address */
  r.h.ah=0x41;
  ems_call(&r);
  FP_SEG(page_frame)=r.x.bx;
  FP_OFF(page_frame)=0;
  /* register ems_close */
  atexit(ems_close);
  }


/* map siz bytes starting at page into page frame */
void ems_map(int page,unsigned siz)
  {
  int i;
  unsigned total=0;
  /* map 4 consecutive pages into pfa */
  for (i=0;i<4;i++)
    {
/* don't go past size request */
    if (total>=siz) break;
    r.h.ah=0x44;
    r.h.al=i;
    r.x.bx=page+i;
    r.x.dx=ems_handle;
    ems_call(&r);
    total+=16384;
    }
  }

/* print EMS error message */
void ems_err(int cmd,int code)
  {
  printf("EMS error #%x(%x)\n",cmd,code);
  exit(10);
  }

/* allocate EMS pages */
long ems_alloc(unsigned long siz)
  {
  long pg=lastpg,pgs;
/* calculate # of pages required */
  pgs=(siz+16383)/16384;
/* init handle if req'd */
  if (!ems_handle)
    {
    r.x.ax=0x5a00;
    r.x.bx=0;
    ems_call(&r);
    ems_handle=r.x.dx;
    }
/* reallocate to contain required # of pages */
  lastpg+=pgs;
  r.h.ah=0x51;
  r.x.bx=lastpg;
  r.x.dx=ems_handle;
  ems_call(&r);
  return pg;
  }


struct file_entry read_file(char *path,char *name,
       unsigned long siz)
  {
  unsigned bufp=0;
  int handle;
  struct file_entry ret;
/* start up EMS routines */
  if (init) ems_init();
/* make room for new entry */
  if (maxfiles<nrfiles+1)
    {
    if (!files)
      {
      files=(struct file_entry *)
            malloc(sizeof(struct file_entry)*10);
      }
    else
      {
      files=realloc(files,(maxfiles+10)*
                    sizeof(struct file_entry));
      }
    if (!files) errabt(0,"");
    maxfiles+=10;
    }
/* store info */
  strcpy(ret.name,name);
  ret.size=siz;
/* allocate space */
  ret.pageno=ems_alloc(siz);
/* open file */
  handle=open(path,O_RDONLY|O_BINARY);
  if (handle==-1) errabt(1,path);
/* read data in 64K (or less) chunks */
  while (siz)
    {
    unsigned long bsize=(siz<0x10000)?siz:0x10000;
/* map EMS chunk */
    ems_map(ret.pageno+bufp,(unsigned)bsize);
    if (bsize!=0x10000)
      {
      if (read(handle,page_frame,(unsigned)bsize)==-1)
         errabt(2,path);
      }
    else
      if (read(handle,page_frame,0xFFFE)==-1||
          read(handle,page_frame+0xFFFE,2)==-1)
            errabt(2,path);
    bufp+=4;
    siz-=bsize;
    }
  close(handle);
  files[nrfiles++]=ret;
  return ret;
  }

void write_files()
  {
  char fn[_MAX_PATH];
  int remaining=nrfiles,i;
  unsigned long dremaining,total_size=0L;
/* reset statistics */
  for (i=0;i<nrfiles;i++)
    {
    files[i].write=0;
    total_size+=files[i].size;
    }
/* assemble output file name prefix */
  fn[0]=drive;
  fn[1]=':';
  do
    {
    struct file_entry *max;
    printf("%lu bytes remaining\n",total_size);
    prompt("Insert disk in the destination drive "
           "and press <SPACE>"," ");
    dremaining=freebytes();
    do
      {
/* find largest file that will fit... */
      max=NULL;
      for (i=0;i<nrfiles;i++)
        {
/* skip file that has already been written */
        if (files[i].write) continue;
        if (!max&&files[i].size<=dremaining)
          max=files+i;
        else if (max&&files[i].size<=dremaining
                 &&files[i].size>max->size)
               max=files+i;
        }
/* if file found */
      if (max)
        {
        unsigned long siz=max->size;
        unsigned bufp=0;
        int handle;
/* make output file name */
        strcpy(fn+2,max->name);
/* open file */
        handle=open(fn,
                O_WRONLY|O_CREAT|O_BINARY|O_TRUNC,
                S_IWRITE|S_IREAD);
        if (handle==-1) errabt(1,fn);
/* write it in 64K (or less) chunks */
        printf("Writing %s\n",fn);
        while (siz)
          {
          unsigned long bsize=(siz<0x10000)?siz:0x10000;
/* map in EMS chunk */
          ems_map(max->pageno+bufp,(unsigned)bsize);
          if (bsize!=0x10000)
            {
            if (write(handle,page_frame,(unsigned)bsize)==-1)
              errabt(2,fn);
            }
          else
            if (write(handle,page_frame,0xFFFE)==-1||
                write(handle,page_frame+0xFFFE,2)==-1)
                  errabt(2,fn);
          bufp+=4;
          siz-=bsize;
          }
        close(handle);
/* update statistics */
        total_size-=max->size;
        remaining--;
        dremaining=freebytes();
        max->write=1;
        }
      } while (max);
    } while (remaining);
  }
