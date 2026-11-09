/****************************************************************************
* Project     : GPA
* File        : calc.h
* Description : support file for hotkey calculator routines
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:40  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/calc.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:40   JGRAY
 *  
* 
****************************************************************************/
#ifndef CALC_H    // stop multiple includes

#define CALC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef CALC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC CHAR         *proccalc   (INT x,INT y);
PUBLIC void          fincalc    (void);

// PUBLIC SYMBOLS E
#ifdef CALC_C

//------------------------PRIVATE Prototypes & Variables-------------------

#define LOGLEN 14
#define LOGWID 13
#define XOFS   3
#define YOFS   0
#define TOFS   1+LOGLEN     // Total text offset (Y co-ord)
#define ADDLISTINC 10       // number added at each malloc
#define ADDWID (LOGWID*2)+1 // width of each calc line

CHAR G_ctotal[ADDWID+1];    // buffer for total
INT  G_numcl=0;             // number of calc lines
INT  G_numallcl=0;          // number of allocated calc lines
CHAR **G_cline=NULL;        // current line pointer

void        upcalc      (INT x,INT y);
void        downcalc    (void);
void        addline     (INT x,INT y,INT k,INT *prevoperator,CHAR *inputln);
CHAR        *dottrunc   (CHAR *s);
void        calctot     (INT lastop,CHAR *inputln);

#endif  //  def CALC_C

#endif  //  ndef CALC_H

// **************************************************************************
// calc.h <end-of-file>

