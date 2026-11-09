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

INT G_inerrhand=0;
#define _HARDERR_FAIL 3

#pragma warn -par
// critical error handler
INT handler(INT err,INT ax,INT bp,INT si)
{
    hardresume(_HARDERR_FAIL);
    return(_HARDERR_FAIL);
}
#pragma warn +par

#ifdef USINGDD
// true if the disk has been changed
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
// read the disk data
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
// write the disk data
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
// get the disk data information
INT getdinfo(void)
{
	ENTRY(4600);
    if (readdd(&G_diskinfo)) RETURNV(0);
    if (calccheck()!=G_diskinfo.check) RETURNV(0);
    G_ddread=1;
    RETURNV(1);
}
// put the disk data information
INT putdinfo(INT rawput)
{
	ENTRY(4610);
    if ((!(rawput))&&(calccheck()!=G_diskinfo.check)) RETURNV(0);
    if (writedd(&G_diskinfo)) RETURNV(0);
    RETURNV(1);
}
// check the disk data information
INT checkdinfo(void)
{
	ENTRY(4620);
    if (readdd(&G_chekinfo)) RETURNV(0);
    if (memcmp(&G_diskinfo,&G_chekinfo,512)) RETURNV(0);
    RETURNV(1);
}
// set the disk password information
void setpass(CHAR *p)
{
    INT i=0;
    CHAR tmp[5];
	ENTRY(4630);
    sprintf(tmp,"%4.4s",p);
    for (i=0;i<5;i++) G_diskinfo.pass[i]=tmp[i]^(0x55<<i);
	RETURN;
}
// get the disk password information
void getpasswd(CHAR *p)
{
    INT i=0;
    CHAR tmp[5];
	ENTRY(4640);
    for (i=0;i<5;i++) tmp[i]=G_diskinfo.pass[i]^(0x55<<i);
    for (i=0;i<5;i++) if (tmp[i]!=' ') p[i]=tmp[i]; else p[i]=0;
	RETURN;
}
// calculate the checksum for the disk data information
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
// set the disk data information
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
// creat a crc file
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
// open a semaphore file
INT opensem(CHAR *path,CHAR *name)
{
    CHAR file[80];
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
// get a semaphore file status
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

// compare the dates of two files
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
// check the CRC of a file
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
// RETURN the disk data information
INT retdinfo(CHAR type,void *data)
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
// setup new disk data information
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
// generate a * file
INT genufile(CHAR *sp,CHAR *s,INT saverest)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR tmp[15];
    CHAR source[80];
    CHAR dest[80];
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
INT resetdisk(UCHAR d)
{
	ENTRY(4800);
I   mov ah,0
I   mov dl,d
I	INT 0x13
I   jnc resetok
I   mov ax,0
I   jmp resetxit
resetok:
I   mov ax,1
resetxit:
	RETURNV(_AX);
}
INT getdiskinfo(UCHAR d)
{
 	INT i;
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
INT formatdisk(INT d,INT q)
{
	INT i,j;
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
#endif // def USINGDD
// find files from wild cards *.??? etc.
INT findfile(CHAR *path,CHAR *name)
{
    struct ffblk f;
    CHAR tmp[80];
    INT done=0;
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
INT copyfile(CHAR *s,CHAR *sp,CHAR *dp)
{
    INT fi,fo,i;
    INT nb;
    CHAR *buf;
    CHAR source[80];
    CHAR dest[80];
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
INT renamefiles(CHAR *p,CHAR *s,CHAR *d)
{
    INT i,rv=1;
    CHAR source[80];
    CHAR dest[80];
    CHAR tmp[10],tmp1[15],*t;
	ENTRY(4770);
    sendmsg("DBM",'ca');
    harderr(handler);
    strcpy(tmp1,d);    
    t=strchr(tmp1,'.');
    if ((t==NULL)||(*(t+1)=='*')) {
        if (*(t+1)=='*') *t=0;
        if (!findfile(p,s)) RETURNV(0);
        for (i=0;i<G_numfd;i++) {
            t=strchr(G_filesfd[i],'.');
            if (t!=NULL) {
                strcpy(tmp,t+1);
                sprintf(source,"%s%s",p,G_filesfd[i]);
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
    sendmsg("DBM",'RI');
    return(rv);
}
// delete file(s) function 
INT delfile(CHAR *s,CHAR *sp)
{
    INT i;
    CHAR source[80];
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
// disk control routine
INT dis_control(INT type,va_list ap)
{
    INT retval=0;
    UCHAR *p;
    UCHAR *s;
    UCHAR *d;
    CHAR tmp[80];
	ENTRY(4850);

    harderr(handler);
    switch (type) {

#ifdef USINGDD

        case 'U' :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
            retval=genufile(p,s,va_arg(ap,INT));
            break;
        case 'S' :
            dtype=va_arg(ap,CHAR);
            retval=setdinfo(dtype,va_arg(ap,void *));
            break;

        case 'G' :
            dtype=va_arg(ap,CHAR);
            retval=retdinfo(dtype,va_arg(ap,void *));
            break;

        case 'F' :
			p=va_arg(ap,CHAR *);
			c=(*p-'A');
			if (formatdisk(c,0)) {
            	retval=0;
			} else {
            	retval=1;
			}
            break;

        case 'P' :
            i=va_arg(ap,INT);
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

        case 'd' :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
            retval=datechk(p,s,va_arg(ap,CHAR *));
            break;

		case 'x' :
            p=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
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
#else   // def USINGDD

        case 'I' :
            retval=1;
            break;

#endif // def USINGDD

        case 's' :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
//            printf("Deleting %sTEMPSWAP.*\n",(CHAR *)p);
            delfile((CHAR *)p,"TEMPSWAP.*");
            sprintf(tmp,"%s.*",(CHAR *)s);
//            printf("renameing %s %s TEMPSWAP\n",(CHAR *)p,tmp);
            renamefiles((CHAR *)p,tmp ,"TEMPSWAP");
            sprintf(tmp,"%s.*",(CHAR *)d);
//            printf("renameing %s %s %s\n",(CHAR *)p,tmp,s);
            renamefiles((CHAR *)p,tmp ,(CHAR *)s );
//            printf("renameing %s TEMPSWAP.* %s\n",(CHAR *)p,d);
            renamefiles((CHAR *)p,"TEMPSWAP.*",(CHAR *)d );
//            printf("Done.\n",(CHAR *)p,d);
            retval=1;
            break;

        case 'r' :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            retval=renamefiles((CHAR *)p,(CHAR *)s,(CHAR *)d);
            break;

        case 'C' :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            (CHAR *)d=va_arg(ap,CHAR *);
            retval=copyfile((CHAR *)p,(CHAR *)s,(CHAR *)d);
            break;
        case 'D' :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=delfile((CHAR *)p,(CHAR *)s);
            break;
        case 'T' :
            (CHAR *)p=va_arg(ap,CHAR *);
            (CHAR *)s=va_arg(ap,CHAR *);
            retval=findfile((CHAR *)p,(CHAR *)s);
            break;
        case 'E' :
            retval=1;
            break;
    }
    RETURNV(retval);
}
#pragma option -p.

