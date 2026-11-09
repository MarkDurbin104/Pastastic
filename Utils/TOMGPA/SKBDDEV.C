#define KBD_DEV_C
#include <ctype.h>
#include <stdio.h>
#include <conio.h>
#include <memory.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#include "types.h"
#include "control.h"
#include "message.h"
#include "keydef.h"
#include "config.h"
#include "scancode.h"
#include "skbddev.h"

INT  G_dossel;
INT  G_recmode=0;
INT  G_playmode=0;
INT  G_recfd=(-1);
INT  G_recptr=0;
INT  G_pkeybuf[50];
INT  G_pkstart=0;
INT  G_pkend=0;
INT mykbhit(void)
{
    if ((G_pkstart!=G_pkend)||(kbhit())) return(1);
    return(0);
}
INT mygetch(void)
{
    INT k;
    while ((G_pkstart==G_pkend)&&(!kbhit()));
    if (G_pkstart!=G_pkend) {
        k=G_pkeybuf[G_pkstart++];
        if (G_pkstart==50) G_pkstart=0;
    } else {
		k=getch();

        if (!k) k=0-getch();
    }
    return(k);
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
                G_kloop[i].num++;
                RETURNV(i);
            }
        }
        for (i=0;i<32;i++) {
            if (G_kloop[i].func==NULL) {
                G_kloop[i].pri=p;
                G_kloop[i].lt=0;
			    G_kloop[i].td=0;
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
	static INT ticker=0;

    ticker++;
    if (ticker>=100) {
   	    for (i=0;i<32;i++) {
       	    if (G_kloop[i].func!=NULL) {
			    G_kloop[i].lt++;
			    if (G_kloop[i].pri==G_kloop[i].lt) {
				    G_kloop[i].lt=0;
				    G_kloop[i].td=1;
			    }
       	    }
   	    }
        ticker=0;
    }
  	for (i=0;i<32;i++) {
       	if ((G_kloop[i].func!=NULL)&&(G_kloop[i].td!=0)) {
           	(G_kloop[i].func)();
			G_kloop[i].td=0;
       	}
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
				    if (remkey) {
                        mygetch();
				    }
				    G_hotkey[i].disabled=1;
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
// RETURNs true if a keypress is present
INT keyhit(void)
{
    INT k=0;
	ENTRY(6050);
	if (mykbhit()) {
        k=1;
	} else {
       	runklfuncs();
	}
    RETURNV(k);
}
INT fkeyhit(void)
{
	ENTRY(6060);
	RETURNV(mykbhit());
}
// waits for a keypress and RETURNs it
INT getkey(void)
{
    INT k;

	while (!mykbhit()) {  // wait for key press
       	runklfuncs();
  	}
	k=mygetch();
	if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}
INT fastgetkey(void)
{
    INT k=0;
	ENTRY(6070);
	if (mykbhit()) {
	    k=mygetch();
  	}
    RETURNV(k);
}
// empty the keyboard buffer
void keyflush(void)
{
	ENTRY(6120);
    while (mykbhit()) mygetch();
	RETURN;
}
// keyboard startup routine
INT kbd_startup(void)
{
	ENTRY(6180);
    memset(G_kloop,0,sizeof(G_kloop));
    RETURNV(1);
}
// keyboard shutdown routine
INT kbd_shutdown(void)
{
	ENTRY(6190);
    RETURNV(1);
}
INT kbd_restartup(void)
{
	return(1);
}
// keyboard shutdown routine
INT kbd_tmpshutdown(void)
{
	return(1);
}
// keyboard control routine
LONG kbd_control(INT type,va_list ap)
{
    LONG retval=1L;
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
			break;
        case MESSAGE_P :                      // Push
            pri=va_arg(ap,INT);
            if (pri!=5000) {
                G_pkeybuf[G_pkend++]=pri;
                if (G_pkend==50) G_pkend=0;
            }
            break;
        case MESSAGE_PH :                      // Push - hot key ignored
            break;
        case MESSAGE_C :                      // Check
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
            break;
		case MESSAGE_rt :
            break;

        case MESSAGE_SS :                      // setup exit ticker
            break;
		case MESSAGE_RM :
			break;
		case MESSAGE_EM :
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
			break;
		case MESSAGE_PM :
			break;
		case MESSAGE_DT :
			break;
		case MESSAGE_NL :
			break;

    }
    RETURNV(retval);
}
#pragma option -p.

