#define OSSDEV_C
#include <conio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <bios.h>
#include <malloc.h>
#include "types.h"
#include "ossdev.h"

#define CMADR    0x70
#define CMDAT    0x71

LONG oss_control(INT type,va_list ap)
{
    LONG retval=1L;
    INT x,rax,rbx,rcx,rdx;
    CHAR *t,tmp[100],r;

    switch (type) {
        case MESSAGE_s :                     // sound
            sound(va_arg(ap,INT));
			break;
        case MESSAGE_ns :                    // nosound
            nosound();
			break;
        case MESSAGE_d :                     // delay
            delay(va_arg(ap,INT));
			break;
        case MESSAGE_xy :                    // gotoxy
            x=va_arg(ap,INT);
            gotoxy(x,va_arg(ap,INT));
            break;
        case MESSAGE_cs :                    // clrscr
            clrscr();
            break;
        case MESSAGE_ta :                    // textattr
            textattr(va_arg(ap,UCHAR));
            break;
        case MESSAGE_p  :                    // print
            t=va_arg(ap,CHAR *);
            vsprintf(tmp,t,ap);
		    cprintf("%s",tmp);
            break;
        case MESSAGE_pc  :                    // put cmos
            outportb(CMADR,va_arg(ap,CHAR));
            outportb(CMDAT,va_arg(ap,CHAR));
            break;
        case MESSAGE_21 :                     // int 21
            rax=va_arg(ap,INT); rbx=va_arg(ap,INT);
            rcx=va_arg(ap,INT); rdx=va_arg(ap,INT);
            _DX=rdx; _CX=rcx; _BX=rbx; _AX=rax;
            geninterrupt(0x21);
            r=_AL;
            retval=(LONG)r;
            break;
        case MESSAGE_fm :                     // available memory
            retval=farcoreleft();
            break;

    }
    return(retval);
}

