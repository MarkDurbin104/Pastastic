#define NETDEV_C
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <memory.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "control.h"
#include "config.h"
#include "netdev.h"
#include "message.h"

#define NUMNODES 32

typedef struct {
	INT  user;
	CHAR name[17];
} NODENAME;

NODENAME *G_nodes=NULL;
INT G_fttonode=0;
INT G_ftinprog=0;


void addnode(CHAR *node)
{
	INT i;
	ENTRY(5270);
	for (i=0;i<NUMNODES;i++) if (!strcmp(G_nodes[i].name,node)) RETURN;
	for (i=0;i<NUMNODES;i++) {
		if (G_nodes[i].user==(-1)) {
			strcpy(G_nodes[i].name,node);
			sendmsg("NETINDI",'o',0,i,"%s",node);
			G_nodes[i].user=0;
			RETURN;
		}
	}
	RETURN;
}

void delnode(CHAR *node)
{
	INT i;
	ENTRY(5280);
	for (i=0;i<NUMNODES;i++) {
		if (!strcmp(G_nodes[i].name,node)) {
			G_nodes[i].user=(-1);
			G_nodes[i].name[0]=0;
			RETURN;
		}
	}
	RETURN;
}

void adduser(CHAR *buf)
{
	INT i;
	INT user;
	CHAR *node;
	ENTRY(5290);

	user=atoi(buf);
	node=buf+2;

	for (i=0;i<NUMNODES;i++) {
		if (!strcmp(G_nodes[i].name,node)) {
			G_nodes[i].user=user;
			RETURN;
		}
	}
	RETURN;
}

void deluser(CHAR *buf)
{
	INT i;
	INT user;
	ENTRY(5300);
	
	user=atoi(buf);
	for (i=0;i<NUMNODES;i++) {
		if (G_nodes[i].user==user) {
			G_nodes[i].user=0;
		}
	}
	RETURN;
}

INT indos(void)
{
	union REGS r;
	struct SREGS s;
	static CHAR *csecflg=NULL;
	ENTRY(5310);
	if (csecflg==NULL) {
		r.x.ax=0x3400;
		int86x(0x21,&r,&r,&s);
		csecflg=MK_FP(s.es,r.x.bx);
		csecflg--;
	}
	RETURNV(*((INT *)csecflg));
}
// get the datagram checksum
UINT getcheck(NCB *n)
{
    CHAR *s;
    INT l,i;
    UINT c=0;
	ENTRY(5320);

    s=(CHAR *)n->buf;
    l=n->len;

    for (i=0;i<4;i++) { c^=*(s++); c<<=1; }
    s+=2;
    i+=2;
    for (;i<l;i++) { c^=*(s++); c<<=1; }

    RETURNV(c);
}
// RETURN the datagram checksum is OK
INT checksum(NCB *n)
{
    UINT *b;
	ENTRY(5330);

    b=(UINT *)n->buf;
    b+=2;
    RETURNV(*b==getcheck(n));
}
// set the datagram checksum 
UINT addchek(NCB *n)
{
    UINT *b;
	ENTRY(5340);

    b=(UINT *)n->buf;
    b+=2;
    *b=getcheck(n);
    RETURNV(*b);
}
// clear a datagram buffer
void cleardgb(INT index)
{
	ENTRY(5350);
    if (index>=MAXDGBUFS) RETURN;
    if (G_dgb[index].s!=0) {
        G_dgb[index].t=0;
        G_dgb[index].s=0;
        G_dgb[index].sn=0;
        if (G_dgb[index].n->comp==0xFF) nbioscancel(G_dgb[index].n);
        if (G_dgb[index].b!=NULL) FREE(G_dgb[index].b);
        G_dgb[index].b=NULL;
        if (G_dgb[index].n!=NULL) FREE(G_dgb[index].n);
        G_dgb[index].n=NULL;
    }
	RETURN;
}
// find a free datagram buffer
INT finddgb(INT len)
{
	ENTRY(5360);
    if ((++G_ldgb)==MAXDGBUFS) G_ldgb=0;

	if (!G_dgb[G_ldgb].s) {
        G_dgb[G_ldgb].b=MALLOC(len);
        if (G_dgb[G_ldgb].b==NULL) RETURNV(-1);
        memset(G_dgb[G_ldgb].b,0,len);
        G_dgb[G_ldgb].n=MALLOC(sizeof(NCB));
        if (G_dgb[G_ldgb].n==NULL){
            FREE(G_dgb[G_ldgb].b);
            RETURNV(-1);
        }
        CLRNCB(G_dgb[G_ldgb].n);
        G_dgb[G_ldgb].s='A';
        G_dgb[G_ldgb].sn=0;
        RETURNV(G_ldgb);
    }
    RETURNV(-1);
}
// datagram keybaord loop function
INT dgklf(void)
{
    INT i,j,sdone=0,rdone=0,zdone=0;
    INT s;
	CHAR tmp[81];
	ENTRY(5370);
  

 	i=G_ldgb;
    for (j=0;j<80;j++) {
		if ((++i)==MAXDGBUFS) i=0;
        if (G_dgb[i].s!=0) {
            tmp[i]=G_dgb[i].s;
        }
		else {
            tmp[i]='_';
        }
    }
    tmp[80]=0;
    s=sendmsg("NETINDI",'i');
    sendmsg("NETINDI",'S',1);
    sendmsg("NETINDI",'o',0,24,"%s",tmp);
    sendmsg("NETINDI",'S',s);
 
 	i=G_ldgb;
	if ((++i)==MAXDGBUFS) i=0;
	j=0;
    while (j<MAXDGBUFS) {
        switch (G_dgb[i].s) {
            case 'r' :
                if (!rdone) rdone=1;
                break;
            case 'Z' :
                if (!zdone) {
                    if (G_dgb[i].n->comp!=0xFF) {
                        cleardgb(i);
                        zdone=1;
                    }
                }
                break;
            case 'S' :
                if (!sdone) {
                    sdone=1;
			        if (G_dgb[i].n->comp!=0xFF) {
                        if ((--G_dgb[i].t)<=0) {
							G_dgb[i].t=DGTIMOUT;
	                        G_dgb[i].sn++;
	                        if (G_dgb[i].sn>DGNUMSEND) {
	                            cleardgb(i);
	                        } else {
	                            ((INT *)G_dgb[i].b)[1]=i;
	                            addchek(G_dgb[i].n);
	                            nbiossdgram(i);
							}
                        }
                    }
                }
                break;
            case 's' :
                if (!sdone) {
                    sdone=1;
                    if (G_dgb[i].sn>=1) {
				        if (G_dgb[i].n->comp!=0xFF)
							cleardgb(i);
                    } else {
                        ((INT *)G_dgb[i].b)[1]=i;
                        addchek(G_dgb[i].n);
                        nbiossdgram(i);
	                    G_dgb[i].sn++;
					}
                }
                break;
        }
        if (((sdone)&&(rdone))) break;
	    if ((++i)==MAXDGBUFS) i=0;
		j++;
    }
    if (!rdone) nbiosrdgram();    // if not waiting setup wait
				
	if ((G_ftinprog)&&(G_ftx.s==100)) {
		G_ftx.s=0;
		if (G_fttonode>=0) sendmsg("LAN",'S',G_nodes[G_fttonode].name,1,1,"",FILERXDONE);
		G_fttonode++;
		while (G_fttonode<NUMNODES) if (G_nodes[G_fttonode].user==(-1)) G_fttonode++; else break; 
		if (G_fttonode<NUMNODES) {
			nbiospdgram(G_nodes[G_fttonode].name,1,strlen(G_nodename)+1,G_nodename,FILEUPDATE);
		} else {
			G_ftinprog=0;
		}
	}
	if ((G_retry!=NULL)&&(G_postrout!=NULL)) {
//		sound(5000);
//		delay(200);
//		nosound();
		_ES=FP_SEG(G_retry);
		_BX=FP_OFF(G_retry);
		(G_postrout)();
	}
    RETURNV(1);
}
// copy a string with padding for NETBIOS names
void nbiosstrcpy(CHAR *ret,CHAR *name,INT len)
{
    INT l,i;
    UCHAR hi,lo;
    UCHAR nm[33];
	ENTRY(5400);

    memset(ret,0,len);

    if (name[0]!='#') {
        if (name[0]==0) {
            memcpy(ret,name,len);
        }
        else {
            memcpy(ret,name,strlen(name));
        }
    }
    else {
        memset(ret,0,len);
        strcpy(nm,&name[1]);
        strupr(nm);
        l=strlen(nm);
        for (i=0;i<l/2;i++) {
            hi=nm[((l-1)-i*2)-1]-'0';
            if (hi>9) hi-=7;
            lo=nm[(l-1)-i*2]-'0';
            if (lo>9) lo-=7;
            ret[(len-1)-i]=(hi<<4)|lo;
        }
    }
}
// issue a NETBIOS request
INT nbiosreq(NCB *n)
{
    struct REGPACK  r;
	ENTRY(5410);

    r.r_es=FP_SEG(n);
    r.r_bx=FP_OFF(n);

    intr(0x5C,&r);

    RETURNV(n->ret);
}
// issue a NETBIOS reset
INT nbiosrst(void)
{
    NCB n;
	ENTRY(5420);

    CLRNCB(&n);
    n.cmd=NBIOS_RESET;
    n.lsn=0;
    n.num=0;
    n.anum=0;
    RETURNV(nbiosreq(&n));
}
// issue a NETBIOS adaptor status request
INT nbiosastat(UCHAR *name,ASTAT *a)
{
    NCB n;
    INT l,i;
    UCHAR hi,lo;
    UCHAR nm[33];
	ENTRY(5430);
    

    CLRNCB(&n);
    n.cmd=NBIOS_ADAPTER_STATUS;
    n.anum=0;
    n.buf=(void *)a;
    n.len=sizeof(*a);
    nbiosstrcpy(n.cnam,name,16);

//    if (!nbiosreq(&n)) prastat(&a);
    nbiosreq(&n);

    RETURNV(n.ret);
}
// issue a NETBIOS add name request
INT nbiosaddname(CHAR *name)
{
    NCB n;
	ENTRY(5440);

    CLRNCB(&n);
    n.cmd=NBIOS_ADD_NAME;
    n.anum=0;
    nbiosstrcpy(n.anam,name,16);

    nbiosreq(&n);

    RETURNV(n.ret);
}
// issue a NETBIOS delete name request
INT nbiosdelname(CHAR *name)
{
    NCB n;
	ENTRY(5450);

    CLRNCB(&n);
    n.cmd=NBIOS_DELETE_NAME;
    n.anum=0;
    nbiosstrcpy(n.anam,name,16);

    nbiosreq(&n);

    RETURNV(n.ret);
}
// issue a NETBIOS cancel request
INT nbioscancel(NCB *cn)
{
    NCB n;
	ENTRY(5460);

    CLRNCB(&n);
    n.cmd=NBIOS_CANCEL;
    n.buf=(void *)cn;
    n.anum=0;

    nbiosreq(&n);

    RETURNV(n.ret);
}
// issue a NETBIOS add group name request
INT nbiosaddgname(CHAR *name)
{
    NCB n;
	ENTRY(5470);

    CLRNCB(&n);
    n.cmd=NBIOS_ADD_GROUP_NAME;
    n.anum=0;
    nbiosstrcpy(n.anam,name,16);

    nbiosreq(&n);

    RETURNV(n.ret);
}
// print network error code
CHAR *nerror(INT v)
{
    static CHAR tmp[10];
	ENTRY(5480);
    sprintf(tmp,"0x%02X   %d",v,v);
    RETURNV(tmp);
}
// issue a NETBIOS send datagram request
INT nbiossdgram(INT index)
{
	INT i;
	ENTRY(5490);
    if ((G_dgb[index].s=='S')||(G_dgb[index].s=='s')) {
        i=nbiosreq(G_dgb[index].n);
        RETURNV(i);
	}
    RETURNV(0);
}
// setup a NETBIOS send datagram request
INT nbiospdgram(CHAR *name,INT num,INT len,CHAR *buf,INT type)
{
    INT i;
	ENTRY(5500);
    if ((i=finddgb(len+(3*sizeof(INT))))==(-1)) RETURNV(i);

    G_dgb[i].t=1;
	if ((type&0x80)!=0) G_dgb[i].s='s'; else G_dgb[i].s='S'; 
    *((INT *)G_dgb[i].b)=type;
    *(((INT *)G_dgb[i].b)+1)=i;
    memcpy(&G_dgb[i].b[sizeof(INT)*3],buf,len);

    G_dgb[i].n->cmd=NBIOS_SEND_DATAGRAM|NO_WAIT;
    G_dgb[i].n->anum=0;
    G_dgb[i].n->num=num;
    G_dgb[i].n->buf=G_dgb[i].b;
    G_dgb[i].n->len=len+(3*sizeof(INT));
    nbiosstrcpy(G_dgb[i].n->cnam,name,16);
    addchek(G_dgb[i].n);
    RETURNV(i);
}
// send acknoledge packet
INT sendack(CHAR *name,INT buf)
{
	INT i;
	ENTRY(5510);
    G_ackpak[1]=buf;

    G_ackncb.cmd=NBIOS_SEND_DATAGRAM|NO_WAIT;
    G_ackncb.anum=0;
    G_ackncb.num=1;
    G_ackncb.buf=G_ackpak;
    G_ackncb.len=6;
    nbiosstrcpy(G_ackncb.cnam,name,16);

    addchek(&G_ackncb);
    nbiosreq(&G_ackncb);

    RETURNV(1);
}
// NETBIOS receive datagram post interrupt routine
void interrupt postroutine(void)
{
    NCB *n;
    INT i,*b;
//	ENTRY(5520);
    G_inpost=1;    
    n=MK_FP(_ES,_BX);

	if (G_rdgb==(-1)) {
	    sendmsg("NETINDI",'o',0,0,"called with no rxbuf");
	    G_inpost=0;    
	    G_donepost=(-1);
		RETURN;
	}
	i=G_rdgb;
	G_rdgb=(-1);
    if (n==G_dgb[i].n) {
        if (checksum(n)) {
            b=(INT *)n->buf;
			switch (*b) {
				case DGRAMACK :
                	b++;
                	if (G_dgb[*b].s) G_dgb[*b].s='Z';
                	G_dgb[i].s='Z';
					break;
				case WHOSTHERE :
                	G_dgb[i].s='R';
					break;
				default :
                	b++;
                	G_dgb[i].s='R';
                	sendack(n->cnam,*b);
			}
            G_donepost=1;
            G_inpost=0;    
            RETURN;
        }
        sendmsg("NETINDI",'o',0,3,"ERROR IN checksum %Fp %d",n,checksum(n));
        G_dgb[i].s='Z';
    }
    sendmsg("NETINDI",'o',0,3,"ERROR IN NCB * %Fp %d",n,checksum(n));
    G_inpost=0;    
    G_donepost=(-1);
}
// setup a NETBIOS receive datagram request
INT nbiosrdgram(void)
{
    INT i;
	ENTRY(5530);

    if ((i=finddgb(MAXDGSIZE))==(-1)) RETURNV(i);

    G_dgb[i].s='r';
    G_dgb[i].n->cmd=NBIOS_RECEIVE_DATAGRAM|NO_WAIT;
    G_dgb[i].n->anum=0;
    G_dgb[i].n->num=0xFF;
    G_dgb[i].n->buf=(void *)G_dgb[i].b;
    G_dgb[i].n->len=MAXDGSIZE;
    G_dgb[i].n->post=postroutine;
    
    G_rdgb=i;

    nbiosreq(G_dgb[i].n);
    
    RETURNV(i);
}
INT gettrxncb(void)
{
	static INT i=0;
	ENTRY(5540);
	if ((++i)==NUMTRXNCB) i=0;
	G_bufuse=i;
	if (G_ftrxncb[i].comp!=0xFF) RETURNV(i);
	G_ftx.er=(-100);
	RETURNV(-1);
}

INT terror(INT er)
{
	ENTRY(5550);
	if (er==10) er=0;
	if (G_ftx.fd) close(G_ftx.fd);
	G_ftx.fd=0;
	G_ftx.nd=0;
	G_ftx.s=100;
	G_ftx.numf=G_ftx.curf=0;
	G_ftx.er=er;
    G_infrtxpost=0;
	RETURNV(1);
}
INT topen(void)
{
	ENTRY(5560);
	G_ftx.fd=open(G_ftx.fl[G_ftx.curf],O_RDONLY|O_BINARY);
	G_ftx.s=3;
	G_ftx.len=read(G_ftx.fd,G_ftx.buf,BUFLEN);
	if (G_ftx.len<0) G_ftx.len=0;
	nbioswrite(G_ftx.nd,G_ftx.buf,G_ftx.len);
	G_infrtxpost=0;
	RETURNV(1);
}
INT tread(INT len)
{
	ENTRY(5570);
	G_ftx.len=len;
	if (G_ftx.len<=0) {
		G_ftx.s=4;
		RETURNV(0);
	} 
	G_ftx.len=read(G_ftx.fd,G_ftx.buf,BUFLEN);
	if (G_ftx.len<0) G_ftx.len=0;
	nbioswrite(G_ftx.nd,G_ftx.buf,G_ftx.len);
	G_infrtxpost=0;
	RETURNV(1);
}
INT tclose(void)
{
	ENTRY(5580);
	close(G_ftx.fd);
	G_ftx.fd=0;
	G_ftx.curf++;
	G_ftx.s=5;
	RETURNV(0);
}
INT texit(void)
{
	CHAR *file;
	ENTRY(5590);
	if (G_ftx.curf>=G_ftx.numf) {
		G_ftx.s=0;
		nbiosclose(G_ftx.nd);
		G_ftx.nd=0;
		G_ftx.s=100;
		G_ftx.numf=G_ftx.curf=0;
	} else {
		file=&G_ftx.fl[G_ftx.curf][G_ftx.pl];
		nbioswrite(G_ftx.nd,file,strlen(file)+1);
		G_ftx.s=2;
	}
	G_infrtxpost=0;
	RETURNV(1);
}
INT ropen(void)
{
	ENTRY(5600);
	if (G_frxfile[0]=='*') {
		G_ftx.s=0;
		nbiosclose(G_ftx.nd);
		G_ftx.nd=0;
		G_infrtxpost=0;
		RETURNV(1);
	}
	G_ftx.fd=open(G_frxfilep,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
	G_ftx.s=3;
	RETURNV(0);
}
INT rread(void)
{
	ENTRY(5610);
	nbiosread(G_ftx.nd,G_ftx.buf,BUFLEN);
	G_ftx.s=4;
	G_infrtxpost=0;
	RETURNV(1);
}
INT rwrite(INT len)
{
	ENTRY(5620);
	G_ftx.len=len;
	if (G_ftx.len<=0) {
		G_ftx.len=0;
		G_ftx.s=5;
		RETURNV(0);
	}
	G_ftx.len=write(G_ftx.fd,G_ftx.buf,G_ftx.len);
	nbiosread(G_ftx.nd,G_ftx.buf,BUFLEN);
	G_infrtxpost=0;
	RETURNV(1);
}
INT rclose(void)
{
	ENTRY(5630);
	close(G_ftx.fd);
	G_ftx.fd=0;
	G_ftx.s=6;
	RETURNV(0);
}
INT rexit(void)
{
	ENTRY(5640);
	G_frxfile[0]='*';
	G_ftx.s=2;
	nbiosread(G_ftx.nd,G_frxfile,80);
	G_infrtxpost=0;
	RETURNV(1);
}
// NETBIOS CALL/SEND post interrupt routine
void interrupt ftxpost(void)
{
    NCB *n;
    n=MK_FP(_ES,_BX);
//	ENTRY(5650);

    G_infrtxpost=1;
	if (indos()) {
		G_retry=n;
	} else {
		G_retry=NULL;
		if (n->ret)     if (terror(n->ret)) RETURN;
		if (G_ftx.s==1) { G_ftx.nd=n->lsn; G_ftx.s=5; }
		if (G_ftx.s==2) if (topen()      ) RETURN;
		if (G_ftx.s==3) if (tread(n->len)) RETURN;
		if (G_ftx.s==4) if (tclose()     ) RETURN;
		if (G_ftx.s==5) if (texit()      ) RETURN;
	}
    G_infrtxpost=0;
}
// NETBIOS LISTEN/RECEIVE post interrupt routine
void interrupt frxpost(void)
{
    NCB *n;
    n=MK_FP(_ES,_BX);
//	ENTRY(5660);

	G_infrtxpost=1;

	if (indos()) {
		G_retry=n;
	} else {
		G_retry=NULL;
		if (n->ret)     if (terror(n->ret)) RETURN;
		if (G_ftx.s==1) { G_ftx.nd=n->lsn; G_ftx.s=6; }
		if (G_ftx.s==2) if (ropen()       ) RETURN;
		if (G_ftx.s==3) if (rread()       ) RETURN;
		if (G_ftx.s==4) if (rwrite(n->len)) RETURN;
		if (G_ftx.s==5) if (rclose()      ) RETURN;
		if (G_ftx.s==6) if (rexit()       ) RETURN;
	}
    G_infrtxpost=0;
}
INT nbiosopen(CHAR *name,INT cl)
{
    NCB *n;
	INT i;
	ENTRY(5670);

	if ((i=gettrxncb())==(-1)) RETURNV(0);
	n=&(G_ftrxncb[i]);

    CLRNCB(n);

	if (cl) {
	    n->cmd=NBIOS_CALL|NO_WAIT;
		G_postrout=ftxpost;
	} else {
		n->cmd=NBIOS_LISTEN|NO_WAIT;
		G_postrout=frxpost;
	}
    n->anum=0;
    nbiosstrcpy(n->cnam,name,16);
    nbiosstrcpy(n->anam,G_nodename,16);
    n->sto=n->rto=30;
	n->post=G_postrout;
    nbiosreq(n);
    RETURNV(1);
}
INT nbiosclose(INT lsn)
{
    NCB *n;
	INT i;
	ENTRY(5680);

	if ((i=gettrxncb())==(-1)) RETURNV(0);
	n=&(G_ftrxncb[i]);

    CLRNCB(n);
    n->cmd=NBIOS_HANG_UP|NO_WAIT;
    n->anum=0;
    n->lsn=lsn;
	n->post=G_postrout;
    nbiosreq(n);
	
    RETURNV(1);
}
INT nbioswrite(INT lsn,CHAR *buf,INT len)
{
    NCB *n;
	INT i;
	ENTRY(5690);

	if ((i=gettrxncb())==(-1)) RETURNV(0);
	n=&(G_ftrxncb[i]);

    CLRNCB(n);
    n->cmd=NBIOS_SEND|NO_WAIT;
    n->anum=0;
    n->lsn=lsn;
    n->buf=buf;
    n->len=len;
	n->post=G_postrout;

	nbiosreq(n);
	RETURNV(1);
}

INT nbiosread(INT lsn,CHAR *buf,INT len)
{
    NCB *n;
	INT i;
	ENTRY(5700);

	if ((i=gettrxncb())==(-1)) RETURNV(0);
	n=&(G_ftrxncb[i]);

    CLRNCB(n);
    n->cmd=NBIOS_RECEIVE|NO_WAIT;
    n->anum=0;
    n->lsn=lsn;
    n->buf=buf;
    n->len=len;
	n->post=G_postrout;

	nbiosreq(n);
	RETURNV(1);
}
INT nbiosgetfiles(CHAR *name,CHAR *path)
{
	ENTRY(5710);
	strcpy(G_frxfilep,path);
	G_frxfile=G_frxfilep+strlen(path);
	G_ftx.buf=G_txrxbuf;
	G_ftx.s=1;
	
	nbiosopen(name,0);
 	RETURNV(1);
}
INT nbiosputfiles(CHAR *name,CHAR *files,CHAR *path)
{
	CHAR tmp[80],*t;
	ENTRY(5720);

	t=strtok(files,", \t\r\n;");
	while (t!=NULL) {
		sprintf(tmp,"%s%s",path,t);
		G_ftx.fl[G_ftx.numf++]=strdup(tmp);
		t=strtok(NULL,", \t\r\n;");
	}
	G_ftx.curf=0;
	G_ftx.buf=G_txrxbuf;
	G_ftx.s=1;
	G_ftx.pl=strlen(path);
	nbiosopen(name,1);

 	RETURNV(1);
}
// recieve a NETBIOS datagram 
INT nbiosgdgram(INT *len,CHAR *buf)
{
    INT i;
    INT *b;
    INT type;
	CHAR tmp[20];
	ENTRY(5730);

    for (i=0;i<MAXDGBUFS;i++) {
        if (G_dgb[i].s=='R') {
			G_dgb[i].s='Z';
            *len=G_dgb[i].n->len-(sizeof(INT)*3);
            b=(INT *)G_dgb[i].n->buf;
            type=*b;
            b+=3;
            memcpy(buf,b,*len);
            cleardgb(i);
			switch (type) {
				case NODESTARTUP  :
					addnode(buf);
					break;
				case NODESHUTDOWN :	delnode(buf); break;
				case USERLOGON	  :	adduser(buf); RETURNV(type);
				case USERLOGOFF	  :	deluser(buf); RETURNV(type);
        		case FILERXDONE   : G_ftx.s=0;    RETURNV(type);
        		case FILEUPDATE   :
					nbiospdgram(G_toname,1,strlen(G_nodename)+1,G_nodename,FILETX);
					nbiosgetfiles(buf,G_database);
            		break;
        		case FILETX       :
					nbiosputfiles(buf,G_frxfilep,G_database);
					break;
				case WHOSTHERE :
		            nbiospdgram(G_toname,1,strlen(G_nodename)+1,G_nodename,NODESTARTUP);
					if (G_uid) {
						sprintf(tmp,"%2d %s",G_uid,G_nodename);
						nbiospdgram(G_toname,1,strlen(tmp)+1,tmp,USERLOGON);
					} else {
						sprintf(tmp,"%2d %s",G_luid,G_nodename);
						nbiospdgram(G_toname,1,strlen(tmp)+1,tmp,USERLOGOFF);
					}
					break;
				default :
					RETURNV(type);
			}
        }
    }
    RETURNV(0);
}
// network input routine
INT net_input(void)
{
    ASTAT a;
	ENTRY(5740);
    RETURNV(nbiosastat("*",&a));
} 
// network reset routine
INT net_reset(void)
{
	ENTRY(5750);
    RETURNV(nbiosrst());
} 
// network shutdown routine
INT net_shutdown(void)
{
    INT i;
	ENTRY(5760);
    sendmsg("INPUT1",'D',dgklf);
    for (i=0;i<MAXDGBUFS;i++) {
        cleardgb(i);
    }
	if (memsig(G_frxfilep)) FREE(G_frxfilep);
	if (memsig(G_txrxbuf))  FREE(G_txrxbuf); 
	if (memsig(G_ftrxncb))  FREE(G_ftrxncb);
	if (memsig(G_nodes))    FREE(G_nodes);

	if (G_dgb!=NULL) {
		FREE(G_dgb);
		G_dgb=NULL;
	}

    nbiosdelname(G_system);
    nbiosdelname(G_nodename);
    nbiosdelname(G_sessname);
    RETURNV(1);
}
// network startup routine
INT net_startup(INT node)
{
	INT i;
	ENTRY(5770);
	if (G_dgb==NULL) G_dgb=MALLOC(MAXDGBUFS*sizeof(DGRAMBUF));
	if (G_dgb==NULL) RETURNV(0);
    memset(G_dgb,0,sizeof(G_dgb));
    sendmsg("INPUT1",'A',2,dgklf);
	do {
		sprintf(G_nodename,"%s%02X",G_system,node);
		node++;
    } while (nbiosaddname(G_nodename));
	node--;
	do {
		sprintf(G_sessname,"S%s%02X",G_system,node);
		node++;
    } while (nbiosaddname(G_sessname));
    nbiosaddgname(G_system);

	if ((G_frxfilep=MALLOC(256))==NULL) RETURNV(0);
	if ((G_txrxbuf=MALLOC(BUFLEN+256))==NULL) RETURNV(0);
	if ((G_ftrxncb=MALLOC(NUMTRXNCB*sizeof(NCB)))==NULL) RETURNV(0);
	if ((G_nodes=MALLOC(NUMNODES*sizeof(NODENAME)))==NULL) RETURNV(0);
	for (i=0;i<NUMNODES;i++) G_nodes[i].user=(-1);

	if (net_input()) RETURNV(0);

    RETURNV(1);
}
// network control routine
INT net_control(INT type,va_list ap)
{
    CHAR *name,*buf,*file,*path,tmp[20];
    INT num,len;
    INT retval=1;
    INT *alen;
	ENTRY(5780);

    switch (type) {

        case 'i' :
			retval=net_input();
			break;

        case 'r' :
			retval=net_reset();
			break;

        case 'I' :
            num=va_arg(ap,INT);
            retval=net_startup(num);
			if (G_isserver) {
	            nbiospdgram(G_toname,1,strlen(G_nodename)+1,G_nodename,WHOSTHERE);
			} else {
	            nbiospdgram(G_toname,1,strlen(G_nodename)+1,G_nodename,NODESTARTUP);
			}
            break;

        case 'S' :
            name=va_arg(ap,CHAR *);
            num=va_arg(ap,INT);
            len=va_arg(ap,INT);
            buf=va_arg(ap,CHAR *);
            retval=nbiospdgram(name,num,len,buf,va_arg(ap,INT));
            break;

        case 'R' :
            alen=va_arg(ap,INT *);
            retval=nbiosgdgram(alen,va_arg(ap,CHAR *));
            break;

        case 'D' :
            retval=nbiosdelname(va_arg(ap,CHAR *));
            break;

        case 'N' :
            retval=nbiosaddname(va_arg(ap,CHAR *));
            break;

        case 'G' :
            retval=nbiosaddgname(va_arg(ap,CHAR *));
            break;

        case 'E' :
			if (!G_isserver) {
	            retval=nbiospdgram(G_toname,1,strlen(G_nodename)+1,G_nodename,NODESHUTDOWN);
				dgklf(); dgklf(); dgklf(); dgklf(); dgklf(); dgklf();
			}
            retval=net_shutdown();
            break;

        case 'F' :
			if (G_ftinprog) RETURNV(0);
            buf=va_arg(ap,CHAR *);
			memset(&G_ftx,0,sizeof(G_ftx));
			strcpy(G_frxfilep,buf);
			G_fttonode=(-1);
			G_ftx.s=100;
			G_ftinprog=1;
            break;

        case 'L' :
			if (!G_isserver) {
            	buf=va_arg(ap,CHAR *);
				sprintf(tmp,"%-2.2s %s",buf,G_nodename);
				retval=nbiospdgram(G_toname,1,strlen(tmp)+1,tmp,USERLOGON);
			}
            break;

        case 'l' :
			if (!G_isserver) {
    	        buf=va_arg(ap,CHAR *);
				sprintf(tmp,"%-2.2s %s",buf,G_nodename);
				retval=nbiospdgram(G_toname,1,strlen(tmp)+1,tmp,USERLOGOFF);
			}
            break;
    }
    RETURNV(retval);
} 
//___________________________________________________________________________

