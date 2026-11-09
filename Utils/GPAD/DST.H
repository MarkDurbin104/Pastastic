#ifndef DST_H    // stop multiple includes

#define DST_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef DST_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

// PUBLIC SYMBOLS S
//-------------------------PUBLIC Prototypes & Variables-------------------
#define NUMSTORES  20
#define NUMFIELDS  20
#define NUMLIBITEM NUMSTORES*NUMFIELDS

PUBLIC INT              loadsdata   (CHAR *sys);
PUBLIC INT              savesdata   (CHAR *sys);
PUBLIC INT              snum        (CHAR *name);
PUBLIC INT              fnum        (CHAR *name,CHAR *fname);
PUBLIC INT              knum        (CHAR *name,CHAR *fname);

PUBLIC STORE            *G_store;
PUBLIC LSTOREF          *G_lib;
PUBLIC INT              G_nums INIT(0);
PUBLIC INT              G_numl INIT(0);

// PUBLIC SYMBOLS E
#ifdef DST_C

//------------------------PRIVATE Prototypes & Variables-------------------

INT                     readstores  (INT fd,PSTORE s,INT *scnt);
INT                     writestores (INT fd,PSTORE s,INT scnt);
INT                     readlib     (INT fd,PLSTOREF l,INT *icnt);
INT                     writelib    (INT fd,PLSTOREF l,INT icnt);
void                    doupdates   (void);

#endif  //  def DST_C

#endif  //  ndef DST_H

