/* DISKIO.C Whole disk I/O routines for CB386 */

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <dos.h>
#include "cb386.h"
#include "display.h"

/* Simple call to make a harmless DOS function run so DOS
   can check for ^Break. Since the routines in this module
   don't call DOS, this is important -- without it break
   goes undetected. If BREAK=OFF this wouldn't work, so
   CB386.C sets BREAK ON and restores it before the
   program exits. */

check_break()
   {
   union REGS r;
   r.x.ax=0x3500;  /* Read int vector -- quick call  */
   int86(0x21,&r,&r);
   }

try13(int try,int cmd,int count,int head,int drive,int track,
      int sector,unsigned dosbuf)
  {
  union REGS r;
/* do operation up to try times */
  while (try--)
    {
    r.h.ah=cmd;
    r.h.al=count;
    r.h.dh=head;
    r.h.dl=drive;
    r.h.ch=track;
    r.h.cl=sector;
    r.x.bx=(unsigned)dosbuf;
    int86(0x13,&r,&r);
/* if error... */
    if (r.x.cflag)
       {
/* if not last try */
       if (try)
         {
/* reset drive and try again */
         r.x.ax=0;
         r.h.dl=drive;
         int86(0x13,&r,&r);
         }
/* continue on all errors */
       continue;
       }
    /* no error */
    break;
    }
  return r.x.cflag;
  }



/* The BIOS read/write routines use a DOS buffer since
   codebuilder does not transparently move data for these
   BIOS interrupts */

/* read count number of sectors via the BIOS
   returns 0 for success */
sector_read(int head,int track, int sector, int drive,
            unsigned char *buf,unsigned count)
   {
   union REGS r;
/* if no dos buffer then allocate one large enough for
   one track */
   check_break();
   if (!dosbuf)
     {
     r.h.ah=0x48;
     dosbufsiz=r.x.bx=bpb.bytespersec*bpb.secpertrack;
     int86(0x21,&r,&r);
     if (r.x.cflag)
       {
       advise("Not enough DOS memory");
       return 1;
       }
     dosbuf=(char *)r.x.ax;
     }

   if (try13(NRTRIES,2,count,head,drive,track,sector,
         (unsigned)dosbuf)) return 1;
     memcpy(buf,dosbuf,bpb.bytespersec*count);
     return 0;
   }

/* Read BIOS parameter block */
read_bpb(int driveno)
  {
  /* read BPB from specified drive */
  bpb.bytespersec=512;  /* default */
  bpb.secpertrack=1;
  if (sector_read(0,0,1,driveno,(unsigned char *)&bpb,1))
    return 0;
  return 1;
  }


/* read entire disk */
read_disk(int drive)
  {
  unsigned i,trk=0,head=0;
  unsigned char *diskp;
/* erase existing image, if any */
  if (diskbuf) free(diskbuf);
/* set up buffer info */
  strcpy(bufinfo.title,"<NONE>");
  bufinfo.source[0]=toupper(drive);
  driveno=bufinfo.source[0]-'A';
  bufinfo.source[1]=':';
  bufinfo.source[2]='\0';
  dosbuf_free();
/* turn on wait indicator on screen */
  wait_on();
  if (!read_bpb(driveno))
    {
    advise("Can't read bpb");
    return 0;
    }
  if (dosbuf) dosbuf_free();
  head=0;
  /* determine size of disk */
  bufinfo.size=disksize=
     (sectorct=bpb.nrsectors?bpb.nrsectors:
       bpb.hugesectors)
       *bpb.bytespersec;
  /* allocate space */
  diskbuf=(unsigned char *)malloc(disksize);
  if (!diskbuf)
    {
    advise("Not enough free memory");
    return 0;
    }
  /* read entire disk */
  diskp=diskbuf;
  goxy(0,12);
  histogram(-1,60);
  curshide();
  for (i=0;i<sectorct;i+=bpb.secpertrack)
    {
    histogram(i,sectorct);
    if (sector_read(head,trk,1,driveno,diskp,
                    bpb.secpertrack))
        {
        char errbuf[80];
        sprintf(errbuf,"\aWarning: bad sector at %u:%u\n",
                head,trk);
        if (advise(errbuf)==-1)
          {
          cleanup();  /* kill incomplete buffer */
          return 0;
          }
        }
    diskp+=bpb.bytespersec*bpb.secpertrack;
    if (++head>=bpb.nrheads)
        {
        head=0;
        trk++;
        }
    }
  bufinfo.dirty=1;
  histogram(i,i);
  bufinfo.csum=checksum();
  wait_off();
  return 1;
  }

/* free dos buffer */
dosbuf_free()
  {
  union REGS r;
  if (!dosbuf) return;
  r.h.ah=0x49;
  r.x.dx=(unsigned int)dosbuf;
  int86(0x21,&r,&r);
  if (r.x.cflag)
    advise("Memory allocation error");
  dosbuf=NULL;
  }


/* write count sectors via BIOS */
sector_write(int head,int track, int sector, int drive,
             unsigned char *buf,unsigned count)
   {
   union REGS r;
   check_break();
/* If no dos buffer, allocate one */
   if (dosbufsiz<bpb.bytespersec*bpb.secpertrack)
     dosbuf_free();
   if (!dosbuf)
     {
     r.h.ah=0x48;
     dosbufsiz=r.x.bx=bpb.bytespersec*bpb.secpertrack;
     int86(0x21,&r,&r);
     if (r.x.cflag)
       {
       advise("Not enough DOS memory");
       return;
       }
     dosbuf=(char *)r.x.ax;
     }
/* copy data to dosbuffer */
   memcpy(dosbuf,buf,bpb.bytespersec*count);
/* retry up to try times */
   return try13(NRTRIES,3,count,head,drive,track,sector,
         (unsigned)dosbuf);
   }

/* write entire disk */
write_disk(int drive)
  {
  int fmt=0;
  unsigned i,trk=0,head=0;
  unsigned char *diskp;
  drive=toupper(drive)-'A';
/* turn on wait indicator */
  wait_on();
  goxy(0,12);
  histogram(-1,60);
  curshide();
  head=0;
  diskp=diskbuf;
  if (!read_bpb(drive))
    {
    format(drive);
    if (!read_bpb(drive))
      {
      advise("Can't read BPB");
      return 0;
      }
    }
  sectorct=bpb.nrsectors?bpb.nrsectors:
       bpb.hugesectors;
  if (bufinfo.size!=sectorct*bpb.bytespersec)
    {
    advise("Incorrect disk size");
    return 0;
    }
/* write entire disk a track at a time */
  for (i=0;i<sectorct;i+=bpb.secpertrack)
    {
    histogram(i,sectorct);
    if (sector_write(head,trk,1,drive,diskp,
                     bpb.secpertrack))
       {
       advise("Write error");
       return 0;
       }
    diskp+=bpb.bytespersec*bpb.secpertrack;
    if (++head>=bpb.nrheads)
        {
        head=0;
        trk++;
        }
    }
  histogram(i,i);
  bufinfo.dirty=0;
  wait_off();
  return 1;
  }
