/****************************************************************************
* Project     : GPA
* File        : formproc.h
* Description : support for formproc.c
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:50  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/formproc.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:50   JGRAY
 *  
* 
****************************************************************************/
#ifndef FORMPROC_H    // stop multiple includes

#define FORMPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FORMPROC_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC INT      _cdecl       scmp           (const void *a,const void *b);
PUBLIC CHAR            *textstr    (PFORMF fld);
PUBLIC INT             findid      (INT id);
PUBLIC INT             initform    (PFORM f);
PUBLIC INT             runform     (INT clear);
PUBLIC void            clrform     (PFORM f);
PUBLIC void            redrawform  (void);
PUBLIC void            updatest    (void);
PUBLIC void            fillform    (PFORM f);
PUBLIC void            fillfields  (PFORM f);
PUBLIC void            srchitem    (PFORMF f);
PUBLIC void            prformname  (PFORM f);
PUBLIC void            prformref   (PFORMF f);

PUBLIC CHAR            **G_formvars INIT(NULL)

// PUBLIC SYMBOLS E
#ifdef FORMPROC_C
#define LENOFSTORENAME 10
#define LENOFFIELDNAME_10 10        // note gpasizes sets this to 9
#define LENOFLOADFLDTMP 20 // should be bigger I think :JDG 26/10
#define LENOFFORMVAR 81
#define LEN2OFSTORENAME 20
#define LEN2OFFIELDNAME 20

//------------------------PRIVATE Prototypes & Variables-------------------

void            loadffld    (INT id);
void            updatest    (void);
CHAR            *getitem    (PFORMF f);
void            loaditem    (PFORMF f);

#endif  //  def FORMPROC_C

#endif  //  ndef FORMPROC_H
// **************************************************************************
// formproc.h <end-of-file>

