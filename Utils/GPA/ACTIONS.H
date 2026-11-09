#ifndef ACTIONS_H    // stop multiple includes

#define ACTIONS_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef ACTIONS_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define MAXRECURSE   25

PUBLIC INT                  runaction       (CHAR *name);
PUBLIC INT                  isaction        (CHAR *name);
PUBLIC INT                  subaction       (CHAR *name,INT depth);
PUBLIC UCHAR *              isdefstr        (CHAR *s);
PUBLIC void                 setstatic       (INT n,CHAR *s);
PUBLIC CHAR *               setvarib        (INT n,CHAR *s);
PUBLIC CHAR *               getvarib        (INT n);

PUBLIC FSAVE                G_savedf        [MAXRECURSE];
PUBLIC INT                  G_numsf         INIT(0);
PUBLIC UCHAR 		        *G_buff         INIT(NULL);
// PUBLIC SYMBOLS E

typedef double VARTYPE;
#ifdef ACTIONS_C

//------------------------PRIVATE Prototypes & Variables-------------------

void    	dumpstate       (INT from);
INT     	savestate       (void);
INT     	reststate       (void);
INT     	loadnewform     (CHAR *name,INT index,CHAR *n1,CHAR *n2,INT w);
void 		ptok(UCHAR* o);
void 		mprintf(CHAR *fmt, ... );
void  		pstack(void);
INT      	inttok(UCHAR *o);

INT G_ca=0;
INT G_attr=10;
INT G_run=0;


#define MAXDSTACK 20

VARTYPE  G_vars[50];
LONG  G_tvars[64]={
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L,
    0L,0L,0L,0L,0L,0L,0L,0L
};

ULONG G_cstack[MAXDSTACK];
INT   G_csp=0;
INT   G_curly=0;


#endif  //  def ACTIONS_C

#endif  //  ndef ACTIONS_H
