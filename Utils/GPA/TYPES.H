#ifndef TYPES_H

#define TYPES_H
// PUBLIC SYMBOLS S

#ifdef __DPMI32__
typedef          char  CHAR;        // define to be  8 bits
typedef          short INT16;       // define to be 16 bits
typedef          int   INT;         // define to be 32 bits
typedef          long  LONG;        // define to be 32 bits
typedef unsigned char  UCHAR;       // define to be  8 bits unsigned
typedef unsigned short UINT16;      // define to be 16 bits unsigned
typedef unsigned int   UINT;        // define to be 32 bits unsigned
typedef unsigned long  ULONG;       // define to be 32 bits unsigned
#else
#define _EAX _AX
#define _EBX _BX
#define _ECX _CX
#define _EDX _DX
typedef          char  CHAR;        // define to be  8 bits
typedef          short INT16;       // define to be 16 bits
typedef          int   INT;         // define to be 32 bits
typedef          long  LONG;        // define to be 32 bits
typedef unsigned char  UCHAR;       // define to be  8 bits unsigned
typedef unsigned short UINT16;      // define to be 16 bits unsigned
typedef unsigned int   UINT;        // define to be 32 bits unsigned
typedef unsigned long  ULONG;       // define to be 32 bits unsigned
#endif

typedef LONG (*DFPTR)(INT,void *);
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
} XYPNT;

typedef struct {
    XYPNT   tl;
    XYPNT   br;
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

typedef struct {                          // Form Field Structure
        CHAR            name[9];          // field name
        CHAR            type[9];          // field type
        UCHAR           ident;            // unique field identifier
        XYPNT           pos;              // x/y co-ordinates
        CHAR            attrib;           // field attributes
        UCHAR           size;             // field size
        INT16           class;            // item classification
        CHAR            func[9];          // validation function
        CHAR            item[60];         // item
        CHAR            fmt[40];          // input format
    } FORMF;
typedef FORMF   *PFORMF;                // Pointer to Form Field Structure

typedef struct {                          // Form Structure
        CHAR            name[9];          // form name
        UCHAR           numitem;          // the number of items
        INT16           access;           // form access level
        WIN             bounds;           // form boundaries
        INT16           type;             // form type
        CHAR            attribs;          // form attributes 
        INT16           curitem;          // the current item selected
        PFORMF         items;           // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;                 // Pointer to Form Structure

typedef struct {
    INT idx;            // 2
    CHAR desc[21];      // 21
    CHAR val[16];       // 16
    CHAR aval[16];      // 16
    INT  round;         // 2
#ifdef WIEN
    ULONG  qty;         // 4
#else//IEN
    INT  qty;         // 2
#endif//WIEN
    INT  prod;          // 2
    CHAR date[9];       // 9   DD-MM-YY
    CHAR time[12];      // 12  HH:MM:SS.hs
    CHAR a[6][41];      // 166
} TRANSLOG;             // 

typedef struct {
    XYPNT pos;
    INT   id;
    INT   numf;
    CHAR  depth;
    CHAR  width;
    CHAR  cols;
    CHAR  type;
    INT   tid[20];
    INT   fid[20];
    INT   fwid[20];
#ifdef WIEN
    INT  sn;
    INT  fn[20];
#else //WIEN
    UCHAR  sn;
    UCHAR  fn[20];
#endif //WIEN
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
    INT16    li[32];
} STORE;
typedef STORE *PSTORE;

typedef struct {
    CHAR   name[9];
    INT    open;
    INT    modified;
    INT    err;
    UINT   handle; // TABLEHANDLE 
    UINT   rec;    // RECORDHANDLE
    CHAR*  buf;
    UINT   len;
    UINT   fofs[32];
} STORESTAT;
typedef STORESTAT *PSTORESTAT;

typedef struct {
    INT  pri;           // function priority 1=maximum 9999=minimum
    INT  num;           // number of times added
    INT  lt;			// number of ticks since last execution
    CHAR td;			// execution to be performed
//    CHAR bd;
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
// ---------------------------- MESSAGE TYPES --------------------------------
#define MESSAGE_0       0x0001
#define MESSAGE_1       0x0002
#define MESSAGE_QUEST   0x0003
#define MESSAGE_TEXT    0x0004
#define MESSAGE_A       0x0005
#define MESSAGE_AN      0x0006
#define MESSAGE_b       0x0007
#define MESSAGE_B       0x0008
#define MESSAGE_bp      0x0009
#define MESSAGE_bs      0x000A
#define MESSAGE_BT      0x000B
#define MESSAGE_c       0x000C
#define MESSAGE_C       0x000D
#define MESSAGE_ca      0x000E
#define MESSAGE_CC      0x000F
#define MESSAGE_CD      0x0010
#define MESSAGE_CH      0x0011
#define MESSAGE_CI      0x0012
#define MESSAGE_CL      0x0013
#define MESSAGE_cr      0x0014
#define MESSAGE_CT      0x0015
#define MESSAGE_D       0x0016
#define MESSAGE_d       0x0017
#define MESSAGE_DA      0x0018
#define MESSAGE_DC      0x0019
#define MESSAGE_dg      0x001A
#define MESSAGE_dr      0x001B
#define MESSAGE_E       0x001C
#define MESSAGE_e       0x001D
#define MESSAGE_f       0x001E
#define MESSAGE_F       0x001F
#define MESSAGE_FH      0x0020
#define MESSAGE_g       0x0021
#define MESSAGE_G       0x0022
#define MESSAGE_GA      0x0023
#define MESSAGE_GC      0x0024
#define MESSAGE_GP      0x0025
#define MESSAGE_GS      0x0026
#define MESSAGE_H       0x0027
#define MESSAGE_HD      0x0028
#define MESSAGE_HN      0x0029
#define MESSAGE_I       0x002A
#define MESSAGE_i       0x002B
#define MESSAGE_in      0x002C
#define MESSAGE_K       0x002D
#define MESSAGE_L       0x002E
#define MESSAGE_l       0x002F
#define MESSAGE_md      0x0030
#define MESSAGE_MI      0x0031
#define MESSAGE_MS      0x0032
#define MESSAGE_MY      0x0033
#define MESSAGE_N       0x0034
#define MESSAGE_NH      0x0035
#define MESSAGE_NL      0x0036
#define MESSAGE_NONE    0x0037
#define MESSAGE_nr      0x0038
#define MESSAGE_O       0x0039
#define MESSAGE_o       0x003A
#define MESSAGE_od      0x003B
#define MESSAGE_OD      0x003C
#define MESSAGE_OF      0x003D
#define MESSAGE_Ol      0x003E
#define MESSAGE_OL      0x003F
#define MESSAGE_On      0x0040
#define MESSAGE_ON      0x0041
#define MESSAGE_p       0x0042
#define MESSAGE_P       0x0043
#define MESSAGE_PH      0x0044
#define MESSAGE_PO      0x0045
#define MESSAGE_PS      0x0046
#define MESSAGE_qg      0x0047
#define MESSAGE_qp      0x0048
#define MESSAGE_r       0x0049
#define MESSAGE_R       0x004A
#define MESSAGE_RA      0x004B
#define MESSAGE_RB      0x004C
#define MESSAGE_RC      0x004D
#define MESSAGE_rd      0x004E
#define MESSAGE_RI      0x004F
#define MESSAGE_RK      0x0050
#define MESSAGE_rn      0x0051
#define MESSAGE_RP      0x0052
#define MESSAGE_rt      0x0053
#define MESSAGE_s       0x0054
#define MESSAGE_S       0x0055
#define MESSAGE_S1      0x0056
#define MESSAGE_S2      0x0057
#define MESSAGE_SA      0x0058
#define MESSAGE_SC      0x0059
#define MESSAGE_SE      0x005A
#define MESSAGE_SI      0x005B
#define MESSAGE_sp      0x005C
#define MESSAGE_SP      0x005D
#define MESSAGE_T       0x005E
#define MESSAGE_tc      0x005F
#define MESSAGE_TE      0x0060
#define MESSAGE_TL      0x0061
#define MESSAGE_tt      0x0062
#define MESSAGE_U       0x0063
#define MESSAGE_UZ      0x0064
#define MESSAGE_V       0x0065
#define MESSAGE_w       0x0066
#define MESSAGE_u  MESSAGE_USER+6
#define MESSAGE_x       0x0067
#define MESSAGE_xt      0x0068
#define MESSAGE_Z       0x0069
#define MESSAGE_TILDI   0x006A
#define MESSAGE_RO      0x006B
#define MESSAGE_3       0x006C
#define MESSAGE_Fi      0x006D
#define MESSAGE_SS      0x006E
#define MESSAGE_RM      0x006F
#define MESSAGE_EM      0x0070
#define MESSAGE_PM      0x0071
#define MESSAGE_DT      0x0072
#define MESSAGE_AA      0x0073
#define MESSAGE_Bl      0x0074
#define MESSAGE_X       0x0075
#define MESSAGE_SB      0x0076
#define MESSAGE_ns      0x0077
#define MESSAGE_xy      0x0078
#define MESSAGE_cs      0x0079
#define MESSAGE_ta      0x007A
#define MESSAGE_21      0x007B
#define MESSAGE_pc      0x007C
#define MESSAGE_fm      0x007D
#define MESSAGE_PL      0x007E
#define MESSAGE_tp      0x007F
#define MESSAGE_ts      0x0080
#define MESSAGE_it      0x0081
#define MESSAGE_PR      0x0082
#define MESSAGE_as      0x0083
#define MESSAGE_sl      0x0084
#define MESSAGE_RS      0x0085
#define MESSAGE_COPY    0x0086

#define MESSAGE_USER    0x4000
#define MESSAGE_ins MESSAGE_USER+1
#define MESSAGE_rh MESSAGE_USER+2
#define MESSAGE_bt MESSAGE_USER+3
#define MESSAGE_ct MESSAGE_USER+4
#define MESSAGE_rb MESSAGE_USER+5
#define MESSAGE_LI MESSAGE_USER+6 //Labeldrucker Init
#define MESSAGE_LP MESSAGE_USER+7 //Labeldruck
#define MESSAGE_rbt MESSAGE_USER+8  //Turbo BeginTransaction
#define MESSAGE_rct MESSAGE_USER+9  //Turbo Commit
#define MESSAGE_rrb MESSAGE_USER+10 //Turbo Rollback
#define MESSAGE_rrf MESSAGE_USER+11 //RamRefresh
#define MESSAGE_rqs MESSAGE_USER+12 //RamQsort
#define MESSAGE_FLPI MESSAGE_USER+13 //Forced LabelPrinter Initialisierung
#define MESSAGE_un MESSAGE_USER+14 // URI of next record




// PUBLIC SYMBOLS E

#endif  //  ndef TYPES_H

