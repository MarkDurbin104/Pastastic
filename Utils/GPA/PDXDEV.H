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
LONG pdx_control(INT type,va_list ap);
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
    pdx_control,
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
INT              stread      (CHAR *name,LONG rtype);
INT              stwrite     (CHAR *name, INT updateonly);
INT              stdelrec    (CHAR *name,LONG recnum);
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

LONG             msinit      (void);
LONG             msexit      (void);
LONG             msreinit    (void);
LONG             msexist     (CHAR *name);
LONG             mscreate    (CHAR *name);
LONG             msdelete    (CHAR *name);
LONG             msopen      (CHAR *name);
LONG             msclose     (CHAR *name);
LONG             mscloseall  (void);
LONG             msnumrec    (CHAR *name);
LONG             msrecnum    (CHAR *name);
LONG             msread      (CHAR *name,LONG rtype);
LONG             mswrite     (CHAR *name);
LONG             msdelrec    (CHAR *name,LONG recnum);
LONG             msquickget  (INT s,INT f,CHAR *var);
LONG             msquickput  (INT s,INT f,CHAR *var);
LONG             mssrch      (CHAR *name,CHAR *fname,INT mode);
LONG             mssrchp     (CHAR *name,INT nflds,INT mode);
LONG             msblank     (CHAR *name);
LONG             msempty     (CHAR *name);
LONG             msbsslist   (CHAR *name,CHAR *fname,LONG *ll);
LONG             msbsplist   (CHAR *name,INT nflds,LONG *ll);

FIELDHANDLE      G_fhs[20] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};

#endif  //  def PDXDEV_C

#endif  //  ndef PDXDEV_H
