/****************************************************************************
* Project     : GPA
* File        : scaledev.h
* Description : USPS scale header
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:08  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/scaledev.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:08   JGRAY
 *  
* 
****************************************************************************/
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
LONG sca_control(INT type,va_list ap);
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
    sca_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef SCALEDEV_C

#endif  //  def SCALEDEV_C

#endif  //  ndef SCALEDEV_H

// **************************************************************************
// scaledev.h <end-of-file>

