/****************************************************************************
* Project     : GPA
* File        : kbddev.c
* Description : Keyboard device driver
* 
* $Revision:   1.4  $  $Date:   Nov 03 1995 11:33:02  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/kbddev.c_v  $
* 
*    Rev 1.4   Nov 03 1995 11:33:02   JGRAY
* Annotations
* 
*    Rev 1.3   Nov 01 1995 15:15:30   JGRAY
*  
* 
****************************************************************************/
#define KBD_DEV_C
#include <ctype.h>
#include <stdio.h>
#include <memory.h>
#include <malloc.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#ifndef __DPMI32__
#define STRICT
#include <windows.h>    
#endif

#include "gpasizes.h"
#include "types.h"
#include "control.h"
#include "message.h"
#include "keydef.h"
#include "config.h"
#include "scancode.h"
#include "realprot.h"
#include "fldproc.h"


#define ENDOFBUF        0x100

typedef struct {
    INT        scan[0x7F*5];
    INT        buf[ENDOFBUF+1];
    INT        start;
    INT        end;
    KLOOPFUNC  loop[32];
    UINT       disabletill;
    ULONG      ticker;
    ULONG      exticker;
    INT        shutdown;
    INT        debug;
    ULONG      inacttime;
} APIBUF;

#pragma option -p-
#include "kbddev.h"

volatile ULONG *G_ticker;
volatile ULONG *G_exticker;
volatile ULONG *G_intacttime;
volatile ULONG G_enticker=0;
volatile ULONG G_ssticker=0;
volatile ULONG G_seticker=0;

INT  L_shutdown=0;
INT  *G_shutdown=&(L_shutdown);
INT  G_dossel;
UINT *G_disabletill;
INT  G_recmode=0;
INT  G_playmode=0;
INT  G_recfd=(-1);
INT  G_recptr=0;


//************************************************************
//S process real mode command by int0x62
//P unsigned int function AX
//P integer CX
//P integer BX

void realcmd(UINT func,INT s,INT o)
{
    _AX=func;
    _BX=o;
    _CX=s;
    geninterrupt(0x62);
}

//************************************************************
//S set up API buffer

void setuprealbuf(void)
{
    LONG h;
    APIBUF *b;

    h=GlobalDosAlloc((LONG)sizeof(APIBUF));
    if (h==0) return;
    b=(APIBUF *)MK_FP((G_dossel=LOWORD(h)),0);
    G_scanmap    = (b->scan);
    G_keybuf     = (b->buf);
    G_kpstart    =&(b->start);
    G_kpend      =&(b->end);
    G_kloop      = (b->loop);    
    G_disabletill=&(b->disabletill);
    G_ticker     =&(b->ticker);
    G_exticker   =&(b->exticker);
    G_shutdown   =&(b->shutdown);
    G_intacttime =&(b->inacttime);
//    G_debug      =&(b->debug);
    realcmd(KBDSETAPIBUF,HIWORD(h),0);
    realcmd(KBDSWITCHON ,0        ,0);
}

//************************************************************
//S switch keyboard off, release G_dossel 

void clearrealmode(void)
{
    realcmd(KBDSWITCHOFF,0        ,0);
    GlobalDosFree(G_dossel);
}

//************************************************************
//S add a keyboard loop function
//P integer priority
//P function pointer 
//R integer -1 no function or no room, otherwise loop array number

INT addklfunc(INT p,FPTR f)
{
    INT i;
    ENTRY(5960);
    if (p==0) p=1;
    if (f==NULL) RETURNV(-1);
    if (G_kloop!=NULL) {
        for (i=0;i<32;i++)
            {
            if (G_kloop[i].func==f)
                {
                G_kloop[i].pri=p;
                G_kloop[i].lt=0;
                G_kloop[i].td=0;
                G_kloop[i].bd=0;
                G_kloop[i].num++;
                RETURNV(i);
                }
            }
        for (i=0;i<32;i++)
            {
            if (G_kloop[i].func==NULL)
                {
                G_kloop[i].pri=p;
                G_kloop[i].lt=0;
                G_kloop[i].td=0;
                G_kloop[i].bd=0;
                G_kloop[i].func=f;
                G_kloop[i].num++;       // not convinced this shouldn't set num to 0 or 1 :JGQ
                RETURNV(i);
            }
        }
    }
    RETURNV(-1);
}

//************************************************************
//S delete a keyboard loop function
//P function pointer used as search key
//R integer -1 if not found, item if found - even if completely removed(!)

INT delklfunc(FPTR f)
{
    INT i;
    ENTRY(5970);
    if (f==NULL) RETURNV(-1);
    if (G_kloop!=NULL) {
        for (i=0;i<32;i++) {
            if ((G_kloop[i].func!=NULL)&&(G_kloop[i].func==f)) {
                G_kloop[i].num--;
                if (!G_kloop[i].num) {
                    G_kloop[i].pri=0;
                    G_kloop[i].lt=0;
                    G_kloop[i].td=0;
                    G_kloop[i].bd=0;
                    G_kloop[i].func=NULL;
                }
                RETURNV(i);
            }
        }
    }
    RETURNV(-1);
}

//************************************************************
//S run all keyboard loop functions

void runklfuncs(void)
{
    INT i;
    static LONG ticker=0;
    realcmd(UPDATEFLAGS,0,0);
    if (G_savescrnto)
        {
        if (*G_intacttime>=G_savescrnto)
            {
            sendmsg("OUTPUT1",MESSAGE_SAVESCRN);
            }
        }
    if (*G_shutdown) exit(1);
    if (ticker!=*G_ticker)
        {
        ticker=*G_ticker;
        if ((G_enticker)&&(G_exticker!=NULL))
            {
            if (*G_exticker>=G_enticker)
                {
                G_enticker=*G_exticker=0;
                sendmsg("HOTKEY",1,"EXIT2TOP");
                pokekey(EXIT_K);
                }
            }
        for (i=0;i<32;i++)
            {
            if ((G_kloop[i].func!=NULL)&&(G_kloop[i].td!=0))
                {
                G_kloop[i].td=0;
                if (!G_kloop[i].bd)
                    {
                    G_kloop[i].bd=1;
                    (G_kloop[i].func)();
                    G_kloop[i].bd=0;
                    }
                }
            }
        }
    else
        {
        enable();
        }
}

//************************************************************
//S add hotkey
//P integer key
//P char string name typically NONE, ~B, ~~ TAXDISP, or similar
//P char string global tag line? not sure

void addhotkey(INT k,CHAR *n,CHAR *d)
{
    INT i,j;
    ENTRY(6020);
    if (strcmp(n,"NONE"))
        {
        if ((*n=='~')&&(*(n+1)=='~'))
            {
            for (i=0;i<G_numhot;i++)
                {
                if (G_hotkey[i].n[0]=='~')
                    {
                    FREE(G_hotkey[i].n);
                    FREE(G_hotkey[i].d);
                    for (j=i;j<G_numhot-1;j++) 
                        memcpy(&(G_hotkey[j]),&(G_hotkey[j+1]),sizeof(HOTKEY));
                    G_numhot--;
                    i--;
                    }
                }
            RETURN;
            }
        else
            {
            if (G_numhot>=MAXHOT)
                RETURN; 
            for (i=0;i<G_numhot;i++)
                {
                if (k==G_hotkey[i].k)
                    {
                    FREE(G_hotkey[i].n);
                    FREE(G_hotkey[i].d);
                    G_hotkey[i].n=STRDUP(n);
                    G_hotkey[i].d=STRDUP(d);
                    G_hotkey[i].disabled=0;
                    RETURN;
                    }
                }
            G_hotkey[G_numhot].k=k;
            G_hotkey[G_numhot].n=STRDUP(n);
            G_hotkey[G_numhot].d=STRDUP(d);
            if (G_hotkey[G_numhot].n!=NULL)
                {
                G_hotkey[G_numhot].disabled=0;
                G_numhot++;
                }
            } 
        }
    else
        {
        for (i=0;i<G_numhot;i++)
            {
            if (k==G_hotkey[i].k)
                {
                FREE(G_hotkey[i].n);
                FREE(G_hotkey[i].d);
                for (j=i;j<G_numhot-1;j++) 
                    memcpy(&(G_hotkey[j]),&(G_hotkey[j+1]),sizeof(HOTKEY));
                G_numhot--;
                RETURN;
                }
            }
        }
    RETURN;
}

//************************************************************
//S skip a hot key
//P integer hot key for id match
//R TRUE if hotkey diasabled temporarily 

INT skipnexthot(INT k)
{
    INT i;
    ENTRY(6030);
    for (i=0;i<G_numhot;i++) {
        if (k==G_hotkey[i].k) {
            G_hotkey[i].disabled=2;
            RETURNV(1);
        }
    }
    RETURNV(0);
}

//************************************************************
//S check for hotkey pending
//P integer hot key id
//P integer bool to remove hotkey
//R integer

INT checkhot(INT k,INT remkey)
{
    INT i;
    ENTRY(6040);
    if (G_hotkeys) {
        for (i=0;i<G_numhot;i++) {
            if (k==G_hotkey[i].k) {
                if (!G_hotkey[i].disabled) {
    //                if ((remkey)||(G_intable)) {
                    if (remkey) {
                           (*G_kpstart)++;
                           if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
                    }
                    G_hotkey[i].disabled=1;
                    G_lasthotkey=k;
                    if (G_hotkeys==2) pokekey(EXIT_K);
                    sendmsg("HOTKEY",k,G_hotkey[i].n);
                    if (G_hotkey[i].disabled==1) G_hotkey[i].disabled=0;
                    RETURNV(1);
                } else if (G_hotkey[i].disabled==2) {
                    G_hotkey[i].disabled=0;
                    RETURNV(0);
                }
            }
        }
    }
    RETURNV(0);
}

//************************************************************
//S check kb buffer 
//R integer number of keys in queue

INT checkkbbuf(void)
{
    INT found=1;
    while ((*G_kpstart!=*G_kpend)&&(found)) {
        if (G_keybuf[*G_kpstart]==KBDPUSHEND) {
            (*G_kpstart)++;
               if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
            sendmsg("OUTPUT1",MESSAGE_ON);
        } else if ((G_printscron)&&(G_keybuf[*G_kpstart]==PRNTSCRKEY)) {
            (*G_kpstart)++;
               if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
            sendmsg("OUTPUT1",MESSAGE_PRINTSCR,G_printscron,G_form.name);
        } else {
            found=0;
        }
    }
    if (*G_kpstart==*G_kpend) sendmsg("OUTPUT1",MESSAGE_ON);
    return(*G_kpstart!=*G_kpend);
}

//************************************************************
//S see if a keypress is present
//R TRUE for keypress, FALSE for none

INT keyhit(void)
{
    INT k=0;
    ENTRY(6050);
    if (checkkbbuf()) {
           k=G_keybuf[*G_kpstart];
        if (k==0) {
               (*G_kpstart)++;
               if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
        }
    } else {
           runklfuncs();
    }
    RETURNV(k);
}

//************************************************************
//S call checkkbbuf - see above
//R as for checkkbbuf

INT fkeyhit(void)
{
    ENTRY(6060);
    RETURNV(checkkbbuf());
}

//************************************************************
//S waits for a keypress and RETURNs it
//R integer Key

INT getkey(void)
{
    INT k;//,i;
//    ENTRY(6070);

    while (!checkkbbuf()) {  // wait for key press
           runklfuncs();
      }
       k=G_keybuf[(*G_kpstart)++];
       if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
      if (k==(-254)) sendmsg("SWAPLANG",MESSAGE_NONE);
    if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}

//************************************************************
//S seek key - don't wait
//R integer 0 or key

INT fastgetkey(void)
{
    INT k=0;
    ENTRY(6070);
    if (checkkbbuf())
        {
        k=G_keybuf[(*G_kpstart)++];
        if (*G_kpstart>ENDOFBUF)
            *G_kpstart=0;
        }
    RETURNV(k);
}


//************************************************************
//S waits for a keypress and RETURNs it ( DOES NOT REMOVE FROM BUFFER )
//R integer key

INT peekkey(void) 
{
    INT k;
    ENTRY(6080);
    while (!checkkbbuf()) {  // wait for key press
        runklfuncs();
    }
    k=G_keybuf[*G_kpstart];
    if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}

//************************************************************
//S insert a key into the buffer
//P integer key to insert

void pokekey(INT k) 
{
    ENTRY(6090);
    realcmd(PUSHKEYPRESS,k,0);
    RETURN;
}

//************************************************************
//S insert a hot key into the buffer and mess with the order of events
//P key to push

void pokehkey(INT k) 
{
    ENTRY(6100);
    pokekey(k);
    pokekey(KBDPUSHEND);
    skipnexthot(k);
}

//************************************************************
//S remove the next key in the buffer
//P parameter

void repkey(void) 
{
    ENTRY(6110);
    disable();
    (*G_kpstart)--;
    if (*G_kpstart<0) *G_kpstart=ENDOFBUF-1;
    enable();
    RETURN;
}

//************************************************************
//S empty the keyboard buffer

void keyflush(void)
{
    ENTRY(6120);
    disable();
    *G_kpstart=*G_kpend=0;
    enable();
    RETURN;
}


//************************************************************
//S old keyboard input routine
//R key

INT ogetch(void)
{
    INT k;
    ENTRY(6130);
    if ((k=getch())==0) RETURNV(0-getch());
    RETURNV(k);
}

//************************************************************
//S load kb map
//R TRUE Ok, FALSE failed

INT loadkeymap(void)
{
    INT *sm;
    ENTRY(6178);
    if ((sm=readkeys())==NULL) RETURNV(0);
    memcpy(G_scanmap,sm,0x7F*5*sizeof(INT));
    RETURNV(1);
}

//************************************************************
//S keyboard startup routine
//R TRUE Ok, FALSE failed

INT kbd_startup(void)
{
    ENTRY(6180);
    setuprealbuf();
    *G_kpstart=*G_kpend=0;
    memset(G_kloop,0,sizeof(G_kloop));
    if (kbhit()) {
        while (kbhit()) pokekey(ogetch());
        pokekey(KBDPUSHEND);
    }
    RETURNV(loadkeymap());
}
// keyboard shutdown routine

//************************************************************
//S keyboar shutdown - clears hotkey list
//R TRUE

INT kbd_shutdown(void)
{
    INT i;
    ENTRY(6190);
    clearrealmode();
    for (i=0;i<G_numhot;i++)
        if (G_hotkey[i].n!=NULL)
            FREE(G_hotkey[i].n);
    RETURNV(1);
}

//************************************************************
//S switch keyboard back on
//R TRUE

INT kbd_restartup(void)
{
    realcmd(KBDSWITCHON ,0,0);
    return(1);
}

//************************************************************
//S switch keyboard off
//R TRUE

INT kbd_tmpshutdown(void)
{
    realcmd(KBDSWITCHOFF,0,0);
    return(1);
}

//************************************************************
//S keyboard control routine
//P integer control request id
//P variable parameters 
//R long integer reply code

LONG kbd_control(INT type,va_list ap)
{
    LONG retval=0L;
    INT pri,k;
    CHAR *a;
    ENTRY(6200);
    
    switch (type) {
        case MESSAGE_i :                    // input
            retval=(LONG)getkey();
            G_lastkey=(INT)retval;
            break;
        case MESSAGE_F :                    // flush
            keyflush();
            break;
        case MESSAGE_I :                    // startup kbd
            retval=(LONG)kbd_startup();
            break;
        case MESSAGE_E :                    // shutdown kbd
            retval=(LONG)kbd_shutdown();
            break;
        case MESSAGE_RI :                   // reinit kbd
            retval=(LONG)kbd_restartup();
            break;
        case MESSAGE_TE :                   // temp shutdown kbd
            retval=(LONG)kbd_tmpshutdown();
            break;
        case MESSAGE_H :                    // Hit currently
            retval=(LONG)keyhit();
            break;
        case MESSAGE_FH :                   // Hit outstanding
            retval=(LONG)fkeyhit();
            break;
        case MESSAGE_Fi :                   // Fast input
            retval=(LONG)fastgetkey();
            G_lastkey=(INT)retval;
            break;
        case MESSAGE_R :                    // Remove last key in buffer
            repkey();
            break;
        case MESSAGE_P :                    // Push
            pokekey(va_arg(ap,INT));
            break;
        case MESSAGE_PH :                    // Push - hot key ignored
            pokehkey(va_arg(ap,INT));
            break;
        case MESSAGE_C :                    // Check - waits for a keypress
            retval=(LONG)peekkey();         // doesn't pop it - just returns it
            break;
        case MESSAGE_A :                    // Add key loop function
            pri=va_arg(ap,INT);
            retval=(LONG)addklfunc(pri,(FPTR)va_arg(ap,void *));
            break;
        case MESSAGE_D :                    // Delete key loop function
            retval=(LONG)delklfunc((FPTR)va_arg(ap,void *));
            break;
        case MESSAGE_K :                      // Hot key action
            pri=va_arg(ap,INT);
            a=va_arg(ap,CHAR *);
            addhotkey(pri,a,va_arg(ap,CHAR *));
            retval=1L;
            break;
        case MESSAGE_NH :                      // Number of Hot keys
            retval=(LONG)G_numhot;
            break;
        case MESSAGE_HN :                      // Hot key name
            pri=va_arg(ap,INT);
            if (pri<G_numhot) retval=(LONG)G_hotkey[pri].k; else retval=0;
            break;
        case MESSAGE_HD :                      // Hot key description
            pri=va_arg(ap,INT);
            a=va_arg(ap,CHAR *);
            retval=0L;
            if (pri<G_numhot) {
                strcpy(a,G_hotkey[pri].d);
                retval=1L;
            }
            break;
        case MESSAGE_xt :                      // setup exit ticker
            disable();
            *G_exticker=0;
            enable();
            G_enticker=(va_arg(ap,INT)*182)/10;
            break;
        case MESSAGE_rt :
            disable();
            *G_exticker=0;
            enable();
            break;

        case MESSAGE_SS :                      // setup exit ticker - valid? :JGQ
            disable();
            G_ssticker=0;                       // This one not used?
            enable();
            G_seticker=(va_arg(ap,INT)*182)/10;
            break;

        case MESSAGE_RM :       // open record file in read write mode 
            G_recfd=open(va_arg(ap,CHAR *),O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (G_recfd==(-1))
                {
                retval=0L;
                }
            else
                {
                retval=1L;
                G_recmode=1;
                }
            break;

        case MESSAGE_EM :       // end record mode
            if (G_recfd!=(-1)) {
                close(G_recfd);
                G_recfd=(-1);
                G_recmode=0;
            }
            break;

        case MESSAGE_RK :       // run keyboard loop functions
            runklfuncs();
            retval=1L;
            break;

        case MESSAGE_CH :       // Check hot key then run kbd loop funcs
            k=fkeyhit();
            if (k)
                {
                retval=checkhot(keyhit(),1);
                }
            else
                {
                retval=1L;
                   runklfuncs();
                }
            break;
        case MESSAGE_tc :       // ticker value
            disable();
            retval=*G_ticker;
            enable();
            break;
        case MESSAGE_PM :       // Open record file in read only mode 
            G_recfd=open(va_arg(ap,CHAR *),O_RDONLY|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
            if (G_recfd==(-1))
                {
                retval=0L;
                }
            else
                {
                retval=1L;
                G_recmode=1;
                }
            break;
        case MESSAGE_DT :       // set/reset disable till flag
            *G_disabletill=va_arg(ap,INT);
            break;
        case MESSAGE_NL :           // update flags in real mode
            k=va_arg(ap,INT);
            realcmd(UPDATEFLAGS,k,0);
            retval=1L;
            break;
        case MESSAGE_LOADKEYS :     // load key map
            retval=(LONG)loadkeymap();
            break;
        case MESSAGE_GETINCAT :     // get intact time
            retval=*G_intacttime;
            break;
        case MESSAGE_CLRINACT :     // clear intact time
            *G_intacttime=0L;
            retval=1L;
            break;
    }
    RETURNV(retval);
}
#pragma option -p.

// **************************************************************************
// kbddev.c <end-of-file>

