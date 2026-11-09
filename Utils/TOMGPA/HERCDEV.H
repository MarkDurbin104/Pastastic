/****************************************************************************
* Project     : GPA
* File        : hercdev.h
* Description : hercules device support
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:56  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/hercdev.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:56   JGRAY
 *  
* 
****************************************************************************/
#ifndef HERCDEV_H

#define HERCDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef HERCDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif


#ifdef HERCDEV_C
INT    hscr_control (INT type,va_list ap);
#endif

// PUBLIC SYMBOLS S
PUBLIC DEVHEADER dev_herc
#if INIT
= {
    DEVSIG,
    "HERC Device Copyright (c) Unisys Ltd 1993 Version 1.00",
    "OUTPUT01",
    "HERC",
    "ioRACBLXSlIEDsr",
    NULL,
    NULL,
    (DFPTR)hscr_control,
    NULL,
    DEVSIG
}
#endif
;

#ifdef HERCDEV_C

// PUBLIC SYMBOLS E

extern SCRATTR G_screen;

extern CHAR            G_hattr[3];

#endif  //  def HERCDEV_C

#endif  //  ndef HERCDEV_H

// **************************************************************************
// hercdev.h <end-of-file>

