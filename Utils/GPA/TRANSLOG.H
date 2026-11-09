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

PUBLIC void       displog       (INT loglev);
#ifdef WIEN
PUBLIC void       endlog        (INT loglev);
#endif
PUBLIC CHAR       *logtotal     (INT loglev);
PUBLIC void       voidlog       (INT idx);
PUBLIC void       removelogt    (INT idx);
PUBLIC void       modlogval     (INT idx);
PUBLIC INT        add2log       (CHAR *n,CHAR *v,CHAR *a1,CHAR *a2,CHAR *a3);
PUBLIC void       freelog       (void);
PUBLIC INT        writetrans    (void);
PUBLIC INT        getlog        (void);

PUBLIC INT        G_tindex
#if INIT
=1
#endif
;
PUBLIC TRANSLOG    *G_log; //[NUMLOGENT];
PUBLIC INT         G_numt
#if INIT
=0
#endif
;
// PUBLIC SYMBOLS E

#ifdef TRANSLOG_C

//------------------------PRIVATE Prototypes & Variables-------------------

INT updatestock(INT prod,INT qty,CHAR *val);

INT         G_markt=(-1);

#endif  //  def TRANSLOG_C

#endif  //  ndef TRANSLOG_H
