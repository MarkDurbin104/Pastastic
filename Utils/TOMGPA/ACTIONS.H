/****************************************************************************
* Project     : GPA
* File        : actions.h
* Description : a few global and private variables and some 
*               public and private function definitions 
*               all relating to actions.c.
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:38  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/actions.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:38   JGRAY
 *  
* 
****************************************************************************/
#ifndef ACTIONS_H    // stop multiple includes

#define ACTIONS_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef ACTIONS_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC INT        runaction       (CHAR *name);
PUBLIC INT        isaction        (CHAR *name);
PUBLIC INT        subaction       (CHAR *name,INT depth);
PUBLIC UCHAR *    isdefstr        (CHAR *s);
PUBLIC void       setstatic       (INT n,CHAR *s);
PUBLIC CHAR *     setvarib        (INT n,CHAR *s);
PUBLIC CHAR *     getvarib        (INT n);
PUBLIC INT        isfcdcode       (ULONG code);

PUBLIC FSAVE      G_savedf        [MAXRECURSE];
PUBLIC INT        G_numsf         INIT(0);
PUBLIC UCHAR      *G_buff         INIT(NULL);

// PUBLIC SYMBOLS E

#ifdef ACTIONS_C

//------------------------PRIVATE Prototypes & Variables-------------------

void        dumpstate      (INT from);
INT         savestate      (void);
INT         reststate      (void);
INT         loadnewform    (CHAR *name,INT index,CHAR *n1,CHAR *n2,INT w);
void        ptok           (UCHAR* o);
void        mprintf        (CHAR *fmt, ... );
void        pstack         (void);
INT         inttok         (UCHAR *o);

INT G_ca=0;
INT G_attr=10;
INT G_run=0;

#define MAXDSTACK 20
#define MAXGTVARS 64

LONG  G_vars[MAXGVARS];
LONG  G_tvars[MAXGTVARS]={
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L
};

ULONG G_cstack[MAXDSTACK];
INT   G_csp=0;
INT   G_curly=0;


#endif  //  def ACTIONS_C

#endif  //  ndef ACTIONS_H
// **************************************************************************
// actions.h <end-of-file>
