#ifndef TYPES_H

#define TYPES_H
// PUBLIC SYMBOLS S

typedef int (*DFPTR)(int,...);
typedef int (*FPTR)();
typedef char *(*TFPTR)(char *);

typedef struct {
    unsigned char x;
    unsigned char y;
} POINT;

typedef struct {
    POINT   tl;
    POINT   br;
} WIN;

typedef struct {
    char name[9];
    long index;
} FINDEX;

typedef struct {
    int prod;
    int key;
    char func[9];
    int  access;
} KEYDEF;

#ifndef OLDFORMS
typedef struct {                          // Form Field Structure
        char            name[9];          // field name
        char            type[9];          // field type
        unsigned char   ident;            // unique field identifier
        POINT           pos;              // x/y co-ordinates
        char            attrib;           // field attributes
        unsigned char   size;             // field size
        int             class;            // item classification
        char            func[9];          // validation function
        char            item[60];         // item
        char            fmt[40];          // input format
    } FORMF;
typedef FORMF   *PFORMF;                // Pointer to Form Field Structure

typedef struct {                          // Form Structure
        char            name[9];          // form name
        unsigned char   numitem;          // the number of items
        int             access;           // form access level
        WIN             bounds;           // form boundaries
        int             type;             // form type
        char            attribs;          // form attributes 
        int             curitem;          // the current item selected
        PFORMF         items;           // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;                 // Pointer to Form Structure
#else
// PUBLIC SYMBOLS E
typedef struct {                // Form Field Structure
        unsigned char ident;    // unique field identifier
        POINT pos;              // x/y co-ordinates
        char  attrib;           // field attributes
        unsigned char size;     // field size
        char  *item;            // item
        int   class;            // item classification
        char  *func;            // validation function
        char  *fmt;             // input format
    } FORMF;
typedef FORMF   *PFORMF;        // Pointer to Form Field Structure

typedef struct {                // Form Structure
        char name[9];           // form name
        int access;             // form access level
        WIN bounds;             // form boundaries
        int type;               // form type
        char attribs;           // form attributes 
        int curitem;            // the current item selected
        unsigned char numitem;  // the number of items
        PFORMF *items;          // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;         // Pointer to Form Structure
// PUBLIC SYMBOLS S
#endif // ndef OLDFORMS

typedef struct {
    int idx;            // 2
    char desc[21];      // 21
    char val[16];       // 16
    char aval[16];      // 16
    int  round;         // 2
    int  qty;           // 2
    int  prod;          // 2
    char date[9];       // 9   DD-MM-YY
    char time[12];      // 12  HH:MM:SS.hs
    char a[3][36];      // 108
} TRANSLOG;             // 170

typedef struct {
    POINT pos;
    int   id;
    int   numf;
    char  depth;
    char  width;
    char  cols;
    char  type;
    int   tid[20];
    int   fid[20];
    int   fwid[20];
    char  sn[9];
    char  fn[20][9];
    char  cd[20];
} TABDAT;
typedef TABDAT *PTABDAT;

typedef struct {
    char    *name;
    FPTR    func;
    int     savescr;
    int     access;
} ACTMAP;
typedef ACTMAP *PACTMAP;

typedef struct {
    char    name[9];
    int     numact;
    int     savescr;
    int     access;
    char    *nlist;
    char    *tlist;
} ACTION;

typedef ACTION *PACTION;

typedef struct {
    char name[9];
    int item;
    int nitem;
    char **vars;
} FSAVE;

typedef FSAVE *PFSAVE;

#define DEVSIG  0xDEF1CE00L

typedef struct {
    unsigned long sig1;
    char *ownership;
    char *type;
    char *name;
    char *usage;
    FPTR input;
    FPTR output;
    DFPTR control;
    FPTR reset;
    unsigned long sig2;
} DEVHEADER;

#define NUMDEV 100
typedef struct {
	char 		iu;
	char 		n[10];
	char 		g[10];
	DEVHEADER 	*d;
} DEVTABLE;

typedef struct {
    int  set;
    char name[40];
    char loc[80];
    char postc[20];
    char lastd[11];
    char mon[11];
    char min[11];
    char cpos[5];
} OFFICED;      

typedef struct {
    char            name[9];
    char            type;
    unsigned char   len;
} LSTOREF;
typedef LSTOREF *PLSTOREF;

typedef struct {
    char            name[9];
    unsigned long   key;
    unsigned long   skey;
    unsigned char   numitem;
    unsigned int    li[32];
} STORE;
typedef STORE *PSTORE;

typedef struct {
    char            name[9];
    int             open;
    int             modified;
    int             skey;
    int             err;
    unsigned int    handle; // TABLEHANDLE 
    unsigned int    rec;    // RECORDHANDLE
} STORESTAT;
typedef STORESTAT *PSTORESTAT;

typedef struct {
    int  pri;           // function priority 1=maximum 256=minimum
    int  num;           // number of times added
    FPTR func;          // function to call
} KLOOPFUNC;

typedef struct {
    char  d;
    char  t;
    char  n[9];
    int   o;
} NAMEINDEX;
// PUBLIC SYMBOLS E

#endif  //  ndef TYPES_H


