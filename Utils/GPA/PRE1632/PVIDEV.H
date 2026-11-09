#ifndef PVIDEV_H
#define PVIDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef PVIDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef PVIDEV_C
PUBLIC int pvi_control(char type,va_list ap);
#endif

PUBLIC DEVHEADER dev_pvi
#if INIT
= {
    DEVSIG,
    "P.V.I. Copyright (c) Unisys 1993 Version 1.00",
    "OUTPUT01",
    "PVI",
    "ioRACBLXSlIEDsrpF",
    NULL,
    NULL,
    (DFPTR)pvi_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef PVIDEV_C
// Place your device's variables & prototypes here

#endif  //  def PVIDEV_C

#endif  //  ndef PVIDEV_H
