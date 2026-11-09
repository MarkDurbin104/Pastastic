/****************************************************************************
* Project     : GPA
* File        : pdxdev.c
* Description : Paradox interface routines
*
* $Revision:   1.5  $  $Date:   Nov 01 1995 14:57:20  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/pdxdev.c_v  $
* 
*    Rev 1.5   Nov 01 1995 14:57:20   JGRAY
* Aannotation amendment
* 
*    Rev 1.4   Oct 31 1995 16:15:48   JGRAY
* Annotations
* 
*    Rev 1.3   Oct 27 1995 14:01:56   TBARTON
* Set G_swapsize to use up to 32 tables.
* Discard use of closeoldest().
* 
****************************************************************************/
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
#include "pxengine.h"               // Borland paradox interface definitions
#include "gpasizes.h"               // GPA field and array sizes
#include "types.h"                  // GPA typedefs and global defines
#include "message.h"                // declare functions in message.c module
#include "control.h"                //
#include "config.h"                 //
#include "function.h"               //
#include "dst.h"                    //
#pragma option -p-
#include "pdxdev.h"                 //

//************************************************************
//S A strange do nothing routine :JG
//D based on the error number modify a parameter
//P store number
//P action identifier - currently set numerically, starts at 7 in this file!
//R void

void prerror(INT s,INT ep)
{
    switch (G_sstat[s].err)
        {
        case PXERR_OUTOFRANGE :			// 31 - Argument out of range
            ep+=2;
            break;
        case PXERR_RECNOTFOUND :		// 89 - Record was not found
            ep+=3;
            break;
        default :
            ep++;
        }
}

//************************************************************
//S Truncate a numeric string at the decimal point
//D detail
//P parameter
//R TRUE 

void dottrunc(CHAR *s)
{
    ENTRY(4240);
    while (*s)
        {
        if (*s=='.')
            {
            *s=0;
            break;
            }
        s++;
        }
    RETURN;
}

//************************************************************
//S initialise the database system
//R TRUE = Ok, FALSE = failed

INT stinit(void)
{
    INT a,b,c;
    INT swapsize,maxtables,maxrecbufs,maxlocks,maxfiles;
    CHAR sortorder;

    ENTRY(4250);
    if (G_sstat==NULL)
        {
        G_sstat=MALLOC(NUMSTORES*sizeof(STORESTAT));
        memset(G_sstat,0,NUMSTORES*sizeof(STORESTAT));
        for (a=0;a<G_nums;a++)
            {
            strcpy(G_sstat[a].name,G_store[a].name);
            c=0;
            for (b=0;b<G_store[a].numitem;b++)
                {
                G_sstat[a].fofs[b]=c;
                switch (G_lib[G_store[a].li[b]].type)
                    {
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
            for (b=0;b<G_store[a].numitem;b++)
                {
                switch (G_lib[G_store[a].li[b]].type)
                    {
                    case 1 :
                    case 2 :
                        G_sstat[a].buf[G_sstat[a].fofs[b]]=0x80;
                        break;
                    }
                }
            
            }
        }
    PXTblCreateMode(PARADOX40);
    PXGetDefaults(&swapsize,&maxtables,&maxrecbufs,&maxlocks,&maxfiles,&sortorder);
//    G_swapsize=min(maxtables,7);
    G_swapsize=min(maxtables,32);
    printf("Pxdefaults = %d %d %d %d %d %d\n",
                    swapsize,maxtables,maxrecbufs,maxlocks,maxfiles,sortorder);
    printf("Swap %d maxtables %d maxrecbufs %d maxlocks %d maxfiles %d sortorder %d\n",
                    swapsize,maxtables,maxrecbufs,maxlocks,maxfiles,sortorder);
    if ((G_sstat[0].err=PXWinInit("PxEngine",PXSINGLECLIENT))!=PXSUCCESS)
        { // PXSINGLECLIENT
        prerror(0,0);
        RETURNV(0);
        }
//    sendmsg("INPUT1",MESSAGE_A,2,receiverec);
    RETURNV(1);
}

//************************************************************
//S reinitialise the database system
//R TRUE = Ok, FALSE = failed

INT streinit(void)
{
    INT a,b,c,d,e;
    CHAR f;
    ENTRY(4260);
    stcloseall();
    if (PXExit()!=PXSUCCESS)
        RETURNV(0);
    PXTblCreateMode(PARADOX40);
    PXGetDefaults(&a,&b,&c,&d,&e,&f);
    G_swapsize=min(b,7);
    if (PXWinInit("PxEngine",PXSINGLECLIENT)!=PXSUCCESS)
        RETURNV(0); // PXSINGLECLIENT PXSHARED
    RETURNV(1);
}

//************************************************************
//S shutdown the database system
//R TRUE Ok, FALSE failure

INT stexit(void)
{
    INT a;
    ENTRY(4270);
    stcloseall();
    if (PXExit()!=PXSUCCESS)
        RETURNV(0);
//  sendmsg("INPUT1",MESSAGE_D,receiverec);
    if (G_sstat!=NULL)
        {
        for (a=0;a<G_nums;a++)
            if (G_sstat[a].buf!=NULL)
                FREE(G_sstat[a].buf);
        FREE(G_sstat);
        G_sstat=NULL;
        }
    RETURNV(1);
}

//************************************************************
//S RETURN the number of records in table 'name'
//P char string table name
//R 0L or no. of records(long)

LONG stnumrec(CHAR *name)
{
    LONG nr=0L;
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4280);
    if (strcmp(name,lname))
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        strcpy(lname,name);
        }
    if (G_msmap[s])
        RETURNV(msnumrec(name));
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0L);
    if ((G_sstat[s].err=PXTblNRecs(G_sstat[s].handle,&nr))!=PXSUCCESS)
        RETURNV(nr);
    RETURNV(nr);
}

//************************************************************
//S RETURN the current record number in table 'name'
//P char string table name
//R 0L or current record no.(long)

LONG strecnum(CHAR *name)
{
    LONG nr=0L;
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4290);
    if (strcmp(name,lname))
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        strcpy(lname,name);
        }
    if (G_msmap[s])
        RETURNV(msrecnum(name));
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(nr);
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS)
        RETURNV(nr);
    RETURNV(nr);
}

//************************************************************
//S return pointer to table path name
//D if snum doesn't find name assume alternative path, other check map to decide
//P char string table name
//R address of table name and path

CHAR *tabname(CHAR *name)
{
    static CHAR tmp[LENOFFULLPATH];
    INT s;
    if ((s=snum(name))<0)
        {
        sprintf(tmp,"%s%s",G_database,name);
        }
    else
        {
        if (G_dbmap[s]!=0)
            {
            sprintf(tmp,"%s%s",G_databas2,name);
            }
        else
            {
            sprintf(tmp,"%s%s",G_database,name);
            }
        }
    return(tmp);
}


//************************************************************
//S check if table exists
//R TRUE - exists, FALSE doesn't or couldn't find out

INT dbexist(CHAR *name)
{
    INT exists=0;
    if (PXTblExist(tabname(name),&exists)!=PXSUCCESS)
        RETURNV(0);
    if (exists)
        RETURNV(1);
    RETURNV(0);
}

//************************************************************
//S check if table exists
//D Complete duplicate function :JG
//P char string table name
//R TRUE - exists, FALSE doesn't or couldn't find out

INT stexist(CHAR *name)
{
    ENTRY(4300);
    if (dbexist(name))
        RETURNV(1);
    RETURNV(0);
}

//************************************************************
//S create table 'name'
//D detail
//P char string table name
//R TRUE success FALSE failed

INT stcreate(CHAR *name)
{
    // Is this NUMFIELDS figure actually correct? at 20 seems a bit low to me :JG
	// The GPA Data Store Designor only allows for 20 fields so this is OK. TB
    CHAR *tf[NUMFIELDS];	// array of data types of fields
    CHAR *nf[NUMFIELDS];	// array of names of fields
    INT i,len;
    INT s;
    ENTRY(4310);

    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)mscreate(name));
    if (G_sstat[s].open)
        RETURNV(1);
    if (dbexist(name))
        RETURNV(1);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++)
        {
        len=G_lib[G_store[s].li[i]].len;
        nf[i]=G_lib[G_store[s].li[i]].name;
        tf[i]=STRDUP("     ");
        switch(G_lib[G_store[s].li[i]].type)
            {
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
    if ((G_sstat[s].err=PXTblCreate(tabname(name),G_store[s].numitem,nf,tf))!=PXSUCCESS)
        {
        for (i=0;i<G_store[s].numitem;i++)
            FREE(tf[i]);
        RETURNV(0);
        }
    for (i=0;i<G_store[s].numitem;i++)
        FREE(tf[i]);
					// Now find the last field with a primary key set
    for (i=0;i<G_store[s].numitem;i++)
        {
        if (!(G_store[s].key&(0x80000000L>>i)))
            break;
        }
    if (i<1)
        RETURNV(1);
					// Set the primary key index.
					// i is the number of contiguous fields to be used.
    if ((G_sstat[s].err=PXKeyAdd(tabname(name),i,G_fhs,PRIMARY))!=PXSUCCESS)
        {
        prerror(s,0);
        RETURNV(0);
        }
//  for (i=0;i<G_store[s].numitem;i++) 
//      {
//      if (G_store[s].skey&(0x80000000L>>i)) 
//          {
//          if ((G_sstat[s].err=PXKeyAdd(tabname(name),1,&G_fhs[i],INCSECONDARY))!=PXSUCCESS) 
//              {
//              prerror(s,0);
//              RETURNV(0);
//              }
//          }
//      }   
    RETURNV(1);
}

//************************************************************
//S delete table
//P char string table name
//R TRUE success, FALSE failed

INT stdelete(CHAR *name)
{
    INT s;
    ENTRY(4320);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msdelete(name));
    stclose(name);

    if (!dbexist(name))
        RETURNV(1);

    G_sstat[s].err=0;
    if ((G_sstat[s].err=PXTblDelete(tabname(name)))!=PXSUCCESS)
        {
        prerror(s,0);
        RETURNV(0);
        }
    G_modified|=1L<<s;
    RETURNV(1);
}

//************************************************************
//S close oldest open table
//D Checks the store status open number and close the store set as 1
//D stclose reduces all open values by 1.
//D NOTE - this is flawed! A store currently in use by a while loop
//D can also be the store first opened!! Closing such a store will
//D lose the current record position!! Code not used as of v1.3 - TB

void closeoldest(void)
{
    INT i;
    if (G_numopen==G_swapsize)
        {
        for (i=0;i<NUMSTORES;i++)
            {
            if (G_sstat[i].open==1)
                {
                stclose(G_sstat[i].name);
                break;
                }
            }
        }
    G_numopen++;
}

//************************************************************
//S open table 'name'
//P char string table name
//R TRUE=Open ok, FALSE=failed

INT stopen(CHAR *name)
{
    static INT s;       // No reason for this to be static :JG
    ENTRY(4330);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msopen(name));
    if (!G_sstat[s].open)
        {
//        closeoldest();
        G_numopen++;
        if (!stcreate(name))
            RETURNV(0);
        G_sstat[s].handle=0;
        G_sstat[s].rec=0;
        if ((G_sstat[s].err=PXTblOpen(tabname(name),&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        G_sstat[s].modified=0;
        G_sstat[s].open=G_numopen;
    }
    RETURNV(1);
}

//************************************************************
//S close table 'name'
//P char string table name to close
//R TRUE=Ok, FALSE=failed

INT stclose(CHAR *name)
{
    INT s,i,j;
    INT err=1;
    ENTRY(4340);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msclose(name));    // always returns 1 and modifies byte 1 of name
    G_sstat[s].err=0;
    if (G_sstat[s].open)
        {
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS)
            err=0;
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS)
            err=0;
        j=G_sstat[s].open;
        G_sstat[s].open=0;
        for (i=0;i<NUMSTORES;i++)
            if (G_sstat[i].open>j)
                G_sstat[i].open--;
        G_numopen--;
    }
    G_sstat[s].modified=0;
    RETURNV(err);
}

//************************************************************
//S close all open tables
//R BOOL TRUE Ok, FALSE failed

INT stcloseall(void)
{
    INT i;
    INT err=1;
    ENTRY(4350);
    for (i=0;i<G_nums;i++)
        {
        if (G_msmap[i])
            {
            msclose(G_sstat[i].name);
        } else
            {
            if (G_sstat[i].open)
                {
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

//************************************************************
//S read record from table 'name' where rtype is FRST,LAST,CURR,NEXT,PREV.
//P char string table name
//P long type of read required or the record number required itself
//R TRUE=Ok, FALSE failed

INT stread(CHAR *name,LONG rtype)
{
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4360);
    if (strcmp(name,lname))
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        strcpy(lname,name);
    }
    if (G_msmap[s])
        RETURNV((INT)msread(name,rtype));
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0);
    switch(rtype)
        {
        case FRST :
            if ((G_sstat[s].err=PXRecFirst(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,7);
                RETURNV(0);
            }
            break;
        case LAST :
            if ((G_sstat[s].err=PXRecLast(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,8);
                RETURNV(0);
            }
            break;
        case PREV :
            if ((G_sstat[s].err=PXRecPrev(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,9);
                RETURNV(0);
            }
            break;
        case NEXT :
            if ((G_sstat[s].err=PXRecNext(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,10);
                RETURNV(0);
            }
            break;
        case CURR :
            break;
        default :
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,(RECORDNUMBER)rtype))!=PXSUCCESS)
                {
                prerror(s,11);
                RETURNV(0);
            }
                            
    }
    if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS)
        {
        prerror(s,12);
        RETURNV(0);
    }
    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS)
        {
        prerror(s,13);
        RETURNV(0);
    }

    G_sstat[s].modified=0;
    RETURNV(1);
}

//************************************************************
//S write/update record in table 'name'
//D n.b. sendrec has been commented out :JG
//P char string table name
//R TRUE  Ok, FALSE failed

INT stwrite(CHAR *name)
{
    INT i;
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4370);
    if (strcmp(name,lname))
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        strcpy(lname,name);
        }
    if (G_msmap[s])
        RETURNV((INT)mswrite(name));
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0);
    if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS)
        {
        prerror(s,14);
        RETURNV(0);
        }
    if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS)
        {
        if (G_sstat[s].err!=PXERR_KEYVIOL)
            {
            prerror(s,13);
            RETURNV(0);
            }
        }
    else
        {
        G_modified|=1L<<s;
        if (!strcmp(name,TRAN_S))
            stflush();
        G_sstat[s].modified=0;
        RETURNV(1);
        }
    // now process PXERR_KEYVIOL
    for (i=0;i<G_store[s].numitem;i++)  
        {
        if (!(G_store[s].key&(0x80000000L>>i)))
            break;
        }
    if (i<1)
        RETURNV(0);
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS)
        {
        prerror(s,15);
        RETURNV(0);
        }
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS)
        {
        prerror(s,16);
        RETURNV(0);
        }
//    sendrec(name,RECUPDATE);
    G_sstat[s].modified=0;
    G_modified|=1L<<s;
    RETURNV(1);
}

//************************************************************
//S write/update record in table 'name' but don't transmit to other systems
//D as for stwrite but doesn't flush for transact and doesn't issue sendrec (neither does stwrite)
//P char string table name
//R TRUE Ok, FALSE failed

INT stwritelocal(CHAR *name)
{
    INT i;
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4380);
    if (strcmp(name,lname))
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        strcpy(lname,name);
        }
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0);
    if ((G_sstat[s].err=PXRecInsert(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS)
        {
        if (G_sstat[s].err!=PXERR_KEYVIOL)
            RETURNV(0);
        }
    else
        {
        G_sstat[s].modified=0;
        RETURNV(1);
        }
    for (i=0;i<G_store[s].numitem;i++)
        {
        if (!(G_store[s].key&(0x80000000L>>i)))
            break;
    }
    if (i<1)
        RETURNV(0);
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,CLOSESTRECORD))!=PXSUCCESS)
        {
        prerror(s,0);
        RETURNV(0);
        }
    if ((G_sstat[s].err=PXRecUpdate(G_sstat[s].handle,G_sstat[s].rec))!=PXSUCCESS)
        {
        prerror(s,0);
        RETURNV(0);
        }
    G_sstat[s].modified=0;
    RETURNV(1);
}

//************************************************************
//S delete record in table 'name'
//P char string table name
//P long record number
//R TRUE Ok, FALSE failed

INT stdelrec(CHAR *name,LONG recnum)
{
    INT s;
    ENTRY(4390);

    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msdelrec(name,recnum));
    G_sstat[s].err=0;
    if (!stread(name,recnum))
        RETURNV(0);
//    sendrec(name,RECDELETE);
    if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS)
        {
        prerror(s,0);
        RETURNV(0);
    }
    G_modified|=1L<<s;
    RETURNV(1);
}

//************************************************************
//S for all fields accumulate total value, together with max of function
//P integer table id
//P long pointer to accumulation location array
//P pointer to buffer of fields

void totalflds(INT s,LONG *list,UCHAR *buf)
{
    INT len,f;
    UCHAR *b,a[LENOFDOUBLEFLOAT];
    CHAR var[LENOFTEMPFIELD];
    short i;
    double d;
    LONG l;
    for (f=0;f<G_store[s].numitem;f++)
        {
        b=(UCHAR *)buf+G_sstat[s].fofs[f];
        switch (G_lib[G_store[s].li[f]].type)
            
            {
            case 1 :
                i=(short)(*b^0x80);
                i<<=8;
                i|=*(b+1);
                l=(LONG)i;
                (*list)+=l;
                (*(list+32))=max((*(list+32)),l);
                break;
            case 2 :
                if ((*b&0x80)==0x80)
                    
                    {
                    for (i=7;i>=0;i--)
                        a[i]=*(b++);
                    a[7]&=0x7F;
                    }
                else
                    
                    {
                    for (i=7;i>=0;i--)
                        a[i]=*(b++)^0xFF;
                    }
                d=*((double *)(a));
                l=(LONG)d;
                (*list)+=l;
                (*(list+32))=max((*(list+32)),l);
                break;
            case 3 :
                var[0]=0;
                if (isdigit(*b)||(*b=='-'))
                    {
                    len=G_lib[G_store[s].li[f]].len;
                    strncpy(var,(CHAR *)b,len);
                    while (*b==32) b++;
                    if (!(*b))
                        {
                        var[0]=0;
                    } else
                        {
                        var[len]=0;
                    }
                }
                l=atol(var);
                (*list)+=l;
                (*(list+32))=max((*(list+32)),l);
                break;
        }
        list++;
    }
}

//************************************************************
//S returns TRUE if all fields in the range match tempstore
//P integer table id  - n.b. relies on G_numselflds being preset
//R TRUE matches in range, FALSE string match fails

INT selectrange(INT s)
{
    INT i;
    CHAR tmp[LENOFTEMPFIELD];
    if (!G_numselflds)
        return(1);

    for (i=0;i<G_numselflds;i++)
        {
        stquickget(s,G_selflds[i],tmp);
        if (strcmp(G_tmpst[i],tmp))
            return(0);
        }
    return(1);
}

//************************************************************
//S generate record number list either for all recs or for matching recs
//P char string table name
//P char string field name
//P long integer array address for reply
//P address of long int array for totals - or null if tots not req.
//R TRUE 

INT stbsslist(CHAR *name,CHAR *fname,LONG *list,LONG *totals)
{
    INT    nr=0,recnum=1,err=0;
    CHAR   buf[LENOFTEMPFIELD],curbuf[LENOFTEMPFIELD];
    INT    s,f;
    ENTRY(4410);

    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msbsslist(name,fname,list));
    if (!strcmp(fname,"ALL-RECS"))      // all recs mode
        {
        nr=(INT)stnumrec(name);         // get number of records in table
        for (recnum=0;recnum<nr;recnum++)
            {                           // set record numbers into list array
            list[recnum]=(LONG)recnum+1L;
            }
        return(nr);
        }
    if ((f=fnum(name,fname))<0)
        RETURNV(0);
    if (!stopen(name))
        RETURNV(0);
    if (!stquickget(s,f,curbuf))
        RETURNV(0);
    G_sstat[s].err=0;
    while (!err)
        {
        if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,recnum))==PXSUCCESS)
            {
            if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                
                {
                if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS)
                    
                    {
                    if ((stquickget(s,f,buf))&&(!strcmp(buf,curbuf)))
                        
                        {
                        if (selectrange(s))
                            
                            {
                            if (totals!=NULL)
                                totalflds(s,totals,(UCHAR *)G_sstat[s].buf);
                            list[nr++]=recnum;
                            }
                        }
                    recnum++;
                    }
                else
                    
                    {
                    err=1;
                    }
                }
            else
                
                {
                err=2;
                }
            }
        else
            
            {
            err=3;
            }
        }
    RETURNV(nr);
}

//************************************************************
//S a kind of search and list mission - not really sure :JG
//P char string table name
//P char string field name
//P address of long int array for list
//P integer number of records to seach
//R integer number of records listed

INT stssslist(CHAR *name,CHAR *fname,LONG *list,INT nrec)
{
    CHAR   curbuf[LENOFTEMPFIELD],buf[LENOFTEMPFIELD];
    INT    s,f,i,j;
    ENTRY(4410);

    if ((s=snum(name))<0)
        RETURNV(0);
    if ((f=fnum(name,fname))<0)
        RETURNV(0);
    if (!stopen(name))
        RETURNV(0);
    if (!stquickget(s,f,curbuf))
        RETURNV(0);
    G_sstat[s].err=0;
    for (i=0;i<nrec;i++)
        
        {
        if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,list[i]))==PXSUCCESS)
            
            {
            if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                
                {
                if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS)
                    
                    {
                    if ((stquickget(s,f,buf))&&(!strcmp(buf,curbuf)))
                        
                        {
                        if (selectrange(s))
                            
                            {
                            for (j=i+1;j<nrec;j++)
                                list[j-1]=list[j];
                            nrec--;
                            i--;
                        }
                    }
                }
            }
        }
    }
    RETURNV(nrec);
}

//************************************************************
//S search table (secondary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
//D detail
//P parameter
//R TRUE 

INT stsrch(CHAR *name,CHAR *fname,INT mode)
{
    INT i;
    static INT recnum=1,s=(-1),f=(-1);
    CHAR   buf[LENOFTEMPFIELD],curbuf[LENOFTEMPFIELD];
    LONG   nr=0L;
    INT    smode;

    ENTRY(4400);
    if (fname!=NULL)
        {
        if ((s==snum(name))&&(f==fnum(name,fname))&&(mode==NEXT))
            {
            recnum++;
            if (!stquickget(s,f,curbuf))
                RETURNV(0);
            G_sstat[s].err=0;
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,recnum))==PXSUCCESS)
                {
                if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                    {
                    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS)
                        {
                        if ((stquickget(s,f,buf))&&(!strcmp(buf,curbuf)))
                            {
                            RETURNV((INT)recnum);
                            }
                        }
                    recnum++;
                    }
                }
            RETURNV(0);
            }
        else
            {
            if (mode==NEXT)
                RETURNV(0);
            if ((s=snum(name))<0)
                RETURNV(0);
            if ((f=fnum(name,fname))<0)
                RETURNV(0);
            if (!stquickget(s,f,curbuf))
                RETURNV(0);
            recnum=1;
            G_sstat[s].err=0;
            while (!G_sstat[s].err)
                {
                if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,recnum))==PXSUCCESS)
                    {
                    if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                        {
                        if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS)
                            {
                            if ((stquickget(s,f,buf))&&(!strcmp(buf,curbuf)))
                                {
                                RETURNV((INT)recnum);
                                }
                            }
                        recnum++;
                        }
                    }
                }
            RETURNV(0);
            }
        }
    else
        {
        if ((s=snum(name))<0)
            RETURNV(0);
        if (G_msmap[s])
            RETURNV((INT)mssrch(name,fname,mode));
        G_sstat[s].err=0;
        if (!stopen(name))
            RETURNV(0);
        switch (mode)
            {
            case FRST :
                smode=SEARCHFIRST;
                break;
            case NEXT :
                smode=SEARCHNEXT;
                break;
            default :
                smode=CLOSESTRECORD;
        }
        if (mode==0)
            {
            for (i=0;i<G_store[s].numitem;i++)
                {
                if (!(G_store[s].key&(0x80000000L>>i)))
                    break;
                }
            if (i<1)
                RETURNV(0);
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,i,smode))!=PXSUCCESS)
                {
                prerror(s,1);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
        }
        else
            {
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,mode,smode))!=PXSUCCESS)
                {
                prerror(s,2);
                RETURNV(0);
            }
            if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&nr))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    RETURNV((INT)nr);
}

//************************************************************
//S search table on a primary key and build a list
//P char string table name
//P integer field to work with, or primary key
//P address of long int array for resultant record no. list
//P address of long int array for totals - or null if tots not req.
//R 0 for failed, otherwise number of records in set

INT stbsplist(CHAR *name,INT nflds,LONG *list,LONG *totals)
{
    INT i;
    INT nr=0,len;
    LONG rn,cr=0;
    INT s,err;
    UCHAR *rbuf;
    ENTRY(4410);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msbsplist(name,nflds,list));
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0);
    if (nflds==0)
        {
        for (i=0;i<G_store[s].numitem;i++) 
            if (!(G_store[s].key&(0x80000000L>>i)))
                break;
        if (i<1)
            RETURNV(0);
        nflds=i;
        }
    if (nflds==G_store[s].numitem)
        len=G_sstat[s].len;
    else
        len=G_sstat[s].fofs[nflds];
    err=0;
    nr=0;
    rbuf=MALLOC(len+1);
    if (!rbuf)
        RETURNV(0);
    memcpy(rbuf,G_sstat[s].buf,len);
    while (!err)
        {
        if (!cr)
            {
            if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,SEARCHFIRST))==PXSUCCESS)
                {
                if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&(cr)))==PXSUCCESS)
                    {
                    PXRecGet(G_sstat[s].handle,G_sstat[s].rec);
                    PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                    if (selectrange(s))
                        {
                        if (totals!=NULL)
							totalflds(s,totals,(UCHAR *)G_sstat[s].buf);
                        list[nr++]=cr;
                    }
                    rn=cr;
                } else
                    {
                    err=1;
                }
            } else
                {
                err=1;
            }
        } else
            {
            rn++;
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,rn))==PXSUCCESS)
                {
                if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                    {
                    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))==PXSUCCESS)
                        {
                        if (!memcmp(rbuf,G_sstat[s].buf,len))
                            {
                            if (selectrange(s))
                                {
                                if (totals!=NULL)
									totalflds(s,totals,(UCHAR *)G_sstat[s].buf);
                                list[nr++]=rn;
                            }
                        } else
                            {
                            err=1;
                        }
                    } else
                        {
                        err=1;
                    }
                } else
                    {
                    err=1;
                }
            } else
                {
                err=1;
            }
        }
    }
    FREE(rbuf);
    RETURNV(nr);
}

//************************************************************
//S search table (primarary) 'name'  using field nflds where 'mode' is FRST,NEXT,CLOSEST
//P char string table name
//P integer field number - if zero use primary key
//P integer mode for search
//R BOOL TRUE - Ok, FALSE - failed 

INT stsrchp(CHAR *name,INT nflds,INT mode)
{
    INT smode;
    static INT lnf;
    static INT s;
    static CHAR lname[LENOFTABLENAME];
    ENTRY(4410);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)mssrchp(name,nflds,mode));
    if (strcmp(name,lname))
        {
        strcpy(lname,name);
        }
    else
        {
        if ((lnf==nflds)&&(mode==NEXT)&&(!memcmp(G_lastsbuf,G_sstat[s].buf,G_lastslen)))
            {
            if ((G_sstat[s].err=PXRecGoto(G_sstat[s].handle,G_lastsrec+1))==PXSUCCESS)
                {
                if ((G_sstat[s].err=PXRecGet(G_sstat[s].handle,G_sstat[s].rec))==PXSUCCESS)
                    {
                    if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_tempsbuf,G_sstat[s].len))==PXSUCCESS)
                        {
                        if (!memcmp(G_lastsbuf,G_tempsbuf,G_lastslen))
                            {
                            G_lastsrec++;
                            RETURNV(1);
                            }
                        else
                            {
                            PXRecGoto(G_sstat[s].handle,G_lastsrec);
                            PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                            RETURNV(0);
                            }
                        }
                    else
                        {
                        PXRecGoto(G_sstat[s].handle,G_lastsrec);
                        PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                        RETURNV(0);
                        }
                    }
                else
                    {
                    PXRecGoto(G_sstat[s].handle,G_lastsrec);
                    PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                    RETURNV(0);
                    }
                }
            else
                {
                PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len);
                RETURNV(0);
                }
            }
//      if ((lnf==nflds)&&(mode==NEXT)) 
//          {
//          if (G_sstat[s].modified) 
//              {
//              if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS) 
//                  {
//                  prerror(s,14);
//                  RETURNV(0);
//                  }
//              }
//          if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,SEARCHNEXT))!=PXSUCCESS) 
//              {
//              prerror(s,4);
//              RETURNV(0);
//              } 
//          else 
//              {
//              RETURNV(1);
//              }
//          }
        }
    G_sstat[s].err=0;
    if (!stopen(name))
        RETURNV(0);
    switch (mode)
        {
        case FRST :
            smode=SEARCHFIRST;
            break;
        case NEXT :
            smode=SEARCHNEXT;
            break;
        default :
            smode=CLOSESTRECORD;
        }
    if (nflds==0)
        {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds)))
                break;
        if (nflds<1)
            RETURNV(0);
        }
    if ((G_sstat[s].err=PXSrchKey(G_sstat[s].handle,G_sstat[s].rec,nflds,smode))!=PXSUCCESS)
        {
        prerror(s,5);
        RETURNV(0);
        }
    if ((G_sstat[s].err=PXRecNum(G_sstat[s].handle,&G_lastsrec))!=PXSUCCESS)
        {
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

//************************************************************
//S get field f from table s and place it in variable 'var'
//P integer table id - should be INT not UCHAR
//P integer field id - should be INT not UCHAR :JG
//P address to place reply
//R TRUE Ok, FALSE failed

INT stquickget(UCHAR s,UCHAR f,CHAR *var)
{
    INT len;
    UCHAR *b,a[LENOFDOUBLEFLOAT];
    short i;
    double d;
    ENTRY(4419);
    if (G_msmap[s])
        RETURNV((INT)msquickget(s,f,var));
    G_sstat[s].err=0;
    len=G_lib[G_store[s].li[f]].len;
    if (!G_sstat[s].open)
        if (!stopen(G_sstat[s].name))
            RETURNV(0);
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    switch (G_lib[G_store[s].li[f]].type)
        {
        case 1 :
            i=(short)(*b^0x80);
            i<<=8;
            i|=*(b+1);
            itoa(i,var,10);
            break;
        case 2 :
            if ((*b&0x80)==0x80)
                {
                for (i=7;i>=0;i--)
                    a[i]=*(b++);
                a[7]&=0x7F;
            } else
                {
                for (i=7;i>=0;i--)
                    a[i]=*(b++)^0xFF;
            }
            d=*((double *)(a));
            sprintf(var,"%lf",d);
            dottrunc(var);
            break;
        case 3 :
            strncpy(var,(CHAR *)b,len);
            while (*b==32) b++;
            if (!(*b))
                {
                var[0]=0;
            } else
                {
                var[len]=0;
            }
            break;
    }
    RETURNV(1);
}


//************************************************************
//S get field using names not numbers
//D converts names to store numbers and field numbers then
//D calls stquickget.
//P char string table name
//P char string field name
//P pointer to location for variable
//R TRUE OK, FALSE failed

INT stget(CHAR *name,CHAR *fname,CHAR *var)
{
    INT s,f;
    ENTRY(4420);
    if ((s=snum(name))<0)
        RETURNV(0);
    if ((f=fnum(name,fname))<0)
        RETURNV(0);
    RETURNV(stquickget(s,f,var));
}

//************************************************************
//S blank the record buffer in table 'name'
//P char string table name
//R TRUE OK, FALSE - failed

INT stblank(CHAR *name)
{
    INT s,i;
    ENTRY(4430);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msblank(name));
    if (!stopen(name))
        RETURNV(0);
    for (i=1;i<=G_store[s].numitem;i++)
        {
        if ((G_sstat[s].err=PXPutBlank(G_sstat[s].rec,i))!=PXSUCCESS)
            {
        prerror(s,0);
        RETURNV(0);
    }
    }
    RETURNV(1);
}

//************************************************************
//S empty the table 'name'
//P char string table name
//R TRUE Ok, FALSE - failed

INT stempty(CHAR *name)
{
    INT s,wo;
    ENTRY(4440);

    if ((s=snum(name))<0)
        RETURNV(0);
    if (G_msmap[s])
        RETURNV((INT)msempty(name));
    if (G_sstat[s].open)
        {
        wo=1;
        G_sstat[s].err=0;
        if ((G_sstat[s].err=PXRecBufClose(G_sstat[s].rec))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        if ((G_sstat[s].err=PXTblClose(G_sstat[s].handle))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        }
    else
        {
        wo=0;
        }
    if ((G_sstat[s].err=PXTblEmpty(tabname(name)))!=PXSUCCESS)
        {
        G_sstat[s].open=0;
        prerror(s,0);
        RETURNV(0);
        }
    if (wo)
        {
        if ((G_sstat[s].err=PXTblOpen(tabname(name),&G_sstat[s].handle,0,G_nocache))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        if ((G_sstat[s].err=PXRecBufOpen(G_sstat[s].handle,&G_sstat[s].rec))!=PXSUCCESS)
            {
            prerror(s,0);
            RETURNV(0);
            }
        if ((G_sstat[s].err=PXRawGet(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS)
            {
            prerror(s,13);
            RETURNV(0);
            }
        }
    RETURNV(1);
}

//************************************************************
//S preserve value as field
//P integer table id - should be INT not UCHAR
//P integer field id - should be INT not UCHAR
//P address of variable to put as field
//R TRUE Ok, FALSE - failed

INT stquickput(UCHAR s,UCHAR f,CHAR *var)
{
    INT len;
    short i;
    UCHAR *b,a[LENOFDOUBLEFLOAT];
    CHAR c[1];
    double d;
    ENTRY(4449);
    if (G_msmap[s])
        RETURNV((INT)msquickput(s,f,var));
    G_sstat[s].err=0;
    if (!G_sstat[s].open) if (!stopen(G_sstat[s].name))
        RETURNV(0);
    if (var==NULL)
        {
        c[0]=0;
        var=c;
        }
    len=G_lib[G_store[s].li[f]].len;
    switch (G_lib[G_store[s].li[f]].type)
        {
        case 1 :
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
            i=(short)atoi(var);
            *(b++)=(UCHAR)((i>>8)^0x80);
            *(b++)=(UCHAR)(i&0xFF);
            break;
        case 2 :
            d=strtod(var,NULL);
            b=(UCHAR *)(&d);
            if ((*(b+7)&0x80)!=0)
                {
                for (i=7;i>=0;i--)
                    a[i]=*(b++)^0xFF;
                }
            else
                {
                for (i=7;i>=0;i--)
                    a[i]=*(b++);
                a[0]^=0x80;
            }
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
            memcpy(b,a,8);
            break;
        case 3 :
            b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
            memset((CHAR *)b,0,len);
            strncpy((CHAR *)b,var,len);
            if ((G_runningdummy)&&(len==1))
                {
               if (!(*b)) *b=32;           // pad empty space
            } 
            break;
    }
    if ((G_sstat[s].err=PXRawPut(G_sstat[s].handle,G_sstat[s].buf,G_sstat[s].len))!=PXSUCCESS)
        {
        prerror(s,14);
        RETURNV(0);
    }
    G_sstat[s].modified=1;
    RETURNV(1);
}

//************************************************************
//S move a field from one table/field to another
//P integer destination field number
//P integer destination file id
//P integer source field number
//P integer source file id
//R TRUE Ok, FALSE failed.

INT stmovedata(UCHAR df,UCHAR ds,UCHAR sf,UCHAR ss)
{
    INT ret=0;
    CHAR buf[LENOFTEMPFIELD+1];
    if (stquickget(ss,sf,buf))
        {
        if (stquickput(ds,df,buf))
            ret=1;
    }
    RETURNV(ret);
}

//************************************************************
//S put variable 'var' it in field 'fname' from table 'name'
//D Converts names to store and field numbers, then calls stquickput.
//P char string table name to place into
//P char string field name to update
//P address of source string to place in specified field
//R TRUE Ok, FALSE failed

INT stput(CHAR *name,CHAR *fname,CHAR *var)
{
    INT s,f;
    ENTRY(4450);
    if ((s=snum(name))<0)
        RETURNV(0);
    if ((f=fnum(name,fname))<0)
        RETURNV(0);
    RETURNV(stquickput(s,f,var));
}

//************************************************************
//S duplicate a table to a temp table using ~ame for name and sec search parameters
//D a sort of fork function - with full inheritance of attributes and none of the mess
//P char string file name 
//P char string field name
//P integer - labelled as mode but I believe this means field id - see stsrchp() :JG
//R TRUE Ok, FALSE failed

INT stdup(CHAR *name,CHAR *fname,INT mode)
{
    INT s;
    INT smode;
    CHAR newname[LENOFTABLENAME-1]; // SO why the -1? :JG
    ENTRY(4460);

    if ((s=snum(name))<0)
        RETURNV(0);

    strcpy(newname,name);
    newname[0]='~';
    strcpy(G_store[G_nums].name,newname);
    G_store[G_nums].key    =G_store[s].key;
    G_store[G_nums].skey   =G_store[s].skey;
    G_store[G_nums].numitem=G_store[s].numitem;
    memcpy(G_store[G_nums].li,G_store[s].li,32*sizeof(INT));
    G_nums++;

    stempty(newname);
    if (!stopen(newname))
        RETURNV(0);
    if (!stopen(name))
        RETURNV(0);
    if (fname!=NULL)
        {
        smode=FRST;
        while (stsrch(name,fname,smode))
            {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
            stwrite(newname);
            smode=NEXT;
        }
    }
    else
        {
        smode=FRST;
        while (stsrchp(name,mode,smode))
            {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecBufCopy(G_sstat[s].rec,G_sstat[G_nums-1].rec))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
            stwrite(newname);
            smode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    RETURNV(1);
}

//************************************************************
//S remove a duplicated table and copy contents back to original if 'copyback'
//P char string table name
//P BOOL decision on whether to copy temp back into main
//R TRUE Ok, FALSE failed

INT stremdup(CHAR *name,INT copyback)
{
    CHAR newname[LENOFTABLENAME-1];       // again - why the -1 :JG
    INT s;
    INT t;
    INT mode=FRST;
    ENTRY(4470);

    strcpy(newname,name);
    newname[0]='~';
    if (copyback)
        {
        stopen(name);
        stopen(newname);
        t=snum(newname);
        s=snum(name);
        while (stread(newname,(LONG)mode))
            {
            if ((G_sstat[t].err=PXRecBufCopy(G_sstat[t].rec,G_sstat[s].rec))!=PXSUCCESS)
                {
                prerror(t,0);
                RETURNV(0);
            }
            stwrite(name);
            mode=NEXT;
        }
    }
    stclose(name);
    stclose(newname);
    G_nums--;
    RETURNV(1);
}

//************************************************************
//S delete all records matched by search parameters
//P char string table name
//P char string field name
//P integer mode as above this is more like an index clue flag - 0 use primary key
//R TRUE Ok, FALSE failed

INT stdelgrp(CHAR *name,CHAR *fname,INT mode)
{
    INT s;
    ENTRY(4480);
    if ((s=snum(name))<0)
        RETURNV(0);
    if (!stopen(name))
        RETURNV(0);
    if (fname!=NULL)
        {
        while (stsrch(name,fname,FRST))
            {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    else
        {
        while (stsrchp(name,mode,FRST))
            {
            stread(name,(LONG)CURR);
            if ((G_sstat[s].err=PXRecDelete(G_sstat[s].handle))!=PXSUCCESS)
                {
                prerror(s,0);
                RETURNV(0);
            }
        }
    }
    stclose(name);
    RETURNV(1);
}

//************************************************************
//S flush all modified buffers
//D Currently doesn't use stwrite :JG
//R TRUE Ok FALSE=failed

INT stflush(void)
{
//    INT i;
    ENTRY(4490);
//  for (i=0;i<G_nums;i++) 
//      {
//      if (G_sstat[s].modified) 
//          stwrite(G_sstat[s].name);
//      }
    if (PXSave()!=PXSUCCESS)
        RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get a record into r and set 'flen' to the length of the buffer

/* commented out next 4 functions - each one individually for flexibility

INT stgetrec(CHAR *name,CHAR *r,INT *flen)
{
    INT i,s,len;
    short j;
    double d;
    CHAR tmp[LENOFTEMPFIELD];
    INT olen=9;
    ENTRY(4500);

    if ((s=snum(name))<0)
        RETURNV(0);
    if (!stopen(name,0))
        RETURNV(0);
    G_sstat[s].err=0;
    strcpy(r,name);
    for (i=0;i<G_store[s].numitem;i++)
        {
        switch(G_lib[G_store[s].li[i]].type)
            {
            case 1 :
                if ((G_sstat[s].err=PXGetShort(G_sstat[s].rec,i+1,&j))!=PXSUCCESS)
                    {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=sizeof(INT);
                if ((olen+len)>=*flen)
                    RETURNV(0);
                *((INT *)&(r[olen]))=j;
                break;
            case 2 :
                if ((G_sstat[s].err=PXGetDoub(G_sstat[s].rec,i+1,&d))!=PXSUCCESS)
                    {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=sizeof(double);
                if ((olen+len)>=*flen)
                    RETURNV(0);
                *((double *)&(r[olen]))=d;
                break;
            case 3 :
                if ((G_sstat[s].err=PXGetAlpha(G_sstat[s].rec,i+1,G_lib[G_store[s].li[i]].len+1,tmp))!=PXSUCCESS)
                    {
                    prerror(s,0);
                    RETURNV(0);
                }
                len=G_lib[G_store[s].li[i]].len+1;
                if ((olen+len)>=*flen)
                    RETURNV(0);
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
*/

//************************************************************
//S put a record from r

/*
INT stputrec(CHAR *r)
{
    CHAR name[LENOFTABLENAME];
    INT i,s,len;
    INT olen=9;
    ENTRY(4510);

    strncpy(name,r,9);      // not sure why this copy but no delimiter ? :JG
    if ((s=snum(name))<0)
        RETURNV(0);
    if (!stopen(name,0))
        RETURNV(0);
    G_sstat[s].err=0;
    for (i=0;i<G_store[s].numitem;i++)
        {
        switch(G_lib[G_store[s].li[i]].type)
            {
            case 1 :
                len=sizeof(INT);
                if ((G_sstat[s].err=PXPutShort(G_sstat[s].rec,i+1,*((short *)&(r[olen]))))!=PXSUCCESS)
                    {
                    prerror(s,0);
                    RETURNV(0);
                }
                break;
            case 2 :
                len=sizeof(double);
                if ((G_sstat[s].err=PXPutDoub(G_sstat[s].rec,i+1,*((double *)&(r[olen]))))!=PXSUCCESS)
                    {
                    prerror(s,0);
                    RETURNV(0);
                }
                break;
            case 3 :
                len=G_lib[G_store[s].li[i]].len+1;
                if ((G_sstat[s].err=PXPutAlpha(G_sstat[s].rec,i+1,&r[olen]))!=PXSUCCESS)
                    {
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
    G_modified|=1L<<s;
    RETURNV(1);
}
*/

//************************************************************
//S send a record to BOS if in the RUPDATE list from config

/*
INT sendrec(CHAR *name,INT type)
{
    CHAR r[MAXDGSIZE];
    INT len=MAXDGSIZE;
    ENTRY(4520);

    if (G_netok&&((G_frupd[snum(name)]&1)==1))
        {
        if (!stgetrec(name,r,&len))
            RETURNV(0);
        if ((sendmsg("LAN",MESSAGE_S,G_toname,1,len,r,type))==(-1))
            RETURNV(0);
    }

    RETURNV(1);
}
*/

//************************************************************
//S receive a record and update local database

/*
INT receiverec(void)
{
    CHAR r[MAXDGSIZE];
    INT len=MAXDGSIZE;
    INT type,pos,uid;
    CHAR file[33],n[20];    // These local vars not used :JG
    CHAR *t;
    ENTRY(4530);

    type=(INT)sendmsg("LAN",MESSAGE_R,&len,r);
    switch (type)
        {
        case USERLOGON      :
            t=r+2;
            *(t++)=0;
            while ((*t)&&(!isdigit(*t))) t++;
            if (*t)
                {
                if (!stput(USER_S,USID,r))
                    RETURNV(0);
                if (stsrch(USER_S,NULL,1))
                    {
                    stread(USER_S,(LONG)CURR);
                    stput(USER_S,POSN,t);
                    stwrite(USER_S);
                    G_finredraw=0;
                }
            }
            break;
        case USERLOGOFF      :
            t=r+3;
            *t=0;
            if (!stput(USER_S,USID,r))
                RETURNV(0);
            if (stsrch(USER_S,NULL,1))
                {
                stread(USER_S,(LONG)CURR);
                stput(USER_S,POSN,"0");
                stwrite(USER_S);
                G_finredraw=0;
            }
            break;
        case RECUPDATE :
            if (stputrec(r))
                {
                stwritelocal(r);
                G_finredraw=0;
            }
            break;
        case RECDELETE :
            if (stputrec(r))
                {
                if (stsrchp(r,0,FRST))
                    {
                    if (stread(r,(LONG)CURR))
                        {
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
}
*/

//************************************************************
//S copy record
//P char str source table
//P char str destination table 
//R TRUE Ok, FALSE failed

INT stcopyrec(CHAR *s,CHAR *d)
{
    INT f1,f2,i,j,l1,l2;
    CHAR tmp[LENOFTEMPFIELD];
//    INT len;
    INT16 *a,*b;
    ENTRY(4540);
    if ((f1=snum(s))<0)
        RETURNV(0);
    if ((f2=snum(d))<0)
        RETURNV(0);
    if (!stopen(s))
        RETURNV(0);
    if (!stopen(d))
        RETURNV(0);
    if (G_sstat[f2].buf==NULL)
        RETURNV(0);
    if (G_sstat[f1].buf==NULL)
        RETURNV(0);
    if ((G_store[f1].numitem==G_store[f2].numitem)
    &&  (!memcmp(G_store[f1].li,G_store[f2].li,G_store[f2].numitem*sizeof(INT16))))
        {
        memcpy(G_sstat[f2].buf,G_sstat[f1].buf,G_sstat[f1].len);
        if (!stwrite(d))
            RETURNV(0);
        }
    else
        {
        a=G_store[f1].li;
        l1=G_store[f1].numitem;
        l2=G_store[f2].numitem;
        for (i=0;i<l1;i++)
            {
            b=G_store[f2].li;
            for (j=0;j<l2;j++)
                {
                if (*a==*b)
                    {
                    stquickget(f1,i,tmp);
                    stquickput(f2,j,tmp);
//                  if (i==l1-1) 
//                      {
//                      len=G_sstat[f1].len-G_sstat[f1].fofs[i];
//                      } 
//                  else 
//                      {
//                      len=G_sstat[f1].fofs[i+1]-G_sstat[f1].fofs[i];
//                      }
//                  memcpy(G_sstat[f2].buf+G_sstat[f2].fofs[j],G_sstat[f1].buf+G_sstat[f1].fofs[i],len);
                    break;
                }
                b++;
            }
            a++;
        }
    }
    RETURNV(1);
}

//************************************************************
//S generate a selection
//P char str table name
//P char string token list

void setupsel(CHAR *name,CHAR *var)
{
    INT i,s;
    G_numselflds=0;
    if (var==NULL)
        return;
    if ((s=snum(name))<0)
        return;
    strcpy(G_sellist,var);  // currently max is 80 bytes incl delim :JG
    var=strtok(G_sellist," ,\t\n");
    while (var!=NULL)       // work through list of tokens
        {
        G_selflds[G_numselflds]=atoi(var)-1; // token assumed to be numbers
        G_numselflds++;
        var=strtok(NULL," ,\t\n");
        }
    if ((G_numselflds==1)&&(G_selflds[0]<0))    // check we didn't have a bum steer
        {
        G_numselflds=0;
        }
    for (i=0;i<G_numselflds;i++)
        {
        stquickget(s,G_selflds[i],G_tmpst[i]); // get field selfield from table s and place it in variable tmpst
        }
}

//************************************************************
//S pdxdev (paradox device) control routine
//P integer message type
//P variable parameter list according to requirements
//R long reply according to type

LONG pdx_control(INT type,va_list ap)
{
    CHAR *name,*var,*fname;
    LONG *ll,*tl;
    UCHAR a,b,c,d;
    INT mode,recnum;
    LONG retval=0L;
    ENTRY(4550);
    switch(type)
        {
        case MESSAGE_I  : // initialise the database system and memory stores
            retval=(LONG)stinit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode])
                break;
            if (mode<32) msinit();
            break;
        case MESSAGE_E  : // shutdown the database system
            retval=(LONG)stexit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode])
                break;
            if (mode<32) msexit();
            break;
        case MESSAGE_RI :   // reinitialise the database system
            retval=(LONG)streinit();
            for (mode=0;mode<32;mode++) if (G_msmap[mode])
                break;
            if (mode<32) msreinit();
            break;
        case MESSAGE_x  : // check if table exists
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                if (((mode=snum(name))>(-1))&&G_msmap[mode])
                    {
                    retval=msexist(name);
                    }
                else
                    {
                    retval=(LONG)stexist(name);
                    }
                }
            break;
        case MESSAGE_C  :   // create table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stcreate(name);
                }
            break;
        case MESSAGE_D  : // delete table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stdelete(name);
            }
            break;
        case MESSAGE_O  :   // open table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stopen(name);
                }
            break;
        case MESSAGE_c  :   // close table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stclose(name);
            }
            break;
        case MESSAGE_ca :   // close all open tables
            retval=(LONG)stcloseall();
            break;
        case MESSAGE_nr :   // RETURN the number of records in table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=stnumrec(name);
                }
            break;
        case MESSAGE_rn :   // RETURN the current record number in table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=strecnum(name);
            }
            break;
        case MESSAGE_r  :   // goto record and read it from table 'name' where rtype is FRST,LAST,CURR,NEXT,PREV.
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=va_arg(ap,LONG);
                retval=(LONG)stread(name,retval);
            }
            break;
        case MESSAGE_w  :   // write/update record in table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stwrite(name);
                }
            break;
        case MESSAGE_dr :   // delete record in table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=va_arg(ap,LONG);
                retval=(LONG)stdelrec(name,retval);
                }
            break;
        case MESSAGE_sl  : // gets field contents into array  given a list of field numbers
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                var=va_arg(ap,CHAR *);
                setupsel(name,var);
                retval=1L;
                }
            break;
        case MESSAGE_s  :   // search table (secondary) 'name'  using field 'fname' where 'mode' is FRST,NEXT,CLOSEST
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
                retval=(LONG)stsrch(name,fname,mode);
            }
            break;
        case MESSAGE_sp :   // search table (primarary) 'name'  using key field n where 'mode' is FRST,NEXT,CLOSEST(= anything else)
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                recnum=va_arg(ap,INT);
                mode=va_arg(ap,INT);
                retval=(LONG)stsrchp(name,recnum,mode);
                }
            break;
        case MESSAGE_bs  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                ll=va_arg(ap,LONG *);
                retval=(LONG)stbsslist(name,fname,ll,NULL);
                }
            break;
        case MESSAGE_bp :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                recnum=va_arg(ap,INT);
                ll=va_arg(ap,LONG *);
                retval=(LONG)stbsplist(name,recnum,ll,NULL);
            }
            break;
        case MESSAGE_as  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                ll=va_arg(ap,LONG *);
                mode=va_arg(ap,INT);
                if (mode<0)
                    retval=(LONG)stbsslist(name,fname,ll,NULL);
                else
                    retval=(LONG)stssslist(name,fname,ll,mode);
            }
            break;
        case MESSAGE_ts  :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                tl=va_arg(ap,LONG *);
                ll=va_arg(ap,LONG *);
                retval=(LONG)stbsslist(name,fname,ll,tl);
            }
            break;
        case MESSAGE_tp :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                recnum=va_arg(ap,INT);
                tl=va_arg(ap,LONG *);
                ll=va_arg(ap,LONG *);
                retval=(LONG)stbsplist(name,recnum,ll,tl);
            }
            break;
        case MESSAGE_g  :	// get field using store and field names
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
                retval=(LONG)stget(name,fname,var);
            }
            break;
        case MESSAGE_qg  :	// get field using store and field numbers
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            var=va_arg(ap,CHAR *);
            retval=(LONG)stquickget(a,b,var);
            break;
        case MESSAGE_qp  :	// set field using store and field numbers
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            var=va_arg(ap,CHAR *);
            retval=(LONG)stquickput(a,b,var);
            break;
        case MESSAGE_b  :	// blank the record buffer in table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stblank(name);
            }
            break;
        case MESSAGE_e  :	// empty the table 'name'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                retval=(LONG)stempty(name);
            }
            break;
        case MESSAGE_p  :	// put variable into store and field identified by name
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                var=va_arg(ap,CHAR *);
                retval=(LONG)stput(name,fname,var);
            }
            break;
        case MESSAGE_d  :	// duplicate a table to a temp table
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
                retval=(LONG)stdup(name,fname,mode);
            }
            break;
        case MESSAGE_rd :	// remove a duplicated table and copy contents back to original if 'copyback'
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                mode=va_arg(ap,INT);
                retval=(LONG)stremdup(name,mode);
            }
            break;
        case MESSAGE_RP : // Relative position +/-
            // if fail return to original record an set retval to 0
            retval=0L;
            break;
        case MESSAGE_PR : // prepare for read of n recs
            retval=0L;
            break;
        case MESSAGE_dg :	// delete all records matched by search parameters
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                mode=va_arg(ap,INT);
                retval=(LONG)stdelgrp(name,fname,mode);
            }
            break;
        case MESSAGE_f  :	// flush buffers to disk
            retval=(LONG)stflush();
            break;
							// commented out actions
/*        case MESSAGE_gr :
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
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
            if (strcmp(name,"NONE"))
                {
                mode=va_arg(ap,INT);
                retval=(LONG)sendrec(name,mode);
            }
            break;
        case MESSAGE_rr :
            retval=(LONG)receiverec();
            break; 									*/
							// end of commented out actions

        case MESSAGE_cr :	// copy record
            name=va_arg(ap,CHAR *);
            if (strcmp(name,"NONE"))
                {
                fname=va_arg(ap,CHAR *);
                retval=(LONG)stcopyrec(name,fname);
            }
            break;
        case MESSAGE_md :	// move a field from one table/field to another
            a=va_arg(ap,UCHAR);
            b=va_arg(ap,UCHAR);
            c=va_arg(ap,UCHAR);
            d=va_arg(ap,UCHAR);
            retval=(LONG)stmovedata(a,b,c,d);
            break;
    }
    RETURNV(retval);
}
#pragma option -p.

//*************************************************************
//	MEMORY STORE routines

//************************************************************
//S compare two buffers for matching fields looking at the same offaset and lengths
//P pointer to buffer 1 address
//P pointer to buffer 2 address
//R memcmp integer reply

INT mscmp(UCHAR **a,UCHAR **b)
{
    return(memcmp((*a)+G_msbufofs,(*b)+G_msbufofs,G_msbuflen));
}


//************************************************************
//S scan through remaining memstored records from current one looking for a match
//D I find the final arithmetic a bit dubious but it's probably right. :JG
//P integer "table" number - store number really
//P integer mode - NEXT or FRST only - anything else treated as FIRST
//P integer offset in record to start comparison
//P integer no. of bytes to compare
//R record number or 0 if failed

INT mssrchbuf(INT s,INT mode,INT ofs,INT len)
{
    INT rn=0;
    size_t ne;              // This is an abuse of the typedef size_t. & probably wrong. :JG
    UCHAR **b;
    G_msbufofs=ofs;
    G_msbuflen=len;
    switch (mode)
        {
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
    if (b==NULL)
        {
        rn=0;    
        }
    else
        {
        rn=(INT)(b-G_memstores[s].recs)+1;  // believe it or not this actually sets the rn - remarkable.
        }
    return(rn);
}

//************************************************************
//S mem store lose record store and move down any above it
//D Please note: does not recover space of record buffer pointer, only
//D the space of the record buffer itself. :JG
//P integer mem store id
//R TRUE 

LONG msdeleterec(INT s)
{
    if (G_memstores[s].recs[G_memstores[s].crec-1]!=NULL)
        {
        FREE(G_memstores[s].recs[G_memstores[s].crec-1]);
        }
    if (G_memstores[s].crec<G_memstores[s].nrec) 
        memcpy(&G_memstores[s].recs[G_memstores[s].crec-1],
               &G_memstores[s].recs[G_memstores[s].crec],
               (G_memstores[s].nrec-G_memstores[s].nrec)*sizeof(UCHAR *));
    G_memstores[s].nrec--;
    return(1L);
}

//************************************************************
//S insert a buffer into a memstore
//D reallocates entire pointer block, adds record to end and sorts the result
//P integer mem store id
//R TRUE = Ok, FALSE = failed

LONG msinsertrec(INT s)
{
    G_memstores[s].recs=REALLOC(G_memstores[s].recs,(G_memstores[s].nrec+1)*sizeof(UCHAR *));
    if (G_memstores[s].recs==NULL)
        {
        G_msmap[s]=0;
        return(0L);
    }
    G_memstores[s].recs[G_memstores[s].nrec]=MALLOC((G_sstat[s].len+1)*sizeof(UCHAR));
    if (G_memstores[s].recs[G_memstores[s].nrec]==NULL)
        {
        return(0L);
    }
    memcpy(G_memstores[s].recs[G_memstores[s].nrec],G_sstat[s].buf,G_sstat[s].len);
    G_memstores[s].nrec++;
    G_msbufofs=0;
    G_msbuflen=G_sstat[s].len;
    qsort(G_memstores[s].recs,G_memstores[s].nrec,sizeof(UCHAR *),(QSPTR)mscmp);
    return(1L);
}

//************************************************************
//S get memstore number
//D returns -1 if memstore not initialised
//D         -2 if specified name is not in store
//D         -3 if specified store is not initialised
//P char string name to get
//R negative - not set up, positive OK and number desired

INT getsnum(CHAR *name)
{
    INT s;
    if (G_memstores==NULL)
        return(-1);
    if ((s=snum(name))<0)
        return(-2);
    if (G_memstores[s].recs==NULL)
        return(-3);
    return(s);
}
//************************************************************
//S Initialise Globals G_memstores, G_nummens 
//D alocates detail
//P parameter
//R returns LONG 0 if unsuccessful, or the number of entries if ok 


//************************************************************
//S initialise memstore
//R TRUE OK, FALSE failed

LONG msinit(void)       // Doesn't need to be LONG :JG
{
   INT i,j,k;
   G_memstores=MALLOC(MEMSTOREQ*sizeof(MEMSTORE));
   if (G_memstores==NULL) 
        {
      G_nummems=0;
      return(0L);
       }
   for (i=0;i<MEMSTOREQ;i++) 
        {
      if (G_msmap[i]) 
            {
         k=0;
         for (j=0;j<G_store[i].numitem;j++) 
                {
            G_sstat[i].fofs[j]=k;
            k+=G_lib[G_store[i].li[j]].len;
            }
            G_sstat[i].len=k;
            if ((G_sstat[i].buf=REALLOC(G_sstat[i].buf,k+1))==NULL)
                G_sstat[i].len=0;
            else
                memset(G_sstat[i].buf,0,k+1);
        }
        G_memstores[i].recs=MALLOC(sizeof(UCHAR *));
        if (G_memstores[i].recs==NULL)  // This is only a partially good shutdown : JG
            {
            FREE(G_memstores);
            G_memstores=NULL;
            G_nummems=0;
            return(0L);
        }
        G_memstores[i].nrec=0;
        G_memstores[i].crec=0;
        G_memstores[i].recs[0]=NULL;
    }
    G_nummems=MEMSTOREQ;
    return(1L);
}

//************************************************************
//S clear down all memstores
//R TRUE Ok, FALSE failed (not setup anyway)

LONG msexit(void)   // This doesn't need to be other than INT :JG
{
    INT i,j;
    if (G_memstores==NULL)
        return(0L);
    for (i=0;i<G_nummems;i++)
        {
        if (G_memstores[i].recs!=NULL)
            {
            for (j=0;j<G_memstores[i].nrec;j++)
                {
                if (G_memstores[i].recs[j]!=NULL)
                    {
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

//************************************************************
//S mem store reinitialise
//R TRUE init OK, FALSE init failed

LONG msreinit(void) // There is no reason for this to return LONG :JG
{
    msexit();
    return(msinit());
}

//************************************************************
//S verify whether specified name is set up i.e. there is a memstore for it
//P char string store name
//R TRUE exists, FALSE doesn't exist

LONG msexist(CHAR *name)
{
    if (getsnum(name)<0)
        return(0L);
    return(1L);
}

//************************************************************
//S create mem store entry name - does nothing but mark the name
//P chat string store name
//R TRUE 

LONG mscreate(CHAR *name)
{
    name++;
    return(1L);
}

//************************************************************
//S memstore entry clear down
//P char string store name
//R TRUE Ok, FALSE Failed

LONG msdelete(CHAR *name)
{
    INT s,j;
    if ((s=getsnum(name))<0)
        return(0L);
    for (j=0;j<G_memstores[s].nrec;j++)
        {
        if (G_memstores[s].recs[j]!=NULL)
            {
            FREE(G_memstores[s].recs[j]);
        }
    }
    FREE(G_memstores[s].recs);
    G_memstores[s].nrec=0;
    G_memstores[s].crec=0;
    G_memstores[s].recs=MALLOC(sizeof(UCHAR *));    // Just a thought - shouldn't this then reset **recs to zero :JG
    return(1L);
}

//************************************************************
//S memstore open
//D Ok - so why does this function incrment the first byte of the name :JG
//P char string memstore name
//R TRUE 

LONG msopen(CHAR *name)
{
    name++;
    return(1L);
}

//************************************************************
//S close memstore
//D Ok.  So why does this function increment byte one of the name :JG
//P char string store name to close
//R TRUE 

LONG msclose(CHAR *name)
{
    name++;
    return(1L);
}

//************************************************************
//S memstore close all - does nothing
//R TRUE 

LONG mscloseall(void)
{
    return(1L);
}

//************************************************************
//S determine the number of records stored for a specific name
//P char string name
//R long number of records - zero if none or not set up.

LONG msnumrec(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0)
        return(0L);
    return((LONG)G_memstores[s].nrec);
}

//************************************************************
//S get memstore current record number ?
//P char string name
//R long memstore crec

LONG msrecnum(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0)
        return(0L);
    return((LONG)G_memstores[s].crec);
}

//************************************************************
//S memstore read - pulls into stat store from memstore specified record
//D type can be FRST LAST PREV NEXT CURR or recno
//P char string store name
//P long type - why is this LONG ? :JG
//R long BOOL TRUE=Ok, FALSE=direction not possible or store not init or no recs

LONG msread(CHAR *name,LONG rtype)
{
    INT s;
    if ((s=getsnum(name))<0)
        return(0L);
    if (G_memstores[s].nrec==0)
        return(0L);
    switch(rtype)
        {
        case FRST :
            G_memstores[s].crec=1;
            break;
        case LAST :
            G_memstores[s].crec=G_memstores[s].nrec;
            break;
        case PREV :
            if (G_memstores[s].crec>1)
                {
                G_memstores[s].crec--;
            } else
                {
                return(0L);
            }
            break;
        case NEXT :
            if (G_memstores[s].crec<G_memstores[s].nrec)
                {
                G_memstores[s].crec++;
            } else
                {
                return(0L);
            }
            break;
        case CURR :
            break;
        default :
            if (rtype<=G_memstores[s].nrec)
                {
                G_memstores[s].crec=(INT)rtype;
            } else
                {
                return(0L);
            }
    }
    if (G_memstores[s].crec==0)
        return(0L);
    memcpy(G_sstat[s].buf,G_memstores[s].recs[G_memstores[s].crec-1],G_sstat[s].len);
    G_sstat[s].modified=0;
    return(1L);
}

//************************************************************
//S put current record into approriate msstore buffer
//P char string store name
//R TRUE BOOL TRUE=Ok, FALSE=failed

LONG mswrite(CHAR *name)
{
    INT r;
    INT s,nflds,len;
    if ((s=getsnum(name))<0)
        return(0L);

    for (nflds=0;nflds<G_store[s].numitem;nflds++) 
        if (!(G_store[s].key&(0x80000000L>>nflds)))
            break;
    if (nflds<1)
        RETURNV(0);
    if (nflds==G_store[s].numitem)
        {
        len=G_sstat[s].len;
        }
    else
        {
        len=G_sstat[s].fofs[nflds];
        }

    if ((r=mssrchbuf(s,FRST,0,len))!=0) // get recno
        {
        memcpy(G_memstores[s].recs[r-1],G_sstat[s].buf,G_sstat[s].len);
        G_memstores[s].crec=r;
        }
    else
        {
        G_sstat[s].modified=1;
        if (msinsertrec(s))
            {
            if ((r=mssrchbuf(s,FRST,0,len))!=0)
                G_memstores[s].crec=r;
            }
        }
    G_sstat[s].modified=1;
    return(1L);
}

//************************************************************
//S make specified recnum current then delete current record
//P char string store name
//R LONG BOOL TRUE=Ok, FALSE=failed

LONG msdelrec(CHAR *name,LONG recnum)
{
    INT s;
    if ((s=getsnum(name))<0)
        return(0L);
    if (msread(name,recnum));
    msdeleterec(s);
    return(1L);
}

//************************************************************
//S get field from current record buffer
//P integer store number
//P integer field number - by my reckonning anyway
//R long TRUE Ok, FALSE failed

LONG msquickget(INT s,INT f,CHAR *var)
{
    INT len;
    UCHAR *b,*e;
    if (G_memstores==NULL)
        return(0L);
    if (G_memstores[f].recs==NULL)      // I think this should be [s] not [f] :JG
        return(0L);
    len=G_lib[G_store[s].li[f]].len;
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    e=b+len;
    switch (G_lib[G_store[s].li[f]].type)
        {
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

//************************************************************
//S store field in current buffer
//P integer store number
//P integer field number
//R long TRUE=OK, FALSE=failed

LONG msquickput(INT s,INT f,CHAR *var)
{
    INT len;
    UCHAR *b;
    if (G_memstores==NULL)
        return(0L);
    if (G_memstores[f].recs==NULL)      // I think this should be [s] not [f] :JG
        return(0L);
    len=G_lib[G_store[s].li[f]].len;
    b=(UCHAR *)G_sstat[s].buf+G_sstat[s].fofs[f];
    switch (G_lib[G_store[s].li[f]].type)
        {
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

//************************************************************
//S compute record number by search
//P char string table/file name
//P char string field name
//P integer mode for mssrchbuf
//R long offset or zero

LONG mssrch(CHAR *name,CHAR *fname,INT mode)
{
    INT s,f;
    INT len,ofs;                // I hate multi use variables :JG
    if ((s=getsnum(name))<0)
        return(0L);
    if ((f=fnum(name,fname))<0)
        return(0L);
    len=G_lib[G_store[s].li[f]].len;
    ofs=G_sstat[s].fofs[f];
    ofs=mssrchbuf(s,mode,ofs,len);
    if (ofs) G_memstores[s].crec=ofs;
    return((LONG)ofs);
}

//************************************************************
//S compute record number by search on field specified or or if blank get primary field
//P char string table name
//P integer field number
//P mode for mssrchbuf
//R long BOOL 1 i.e. TRUE or zero

LONG mssrchp(CHAR *name,INT nflds,INT mode)
{
    INT s;
    INT len,ofs;
    if ((s=getsnum(name))<0)
        return(0L);
    if (nflds==0)
        {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds)))
                break;
        if (nflds<1)
            RETURNV(0);
    }
    if (nflds==G_store[s].numitem)
        {
        len=G_sstat[s].len;
    } else
        {
        len=G_sstat[s].fofs[nflds];
    }
    ofs=mssrchbuf(s,mode,0,len);
    if (ofs) G_memstores[s].crec=ofs;
    return((LONG)(ofs>0));  // Why the boolean - markedly different to fn. mssrch() :JG
}

//************************************************************
//S empty a current record buffer 
//P char string table name
//R TRUE = valid or FALSE=failed

LONG msblank(CHAR *name)
{
    INT s;
    if ((s=getsnum(name))<0)
        return(0L);
    memset(G_sstat[s].buf,0,G_sstat[s].len);
    return(1L);
}

//************************************************************
//S empty a generic current record
//P char string table name
//R TRUE Ok, FALSE bad

LONG msempty(CHAR *name)
{
    return(msdelete(name));
}

//************************************************************
//S generate record number list either for matching recs - secondary
//P char str table name
//P char string field name
//P address to place list
//R integer number of recno.s returned (0=none returned)

LONG msbsslist(CHAR *name,CHAR *fname,LONG *ll)
{
    INT s,f,mode;
    INT len,ofs,nr=0;
    LONG rn;
    if ((s=getsnum(name))<0)
        return(0L);
    if ((f=fnum(name,fname))<0)
        return(0L);
    len=G_lib[G_store[s].li[f]].len;
    ofs=G_sstat[s].fofs[f];
    mode=FRST;
    while ((rn=(LONG)mssrchbuf(s,mode,ofs,len))!=0L)
        {
        G_memstores[s].crec=(INT)rn;
        ll[nr++]=rn;
        mode=NEXT;
    }
    return(nr);
}

//************************************************************
//S generate record number list either for matching recs - secondary
//P char str table name
//P integer field to work with or 0=use primary 
//P address to place list
//R integer number of recno.s returned (0=none returned)

LONG msbsplist(CHAR *name,INT nflds,LONG *ll)
{
    INT s,mode;
    INT len,nr=0;
    LONG rn;
    if ((s=getsnum(name))<0)
        return(0L);
    if (nflds==0)
        {
        for (nflds=0;nflds<G_store[s].numitem;nflds++) 
            if (!(G_store[s].key&(0x80000000L>>nflds)))
                break;
        if (nflds<1)
            RETURNV(0);
    }
    if (nflds==G_store[s].numitem)
        {
        len=G_sstat[s].len;
    } else
        {
        len=G_sstat[s].fofs[nflds];
    }
    mode=FRST;
    while ((rn=(LONG)mssrchbuf(s,mode,0,len))!=0L)
        {
        G_memstores[s].crec=(INT)rn;
        ll[nr++]=rn;
        mode=NEXT;
    }
    return(nr);
}
// **************************************************************************
// pdxdev.c <end-of-file>

