/****************************************************************************
* Project     : GPA
* File        : money.h
* Description : header for money routines - add sub etc.
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:04  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/money.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:04   JGRAY
 *  
* 
****************************************************************************/
#ifndef MONEY_H    // stop multiple includes

#define MONEY_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef MONEY_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC CHAR             *addm       (CHAR *a,CHAR *b);
PUBLIC CHAR             *subm       (CHAR *a,CHAR *b);
PUBLIC CHAR             *divm       (CHAR *a,CHAR *b);
PUBLIC CHAR             *mulm       (CHAR *a,INT b);
PUBLIC CHAR             *rndm       (CHAR *a,INT b);
PUBLIC CHAR             *formatstr  (CHAR *s,CHAR *fmt,INT len);
PUBLIC CHAR             *mstr       (CHAR *val,INT len);

// PUBLIC SYMBOLS E

#ifdef MONEY_C

#define LENOFMONEY 30
#define LENOFVLTMP 80
#define LENOFFSTMP 80
#define MAXOFFSTMP 40
#define MAXOFVLTMP 40
//------------------------PRIVATE Prototypes & Variables-------------------

#endif  //  def MONEY_C

#endif  //  ndef MONEY_H
// **************************************************************************
// money.h <end-of-file>

