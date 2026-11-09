#ifndef REPPROC_H    // stop multiple includes

#define REPPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef REPPROC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC INT   runreport   (void);

// PUBLIC SYMBOLS E
#ifdef REPPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------

void  poutput     (INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size,INT attr);
void  printtab    (PTABDAT tb,INT top);
void  tablepbdr   (PTABDAT tb);
void  tableoutput (INT id);


#endif  //  def REPPROC_C

#endif  //  ndef REPPROC_H

