#ifndef TRANSLOG_H    // stop multiple includes

#define TRANSLOG_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef TRANSLOG_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define NUMLOGENT   50

PUBLIC void       displog       (int loglev);
PUBLIC char       *logtotal     (int loglev);
PUBLIC void       voidlog       (int idx);
PUBLIC void       removelogt    (int idx);
PUBLIC void       modlogval     (int idx);
PUBLIC int        add2log       (char *n,char *v,char *a1,char *a2,char *a3);
PUBLIC void       freelog       (void);
PUBLIC int        writetrans    (void);
PUBLIC int        getlog        (void);

PUBLIC int        G_tindex
#if INIT
=1
#endif
;
PUBLIC TRANSLOG    *G_log; //[NUMLOGENT];
PUBLIC int         G_numt
#if INIT
=0
#endif
;
// PUBLIC SYMBOLS E

#ifdef TRANSLOG_C

//------------------------PRIVATE Prototypes & Variables-------------------

int updatestock(int prod,int qty,char *val);

int         G_markt=(-1);

#endif  //  def TRANSLOG_C

#endif  //  ndef TRANSLOG_H
