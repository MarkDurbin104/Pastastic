#ifndef CONFIG_H    // stop multiple includes

#define CONFIG_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef CONFIG_C
#define PUBLIC
#define INIT(a) =a;
#else
#define PUBLIC extern
#define INIT(a)   ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define MAPSIZE     ((5*128)*sizeof(INT))
#define FONTSIZE    (32+(16*256)+(14*256)+256+768)
#define RECUPDATE   1
#define FILEUPDATE  2
#define RECDELETE   3

#define OFFICE_N    1           // office name
#define OFFICE_L    2           // office location
#define OFFICE_P    3           // office postcode
#define OFFICE_LD   4           // office last disk generated
#define OFFICE_MON  5           // office money order out number
#define OFFICE_MIN  6           // office money order in number
#define COUNTERPOS  7           // counter position

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

PUBLIC CHAR            *datestr     (INT type);
PUBLIC INT             readconfig   (CHAR *sys);
PUBLIC CHAR            *readfont    (void);
PUBLIC INT             *readkeys    (void);
PUBLIC INT             readoffdet   (void);
PUBLIC INT             writeoffdet  (void);
PUBLIC INT             setoffdet    (CHAR type,CHAR *det);
PUBLIC INT             getoffdet    (CHAR type,CHAR *det);

PUBLIC CHAR    G_system     [9];
PUBLIC CHAR    G_cache      [4];
PUBLIC CHAR    G_moneys     [10];
PUBLIC CHAR    G_moneyf     [40];
PUBLIC CHAR    G_weights    [10];
PUBLIC CHAR    G_weightf    [40];
PUBLIC CHAR    G_days       [7][10];
PUBLIC CHAR    G_mnths      [12][10];
PUBLIC CHAR    G_database   [80];
PUBLIC CHAR    G_config     [80];
PUBLIC CHAR    G_textfile   [80];
PUBLIC CHAR    G_textfile1  [80];
PUBLIC CHAR    G_textfile2  [80];
PUBLIC CHAR    G_backup     [80];
PUBLIC CHAR    G_fontfile   [80];
PUBLIC CHAR    G_kbdfile    [80];
PUBLIC CHAR    G_scrname    [10];
PUBLIC CHAR    G_harderr    [80];
PUBLIC CHAR    G_noacc      [80];
PUBLIC CHAR    G_nopass     [80];
PUBLIC CHAR    G_offdets    [80];
PUBLIC CHAR    G_insertd    [80];
PUBLIC CHAR    G_newdisk    [80];
PUBLIC CHAR    G_olddisk    [80];
PUBLIC CHAR    G_format     [80];
PUBLIC CHAR    G_formatf    [80];
PUBLIC CHAR    G_formatok   [80];
PUBLIC CHAR    G_posierr    [80];
PUBLIC CHAR    G_stoplist   [80];
PUBLIC CHAR    G_newdata    [80];
PUBLIC CHAR    G_revprmt    [80];
PUBLIC CHAR    G_clrstok    [80];
PUBLIC CHAR    G_netpath    [80];
PUBLIC CHAR    G_fupdate    [80];
PUBLIC CHAR    G_rupdate    [80];
PUBLIC CHAR    G_toname     [17];
PUBLIC CHAR    G_none       [80];
PUBLIC CHAR    G_globs      [10][80];


PUBLIC CHAR             G_fixed[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_round      INIT(0)
PUBLIC INT              G_roundval   INIT(0)
PUBLIC INT              G_keydisk    INIT(0)
PUBLIC CHAR             G_yes        INIT('Y')
PUBLIC CHAR             G_no         INIT('N')
PUBLIC INT              G_canswitch  INIT(0)
PUBLIC INT              G_pagenum    INIT(0)
PUBLIC INT              G_numpage    INIT(0)
PUBLIC PTABDAT          G_tb         INIT(NULL)
PUBLIC UCHAR    G_position   INIT(0)
PUBLIC INT              G_scaleout   INIT(0)
PUBLIC UCHAR    G_uid        INIT(99)
PUBLIC UCHAR    G_access     INIT(9)
PUBLIC CHAR             G_upass[5]   INIT("\0\0\0\0\0")
PUBLIC CHAR             G_uname[9]   INIT("\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_qnty       INIT(1)
PUBLIC INT              G_prod       INIT(0)
PUBLIC INT              G_loglev     INIT(0)
PUBLIC INT              G_fontwide   INIT(8)
PUBLIC INT              G_fonthigh   INIT(14)
PUBLIC UCHAR    *G_fontspace INIT(NULL)
PUBLIC INT              *G_keyspace  INIT(NULL)
PUBLIC CHAR             G_dpm[12]    INIT("")
PUBLIC INT              G_lang       INIT(0)
//PUBLIC INT              G_network    INIT(NOTONNET)
PUBLIC INT              G_netok      INIT(0)
PUBLIC INT              G_semnet     INIT(0)
PUBLIC CHAR             G_frupd[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_finredraw  INIT(0)
PUBLIC INT              G_debug      INIT(0)

// PUBLIC SYMBOLS E

#ifdef CONFIG_C

//------------------------PRIVATE Prototypes & Variables-------------------
#define NUMCONFIG 39

INT     G_confread=0;
CHAR    *G_confs[NUMCONFIG]={
    "SYSTEM"  ,"CACHE"   ,"MONEY"   ,"WEIGHT"  ,"DAYS"    ,"MONTHS"  ,  
    "DATABASE","CONFIG"  ,"TEXT1"   ,"BACKUP"  ,"FONT"    ,"SCREEN"  ,
    "KEYBOARD","HARDERR" ,"NOACCESS","NOPASS"  ,"OFFICE"  ,"INSERTD" ,
    "NEWDISK" ,"OLDDISK" ,"FORMAT"  ,"FORMATF" ,"FORMATOK","YES-NO"  ,
    "POSIERR" ,"STOPLIST","KEYDISK" ,"NEWDATA" ,"TEXT2"   ,"REVPROMP",
    "ROUNDTO" ,"CLRSTOK" ,"NETWORK" ,"NETPATH" ,"RUPDATE" ,"FUPDATE",
    "TONAME"  ,"DEBUG"   ,"NONE"
};

OFFICED G_office;

#endif  //  def CONFIG_C

#endif  //  ndef CONFIG_H

