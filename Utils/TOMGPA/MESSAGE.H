/****************************************************************************
* Project     : GPA
* File        : message.h
* Description : 1) declare functions to be found in message.c
*               2) define global variables for message.c module use only
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:02  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/message.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:02   JGRAY
 *  
* 
****************************************************************************/
#ifndef MESSAGE_H_FILE
#define MESSAGE_H_FILE

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef MESSAGE_C_FILE
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC INT      asigndev            (CHAR *name,CHAR *group,CHAR mode);
PUBLIC LONG     sendmsg             (CHAR *group,INT mtype,...);
PUBLIC INT      initdevices         (void);
PUBLIC void     closedevices        (void);
PUBLIC void     prdevlist           (void);
PUBLIC void     savedevices         (void);
PUBLIC void     restdevices         (void);

// PUBLIC SYMBOLS E

#ifdef MESSAGE_C_FILE      /* declare these vars. only when in message.c */

DEVTABLE      *G_device=NULL;
DEVHEADER     *G_devtab[LENOFDEVTABLE];
INT            G_numdt=0;
DEVTABLE      *G_sdevice=NULL;
INT            G_devsaved=0;

INT            finddg        (CHAR *name,CHAR *group);
INT            finddev       (CHAR *name,INT idx);
INT            devinlist     (CHAR *name);
INT            adddev        (CHAR *name,CHAR *group,INT ofs);

#endif // def MESSAGE_C_FILE

#endif // ndef MESSAGE_H_FILE
// **************************************************************************
// message.h <end-of-file>

