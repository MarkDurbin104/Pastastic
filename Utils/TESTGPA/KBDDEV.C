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

void realcmd(UINT func,INT s,INT o)
{
    _AX=func;
    _BX=o;
    _CX=s;
    geninterrupt(0x62);
}
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
void clearrealmode(void)
{
    realcmd(KBDSWITCHOFF,0        ,0);
    GlobalDosFree(G_dossel);
}
// add a keyboard loop function
INT addklfunc(INT p,FPTR f)
{
    INT i;
	ENTRY(5960);
    if (p==0) p=1;
    if (f==NULL) RETURNV(-1);
    if (G_kloop!=NULL) {
        for (i=0;i<32;i++) {
            if (G_kloop[i].func==f) {
                G_kloop[i].pri=p;
                G_kloop[i].lt=0;
			    G_kloop[i].td=0;
			    G_kloop[i].bd=0;
                G_kloop[i].num++;
                RETURNV(i);
            }
        }
        for (i=0;i<32;i++) {
            if (G_kloop[i].func==NULL) {
                G_kloop[i].pri=p;
                G_kloop[i].lt=0;
			    G_kloop[i].td=0;
			    G_kloop[i].bd=0;
                G_kloop[i].func=f;
                G_kloop[i].num++;
                RETURNV(i);
            }
        }
    }
    RETURNV(-1);
}
// delete a keyboard loop function
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
// run all keyboard loop functions
void runklfuncs(void)
{
    INT i;
	static LONG ticker=0;
    realcmd(UPDATEFLAGS,0,0);
    if (G_savescrnto) {
        if (*G_intacttime>=G_savescrnto) {
            sendmsg("OUTPUT1",MESSAGE_SAVESCRN);
        }
    }
    if (*G_shutdown) exit(1);
	if (ticker!=*G_ticker) {
		ticker=*G_ticker;
		if ((G_enticker)&&(G_exticker!=NULL)) {
			if (*G_exticker>=G_enticker) {
				G_enticker=*G_exticker=0;
				sendmsg("HOTKEY",1,"EXIT2TOP");
				pokekey(EXIT_K);
			}
		}

    	for (i=0;i<32;i++) {
        	if ((G_kloop[i].func!=NULL)&&(G_kloop[i].td!=0)) {
				G_kloop[i].td=0;
            	if (!G_kloop[i].bd) {
                    G_kloop[i].bd=1;
                    (G_kloop[i].func)();
    			    G_kloop[i].bd=0;
                }
        	}
    	}
	} else {
		enable();
	}
}
void addhotkey(INT k,CHAR *n,CHAR *d)
{
	INT i,j;
	ENTRY(6020);
	if (strcmp(n,"NONE")) {
		if ((*n=='~')&&(*(n+1)=='~')) {
			for (i=0;i<G_numhot;i++) {
				if (G_hotkey[i].n[0]=='~') {
					FREE(G_hotkey[i].n);
					FREE(G_hotkey[i].d);
					for (j=i;j<G_numhot-1;j++) 
						memcpy(&(G_hotkey[j]),&(G_hotkey[j+1]),sizeof(HOTKEY));
					G_numhot--;
					i--;
				}
			}
			RETURN;
		} else {
			if (G_numhot>=MAXHOT) RETURN; 
			for (i=0;i<G_numhot;i++) {
				if (k==G_hotkey[i].k) {
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
			if (G_hotkey[G_numhot].n!=NULL) {
				G_hotkey[G_numhot].disabled=0;
				G_numhot++;
			}
		} 
	} else {
		for (i=0;i<G_numhot;i++) {
			if (k==G_hotkey[i].k) {
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
INT checkhot(INT k,INT remkey)
{
	INT i;
	ENTRY(6040);
    if (G_hotkeys) {
	    for (i=0;i<G_numhot;i++) {
		    if (k==G_hotkey[i].k) {
			    if (!G_hotkey[i].disabled) {
    //				if ((remkey)||(G_intable)) {
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
INT checkkbbuf(void)
{
    int found=1;
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
// RETURNs true if a keypress is present
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
INT fkeyhit(void)
{
	ENTRY(6060);
	RETURNV(checkkbbuf());
}
// waits for a keypress and RETURNs it
INT getkey(void)
{
    INT k;//,i;
//	ENTRY(6070);

	while (!checkkbbuf()) {  // wait for key press
       	runklfuncs();
  	}
   	k=G_keybuf[(*G_kpstart)++];
   	if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
  	if (k==(-254)) sendmsg("SWAPLANG",MESSAGE_NONE);
	if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}
INT fastgetkey(void)
{
    INT k=0;
	ENTRY(6070);
	if (checkkbbuf()) {
	   	k=G_keybuf[(*G_kpstart)++];
	   	if (*G_kpstart>ENDOFBUF) *G_kpstart=0;
  	}
    RETURNV(k);
}
// waits for a keypress and RETURNs it ( DOES NOT REMOVE FROM BUFFER )
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
// insert a key into the buffer
void pokekey(INT k) 
{
	ENTRY(6090);
    realcmd(PUSHKEYPRESS,k,0);
	RETURN;
}
// insert a key into the buffer
void pokehkey(INT k) 
{
	ENTRY(6100);
	pokekey(k);
    pokekey(KBDPUSHEND);
	skipnexthot(k);
}
// replace the next key in the buffer
void repkey(void) 
{
	ENTRY(6110);
   	disable();
    (*G_kpstart)--;
    if (*G_kpstart<0) *G_kpstart=ENDOFBUF-1;
    enable();
	RETURN;
}
// empty the keyboard buffer
void keyflush(void)
{
	ENTRY(6120);
    disable();
    *G_kpstart=*G_kpend=0;
    enable();
	RETURN;
}
// old keyboard input routine
INT ogetch(void)
{
    INT k;
	ENTRY(6130);
    if ((k=getch())==0) RETURNV(0-getch());
    RETURNV(k);
}
INT loadkeymap(void)
{
    INT *sm;
	ENTRY(6178);
    if ((sm=readkeys())==NULL) RETURNV(0);
    memcpy(G_scanmap,sm,0x7F*5*sizeof(INT));
    RETURNV(1);
}
// keyboard startup routine
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
INT kbd_shutdown(void)
{
	INT i;
	ENTRY(6190);
    clearrealmode();
	for (i=0;i<G_numhot;i++) if (G_hotkey[i].n!=NULL) FREE(G_hotkey[i].n);
    RETURNV(1);
}
INT kbd_restartup(void)
{
    realcmd(KBDSWITCHON ,0,0);
	return(1);
}
// keyboard shutdown routine
INT kbd_tmpshutdown(void)
{
    realcmd(KBDSWITCHOFF,0,0);
	return(1);
}
// keyboard control routine
LONG kbd_control(INT type,va_list ap)
{
    LONG retval=0L;
    INT pri,k;
	CHAR *a;
	ENTRY(6200);
	
    switch (type) {
        case MESSAGE_i :                      // input
            retval=(LONG)getkey();
            G_lastkey=(INT)retval;
			break;
        case MESSAGE_F :                      // flush
            keyflush();
            break;
        case MESSAGE_I :
            retval=(LONG)kbd_startup();
            break;
        case MESSAGE_E :
            retval=(LONG)kbd_shutdown();
            break;
        case MESSAGE_RI :
            retval=(LONG)kbd_restartup();
            break;
        case MESSAGE_TE :
            retval=(LONG)kbd_tmpshutdown();
            break;
        case MESSAGE_H :                      // Hit
            retval=(LONG)keyhit();
            break;
        case MESSAGE_FH :                      // Fast Hit
            retval=(LONG)fkeyhit();
            break;
        case MESSAGE_Fi :                      // Fast input
            retval=(LONG)fastgetkey();
            G_lastkey=(INT)retval;
			break;
        case MESSAGE_R :                      // Replace
            repkey();
			break;
        case MESSAGE_P :                      // Push
            pokekey(va_arg(ap,INT));
            break;
        case MESSAGE_PH :                      // Push - hot key ignored
            pokehkey(va_arg(ap,INT));
            break;
        case MESSAGE_C :                      // Check
            retval=(LONG)peekkey();
            break;
        case MESSAGE_A :                      // Add key loop function
            pri=va_arg(ap,INT);
            retval=(LONG)addklfunc(pri,(FPTR)va_arg(ap,void *));
            break;
        case MESSAGE_D :                      // Delete key loop function
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

        case MESSAGE_SS :                      // setup exit ticker
			disable();
			G_ssticker=0;
			enable();
			G_seticker=(va_arg(ap,INT)*182)/10;
            break;
		case MESSAGE_RM :
			G_recfd=open(va_arg(ap,CHAR *),O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
			if (G_recfd==(-1)) {
				retval=0L;
			} else {
				retval=1L;
				G_recmode=1;
			}
			break;
		case MESSAGE_EM :
			if (G_recfd!=(-1)) {
				close(G_recfd);
				G_recfd=(-1);
				G_recmode=0;
			}
			break;

		case MESSAGE_RK :
           	runklfuncs();
			retval=1L;
            break;

		case MESSAGE_CH :
			k=fkeyhit();
			if (k) {
				retval=checkhot(keyhit(),1);
			} else {
				retval=1L;
		       	runklfuncs();
			}
			break;
		case MESSAGE_tc :
			disable();
			retval=*G_ticker;
			enable();
			break;
		case MESSAGE_PM :
			G_recfd=open(va_arg(ap,CHAR *),O_RDONLY|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
			if (G_recfd==(-1)) {
				retval=0L;
			} else {
				retval=1L;
				G_recmode=1;
			}
			break;
		case MESSAGE_DT :
			*G_disabletill=va_arg(ap,INT);
			break;
		case MESSAGE_NL :
            k=va_arg(ap,INT);
            realcmd(UPDATEFLAGS,k,0);
        	retval=1L;
			break;
		case MESSAGE_LOADKEYS :
            retval=(LONG)loadkeymap();
			break;
        case MESSAGE_GETINCAT :
            retval=*G_intacttime;
            break;
        case MESSAGE_CLRINACT :
            *G_intacttime=0L;
        	retval=1L;
            break;
    }
    RETURNV(retval);
}
#pragma option -p.

