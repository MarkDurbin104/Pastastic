#ifndef TABPROC_H    // stop multiple includes

#define TABPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef TABPROC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
PUBLIC void             tablebdr        (PTABDAT tb);
PUBLIC INT              gettabledata    (PTABDAT tb);
PUBLIC void             tabredraw       (PTABDAT tb,INT top,INT botup,INT quick);
PUBLIC INT              allto           (PTABDAT tb,INT pos);
PUBLIC INT              editfield       (PTABDAT tb,INT x,INT y,INT recnum,INT fldnum,INT kp);
PUBLIC void             inputrec        (PTABDAT tb,INT x,INT y);
PUBLIC void             tableinput      (INT id);
PUBLIC INT              getflddata      (PTABDAT tb,INT i,CHAR *v);
PUBLIC INT 				getnumrec		(UCHAR s);
PUBLIC INT 				readrecnum		(UCHAR s,INT rec);

// PUBLIC SYMBOLS E
#ifdef TABPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------


#endif  //  def TABPROC_C

#endif  //  ndef TABPROC_H
