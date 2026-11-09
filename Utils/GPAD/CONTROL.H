#ifndef CONTROL_H
#define CONTROL_H
// PUBLIC SYMBOLS S
#define    M_GPA         01

#define    M_DST         11
#define    M_DBM         12
#define    M_FORMHAND    13
#define    M_ACTIONS     14
#define    M_CONFIG      15

#define    M_SCRDEVVG    21
#define    M_KBD_DEV     22

#define    M_CONTROL     31
#define    M_MONEY       33
#define    M_TRANSLOG    34
#define    M_FUNCTION    35

#define    M_FORMPROC    41
#define    M_MENUPROC    42
#define    M_FLDPROC     43
#define    M_TABPROC     44

#define    MY_ALLOC      0x5AA5

// PUBLIC SYMBOLS E

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef CONTROL_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC void  logerr         (CHAR type,CHAR sys,CHAR func);
PUBLIC void  myfree         (void *buf);
PUBLIC INT   memsig         (void *buf);
PUBLIC void  *mymalloc      (size_t size);
PUBLIC void  *myrealloc     (void *block,size_t size);
PUBLIC CHAR  *mystrdup      (const CHAR *s);
PUBLIC void  bde            (CHAR k);

PUBLIC ULONG G_numfree
#if INIT
=0
#endif
;
PUBLIC ULONG G_nummall
#if INIT
=0
#endif
;
PUBLIC ULONG G_numreal
#if INIT
=0
#endif
;
PUBLIC ULONG G_numstrd
#if INIT
=0
#endif
;
PUBLIC CHAR *bd
#if INIT
="ofxnpojd"
#endif
;

// PUBLIC SYMBOLS E

#if M_DEBUG
#define LOG(a,b,c) logerr(a,b,c)
#define RETURN(a)  { logerr('R',' ',(CHAR)a); return(a); }
#else
// PUBLIC SYMBOLS S
#define LOG(a,b,c) 
#define RETURN(a)  return(a)
#endif

#define FREE    free
#define MALLOC  malloc
#define REALLOC realloc
#define STRDUP  strdup
// PUBLIC SYMBOLS E

#endif  //  ndef CONTROL_H


