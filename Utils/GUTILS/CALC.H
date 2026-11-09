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

PUBLIC char         *proccalc   (void);

// PUBLIC SYMBOLS E
#ifdef CALC_C

//------------------------PRIVATE Prototypes & Variables-------------------

char        G_cline[25][40];

void        upcalc      (void);
void        downcalc    (void);
void        addline     (int k,char *inputln);
char        *dottrunc   (char *s);
void        calctot     (int lastop,char *inputln);

#endif  //  def CALC_C

#endif  //  ndef CALC_H
