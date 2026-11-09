#ifndef SCALEDEV_H

#define SCALEDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef SCALEDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S
#ifdef SCALEDEV_C
INT sca_control(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_scale 
#if INIT
= {
	DEVSIG,
    "USPS Scale Device (Kg) Copyright (c) Unisys Ltd 1992 Version 1.00",
    "INPUT 02",
    "SCALE",
    "I CR",
    NULL,
    NULL,
    (DFPTR)sca_control,
    NULL,
	DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef SCALEDEV_C

#endif  //  def SCALEDEV_C

#endif  //  ndef SCALEDEV_H

