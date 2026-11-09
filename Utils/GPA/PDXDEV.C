#define PDXDEV_C
#include <dos.h>
#include <dir.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <ctype.h>

#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "pxengine.h"

#include "types.h"
#include "message.h"
#include "control.h"
#include "config.h"
#include "function.h"
#include "dst.h"

#pragma option -p-
#include "pdxdev.h"
#define  FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

INT G_numopen=0;
INT dbexist(CHAR *name);
int fkeysize(int s, int n);
INT stquickget(UCHAR s,UCHAR f,CHAR *var);

#ifdef WIEN
 #ifdef DOS
 extern INT isbegintxn;
 #endif//DOS
 int gpabegin;
 extern void errorline (CHAR *e,INT type);
#endif//WIEN

UCHAR G_tempsbuf[500];
UCHAR G_lastsbuf[500];
INT   G_lastslen=0;
LONG  G_lastsrec=0;

//extern void mprintf(CHAR *fmt, ... );
void prerror(INT s,INT ep)
{
    switch (G_sstat[s].err) {
        case 31 :
            ep+=2;
            break;
        case 89 :
            ep+=3;
            break;
        default :
            ep++;
    }
}
//___________________________________________________________________________
// Truncate a numeric string at the decimal point
void dottrunc(CHAR *s)
{
	ENTRY(4240);
    while (*s) {
        if (*s=='.') {
            *s=0;
            break;
        }
        s++;
    }
	RETURN;
}
// initialise the database system
INT stinit(void)
{
    int a,b,c,d,e;
    char f;
	ENTRY(4250);
    if (G_sstat==NULL) {
        G_sstat=MALLOC(NUMSTORES*sizeof(STORESTAT));
        memset(G_sstat,0,NUMSTORES*sizeof(STORESTAT));
        for (a=0;a<G_nums;a++) {
            strcpy(G_sstat[a].name,G_store[a].name);
            c=0;
            for (b=0;b<G_store[a].numitem;b++) {
                G_sstat[a].fofs[b]=c;
                switch (G_lib[G_store[a].li[b]].type) {
                    case 1 :
                        c+=2;
                        break;
                    case 2 :
                        c+=8;
                        break;
                    case 3 :
                        c+=G_lib[G_store[a].li[b]].len;
                        break;
                }
            }
            G_sstat[a].len=c;
            if ((G_sstat[a].buf=MALLOC(c+1))==NULL)
                G_sstat[a].len=0;
            else
                memset(G_sstat[a].buf,0,c+1);
            for (b=0;b<G_store[a].numitem;b++) {
                switch (G_lib[G_store[a].li[b]].type) {
                    case 1 :
                    case 2 :
                        G_sstat[a].buf[G_sstat[a].fofs[b]]=0x80;
                        break;
                }
            }
            
        }
    }
    PXTblCreateMode(1);
    PXSetDefaults(32,32,64,64,64,DEFSORTORDER);
    PXGetDefaults(&a,&b,&c,&d,&e,&f);
//    G_swapsize=min(b,7);
    G_swapsize=min(b,10);
    printf("Pxdefaults = %d %d %d %d %d %d\n",a,b,c,d,e,f);

    if ((G_sstat[0].err=PXWinInit("PxEngine",PXSINGLECLIENT))!=PXSUCCESS) { // PXSINGLECLIENT
        prerror(0,0);
        RETURNV(0);
    }
//    sendmsg("INPUT1",MESSAGE_A,2,receiverec);
    RETURNV(1);
}
// reinitialise the database system
INT streinit(void)
{
    int a,b,c,d,e;
    char f;
	ENTRY(4260);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURNV(0);
    PXTblCreateMode(1);
    PXGetDefaults(&a,&b,&c,&d,&e,&f);
//    G_swapsize=min(b,7);
    G_swapsize=min(b,10);
    if (PXWinInit("PxEngine",PXSINGLECLIENT)!=PXSUCCESS) RETURNV(0); // PXSINGLECLIENT PXSHARED
    RETURNV(1);
}
// shutdown the database system
INT stexit(void)
{
    int a;
	ENTRY(4270);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURNV(0);
//    sendmsg("INPUT1",MESSAGE_D,receiverec);
    if (G_sstat!=NULL) {
        for (a=0;a<G_nums;a++) if (G_sstat[a].buf!=NULL) FREE(G_sstat[a].buf);
        FREE(G_sstat);
        G_sstat=NULL;
    }
    RETURNV(1);
}
// RETURN the number of records in table 'name'
LONG stnumrec(CHAR *name)
{
    LONG nr=0L;
    static INT s;
    static CHAR lname[10];
	ENTRY(4280);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s]) RETURNV(msnumrec(name));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0L);
    if ((G_sstat[s].err=PXTblNRecs(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(nr);
    RETURNV(nr);
}
// RETURN the current record number in table 'name'
LONG strecnum(CHAR *name)
{
    LONG nr=0L;
    static INT s;
    static CHAR lname[10];
	ENTRY(4290);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s]) RETURNV(msrecnum(name));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(nr);
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(nr);
    RETURNV(nr);
}
CHAR *tabname(CHAR *name)
{
    static CHAR tmp[80];
    INT s;
    if ((s=snum(name))<0) {
   	    sprintf(tmp,"%s%s",G_database,name);
    } else {
	    if (G_dbmap[s]!=0) {
    	    sprintf(tmp,"%s%s",G_databas2,name);
	    } else {
    	    sprintf(tmp,"%s%s",G_database,name);
        }
	}
    return(tmp);
}
INT dbexist(CHAR *name)
{
    int e=0;
    if (PXTblExist(tabname(name),&e)!=PXSUCCESS) RETURNV(0);
    if (e) RETURNV(1);
    RETURNV(0);
}
// check if table exists
INT stexist(CHAR *name)
{
	ENTRY(4300);
    if (dbexist(name)) RETURNV(1);
    RETURNV(0);
}
// create table 'name'
INT stcreate(CHAR *name)
{
    CHAR *tf[NUMFIELDS];
    CHAR *nf[NUMFIELDS];
    INT i,len;
    INT s;
	ENTRY(4310);

    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)mscreate(name));
    if (G_sstat[s].open) RETURNV(1);

    if (dbexist(name)) RETURNV(1);

    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++) {
        len=G_lib[G_store[s].li[i]].len;
        nf[i]=G_lib[G_store[s].li[i]].name;
        tf[i]=STRDUP("     ");
        switch(G_lib[G_store[s].li[i]].type) {
            case 1 :
                strcpy(tf[i],"S");
                break;
            case 2 :
                strcpy(tf[i],"N");
                break;
            case 3 :
                sprintf(tf[i],"A%d",len);
                break;
            default :
                RETURNV(0);
        }
    }
    if ((G_sstat[s].err=PXTblCreate(tabname(name),G_store[s].numitem,nf,tf))!=PXSUCCESS) {
	    for (i=0;i<G_store[s].numitem;i++) FREE(tf[i]);
		RETURNV(0);
	}
    for (i=0;i<G_store[s].numitem;i++) FREE(tf[i]);

    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURNV(1);
    if ((G_sstat[s].err=PXKeyAdd(tabname(name),i,G_fhs,PRIMARY))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    for (i=0;i<G_store[s].numitem;i++) {
        if (G_store[s].skey&(0x80000000L>>i)) {
            if ((G_sstat[s].err=PXKeyAdd(tabname(name),1,&G_fhs[i],INCSECONDARY))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    
    RETURNV(1);
}
// delete table 'name'
INT stdelete(CHAR *name)
{
    INT s;
	ENTRY(4320);
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msdelete(name));
    stclose(name);

    if (!dbexist(name)) RETURNV(1);

    G_sstat[s].err=0;
    if ((G_sstat[s].err=PXTblDelete(tabname(name)))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    RETURNV(1);
}
void closeoldest(void)
{
    int i;
    if (G_numopen==G_swapsize) {
        for (i=0;i<NUMSTORES;i++) {
            if (G_sstat[i].open==1) {
                stclose(G_sstat[i].name);
                break;
            }
        }
    }
    G_numopen++;
}
// open table 'name'
INT stopen(CHAR *name)
{
    static INT s;
	ENTRY(4330);
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msopen(name));
    if (!G_sstat[s].open) {
        closeoldest();
        if (!stcreate(name)) RETURNV(0);
        G_sstat[s].handle=0;
        G_sstat[s].rec=0;
        if ((G_sstat[s].err=PXTblOpen(tabname(name),&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
        G_sstat[s].modified=0;
        G_sstat[s].open=G_numopen;
    }
    RETURNV(1);
}
// close table 'name'
INT stclose(CHAR *name)
{
    INT s,i,j;
    INT err=1;
	ENTRY(4340);
#ifdef DOS
//  if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
#endif//DOS
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msclose(name));
    G_sstat[s].err=0;
    if (G_sstat[s].open) {
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS) err=0;
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS) err=0;
        j=G_sstat[s].open;
        G_sstat[s].open=0;
        for (i=0;i<NUMSTORES;i++) if (G_sstat[i].open>j) G_sstat[i].open--;
        G_numopen--;
    }
    G_sstat[s].modified=0;
    RETURNV(err);
}
// close all open tables
INT stcloseall(void)
{
    INT i;
    INT err=1;
	ENTRY(4350);
#ifdef DOS
//  if(!(isbegintxn)) errorline("Nicht in Transaktion",1);
#endif//DOS
    for (i=0;i<G_nums;i++) {
        if (G_msmap[i]) {
            msclose(G_sstat[i].name);
        } else {
            if (G_sstat[i].open) {
                if ((G_sstat[i].err=PXRecBufClose(G_sstat[i].rec))!=PXSUCCESS) err=0;
                if ((G_sstat[i].err=PXTblClose(G_sstat[i].handle))!=PXSUCCESS) err=0;
            }
            G_sstat[i].open=0;
        }
        G_sstat[i].modified=0;
    }
    G_numopen=0;
    RETURNV(err);
}
// read record from table 'name' where rtype is FRST,LAST,CURR,NEXT,PREV.
INT stread(CHAR *name,LONG rtype)
{
    static INT s;
    static CHAR lname[10];
//    FILE *errorlog;
	ENTRY(4360);
//                errorlog=fopen("gpaerror.log","a");
//                fprintf(errorlog,"%s %ld\n",name,rtype);
//                fclose(errorlog);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s]) RETURNV((INT)msread(name,rtype));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    switch(rtype) {
        case FRST :
            if ((G_sstat[s].err=PXRecFirst(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,7);
                RETURNV(0);
            }
            break;
        case LAST :
            if ((G_sstat[s].err=PXRecLast(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,8);
                RETURNV(0);
            }
            break;
        case PREV :
            if ((G_sstat[s].err=PXRecPrev(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,9);
                RETURNV(0);
            }
            break;
        case NEXT :
            if ((G_sstat[s].err=PXRecNext(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,10);
                RETURNV(0);
            }
            break;
        case CURR :
            break;
        default :
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,(RECORDNUMBER)rtype))!=PXSUCCESS) {
                prerror(s,11);
                RETURNV(0);
            }
                            
    }
    if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        prerror(s,12);
        RETURNV(0);
    }
    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) {
        prerror(s,13);
        RETURNV(0);
    }

    G_sstat[s].modified=0;
    RETURNV(1);
}
// write/update record in table 'name'
INT stwrite(CHAR *name, INT updateonly)
{
    INT i;
    static INT s;
    static CHAR lname[10];
	ENTRY(4370);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s]) RETURNV((INT)mswrite(name));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) {
        prerror(s,14);
        RETURNV(0);
    }
    if (!updateonly) {
      if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
          if (G_sstat[s].err!=PXERR_KEYVIOL) {
              prerror(s,13);
              RETURNV(0);
          }
      }
      else  {
	   	G_modified=1;
		  if (!strcmp(name,"transact")) stflush();
          G_sstat[s].modified=0;
          RETURNV(1);
      }
      for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
      }
      if (i<1) RETURNV(0);
      if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS) {
          prerror(s,15);
          RETURNV(0);
      }
    }
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        prerror(s,16);
        RETURNV(0);
    }

//    sendrec(name,RECUPDATE);
    G_sstat[s].modified=0;
	G_modified=1;
    RETURNV(1);
}

// write/update record in table 'name' but don't transmit to other systems
INT stwritelocal(CHAR *name)
{
    INT i;
    static INT s;
    static CHAR lname[10];
	ENTRY(4380);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        if (G_sstat[s].err!=PXERR_KEYVIOL) RETURNV(0);
    }
    else  {
        G_sstat[s].modified=0;
        RETURNV(1);
    }
    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURNV(0);
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }

    G_sstat[s].modified=0;
    RETURNV(1);
}
// delete record in table 'name'
INT stdelrec(CHAR *name,LONG recnum)
{
    INT s;
	ENTRY(4390);

    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msdelrec(name,recnum));

    G_sstat[s].err=0;

    if (!stread(name,recnum)) RETURNV(0);

//    sendrec(name,RECDELETE);
    if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    RETURNV(1);
}
INT stbsslist(CHAR *name,CHAR *fname,LONG *list)
{
    INT    nr=0,recnum=1,err=0;
    CHAR   buf[80],curbuf[80];
    INT    s,f;
	ENTRY(4410);

    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msbsslist(name,fname,list));
    if ((f=fnum(name,fname))<0) RETURNV(0);
    if (!stopen(name)) RETURNV(0);
    if (!stquickget(s,f,curbuf)) RETURNV(0);
    G_sstat[s].err=0;
    while (!err) {
        if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,recnum))==PXSUCCESS) {
            if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS) {
                if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS) {
                    if ((stquickget(s,f,buf))&&(!strcmp(buf,curbuf))) {
                        list[nr++]=recnum;
                    }
                    recnum++;
                } else {
                    err=1;
                }
            } else {
                err=2;
            }
        } else {
            err=3;
        }
    }
    RETURNV(nr);
}
// search table (secondary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
INT stsrch(CHAR *name,CHAR *fname,INT mode)
{
    INT k,i;
    LONG nr=0L;
    INT smode;
    static INT s;
    static CHAR lname[10];
	ENTRY(4400);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s]) RETURNV((INT)mssrch(name,fname,mode));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    switch (mode) {
        case FRST :
            smode=SEARCHFIRST;
            break;
        case NEXT :
            smode=SEARCHNEXT;
            break;
        default :
            smode=CLOSESTRECORD;
    }
    if ((fname==NULL)&&(mode==0)) {
        for (i=0;i<G_store[s].numitem;i++) {
            if (!(G_store[s].key&(0x80000000L>>i))) break;
        }
        if (i<1) RETURNV(0);
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,smode))!=PXSUCCESS) {
            prerror(s,1);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
    }
    else {
        if (fname==NULL) {
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,mode,smode))!=PXSUCCESS) {
                prerror(s,2);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
        }
        else {
            if (!(k=knum(name,fname))) RETURNV(0);
            if ((G_sstat[s].err=PXSrchFld(G_sstat[s].handle,G_sstat[s].rec,k,smode))!=PXSUCCESS) {
                prerror(s,3);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    RETURNV((INT)nr);
}
INT stbsplist(CHAR *name,INT nflds,LONG *list)
{
    INT i;
    INT nr=0,len;
    LONG rn;
    INT s,err;
    UCHAR *rbuf;
	ENTRY(4410);
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msbsplist(name,nflds,list));
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    if (nflds==0) {
        for (i=0;i<G_store[s].numitem;i++) 
            if (!(G_store[s].key&(0x80000000L>>i))) break;

        if (i<1) RETURNV(0);
        nflds=i;
    }
    if (nflds==G_store[s].numitem) len=G_sstat[s].len; else len=G_sstat[s].fofs[nflds];
    err=0;
    nr=0;
    rbuf=MALLOC(len+1);
    if (!rbuf) RETURNV(0);
    memcpy(rbuf,G_sstat[s].buf,len);
    while (!err) {
        if (!nr){
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,SEARCHFIRST))==PXSUCCESS) {
                if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&(list[nr])))==PXSUCCESS) {
                    rn=list[0];
                    nr++;
                } else {
                    err=1;
                }
            } else {
                err=1;
            }
        } else {
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,rn+(LONG)nr))==PXSUCCESS) {
                if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS) {
                    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_tempsbuf,G_sstat[s].len))==PXSUCCESS) {
                        if (!memcmp(rbuf,G_tempsbuf,len)) {
                            list[nr]=rn+(LONG)nr;
                            nr++;
                        } else {
                            err=1;
                        }
                    } else {
                        err=1;
                    }
                } else {
                    err=1;
                }
            } else {
                err=1;
            }
        }
    }
    FREE(rbuf);
    RETURNV(nr);
}
// search table (primarary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
INT stsrchp(CHAR *name,INT nflds,INT mode)
{
    INT smode;
    static INT lnf;
    static INT s;
    static CHAR lname[10];
	ENTRY(4410);
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)mssrchp(name,nflds,mode));
    if (strcmp(name,lname)) {
        strcpy(lname,name);
    } else {
        if ((lnf==nflds)&&(mode==NEXT)&&(!memcmp(G_lastsbuf,G_sstat[s].buf,G_lastslen))) {
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,G_lastsrec+1))==PXSUCCESS) {
                if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS) {
                    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_tempsbuf,G_sstat[s].len))==PXSUCCESS) {
                        if (!memcmp(G_lastsbuf,G_tempsbuf,G_lastslen)) {
                            G_lastsrec++;
                            RETURNV(1);
                        } else {
                            PXRecGoto(G_sstat[s].handle,G_lastsrec);
                            PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                            RETURNV(0);
                        }
                    } else {
                        PXRecGoto(G_sstat[s].handle,G_lastsrec);
                        PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                        RETURNV(0);
                    }
                } else {
                    PXRecGoto(G_sstat[s].handle,G_lastsrec);
                    PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                    RETURNV(0);
                }
            } else {
                PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                RETURNV(0);
            }
        }
//        if ((lnf==nflds)&&(mode==NEXT)) {
//            if (G_sstat[s].modified) {
//                if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) {
//                    prerror(s,14);
//                    RETURNV(0);
//                }
//            }
//            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,SEARCHNEXT))!=PXSUCCESS) {
//                prerror(s,4);
//                RETURNV(0);
//            } else {
//                RETURNV(1);
//            }
//        }
    }
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    switch (mode) {
        case FRST :
            smode=SEARCHFIRST;
            break;
        case NEXT :
            smode=SEARCHNEXT;
            break;
        default :
            smode=CLOSESTRECORD;
    }
    if (nflds==0) {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds))) break;

        if (nflds<1) RETURNV(0);
    }
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,smode))!=PXSUCCESS) {
        prerror(s,5);
        RETURNV(0);
    }
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&G_lastsrec))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    lnf=nflds;
    if (nflds==G_store[s].numitem)
        G_lastslen=G_sstat[s].len;
    else
        G_lastslen=G_sstat[s].fofs[nflds];
    memcpy(G_lastsbuf,G_sstat[s].buf,G_lastslen);
    RETURNV(1);
}
// get field 'fname' from table 'name' and place it in variable 'var'
INT stquickget(UCHAR s,UCHAR f,CHAR *var)
{
    INT len;
    UCHAR *b,a[8];
    short i;
    double d;
	ENTRY(4419);
    if (G_msmap[s]) RETURNV((INT)msquickget(s,f,var));
    G_sstat[s].err=0;
    len=G_lib[G_store[s].li[f]].len;
    if (!G_sstat[s].open) if (!stopen(G_sstat[s].name)) RETURNV(0);
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    switch (G_lib[G_store[s].li[f]].type) {
        case 1 :
            i=(short)(*b^0x80);
            i<<=8;
            i|=*(b+1);
            itoa(i,var,10);
            break;
        case 2 :
            if ((*b&0x80)==0x80) {
                for (i=7;i>=0;i--) a[i]=*(b++);
                a[7]&=0x7F;
            } else {
                for (i=7;i>=0;i--) a[i]=*(b++)^0xFF;
            }
            d=*((double *)(a));
            sprintf(var,"%lf",d);
            dottrunc(var);
            break;
        case 3 :
            strncpy(var,(CHAR *)b,len);
            while (*b==32) b++;
            if (!(*b)) {
                var[0]=0;
            } else {
                var[len]=0;
            }
            break;
    }
    RETURNV(1);
}
INT stget(CHAR *name,CHAR *fname,CHAR *var)
{
    INT s,f;
	ENTRY(4420);
    if ((s=snum(name))<0) RETURNV(0);
    if ((f=fnum(name,fname))<0) RETURNV(0);
    RETURNV(stquickget(s,f,var));
}
// blank the record buffer in table 'name'
INT stblank(CHAR *name)
{
    INT s,i;
	ENTRY(4430);
    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msblank(name));
    if (!stopen(name)) RETURNV(0);
    for (i=1;i<=G_store[s].numitem;i++) {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,i))!=PXSUCCESS) {
        prerror(s,0);
        RETURNV(0);
    }
    }
    RETURNV(1);
}
// empty the table 'name'
INT stempty(CHAR *name)
{
    INT s,wo;
	ENTRY(4440);

    if ((s=snum(name))<0) RETURNV(0);
    if (G_msmap[s]) RETURNV((INT)msempty(name));
    if (G_sstat[s].open) {
        wo=1;
        G_sstat[s].err=0;
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
    } else {
        wo=0;
    }
    if ((G_sstat[s].err=PXTblEmpty(tabname(name)))!=PXSUCCESS) {
        G_sstat[s].open=0;
        prerror(s,0);
        RETURNV(0);
    }
    if (wo) {
        if ((G_sstat[s].err=PXTblOpen(tabname(name),&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS) {
            prerror(s,0);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) {
            prerror(s,13);
            RETURNV(0);
        }
    }
    RETURNV(1);
}
INT stquickput(UCHAR s,UCHAR f,CHAR *var)
{
    INT len;
    short i;
    UCHAR *b,a[8];
    CHAR c[1];
    double d;
	ENTRY(4449);
    if (G_msmap[s]) RETURNV((INT)msquickput(s,f,var));
    G_sstat[s].err=0;
    if (!G_sstat[s].open) if (!stopen(G_sstat[s].name)) RETURNV(0);
    if (var==NULL) {
        c[0]=0;
        var=c;
    }
    len=G_lib[G_store[s].li[f]].len;
    switch (G_lib[G_store[s].li[f]].type) {
        case 1 :
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
			i=(short)atoi(var);
            *(b++)=(UCHAR)((i>>8)^0x80);
            *(b++)=(UCHAR)(i&0xFF);
            break;
        case 2 :
            d=strtod(var,NULL);
            b=(UCHAR *)(&d);
            if ((*(b+7)&0x80)!=0) {
                for (i=7;i>=0;i--) a[i]=*(b++)^0xFF;
            } else {
                for (i=7;i>=0;i--) a[i]=*(b++);
                a[0]^=0x80;
            }
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
            memcpy(b,a,8);
            break;
        case 3 :
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
            memset((CHAR *)b,0,len);
            strncpy((CHAR *)b,var,len);
            break;
    }
    if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) {
        prerror(s,14);
        RETURNV(0);
    }
    G_sstat[s].modified=1;
    RETURNV(1);
}
INT stmovedata(UCHAR df,UCHAR ds,UCHAR sf,UCHAR ss)
{
    INT ret=0;
    CHAR buf[81];
    if (stquickget(ss,sf,buf)) {
        if (stquickput(ds,df,buf)) ret=1;
    }
    RETURNV(ret);
}


// put variable 'var' it in field 'fname' from table 'name' 
INT stput(CHAR *name,CHAR *fname,CHAR *var)
{
    INT s,f;
	ENTRY(4450);
    if ((s=snum(name))<0) RETURNV(0);
    if ((f=fnum(name,fname))<0) RETURNV(0);
    RETURNV(stquickput(s,f,var));
}
// duplicate a table to a temp table using ~ame for name and sec search parameters
INT stdup(CHAR *name,CHAR *fname,INT mode)
{
    INT s;
    INT smode;
    CHAR newname[9];
	ENTRY(4460);

    if ((s=snum(name))<0) RETURNV(0);

    strcpy(newname,name);
    newname[0]='~';
    strcpy(G_store[G_nums].name,newname);
    G_store[G_nums].key    =G_store[s].key;
    G_store[G_nums].skey   =G_store[s].skey;
    G_store[G_nums].numitem=G_store[s].numitem;
    memcpy(G_store[G_nums].li,G_store[s].li,32*sizeof(INT));
    G_nums++;

    stempty(newname);
    if (!stopen(newname)) RETURNV(0);
    if (!stopen(name)) RETURNV(0);
    if (fname!=NULL) {
        smode=FRST;
        while (stsrch(name,fname,smode)) {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
            stwrite(newname,0);
            smode=NEXT;
        }
    }
    else {
        smode=FRST;
        while (stsrchp(name,mode,smode)) {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
            stwrite(newname,0);
            smode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    RETURNV(1);
}
// remove a duplicated table and copy contents back to original if 'copyback'
INT stremdup(CHAR *name,INT copyback)
{
    CHAR newname[9];
    INT s;
    INT t;
    INT mode=FRST;
	ENTRY(4470);

    strcpy(newname,name);
    newname[0]='~';
    if (copyback) {
        stopen(name);
        stopen(newname);
        t=snum(newname);
        s=snum(name);
        while (stread(newname,(LONG)mode)) {
            if ((G_sstat[t].err=PXRecBufCopy(G_sstat[t].rec,G_sstat[s].rec))!=PXSUCCESS) {
                prerror(t,0);
                RETURNV(0);
            }
            stwrite(name,0);
            mode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    G_nums--;
    RETURNV(1);
}
// delete all records matched by search parameters
INT stdelgrp(CHAR *name,CHAR *fname,INT mode)
{
    INT s;
	ENTRY(4480);
    if ((s=snum(name))<0) RETURNV(0);
    if (!stopen(name)) RETURNV(0);
    if (fname!=NULL) {
        while (stsrch(name,fname,FRST)) {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    else {
        while (stsrchp(name,mode,FRST)) {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    stclose(name);
    RETURNV(1);
}
// flush all modified buffers
INT stflush(void)
{
//    INT i;
	ENTRY(4490);
//    for (i=0;i<G_nums;i++) {
//        if (G_sstat[s].modified) stwrite(G_sstat[s].name,0);
//    }
    if (PXSave()!=PXSUCCESS) RETURNV(0);
    RETURNV(1);
}
/*
// get a record into r and set 'flen' to the length of the buffer
INT stgetrec(CHAR *name,CHAR *r,INT *flen)
{
    INT i,s,len;
    short j;
    double d;
    CHAR tmp[80];
    INT olen=9;
	ENTRY(4500);

    if ((s=snum(name))<0) RETURNV(0);
    if (!stopen(name,0)) RETURNV(0);
    G_sstat[s].err=0;
    strcpy(r,name);
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 1 :
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=sizeof(INT);
                if ((olen+len)>=*flen) RETURNV(0);
                *((INT *)&(r[olen]))=j;
                break;
            case 2 :
                if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,i+1,&d))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=sizeof(double);
                if ((olen+len)>=*flen) RETURNV(0);
                *((double *)&(r[olen]))=d;
                break;
            case 3 :
                if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=G_lib[G_store[s].li[i]].len+1;
                if ((olen+len)>=*flen) RETURNV(0);
                strcpy(&(r[olen]),tmp);
                break;
            default :
                RETURNV(0);
        }
        olen+=len;
    }
    *flen=olen;
    RETURNV(1);
}
// put a record from r
INT stputrec(CHAR *r)
{
    CHAR name[10];
    INT i,s,len;
    INT olen=9;
	ENTRY(4510);

    strncpy(name,r,9);
    if ((s=snum(name))<0) RETURNV(0);
    if (!stopen(name,0)) RETURNV(0);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 1 :
                len=sizeof(INT);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                break;
            case 2 :
                len=sizeof(double);
                if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,i+1,*((double *)&(r[olen]))))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                break;
            case 3 :
                len=G_lib[G_store[s].li[i]].len+1;
                if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS) {
                    prerror(s,0);
                    RETURNV(0);
                }
                break;
            default :
                RETURNV(0);
        }
        olen+=len;
    }
    G_sstat[s].modified=1;
	G_modified=1;
    RETURNV(1);
}
// send a record to BOS if in the RUPDATE list from config
INT sendrec(CHAR *name,INT type)
{
    CHAR r[MAXDGSIZE];
    INT len=MAXDGSIZE;
	ENTRY(4520);

    if (G_netok&&((G_frupd[snum(name)]&1)==1)) {
        if (!stgetrec(name,r,&len)) RETURNV(0);
        if ((sendmsg("LAN",MESSAGE_S,G_toname,1,len,r,type))==(-1)) RETURNV(0);
    }

    RETURNV(1);
}
// receive a record and update local database
INT receiverec(void)
{
    CHAR r[MAXDGSIZE];
    INT len=MAXDGSIZE;
    INT type,pos,uid;
    CHAR file[33],*t,n[20];
	ENTRY(4530);

    type=(INT)sendmsg("LAN",MESSAGE_R,&len,r);
    switch (type) {
		case USERLOGON	  :
			t=r+2;
			*(t++)=0;
			while ((*t)&&(!isdigit(*t))) t++;
			if (*t) {
			    if (!stput(USER_S,USID,r)) RETURNV(0);
			    if (stsrch(USER_S,NULL,1)) {
                    stread(USER_S,(LONG)CURR);
					stput(USER_S,POSN,t);
                    stwrite(USER_S,0);
	                G_finredraw=0;
				}
			}
			break;
		case USERLOGOFF	  :
			t=r+3;
			*t=0;
		    if (!stput(USER_S,USID,r)) RETURNV(0);
		    if (stsrch(USER_S,NULL,1)) {
                stread(USER_S,(LONG)CURR);
				stput(USER_S,POSN,"0");
                stwrite(USER_S,0);
	            G_finredraw=0;
			}
			break;
        case RECUPDATE :
            if (stputrec(r)) {
                stwritelocal(r);
                G_finredraw=0;
            }
            break;
        case RECDELETE :
            if (stputrec(r)) {
                if (stsrchp(r,0,FRST)) {
                    if (stread(r,(LONG)CURR)) {
						PXRecDelete(G_sstat[snum(r)].handle);
		                G_finredraw=0;
					}
                }
            }
            break;
        case FILERXDONE :
			sendmsg("LAN",MESSAGE_S,G_toname,1,1,"",FILETXDONE);
        case FILETXDONE :
            streinit();
            break;
        case 0 :
            break;
    }
    RETURNV(1);
} */
INT stcopyrec(CHAR *s,CHAR *d)
{
    INT f1,f2;
	ENTRY(4540);
    if ((f1=snum(s))<0) RETURNV(0);
    if ((f2=snum(d))<0) RETURNV(0);
    if (!stopen(s)) RETURNV(0);
    if (!stopen(d)) RETURNV(0);
    if (G_sstat[f2].buf==NULL) RETURNV(0);
    if (G_sstat[f1].buf==NULL) RETURNV(0);
    memcpy(G_sstat[f2].buf,G_sstat[f1].buf,G_sstat[f1].len);
    if (!stwrite(d,0)) RETURNV(0);

    RETURNV(1);
}

// pdxdev control routine
LONG pdx_control(INT type,va_list ap)
{
	CHAR *name,*var,*fname;
    LONG *ll;
    UCHAR a,b,c,d;
	INT mode,recnum;
    LONG retval=0L;
	ENTRY(4550);
    switch(type) {
		case MESSAGE_I  :
			retval=(LONG)stinit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode]) break;
            if (mode<32) msinit();
			break;
		case MESSAGE_E  :
			retval=(LONG)stexit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode]) break;
            if (mode<32) msexit();
			break;
		case MESSAGE_RI :
			retval=(LONG)streinit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode]) break;
            if (mode<32) msreinit();
			break;
		case MESSAGE_x  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                if (((mode=snum(name))>(-1))&&G_msmap[mode]) {
                    retval=msexist(name);
                } else {
                    retval=(LONG)stexist(name);
                }
            }
			break;
		case MESSAGE_C  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stcreate(name);
            }
			break;
		case MESSAGE_D  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stdelete(name);
            }
			break;
		case MESSAGE_O  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stopen(name);
            }
			break;
		case MESSAGE_c  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stclose(name);
            }
			break;
		case MESSAGE_ca :
			retval=(LONG)stcloseall();
			break;
		case MESSAGE_nr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
			    retval=stnumrec(name);
            }
			break;
		case MESSAGE_rn :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
			    retval=strecnum(name);
            }
			break;
		case MESSAGE_un :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
			    retval=strecnum(name)+1L;
            }
			break;
		case MESSAGE_r  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                retval=va_arg(ap,LONG);
			    retval=(LONG)stread(name,retval);
            }
			break;
		case MESSAGE_w  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stwrite(name,0);
            }
			break;
		case MESSAGE_u  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stwrite(name,1);
            }
			break;
		case MESSAGE_dr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                retval=va_arg(ap,LONG);
    			retval=(LONG)stdelrec(name,retval);
            }
			break;
		case MESSAGE_s  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=(LONG)stsrch(name,fname,mode);
            }
			break;
		case MESSAGE_sp :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                recnum=va_arg(ap,INT);
                mode=va_arg(ap,INT);
			    retval=(LONG)stsrchp(name,recnum,mode);
            }
			break;
		case MESSAGE_bs  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                ll=va_arg(ap,LONG *);
			    retval=(LONG)stbsslist(name,fname,ll);
            }
			break;
		case MESSAGE_bp :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                recnum=va_arg(ap,INT);
                ll=va_arg(ap,LONG *);
			    retval=(LONG)stbsplist(name,recnum,ll);
            }
			break;
		case MESSAGE_g  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
			    retval=(LONG)stget(name,fname,var);
            }
			break;
		case MESSAGE_qg  :
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            var=va_arg(ap,CHAR *);
    	    retval=(LONG)stquickget(a,b,var);
			break;
		case MESSAGE_qp  :
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            var=va_arg(ap,CHAR *);
    	    retval=(LONG)stquickput(a,b,var);
			break;
		case MESSAGE_b  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stblank(name);
            }
			break;
		case MESSAGE_e  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=(LONG)stempty(name);
            }
			break;
		case MESSAGE_p  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
			    retval=(LONG)stput(name,fname,var);
            }
			break;
		case MESSAGE_d  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=(LONG)stdup(name,fname,mode);
            }
			break;
		case MESSAGE_rd :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
			    retval=(LONG)stremdup(name,mode);
            }
			break;
		case MESSAGE_dg :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=(LONG)stdelgrp(name,fname,mode);
            }
			break;
		case MESSAGE_f  :
			retval=(LONG)stflush();
			break;
/*		case MESSAGE_gr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                var=va_arg(ap,CHAR *);
                flen=va_arg(ap,INT *);
			    retval=(LONG)stgetrec(name,var,flen);
            }
			break;
		case MESSAGE_pr :
            var=va_arg(ap,CHAR *);
			retval=(LONG)stputrec(var);
			break;
		case MESSAGE_sr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
			    retval=(LONG)sendrec(name,mode);
            }
			break;
		case MESSAGE_rr :
			retval=(LONG)receiverec();
			break; */
		case MESSAGE_cr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
			    retval=(LONG)stcopyrec(name,fname);
            }
			break;
        case MESSAGE_md :
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            c=va_arg(ap,UCHAR);
            d=va_arg(ap,UCHAR);
            retval=(LONG)stmovedata(a,b,c,d);
            break;
    }
    RETURNV(retval);
}
//___________________________________________________________________________
#pragma option -p.

// -----------------------  MEM STORES --------------------------------------

typedef struct {
    INT nrec;
    INT crec;
    UCHAR **recs;
    UCHAR *recbuf;
} MEMSTORE;
MEMSTORE *G_memstores;
INT      G_nummems;
INT      G_msbufofs=0;
INT      G_msbuflen=0;

INT mscmp(UCHAR **a,UCHAR **b)
{
    return(memcmp((*a)+G_msbufofs,(*b)+G_msbufofs,G_msbuflen));
}

INT mssrchbuf(INT s,INT mode,INT ofs,INT len)
{
    INT rn=0;
    size_t ne;
    UCHAR **b;
    G_msbufofs=ofs;
    G_msbuflen=len;
    switch (mode) {
        case NEXT :
            ne=G_memstores[s].nrec-G_memstores[s].crec;
            b=(UCHAR **)lfind(&(G_sstat[s].buf),
                &(G_memstores[s].recs[G_memstores[s].crec]),
                &ne,sizeof(UCHAR *),(QSPTR)mscmp);
            break;
        case FRST :
        default :
            ne=G_memstores[s].nrec;
            b=(UCHAR **)lfind(&(G_sstat[s].buf),
                G_memstores[s].recs,
                &ne,sizeof(UCHAR *),(QSPTR)mscmp);
    }
    if (b==NULL) {
        rn=0;    
    } else {
        G_memstores[s].crec=rn=(INT)(b-G_memstores[s].recs)+1;
    }
    return(rn);
}
LONG msdeleterec(INT s)
{
    if (G_memstores[s].recs[G_memstores[s].crec-1]!=NULL) {
        FREE(G_memstores[s].recs[G_memstores[s].crec-1]);
    }
    if (G_memstores[s].crec<G_memstores[s].nrec) 
        memcpy(&G_memstores[s].recs[G_memstores[s].crec-1],
               &G_memstores[s].recs[G_memstores[s].crec],
               (G_memstores[s].nrec-G_memstores[s].nrec)*sizeof(UCHAR *));
    G_memstores[s].nrec--;
    return(1L);
}
LONG msinsertrec(INT s)
{
    G_memstores[s].recs=REALLOC(G_memstores[s].recs,(G_memstores[s].nrec+1)*sizeof(UCHAR *));
    if (G_memstores[s].recs==NULL) {
        G_msmap[s]=0;
        return(0L);
    }
    G_memstores[s].recs[G_memstores[s].nrec]=MALLOC((G_sstat[s].len+1)*sizeof(UCHAR));
    if (G_memstores[s].recs[G_memstores[s].nrec]==NULL) {
        return(0L);
    }
    memcpy(G_memstores[s].recs[G_memstores[s].nrec],G_sstat[s].buf,G_sstat[s].len);
    G_memstores[s].nrec++;
    G_msbufofs=0;
    G_msbuflen=G_sstat[s].len;
    qsort(G_memstores[s].recs,G_memstores[s].nrec,sizeof(UCHAR *),(QSPTR)mscmp);
    return(1L);
}
int getsnum(CHAR *name)
{
    INT s;
    if (G_memstores==NULL) return(-1);
    if ((s=snum(name))<0) return(-2);
    if (G_memstores[s].recs==NULL) return(-3);
    return(s);
}
LONG msinit(void)
{
    INT i,j,k;
    G_memstores=MALLOC(32*sizeof(MEMSTORE));
    if (G_memstores==NULL) {
        G_nummems=0;
        return(0L);
    }
    for (i=0;i<32;i++) {
        if (G_msmap[i]) {
            k=0;
            for (j=0;j<G_store[i].numitem;j++) {
                G_sstat[i].fofs[j]=k;
//                switch (G_lib[G_store[i].li[j]].type) {
//                    case 1 :
//                        k+=2;
//                        break;
//                    case 2 :
//                        k+=8;
//                        break;
//                    case 3 :
//                        k+=G_lib[G_store[i].li[j]].len;
//                        break;
//                }
                k+=G_lib[G_store[i].li[j]].len;
            }
            G_sstat[i].len=k;
            if ((G_sstat[i].buf=REALLOC(G_sstat[i].buf,k+1))==NULL)
                G_sstat[i].len=0;
            else
                memset(G_sstat[i].buf,0,k+1);
            for (j=0;j<G_store[i].numitem;j++) {
                switch (G_lib[G_store[i].li[j]].type) {
                    case 1 :
                    case 2 :
                        G_sstat[i].buf[G_sstat[i].fofs[j]]=0x80;
                        break;
                }
            }
        }
        G_memstores[i].recs=MALLOC(sizeof(UCHAR *));
        if (G_memstores[i].recs==NULL) {
            FREE(G_memstores);
            G_memstores=NULL;
            G_nummems=0;
            return(0L);
        }
        G_memstores[i].nrec=0;
        G_memstores[i].crec=0;
        G_memstores[i].recs[0]=NULL;
    }
    G_nummems=32;
    return(1L);
}
LONG msexit(void)
{
    INT i,j;
    if (G_memstores==NULL) return(0L);
    for (i=0;i<G_nummems;i++) {
        if (G_memstores[i].recs!=NULL) {
            for (j=0;j<G_memstores[i].nrec;j++) {
                if (G_memstores[i].recs[j]!=NULL) {
                    FREE(G_memstores[i].recs[j]);
                }
            }
            FREE(G_memstores[i].recs);
        }
        G_memstores[i].nrec=0;
        G_memstores[i].crec=0;
    }
    FREE(G_memstores);
    G_nummems=0;
    G_memstores=NULL;
    return(1L);
}
LONG msreinit(void)
{
    msexit();
    return(msinit());
}
LONG msexist(CHAR *name)
{
    if (getsnum(name)<0) return(0L);
    return(1L);
}
LONG mscreate(CHAR *name)
{
    name++;
    return(1L);
}
LONG msdelete(CHAR *name)
{
    INT s,j;
    if ((s=getsnum(name))<0) return(0L);
    for (j=0;j<G_memstores[s].nrec;j++) {
        if (G_memstores[s].recs[j]!=NULL) {
            FREE(G_memstores[s].recs[j]);
        }
    }
    FREE(G_memstores[s].recs);
    G_memstores[s].nrec=0;
    G_memstores[s].crec=0;
    G_memstores[s].recs=MALLOC(sizeof(UCHAR *));
    return(1L);
}
LONG msopen(CHAR *name)
{
    name++;
    return(1L);
}
LONG msclose(CHAR *name)
{
    name++;
    return(1L);
}
LONG mscloseall(void)
{
    return(1L);
}
LONG msnumrec(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0) return(0L);
    return((LONG)G_memstores[s].nrec);
}
LONG msrecnum(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0) return(0L);
    return((LONG)G_memstores[s].crec);
}
LONG msread(CHAR *name,LONG rtype)
{
    INT s;
    if ((s=getsnum(name))<0) return(0L);
    if (G_memstores[s].nrec==0) return(0L);
    switch(rtype) {
        case FRST :
            G_memstores[s].crec=1;
            break;
        case LAST :
            G_memstores[s].crec=G_memstores[s].nrec;
            break;
        case PREV :
            if (G_memstores[s].crec>1) {
                G_memstores[s].crec--;
            } else {
                return(0L);
            }
            break;
        case NEXT :
            if (G_memstores[s].crec<G_memstores[s].nrec) {
                G_memstores[s].crec++;
            } else {
                return(0L);
            }
            break;
        case CURR :
            break;
        default :
            if (rtype<=G_memstores[s].nrec) {
                G_memstores[s].crec=(INT)rtype;
            } else {
                return(0L);
            }
    }
    if (G_memstores[s].crec==0) return(0L);
    memcpy(G_sstat[s].buf,G_memstores[s].recs[G_memstores[s].crec-1],G_sstat[s].len);
    G_sstat[s].modified=0;
    return(1L);
}
LONG mswrite(CHAR *name)
{
    INT r;
    INT s,nflds,len;
    if ((s=getsnum(name))<0) return(0L);

    for (nflds=0;nflds<G_store[s].numitem;nflds++) 
        if (!(G_store[s].key&(0x80000000L>>nflds))) break;
    if (nflds<1) RETURNV(0);
    if (nflds==G_store[s].numitem) {
        len=G_sstat[s].len;
    } else {
        len=G_sstat[s].fofs[nflds];
    }

    if ((r=mssrchbuf(s,FRST,0,len))!=0) {
        memcpy(G_memstores[s].recs[r-1],G_sstat[s].buf,G_sstat[s].len);
        G_memstores[s].crec=r;
    } else {
        G_sstat[s].modified=1;
        if (msinsertrec(s)) {
            if ((r=mssrchbuf(s,FRST,0,len))!=0) G_memstores[s].crec=r;
        }
    }
    G_sstat[s].modified=1;
    return(1L);
}
LONG msdelrec(CHAR *name,LONG recnum)
{
    INT s;
    if ((s=getsnum(name))<0) return(0L);
    if (msread(name,recnum));
    msdeleterec(s);
    return(1L);
}
LONG msquickget(INT s,INT f,CHAR *var)
{
    INT len;
    UCHAR *b,*e;
    if (G_memstores==NULL) return(0L);
    if (G_memstores[f].recs==NULL) return(0L);
    len=G_lib[G_store[s].li[f]].len;
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    e=b+len;
    switch (G_lib[G_store[s].li[f]].type) {
        case 1 :
        case 2 :
            while ((*b)&&(*b=='0')&&(b<e)) b++;
            if (b==e) b--;
            memcpy(var,b,(INT)(e-b));
            var[(INT)(e-b)]=0;
            break;
        case 3 :
            memcpy(var,b,len);
            var[len]=0;
            break;
    }
    return(1L);
}
LONG msquickput(INT s,INT f,CHAR *var)
{
    INT len;
    UCHAR *b;
    if (G_memstores==NULL) return(0L);
    if (G_memstores[f].recs==NULL) return(0L);
    len=G_lib[G_store[s].li[f]].len;
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    switch (G_lib[G_store[s].li[f]].type) {
        case 1 :
        case 2 :
            if (strlen(var)>len) var[len]=0;
            memset(b,'0',len);
            memcpy(b+len-strlen(var),var,strlen(var));
            break;
        case 3 :
            memcpy(b,var,len);
            break;
    }
    return(1L);
}
LONG mssrch(CHAR *name,CHAR *fname,INT mode)
{
    INT s,f;
    INT len,ofs;
    if ((s=getsnum(name))<0) return(0L);
//Bugfix
    if(fname==NULL)
    {
		if (mode > 0)
		  len=fkeysize(s,mode);		//get keysize
		else
			return(0L);
		ofs=0;
		mode=FRST;
    }
    else {
      if ((f=fnum(name,fname))<0) return(0L);
      len=G_lib[G_store[s].li[f]].len;
      ofs=G_sstat[s].fofs[f];
    }    
//end of Bugfix
    ofs=mssrchbuf(s,mode,ofs,len);
    if (ofs) G_memstores[s].crec=ofs;
    return((LONG)ofs);
}
LONG mssrchp(CHAR *name,INT nflds,INT mode)
{
    INT s;
    INT len,ofs;
    if ((s=getsnum(name))<0) return(0L);
    if (nflds==0) {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds))) break;
        if (nflds<1) RETURNV(0);
    }
    if (nflds==G_store[s].numitem) {
        len=G_sstat[s].len;
    } else {
        len=G_sstat[s].fofs[nflds];
    }
    ofs=mssrchbuf(s,mode,0,len);
    if (ofs) G_memstores[s].crec=ofs;
    return((LONG)(ofs>0));
}
LONG msblank(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0) return(0L);
    memset(G_sstat[s].buf,0,G_sstat[s].len);
    return(1L);
}
LONG msempty(CHAR *name)
{
    return(msdelete(name));
}
LONG msbsslist(CHAR *name,CHAR *fname,LONG *ll)
{
    INT s,f,mode;
    INT len,ofs,nr=0;
    LONG rn;
    if ((s=getsnum(name))<0) return(0L);
    if ((f=fnum(name,fname))<0) return(0L);
    len=G_lib[G_store[s].li[f]].len;
    ofs=G_sstat[s].fofs[f];
    mode=FRST;
    while ((rn=(LONG)mssrchbuf(s,mode,ofs,len))!=0L) {
        G_memstores[s].crec=(INT)rn;
        ll[nr++]=rn;
        mode=NEXT;
    }
    return(nr);
}
LONG msbsplist(CHAR *name,INT nflds,LONG *ll)
{
    INT s,mode;
    INT len,nr=0;
    LONG rn;
    if ((s=getsnum(name))<0) return(0L);
    if (nflds==0) {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds))) break;
        if (nflds<1) RETURNV(0);
    }
    if (nflds==G_store[s].numitem) {
        len=G_sstat[s].len;
    } else {
        len=G_sstat[s].fofs[nflds];
    }
    mode=FRST;
    while ((rn=(LONG)mssrchbuf(s,mode,0,len))!=0L) {
        G_memstores[s].crec=(INT)rn;
        ll[nr++]=rn;
        mode=NEXT;
    }
    return(nr);
}
/*------------------------------------------------------------------
return keySize for store number 's' with 'n' key fields
...Call this routine when 'n' has been determined in 0x8000000 ops
-------------------------------------------------------------------*/
int fkeysize(int s, int n)
{
	int i,r=0;

	for (i=0; i < n; i++)
		r+=G_lib[G_store[s].li[i]].len;
	RETURNV(r);
}

