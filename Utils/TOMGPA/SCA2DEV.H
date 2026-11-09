/****************************************************************************
* Project     : GPA
* File        : sca2dev.h 
* Description : Sca2 header
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:08  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/sca2dev.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:08   JGRAY
 *  
* 
****************************************************************************/
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
PUBLIC INT sca2_control(CHAR type,va_list ap);
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
// **************************************************************************
// sca2dev.h <end-of-file>

