#ifndef CREDTDEV_H
#define CREDTDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef CREDTDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S
#ifdef CREDTDEV_C
#include <stdarg.h>

int credit_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_credt
#if INIT
= {
    DEVSIG,
    "GPA Magtek Credit Card Reader Driver Copyright (c) Unisys 1994 Version 1.00",
    "INPUT03",
    "MT",
    "IECi",
    NULL,
    NULL,
    (DFPTR)credit_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef CREDTDEV_C
// Place your device's variables & prototypes here

#endif  //  def CREDTDEV_C

#endif  //  def CREDTDEV_H
