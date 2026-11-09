#ifndef ORACLEDEV_H
#define ORACLEDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef ORACLEDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

#ifdef ORACLEDEV_C
PUBLIC int ORACLE_control(char type,va_list ap);
#endif

PUBLIC DEVHEADER dev_ORACLE
#if INIT
= {
    DEVSIG,
    "Oracle Copyright (c) Unisys 1994 Version 1.00",
    "DISK  01",
    "ORACLE",
    "CUDTSGFPRNIEd",
    NULL,
    NULL,
    (DFPTR)ORACLE_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef ORACLEDEV_C
// Place your device's variables & prototypes here

#endif  //  def ORACLEDEV_C

#endif  //  ndef ORACLEDEV_H
