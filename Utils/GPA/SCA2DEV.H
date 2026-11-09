#ifndef SCA2DEV_H
#define SCA2DEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef SCA2DEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef SCA2DEV_C
PUBLIC int sca2_control(char type,va_list ap);
#endif

PUBLIC DEVHEADER dev_sca2
#if INIT
= {
    DEVSIG,
    " Copyright (c) The Post Office 1994 Version 1.00",
    "OUTPUT01",
    "SCA2",
    "ioRACBLXSlIEDsrpF",
    NULL,
    NULL,
    (DFPTR)sca2_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef SCA2DEV_C
// Place your device's variables & prototypes here

#endif  //  def SCA2DEV_C

#endif  //  ndef SCA2DEV_H
