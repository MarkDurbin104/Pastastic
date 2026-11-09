/* RCRIT.C

Real mode critical error handler

*/

#include <dos.h>
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "keydef.h"

// from #include "kbddev.h"
extern volatile INT            *G_keybuf;
extern volatile INT            *G_kpstart;
extern volatile INT            *G_kpend;
// form "start.h"
#define ENDOFBUF        0x100


//**********************************************
void beep(void)
{
    sound(500);
    delay(200);
    nosound();
}


//**************************************************
// critical error handler   MUST BE IN LOCKED MEMORY!!
void interrupt (*oldcriticalerror)();
void interrupt criticalerrorhandler(void)
{
    INT AX=_AX;     // Get status values
    INT DI=_DI;
    INT err=0;
    INT length,segment,off;
    CHAR    diskerrmsg[] = "Disk error";
    CHAR    retryfail[] = "Retry or Fail R/F";

     // if disk I/O error handle, else ignore.
    if (!(AX & 0x8000))         //AH bit 7 set 0 indicates an I/O error
    {
        if (AX & 0x0380)   // Test if Ignore, Retry Abort allowed
        {
                // save screen area
                // put up message line (change to a box?)
            beep();

            // don't save region, taks up valuable real memory
//            savemsgregion();

/* INT 10 - VIDEO - (AT,XT286,PS,EGA,VGA)
     AH = 13h
     AL = mode
           bit 1: set if string contains alternating characters and
                                          attributes
           bit 0: set in order to move cursor after write
     BL = attribute if AL bit 1 clear
     BH = display page number
     DH,DL = row,column of starting cursor position
     CX = length of string
     ES:BP -> start of string
     Note:   recognizes CR, LF, BS, and bell
*/

            enable();

            length=strlen(diskerrmsg);
            segment = FP_SEG(diskerrmsg);
            off = FP_OFF(diskerrmsg);

            // simple error message to screen
            asm {
            push es
            push bp
            mov ax,segment
            mov es,ax
            mov bp,off
            mov ah,0x13
            mov al,0
            mov bx,0
            mov dh,10
            mov dl,10
            mov cx,length
            int 0x10
            pop bp
            pop es
            }

            // ignore error because what do we do??

            length=strlen(retryfail);
            segment = FP_SEG(retryfail);
            off = FP_OFF(retryfail);

            asm {
            push es
            push bp
            mov ax,segment
            mov es,ax
            mov bp,off
            mov ah,0x13
            mov al,0
            mov bx,0
            mov dh,10
            mov dl,11
            mov cx,length
            int 0x10
            pop bp
            pop es
            }

                // wait for key press
            while (err==0) {
            	while (*G_kpstart==*G_kpend) {
                    // wait for keyboard input
                }
           		switch (G_keybuf[*G_kpstart]) {
                    case 'r' : case 'R' : err=1; break;
                    case 'f' : case 'F' : err=2; break;
                    default  : beep();
                }
                (*G_kpstart)++;
                if (*G_kpstart==ENDOFBUF) *G_kpstart=0;
            }
            disable();

            // we haven't saved it so we can't restore
//            restmsgregion();

                // set value of AL and continue
            switch (err) {
                case 1:
                    _AL=0x01;
                    break;
                case 2:
                default:
                    _AL=0x03;
            }
            // note we pop value of ax to bx as we do not want to destroy ax
            asm {
                leave
                pop di
                pop si
                pop ds
                pop es
                pop dx
                pop cx
                pop bx
                pop bx
                iret
            }
        }
    }
    else
    {
        _AL=0x01;                   // probably the printer, just retry
        outp(0x20,0x20);            // signal EOI
        enable();
    }
}


