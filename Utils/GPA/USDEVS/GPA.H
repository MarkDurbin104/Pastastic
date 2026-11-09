// ------------------------------ TYPES.H START ------------------------------


typedef int _cdecl (*DFPTR)(int,...);
typedef int (*FPTR)(void);
typedef char *(*TFPTR)(char *);

typedef unsigned int uint;
typedef unsigned long ulong;
typedef unsigned char uchar;

typedef struct {
    uchar attr;
    uchar size;
    uchar xor;
} SCRATTR;

typedef struct {
    uchar x;
    uchar y;
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
        uchar   ident;            // unique field identifier
        POINT           pos;              // x/y co-ordinates
        char            attrib;           // field attributes
        uchar   size;             // field size
        int             class;            // item classification
        char            func[9];          // validation function
        char            item[60];         // item
        char            fmt[40];          // input format
    } FORMF;
typedef FORMF   *PFORMF;                // Pointer to Form Field Structure

typedef struct {                          // Form Structure
        char            name[9];          // form name
        uchar   numitem;          // the number of items
        int             access;           // form access level
        WIN             bounds;           // form boundaries
        int             type;             // form type
        char            attribs;          // form attributes 
        int             curitem;          // the current item selected
        PFORMF         items;           // the list of items in order of display
    } FORM;
typedef FORM    *PFORM;                 // Pointer to Form Structure
#else
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
    char mark;
    int item;
    int nitem;
    char **vars;
    char *tflds;
} FSAVE;

typedef FSAVE *PFSAVE;

#define DEVSIG  0xDEF1CE00L

typedef struct {
    ulong sig1;
    char *ownership;
    char *type;
    char *name;
    char *usage;
    FPTR input;
    FPTR output;
    DFPTR control;
    FPTR reset;
    ulong sig2;
} DEVHEADER;

#define NUMDEV 50
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
    uchar   len;
} LSTOREF;
typedef LSTOREF *PLSTOREF;

typedef struct {
    char            name[9];
    ulong   key;
    ulong   skey;
    uchar   numitem;
    uint    li[32];
} STORE;
typedef STORE *PSTORE;

typedef struct {
    char            name[9];
    int             open;
    int             modified;
    int             skey;
    int             err;
    uint    handle; // TABLEHANDLE 
    uint    rec;    // RECORDHANDLE
} STORESTAT;
typedef STORESTAT *PSTORESTAT;

typedef struct {
    int  pri;           // function priority 1=maximum 9999=minimum
    int  num;           // number of times added
    int  lt;			// number of ticks since last execution
    char td;			// execution to be performed
    FPTR func;          // function to call
} KLOOPFUNC;

typedef struct {
    char  d;
    char  t;
    char  n[9];
    int   o;
} NAMEINDEX;


typedef struct {
    char t;
    union {
        double n;
        char   s[80];
    } u;
} STACK;


// ------------------------------- TYPES.H END --------------------------------

// ------------------------------ INSTRUCT.H START ------------------------------

#define EQUAL       1
#define LOGIC_AND   2
#define LOGIC_OR    3
#define LOGIC_NOT   4
#define LESSEQUAL   5
#define LESS        6
#define GREATEQUAL  7
#define GREAT       8
#define EQUALITY    9
#define NOTEQUAL   10
#define PLUS       11
#define MINUS      12
#define MULTIPLY   13
#define MODULUS    14
#define DEVIDE     15
#define NEGATE     16
#define OCURLY     17
#define CCURLY     18
#define TCONSTANT  19
#define SCONSTANT  20
#define LCONSTANT  21
#define DCONSTANT  22
#define CCONSTANT  23
#define FORMVAR    24
#define VARIABLE   25
#define ABS        26
#define ACOS       27
#define ASIN       28
#define ATAN       29
#define COSH       30
#define COS        31
#define EXP        32
#define LOG10      33
#define LOGAR      34
#define ROUND      35
#define POW10      36
#define SINH       37
#define SIN        38
#define SQRT       39
#define SQR        40
#define TANH       41
#define TAN        42
#define TRUNC      43
#define GOTOXY     44
#define MARKER     45
#define WHILE      46
#define IF         47
#define ELSE       48
#define SETFMVAR   49
#define SETVARIAB  50
#define ANAME      51
#define ACTIONN    52
#define RANGE      53
#define RESULT     54
#define LOOKUP     55
#define TABLE      56
#define LOOKTAB    57
#define PASSEDVAL  58
#define LOGQNTY    59
#define LOGVALUE   60
#define LOGNAME    61
#define DSNAME     62
#define DATASTORE  63
#define SETDATAST  64
#define ADDTOLOG   65
#define CURFIELD   66
#define FORMNAME   67
#define UFUNC      68
#define CFUNC      69
#define USING      70
#define UPDATE     71
#define ACCESSL    72
#define SJOIN      73
#define SCUT       74
#define SEQU       75
#define SNEQU      76
#define SLESS      77
#define SLEQU      78
#define SGREAT     79
#define SGEQU      80
#define SUPPER     81
#define SLOWER     82
#define SETCURITM  83
#define GLOBVAR    84
#define SETGLOBVR  85
#define INRANGE    86
#define NMONTHS    87
#define GETYEAR    88
#define NDAYS      89
#define DUEDOM     90
#define DUEHALF    91
#define GETPROD    92
#define ERRLINE    93
#define DATESTR    94
#define FMTMATCH   95
#define WHERE      96
#define COPYREC    97
#define DUPDSFMT   98
#define REMDSFMT   99
#define RUNFORM   100
#define STSRCH    101
#define STSRCHP   102
#define STREAD    103
#define STWRITE   104
#define CREC      105
#define NREC      106
#define PREC      107
#define FREC      108
#define LREC      109
#define CLREC     110
#define HOTKEY	  111
#define SETDEV	  112
#define SAVEDEV	  113
#define RESTDEV	  114
#define XTIMER 	  115
#define SWAPTO	  116
#define RUN	      117
#define STEMPTY	  118
#define PSHKEY	  119
#define SAVESCR   120
#define USERVAR   121
#define SETUSRVAR 122
#define STATICS   123
#define SETSTATIC 124
#define STATNAME  125

// ------------------------------- INSTRUCT.H END --------------------------------

// ------------------------------ KEYNAMES.H START ------------------------------


// ------------------------------- KEYNAMES.H END --------------------------------

// ------------------------------ KEYDEF.H START ------------------------------

#define CTRLA   1
#define CTRLB   2
#define CTRLC   3
#define CTRLD   4
#define CTRLE   5
#define CTRLF   6
#define CTRLG   7
#define CTRLH   8
#define CTRLI   9
#define CTRLJ   10
#define CTRLK   11
#define CTRLL   12
#define CTRLM   13
#define CTRLN   14
#define CTRLO   15
#define CTRLP   16
#define CTRLQ   17
#define CTRLR   18
#define CTRLS   19
#define CTRLT   20
#define CTRLU   21
#define CTRLV   22
#define CTRLW   23
#define CTRLX   24
#define CTRLY   25
#define CTRLZ   26
#define SPACE   32
#define BKSP    8
#define SBKSP   8
#define CBKSP   127
#define ABKSP   (-14)
#define LF      10
#define CR      13
#define ENTER   13
#define SCR     13
#define CCR     10
#define ACR     (-28)
#define TAB     9
#define STAB    (-15)
#define CTAB    (-148)
#define ATAB    (-165)
#define ESC     27
#define SESC    (-4)
#define CESC    (-2)
#define AESC    (-1)
#define LEFT    (-75)
#define RGT     (-77)
#define UP      (-72)
#define DOWN    (-80)
#define SLEFT   (-75)
#define SRGT    (-77)
#define SUP     (-72)
#define SDOWN   (-80)
#define CLEFT   (-115)
#define CRGT    (-116)
#define CUP     (-141)
#define CDOWN   (-145)
#define ALEFT   (-155)
#define ARGT    (-157)
#define AUP     (-152)
#define ADOWN   (-160)
#define INS     (-82)
#define DEL     (-83)
#define HOME    (-71)
#define END     (-79)
#define PGUP    (-73)
#define PGDN    (-81)
#define SINS    (-82)
#define SDEL    (-83)
#define SHOME   (-71)
#define SEND    (-79)
#define SPGUP   (-73)
#define SPGDN   (-81)
#define CINS    (-146)
#define CDEL    (-147)
#define CHOME   (-119)
#define CEND    (-117)
#define CPGUP   (-132)
#define CPGDN   (-118)
#define AINS    (-162)
#define ADEL    (-163)
#define AHOME   (-151)
#define AEND    (-159)
#define APGUP   (-153)
#define APGDN   (-161)
#define F01     (-59)
#define F02     (-60)
#define F03     (-61)
#define F04     (-62)
#define F05     (-63)
#define F06     (-64)
#define F07     (-65)
#define F08     (-66)
#define F09     (-67)
#define F10     (-68)
#define F11     (-133)
#define F12     (-134)
#define SF01    (-84)
#define SF02    (-85)
#define SF03    (-86)
#define SF04    (-87)
#define SF05    (-88)
#define SF06    (-89)
#define SF07    (-90)
#define SF08    (-91)
#define SF09    (-92)
#define SF10    (-93)
#define SF11    (-135)
#define SF12    (-136)
#define CF01    (-94)
#define CF02    (-95)
#define CF03    (-96)
#define CF04    (-97)
#define CF05    (-98)
#define CF06    (-99)
#define CF07    (-100)
#define CF08    (-101)
#define CF09    (-102)
#define CF10    (-103)
#define CF11    (-137)
#define CF12    (-138)
#define AF01    (-104)
#define AF02    (-105)
#define AF03    (-106)
#define AF04    (-107)
#define AF05    (-108)
#define AF06    (-109)
#define AF07    (-110)
#define AF08    (-111)
#define AF09    (-112)
#define AF10    (-113)
#define AF11    (-139)
#define AF12    (-140)
#define ALTA    (-30)
#define ALTB    (-48)
#define ALTC    (-46)
#define ALTD    (-32)
#define ALTE    (-18)
#define ALTF    (-33)
#define ALTG    (-34)
#define ALTH    (-35)
#define ALTI    (-23)
#define ALTJ    (-36)
#define ALTK    (-37)
#define ALTL    (-38)
#define ALTM    (-50)
#define ALTN    (-49)
#define ALTO    (-24)
#define ALTP    (-25)
#define ALTQ    (-16)
#define ALTR    (-19)
#define ALTS    (-31)
#define ALTT    (-20)
#define ALTU    (-22)
#define ALTV    (-47)
#define ALTW    (-17)
#define ALTX    (-45)
#define ALTY    (-21)
#define ALTZ    (-44)
#define ALT1    (-120)
#define ALT2    (-121)
#define ALT3    (-122)
#define ALT4    (-123)
#define ALT5    (-124)
#define ALT6    (-125)
#define ALT7    (-126)
#define ALT8    (-127)
#define ALT9    (-128)
#define ALT0    (-129)
#define DOUB0   (-176)
#define TREB0   (-175)
#define KLSFT   (-174)
#define KRSFT   (-173)
#define KCTRL   (-172)
#define KALT    (-171)
#define PRSCR   (-170)
#define BREAK   (-169)
#define KNUML   (-168)
#define KCAPL   (-167)
#define KSCRL   (-166)
#define LANGSWITCH (-254)
#define EXIT_K  F10
#define ENDCUST F08
#define MODIFY  F09
#define CALC    AF08
#define PICK    ESC
#define VOID    ESC
#define PRINT   SF05

// ------------------------------- KEYDEF.H END --------------------------------

// ------------------------------ SCANCODE.H START ------------------------------

#define LSHIFT      0x01
#define RSHIFT      0x02
#define CTRL        0x04
#define ALT         0x08
#define CAPSL       0x10
#define NUML        0x20
#define SCROLLL     0x40
#define INSL        0x80
#define EXTENDED    0xE0

// ------------------------------- SCANCODE.H END --------------------------------

// ------------------------------ CONFIG.H START ------------------------------

#define MAPSIZE     ((5*128)*sizeof(int))
#define FONTSIZE    (32+(16*256)+(14*256)+256+768)
#define NUMSTORES  20
#define RECUPDATE    0x01 		// record update
#define RECDELETE    0x02 		// record delete
#define FILEUPDATE   0x03 		// file update   - sent by server --+
#define FILETX       0x04 		// file transmit - resp by client --+
#define FILERXDONE   0x05 		// file receive complete  - sent by server --+
#define FILETXDONE   0x06 		// file transmit complete - resp by client --+
#define WHOSTHERE 	 0x87 		// sent by server to find whos on the network
#define NODESTARTUP	 0x08 		// new node startup  - sent by client
#define NODESHUTDOWN 0x09 		// new node shutdown - sent by client
#define USERLOGON	 0x0A		// user logon 		 - sent by client
#define USERLOGOFF	 0x0B		// user logoff		 - sent by client
#define CLSE        (-6)
#define FRST        (-5)
#define LAST        (-4)
#define PREV        (-3)
#define NEXT        (-2)
#define CURR        (-1)
#define MAXDGSIZE   512
#define MAXDGBUFS   80
#define DGRAMACK    0x55AA
#define DGTIMOUT    182
#define DGNUMSEND   4
#define BUFLEN 		0x4000
#define NUMTRXNCB   10
#define OFFICE_N    1           // office name
#define OFFICE_L    2           // office location
#define OFFICE_P    3           // office postcode
#define OFFICE_LD   4           // office last disk generated
#define OFFICE_MON  5           // office money order out number
#define OFFICE_MIN  6           // office money order in number
#define COUNTERPOS  7           // counter position
#define GREGORIAN   0			// Gregorian date format
#define JULIAN      1			// Julian date format
#define HEGIRA      2			// Hegira date format
#define PERSIAN     3			// Persian date format
#define CHINESE     4			// Persian date format
#define GREGYEAR	1980
#define HEGYEAR		1413
#define PERYEAR		1370
#define CHINYEAR	69
#define PERSTART    (4462-365)
#define HEGSTART    4565
#define GREGSTART   0
#define CALCDATE    (-1)        // calculate the date from a number of days
#define LOCDATEL    0           // local date long format
#define LOCDATES    1           // local date short format
#define UKDATE      2           // UK date
#define USDATE      3           // US date
#define TIMES       4           // Time to seconds
#define TIMEM       5           // Time to minutes
#define UKDATEL     6           // UK date 19?? format
#define USDATEL     7           // US date 19?? format
#define MINDATE     8           // DDMMYY
#define MINTIME     9           // HHMMSShh
#define MINDT       10          // DDMMYY-HHMMSS
#define NUMDAYS     11          // NUMBER OF DAYS SINCE 01/01/1980
#define LOCDATEL2   12          // Alternative local date long format
#define STDPRN1			0x00
#define STDPRN2			0x01
#define STDPRN3			0x02
#define STDPRN4			0x03
#define STDAUX1			0x04
#define STDAUX2			0x05
#define STDAUX3			0x06
#define STDAUX4			0x07
#define STANDARD		0x00
#define TRANSLATE		0x10
#define GRAPHIC			0x20
#define MIXED			0x30
extern  int  		   getday       (char *dt);
extern  int  		   getmon       (char *dt);
extern  int  		   getyear      (char *dt);
extern  void 		   orddfrom     (int *y,int *m,int *d);
extern  void 		   orddto       (int *y,int *m,int *d);
extern  char            *datestr     (int type);
extern  unsigned int    datetonum    (char *dt);
extern  int             readconfig   (char *sys);
extern  int 			   readlang		(char *langfile);
extern  int             *readkeys    (void);
extern  int             readoffdet   (void);
extern  int             writeoffdet  (void);
extern  int             setoffdet    (char type,char *det);
extern  int             getoffdet    (char type,char *det);
extern  void 		   clrconfig	(void);
extern  char    *G_cache;
extern  char    *G_system	;
extern  char    *G_moneys;
extern  char    *G_scrname;
extern  char    *G_toname;
extern  char    *G_moneyf;
extern  char    *G_weightf;
extern  char    *G_weights;
extern  char    *G_database;
extern  char    *G_databas2;
extern  char    *G_config;
extern  char    *G_backup;
extern  char    *G_kbdfile;
extern  char    *G_harderr;
extern  char    *G_noacc;
extern  char    *G_nopass;
extern  char    *G_offdets;
extern  char    *G_insertd;
extern  char    *G_newdisk;
extern  char    *G_olddisk;
extern  char    *G_format;
extern  char    *G_formatf;
extern  char    *G_formatok;
extern  char    *G_posierr;
extern  char    *G_stoplist;
extern  char    *G_newdata;
extern  char    *G_revprmt;
extern  char    *G_clrstok;
extern  char    *G_netpath;
extern  char    *G_rupdate;
extern  char    *G_none;
extern  char    *G_name     	;
extern  char    *G_base     	;
extern  char    *G_topline 	;
extern  char    *G_thankyou	;
extern  char    *G_total   	;
extern  char    *G_clerk   	;
extern  char    *G_fupdate;
extern  char    *G_wallpaper;
extern  char    *G_dispwgt	;
extern  char    *G_exact		;
extern  STORESTAT        G_sstat      [NUMSTORES];
extern  char    			G_days       [7][10];
extern  char    			G_mnths      [15][10];
extern  char    			G_globs      [10][80];
extern  char    			G_langfiles	 [10][20];
extern  char    			G_textfile   [80];
extern  char    			G_fontfile   [80];
extern  char             G_fixed[20];
extern  int              G_round;
extern  int              G_roundval;
extern  int              G_keydisk;
extern  int              G_yes;
extern  int              G_no;
extern  int              G_canswitch;
extern  int 				G_intable;
extern  int 				*G_scanmap;
extern  int              G_pagenum;
extern  int              G_numpage;
extern  PTABDAT          G_tb;
extern  unsigned char    G_position;
extern  int              G_scaleout;
extern  unsigned char    G_uid;
extern  unsigned char    G_luid;
extern  unsigned char    G_access;
extern  char             G_upass[5];
extern  char             G_uname[9];
extern  int              G_qnty;
extern  int              G_type;
extern  int              G_error;
extern  int              G_prod;
extern  int              G_loglev;
extern  unsigned char    *G_textspace;
extern  unsigned char    *G_formspace;
extern  unsigned char    *G_langspace;
extern  int              *G_keyspace;
extern  unsigned int     *G_prn;
extern  char             G_dpm[16];
extern  char             G_gdpm[13];
extern  int              G_datetype;
extern  char             G_dateorder[6];
extern  int              G_nummon;
extern  int              G_lang;
extern  int              G_multilang;
extern  int              G_network;
extern  int              G_netok;
extern  int              G_semnet;
extern  char             G_frupd[20];
extern  char             G_dbmap[20];
extern  int              G_finredraw;
extern  int              G_isserver;
extern  int              G_debug;
extern  int              G_numlang;
extern  char    			G_righthand;
extern  char    			G_onlyhot;
extern  unsigned long    G_formloaded;
extern  int              G_exit2top;
extern  int              G_exit2mrk;
extern  int      		G_keybutt	;
extern  int              G_nocache;
extern  int              G_refson;
extern  long             G_sstart 	;
extern  int              G_weighton;
extern  int              G_weightat[3];
extern  int              G_coinon;
extern  int              G_coinat[3];
extern  char				G_formmark;
extern  unsigned char	G_denoms[5];
extern  int 				G_numhopp;
extern  int 				G_scaleact	;
extern  int 				G_scond	  	;
extern  int 				G_srec	  	;
extern  char				G_sfname[10];
extern  char				*G_tflds;

// ------------------------------- CONFIG.H END --------------------------------

// ------------------------------ CONTROL.H START ------------------------------

#define    MY_ALLOC      0x5AA5
extern  void  logerr			(char *e,int l);
extern  void  memerr			(char *e,int l);
extern  void  myfree			(void *buf);
extern  int   memsig         (void *buf);
extern  void  *mymalloc      (size_t size);
extern  void  *myrealloc     (void *block,size_t size);
extern  char  *mystrdup      (const char *s);
extern  void  bde            (char k);
extern  void  funcentry		(int f);
extern  void  funcexit		(void);
extern  unsigned long G_curmem;
extern  unsigned long G_maxblk;
extern  unsigned long G_maxmem;
extern  unsigned long G_numfree;
extern  unsigned long G_nummall;
extern  unsigned long G_numreal;
extern  unsigned long G_numstrd;
extern  			char *bd;
extern  			char *bm;
#define ENTRY(a)
#define RETURN      return
#define RETURNV(a)  return(a)
#define FREE    myfree
#define MALLOC  mymalloc
#define REALLOC myrealloc
#define STRDUP  mystrdup

// ------------------------------- CONTROL.H END --------------------------------

// ------------------------------ MEMORY.H START ------------------------------

extern  int  		isblk(char *name);
extern  int 			setupblk(char *name,unsigned long size);
extern  int  		restblk(char *name,void *ptr);
extern  int 			restpblk(char *name,void *ptr,unsigned long ofs,unsigned int long);
extern  int  		saveblk(char *name,unsigned long size,void *ptr);			;
extern  int 			savepblk(char *name,void *ptr,unsigned long ofs,unsigned int long);
extern  int  		finblk(char *name);
extern  void 	    cleanupblks(int show);
extern  unsigned int blksize(char *name);

// ------------------------------- MEMORY.H END --------------------------------

// ------------------------------ EXTMEM.H START ------------------------------

extern  uint EXMEMinstalled(void);
extern  uint EXMEMalloc(long size);
extern  uint EXMEMfree(uint h);
extern  int  mem2exmem (void *b,uint h,ulong ofs,ulong len);
extern  int  exmem2mem (void *b,uint h,ulong ofs,ulong len);
extern  uint EMSalloc(uint npg);
extern  uint EMSfree(uint h);
extern  uint EMSmove(char *b,uint h,ulong o,ulong l,uint ft);
extern  void *EMSbase(void);
extern  int  EMSpg(uint h,uint lp,uint pp);
extern  int  moveblk(char *b,uint h,ulong o,ulong l,uint ofs,uint ft);

// ------------------------------- EXTMEM.H END --------------------------------

// ------------------------------ FUNCTION.H START ------------------------------

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
extern  void            errorline   (char *e,int type);
extern  int             upfunc      (void);
extern  int             downfunc    (void);
extern  int             exitform    (void);
extern  int             exit2top    (void);
extern  int             exit2mrk    (void);
extern  int             markform    (void);
extern  int             pushbkey    (void);
extern  int             beep        (void);
extern  int             prodlist    (void);
extern  int             userdetails (void);
extern  int             exitkcheck  (void);
extern  int             logtransact (void);
extern  int             putcurinlog (void);
extern  int             getuser     (void);
extern  int             domop       (void);
extern  int             addmop      (void);
extern  int             addlast2    (void);
extern  int             sublast2    (void);
extern  int             getplname    (void);
extern  int             getpname    (void);
extern  int             getuname    (void);
extern  int             tabstuid     (void);
extern  int             tabssuid     (void);
extern  int             cchange      (void);
extern  int             getprod      (int prodcode);
extern  int             setsdate     (void);
extern  int             setstime     (void);
extern  int             logoff       (void);
extern  int             setoname     (void);
extern  int             getoname     (void);
extern  int             setodets     (void);
extern  int             getodets     (void);
extern  int             getscale     (void);
extern  int             scalez       (void);
extern  int             scalenz      (void);
extern  int             scalestab    (void);
extern  int             setctdets    (void);
extern  int             getctdets    (void);
extern  int             getnewdiskno (void);
extern  int             newclerkdisk (void);
extern  int             consolidd    (void);
extern  int             setnewdbm    (void);
extern  int             setnewsys    (void);
extern  int             setnewcfg    (void);
extern  int             setnewoff    (void);
extern  int             blankrest    (void);
extern  int             checkpass    (void);
extern  int             getuserdet   (void);
extern  int             checkpequal  (void);
extern  int             setpassword  (void);
extern  int             reversal     (void);
extern  int 			   zerotran 	(void);
extern  int             backup       (void);
extern  int             inrange      (char *table,char *value);
extern  int             yesno        (void);
extern  int            backoff      (char *name);
extern  int            backon       (char *name);
extern  int            cleanup      (void);
extern  int            daynum       (char *dt);
extern  int            days         (char *datef,char *datet);
extern  char *         duedom       (int day);
extern  char *         duehalf      (char *h1,char *h2);
extern  char *         duequat      (char *q1,char *q2,char *q3,char *q4);
extern  int            fldcmp       (char *a,char *b);
extern  int            getaction    (char prevkey,int key);
extern  int            logprod      (int prodcode);
extern  int            months       (char *datef,char *datet);
extern  int            nearday      (char *datef,char *datet);
extern  int            p4566        (int ix,int nr);
extern  int            proptional   (void);
extern  int            receipt      (void);
extern  unsigned char  rotbyte      (unsigned char b);
extern  int            setupaction  (int prod);
extern  int            sideslip     (void);
extern  int            getl1        (void);
extern  int            getl2        (void);
extern  int            getl3        (void);
extern  int            dispense     (void);
extern  int            coinstat	   (void);
extern  int            payoutcn     (void);
extern  int            getcoins     (void);
extern  int            operdoor     (void);
extern  int            reducecn	   (void);
extern  ACTMAP G_actmap[];
extern  int G_numeks[4];
extern  KEYDEF *G_exitkeys[4];
extern  int G_innext;
extern  int G_edepth;
extern  int G_exitkey;
extern  int G_exit;

// ------------------------------- FUNCTION.H END --------------------------------

// ------------------------------ DST.H START ------------------------------

#define NUMSTORES  20
#define NUMFIELDS  20
#define NUMLIBITEM NUMSTORES*NUMFIELDS
extern  int              loadsdata   (char *sys);
extern  int              savesdata   (char *sys);
extern  int              snum        (char *name);
extern  int              fnum        (char *name,char *fname);
extern  int              knum        (char *name,char *fname);
extern  STORE            *G_store;
extern  LSTOREF          *G_lib;
extern  int              G_nums;
extern  int              G_numl;

// ------------------------------- DST.H END --------------------------------

// ------------------------------ MONEY.H START ------------------------------

extern  char             *addm   	(char *a,char *b);
extern  char             *subm   	(char *a,char *b);
extern  char             *divm   	(char *a,char *b);
extern  char             *mulm   	(char *a,int b);
extern  char             *rndm   	(char *a,int b);
extern  char 			*formatstr	(char *s,char *fmt,int len);
extern  char             *mstr   	(char *val,int len);

// ------------------------------- MONEY.H END --------------------------------

// ------------------------------ ARITH.H START ------------------------------

#define MAXSTRLEN  80
#define NUMB      double
#define ATON      atof
#define NTOA(a,b) sprintf(a,"%0.0f",b)
#define PUSHN(a) push('n',(NUMB)a)
#define PUSHS(a) push('s',a)
#define POP(a)   pop((void *)a)
extern  NUMB  G_n[3];
extern  char  G_s[3][MAXSTRLEN];
#define MAXSTACK   50
extern  STACK  *G_stack        [MAXSTACK];
extern  int     G_nstk;
extern  void    push           (char type,...);
extern  char    pop            (void *var);
extern  char    stktype        (int place);
extern  char    stknum         (int place,NUMB *n);
extern  char    stkstr         (int place,char *s);
extern  int     stksize        (void);
extern  long    popl           (void);
extern  char   *pops           (void);
extern  void    add            (void);
extern  void    sub            (void);
extern  void    mul            (void);
extern  void    land           (void);
extern  void    lor            (void);
extern  void    lxor           (void);
extern  void    lnot           (void);
extern  void    equal          (void);
extern  void    notequal       (void);
extern  void    less           (void);
extern  void    lessequal      (void);
extern  void    great          (void);
extern  void    greatequal     (void);
extern  void    not            (void);
extern  void    neg            (void);
extern  void    sequal         (void);
extern  void    snotequal      (void);
extern  void    sless          (void);
extern  void    slessequal     (void);
extern  void    sgreat         (void);
extern  void    sgreatequal    (void);
extern  void    divide         (void);
extern  void    mod            (void);
extern  void    sjoin          (void);
extern  void    scut           (void);
extern  void    get2strs       (void);
extern  void    get2nums       (void);
extern  void    getnum         (void);
extern  void    getstr         (void);
extern  void    arithend       (void);

// ------------------------------- ARITH.H END --------------------------------

// ------------------------------ GLOBAL.H START ------------------------------

extern       int          findgname (char *n);
extern       int          isglobal  (char *n);
extern       char        *getglobal (int i);
extern       int          setglobal (int i,char *v);
extern       void         printglob (int i);

// ------------------------------- GLOBAL.H END --------------------------------

// ------------------------------ ACTIONS.H START ------------------------------

#define MAXRECURSE   50
extern  int                  loadactions     (char *sys);
extern  void                 freeactions     (void);
extern  int                  runaction       (char *name);
extern  int                  isaction        (char *name);
extern  int                  subaction       (char *name,int depth);
extern  FSAVE                G_savedf        [MAXRECURSE];
extern  int                  G_numsf;
extern  NAMEINDEX            *G_nbuf;
extern  int                  G_numn;
extern  unsigned char 		*G_buff;

// ------------------------------- ACTIONS.H END --------------------------------

// ------------------------------ LANG.H START ------------------------------

extern  void            swaplang     (void);
extern  char 		  *langtext		(int idx);
extern  char 		  *langstr      (char *name,char *s);
extern  void 		  adddevname	(char *n);
extern  void 		  addlangname	(char *n);
extern  void 		  restoreform   (void);
extern  int             justbutt     (PFORM form);

// ------------------------------- LANG.H END --------------------------------

// ------------------------------ MESSAGE.H START ------------------------------

extern  int 		asigndev		(char *name,char *group,char mode);
extern  int 		sendmsg			(char *group,int mtype,...);
extern  int 		initdevices		(void);
extern  void 	closedevices	(void);
extern  void 	prdevlist		(void);
extern  void 	savedevices		(void);
extern  void 	restdevices		(void);
#define OUTGRP  "OUTPUT1"
#define INPGRP  "INPUT1"
#define DISKGRP "DISK1"
#define LANGRP  "LAN1"
#define BDMGRP  "DBM1"
#define OUTMSGBASE   100	
#define OUTINPT     (OUTMSGBASE+ 0)
#define OUTOUTT     (OUTMSGBASE+ 1)
#define OUTATTR     (OUTMSGBASE+ 2)
#define OUTCURS     (OUTMSGBASE+ 3)
#define OUTDBOX     (OUTMSGBASE+ 4)
#define OUTLINE     (OUTMSGBASE+ 5)
#define OUTSXOR     (OUTMSGBASE+ 6)
#define OUTSIZE     (OUTMSGBASE+ 7)
#define OUTLITS     (OUTMSGBASE+ 8)
#define OUT
#define OUTEND	    (OUTMSGBASE+10)
#define OUTLOGO     (OUTMSGBASE+11)
#define OUTSINK     (OUTMSGBASE+12)
#define OUTRAZE     (OUTMSGBASE+13)
#define INMSGBASE    200	
#define ININPUT     (INMSGBASE+ 0)
#define INFLUSH     (INMSGBASE+ 1)
#define IN
#define INEND	    (INMSGBASE+ 3)
#define INHIT	    (INMSGBASE+ 4)
#define INRPLCE     (INMSGBASE+ 5)
#define INPOKE	    (INMSGBASE+ 6)
#define INPEEK	    (INMSGBASE+ 7)
#define INERASE     (INMSGBASE+ 8)
#define INRECRD     (INMSGBASE+ 9)
#define INPLAY	    (INMSGBASE+10)
#define INADKLF     (INMSGBASE+11)
#define INDLKLF     (INMSGBASE+12)
#define DSKMSGBASE   300	
#define DSKCOPYF    (DSKMSGBASE+ 0)
#define DSKGENUF    (DSKMSGBASE+ 1)
#define DSKDELF	    (DSKMSGBASE+ 2)
#define DSKFINDF    (DSKMSGBASE+ 3)
#define DSKSETDI    (DSKMSGBASE+ 4)
#define DSKRETDI    (DSKMSGBASE+ 5)
#define DSKFORMAT   (DSKMSGBASE+ 6)
#define DSKPUTDI    (DSKMSGBASE+ 7)
#define DSKGETDI    (DSKMSGBASE+ 8)
#define DSKNEWDD    (DSKMSGBASE+ 9)
#define DSKDATECK   (DSKMSGBASE+10)
#define DSK
#define DSKEND	    (DSKMSGBASE+12)
#define DBMMSGBASE   400	
#define DBM
#define DBMEXIT     (DBMMSGBASE+ 1)
#define DBMR
#define DBMEXIST    (DBMMSGBASE+ 3)
#define DBMCREAT    (DBMMSGBASE+ 4)
#define DBMDELET    (DBMMSGBASE+ 5)
#define DBMOPEN     (DBMMSGBASE+ 6)
#define DBMCLOSE    (DBMMSGBASE+ 7)
#define DBMCLSAL    (DBMMSGBASE+ 8)
#define DBMNOREC    (DBMMSGBASE+ 9)
#define DBMRECNO    (DBMMSGBASE+10)
#define DBMREAD     (DBMMSGBASE+11)
#define DBMWRITE    (DBMMSGBASE+12)
#define DBMDLREC    (DBMMSGBASE+13)
#define DBMSRCH     (DBMMSGBASE+14)
#define DBMSRCHP    (DBMMSGBASE+15)
#define DBMGET      (DBMMSGBASE+16)
#define DBMBLANK    (DBMMSGBASE+17)
#define DBMEMPTY    (DBMMSGBASE+18)
#define DBMPUT      (DBMMSGBASE+19)
#define DBMDUP      (DBMMSGBASE+20)
#define DBMRMDUP    (DBMMSGBASE+21)
#define DBMDELGP    (DBMMSGBASE+22)
#define DBMFLUSH    (DBMMSGBASE+23)
#define DBMGTREC    (DBMMSGBASE+24)
#define DBMPTREC    (DBMMSGBASE+25)
#define DBMTXREC    (DBMMSGBASE+26)
#define DBMRXREC    (DBMMSGBASE+27)
#define DBMCREC     (DBMMSGBASE+28)
#define DBMGETS     (DBMMSGBASE+29)
#define DBMSETS     (DBMMSGBASE+30)
#define DBMGETC     (DBMMSGBASE+31)
#define DBMSETC     (DBMMSGBASE+32)

// ------------------------------- MESSAGE.H END --------------------------------

// ------------------------------ CALC.H START ------------------------------

extern  char         *proccalc   (void);
extern  void          fincalc    (void);

// ------------------------------- CALC.H END --------------------------------

// ------------------------------ TRANSLOG.H START ------------------------------

#define NUMLOGENT   50
extern  void       displog       (int loglev);
extern  char       *logtotal     (int loglev);
extern  void       voidlog       (int idx);
extern  void       removelogt    (int idx);
extern  void       modlogval     (int idx);
extern  int        add2log       (char *n,char *v,char *a1,char *a2,char *a3);
extern  void       freelog       (void);
extern  int        writetrans    (void);
extern  int        getlog        (void);
extern  int        G_tindex;
extern  TRANSLOG    *G_log; //[NUMLOGENT];
extern  int         G_numt;

// ------------------------------- TRANSLOG.H END --------------------------------

// ------------------------------ FORMHAND.H START ------------------------------

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
extern  int                 savetext           (char *sys);
extern  int                 loadtext           (char *sys);
extern  void                freetext           (void);
extern  long                isform             (char *name);
extern  int                 loadformidx        (PFORM sf,long ofs);
extern  int                 loadform           (PFORM sf);
extern  void                freeform           (PFORM f);
extern  void                orderform          (PFORM f,int type);
extern  int                 addformf           (PFORM f,PFORMF fld);
extern  int                 delformf           (PFORM f,int id);
extern  void                freeformidx        (void);
extern  long                getformidx         (char *name);
extern  int        _cdecl   ficmp              (const void *a,const void *b);
extern  char     		   *fnameidx   		  (long ofs);
extern  int                  G_numidx;
extern  FINDEX               *G_fid;
extern  FORM                 G_form;
extern  char                 **G_text;
extern  char                 **G_tname;
extern  int                  G_tcnt;
extern  int                  G_saved;
extern  char                 G_parea[4];
extern  char                 G_tarea[4];
extern  char                 G_larea[4];
extern  int                  G_fversion;

// ------------------------------- FORMHAND.H END --------------------------------

// ------------------------------ FORMPROC.H START ------------------------------

extern  int 	 _cdecl	   scmp		   (const void *a,const void *b);
extern  char            *textstr    (PFORMF fld);
extern  int             findid      (int id);
extern  int             initform    (PFORM f);
extern  int             runform     (int clear);
extern  void            clrform     (PFORM f);
extern  void            redrawform  (void);
extern  void            updatest    (void);
extern  void            fillform    (PFORM f);
extern  void            fillfields  (PFORM f);
extern  void            srchitem    (PFORMF f);
extern  void 		   prformname  (PFORM f);
extern  void 		   prformref   (PFORMF f);
extern  char            **G_formvars;

// ------------------------------- FORMPROC.H END --------------------------------

// ------------------------------ MENUPROC.H START ------------------------------

extern  void         drawmenu    (void);
extern  int          runmenu     (void);

// ------------------------------- MENUPROC.H END --------------------------------

// ------------------------------ TABPROC.H START ------------------------------

extern  void             tablebdr        (PTABDAT tb);
extern  int              gettabledata    (PTABDAT tb);
extern  void             tabredraw       (PTABDAT tb,int top,int botup,int quick);
extern  int              allto           (PTABDAT tb,int pos);
extern  int              editfield       (PTABDAT tb,int x,int y,int recnum,int fldnum);
extern  void             inputrec        (PTABDAT tb,int x,int y);
extern  void             tableinput      (int id);
extern  int              getflddata      (PTABDAT tb,int i,char *v);
extern  int 				getnumrec		(char *name);
extern  int 				readrecnum		(char *name,int rec);

// ------------------------------- TABPROC.H END --------------------------------

// ------------------------------ FLDPROC.H START ------------------------------

extern   int     prdate      (void);
extern   int     chkfmt      (char t,int k);
extern   void    putcur      (int x,int y,int curpos,int l,int t,int insert,int size,char *s);
extern   void    output      (int x,int y,char *s,int l,int t,int size);
extern   int     inputstr    (int x,int y,char *s,char *fmt);
extern   char   *tstr        (char *s,int l);
extern   char   *dstr        (char *s,int l);
extern   char   *keyname     (int k);

// ------------------------------- FLDPROC.H END --------------------------------

// ------------------------------ REPPROC.H START ------------------------------

extern  int   runreport   (void);

// ------------------------------- REPPROC.H END --------------------------------

// ------------------------------ KBDDEV.H START ------------------------------

extern  DEVHEADER dev_kbd;
extern  volatile unsigned char  G_shiftstat;

// ------------------------------- KBDDEV.H END --------------------------------

// ------------------------------ VFONDEV.H START ------------------------------

extern  DEVHEADER dev_vfon;
extern  DEVHEADER dev_farsi;

// ------------------------------- VFONDEV.H END --------------------------------

// ------------------------------ HERCDEV.H START ------------------------------

extern  DEVHEADER dev_herc;

// ------------------------------- HERCDEV.H END --------------------------------

// ------------------------------ PDXDEV.H START ------------------------------

extern  DEVHEADER dev_pdx;

// ------------------------------- PDXDEV.H END --------------------------------

// ------------------------------ DISKDEV.H START ------------------------------

#define  FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define  DISKPROMPT      "USUN DYSK I NACISNIJ POTWIERDZ"
#define  DISKNAME        "GPA v1.6"
#define I asm
#define DEFAULT_SECTOR_SIZE 512
#define OUT_OF_MEM (-2)
#define OK 0
#define WRITE_PROTECTION 3
#define RESET_NO 7
#define DISK_IO_NO 10

// ------------------------------- DISKDEV.H END --------------------------------

// ------------------------------ PRNDEV.H START ------------------------------

extern  DEVHEADER dev_prn;

// ------------------------------- PRNDEV.H END --------------------------------

// ------------------------------ SCALEDEV.H START ------------------------------

extern  DEVHEADER dev_scale;

// ------------------------------- SCALEDEV.H END --------------------------------

// ------------------------------ MOUSEDEV.H START ------------------------------

extern  DEVHEADER dev_mouse;
extern  DEVHEADER dev_mousecur;

// ------------------------------- MOUSEDEV.H END --------------------------------

// ------------------------------ 8255DEV.H START ------------------------------

extern  DEVHEADER dev_8255;

// ------------------------------- 8255DEV.H END --------------------------------

// ------------------------------ COMMDEV.H START ------------------------------

extern  DEVHEADER dev_comm;

// ------------------------------- COMMDEV.H END --------------------------------

// ------------------------------ STAMPDEV.H START ------------------------------

extern  DEVHEADER dev_stamp;

// ------------------------------- STAMPDEV.H END --------------------------------

// ------------------------------ BILLVDEV.H START ------------------------------

extern  DEVHEADER dev_billv;

// ------------------------------- BILLVDEV.H END --------------------------------

// ------------------------------ CREDTDEV.H START ------------------------------

extern  DEVHEADER dev_credt;

// ------------------------------- CREDTDEV.H END --------------------------------

// ------------------------------ LABELDEV.H START ------------------------------

#define GS                  0x1D
#define ESCAPE              0x1B
#define PRTRDY              0xD0
#define HORIZONTAL_TAB      0x9         // Horizontal Tab of 8 characters
#define NL                  0xA         // Print buffer and go to newline
#define VERTICAL_TAB        0xB         // Vertical Tab in line numbers
#define CR                  13          // Carriage return (same as newline)
#define DBL_WIDE            0xE         // Set double width character mode
#define NO_DBL_WIDE         0xF         // End double width mode
#define RESET               0x10        // Reset to standard character mode
#define GRAPHIC_MODE        0x11        // Print graphic data
#define DBL_HI              0x12        // Start double high printing
#define NO_DBL_HI           0x13        // End double high printing
#define UNDERLINE           0x15        // Select underline printing
#define PAPER_CUT           0x16        // Paper cut command
#define NO_UNDERLINE        0x18        // End underline mode
#define INVERSE             0x1E        // Select inverse print mode
#define NO_INVERSE          0x1F        // End inverse print mode
#define ASCII_DOWNLOAD      "\x1b\x26"  // Download ASCII character(ESC'&')
#define PRINT_BUFFER        "\x1b\x4A"  // Print all data in buffer(ESC'J')
#define SIDE_CHARS          "\x1b\x74"  // Set # of side-writing chars(ESC't')
#define PRINTER_STATUS      "\x1b\x76"  // Get printer status(ESC'v')
#define SIDE_WRITE_MODE     "\x1b\x56"  // Set side write mode(ESC'V')
#define BAR_POSITION        "\x1d\x41"   // Select X position of bar code(GS'A')
#define BAR_HEIGHT          "\x1d\x68"   // Select height of bar code(GS'h')
#define BAR_PRINT           "\x1d\x6b"   // Print bar code(GS'k')
#define MOTOR_ADVANCE       "\x1d\x4b"   // Motor advance 1/3 sec (GS'K')
#define BAR_ORIENT_VERT     "\x1d\x4f\0" // Set bar code to vertical orientation
#define BAR_ORIENT_SIDE     "\x1d\x4f\1" // Set bar code to side print orienta-
#define BAR_SIDE_PASS_1     "\x1d\x52\0" // Print bar code with 1 pass (GS'R'0)
#define BAR_SIDE_PASS_2     "\x1d\x52\1" // Print bar code with 2 pass (GS'R'1)
#define DISABLE_SENSOR      "\x1d\x54"   // Disable ticket sensor (GS'T')
#define BAR_SIZE            "\x1d\x57"   // Select size of barcode lines(GS'W')
#define LP         0x278
#define LP_STAT    (LP+1)
#define LP_CONT    (LP+2)
#define STROBE     0xD
#define NO_STROBE  0xC
#define PRINTER    0x17

// ------------------------------- LABELDEV.H END --------------------------------

// ------------------------------ BGPAHEAD.EXE START ------------------------------


// ------------------------------- BGPAHEAD.EXE END --------------------------------

