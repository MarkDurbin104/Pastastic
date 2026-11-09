#ifndef TYPES_H

#define TYPES_H
// PUBLIC SYMBOLS S

typedef int  INT;
typedef long LONG;
typedef char CHAR;
typedef unsigned int  UINT;
typedef unsigned long ULONG;
typedef unsigned char UCHAR;

typedef INT (*DFPTR)(INT,...);
typedef INT (*FPTR)(void);
typedef CHAR *(*TFPTR)(CHAR *);
typedef INT (*QSPTR)(const void*, const void*);

typedef struct {
    UCHAR attr;
    UCHAR size;
    UCHAR xor;
} SCRATTR;

typedef struct {
    UCHAR x;
    UCHAR y;
} POINT;

typedef struct {
    POINT   tl;
    POINT   br;
} WIN;

typedef struct {
    CHAR name[9];
    LONG index;
} FINDEX;

typedef struct {
    INT prod;
    INT key;
    CHAR func[9];
    INT  access;
} KEYDEF;

#ifndef OLDFORMS
typedef struct {                          // Form Field Structure
        CHAR            name[9];          // field name
        CHAR            type[9];          // field type
        UCHAR   ident;            // unique field identifier
        POINT           pos;              // x/y co-ordinates
        CHAR            attrib;           // field attributes
        UCHAR   size;             // field size
        INT             class;            // item classification
        CHAR            func[9];          // validation function
        CHAR            item[60];         // item
        CHAR            fmt[40];          // input format
    } FORMF;
typedef FORMF   *PFORMF;                // Pointer to Form Field Structure

typedef struct {                          // Form Structure
        CHAR            name[9];          // form name
        UCHAR   numitem;          // the number of items
        INT             access;           // form access level
        WIN             bounds;           // form boundaries
        INT             type;             // form type
        CHAR            attribs;          // form attributes 
        INT             curitem;          // the current item selected
        PFORMF         items;           // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;                 // Pointer to Form Structure
#else
// PUBLIC SYMBOLS E
typedef struct {                // Form Field Structure
        UCHAR ident;    // unique field identifier
        POINT pos;              // x/y co-ordinates
        CHAR  attrib;           // field attributes
        UCHAR size;     // field size
        CHAR  *item;            // item
        INT   class;            // item classification
        CHAR  *func;            // validation function
        CHAR  *fmt;             // input format
    } FORMF;
typedef FORMF   *PFORMF;        // Pointer to Form Field Structure

typedef struct {                // Form Structure
        CHAR name[9];           // form name
        INT access;             // form access level
        WIN bounds;             // form boundaries
        INT type;               // form type
        CHAR attribs;           // form attributes 
        INT curitem;            // the current item selected
        UCHAR numitem;  // the number of items
        PFORMF *items;          // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;         // Pointer to Form Structure
// PUBLIC SYMBOLS S
#endif // ndef OLDFORMS

typedef struct {
    INT idx;            // 2
    CHAR desc[21];      // 21
    CHAR val[16];       // 16
    CHAR aval[16];      // 16
    INT  round;         // 2
    INT  qty;           // 2
    INT  prod;          // 2
    CHAR date[9];       // 9   DD-MM-YY
    CHAR time[12];      // 12  HH:MM:SS.hs
    CHAR a[3][36];      // 108
} TRANSLOG;             // 170

typedef struct {
    POINT pos;
    INT   id;
    INT   numf;
    CHAR  depth;
    CHAR  width;
    CHAR  cols;
    CHAR  type;
    INT   tid[20];
    INT   fid[20];
    INT   fwid[20];
    CHAR  sn[9];
    CHAR  fn[20][9];
    CHAR  cd[20];
} TABDAT;
typedef TABDAT *PTABDAT;

typedef struct {
    CHAR    *name;
    FPTR    func;
//    INT     savescr;
//    INT     access;
} ACTMAP;
typedef ACTMAP *PACTMAP;

typedef struct {
    CHAR    name[9];
    INT     numact;
    INT     savescr;
    INT     access;
    CHAR    *nlist;
    CHAR    *tlist;
} ACTION;

typedef ACTION *PACTION;

typedef struct {
    CHAR name[9];
    CHAR mark;
    INT item;
    INT nitem;
    CHAR **vars;
    CHAR *tflds;
} FSAVE;

typedef FSAVE *PFSAVE;

#define DEVSIG  0xDEF1CE00L

typedef struct {
    ULONG sig1;
    CHAR *ownership;
    CHAR *type;
    CHAR *name;
    CHAR *usage;
    FPTR input;
    FPTR output;
    DFPTR control;
    FPTR reset;
    ULONG sig2;
} DEVHEADER;

#define NUMDEV 50
typedef struct {
	CHAR 		iu;
	CHAR 		n[10];
	CHAR 		g[10];
	DEVHEADER 	*d;
} DEVTABLE;

typedef struct {
    INT  set;
    CHAR name[40];
    CHAR loc[80];
    CHAR postc[20];
    CHAR lastd[11];
    CHAR mon[11];
    CHAR min[11];
    CHAR cpos[5];
} OFFICED;      

typedef struct {
    CHAR            name[9];
    CHAR            type;
    UCHAR   len;
} LSTOREF;
typedef LSTOREF *PLSTOREF;

typedef struct {
    CHAR            name[9];
    ULONG   key;
    ULONG   skey;
    UCHAR   numitem;
    UINT    li[32];
} STORE;
typedef STORE *PSTORE;

typedef struct {
    CHAR            name[9];
    INT             open;
    INT             modified;
    INT             skey;
    INT             err;
    UINT    handle; // TABLEHANDLE 
    UINT    rec;    // RECORDHANDLE
} STORESTAT;
typedef STORESTAT *PSTORESTAT;

typedef struct {
    INT  pri;           // function priority 1=maximum 9999=minimum
    INT  num;           // number of times added
    INT  lt;			// number of ticks since last execution
    CHAR td;			// execution to be performed
    FPTR func;          // function to call
} KLOOPFUNC;

typedef struct {
    CHAR  d;
    CHAR  t;
    CHAR  n[9];
    ULONG  o;
    UCHAR *b;
} NAMEINDEX;
typedef struct {
    CHAR n[9];
    INT  i;
} NAMEBUFFER;


typedef struct {
    CHAR t;
    union {
        double n;
        CHAR   s[80];
    } u;
} STACK;

// PUBLIC SYMBOLS E
#endif  //  ndef TYPES_H


