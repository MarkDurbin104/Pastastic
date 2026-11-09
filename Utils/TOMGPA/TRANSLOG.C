/****************************************************************************
* Project     : GPA
* File        : translog.c
* Description : transaction log functions
* 
* $Revision:   1.2  $  $Date:   Nov 03 1995 11:33:12  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/translog.c_v  $
* 
*    Rev 1.2   Nov 03 1995 11:33:12   JGRAY
* Annotations
* 
****************************************************************************/
#define TRANSLOG_C

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "gpasizes.h"
#include "types.h"
#include "config.h"
#include "message.h"
#include "keydef.h"
#include "formproc.h"
#include "fldproc.h"
#include "formhand.h"
#include "translog.h"
#include "money.h"
#include "control.h"
#include "function.h"
#include "actions.h"
#include "dst.h"
// 

//************************************************************
//S modify a log value
//P integer index of item to modify

void modlogval(INT idx)
{
    INT i,j=0;
    INT le=(-1);
    CHAR tmp[16];
    CHAR fixed[10];
    ENTRY(1640);
    if (!idx) {
        j=G_numt;
        le=j-1;
    }
    else {
        for (i=0;i<G_numt;i++) {
            if (G_log[i].idx==idx) {
                j++;
                le=i;
            }
        }
    }
    
    if (j<1) {
        beep();
        RETURN;
    }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_S,1);
    strcpy(tmp,G_log[le].aval);
    if (j>((G_larea[3]-G_larea[1])-1)) {
        inputstr(G_larea[0]+17,G_larea[3]-1,tmp,"MMMMMMMMMMMMMMM",0);
    }
    else {
        inputstr(G_larea[0]+17,G_larea[1]+j,tmp,"MMMMMMMMMMMMMMM",0);
    }
    if (!getprod(G_log[le].prod)) {
        getprod(G_prod);
        RETURN;
    }    
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,FIXP,fixed)) {
        getprod(G_prod);
        RETURN;
    }    
    if (!strcmp(fixed,"Y")) {
        G_log[le].qty=atoi(divm(tmp,G_log[le].val));
    }
    else {
        G_log[le].qty=1;
        strcpy(G_log[le].val,tmp);
    }
    strcpy(G_log[le].aval,rndm(mulm(G_log[le].val,G_log[le].qty),G_log[le].round));
    getprod(G_prod);
    displog(idx);
    RETURN;
}

//************************************************************
//S copy a log entry
//P pointer to TRANSLOG source
//P pointer to TRANSLOG destination

void copylog(TRANSLOG *s,TRANSLOG *d)
{
    ENTRY(1650);
    memcpy(d,s,sizeof(TRANSLOG));
    RETURN;
}

//************************************************************
//S delete a log entry
//P integer item to delete

void dellogrec(INT i)
{
    INT j;
    ENTRY(1660);

    for (j=i;j<G_numt;j++) copylog(&G_log[j+1],&G_log[j]);
    G_numt--;
    RETURN;
}

//************************************************************
//S remove a log entry type
//P integer index id

void removelogt(INT idx)
{
    INT i;
    ENTRY(1670);
    if (!idx) {
        G_numt=0;
        G_tindex=1;
    }
    else {
        for (i=0;i<G_numt;i++) {
            if (G_log[i].idx==idx) {
                dellogrec(i);
                i--;
            }
        }
        G_tindex--;
    }
    RETURN;
}

//************************************************************
//S let the operator scroll up and down the log and void transactions
//P integer idx to start at

void voidlog(INT idx)
{
    INT i;
    INT xit=0;
    INT le=0;
    ENTRY(1680);

    if (!idx)
        le=G_tindex-1;
    else
        for (i=0;i<G_numt;i++) if (G_log[i].idx==idx) le++;

    if (le<1) {
        beep();
        RETURN;
    }
    G_markt=le;
    displog(idx);
//    sendmsg("INPUT1",MESSAGE_A,9,prdate);
    while (!xit) {
        switch (sendmsg("INPUT1",MESSAGE_i)) {
            case UP :
                if (G_markt>1) G_markt--;
                break;
            case DOWN :
                if (G_markt<le) G_markt++;
                break;
            case F10 :
                G_markt=(-1);
                xit=1;
                break;
            case ESC :
                G_markt=(-1);
                xit=1;
                break;
            case LANGSWITCH : break;
            case CR :
#ifdef WIEN
                G_prod=G_log[G_markt-1].prod;
                G_marked=G_markt-1;
                runaction("PREVLOG");
#endif
                if (!idx)
                    {
                    for (i=0;i<G_numt;i++)
                        {
                        if (G_log[i].idx==G_markt)
                            {
                            dellogrec(i);
                            i--;
                            }
                        }
                    for (i=0;i<G_numt;i++) 
                        if (G_log[i].idx>G_markt)
                            G_log[i].idx--;
                    G_tindex--;
                    }
                else
                    {
                    le=0;
                    for (i=0;i<G_numt;i++)
                        {
                        if (G_log[i].idx==idx)
                            {
                            le++;
                            if (le==G_markt)
                                {
                                dellogrec(i);
                                i=G_numt;
                                }
                            }
                        }
                    }
                G_markt=(-1);
                xit=1;
                break;
            }
        displog(idx);
        }
//  sendmsg("INPUT1",MESSAGE_D,prdate);
    RETURN;
}

//************************************************************
//S output a log line
//P integer y column no.
//P integer log item to use
//P integer attribute

void outll(INT y,INT i,INT attr)
{
    CHAR tmp[40];
    ENTRY(1690);

    if (G_log[i].qty>1)
        {
        if (G_log[i].qty<100)
            sprintf(tmp,"%-14.14s%2d",G_log[i].desc,G_log[i].qty);
        else
            sprintf(tmp,"%-14.14s**",G_log[i].desc);
        }
    else
        {
        sprintf(tmp,"%-16.16s",G_log[i].desc);
    }
    output(G_larea[0]+1 ,G_larea[1]+1+y,tmp,16,"X",1,attr);
    output(G_larea[0]+17,G_larea[1]+1+y,G_log[i].aval,15,"M",1,attr);
    sendmsg("OUTPUT1",MESSAGE_A,0);
    RETURN;
}

//************************************************************
//S display the transaction log on screen
//P integer log level to work on

void displog(INT loglev)
{
    INT loglen,logofs;
    INT i,j,k;
    INT tft=G_form.type;
    ENTRY(1700);

    G_form.type=0;
    loglen=(G_larea[3]-G_larea[1])-1;
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_S,1);
    if (loglev==0) {
        if (G_numt<loglen) {
            for (i=0;i<loglen;i++) {
                if (i<G_numt) {
                    if (G_log[i].idx==G_markt)
                        outll(i,i,1);
                    else
                        outll(i,i,0);
                }
                else {
                    output(G_larea[0]+1,G_larea[1]+1+i,"",31,"X",1,0);
                }
            }
        }
        else {
            logofs=G_numt-loglen;
            if (G_markt!=(-1)) {
                for (i=0;i<G_numt;i++) if (G_log[i].idx==G_markt) break;
                if (logofs>i) logofs=i;
            }
            for (i=0;i<loglen;i++) {
                if (G_log[i+logofs].idx==G_markt)
                    outll(i,i+logofs,1);
                else
                    outll(i,i+logofs,0);
            }
        }
    }
    else {
        j=0;
        for (i=0;i<G_numt;i++) if (G_log[i].idx==loglev) j++;
        if (j<loglen) {
            i=0;
            for (k=0;k<G_numt;k++) {
                if (G_log[k].idx==loglev) {
                    if ((i+1)==G_markt)
                        outll(i,k,1);
                    else
                        outll(i,k,0);
                    i++;
                }
            }
            for (;i<loglen;i++) {
                output(G_larea[0]+1,G_larea[1]+1+i,"",31,"X",1,0);
            }
        }
        else {
            i=loglen-1;
            for (k=G_numt-1;k>=0;k--) {
                if (G_log[k].idx==loglev) {
                    if (k==G_markt)
                        outll(i,k,1);
                    else
                        outll(i,k,0);
                    i--;
                }
                if (i<0) break;
            }
        }
    }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_S,3);
    sendmsg("OUTPUT1",MESSAGE_o,G_tarea[0]+1,G_tarea[1]+1,"%s",G_moneys);
    output(G_tarea[0]+6,G_tarea[1]+1,logtotal(loglev),15,"M",3,0);
    G_form.type=(CHAR)tft;
    RETURN;
}

//************************************************************
//S RETURN the transaction log total value
//P integer log level to work with
//R reply char string address of total

CHAR *logtotal(INT loglev)
{
    INT i;
    static CHAR totmoney[40];
    ENTRY(1710);

    strcpy(totmoney,"0");

    for (i=0;i<G_numt;i++) {
        if ((loglev==0)||(G_log[i].idx==loglev)) {
            strcpy(totmoney,addm(totmoney,G_log[i].aval));
        }
    }
    RETURNV(totmoney);
}

//************************************************************
//S add a transaction to the log
//P char string description
//P char string value
//P char string a0
//P char string a1
//P char string a2
//R BOOL TRUE Ok, FALSE failed

INT add2log(CHAR *n,CHAR *v,CHAR *a1,CHAR *a2,CHAR *a3)
{
#ifdef WIEN
   CHAR verrgr[20];
   CHAR statgr[20];
#endif
    ENTRY(1720);

    if (G_log==NULL)
        {
        G_log=MALLOC(NUMLOGENT*sizeof(TRANSLOG));
        if (G_log==NULL)
            RETURNV(0);
        }
    if (G_numt>=(NUMLOGENT-1))
        {
        beep();
        RETURNV(0);
        }
    G_log[G_numt].idx=G_tindex;
    G_log[G_numt].prod=G_prod;
    G_log[G_numt].round=G_round;
    G_log[G_numt].qty=G_qnty;
    strcpy(G_log[G_numt].desc,n);
    strcpy(G_log[G_numt].val,v);
    strcpy(G_log[G_numt].aval,rndm(mulm(G_log[G_numt].val,G_log[G_numt].qty),G_log[G_numt].round));
    strcpy(G_log[G_numt].date,datestr(MINDATE));
    strcpy(G_log[G_numt].time,datestr(MINTIME));
    if ((G_numt)&&(!strcmp(G_log[G_numt].time,G_log[G_numt-1].time)))
        strcpy(G_log[G_numt].time,addm(G_log[G_numt].time,"1"));
    strcpy(G_log[G_numt].a[0],a1);
    strcpy(G_log[G_numt].a[1],a2);
    strcpy(G_log[G_numt].a[2],a3);
    sendmsg("OUTPUT1",MESSAGE_o,0,2,"Adding %d",G_prod);
#ifdef WIEN
    if(G_prod !=0)
        {
        if (!getprod(G_prod)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_g,PROD_S,OPT4,verrgr)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_g,PROD_S,OPT5,statgr)) RETURNV(0);
        if (strlen(G_globs[9])<2)
            strcpy(G_log[G_numt].a[4],statgr);
        else
            {
            strcpy(G_log[G_numt].a[4],G_globs[9]);
            }
        strcpy(G_log[G_numt].a[3],verrgr);
        strcpy(G_globs[8],"0");
        strcpy(G_globs[9],"0");
        }
    sendmsg("OUTPUT1",MESSAGE_o,0,3,"Adding %d %s %s %s %s %s",G_prod,G_log[G_numt].a[0],G_log[G_numt].a[1],G_log[G_numt].a[2],G_log[G_numt].a[3],G_log[G_numt].a[4]);
#endif
    sendmsg("INPUT1",MESSAGE_i);
    G_numt++;

    RETURNV(1);
}

//************************************************************
//S write all transactions from the log to the table
//R TRUE Ok, FALSE failed

INT writetrans(void)
{
    CHAR tmp[80];
    INT i;
    ENTRY(1730);
    if (G_numt) {
        G_prod=0;         // End customer marker
        G_qnty=0;
        add2log("-------------------","0","-------------------","-------------------","-------------------");
        for (i=0;i<G_numt;i++) {
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,CDAT,G_log[i].date)) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,TIME,G_log[i].time)) RETURNV(0);
            sprintf(tmp,"%d",G_uid);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,USID,tmp)) RETURNV(0);
            sprintf(tmp,"%d",G_position);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,POSN,tmp)) RETURNV(0);
            sprintf(tmp,"%d",G_log[i].prod);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,CODE,tmp)) RETURNV(0);
            sprintf(tmp,"%d",G_log[i].qty);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,QNTY,tmp)) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,AMNT,G_log[i].aval)) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,ADF1,G_log[i].a[0])) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,ADF2,G_log[i].a[1])) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,ADF3,G_log[i].a[2])) RETURNV(0);
#ifdef WIEN
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,ADF4,G_log[i].a[3])) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,ADF5,G_log[i].a[4])) RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,"abgeschl","N")) RETURNV(0);
#endif
            if (!sendmsg("DBM",MESSAGE_w,TRAN_S)) RETURNV(0);
            updatestock(G_log[i].prod,G_log[i].qty,G_log[i].aval);
            }
        }
    G_numt=0;
    RETURNV(1);
}

//************************************************************
//S update the stock table from the transaction log
//P integer product code
//P integer quantity
//P char string value
//R TRUE Ok, FALSE failed

INT updatestock(INT prod,INT qty,CHAR *val)
{
    CHAR tmp[20];
    CHAR qnty[20];
    ENTRY(1740);

    if (prod==0) RETURNV(1);   // End customer marker

    sprintf(tmp,"%d",prod);
    if (!sendmsg("DBM",MESSAGE_p,STOK_S,CODE,tmp)) RETURNV(0);
    sprintf(tmp,"%d",G_uid);
    if (!sendmsg("DBM",MESSAGE_p,STOK_S,USID,tmp)) RETURNV(0);

    if (!sendmsg("DBM",MESSAGE_s,STOK_S,NULL,2)) {
        sprintf(qnty,"%d",0-qty);
        if (!sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,qnty)) RETURNV(0);
        strcpy(tmp,"0");
        if (!sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,subm(tmp,val))) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_w,STOK_S)) RETURNV(0);
        }
    else {
        if (!sendmsg("DBM",MESSAGE_r,STOK_S,(LONG)CURR)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_g,STOK_S,QNTY,qnty)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_g,STOK_S,AMNT,tmp)) RETURNV(0);

        sprintf(qnty,"%d",atoi(qnty)-qty);
        if (!sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,qnty)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,subm(tmp,val))) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_w,STOK_S)) RETURNV(0);
        }
#ifdef WIEN
    runaction("ASTKMARK");
#endif
    RETURNV(1);
}
// **************************************************************************
// translog.c <end-of-file>

