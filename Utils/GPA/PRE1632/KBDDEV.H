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
INT kbd_control(INT type,va_list ap);
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
    (DFPTR)kbd_control,
    NULL,
	DEVSIG
}
#endif
;

PUBLIC volatile UCHAR  G_shiftstat
#if INIT
=0
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

#define ENDOFBUF     0x100
#define RECORDBUF    0x100
#define MAXHOT 		 50

void interrupt (*oldkeyb)(void);
void interrupt (*oldtick)(void);


volatile INT            G_extnext=0;
volatile INT            G_keybuf[ENDOFBUF+1];
volatile INT            G_recbuf[ENDOFBUF+1];
volatile INT            G_kpstart=0;
volatile INT            G_kpend=0;
volatile INT            G_recorded=0;
volatile INT            G_inplaymode=0;
volatile INT            G_inrecmode=0;
KLOOPFUNC               G_kloop[32];
HOTKEY					G_hotkey[MAXHOT];
INT 					G_numhot=0;

INT             findshifts  (INT k);
void            bufferkey   (INT k);
void interrupt  mykeyb      (void);
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
void 			addhotkey   (INT k,CHAR *n,CHAR *d);

#endif  //  def KBD_DEV_C

#endif  //  ndef KBD_DEV_H

