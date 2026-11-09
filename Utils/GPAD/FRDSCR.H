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

// PUBLIC SYMBOLS S

PUBLIC void   deselectitems (void);
PUBLIC void   dispform      (void);
PUBLIC void   dispitem      (INT i,INT col,INT xpos,INT ypos);
PUBLIC void   disptable     (PTABDAT tb,INT col,INT xpos,INT ypos);
PUBLIC INT    findid        (INT id);
PUBLIC void   formbg        (void);
PUBLIC INT    gettabledata  (PTABDAT tb);
PUBLIC INT    iteminbox     (INT i,INT x,INT y,INT x1,INT y1);
PUBLIC INT    itemselected  (INT item);
PUBLIC void   moveitems     (INT mx,INT my);
PUBLIC INT    nextid        (void);
PUBLIC INT    onitem        (INT x,INT y);
PUBLIC int    scmp          (const void *a,const void *b);
PUBLIC void   selectitem    (INT item);
PUBLIC void   selectfmitem  (INT item);
PUBLIC void   selectitems   (INT x,INT y,INT x1,INT y1);
PUBLIC void   tablebdr      (PTABDAT tb,INT col,INT xpos,INT ypos);
PUBLIC CHAR * textstr       (PFORMF fld);
PUBLIC CHAR * itemtext      (INT i);
PUBLIC void   square        (INT x,INT y,INT x1,INT y1);

PUBLIC FORM   *G_forms[256];
PUBLIC INT     G_scrx       INIT(0);
PUBLIC INT     G_scry       INIT(0);
PUBLIC INT     G_scrh       INIT(25);
PUBLIC INT     G_scrw       INIT(80);
PUBLIC INT     G_fnth       INIT(12);
PUBLIC INT     G_fntw       INIT(6);
PUBLIC INT     G_formx      INIT(0);
PUBLIC INT     G_formy      INIT(0);
PUBLIC CHAR    G_widstr[4]  INIT("80");
PUBLIC CHAR    G_hgtstr[4]  INIT("25");
PUBLIC INT     G_curform    INIT(-1);
PUBLIC INT     G_modified   INIT(0);
PUBLIC INT     G_numsel     INIT(0);
PUBLIC INT     G_cds        INIT(0);
PUBLIC INT     G_cdsf       INIT(0);
PUBLIC INT     G_numdsf;
PUBLIC INT     G_sel[256];
PUBLIC INT     G_snapoff    INIT(0);

// PUBLIC SYMBOLS E

#ifdef FRDSCR_C

#endif

#endif


