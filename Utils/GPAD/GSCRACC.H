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
    UINT    attr;
    UCHAR   size;
} VARPARMS;

//-------------------------PUBLIC Prototypes & Variables-------------------
PUBLIC VARPARMS        G;
PUBLIC INT             G_xor INIT(0);
PUBLIC INT             G_coordson INIT(0);
PUBLIC UCHAR   *G_font;

PUBLIC INT          grafix      (void);
PUBLIC void         cls         (void);
PUBLIC void         getfont     (void);
PUBLIC void         outch       (INT x,INT y,UCHAR c,INT col);
PUBLIC void         prat        (INT x,INT y,CHAR *fmt, ... );
PUBLIC void         pratc       (INT x,INT y,INT col,CHAR *fmt, ... );
PUBLIC void         flipattr    (INT x,INT y,INT num);
PUBLIC CHAR         *inputln    (void);
PUBLIC INT          inputstr    (INT x,INT y,CHAR *s,INT l,CHAR t);
PUBLIC void         cursor      (INT x,INT y,INT num,INT type);
PUBLIC INT          getkey      (void);
PUBLIC INT          peekkey     (void);
PUBLIC INT          keyhit      (void);

#ifdef GSCRACC_C

//------------------------PRIVATE Prototypes & Variables-------------------


INT             G_kpeek=0;
UCHAR   G_scrc[3][80][30];
extern INT             G_maxx,G_maxy;
INT             G_linespace;
UINT    dublit(UCHAR c);
INT             chkfmt(CHAR t,CHAR k);

#endif  //  def GSCRACC_C

#endif  //  ndef GSCRACC_H

