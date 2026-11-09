#define DISKDEV_C

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <dir.h>
#include <mem.h>
#include <fcntl.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "control.h"
#include "config.h"
#include "message.h"
#include "diskdev.h"
#include "function.h"
#include "dbm.h"
int G_inerrhand=0;
#define _HARDERR_RETRY 1
/*   These dummy routines are for sysdoc
// macro for dis_control
int DCONTROL(int type,...)
{
    dis_control(type);
}

// macro for dis_input
int DINPUT(void)
{
    dis_input();
}
// macro for dis_output
int DOUTPUT(int x,int y,char *fmt,...)
{
    dis_output(x,y,fmt);
}

// macro for dis_reset
int DRESET(void)
{
    dis_reset();
}
*/

#pragma warn -par
// critical error handler
int handler(int err,int ax,int bp,int si)
{
    if (ax<0) hardretn(-1);
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'S',3);
    beep();
    sendmsg("OUTPUT1",'o',40-strlen(G_harderr),4,G_harderr);
    delay(500);
    beep();
    delay(500);
    beep();
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',40-strlen(G_harderr),4,"%*.*s",strlen(G_harderr),strlen(G_harderr),"");
    sendmsg("OUTPUT1",'S',1);
    hardretn(-1);

    hardresume(_HARDERR_RETRY);
    return(_HARDERR_RETRY);
}
#pragma warn +par

// true if the disk has been changed
int diskchanged(void)
{
    union REGS r;

    r.x.ax=0x1600;
    r.x.dx=0;
    int86(0x13,&r,&r);
    if (r.x.cflag) return(1);
    return(0);
}
// read the disk data
int readdd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    int timeout=0;
    while (timeout<10) {
        timeout++;
        r.x.ax=0x0201;
        r.x.bx=FP_OFF(buf);
        r.x.cx=1;
        r.x.dx=0;
        sr.es=FP_SEG(buf);
        int86x(0x13,&r,&r,&sr);
        if (r.x.cflag==0) timeout=20;
        if ((timeout!=20)&&(G_inerrhand)) return(0);
    }
    if (timeout==20) return(1);
    return(0);
}
// write the disk data
int writedd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    int timeout=0;
    while (timeout<10) {
        timeout++;
        r.x.ax=0x0301;
        r.x.bx=FP_OFF(buf);
        r.x.cx=1;
        r.x.dx=0;
        sr.es=FP_SEG(buf);
        int86x(0x13,&r,&r,&sr);
        if (r.x.cflag==0) timeout=20;
    }
    if (timeout==20) return(1);
    return(0);
}
// get the disk data information
int getdinfo(void)
{
    if (readdd(&G_diskinfo)) return(0);
    if (calccheck()!=G_diskinfo.check) return(0);
    G_ddread=1;
    return(1);
}
// put the disk data information
int putdinfo(int rawput)
{
    if ((!(rawput))&&(calccheck()!=G_diskinfo.check)) return(0);
    if (writedd(&G_diskinfo)) return(0);
    return(1);
}
// check the disk data information
int checkdinfo(void)
{
    if (readdd(&G_chekinfo)) return(0);
    if (memcmp(&G_diskinfo,&G_chekinfo,512)) return(0);
    return(1);
}
// set the disk password information
void setpass(char *p)
{
    int i=0;
    char tmp[5];
    sprintf(tmp,"%4.4s",p);
    for (i=0;i<5;i++) G_diskinfo.pass[i]=tmp[i]^(0x55<<i);
}
// get the disk password information
void getpasswd(char *p)
{
    int i=0;
    char tmp[5];
    for (i=0;i<5;i++) tmp[i]=G_diskinfo.pass[i]^(0x55<<i);
    for (i=0;i<5;i++) if (tmp[i]!=' ') p[i]=tmp[i]; else p[i]=0;
}
// calculate the checksum for the disk data information
unsigned char calccheck(void)
{
    unsigned char *s,*e,ret;

    s=(unsigned char *)&(G_diskinfo.id);
    e=(unsigned char *)&(G_diskinfo.check);
    ret=*s;
    while (s<e) ret-=*(s++);

    return(ret);
}
// set the disk data information
int setdinfo(char type,void *data)
{
    switch (type) {
        case DISKID    :
            G_diskinfo.id=*((unsigned int *)data);
            break;
        case USERID    :
            G_diskinfo.user=*((unsigned char *)data);
            break;
        case USERNAME  :
            strcpy(G_diskinfo.username,((unsigned char *)data));
            break;
        case ACCESS    :
            G_diskinfo.access=*((unsigned char *)data);
            break;
        case PASSWORD  :
            setpass((char *)data);
            break;
        case POSITION  :
            G_diskinfo.pos=*((unsigned char *)data);
            break;
        case BACKEDUP  :
            G_diskinfo.backed=*((unsigned char *)data);
            break;
        case CONSOLID  :
            G_diskinfo.consol=*((unsigned char *)data);
            break;
        case NEWEXE    :
            G_diskinfo.newexe=*((unsigned char *)data);
            createcrcfile(G_backup,NEWEXEF);
            G_diskinfo.exechk=crcchk(G_backup,NEWEXEF);
            break;
        case NEWCFG    :
            G_diskinfo.newcfg=*((unsigned char *)data);
            createcrcfile(G_backup,NEWCFGF);
            G_diskinfo.cfgchk=crcchk(G_backup,NEWCFGF);
            break;
        case NEWOFF    :
            G_diskinfo.newoff=*((unsigned char *)data);
            createcrcfile(G_backup,NEWOFFF);
            G_diskinfo.offchk=crcchk(G_backup,NEWOFFF);
            break;
        case NEWSYS    :
            G_diskinfo.newsys=*((unsigned char *)data);
            createcrcfile(G_backup,NEWSYSF);
            G_diskinfo.syschk=crcchk(G_backup,NEWSYSF);
            break;
        case NEWDAT    :
            G_diskinfo.newdat=*((unsigned char *)data);
            createcrcfile(G_backup,NEWDATF);
            G_diskinfo.datchk=crcchk(G_backup,NEWDATF);
            break;
        case MERGETYPE :
            G_diskinfo.merge=*((unsigned char *)data);
            break;
        default :
            return(0);
    }
    G_diskinfo.check=calccheck();
    return(1);
}
// creat a crc file
void createcrcfile(char *path,char *name)
{
    int fd;
    char file[80];
    char tmp[80];

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) return;
    strcpy(tmp,datestr(0));
    write(fd,tmp,strlen(tmp));
    close(fd);
}
//------------------------------------------------------------------------/
//                  SEMAPHORE FUNCTIONS
// open a semaphore file
int opensem(char *path,char *name)
{
    char file[80];
    sprintf(file,"%s%s",path,name);
    G_semfd=open(file,O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (G_semfd==(-1)) return(0);
    return(1);
}
// close a semaphore file
void closesem(void)
{
    close(G_semfd);
}
// update a semaphore file
int updatesem(char *tabname,char state)
{
    int s;
    int i;
    unsigned char flag;

    if (!G_semnet) return(1);

    flag=0xAA*state;
    s=snum(tabname);
    if (s<0) return(0);
    if (!opensem(G_netpath,"SEM.NET")) return(0);
    for (i=0;i<32;i++) {
        if (i!=G_position) {
            if (lseek(G_semfd,s+i*20,SEEK_SET)!=s) {
                closesem();
                return(0);
            }
            if (write(G_semfd,&flag,1)!=1) {
                closesem();
                return(0);
            }
        }
    }
    closesem();
    return(1);
}
// get a semaphore file status
int semstate(char *tabname)
{
    unsigned char state;
    int s;

    if (!G_semnet) return(0);

    s=snum(tabname);
    if (s<0) return(-1);
    if (!opensem(G_netpath,"SEM.NET")) return(-1);
    if (lseek(G_semfd,s+G_position*20,SEEK_SET)!=s) {
        closesem();
        return(-1);
    }
    if (read(G_semfd,&state,1)!=1) {
        closesem();
        return(-1);
    }
    closesem();
    return(state==0xAA);
}

// compare the dates of two files
int datechk(char *path,char *bpath,char *name)
{
    int fd;
    char file[80];
    unsigned long a,b;
    unsigned int d,t;
    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    _dos_getftime(fd,&d,&t);
    close(fd);
    sendmsg("OUTPUT1",'o',0,0,"%04X %04X",d,t);
    a=(long)d<<16|t;
    sprintf(file,"%s%s",bpath,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    _dos_getftime(fd,&d,&t);
    sendmsg("OUTPUT1",'o',0,0,"%04X %04X",d,t);
    close(fd);
    b=(long)d<<16|t;
    if (b>a) return(1);
    return(0);
}
// check the CRC of a file
unsigned int crcchk(char *path,char *name)
{
    int fd;
    char file[80];
    unsigned int buf,ret;

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    while (read(fd,&buf,sizeof(unsigned int))==sizeof(unsigned int)) {
        ret^=buf;
        ret++;
    }
    close(fd);
    return(ret);
}
// return the disk data information
int retdinfo(char type,void *data)
{
    if (!G_ddread||diskchanged()) if (!readdd(&G_diskinfo)) return(0);
    if (G_diskinfo.check!=calccheck()) return(0);
    switch (type) {
        case DISKID    :
            *((unsigned int *)data)=G_diskinfo.id;
            break;
        case USERID    :
            *((unsigned char *)data)=G_diskinfo.user;
            break;
        case USERNAME  :
            strcpy(((unsigned char *)data),G_diskinfo.username);
            break;
        case ACCESS    :
            *((unsigned char *)data)=G_diskinfo.access;
            break;
        case PASSWORD  :
            getpasswd((char *)data);
            break;
        case POSITION  :
            *((unsigned char *)data)=G_diskinfo.pos;
            break;
        case BACKEDUP  :
            *((unsigned char *)data)=G_diskinfo.backed;
            break;
        case CONSOLID  :
            *((unsigned char *)data)=G_diskinfo.consol;
            break;
        case NEWEXE    :
            if (crcchk(G_database,NEWEXEF)==G_diskinfo.exechk) 
                *((unsigned char *)data)=0;
            else 
                *((unsigned char *)data)=G_diskinfo.newexe;
            break;
        case NEWCFG    :
            if (crcchk(G_database,NEWCFGF)==G_diskinfo.cfgchk) 
                *((unsigned char *)data)=0;
            else 
                *((unsigned char *)data)=G_diskinfo.newcfg;
            break;
        case NEWOFF    :
            if (crcchk(G_database,NEWOFFF)==G_diskinfo.offchk) 
                *((unsigned char *)data)=0;
            else 
                *((unsigned char *)data)=G_diskinfo.newoff;
            break;
        case NEWSYS    :
            if (crcchk(G_database,NEWSYSF)==G_diskinfo.syschk) 
                *((unsigned char *)data)=0;
            else 
                *((unsigned char *)data)=G_diskinfo.newsys;
            break;
        case NEWDAT    :
            if (crcchk(G_database,NEWDATF)==G_diskinfo.datchk) 
                *((unsigned char *)data)=0;
            else 
                *((unsigned char *)data)=G_diskinfo.newdat;
            break;
        case MERGETYPE :
            *((unsigned char *)data)=G_diskinfo.merge;
            break;
        default :
            return(0);
    }
    return(1);
}
// setup new disk data information
int newdd(void)
{
    unsigned char *s,*e;

    memcpy(&G_diskinfo,G_bootsec,512);
    strcpy(G_diskinfo.name,DISKNAME);
    strcpy(G_diskinfo.prompt,DISKPROMPT);
    G_ddread=1;
    return(1);
}
// find files from wild cards *.??? etc.
int findfile(char *path,char *name)
{
    struct ffblk f;
    char tmp[80];
    int done=0;

    G_numfd=0;
    sprintf(tmp,"%s%s",path,name);
    if ((done=findfirst(tmp,&f,FILEATTR))==(-1)) return(0);
    while ((done!=(-1))&&(G_numfd<100)) {
        strcpy(G_filesfd[G_numfd],f.ff_name);
        G_numfd++;
        done=findnext(&f);
    }
    return(1);
}
// copy file(s) function 
int copyfile(char *s,char *sp,char *dp)
{
    int fi,fo,i;
    int nb;
    char *buf;
    char source[80];
    char dest[80];
    
    stcloseall();
    harderr(handler);

    if (!findfile(sp,s)) return(0);

    buf=MALLOC(32760);
    if (buf==NULL) return(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i]);
        sprintf(dest,"%s%s",dp,G_filesfd[i]);
        fi=open(source,O_RDONLY|O_BINARY);
        if (fi!=(-1)) {
            fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (fo!=(-1)) {
                while ((nb=read(fi,buf,32760))>0) {
                    if (write(fo,buf,nb)!=nb) {
                        FREE(buf);
                        close(fi);
                        close(fo);
                        return(0);
                    }
                }
                close(fo);
            }
            else {
                FREE(buf);
                close(fi);
                close(fo);
                return(0);
            }
            close(fi);
        }
        else {
            FREE(buf);
            return(0);
        }
    }
    FREE(buf);
    return(1);
}
// delete file(s) function 
int delfile(char *s,char *sp)
{
    int i;
    char source[80];
    
    stcloseall();
    harderr(handler);

    if (!findfile(sp,s)) return(1);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i]);
        unlink(source);
    }
    return(1);
}
// generate a * file
int genufile(char *sp,char *s,int saverest)
{
    int fi,fo,i;
    int nb;
    char *buf;
    char tmp[15];
    char source[80];
    char dest[80];
    
    stcloseall();
    harderr(handler);


    if (saverest==1) {
        strcpy(tmp,s);
        tmp[0]=(G_uid/10)+'0';
        tmp[1]=(G_uid%10)+'0';
        if (!findfile(sp,tmp)) return(0);
    }
    else {
        if (!findfile(sp,s)) return(0);
    }

    buf=MALLOC(32760);
    if (buf==NULL) return(0);

    for (i=0;i<G_numfd;i++) {
        strcpy(tmp,G_filesfd[i]);

        switch (saverest) {
            case 0 :
                tmp[0]=(G_uid/10)+'0';
                tmp[1]=(G_uid%10)+'0';
                break;
            case 1 :
                tmp[0]='T';
                tmp[1]='R';
                break;
            case 2 :
                tmp[0]='~';
                break;
        }
        sprintf(source,"%s%s",sp,G_filesfd[i]);
        sprintf(dest,"%s%s",sp,tmp);
        fi=open(source,O_RDONLY|O_BINARY);
        if (fi!=(-1)) {
            fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (fo!=(-1)) {
                while ((nb=read(fi,buf,32760))>0) {
                    if (write(fo,buf,nb)!=nb) {
                        FREE(buf);
                        close(fi);
                        close(fo);
                        return(0);
                    }
                }
                close(fo);
            }
            else {
                FREE(buf);
                close(fi);
                close(fo);
                return(0);
            }
            close(fi);
        }
        else {
            FREE(buf);
            return(0);
        }
    }
    FREE(buf);

    for (i=0;i<G_numfd;i++) {
        strcpy(tmp,G_filesfd[i]);
        sprintf(source,"%s%s",sp,tmp);
        unlink(source);
    }
    return(1);
}
// format disk "BACKUP"
int formatdisk(char *name)
{
    FILE *fp;
    int fd,i;
    char fmtline[80];
    char drv[20];
    static char comp[]="Format complete.";
    int err=0;

    if ((fp=fopen("~YES.YES","w"))==NULL) return(0);
    fprintf(fp,"\n\n\nN\n");
    fclose(fp);

    strcpy(drv,name);
    drv[2]=0;

    sprintf(fmtline,"format %s < ~YES.YES > ~FORMAT.DAT",drv);
    fclose(stderr);
    fopen("~STDERR.DAT","w");
    system(fmtline);
    unlink("~YES.YES");
    fclose(stderr);
    unlink("~STDERR.DAT");

    fd=open("~FORMAT.DAT",O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    err=0;
    i=0;
    while (read(fd,fmtline,1)==1) {
        if (fmtline[0]==comp[i]) i++; else i=0;
        if (i==15) {
            err=1;
            break;
        }
    }
    close(fd);
    unlink("~FORMAT.DAT");

    return(err);
}
// disk reset routine
int dis_reset(void)
{
    return(1);
} 
// disk input routine
int dis_input(void)
{
    return(1);
} 
// disk output routine
int dis_output(void)
{
    return(1);                 
}
// disk control routine
int dis_control(int type,...)
{
    va_list ap;
    int retval=0,i;
    unsigned long l;
    unsigned char c,dtype;
    unsigned char *p;
    unsigned char *s;

    harderr(handler);
    va_start(ap,type);
    switch (type) {
        case 'C' :
            p=va_arg(ap,char *);
            s=va_arg(ap,char *);
            retval=copyfile(p,s,va_arg(ap,char *));
            break;

        case 'U' :
            p=va_arg(ap,char *);
            s=va_arg(ap,char *);
            retval=genufile(p,s,va_arg(ap,int));
            break;

        case 'D' :
            p=va_arg(ap,char *);
            retval=delfile(p,va_arg(ap,char *));
            break;

        case 'T' :
            p=va_arg(ap,char *);
            retval=findfile(p,va_arg(ap,char *));
            break;

        case 'S' :
            dtype=va_arg(ap,char);
            retval=setdinfo(dtype,va_arg(ap,void *));
            break;

        case 'G' :
            dtype=va_arg(ap,char);
            retval=retdinfo(dtype,va_arg(ap,void *));
            break;

        case 'F' :
            retval=formatdisk(va_arg(ap,char *));
            break;

        case 'P' :
            i=va_arg(ap,int);
            retval=putdinfo(i);
            break;

        case 'R' :
            retval=getdinfo();
            break;

        case 'N' :
            retval=newdd();
            break;

        case 'I' :
            G_ddread=0;
            retval=1;
            break;

        case 'E' :
            retval=1;
            break;

        case 'd' :
            p=va_arg(ap,char *);
            s=va_arg(ap,char *);
            retval=datechk(p,s,va_arg(ap,char *));
            break;
    }
    va_end(ap);
    return(retval);
} 
