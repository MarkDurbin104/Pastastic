#ifndef ERICDEV_H
#define ERICDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef ERICDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef ERICDEV_C
PUBLIC int ERIC_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_ERIC
#if INIT
= {
    DEVSIG,
    "Eric Device Copyright (c) Eric Tseng 1994 Version 1.00",
    "OUTPUT01",
    "ERIC",
    "ioRACBLXSlIEDsrpF",
    NULL,
    NULL,
    (DFPTR)ERIC_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef ERICDEV_C
// Place your device's variables & prototypes here

#endif  //  def ERICDEV_C

#endif  //  ndef ERICDEV_H
