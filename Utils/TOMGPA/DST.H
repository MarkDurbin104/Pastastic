/****************************************************************************
* Project     : GPA
* File        : dst.h
* Description : datastore routine definitions
*
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:46  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/dst.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:46   JGRAY
 *  
* 
****************************************************************************/
#ifndef DST_H    // stop multiple includes

#define DST_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef DST_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

// PUBLIC SYMBOLS S
//-------------------------PUBLIC Prototypes & Variables-------------------
PUBLIC INT              loadsdata   (CHAR *sys);
PUBLIC INT              savesdata   (CHAR *sys);
PUBLIC INT              snum        (CHAR *name);
PUBLIC INT              fnum        (CHAR *name,CHAR *fname);
PUBLIC INT              knum        (CHAR *name,CHAR *fname);

PUBLIC STORE            *G_store;
PUBLIC LSTOREF          *G_lib;
PUBLIC INT              G_nums INIT(0);
PUBLIC INT              G_numl INIT(0);

// PUBLIC SYMBOLS E
#ifdef DST_C

#define LENOFDSTFNAME 80
#define LENOFDSTUBUF 160

//------------------------PRIVATE Prototypes & Variables-------------------

INT                     readstores  (INT fd,PSTORE s,INT *scnt);
INT                     writestores (INT fd,PSTORE s,INT scnt);
INT                     readlib     (INT fd,PLSTOREF l,INT *icnt);
INT                     writelib    (INT fd,PLSTOREF l,INT icnt);
void                    doupdates   (void);

#endif  //  def DST_C

#endif  //  ndef DST_H
// **************************************************************************
// dst.h <end-of-file>

