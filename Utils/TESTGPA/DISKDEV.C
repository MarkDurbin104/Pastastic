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
//F handler
//S critical error handler
//P error
//P register ax
//P register bp
//P register si
INT handler(INT err,INT ax,INT bp,INT si)
{
    G_inerrhand=1;
//    hardresume(_HARDERR_FAIL);
    return(_HARDERR_FAIL);
}
#pragma warn +par

#ifdef USINGDD
//*************************************************************
//F diskchanged
//S check disk changed status, true if the disk has been changed
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
//F readdd
//S read the disk data
//P buffer for disk information
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
//F writedd
//S write the disk data
//P buffer for disk information
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
//F getdinfo
//S get the disk data information
INT getdinfo(void)
{
	ENTRY(4600);
    if (readdd(&G_diskinfo)) RETURNV(0);
    if (calccheck()!=G_diskinfo.check) RETURNV(0);
    G_ddread=1;
    RETURNV(1);
}
//*************************************************************
//F putdinfo
//S put the disk data information
//P ????
INT putdinfo(INT rawput)
{
	ENTRY(4610);
    if ((!(rawput))&&(calccheck()!=G_diskinfo.check)) RETURNV(0);
    if (writedd(&G_diskinfo)) RETURNV(0);
    RETURNV(1);
}
//*************************************************************
//F checkdinfo
//S check the disk data information
INT checkdinfo(void)
{
	ENTRY(4620);
    if (readdd(&G_chekinfo)) RETURNV(0);
    if (memcmp(&G_diskinfo,&G_chekinfo,512)) RETURNV(0);
    RETURNV(1);
}
//*************************************************************
//F setpass
//S set the disk password information
//P password
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
//F getpasswd
//S get the disk password information
//P password
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
//F calccheck
//S calculate the checksum for the disk data information
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
//F setdinfo
//S set the disk data information
//P type of data
//P data
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
//F createcrcfile
//S creat a crc file
//P path of crc file
//P name of crc file
void createcrcfile(CHAR *path,CHAR *name)
{
    INT fd;
    CHAR file[80];
    CHAR tmp[80];
	ENTRY(4670);

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) RETURN;
    strcpy(tmp,datestr(0));
    write(fd,tmp,strlen(tmp));
    close(fd);
	RETURN;
}
//------------------------------------------------------------------------/
//                  SEMAPHORE FUNCTIONS
//F opensem
//S open a semaphore file
INT opensem(CHAR *path,CHAR *name)
{
    CHAR file[80];
	ENTRY(4680);
    sprintf(file,"%s%s",path,name);
    G_semfd=open(file,O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (G_semfd==(-1)) RETURNV(0);
    RETURNV(1);
}
//F closesem
//S close a semaphore file
void closesem(void)
{
	ENTRY(4690);
    close(G_semfd);
	RETURN;
}
//F updatesem
//S update a semaphore file
INT updatesem(CHAR *tabname,CHAR state)
{
    INT s;
    INT i;
    UCHAR flag;
	ENTRY(4700);

    if (!G_semnet) RETURNV(1);

    flag=0xAA*state;
    s=snum(tabname);
    if (s<0) RETURNV(0);
    if (!opensem(G_netpath,"SEM.NET")) RETURNV(0);
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
//F semstate
//S get a semaphore file status
INT semstate(CHAR *tabname)
{
    UCHAR state;
    INT s;
	ENTRY(4710);

    if (!G_semnet) RETURNV(0);

    s=snum(tabname);
    if (s<0) RETURNV(-1);
    if (!opensem(G_netpath,"SEM.NET")) RETURNV(-1);
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
//                  SEMAPHORE FUNCTIONS - End
//------------------------------------------------------------------------/

//**********************************************************
//F datechk
//S compare the dates of two files
INT datechk(CHAR *path,CHAR *bpath,CHAR *name)
{
    INT fd;
    CHAR file[80];
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
//F crcchk
//S check the CRC of a file
UINT crcchk(CHAR *path,CHAR *name)
{
    INT fd;
    CHAR file[80];
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
//F mretdinfo
//S RETURN the disk data information
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
//F newdd
//S setup new disk data information
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
//F genufile
//S generate a * file
INT genufile(CHAR *sp,CHAR *s,INT saverest)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR tmp[15];
    CHAR source[80];
    CHAR dest[80];
	ENTRY(4790);
    
    sendmsg("DBM",MESSAGE_ca);


    if (saverest==1) {
        strcpy(tmp,s);
        tmp[0]=(G_uid/10)+'0';
        tmp[1]=(G_uid%10)+'0';
        if (!findfile(sp,tmp,0)) RETURNV(0);
    }
    else {
        if (!findfile(sp,s,0)) RETURNV(0);
    }

    buf=MALLOC(32760);
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
                while ((nb=read(fi,buf,32760))>0) {
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
//F resetdisk
//S reset the disk using int 13h
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
//F getdiskinfo
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
//F write_ss
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
//F format_track
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
	if ((afl_b=malloc(DEFAULT_SECTOR_SIZE*2))==NULL) {
 		RETURNV(OUT_OF_MEM);
	}
	seg_buf=FP_SEG(afl_b); off_buf=FP_OFF(afl_b);
	off_4=off_buf; seg_buf+=((off_4>>4)&0x0FFF);
	off_buf=(off_buf&0x000F); segread(&sr);
	if (seg_buf>0xFFE0U) {
		afl_2b=afl_b+DEFAULT_SECTOR_SIZE;
		seg_buf=FP_SEG(afl_2b);	off_buf=FP_OFF(afl_2b);
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
		 	free(afl_b); RETURNV(OK);
		} else {
	 		resetdisk(d);
		}
 	}
 	free(afl_b);
 	RETURNV(or.h.ah);
}
//**********************************************************
//F formatdisk
//S format disk "BACKUP"
INT formatdisk(INT d,INT q)
{
	INT i,j;
	IFPTR old1E;
	ENTRY(4840);
	old1E=getvect(0x1E);
	if (getdiskinfo(d)) RETURNV(-1000);
	sendmsg("OUTPUT1",MESSAGE_P,440,80,"FLOPPY.BMP");
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
//F freefind
void freefind(void)
{
    INT i;
    if ((G_numfd>0)&&(G_filesfd!=NULL)) {
        for (i=0;i<G_numfd;i++) {
            if (G_filesfd[i].n!=NULL) {
                free(G_filesfd[i].n);
            }
        }
        free(G_filesfd);
    }
    G_numfd=0;
    G_filesfd=NULL;
}
//**********************************************************
//F fncmp
int fncmp(FILEINFO *a,FILEINFO *b)
{
    return(strcmp(a->n,b->n));
}
//**********************************************************
//F findfile
int findfile(CHAR *path,CHAR *name,INT fullpath)
{
    struct ffblk f;
    int done=0;
    static char tmp[100];
    static char opt[100];

    freefind();
    sprintf(tmp,"%s%s",path,name);
    done=findfirst(tmp,&f,FILEATTR);
    while (done!=(-1)) {
        G_numfd++;
        done=findnext(&f);
    }
    if (G_numfd==0) return(G_numfd);

    G_filesfd=malloc(sizeof(FILEINFO)*G_numfd);
    G_numfd=0;
    if (G_filesfd!=NULL) {
        done=findfirst(tmp,&f,FILEATTR);
        while (done!=(-1)) {
            if (fullpath)
                sprintf(opt,"%s%s",path,f.ff_name);
            else {
                strcpy(opt,f.ff_name);
            }
            strupr(opt);
            G_filesfd[G_numfd].n=strdup(opt);
            if (G_filesfd[G_numfd].n==NULL) break;
            G_filesfd[G_numfd].l=strlen(opt);
            G_filesfd[G_numfd].t=0;
            G_blocksize+=sizeof(long)+sizeof(char)*2+G_filesfd[G_numfd].l;
            G_numfd++;
            done=findnext(&f);
        }
        qsort(G_filesfd,G_numfd,sizeof(FILEINFO),(QSPTR)fncmp);
    }
    return(G_numfd);
}
//**********************************************************
//F copyfile
//S copy file(s) function 
INT copyfile(CHAR *s,CHAR *sp,CHAR *dp)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR source[80];
    CHAR dest[80];
	ENTRY(4770);
    
    sendmsg("DBM",MESSAGE_ca);
    if (!findfile(sp,s,0)) RETURNV(0);

    buf=MALLOC(8192);
    if (buf==NULL) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i].n);
        sprintf(dest,"%s%s",dp,G_filesfd[i].n);
        fi=open(source,O_RDONLY|O_BINARY);
        if (fi!=(-1)) {
            fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (fo!=(-1)) {
                while ((nb=read(fi,buf,8192))>0) {
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
//F copyrenfile
//S copy file(s) function. Copies file to new filename in same path
INT copyrenfile(CHAR *path,CHAR *srcfile,CHAR *destfile)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR source[80];
    CHAR dest[80];
    CHAR tmp[10],tmp1[15],*t;
	ENTRY(4770);
    
    sendmsg("DBM",MESSAGE_ca);
    strcpy(tmp1,destfile);
    t=strchr(tmp1,'.');
    if ((t==NULL)||(*(t+1)=='*')) {     // wild copy
        if (t!=NULL) *t=0;
        if (!findfile(path,srcfile,0)) RETURNV(0);

        if (!(stricmp(srcfile,destfile))) RETURNV(0);
        buf=MALLOC(8192);
        if (buf==NULL) RETURNV(0);

        for (i=0;i<G_numfd;i++) {
            t=strchr(G_filesfd[i].n,'.');
            if (t!=NULL) {
                strcpy(tmp,t+1);
            }
            sprintf(source,"%s%s",path,G_filesfd[i].n);
            sprintf(dest,"%s%s.%s",path,tmp1,tmp);
            fi=open(source,O_RDONLY|O_BINARY);
            if (fi!=(-1)) {
                fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
                if (fo!=(-1)) {
                    while ((nb=read(fi,buf,8192))>0) {
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
    else {
        RETURNV(0);     // must be wildcard copy!
    }
}
//**********************************************************
//F renamefiles
INT renamefiles(CHAR *p,CHAR *s,CHAR *d)
{
    INT i,rv=1;
    CHAR source[80];
    CHAR dest[80];
    CHAR tmp[10],tmp1[15],*t;
	ENTRY(4770);
    sendmsg("DBM",MESSAGE_ca);
    strcpy(tmp1,d);    
    t=strchr(tmp1,'.');
    if ((t==NULL)||(*(t+1)=='*')) {
        if (t!=NULL) *t=0;
        if (!findfile(p,s,0)) RETURNV(0);
        for (i=0;i<G_numfd;i++) {
            t=strchr(G_filesfd[i].n,'.');
            if (t!=NULL) {
                strcpy(tmp,t+1);
                sprintf(source,"%s%s",p,G_filesfd[i].n);
                sprintf(dest,"%s%s.%s",p,tmp1,tmp);
//                printf("Rename 1 %s %s\n",source,dest);
                if (rename(source,dest)) rv=0;
            }
        }
    } else {
        sprintf(source,"%s%s",p,s);
        sprintf(dest,"%s%s.%s",p,d);
//        printf("Rename 2 %s %s\n",source,dest);
        if (rename(source,dest)) rv=0;
    }
    sendmsg("DBM",MESSAGE_RI);
    return(rv);
}
//**********************************************************
//F delfile
//S delete file(s) function 
INT delfile(CHAR *s,CHAR *sp)
{
    INT i;
    CHAR source[80];
	ENTRY(4780);
    
    sendmsg("DBM",MESSAGE_ca);

    if (!findfile(sp,s,0)) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i].n);
        if (unlink(source) == -1) {
            RETURNV(0);
        }
    }
    RETURNV(1);
}
//**********************************************************
//F mangle
void mangle(UCHAR *s,UCHAR l)
{
    UCHAR c=l;
    while (l--) *(s++)^=c++;
}
//**********************************************************
//F readbuff
UINT pascal readbuff(CHAR *buff,UINT *size)
{
    int r=read(G_ifd,buff,*size);
    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if (G_zerr==1) {
        // buf_writebuff has failed, return 0 to terminate implode
        return(0);
    }
    if (r<0) G_zerr=1;
    return(r);
}
//*************************************************
//F buf_writebuff
//S write routine that writes via the buffered write
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
//F buff_alloc
//S Allocate a large buffer
//D returns buff address, NULL if failed
void buff_alloc(CHAR **buff,UINT *size)
{
    *size=64000U;
    *buff=(CHAR *)malloc(*size);
    if (*buff == NULL)
    {
        // try for a smaller buffer
        *size=32000;
        *buff=(CHAR *)malloc(*size);
    }
}

//************************************************

static BUF_DATA *G_bufdata=NULL;

//************************************************
//F buf_flush
//S flush the buffer

void buf_flush(void)
{
    if ((write(G_bufdata->fhan,G_bufdata->buffer,G_bufdata->byteswritten)) != G_bufdata->byteswritten) {
        G_zerr=1;            // set global error flag
    }
    G_bufdata->byteswritten=0;
}

//************************************************
//F buf_write
//S write to the buffer

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
//P file handle

void buf_init(INT fhan)
{
    if ((G_bufdata=(BUF_DATA *)malloc(sizeof(BUF_DATA)))!=NULL)
    {
        G_bufdata->fhan=fhan;
        buff_alloc(&G_bufdata->buffer,&G_bufdata->size);
        G_bufdata->byteswritten=0;   // relative to the current file offset, i.e. bytes written to buffer
        if(G_bufdata->buffer == NULL)
        {
            free (G_bufdata);       // Cannot buffer so free up
            G_bufdata = NULL;
        }
    }
}

//************************************************
//S close buffered file handling
//D flushes any data in the buffer to the file and then closes the file
//P file handle

void buf_close(INT fhan)
{
    if ((G_bufdata != NULL) && (G_bufdata->fhan == fhan))
    {
        buf_flush();
        free(G_bufdata->buffer);
        free(G_bufdata);
        G_bufdata = NULL;
    }
    close(fhan);
}

//************************************************
//S buffered lseek
//P file handle
//P offset
//P from where (positioning)

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
//F sys_compress
//S compress a file using the Pkware library
//P input file

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
//        if ((workbuff=(CHAR *)malloc(35256U))!=NULL)
            // malloc this memory at start up - hopefully fix backup bug?
        if (G_workbuff!=NULL)
        {
            G_outs=0L;                  // Amount of data written
            implode(readbuff,buf_writebuff,G_workbuff,&type,&dsize);
//            free(workbuff);
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
//F writebuff
void pascal writebuff(CHAR *buff,UINT *size)
{
    UINT w;

    sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
    if (G_compressing) {
        if (G_outs+(long)*size>G_start) {
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
//F cstore
//S direct transfer of data from input file to output file
//P input filename
void cstore(char *inf)
{
    CHAR *wkb;
    if ((wkb=(CHAR *)malloc(30000U))==NULL) return;
    if ((G_ifd=open(inf,O_RDONLY|O_BINARY))==-1) { free(wkb); return; }
    while (write(G_ofd,wkb,read(G_ifd,wkb,30000))>0);
    close(G_ifd);
    free(wkb);
}
//************************************************
//F compress
//S compress a file using the Pkware library
//P input file

int compress(char *inf)
{
    UINT type=CMP_BINARY;   // Compression mode
    UINT dsize=4096;    // sliding window size
//    CHAR *workbuff;     // for use by the Pkware libraries

    if ((G_ifd=open(inf,O_RDONLY|O_BINARY))==-1) return(0);
//    if ((workbuff=(CHAR *)malloc(35256U))==NULL) return(0);
            // malloc this memory at start up - hopefully fix backup bug?
    if (G_workbuff==NULL) return(0);
    G_start=filelength(G_ifd);
    G_outs=0L;                  // Amount of data written
    G_compressing=1;
    implode(readbuff,writebuff,G_workbuff,&type,&dsize);
    G_compressing=0;
    close(G_ifd);
//    free(workbuff);
    type=G_nocomp;
    G_nocomp=0;
    return(type==0);
}

//************************************************
//F csumcore
//S 
long csumcore(int fd,long *buf)
{
    int i,j;
    long ret=0x55A55AAAL;
    while ((i=read(fd,buf,4096))>0) {
        for (j=0;j<i/4;j++) { 
            ret^=buf[j];
        }
    }
    return(ret);
}
//************************************************
//F csum
//S crc check or set a file.
//D The crc check is based upon data in the file from an
//D offset of 8bytes and stored at an offset of 4 bytes.
int csum(char *file,int setcheck)
{
    int fd;
    char *buf;
    long csumval=0L;
    buf=malloc(4096+8);
    if (buf==NULL) return(0);
    fd=open(file,O_RDWR|O_BINARY);
    if (fd!=(-1)) {
        if (setcheck==1) {              // CHECK
            if (read(fd,buf,8)==8) {
                if (strcmp(buf,"ZIPPED")) {
                    csumval=csumcore(fd,(long *)(buf+8));
                    if (*((long *)(buf+4))==csumval) {
                        close(fd);
                        free(buf);
                        return(1);
                    }
                } else {
                    close(fd);
                    free(buf);
                    return(1);
                }
            }
        } else {                        // SET
            lseek(fd,8L,SEEK_SET);
            csumval=csumcore(fd,(long *)buf);
            lseek(fd,4L,SEEK_SET);
            write(fd,&csumval,4);
        }
        close(fd);
    }
    free(buf);
    return(0);
}

//*************************************************
#define ZIPVER1 26       // Backup signature/version for the trial CAPTURE systems (1 to 3)
#define ZIPVER2 27       // Backup signature/version for release version 4
                         //     which had the quantity and maxqty fields
                         //     increased in size from 4 to 8.
//*************************************************
//F zipit
//S zip files up using Pkware and write out to the zipped file
//P source file
//P source path
//P zip file
//P zip path

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
//F ustore
void ustore(char *onf,long l)
{
    CHAR *wkb;
    int rem=30000;
    if ((wkb=(CHAR *)malloc(30000U))==NULL) return;
    if ((G_ofd=open(onf,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==-1) { free(wkb); return; }
    while (l) {
        if ((long)rem>l) rem=(int)l;
        read(G_ifd,wkb,rem);
        write(G_ofd,wkb,rem);
        l-=rem;
    }
    close(G_ofd);
    free(wkb);
}
//*************************************************
//F uncompress
int uncompress(char *onf,char type,long l)
{
    CHAR *wkb;
    if (type==1) {
        ustore(onf,l);
        return(1);
    }
    if ((G_ofd=open(onf,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==-1) return(0);
    if ((wkb=(CHAR *)malloc(12574))==NULL) return(0);
    explode(readbuff,writebuff,wkb);
    free(wkb);
    close(G_ofd);
    return(1);
}
//*************************************************
//F unzipit
int unzipit(char *zf,char *zp)
{
    int i,j;
    CHAR tmp[100];
    long l;

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
        if (read(G_ifd,&G_numfd,sizeof(int))<0) G_zerr=1;
        G_filesfd=malloc(sizeof(FILEINFO)*G_numfd);
        for (i=0;i<G_numfd;i++) {
            sendmsg("INPUT1",MESSAGE_CLRINACT);     // stop scrensaver popping up!
            if (read(G_ifd,&(G_filesfd[i].o),sizeof(long))<0) G_zerr=1;
            if (read(G_ifd,&(G_filesfd[i].l),sizeof(char))<0) G_zerr=1;
            if (read(G_ifd,&(G_filesfd[i].t),sizeof(char))<0) G_zerr=1;
            G_filesfd[i].n=malloc(G_filesfd[i].l+1);
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
//F dis_control
//S disk control routine
LONG dis_control(INT type,va_list ap)
{
    LONG retval=0L;
    UCHAR *p;
    UCHAR *s;
    UCHAR *d;
    UCHAR *dp;
    CHAR tmp[80];
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

		case MESSAGE_x :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
    		if (!findfile(p,s,0)) {
				retval=0L;
			} else {
				sprintf(p,"%s",G_filesfd[i].n);
			    for (i=1;i<G_numfd;i++) {
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
            delfile((CHAR *)p,"TEMPSWAP.*");
            sprintf(tmp,"%s.*",(CHAR *)s);
            renamefiles((CHAR *)p,tmp ,"TEMPSWAP");
            sprintf(tmp,"%s.*",(CHAR *)d);
            renamefiles((CHAR *)p,tmp ,(CHAR *)s );
            renamefiles((CHAR *)p,"TEMPSWAP.*",(CHAR *)d );
            sendmsg("DBM",MESSAGE_RI);
            retval=1L;
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
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=(LONG)delfile((CHAR *)p,(CHAR *)s);
            break;
        case MESSAGE_T :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=(LONG)findfile((CHAR *)p,(CHAR *)s,0);
            if (G_inerrhand==1) retval=(-1L);
            break;
        case MESSAGE_E :
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
//****************************************************************
//  End of file - DISKDEV.C

