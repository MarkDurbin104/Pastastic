//===========================================================================
// Module        : DEBALLOC.H
// Synopsys      : debug rountines for memory allocation
// Description   : replacement rountines for memory allocation
//               : include and define a level of debug to check
//               : missing frees bad frees allocs re-allocs and strdups
//               : and bounds on blocks
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th June 1993
//===========================================================================
// Functions     : debfree debmalloc debrealloc debstrdup
//               : endcheck boundscheck
//               : 
//===========================================================================
// Global Vars.  : G_freeerr, G_mallerr, G_realerr, G_strderr, G_bndserr
//               : G_debvalue, G_debexit, G_checkfreq 
//               : 
// static        : alloclist
//===========================================================================
// Date      Id   Modification history
//---------------------------------------------------------------------------
// 06/06/93  MJD  Initial entry
// 08/09/93  MJD  added bounds checking
// 10/09/93  MJD  added exit pragma to list errors
// 15/10/93  MJD  G_freqcheck to check for bounds errors during running
//===========================================================================
#ifndef DEBALLOC_H
#define DEBALLOC_H

#define    DEB_ALLOC      0x5AA5  // signature applied to start of each block
#define    DEB_ENDSIG     0x55    // signature applied to end of each block
#define    REPORTNUM      20      // number of un-freed blocks reported DEBUG==3

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef DEBALLOC_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

// #define DEBUG 1      // define to activate increased memory debugging
// #define DEBUG 2      // as above with short print and exit() on error
// #define DEBUG 3      // as above with full print and exit() on error 


#ifndef DEBUG
int G_checkfreq=0;    // check bounds frequency 0=DON'T

#define FREE    free
#define MALLOC  malloc
#define REALLOC realloc
#define STRDUP  strdup
#define PTRCHECK(a) (a!=NULL) 

#else
PUBLIC int G_checkfreq INIT(100);    // check bounds frequency 0=DON'T

typedef struct {
    short   signature;
    void    *next;
    void    *prev;
    void    *addr;
    int     line;
    char    file[15];
    size_t  size;
} ALLOCHDR;

static ALLOCHDR *alloclist=NULL;

PUBLIC void  endcheck       (void);

PUBLIC void  debfree		 (int line, char *file, void *buf);
PUBLIC void  *debmalloc      (int line, char *file, size_t size);
PUBLIC void  *debrealloc     (int line, char *file, void *block,size_t size);
PUBLIC char  *debstrdup      (int line, char *file, const char *s);
PUBLIC int   debptrcheck	 (int line, char *file, void *buf);

#define FREE(a)             debfree(__LINE__,__FILE__,a)
#define MALLOC(a)           debmalloc(__LINE__,__FILE__,a)
#define REALLOC(a,b)        debrealloc(__LINE__,__FILE__,a,b)
#define STRDUP(a)           debstrdup(__LINE__,__FILE__,a)
#define PTRCHECK(a)         debptrcheck(__LINE__,__FILE__,a)

PUBLIC unsigned long G_freeerr   INIT(0L); // errors in frees
PUBLIC unsigned long G_mallerr   INIT(0L); // errors in malloc allocations 
PUBLIC unsigned long G_realerr   INIT(0L); // errors in realloc allocations
PUBLIC unsigned long G_strderr   INIT(0L); // errors in string allocations
PUBLIC unsigned long G_bndserr   INIT(0L); // bounds errors

PUBLIC int   G_debvalue     INIT(DEBUG); // the value of debug
PUBLIC int   G_debexit      INIT(0);     // debug exiting!

#pragma exit endcheck 64    // report errors on exit

#endif

#endif  //  ndef DEBALLOC_H
