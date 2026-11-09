#ifndef FLDPROC_H    // stop multiple includes

#define FLDPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FLDPROC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC  INT     prdate      (void);
PUBLIC  INT     chkfmt      (CHAR t,INT k);
PUBLIC  void    putcur      (INT x,INT y,INT curpos,INT l,CHAR *fmt,INT insert,INT size,CHAR *s);
PUBLIC  void    output      (INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size);
PUBLIC  INT     inputstr    (INT x,INT y,CHAR *s,CHAR *fmt,INT kp);
PUBLIC  CHAR   *tstr        (CHAR *s,INT l);
PUBLIC  CHAR   *dstr        (CHAR *s,INT l);
PUBLIC  CHAR   *keyname     (INT k);
PUBLIC  CHAR   *applyformat (CHAR *s,CHAR *fmt,INT rl);

// PUBLIC SYMBOLS E
#ifdef FLDPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------
#define TABSTOP 4

#endif  //  def FLDPROC_C

#endif  //  ndef FLDPROC_H
