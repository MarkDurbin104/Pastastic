/****************************************************************************
* Project     : GPA
* File        : message.c
* Description : Routines to do all sorts of things with devices
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:33:04  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/message.c_v  $
* 
*    Rev 1.1   Nov 03 1995 11:33:04   JGRAY
* Annotations
* 
****************************************************************************/
#define MESSAGE_C_FILE     /* for the benefit of include routing */
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>

#include "gpasizes.h"      // define field sizes
#include "types.h"         // structure and type definitions
#include "config.h"        //
#include "control.h"       //
#include "lang.h"          //
#include "actions.h"       //
#include "message.h"       //
#include "formhand.h"      //
#include "formproc.h"      //
//~~~~~~~DO NOT REMOVE THIS LINE
#ifdef TEXTMODE  
#include "scrdev.h"
#include "skbddev.h"
#else
#include "vfondev.h"
#include "kbddev.h"
#endif // def TEXTMODE
#include "pdxdev.h"        //
#include "ossdev.h"        //
#include "commdev.h"       //
#ifdef __TURBOC__
#include "diskdev.h"       //
#ifdef WIEN
#include "scaledev.h"      //
#endif // def WIEN
#include "caprndev.h"      //
#else
#include "prcomdev.h"      //
#include "prndev.h"        //
#endif
//#include "hercdev.h"
//#include "scaledev.h"
//#include "mousedev.h"
//#include "8255dev.h"
//#include "commdev.h"
//#include "stampdev.h"
//~~~~~~~DO NOT REMOVE THIS LINE

extern CHAR *G_keyname[];
INT G_dontsendonoff=0;
#define MAXNUMBK 50 // Taiwan
/// #define MAXNUMBK 1
typedef struct {
    INT k ;                     //???? quick key
    INT x ;                     //
    INT y ;                     //
    INT x1;                     //???? bottom left 
    INT y1;                     //????  "      "
    CHAR s[40];                 //???? displayed text 
    CHAR st;                    //????
} BUTKEY;
BUTKEY G_butkey[MAXNUMBK];      // ???? add dynamic allocation - Tom
INT G_numbk=0;
CHAR G_tline[80];
INT G_maxdev=0;

//*********************************************************
//S find form item at position x,y. Returns form or -1 for none
//P integer x position
//P integer y position
//R integer -1 if nothing doing or the item number if that is positioned at x,y

INT actatpos(INT x,INT y)
{
    INT i;
    PFORMF f;
    ENTRY(2510);
    for (i=0;i<G_form.numitem;i++)
        {
        f=&(G_form.items[i]);
        if (((x==f->pos.x)&&(y==f->pos.y)))
            {
            RETURNV(i);
            }
        }
    RETURNV(-1);
}

//*********************************************************
//S find device number given a device name and group
//P string name to search for
//P string group to search for
//R device number or -1

INT finddg(CHAR *name,CHAR *group)
{
    INT i;
    ENTRY(2520);
    for (i=0;i<NUMDEV;i++)
        {
        if (G_device[i].iu) {        // if in use
            if (!strcmp(group,G_device[i].g)) {
                if (!strcmp(name,G_device[i].n)) RETURNV(i);
            }
        }
    }
    RETURNV(-1);
}

//*********************************************************
//S search for a device from a specified idx
//D first attempts a group match from the specified index
//D then attempts a name match if search all was specified.
//P char str name to find
//P integer index to search from - set to -1 to search all devices
//R integer index of identified device or -1 for failed

INT finddev(CHAR *name,INT idx)
{
    INT i;
    LONG *a,*b;
    ENTRY(2530);
    if ((idx<(-1))||(idx>=G_maxdev))        // validate idx - a bit unusual for this code :JGQ
        RETURNV(-1);

    a=(LONG*)name;
    for (i=idx+1;i<G_maxdev;i++)            // search through remaining devices above the one we know
        {
        if (G_device[i].iu)
            {
            b=(LONG*)G_device[i].g;         // compare group name
            if ((*a==*b)&&(*(a+1)==*(b+1))) // I'd rather use memcmp - :JGQ
                RETURNV(i);
            }
        }
    if (idx>(-1))
        RETURNV(-1);                        // reply as no device found if start point specified and no group match
    for (i=idx+1;i<G_maxdev;i++)            // by definition idx must be -1 if we got here
        {
        if (G_device[i].iu)
            {
            b=(LONG*)G_device[i].n;         // compare device name
            if ((*a==*b)&&(*(a+1)==*(b+1)))
                RETURNV(i);
        }
    }
    RETURNV(-1);
}

//*********************************************************
//S search device table for 'name' and return index if found
//P device name to search for
//R returns positive integer or 0 for failed to find

INT devinlist(CHAR *name)
{
    INT i;
    ENTRY(2540);
    for (i=0;i<G_numdt;i++)
        {
        if (!strcmp(name,G_devtab[i]->name))
            RETURNV(i+1);
        }
    RETURNV(0);
}

//*********************************************************
//S add a device to the G_device list
//P char string device name
//P char string device group
//P integer device table number
//R returns new device number unless table full in which case returns -1

INT adddev(CHAR *name,CHAR *group,INT ofs)
{
    INT i;
    ENTRY(2550);
    for (i=0;i<NUMDEV;i++)
        {
        if (!G_device[i].iu)
            {
            G_device[i].iu=1;
            strcpy(G_device[i].g,group);
            strcpy(G_device[i].n,name);
            G_device[i].d=G_devtab[ofs];        // set pointer to device header
            G_maxdev=max((i+1),G_maxdev);
            RETURNV(i);
            }
        }
    RETURNV(-1);
}

//*********************************************************
//S add, subtract or substitute a device
//P char string device name
//P char string device group
//P char integer action
//R FALSE failed, TRUE Ok

INT asigndev(CHAR *name,CHAR *g,CHAR mode)
{
    INT i,j;
    CHAR group[9];
    ENTRY(2560);
    if ((g==NULL)||(*g==0))                 // bomb out if not valud group
        return(0);
    memset(group,0,8);                      // ???? why do this - Tom
    strcpy(group,g);
    if ((i=devinlist(name))==0)             // Check G_devtab - bomb out if not valid
        RETURNV(i);                         // returns FALSE
    i--;                                    // decr i because devinlist reply counts from 1
    adddevname(name);
    switch (mode)
        {
        case '+' :                    // add a device
            if (finddg(name,group)>=0)
                RETURNV(0);
            adddev(name,group,i);
            break;
        case '-' :                    // subtract a device (mark not in use)
            if ((j=finddg(name,group))<0) RETURNV(0);
            G_device[j].iu=0;
            break;
        case 's' :
        case 'S' :                    // substitute group   ???? why group - Tom
            j=0;
            while ((j=finddev(group,j))>=0) G_device[j].iu=0;
            adddev(name,group,i);
            break;
    }
    RETURNV(1);
}
//*********************************************************
//S Pass task on to device's controlling function
//D messages so passed on are one of:
//D MESSAGE_P, MESSAGE_RO, 
//D MESSAGE_AN, MESSAGE_SC, 
//D MESSAGE_3, MESSAGE_BT, MESSAGE_o
//P integer device id
//P integer message_id
//P variable set of parameters
//R return device message reply

LONG passon(INT i,INT mtype,...)
{
    LONG r=0;
    va_list ap;
    ENTRY(2575);
    va_start(ap,mtype);
    r=((G_device[i].d->control)(mtype,ap));
    va_end(ap);
    RETURNV(r);
}
//*********************************************************
//F addbkey
//S add a button key
void addbkey(INT k,INT x,INT y,INT x1,INT y1,CHAR *s,INT st)
{
    ENTRY(2580);
    if (G_numbk>=MAXNUMBK) RETURN;            //???? very friendly, no failure indication - Tom
    G_butkey[G_numbk].k =k ;
    G_butkey[G_numbk].x =x ;
    G_butkey[G_numbk].y =y ;
    G_butkey[G_numbk].x1=x1;
    G_butkey[G_numbk].y1=y1;
    G_butkey[G_numbk].st=(CHAR)st;
    strcpy(G_butkey[G_numbk].s,s);
    G_numbk++;
    sendmsg("INPUT3",MESSAGE_A,x,y,x+x1,y+y1,k);
    RETURN;
}
//*********************************************************
//F runbact
//S run a button action
void runbact(INT k)
{
    INT i,x,y,x1,y1,idx,tcf;
    ENTRY(2590);
    for (i=0;i<G_numbk;i++)
        {
        if (G_butkey[i].k==k)
            {
            x =G_butkey[i].x;
            y =G_butkey[i].y;
            idx=actatpos(x,y);
            if ((isaction(G_form.items[idx].func)==0)
            &&  (isform  (G_form.items[idx].func)==(-1L))) RETURN;
            x1=G_butkey[i].x1;
            y1=G_butkey[i].y1;
            if (idx!=(-1))
                {
                G_formvars[idx][0]^=1;
                sendmsg("OUTPUT1",MESSAGE_A,G_form.items[idx].attrib);
                sendmsg("OUTPUT1",MESSAGE_S,G_form.items[idx].size);
                sendmsg("OUTPUT1",MESSAGE_BT,x,y,x1+x,y1+y,(G_formvars[idx][0]&1)^1,G_butkey[i].s);
                G_keybutt=k;
                tcf=G_form.curitem;
                G_form.curitem=(CHAR)idx;
                runaction(G_form.items[idx].func);
                if (G_form.curitem==(CHAR)idx) G_form.curitem=(CHAR)tcf;
                G_keybutt=0;
                for (i=0;i<G_numbk;i++)
                    {
                    x =G_butkey[i].x;
                    y =G_butkey[i].y;
                    idx=actatpos(x,y);
                    if (idx!=(-1))
                        {
                        G_butkey[i].st=(G_formvars[idx][0]&(CHAR)1)^(CHAR)1;
                        x1=G_butkey[i].x1;
                        y1=G_butkey[i].y1;
                        sendmsg("OUTPUT1",MESSAGE_A,G_form.items[idx].attrib);
                        sendmsg("OUTPUT1",MESSAGE_S,G_form.items[idx].size);
                        sendmsg("OUTPUT1",MESSAGE_BT,x,y,x1+x,y1+y,G_butkey[i].st,G_butkey[i].s);
                        }
                    }
                }
            RETURN;
            }
        }
    RETURN;
}
//*********************************************************
//S Issue one of a series of graphics commands - all bitmap-ish related
//D     D duplicate string as G_tfields
//D     P output bitmap 
//D     R Flip two images 
//D     A Animate image
//D     S Rotate image 
//D     G Apply bezel 
//D     B Add button 
//D     default output text
//P integer device ID
//P integer x coord
//P integer Y coord
//P string pointer to task to perform concat with data string

void graphic(INT i,INT x,INT y,CHAR *s)
{
    INT x1,y1,num,l,k;
    CHAR *t;
    s++;
    ENTRY(2595);
    switch (*s)
        {
        case 'D' :
            if (G_tflds!=NULL)
                FREE(G_tflds);
            G_tflds=STRDUP(s+1);
            break;
        case 'P' :
            passon(i,MESSAGE_P,x,y,s+1);
            break;
        case 'R' :
            s++;
            x1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            strcpy(G_tline,s);
            s=t=G_tline;
            while ((*s)&&(*s!=','))
                s++;
            if (*s==',')
                {
                *s=0;
                passon(i,MESSAGE_RO,x,y,x1,t,s+1);
                }
            break;
        case 'A' :
            s++;
            x1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            y1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            passon(i,MESSAGE_AN,x,y,x1,y1,s);
            break;
        case 'S' :
            s++;
            x1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            num=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            y1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            passon(i,MESSAGE_SC,x,y,x1,num,y1,s);
            break;
        case 'G' :
            s++;
            x1=atoi(s);
            while (isdigit(*s))
                s++;
            y1=atoi(s+1);
            passon(i,MESSAGE_3,x,y,x1+x,y1+y);
            break;
        case 'B' :
            s++;
            x1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            y1=atoi(s);
            while (isdigit(*s))
                s++;
            s++;
            strcpy(G_tline,s);
            t=G_tline;
            while ((*s)&&(*s!=','))
                {
                s++;
                t++;
                }
            if (*s)
                {
                *t=0;
                s++;
                l=(G_formvars[actatpos(x,y)][0]&1)^1;
                passon(i,MESSAGE_BT,x,y,x1+x,y1+y,l,G_tline);
                num=strlen(s);
                if (num==1)
                    {
                    sendmsg("INPUT1",MESSAGE_K,*s,"~B",G_tline);
                    addbkey(*s,x,y,x1,y1,G_tline,l);
                    }
                else
                    {
                    k=0;
                    while ((k<10000)&&(G_keyname[k]!=NULL))
                        {
                        if (!strncmp(s,G_keyname[k],num))
                            {
                            sendmsg("INPUT1",MESSAGE_K,k-176,"~B",G_tline);
                            addbkey(k-176,x,y,x1,y1,G_tline,l);
                            k=10000;
                            }
                        k++;
                        }
                    }
                }
            else
                {
                l=(G_formvars[actatpos(x,y)][0]&1)^1;
                passon(i,MESSAGE_BT,x,y,x1+x,y1+y,l,G_tline);
                }
            break;
        default :
            passon(i,MESSAGE_o,x,y,"%s",s-1);
    }
    RETURN;
}

//*********************************************************
//S Action a message or pass it on
//P char string group name to apply message to - or device name
//P integer message id
//P variable further parameters
//R long reply value

LONG sendmsg(CHAR *g,INT mtype,...)
{
    INT i=0,x,y;
    LONG r=0L;
    CHAR group[9];
    CHAR *s;
    va_list ap;
    ENTRY(2600);
    if ((g==NULL)||(*g==0))
        return(0);
    memset(group,0,8);              // redundant code :JGQ
    strcpy(group,g);
    if ((group[0]=='R')||(group[0]=='H')||(group[0]=='S'))  // Receipt, Remhot, Scales, Hotkey, Swaplang
        {
        if (!strcmp(group,"REMHOT"))
            {                                       // convert any pseudo group REMHOT call into a proper remove hotkey call
            sendmsg("INPUT3",MESSAGE_r);            // remove hot key
            G_numbk=0;
            RETURNV(1);
            }
        else
            if (!strcmp(group,"HOTKEY"))            // process hotkey
                {                                   // pseudo device HOTKEY causes this activity
                va_start(ap,mtype);
                s=va_arg(ap,CHAR *);
                va_end(ap);
                if ((*s=='~')&&(*(s+1)=='B'))
                    {
                    runbact(mtype);
                    }
                else
                    {
                    runaction(s);
                    }
                RETURNV(1);
                }
            else
                if (!strcmp(group,"SWAPLANG"))      // swap language pseduo device SWAPLANG
                    {
                    swaplang();                     // causes swap lang function to process
                    RETURNV(1);
                    }
        }
    if (mtype==MESSAGE_QUEST)                       // special to return boolean based on ~B in message
        {                                           // see justbutt in lang.c :JGQ
        va_start(ap,mtype);
        s=va_arg(ap,CHAR *);
        va_end(ap);
        s=langstr(G_device[finddev(group,i)].n,s);
        RETURNV((*s!='~')&&(*(s+1)!='B'));          // maybe OR not AND check MJD
        }
    else
        if (mtype==MESSAGE_TEXT)
            {
            va_start(ap,mtype);                // get text string for output
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            s=va_arg(ap,CHAR *);
            va_end(ap);
            mtype='o';
            if ((i=finddev(group,i))>=0)
                {
                s=langstr(G_device[i].n,s);
                if (*s=='~')
                    {
                    graphic(i,x,y,s);
                    }
                else
                    {
                    passon(i,MESSAGE_o,x,y,"%s",s);
                    }
                }
            }
        else
            if (mtype==MESSAGE_RS)
                {
                restoreform();
                }
            else
                {
                while ((i=finddev(group,i))>=0) // apply to all devices in specified group, or device explicitely
                    {
                    va_start(ap,mtype);
                    r=((G_device[i].d->control)(mtype,ap));
                    va_end(ap);
                    }
                }
    RETURNV(r);
}

//*********************************************************
//S Set up device table. Read from DEVICE.MAP, defaults used if no DEVICE.MAP
//R memory alloc failure causes FALSE reply, success = TRUE reply

INT initdevices(void)
{
    FILE *fp;
    CHAR s[81],tmp[20];
    CHAR *t;
    ENTRY(2610);

#ifdef TEXTMODE
    G_devtab[G_numdt++]=&dev_scr;
#else
    G_devtab[G_numdt++]=&dev_vfon;
#endif // def TEXTMODE
    G_devtab[G_numdt++]=&dev_oss;
    G_devtab[G_numdt++]=&dev_pdx;
    G_devtab[G_numdt++]=&dev_kbd;
    G_devtab[G_numdt++]=&dev_prn;
    G_devtab[G_numdt++]=&dev_comm;
#ifdef __TURBOC__
    G_devtab[G_numdt++]=&dev_disk;
#ifdef WIEN
    G_devtab[G_numdt++]=&dev_scale;
#endif // def WIEN
#else
//    G_devtab[G_numdt++]=&dev_scale;
#endif
//    G_devtab[G_numdt++]=&dev_herc;
//    G_devtab[G_numdt++]=&dev_mouse;
//    G_devtab[G_numdt++]=&dev_8255;
//    G_devtab[G_numdt++]=&dev_comm;
//    G_devtab[G_numdt++]=&dev_stamp;

    if (!G_numdt)
        RETURNV(0);
    G_device=MALLOC(NUMDEV*sizeof(DEVTABLE));
    if (G_device==NULL)
        RETURNV(0);
    memset(G_device,0,NUMDEV*sizeof(DEVTABLE));
    fp=fopen("device.map","r");
    if (fp==NULL) {
        asigndev("VGA"     ,"OUTPUT1",'S');
        asigndev("PARADOX" ,"DBM"    ,'S');
        asigndev("KBD"     ,"INPUT1" ,'S');
        asigndev("DISK"    ,"DISK"   ,'S');
        asigndev("PRN"     ,"OUTPUT2",'S');
    } else {
        while ((fgets(s,80,fp))!=NULL) {
            t=strtok(s," \n\t,");
            if (t!=NULL) {
                strcpy(tmp,t);
                tmp[9]=0;
                if (strcmp(tmp,"NO_CUSTD")) {
                    t=strtok(NULL," \n\t,");
                    *(t+9)=0;
                    asigndev(tmp,t,'+');
                } else {
                    G_dontsendonoff=1;
                }
            }
        }
        fclose(fp);
    }
    if (finddev("OUTPUT1",0)<0) asigndev("VGA"     ,"OUTPUT1",'S');
    if (finddev("DBM"    ,0)<0) asigndev("PARADOX" ,"DBM"    ,'S');
    if (finddev("INPUT1" ,0)<0) asigndev("KBD"     ,"INPUT1" ,'S');
    if (finddev("DISK"   ,0)<0) asigndev("DISK"    ,"DISK"   ,'S');
    RETURNV(1);
}

//*********************************************************
//S print to stdio the device list

void prdevlist(void)
{
    INT i;
    ENTRY(2620);
    for (i=0;i<G_numdt;i++)
        {
        printf("\n%-8.8s %s",G_devtab[i]->name,G_devtab[i]->ownership);
        }
    printf("\nDEVICES USED\n");

    for (i=0;i<NUMDEV;i++)
        {
        if (G_device[i].iu)
            {
            printf("%-8.8s %-8.8s\n",G_device[i].n,G_device[i].g);
            }
        }
    RETURN;
}

//*********************************************************
//S save a copy of G_device list to G_sdevice
//D mallocs memory for G_sdevice and sets G_devsaved

void savedevices(void)
{
    INT i;
    ENTRY(2630);
    if (G_sdevice!=NULL)
        FREE(G_sdevice);
    G_sdevice=MALLOC(NUMDEV*sizeof(DEVTABLE));
    if (G_sdevice==NULL)
        RETURN;
    memset(G_sdevice,0,NUMDEV*sizeof(DEVTABLE));
    for (i=0;i<NUMDEV;i++)
        {
        G_sdevice[i].iu=G_device[i].iu;
        strcpy(G_sdevice[i].g,G_device[i].g);
        strcpy(G_sdevice[i].n,G_device[i].n);
        G_sdevice[i].d=G_device[i].d;
        }
    G_devsaved=1;            //???? why do we need this - its a flag for the next function
    RETURN;
}

//*********************************************************
//S restore saved device list from G_sdevice to G_device

void restdevices(void)
{
    INT i;
    ENTRY(2640);

    if (!G_devsaved)
        RETURN;
    if (G_sdevice==NULL)
        RETURN;
    for (i=0;i<NUMDEV;i++)
        {
        G_device[i].iu=G_sdevice[i].iu;
        strcpy(G_device[i].g,G_sdevice[i].g);
        strcpy(G_device[i].n,G_sdevice[i].n);
        G_device[i].d=G_sdevice[i].d;
        }
    FREE(G_sdevice);
    G_sdevice=NULL;
    RETURN;
}

//*********************************************************
//S Free G_device and G_sdevice

void closedevices(void)
{
    ENTRY(2650);
    if (G_device!=NULL)  { FREE(G_device);  G_device=NULL;  }
    if (G_sdevice!=NULL) { FREE(G_sdevice); G_sdevice=NULL; }
//  known internal devices for optimised linker 
//    otherwise it doesn't include the device obj's in the exe
//    no such problems for user added devices !
//~~~~~~~DO NOT REMOVE THIS LINE
//~~~~~~~DO NOT REMOVE THIS LINE
    RETURN;
}
// **************************************************************************
// message.c <end-of-file>

