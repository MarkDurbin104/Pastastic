/****************************************************************************
* Project     : GPA
* File        : prndev.h
* Description : printer device header
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:10  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/prndev.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:10   JGRAY
 *  
* 
****************************************************************************/
#ifndef PRNDEV_H

#define PRNDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef PRNDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S
#ifdef PRNDEV_C
LONG prn_control(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_prn 
#if INIT
= {
    DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN","IOCR",NULL,NULL,(DFPTR)prn_control,NULL,
    DEVSIG
}
#endif
;

#define PP_DRAFT       0
#define PP_LETTER      1
#define PP_GRAPH       2
#define PP_HIGHG       3

// PUBLIC SYMBOLS E
#ifdef PRNDEV_C

INT             G_ppcurx=0;
INT             G_ppcury=0;
INT             G_ppmaxx=80;
INT             G_ppmaxy=66;
INT             G_pprnsize=1;
INT             G_pprnattr=1;
INT             G_pprnmode=0;

INT             prn_shutdown    (void);
INT             prn_startup     (INT type);

#endif  //  def PRNDEVICE

#endif  //  ndef PRNDEV_H

// **************************************************************************
// prndev.h <end-of-file>

