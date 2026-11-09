#ifndef FUNCTION_H    // stop multiple includes

#define FUNCTION_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef FUNCTION_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define PROD_S  "product"
#define TRAN_S  "transact"
#define USER_S  "user"
#define STOK_S  "stock"

#define CODE    "prodcode"
#define FKEY    "fnkey"   
#define NAME    "name"    
#define AMNT    "amount"  
#define MAXQ    "maxqty"  
#define ACTI    "action"  
#define MAND    "mndprd"  
#define PKEY    "prevkey" 
#define PRIV    "privlev" 
#define OPT1    "optprd1" 
#define OPT2    "optprd2" 
#define OPT3    "optprd3" 
#define OPT4    "optprd4" 
#define OPT5    "optprd5" 
#define FIXP    "fixprice"
#define ADD1    "addprmt1"
#define ADD2    "addprmt2"
#define ADD3    "addprmt3"
#define USID    "userid"
#define UNAM    "username"
#define PASS    "password"
#define DISK    "diskid"
#define POSN    "position"
#define CDAT    "date"          // can't use DATE - defined in PXENGINE.H
#define TIME    "time"
#define ADF1    "addinf1"
#define ADF2    "addinf2"
#define ADF3    "addinf3"
#define QNTY    "quantity"
#define FROM    "fromfld"
#define TO_F    "tofld"

PUBLIC void            errorline   (char *e,int type);
PUBLIC int             upfunc      (void);
PUBLIC int             downfunc    (void);
PUBLIC int             exitform    (void);
PUBLIC int             beep        (void);
PUBLIC int             prodlist    (void);
PUBLIC int             userdetails (void);
PUBLIC int             exitkcheck  (void);
PUBLIC int             logtransact (void);
PUBLIC int             putcurinlog (void);
PUBLIC int             getuser     (void);
PUBLIC int             domop       (void);
PUBLIC int             addmop      (void);
PUBLIC int             addlast2    (void);
PUBLIC int             sublast2    (void);
PUBLIC int             getpname    (void);
PUBLIC int             getuname    (void);
PUBLIC int             tabstuid     (void);
PUBLIC int             tabssuid     (void);
PUBLIC int             cchange      (void);
PUBLIC int             getprod      (int prodcode);
PUBLIC int             setsdate     (void);
PUBLIC int             setstime     (void);
PUBLIC int             logoff       (void);
PUBLIC int             setodets     (void);
PUBLIC int             getodets     (void);
PUBLIC int             setctdets    (void);
PUBLIC int             getctdets    (void);
PUBLIC int             getnewdiskno (void);
PUBLIC int             newclerkdisk (void);
PUBLIC int             consolidd    (void);
PUBLIC int             setnewdbm    (void);
PUBLIC int             setnewsys    (void);
PUBLIC int             setnewcfg    (void);
PUBLIC int             setnewoff    (void);
PUBLIC int             blankrest    (void);
PUBLIC int             checkpass    (void);
PUBLIC int             getuserdet   (void);
PUBLIC int             checkpequal  (void);
PUBLIC int             setpassword  (void);
PUBLIC int             reversal     (void);
PUBLIC int             backup       (void);
PUBLIC int             inrange      (char *table,char *value);
PUBLIC int             yesno        (void);

PUBLIC int            backoff      (char *name);
PUBLIC int            backon       (char *name);
PUBLIC int            cleanup      (void);
PUBLIC int            daynum       (char *dt);
PUBLIC int            days         (char *datef,char *datet);
PUBLIC char *         duedom       (int day);
PUBLIC char *         duehalf      (char *h1,char *h2);
PUBLIC char *         duequat      (char *q1,char *q2,char *q3,char *q4);
PUBLIC int            fldcmp       (char *a,char *b);
PUBLIC int            getaction    (char prevkey,int key);
PUBLIC int            getday       (char *dt);
PUBLIC int            getmon       (char *dt);
PUBLIC int            getyear      (char *dt);
PUBLIC int            logprod      (int prodcode);
PUBLIC int            months       (char *datef,char *datet);
PUBLIC int            nearday      (char *datef,char *datet);
PUBLIC int            p4566        (int ix,int nr);
PUBLIC int            proptional   (void);
PUBLIC int            receipt      (void);
PUBLIC unsigned char  rotbyte      (unsigned char b);
PUBLIC int            setupaction  (int prod);
PUBLIC int            sideslip     (void);

extern ACTMAP G_ufunc[];

#ifdef FUNCTION_C
#include "func.h"
#else
PUBLIC ACTMAP G_actmap[];
#endif
PUBLIC int G_numeks[4];
PUBLIC KEYDEF *G_exitkeys[4]
#if INIT
={NULL,NULL,NULL,NULL}
#endif
;

PUBLIC int G_innext
#if INIT
=0
#endif
;
PUBLIC int G_edepth
#if INIT
=0
#endif
;
PUBLIC int G_exitkey
#if INIT
=0
#endif
;

PUBLIC int G_exit
#if INIT
=0
#endif
;

PUBLIC int G_intable
#if INIT
=0
#endif
;
// PUBLIC SYMBOLS E

#ifdef FUNCTION_C

//------------------------PRIVATE Prototypes & Variables-------------------

int cleanup         (void);
int getaction       (char prevkey,int key);
int logprod         (int prodcode);

#endif  //  def FUNCTION_C

#endif  //  ndef FUNCTION_H
