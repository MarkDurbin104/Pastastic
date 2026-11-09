/****************************************************************************
* Project     : GPA
* File        : lang.c
* Description : language support routines.
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:15:30  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/lang.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:15:30   JGRAY
*  
* 
****************************************************************************/
#define LANG_C
#include <string.h>
#include <stdlib.h>
//#include <search.h>

#include "gpasizes.h"
#include "types.h"
#include "config.h"
#include "control.h"
#include "message.h"
#include "formhand.h"
#include "formproc.h"
#include "menuproc.h"
#include "tabproc.h"
#include "keydef.h"
//#include "gprim.h"
#include "lang.h"

INT G_swaplang=0;


//************************************************************
//S scan current form if first TEXT item langstr is a ~B return TRUE
//P parameter
//R reply 

INT justbutt(PFORM form)
{
    INT i,b=0;
    PFORMF f;
    CHAR *s;
    ENTRY(2420);
    for (i=0;i<form->numitem;i++)
        {
        f=&(form->items[i]);
        if (f->class==FF_TEXT)
            {
            s=langstr("OUTPUT1",f->item);
            if ((*s=='~')&&(*(s+1)=='B'))
                b=1;
            }
        else
            {
            if (f->class!=FF_DISP)
                RETURNV(0);
            }
        }
    RETURNV(b);
}

//************************************************************
//S add device to G_devs table
//D function not used? :JGQ
//P char string device or group name 

void adddevname(CHAR *DevName)
{
    INT i;
    ENTRY(2430);
    for (i=0;i<G_numdn;i++)
        if (!strcmp(G_devs[i],DevName))
            RETURN;
    strcpy(G_devs[G_numdn++],DevName);
    RETURN;
}

//************************************************************
//S put supplied language into table at current lang position
//D not fully thought out - table not used I think :JGQ
//P char string language name

void addlangname(CHAR *n)
{
    ENTRY(2440);
    strcpy(G_langs[G_lang],n);
    RETURN;
}

//************************************************************
//S sets up language mapping - beware - table gets cleard down by other routines
//P char string device name e.g. VGA
//P integer language Id number 0 to G_numlang-1
//P char string text file name
//P char string font file name

void setuplmap(CHAR *DevName,INT l,CHAR *TextFileName,CHAR *FontFileName)
{
    INT i;
    ENTRY(2450);
    if (G_numlm==0)                 // if not set before
        {
        G_numlm=LANGUAGESQ;         // flag first run through
        for (i=0;i<G_numlm;i++)     // reset flag
            G_langmaps[i].n=(-1);
        }
    for (i=0;i<G_numlm;i++)         // scan for match on device name type
        {
        if (!strcmp(DevName,G_langmaps[i].d))
            {
            G_langmaps[i].n=l;          // override map info
            strcpy(G_langmaps[i].t,TextFileName);  // with l, t & f
            strcpy(G_langmaps[i].f,FontFileName);
            RETURN;
            }
        }
    for (i=0;i<G_numlm;i++)         // not found so scan for spare entry
        {
        if (G_langmaps[i].n==(-1))  // indicates unused entry
            {
            strcpy(G_langmaps[i].d,DevName);
            strcpy(G_langmaps[i].t,TextFileName);
            strcpy(G_langmaps[i].f,FontFileName);
            G_langmaps[i].n=l;
            RETURN;
            }
    }
    RETURN;
}

//************************************************************
//S set language for specified device or group
//D Does nothing if device not actually set up in table
//P char string device name

void setoplang(CHAR *DevName)
{
    INT i;
    static CHAR tmp[10];        // current store for device or name
    ENTRY(2460);

    if (!strcmp(DevName,tmp))
        RETURN;
    strcpy(tmp,DevName);

    for (i=0;i<G_numlm;i++)             // scan for device match
        {
        if (!strcmp(DevName,G_langmaps[i].d)) // found good un'
            {
//          if (G_textfile!=NULL) 
//              FREE(G_textfile);
//          G_textfile=STRDUP(G_langmaps[i].t);
            strcpy(G_textfile,G_langmaps[i].t); // set textfile name
//          if (G_fontfile!=NULL) 
//              FREE(G_fontfile);
//          G_fontfile=STRDUP(G_langmaps[i].f);
            strcpy(G_fontfile,G_langmaps[i].f); // set fontfile name
            freetext();
            loadtext(G_system);                 // force system to load text
            sendmsg(DevName, MESSAGE_F, G_fontfile);    // force system to load font
            RETURN;
        }
    }
    RETURN;
}

//************************************************************
//S force redraw of form

void restoreform(void)
{
    ENTRY(2470);
    if (G_incalc)
        G_calcredraw=1;
    if (G_incal)
        G_calredraw =1;
    G_needinputredraw=1;
    if (G_form.type==F_MENU)
        {
        drawmenu();
        menucur();
        }
    else
        {
        if ((G_form.type==F_SERVE)||(G_form.type==F_PROMPT)||(G_form.type==F_NORM))
            {
            redrawform();
            G_finredraw=(-1);
            if (!strcmp(G_form.name,"logon"))
                sendmsg("OUTPUT1",MESSAGE_D,1,23);  // draw logo
            }
        }
    RETURN;
}

//************************************************************
//S cycle language to next in list up to G_numlang if allowed (G_canswitch)

void swaplang(void)
{
    INT i;
    ENTRY(2480);
    if (!G_canswitch)
        RETURN;
    if (G_lang<(G_numlang-1))
        G_lang++;
    else
        G_lang=0;
    readlang(G_lang);
    freetext();
    loadtext(G_system);
    sendmsg("OUTPUT1",MESSAGE_F,G_fontfile);
    sendmsg("INPUT1",MESSAGE_LOADKEYS);
    addlangname(G_name);        // store current language name - probably not set
    for (i=0;i<G_numlm;i++)     // make table effectively empty
        G_langmaps[i].n=(-1);
    setuplmap(G_scrname,G_lang,G_textfile,G_fontfile);  // Store new current set as first item in array
    G_swaplang=1;
    restoreform();
    G_swaplang=0;
    RETURN;
}

//************************************************************
//S perform a string comparison given two pointers to pointers
//D not used by anything as far as I can see.
//D ?Used by textstr to find string name - original comment
//P pointer to string pointer 1
//P pointer to string pointer 2
//R cdecl type integer string compare result

INT _cdecl scmp(const void *a,const void *b)
{
    ENTRY(2740);
    RETURNV(strcmp(*((CHAR **)a),*((CHAR **)b)));
}

//************************************************************
//S offset string id by G_nut
//P integer text id to be offset
//R address of string text, current language, duly looked up

CHAR *langtext(INT idx)
{
    ENTRY(2490);
    idx+=G_nut;
    RETURNV(atextstr(idx));
}

//************************************************************
//S set language and return string numbered according to P2[5]
//D Confused - you will be.  P1 can be supplied as a NAME or as a GROUP
//D but the s/w hereon in assumes NAME only
//P char string output device to set language for
//P char string formatted TEXTnnnn or TEXT_nnnn where nnnn is the string no desired
//R pointer to string requested

CHAR *langstr(CHAR *name,CHAR *s)
{
    INT j=0;
    ENTRY(2500);
    if ((name==NULL)||(s==NULL)||(strlen(s)<4))
        RETURNV(s);
     setoplang(name);
    if (*(s+4)=='_')
        j=atoi(s+5);
    else
        j=atoi(s+4);
    if (j>(G_tcnt-G_nut))
        RETURNV(s);
    RETURNV(langtext(j));
}
// **************************************************************************
// lang.c <end-of-file>

