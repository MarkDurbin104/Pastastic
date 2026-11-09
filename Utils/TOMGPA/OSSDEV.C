/****************************************************************************
* Project     : GPA
* File        : ossdev.c
* Description : Some system commands and exception and critical error handler
*               routines.  The handler routines have LOTS and LOTS of hard
*               coded magic numbers.  Probably needs tidying up sometime.
* 
* $Revision:   1.3  $  $Date:   Nov 01 1995 15:15:48  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/ossdev.c_v  $
* 
*    Rev 1.3   Nov 01 1995 15:15:48   JGRAY
*  
* 
****************************************************************************/
#define OSSDEV_C
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <dos.h>
#include <bios.h>
#include <malloc.h>
#include <memory.h>
#include <alloc.h>

#include "gpasizes.h"
#include "types.h"
#include "gprim.h"
#include "ossdev.h"
#include "control.h"
#include "config.h"
#include "message.h"
#include "function.h"
#include "actions.h"

#define CMADR    0x70
#define CMDAT    0x71

// from GPRIM.H
#define WRITEPLANE(a) OUTPW(0x3C4,(UINT16)((0x100<<(a))|2));
#define READPLANE(a)  OUTPW(0x3CE,(UINT16)(((a)<<8)|4));

//************************************************************
//S routing of operating system control message to appropriate function
//D selected messages are processed by this routine
//D n.b. first call ever this checks for existance of env. value SOUNDER
//P integer message type (see [should be eval] table in types for value)
//P variable according to command.
//R long reply of 1 or according to command.

LONG oss_control(INT type,va_list ap)
{
   LONG retval=1L;
   INT x,rax,rbx,rcx,rdx;
   CHAR *t,tmp[100],r;              // used for print command. IS THIS Big enough ?:JGQ 23/10
   static INT firsttime=1;
   static INT nosnd=0;
   if (firsttime)
      {
      firsttime=0;
      if (getenv(SOUNDER)!=NULL) nosnd=1;
      }
   switch (type)
      {
      case MESSAGE_s :                     // sound
         if (!nosnd)
            sound(va_arg(ap,INT));
         break;
      case MESSAGE_ns :                    // nosound
         if (!nosnd)
            nosound();
         break;
      case MESSAGE_d :                     // delay
         if (!nosnd)
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

//************************************************************
//* CRITICAL ERROR HANDLER CODE

// from #include "kbddev.h"
extern volatile INT            *G_keybuf;
extern volatile INT            *G_kpstart;
extern volatile INT            *G_kpend;
// form "start.h"
#define ENDOFBUF        0x100


//**************************************************
//S Routine to save screen area
//D relies on G_criterrscrnbuf already having been set up

void savemsgregion(void)
{
   CHAR *s,*b;
   INT i,j;

   if (G_criterrscrnbuf != NULL)
      {
        b=G_criterrscrnbuf;
        for (i=0;i<4;i++) {
            s=COLVIDMEM+CE_XBYTEPOS+CE_YPOS*80;
            READPLANE(i);
            for (j=0;j<CE_HEIGHT;j++) {
                memcpy(b,s,CE_BYTEWIDTH);
                s+=80;
                b+=CE_BYTEWIDTH;
            }
        }
    }
}

//**************************************************************
//S Routine to restore the saved screen area
//D saved area was G_criterrscrnbuf 

void restmsgregion(void)
{
    CHAR *s,*b;
    INT i,j;

    if (G_criterrscrnbuf!=NULL) {
        b=G_criterrscrnbuf;
        for (i=0;i<4;i++) {
            s=COLVIDMEM+CE_XBYTEPOS+CE_YPOS*80;
            WRITEPLANE(i);
            for (j=0;j<CE_HEIGHT;j++) {
                memcpy(s,b,CE_BYTEWIDTH);
                s+=80;
                b+=CE_BYTEWIDTH;
            }
        }
    }
}

//**************************************************
//void protcrit(void)
//{
//    INT x=0;
//}

//************************************************************
typedef struct {
    unsigned    carry:1;
    unsigned    unknown1:1;
    unsigned    p:1;
    unsigned    unknown2:1;
    unsigned    a:1;
    unsigned    unknown3:1;
    unsigned    z:1;
    unsigned    s:1;

    unsigned    unknown4:1;
    unsigned    i:1;
    unsigned    unused:6;
} BITFLAGS;

//**************************************************
// exception error handler   MUST BE IN LOCKED MEMORY!!
extern void interrupt (*oldexceptionerror)();
extern void interrupt exceptionerrorhandler(void);  // See except.asm


//************************************************************
//S Routine to set up exceptionerrorhandler(except.asm) as the exeption handler
//D Gets the old vector and sets the new one via int 0x31

void setexceptionhandler(void)
{
    INT flags;
    BITFLAGS *bitflags;

    _AX=0x0202;             //DPMI call - Get processor exception handler vector
    _BL=0x0D;               //GPF vector
    geninterrupt(0x31);
    flags = _FLAGS;         // get a copy of the flags register
    bitflags = (BITFLAGS *) &flags;
    if (!(bitflags->carry))         // carry clear for success
    {
        // save old interrupt
        oldexceptionerror = MK_FP (_CX, _DX);

        // set up new
        _AX=0x0203;
        _BL=0x0D;               //GPF vector
        _CX=FP_SEG(exceptionerrorhandler);
        _DX=FP_OFF(exceptionerrorhandler);
        geninterrupt(0x31);
        flags = _FLAGS;         // get a copy of the flags register
        bitflags = (BITFLAGS *) &flags;
        if (bitflags->carry)
        {
            // call failed
        }
    }
}

//************************************************************
//S Routine to release the exception handler by setting to its previous value
//D original value was determined by the setexceptionhandler(void) routine
//D and stored in local static ptr oldexceptionerror

void releaseexceptionhandler(void)
{
    INT flags;
    BITFLAGS *bitflags;

    if (oldexceptionerror)         // we got it
    {
        // restore old
        _AX=0x0203;
        _BL=0x0D;               //GPF vector
        _CX=FP_SEG(oldexceptionerror);
        _DX=FP_OFF(oldexceptionerror);
        geninterrupt(0x31);
        flags = _FLAGS;         // get a copy of the flags register
        bitflags = (BITFLAGS *) &flags;
        if (bitflags->carry)
        {
            // call failed - not much we can do!?
        }
    }
}

//**************************************************
// critical error handler   MUST BE IN LOCKED MEMORY!!

void interrupt (*oldcriticalerror)();

//************************************************************
//S routine to handle critical errors.
//D Processes disk i/o errors - FAILS ALL OTHERS

void interrupt criticalerrorhandler(void)
{
    INT AX=_AX;     // Get status values
    INT DI=_DI;
    INT err=0;
    CHAR msg[20];

   // if disk I/O error handle, else pass on.
   if (!(AX & 0x8000))         //AH bit 7 set 0 indicates an I/O error
      {
      if (AX & 0x0380)   // Test if Ignore, Retry Abort allowed
         {
         if (DI == 0)
            {
            strcpy(msg, "Write protect error");
            }
         else
            {
            strcpy(msg, "Disk error");
            }
                // save screen area
                // put up message line (change to a box?)
         beep();

         savemsgregion();

         sendmsg("OUTPUT1",MESSAGE_S,1);
         sendmsg("OUTPUT1",MESSAGE_AA,1);
         sendmsg("OUTPUT1",MESSAGE_b,(CE_XBYTEPOS*8)+4,(11*19)+9,((CE_XBYTEPOS+CE_BYTEWIDTH-1)*8)+4,(14*19)+9);
         sendmsg("OUTPUT1",MESSAGE_B,CE_XBYTEPOS,11,(CE_XBYTEPOS+CE_BYTEWIDTH-1),14);
         sendmsg("OUTPUT1",MESSAGE_AA,0x10);
         sendmsg("OUTPUT1",MESSAGE_o,(CE_XBYTEPOS+1),12,"%s",isdefstr(msg));
         sendmsg("OUTPUT1",MESSAGE_o,(CE_XBYTEPOS+1),13,"%s",isdefstr("Retry or Fail R/F"));
                // wait for key press
         enable();
         while (err==0)
            {
            while (*G_kpstart==*G_kpend)
               {
                    // wait for keyboard input
               }
            switch (G_keybuf[*G_kpstart])
               {
                    case 'r' : case 'R' : err=1; break;
                    case 'f' : case 'F' : err=2; break;
                    default  : beep();
               }
            (*G_kpstart)++;
            if (*G_kpstart==ENDOFBUF) *G_kpstart=0;
            }
         disable();

         restmsgregion();

                // set value of AL and continue
         switch (err)
            {
                case 1:
                    _AL=0x01;
                    break;
                case 2:
                default:
                    _AL=0x03;
            }
            // note we pop value of ax to bx as we do not want to destroy ax
         asm
            {
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
        // fail all other devices
      _AL=0x03;
        // note we pop value of ax to bx as we do not want to destroy ax
      asm
         {
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
//    _chain_intr(oldcriticalerror);
      }
}

//************************************************************
//S Routine to vector the critical error handler
//D stors the old value in oldcriticalerror - currently not used for chain tho

void setprotmodeint(void)
{
    INT flags;
    BITFLAGS *bitflags;

    _AX=0x0204;             //DPMI call - Get protected mode interrupt
    geninterrupt(0x31);     //Borland DOS Powerpak hooks real mode for this
    flags = _FLAGS;         // get a copy of the flags register
    bitflags = (BITFLAGS *) &flags;
    if (!(bitflags->carry))         // carry clear for success
    {
        // save old interrupt
        oldcriticalerror = MK_FP (_CX, _DX);

        // set up new
        _AX=0x0205;
        _BL=0x24;       // Critical error interrupt
        _CX=FP_SEG(criticalerrorhandler);
        _DX=FP_OFF(criticalerrorhandler);
        geninterrupt(0x31);
        flags = _FLAGS;         // get a copy of the flags register
        bitflags = (BITFLAGS *) &flags;
        if (bitflags->carry)
        {
            // call failed
        }
    }

    // Now set up a callback for the real mode handler

//    _DS=FP_SEG(protcrit);   // Protected mode procedure to call
//    _SI=FP_OFF(protcrit);
//
//    _ES=FP_SEG(protbuff);   // Protected mode procedure to call
//    _DI=FP_OFF(protbuff);
//
//    _AX=0x0303;             //DPMI call - Get protected mode interrupt
//    geninterrupt(0x31);     //Borland DOS Powerpak hooks real mode for this
//    flags = _FLAGS;         // get a copy of the flags register
//    bitflags = (BITFLAGS *) &flags;
//    if (!(bitflags->carry))         // carry clear for success
//    {
//    }
    
//    realcmd (SETCRITCALLBACK, FP_SEG(protcrit), FP_OFF(protcrit) );
}

//************************************************************
//void restoreprotmodeint(void)
//{
//    INT x=0;
//}
//
// **************************************************************************
// ossdev.c <end-of-file>

