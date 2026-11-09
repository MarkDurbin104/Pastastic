// ------------------------------ TYPES.H START ------------------------------


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
#define PICKKEY   126
#define STDELREC  127
#define TOTALBOX  128
#define PRLINE    129
#define PREOL     130
#define PREOF     131
#define JUMPTO    132
#define MOVETCUR  133
#define RECNUM    134
#define PROMPT    135
#define DAYOFWK   136
#define MOVEPLN   137
#define SENDLINE  138
#define SENDEOL   139
#define PRAGAIN   140
#define SETDSKEY  141
#define RUNCOPY   142
#define RUNSRCH   143
#define DISPHOT   144
#define BLANKREC  145
#define VARARGS   146
#define WAITFLAG  147
#define WAITTEST  148
#define TVARIABLE 149
#define SETTVARIB 150
#define DATESWAP  151

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

#define MAPSIZE     ((5*128)*sizeof(INT))
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
#define CHINESE     4			// Chinese date format
#define GREGYEAR	1980
#define HEGYEAR		1413
#define PERYEAR		1370
#define CHINYEAR	69
#define PERSTART    (4462-365)
#define HEGSTART    4565
#define GREGSTART   0
#define CALCDATE    (-1)        // calculate the date from a number of days
#define LOCDATEL    0           // local date LONG format
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
#define LOCDATEL2   12          // Alternative local date LONG format
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
extern  INT  		   getday       (CHAR *dt);
extern  INT  		   getmon       (CHAR *dt);
extern  INT  		   getyear      (CHAR *dt);
extern  void 		   orddfrom     (INT *y,INT *m,INT *d);
extern  void 		   orddto       (INT *y,INT *m,INT *d);
extern  CHAR            *datestr     (INT type);
extern  UINT    datetonum    (CHAR *dt);
extern  INT             readconfig   (CHAR *sys);
extern  INT 			   readlang		(CHAR *langfile);
extern  INT             *readkeys    (void);
extern  INT             readoffdet   (void);
extern  INT             writeoffdet  (void);
extern  INT             setoffdet    (CHAR type,CHAR *det);
extern  INT             getoffdet    (CHAR type,CHAR *det);
extern  void 		   clrconfig	(void);
extern  ULONG   memleft		(void);
extern  CHAR    *G_cache;
extern  CHAR    *G_system	;
extern  CHAR    *G_moneys;
extern  CHAR    *G_scrname;
extern  CHAR    *G_toname;
extern  CHAR    *G_moneyf;
extern  CHAR    *G_weightf;
extern  CHAR    *G_weights;
extern  CHAR    *G_database;
extern  CHAR    *G_databas2;
extern  CHAR    *G_config;
extern  CHAR    *G_backup;
extern  CHAR    *G_kbdfile;
extern  CHAR    *G_harderr;
extern  CHAR    *G_noacc;
extern  CHAR    *G_nopass;
extern  CHAR    *G_offdets;
extern  CHAR    *G_insertd;
extern  CHAR    *G_newdisk;
extern  CHAR    *G_olddisk;
extern  CHAR    *G_format;
extern  CHAR    *G_formatf;
extern  CHAR    *G_formatok;
extern  CHAR    *G_posierr;
extern  CHAR    *G_stoplist;
extern  CHAR    *G_newdata;
extern  CHAR    *G_revprmt;
extern  CHAR    *G_clrstok;
extern  CHAR    *G_netpath;
extern  CHAR    *G_rupdate;
extern  CHAR    *G_none;
extern  CHAR    *G_name     	;
extern  CHAR    *G_base     	;
extern  CHAR    *G_topline 	;
extern  CHAR    *G_thankyou	;
extern  CHAR    *G_total   	;
extern  CHAR    *G_clerk   	;
extern  CHAR    *G_fupdate;
extern  CHAR    *G_wallpaper;
extern  CHAR    *G_dispwgt	;
extern  CHAR    *G_exact		;
extern  STORESTAT        G_sstat      [NUMSTORES];
extern  CHAR    			G_days       [7][10];
extern  CHAR    			G_mnths      [15][10];
extern  CHAR    			G_globs      [10][80];
extern  CHAR    			G_langfiles	 [10][20];
extern  CHAR    			G_textfile   [80];
extern  CHAR    			G_fontfile   [80];
extern  CHAR             G_fixed[20];
extern  INT              G_pickkey;
extern  INT              G_round;
extern  INT              G_roundval;
extern  INT              G_keydisk;
extern  INT              G_yes;
extern  INT              G_no;
extern  INT              G_canswitch;
extern  INT 				G_intable;
extern  INT 				*G_scanmap;
extern  INT              G_pagenum;
extern  INT              G_numpage;
extern  INT              G_tbspace;
extern  PTABDAT          G_tb;
extern  UCHAR    G_position;
extern  INT              G_scaleout;
extern  UCHAR    G_uid;
extern  UCHAR    G_luid;
extern  UCHAR    G_access;
extern  CHAR             G_upass[5];
extern  CHAR             G_uname[9];
extern  INT              G_qnty;
extern  INT              G_type;
extern  INT              G_error;
extern  INT              G_prod;
extern  INT              G_loglev;
extern  UCHAR    *G_formspace;
extern  UCHAR    *G_langspace;
extern  INT              *G_keyspace;
extern  UINT     *G_prn;
extern  CHAR             G_dpm[16];
extern  CHAR             G_gdpm[13];
extern  INT              G_datetype;
extern  CHAR             G_dateorder[6];
extern  INT              G_nummon;
extern  INT              G_lang;
extern  INT              G_multilang;
extern  INT              G_network;
extern  INT              G_netok;
extern  INT              G_semnet;
extern  CHAR             G_frupd[20];
extern  CHAR             G_dbmap[20];
extern  INT              G_finredraw;
extern  INT              G_isserver;
extern  INT              G_debug;
extern  INT              G_numlang;
extern  CHAR    			G_righthand;
extern  CHAR    			G_onlyhot;
extern  ULONG    G_formloaded;
extern  INT              G_exit2top;
extern  INT              G_exit2mrk;
extern  INT      		G_keybutt	;
extern  INT              G_nocache;
extern  INT              G_refson;
extern  LONG             G_sstart 	;
extern  INT              G_weighton;
extern  INT              G_weightat[3];
extern  INT              G_coinon;
extern  INT              G_coinat[3];
extern  CHAR				G_formmark;
extern  UCHAR	G_denoms[5];
extern  INT 				G_numhopp;
extern  INT 				G_scaleact	;
extern  INT 				G_scond	  	;
extern  INT 				G_srec	  	;
extern  INT 				G_elineat  	;
extern  INT 				G_elinecl 	;
extern  INT 				G_elinesz 	;
extern  INT 				G_modified 	;
extern  CHAR 			G_lastval[81];
extern  CHAR				G_sfname[10];
extern  CHAR				*G_tflds;
extern  INT 				G_tabmoved;
extern  INT 				G_tabmovet;
extern  INT 				G_spacingx;
extern  INT 				G_spacingy;
extern  INT 				G_curtcol;
extern  INT 				G_calcxpos;
extern  INT 				G_calcypos;
extern  INT 				G_calcon	;
extern  INT              G_curpline	;
extern  INT              G_fudgeit 	;
extern  CHAR 			G_curdir[80];
extern  CHAR 			G_cfgdir[80];
extern  INT              G_debon 	;
extern  INT              G_hotkeys;
extern  INT              G_waiting;
extern  INT              G_swapsize;
extern  UCHAR    G_defpal[48];
extern  UCHAR    G_palentry[48];

// ------------------------------- CONFIG.H END --------------------------------

// ------------------------------ CONTROL.H START ------------------------------

#define    MY_ALLOC      0x5AA5
extern  void  logerr			(CHAR *e,INT l);
extern  void  memerr			(CHAR *e,INT l);
extern  void  myfree			(void *buf);
extern  INT   memsig         (void *buf);
extern  void  *mymalloc      (size_t size);
extern  void  *myrealloc     (void *block,size_t size);
extern  CHAR  *mystrdup      (const CHAR *s);
extern  void  bde            (INT k);
extern  void  funcentry		(INT f);
extern  void  funcexit		(void);
extern  ULONG G_curmem;
extern  ULONG G_maxblk;
extern  ULONG G_maxmem;
extern  ULONG G_numfree;
extern  ULONG G_nummall;
extern  ULONG G_numreal;
extern  ULONG G_numstrd;
extern  			CHAR *bd;
extern  			CHAR *bm;
#define ENTRY(a)
#define RETURN      return
#define RETURNV(a)  return(a)
#define FREE    myfree
#define MALLOC  mymalloc
#define REALLOC myrealloc
#define STRDUP  mystrdup

// ------------------------------- CONTROL.H END --------------------------------

// ------------------------------ MEMORY.H START ------------------------------

extern  INT  		isblk(CHAR *name);
extern  INT 			setupblk(CHAR *name,ULONG size);
extern  INT  		restblk(CHAR *name,void *ptr);
extern  INT 			restpblk(CHAR *name,void *ptr,ULONG ofs,ULONG len);
extern  INT  		saveblk(CHAR *name,ULONG size,void *ptr);	;
extern  INT 			savepblk(CHAR *name,void *ptr,ULONG ofs,ULONG len);
extern  INT  		finblk(CHAR *name);
extern  void 	    cleanupblks(INT show);
extern  UINT blksize(CHAR *name);

// ------------------------------- MEMORY.H END --------------------------------

// ------------------------------ EXTMEM.H START ------------------------------

extern  UINT EXMEMinstalled(void);
extern  UINT EXMEMalloc(LONG size);
extern  UINT EXMEMfree(UINT h);
extern  INT  mem2exmem (void *b,UINT h,ULONG ofs,ULONG len);
extern  INT  exmem2mem (void *b,UINT h,ULONG ofs,ULONG len);
extern  UINT EMSalloc(UINT npg);
extern  UINT EMSfree(UINT h);
extern  UINT EMSmove(CHAR *b,UINT h,ULONG o,ULONG l,UINT ft);
extern  void *EMSbase(void);
extern  INT  EMSpg(UINT h,UINT lp);
extern  INT  moveblk(CHAR *b,UINT h,ULONG o,ULONG l,UINT ofs,UINT ft);

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
extern  void            errorline   (CHAR *e,INT type);
extern  INT             upfunc      (void);
extern  INT             downfunc    (void);
extern  INT             endform     (void);
extern  INT             exitform    (void);
extern  INT             exit2top    (void);
extern  INT             exit2mrk    (void);
extern  INT             markform    (void);
extern  INT             pushbkey    (void);
extern  INT             beep        (void);
extern  INT             prodlist    (void);
extern  INT             userdetails (void);
extern  INT             exitkcheck  (void);
extern  INT             logtransact (void);
extern  INT             putcurinlog (void);
extern  INT             getuser     (void);
extern  INT             domop       (void);
extern  INT             addmop      (void);
extern  INT             addlast2    (void);
extern  INT             sublast2    (void);
extern  INT             getplname    (void);
extern  INT             getpname    (void);
extern  INT             getuname    (void);
extern  INT             tabstuid     (void);
extern  INT             tabssuid     (void);
extern  INT             cchange      (void);
extern  INT             getprod      (INT prodcode);
extern  INT             setsdate     (void);
extern  INT             setstime     (void);
extern  INT             logoff       (void);
extern  INT             setoname     (void);
extern  INT             getoname     (void);
extern  INT             setodets     (void);
extern  INT             getodets     (void);
extern  INT             getscale     (void);
extern  INT             scalez       (void);
extern  INT             scalenz      (void);
extern  INT             scalestab    (void);
extern  INT             setctdets    (void);
extern  INT             getctdets    (void);
extern  INT             getnewdiskno (void);
extern  INT             newclerkdisk (void);
extern  INT             consolidd    (void);
extern  INT             setnewdbm    (void);
extern  INT             setnewsys    (void);
extern  INT             setnewcfg    (void);
extern  INT             setnewoff    (void);
extern  INT             blankrest    (void);
extern  INT             checkpass    (void);
extern  INT             getuserdet   (void);
extern  INT             checkpequal  (void);
extern  INT             setpassword  (void);
extern  INT             reversal     (void);
extern  INT 			   zerotran 	(void);
extern  INT             obackup      (void);
extern  INT             inrange      (CHAR *table,CHAR *value);
extern  INT             yesno        (void);
extern  INT             endcust      (void);
extern  INT            backoff      (CHAR *name);
extern  INT            backon       (CHAR *name);
extern  INT            cleanup      (void);
extern  INT            daynum       (CHAR *dt);
extern  INT            days         (CHAR *datef,CHAR *datet);
extern  CHAR *         duedom       (INT day);
extern  CHAR *         duehalf      (CHAR *h1,CHAR *h2);
extern  CHAR *         duequat      (CHAR *q1,CHAR *q2,CHAR *q3,CHAR *q4);
extern  INT            fldcmp       (CHAR *a,CHAR *b);
extern  INT            getaction    (CHAR prevkey,INT key);
extern  INT            logprod      (INT prodcode);
extern  INT            months       (CHAR *datef,CHAR *datet);
extern  INT            nearday      (CHAR *datef,CHAR *datet);
extern  INT            p4566        (INT ix,INT nr);
extern  INT            proptional   (void);
extern  INT            receipt      (void);
extern  UCHAR  rotbyte      (UCHAR b);
extern  INT            setupaction  (INT prod);
extern  INT            sideslip     (void);
extern  INT            getl1        (void);
extern  INT            getl2        (void);
extern  INT            getl3        (void);
extern  INT            dispense     (void);
extern  INT            coinstat	   (void);
extern  INT            payoutcn     (void);
extern  INT            getcoins     (void);
extern  INT            operdoor     (void);
extern  INT            reducecn	   (void);
extern  ACTMAP G_actmap[];
extern  INT G_numeks[4];
extern  KEYDEF *G_exitkeys[4];
extern  INT G_innext;
extern  INT G_edepth;
extern  INT G_exitkey;
extern  INT G_exit;

// ------------------------------- FUNCTION.H END --------------------------------

// ------------------------------ DST.H START ------------------------------

#define NUMSTORES  20
#define NUMFIELDS  20
#define NUMLIBITEM NUMSTORES*NUMFIELDS
extern  INT              loadsdata   (CHAR *sys);
extern  INT              savesdata   (CHAR *sys);
extern  INT              snum        (CHAR *name);
extern  INT              fnum        (CHAR *name,CHAR *fname);
extern  INT              knum        (CHAR *name,CHAR *fname);
extern  STORE            *G_store;
extern  LSTOREF          *G_lib;
extern  INT              G_nums;
extern  INT              G_numl;

// ------------------------------- DST.H END --------------------------------

// ------------------------------ MONEY.H START ------------------------------

extern  CHAR             *addm   	(CHAR *a,CHAR *b);
extern  CHAR             *subm   	(CHAR *a,CHAR *b);
extern  CHAR             *divm   	(CHAR *a,CHAR *b);
extern  CHAR             *mulm   	(CHAR *a,INT b);
extern  CHAR             *rndm   	(CHAR *a,INT b);
extern  CHAR 			*formatstr	(CHAR *s,CHAR *fmt,INT len);
extern  CHAR             *mstr   	(CHAR *val,INT len);

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
extern  CHAR  G_s[3][MAXSTRLEN];
#define MAXSTACK   50
extern  STACK  *G_stack        [MAXSTACK];
extern  INT     G_nstk;
extern  void    push           (CHAR type,...);
extern  CHAR    pop            (void *var);
extern  CHAR    stktype        (INT place);
extern  CHAR    stknum         (INT place,NUMB *n);
extern  CHAR    stkstr         (INT place,CHAR *s);
extern  INT     stksize        (void);
extern  LONG    popl           (void);
extern  CHAR   *pops           (void);
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

extern       INT          findgname (CHAR *n);
extern       INT          isglobal  (CHAR *n);
extern       CHAR        *getglobal (INT i);
extern       INT          setglobal (INT i,CHAR *v);
extern       void         printglob (INT i);

// ------------------------------- GLOBAL.H END --------------------------------

// ------------------------------ ACTIONS.H START ------------------------------

#define MAXRECURSE   25
extern  INT                  loadactions     (CHAR *sys);
extern  void                 freeactions     (void);
extern  INT                  runaction       (CHAR *name);
extern  INT                  isaction        (CHAR *name);
extern  INT                  subaction       (CHAR *name,INT depth);
extern  UCHAR       *isdefstr        (CHAR *s);
extern  void                 setstatic       (INT n,CHAR *s);
extern  CHAR                *setvarib        (INT n,CHAR *s);
extern  CHAR                *getvarib        (INT n);
extern  FSAVE                G_savedf        [MAXRECURSE];
extern  INT                  G_numsf;
extern  NAMEINDEX            *G_nbuf;
extern  INT                  G_numn;
extern  UCHAR 		*G_buff;
extern  CHAR 		        G_afilename[80];
extern  NAMEBUFFER           *G_anamebuf;

// ------------------------------- ACTIONS.H END --------------------------------

// ------------------------------ LANG.H START ------------------------------

extern  void            swaplang     (void);
extern  CHAR 		  *langtext		(INT idx);
extern  CHAR 		  *langstr      (CHAR *name,CHAR *s);
extern  void 		  adddevname	(CHAR *n);
extern  void 		  addlangname	(CHAR *n);
extern  void 		  restoreform   (void);
extern  INT             justbutt     (PFORM form);

// ------------------------------- LANG.H END --------------------------------

// ------------------------------ MESSAGE.H START ------------------------------

extern  INT 		asigndev		(CHAR *name,CHAR *group,CHAR mode);
extern  INT 		sendmsg			(CHAR *group,INT mtype,...);
extern  INT 		initdevices		(void);
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

extern  CHAR         *proccalc   (INT x,INT y);
extern  void          fincalc    (void);

// ------------------------------- CALC.H END --------------------------------

// ------------------------------ TRANSLOG.H START ------------------------------

#define NUMLOGENT   50
extern  void       displog       (INT loglev);
extern  CHAR       *logtotal     (INT loglev);
extern  void       voidlog       (INT idx);
extern  void       removelogt    (INT idx);
extern  void       modlogval     (INT idx);
extern  INT        add2log       (CHAR *n,CHAR *v,CHAR *a1,CHAR *a2,CHAR *a3);
extern  void       freelog       (void);
extern  INT        writetrans    (void);
extern  INT        getlog        (void);
extern  INT        G_tindex;
extern  TRANSLOG    *G_log; //[NUMLOGENT];
extern  INT         G_numt;

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
extern  INT                 savetext           (CHAR *sys);
extern  INT                 loadtext           (CHAR *sys);
extern  void                freetext           (void);
extern  CHAR *              atextstr           (INT i);
extern  LONG                isform             (CHAR *name);
extern  INT                 loadformidx        (PFORM sf,LONG ofs);
extern  INT                 loadform           (PFORM sf);
extern  void                freeform           (PFORM f);
extern  void                orderform          (PFORM f,INT type);
extern  INT                 addformf           (PFORM f,PFORMF fld);
extern  INT                 delformf           (PFORM f,INT id);
extern  void                freeformidx        (void);
extern  LONG                getformidx         (CHAR *name);
extern  INT        _cdecl   ficmp              (const void *a,const void *b);
extern  CHAR     		   *fnameidx   		  (LONG ofs);
extern  INT                  G_numidx;
extern  FINDEX               *G_fid;
extern  FORM                 G_form;
extern  CHAR                 **G_tname;
extern  INT                  G_tcnt;
extern  INT                  G_nut;
extern  INT                  G_saved;
extern  CHAR                 G_parea[4];
extern  CHAR                 G_tarea[4];
extern  CHAR                 G_larea[4];
extern  INT                  G_fversion;

// ------------------------------- FORMHAND.H END --------------------------------

// ------------------------------ FORMPROC.H START ------------------------------

extern  INT 	 _cdecl	   scmp		   (const void *a,const void *b);
extern  CHAR            *textstr    (PFORMF fld);
extern  INT             findid      (INT id);
extern  INT             initform    (PFORM f);
extern  INT             runform     (INT clear);
extern  void            clrform     (PFORM f);
extern  void            redrawform  (void);
extern  void            updatest    (void);
extern  void            fillform    (PFORM f);
extern  void            fillfields  (PFORM f);
extern  void            srchitem    (PFORMF f);
extern  void 		   prformname  (PFORM f);
extern  void 		   prformref   (PFORMF f);
extern  CHAR            **G_formvars;

// ------------------------------- FORMPROC.H END --------------------------------

// ------------------------------ MENUPROC.H START ------------------------------

extern  void         drawmenu    (void);
extern  INT          runmenu     (void);
extern  void 		menucur		(void);

// ------------------------------- MENUPROC.H END --------------------------------

// ------------------------------ TABPROC.H START ------------------------------

extern  void             tablebdr        (PTABDAT tb);
extern  INT              gettabledata    (PTABDAT tb);
extern  void             tabredraw       (PTABDAT tb,INT top,INT botup,INT quick);
extern  INT              allto           (PTABDAT tb,INT pos);
extern  INT              editfield       (PTABDAT tb,INT x,INT y,INT recnum,INT fldnum,INT kp);
extern  void             inputrec        (PTABDAT tb,INT x,INT y);
extern  void             tableinput      (INT id);
extern  INT              getflddata      (PTABDAT tb,INT i,CHAR *v);
extern  INT 				getnumrec		(CHAR *name);
extern  INT 				readrecnum		(CHAR *name,INT rec);

// ------------------------------- TABPROC.H END --------------------------------

// ------------------------------ FLDPROC.H START ------------------------------

extern   INT     prdate      (void);
extern   INT     chkfmt      (CHAR t,INT k);
extern   void    putcur      (INT x,INT y,INT curpos,INT l,CHAR *fmt,INT insert,INT size,CHAR *s);
extern   void    output      (INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size);
extern   INT     inputstr    (INT x,INT y,CHAR *s,CHAR *fmt,INT kp);
extern   CHAR   *tstr        (CHAR *s,INT l);
extern   CHAR   *dstr        (CHAR *s,INT l);
extern   CHAR   *keyname     (INT k);
extern   CHAR   *applyformat (CHAR *s,CHAR *fmt,INT rl);

// ------------------------------- FLDPROC.H END --------------------------------

// ------------------------------ REPPROC.H START ------------------------------

extern  INT   runreport   (void);

// ------------------------------- REPPROC.H END --------------------------------

// ------------------------------ KBDDEV.H START ------------------------------

extern  DEVHEADER dev_kbd;
extern  volatile UCHAR  G_shiftstat;

// ------------------------------- KBDDEV.H END --------------------------------

// ------------------------------ VFONDEV.H START ------------------------------

extern  DEVHEADER dev_vfon;

// ------------------------------- VFONDEV.H END --------------------------------

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
extern  DEVHEADER dev_prn2;
extern  DEVHEADER dev_prn3;
extern  DEVHEADER dev_prn4;
extern  DEVHEADER dev_prn5;
extern  DEVHEADER dev_prn6;
extern  DEVHEADER dev_prn7;
extern  DEVHEADER dev_prn8;
#define PP_DRAFT       0
#define PP_LETTER      1
#define PP_GRAPH       2
#define PP_HIGHG       3

// ------------------------------- PRNDEV.H END --------------------------------

// ------------------------------ PDXDEV.H START ------------------------------

extern  DEVHEADER dev_pdx;

// ------------------------------- PDXDEV.H END --------------------------------

// ------------------------------ BGPAHEAD.EXE START ------------------------------


// ------------------------------- BGPAHEAD.EXE END --------------------------------

// ------------------------------ TYPES.H START ------------------------------

#define DEVSIG  0xDEF1CE00L
#define NUMDEV 50

// ------------------------------- TYPES.H END --------------------------------

