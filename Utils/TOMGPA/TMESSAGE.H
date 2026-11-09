/****************************************************************************
* Project     : GPA
* File        : tmessage.h
* Description : temp version of message.h
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:52:16  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/tmessage.h_v  $
 * 
 *    Rev 1.1   Nov 03 1995 11:52:16   JGRAY
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

PUBLIC INT         asigndev        (CHAR *name,CHAR *group,CHAR mode);
PUBLIC LONG        sendmsg            (CHAR *group,INT mtype,...);
PUBLIC INT         initdevices        (void);
PUBLIC void     closedevices    (void);
PUBLIC void     prdevlist        (void);
PUBLIC void     savedevices        (void);
PUBLIC void     restdevices        (void);

// PUBLIC SYMBOLS E

#ifdef MESSAGE_C_FILE

DEVTABLE     *G_device=NULL;
DEVHEADER     *G_devtab[30];
INT           G_numdt=0;

DEVTABLE     *G_sdevice=NULL;
INT         G_devsaved=0;

INT         finddg        (CHAR *name,CHAR *group);
INT         finddev        (CHAR *name,INT idx);
INT         devinlist    (CHAR *name);
INT         adddev        (CHAR *name,CHAR *group,INT ofs);

#endif // def MESSAGE_C_FILE

#endif // ndef MESSAGE_H_FILE
// **************************************************************************
// tmessage.h <end-of-file>

