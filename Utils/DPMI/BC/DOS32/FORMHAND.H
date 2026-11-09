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

PUBLIC int      savetext    (char *sys);
PUBLIC int      loadtext    (char *sys);
PUBLIC void     freetext    (void);
PUBLIC int      readindex   (int fd,FINDEX *i);
PUBLIC int      writeindex  (int fd,FINDEX *i);
PUBLIC int      wipeindex   (int fd);
PUBLIC int      readform    (int fd,FORM *f);
PUBLIC int      writeform   (int fd,FORM *f);
PUBLIC int      readvitem   (int fd,int *len,char *str);
PUBLIC int      writevitem  (int fd,char *str);
PUBLIC int      readformf   (int fd,FORMF *f);
PUBLIC int      writeformf  (int fd,FORMF *f);
PUBLIC int      saveform    (char *sys,PFORM sf);
PUBLIC void     orderform   (PFORM f,int type);
PUBLIC int      consolid    (char *sys);
PUBLIC long     isform      (char *sys,char *name);
PUBLIC int      loadformidx (char *sys,PFORM sf,long index);
PUBLIC int      loadform    (char *sys,PFORM sf);
PUBLIC int      addformf    (PFORM f,PFORMF fld);
PUBLIC int      delformf    (PFORM f,int id);
PUBLIC void     freeform    (PFORM f);
#else
// PUBLIC SYMBOLS S
PUBLIC int                 savetext           (char *sys);
PUBLIC int                 loadtext           (char *sys);
PUBLIC void                freetext           (void);
PUBLIC long                isform             (char *name);
PUBLIC int                 loadformidx        (PFORM sf,long ofs);
PUBLIC int                 loadform           (PFORM sf);
PUBLIC void                freeform           (PFORM f);
PUBLIC void                orderform          (PFORM f,int type);
PUBLIC int                 addformf           (PFORM f,PFORMF fld);
PUBLIC int                 delformf           (PFORM f,int id);
PUBLIC void                freeformidx        (void);
PUBLIC long                getformidx         (char *name);
PUBLIC int                 ficmp              (const void *a,const void *b);
#endif

PUBLIC int                  G_numidx INIT(0);
PUBLIC FINDEX               *G_fid INIT(NULL);
PUBLIC FORM                 G_form;
PUBLIC char                 **G_text;
PUBLIC char                 **G_tname;
PUBLIC int                  G_tcnt INIT(0);
PUBLIC int                  G_saved INIT(0);
PUBLIC char                 G_parea[4] INIT4(0,17,79,20);
PUBLIC char                 G_tarea[4] INIT4(43,21,79,24);
PUBLIC char                 G_larea[4] INIT4(47,2,79,16);
PUBLIC int                  G_fversion INIT(0);

// PUBLIC SYMBOLS E
#ifdef FORMHAND_C

//------------------------PRIVATE Prototypes & Variables-------------------
int  G_formsize=0;
int  G_fieldsize=0;
int  usort    (const void *a,const void *b);
int  fsort    (const void *a,const void *b);

#ifndef OLDFORMS
long remform  (int fd,char *name);
#endif

#endif  //  def FORMHAND_C

#endif  //  ndef FORMHAND_H
