#ifndef FORMPROC_H    // stop multiple includes

#define FORMPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FORMPROC_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC char            *textstr    (PFORMF fld);
PUBLIC int             findid      (int id);
PUBLIC int             initform    (PFORM f);
PUBLIC int             runform     (int clear);
PUBLIC void            clrform     (PFORM f);
PUBLIC void            redrawform  (void);
PUBLIC void            updatest    (void);
PUBLIC void            swaplang    (void);
PUBLIC void            fillform    (PFORM f);
PUBLIC void            srchitem    (PFORMF f);

PUBLIC char            **G_formvars INIT(NULL)

// PUBLIC SYMBOLS E
#ifdef FORMPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------

void            loadffld    (int id);
void            updatest    (void);
char            *getitem    (PFORMF f);
void            loaditem    (PFORMF f);

#endif  //  def FORMPROC_C

#endif  //  ndef FORMPROC_H
