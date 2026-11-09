#define PDXDEV_C
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <ctype.h>
#include <pxengine.h>

#include "types.h"
#include "message.h"
#include "control.h"
#include "config.h"
#include "function.h"
#include "dst.h"

#pragma option -p-
#include "pdxdev.h"

//extern void mprintf(CHAR *fmt, ... );
void prerror(INT s,INT ep)
{
    switch (G_sstat[s].err) {
        case 31 :
        case 89 :
            break;
        default :
            ep++;
//            sendmsg("OUTPUT1",'o',0,1,"Error At %d = %d",ep,G_sstat[s].err);
//            sendmsg("INPUT1",'i');
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
	ENTRY(4250);
    memset(G_sstat,0,sizeof(G_sstat));
    sendmsg("OUTPUT1",0,1,"SWAPSIZE=%d",G_swapsize);
    if ((G_sstat[0].err=PXSetDefaults(G_swapsize,20,20,40,40,PXDEFAULT))!=PXSUCCESS) {
        prerror(0,0);
        RETURNV(0);
    }
    PXSetHWHandler(TRUE);
    if ((G_sstat[0].err=PXInit())!=PXSUCCESS) {
        prerror(0,0);
        RETURNV(0);
    }
    memset(G_sstat,0,sizeof(G_sstat));
//    sendmsg("INPUT1",'A',2,receiverec);
    RETURNV(1);
}
// reinitialise the database system
INT streinit(void)
{
	ENTRY(4260);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURNV(0);
    PXSetHWHandler(TRUE);
    if (PXInit()!=PXSUCCESS) RETURNV(0);
    RETURNV(1);
}
// shutdown the database system
INT stexit(void)
{
	ENTRY(4270);
    stcloseall();
    if (PXExit()!=PXSUCCESS) RETURNV(0);
//    sendmsg("INPUT1",'D',receiverec);
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
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(nr);
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(nr);
    RETURNV(nr);
}
// check if table exists
INT stexist(CHAR *name)
{
    CHAR tmp[80];
    INT i,s;
	ENTRY(4300);
    if ((s=snum(name))<0) RETURNV(0);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if (PXTblExist(tmp,&i)!=PXSUCCESS) RETURNV(0);
    if (i) RETURNV(1);
    RETURNV(0);
}
// create table 'name'
INT stcreate(CHAR *name)
{
    CHAR *tf[NUMFIELDS];
    CHAR *nf[NUMFIELDS];
    INT i,len;
    CHAR tmp[80];
    static INT s;
    static CHAR lname[10];
	ENTRY(4310);

	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if ((G_sstat[s].err=PXTblExist(tmp,&i))!=PXSUCCESS) RETURNV(0);
    if (i) RETURNV(1);

    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
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
                RETURNV(0);
        }
    }
    if ((G_sstat[s].err=PXTblCreate(tmp,G_store[s].numitem,nf,tf))!=PXSUCCESS) {
	    for (i=0;i<G_store[s].numitem;i++) FREE(tf[i]);
//		sendmsg("OUTPUT1",'o',0,0,"%s %d",tmp,G_store[s].numitem);
//		sendmsg("INPUT1",'i');
		RETURNV(0);
	}
    for (i=0;i<G_store[s].numitem;i++) FREE(tf[i]);

    for (i=0;i<G_store[s].numitem;i++) {
        if (!(G_store[s].key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURNV(1);
    if ((G_sstat[s].err=PXKeyAdd(tmp,i,G_fhs,PRIMARY))!=PXSUCCESS) RETURNV(0);
    for (i=0;i<G_store[s].numitem;i++) {
        if (G_store[s].skey&(0x80000000L>>i)) {
            if ((G_sstat[s].err=PXKeyAdd(tmp,1,&G_fhs[i],INCSECONDARY))!=PXSUCCESS) RETURNV(0);
        }
    }
    
    RETURNV(1);
}
// delete table 'name'
INT stdelete(CHAR *name)
{
    INT s,i;
    CHAR tmp[80];
	ENTRY(4320);
    if ((s=snum(name))<0) RETURNV(0);
    stclose(name);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if ((G_sstat[s].err=PXTblExist(tmp,&i))!=PXSUCCESS) RETURNV(0);
    if (!i) RETURNV(1);

    G_sstat[s].err=0;
    if ((G_sstat[s].err=PXTblDelete(tmp))!=PXSUCCESS) RETURNV(0);
    RETURNV(1);
}
// open table 'name'
INT stopen(CHAR *name)
{
    CHAR tmp[80];
    static INT s;
    static CHAR lname[10];
	ENTRY(4330);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    if (!G_sstat[s].open) {
		if (G_dbmap[s]!=0) {
    		sprintf(tmp,"%s%s",G_databas2,name);
		} else {
    		sprintf(tmp,"%s%s",G_database,name);
		}
        if (!stcreate(name)) RETURNV(0);
        if ((G_sstat[s].err=PXTblOpen(tmp,&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS) RETURNV(0);
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS) RETURNV(0);
        strcpy(G_sstat[s].name,name);
        G_sstat[s].modified=0;
        G_sstat[s].open=1;
    }
    RETURNV(1);
}
// close table 'name'
INT stclose(CHAR *name)
{
    INT s;
    INT err=1;
	ENTRY(4340);
    if ((s=snum(name))<0) RETURNV(0);
    G_sstat[s].err=0;
    if (G_sstat[s].open) {
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS) err=0;
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS) err=0;
    }
    G_sstat[s].name[0]=0;
    G_sstat[s].open=0;
    G_sstat[s].modified=0;
    RETURNV(err);
}
// close all open tables
INT stcloseall(void)
{
    INT i;
    INT err=1;
	ENTRY(4350);
    for (i=0;i<G_nums;i++) {
        if (G_sstat[i].open) {
            if ((G_sstat[i].err=PXRecBufClose(G_sstat[i].rec))!=PXSUCCESS) err=0;
            if ((G_sstat[i].err=PXTblClose(G_sstat[i].handle))!=PXSUCCESS) err=0;
        }
        G_sstat[i].name[0]=0;
        G_sstat[i].open=0;
        G_sstat[i].modified=0;
    }
    RETURNV(err);
}
// read record from table 'name' where rtype is FRST,LAST,CURR,NEXT,PREV.
INT stread(CHAR *name,INT rtype)
{
    static INT s;
    static CHAR lname[10];
	ENTRY(4360);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
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
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,rtype))!=PXSUCCESS) {
                prerror(s,11);
                RETURNV(0);
            }
                            
    }
    if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) {
        prerror(s,12);
        RETURNV(0);
    }
    G_sstat[s].modified=0;
    RETURNV(1);
}
// write/update record in table 'name'
INT stwrite(CHAR *name)
{
    INT i;
    static INT s;
    static CHAR lname[10];
	ENTRY(4370);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
    }
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
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
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS) RETURNV(0);
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS) RETURNV(0);

    G_sstat[s].modified=0;
    RETURNV(1);
}
// delete record in table 'name'
INT stdelrec(CHAR *name,INT recnum)
{
    INT s;
	ENTRY(4390);

    if ((s=snum(name))<0) RETURNV(0);

    G_sstat[s].err=0;

    if (!stread(name,recnum)) RETURNV(0);

//    sendrec(name,RECDELETE);
    if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURNV(0);
    RETURNV(1);
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
        if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(0);
    }
    else {
        if (fname==NULL) {
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,mode,smode))!=PXSUCCESS) {
                prerror(s,2);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(0);
        }
        else {
            if (!(k=knum(name,fname))) RETURNV(0);
            if ((G_sstat[s].err=PXSrchFld(G_sstat[s].handle,G_sstat[s].rec,k,smode))!=PXSUCCESS) {
                prerror(s,3);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(0);
        }
    }
    RETURNV((INT)nr);
}
// search table (primarary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
INT stsrchp(CHAR *name,INT nflds,INT mode)
{
    INT smode,i;
    LONG nr=0L;
    static INT s;
    static CHAR lname[10];
	ENTRY(4410);
    if (strcmp(name,lname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lname,name);
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
        for (i=0;i<G_store[s].numitem;i++) 
            if (!(G_store[s].key&(0x80000000L>>i))) break;

        if (i<1) RETURNV(0);
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,smode))!=PXSUCCESS) {
            prerror(s,4);
            RETURNV(0);
        }
        if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(0);
    }
    else {
        if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,smode))!=PXSUCCESS) {
            prerror(s,5);
			RETURNV(0);
		}
        if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS) RETURNV(0);
    }
    RETURNV((INT)nr);
}
// get field 'fname' from table 'name' and place it in variable 'var'
INT stget(CHAR *name,CHAR *fname,CHAR *var)
{
    INT len,type;
    CHAR buf[81];
    short i;
    double d;
    static INT s,f;
    static CHAR lsname[10];
    static CHAR lfname[10];
	ENTRY(4420);
    if (strcmp(name,lsname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lsname,name);
        if ((f=fnum(name,fname))<0) RETURNV(0);
        strcpy(lfname,fname);
    } else {
        if (strcmp(fname,lfname)) {
            if ((f=fnum(name,fname))<0) RETURNV(0);
            strcpy(lfname,fname);
        }
    }
    G_sstat[s].err=0;
    len=G_lib[G_store[s].li[f]].len;
    type=G_lib[G_store[s].li[f]].type;
    if (!stopen(name)) RETURNV(0);

    switch (type) {
        case 'K' :
            if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,f+1,&i))!=PXSUCCESS) RETURNV(0);
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
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,f+1,&i))!=PXSUCCESS) RETURNV(0);
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
                    if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,f+1,&d))!=PXSUCCESS) RETURNV(0);
                    if (ISBLANKDOUBLE(d)) {
                        buf[0]=0;
                    }
                    else {
                        sprintf(buf,"%lf",d);
                        dottrunc(buf);
                    }
                }
                else {
                    if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,f+1,len+1,buf))!=PXSUCCESS) RETURNV(0);
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
            if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,f+1,len+1,buf))!=PXSUCCESS) {
				RETURNV(0);
			}
            break;
    }
    strcpy(var,buf);
    RETURNV(1);
}
// blank the record buffer in table 'name'
INT stblank(CHAR *name)
{
    INT s,i;
	ENTRY(4430);
    if ((s=snum(name))<0) RETURNV(0);
    if (!stopen(name)) RETURNV(0);
    for (i=1;i<=G_store[s].numitem;i++) {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,i))!=PXSUCCESS) RETURNV(0);
    }
    RETURNV(1);
}
// empty the table 'name'
INT stempty(CHAR *name)
{
    INT s;
    CHAR tmp[80];
	ENTRY(4440);

    if ((s=snum(name))<0) RETURNV(0);
	if (G_dbmap[s]!=0) {
    	sprintf(tmp,"%s%s",G_databas2,name);
	} else {
    	sprintf(tmp,"%s%s",G_database,name);
	}
    if (!stclose(name)) RETURNV(0);
    if ((G_sstat[s].err=PXTblEmpty(tmp))!=PXSUCCESS) RETURNV(0);
    RETURNV(1);
}
// put variable 'var' it in field 'fname' from table 'name' 
INT stput(CHAR *name,CHAR *fname,CHAR *var)
{
    INT len,type;
    short i;
    double d;
    static INT s,f;
    static CHAR lsname[10];
    static CHAR lfname[10];
	ENTRY(4450);
    if (strcmp(name,lsname)) {
        if ((s=snum(name))<0) RETURNV(0);
        strcpy(lsname,name);
    }
    if (strcmp(fname,lfname)) {
        if ((f=fnum(name,fname))<0) RETURNV(0);
        strcpy(lfname,fname);
    }
    G_sstat[s].err=0;
    if (!stopen(name)) RETURNV(0);
    if (var==NULL) {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,f+1))!=PXSUCCESS) {
            RETURNV(0);
        }
        else {
            RETURNV(1);
        }
    }
    len=G_lib[G_store[s].li[f]].len;
    type=G_lib[G_store[s].li[f]].type;

    switch (type) {
        case 'K' :
            i=atoi(var);
            if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,f+1,i))!=PXSUCCESS) RETURNV(0);
            break;

        case 'M' :
        case '9' :
        case 'W' :
            if (len<5) {
                i=atoi(var);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,f+1,i))!=PXSUCCESS) RETURNV(0);
            }
            else {
                if (len<16) {
                    d=strtod(var,NULL);
                    if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,f+1,d))!=PXSUCCESS) RETURNV(0);
                }
                else {
                    if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,f+1,var))!=PXSUCCESS) RETURNV(0);
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
            if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,f+1,var))!=PXSUCCESS) RETURNV(0);
            break;
    }
    G_sstat[s].modified=1;
    RETURNV(1);
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
        while (stread(newname,mode)) {
            PXRecBufCopy(G_sstat[t].rec,G_sstat[s].rec);
            stwrite(name);
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
            stread(name,CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURNV(0);
        }
    }
    else {
        while (stsrchp(name,mode,FRST)) {
            stread(name,CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS) RETURNV(0);
        }
    }
    stclose(name);
    RETURNV(1);
}
// flush all modified buffers
INT stflush(void)
{
	ENTRY(4490);
//	streinit();
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
    if (!stopen(name)) RETURNV(0);
    G_sstat[s].err=0;
    strcpy(r,name);
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 'K' :
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS) RETURNV(0);
                len=sizeof(INT);
                if ((olen+len)>=*flen) RETURNV(0);
                *((INT *)&(r[olen]))=j;
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (G_lib[G_store[s].li[i]].len<5) {
                    if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS) RETURNV(0);
                    len=sizeof(INT);
                    if ((olen+len)>=*flen) RETURNV(0);
                    *((INT *)&(r[olen]))=j;
                }
                else {
                    if (G_lib[G_store[s].li[i]].len<16) {
                        if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,i+1,&d))!=PXSUCCESS) RETURNV(0);
                        len=sizeof(double);
                        if ((olen+len)>=*flen) RETURNV(0);
                        *((double *)&(r[olen]))=d;
                    }
                    else {
                        if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS) RETURNV(0);
                        len=G_lib[G_store[s].li[i]].len+1;
                        if ((olen+len)>=*flen) RETURNV(0);
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
                if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS) RETURNV(0);
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
//    sendmsg("OUTPUT1",'o',0,2,"%s",name);
    if ((s=snum(name))<0) RETURNV(0);
    if (!stopen(name)) RETURNV(0);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++) {
        switch(G_lib[G_store[s].li[i]].type) {
            case 'K' :
                len=sizeof(INT);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS) RETURNV(0);
//                sendmsg("OUTPUT1",'o',0,i,"%d",*((short *)&(r[olen])));
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (G_lib[G_store[s].li[i]].len<5) {
                    len=sizeof(INT);
                    if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS) RETURNV(0);
//                    sendmsg("OUTPUT1",'o',0,i,"%d",*((short *)&(r[olen])));
                }
                else {
                    if (G_lib[G_store[s].li[i]].len<16) {
                        len=sizeof(double);
                        if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,i+1,*((double *)&(r[olen]))))!=PXSUCCESS) RETURNV(0);
//                        sendmsg("OUTPUT1",'o',0,i,"%f",*((double *)&(r[olen])));
                    }
                    else {
                        len=G_lib[G_store[s].li[i]].len+1;
                        if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS) RETURNV(0);
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
                if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS) RETURNV(0);
//                sendmsg("OUTPUT1",'o',0,i,"%s",&r[olen]);
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
        if ((sendmsg("LAN",'S',G_toname,1,len,r,type))==(-1)) RETURNV(0);
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

    type=sendmsg("LAN",'R',&len,r);
    switch (type) {
		case USERLOGON	  :
			t=r+2;
			*(t++)=0;
			while ((*t)&&(!isdigit(*t))) t++;
			if (*t) {
			    if (!stput(USER_S,USID,r)) RETURNV(0);
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
		    if (!stput(USER_S,USID,r)) RETURNV(0);
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
    RETURNV(1);
} */
INT stcopyrec(CHAR *s,CHAR *d)
{
    INT f1,f2;
	ENTRY(4540);
    if ((f1=snum(s))<0) RETURNV(0);
    if ((f2=snum(d))<0) RETURNV(0);
    if (!stopen(d)) RETURNV(0);
    G_sstat[f1].err=0;
    if ((G_sstat[f1].err=PXRecBufCopy(G_sstat[f1].rec,G_sstat[f2].rec))!=0) RETURNV(0);
    stwrite(d);
    RETURNV(1);
}

// pdxdev control routine
INT pdx_control(INT type,va_list ap)
{
	CHAR *name,*var,*fname;
	INT mode,recnum;
    INT retval=0;
	ENTRY(4550);
    switch(type) {
		case 'I'  :
			retval=stinit();
			break;
		case 'E'  :
			retval=stexit();
			break;
		case 'RI' :
			retval=streinit();
			break;
		case 'x'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                retval=stexist(name);
            }
			break;
		case 'C'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stcreate(name);
            }
			break;
		case 'D'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stdelete(name);
            }
			break;
		case 'O'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stopen(name);
            }
			break;
		case 'c'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stclose(name);
            }
			break;
		case 'ca' :
			retval=stcloseall();
			break;
		case 'nr' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
			    retval=(INT)stnumrec(name);
            }
			break;
		case 'rn' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
			    retval=(INT)strecnum(name);
            }
			break;
		case 'r'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
			    retval=stread(name,mode);
            }
			break;
		case 'w'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stwrite(name);
            }
			break;
		case 'dr' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
    			retval=stdelrec(name,mode);
            }
			break;
		case 's'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=stsrch(name,fname,mode);
            }
			break;
		case 'sp' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                recnum=va_arg(ap,INT);
                mode=va_arg(ap,INT);
			    retval=stsrchp(name,recnum,mode);
            }
			break;
		case 'g'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
			    retval=stget(name,fname,var);
            }
			break;
		case 'b'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stblank(name);
            }
			break;
		case 'e'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
    			retval=stempty(name);
            }
			break;
		case 'p'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
			    retval=stput(name,fname,var);
            }
			break;
		case 'd'  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=stdup(name,fname,mode);
            }
			break;
		case 'rd' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
			    retval=stremdup(name,mode);
            }
			break;
		case 'dg' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
			    retval=stdelgrp(name,fname,mode);
            }
			break;
		case 'f'  :
			retval=stflush();
			break;
/*		case 'gr' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                var=va_arg(ap,CHAR *);
                flen=va_arg(ap,INT *);
			    retval=stgetrec(name,var,flen);
            }
			break;
		case 'pr' :
            var=va_arg(ap,CHAR *);
			retval=stputrec(var);
			break;
		case 'sr' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                mode=va_arg(ap,INT);
			    retval=sendrec(name,mode);
            }
			break;
		case 'rr' :
			retval=receiverec();
			break; */
		case 'cr' :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE")) {
                fname=va_arg(ap,CHAR *);
			    retval=stcopyrec(name,fname);
            }
			break;
    }
    RETURNV(retval);
}
//___________________________________________________________________________
#pragma option -p.

