#define KBD_DEV_C
#include <ctype.h>
#include <stdio.h>
#include <memory.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <stdarg.h>
#include <string.h>
#include <dos.h>
#include "types.h"
#include "control.h"
#include "message.h"
#include "keydef.h"
#include "config.h"
#include "scancode.h"

extern FORM G_form;

#pragma option -p-
#include "kbddev.h"

volatile INT G_ticker=0;
volatile INT G_exticker=0;
volatile INT G_enticker=0;
volatile INT G_ssticker=0;
volatile INT G_seticker=0;


INT G_disabletill=0;
INT G_printscr=0;
INT G_recmode=0;
INT G_playmode=0;
INT G_recfd=(-1);
INT G_recptr=0;

// add a keyboard loop function
INT addklfunc(INT p,FPTR f)
{
    INT i;
	ENTRY(5960);
    if (p==0) p=1;

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
    RETURNV(-1);
}
// delete a keyboard loop function
INT delklfunc(FPTR f)
{
    INT i;
	ENTRY(5970);

    for (i=0;i<32;i++) {
        if (G_kloop[i].func==f) {
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
    RETURNV(-1);
}
// run all keyboard loop functions
void runklfuncs(void)
{
    INT i;
	static INT ticker=20000;
//	ENTRY(5980);

	disable();
    if (G_recmode)  { write(G_recfd,G_recbuf,G_recptr*sizeof(INT)); G_recptr=0; }
    if (G_playmode) { read(G_recfd,&i,sizeof(INT)); bufferkey(i); }
	if (ticker!=G_ticker) {
		ticker=G_ticker;
		enable();
		if (G_enticker) {
			if (G_exticker>=G_enticker) {
				G_enticker=G_exticker=0;
				sendmsg("HOTKEY",1,"EXIT2TOP");
				pokekey(EXIT_K);
			}
		}

    	for (i=0;i<32;i++) {
        	if ((G_kloop[i].func!=NULL)&&(G_kloop[i].td!=0)) {
            	(G_kloop[i].func)();
				G_kloop[i].td=0;
        	}
    	}
	} else {
		enable();
	}
//    RETURN;
}
// buffer a keypress
void bufferkey(INT k)
{
	ENTRY(5990);
	G_exticker=0;
    if (!G_disabletill) {
		G_keybuf[G_kpend++]=k;
    	if (G_kpend>ENDOFBUF) G_kpend=0;
    	if (G_recmode) G_recbuf[G_recptr++]=k;
	}
	RETURN;
}
void interrupt ticker(void)
{
	INT i;
	(oldtick)();
	if ((++G_ticker)>10000) G_ticker=0;
	if ((++G_exticker)>10000) G_exticker=0;
   	for (i=0;i<32;i++) {
       	if (G_kloop[i].func!=NULL) {
			G_kloop[i].lt++;
			if (G_kloop[i].pri==G_kloop[i].lt) {
				G_kloop[i].lt=0;
				G_kloop[i].td=1;
			}
       	}
   	}
}
// keyboard interrupt routine
void interrupt mykeyb(void)
{
    UCHAR stat;
    INT kpress,mappos;
    INT k;

    disable();

    k=inp(0x60);
    kpress=G_scanmap[((k&0x7F)*5)+0];
    if (k&0x80) {       // release code
        switch (kpress) {
            case KLSFT  :
                G_shiftstat&=~(LSHIFT);
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KRSFT  :
                G_shiftstat&=~(RSHIFT);
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KCTRL    :
                G_shiftstat&=~(CTRL);
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KALT     :
                G_shiftstat&=~(ALT);
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
        }
    }
    else {                  // press code
        switch (kpress) {
            case KLSFT  :
                G_shiftstat|=LSHIFT;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KRSFT  :
                G_shiftstat|=RSHIFT;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KCTRL    :
                G_shiftstat|=CTRL;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KALT     :
                G_shiftstat|=ALT;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KCAPL   :
                G_shiftstat^=CAPSL;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KNUML    :
                G_shiftstat^=NUML;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                break;
            case KSCRL :
                G_shiftstat^=SCROLLL;
                sendmsg("OUTPUT1",'l',G_shiftstat);
                bufferkey(-254);
                break;
            default :
                if (kpress==INS) {
                    G_shiftstat^=INSL;
                    sendmsg("OUTPUT1",'l',G_shiftstat);
                }
                mappos=0;
                if (!G_extnext) {
                    if ((G_shiftstat&(LSHIFT|RSHIFT))!=0) mappos=1;
                    if (  ((G_scanmap[(k*5)+4]==1)&&((G_shiftstat&CAPSL)!=0))
                      ||  ((G_scanmap[(k*5)+4]==2)&&((G_shiftstat&NUML )!=0)))
                        mappos^=1;
                }
                if ((G_shiftstat&CTRL)!=0) mappos=2;
                if ((G_shiftstat&ALT)!=0)  mappos=3;
                kpress=G_scanmap[(k*5)+mappos];
                if (kpress==DOUB0) {
                    bufferkey('0');
                    kpress='0';
                }
                if (kpress==TREB0) {
                    bufferkey('0');
                    bufferkey('0');
                    kpress='0';
                }
                if (kpress!=0) bufferkey(kpress);
        }
    }
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);

    G_extnext=(k==EXTENDED);
    if ((G_shiftstat==(LSHIFT|RSHIFT))&&(!G_printscr)) G_printscr=1;
    if ((G_shiftstat==0)&&(G_printscr==1)) G_printscr=2;
    enable();
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
			   		    G_kpstart++;
			   		    if (G_kpstart>ENDOFBUF) G_kpstart=0;
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
void setflags(void)
{
	static UCHAR ss=0;
	UCHAR s=0;
	if (ss!=G_shiftstat) {
		ss=G_shiftstat;
		if ((G_shiftstat&CAPSL  )!=0) s|=4;
		if ((G_shiftstat&NUML   )!=0) s|=2;
		if ((G_shiftstat&SCROLLL)!=0) s|=1;
  		while ((inp(0x64)&0x2)==2);
		outp(0x60,0xED);
  		while ((inp(0x64)&0x2)==2);
		outp(0x60,s);
	}
}
// RETURNs true if a keypress is present
INT keyhit(void)
{
    INT k=0;
	ENTRY(6050);
	setflags();
	if (G_kpstart!=G_kpend) {
   		k=G_keybuf[G_kpstart];
	} else {
       	runklfuncs();
	}
	if ((k)&&(k==G_disabletill)) { k=-254; G_disabletill=0; sendmsg("OUTPUT1",'ON'); }
    RETURNV(k);
}
INT fkeyhit(void)
{
	ENTRY(6060);
	RETURNV(G_kpstart!=G_kpend);
}
// waits for a keypress and RETURNs it
INT getkey(void)
{
    INT k;//,i;
	ENTRY(6070);
	while (G_kpstart==G_kpend) {  // wait for key press
		setflags();
       	runklfuncs();
       	if (G_printscr==2) {
			sendmsg("OUTPUT1",'SP',G_form.name);
			G_printscr=0;
		}
  	}
   	k=G_keybuf[G_kpstart++];
   	if (G_kpstart>ENDOFBUF) G_kpstart=0;
  	if (k==(-254)) sendmsg("SWAPLANG",' ');
	if ((k)&&(k==G_disabletill)) { k=-254; G_disabletill=0; sendmsg("OUTPUT1",'ON'); }
	if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}
INT fastgetkey(void)
{
    INT k=0;
	ENTRY(6070);
	setflags();
	if (G_kpstart!=G_kpend) {
	   	k=G_keybuf[G_kpstart++];
	   	if (G_kpstart>ENDOFBUF) G_kpstart=0;
  	}
	if ((k)&&(k==G_disabletill)) { k=-254; G_disabletill=0; sendmsg("OUTPUT1",'ON'); }
    RETURNV(k);
}
// waits for a keypress and RETURNs it ( DOES NOT REMOVE FROM BUFFER )
INT peekkey(void) 
{
    INT k;
	ENTRY(6080);
    while (G_kpstart==G_kpend) {  // wait for key press
		setflags();
        runklfuncs();
       	if (G_printscr==2) {
			sendmsg("OUTPUT1",'SP',G_form.name);
			G_printscr=0;
		}
    }
	k=G_keybuf[G_kpstart];
	if ((k)&&(k==G_disabletill)) { k=-254; G_disabletill=0; sendmsg("OUTPUT1",'ON'); }
	if (checkhot(k,0)) k=(-254);
    RETURNV(k);
}
// insert a key into the buffer
void pokekey(INT k) 
{
	ENTRY(6090);
    disable();
	bufferkey(k);
    enable();
	RETURN;
}
// insert a key into the buffer
void pokehkey(INT k) 
{
	ENTRY(6100);
	pokekey(k);
	skipnexthot(k);
}
// replace the next key in the buffer
void repkey(void) 
{
	ENTRY(6110);
   	disable();
    G_kpstart--;
    if (G_kpstart<0) G_kpstart=ENDOFBUF;
    enable();
	RETURN;
}
// empty the keyboard buffer
void keyflush(void)
{
	ENTRY(6120);
    disable();
    G_kpstart=G_kpend=0;
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
// keyboard startup routine
INT kbd_startup(void)
{
	ENTRY(6180);
    G_printscr=0;
    memset(G_kloop,0,sizeof(G_kloop));
    while (kbhit()) pokekey(ogetch());
    oldkeyb=getvect(0x09);
    oldtick=getvect(0x1C);
    if ((G_scanmap=readkeys())==NULL) {
		RETURNV(0);
    }
    setvect(0x1C,ticker);
    setvect(0x09,mykeyb);
    RETURNV(1);
}
// keyboard shutdown routine
INT kbd_shutdown(void)
{
	INT i;
	ENTRY(6190);
    setvect(0x09,oldkeyb);
    setvect(0x1C,oldtick);
    memset(G_kloop,0,sizeof(G_kloop));
	for (i=0;i<G_numhot;i++) if (G_hotkey[i].n!=NULL) FREE(G_hotkey[i].n);
    RETURNV(1);
}
INT kbd_restartup(void)
{
    setvect(0x1C,ticker);
    setvect(0x09,mykeyb);
	return(1);
}
// keyboard shutdown routine
INT kbd_tmpshutdown(void)
{
    setvect(0x09,oldkeyb);
    setvect(0x1C,oldtick);
	return(1);
}
// keyboard control routine
INT kbd_control(INT type,va_list ap)
{
    INT retval=0;
    INT pri,k;
	CHAR *a;
	ENTRY(6200);
	
    switch (type) {
        case 'i' :                      // input
            retval=getkey();
			break;
        case 'F' :                      // flush
            keyflush();
            break;
        case 'I' :
            retval=kbd_startup();
            break;
        case 'E' :
            retval=kbd_shutdown();
            break;
        case 'RI' :
            retval=kbd_restartup();
            break;
        case 'TE' :
            retval=kbd_tmpshutdown();
            break;
        case 'H' :                      // Hit
            retval=keyhit();
            break;
        case 'FH' :                      // Fast Hit
            retval=fkeyhit();
            break;
        case 'Fi' :                      // Fast input
            retval=fastgetkey();
			break;
        case 'R' :                      // Replace
            repkey();
			break;
        case 'P' :                      // Push
            pokekey(va_arg(ap,INT));
            break;
        case 'PH' :                      // Push - hot key ignored
            pokehkey(va_arg(ap,INT));
            break;
        case 'C' :                      // Check
            retval=peekkey();
            break;
        case 'A' :                      // Add key loop function
            pri=va_arg(ap,INT);
            retval=addklfunc(pri,(FPTR)va_arg(ap,void *));
            break;
        case 'D' :                      // Delete key loop function
            retval=delklfunc((FPTR)va_arg(ap,void *));
            break;
        case 'K' :                      // Hot key action
            pri=va_arg(ap,INT);
            a=va_arg(ap,CHAR *);
			addhotkey(pri,a,va_arg(ap,CHAR *));
			retval=1;
            break;
        case 'NH' :                      // Number of Hot keys
            retval=G_numhot;
            break;
        case 'HN' :                      // Hot key name
            pri=va_arg(ap,INT);
            if (pri<G_numhot) retval=G_hotkey[pri].k; else retval=0;
            break;
        case 'HD' :                      // Hot key description
            pri=va_arg(ap,INT);
            a=va_arg(ap,CHAR *);
            retval=0;
            if (pri<G_numhot) {
                strcpy(a,G_hotkey[pri].d);
                retval=1;
            }
            break;
        case 'xt' :                      // setup exit ticker
			disable();
			G_exticker=0;
			enable();
			G_enticker=(va_arg(ap,INT)*182)/10;
            break;
		case 'rt' :
			disable();
			G_exticker=0;
			enable();
            break;

        case 'SS' :                      // setup exit ticker
			disable();
			G_ssticker=0;
			enable();
			G_seticker=(va_arg(ap,INT)*182)/10;
            break;
		case 'RM' :
			G_recfd=open(va_arg(ap,CHAR *),O_RDWR|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
			if (G_recfd==(-1)) {
				retval=0;
			} else {
				retval=1;
				G_recmode=1;
			}
			break;
		case 'EM' :
			if (G_recfd!=(-1)) {
				close(G_recfd);
				G_recfd=(-1);
				G_recmode=0;
			}
			break;

		case 'RK' :
           	runklfuncs();
			retval=1;
            break;

		case 'CH' :
			k=fkeyhit();
			if (k) {
				retval=checkhot(keyhit(),1);
			} else {
				retval=1;
		       	runklfuncs();
			}
			break;
		case 'tc' :
			disable();
			retval=G_ticker;
			enable();
			break;
		case 'PM' :
			G_recfd=open(va_arg(ap,CHAR *),O_RDONLY|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
			if (G_recfd==(-1)) {
				retval=0;
			} else {
				retval=1;
				G_recmode=1;
			}
			break;
		case 'DT' :
			G_disabletill=va_arg(ap,INT);
			break;
		case 'NL' :
			if (va_arg(ap,INT)) 
	            G_shiftstat|=NUML;
			else
	            G_shiftstat&=~NUML;
			break;

    }
    RETURNV(retval);
}
#pragma option -p.

