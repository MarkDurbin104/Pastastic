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

PUBLIC int              loadsdata   (char *sys);
PUBLIC int              savesdata   (char *sys);
PUBLIC int              snum        (char *name);
PUBLIC int              fnum        (char *name,char *fname);
PUBLIC int              knum        (char *name,char *fname);

PUBLIC STORE            *G_store;
PUBLIC LSTOREF          *G_lib;
PUBLIC int              G_nums INIT(0);
PUBLIC int              G_numl INIT(0);

// PUBLIC SYMBOLS E
#ifdef DST_C

//------------------------PRIVATE Prototypes & Variables-------------------

int                     readstores  (int fd,PSTORE s,int *scnt);
int                     writestores (int fd,PSTORE s,int scnt);
int                     readlib     (int fd,PLSTOREF l,int *icnt);
int                     writelib    (int fd,PLSTOREF l,int icnt);
void                    doupdates   (void);

#endif  //  def DST_C

#endif  //  ndef DST_H
