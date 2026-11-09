/****************************************************************************
* Project     : GPA
* File        : formhand.h
* Description : Support routines for form handling module formhand.c
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:50  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/formhand.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:50   JGRAY
 *  
* 
****************************************************************************/
#ifndef FORMHAND_H    // stop multiple includes

#define FORMHAND_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FORMHAND_C
#define PUBLIC 
#define INIT(a) = a;
#define INIT4(a,b,c,d) = {a,b,c,d};
#else
#define PUBLIC extern
#define INIT(a) ;
#define INIT4(a,b,c,d) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define NUM_FCLASS  10
#define FF_MAND   0x0000
#define FF_OPTI   0x0001
#define FF_SRCH   0x0002
#define FF_TEXT   0x0003
#define FF_MSRH   0x0004
#define FF_MSEC   0x0005
#define FF_WAIT   0x0006
#define FF_DISP   0x0007
#define FF_SECS   0x0008
#define FF_TABL   0x0009

#define FF_TBLF   0x8000

#define IT_MENU   0x01
#define IT_FORM   0x02
#define IT_FUNC   0x03

#define MI_ENAB   0x00
#define MI_DISA   0x01

#define F_NORM    0
#define F_SERVE   1
#define F_PROMPT  2
#define F_MENU    3
#define F_REPORT  4
#define F_PPFORM  5

#define FA_UPDS   0x01

PUBLIC void     freeformidx     (void);
PUBLIC INT      ficmp           (PFORM a,PFORM b);
PUBLIC INT      getformidx      (CHAR *name);
PUBLIC INT      isform          (CHAR *name);
PUBLIC INT      getfedata       (INT ofs,PFORM sf);
PUBLIC INT      loadformidx     (PFORM sf,INT ofs);
PUBLIC INT      loadform        (PFORM sf);
PUBLIC void     freeform        (PFORM f);
PUBLIC void     orderform       (PFORM f,INT type);

PUBLIC INT      loadtext        (CHAR *sys);
PUBLIC CHAR *   atextstr        (INT i);
PUBLIC void     freetext        (void);

PUBLIC INT                  G_numidx INIT(0);
PUBLIC PFORM               *G_fid INIT(NULL);
PUBLIC CHAR                 **G_tname;
PUBLIC INT                  G_tcnt INIT(0);
PUBLIC INT                  G_nut  INIT(0);
PUBLIC INT                  G_saved INIT(0);
PUBLIC CHAR                 G_parea[4] INIT4(0,17,79,20);
PUBLIC CHAR                 G_tarea[4] INIT4(43,21,79,24);
PUBLIC CHAR                 G_larea[4] INIT4(47,2,79,16);
PUBLIC INT                  G_fversion INIT(0);

// PUBLIC SYMBOLS E
#ifdef FORMHAND_C
#define LENOFLASTTEXT 100
#define LENOFTEXTINPBUF 100      // THIS ONE SHOULD BE 160 :JGQ 26/10
#define TEXTNAMEITEMQ 0x3000

//------------------------PRIVATE Prototypes & Variables-------------------
INT  G_formsize=0;
INT  G_fieldsize=0;
CHAR  G_lasttext[LENOFLASTTEXT];
INT  usort          (PFORMF a,PFORMF b);
INT  fsort          (PFORMF a,PFORMF b);

#endif  //  def FORMHAND_C

#endif  //  ndef FORMHAND_H
// **************************************************************************
// formhand.h <end-of-file>

