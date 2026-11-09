/****************************************************************************
* Project     : GPA
* File        : textdev.h
* Description : text device header
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:14  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/textdev.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:14   JGRAY
 *  
* 
****************************************************************************/
#ifndef SCRDEV_H
#define SCRDEV_H
#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef SCRDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef SCRDEV_C
LONG    scr_control    (INT type,va_list ap);
#endif

// PUBLIC SYMBOLS S
PUBLIC DEVHEADER dev_scr
#if INIT
=
{
    DEVSIG,
    "Text",
    "OUTPUT01",
    "VGA",
    "ioRACBLXSlIEDsrF",
    NULL,
    NULL,
    scr_control,
    NULL,
    DEVSIG
}
#endif
;

#ifdef SCRDEV_C
SCRATTR G_screen;
INT     G_newscr=1;
CHAR    G_hattr[4]={0x71,0x17,0x7C,0x47};
#endif  //  def SCRDEV_C
#endif  //  ndef SCRDEV_H

// **************************************************************************
// textdev.h <end-of-file>

