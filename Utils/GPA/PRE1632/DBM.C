#define DBM_C

#include <pxengine.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <ctype.h>

#include "types.h"
#include "dbm.h"
#include "netdev.h"
#include "message.h"
#include "control.h"
#include "config.h"
#include "function.h"
// Truncate a numeric string at the decimal point
void dottrunc(char *s)
{
    LOG('E',M_DBM,1);
    while (*s) {
        if (*s=='.') {
            *s=0;
            break;
        }
        s++;
    }
}
// initialise the database system
int stinit(char *sys)
{
    LOG('E',M_DBM,2);
    memset(G_sstat,0,sizeof(G_sstat));
    if (PXSetDefaults(64,15,15,30,30,PXDEFAULT)!=PXSUCCESS) RETURN(0);
    PXSetHWHandler(TRUE);
    if (PXInit()!=PXSUCCESS) RETURN(0);
    sendmsg("INPUT1",'A',2,receiverec);
    RETURN(1);
}
// reinitialise the database system
int streinit(void)
{
    LOG('E',M_DBM,2);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURN(0);
    PXSetHWHandler(TRUE);
    if (PXInit()!=PXSUCCESS) RETURN(0);
    RETURN(1);
}
// shutdown the database system
int stexit(void)
{
    LOG('E',M_DBM,3);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURN(0);
    sendmsg("INPUT1",'D',receiverec);
    RETURN(1);
}
// return the number of records in table 'name'
long stnumrec(char *name)
{
    int s;
    long nr=0L;

    LOG('E',M_DBM,4);
    if ((s=snum(name))<0) RETURN(0L);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0L);
    if ((G_sstat[s].err=PXTblNRecs(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURN(nr);
    RETURN(nr);
}
// return the current record number in table 'name'
long strecnum(char *name)
{
    int s;
    long nr=0L;

    LOG('E',M_DBM,5);
    if ((s=snum(name))<0) RETURN(nr);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(nr);
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURN(nr);
    RETURN(nr);
}
// check if table exists
int stexist(char *name)
{
    char tmp[80];
    int i,s;
    if ((s=snum(name))<0) RETURN(0);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if (PXTblExist(tmp,&i)!=PXSUCCESS) RETURN(0);
    if (i) RETURN(1);
    RETURN(0);
}
// create table 'name'
int stcreate(char *name)
{
    char *tf[NUMFIELDS];
    char *nf[NUMFIELDS];
    int i,s,len;
    char tmp[80];

    LOG('E',M_DBM,6);

    if ((s=snum(name))<0) RETURN(0);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if ((G_sstat[s].err=PXTblExist(tmp,&i))!=PXSUCCESS) RETURN(0);
    if (i) RETURN(1);

    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++) {
        len=G_lib[G_store[s].li[i]].len;
        nf[i]=G_lib[G_store[s].li[i]].name;
        tf[i]=STRDUP("     ");
        switch(G_lib[G_store[s].li[i]].type) {
            case 'K' :
                strcpy(tf[i],"S");
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (len<5) {
                    strcpy(tf[i],"S");
                }
                else {
                    if (len<16) {
                        strcpy(tf[i],"N");
                    }
                    else {
                        sprintf(tf[i],"A%d",len);
                    }
                }
                break;
            case 'D' :
            case 'A' :
            case 'X' :
            case 'U' :
            case 'L' :
            case 'T' :
            case 'P' :
                sprintf(tf[i],"A%d",len);
                break;
            default :
                RETURN(0);
        }
    }
    if ((G_sstat[s].err=PXTblCreate(tmp,G_store[s].numitem,nf,tf))!=PXSUCCESS) RETURN(0);
    for (i=0;i<G_store[s].numitem;i++) FREE(tf[i]);

    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURN(1);
    if ((G_sstat[s].err=PXKeyAdd(tmp,i,G_fhs,PRIMARY))!=PXSUCCESS) RETURN(0);
    for (i=0;i<G_store[s].numitem;i++) {
        if (G_store[s].skey&(0x80000000L>>i)) {
            if ((G_sstat[s].err=PXKeyAdd(tmp,1,&G_fhs[i],INCSECONDARY))!=PXSUCCESS) RETURN(0);
        }
    }
    
    RETURN(1);
}
// delete table 'name'
int stdelete(char *name)
{
    int s,i;
    char tmp[80];
    LOG('E',M_DBM,7);
    if ((s=snum(name))<0) RETURN(0);
    stclose(name);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if ((G_sstat[s].err=PXTblExist(tmp,&i))!=PXSUCCESS) RETURN(0);
    if (!i) RETURN(1);

    G_sstat[s].err=0;
    if ((G_sstat[s].err=PXTblDelete(tmp))!=PXSUCCESS) RETURN(0);
    RETURN(1);
}
// open table 'name'
int stopen(char *name)
{
    int s;
    char tmp[80];
    LOG('E',M_DBM,8);
    if ((s=snum(name))<0) RETURN(0);
    if (!G_sstat[s].open) {
		if (G_dbmap[s]!=0) {
    		sprintf(tmp,"%s%s",G_databas2,name);
		} else {
    		sprintf(tmp,"%s%s",G_database,name);
		}
        if (!stcreate(name)) RETURN(0);
        if ((G_sstat[s].err=PXTblOpen(tmp,&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS) RETURN(0);
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS) RETURN(0);
        strcpy(G_sstat[s].name,name);
        G_sstat[s].modified=0;
        G_sstat[s].open=1;
    }
    RETURN(1);
}
// close table 'name'
int stclose(char *name)
{
    int s;
    int err=1;
    LOG('E',M_DBM,9);
    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (G_sstat[s].open) {
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS) err=0;
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS) err=0;
    }
    G_sstat[s].name[0]=0;
    G_sstat[s].open=0;
    G_sstat[s].modified=0;
    RETURN(err);
}
// close all open tables
int stcloseall(void)
{
    int i;
    int err=1;
    LOG('E',M_DBM,10);
    for (i=0;i<G_nums;i++) {
        if (G_sstat[i].open) {
            if ((G_sstat[i].err=PXRecBufClose(G_sstat[i].rec))!=PXSUCCESS) err=0;
            if ((G_sstat[i].err=PXTblClose(G_sstat[i].handle))!=PXSUCCESS) err=0;
        }
        G_sstat[i].name[0]=0;
        G_sstat[i].open=0;
        G_sstat[i].modified=0;
    }
    RETURN(err);
}
// read record from table 'name' where rtype is FRST,LAST,CURR,NEXT,PREV.
int stread(char *name,int rtype)
{
    int s;
    LOG('E',M_DBM,11);
    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0);
    switch(rtype) {
        case FRST :
            if ((G_sstat[s].err=PXRecFirst(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
            break;
        case LAST :
            if ((G_sstat[s].err=PXRecLast(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
            break;
        case PREV :
            if ((G_sstat[s].err=PXRecPrev(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
            break;
        case NEXT :
            if ((G_sstat[s].err=PXRecNext(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
            break;
        case CURR :
            break;
        default :
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,rtype))!=PXSUCCESS) RETURN(0);
                            
    }
    if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) RETURN(0);
    G_sstat[s].modified=0;
    RETURN(1);
}
// write/update record in table 'name'
int stwrite(char *name)
{
    RECORDHANDLE trec;
    int s,i;
    LOG('E',M_DBM,12);
    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0);
    if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        if (G_sstat[s].err!=PXERR_KEYVIOL) RETURN(0);
    }
    else  {
        sendrec(name,RECUPDATE);
        G_sstat[s].modified=0;
		if (!strcmp(name,"transact")) stflush();
        RETURN(1);
    }
    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURN(0);
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS) RETURN(0);
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) RETURN(0);

    sendrec(name,RECUPDATE);
    G_sstat[s].modified=0;
    RETURN(1);
}
// write/update record in table 'name' but don't transmit to other systems
int stwritelocal(char *name)
{
    RECORDHANDLE trec;
    int s,i;
    LOG('E',M_DBM,12);
    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0);
    if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        if (G_sstat[s].err!=PXERR_KEYVIOL) RETURN(0);
    }
    else  {
        G_sstat[s].modified=0;
        RETURN(1);
    }
    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURN(0);
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS) RETURN(0);
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) RETURN(0);

    G_sstat[s].modified=0;
    RETURN(1);
}
// delete record in table 'name'
int stdelrec(char *name,int recnum)
{
    int s;
    LOG('E',M_DBM,13);

    if ((s=snum(name))<0) RETURN(0);

    G_sstat[s].err=0;

    if (!stread(name,recnum)) RETURN(0);

    sendrec(name,RECDELETE);
    if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
    RETURN(1);
}
// search table (secondary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
int stsrch(char *name,char *fname,int mode)
{
    int s,k,i;
    int smode;
    LOG('E',M_DBM,14);
    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0);
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
        if (i<1) RETURN(0);
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,smode))!=PXSUCCESS) RETURN(0);
    }
    else {
        if (fname==NULL) {
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,mode,smode))!=PXSUCCESS) RETURN(0);
        }
        else {
            if (!(k=knum(name,fname))) RETURN(0);
            if ((G_sstat[s].err=PXSrchFld(G_sstat[s].handle,G_sstat[s].rec,k,smode))!=PXSUCCESS) RETURN(0);
        }
    }
    RETURN(1);
}
// search table (primarary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
int stsrchp(char *name,int nflds,int mode)
{
    int s,k,i;
    int smode;

    if ((s=snum(name))<0) RETURN(0);
    G_sstat[s].err=0;
    if (!stopen(name)) RETURN(0);
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
        for (i=0;i<G_store[s].numitem;i++) 
            if (!(G_store[s].key&(0x80000000L>>i))) break;

        if (i<1) RETURN(0);
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,smode))!=PXSUCCESS) RETURN(0);
    }
    else {
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,smode))!=PXSUCCESS) RETURN(0);
    }
    RETURN(1);
}
// get field 'fname' from table 'name' and place it in variable 'var'
int stget(char *name,char *fname,char *var)
{
    int len,type;
    char buf[81];
    short i;
    long l;
    double d;
    DATE   dt;
    int s;
    int f;
    LOG('E',M_DBM,15);
    if ((s=snum(name))<0) RETURN(0);
    if ((f=fnum(name,fname))<0) RETURN(0);
    G_sstat[s].err=0;
    len=G_lib[G_store[s].li[f]].len;
    type=G_lib[G_store[s].li[f]].type;
    if (!stopen(name)) RETURN(0);

    switch (type) {
        case 'K' :
            if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,f+1,&i))!=PXSUCCESS) RETURN(0);
            if (ISBLANKSHORT(i)) {
                buf[0]=0;
            }
            else {
                sprintf(buf,"%d",i);
                dottrunc(buf);
            }
            break;
        case 'M' :
        case '9' :
        case 'W' :
            if (len<5) {
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,f+1,&i))!=PXSUCCESS) RETURN(0);
                if (ISBLANKSHORT(i)) {
                    buf[0]=0;
                }
                else {
                    sprintf(buf,"%d",i);
                    dottrunc(buf);
                }
            }
            else {
                if (len<16) {
                    if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,f+1,&d))!=PXSUCCESS) RETURN(0);
                    if (ISBLANKDOUBLE(d)) {
                        buf[0]=0;
                    }
                    else {
                        sprintf(buf,"%lf",d);
                        dottrunc(buf);
                    }
                }
                else {
                    if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,f+1,len+1,buf))!=PXSUCCESS) RETURN(0);
                }
            }
            break;

        case 'A' :
        case 'U' :
        case 'L' :
        case 'X' :
        case 'T' :
        case 'D' :
        case 'P' :
            if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,f+1,len+1,buf))!=PXSUCCESS) RETURN(0);
            break;
    }
    strcpy(var,buf);
    RETURN(1);
}
// blank the record buffer in table 'name'
int stblank(char *name)
{
    int s,i;
    LOG('E',M_DBM,16);
    if ((s=snum(name))<0) RETURN(0);
    if (!stopen(name)) RETURN(0);
    for (i=1;i<=G_store[s].numitem;i++) {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,i))!=PXSUCCESS) RETURN(0);
    }
    RETURN(1);
}
// empty the table 'name'
int stempty(char *name)
{
    int s;
    char tmp[80];

    if ((s=snum(name))<0) RETURN(0);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if (!stclose(name)) RETURN(0);
    if ((G_sstat[s].err=PXTblEmpty(tmp))!=PXSUCCESS) RETURN(0);
    RETURN(1);
}
// put variable 'var' it in field 'fname' from table 'name' 
int stput(char *name,char *fname,char *var)
{
    FIELDHANDLE fh;
    int len,type;
    char buf[81];
    short i;
    long l;
    double d;
    int s;
    int f;
    LOG('E',M_DBM,17);
    if ((s=snum(name))<0) RETURN(0);
    if ((f=fnum(name,fname))<0) RETURN(0);
    if (!stopen(name)) RETURN(0);
    
    G_sstat[s].err=0;
    if (var==NULL) {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,f+1))!=PXSUCCESS) {
            RETURN(0);
        }
        else {
            RETURN(1);
        }
    }
    len=G_lib[G_store[s].li[f]].len;
    type=G_lib[G_store[s].li[f]].type;

    switch (type) {
        case 'K' :
            i=atoi(var);
            if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,f+1,i))!=PXSUCCESS) RETURN(0);
            break;

        case 'M' :
        case '9' :
        case 'W' :
            if (len<5) {
                i=atoi(var);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,f+1,i))!=PXSUCCESS) RETURN(0);
            }
            else {
                if (len<16) {
                    d=strtod(var,NULL);
                    if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,f+1,d))!=PXSUCCESS) RETURN(0);
                }
                else {
                    if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,f+1,var))!=PXSUCCESS) RETURN(0);
                }
            }
            break;

        case 'A' :
        case 'U' :
        case 'L' :
        case 'X' :
        case 'T' :
        case 'D' :
        case 'P' :
            if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,f+1,var))!=PXSUCCESS) RETURN(0);
            break;
    }
    G_sstat[s].modified=1;
    RETURN(1);
}
// duplicate a table to a temp table using ~ame for name and sec search parameters
int stdup(char *name,char *fname,int mode)
{
    int s;
    int smode;
    char newname[9];

    if ((s=snum(name))<0) RETURN(0);

    strcpy(newname,name);
    newname[0]='~';
    strcpy(G_store[G_nums].name,newname);
    G_store[G_nums].key    =G_store[s].key;
    G_store[G_nums].skey   =G_store[s].skey;
    G_store[G_nums].numitem=G_store[s].numitem;
    memcpy(G_store[G_nums].li,G_store[s].li,32*sizeof(int));
    G_nums++;

    stempty(newname);
    if (!stopen(newname)) RETURN(0);
    if (!stopen(name)) RETURN(0);
    if (fname!=NULL) {
        smode=FRST;
        while (stsrch(name,fname,smode)) {
            stread(name,CURR);
            PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec);
            stwrite(newname);
            smode=NEXT;
        }
    }
    else {
        smode=FRST;
        while (stsrchp(name,mode,smode)) {
            stread(name,CURR);
            PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec);
            stwrite(newname);
            smode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    return(1);
}
// remove a duplicated table and copy contents back to original if 'copyback'
int stremdup(char *name,int copyback)
{
    char newname[9];
    int s;
    int t;
    int mode=FRST;

    strcpy(newname,name);
    newname[0]='~';
    if (copyback) {
        stopen(name);
        stopen(newname);
        t=snum(newname);
        s=snum(name);
        while (stread(newname,mode)) {
            PXRecBufCopy(G_sstat[t].rec,G_sstat[s].rec);
            stwrite(name);
            mode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    G_nums--;
    return(1);
}
// delete all records matched by search parameters
int stdelgrp(char *name,char *fname,int mode)
{
    int s;
    if ((s=snum(name))<0) RETURN(0);
    if (!stopen(name)) RETURN(0);
    if (fname!=NULL) {
        while (stsrch(name,fname,FRST)) {
            stread(name,CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
        }
    }
    else {
        while (stsrchp(name,mode,FRST)) {
            stread(name,CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURN(0);
        }
    }
    stclose(name);
    return(1);
}
// flush all modified buffers
int stflush(void)
{
	streinit();
//    if (PXSave()!=PXSUCCESS) return(0);
    return(1);
}
// get a record into r and set 'flen' to the length of the buffer
int stgetrec(char *name,char *r,int *flen)
{
    int i,s,len;
    short j;
    double d;
    char tmp[80];
    int olen=9;
    LOG('E',M_DBM,6);

    if ((s=snum(name))<0) RETURN(0);
    if (!stopen(name)) RETURN(0);
    G_sstat[s].err=0;
    strcpy(r,name);
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 'K' :
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS) RETURN(0);
                len=sizeof(int);
                if ((olen+len)>=*flen) return(0);
                *((int *)&(r[olen]))=j;
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (G_lib[G_store[s].li[i]].len<5) {
                    if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS) RETURN(0);
                    len=sizeof(int);
                    if ((olen+len)>=*flen) return(0);
                    *((int *)&(r[olen]))=j;
                }
                else {
                    if (G_lib[G_store[s].li[i]].len<16) {
                        if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,i+1,&d))!=PXSUCCESS) RETURN(0);
                        len=sizeof(double);
                        if ((olen+len)>=*flen) return(0);
                        *((double *)&(r[olen]))=d;
                    }
                    else {
                        if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS) RETURN(0);
                        len=G_lib[G_store[s].li[i]].len+1;
                        if ((olen+len)>=*flen) return(0);
                        strcpy(&(r[olen]),tmp);
                    }
                }
                break;
            case 'D' :
            case 'A' :
            case 'X' :
            case 'U' :
            case 'L' :
            case 'T' :
            case 'P' :
                if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS) RETURN(0);
                len=G_lib[G_store[s].li[i]].len+1;
                if ((olen+len)>=*flen) return(0);
                strcpy(&(r[olen]),tmp);
                break;
            default :
                RETURN(0);
        }
        olen+=len;
    }
    *flen=olen;
    RETURN(1);
}
// put a record from r
int stputrec(char *r)
{
    char name[10];
    int i,s,len;
    int olen=9;
    LOG('E',M_DBM,6);

    strncpy(name,r,9);
//    sendmsg("OUTPUT1",'o',0,2,"%s",name);
    if ((s=snum(name))<0) RETURN(0);
    if (!stopen(name)) RETURN(0);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 'K' :
                len=sizeof(int);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS) RETURN(0);
//                sendmsg("OUTPUT1",'o',0,i,"%d",*((short *)&(r[olen])));
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (G_lib[G_store[s].li[i]].len<5) {
                    len=sizeof(int);
                    if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS) RETURN(0);
//                    sendmsg("OUTPUT1",'o',0,i,"%d",*((short *)&(r[olen])));
                }
                else {
                    if (G_lib[G_store[s].li[i]].len<16) {
                        len=sizeof(double);
                        if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,i+1,*((double *)&(r[olen]))))!=PXSUCCESS) RETURN(0);
//                        sendmsg("OUTPUT1",'o',0,i,"%f",*((double *)&(r[olen])));
                    }
                    else {
                        len=G_lib[G_store[s].li[i]].len+1;
                        if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS) RETURN(0);
//                        sendmsg("OUTPUT1",'o',0,i,"%s",&r[olen]);
                    }
                }
                break;
            case 'D' :
            case 'A' :
            case 'X' :
            case 'U' :
            case 'L' :
            case 'T' :
            case 'P' :
                len=G_lib[G_store[s].li[i]].len+1;
                if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS) RETURN(0);
//                sendmsg("OUTPUT1",'o',0,i,"%s",&r[olen]);
                break;
            default :
                RETURN(0);
        }
        olen+=len;
    }
    G_sstat[s].modified=1;
    RETURN(1);
}
// send a record to BOS if in the RUPDATE list from config
int sendrec(char *name,int type)
{
    char r[MAXDGSIZE];
    int len=MAXDGSIZE;

    if (G_netok&&((G_frupd[snum(name)]&1)==1)) {
        if (!stgetrec(name,r,&len)) return(0);
        if ((sendmsg("LAN",'S',G_toname,1,len,r,type))==(-1)) return(0);
    }

    return(1);
}
// receive a record and update local database
int receiverec(void)
{
    char r[MAXDGSIZE];
    int len=MAXDGSIZE;
    int type,pos,uid;
    char file[33],*t,n[20];

    type=sendmsg("LAN",'R',&len,r);
    switch (type) {
		case USERLOGON	  :
			t=r+2;
			*(t++)=0;
			while ((*t)&&(!isdigit(*t))) t++;
			if (*t) {
			    if (!stput(USER_S,USID,r)) return(0);
			    if (stsrch(USER_S,NULL,1)) {
                    stread(USER_S,CURR);
					stput(USER_S,POSN,t);
                    stwrite(USER_S);
	                G_finredraw=0;
				}
			}
			break;
		case USERLOGOFF	  :
			t=r+3;
			*t=0;
		    if (!stput(USER_S,USID,r)) return(0);
		    if (stsrch(USER_S,NULL,1)) {
                stread(USER_S,CURR);
				stput(USER_S,POSN,"0");
                stwrite(USER_S);
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
                    if (stread(r,CURR)) {
						PXRecDelete(G_sstat[snum(r)].handle);
		                G_finredraw=0;
					}
                }
            }
            break;
        case FILERXDONE :
			sendmsg("LAN",'S',G_toname,1,1,"",FILETXDONE);
        case FILETXDONE :
            streinit();
            break;
        case 0 :
            break;
    }
    return(1);
}
int stcopyrec(char *s,char *d)
{
    int f1,f2;
    if ((f1=snum(s))<0) RETURN(0);
    if ((f2=snum(d))<0) RETURN(0);
    if (!stopen(d)) RETURN(0);
    G_sstat[f1].err=0;
    if ((G_sstat[f1].err=PXRecBufCopy(G_sstat[f1].rec,G_sstat[f2].rec))!=0) RETURN(0);
    stwrite(d);
    return(1);
}

