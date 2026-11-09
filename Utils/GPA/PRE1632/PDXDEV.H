#ifndef PDXDEV_H
#define PDXDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef PDXDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

#ifdef PDXDEV_C
INT pdx_control(INT type,va_list ap);
#endif

// PUBLIC SYMBOLS S
PUBLIC DEVHEADER dev_pdx
#if INIT
= {
    DEVSIG,
    "PARADOX Engine Device Copyright (c) Unisys Version 1.00",
    "DBM",
    "PARADOX",
    "IE",
    NULL,
    NULL,
    (DFPTR)pdx_control,
    NULL,
    DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E

#ifdef PDXDEV_C

INT              stinit      (void);
INT              stexit      (void);
INT              streinit    (void);
INT              stexist     (CHAR *name);
INT              stcreate    (CHAR *name);
INT              stdelete    (CHAR *name);
INT              stopen      (CHAR *name);
INT              stclose     (CHAR *name);
INT              stcloseall  (void);
LONG             stnumrec    (CHAR *name);
LONG             strecnum    (CHAR *name);
INT              stread      (CHAR *name,INT rtype);
INT              stwrite     (CHAR *name);
INT              stdelrec    (CHAR *name,INT recnum);
INT              stsrch      (CHAR *name,CHAR *fname,INT mode);
INT              stsrchp     (CHAR *name,INT nflds,INT mode);
INT              stget       (CHAR *name,CHAR *fname,CHAR *var);
INT              stblank     (CHAR *name);
INT              stempty     (CHAR *name);
INT              stput       (CHAR *name,CHAR *fname,CHAR *var);
INT              stdup       (CHAR *name,CHAR *fname,INT mode);
INT              stremdup    (CHAR *name,INT copyback);
INT              stdelgrp    (CHAR *name,CHAR *fname,INT mode);
INT              stflush     (void);
INT              stgetrec    (CHAR *name,CHAR *r,INT *flen);
INT              stputrec    (CHAR *r);
INT              sendrec     (CHAR *name,INT type);
INT              receiverec  (void);
INT              stcopyrec   (CHAR *s,CHAR *d);
void             dottrunc    (CHAR *s);

FIELDHANDLE      G_fhs[20] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};

#endif  //  def PDXDEV_C

#endif  //  ndef PDXDEV_H
