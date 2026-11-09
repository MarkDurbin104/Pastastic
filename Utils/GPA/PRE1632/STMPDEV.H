#ifndef STAMPDEV_H
#define STAMPDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef STAMPDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif


// PUBLIC SYMBOLS S
#ifdef STAMPDEV_C
PUBLIC int stamp_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_stamp
#if INIT
= {
    DEVSIG,
    "Stamp printer Copyright (c) Unisys Ltd. 1994 Version 1.00",
    "OUTPUT02",
    "STAMP",
    "RoISAbEFBLM",
    NULL,
    NULL,
    (DFPTR)stamp_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef STAMPDEV_C
// Place your device's variables & prototypes here

#endif  //  def STAMPDEV_C

#endif  //  ndef STAMPDEV_H
