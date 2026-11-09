/****************************************************************************
* Project     : GPA
* File        : formhand.c
* Description : Support routines for form handling
* 
* $Revision:   1.2  $  $Date:   Nov 01 1995 15:15:06  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/formhand.c_v  $
* 
*    Rev 1.2   Nov 01 1995 15:15:06   JGRAY
*  
* 
****************************************************************************/
#define FORMHAND_C

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <stdlib.h>
#include <ctype.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpasizes.h"
#include "types.h"
#include "formproc.h"
#include "formhand.h"
#include "control.h"
#include "config.h"
#include "message.h"

//*********************************************************
//F freeformidx
//S free globals G_fid & G_formspace, set G_numidx=0

void freeformidx(void)
{
    INT i;

    ENTRY(1290);
    if (G_fid!=NULL) {
        for (i=0 ; i<G_numidx ; i++)
        {
            if (G_fid[i]->items!=NULL)
            {
                FREE(G_fid[i]->items);
            }
            if (G_fid[i]!=NULL)
            {
                FREE(G_fid[i]);
            }
        }
        FREE(G_fid);
        G_fid=NULL;
    }
    if (G_formspace!=NULL) {
        FREE(G_formspace);
        G_formspace=NULL;
    }
    G_numidx=0;
    RETURN;
}

//*********************************************************
//S form name compare for use by qsort()
//P pointer to FORM a
//P pointer to FORM b
//R integer strcmp results

INT ficmp(PFORM a,PFORM b)
{
    ENTRY(1300);
    RETURNV(strcmp(a->name,b->name));
}

//*********************************************************
//S get the form index number for form 'name'
//D If the *N.DAT form file has not been loaded (G_numidx==0) then
//D open the form file and load it into memory.
//P char string form name
//R integer -1 fail or form number

INT getformidx(CHAR *name)
{
    INT i,fd;
    INT16 *base;
    LONG ofs;
    LONG len;
    CHAR tmp[80];

    ENTRY(1310);
    if (G_numidx==0) {
        sprintf(tmp,"%s%sN.DAT",G_config,G_system);
        if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) RETURNV(-1);
        len=filelength(fd);
        read(fd,tmp,(sizeof(INT16)*4));
        base=(INT16*)tmp;
        if (*base!=0x5A4B) RETURNV(-1);
        base++;
        G_fversion =*(base++);
        G_formsize =*(base++);
        G_fieldsize=*(base);
        ofs=(LONG)(sizeof(INT16)*4);
        G_fid=MALLOC(0x3000*sizeof(PFORM));
        while (ofs<len) {
            G_fid[G_numidx]=MALLOC(sizeof(FORM));
            read(fd,G_fid[G_numidx],G_formsize);
            ofs+=G_formsize;
            G_fid[G_numidx]->items=MALLOC(G_fid[G_numidx]->numitem*sizeof(FORMF));
            read(fd,G_fid[G_numidx]->items,(G_fid[G_numidx]->numitem*G_fieldsize));

            // Fix a bug in GPAD -- This code should be removed
            for (i=0;i<G_fid[G_numidx]->numitem;i++) {
                if (G_fid[G_numidx]->items[i].class==FF_TABL) {
                    strcpy(G_fid[G_numidx]->items[i].name,"NONE    ");
                    G_fid[G_numidx]->items[i].type[0]=0;
                }
            }
            ofs+=(G_fid[G_numidx]->numitem*G_fieldsize);
            G_numidx++;
        }
        G_fid=REALLOC(G_fid,G_numidx*sizeof(PFORM));
        close(fd);
//        qsort(G_fid,G_numidx,sizeof(PFORM),(QSPTR)ficmp);
    }
    for (i=0;i<G_numidx;i++) 
        if (!strcmp(name,G_fid[i]->name)) RETURNV(i);
    RETURNV(-1);
}

//*********************************************************
//S is a 'name' a form name
//P char string name to check
//R -1 if it wasn't a valid form otherwise 0 or +ive form no. 

INT isform(CHAR *name)
{
    ENTRY(1360);
    RETURNV(getformidx(name));
}

//*********************************************************
//S copy FORM data to temporary store
//D FORM structure members which are pointers are initilaised
//D using MALLOC.
//P integer FORM index number
//P pointer to uninitialised FORM structure
//R TRUE if OK, FALSE if failed e.g. malloc failed

INT getfedata(INT ofs,PFORM sf)
{
    ENTRY(1370);
    if ((ofs<0)||(ofs>G_numidx)) RETURNV(0);
    memcpy(sf,G_fid[ofs],sizeof(FORM));
    if ((sf->items=MALLOC(sf->numitem*sizeof(FORMF)))==NULL) RETURNV(0);
    memcpy(sf->items,G_fid[ofs]->items,sf->numitem*sizeof(FORMF));
    RETURNV(1);
}

//*********************************************************
//S load FORM data to temporary store
//D N.B. compare this with function with getfedata (above) :JGQ 25/10
//P pointer to uninitialised FORM structure
//P integer FORM index number
//R TRUE if Ok, FALSE if failed

INT loadformidx(PFORM sf,INT ofs)
{
    ENTRY(1390);
      RETURNV(getfedata(ofs,sf));
}

//*********************************************************
//S load FORM data to temporary store, index is found
//P pointer to uninitialised FORM structure
//R TRUE if Ok, FALSE if failed

INT loadform(PFORM sf)
{
    ENTRY(1400);
      RETURNV(getfedata(isform(sf->name),sf));
}

//*********************************************************
//S free up all pointers in a FORM structure
//P pointer to initialised FORM structure

void freeform(PFORM f)
{
    ENTRY(1410);
    if (f->items!=NULL)
        FREE(f->items);
    f->items=NULL;
    RETURN;
}

//*********************************************************
//S Re-order form fields l->r t->b
//P pointer to FORM a
//P pointer to FORM b
//R integer result {-2,-1,0,1,2 }
  
INT usort(PFORMF a,PFORMF b)
{
    ENTRY(1420);

    if (a->pos.y>b->pos.y) RETURNV(2);
    if (a->pos.y<b->pos.y) RETURNV(-2);
    if (a->pos.x>b->pos.x) RETURNV(1);
    if (a->pos.x<b->pos.x) RETURNV(-1);
    RETURNV(0);
}

//*********************************************************
//S Re-order form fields t->b l->r
//P pointer to FORM a
//P pointer to FORM b
//R integer result {-2,-1,0,1,2 }

INT fsort(PFORMF a,PFORMF b)
{
    ENTRY(1430);

    if (a->pos.x>b->pos.x) RETURNV(2);
    if (a->pos.x<b->pos.x) RETURNV(-2);
    if (a->pos.y>b->pos.y) RETURNV(1);
    if (a->pos.y<b->pos.y) RETURNV(-1);
    RETURNV(0);
}

//*********************************************************
//F orderform
//S Re-order form fields given type
//P pointer to FORM
//P type

void orderform(PFORM f,INT type)
{
    ENTRY(1440);
    if ((f==NULL)||(f->items==NULL)) return;
    if (type==0)
        qsort(f->items,f->numitem,G_fieldsize,(QSPTR)fsort);
    else
        qsort(f->items,f->numitem,G_fieldsize,(QSPTR)usort);
    RETURN;
}

//********************************* TEXT ****************************
//S load the text information
//D n.b. uses and corrupts G_lasttext - assumedly not a problem here :JGQ 25/10
//P system name, used to build *T.DAT name
//R FALSE failed, TRUE Ok

INT loadtext(CHAR *sys)
{
    INT hadtildi=0;
    FILE *fp;
    CHAR buf[LENOFTEXTINPBUF];
    ENTRY(1340);
    G_nut=0;
    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(G_lasttext,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(G_lasttext,G_textfile);

    if (G_tname!=NULL) freetext();          // language switch, free up old text
    G_tname=MALLOC(TEXTNAMEITEMQ*sizeof(CHAR *));
    G_tcnt=0;
    if (G_tname==NULL) RETURNV(0);
    if ((fp=fopen(G_lasttext,"r"))!=NULL) {
        while (fgets(buf,LENOFTEXTINPBUF,fp)!=NULL) // CORRECTED FROM 160 - :JGQ 26/10
            {
            buf[strlen(buf)-1]=0;
            G_tname[G_tcnt]=STRDUP(buf);
            G_tname[G_tcnt][8]=0;
            G_tcnt++;
            if (!hadtildi) {
                if (buf[0]=='~') hadtildi=1;
                G_nut++;
            }
        }
    }
    if (!hadtildi) {
        G_nut=0;
    }
    G_tname=REALLOC(G_tname,G_tcnt*sizeof(CHAR *));
/*
    while (G_tcnt<nt) {
        restpblk(G_lasttext,buf,(LONG)G_tcnt*100L+(LONG)sizeof(INT)*2,100L);
        if (G_tcnt<G_nut) {
            G_tname[G_tcnt]=STRDUP(buf);
            if (G_tname[G_tcnt]==NULL) RETURNV(0);
        }
        if ((newt)&&(buf[9]=='~')) {
            t=&(buf[10]);
            switch (*t) {
                case 'P':
                case 'S':
                case 'A':
                    t++;
                    while (!isalpha(*t)&&(*t)) t++;
                    sendmsg("OUTPUT1",MESSAGE_TL,t);
                    break;
                case 'R':
                    strcpy(tmp,t);
                    t=tmp;
                    t++;
                    while (!isalpha(*t)&&(*t)) t++;
                    u=t;
                    while ((*t!=',')&&(*t)) t++;
                    if (*t) {
                        *t=0;
                        sendmsg("OUTPUT1",MESSAGE_TL,u);
                        sendmsg("OUTPUT1",MESSAGE_TL,t+1);
                    }
                    break;
            }
        }
        G_tcnt++;
    }
*/
    RETURNV(1);
}

//*********************************************************
//S return address of a text string number 'i'
//D No range check on i
//P integer text id 
//R address of the specified string

CHAR *atextstr(INT i)
{
    return(&(G_tname[i][9]));
}

//*********************************************************
//S free the text information buffers

void freetext(void)
{
    INT i;
    ENTRY(1350);
    if (G_tname!=NULL)
        {
        for (i=0;i<G_tcnt;i++)
            {
            if (G_tname[i]!=NULL)
                FREE(G_tname[i]);
            }
        FREE(G_tname);
        G_tname=NULL;
        }
    G_tcnt=0;
    G_nut=0;
    RETURN;
}
// **************************************************************************
// formhand.c <end-of-file>

