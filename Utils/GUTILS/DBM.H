#ifndef DBM_H    // stop multiple includes
#define DBM_H

#ifndef DST_H
#include "dst.h"
#endif
#ifndef PXENGINE_H
#include <pxengine.h>
#endif

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef DBM_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

#define CLSE        (-6)
#define FRST        (-5)
#define LAST        (-4)
#define PREV        (-3)
#define NEXT        (-2)
#define CURR        (-1)

PUBLIC int              stinit      (char *sys);
PUBLIC int              stexit      (void);
PUBLIC int              streinit    (void);
PUBLIC int              stexist     (char *name);
PUBLIC int              stcreate    (char *name);
PUBLIC int              stdelete    (char *name);
PUBLIC int              stopen      (char *name);
PUBLIC int              stclose     (char *name);
PUBLIC int              stcloseall  (void);
PUBLIC long             stnumrec    (char *name);
PUBLIC long             strecnum    (char *name);
PUBLIC int              stread      (char *name,int rtype);
PUBLIC int              stwrite     (char *name);
PUBLIC int              stdelrec    (char *name,int recnum);
PUBLIC int              stsrch      (char *name,char *fname,int mode);
PUBLIC int              stsrchp     (char *name,int nflds,int mode);
PUBLIC int              stget       (char *name,char *fname,char *var);
PUBLIC int              stblank     (char *name);
PUBLIC int              stempty     (char *name);
PUBLIC int              stput       (char *name,char *fname,char *var);
PUBLIC int              stdup       (char *name,char *fname,int mode);
PUBLIC int              stremdup    (char *name,int copyback);
PUBLIC int              stdelgrp    (char *name,char *fname,int mode);
PUBLIC int              stflush     (void);
PUBLIC int              stgetrec    (char *name,char *r,int *flen);
PUBLIC int              stputrec    (char *r);
PUBLIC int              sendrec     (char *name,int type);
PUBLIC int              receiverec  (void);
PUBLIC int              stcopyrec   (char *s,char *d);

PUBLIC STORESTAT        G_sstat[NUMSTORES];
PUBLIC int              G_nocache INIT(0);

// PUBLIC SYMBOLS E

#ifdef DBM_C

//------------------------PRIVATE Prototypes & Variables-------------------

void                    dottrunc    (char *s);

FIELDHANDLE             G_fhs[20] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
#endif  //  def DBM_C

#endif  //  ndef DBM_H
