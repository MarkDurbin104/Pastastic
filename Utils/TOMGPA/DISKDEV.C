/****************************************************************************
* Project     : GPA
* File        : diskdev.c
* Description : disk device handler
* 
* $Revision:   1.3  $  $Date:   Nov 01 1995 15:14:58  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/diskdev.c_v  $
* 
*    Rev 1.3   Nov 01 1995 15:14:58   JGRAY
*  
* 
****************************************************************************/
#define DISKDEV_C

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <direct.h>
#include <memory.h>
#include <fcntl.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "gpasizes.h"
#include "types.h"
#include "control.h"
#include "config.h"
#include "message.h"
#include "function.h"
#include "formhand.h"
#include "dst.h"

#include "diskdev.h"
#include "pkware.h"


INT G_inerrhand=0;
INT G_zerr=0;
extern CHAR *G_workbuff;     // for use by the Pkware libraries
#define _HARDERR_FAIL 3

#pragma warn -par

//*************************************************************
//S critical error handler
//P integer error
//P integer register ax
//P integer register bp
//P integer register si
//R integer error code

INT handler(INT err,INT ax,INT bp,INT si)
{
    G_inerrhand=1;
//    hardresume(_HARDERR_FAIL);
    return(_HARDERR_FAIL);
}
#pragma warn +par

#ifdef USINGDD

//*************************************************************
//S check disk changed status, true if the disk has been changed
//R BOOL TRUE if changed, FALSE if not

INT diskchanged(void)
{
    union REGS r;
    ENTRY(4570);

    r.x.ax=0x1600;
    r.x.dx=0;
    int86(0x13,&r,&r);
    if (r.x.cflag) RETURNV(1);
    RETURNV(0);
}

//*************************************************************
//S read the disk data
//P buffer for disk information
//R TRUE means timed out

INT readdd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    INT timeout=0;
    ENTRY(4580);
    while (timeout<10) {
        timeout++;
        r.x.ax=0x0201;
        r.x.bx=FP_OFF(buf);
        r.x.cx=1;
        r.x.dx=0;
        sr.es=FP_SEG(buf);
        int86x(0x13,&r,&r,&sr);
        if (r.x.cflag==0) timeout=20;
        if ((timeout!=20)&&(G_inerrhand)) RETURNV(0);
    }
    if (timeout==20) RETURNV(1);
    RETURNV(0);
}

//*************************************************************
//S write the disk data
//P buffer of disk information
//R TRUE timed out, FALSE ok

INT writedd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    INT timeout=0;
    ENTRY(4590);
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
    if (timeout==20) RETURNV(1);
    RETURNV(0);
}

//*************************************************************
//S get the disk data information
//R TRUE ok, FALSE=disk checksum

INT getdinfo(void)
{
    ENTRY(4600);
    if (readdd(&G_diskinfo)) RETURNV(0);
    if (calccheck()!=G_diskinfo.check) RETURNV(0);
    G_ddread=1;
    RETURNV(1);
}

//*************************************************************
//S put the disk data information
//P integer BOOL TRUE forces write even if checksum failed
//R write fail or check fail FALSE, TRUE for Ok

INT putdinfo(INT rawput)
{
    ENTRY(4610);
    if ((!(rawput))&&(calccheck()!=G_diskinfo.check)) RETURNV(0);
    if (writedd(&G_diskinfo)) RETURNV(0);
    RETURNV(1);
}
//*************************************************************
//S check the disk data information
//R TRUE for OK, FALSE for check fail

INT checkdinfo(void)
{
    ENTRY(4620);
    if (readdd(&G_chekinfo)) RETURNV(0);
    if (memcmp(&G_diskinfo,&G_chekinfo,512)) RETURNV(0);
    RETURNV(1);
}

//*************************************************************
//S set the disk password information
//P char ptr password

void setpass(CHAR *p)
{
    INT i=0;
    CHAR tmp[5];
    ENTRY(4630);
    sprintf(tmp,"%4.4s",p);
    for (i=0;i<5;i++) G_diskinfo.pass[i]=tmp[i]^(0x55<<i);
    RETURN;
}

//*************************************************************
//S get the disk password information
//P char str place to put password

void getpasswd(CHAR *p)
{
    INT i=0;
    CHAR tmp[5];
    ENTRY(4640);
    for (i=0;i<5;i++) tmp[i]=G_diskinfo.pass[i]^(0x55<<i);
    for (i=0;i<5;i++) if (tmp[i]!=' ') p[i]=tmp[i]; else p[i]=0;
    RETURN;
}

//*************************************************************
//S calculate the checksum for the disk data information
//R U char checksum

UCHAR calccheck(void)
{
    UCHAR *s,*e,ret;
    ENTRY(4650);

    s=(UCHAR *)&(G_diskinfo.id);
    e=(UCHAR *)&(G_diskinfo.check);
    ret=*s;
    while (s<e) ret-=*(s++);

    RETURNV(ret);
}

//*************************************************************
//S set the disk data information
//P type of data
//P data
//R FALSE invalid type, TRUE Ok

INT setdinfo(CHAR type,void *data)
{
    ENTRY(4660);
    switch (type) {
        case DISKID    :
            G_diskinfo.id=*((UINT *)data);
            break;
        case USERID    :
            G_diskinfo.user=*((UCHAR *)data);
            break;
        case USERNAME  :
            strcpy(G_diskinfo.username,((UCHAR *)data));
            break;
        case ACCESS    :
            G_diskinfo.access=*((UCHAR *)data);
            break;
        case PASSWORD  :
            setpass((CHAR *)data);
            break;
        case POSITION  :
            G_diskinfo.pos=*((UCHAR *)data);
            break;
        case BACKEDUP  :
            G_diskinfo.backed=*((UCHAR *)data);
            break;
        case CONSOLID  :
            G_diskinfo.consol=*((UCHAR *)data);
            break;
        case NEWEXE    :
            G_diskinfo.newexe=*((UCHAR *)data);
            createcrcfile(G_backup,NEWEXEF);
            G_diskinfo.exechk=crcchk(G_backup,NEWEXEF);
            break;
        case NEWCFG    :
            G_diskinfo.newcfg=*((UCHAR *)data);
            createcrcfile(G_backup,NEWCFGF);
            G_diskinfo.cfgchk=crcchk(G_backup,NEWCFGF);
            break;
        case NEWOFF    :
            G_diskinfo.newoff=*((UCHAR *)data);
            createcrcfile(G_backup,NEWOFFF);
            G_diskinfo.offchk=crcchk(G_backup,NEWOFFF);
            break;
        case NEWSYS    :
            G_diskinfo.newsys=*((UCHAR *)data);
            createcrcfile(G_backup,NEWSYSF);
            G_diskinfo.syschk=crcchk(G_backup,NEWSYSF);
            break;
        case NEWDAT    :
            G_diskinfo.newdat=*((UCHAR *)data);
            createcrcfile(G_backup,NEWDATF);
            G_diskinfo.datchk=crcchk(G_backup,NEWDATF);
            break;
        case MERGETYPE :
            G_diskinfo.merge=*((UCHAR *)data);
            break;
        default :
            RETURNV(0);
    }
    G_diskinfo.check=calccheck();
    RETURNV(1);
}

//*************************************************************
//S create a crc file
//P char string path of crc file
//P char str name of crc file

void createcrcfile(CHAR *path, CHAR *name)
{
    INT fd;
    CHAR file[LENOFFULLFILEPATH];
    CHAR tmp[LENOFFULLFILEPATH];
    ENTRY(4670);

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) RETURN;
    strcpy(tmp,datestr(0));
    write(fd,tmp,strlen(tmp));
    close(fd);
    RETURN;
}

//*************************************************************
//                  SEMAPHORE FUNCTIONS
//*************************************************************

//*************************************************************
//S open a semaphore file
//P char string path
//P char string filename
//R FALSE failed, TRUE openned

INT opensem(CHAR *path,CHAR *name)
{
    CHAR file[LENOFFULLFILEPATH];
    ENTRY(4680);
    sprintf(file,"%s%s",path,name);
    G_semfd=open(file,O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (G_semfd==(-1)) RETURNV(0);
    RETURNV(1);
}

//*************************************************************
//S close a semaphore file

void closesem(void)
{
    ENTRY(4690);
    close(G_semfd);
    RETURN;
}

//*************************************************************
//S update a semaphore file
//P char * tab name
//P char state to set
//R TRUE if update Ok, FALSE if failed

INT updatesem(CHAR *tabname, CHAR state)
{
    INT s;
    INT i;
    UCHAR flag;
    ENTRY(4700);

    if (!G_semnet) RETURNV(1);

    flag=0xAA*state;
    s=snum(tabname);
    if (s<0) RETURNV(0);
    if (!opensem(G_netpath,SEMNET)) RETURNV(0);
    for (i=0;i<32;i++) {
        if (i!=G_position) {
            if (lseek(G_semfd,s+i*20,SEEK_SET)!=s) {
                closesem();
                RETURNV(0);
            }
            if (write(G_semfd,&flag,1)!=1) {
                closesem();
                RETURNV(0);
            }
        }
    }
    closesem();
    RETURNV(1);
}

//*************************************************************
//S get a semaphore status
//P char * tab name
//R -1 if access failed, Otherwise sem state is returned 

INT semstate(CHAR *tabname)
{
    UCHAR state;
    INT s;
    ENTRY(4710);

    if (!G_semnet) RETURNV(0);

    s=snum(tabname);
    if (s<0) RETURNV(-1);
    if (!opensem(G_netpath,SEMNET)) RETURNV(-1);
    if (lseek(G_semfd,s+G_position*20,SEEK_SET)!=s) {
        closesem();
        RETURNV(-1);
    }
    if (read(G_semfd,&state,1)!=1) {
        closesem();
        RETURNV(-1);
    }
    closesem();
    RETURNV(state==0xAA);
}

//**********************************************************
//                  SEMAPHORE FUNCTIONS - End
//**********************************************************

//**********************************************************
//S compare the dates of two files of the same name 
//P char str path A
//P char str path B
//P char str fiilename
//R TRUE if date on B is greater than date on A. FALSE for all others incl failure

INT datechk(CHAR *path,CHAR *bpath,CHAR *name)
{
    INT fd;
    CHAR file[LENOFFULLFILEPATH];
    ULONG a,b;
    UINT d,t;
    ENTRY(4720);
    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    _dos_getftime(fd,&d,&t);
    close(fd);
    a=(LONG)d<<16|t;
    sprintf(file,"%s%s",bpath,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    _dos_getftime(fd,&d,&t);
    close(fd);
    b=(LONG)d<<16|t;
    if (b>a) RETURNV(1);
    RETURNV(0);
}

//**********************************************************
//S check the CRC of a file
//P char str path
//P char str fiilename
//R 0 failed, otherwise 16 bit CRC of file

UINT crcchk(CHAR *path,CHAR *name)
{
    INT fd;
    CHAR file[LENOFFULLFILEPATH];
    UINT buf,ret;
    ENTRY(4730);

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    while (read(fd,&buf,sizeof(UINT))==sizeof(UINT)) {
        ret^=buf;
        ret++;
    }
    close(fd);
    RETURNV(ret);
}

//**********************************************************
//S RETURN the disk data information
//P char type of data expected
//P address of buffer to put data into
//R TRUE Ok, FALSE failed

INT mretdinfo(CHAR type,void *data)
{
    ENTRY(4740);
    if (!G_ddread||diskchanged()) if (!readdd(&G_diskinfo)) RETURNV(0);
    if (G_diskinfo.check!=calccheck()) RETURNV(0);
    switch (type) {
        case DISKID    :
            *((UINT *)data)=G_diskinfo.id;
            break;
        case USERID    :
            *((UCHAR *)data)=G_diskinfo.user;
            break;
        case USERNAME  :
            strcpy(((UCHAR *)data),G_diskinfo.username);
            break;
        case ACCESS    :
            *((UCHAR *)data)=G_diskinfo.access;
            break;
        case PASSWORD  :
            getpasswd((CHAR *)data);
            break;
        case POSITION  :
            *((UCHAR *)data)=G_diskinfo.pos;
            break;
        case BACKEDUP  :
            *((UCHAR *)data)=G_diskinfo.backed;
            break;
        case CONSOLID  :
            *((UCHAR *)data)=G_diskinfo.consol;
            break;
        case NEWEXE    :
            if (crcchk(G_database,NEWEXEF)==G_diskinfo.exechk) 
                *((UCHAR *)data)=0;
            else 
                *((UCHAR *)data)=G_diskinfo.newexe;
            break;
        case NEWCFG    :
            if (crcchk(G_database,NEWCFGF)==G_diskinfo.cfgchk) 
                *((UCHAR *)data)=0;
            else 
                *((UCHAR *)data)=G_diskinfo.newcfg;
            break;
        case NEWOFF    :
            if (crcchk(G_database,NEWOFFF)==G_diskinfo.offchk) 
                *((UCHAR *)data)=0;
            else 
                *((UCHAR *)data)=G_diskinfo.newoff;
            break;
        case NEWSYS    :
            if (crcchk(G_database,NEWSYSF)==G_diskinfo.syschk) 
                *((UCHAR *)data)=0;
            else 
                *((UCHAR *)data)=G_diskinfo.newsys;
            break;
        case NEWDAT    :
            if (crcchk(G_database,NEWDATF)==G_diskinfo.datchk) 
                *((UCHAR *)data)=0;
            else 
                *((UCHAR *)data)=G_diskinfo.newdat;
            break;
        case MERGETYPE :
            *((UCHAR *)data)=G_diskinfo.merge;
            break;
        default :
            RETURNV(0);
    }
    RETURNV(1);
}

//**********************************************************
//S setup new disk data information
//R TRUE

INT newdd(void)
{
    UCHAR *s,*e;
    ENTRY(4750);

    memcpy(&G_diskinfo,G_bootsec,512);
    strcpy(G_diskinfo.name,DISKNAME);
    strcpy(G_diskinfo.prompt,DISKPROMPT);
    G_ddread=1;
    RETURNV(1);
}

//**********************************************************
//S generate a user file
//P char str path 
//P char str base filename
//P integer set to 1 to use Guid in filename
//R TRUE Ok, FALSE failed

INT genufile(CHAR *sp, CHAR *s, INT saverest)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR tmp[LENOFFNAME];
    CHAR source[LENOFFULLFILEPATH];
    CHAR dest[LENOFFULLFILEPATH];
    ENTRY(4790);
    
    sendmsg("DBM",MESSAGE_ca);


    if (saverest==1)
        {
        strcpy(tmp,s);
        tmp[0]=(G_uid/10)+'0';
        tmp[1]=(G_uid%10)+'0';
        if (!findfile(sp,tmp,0)) RETURNV(0);
        }
    else
        {
        if (!findfile(sp,s,0)) RETURNV(0);
        }

    buf=MALLOC(BIGBUFQ);
    if (buf==NULL) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        strcpy(tmp,G_filesfd[i].n);

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
        sprintf(source,"%s%s",sp,G_filesfd[i].n);
        sprintf(dest,"%s%s",sp,tmp);
        fi=open(source,O_RDONLY|O_BINARY);
        if (fi!=(-1)) {
            fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (fo!=(-1)) {
                while ((nb=read(fi,buf,BIGBUFQ))>0) {
                    if (write(fo,buf,nb)!=nb) {
                        FREE(buf);
                        close(fi);
                        close(fo);
                        RETURNV(0);
                    }
                }
                close(fo);
            }
            else {
                FREE(buf);
                close(fi);
                close(fo);
                RETURNV(0);
            }
            close(fi);
        }
        else {
            FREE(buf);
            RETURNV(0);
        }
    }
    FREE(buf);

    for (i=0;i<G_numfd;i++) {
        strcpy(tmp,G_filesfd[i].n);
        sprintf(source,"%s%s",sp,tmp);
        unlink(source);
    }
    RETURNV(1);
}

//**********************************************************
//S reset the disk using int 13h
//P U char disk id ?0=def, 1=A etc.
//R TRUE Ok, FALSE failed

INT resetdisk(UCHAR d)
{
    union REGS r;
    ENTRY(4800);
    r.h.ah=0;
    r.h.dl=d;
    int386(0x13,&r,&r);
    if (r.x.cflag) RETURNV(0);
    RETURNV(1);
}

//**********************************************************
//S get diskinfo
//P U char disk id ?0=def, 1=A etc.
//R integer 0 OK, or disk error code

INT getdiskinfo(UCHAR d)
{
     INT i;
     union REGS ir, or;
     struct SREGS sr;
    ENTRY(4810);

     for (i=0;i<RESET_NO+DISK_IO_NO;i++) {
         if (resetdisk(d)) {
             ir.h.ah=0x08; ir.h.dl=d; int386(0x13,&ir,&or);
             if (or.x.cflag==0) {
                 G_di.t=(((or.h.cl&0xc0)<<2)|or.h.ch);
                 G_di.s=or.h.cl&0x3f;
                 G_di.h=or.h.dh;
                do {
                    ir.h.ah=0x18;
                    ir.x.ecx=or.x.ecx;
                     ir.h.dh=or.h.dh;
                    ir.h.dl=d;
                    int386x(0x13,&ir,&or,&sr);
                } while (or.h.ah==6);
                if ((or.h.ah!=0)||(or.x.cflag==1)) {
                     RETURNV(or.h.ah);
                }
                setvect(0x1E,(IFPTR)MK_FP(sr.es,or.x.di));
                RETURNV(OK);
             }
         }
     }
     RETURNV(or.h.ah);
}

//**********************************************************
//S write_ss
//P U char d
//P U char h
//P U char t
//P U char s
//P U char n
//P pointer to U char buffer
//R integer 0 OK, or disk error code

INT write_ss(UCHAR d,UCHAR h,UCHAR t,UCHAR s,UCHAR n,UCHAR far *b)
{
    UINT i,ms2b,sb,ob,o4;
    union REGS ir,or;
    struct SREGS sr;
    ENTRY(4820);

    if (h>G_di.h||t>G_di.t+1||s>G_di.s||n>G_di.s) RETURNV(1);
    ms2b=(t>>2)&0xC0; sb=FP_SEG(b); ob=FP_OFF(b);
    o4=ob; sb+=((o4>>4)&0x0FFF); ob=(ob&0x000F); segread(&sr);
    for (i=0;i<RESET_NO+DISK_IO_NO;i++) {
        ir.x.eax=0x0300|n; ir.x.ecx=(t<<8)|s|ms2b; ir.x.edx=(h<<8)|d;
        sr.es=sb; ir.x.ebx=ob; int386x(0x13,&ir,&or,&sr);
        if (or.x.cflag==0) {
            RETURNV(OK);
        } else {
             resetdisk(d);
        }
    }
    RETURNV(or.h.ah);
}

//**********************************************************
//S format_track
//P unsigned integer d
//P unsigned integer h
//P unsigned integer c
//R integer 0 OK, or disk error code

INT format_track(UINT d,UINT h,UINT c)
{
    INT i,k;
    UINT ms2b_cyl_no;
    UINT seg_buf;
    UINT off_buf;
    UINT off_4;
    CHAR far *afl_b; // address field list
    CHAR far *afl_2b;
    CHAR far *afl_ptr;
    union REGS ir, or;
    struct SREGS sr;
    ENTRY(4830);

    if (h>G_di.h||c>G_di.t+1) RETURNV(1);
    ms2b_cyl_no=(c>>2)&0xC0;
    if ((afl_b=MALLOC(DEFAULT_SECTOR_SIZE*2))==NULL) {
         RETURNV(OUT_OF_MEM);
    }
    seg_buf=FP_SEG(afl_b); off_buf=FP_OFF(afl_b);
    off_4=off_buf; seg_buf+=((off_4>>4)&0x0FFF);
    off_buf=(off_buf&0x000F); segread(&sr);
    if (seg_buf>0xFFE0U) {
        afl_2b=afl_b+DEFAULT_SECTOR_SIZE;
        seg_buf=FP_SEG(afl_2b);    off_buf=FP_OFF(afl_2b);
        off_4=off_buf; seg_buf+=((off_4>>4)&0x0FFF);
        off_buf=(off_buf&0x000F);
    }
    for (k=1,afl_ptr=afl_b;k<=G_di.s;k++) {
        *(afl_ptr++)=c&0xff; *(afl_ptr++)=h; *(afl_ptr++)=k; *(afl_ptr++)=2;
    }
    for (i=0;i<RESET_NO+DISK_IO_NO;i++) {
        ir.x.eax=0x0500|((d<0x80)?G_di.s:3);
        ir.x.ecx=(c<<8)|ms2b_cyl_no;
        ir.x.edx=(h<<8)|(d&0xff);
        sr.es=seg_buf; ir.x.ebx=off_buf;
        int386x(0x13,&ir,&or,&sr);
        if (or.x.cflag==0) {
             FREE(afl_b); RETURNV(OK);
        } else {
             resetdisk(d);
        }
     }
     FREE(afl_b);
     RETURNV(or.h.ah);
}
//**********************************************************
//S format disk "BACKUP"
//P integer d
//P integer q
//R integer 0 Ok, -1 failed, -1000 no disk info, and other neg no.s

INT formatdisk(INT d,INT q)
{
    INT i,j;
    IFPTR old1E;
    ENTRY(4840);
    old1E=getvect(0x1E);
    if (getdiskinfo(d)) RETURNV(-1000);
    sendmsg("OUTPUT1",MESSAGE_P,440,80,FLOPPYBMP);
    sendmsg("OUTPUT1",MESSAGE_A,3);
    if (!q) {
        for (i=0;i<=G_di.t;i++) {
            for (j=0;j<=G_di.h;j++) {
                if (format_track(d,j,i)) {
                    setvect(0x1E,old1E);
                    RETURNV(1+i*2+j);
                }
                sendmsg("OUTPUT1",MESSAGE_b,440,80+i*2+j,620,81+i*2+j);
             }
         }
    }
    if (write_ss(d,0,0,1,1,G_bootsec)) {
         setvect(0x1E,old1E);
        RETURNV(-1);
    }
    sendmsg("OUTPUT1",MESSAGE_b,440,232,620,233);
    for (i=1;i<18;i++) {
        memset(G_wbuf,0,512);
        if ((i==1)||(i==10)) { G_wbuf[0]=0xF0; G_wbuf[1]=G_wbuf[2]=0xFF; } 
        if (write_ss(d,0,0,i+1,1,G_wbuf)) {
            setvect(0x1E,old1E);
            RETURNV(0-(i+1));
        }
        sendmsg("OUTPUT1",MESSAGE_b,440,232+i/2,620,233+i/2);
    }
    for (i=0;i<15;i++) {
        if (write_ss(d,1,0,i+1,1,G_wbuf)) {
            setvect(0x1E,old1E);
            RETURNV(0-(i+19));
        }
        sendmsg("OUTPUT1",MESSAGE_b,440,241+i,620,242+i);
    }
    sendmsg("OUTPUT1",MESSAGE_b,440,241+i,620,242+i);
    sendmsg("OUTPUT1",MESSAGE_A,0);
    setvect(0x1E,old1E);
     RETURNV(0);
}
#endif // def USINGDD

//**********************************************************
//S free memory in find files list

void freefind(void)
{
    INT i;
    if ((G_numfd>0)&&(G_filesfd!=NULL))
        {
        for (i=0;i<G_numfd;i++)
            {
            if (G_filesfd[i].n!=NULL)
                {
                FREE(G_filesfd[i].n);
                }
            }
        FREE(G_filesfd);
        }
    G_numfd=0;
    G_filesfd=NULL;
}

//**********************************************************
//S file name compare for sort
//P FILEINFO ptr 1
//P FILEINFO ptr 2
//R strcmp reply values

INT fncmp(FILEINFO *a,FILEINFO *b)
{
    return(strcmp(a->n,b->n));
}

//**********************************************************
//S generate sorted list of matching files
//P char str path
//P char str name
//P BOOL flag TRUE to indicate path needs adding to filename in array data
//R integer number of files found

INT findfile(CHAR *path,CHAR *name,INT fullpath)
{
    struct ffblk f;
    INT done=0;
    static CHAR tmp[LENOFFULLFILEPATHX];
    static CHAR opt[LENOFFULLFILEPATHX];

    freefind();
    sprintf(tmp,"%s%s",path,name);
    done=findfirst(tmp,&f,FILEATTR);
    while (done!=(-1))
        {
        G_numfd++;
        done=findnext(&f);
        }
    if (G_numfd==0)
        return(G_numfd);

    G_filesfd=MALLOC(sizeof(FILEINFO)*G_numfd);
    G_numfd=0;
    if (G_filesfd!=NULL)
        {
        done=findfirst(tmp,&f,FILEATTR);
        while (done!=(-1))
            {
            if (fullpath)
                sprintf(opt,"%s%s",path,f.ff_name);
            else
                {
                strcpy(opt,f.ff_name);
                }
            strupr(opt);
            G_filesfd[G_numfd].n=STRDUP(opt);
            if (G_filesfd[G_numfd].n==NULL) break;
            G_filesfd[G_numfd].l=strlen(opt);
            G_filesfd[G_numfd].t=0;
            G_blocksize+=sizeof(LONG)+sizeof(CHAR)*2+G_filesfd[G_numfd].l;
            G_numfd++;
            done=findnext(&f);
        }
        qsort(G_filesfd,G_numfd,sizeof(FILEINFO),(QSPTR)fncmp);
    }
    return(G_numfd);
}

//**********************************************************
//S copy file(s) function 
//P char str filespec
//P char str source path
//P char str Dest path
//R integer TRUE Ok, FALSE failed

INT copyfile(CHAR *s,CHAR *sp,CHAR *dp)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR source[LENOFFULLFILEPATH];
    CHAR dest[LENOFFULLFILEPATH];
    ENTRY(4770);
    
    sendmsg("DBM",MESSAGE_ca);
    if (!findfile(sp,s,0)) RETURNV(0);

    buf=MALLOC(FCBIGBUFQ);
    if (buf==NULL) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i].n);
        sprintf(dest,"%s%s",dp,G_filesfd[i].n);
        fi=open(source,O_RDONLY|O_BINARY);
        if (fi!=(-1)) {
            fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (fo!=(-1)) {
                while ((nb=read(fi,buf,FCBIGBUFQ))>0) {
                    if (write(fo,buf,nb)!=nb) {
                        FREE(buf);
                        close(fi);
                        close(fo);
                        RETURNV(0);
                    }
                }
                close(fo);
            }
            else {
                FREE(buf);
                close(fi);
                close(fo);
                RETURNV(0);
            }
            close(fi);
        }
        else {
            FREE(buf);
            RETURNV(0);
        }
    }
    FREE(buf);
    RETURNV(1);
}

//**********************************************************
//S copy file(s) function. Copies file to new filename in same path
//D I have problems with what happens if there is no extn. on a file to be copied :JGQ 25/10
//P char str path
//P char str source filespec
//P char str dest filespec
//R integer TRUE Ok, FALSE failed

INT copyrenfile(CHAR *path,CHAR *srcfile,CHAR *destfile)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR source[LENOFFULLFILEPATH];
    CHAR dest[LENOFFULLFILEPATH];
    CHAR tmp[10],tmp1[LENOFFNAME],*t;
    ENTRY(4770);
    
    sendmsg("DBM",MESSAGE_ca);
    strcpy(tmp1,destfile);
    t=strchr(tmp1,'.');
    if ((t==NULL)||(*(t+1)=='*'))
        {     // wild copy
        if (t!=NULL) *t=0;
        if (!findfile(path,srcfile,0)) RETURNV(0);
        if (!(stricmp(srcfile,destfile))) RETURNV(0);
        buf=MALLOC(FCBIGBUFQ);
        if (buf==NULL) RETURNV(0);
        for (i=0;i<G_numfd;i++)
            {
            t=strchr(G_filesfd[i].n,'.');
            if (t!=NULL)
                {
                strcpy(tmp,t+1);
                }
            sprintf(source,"%s%s",path,G_filesfd[i].n);
            sprintf(dest,"%s%s.%s",path,tmp1,tmp);
            fi=open(source,O_RDONLY|O_BINARY);
            if (fi!=(-1))
                {
                fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
                if (fo!=(-1))
                    {
                    while ((nb=read(fi,buf,FCBIGBUFQ))>0)
                        {
                        if (write(fo,buf,nb)!=nb)
                            {
                            FREE(buf);
                            close(fi);
                            close(fo);
                            RETURNV(0);
                            }
                        }
                    close(fo);
                    }
                else
                    {
                    FREE(buf);
                    close(fi);
                    close(fo);
                    RETURNV(0);
                    }
                close(fi);
                }
            else
                {
                FREE(buf);
                RETURNV(0);
                }
            }
        FREE(buf);
        RETURNV(1);
        }
    else
        {
        RETURNV(0);     // must be wildcard copy!
        }
}

//**********************************************************
//S rename files
//P char str path
//P char str source
//P char str destination
//R BOOL TRUE =Ok, FALSE =failed

INT renamefiles(CHAR *p,CHAR *s,CHAR *d)
{
    INT i,rv=1;
    CHAR source[LENOFFULLFILEPATH];
    CHAR dest[LENOFFULLFILEPATH];
    CHAR tmp[10],tmp1[LENOFFNAME],*t;
    ENTRY(4770);
    sendmsg("DBM",MESSAGE_ca);
    strcpy(tmp1,d);    
    t=strchr(tmp1,'.');
    if ((t==NULL)||(*(t+1)=='*'))
        {
        if (t!=NULL) *t=0;
        if (!findfile(p,s,0)) RETURNV(0);
        for (i=0;i<G_numfd;i++) {
            t=strchr(G_filesfd[i].n,'.');
            if (t!=NULL) {
                strcpy(tmp,t+1);
                sprintf(source,"%s%s",p,G_filesfd[i].n);
                sprintf(dest,"%s%s.%s",p,tmp1,tmp);
                if (rename(source,dest)) rv=0;
                }
            }
        }
    else
        {
        sprintf(source,"%s%s",p,s);
        sprintf(dest,"%s%s.%s",p,d);    // CODE FAULT INSUFFICIENT PARAMS :JGQ 25/10
        if (rename(source,dest)) rv=0;
        }
    sendmsg("DBM",MESSAGE_RI);
    return(rv);
}

//**********************************************************
//S delete file(s) function 
//P char str filespec
//P char str path
//R BOOL TRUE Ok, FALSE failed

INT delfile(CHAR *filespec,CHAR *path)
{
    INT i;
    CHAR source[LENOFFULLFILEPATH];
    ENTRY(4780);
    
    sendmsg("DBM",MESSAGE_ca);

    if (!findfile(path,filespec,0)) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",path,G_filesfd[i].n);
        if (unlink(source) == -1) {
            RETURNV(0);
        }
    }
    RETURNV(1);
}

//**********************************************************
//S mangle
//P address to work on.
//P no. of chars to work on.

void mangle(UCHAR *s,UCHAR l)
{
    UCHAR c=l;
    while (l--)
        *(s++)^=c++;
}

//**********************************************************
//S readbuff
//P buffer address
//P address of Unsigned integer buffer size    I vaguely question whether this function can read more than 32k :JGQ 25/10
//R no. char read - may be negative in which case how can it be unsigned? :JGQ 25/10

UINT pascal readbuff(CHAR *buff,UINT *size)
{
    INT r=read(G_ifd,buff,*size);
    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if (G_zerr==1) {
        // buf_writebuff has failed, return 0 to terminate implode
        return(0);
    }
    if (r<0)
        G_zerr=1;
    return(r);
}

//*************************************************
//S write routine that writes via the buffered write
//D note heavy use of globals to communicate errors
//P buffer address
//P address of Unsigned integer buffer size    I vaguely question whether this function can read more than 32k :JGQ 25/10

void pascal buf_writebuff(CHAR *buff,UINT *size)
{
    UINT w;

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if (G_compressing) {
        w=buf_write(G_ofd,buff,*size);
        if (w!=*size) G_zerr=1;
        G_outs+=w;
    } else {
        w=buf_write(G_ofd,buff,*size);
        if (w!=*size) G_zerr=1;
    }
}

//************************************************
//S Allocate a large buffer
//D returns buff address, NULL if failed
//P place to put buffer address
//P address of Unsigned integer buffer size

void buff_alloc(CHAR **buff,UINT *size)
{
    *size=ALLOC1BUFFQ;
    *buff=(CHAR *)MALLOC(*size);
    if (*buff == NULL)
    {
        // try for a smaller buffer
        *size=ALLOC2BUFFQ;
        *buff=(CHAR *)MALLOC(*size);
    }
}

//************************************************

static BUF_DATA *G_bufdata=NULL;

//************************************************
//S flush the buffer

void buf_flush(void)
{
    if ((write(G_bufdata->fhan,G_bufdata->buffer,G_bufdata->byteswritten)) != G_bufdata->byteswritten)
        {
        G_zerr=1;            // set global error flag
        }
    G_bufdata->byteswritten=0;
}

//************************************************
//S write to the buffer
//P integer file handle
//P buffer address
//P U integer length of buffer to write
//R U integer no. of bytes written

UINT buf_write(INT fhan, void *buf, UINT len)
{
    UINT wbytes;

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if ((G_bufdata->buffer != NULL) && (G_bufdata->fhan == fhan))
    {
        if (len >= G_bufdata->size)
        {
            // write straight to disk
            buf_flush();
            wbytes=write(fhan,buf,len);
        }
        else
        {
            if (G_bufdata->byteswritten >= (G_bufdata->size - len))
            {
                buf_flush();
            }
            if (G_zerr) {
                wbytes=0;
            } else {
                memcpy(&G_bufdata->buffer[G_bufdata->byteswritten], buf, len); // <0  err=1;
                wbytes=len;
                G_bufdata->byteswritten += len;
            }
        }
    }
    else        // no buffering
    {
        wbytes=write(fhan,buf,len);
    }
    return (wbytes);
}

//************************************************
//S initialise buffered file handling. Only use for newly created files
//D note that if a buffer cannot be allocated the buffered write
//D routines fall back to direct disk writes
//P integer file handle

void buf_init(INT fhan)
{
    if ((G_bufdata=(BUF_DATA *)MALLOC(sizeof(BUF_DATA)))!=NULL)
    {
        G_bufdata->fhan=fhan;
        buff_alloc(&G_bufdata->buffer,&G_bufdata->size);
        G_bufdata->byteswritten=0;   // relative to the current file offset, i.e. bytes written to buffer
        if(G_bufdata->buffer == NULL)
        {
            FREE (G_bufdata);       // Cannot buffer so free up
            G_bufdata = NULL;
        }
    }
}

//************************************************
//S close buffered file handling
//D flushes any data in the buffer to the file and then closes the file
//P integer file handle

void buf_close(INT fhan)
{
    if ((G_bufdata != NULL) && (G_bufdata->fhan == fhan))
    {
        buf_flush();
        FREE(G_bufdata->buffer);
        FREE(G_bufdata);
        G_bufdata = NULL;
    }
    close(fhan);
}

//************************************************
//S buffered lseek
//P integer file handle
//P long integer offset
//P integer from where (positioning)

LONG buf_lseek(INT fhan,LONG offset,INT fromwhere)
{
    LONG    retval=0;

    if ((G_bufdata->buffer != NULL) && (G_bufdata->fhan == fhan))
    {
        switch (fromwhere) {
            case SEEK_SET:
                if (G_bufdata->byteswritten != 0)
                {
                    buf_flush();
                }
                break;
            case SEEK_CUR:
                retval += G_bufdata->byteswritten;
            default:
                // no action on buffer
                break;
            }
    }
    retval += lseek(fhan,offset,fromwhere);
    return (retval);
}

//************************************************
//S compress a file using the Pkware library
//P char str input file
//R integer return value

INT sys_compress(CHAR *inputfilename)
{
    UINT type=CMP_BINARY;   // Compression mode
    UINT dsize=1024;    // sliding window size - set for maximum speed
//    CHAR *workbuff;     // for use by the Pkware libraries
    INT  retval=1;


    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if ((G_ifd=open(inputfilename,O_RDONLY|O_BINARY))==-1)    // set up handle for readbuff()
    {
        retval=0;
    }
    else
    {
//        if ((workbuff=(CHAR *)MALLOC(IMPLODEBUFQ))!=NULL)
            // MALLOC this memory at start up - hopefully fix backup bug?
        if (G_workbuff!=NULL)
        {
            G_outs=0L;                  // Amount of data written
            implode(readbuff,buf_writebuff,G_workbuff,&type,&dsize);
//            FREE(workbuff);
        }
        else
        {
            retval=0;
        }
        close(G_ifd);
    }
    return (retval);
}

//*************************************************
//S write buff
//P char pointer buffer address
//P address of unsigned int size

void pascal writebuff(CHAR *buff,UINT *size)
{
    UINT w;

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if (G_compressing) {
        if (G_outs+(LONG)*size>G_start) {
            G_nocomp=1;
            return;
        }
        w=write(G_ofd,buff,*size);
        if (w!=*size) G_zerr=1;
        G_outs+=w;
    } else {
        w=write(G_ofd,buff,*size);
        if (w!=*size) G_zerr=1;
    }
}

//*************************************************
//S direct transfer of data from input file to output file
//D uses assumed open output file G_ofd
//P input filename

void cstore(CHAR *inf)
{
    CHAR *wkb;
    if ((wkb=(CHAR *)MALLOC(COPYSTOREQ))==NULL) return;
    if ((G_ifd=open(inf,O_RDONLY|O_BINARY))==-1) { FREE(wkb); return; }
    while (write(G_ofd,wkb,read(G_ifd,wkb,COPYSTOREQ))>0);
    close(G_ifd);
    FREE(wkb);
}
//************************************************
//S compress a file using the Pkware library
//P input file

INT compress(CHAR *inf)
{
    UINT type=CMP_BINARY;   // Compression mode
    UINT dsize=4096;    // sliding window size
//    CHAR *workbuff;     // for use by the Pkware libraries

    if ((G_ifd=open(inf,O_RDONLY|O_BINARY))==-1) return(0);
//    if ((workbuff=(CHAR *)MALLOC(IMPLODEBUFQ))==NULL) return(0);
            // malloc this memory at start up - hopefully fix backup bug?
    if (G_workbuff==NULL) return(0);
    G_start=filelength(G_ifd);
    G_outs=0L;                  // Amount of data written
    G_compressing=1;
    implode(readbuff,writebuff,G_workbuff,&type,&dsize);
    G_compressing=0;
    close(G_ifd);
//    FREE(workbuff);
    type=G_nocomp;
    G_nocomp=0;
    return(type==0);
}

//************************************************
//S compute checksum using 4 byte ling int as basis
//P integer file handle
//P buffer address
//R reply long int csum

LONG csumcore(INT fd,LONG *buf)
{
    INT i,j;
    LONG ret=0x55A55AAAL;
    while ((i=read(fd,buf,4096))>0) {
        for (j=0;j<i/4;j++) { 
            ret^=buf[j];
        }
    }
    return(ret);
}

//************************************************
//S crc check or set a file.
//D The crc check is based upon data in the file from an
//D offset of 8bytes and stored at an offset of 4 bytes.
//P char str filename
//P BOOL setcheck flag
//R TRUE Ok, FALSE failed - perhaps? :JGQ 25/10
INT csum(CHAR *file,INT setcheck)
{
    INT fd;
    CHAR *buf;
    LONG csumval=0L;
    buf=MALLOC(CSUMBUFQ);
    if (buf==NULL)
        return(0);
    fd=open(file,O_RDWR|O_BINARY);
    if (fd!=(-1)) {
        if (setcheck==1) {              // CHECK
            if (read(fd,buf,8)==8) {
                if (strcmp(buf,"ZIPPED")) {
                    csumval=csumcore(fd,(LONG *)(buf+8));
                    if (*((LONG *)(buf+4))==csumval) {
                        close(fd);
                        FREE(buf);
                        return(1);
                    }
                } else {
                    close(fd);
                    FREE(buf);
                    return(1);
                }
            }
        } else {                        // SET
            lseek(fd,8L,SEEK_SET);
            csumval=csumcore(fd,(LONG *)buf);
            lseek(fd,4L,SEEK_SET);
            write(fd,&csumval,4);
        }
        close(fd);
    }
    FREE(buf);
    return(0);
}

//*************************************************
#define ZIPVER1 26       // Backup signature/version for the trial CAPTURE systems (1 to 3)
#define ZIPVER2 27       // Backup signature/version for release version 4
                         //     which had the quantity and maxqty fields
                         //     increased in size from 4 to 8.
//*************************************************
//S zip files up using Pkware and write out to the zipped file
//P source file
//P source path
//P zip file
//P zip path
//R TRUE Ok, FALSE failed

INT zipit(CHAR *sf,CHAR *sp,CHAR *zf,CHAR *zp)
{
    INT16 i,j,err=0;
    CHAR tmp[100];

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    sendmsg("DBM",MESSAGE_ca);
    G_blocksize=sizeof(CHAR)*8+sizeof(INT16);
    if (!findfile(sp,sf,1)) RETURNV(0);
    sprintf(tmp,"%s%s",zp,zf);
    if (G_numfd!=0) {
        G_ofd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
        if (G_ofd==(-1)) RETURNV(0);

        buf_init(G_ofd);
        buf_lseek(G_ofd,G_blocksize,SEEK_SET);
        G_zerr=0;
        for (i=0;i<G_numfd;i++) {
            sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
            sendmsg("OUTPUT1",MESSAGE_o,0,G_elineat,"%d%%",((i*100)/G_numfd));
            G_filesfd[i].o=buf_lseek(G_ofd,0L,SEEK_CUR);
            if (!sys_compress(G_filesfd[i].n)) {
                G_zerr=1;
            }
            if (G_zerr) {
                buf_close(G_ofd);
                sendmsg("DBM",MESSAGE_RI);
                RETURNV(0);
            }
            sendmsg("OUTPUT1",MESSAGE_o,0,G_elineat,"    ");
        }
        buf_lseek(G_ofd,0,SEEK_SET);
        buf_write(G_ofd,"ZIP",3);
        j=ZIPVER2;
        if (buf_write(G_ofd,&j,1)<=0) err=1;
        buf_write(G_ofd,"\0\0\0\0",4);
        if (buf_write(G_ofd,&G_numfd,sizeof(INT16))<=0) err=1;
        for (i=0;i<G_numfd;i++) {
            sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
            if (buf_write(G_ofd,&(G_filesfd[i].o),sizeof(LONG))<=0) err=1;
            if (buf_write(G_ofd,&(G_filesfd[i].l),sizeof(CHAR))<=0) err=1;
            if (buf_write(G_ofd,&(G_filesfd[i].t),sizeof(CHAR))<=0) err=1;
            mangle((UCHAR *)G_filesfd[i].n,(UCHAR)G_filesfd[i].l);
            if (buf_write(G_ofd,G_filesfd[i].n,G_filesfd[i].l)<=0) err=1;
        }
        buf_close(G_ofd);
        if (!err) csum(tmp,0);
    }
    sendmsg("DBM",MESSAGE_RI);
    if (err) RETURNV(0);
    RETURNV(1);
}

//*************************************************
//S reads from input file ifd and writes to file specified
//P char str file name
//P long int no. of bytes to copy

void ustore(CHAR *onf,LONG l)
{
    CHAR *wkb;
    INT rem=COPYSTOREQ;
    if ((wkb=(CHAR *)MALLOC(COPYSTOREQ))==NULL) return;
    if ((G_ofd=open(onf,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==-1) { FREE(wkb); return; }
    while (l) {
        if ((LONG)rem>l) rem=(INT)l;
        read(G_ifd,wkb,rem);
        write(G_ofd,wkb,rem);
        l-=rem;
    }
    close(G_ofd);
    FREE(wkb);
}

//*************************************************
//S uncompress specified file
//P char str filename
//P char type to do (1== use ustore)
//P long int no. of bytes
//R TRUE Ok, FALSE failed

INT uncompress(CHAR *onf,CHAR type,LONG l)
{
    CHAR *wkb;
    if (type==1) {
        ustore(onf,l);
        return(1);
    }
    if ((G_ofd=open(onf,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==-1)
        return(0);
    if ((wkb=(CHAR *)MALLOC(EXPLODEBUFQ))==NULL)
        return(0);
    explode(readbuff,writebuff,wkb);
    FREE(wkb);
    close(G_ofd);
    return(1);
}

//*************************************************
//S unzipit
//P char str zip filename
//P char zip path
//R TRUE Ok, FALSE fail

INT unzipit(CHAR *zf,CHAR *zp)
{
    INT i,j;
    CHAR tmp[LENOFFULLFILEPATHX];
    LONG l;

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    sendmsg("DBM",MESSAGE_ca);
    sprintf(tmp,"%s%s",zp,zf);
    if (!csum(tmp,1)) return(0);
    if ((G_ifd=open(tmp,O_RDONLY|O_BINARY))==(-1)) {
        RETURNV(0);
    } else {
        G_zerr=0;
        freefind();
        G_left=filelength(G_ifd);
                                      // Check version of zipped code
        if (read(G_ifd,tmp,8)<0) G_zerr=1;
        if (tmp[3] == ZIPVER1) {
            sendmsg("OUTPUT1",MESSAGE_o,0,G_elineat,"Old version, use UPDATE program");
            G_zerr=1;
            close(G_ofd);
            RETURNV(0);
        }
//        lseek(G_ifd,8,SEEK_SET);
        if (read(G_ifd,&G_numfd,sizeof(INT))<0) G_zerr=1;
        G_filesfd=MALLOC(sizeof(FILEINFO)*G_numfd);
        for (i=0;i<G_numfd;i++) {
            sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
            if (read(G_ifd,&(G_filesfd[i].o),sizeof(LONG))<0) G_zerr=1;
            if (read(G_ifd,&(G_filesfd[i].l),sizeof(CHAR))<0) G_zerr=1;
            if (read(G_ifd,&(G_filesfd[i].t),sizeof(CHAR))<0) G_zerr=1;
            G_filesfd[i].n=MALLOC(G_filesfd[i].l+1);
            if (read(G_ifd,G_filesfd[i].n,G_filesfd[i].l)<0) G_zerr=1;
            mangle((UCHAR *)G_filesfd[i].n,(UCHAR)G_filesfd[i].l);
            G_filesfd[i].n[G_filesfd[i].l]=0;
        }
        if (G_zerr) {
            close(G_ofd);
            sendmsg("DBM",MESSAGE_RI);
            RETURNV(0);
        }
        for (i=0;i<G_numfd;i++) {
            sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
            sendmsg("OUTPUT1",MESSAGE_o,0,G_elineat,"%d%%",((i*100)/G_numfd));
            lseek(G_ifd,G_filesfd[i].o,SEEK_SET);
            if (i==G_numfd-1)
                l=G_left-G_filesfd[i].o;
            else
                l=G_filesfd[i+1].o-G_filesfd[i].o;
            sprintf(tmp,"PRE-REST.%03d",i);
            unlink(tmp);
            rename(G_filesfd[i].n,tmp);
            uncompress(G_filesfd[i].n,G_filesfd[i].t,l);
            if (G_zerr) {
                close(G_ofd);
                for (j=0;j<=i;j++) {
                    sprintf(tmp,"PRE-REST.%03d",j);
                    unlink(G_filesfd[i].n);
                    rename(tmp,G_filesfd[i].n);
                }
                sendmsg("DBM",MESSAGE_RI);
                RETURNV(0);
            }
            sendmsg("OUTPUT1",MESSAGE_o,0,G_elineat,"    ");
        }
        close(G_ifd);
        for (i=0;i<G_numfd;i++) {
            sprintf(tmp,"PRE-REST.%03d",i);
            unlink(tmp);
        }
    }
    sendmsg("DBM",MESSAGE_RI);
    return(1);
}


//*************************************************
//S disk control routine
//P integer control type
//P variable list
//R long reply as appropriate

LONG dis_control(INT type,va_list ap)
{
    LONG retval=0L;
    UCHAR *p;
    UCHAR *s;
    UCHAR *d;
    UCHAR *dp;
    CHAR tmp[LENOFFULLFILEPATH];
    ENTRY(4850);

    G_inerrhand=0;
//    harderr(handler);
    switch (type) {

#ifdef USINGDD

        case MESSAGE_U :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
            retval=(LONG)genufile(p,s,va_arg(ap,INT));
            break;
        case MESSAGE_S :
            dtype=va_arg(ap,CHAR);
            retval=(LONG)setdinfo(dtype,va_arg(ap,void *));
            break;

        case MESSAGE_G :
            dtype=va_arg(ap,CHAR);
            retval=(LONG)retdinfo(dtype,va_arg(ap,void *));
            break;

        case MESSAGE_F :
            p=va_arg(ap,CHAR *);
            c=(*p-'A');
            if (formatdisk(c,0)) {
                retval=0L;
            } else {
                retval=1L;
            }
            break;

        case MESSAGE_P :
            i=va_arg(ap,INT);
            retval=(LONG)putdinfo(i);
            break;

        case MESSAGE_R :
            retval=(LONG)getdinfo();
            break;

        case MESSAGE_N :
            retval=(LONG)newdd();
            break;

        case MESSAGE_I :
            G_ddread=0;
            retval=1L;
            break;

        case MESSAGE_d :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
            retval=(LONG)datechk(p,s,va_arg(ap,CHAR *));
            break;

        case MESSAGE_x :        // Warning : can build enormous linear list :JGQ 25/10
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
            if (!findfile(p,s,0))
                {
                retval=0L;
                }
            else
                {
                sprintf(p,"%s",G_filesfd[i].n);
                for (i=1;i<G_numfd;i++)
                    {
                    strcat(p," ");
                    strcat(p,G_filesfd[i].n);
                    }
                retval=(LONG)strlen(p);
            }
            break;
#else   // def USINGDD

        case MESSAGE_I :
            retval=1L;
            break;

#endif // def USINGDD

        case MESSAGE_s :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            sendmsg("DBM",MESSAGE_ca);
            retval=1L;
            delfile("TEMPSWAP.*",(CHAR *)p);
            sprintf(tmp,"%s.*",(CHAR *)s);
            renamefiles((CHAR *)p,tmp ,"TEMPSWAP");
            sprintf(tmp,"%s.*",(CHAR *)d);
            renamefiles((CHAR *)p,tmp ,(CHAR *)s );
            renamefiles((CHAR *)p,"TEMPSWAP.*",(CHAR *)d);
            sendmsg("DBM",MESSAGE_RI);
            break;

        case MESSAGE_r :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            retval=(LONG)renamefiles((CHAR *)p,(CHAR *)s,(CHAR *)d);
            break;

        case MESSAGE_C :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            retval=(LONG)copyfile((CHAR *)p,(CHAR *)s,(CHAR *)d);
            break;

        case MESSAGE_COPY :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            retval=(LONG)copyrenfile((CHAR *)p,(CHAR *)s,(CHAR *)d);
            break;

        case MESSAGE_D :
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)p=va_arg(ap,CHAR *);
            retval=(LONG)delfile((CHAR *)s,(CHAR *)p);
            break;

        case MESSAGE_T :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=(LONG)findfile((CHAR *)p,(CHAR *)s,0);
            if (G_inerrhand==1) retval=(-1L);
            break;

        case MESSAGE_E :
            freefind();
            retval=1L;
            break;

        case MESSAGE_Z :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            (CHAR *)dp=va_arg(ap,CHAR *);
            retval=(LONG)zipit((CHAR *)p,(CHAR *)s,(CHAR *)d,(CHAR *)dp);
            break;

        case MESSAGE_UZ :
            (CHAR *)d=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=(LONG)unzipit((CHAR *)d,(CHAR *)s);
            break;
    }
    RETURNV(retval);
}
#pragma option -p.
// **************************************************************************
// diskdev.c <end-of-file>

