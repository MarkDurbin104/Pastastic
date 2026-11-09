#ifndef FRDSCR_H

#define FRDSCR_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef FRDSCR_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

typedef unsigned int  UINT;
typedef unsigned char UCHAR;

// PUBLIC SYMBOLS S

PUBLIC void   deselectitems (void);
PUBLIC void   dispform      (void);
PUBLIC void   dispitem      (int i,int col,int xpos,int ypos);
PUBLIC void   disptable     (PTABDAT tb,int col,int xpos,int ypos);
PUBLIC int    findid        (int id);
PUBLIC void   formbg        (void);
PUBLIC int    gettabledata  (PTABDAT tb);
PUBLIC int    iteminbox     (int i,int x,int y,int x1,int y1);
PUBLIC int    itemselected  (int item);
PUBLIC void   moveitems     (int mx,int my);
PUBLIC int    nextid        (void);
PUBLIC int    onitem        (int x,int y);
PUBLIC int    scmp          (const void *a,const void *b);
PUBLIC void   selectitem    (int item);
PUBLIC void   selectfmitem  (int item);
PUBLIC void   selectitems   (int x,int y,int x1,int y1);
PUBLIC void   tablebdr      (PTABDAT tb,int col,int xpos,int ypos);
PUBLIC char * textstr       (PFORMF fld);
PUBLIC char * itemtext      (int i);
PUBLIC void   square        (int x,int y,int x1,int y1);

PUBLIC FORM   *G_forms[256];
PUBLIC int     G_scrx       INIT(0);
PUBLIC int     G_scry       INIT(0);
PUBLIC int     G_scrh       INIT(25);
PUBLIC int     G_scrw       INIT(80);
PUBLIC int     G_fnth       INIT(12);
PUBLIC int     G_fntw       INIT(6);
PUBLIC int     G_formx      INIT(0);
PUBLIC int     G_formy      INIT(0);
PUBLIC char    G_widstr[4]  INIT("80");
PUBLIC char    G_hgtstr[4]  INIT("25");
PUBLIC int     G_curform    INIT(-1);
PUBLIC int     G_modified   INIT(0);
PUBLIC int     G_numsel     INIT(0);
PUBLIC int     G_cds        INIT(0);
PUBLIC int     G_cdsf       INIT(0);
PUBLIC int     G_numdsf;
PUBLIC int     G_sel[256];
PUBLIC int     G_snapoff    INIT(0);

// PUBLIC SYMBOLS E

#ifdef FRDSCR_C

#endif

#endif


