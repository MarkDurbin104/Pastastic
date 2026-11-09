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
#define MAPSIZE     ((5*128)*sizeof(int))
#define FONTSIZE    (32+(16*256)+(14*256)+256)
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

PUBLIC char            *datestr     (int type);
PUBLIC int             readconfig   (char *sys);
PUBLIC char            *readfont    (void);
PUBLIC int             *readkeys    (void);
PUBLIC int             readoffdet   (void);
PUBLIC int             writeoffdet  (void);
PUBLIC int             setoffdet    (char type,char *det);
PUBLIC int             getoffdet    (char type,char *det);

PUBLIC char    G_system     [9];
PUBLIC char    G_cache      [4];
PUBLIC char    G_moneys     [10];
PUBLIC char    G_moneyf     [40];
PUBLIC char    G_weights    [10];
PUBLIC char    G_weightf    [40];
PUBLIC char    G_days       [7][10];
PUBLIC char    G_mnths      [12][10];
PUBLIC char    G_database   [80];
PUBLIC char    G_config     [80];
PUBLIC char    G_textfile   [80];
PUBLIC char    G_textfile1  [80];
PUBLIC char    G_textfile2  [80];
PUBLIC char    G_backup     [80];
PUBLIC char    G_fontfile   [80];
PUBLIC char    G_kbdfile    [80];
PUBLIC char    G_scrname    [10];
PUBLIC char    G_harderr    [80];
PUBLIC char    G_noacc      [80];
PUBLIC char    G_nopass     [80];
PUBLIC char    G_offdets    [80];
PUBLIC char    G_insertd    [80];
PUBLIC char    G_newdisk    [80];
PUBLIC char    G_olddisk    [80];
PUBLIC char    G_format     [80];
PUBLIC char    G_formatf    [80];
PUBLIC char    G_formatok   [80];
PUBLIC char    G_posierr    [80];
PUBLIC char    G_stoplist   [80];
PUBLIC char    G_newdata    [80];
PUBLIC char    G_revprmt    [80];
PUBLIC char    G_clrstok    [80];
PUBLIC char    G_netpath    [80];
PUBLIC char    G_fupdate    [80];
PUBLIC char    G_rupdate    [80];
PUBLIC char    G_toname     [17];
PUBLIC char    G_none       [80];
PUBLIC char    G_globs      [10][80];


PUBLIC char             G_fixed[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC int              G_round      INIT(0)
PUBLIC int              G_roundval   INIT(0)
PUBLIC int              G_keydisk    INIT(0)
PUBLIC char             G_yes        INIT('Y')
PUBLIC char             G_no         INIT('N')
PUBLIC int              G_canswitch  INIT(0)
PUBLIC int              G_pagenum    INIT(0)
PUBLIC int              G_numpage    INIT(0)
PUBLIC PTABDAT          G_tb         INIT(NULL)
PUBLIC unsigned char    G_position   INIT(0)
PUBLIC int              G_scaleout   INIT(0)
PUBLIC unsigned char    G_uid        INIT(99)
PUBLIC unsigned char    G_access     INIT(9)
PUBLIC char             G_upass[5]   INIT("\0\0\0\0\0")
PUBLIC char             G_uname[9]   INIT("\0\0\0\0\0\0\0\0\0")
PUBLIC int              G_qnty       INIT(1)
PUBLIC int              G_prod       INIT(0)
PUBLIC int              G_loglev     INIT(0)
PUBLIC int              G_fontwide   INIT(8)
PUBLIC int              G_fonthigh   INIT(14)
PUBLIC unsigned char    *G_fontspace INIT(NULL)
PUBLIC int              *G_keyspace  INIT(NULL)
PUBLIC char             G_dpm[12]    INIT("")
PUBLIC int              G_lang       INIT(0)
PUBLIC int              G_network    INIT(NOTONNET)
PUBLIC int              G_netok      INIT(0)
PUBLIC int              G_semnet     INIT(0)
PUBLIC char             G_frupd[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC int              G_finredraw  INIT(0)
PUBLIC int              G_debug      INIT(0)

// PUBLIC SYMBOLS E

#ifdef CONFIG_C

//------------------------PRIVATE Prototypes & Variables-------------------
#define NUMCONFIG 39

int     G_confread=0;
char    *G_confs[NUMCONFIG]={
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