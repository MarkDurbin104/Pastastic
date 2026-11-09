/****************************************************************************
* Project     : GPA
* File        : tabproc.c
* Description : table processing
* 
* $Revision:   1.3  $  $Date:   Nov 03 1995 11:33:08  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/tabproc.c_v  $
* 
*    Rev 1.3   Nov 03 1995 11:33:08   JGRAY
* Annotations
* 
****************************************************************************/
#define TABPROC_C

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "gpasizes.h"
#include "types.h"
#include "keydef.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "formhand.h"
#include "fldproc.h"
#include "tabproc.h"
#include "dst.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "config.h"

TABDAT  *G_wtb;
INT     G_wxpos;
INT     G_wypos;
INT     G_wcurrec;
INT     G_wnumrec;
INT     G_wtoprec;
INT     G_recnum=1;
INT     G_prevnumrecs=(-100);
INT     G_activeflds[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
INT     G_numaf=0;
INT     G_deffld[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
INT     G_numdffld=0;

//*********************************************************
//S converts string G_tflds (table fields) into an array - G_activeflds
//R integer number fields in array

INT checkflds(void)
{
    CHAR *t;
    CHAR s[80];
    INT i;
    ENTRY(2921);
    G_numaf=0;
    G_numdffld=0;
    if (G_tflds!=NULL)
        {
        strncpy(s,G_tflds,79);  // I hate this use of strncpy - buggy buggy buggy :JGQ
        t=strtok(s,",\r\n. ");
        while (t!=NULL)
            {
            if (*t=='~')
                {
                t++;
                G_deffld[G_numdffld++]=atoi(t);
                }
            if ((i=atoi(t))!=0)
                G_activeflds[G_numaf++]=i;
            t=strtok(NULL,",\r\n. ");
            }
        }
    RETURNV(G_numaf);
}

//*********************************************************
//S Get the number of records, set up memory buffer
//D Sets up G_numrec and G_prevnumrecs. Allocates a record index buffer space
//D pointed at by G_ridxbuf, if memory is not available searchs will be slower
//P store number
//R integer number of records

INT getnumrec(UCHAR s)
{
    INT i=FRST;
    LONG l;
    UINT nr;
    ENTRY(2922);
       nr=(INT)sendmsg("DBM",MESSAGE_nr,G_store[s].name);
    switch (G_scond)
        {
        case 0 :            // look in complete data table
            G_numrec=nr;
            break;
        case 1 :        // Primary key
            if (G_prevnumrecs+1==nr)
                {    // If just one record added at end - special case
                if (G_numrec>0)
                    {
                    l=(LONG)sendmsg("DBM",MESSAGE_rn,G_store[s].name);        // returns current record number
                    if (l==G_ridxbuf[G_numrec-1])
                        {
                        G_ridxbuf=REALLOC(G_ridxbuf,sizeof(LONG)*(G_numrec+1)+1);
                        if (G_ridxbuf!=NULL)
                            {
                            G_prevnumrecs++;
                            G_ridxbuf[G_numrec]=l+1;        // record index buffer - in memory copy for quick searches
                            G_numrec++;                        // number of records in on-screen table
                            }
                        }
                    }
                }
            if (G_prevnumrecs!=nr)
                {        // Perform a search
                if (G_ridxbuf!=NULL)
                    FREE(G_ridxbuf);
                G_prevnumrecs=nr;
                G_numrec=0;
                G_ridxbuf=MALLOC(nr*sizeof(LONG)+1);            // System limit (16bit), 16382 records max in a table
                if (G_ridxbuf!=NULL)
                    {
                    sendmsg("DBM",MESSAGE_sl,G_store[s].name,G_alsosel);
                    G_numrec=(INT)sendmsg("DBM",MESSAGE_bp,G_store[s].name,G_srec,G_ridxbuf);  // build primary index
                    if (G_numrec)
                        {
                        G_ridxbuf=REALLOC(G_ridxbuf,sizeof(LONG)*(G_numrec+1)+1);
                        sendmsg("DBM",MESSAGE_r,G_store[s].name,G_ridxbuf[0]);        // read a record
                        }
                    }
                else
                    {
                    // if no memory, search via first, next, next....
                    while (sendmsg("DBM",MESSAGE_sp,G_store[s].name,G_srec,i))
                        {
                        G_numrec++;
                        i=NEXT;
                        }
                    sendmsg("DBM",MESSAGE_sp,G_store[s].name,G_srec,FRST);
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR);
                    }
                G_recnum=1;                // set to first record in the table
            }
            nr=G_numrec;
            break;
        case 2 :                    // Secondary search
            if (G_prevnumrecs+1==nr)
                {
                if (G_numrec>0)
                    {
                    l=(LONG)sendmsg("DBM",MESSAGE_rn,G_store[s].name);
                    if (l==G_ridxbuf[G_numrec-1])
                        {
                        G_ridxbuf=REALLOC(G_ridxbuf,sizeof(LONG)*(G_numrec+1)+1);
                        if (G_ridxbuf!=NULL)
                            {
                            G_prevnumrecs++;
                            G_ridxbuf[G_numrec]=l+1;
                            G_numrec++;
                            }
                        }
                    }
                }
            if (G_prevnumrecs!=nr)
                {
                if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
                G_prevnumrecs=nr;
                G_numrec=0;
                G_ridxbuf=MALLOC(nr*sizeof(LONG)+1);
                if (G_ridxbuf!=NULL)
                    { 
                    sendmsg("DBM",MESSAGE_sl,G_store[s].name,G_alsosel);
                    G_numrec=(INT)sendmsg("DBM",MESSAGE_bs,G_store[s].name,G_sfname,G_ridxbuf);
                    if (G_numrec)
                        {
                        G_ridxbuf=REALLOC(G_ridxbuf,sizeof(LONG)*(G_numrec+1)+1);
                        sendmsg("DBM",MESSAGE_r,G_store[s].name,G_ridxbuf[0]);
                        }
                    }
                else
                    {
                    while (sendmsg("DBM",MESSAGE_s,G_store[s].name,G_sfname,i))
                        {
                        G_numrec++;
                        i=NEXT;
                        }
                    sendmsg("DBM",MESSAGE_s,G_store[s].name,G_sfname,FRST);
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR);
                    }
                G_recnum=1;
                }
            nr=G_numrec;
            break;
        }
    RETURNV(nr);
}

//*********************************************************
//S flush table
//R integer reply from message_f

INT flushtab(void)
{
    ENTRY(2923);
    RETURNV((INT)sendmsg("DBM",MESSAGE_f));
}

//*********************************************************
//S get a record number
//P store number
//R integer record number

INT getrecnum(UCHAR s)
{
    INT nr=0;
    INT i;
    ENTRY(2924);
    switch (G_scond)
        {
        case 0 :            // look in complete data table
            nr=(INT)sendmsg("DBM",MESSAGE_rn,G_store[s].name);
            break;
        case 1 :   //Primary
        case 2 :   //Secondary            // look in the sub selection
            if ((G_ridxbuf!=NULL)&&(G_recnum>0))
                {
                nr=(INT)sendmsg("DBM",MESSAGE_rn,G_store[s].name);
                for (i=0;i<G_numrec;i++)
                    {
                    if (nr==G_ridxbuf[i])
                        {
                        G_recnum=nr=i;
                        break;
                        }
                    }
                }
            else
                {
                nr=G_recnum;
                }
            break;
        }
    RETURNV(nr);
}

//*********************************************************
//S read a record given a number
//P store number
//P find criteria
//R integer 0 or current record number

INT readrecnum(UCHAR s,INT rec)
{
    INT nr=0;
    ENTRY(2925);
    if (!getnumrec(s))
        RETURNV(0);

    switch (G_scond)
        {
        case 0 :        // entire data store
#ifdef WIEN
            if (rec==G_numrec)
                rec=LAST;
            else
                if ((rec==G_recnum)&&(rec<=G_numrec))
                    rec=CURR;
            switch (rec)
                {
                case FRST :
                case 1 :
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)FRST);
                    G_recnum=1;
                    break;
                case NEXT :
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)NEXT);  
                    G_recnum++;                                       
                    break;                                            
                case CURR :                                           
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR);
                    break;                                            
                case PREV :                                           
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)PREV);  
                    G_recnum--;                                       
                    break;                                            
                case LAST :                                           
                    sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)LAST);  
                    G_recnum=G_numrec;
                    break;
                default :
                    if (rec<1)
                        {
                        G_recnum=1;
                        sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)FRST);
                        RETURNV(0);
                        }
                    if (rec>G_numrec)
                        {
                        G_recnum=G_numrec;
                        sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)LAST);
                        RETURNV(0);
                        }
                    if (sendmsg("DBM",MESSAGE_RP,G_store[s].name,rec-G_recnum))
                        {
                        if (sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR))
                            {
                            G_recnum=rec;
                            return(G_recnum);
                            }
                        }
                    while (rec>G_recnum)
                        {
                        if (sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)NEXT))
                            {
                            G_recnum++;
                            }
                        else
                            {
                            sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)LAST);
                            G_recnum=G_numrec;
                            return(0);
                            }
                        }
                    while (rec<G_recnum)
                        {
                        if (sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)PREV))
                            {
                            G_recnum--;
                            }
                        else
                            {
                            G_recnum=1;
                            sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)FRST);
                            return(0);
                            }
                        }
                }
            nr=G_recnum;
#else
            nr=(INT)sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)rec); // ??????????? MJD
#endif
            break;
        case 1 :        // primary search
            if (G_numrec==0)
                {
                nr=0;
                }
            else
                {
                switch (rec)
                    {
                    case FRST : rec=1;          break;
                    case NEXT : rec=G_recnum+1; break;
                    case CURR : rec=G_recnum;   break;
                    case PREV : rec=G_recnum-1; break;
                    case LAST : rec=G_numrec;   break;
                    }
                if (rec<1)
                    RETURNV(0);
                if (G_ridxbuf!=NULL)
                    {
                    if (rec<=G_numrec)
                        {
                        nr=(INT)sendmsg("DBM",MESSAGE_r,G_store[s].name,G_ridxbuf[rec-1]);
                        }
                    else
                        {
                        G_recnum=G_numrec;
                        RETURNV(0);
                        } 
                    }
                else
                    {
                    if (rec!=G_recnum)
                        {
                        if (rec<G_recnum)
                            {
                            G_recnum=1;
                            sendmsg("DBM",MESSAGE_sp,G_store[s].name,G_srec,FRST);
                            }
                        while (rec>G_recnum)
                            {
                            if (sendmsg("DBM",MESSAGE_sp,G_store[s].name,G_srec,NEXT))
                                {
                                G_recnum++;
                                }
                            else
                                {
                                G_recnum=G_numrec;
                                RETURNV(0);
                                }
                            }
                        }
                    nr=(INT)sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR);
                    }
                }
            break;
        case 2 :            // secondary
            if (G_numrec==0)
                {
                nr=0;
                }
            else
                {
                switch (rec)
                    {
                    case FRST : rec=1;          break;
                    case NEXT : rec=G_recnum+1; break;
                    case CURR : rec=G_recnum;   break;
                    case PREV : rec=G_recnum-1; break;
                    case LAST : rec=G_numrec;   break;
                    }
                if (rec<1) RETURNV(0);
                if (G_ridxbuf!=NULL)
                    {
                    if (rec<=G_numrec)
                        {
                        nr=(INT)sendmsg("DBM",MESSAGE_r,G_store[s].name,G_ridxbuf[rec-1]);
                        }
                    else
                        {
                        G_recnum=G_numrec;
                        RETURNV(0);
                        } 
                    }
                else
                    {
                    if (rec!=G_recnum)
                        {
                        if (rec<G_recnum)
                            {
                            G_recnum=1;
                            sendmsg("DBM",MESSAGE_s,G_store[s].name,G_sfname,FRST);
                            }
                        while (rec>G_recnum)
                            {
                            if (sendmsg("DBM",MESSAGE_s,G_store[s].name,G_sfname,NEXT))
                                {
                                G_recnum++;
                                }
                            else
                                {
                                G_recnum=G_numrec;
                                RETURNV(0);
                                }
                            }
                        }
                    nr=(INT)sendmsg("DBM",MESSAGE_r,G_store[s].name,(LONG)CURR);
                    }
                }
            break;
        }
    RETURNV(nr);        // return current record number
}

//*********************************************************
//S delete a record
//P store number
//P find criteria
//R delete record reply

INT delrec(UCHAR s,INT rec)
{
    ENTRY(2926);
    readrecnum(s,rec);
    RETURNV((INT)sendmsg("DBM",MESSAGE_dr,G_store[s].name,(LONG)CURR));
}

//*********************************************************
//S collect all field information for a given table and run actions off display fields
//D For a table, processes any form items which are display only or any items on
//D reports or pre-printed forms.
//P pointer to table data
//P integer item to get
//P ptr to location to place field data
//R FALSE failed, TRUE Ok

INT getflddata(PTABDAT tb,INT i,CHAR *v)
{
    INT item=G_form.curitem;
    ENTRY(2930);
    if (((G_form.items[tb->fid[i]].class^FF_TBLF)==FF_DISP)
    ||   (G_form.type==F_REPORT)
    ||   (G_form.type==F_PPFORM))
        {
        if (strncmp(G_form.items[tb->fid[i]].func,"NONE",4))
            {
            if (!sendmsg("DBM",MESSAGE_qg,tb->sn,tb->fn[i],G_formvars[tb->fid[i]]))
                RETURNV(0);    // quick get
            G_form.curitem=(CHAR)tb->fid[i];
            G_curtcol=i;
            runaction(G_form.items[tb->fid[i]].func);
            G_form.curitem=(CHAR)item;
            strcpy(v,G_formvars[tb->fid[i]]);
            RETURNV(1);
            }
        }
    RETURNV((INT)sendmsg("DBM",MESSAGE_qg,tb->sn,tb->fn[i],v));
}

//*********************************************************
//S draw the border/background for a table
//P pointer to table data

void tablebdr(PTABDAT tb)
{
    INT i,j,l;
    INT ofs,x,y,x1,y1;
    ENTRY(2940);
    if (tb->type=='N')
        RETURN;                     // None - no border
    x=tb->pos.x;                    // calculate extents of the table
    y=tb->pos.y;
    x1=tb->pos.x+tb->width;
    y1=tb->pos.y+tb->depth+3;
    sendmsg("OUTPUT1",MESSAGE_S,1); // set character size to 1
    if ((tb->type=='S')||(tb->type=='D'))
        {                           // if single or display only table
        for (j=0;j<tb->cols;j++)
            {                       // loop for extra 'block' copies
            sendmsg("OUTPUT1",MESSAGE_B,x,y,x1,y1);        // draw box
            ofs=x;
            sendmsg("OUTPUT1",MESSAGE_L,x,y+2,x1,y+2);    // draw horizontal lines
            for (i=0;i<tb->numf-1;i++)
                {
                ofs+=tb->fwid[i]+1;
                sendmsg("OUTPUT1",MESSAGE_L,ofs,y,ofs,y1);  // vertical lines
                }
            ofs+=tb->fwid[i]+1;
            ofs-=x;
            x+=ofs;
            x1+=ofs;
            }
        }
    l=1;
    for (j=0;j<tb->cols;j++)
        {            // print titles
        for (i=0;i<tb->numf;i++)
            {
            sendmsg("OUTPUT1",MESSAGE_o,tb->pos.x+l,tb->pos.y+1,"%-*.*s",tb->fwid[i],tb->fwid[i],"");
            sendmsg("OUTPUT1",MESSAGE_TEXT,tb->pos.x+l,tb->pos.y+1,G_form.items[tb->tid[i]].item);
            l+=tb->fwid[i]+1;
            }
        }
    RETURN;
}

//*********************************************************
//S collect all dimension information for a given table
//P pointer to table data
//R TRUE Ok, FALSE failed

INT gettabledata(PTABDAT tb)
{
    CHAR *t,tmp[80];
    PFORMF fld=&(G_form.items[tb->id]);
    INT i,l;
    ENTRY(2950);

    tb->pos.x=fld->pos.x;
    tb->pos.y=fld->pos.y;
    tb->depth=(CHAR)atoi(&(fld->fmt[2]));
    tb->type=fld->fmt[0];
    tb->cols=fld->fmt[5];
    tmp[0]=fld->fmt[7];
    tmp[1]=fld->fmt[8];
    tmp[2]=0;
    tb->numf=atoi(tmp);

    if ((G_form.type!=F_REPORT)&&(G_form.type!=F_PPFORM))
        tb->cols=1;

    for (i=0;i<tb->cols;i++)
        tb->cd[i]=fld->fmt[9+i];
    if (fld->size==3)
        tb->type='D';        // do this in the designer

    strcpy(tmp,fld->item);
    if (tmp[0]=='!')
        {                   // New Table field identifier format starts with '!'
        t=&tmp[1];
        l=0;
        for (i=0;i<tb->numf;i++)
            {
            tb->fwid[i]=0;
            tb->tid[i]=findid(*(t++)-1);
            if (tb->tid[i]==(-1))
                RETURNV(0);
            tb->fid[i]=findid(*(t++)-1);
            tb->fwid[i]=max(strlen(textstr(&(G_form.items[tb->tid[i]]))),strlen(G_form.items[tb->fid[i]].fmt));
            if (G_form.items[tb->fid[i]].size>1)
                tb->fwid[i]*=2;
            l+=tb->fwid[i]+1;
            }
        }
    else
        {
        t=strtok(tmp,"~ ");
        l=0;
        for (i=0;i<tb->numf;i++)
            {
            tb->fwid[i]=0;
            if (t!=NULL)
                {
                if (isdigit(*t))
                    {                    // oldest format
                    tb->tid[i]=findid(atoi(t));
                    }
                else
                    {                            // older format
                    tb->tid[i]=findid(*t-'A');  
                    }
                if (tb->tid[i]==(-1))
                    RETURNV(0);
                t=strtok(NULL,"~ ");
                if (t!=NULL)
                    {
                    if (isdigit(*t))
                        {
                        tb->fid[i]=findid(atoi(t));
                        }
                    else
                        {
                        tb->fid[i]=findid(*t-'A');
                        }
                    tb->fwid[i]=max(strlen(textstr(&(G_form.items[tb->tid[i]]))),strlen(G_form.items[tb->fid[i]].fmt));
                    if (G_form.items[tb->fid[i]].size>1)
                        tb->fwid[i]*=2;
                    t=strtok(NULL,"~ ");
                    }
                }
            l+=tb->fwid[i]+1;
            }
        }
    tb->width=(CHAR)l;
    tb->disponly=1;
    for (i=0;i<tb->numf;i++)
        {        // collect field numbers and store number
        if (((G_form.items[tb->fid[i]].class&~FF_TBLF)!=FF_DISP)
        &&  ((G_form.items[tb->fid[i]].class&~FF_TBLF)!=FF_WAIT))
            {
            tb->disponly=0;
            }
        strcpy(tmp,G_form.items[tb->fid[i]].item);
        t=strtok(tmp,". ");
        if (t!=NULL)
            {
            if ((INT)((tb->sn=snum(t)))<0) RETURNV(0);
            t=strtok(NULL,". ");
            if (t!=NULL)
                if ((INT)((tb->fn[i]=fnum(G_store[tb->sn].name,t)))<0)
                    RETURNV(0);
            }
        }
//  if (isaction(fld->func)) tb->sn[0]='~';
    RETURNV(1);
}

//*********************************************************
//S redraw the table contents
//P pointer to the table structure
//P top record number
//P whether to draw bottom up or top down.  1 == bottom up, 2 - redraw same way as last time
//P whether key press can interrupt redraw

void tabredraw(PTABDAT tb,INT top,INT botup,INT quick)
{
    PFORMF fldp;
    CHAR tmp[80];
    static CHAR fmt[61];            // Ok - so why 61 so precisely ????? :JGQ
    // field format is 40 wide, field item is 60 wide.  We later in this code
    // place a null byte in fmt[] at the field width position so fmt has to be
    // big enough to cater for all widths.
    INT l,ofs,i,j,k,res,rec;
    INT tft=G_form.type;
    static INT dir=0;
    ENTRY(2960);

    if (botup==2)
        botup=dir;
    else
        dir=botup;
    G_form.type=0;
    G_finredraw=0;
    l=tb->width*tb->cols;        // width of table
    if (botup)
        {
        rec=top+(tb->depth*tb->cols);        // depth is number of rows
        res=readrecnum(tb->sn,rec);
        // tell dbm to be ready for nrec reads
        if (res)
            sendmsg("DBM",MESSAGE_PR,G_store[tb->sn].name,(LONG)(tb->depth*tb->cols));
        for (k=tb->cols-1;k>=0;k--)
            {        // for each column
            ofs=l;
            for (j=tb->depth;j>0;j--)
                {        // for each row
                l=ofs;
//              sendmsg("OUTPUT1",MESSAGE_o,tb->pos.x,tb->pos.y+j+2,"%c",(res!=0)?'X':' ');
                if (res)
                    {                    // if search Ok - output
                    for (i=tb->numf-1;i>=0;i--)
                        {
                        fldp=&(G_form.items[tb->fid[i]]);
                        l-=tb->fwid[i];
                        getflddata(tb,i,tmp);
                        strcpy(fmt,fldp->fmt);
                        // set field width for output(). NOTE output() requires width in characters, not cells. (/2 for dble width)
                        if (fldp->size==1)
                            fmt[tb->fwid[i]]=0;
                        else
                            fmt[tb->fwid[i]/2]=0;
                        output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size,fldp->attrib);
                        l--;
                        }
                    sendmsg("OUTPUT1",MESSAGE_S,1);
                    if (quick&&sendmsg("INPUT1",MESSAGE_FH))
                        {        // check for key press (fast hit does not action key)
                        G_form.type=(CHAR)tft;
                        RETURN;
                        }
                    }
                else
                    {                        // no record - blank
                    if (tb->type!='D')
                        {
                        for (i=tb->numf-1;i>=0;i--)
                            {
                            fldp=&(G_form.items[tb->fid[i]]);
                            l-=tb->fwid[i];
                            strcpy(fmt,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                            strcpy(tmp,"                                        ");
                            if (fldp->size==1)
                                fmt[tb->fwid[i]]=0;
                            else
                                fmt[(tb->fwid[i]/2)]=0;
                            output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size,fldp->attrib);
                            l--;
                            if (quick&&sendmsg("INPUT1",MESSAGE_FH))
                                {
                                G_form.type=(CHAR)tft;
                                RETURN;
                                }
                            }
                        }
                    }
                res=readrecnum(tb->sn,--rec);
                }
            }
        }
    else
        {            // top down
        l=1;
        rec=top+1;
        res=readrecnum(tb->sn,rec);
        // tell dbm to be ready for nrec reads
        if (res)
            sendmsg("DBM",MESSAGE_PR,G_store[tb->sn].name,(LONG)(tb->depth*tb->cols));
        for (k=0;k<tb->cols;k++)
            {
            ofs=l;
            for (j=1;j<=tb->depth;j++)
                {
                l=ofs;
//              sendmsg("OUTPUT1",MESSAGE_o,tb->pos.x,tb->pos.y+j+2,"%c",(res!=0)?'X':' ');
                if (res)
                    {
                    for (i=0;i<tb->numf;i++)
                        {
                        fldp=&(G_form.items[tb->fid[i]]);
                        getflddata(tb,i,tmp);
                        strcpy(fmt,fldp->fmt);
                        if (fldp->size==1)
                            fmt[tb->fwid[i]]=0;
                        else
                            fmt[tb->fwid[i]/2]=0;
                        output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size,fldp->attrib);
                        l+=tb->fwid[i]+1;
                        }
                    sendmsg("OUTPUT1",MESSAGE_S,1);
                    if (quick&&sendmsg("INPUT1",MESSAGE_FH))
                        {
                        G_form.type=(CHAR)tft;
                        RETURN;
                        }
                    res=readrecnum(tb->sn,++rec);
                    }
                else
                    {
                    if (tb->type!='D')
                        {
                        for (i=0;i<tb->numf;i++)
                            {
                            fldp=&(G_form.items[tb->fid[i]]);
                            strcpy(fmt,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                            strcpy(tmp,"                                        ");
                            if (fldp->size==1)
                                fmt[tb->fwid[i]]=0;
                            else
                                fmt[(tb->fwid[i]/2)]=0;
                            output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size,fldp->attrib);
                            l+=tb->fwid[i]+1;
                            }
                        if (quick&&sendmsg("INPUT1",MESSAGE_FH))
                            {
                            G_form.type=(CHAR)tft;
                            RETURN;
                            }
                        }
                    }
                }
            }
        }
    G_finredraw=1;                // redraw complete
    G_form.type=(CHAR)tft;        // restore global
    RETURN;
}

//*********************************************************
//S find the x position of the cursor - given the field offset in the table
//P pointer to table
//P integer field offset
//R integer x offset 

INT allto(PTABDAT tb,INT pos)
{
    INT ret=0;
    INT i,j,k=0;
    ENTRY(2970);
    for (i=0;i<tb->cols;i++)
        {            // loop for 'blocks' of columns
        for (j=0;j<tb->numf;j++)
            {        // number of fields (columns)
            if (pos==k) RETURNV(ret);
            k++;
            ret+=tb->fwid[j]+1;
        }
    }
    RETURNV(0);
}

//************************************************************
//S plut a cursor on the screen 
//P integer x
//P integer x1
//P integer y
//P integer length of cursor
//P integer type
//P address of table data used to determine whether disponly table

void tablecur(INT x,INT x1,INT y,INT length,INT type,PTABDAT tb)
{
    if (tb->disponly)
        {
        sendmsg("OUTPUT1",MESSAGE_C,tb->pos.x,1,y,tb->width-1,type);
        }
    else
        {
        sendmsg("OUTPUT1",MESSAGE_C,x,x1,y,length,type);
        }
}

//*********************************************************
//S edit a field in a table
//P pointer to table data
//P integer x location
//P integer y location
//P integer record number
//P integer field number
//P integer keypress flag ????

INT editfield(PTABDAT tb,INT x,INT y,INT recnum,INT fldnum,INT kp)
{
    INT curpos,r;
    CHAR tmp[LENOFTMPEDITFLD];
    INT fr;
    ENTRY(2980);
    fr=G_finredraw;
    curpos=G_form.curitem;
    if (getrecnum(tb->sn)!=recnum+1)
        {
        if (!readrecnum(tb->sn,recnum+1))
            RETURNV(0);
        }
    if (!getflddata(tb,fldnum,tmp))
        RETURNV(0);
// Mark's fix for redraw at end of JUMPTO command - unfortunately system hangs with this code!
// I added the i count loop but this badly affects performance.  Tom
//    if (kp==CRGT) {
//        INT i=32000;
//        while (i>0) {
//            if (!G_finredraw) {
//                sendmsg("INPUT1",MESSAGE_H);
//            } else {
//                break;
//            }
//            i--;
//        }
//        if (G_wtb->type!='D') tablecur(G_wtb->pos.x,1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wtb->fwid[G_wxpos%G_wtb->numf],1,G_wtb);
//    } else {
//        G_finredraw=1;
//    }
    G_finredraw=1;
    if ((r=inputstr(x,y,tmp,G_form.items[tb->fid[fldnum]].fmt,kp))==(-1))
        RETURNV(0);
    if (r!=EXIT_K)
        {
        if (!sendmsg("DBM",MESSAGE_qp,tb->sn,tb->fn[fldnum],tmp))
            RETURNV(0);
        }
    if (kp!=CRGT)
        G_finredraw=fr;
    G_form.curitem=(CHAR)curpos;
    RETURNV(r);
}

//*********************************************************
//S output a field in a table
//P pointer to TABDAT table data
//P integer x location
//P integer y location
//P integer record number
//P integer field number

void outfield(PTABDAT tb,INT x,INT y,INT recnum,INT fldnum)
{
    CHAR tmp[LENOFTMPEDITFLD];
    CHAR fmt[LENOFTMPEDITFLD];
    ENTRY(2990);

    strcpy(fmt,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    strcpy(tmp,"                                        ");
    if (G_form.items[tb->fid[fldnum]].size==1)
        fmt[tb->fwid[fldnum]]=0;
    else
        fmt[(tb->fwid[fldnum]/2)]=0;
    output(x,y,tmp,0,fmt,G_form.items[tb->fid[fldnum]].size,G_form.items[tb->fid[fldnum]].attrib);
    if (!readrecnum(tb->sn,recnum+1))
        RETURN;
    if (!getflddata(tb,fldnum,tmp))
        RETURN;
    output(x,y,tmp,0,G_form.items[tb->fid[fldnum]].fmt,G_form.items[tb->fid[fldnum]].size,G_form.items[tb->fid[fldnum]].attrib);
    RETURN;
}

//*********************************************************
//S update named store - i.e. if modified, write record to store
//P store number
//R TRUE Ok, FALSE failed

INT upnamedatest(UCHAR s)
{
    ENTRY(2991);
    if ((G_sstat[s].open)&&(G_sstat[s].modified))
        {
        RETURNV((INT)sendmsg("DBM",MESSAGE_w,G_store[s].name));
        }
    RETURNV(1);
}

//*********************************************************
//S input a record in a table on field at a time
//P address of table data
//P integer x offset of table column to start
//P integer y row location

void inputrec(PTABDAT tb,INT x,INT y)
{
    INT i,ofs;
    CHAR tmp[LENOFTMPEDITFLD];
    ENTRY(3000);
    ofs=0;
    for (i=0;i<tb->numf;i++)
        {        // blank all fields
        sendmsg("OUTPUT1",MESSAGE_o,x+ofs,y,"%*.*s",tb->fwid[i],tb->fwid[i],"");
        ofs+=1+tb->fwid[i];
        }
    ofs=0;
    for (i=0;i<tb->numf;i++)
        {        // call inputstr for each field
        tmp[0]=0;
        inputstr(x+ofs,y,tmp,G_form.items[tb->fid[i]].fmt,0);
        if (((G_form.items[tb->fid[i]].class&FF_DISP)==FF_DISP)&&(tmp[0]==0))
            {
            beep();            // alert user, nothing entered.  Data entry must be forced for primary key fields
            i--;
            }
        else
            {                // not display (primary key) field, data entry not necessary
            sendmsg("DBM",MESSAGE_qp,tb->sn,tb->fn[i],tmp);
            ofs+=1+tb->fwid[i];
            }
        }
    upnamedatest(tb->sn);
//  updatest();
}

//*********************************************************
//S called to finish redrawing a table when there is no keyboard activity
//D called as a key loop function
//R TRUE

INT finred(void)
{
    ENTRY(3010);
    if ((G_finredraw!=1) && (G_intable))
        {
        if (G_finredraw==(-1))
            tablebdr(G_wtb);
                // switch cursor off if not display only table
        if (G_wtb->type!='D')
            tablecur(G_wtb->pos.x,1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wtb->fwid[G_wxpos%G_wtb->numf],(-1),G_wtb);
        G_wnumrec=getnumrec(G_wtb->sn);
        if (G_wnumrec!=0)
            if (G_wcurrec>G_wnumrec-1)
                {        // move cursor up to make sure it isn't off the end of the table
                sendmsg("OUTPUT1",MESSAGE_OF);
                sendmsg("INPUT1",MESSAGE_P,UP);
                sendmsg("INPUT1",MESSAGE_P,5000);
                }
        tabredraw(G_wtb,G_wtoprec,2,1);            // redraw, same direction as before
        outfield(G_wtb,G_wtb->pos.x+1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wcurrec,G_wxpos%G_wtb->numf);
        if (G_wtb->type!='D')
            tablecur(G_wtb->pos.x,1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wtb->fwid[G_wxpos%G_wtb->numf],1,G_wtb);
        }
    RETURNV(1);
}

//*********************************************************
//S returns value of rightmost lastfield of active columns
//D If no active fields, return rightmost column
//P pointer to table data
//R integer field id

INT lastfield(PTABDAT tb)
{
    INT i,j=0;
    ENTRY(3011);
    if (G_numaf==0)
        RETURNV(tb->numf-1);
    for (i=0;i<G_numaf;i++)
        j=max(j,(G_activeflds[i]-1));
    RETURNV(j);
}

//*********************************************************
//S returns value of leftmost firstfield of active columns
//D If no active fields, return leftmost column
//R integer leftmost active field or 0

INT firstfield(void)
{
    INT i,j=32000;
    ENTRY(3012);
    if (G_numaf==0)
        RETURNV(0);
    for (i=0;i<G_numaf;i++)
        j=min(j,(G_activeflds[i]-1));
    RETURNV(j);
}

//*********************************************************
//S Check position of cursor. If not OK move it appropriately
//P pointer to table data
//P pointer to xpos
//P direction of movement

void setcheck(PTABDAT tb,INT *xpos,INT dir)
{
    INT i;
    ENTRY(3013);
    if (G_movecto)
        {
        *xpos=G_movecto-1;
        G_movecto=0;
        RETURN;
        }
    if (G_numaf==0)
        RETURN;
    if (dir==4)
        {                    // CR type movement
        if (G_numdffld<1)
            RETURN;
        while (*xpos<=tb->numf)
            {
            for (i=0;i<G_numdffld;i++)
                {
                if ((G_deffld[i]-1)==*xpos)
                    RETURN;
                }
            (*xpos)++;                // if position not found, increment xpos to try again
            }
        (*xpos)=G_deffld[0];        // If moved off right, reset to left
        RETURN;
        }
    for (i=0;i<G_numaf;i++)
        {
        if ((G_activeflds[i]-1)==*xpos)
            RETURN;        //OK, in active field
        }
    if ((dir==1)||(dir==2))
        {                    // across or right
        while (*xpos<=tb->numf)
            {
            (*xpos)++;
            for (i=0;i<G_numaf;i++)
                {
                if ((G_activeflds[i]-1)==*xpos)
                    RETURN;
                }
            }
        if (dir!=2)
            {                            // CR across, look to wrap
            *xpos=0;
            while (*xpos<=tb->numf)
                {
                for (i=0;i<G_numaf;i++)
                    {
                    if ((G_activeflds[i]-1)==*xpos)
                        RETURN;
                    }
                (*xpos)++;
                }
            RETURN;
            }
        } 
    while (*xpos>=0)
        {            // either 2 or 3 (right, left), now look left
        (*xpos)--;
        for (i=0;i<G_numaf;i++)
            {
            if ((G_activeflds[i]-1)==*xpos)
                RETURN;
            }
        }
    if (dir!=3)
        {                 // try looking left from rightmost field
        *xpos=tb->numf;
        while (*xpos>0)
            {
            for (i=0;i<G_numaf;i++)
                {
                if ((G_activeflds[i]-1)==*xpos) RETURN;
                }
            (*xpos)--;
            }
        RETURN;                    // give up - no active fields???
        }
    while (*xpos<=tb->numf)
        {    // move right from active field
        (*xpos)++;
        for (i=0;i<G_numaf;i++)
            {
            if ((G_activeflds[i]-1)==*xpos) RETURN;
            }
        }
    RETURN;
}

//*********************************************************
//S move cursor from actions - doesn't work!!!
//P address of integer field or row depending on type
//P integer amount to shift if CURR selected (may be negative)
//P integer type of move FRST, LAST, CURR moves to first field, last field +100 for up down movement
//P pointer to table

INT movecur(INT *o,INT m,INT t,PTABDAT tb)
{
    INT retval=0;
    ENTRY(3014);
    if (t<100)
        {
        switch (t)
            {
            case 0    :                         break;
            case FRST :     *o=firstfield();    break;
            case LAST :     *o=lastfield(tb);   break;
            case CURR :     *o+=m;              break;
            default   :     *o=m;
            }
        if (*o>lastfield(tb))
            *o=lastfield(tb);
        if (*o<firstfield())
            *o=firstfield();
        }
    else
        {
        t-=100;
        retval=1;
        switch (t)
            {
            case 0    : retval=0;               break;
            case FRST : *o=0;                   break;
            case LAST : *o=getnumrec(tb->sn);   break;
            case CURR : *o+=m;                  break;
            default   : *o=m;                     
        }
        if (*o>getnumrec(tb->sn)) *o=getnumrec(tb->sn);
        if (*o<0)                 *o=0;
    }
    RETURNV(retval);
}

//*********************************************************
//S handle all table input/output processing - 600 lines to go!
//P table identifier

void tableinput(INT id)
{
    PTABDAT tb;
    LONG fl,cr,hadanedit=0,ar;
    INT xpos=0;
    INT item=0;
    INT ypos=0;
    CHAR xit=0,suppress=0;
    CHAR dobeep=0;
    CHAR dir=1;
    INT currec=0;
    INT toprec=0;
    INT numrec=0;
    INT k,hk;
    INT croffbot=0;
//    CHAR tmp[50];
    LONG rn;
    ENTRY(3020);
    tb=MALLOC(sizeof(TABDAT));
    if (tb==NULL)
        RETURN;
    tb->id=id;

    checkflds();

    if (G_ridxbuf!=NULL)
        FREE(G_ridxbuf);
    G_ridxbuf=NULL;

    G_finredraw=0;
    if (!gettabledata(tb))
        {
        FREE(tb);
        RETURN;
        }

    if (G_scond==3) {
        G_scond=G_reclisttype;
        if ((G_reclist!=NULL)&&(G_reclistlen!=0)) {
            G_ridxbuf=MALLOC(G_reclistlen*sizeof(LONG)+1);
            if (G_ridxbuf!=NULL) {
                G_prevnumrecs=(INT)sendmsg("DBM",MESSAGE_nr,G_store[tb->sn].name);
                G_numrec=G_reclistlen;
                memcpy(G_ridxbuf,G_reclist,G_numrec*sizeof(LONG)+1);
                switch (G_scond) {
                    case 1 :
                        G_srec=atoi(G_reclistfld);
                        break;
                    case 2 :
                        strcpy(G_sfname,G_reclistfld);
                        break;
                    default :
                        RETURN;
                }
            }
        }
    } else {
        G_prevnumrecs=(-100);
        if (G_scond==0) {
            G_recnum=1;
            sendmsg("DBM",MESSAGE_r,G_store[tb->sn].name,(LONG)FRST);
        }
    }
    numrec=getnumrec(tb->sn);
    tablebdr(tb);
    if (tb->type=='D') {        // Display only, i.e. no cursor
        tabredraw(tb,toprec,0,0);
        if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
        G_ridxbuf=NULL;
        FREE(tb);
        RETURN;
    }
    if (G_numdffld!=0) xpos=G_deffld[0]-1;
    setcheck(tb,&xpos,dir);
    outfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf);
    G_wtb=tb; G_wxpos=xpos; G_wypos=ypos; G_wcurrec=currec; G_wnumrec=numrec; G_wtoprec=toprec;
    prdate();
    sendmsg("INPUT1",MESSAGE_A,2,finred);
    cr=getnumrec(tb->sn);
    if (sendmsg("INPUT1",MESSAGE_FH)) tabredraw(tb,toprec,0,0);
    tablecur(tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],1,tb);
    while (!xit) {
        ar=G_actionrun;
        fl=G_formloaded;
        if ((xpos<0)||(xpos>(tb->numf*tb->cols)-1)) xpos=0;
        G_wtb=tb; G_wxpos=xpos; G_wypos=ypos; G_wcurrec=currec; G_wnumrec=numrec; G_wtoprec=toprec;
        G_curtcol=xpos;

        item=G_form.curitem;
        G_form.curitem=(CHAR)tb->fid[xpos];
        rn=sendmsg("DBM",MESSAGE_rn,G_store[tb->sn].name);
        sendmsg("DBM",MESSAGE_qg,tb->sn,tb->fn[xpos],G_formvars[tb->fid[xpos]]);

        k=(INT)sendmsg("INPUT1",MESSAGE_i);
        tablecur(tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1),tb);
        if (fl!=G_formloaded) {
            fl=G_formloaded;
            if (!gettabledata(tb)) {
                FREE(tb);
                RETURN;
            }
            if (G_form.curitem!=tb->fid[xpos])
                movecur(&xpos,1,xpos+(G_form.curitem-tb->fid[xpos]),tb);
            if (G_form.curitem!=G_form.numitem) G_form.curitem=(CHAR)item;
            tablebdr(tb);
            G_prevnumrecs=(-100);
            numrec=getnumrec(tb->sn);
            G_wtb=tb;
            G_wxpos=xpos;
            G_wypos=ypos;
            G_wcurrec=currec;
            G_wnumrec=numrec;
            G_wtoprec=toprec;
            G_intable=1;
            checkflds();
            tabredraw(tb,toprec,0,0);
        } else {
            if (ar!=G_actionrun) {
                ar=G_actionrun;
                if (numrec==getnumrec(tb->sn)) {
                    sendmsg("DBM",MESSAGE_r,G_store[tb->sn].name,rn);
                    sendmsg("DBM",MESSAGE_qp,tb->sn,tb->fn[xpos],G_formvars[tb->fid[xpos]]);
                    upnamedatest(tb->sn);
                    checkflds();
                } else {
                    numrec=getnumrec(tb->sn);
                    G_wnumrec=numrec;
                    checkflds();
                    tabredraw(tb,toprec,0,0);
                }
            }
        }
        if (G_form.curitem!=G_form.numitem) G_form.curitem=(CHAR)item;
        if ((k==LEFT)||(k==RGT)) k=(INT)sendmsg("OUTPUT1",MESSAGE_K,k);    // swap right/left for Farsi
        numrec=G_wnumrec;
        if ((k==G_pickkey)
        &&  (strncmp(G_form.items[tb->fid[xpos]].func,"NONE",4))
        &&  ((G_form.items[tb->fid[xpos]].class^FF_TBLF)!=FF_DISP)) {
            if (readrecnum(tb->sn,currec+1)) {
                item=G_form.curitem;
                G_form.curitem=(CHAR)tb->fid[xpos];
                G_curtcol=xpos;
                rn=sendmsg("DBM",MESSAGE_rn,G_store[tb->sn].name);
                if (!hadanedit) sendmsg("DBM",MESSAGE_qg,tb->sn,tb->fn[xpos],G_lastval);
                sendmsg("DBM",MESSAGE_qg,tb->sn,tb->fn[xpos],G_formvars[tb->fid[xpos]]);
//                strcpy(tmp,G_formvars[tb->fid[xpos]]);
                runaction(G_form.items[tb->fid[xpos]].func);
                sendmsg("DBM",MESSAGE_r,G_store[tb->sn].name,rn);
//                if (strcmp(G_formvars[tb->fid[xpos]],tmp)) {
                    sendmsg("DBM",MESSAGE_qp,tb->sn,tb->fn[xpos],G_formvars[tb->fid[xpos]]);
//                    sendmsg("DBM",MESSAGE_w,G_store[tb->sn].name);
//                }
                if (fl!=G_formloaded)
                    {
                    fl=G_formloaded;
                    if (!gettabledata(tb))
                        {
                        FREE(tb);
                        RETURN;
                        }
                    if (G_form.curitem!=tb->fid[xpos])
                        movecur(&xpos,1,xpos+(G_form.curitem-tb->fid[xpos]),tb);
                    if (G_form.curitem!=G_form.numitem)
                        G_form.curitem=(CHAR)item;
                    tablebdr(tb);
                    G_prevnumrecs=(-100);
                    numrec=getnumrec(tb->sn);
                    G_wtb=tb;
                    G_wxpos=xpos;
                    G_wypos=ypos;
                    G_wcurrec=currec;
                    G_wnumrec=numrec;
                    G_wtoprec=toprec;
                    G_intable=1;
                    checkflds();
                    tabredraw(tb,toprec,0,0);
                } else if (ar!=G_actionrun) {
                    ar=G_actionrun;
                    if (G_form.curitem!=tb->fid[xpos]) xpos+=(G_form.curitem-tb->fid[xpos]);
                    if (G_form.curitem!=G_form.numitem) G_form.curitem=(CHAR)item;
                    fillfields(&G_form);
                    numrec=getnumrec(tb->sn);
                       cr=numrec;
                    G_wtb=tb;
                    G_wxpos=xpos;
                    G_wypos=ypos;
                    G_wcurrec=currec;
                    G_wnumrec=numrec;
                    G_wtoprec=toprec;
                    if (G_finredraw==1) G_finredraw=0;
                }
            }
            if (suppress) k=suppress;        // suppress holds temporary key press. Use on retrun from sub-form
            suppress=0;
            switch(k) {
                case CPGUP : case CPGDN : case PGUP : case PGDN :
                case HOME  : case END   : case UP   : case DOWN :
                case LEFT  : case RGT   : case INS  : case DEL  :
                case CR    : case EXIT_K : 
                    break;
                default :
                    k=0;
            }
        }
        hadanedit=0;
        switch(k) {
            case 0 :
                break;
            case PRINT :
                croffbot=0;
                if (readrecnum(tb->sn,currec+1)) {
                    G_tb=tb;
                    subaction("PRINTKEY",1);
                    G_tb=NULL;
                    numrec=getnumrec(tb->sn);
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case HOME :
                croffbot=0;
                xpos=0;
                if (G_numdffld) xpos=G_deffld[0]-1;
                break;

            case END :
                croffbot=0;
                xpos=(tb->numf*tb->cols)-1;
                if (G_numdffld) xpos=G_deffld[G_numdffld-1]-1;
                dir=0;
                break;

            case CPGUP :
                if (currec>0) {
                    currec=0;
                    toprec=0;
                    ypos=0;
                    xpos=0;
                    if (G_numdffld) xpos=G_deffld[0]-1;
                    tabredraw(tb,toprec,0,1);
                }
                croffbot=0;
                break;

            case CPGDN :
                if (currec<=numrec) {
                    currec=numrec-1;
                    toprec=currec-((tb->depth*tb->cols)-1);
                    if (toprec<0) toprec=0;
                    ypos=(currec-toprec)%tb->depth;
                    xpos=(tb->cols-1)*tb->numf;
                    if (G_numdffld) xpos=G_deffld[0]-1;
                    tabredraw(tb,toprec,0,1);
                }
                croffbot=0;
                break;

            case PGUP :
                if (currec>0) {
                    currec-=(tb->depth*tb->cols);
                    toprec-=(tb->depth*tb->cols);
                    if (toprec<0) {
                        toprec=0;
                        currec=0;
                        ypos=0;
                        xpos=0;
                    }
                    tabredraw(tb,toprec,0,1);
                }
                croffbot=0;
                break;

            case PGDN :
                if (currec<=numrec) {
                    currec+=(tb->depth*tb->cols);
                    toprec+=(tb->depth*tb->cols);
                    if (currec>=numrec) {
                        currec=numrec-1;
                        toprec=currec-((tb->depth*tb->cols)-1);
                        if (toprec<0) toprec=0;
                        ypos=(currec-toprec)%tb->depth;
                        xpos=0;
                    }
                    tabredraw(tb,toprec,0,1);
                }
                croffbot=0;
                break;

            case CUP :
                // Control UP only moves up if NOT on last
                // record and lastkey was CR off bottom
                if ((currec<(numrec-1))||(croffbot==1)) { // last record ? 
                    if (ypos>0) {
                        ypos--;
                        currec--;
                    } else {
                        if (xpos>=tb->numf) {
                            xpos-=tb->numf;
                            ypos=tb->depth-1;
                            currec--;
                        } else {
                            if (toprec!=0) {
                                toprec--;
                                currec--;
                                tabredraw(tb,toprec,0,(toprec!=0));
                            }
                        }
                    }
                }
                croffbot=0;
                break;
            case UP : 
                if (ypos>0) {
                    ypos--;
                    currec--;
                } else {
                    if (xpos>=tb->numf) {
                        xpos-=tb->numf;
                        ypos=tb->depth-1;
                        currec--;
                    } else {
                        if (toprec!=0) {
                            toprec--;
                            currec--;
                            tabredraw(tb,toprec,0,(toprec!=0));
                        }
                    }
                }
                croffbot=0;
                break;
            case DEL :
                if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                    if (numrec>0) {
                        delrec(tb->sn,currec+1);
                        tabredraw(tb,toprec,0,1);
                        numrec=getnumrec(tb->sn);
                        if (currec>numrec-1) {
                            sendmsg("OUTPUT1",MESSAGE_OF);
                            sendmsg("INPUT1",MESSAGE_P,UP);
                            sendmsg("INPUT1",MESSAGE_P,5000);
                        }
                    }
                } else {
                    beep();
                }
                croffbot=0;
                break;
            case INS :
                if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                    xpos=(xpos/tb->numf)*tb->numf;
                    if (xpos<0) xpos=0;
                    inputrec(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos);
                    tabredraw(tb,toprec,0,1);
                    numrec=getnumrec(tb->sn);
                } else {
                    beep();
                }
                croffbot=0;
                break;
            case DOWN :
                if (currec<(numrec-1)) {
                    if (ypos<tb->depth-1) {
                        ypos++;
                        currec++;
                    } else {
                        if (xpos<(tb->numf*(tb->cols-1))) {
                            xpos+=tb->numf;
                            if (xpos<0) xpos=0;
                            ypos=0;
                            currec++;
                        } else {
                            if (currec<numrec-1) {
                                toprec++;
                                currec++;
                                tabredraw(tb,toprec,1,(currec<numrec-1));
                            }
                        }
                    }
                }
                croffbot=0;
                break;
            case CR :
                   if ((xpos==lastfield(tb))||(G_numdffld==1)||(xpos==G_deffld[G_numdffld-1]-1)) {
                    dir=(CHAR)xpos;
                       if (currec<numrec-1) {
                           if (ypos<tb->depth-1) {
                               currec++;
                               ypos++;
                               xpos=(xpos/tb->numf)*tb->numf;
                            if (xpos<0) xpos=0;
                           } else {
                               if (xpos<(tb->numf*(tb->cols-1))) {
                                   xpos+=tb->numf;
                                   xpos=(xpos/tb->numf)*tb->numf;
                                if (xpos<0) xpos=0;
                                   ypos=0;
                                   currec++;
                               } else {
                                   if (currec<numrec-1) {
                                       toprec++;
                                       currec++;
                                    tabredraw(tb,toprec,1,(currec<numrec-1));
                                       xpos=(xpos/tb->numf)*tb->numf;
                                    if (xpos<0) xpos=0;
                                   }
                               }
                            if ((G_numdffld==1)||(dir==G_deffld[G_numdffld-1]-1))
                                xpos=G_deffld[0]-1;
                           }
                           if (currec<numrec-1) croffbot=0; else croffbot=1;
                    }
                    if (G_numdffld==1) xpos=G_deffld[0]-1;
                    dir=1;
                   } else {
                    dir=4;
                       if (xpos<(tb->numf*tb->cols)-1) xpos++;
                   }
                break;
            case LEFT :
                   if (xpos>0) {
                       xpos--;
                       if ((xpos%tb->numf)==tb->numf-1) {
                           currec-=tb->depth;
                       }
                   }
                dir=3;
                croffbot=0;
                break;
            case RGT : 
                   if (((xpos%tb->numf)!=tb->numf-1)||(currec<numrec-tb->depth)) {
                       if (xpos<(tb->numf*tb->cols)-1) {
                           xpos++;
                        if ((xpos%tb->numf)==0) currec+=tb->depth;
                    }
                }
                dir=2;
                croffbot=0;
                break;

            case EXIT_K :
                flushtab();
                G_exitkey=EXIT_K;
                xit=1;
                croffbot=0;
                break;

            case LANGSWITCH :
                if (fl!=G_formloaded) {
                    G_finredraw=1;    
                }
                if (G_form.numitem==G_form.curitem) {
                    flushtab();
                    xit=1;
                }
                croffbot=0;
                break;

            default :
                croffbot=0;
                if (((G_form.items[tb->fid[xpos%tb->numf]].class&FF_DISP)==FF_DISP)
                ||  ((G_form.items[tb->fid[xpos%tb->numf]].class&FF_WAIT)==FF_WAIT)) {
                    dobeep=1;
                } else {
                    if (numrec>=1) {
                        hk=G_hotkeys;    
                        G_hotkeys=0;
                        if ((k=editfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf,k))!=0)
                            {
                                    // Multi-tasking for Austria
                            sendmsg("DBM",MESSAGE_BT);        // Begin Transaction
                            sendmsg("DBM",MESSAGE_L);        // Lock
                            if (upnamedatest(tb->sn))
                                {
                                sendmsg("DBM",MESSAGE_CT);    // Commit transaction
                                }
                            else
                                {
                                sendmsg("DBM",MESSAGE_RB);    // Roll back (ignore changes)
                                }
                            numrec=getnumrec(tb->sn);
                            tabredraw(tb,toprec,0,1);
                        }
                        G_hotkeys=hk;
                        hadanedit=1;        
                        switch(k) {
                            case CPGUP : case CPGDN : case PGUP : case PGDN :
                            case HOME  : case END   : case UP   : case DOWN :
                            case LEFT  : case RGT   : case INS  : case DEL  :
                            case CR    : case EXIT_K :
                                if (G_pickkey==CR) {
                                    sendmsg("OUTPUT1",MESSAGE_OF);
                                    sendmsg("INPUT1",MESSAGE_P,CR);
                                    sendmsg("INPUT1",MESSAGE_P,5000);
                                    suppress=(CHAR)k;
                                } else {
                                    sendmsg("OUTPUT1",MESSAGE_OF);
                                    sendmsg("INPUT1",MESSAGE_P,k);
                                    sendmsg("INPUT1",MESSAGE_P,5000);
                                }
                                break;
                            case 0 :
                            case ESC   :
                                break;
                            default :
                                sendmsg("OUTPUT1",MESSAGE_OF);
                                sendmsg("INPUT1",MESSAGE_P,CR);
                                   sendmsg("INPUT1",MESSAGE_P,5000);
                        }
                    }
                    else {
                        if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                            xpos=(xpos/tb->numf)*tb->numf;
                            if (xpos<0) xpos=0;
                            inputrec(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos);
                            tabredraw(tb,toprec,0,1);
                            numrec=getnumrec(tb->sn);
                        }
                        else {
                            dobeep=1;
                        }
                    }
                }
        }
        if (fl!=G_formloaded) {
            tablecur(tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1),tb);
            fl=G_formloaded;
            if (!gettabledata(tb)) {
                FREE(tb);
                RETURN;
            }
            tablebdr(tb);
            numrec=getnumrec(tb->sn);
            if (cr!=numrec) {
                  G_prevnumrecs=(-100);
                   cr=numrec=getnumrec(tb->sn);
            }
            G_wtb=tb;
            G_wxpos=xpos;
            G_wypos=ypos;
            G_wcurrec=currec;
            G_wnumrec=numrec;
            G_wtoprec=toprec;
            G_intable=1;
            tabredraw(tb,toprec,0,0);
            checkflds();
            dobeep=0;
        } else if (ar!=G_actionrun) {
            if (k==LANGSWITCH) {
                numrec=getnumrec(tb->sn);
                fillfields(&G_form);
                   numrec=getnumrec(tb->sn);
                G_wtb=tb;
                G_wxpos=xpos;
                G_wypos=ypos;
                G_wcurrec=currec;
                G_wnumrec=numrec;
                G_wtoprec=toprec;
                   if (G_finredraw==1) G_finredraw=0;
            }
        }
        if (dobeep) {
            if (k!=LANGSWITCH) beep();
            dobeep=0;
        }
        checkflds();
        setcheck(tb,&xpos,dir);
        outfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf);
        tablecur(tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],1,tb);
        dir=1;
        if (G_form.curitem==G_form.numitem) xit=1;
    }
    sendmsg("INPUT1",MESSAGE_D,finred);
    tablecur(tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1),tb);
    strcpy(G_alsosel,"0");
    sendmsg("DBM",MESSAGE_sl,G_store[tb->sn].name,G_alsosel);
    FREE(tb);
    RETURN;
}

// **************************************************************************
// tabproc.c <end-of-file>

