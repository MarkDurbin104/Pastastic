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

CHAR        **G_cline=NULL;

void        upcalc      (INT x,INT y);
void        downcalc    (void);
void        addline     (INT x,INT y,INT k,CHAR *inputln);
CHAR        *dottrunc   (CHAR *s);
void        calctot     (INT lastop,CHAR *inputln);

#endif  //  def CALC_C

#endif  //  ndef CALC_H
