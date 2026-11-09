/****************************************************************************
* Project     : GPA
* File        : ossdev.h
* Description : Support of the crit error handlers.
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:08  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/ossdev.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:08   JGRAY
 *  
* 
****************************************************************************/
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
// PUBLIC SYMBOLS START
PUBLIC void setprotmodeint(void);

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

                    // Pointer to memory for use as screen save
                    // and restore buffer by the critical error handler.
PUBLIC CHAR *G_criterrscrnbuf
#if INIT
=NULL
#endif
;

#define CE_BYTEWIDTH   22    // values to calculate the size of the screen buffer
#define CE_HEIGHT      70
#define CE_XBYTEPOS    25    // X byte position of saved screen area
#define CE_YPOS        215   // Y pixel position of saved screen area


// PUBLIC SYMBOLS END

// PRIVATE 
#ifdef OSSDEV_C

extern void savemsgregion(void);
extern void restmsgregion(void);


#endif  //  def OSSDEV_C

#endif  //  ndef OSSDEV_H

// **************************************************************************
// ossdev.h <end-of-file>

