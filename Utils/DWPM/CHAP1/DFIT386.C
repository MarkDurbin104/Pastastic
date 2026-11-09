#include "dfit.h"

struct file_entry read_file(char *path,char *name,
       unsigned long siz)
  {
  int handle;
  struct file_entry ret;
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
  ret.data=(char *)malloc(siz);
  if (!ret.data) errabt(0,"");
/* open file */
  handle=open(path,O_RDONLY|O_BINARY);
  if (handle==-1) errabt(1,path);
/* read data in one fell swoop */
  if (read(handle,ret.data,ret.size)==-1) errabt(2,path);
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
        int handle;
/* make output file name */
        strcpy(fn+2,max->name);
/* open file */
        handle=open(fn,
           O_WRONLY|O_CREAT|O_BINARY|O_TRUNC,
           S_IWRITE|S_IREAD);
        if (handle==-1) errabt(1,fn);
/* write file with one call */
        printf("Writing %s\n",fn);
        if (write(handle,max->data,max->size)==-1)
           errabt(3,fn);
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
