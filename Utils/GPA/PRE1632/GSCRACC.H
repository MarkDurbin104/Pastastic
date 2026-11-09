#ifndef GSCRACC_H    // stop multiple includes

#define GSCRACC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef GSCRACC_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

#define TABSTOP 4

typedef struct {
    unsigned int    attr;
    unsigned char   size;
} VARPARMS;

//-------------------------PUBLIC Prototypes & Variables-------------------
PUBLIC VARPARMS        G;
PUBLIC int             G_xor INIT(0);
PUBLIC int             G_coordson INIT(0);
PUBLIC unsigned char   *G_font;

PUBLIC int          grafix      (void);
PUBLIC void         cls         (void);
PUBLIC void         getfont     (void);
PUBLIC void         outch       (int x,int y,unsigned char c,int col);
PUBLIC void         prat        (int x,int y,char *fmt, ... );
PUBLIC void         pratc       (int x,int y,int col,char *fmt, ... );
PUBLIC void         flipattr    (int x,int y,int num);
PUBLIC char         *inputln    (void);
PUBLIC int          inputstr    (int x,int y,char *s,int l,char t);
PUBLIC void         cursor      (int x,int y,int num,int type);
PUBLIC int          getkey      (void);
PUBLIC int          peekkey     (void);
PUBLIC int          keyhit      (void);

#ifdef GSCRACC_C

//------------------------PRIVATE Prototypes & Variables-------------------


int             G_kpeek=0;
unsigned char   G_scrc[3][80][30];
int             G_maxx,G_maxy,G_linespace;
unsigned int    dublit(unsigned char c);
int             chkfmt(char t,char k);

#endif  //  def GSCRACC_C

#endif  //  ndef GSCRACC_H

