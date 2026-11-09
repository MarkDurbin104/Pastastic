/****************************************************************************
* Project     : GPA
* File        : kbddev.h
* Description : keyboard device driver
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:58  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/kbddev.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:58   JGRAY
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

typedef struct {
    INT k;
    CHAR *n;
    CHAR *d;
    UCHAR disabled;
} HOTKEY;

volatile INT                *G_keybuf;
volatile INT                *G_kpstart;
volatile INT                *G_kpend;
KLOOPFUNC                   *G_kloop;

HOTKEY                      G_hotkey[MAXHOT];
INT                         G_numhot=0;

INT             keyhit      (void);
INT             addklfunc   (INT p,FPTR f);
INT             delklfunc   (FPTR f);
void            runklfuncs  (void);
INT             getkey      (void);
INT             peekkey     (void);
void            pokekey     (INT k);
void            repkey      (void);
void            keyflush    (void);
void            rstrecord   (void);
void            recordkeys  (INT k);
INT             pushtocr    (INT st,INT onoff);
void            playback    (INT start);
void            addhotkey   (INT k,CHAR *n,CHAR *d);

#endif  //  def KBD_DEV_C

#endif  //  ndef KBD_DEV_H

// **************************************************************************
// kbddev.h <end-of-file>

