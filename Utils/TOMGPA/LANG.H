/****************************************************************************
* Project     : GPA
* File        : lang.h
* Description : language support header
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:02  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/lang.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:02   JGRAY
 *  
* 
****************************************************************************/
#ifndef LANG_H
#define LANG_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef LANG_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC void           swaplang      (void);
PUBLIC CHAR           *langtext     (INT idx);
PUBLIC CHAR           *langstr      (CHAR *name,CHAR *s);
PUBLIC void           adddevname    (CHAR *n);
PUBLIC void           addlangname   (CHAR *n);
PUBLIC void           restoreform   (void);
PUBLIC INT            justbutt      (PFORM form);

// PUBLIC SYMBOLS E

#ifdef LANG_C

typedef struct {
    CHAR d[10];     // device or group name
    CHAR t[80];     // text file name
    CHAR f[80];     // font file name
    INT  n;         // don't know what this is for :JGQ
} LANGMAP;

LANGMAP G_langmaps[LANGUAGESQ];
INT     G_numlm=0;
CHAR    G_langs[LANGUAGESQ][LENOFLANGNAME];    // name of the language table
CHAR    G_devs[MAXNOOFDEVS][LENOFDEVICE];
INT     G_numdn=0;

#endif // def LANG_C

#endif // ndef LANG_H
// **************************************************************************
// lang.h <end-of-file>

