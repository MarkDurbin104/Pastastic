/****************************************************************************
* Project     : GPA
* File        : skbddev.h
* Description : Keyboard device header
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:12  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/skbddev.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:12   JGRAY
 *  
* 
****************************************************************************/
#ifndef KBD_DEV_H

#define KBD_DEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef KBD_DEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef KBD_DEV_C
LONG kbd_control(INT type,va_list ap);
#endif
// PUBLIC SYMBOLS S

PUBLIC DEVHEADER dev_kbd 
#if INIT
= {
    DEVSIG,
    "Keyboard Device Copyright (c) Unisys Ltd 1992 Version 1.00",
    "INPUT 01",
    "KBD",
    "I C ",
    NULL,
    NULL,
    kbd_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef KBD_DEV_C

typedef struct 
{
    INT k;
    CHAR *n;
    CHAR *d;
    UCHAR disabled;
} HOTKEY;

#define MAXHOT          50

KLOOPFUNC               G_kloop[MAXHOT];
HOTKEY                  G_hotkey[MAXHOT];
INT                     G_numhot=0;

#endif  //  def KBD_DEV_C

#endif  //  ndef KBD_DEV_H

// **************************************************************************
// skbddev.h <end-of-file>

