/****************************************************************************
* Project     : GPA
* File        : function.c
* Description : 
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:15:10  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/function.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:15:10   JGRAY
*  
* 
****************************************************************************/
#define FUNCTION_C 

#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <dos.h>

#include "gpasizes.h"
#include "types.h"
#include "money.h"
#include "keydef.h"
#include "config.h"
#include "diskdev.h"
#include "message.h"
#include "formproc.h"
#include "fldproc.h"
#include "tabproc.h"
#include "menuproc.h"
#include "formhand.h"
#include "dst.h"
#include "actions.h"
#include "translog.h"
#include "function.h"
#include "control.h"
#ifndef __TURBOC__
#include "supp.h"
#endif

INT G_lcnt=0;


//************************************************************
//S Compare two fields, supplied as strings
//P char string 1
//P char string 2
//R standard strcmp reply 

INT fldcmp(CHAR *a,CHAR *b)
{
    ENTRY(510);
//    if ((strlen(a)!=strlen(b))) RETURNV(1000);
    RETURNV(strcmp(a,b));
}

//************************************************************
//S check value for range using table set parameters
//P char string table name
//P char string value to check for range
//R TRUE=inrange or FALSE=not in range

INT inrange(CHAR *table,CHAR *value)
{
    CHAR val[LENOFRANGECMPSTR];
    CHAR cmp[LENOFRANGECMPSTR];
    LONG v,c;
    INT res;
    INT s,i,j;
    ENTRY(520);

    if ((s=snum(table))<0) RETURNV(0);
    for (j=0;j<G_store[s].numitem;j++) 
       if (!(G_store[s].key&(0x80000000L>>j))) break;

    if (j<2) RETURNV(0);
    j--;
    if ((i=fnum(table,TO_F))<0) RETURNV(0);
    if ((i=fnum(table,FROM))<0) RETURNV(0);
    i=G_lib[G_store[s].li[i]].type;
    if ((i=='9')||(i=='M')||(i=='W')) {
        v=atol(value);
        strcpy(val,value);
        sendmsg("DBM",MESSAGE_p,table,FROM,val);
        sendmsg("DBM",MESSAGE_sp,table,j,CLSE);
        sendmsg("DBM",MESSAGE_r,table,(LONG)CURR);
        sendmsg("DBM",MESSAGE_g,table,FROM,cmp);
        c=atol(cmp);
        if (v!=c) {
            if (c<v) {
                sendmsg("DBM",MESSAGE_r,table,(LONG)PREV);
                sendmsg("DBM",MESSAGE_g,table,FROM,cmp);
                c=atol(cmp);
                if (v!=c) {
                    if (v<c) {
                        RETURNV(0);
                    } else {
                        sendmsg("DBM",MESSAGE_g,table,TO_F,cmp);
                        c=atol(cmp);
                        if (v<=c) {
                            RETURNV(1);
                        } else {
                            RETURNV(0);
                        }
                    }
                } else {
                    RETURNV(1);
                }
            } else {
                sendmsg("DBM",MESSAGE_g,table,TO_F,cmp);
                c=atol(cmp);
                if (v<=c) {
                    RETURNV(1);
                } else {
                    RETURNV(0);
                }
            }
        }
    } else {
        strcpy(val,value);
        strupr(val);
        sendmsg("DBM",MESSAGE_p,table,FROM,val);
        sendmsg("DBM",MESSAGE_sp,table,j,CLSE);
        sendmsg("DBM",MESSAGE_r,table,(LONG)CURR);
        sendmsg("DBM",MESSAGE_g,table,FROM,cmp);
        if ((res=fldcmp(val,cmp))!=0) {
            if (res==1000) RETURNV(0);
            if (res<0) {
                sendmsg("DBM",MESSAGE_r,table,(LONG)PREV);
                sendmsg("DBM",MESSAGE_g,table,FROM,cmp);
                if ((res=fldcmp(val,cmp))!=0) {
                    if (res<0) {
                        RETURNV(0);
                    }
                    else {
                        sendmsg("DBM",MESSAGE_g,table,TO_F,cmp);
                        if ((res=fldcmp(val,cmp))<=0) {
                            RETURNV(1);
                        }
                        else {
                            RETURNV(0);
                        }
                    }
                }
                else {
                    RETURNV(1);
                }
            }
            else {
                sendmsg("DBM",MESSAGE_g,table,TO_F,cmp);
                if ((res=fldcmp(val,cmp))<=0) {
                    RETURNV(1);
                }
                else {
                    RETURNV(0); // assumption
                }
            }
        }
    }
    RETURNV(1);
}

//************************************************************
//S determine no. of months between two dates
//P char string date from
//P char string date to
//R integer number of months between the two dates

INT months(CHAR *datef,CHAR *datet)
{
   CHAR xx[3];
   INT i,ms,me,mm,yy;
   INT df,mf,yf;
   INT dt,mt,yt;
   INT ystart = 92;
   ENTRY(530);
   // I think there should be code to say xx[2]='\0' here :JGQ 26/10
   strncpy(xx,&datef[4],2); df = atoi(xx);
   strncpy(xx,&datef[2],2); mf = atoi(xx);
   strncpy(xx,&datef[0],2); yf = atoi(xx);
   
   strncpy(xx,&datet[4],2); dt = atoi(xx);
   strncpy(xx,&datet[2],2); mt = atoi(xx);
   strncpy(xx,&datet[0],2); yt = atoi(xx);

   mm = 0; yy = yf;
   for(i = ystart; i < yy; i++)  mm = mm + 12;

   for(i = 0; i < mf; i++) mm++; 
   ms = mm;

   mm = 0; yy = yt;
   for(i = ystart; i < yy; i++) mm = mm + 12;
   
   for(i = 0; i < mt; i++) mm++;
   me = mm;
   if((dt - df) > 0) RETURNV(me - ms + 1);
   RETURNV(me - ms);  
}

//************************************************************
//S routine to determine an integer no. of days from a supplied date
//D just calls datetonum from config module
//P char string date
//R integer number of days

INT daynum(CHAR *dt)
{
    ENTRY(540);
    RETURNV(datetonum(dt));
}

//************************************************************
//S number of days between two dates
//P char string date to count from
//P char string date to end range
//R integer number of days

INT days(CHAR *datef,CHAR *datet)
{
    ENTRY(550);
    RETURNV(daynum(datet)-daynum(datef));
}

//************************************************************
//S This routine determines the nearest of two presented dates to today
//P char string first date to check
//P char string end date to work with
//R integer no. of days negative or positive relating to today and the date range

INT nearday(CHAR *datef,CHAR *datet)
{
    INT daysf,dayst,daysn;
    ENTRY(560);

    daysf=daynum(datef);
    dayst=daynum(datet);
    daysn=daynum(datestr(MINDATE));
                                     
    if ((daysn-daysf)<(dayst-daysn))
        RETURNV(daysf-daysn);         // RETURN < -tive days late
    RETURNV(dayst-daysn);             // RETURN < +tive days early
}

//************************************************************
//S determines nearest due date to today when specified which day is due
//P integer day on month to check
//R char string date due

CHAR *duedom(INT day)
{
    INT d,m,y;
    static CHAR fd[LENOFDATESTR],td[LENOFDATESTR];
    ENTRY(570);
    
    strcpy(fd,datestr(MINDATE));

    d = getday(fd);
    m = getmon(fd);
    y = getyear(fd);
    orddfrom(&y,&m,&d);
    if (day<d) m++;
    if (m==13) { m=1; y++; }
    if (day==32) d=G_dpm[m-1]; else d=day;
    sprintf(td,"%02d%02d%02d",y,m,d);

    d = getday(fd);
    m = getmon(fd);
    y = getyear(fd);
    orddfrom(&y,&m,&d);
    if (day>d) m--;
    if (m==0) { m=12; y--; }
    if (day==32) d=G_dpm[m-1]; else d=day;
    orddto(&y,&m,&d);
    sprintf(fd,"%02d%02d%02d",y,m,d);

    if (nearday(fd,td)<0) RETURNV(fd);
    RETURNV(td);
}

//************************************************************
//S Presented with 4 quarter dates determines current due quarter
//P char string quarter 1
//P char string quarter 2
//P char string quarter 3
//P char string quarter 4
//R char string due date of quarter

CHAR *duequat(CHAR *q1,CHAR *q2,CHAR *q3,CHAR *q4)
{
    static CHAR dd[LENOFDATESTR];
    CHAR fq[LENOFDATESTR],lq[LENOFDATESTR];
    INT a,b,c,d,e,f,g;
    ENTRY(580);

    strcpy(dd,datestr(MINDATE));

    a=getday(q4);
    b=getmon(q4);
    c=getyear(q4);
    orddfrom(&c,&b,&a);
    c--;
    orddto(&c,&b,&a);
    sprintf(fq,"%02d%02d%02d",c,b,a);

    a=getday(q1);
    b=getmon(q1);
    c=getyear(q1);
    orddfrom(&c,&b,&a);
    c++;
    orddto(&c,&b,&a);
    sprintf(lq,"%02d%02d%02d",c,b,a);

    a=abs(days(fq,dd));
    b=abs(days(q1,dd));
    c=abs(days(q2,dd));
    d=abs(days(q3,dd));
    e=abs(days(q4,dd));
    f=abs(days(lq,dd));

    g=min(a,b); g=min(g,c); g=min(g,d); g=min(g,e); g=min(g,f);

    if (g==a) strcpy(dd,fq);
    if (g==b) strcpy(dd,q1);
    if (g==c) strcpy(dd,q2);
    if (g==d) strcpy(dd,q3);
    if (g==e) strcpy(dd,q4);
    if (g==f) strcpy(dd,lq);

    RETURNV(dd);
}

//************************************************************
//S Presented with two half year dates computes due half year date
//P char string half year date 1
//P char string half year date 2
//R char string half year due date

CHAR *duehalf(CHAR *h1,CHAR *h2)
{
    static CHAR dd[LENOFDATESTR];
    CHAR fh[LENOFDATESTR],lh[LENOFDATESTR];
    INT a,b,c,d,f;
    ENTRY(590);
    
    strcpy(dd,datestr(MINDATE));

    a=getday(h2);
    b=getmon(h2);
    c=getyear(h2);
    orddfrom(&c,&b,&a);
    c--;
    orddto(&c,&b,&a);
    sprintf(fh,"%02d%02d%02d",c,b,a);

    a=getday(h1);
    b=getmon(h1);
    c=getyear(h1);
    orddfrom(&c,&b,&a);
    c++;
    orddto(&c,&b,&a);
    sprintf(lh,"%02d%02d%02d",c,b,a);

    a=abs(days(fh,dd));
    b=abs(days(h1,dd));
    c=abs(days(h2,dd));
    d=abs(days(lh,dd));

    f=min(a,b); f=min(f,c); f=min(f,d);

    if (f==a) strcpy(dd,fh);
    if (f==b) strcpy(dd,h1);
    if (f==c) strcpy(dd,h2);
    if (f==d) strcpy(dd,lh);

    RETURNV(dd);
}

//************************************************************
//S Check current item if Yes or No character
//R BOOL TRUE if OK, FALSE if neither Y nor N

INT yesno(void)
{
    ENTRY(600);
    if (toupper(G_formvars[G_form.curitem][0])==G_yes)
        {
        G_formvars[G_form.curitem][0]=(CHAR)G_yes;
        RETURNV(1);
        }
    if (toupper(G_formvars[G_form.curitem][0])==G_no)
        {
        G_formvars[G_form.curitem][0]=(CHAR)G_no;
        RETURNV(1);
        }
    if (G_formvars[G_form.curitem][0]==G_yes)
        {
        RETURNV(1);
        }
    if (G_formvars[G_form.curitem][0]==G_no)
        {
        RETURNV(1);
        }
    beep();
    G_form.curitem--;
    RETURNV(0);
}

//************************************************************
//S For remaining items in form blank them out
//R TRUE

INT blankrest(void)
{
    CHAR sn[LENOFITEM],fn[LENOFITEM],tmp[LENOFITEM],*t;
    INT i;
    ENTRY(610);

    for (i=G_form.curitem+1;i<G_form.numitem;i++) {
        strcpy(tmp,G_form.items[i].item);
        if (tmp!=NULL) {
            t=strtok(tmp,". ");
            if (t!=NULL) {
                strcpy(sn,t);
                t=strtok(NULL,". ");
                if (t!=NULL) {
                    strcpy(fn,t);
                    if (sendmsg("DBM",MESSAGE_p,sn,fn,""))
                        G_formvars[i][0]=0;
                    }
                }
            }
        }
    RETURNV(1);
}

//************************************************************
//S Put error message on screen
//D if we had one already then blank it
//P char string error text
//P integer type { 0 = wait ERRORTYPE0WAIT and clear,1 = acknowledge, 3=clear } 

void errorline(CHAR *e,INT type) 
{
    static INT lll=0;
    INT k=0,nobell;
    INT s=(INT)sendmsg("OUTPUT1",MESSAGE_i);
    ENTRY(620);
    nobell=type&0x08;
    type&=0x07;
    G_hotkeys=0;
    if (lll!=0)
        {
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_S,G_elinesz);
        sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,"%*.*s",lll,lll,"");
    }
    lll=strlen(e);
    if (type!=3)
        {
        sendmsg("OUTPUT1",MESSAGE_A,G_elinecl);
        sendmsg("OUTPUT1",MESSAGE_S,G_elinesz);
        sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,e);
        if (!nobell)
            beep();
        }
    else
        {
        lll=0;
        }
    switch (type) {
        case 0 :
            sendmsg("OSSDEV",MESSAGE_d,ERRORTYPE0WAIT);
            sendmsg("OUTPUT1",MESSAGE_A,0);
              sendmsg("OUTPUT1",MESSAGE_S,G_elinesz);
            sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,"%*.*s",lll,lll,"");
            lll=0;
            break;
        case 1 :
            k=(INT)sendmsg("INPUT1",MESSAGE_i);
            sendmsg("OUTPUT1",MESSAGE_A,0);
              sendmsg("OUTPUT1",MESSAGE_S,G_elinesz);
            sendmsg("OUTPUT1",MESSAGE_o,1,G_elineat,"%*.*s",lll,lll,"");
            lll=0;
            if (k==EXIT_K) {
                sendmsg("OUTPUT1",MESSAGE_OF);
                sendmsg("INPUT1",MESSAGE_P,EXIT_K);
                sendmsg("INPUT1",MESSAGE_P,5000);
            }
            break;
    }
       sendmsg("OUTPUT1",MESSAGE_S,s);
       sendmsg("OUTPUT1",MESSAGE_A,0);
    G_hotkeys=1;
    RETURN;
}

//************************************************************
//S zerotran: Empty transact buffer
//R TRUE

INT zerotran(void)
{
    ENTRY(630);
    sendmsg("DBM",MESSAGE_e,TRAN_S);
    RETURNV(1);
}

//************************************************************
//S Reverse payment utility reversal: related to transact table
//R TRUE Ok, or FALSE failed

INT reversal(void)
{
    CHAR tmp[LENOFREVERSALTMP];
    CHAR prod[LENOFPROD];
    CHAR val[LENOFVAL];
    CHAR qty[LENOFQTY];
    UCHAR acc;
    INT xit=0;
    CHAR dpass[LENOFDPASS];
    ENTRY(640);
    if ((G_tb!=NULL)&&(!strcmp(G_store[G_tb->sn].name,TRAN_S)))
        {
        if (G_keydisk) {
            sendmsg("OUTPUT1",MESSAGE_A,0);
            sendmsg("OUTPUT1",MESSAGE_S,1);
            sendmsg("OUTPUT1",MESSAGE_o,0,4,"%s",G_revprmt);
            tmp[0]=0;
            inputstr(strlen(G_revprmt)+1,4,tmp,"PPPP",0);
            sendmsg("OUTPUT1",MESSAGE_o,0,4,"%*.*s",strlen(G_revprmt)+6,strlen(G_revprmt)+6,"");
            sendmsg("DISK",MESSAGE_G,PASSWORD,dpass);
            if (strcmp(tmp,dpass)) {
                beep();
                RETURNV(0);
            }
            sendmsg("DISK",MESSAGE_G,ACCESS,&acc);
            if (acc<5) {
                beep();
                RETURNV(0);
            }
        }
        sendmsg("DBM",MESSAGE_g,TRAN_S,CODE,prod);
        sendmsg("DBM",MESSAGE_g,TRAN_S,AMNT,val);
        sendmsg("DBM",MESSAGE_g,TRAN_S,QNTY,qty);
        sendmsg("DBM",MESSAGE_g,TRAN_S,TIME,tmp);
        if ((tmp[7]=='R')||(tmp[7]=='r'))
            {
            sendmsg("DBM",MESSAGE_dr,TRAN_S,sendmsg("DBM",MESSAGE_rn,TRAN_S));
            if (G_keydisk)
                {
                sendmsg("DBM",MESSAGE_p,STOK_S,CODE,prod);
                sprintf(tmp,"%d",G_uid);
                sendmsg("DBM",MESSAGE_p,STOK_S,USID,tmp);
    
                if (sendmsg("DBM",MESSAGE_s,STOK_S,NULL,2))
                    {
                    sendmsg("DBM",MESSAGE_r,STOK_S,(LONG)CURR);
                    sendmsg("DBM",MESSAGE_g,STOK_S,QNTY,tmp);
                    sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,subm(tmp,qty));
                    sendmsg("DBM",MESSAGE_g,STOK_S,AMNT,tmp);
                    sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,addm(tmp,val));
                    sendmsg("DBM",MESSAGE_w,STOK_S);
                    }
                }
            RETURNV(1);
            }
        tmp[7]='R';
        sendmsg("DBM",MESSAGE_p,TRAN_S,TIME,tmp);
        sendmsg("DBM",MESSAGE_p,TRAN_S,AMNT,subm("0",val));
        sendmsg("DISK",MESSAGE_G,USERNAME,dpass);
        sendmsg("DISK",MESSAGE_G,USERID,&acc);
        sprintf(tmp,"%s - %d",dpass,acc);
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF1,tmp);
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF2,datestr(MINDT));
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF3,"");
        sendmsg("DBM",MESSAGE_w,TRAN_S);

        if (G_keydisk)
            {
            sendmsg("DBM",MESSAGE_p,STOK_S,CODE,prod);
            sprintf(tmp,"%d",G_uid);
            sendmsg("DBM",MESSAGE_p,STOK_S,USID,tmp);

            if (sendmsg("DBM",MESSAGE_s,STOK_S,NULL,2))
                {
                sendmsg("DBM",MESSAGE_r,STOK_S,(LONG)CURR);
                sendmsg("DBM",MESSAGE_g,STOK_S,QNTY,tmp);
                sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,addm(tmp,qty));
                sendmsg("DBM",MESSAGE_g,STOK_S,AMNT,tmp);
                sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,addm(tmp,val));
                sendmsg("DBM",MESSAGE_w,STOK_S);
                }
            }
        sendmsg("DBM",MESSAGE_g,TRAN_S,TIME,tmp);
        tmp[7]='r';
        sendmsg("DBM",MESSAGE_p,TRAN_S,TIME,tmp);
        sendmsg("DBM",MESSAGE_p,TRAN_S,AMNT,val);
        sendmsg("DISK",MESSAGE_G,USERNAME,dpass);
        sendmsg("DISK",MESSAGE_G,USERID,&acc);
        sprintf(tmp,"%d",1);
        sendmsg("DBM",MESSAGE_p,TRAN_S,CODE,tmp);
        sprintf(tmp,"%s - %d",dpass,acc);
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF1,tmp);
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF2,datestr(MINDT));
        sendmsg("DBM",MESSAGE_p,TRAN_S,ADF3,"");
        sendmsg("DBM",MESSAGE_w,TRAN_S);

        if (G_keydisk) {
            sprintf(tmp,"%d",1);
            sendmsg("DBM",MESSAGE_p,STOK_S,CODE,tmp);
            sprintf(tmp,"%d",G_uid);
            sendmsg("DBM",MESSAGE_p,STOK_S,USID,tmp);

            if (sendmsg("DBM",MESSAGE_s,STOK_S,NULL,2)) {
                sendmsg("DBM",MESSAGE_r,STOK_S,(LONG)CURR);
                sendmsg("DBM",MESSAGE_g,STOK_S,QNTY,tmp);
                sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,addm(tmp,qty));
                sendmsg("DBM",MESSAGE_g,STOK_S,AMNT,tmp);
                sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,subm(tmp,val));
                sendmsg("DBM",MESSAGE_w,STOK_S);
            }
        }
    }
    if ((G_tb!=NULL)&&(!strcmp(G_store[G_tb->sn].name,"~tock")))
        {
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_S,1);
        sendmsg("OUTPUT1",MESSAGE_o,0,4,"%s",G_clrstok);
        tmp[0]=0;
        inputstr(strlen(G_clrstok)+1,4,tmp,"A",0);
        sendmsg("OUTPUT1",MESSAGE_o,0,4,"%*.*s",strlen(G_clrstok)+6,strlen(G_clrstok)+2,"");
        if ((toupper(tmp[0])==G_yes)||(tmp[0]==G_yes)) {
            xit=(!sendmsg("DBM",MESSAGE_r,"~tock",(LONG)FRST));
            sendmsg("DBM",MESSAGE_g,"~tock",USID,tmp);
            while (!xit) {
                if (atoi(tmp)==G_uid)
                sendmsg("DBM",MESSAGE_p,"~tock",QNTY,"0");
                sendmsg("DBM",MESSAGE_p,"~tock",AMNT,"0");
                sendmsg("DBM",MESSAGE_w,"~tock");
                xit=(!sendmsg("DBM",MESSAGE_r,"~tock",(LONG)NEXT));
            }
        }
    }
    RETURNV(0);
}

//************************************************************
//S set / clear transact temp user id table
//R TRUE Ok, FALSE Failed

INT tabstuid(void)
{
    CHAR tmp[LENOFUID];
    ENTRY(650);
    sprintf(tmp,"%d",G_uid);
    if (!sendmsg("DBM",MESSAGE_p,TRAN_S,USID,tmp)) // put useer id field
        RETURNV(0);
    if (G_intable)
        {
        sendmsg("DBM",MESSAGE_d,TRAN_S,NULL,1);     // duplicate table
        }
    else
        {
        sendmsg("DBM",MESSAGE_rd,TRAN_S,0);         // remove duplicate
        }
    RETURNV(1);
}

//************************************************************
//S set / clear stock temp user id table
//R TRUE Ok, FALSE Failed

INT tabssuid(void)
{
    CHAR tmp[LENOFUID];
    ENTRY(660);
    sprintf(tmp,"%d",G_uid);
    if (!sendmsg("DBM",MESSAGE_p,STOK_S,USID,tmp))
        RETURNV(0);
    if (G_intable)
        sendmsg("DBM",MESSAGE_d,STOK_S,NULL,1);
    else
        sendmsg("DBM",MESSAGE_rd,STOK_S,1);
    RETURNV(1);
}

//************************************************************
//S print list to output1
//P integer x coordinate
//P integer y coordinate
//P integer width of display
//P integer length of display
//P address of array of string pointers
//P integer ni number of items
//P integer current position to be hilit

void prlist(INT x,INT y,INT w,INT l,CHAR **list,INT ni,INT pos)
{
    INT i,j,tp;
    ENTRY(670);
    sendmsg("OUTPUT1",MESSAGE_S,1);
    sendmsg("OUTPUT1",MESSAGE_B,x,y,x+w,y+(l-1));
    tp=pos;
    if (tp>=(ni-(l-2))) tp=ni-(l-2);
    for (j=1,i=tp;i<ni;j++,i++)
        {
        if (i==pos)
            sendmsg("OUTPUT1",MESSAGE_A,1);
        else
            sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+1+(i-tp),"%-*.*s",w-2,w-2,list[i]);
        if (j==(l-2)) break;
        }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    for (;j<(l-2);j++) {
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+1+(i-tp),"%-*.*s",w-2,w-2,"");
    }
    RETURN;
}

//************************************************************
//S controled output of a list to screen with scroll commands
//P integer x coordinate
//P integer y coordinate
//P integer width of display
//P integer length of display
//P address of array of string pointers
//P integer string list of key numbers
//P integer current position to be hilit
//P address of integer for key selected on CR/LF or (-ive) key value e.g. F10
//P integer ni number of items

void clist(INT x,INT y,INT w,INT l,CHAR **list,INT *klist,INT pos,INT *np,INT ni)
{
    INT i,k;
    INT xit=0;
    ENTRY(680);
    while (!xit)
        {
        prlist(x,y,w,l,list,ni,pos);
        switch (k=(INT)sendmsg("INPUT1",MESSAGE_i))
            {
            case UP :
                if (pos>0) pos--;
                break;
            case DOWN :
                if (pos<(ni-1)) pos++;
                break;
            case CR :
            case LF :
                *np=klist[pos];
                xit=1;
                break;
            case ESC :
                *np=ESC;
                xit=1;
                break;
            case F09 :
                *np=F09;
                xit=1;
                break;
            case EXIT_K :
                *np=EXIT_K;
                xit=1;
                break;
            case LANGSWITCH : break;
            default :
                for (i=0;i<ni;i++) {
                    if (k==klist[i]) {
                        *np=k;
                        xit=1;
                        break;
                    }
                }
                if (i==ni) beep();
        }
    }
    RETURN;
}

//************************************************************
//S Build data list for item selection then calls clist to select item
//R integer return key value - or control key exit code e.g. F10

INT proptional(void)
{
    INT i=1,j,k;
    CHAR **list=NULL;
    INT *klist=NULL;
    CHAR tmp[LENOFNAME];
    CHAR tmp1[LENOFKEYDETS];
    INT tft=G_form.type;
    ENTRY(690);
    G_form.type=0;
    for (j=0;j<G_numeks[G_edepth-1];j++)
        {
        if (G_exitkeys[G_edepth-1][j].key!=0) i++;
        }
    list=MALLOC(i*sizeof(CHAR *));
    klist=MALLOC(i*sizeof(INT));
    list[0]=STRDUP(G_none);
    klist[0]=CR;
    i=1;
    for (j=0;j<G_numeks[G_edepth-1];j++)
        {
        if (G_exitkeys[G_edepth-1][j].key!=0)
            {
            getprod(G_exitkeys[G_edepth-1][j].prod);
            tmp[0]=0;
            sendmsg("DBM",MESSAGE_g,PROD_S,NAME,tmp);
            sprintf(tmp1,"%-32.32s %-5.5s",tmp,keyname(G_exitkeys[G_edepth-1][j].key));
            list[i]=STRDUP(tmp1);
            klist[i]=G_exitkeys[G_edepth-1][j].key;
            i++;
        }
    }
    clist(1,21,40,4,list,klist,0,&j,i);
    G_form.type=(CHAR)tft;
    for (k=0;k<i;k++) FREE(list[k]);
    FREE(list);
    FREE(klist);
    RETURNV(j);
}

//************************************************************
//S get value from scales
//R TRUE

INT getscale(void)
{
    ENTRY(700);
    sendmsg("INPUT2",MESSAGE_i);
    RETURNV(1);
}

//************************************************************
//S Process scale MESSAGE_Z
//R TRUE

INT scalez(void)
{
    ENTRY(710);
    sendmsg("INPUT2",MESSAGE_Z);
    RETURNV(1);
}

//************************************************************
//S Read scale (MESSAGE_i) - same as function getscale
//R TRUE

INT scalenz(void)
{
    ENTRY(720);
    sendmsg("INPUT2",MESSAGE_i);
    RETURNV(1);
}

//************************************************************
//S scalestab: void function
//R TRUE

INT scalestab(void)
{
    ENTRY(730);
    RETURNV(1);
}

//************************************************************
//S get office name :void function
//R TRUE

INT getoname(void)
{
    ENTRY(740);
//    if (!getoffdet(OFFICE_L  ,G_formvars[G_form.curitem+1])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S set office name : void function
//R TRUE

INT setoname(void)
{
    ENTRY(750);
//    if (!setoffdet(OFFICE_L  ,G_formvars[G_form.curitem])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get office details : void function
//R TRUE

INT getodets(void)
{
    ENTRY(760);
//    if (!getoffdet(OFFICE_N  ,G_formvars[G_form.curitem+1])) RETURNV(0);
//    if (!getoffdet(OFFICE_L  ,G_formvars[G_form.curitem+2])) RETURNV(0);
//    if (!getoffdet(OFFICE_P  ,G_formvars[G_form.curitem+3])) RETURNV(0);
//    if (!getoffdet(OFFICE_LD ,G_formvars[G_form.curitem+4])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S set office details : guess what - void function
//R TRUE

INT setodets(void)
{
    ENTRY(770);
//    if (!setoffdet(OFFICE_N  ,G_formvars[G_form.curitem-3])) RETURNV(0);
//    if (!setoffdet(OFFICE_L  ,G_formvars[G_form.curitem-2])) RETURNV(0);
//    if (!setoffdet(OFFICE_P  ,G_formvars[G_form.curitem-1])) RETURNV(0);
//    if (!setoffdet(OFFICE_LD ,G_formvars[G_form.curitem  ])) RETURNV(0);
//    if (!setoffdet(OFFICE_MON,"0"                         )) RETURNV(0);
//    if (!setoffdet(OFFICE_MIN,"0"                         )) RETURNV(0);
//    if (!setoffdet(COUNTERPOS,"0"                         )) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get counter details - void function
//R TRUE

INT getctdets(void)
{
    ENTRY(780);
//    if (!getoffdet(COUNTERPOS,G_formvars[G_form.curitem+1])) RETURNV(0);
//    if (!getoffdet(OFFICE_MIN,G_formvars[G_form.curitem+2])) RETURNV(0);
//    if (!getoffdet(OFFICE_MON,G_formvars[G_form.curitem+3])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S set counter details : void function
//R TRUE

INT setctdets(void)
{
    ENTRY(790);
//    if (!setoffdet(COUNTERPOS,G_formvars[G_form.curitem-2])) RETURNV(0);
//    if (!setoffdet(OFFICE_MIN,G_formvars[G_form.curitem-1])) RETURNV(0);
//    if (!setoffdet(OFFICE_MON,G_formvars[G_form.curitem  ])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get new disk number
//R TRUE

INT getnewdiskno(void)
{
    LONG l;
    ENTRY(800);
//    if (!getoffdet(OFFICE_LD ,G_formvars[G_form.curitem+1])) RETURNV(0);
    l=atol(G_formvars[G_form.curitem+1]);
    l++;
    sprintf(G_formvars[G_form.curitem+1],"%ld",l);
    if (!sendmsg("DBM",MESSAGE_p,USER_S,DISK,G_formvars[G_form.curitem+1]))    RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S Prepare a new clerk disk 
//R FALSE abandoned TRUE Ok

INT newclerkdisk(void)
{
    INT k;
    UINT did;
    INT i;
    UCHAR u;
    CHAR tmp[LENOFCLERKTEMP];
    ENTRY(810);
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_insertd))/2,16,"%s",G_insertd);
    beep();
    if (sendmsg("INPUT1",MESSAGE_i)==EXIT_K) RETURNV(0);
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_insertd))/2,16,"%*.*s",strlen(G_insertd),strlen(G_insertd),"");
    if (sendmsg("DISK",MESSAGE_G,DISKID,&did))
        {
        sendmsg("OUTPUT1",MESSAGE_A,1);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_olddisk))/2,16,"%s",G_olddisk);
        beep();
        if ((k=(INT)sendmsg("INPUT1",MESSAGE_i))==EXIT_K) RETURNV(0);
        if ((toupper(k)!=G_yes)&&(k!=G_yes)) RETURNV(0);
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_olddisk))/2,16,"%*.*s",strlen(G_olddisk),strlen(G_olddisk),"");
    }
    else {
        sendmsg("OUTPUT1",MESSAGE_A,1);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_newdisk))/2,16,"%s",G_newdisk);
        beep();
        if ((k=(INT)sendmsg("INPUT1",MESSAGE_i))==EXIT_K) RETURNV(0);
        if ((toupper(k)!=G_yes)&&(k!=G_yes)) RETURNV(0);
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_newdisk))/2,16,"%*.*s",strlen(G_newdisk),strlen(G_newdisk),"");
    }
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_format))/2,16,"%s",G_format);

    if (sendmsg("DISK",MESSAGE_F,G_backup))
        {
        sendmsg("DISK",MESSAGE_N);

//        getoffdet(OFFICE_LD,tmp);
        did=(UINT)(atol(tmp)+1L);       // Processing an uninitialized string :JGQ 26/10
        sprintf(tmp,"%ld",did);
//        setoffdet(OFFICE_LD,tmp);
        sendmsg("DISK",MESSAGE_S,DISKID,&did);

        i=atoi(G_formvars[G_form.curitem-1]);
        sendmsg("DISK",MESSAGE_S,ACCESS,&i);

        sendmsg("DISK",MESSAGE_S,PASSWORD,G_formvars[G_form.curitem-2]);

        u=(CHAR)atoi(G_formvars[G_form.curitem-4]);
        sendmsg("DISK",MESSAGE_S,USERID,&u);

        strcpy(tmp,G_formvars[G_form.curitem-3]);
        tmp[8]=0;
        sendmsg("DISK",MESSAGE_S,USERNAME,tmp);

        sendmsg("DISK",MESSAGE_P,1);
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_format))/2,16,"%*.*s",strlen(G_format),strlen(G_format),"");
        sendmsg("OUTPUT1",MESSAGE_A,1);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_formatok))/2,16,"%s %d",G_formatok,u);
        sendmsg("INPUT1",MESSAGE_i);
    }
    else {
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_format))/2,16,"%*.*s",strlen(G_format),strlen(G_format),"");
        sendmsg("OUTPUT1",MESSAGE_A,1);
        sendmsg("OUTPUT1",MESSAGE_o,(80-strlen(G_formatf))/2,16,"%s",G_formatf);
        sendmsg("INPUT1",MESSAGE_i);
    }
    
    RETURNV(1);
}

//************************************************************
//S Format diskette and perform a backup
//R TRUE for OK, FALSE for abended

INT obackup(void)
{
    UINT did;
    CHAR tmp[LENOFOBKUPTMP];

    ENTRY(820);
    if (!sendmsg("DISK",MESSAGE_G,DISKID,&did))
        {
        if (sendmsg("DISK",MESSAGE_F,G_backup))
            {
            sendmsg("DISK",MESSAGE_N);
//          getoffdet(OFFICE_LD,tmp);
            did=(UINT)(atol(tmp)+1L);  // Processing an uninitialized string :JGQ 26/10
            sprintf(tmp,"%ld",did);
//          setoffdet(OFFICE_LD,tmp);
            sendmsg("DISK",MESSAGE_S,DISKID,&did);
            sendmsg("DISK",MESSAGE_P,1);
        }
        else {
            beep();
            RETURNV(0);
        }
    }
    sprintf(tmp,"%s.*",TRAN_S);
    if (!sendmsg("DISK",MESSAGE_C,tmp,G_database,G_backup)) RETURNV(0);
    sendmsg("DISK",MESSAGE_D,tmp,G_database);
    sprintf(tmp,"%s.*",TRAN_S);
    tmp[0]='~';
    sendmsg("DISK",MESSAGE_D,tmp,G_database);
    sendmsg("DBM",MESSAGE_RI);
    RETURNV(1);
}

//************************************************************
//S some sort of list processing - really not at all sure :JGQ
//R reply 

INT exitkcheck(void)
{
    CHAR tmp[LENOFMANDFLD];
    CHAR name[LENOFNAME];
    CHAR val[LENOFAMNT];
    CHAR fixed[LENOFFIXP];
    INT mand=0;
    INT i=0,j,xit=0;
    INT k;
    ENTRY(830);

    getprod(G_prod);
    if (sendmsg("DBM",MESSAGE_g,PROD_S,MAND,tmp)) {
        mand=atoi(tmp);
        if ((mand)&&(mand!=G_prod)) logprod(mand);
    }

    for (j=0;j<G_numeks[G_edepth-1];j++)
        if (G_exitkeys[G_edepth-1][j].key!=0) i++;
    if (i==0) RETURNV(0);

    displog(G_tindex);
//    proptional();
    prdate();
//    sendmsg("INPUT1",MESSAGE_A,9,prdate);
    while (!xit) {
        switch (k=proptional()) {
            case CR :
                xit=1;
                break;
            case ESC :
                voidlog(G_tindex);
                break;
            case F09 :
                modlogval(G_tindex);
                break;
            case EXIT_K :
                removelogt(G_tindex);
                RETURNV(0);
            default :
                for (j=0;j<G_numeks[G_edepth-1];j++) {
                    if ((G_exitkeys[G_edepth-1][j].key==k)
                     && (G_exitkeys[G_edepth-1][j].func[0]!=0)
                     && (G_exitkeys[G_edepth-1][j].access<=G_access) ) {
                        i--;
                        G_exitkeys[G_edepth-1][j].key=0;
                        G_prod=G_exitkeys[G_edepth-1][j].prod;
                        getprod(G_prod);
                        sendmsg("DBM",MESSAGE_g,PROD_S,AMNT,val);
                        if ((atol(val)>G_roundval)||(atol(val)==0L)) G_round=G_roundval; else G_round=0; //ROUND
                        sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name);
                        sendmsg("DBM",MESSAGE_g,PROD_S,FIXP,fixed);
                        G_loglev=G_tindex;
                        if ((strcmp(fixed,"Y"))&&(strcmp(val,"0"))) 
                            strcpy(G_fixed,val);
                        else 
                            G_fixed[0]=0;
                        if (!strcmp(fixed,"Y")) {
                            add2log(name,val," "," "," ");
                            displog(G_tindex);
//                            proptional();
                            G_fixed[0]=0;
                            G_loglev=0;
                            G_prod=0;
                            G_round=0;
                            break;
                        }
                        else {
                            
                            subaction(G_exitkeys[G_edepth-1][j].func,1);
                            G_fixed[0]=0;
                            G_loglev=0;
                            G_prod=0;
                            G_round=0;
                            if (!isaction(G_exitkeys[G_edepth-1][j].func)) 
                                RETURNV(1);
                            displog(G_tindex);
//                            proptional();
                            break;
                        }
                    }
                }
                if (j==10) {
                    beep();
                }
                else {
                    if (i==0) xit=1;
                }
        }
    }
//    sendmsg("INPUT1",MESSAGE_D,256,prdate);
    RETURNV(0);
}

//************************************************************
//S Look back up list (i.e. nearer to zero) for previous non DISP or TEXT item
//D if all the previous items are TEXT or DISP then just go to the next previous
//D anyway and BEEP.  This routine CAN decrement beyond zero.
//R TRUE

INT upfunc(void)                               
{
    INT i=G_form.curitem;
    ENTRY(840);
    do
        {
        i--;
        } while (((G_form.items[i].class==FF_DISP)||(G_form.items[i].class==FF_TEXT))
                    &&       (i>0));

    if ((G_form.items[i].class==FF_DISP)||(G_form.items[i].class==FF_TEXT))
        {   // seems to me this means if i had been reduced to 0 :JGQ
        G_form.curitem--;
        beep();
        }
    else
        {
        G_form.curitem=(CHAR)(i-1);
        }
    RETURNV(1);
    
}

//************************************************************
//S downfunc: void function
//R TRUE

INT downfunc(void)
{
    ENTRY(850);
    RETURNV(1);
}

//************************************************************
//S pushbkey : Push button key into buffer
//R TRUE

INT pushbkey(void)
{
    ENTRY(860);
    sendmsg("INPUT1",MESSAGE_PH,G_keybutt);
    RETURNV(1);
}

//************************************************************
//S Exit form : set exit key to standard exit key and current item to no. of items
//R TRUE

INT exitform(void)
{
    ENTRY(870);
    G_exitkey=EXIT_K;
    G_form.curitem=G_form.numitem;
    RETURNV(-1);
}

//************************************************************
//S End form : don't touch keys, just set current item to no. of items
//R TRUE

INT endform(void)
{
    ENTRY(871);
    G_form.curitem=G_form.numitem;
    RETURNV(-1);
}

//************************************************************
//S exit to top : set exit2top flag TRUE, and current item to no. of items
//R TRUE

INT exit2top(void)
{
    ENTRY(880);
    G_form.curitem=G_form.numitem;
    G_exit2top=1;
    RETURNV(-1);
}

//************************************************************
//S exit to mark : set exit2mrk flag TRUE, and current item to no. of items
//R TRUE

INT exit2mrk(void)
{
    ENTRY(881);
    G_form.curitem=G_form.numitem;
    G_exit2mrk=1;
    RETURNV(-1);
}

//************************************************************
//S mark form : set formmark flag to TRUE
//R TRUE

INT markform(void)
{
    ENTRY(882);
    G_formmark=1;
    RETURNV(1);
}

//************************************************************
//S beep : du da beep
//R TRUE

INT beep(void) 
{
    ENTRY(890);
    sendmsg("OSSDEV",MESSAGE_s,500);
    sendmsg("OSSDEV",MESSAGE_d,200);
    sendmsg("OSSDEV",MESSAGE_s,300);
    sendmsg("OSSDEV",MESSAGE_d,200);
    sendmsg("OSSDEV",MESSAGE_ns);
    RETURNV(1);
}

//************************************************************
//S turn a byte over end to end bit wise
//D i.e. bit 1 becomes bit 8, bit 2 b bit 7, bit 3 b bit 6 etc.
//R 8 bit byte

UCHAR rotbyte(UCHAR b)
{
    UCHAR r=0;
    INT i;
    ENTRY(900);
    for (i=0;i<8;i++)
        if ((b&(0x80>>i))!=0) r|=(CHAR)(1<<i);
    RETURNV(r);
}

//************************************************************
//S demonstration routine to initialise and print to a slip printer
//D doesn't print any real data, LOGO print is commented out for Polish post office :JGQ
//R TRUE Ok, FALSE failed

INT sideslip(void)
{
    INT j;
    ENTRY(910);
    sendmsg("SPRN",MESSAGE_I);
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,2,"%c@",27)) RETURNV(0);
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,4,"%cf%c%c",27,1,1)) RETURNV(0);
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,4,"%cc0%c",27,4)) RETURNV(0);
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,3,"%cV%c",27,1)) RETURNV(0);
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,4,"%c3%c\n",27,32)) RETURNV(0);
    for (j=16;j>=0;j--) {
        if (!sendmsg("OUTPUT2",MESSAGE_o,-2,5,"%c*%c%c%c",27,0,38,0)) RETURNV(0);
//        for (i=0;i<38;i++) {
//            if (!sendmsg("OUTPUT2",MESSAGE_o,-2,1,"%c",G_logo[i][j])) RETURNV(0);
//        }
        if (j==15) if (!sendmsg("OUTPUT2",MESSAGE_o,-1,-1,"   POLISH POST OFFICE")) RETURNV(0);
        if (j==10) if (!sendmsg("OUTPUT2",MESSAGE_o,-1,-1,"      SLIP PRINTING")) RETURNV(0);
        if (j==5) if (!sendmsg("OUTPUT2",MESSAGE_o,-1,-1,"      DEMONSTRATION")) RETURNV(0);
        if (!sendmsg("OUTPUT2",MESSAGE_o,-2,1,"\n")) RETURNV(0);
    }
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,2,"%c\n",12)) RETURNV(0);    // Release paper
    if (!sendmsg("OUTPUT2",MESSAGE_o,-2,2,"%c@",27)) RETURNV(0);
    sendmsg("OUTPUT2",MESSAGE_E);

    RETURNV(1);
}

//************************************************************
//S Print receipt
//R TRUE Ok, FALSE failed e.g. total is zero

INT receipt(void)
{
    INT i,q=0,k=0;
    CHAR tmp[LENOFOFFICEN];
    CHAR val[LENOFOFFICEL];
    ENTRY(920);

    if (strcmp(logtotal(0),"0")) {
        beep();
        RETURNV(0);
    }
    if (G_numt) {
//           getoffdet(OFFICE_N,tmp);
//           getoffdet(OFFICE_L,val);
        sendmsg("RECEIPT",MESSAGE_b,26,G_numt+19);
        sendmsg("RECEIPT",MESSAGE_S,1);
        sendmsg("RECEIPT",MESSAGE_B,0,0,25,6);
        sendmsg("RECEIPT",MESSAGE_o,1,1,G_topline);
        sendmsg("RECEIPT",MESSAGE_o,1,2,"%s",tmp);  // output uninit string :JGQ 26/10
        sendmsg("RECEIPT",MESSAGE_o,1,3,"%s",val);  // output uninit string :JGQ 26/10
        sendmsg("RECEIPT",MESSAGE_o,1,4,"%s %s",G_clerk,G_uname);
        sendmsg("RECEIPT",MESSAGE_o,1,5,datestr(MINDT));

        strcpy(tmp,"0");
        for (i=0;i<G_numt;i++) {
            if ((G_log[i].prod==1)&&(G_log[i-1].prod!=1)) {
                sendmsg("RECEIPT",MESSAGE_o,0 ,8+i,"%-3d",q);
                sendmsg("RECEIPT",MESSAGE_o,3 ,8+i,"%15.15s",G_total);
                sendmsg("RECEIPT",MESSAGE_o,19,8+i,"%s",mstr(tmp,7));
                k=2;
            }
            strcpy(val,rndm(mulm(G_log[i].val,G_log[i].qty),G_log[i].round));
            sendmsg("RECEIPT",MESSAGE_o,0 ,7+i+k,"%-3d",G_log[i].qty);
            sendmsg("RECEIPT",MESSAGE_o,3 ,7+i+k,"%15.15s",G_log[i].desc);
            sendmsg("RECEIPT",MESSAGE_o,19,7+i+k,"%s",mstr(val,7));
            strcpy(tmp,addm(tmp,val));
            if (G_log[i].prod!=1) q+=G_log[i].qty;
        }
        sendmsg("RECEIPT",MESSAGE_B,0,7+i+k,25,9+i+k);
        sendmsg("RECEIPT",MESSAGE_o,1+(24-strlen(G_thankyou))/2,8+i+k,G_thankyou);
        sendmsg("RECEIPT",MESSAGE_F);
    }
    RETURNV(1);
}


//************************************************************
//S prodlist : Can't work out exactly whst this input function does :JGQ
//R TRUE

INT prodlist(void)
{
    INT xit=0,i=0;
    CHAR buffer[LENOFINPUTBUF];
    INT k,nt;
    INT tft=G_form.type;
    G_innext=1;
    ENTRY(930);
    buffer[0]=0;
    prdate();
//    sendmsg("INPUT1",MESSAGE_A,9,prdate);
    while (!xit)
        {
        nt=G_numt;
        if ((i==0)&&(!G_numt))
            {
            sendmsg("OUTPUT1",MESSAGE_0);
            }
        else
            {
            sendmsg("OUTPUT1",MESSAGE_1);
            }
        switch (k=(INT)sendmsg("INPUT1",MESSAGE_i))
            {
            case ESC :
                voidlog(0);
                sendmsg("INPUT1",MESSAGE_e);
                break;

            case ENDCUST :
                if (!strcmp(logtotal(0),"0"))
                    {
                    runaction("PRENDCUS");
                    runaction("ENDCUST");
                    runaction("AFENDCUS");
                    }
                else
                    {
                    G_form.type=0;
                    sendmsg("OUTPUT1",MESSAGE_A,1);
                    sendmsg("OUTPUT1",MESSAGE_S,3);
                    sendmsg("OUTPUT1",MESSAGE_o,G_tarea[0]+1,G_tarea[1]+1,"%s",G_moneys);
                    output(G_tarea[0]+6,G_tarea[1]+1,logtotal(0),15,"M",3,0);
                    sendmsg("OUTPUT1",MESSAGE_A,0);
                    G_form.type=(CHAR)tft;
                    beep();
                    }
                sendmsg("INPUT1",MESSAGE_e);
                break;

            case MODIFY :
                modlogval(0);
                sendmsg("INPUT1",MESSAGE_e);
                break;

            case PRINT :
                if (!receipt()) beep();
                sendmsg("INPUT1",MESSAGE_e);
                break;

            case EXIT_K :
                removelogt(0);
                G_exitkey=EXIT_K;
                xit=1;
                sendmsg("INPUT1",MESSAGE_e);
                sendmsg("OUTPUT1",MESSAGE_0);
                break;

            case BKSP :
                if (i>0) {
                    buffer[--i]=0;
                    output(90,0,buffer,38,"9",1,0);
                }
                else {
                    beep();
                }
                break;
            case LANGSWITCH :
                break;
            default :
                if (chkfmt('9',k)) {
                    if (i<4) {
                        buffer[i++]=(CHAR)k;
                        buffer[i]=0;
                        output(90,0,buffer,38,"9",1,0);
                    }
                    else {
                        beep();
                    }
                }
                else {
                    G_qnty=atoi(buffer);
                    if (G_qnty==0) G_qnty=1;
                    sendmsg("INPUT1",MESSAGE_r,k);
                    if (getaction(0,k)) {
                        G_edepth=i=0;
                        buffer[i]=0;
                        G_qnty=0;
                        G_prod=-1;
                        if (G_numt<(NUMLOGENT)) G_tindex++;
                        displog(0);
                        nt=G_numt;
                    }
                    else {
                        sendmsg("INPUT1",MESSAGE_e);
                        beep();
                    }
                }
        }
        
        if (nt!=G_numt) displog(0);
    }
//    sendmsg("INPUT1",MESSAGE_D,prdate);
    G_innext=0;
    RETURNV(1);
}

//************************************************************
//S Build product transaction log details, add to log and display
//R TRUE Ok, FALSE failed to get product G_prod

INT logtransact(void)
{
    CHAR a[3][LENOFADF];
    CHAR val[LENOFAMNT];
    CHAR name[LENOFNAME2];
    ENTRY(940);

    if (!getprod(G_prod)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,AMNT,val)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF1,a[0])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF2,a[1])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF3,a[2])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name)) RETURNV(0);
    add2log(name,val,a[0],a[1],a[2]);
    displog(G_tindex);
    RETURNV(1);
}

//************************************************************
//S end customer - write transaction, close DBM, clear log
//R TRUE

INT endcust(void)
{
    ENTRY(941);
    writetrans();
    sendmsg("DBM",MESSAGE_f);
    removelogt(0);
    RETURNV(1);
}

//************************************************************
//S Build product transaction log details, add to log and display
//D identical to logtransact(void) because of commented out lines :JGQ
//R TRUE Ok, FALSE failed to get product G_prod

INT putcurinlog(void)
{
    CHAR name[LENOFNAME2];
    CHAR a[6][LENOFADF];
    ENTRY(950);

    if (!getprod(G_prod)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF1,a[0])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF2,a[1])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF3,a[2])) RETURNV(0);
//    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF4,a[3])) RETURNV(0);
//    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF5,a[4])) RETURNV(0);
//    if (!sendmsg("DBM",MESSAGE_g,TRAN_S,ADF6,a[5])) RETURNV(0);
    add2log(name,G_formvars[G_form.curitem],a[0],a[1],a[2]);
    displog(G_tindex);
    RETURNV(1);
}

//************************************************************
//S output only if log total is negative.  Also write to log
//R TRUE if all was OK, or log total was +ive

INT cchange(void)
{
    CHAR name[LENOFNAME2];
    CHAR tmp[LENOFLOGTOTAL];
    ENTRY(960);

    strcpy(tmp,logtotal(0));
    if (tmp[0]!='-') RETURNV(1);

    if (!getprod(G_prod)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name)) RETURNV(0);
    G_prod=1;
    // Why should anyone want to output to 81,0?? :JGQ
    //  CHECK THIS DOES NOT CAUSE PROBLEMS 
                output(81,0,subm("0",logtotal(0)),15,"M",1,0);
    //  CHECK THIS DOES NOT CAUSE PROBLEMS 
    add2log(name,subm("0",logtotal(0))," "," "," ");
    displog(0);
    while (!sendmsg("INPUT1",MESSAGE_H));
    RETURNV(1);
}

//************************************************************
//S negate current value then add it to the log
//R TRUE - OK, FALSE failed

INT addmop(void)
{
    CHAR name[LENOFNAME2];
    CHAR tmp[LENOFADDMOPTMP];
    ENTRY(970);

    if (!getprod(G_prod)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name)) RETURNV(0);
    strcpy(tmp,"0");
    strcpy(tmp,subm(tmp,G_formvars[G_form.curitem]));
    add2log(name,tmp," "," "," ");
    displog(0);
    RETURNV(1);
}

//************************************************************
//S set the next item to be the previous item minus the current item
//R TRUE

INT sublast2(void)
{
    ENTRY(980);
    strcpy(G_formvars[G_form.curitem+1],subm(G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]));
    RETURNV(1);
}

//************************************************************
//S set the next item to be the total of the current item and the previous item
//R TRUE

INT addlast2(void)
{
    ENTRY(990);
    strcpy(G_formvars[G_form.curitem+1],addm(G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]));
    RETURNV(1);
}

//************************************************************
//S specifically set current item to be name of product and c+2 to be logtotal
//R TRUE=Ok, FALSE = failed

INT domop(void)
{
    CHAR name[LENOFNAME2];
    ENTRY(1000);

    if (!getprod(G_prod)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name)) RETURNV(0);
    strcpy(G_formvars[G_form.curitem],name);
    strcpy(G_formvars[G_form.curitem+2],logtotal(0));
    displog(0);
    RETURNV(1);
}

//************************************************************
//S convert 8bit byte integer value to 4bit+4bit bcd
//D n.b. no range check
//P 8 bit value to convert
//R 8bit bcd reply

UCHAR bcd(UCHAR a)
{
    ENTRY(1001);
    RETURNV((CHAR)(((a/10)<<4)|(a%10)));
}

//************************************************************
//S write byte to cmos in bcd format
//P U char port address
//P 8bit integer value to be bcd'd and output

void putcm(UCHAR pcportaddress,UCHAR databyte)
{
    sendmsg("OSSDEV",MESSAGE_pc,pcportaddress,bcd(databyte));
}

//************************************************************
//S Set system date using int21 and then sets cmos &7,&8,&9
//R TRUE completed, FALSE failed

INT setsdate(void)
{
    CHAR tmp[LENOFDATESTR2];
    INT day=0,mnth=0,year=0,dt,numdays;
    LONG r;
    ENTRY(1010);

    dt=G_datetype;

    numdays=0-datetonum(G_formvars[G_form.curitem]);

    G_datetype=GREGORIAN;

    strcpy(tmp,datestr(numdays));

    day =getday(tmp);
    mnth=getmon(tmp);
    year=getyear(tmp);
    orddfrom(&year,&mnth,&day);

    G_datetype=dt;
    if (year<92) year+=100;
    r=sendmsg("OSSDEV",MESSAGE_21,0x2B00,0,year+1900,(INT)((mnth<<8)|day));
    if (r!=0) {
        G_form.curitem--;
        beep();
        RETURNV(0);
    }
    putcm(7,(UCHAR)day);
    putcm(8,(UCHAR)mnth);
    putcm(9,(UCHAR)year);

    RETURNV(1);
}

//************************************************************
//S Set system time using int21 and then poking into cmos &0,&2,&4
//R TRUE Ok, FALSE failed

INT setstime(void)
{
    LONG r;
    INT sec=0;
    INT min=0;
    INT hour=0;
    ENTRY(1020);

    sscanf(datestr(MINTIME),"%2d%2d%2d",&hour,&min,&sec);
    sscanf(G_formvars[G_form.curitem],"%2d%2d%2d",&hour,&min,&sec);
    r=sendmsg("OSSDEV",MESSAGE_21,0x2D00,0,(INT)((hour<<8)|min),(INT)(sec<<8));
    if (r!=0) {
        G_form.curitem--;
        beep();
        RETURNV(0);
    }
    putcm(0,(UCHAR)sec);
    putcm(2,(UCHAR)min);
    putcm(4,(UCHAR)hour);
    RETURNV(1);
}

//************************************************************
//S Copy specified file[s] to backup drive
//P char string filename NO EXTENSION and first char gets set to tilda
//R TRUE Ok, FALSE failed

INT backoff(CHAR *name)
{
    CHAR s[LENOFFILESPEC];
    ENTRY(1030);
    sprintf(s,"%s.*",name);
    s[0]='~';
    if (!sendmsg("DISK",MESSAGE_C,s,G_database,G_backup)) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S Copy specified file[s] FROM backup drive then reinit database
//P char string filename NO EXTENSION and first char gets set to tilda
//R TRUE Ok, FALSE failed

INT backon(CHAR *name)
{
    CHAR s[LENOFFILESPEC];
    ENTRY(1040);
    sprintf(s,"%s.*",name);
    s[0]='~';
    if (!sendmsg("DISK",MESSAGE_C,s,G_backup,G_database)) RETURNV(0);
    sendmsg("DBM",MESSAGE_RI);
    RETURNV(1);
}

//************************************************************
//S I think this function logs the user off incl disk settings. I'm not sure :JGQ
//R FALSE failed or escaped, TRUE completed

INT logoff(void)
{
    CHAR tmp[LENOFLOGOFFTMP];
    CHAR userid[LENOFUID];
    INT k;
    UCHAR u;
    ENTRY(1050);

    do {
        sendmsg("DISK",MESSAGE_G,USERID,&u);
        if (u!=G_uid) {
            sprintf(tmp,"%s %02d",G_harderr,G_uid);
            sendmsg("OUTPUT1",MESSAGE_A,1);
            sendmsg("OUTPUT1",MESSAGE_S,3);
            beep();
            sendmsg("OUTPUT1",MESSAGE_o,40-strlen(tmp),4,tmp);
            k=(INT)sendmsg("INPUT1",MESSAGE_i);
            sendmsg("OUTPUT1",MESSAGE_A,0);
            sendmsg("OUTPUT1",MESSAGE_o,40-strlen(tmp),4,"%*.*s",strlen(tmp),strlen(tmp),"");
            sendmsg("OUTPUT1",MESSAGE_S,1);
            if (k==EXIT_K) RETURNV(0);
        }        
    } while (u!=G_uid);
    
    sprintf(userid,"%d",G_uid);

    sprintf(tmp,"%s.*",TRAN_S);
    if (sendmsg("DISK",MESSAGE_U,G_database,tmp,2)) {
        backoff(TRAN_S);
    }

    if (!sendmsg("DBM",MESSAGE_p,STOK_S,USID,userid)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_d,STOK_S,USID,FRST)) RETURNV(0);
    if (!backoff(STOK_S)) {
        if (!sendmsg("DBM",MESSAGE_rd,STOK_S,0)) RETURNV(0);
        RETURNV(0);
    }
    if (!sendmsg("DBM",MESSAGE_rd,STOK_S,0)) RETURNV(0);
    u=1;
    sendmsg("DISK",MESSAGE_S,BACKEDUP,&u);
    u=0;
    sendmsg("DISK",MESSAGE_S,CONSOLID,&u);
    sendmsg("DISK",MESSAGE_S,POSITION,&u);

    sendmsg("DISK",MESSAGE_P);

    if (!sendmsg("DBM",MESSAGE_p,STOK_S,USID,userid)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_dg,STOK_S,USID,FRST)) RETURNV(0);

    G_form.curitem=G_form.numitem;
    G_exitkey=EXIT_K;

    RETURNV(1);
}

//--------------------------------------------------------------------------
//                      PRIVATE FUNCTIONS
//--------------------------------------------------------------------------

//************************************************************
//S Lookup product given the code
//P integer product code
//R TRUE OK, FALSE failed

INT getprod(INT prodcode)
{
    CHAR tmp[LENOFPROD2];
    ENTRY(1060);
    sprintf(tmp,"%d",prodcode);

    if (!sendmsg("DBM",MESSAGE_p,PROD_S,CODE,tmp)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_s,PROD_S,NULL,1)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)CURR)) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get product name with language control? Not entirely sure :JGQ
//R TRUE OK, FALSE failed

INT getplname(void)
{
    CHAR tmp[LENOFLANGID];
    ENTRY(1070);
    sprintf(tmp,"%d",G_lang);
    if (!sendmsg("DBM",MESSAGE_p,"prodname",CODE,G_formvars[G_form.curitem])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_p,"prodname","language",tmp)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_sp,"prodname",2,FRST)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_r,"prodname",(LONG)CURR)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,"prodname",NAME,G_formvars[G_form.curitem])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get product name without language control? Not entirely sure :JGQ
//R TRUE OK, FALSE failed

INT getpname(void)
{
    ENTRY(1080);
    if (!sendmsg("DBM",MESSAGE_p,PROD_S,CODE,G_formvars[G_form.curitem])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_s,PROD_S,NULL,1)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)CURR)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,G_formvars[G_form.curitem])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get user name
//R TRUE OK, FALSE failed

INT getuname(void)
{
    ENTRY(1090);
    if (!sendmsg("DBM",MESSAGE_p,USER_S,USID,G_formvars[G_form.curitem])) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_s,USER_S,NULL,1)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_r,USER_S,(LONG)CURR)) RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,USER_S,UNAM,G_formvars[G_form.curitem])) RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S I reckon this gets userid and password and stores em in transact and user files
//R TRUE OK, FALSE failed

INT consolidd(void)
{
    CHAR tmp[LENOFFILESPEC2];
    CHAR userid[LENOFUID];
    UCHAR u;
    ENTRY(1100);

    sendmsg("DISK",MESSAGE_G,USERID,&u);    // Get disk info
    sprintf(userid,"%d",u);
    sendmsg("DISK",MESSAGE_G,BACKEDUP,&u);  // Get disk info
    if (u)
        {
        if (!sendmsg("DBM",MESSAGE_p,TRAN_S,USID,"99")) // put user id by name into transact
            RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_d,TRAN_S,NULL,1))    // duplicate transact
            RETURNV(0);
        if (!backon(TRAN_S))        // restore files
            {
            if (!sendmsg("DBM",MESSAGE_rd,TRAN_S,0))    // remove duplicate - no keep
                RETURNV(0);
            RETURNV(0);
            }
        if (!sendmsg("DBM",MESSAGE_rd,TRAN_S,1))    // remove duplicate with keep
            RETURNV(0);
        u=1;
        sendmsg("DISK",MESSAGE_S,CONSOLID,&u);  // Set disk info
        sendmsg("DISK",MESSAGE_P);              // Put disk info
        sprintf(tmp,"%s.*",TRAN_S);
        tmp[0]='~';
        sendmsg("DISK",MESSAGE_D,tmp,G_backup); // Delete temp datastore
        sendmsg("DISK",MESSAGE_G,USERID,&u);    // Get disk info
        sprintf(tmp,"%d",u);
        sendmsg("DBM",MESSAGE_p,USER_S,USID,tmp);   // put user id into user
        if (!sendmsg("DBM",MESSAGE_sp,USER_S,1,FRST))   // search table 
            RETURNV(0);
        sendmsg("DBM",MESSAGE_r,USER_S,(LONG)CURR); // read record
        sendmsg("DISK",MESSAGE_G,PASSWORD,tmp);     // Get disk info
        sendmsg("DBM",MESSAGE_p,USER_S,PASS,tmp);   // put field
        sendmsg("DBM",MESSAGE_w,USER_S);            // update record
        }
    else
        {
        sendmsg("DISK",MESSAGE_G,POSITION,&u);      // Get disk info
        if (u!=G_position)
            {
            if (u!=0)
                {
                errorline(G_posierr,1);
                RETURNV(0);
                }
            }
        }
    RETURNV(1);
}

//************************************************************
//S work out user details - generates them if necessary
//R TRUE Ok, FALSE failed

INT userdetails(void)
{
    CHAR tmp[LENOFFUSERDETAILS];
    UCHAR u;
    ENTRY(1110);

    if (!G_keydisk) // if we're not using keydisk facility
        {
        sendmsg("DBM",MESSAGE_p,USER_S,USID,G_formvars[G_form.curitem]);
        if (!sendmsg("DBM",MESSAGE_sp,USER_S,1,FRST))
            {
            beep();
            G_form.curitem--;
            RETURNV(0);
            }
        sendmsg("DBM",MESSAGE_r,USER_S,(LONG)CURR);
        sendmsg("DBM",MESSAGE_g,USER_S,UNAM,G_formvars[G_form.curitem+1]);
        }
    else
        {
        sprintf(tmp,"%s.*",TRAN_S);
        if ((G_uid==99)&&(sendmsg("DISK",MESSAGE_T,G_database,tmp)))
            {   // if userid is 99 and transact files are there determine user id from that
            sendmsg("DBM",MESSAGE_r,TRAN_S,(LONG)FRST);
            sendmsg("DBM",MESSAGE_g,TRAN_S,USID,tmp);
            G_uid=(CHAR)atoi(tmp);          // So why not use a second variable then? :JGQ
            sprintf(tmp,"%s.*",TRAN_S);
            }
        sendmsg("DBM",MESSAGE_RI);      // reinit dbm based on new user id?

        if (G_uid!=atoi(G_formvars[G_form.curitem]))  // if desired userid is not the current one?
            {   // if user id is non zero and transact files are there
            if (sendmsg("DISK",MESSAGE_T,G_database,tmp)&&(G_uid!=0))
                sendmsg("DISK",MESSAGE_U,G_database,tmp,0); // generate user files
            if (G_uid==0)                           // userid zero delete transact files
                sendmsg("DISK",MESSAGE_D,tmp,G_database);
            }
        G_uid=(CHAR)atoi(G_formvars[G_form.curitem]);
        sendmsg("DISK",MESSAGE_G,USERID,&u);
        if (u!=G_uid)
            {
            G_uid=99;
            errorline(G_harderr,1);
            G_form.curitem--;
            RETURNV(0);
        }
        if (!sendmsg("DISK",MESSAGE_T,G_database,tmp))
            sendmsg("DISK",MESSAGE_U,G_database,tmp,1); // generate user files if transact files not there
        if (!sendmsg("DISK",MESSAGE_T,G_database,tmp))
            sendmsg("DBM",MESSAGE_O,TRAN_S);

        sendmsg("DISK",MESSAGE_G,USERNAME,G_formvars[G_form.curitem+1]);
    }
    RETURNV(1);    
}

//************************************************************
//S Seriously convoluted ...... seems to get and check passwords the world over
//D and has LAN sendmsg not commented out
//D copies lots of files
//R TRUE Ok, FALSE failed

INT checkpass(void)
{
    CHAR tmp[LENOFCHKPASSTMP];
    INT mode;
    CHAR userid[LENOFUID];
    UCHAR u;
    INT flash=0;
    INT ret;
    ENTRY(1120);

    if (!G_keydisk)
        {   // put cur item -2 (user id)
        sendmsg("DBM",MESSAGE_p,USER_S,USID,G_formvars[G_form.curitem-2]);
        if (!sendmsg("DBM",MESSAGE_sp,USER_S,1,FRST))   // search for it
            {
            beep();
            G_form.curitem--;
            RETURNV(0);
            }
        sendmsg("DBM",MESSAGE_r,USER_S,(LONG)CURR); // read record 
        sendmsg("DBM",MESSAGE_g,USER_S,PASS,tmp);   // get password
        if (strcmp(tmp,G_formvars[G_form.curitem])) // compare with keyed password
            {
            errorline(G_nopass,1);
            G_form.curitem--;
            RETURNV(0);
            }
        ret=1;
        if (!sendmsg("DBM",MESSAGE_g,USER_S,USID,tmp))
            ret=0;
        sendmsg("LAN",MESSAGE_L,tmp);
        G_uid=(CHAR)atoi(tmp);
        if (!sendmsg("DBM",MESSAGE_g,USER_S,PRIV,tmp))
            ret=0;
        G_access=(CHAR)atoi(tmp);
        if (!sendmsg("DBM",MESSAGE_g,USER_S,PASS,G_upass))
            ret=0;
        if (!sendmsg("DBM",MESSAGE_g,USER_S,UNAM,tmp))
            ret=0;
        tmp[8]=0;
        strcpy(G_uname,tmp);
        RETURNV(ret);
        }   // end of no keydisk version
    G_uid=(CHAR)atoi(G_formvars[G_form.curitem-2]);
    sendmsg("DISK",MESSAGE_G,USERID,&u);
    if (u!=G_uid)
        {
        errorline(G_harderr,1);
        G_form.curitem--;
        RETURNV(0);
        }
    sendmsg("DISK",MESSAGE_G,PASSWORD,tmp);
    if (strcmp(tmp,G_formvars[G_form.curitem]))
        {
        errorline(G_nopass,1);
        G_form.curitem--;
        RETURNV(0);
        }
    sendmsg("DISK",MESSAGE_G,USERID,&G_uid);
    sendmsg("DISK",MESSAGE_G,ACCESS,&G_access);
    sendmsg("DISK",MESSAGE_G,PASSWORD,G_upass);
    sendmsg("DISK",MESSAGE_G,USERNAME,G_uname);
    sprintf(userid,"%d",G_uid);
    sendmsg("DISK",MESSAGE_G,POSITION,&u);
    if (u!=G_position)
        {
        if (u==0)
            {
            u=G_position;
            sendmsg("DISK",MESSAGE_S,POSITION,&u);
            sendmsg("DISK",MESSAGE_P);
            }
        else
            {
            errorline(G_posierr,1);
            G_form.curitem--;
            RETURNV(0);
            }
        }
    sendmsg("LAN",MESSAGE_L,userid);
    sendmsg("DISK",MESSAGE_G,BACKEDUP,&u);
    if (u)
        {
        sprintf(tmp,"%s.*",TRAN_S);
        tmp[0]='~';
        if (sendmsg("DISK",MESSAGE_T,G_backup,tmp))
            {
            if (!sendmsg("DBM",MESSAGE_p,TRAN_S,USID,"99"))
                RETURNV(0);
            if (!sendmsg("DBM",MESSAGE_d,TRAN_S,NULL,1))
                RETURNV(0);
            if (!backon(TRAN_S))
                {
                if (!sendmsg("DBM",MESSAGE_rd,TRAN_S,0))
                    RETURNV(0);
                }
            else
                {
                if (!sendmsg("DBM",MESSAGE_rd,TRAN_S,1))
                    RETURNV(0);
                }
        }

        if (!sendmsg("DBM",MESSAGE_p,STOK_S,USID,userid)) RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_d,STOK_S,USID,FRST)) RETURNV(0);
        if (!backon(STOK_S)) {
            if (!sendmsg("DBM",MESSAGE_rd,STOK_S,0)) RETURNV(0);
        }
        else {
            if (!sendmsg("DBM",MESSAGE_rd,STOK_S,1)) RETURNV(0);
        }
        u=0;
        sendmsg("DISK",MESSAGE_S,BACKEDUP,&u);
        sendmsg("DISK",MESSAGE_P);
    }
    mode=FRST;
    sprintf(tmp,"%d",G_uid);
    while (sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)mode)) {
        sendmsg("DBM",MESSAGE_g,PROD_S,CODE,tmp);
        sendmsg("DBM",MESSAGE_p,STOK_S,USID,userid);
        sendmsg("DBM",MESSAGE_p,STOK_S,CODE,tmp);
        if (!sendmsg("DBM",MESSAGE_s,STOK_S,NULL,2)) {
            sendmsg("DBM",MESSAGE_p,STOK_S,QNTY,"0");
            sendmsg("DBM",MESSAGE_p,STOK_S,AMNT,"0");
            sendmsg("DBM",MESSAGE_w,STOK_S);
        }
        mode=NEXT;
    }
    sendmsg("DISK",MESSAGE_G,NEWDAT,&u);
    if (u)
        {
        if (sendmsg("DISK",MESSAGE_d,G_database,G_backup,NEWDATF))
            {
            sprintf(tmp,"%s.*",PROD_S);
            sendmsg("DISK",MESSAGE_C,tmp,G_backup,G_database);
            sendmsg("DISK",MESSAGE_C,ACC_FILE".*",G_backup,G_database);
            sendmsg("DISK",MESSAGE_C,CUS_FILE".*",G_backup,G_database);
            sendmsg("DISK",MESSAGE_C,PKA_FILE".*",G_backup,G_database);
            sendmsg("DISK",MESSAGE_C,PKC_FILE".*",G_backup,G_database);
            sendmsg("DISK",MESSAGE_C,NEWDATF,G_backup,G_database);
            sendmsg("DBM",MESSAGE_RI);
            flash=1;
        }
    }
    sendmsg("DISK",MESSAGE_G,NEWSYS,&u);
    if (u) {
        if (!sendmsg("DISK",MESSAGE_C,NEWSYSF,G_backup,G_config))
            RETURNV(0);
        sprintf(tmp,"%s?.DAT",G_system);
        if (!sendmsg("DISK",MESSAGE_C,tmp,G_backup,G_config))
            RETURNV(0);
        sprintf(tmp,"%s?.IDX",G_system);
        if (!sendmsg("DISK",MESSAGE_C,tmp,G_backup,G_config))
            RETURNV(0);
        G_exit=1;
        flash=1;
    }
    sendmsg("DISK",MESSAGE_G,NEWCFG,&u);
    if (u) {
        if (!sendmsg("DISK",MESSAGE_C,NEWCFGF,G_backup,G_config))
            RETURNV(0);
        if (!sendmsg("DISK",MESSAGE_C,POLKBD_FILE, G_backup,CURRENT_DIR))
            RETURNV(0);
        if (!sendmsg("DISK",MESSAGE_C,POLFNT_FILE , G_backup,CURRENT_DIR))
            RETURNV(0);
        if (!sendmsg("DISK",MESSAGE_C,GPACFG_FILE , G_backup, CURRENT_DIR))
            RETURNV(0);
        G_exit=1;
        flash=1;
    }
    sendmsg("DISK",MESSAGE_G,NEWOFF,&u);
    if (u)
        {
        if (!sendmsg("DISK", MESSAGE_C, NEWOFFF, G_backup, G_config))
            RETURNV(0);
        if (!sendmsg("DISK", MESSAGE_C, GPAOFF_FILE, G_backup, CURRENT_DIR))
            RETURNV(0);
        flash=1;
        }
    if (flash) errorline(G_newdata,1);
    RETURNV(1);
}

//************************************************************
//S install new config files - very specific names
//R FALSE - failed, TRUE Ok

INT setnewcfg(void)
{
    UCHAR u;
    ENTRY(1130);

    sendmsg("DISK",MESSAGE_R);
    if (!sendmsg("DISK", MESSAGE_C, POLKBD_FILE, CURRENT_CLK, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, POLFNT_FILE, CURRENT_DIR, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, GPACFG_FILE, CURRENT_CLK, G_backup))
        RETURNV(0);
    u=1;
    if (!sendmsg("DISK", MESSAGE_S, NEWCFG, &u))
        RETURNV(0);
    sendmsg("DISK", MESSAGE_P);
    errorline(G_newdata,1);
    RETURNV(1);
}

//************************************************************
//S install new GPA.OFF file
//R TRUE Ok, FALSE failed

INT setnewoff(void)
{
    UCHAR u;
    ENTRY(1140);

    sendmsg("DISK",MESSAGE_R);
    if (!sendmsg("DISK", MESSAGE_C, GPAOFF_FILE, CURRENT_DIR, G_backup))
        RETURNV(0);
    u=1;
    if (!sendmsg("DISK", MESSAGE_S, NEWOFF, &u))
        RETURNV(0);
    sendmsg("DISK",MESSAGE_P);
    errorline(G_newdata,1);
    RETURNV(1);
}

//************************************************************
//S set clerks files
//R TRUE Ok, FALSE failed

INT setnewsys(void)
{
    UCHAR u;
    ENTRY(1150);

    sendmsg("DISK",MESSAGE_R);
    if (!sendmsg("DISK", MESSAGE_C, CLERKS_DAT, CURRENT_CLK, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, CLERKS_IDX, CURRENT_CLK, G_backup))
        RETURNV(0);
    u=1;
    if (!sendmsg("DISK",MESSAGE_S,NEWSYS,&u)) RETURNV(0);
    sendmsg("DISK",MESSAGE_P);
    errorline(G_newdata,1);
    RETURNV(1);
}

//************************************************************
//S New database files
//R TRUE Ok, FALSE failed

INT setnewdbm(void)
{
    CHAR tmp[LENOFFILESPEC2];
    UCHAR u;
    ENTRY(1160);

    sendmsg("DISK",MESSAGE_R);
    sprintf(tmp,"%s.*",PROD_S);
    if (!sendmsg("DISK",MESSAGE_C,tmp,G_database,G_backup))
        RETURNV(0);
    sprintf(tmp,"%s.*",USER_S);
    if (!sendmsg("DISK",MESSAGE_C,tmp,G_database,G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, ACC_FILE".*", G_database, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, PKA_FILE".*", G_database, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, PKC_FILE".*", G_database, G_backup))
        RETURNV(0);
    if (!sendmsg("DISK", MESSAGE_C, CUS_FILE".*", G_database, G_backup))
        RETURNV(0);
    u=1;
    if (!sendmsg("DISK",MESSAGE_S,NEWDAT,&u)) RETURNV(0);
    sendmsg("DISK",MESSAGE_P);
    errorline(G_newdata,1);
    RETURNV(1);
}

//************************************************************
//S Get user details from disk and put into form
//R TRUE Ok, FALSE failed

INT getuserdet(void)
{
    UCHAR u;
    ENTRY(1170);
    sendmsg("DISK",MESSAGE_G,USERID,&u);
    if (u!=G_uid) {
        errorline(G_harderr,1);
        G_form.curitem--;
        RETURNV(0);
    }
    sprintf(G_formvars[G_form.curitem+1],"%d",G_uid);
    strcpy(G_formvars[G_form.curitem+2],G_uname);
    sprintf(G_formvars[G_form.curitem+3],"%d",G_access);
    strcpy(G_formvars[G_form.curitem+4],G_upass);
    RETURNV(1);
}

//************************************************************
//S Check for password match
//R TRUE - matches, FALSE didn't match

INT checkpequal(void)
{
    ENTRY(1180);
    if (strcmp(G_upass,G_formvars[G_form.curitem]))
        {
        errorline(G_nopass,1);
        G_form.curitem--;
        RETURNV(0);
        }
    RETURNV(1);
}

//************************************************************
//S Put password to disk
//R TRUE Ok, FALSE failed (user id doesn't match)

INT setpassword(void)
{
    UCHAR u;
    ENTRY(1190);

    strcpy(G_upass,G_formvars[G_form.curitem]);
    sendmsg("DISK",MESSAGE_G,USERID,&u);
    if (u!=G_uid) {
        errorline(G_harderr,1);
        G_form.curitem--;
        RETURNV(0);
    }
    sendmsg("DISK",MESSAGE_S,PASSWORD,G_upass);
    sendmsg("DISK",MESSAGE_P);
    RETURNV(1);
}

//************************************************************
//S lookup user in table
//R FALSE - failed, TRUE Ok

INT getuser(void)
{
    CHAR tmp[LENOFUID2];
    ENTRY(1200);
    sprintf(tmp,"%d",G_uid);
    if (!sendmsg("DBM",MESSAGE_p,USER_S,USID,tmp))  // put field for search
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_s,USER_S,NULL,1))    // Search table
        {
        exitform();
        RETURNV(0);
    }
    RETURNV(1);
}

//************************************************************
//S clear exitkeys set for current exit depth
//R FALSE

INT cleanup(void)
{
    ENTRY(1210);
    if (G_exitkeys[G_edepth]!=NULL)
        FREE(G_exitkeys[G_edepth]);
    G_exitkeys[G_edepth]=NULL;
    RETURNV(0);
}

//************************************************************
//S set up action
//P integer product code
//R TRUE Ok, FALSE failed

INT setupaction(INT prod)
{
    CHAR tmp[LENOFSETUPATEMP];
    CHAR act[LENOFACTION];
    INT i,j,k;
    INT err;                         // setupaction success (0) or fail (1)
    INT *p;
#ifdef WIEN
    INT klemens;
#endif
    ENTRY(1220);

    if (G_edepth>4)
        RETURNV(0);            // THIS SHOULD BE A 3? :JGQ
    
    if (!getprod(prod))
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,ACTI,act))
        RETURNV(0);
    if (act[0]==0)
        RETURNV(0);
#ifdef WIEN
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,CODE,tmp))
        RETURNV(0);
    klemens=atoi(tmp);
#endif

    if (!sendmsg("DBM",MESSAGE_g,PROD_S,FKEY,tmp))
        RETURNV(0);
    k=atoi(tmp);
    i=(INT)sendmsg("DBM",MESSAGE_nr,PROD_S);
    if (i<1)
        RETURNV(0);
    p=MALLOC(i*sizeof(INT));

    i=0;
    j=FRST;
#ifdef WIEN
    if(((klemens>=6000)&&(klemens<=6999))||(klemens==2071))  {
#endif
        while (sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)j)) {
            sendmsg("DBM",MESSAGE_g,PROD_S,PKEY,tmp);
            if (k==atoi(tmp)) {
                sendmsg("DBM",MESSAGE_g,PROD_S,CODE,tmp);
                p[i]=atoi(tmp);
                i++;
            }
            j=NEXT;
        }
#ifdef WIEN
    }
    else {
        i=0;
    }
#endif

    G_numeks[G_edepth]=i;
    if (i!=0) {
        if (G_exitkeys[G_edepth]!=NULL) FREE(G_exitkeys[G_edepth]);
        G_exitkeys[G_edepth]=MALLOC(i*sizeof(KEYDEF));
        err=0;
        for (j=0;j<i;j++) {
            getprod(p[j]);
            if (!sendmsg("DBM",MESSAGE_g,PROD_S,CODE,tmp)) err=1;
            G_exitkeys[G_edepth][j].prod=atoi(tmp);
            if (!sendmsg("DBM",MESSAGE_g,PROD_S,FKEY,tmp)) err=1; 
            G_exitkeys[G_edepth][j].key=atoi(tmp);
            if (!sendmsg("DBM",MESSAGE_g,PROD_S,PRIV,tmp)) err=1; 
            G_exitkeys[G_edepth][j].access=atoi(tmp);
            if (!sendmsg("DBM",MESSAGE_g,PROD_S,ACTI,G_exitkeys[G_edepth][j].func))  err=1;
            if (G_exitkeys[G_edepth][j].func[0]==0)
                strcpy(G_exitkeys[G_edepth][j].func,"NONE");
        }
        if (err) {
            FREE(p);
            FREE(G_exitkeys[G_edepth]);
            RETURNV(0);
        }
    }
    FREE(p);
    G_edepth++;
    G_loglev=G_tindex;
    G_prod=prod;
    runaction(act);
    G_prod=0;
    G_loglev=0;
    G_edepth--;
    cleanup();

    RETURNV(1);
}

//************************************************************
//S Add product to log
//P integer product code
//R TRUE Ok, FALSE failed

INT logprod(INT prodcode)
{
    CHAR val[LENOFVAL];
    CHAR tmp[LENOFLOGPRODTEMP];
    CHAR name[LENOFNAME2];
    CHAR fixed[LENOFFIXP2];
    INT pl,mand;
    ENTRY(1230);

    if (!getprod(prodcode))
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,PRIV,tmp))
        RETURNV(0);
    pl=atoi(tmp);
    if (pl>G_access)
        RETURNV(0);

    if (!sendmsg("DBM",MESSAGE_g,PROD_S,AMNT,val))
        RETURNV(0);
    if ((atol(val)>G_roundval)||(atol(val)==0L))
        G_round=G_roundval;
    else
        G_round=0; //ROUND
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,FIXP,fixed))
        RETURNV(0);

    sendmsg("OUTPUT1",MESSAGE_1);
    if (strcmp(fixed,"Y"))
        {
        if (strcmp(val,"0"))
            strcpy(G_fixed,val);
        else
            G_fixed[0]=0;
        if (!setupaction(prodcode))
            RETURNV(0);
        }
    else
        {
        if (!sendmsg("DBM",MESSAGE_g,PROD_S,NAME,name))
            RETURNV(0);
        G_prod=prodcode;
        add2log(name,val," "," "," ");
        if (sendmsg("DBM",MESSAGE_g,PROD_S,MAND,tmp))
            {
            mand=atoi(tmp);
            if ((mand)&&(mand!=prodcode)) logprod(mand);
            }
        }
    RETURNV(1);
}

//************************************************************
//S Get action
//P char prevkey - I think this should be int :JGQ
//P integer product key
//R TRUE Ok, FALSE failed

INT getaction(CHAR prevkey,INT key)
{
    CHAR tmp[LENOFGETACTIONTEMP];
    CHAR keyp[LENOFKEYP];
    INT prod=0,maxqty=0;
    ENTRY(1240);

    sprintf(keyp,"%d",key);

    if (!sendmsg("DBM",MESSAGE_p,PROD_S,FKEY,keyp))     // put field
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_s,PROD_S,FKEY,FRST))     // search
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)CURR))    // read
        RETURNV(0);
#ifndef WIEN
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,PKEY,tmp))
        RETURNV(0);
    while (atoi(tmp)!=prevkey)
        {
        if (!sendmsg("DBM",MESSAGE_s,PROD_S,FKEY,NEXT))
            RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_r,PROD_S,(LONG)CURR))
            RETURNV(0);
        if (!sendmsg("DBM",MESSAGE_g,PROD_S,PKEY,tmp))
            RETURNV(0);
        }
#else
    prevkey++;
#endif
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,MAXQ,tmp))
        RETURNV(0);
    maxqty=atoi(tmp);
    if ((maxqty!=0)&&(G_qnty>maxqty))
        RETURNV(0);
    if (!sendmsg("DBM",MESSAGE_g,PROD_S,CODE,tmp))
        RETURNV(0);
    prod=atoi(tmp);
    if (!logprod(prod))
        RETURNV(0);
    RETURNV(1);
}

//************************************************************
//S get line 1 of a file into current item
//D opens supplied filename and keeps it open - reads a line and returns to current item
//R TRUE

INT getl1(void)
{
    static FILE *fp;
    CHAR tmp[LENOFGETL1TEMP];
    ENTRY(1250);
    if (!G_lcnt)
        {
        fp=fopen(G_formvars[G_form.curitem-1],"r");
        if (fp==NULL)
            {
            sprintf(G_formvars[G_form.curitem],"Can't Open %s",G_formvars[G_form.curitem-1]);
            G_form.curitem-=(CHAR)2;
            RETURNV(1);
        }
    }
    G_lcnt++;
    if (fgets(tmp,80,fp)==NULL)
        {
        sprintf(G_formvars[G_form.curitem],"Can't Get String %d",G_lcnt);
        RETURNV(1);
        }
    while ((tmp[strlen(tmp)-1]=='\r')||(tmp[strlen(tmp)-1]=='\n'))
        {
        tmp[strlen(tmp)-1]=0;
        }
    strcpy(G_formvars[G_form.curitem],tmp);
    RETURNV(1);
}

//************************************************************
//S this version puts text from current item to stdout (& flushes)
//R TRUE

INT getl2(void)
{
    ENTRY(1260);
    fprintf(stdout,"TEXT%04d %s\n",G_lcnt-1,G_formvars[G_form.curitem]);
    fflush(stdout);
    G_form.curitem-=(CHAR)2;
    RETURNV(1);
}

//************************************************************
//S void 
//R TRUE

INT getl3(void)
{
    ENTRY(1270);
    RETURNV(1);
}

//************************************************************
//S dispense from G_Type, G_qnty
//D gets an integer response and throws it away
//R TRUE

INT dispense(void)
{
    INT e;
    ENTRY(1261);
    sendmsg("OUTPUT4",MESSAGE_DC,G_type,G_qnty,&e);
    RETURNV(1);
}

//************************************************************
//S pay out from G_qnty
//R TRUE

INT payoutcn(void)
{
    ENTRY(1262);
    G_qnty=(INT)sendmsg("OUTPUT4",MESSAGE_PO,G_qnty);
    RETURNV(1);
}

//************************************************************
//S Reduce money counter - If successful sets current G_qnty to 0
//R TRUE

INT reducecn(void)
{
    ENTRY(1263);
    if (!sendmsg("OUTPUT4",MESSAGE_RC,G_qnty))
        G_qnty=0;
    RETURNV(1);
}

//************************************************************
//S Get coins - sets total value in G_qnty - ignores breakdown
//R TRUE

INT getcoins(void)
{
    INT a,b,c,d,e;
    ENTRY(1264);
    G_qnty=(INT)sendmsg("OUTPUT4",MESSAGE_GC,&a,&b,&c,&d,&e);
    RETURNV(1);
}

//************************************************************
//S Operate door
//R TRUE

INT operdoor(void)
{
    ENTRY(1265);
    sendmsg("OUTPUT4",MESSAGE_OD,0);
    RETURNV(1);
}

//************************************************************
//S Get coin status
//R TRUE

INT coinstat(void)
{
    ENTRY(1266);
    sendmsg("OUTPUT4",MESSAGE_GS,G_type,G_formvars[G_form.curitem]);
    RETURNV(1);
}
// **************************************************************************
// function.c <end-of-file>

