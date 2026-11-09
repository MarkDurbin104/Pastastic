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

#pragma option -p-

#include "diskdev.h"

int G_inerrhand=0;
#define _HARDERR_FAIL 3

#pragma warn -par
// critical error handler
int handler(int err,int ax,int bp,int si)
{
    hardresume(_HARDERR_FAIL);
    return(_HARDERR_FAIL);
}
#pragma warn +par

// true if the disk has been changed
int diskchanged(void)
{
    union REGS r;
	ENTRY(4570);

    r.x.ax=0x1600;
    r.x.dx=0;
    int86(0x13,&r,&r);
    if (r.x.cflag) RETURNV(1);
    RETURNV(0);
}
// read the disk data
int readdd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    int timeout=0;
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
// write the disk data
int writedd(DISKINFO *buf)
{
    union REGS r;
    struct SREGS sr;
    int timeout=0;
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
// get the disk data information
int getdinfo(void)
{
	ENTRY(4600);
    if (readdd(&G_diskinfo)) RETURNV(0);
    if (calccheck()!=G_diskinfo.check) RETURNV(0);
    G_ddread=1;
    RETURNV(1);
}
// put the disk data information
int putdinfo(int rawput)
{
	ENTRY(4610);
    if ((!(rawput))&&(calccheck()!=G_diskinfo.check)) RETURNV(0);
    if (writedd(&G_diskinfo)) RETURNV(0);
    RETURNV(1);
}
// check the disk data information
int checkdinfo(void)
{
	ENTRY(4620);
    if (readdd(&G_chekinfo)) RETURNV(0);
    if (memcmp(&G_diskinfo,&G_chekinfo,512)) RETURNV(0);
    RETURNV(1);
}
// set the disk password information
void setpass(char *p)
{
    int i=0;
    char tmp[5];
	ENTRY(4630);
    sprintf(tmp,"%4.4s",p);
    for (i=0;i<5;i++) G_diskinfo.pass[i]=tmp[i]^(0x55<<i);
	RETURN;
}
// get the disk password information
void getpasswd(char *p)
{
    int i=0;
    char tmp[5];
	ENTRY(4640);
    for (i=0;i<5;i++) tmp[i]=G_diskinfo.pass[i]^(0x55<<i);
    for (i=0;i<5;i++) if (tmp[i]!=' ') p[i]=tmp[i]; else p[i]=0;
	RETURN;
}
// calculate the checksum for the disk data information
unsigned char calccheck(void)
{
    unsigned char *s,*e,ret;
	ENTRY(4650);

    s=(unsigned char *)&(G_diskinfo.id);
    e=(unsigned char *)&(G_diskinfo.check);
    ret=*s;
    while (s<e) ret-=*(s++);

    RETURNV(ret);
}
// set the disk data information
int setdinfo(char type,void *data)
{
	ENTRY(4660);
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
            RETURNV(0);
    }
    G_diskinfo.check=calccheck();
    RETURNV(1);
}
// creat a crc file
void createcrcfile(char *path,char *name)
{
    int fd;
    char file[80];
    char tmp[80];
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
// open a semaphore file
int opensem(char *path,char *name)
{
    char file[80];
	ENTRY(4680);
    sprintf(file,"%s%s",path,name);
    G_semfd=open(file,O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
    if (G_semfd==(-1)) RETURNV(0);
    RETURNV(1);
}
// close a semaphore file
void closesem(void)
{
	ENTRY(4690);
    close(G_semfd);
	RETURN;
}
// update a semaphore file
int updatesem(char *tabname,char state)
{
    int s;
    int i;
    unsigned char flag;
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
// get a semaphore file status
int semstate(char *tabname)
{
    unsigned char state;
    int s;
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

// compare the dates of two files
int datechk(char *path,char *bpath,char *name)
{
    int fd;
    char file[80];
    unsigned long a,b;
    unsigned int d,t;
	ENTRY(4720);
    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    _dos_getftime(fd,&d,&t);
    close(fd);
    a=(long)d<<16|t;
    sprintf(file,"%s%s",bpath,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    _dos_getftime(fd,&d,&t);
    close(fd);
    b=(long)d<<16|t;
    if (b>a) RETURNV(1);
    RETURNV(0);
}
// check the CRC of a file
unsigned int crcchk(char *path,char *name)
{
    int fd;
    char file[80];
    unsigned int buf,ret;
	ENTRY(4730);

    sprintf(file,"%s%s",path,name);
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    while (read(fd,&buf,sizeof(unsigned int))==sizeof(unsigned int)) {
        ret^=buf;
        ret++;
    }
    close(fd);
    RETURNV(ret);
}
// RETURN the disk data information
int retdinfo(char type,void *data)
{
	ENTRY(4740);
    if (!G_ddread||diskchanged()) if (!readdd(&G_diskinfo)) RETURNV(0);
    if (G_diskinfo.check!=calccheck()) RETURNV(0);
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
            RETURNV(0);
    }
    RETURNV(1);
}
// setup new disk data information
int newdd(void)
{
    unsigned char *s,*e;
	ENTRY(4750);

    memcpy(&G_diskinfo,G_bootsec,512);
    strcpy(G_diskinfo.name,DISKNAME);
    strcpy(G_diskinfo.prompt,DISKPROMPT);
    G_ddread=1;
    RETURNV(1);
}
// find files from wild cards *.??? etc.
int findfile(char *path,char *name)
{
    struct ffblk f;
    char tmp[80];
    int done=0;
	ENTRY(4760);

    G_numfd=0;
    sprintf(tmp,"%s%s",path,name);
    if ((done=findfirst(tmp,&f,FILEATTR))==(-1)) RETURNV(0);
    while ((done!=(-1))&&(G_numfd<100)) {
        strcpy(G_filesfd[G_numfd],f.ff_name);
        G_numfd++;
        done=findnext(&f);
    }
    RETURNV(G_numfd);
}
// copy file(s) function 
int copyfile(char *s,char *sp,char *dp)
{
    int fi,fo,i;
    int nb;
    char *buf;
    char source[80];
    char dest[80];
	ENTRY(4770);
    
    sendmsg("DBM",'ca');
    harderr(handler);
    if (!findfile(sp,s)) RETURNV(0);

    buf=MALLOC(8192);
    if (buf==NULL) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i]);
        sprintf(dest,"%s%s",dp,G_filesfd[i]);
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
// delete file(s) function 
int delfile(char *s,char *sp)
{
    int i;
    char source[80];
	ENTRY(4780);
    
    sendmsg("DBM",'ca');
    harderr(handler);

    if (!findfile(sp,s)) RETURNV(0);

    for (i=0;i<G_numfd;i++) {
        sprintf(source,"%s%s",sp,G_filesfd[i]);
        unlink(source);
    }
    RETURNV(1);
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
	ENTRY(4790);
    
    sendmsg("DBM",'ca');
    harderr(handler);


    if (saverest==1) {
        strcpy(tmp,s);
        tmp[0]=(G_uid/10)+'0';
        tmp[1]=(G_uid%10)+'0';
        if (!findfile(sp,tmp)) RETURNV(0);
    }
    else {
        if (!findfile(sp,s)) RETURNV(0);
    }

    buf=MALLOC(32760);
    if (buf==NULL) RETURNV(0);

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
        strcpy(tmp,G_filesfd[i]);
        sprintf(source,"%s%s",sp,tmp);
        unlink(source);
    }
    RETURNV(1);
}
int resetdisk(uchar d)
{
	ENTRY(4800);
I   mov ah,0
I   mov dl,d
I	int 0x13
I   jnc resetok
I   mov ax,0
I   jmp resetxit
resetok:
I   mov ax,1
resetxit:
	RETURNV(_AX);
}
int getdiskinfo(uchar d)
{
 	int i;
 	union REGS ir, or;
 	struct SREGS sr;
	ENTRY(4810);

 	for (i=0;i<RESET_NO+DISK_IO_NO;i++) {
 		if (resetdisk(d)) {
 			ir.h.ah=0x08; ir.h.dl=d; int86(0x13,&ir,&or);
 			if (or.x.cflag==0) {
 				G_di.t=(((or.h.cl&0xc0)<<2)|or.h.ch);
 				G_di.s=or.h.cl&0x3f;
 				G_di.h=or.h.dh;
				do {
					ir.h.ah=0x18;
					ir.x.cx=or.x.cx;
 					ir.h.dh=or.h.dh;
					ir.h.dl=d;
					int86x(0x13,&ir,&or,&sr);
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
int write_ss(uchar d,uchar h,uchar t,uchar s,uchar n,uchar far *b)
{
	uint i,ms2b,sb,ob,o4;
	union REGS ir,or;
	struct SREGS sr;
	ENTRY(4820);

	if (h>G_di.h||t>G_di.t+1||s>G_di.s||n>G_di.s) RETURNV(1);
	ms2b=(t>>2)&0xC0; sb=FP_SEG(b); ob=FP_OFF(b);
	o4=ob; sb+=((o4>>4)&0x0FFF); ob=(ob&0x000F); segread(&sr);
	for (i=0;i<RESET_NO+DISK_IO_NO;i++) {
		ir.x.ax=0x0300|n; ir.x.cx=(t<<8)|s|ms2b; ir.x.dx=(h<<8)|d;
		sr.es=sb; ir.x.bx=ob; int86x(0x13,&ir,&or,&sr);
		if (or.x.cflag==0) {
			RETURNV(OK);
		} else {
 			resetdisk(d);
		}
	}
	RETURNV(or.h.ah);
}
int format_track(uint d,uint h,uint c)
{
	int i,k;
	uint ms2b_cyl_no;
	uint seg_buf;
	uint off_buf;
	uint off_4;
	char far *afl_b; // address field list
	char far *afl_2b;
	char far *afl_ptr;
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
		ir.x.ax=0x0500|((d<0x80)?G_di.s:3);
		ir.x.cx=(c<<8)|ms2b_cyl_no;
		ir.x.dx=(h<<8)|(d&0xff);
		sr.es=seg_buf; ir.x.bx=off_buf;
		int86x(0x13,&ir,&or,&sr);
		if (or.x.cflag==0) {
		 	free(afl_b); RETURNV(OK);
		} else {
	 		resetdisk(d);
		}
 	}
 	free(afl_b);
 	RETURNV(or.h.ah);
}
// format disk "BACKUP"
int formatdisk(int d,int q)
{
	int i,j;
	IFPTR old1E;
	ENTRY(4840);
	old1E=getvect(0x1E);
	if (getdiskinfo(d)) RETURNV(-1000);
	sendmsg("OUTPUT1",'P',440,80,"FLOPPY.BMP");
	sendmsg("OUTPUT1",'A',3);
	if (!q) {
		for (i=0;i<=G_di.t;i++) {
			for (j=0;j<=G_di.h;j++) {
				if (format_track(d,j,i)) {
					setvect(0x1E,old1E);
					RETURNV(1+i*2+j);
				}
				sendmsg("OUTPUT1",'b',440,80+i*2+j,620,81+i*2+j);
 			}
 		}
	}
	if (write_ss(d,0,0,1,1,G_bootsec)) {
	 	setvect(0x1E,old1E);
		RETURNV(-1);
	}
	sendmsg("OUTPUT1",'b',440,232,620,233);
	for (i=1;i<18;i++) {
		memset(G_wbuf,0,512);
		if ((i==1)||(i==10)) { G_wbuf[0]=0xF0; G_wbuf[1]=G_wbuf[2]=0xFF; } 
		if (write_ss(d,0,0,i+1,1,G_wbuf)) {
			setvect(0x1E,old1E);
			RETURNV(0-(i+1));
		}
		sendmsg("OUTPUT1",'b',440,232+i/2,620,233+i/2);
	}
	for (i=0;i<15;i++) {
		if (write_ss(d,1,0,i+1,1,G_wbuf)) {
			setvect(0x1E,old1E);
			RETURNV(0-(i+19));
		}
		sendmsg("OUTPUT1",'b',440,241+i,620,242+i);
	}
	sendmsg("OUTPUT1",'b',440,241+i,620,242+i);
	sendmsg("OUTPUT1",'A',0);
	setvect(0x1E,old1E);
 	RETURNV(0);
}
// disk control routine
int dis_control(int type,va_list ap)
{
    int retval=0,i;
    unsigned long l;
    unsigned char c,dtype;
    unsigned char *p;
    unsigned char *s;
	ENTRY(4850);

    harderr(handler);
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
			p=va_arg(ap,char *);
			c=(*p-'A');
			if (formatdisk(c,0)) {
            	retval=0;
			} else {
            	retval=1;
			}
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
		case 'x' :
            p=va_arg(ap,char *);
            s=va_arg(ap,char *);
    		if (!findfile(p,s)) {
				retval=0;
			} else {
				sprintf(p,"%s",G_filesfd[i]);
			    for (i=1;i<G_numfd;i++) {
					strcat(p," ");
					strcat(p,G_filesfd[i]);
				}
				retval=strlen(p);
			}
            break;

    }
    RETURNV(retval);
}
#pragma option -p.

