#ifndef OSSDEV_H

#define OSSDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef OSSDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef OSSDEV_C
LONG oss_control(INT type,va_list ap);
#endif
// PUBLIC SYMBOLS S

PUBLIC DEVHEADER dev_oss
#if INIT
= {
	DEVSIG,
    "Operating System Services Device Copyright (c) Unisys Ltd 1994 Version 1.00",
    "OSS 01",
    "OSS",
    "iOIE",
    NULL,
    NULL,
    oss_control,
    NULL,
	DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef OSSDEV_C

#endif  //  def OSSDEV_C

#endif  //  ndef OSSDEV_H

