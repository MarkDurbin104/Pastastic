#ifndef FORMHAND_H    // stop multiple includes

#define FORMHAND_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FORMHAND_C
#define PUBLIC 
#define INIT(a) = a;
#define INIT4(a,b,c,d) = {a,b,c,d};
#else
#define PUBLIC extern
#define INIT(a) ;
#define INIT4(a,b,c,d) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define NUM_FCLASS  10
#define FF_MAND   0x0000
#define FF_OPTI   0x0001
#define FF_SRCH   0x0002
#define FF_TEXT   0x0003
#define FF_MSRH   0x0004
#define FF_MSEC   0x0005
#define FF_WAIT   0x0006
#define FF_DISP   0x0007
#define FF_SECS   0x0008
#define FF_TABL   0x0009

#define FF_TBLF   0x8000

#define IT_MENU   0x01
#define IT_FORM   0x02
#define IT_FUNC   0x03

#define MI_ENAB   0x00
#define MI_DISA   0x01

#define F_NORM    0
#define F_SERVE   1
#define F_PROMPT  2
#define F_MENU    3
#define F_REPORT  4
#define F_PPFORM  5

#define FA_UPDS   0x01

// PUBLIC SYMBOLS E

#ifdef OLDFORMS

PUBLIC INT      savetext    (CHAR *sys);
PUBLIC INT      loadtext    (CHAR *sys);
PUBLIC void     freetext    (void);
PUBLIC INT      readindex   (INT fd,FINDEX *i);
PUBLIC INT      writeindex  (INT fd,FINDEX *i);
PUBLIC INT      wipeindex   (INT fd);
PUBLIC INT      readform    (INT fd,FORM *f);
PUBLIC INT      writeform   (INT fd,FORM *f);
PUBLIC INT      readvitem   (INT fd,INT *len,CHAR *str);
PUBLIC INT      writevitem  (INT fd,CHAR *str);
PUBLIC INT      readformf   (INT fd,FORMF *f);
PUBLIC INT      writeformf  (INT fd,FORMF *f);
PUBLIC INT      saveform    (CHAR *sys,PFORM sf);
PUBLIC void     orderform   (PFORM f,INT type);
PUBLIC INT      consolid    (CHAR *sys);
PUBLIC LONG     isform      (CHAR *sys,CHAR *name);
PUBLIC INT      loadformidx (CHAR *sys,PFORM sf,LONG index);
PUBLIC INT      loadform    (CHAR *sys,PFORM sf);
PUBLIC INT      addformf    (PFORM f,PFORMF fld);
PUBLIC INT      delformf    (PFORM f,INT id);
PUBLIC void     freeform    (PFORM f);
#else
// PUBLIC SYMBOLS S
PUBLIC INT                 savetext           (CHAR *sys);
PUBLIC INT                 loadtext           (CHAR *sys);
PUBLIC void                freetext           (void);
PUBLIC LONG                isform             (CHAR *name);
PUBLIC INT                 loadformidx        (PFORM sf,LONG ofs);
PUBLIC INT                 loadform           (PFORM sf);
PUBLIC void                freeform           (PFORM f);
PUBLIC void                orderform          (PFORM f,INT type);
PUBLIC INT                 addformf           (PFORM f,PFORMF fld);
PUBLIC INT                 delformf           (PFORM f,INT id);
PUBLIC void                freeformidx        (void);
PUBLIC LONG                getformidx         (CHAR *name);
PUBLIC int                 ficmp              (const void *a,const void *b);
#endif

PUBLIC INT                  G_numidx INIT(0);
PUBLIC FINDEX               *G_fid INIT(NULL);
PUBLIC FORM                 G_form;
PUBLIC CHAR                 **G_text;
PUBLIC CHAR                 **G_tname;
PUBLIC INT                  G_tcnt INIT(0);
PUBLIC INT                  G_saved INIT(0);
PUBLIC CHAR                 G_parea[4] INIT4(0,17,79,20);
PUBLIC CHAR                 G_tarea[4] INIT4(43,21,79,24);
PUBLIC CHAR                 G_larea[4] INIT4(47,2,79,16);
PUBLIC INT                  G_fversion INIT(0);

// PUBLIC SYMBOLS E
#ifdef FORMHAND_C

//------------------------PRIVATE Prototypes & Variables-------------------
INT  G_formsize=0;
INT  G_fieldsize=0;
int  usort    (const void *a,const void *b);
int  fsort    (const void *a,const void *b);

#ifndef OLDFORMS
LONG remform  (INT fd,CHAR *name);
#endif

#endif  //  def FORMHAND_C

#endif  //  ndef FORMHAND_H


