/****************************************************************************
* Project     : GPA
* File        : stampdev.h
* Description : stamp printer device header
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:12  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/stampdev.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:12   JGRAY
 *  
* 
****************************************************************************/
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
LONG stamp_control(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_stamp 
#if INIT
= {
    DEVSIG,
    "Stamp printer Device Copyright (c) Unisys Ltd 1994 Version 1.00",
    "OUTPUT 03",
    "STAMP",
    "IOCR",
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

#endif  //  def STAMPDEV_C

#endif  //  ndef STAMPDEV_H

// **************************************************************************
// stampdev.h <end-of-file>

