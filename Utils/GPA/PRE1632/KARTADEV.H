#ifndef KARTADEV_H
#define KARTADEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef KARTADEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef KARTADEV_C
PUBLIC int KARTA_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_KARTA
#if INIT
= {
    DEVSIG,
    "1994 Copyright (c) Russian Post Office 1994 Version 1.00",
    "OUTPUT01",
    "KARTA",
    "ioRACBLXSlIEDsrpF",
    NULL,
    NULL,
    (DFPTR)KARTA_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef KARTADEV_C
// Place your device's variables & prototypes here

#endif  //  def KARTADEV_C

#endif  //  ndef KARTADEV_H
