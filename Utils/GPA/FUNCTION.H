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
#define ADF4    "addinf4"
#define ADF5    "addinf5"
#ifdef WIEN
#define ADF6    "nennwert"
#else
// PUBLIC SYMBOLS E
#define ADF6    "addinf6"
// PUBLIC SYMBOLS S
#endif
#define QNTY    "quantity"
#define FROM    "fromfld"
#define TO_F    "tofld"

PUBLIC void            errorline   (CHAR *e,INT type);
PUBLIC INT             upfunc      (void);
PUBLIC INT             downfunc    (void);
PUBLIC INT             endform     (void);
PUBLIC INT             exitform    (void);
PUBLIC INT             exit2top    (void);
PUBLIC INT             exit2mrk    (void);
PUBLIC INT             markform    (void);
PUBLIC INT             pushbkey    (void);
PUBLIC INT             beep        (void);
PUBLIC INT             prodlist    (void);

PUBLIC INT             MyProdlist    (void);
PUBLIC void            endlog(INT loglev);

PUBLIC INT             userdetails (void);
PUBLIC INT             exitkcheck  (void);
PUBLIC INT             logtransact (void);
PUBLIC INT             putcurinlog (void);
PUBLIC INT             getuser     (void);
PUBLIC INT             domop       (void);
PUBLIC INT             addmop      (void);
PUBLIC INT             addlast2    (void);
PUBLIC INT             sublast2    (void);
PUBLIC INT             getplname    (void);
PUBLIC INT             getpname    (void);
PUBLIC INT             getuname    (void);
PUBLIC INT             tabstuid     (void);
PUBLIC INT             tabssuid     (void);
PUBLIC INT             cchange      (void);
PUBLIC INT             getprod      (INT prodcode);
PUBLIC INT             setsdate     (void);
PUBLIC INT             setstime     (void);
PUBLIC INT             logoff       (void);
#ifndef WIEN
PUBLIC INT             setoname     (void);
PUBLIC INT             getoname     (void);
PUBLIC INT             setodets     (void);
PUBLIC INT             getodets     (void);
#endif
PUBLIC INT             getscale     (void);
PUBLIC INT             scalez       (void);
PUBLIC INT             scalenz      (void);
PUBLIC INT             scalestab    (void);
PUBLIC INT             setctdets    (void);
PUBLIC INT             getctdets    (void);
PUBLIC INT             getnewdiskno (void);
PUBLIC INT             newclerkdisk (void);
PUBLIC INT             consolidd    (void);
PUBLIC INT             setnewdbm    (void);
PUBLIC INT             setnewsys    (void);
PUBLIC INT             setnewcfg    (void);
PUBLIC INT             setnewoff    (void);
PUBLIC INT             blankrest    (void);
PUBLIC INT             checkpass    (void);
PUBLIC INT             getuserdet   (void);
PUBLIC INT             checkpequal  (void);
PUBLIC INT             setpassword  (void);
PUBLIC INT             reversal     (void);
PUBLIC INT 			   zerotran 	(void);
PUBLIC INT             obackup      (void);
PUBLIC INT             inrange      (CHAR *table,CHAR *value);
PUBLIC INT             yesno        (void);
PUBLIC INT             endcust      (void);

PUBLIC INT            backoff      (CHAR *name);
PUBLIC INT            backon       (CHAR *name);
PUBLIC INT            cleanup      (void);
PUBLIC INT            daynum       (CHAR *dt);
PUBLIC INT            days         (CHAR *datef,CHAR *datet);
PUBLIC CHAR *         duedom       (INT day);
PUBLIC CHAR *         duehalf      (CHAR *h1,CHAR *h2);
PUBLIC CHAR *         duequat      (CHAR *q1,CHAR *q2,CHAR *q3,CHAR *q4);
PUBLIC INT            fldcmp       (CHAR *a,CHAR *b);
PUBLIC INT            getaction    (CHAR prevkey,INT key);
PUBLIC INT            logprod      (INT prodcode);
PUBLIC INT            months       (CHAR *datef,CHAR *datet);
PUBLIC INT            nearday      (CHAR *datef,CHAR *datet);
PUBLIC INT            p4566        (INT ix,INT nr);
PUBLIC INT            proptional   (void);
PUBLIC INT            receipt      (void);
PUBLIC UCHAR  rotbyte      (UCHAR b);
PUBLIC INT            setupaction  (INT prod);
PUBLIC INT            sideslip     (void);
PUBLIC INT            getl1        (void);
PUBLIC INT            getl2        (void);
PUBLIC INT            getl3        (void);
PUBLIC INT            dispense     (void);
PUBLIC INT            coinstat	   (void);
PUBLIC INT            payoutcn     (void);
PUBLIC INT            getcoins     (void);
PUBLIC INT            operdoor     (void);
PUBLIC INT            reducecn	   (void);
PUBLIC INT            fkeysetupaction(INT prod);
PUBLIC void           putinto(char *t,char *f,char *v,int s,int e);
PUBLIC void           myerrorlog(char *text);

extern ACTMAP G_ufunc[];

#ifdef FUNCTION_C
#include "func.h"
#else
PUBLIC ACTMAP G_actmap[];
#endif
PUBLIC INT G_numeks[4];
PUBLIC KEYDEF *G_exitkeys[4]
#if INIT
={NULL,NULL,NULL,NULL}
#endif
;

PUBLIC INT G_innext
#if INIT
=0
#endif
;
PUBLIC INT G_edepth
#if INIT
=0
#endif
;
PUBLIC INT G_exitkey
#if INIT
=0
#endif
;

PUBLIC INT G_exit
#if INIT
=0
#endif
;

// PUBLIC SYMBOLS E

#ifdef FUNCTION_C

//------------------------PRIVATE Prototypes & Variables-------------------

INT cleanup         (void);
INT getaction       (CHAR prevkey,INT key);
INT logprod         (INT prodcode);

#endif  //  def FUNCTION_C

#endif  //  ndef FUNCTION_H

