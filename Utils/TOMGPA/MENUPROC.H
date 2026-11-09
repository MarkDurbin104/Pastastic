/****************************************************************************
* Project     : GPA
* File        : menuproc.h
* Description : support for menu process functions
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:02  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/menuproc.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:02   JGRAY
 *  
* 
****************************************************************************/
#ifndef MENUPROC_H    // stop multiple includes

#define MENUPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef MENUPROC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC void         drawmenu    (void);
PUBLIC INT          runmenu     (void);
PUBLIC void         menucur     (void);

// PUBLIC SYMBOLS E
#ifdef MENUPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------

#endif  //  def MENUPROC_C

#endif  //  ndef MENUPROC_H
// **************************************************************************
// menuproc.h <end-of-file>

