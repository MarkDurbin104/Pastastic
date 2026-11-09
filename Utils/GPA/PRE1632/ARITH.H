#ifndef ARITH_H
#define ARITH_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef ARITH_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
// #define LONGS        // comment out this line for floating point numbers

#define MAXSTRLEN  80

// PUBLIC SYMBOLS E
#ifdef LONGS
#define NUMB      LONG
#define ATON      atol
#define NTOA(a,b) sprintf(a,"%ld",b)
#else
// PUBLIC SYMBOLS S
#define NUMB      double
#define ATON      atof
#define NTOA(a,b) sprintf(a,"%0.0f",b)
#endif

#define PUSHN(a) push('n',(NUMB)a)
#define PUSHS(a) push('s',a)
#define POP(a)   pop((void *)a)

PUBLIC NUMB  G_n[3];
PUBLIC CHAR  G_s[3][MAXSTRLEN];

#define MAXSTACK   50

PUBLIC STACK  *G_stack        [MAXSTACK];
PUBLIC INT     G_nstk         INIT(0)
PUBLIC void    push           (CHAR type,...);
PUBLIC CHAR    pop            (void *var);
PUBLIC CHAR    stktype        (INT place);
PUBLIC CHAR    stknum         (INT place,NUMB *n);
PUBLIC CHAR    stkstr         (INT place,CHAR *s);
PUBLIC INT     stksize        (void);
PUBLIC LONG    popl           (void);
PUBLIC CHAR   *pops           (void);
PUBLIC void    add            (void);
PUBLIC void    sub            (void);
PUBLIC void    mul            (void);
PUBLIC void    land           (void);
PUBLIC void    lor            (void);
PUBLIC void    lxor           (void);
PUBLIC void    lnot           (void);
PUBLIC void    equal          (void);
PUBLIC void    notequal       (void);
PUBLIC void    less           (void);
PUBLIC void    lessequal      (void);
PUBLIC void    great          (void);
PUBLIC void    greatequal     (void);
PUBLIC void    not            (void);
PUBLIC void    neg            (void);
PUBLIC void    sequal         (void);
PUBLIC void    snotequal      (void);
PUBLIC void    sless          (void);
PUBLIC void    slessequal     (void);
PUBLIC void    sgreat         (void);
PUBLIC void    sgreatequal    (void);
PUBLIC void    divide         (void);
PUBLIC void    mod            (void);
PUBLIC void    sjoin          (void);
PUBLIC void    scut           (void);
PUBLIC void    get2strs       (void);
PUBLIC void    get2nums       (void);
PUBLIC void    getnum         (void);
PUBLIC void    getstr         (void);
PUBLIC void    arithend       (void);

// PUBLIC SYMBOLS E
#ifdef ARITH_C

//------------------------PRIVATE Prototypes & Variables-------------------


#endif  //  def ARITH_C

#endif  //  ndef ARITH_H
