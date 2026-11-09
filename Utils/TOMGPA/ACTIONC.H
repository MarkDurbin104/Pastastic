/****************************************************************************
* Project     : GPA
* File        : actionc.h
* Description : 
* 
* $Revision:   1.2  $  $Date:   Nov 01 1995 16:06:36  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/actionc.h_v  $
 * 
 *    Rev 1.2   Nov 01 1995 16:06:36   JGRAY
 *  
 * 
 *    Rev 1.1   Oct 20 1995 15:16:30   JGRAY
 * Annotations
* 
****************************************************************************/
// actionc.h
#ifndef ACTIONC_H    // stop multiple includes

#define ACTIONC_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef ACTIONC_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define gettoken(b) (  (UCHAR   )*(b))
#define gettiny(b)  (  (UCHAR   )*(b))
#define getint(b)   (*((UINT16 *) (b)))
#define getlong(b)  (*((ULONG  *) (b)))
#define getdoub(b)  (*((double *) (b)))
#define getstrg(b)  (  (UCHAR  *) (b))

PUBLIC INT                  loadactions     (CHAR *sys);
PUBLIC void                 freeactions     (void);
PUBLIC LONG                 actionofs       (INT idx);
PUBLIC UCHAR                actiontype      (INT idx);
PUBLIC UCHAR                actiondeb       (INT idx);
PUBLIC CHAR *               actionname      (INT idx);
PUBLIC UCHAR *              actionbuf       (INT idx);
PUBLIC void                 setactionbuf    (INT idx,UCHAR *s);
PUBLIC INT                  findname        (CHAR *name);

PUBLIC NAMEINDEX            *G_nbuf         INIT(NULL); // pointer to action name array
PUBLIC INT                  G_numn          INIT(0);    // Number of action names
PUBLIC NAMEBUFFER           *G_anamebuf     INIT(NULL); // pointer to index of actions
PUBLIC CHAR                 G_afilename[LENOFAFN];      // action filename (path + filename *I.DAT)
PUBLIC LONG                 G_buffofs       INIT(0L);   // Offset in actions file to name buffer offsets
// PUBLIC SYMBOLS E

#ifdef ACTIONC_C

//------------------------PRIVATE Prototypes & Variables-------------------

UCHAR *G_asbuff=NULL;

#endif  //  def ACTIONC_C

#endif  //  ndef ACTIONC_H

// **************************************************************************
// actionc.h <end-of-file>
