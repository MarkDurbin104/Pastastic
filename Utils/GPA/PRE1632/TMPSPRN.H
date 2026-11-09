#ifndef SPRNDEV_H

#define SPRNDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef SPRNDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef SPRNDEV_C
int sprn_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_sprn 
#if INIT
= {
	DEVSIG,
    "Serial Printer Device Copyright (c) Unisys Ltd 1992 Version 1.00",
    "OUTPUT02",
    "SPRN",
    "IOCR",
    NULL,
    NULL,
    (DFPTR)sprn_control,
    NULL,
	DEVSIG
}
#endif
;


// PUBLIC SYMBOLS E
#ifdef SPRNDEV_C


unsigned char   *G_sprn;
int             G_spcurx,G_spcury;
int             G_spmaxx,G_spmaxy;
int             G_sprntype;

int             sprn_shutdown    (void);
int             sprn_startup     (void);

#endif  //  def SPRNDEVICE

#endif  //  ndef SPRNDEV_H


