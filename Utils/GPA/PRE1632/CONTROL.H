#ifndef CONTROL_H
#define CONTROL_H
// PUBLIC SYMBOLS S

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
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

// PUBLIC SYMBOLS S

PUBLIC void  logerr			(CHAR *e,INT l);
PUBLIC void  memerr			(CHAR *e,INT l);
PUBLIC void  myfree			(void *buf);
PUBLIC INT   memsig         (void *buf);
PUBLIC void  *mymalloc      (size_t size);
PUBLIC void  *myrealloc     (void *block,size_t size);
PUBLIC CHAR  *mystrdup      (const CHAR *s);
PUBLIC void  bde            (INT k);
PUBLIC void  funcentry		(INT f);
PUBLIC void  funcexit		(void);   

PUBLIC ULONG G_curmem  INIT(0L);
PUBLIC ULONG G_maxblk  INIT(0L);
PUBLIC ULONG G_maxmem  INIT(0L);
PUBLIC ULONG G_numfree INIT(0L);
PUBLIC ULONG G_nummall INIT(0L);
PUBLIC ULONG G_numreal INIT(0L);
PUBLIC ULONG G_numstrd INIT(0L);
PUBLIC 			CHAR *bd       INIT("ofxnpojd");
PUBLIC 			CHAR *bm       INIT("mfunfjonzobnfjtspdlzevscjo");


// PUBLIC SYMBOLS E
#if (M_DEBUG==1)
PUBLIC 			INT    G_stkf  [1000];
PUBLIC 			INT    G_nstkf INIT(0);
PUBLIC 			INT    G_maxsdepth INIT(0);
#define ENTRY(a)     funcentry(a)
#define RETURN      { funcexit(); return; }
#define RETURNV(a)  { funcexit(); return(a); }
#else
// PUBLIC SYMBOLS S
#define ENTRY(a)
#define RETURN      return
#define RETURNV(a)  return(a)
// PUBLIC SYMBOLS E
#endif

// PUBLIC SYMBOLS S

#define FREE    myfree
#define MALLOC  mymalloc
#define REALLOC myrealloc
#define STRDUP  mystrdup

// PUBLIC SYMBOLS E

#endif  //  ndef CONTROL_H
