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
#define MAXRECURSE   20

PUBLIC int                  loadactions     (char *sys);
PUBLIC void                 freeactions     (void);
PUBLIC void                 runaction       (char *name);
PUBLIC int                  isaction        (char *name);
PUBLIC int                  subaction       (char *name,int depth);

PUBLIC FSAVE                G_savedf        [MAXRECURSE];
PUBLIC int                  G_numsf         INIT(0);
PUBLIC NAMEINDEX            G_nbuf          [100];
PUBLIC int                  G_numn          INIT(0);

// PUBLIC SYMBOLS E

#ifdef ACTIONS_C

//------------------------PRIVATE Prototypes & Variables-------------------

void    dumpstate       (int from);
int     savestate       (char *name);
int     reststate       (char *name);
int     loadnewform     (char *name,long index,char *n1,char *n2);

int G_ca=0;
int G_attr=10;
int G_run=0;


#define MAXDSTACK 256

long  G_vars[30]={0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L};
long  G_fvars[30]={0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L};

char *G_cstack[MAXDSTACK];
int   G_csp=0;
int   G_curly=0;

unsigned char *G_buff;

#endif  //  def ACTIONS_C

#endif  //  ndef ACTIONS_H
