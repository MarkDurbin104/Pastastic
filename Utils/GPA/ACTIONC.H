#ifndef ACTIONC_H    // stop multiple includes

#define ACTIONC_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef ACTIONC_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define gettoken(b) (  (UCHAR   )*(b))
#define gettiny(b)  (  (UCHAR   )*(b))
#define getint(b)   (*((UINT16 *) (b)))
#define getlong(b)  (*((ULONG  *) (b)))
#define getdoub(b)  (*((double *) (b)))
#define getstrg(b)  (  (UCHAR  *) (b))

PUBLIC INT                  loadactions     (CHAR *sys);
PUBLIC void                 freeactions     (void);
PUBLIC LONG                 actionofs       (INT idx);
PUBLIC UCHAR                actiontype      (INT idx);
PUBLIC UCHAR                actiondeb       (INT idx);
PUBLIC CHAR *               actionname      (INT idx);
PUBLIC UCHAR *              actionbuf       (INT idx);
PUBLIC void                 setactionbuf    (INT idx,UCHAR *s);
PUBLIC INT                  findname        (CHAR *name);

PUBLIC NAMEINDEX            *G_nbuf         INIT(NULL);
PUBLIC INT                  G_numn          INIT(0);
PUBLIC NAMEBUFFER           *G_anamebuf     INIT(NULL);
PUBLIC CHAR 		        G_afilename[80];
PUBLIC LONG                 G_buffofs       INIT(0L);
// PUBLIC SYMBOLS E

#ifdef ACTIONC_C

//------------------------PRIVATE Prototypes & Variables-------------------

UCHAR *G_asbuff=NULL;

#endif  //  def ACTIONC_C

#endif  //  ndef ACTIONC_H

