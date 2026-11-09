#ifndef CONFIG_H    // stop multiple includes

#define CONFIG_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif
#ifdef DOIT
#undef DOIT
#endif

#ifdef CONFIG_C
#define PUBLIC
#define INIT(a) =a;
#define DOIT 1
#else
#define PUBLIC extern
#define INIT(a)   ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S
#define MAPSIZE     ((5*128)*sizeof(INT))
#define FONTSIZE    (32+(16*256)+(14*256)+256+768)

#ifndef NUMSTORES
#define NUMSTORES  20
#endif //ndef NUMSTORES

// set top bit if no ACKNOLEDGED required
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

PUBLIC INT  		   getday       (CHAR *dt);
PUBLIC INT  		   getmon       (CHAR *dt);
PUBLIC INT  		   getyear      (CHAR *dt);
PUBLIC void 		   orddfrom     (INT *y,INT *m,INT *d);
PUBLIC void 		   orddto       (INT *y,INT *m,INT *d);
PUBLIC CHAR            *datestr     (INT type);
PUBLIC UINT    datetonum    (CHAR *dt);
PUBLIC INT             readconfig   (CHAR *sys);
PUBLIC INT 			   readlang		(CHAR *langfile);
PUBLIC INT             *readkeys    (void);
PUBLIC INT             readoffdet   (void);
PUBLIC INT             writeoffdet  (void);
PUBLIC INT             setoffdet    (CHAR type,CHAR *det);
PUBLIC INT             getoffdet    (CHAR type,CHAR *det);
PUBLIC void 		   clrconfig	(void);
PUBLIC ULONG   memleft		(void);

PUBLIC CHAR    *G_cache     INIT(NULL) 
PUBLIC CHAR    *G_system	INIT(NULL)
PUBLIC CHAR    *G_moneys    INIT(NULL) 
PUBLIC CHAR    *G_scrname   INIT(NULL) 
PUBLIC CHAR    *G_toname    INIT(NULL) 
PUBLIC CHAR    *G_moneyf    INIT(NULL) 
PUBLIC CHAR    *G_weightf   INIT(NULL) 
PUBLIC CHAR    *G_weights   INIT(NULL) 
PUBLIC CHAR    *G_database  INIT(NULL) 
PUBLIC CHAR    *G_databas2  INIT(NULL) 
PUBLIC CHAR    *G_config    INIT(NULL) 
PUBLIC CHAR    *G_backup    INIT(NULL) 
PUBLIC CHAR    *G_kbdfile   INIT(NULL) 
PUBLIC CHAR    *G_harderr   INIT(NULL) 
PUBLIC CHAR    *G_noacc     INIT(NULL) 
PUBLIC CHAR    *G_nopass    INIT(NULL) 
PUBLIC CHAR    *G_offdets   INIT(NULL) 
PUBLIC CHAR    *G_insertd   INIT(NULL) 
PUBLIC CHAR    *G_newdisk   INIT(NULL) 
PUBLIC CHAR    *G_olddisk   INIT(NULL) 
PUBLIC CHAR    *G_format    INIT(NULL) 
PUBLIC CHAR    *G_formatf   INIT(NULL) 
PUBLIC CHAR    *G_formatok  INIT(NULL) 
PUBLIC CHAR    *G_posierr   INIT(NULL) 
PUBLIC CHAR    *G_stoplist  INIT(NULL) 
PUBLIC CHAR    *G_newdata   INIT(NULL) 
PUBLIC CHAR    *G_revprmt   INIT(NULL) 
PUBLIC CHAR    *G_clrstok   INIT(NULL) 
PUBLIC CHAR    *G_netpath   INIT(NULL) 
PUBLIC CHAR    *G_rupdate   INIT(NULL) 
PUBLIC CHAR    *G_none      INIT(NULL) 
PUBLIC CHAR    *G_name     	INIT(NULL) 
PUBLIC CHAR    *G_base     	INIT(NULL) 
PUBLIC CHAR    *G_topline 	INIT(NULL) 
PUBLIC CHAR    *G_thankyou	INIT(NULL) 
PUBLIC CHAR    *G_total   	INIT(NULL) 
PUBLIC CHAR    *G_clerk   	INIT(NULL) 
PUBLIC CHAR    *G_fupdate   INIT(NULL) 
PUBLIC CHAR    *G_wallpaper INIT(NULL) 
PUBLIC CHAR    *G_dispwgt	INIT(NULL)
PUBLIC CHAR    *G_exact		INIT(NULL)
			   
PUBLIC STORESTAT        G_sstat      [NUMSTORES];
PUBLIC CHAR    			G_days       [7][10];
PUBLIC CHAR    			G_mnths      [15][10];
PUBLIC CHAR    			G_globs      [10][80];
PUBLIC CHAR    			G_langfiles	 [10][20];
PUBLIC CHAR    			G_textfile   [80];
PUBLIC CHAR    			G_fontfile   [80];

PUBLIC CHAR             G_fixed[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_pickkey    INIT(0)
PUBLIC INT              G_round      INIT(0)
PUBLIC INT              G_roundval   INIT(0)
PUBLIC INT              G_keydisk    INIT(0)
PUBLIC INT              G_yes        INIT('Y')
PUBLIC INT              G_no         INIT('N')
PUBLIC INT              G_canswitch  INIT(0)
PUBLIC INT 				G_intable    INIT(0) 
PUBLIC INT 				*G_scanmap   INIT(NULL)
PUBLIC INT              G_pagenum    INIT(0)
PUBLIC INT              G_numpage    INIT(0)
PUBLIC INT              G_tbspace    INIT(0)
PUBLIC PTABDAT          G_tb         INIT(NULL)
PUBLIC UCHAR    G_position   INIT(0)
PUBLIC INT              G_scaleout   INIT(0)
PUBLIC UCHAR    G_uid        INIT(99)
PUBLIC UCHAR    G_luid       INIT(0)
PUBLIC UCHAR    G_access     INIT(9)
PUBLIC CHAR             G_upass[5]   INIT("\0\0\0\0\0")
PUBLIC CHAR             G_uname[9]   INIT("\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_qnty       INIT(1)
PUBLIC INT              G_type       INIT(0)
PUBLIC INT              G_error      INIT(0)
PUBLIC INT              G_prod       INIT(0)
PUBLIC INT              G_loglev     INIT(0)
//PUBLIC UCHAR    *G_textspace INIT(NULL)
PUBLIC UCHAR    *G_formspace INIT(NULL)
PUBLIC UCHAR    *G_langspace INIT(NULL)
PUBLIC INT              *G_keyspace  INIT(NULL)
PUBLIC UINT     *G_prn       INIT(NULL)
PUBLIC CHAR             G_dpm[16]    INIT("   ")
PUBLIC CHAR             G_gdpm[13]   INIT("")
PUBLIC INT              G_datetype   INIT(GREGORIAN)
PUBLIC CHAR             G_dateorder[6] INIT("DMY0 ")
PUBLIC INT              G_nummon     INIT(12)
PUBLIC INT              G_lang       INIT(0)
PUBLIC INT              G_multilang  INIT(0)
PUBLIC INT              G_network    INIT(0)
PUBLIC INT              G_netok      INIT(0)
PUBLIC INT              G_semnet     INIT(0)
PUBLIC CHAR             G_frupd[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC CHAR             G_dbmap[20]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_finredraw  INIT(0)
PUBLIC INT              G_isserver   INIT(0)
PUBLIC INT              G_debug      INIT(0)
PUBLIC INT              G_numlang    INIT(1)
PUBLIC CHAR    			G_righthand  INIT(0)
PUBLIC CHAR    			G_onlyhot    INIT(0)
PUBLIC ULONG    G_formloaded INIT(0L)
PUBLIC INT              G_exit2top   INIT(0)
PUBLIC INT              G_exit2mrk   INIT(0)
PUBLIC INT      		G_keybutt	 INIT(0)
PUBLIC INT              G_nocache    INIT(0)
PUBLIC INT              G_refson     INIT(0)
PUBLIC LONG             G_sstart 	 INIT(0L)
PUBLIC INT              G_weighton   INIT(0)
PUBLIC INT              G_weightat[3];
PUBLIC INT              G_coinon     INIT(0)
PUBLIC INT              G_coinat[3];
PUBLIC CHAR				G_formmark   INIT(0)
PUBLIC UCHAR	G_denoms[5]  INIT("ddddd") // 1,5,10,25,100
PUBLIC INT 				G_numhopp    INIT(5)
PUBLIC INT 				G_scaleact	 INIT(0)
PUBLIC INT 				G_scond	  	 INIT(0)
PUBLIC INT 				G_srec	  	 INIT(0)
PUBLIC INT 				G_elineat  	 INIT(17)
PUBLIC INT 				G_elinecl 	 INIT(1)
PUBLIC INT 				G_elinesz 	 INIT(3)
PUBLIC INT 				G_modified 	 INIT(0)
PUBLIC CHAR 			G_lastval[81] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC CHAR				G_sfname[10] INIT("\0\0\0\0\0\0\0\0\0\0")
PUBLIC CHAR				*G_tflds     INIT(NULL)
PUBLIC INT 				G_tabmoved   INIT(0)
PUBLIC INT 				G_tabmovet   INIT(0)
PUBLIC INT 				G_spacingx   INIT(0)
PUBLIC INT 				G_spacingy   INIT(0)
PUBLIC INT 				G_curtcol    INIT(0)
PUBLIC INT 				G_calcxpos   INIT(40)
PUBLIC INT 				G_calcypos   INIT(3)
PUBLIC INT 				G_calcon	 INIT(0)
PUBLIC INT              G_curpline	 INIT(0)
PUBLIC INT              G_fudgeit 	 INIT(0)
PUBLIC CHAR 			G_curdir[80] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC CHAR 			G_cfgdir[80] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT              G_debon 	 INIT(0)
PUBLIC INT              G_hotkeys    INIT(1)
PUBLIC INT              G_waiting    INIT(0)
PUBLIC INT              G_swapsize   INIT(30)
PUBLIC UCHAR    G_defpal[48];
PUBLIC UCHAR    G_palentry[48]
#ifdef DOIT
= { 
    0x00,0x00,0x00, // 00 00 00
    0x00,0x00,0x2A, // 00 00 42
    0x00,0x2F,0x00, // 00 47 00
    0x00,0x2A,0x2A, // 00 42 42
    0x2A,0x00,0x00, // 42 00 00
    0x2A,0x00,0x2A, // 42 00 42
    0x2A,0x23,0x00, // 42 35 00
    0x2D,0x2D,0x2D, // 45 45 45
    0x00,0x00,0x15, // 00 00 21
    0x00,0x00,0x3F, // 00 00 63
    0x00,0x2B,0x15, // 00 43 21
    0x00,0x27,0x3F, // 00 39 63
    0x2A,0x00,0x15, // 42 00 21
    0x23,0x00,0x3F, // 35 00 63
    0x2A,0x34,0x15, // 42 52 21
    0x2A,0x2B,0x3F} // 42 43 63
#endif
;
// PUBLIC SYMBOLS E

#ifdef CONFIG_C

//------------------------PRIVATE Prototypes & Variables-------------------
#define NUMCONFIG 61

INT     G_confread=0;
CHAR    *G_confs[NUMCONFIG]={
    "SYSTEM"  ,"CACHE"   ,"MONEY"   ,"WEIGHT"  ,"DAYS"    ,"MONTHS"  ,  
    "DATABASE","CONFIG"  ,"LANG"    ,"BACKUP"  ,"FONT"    ,"SCREEN"  ,
    "KEYBOARD","HARDERR" ,"NOACCESS","NOPASS"  ,"OFFICE"  ,"INSERTD" ,
    "NEWDISK" ,"OLDDISK" ,"FORMAT"  ,"FORMATF" ,"FORMATOK","YES-NO"  ,
    "POSIERR" ,"STOPLIST","KEYDISK" ,"NEWDATA" ,"TEXT"    ,"REVPROMP",
    "ROUNDTO" ,"CLRSTOK" ,"NETWORK" ,"NETPATH" ,"RUPDATE" ,"FUPDATE",
    "TONAME"  ,"DEBUG"   ,"NONE" 	,"NAME"	   ,"BASE"	  ,"DATETYPE",
	"SERVER"  ,"TOPLINE" ,"THANKYOU","TOTAL"   ,"CLERK"   ,"ONLYHOT",
	"DBM2"	  ,"REFSON"	 ,"WALLPAPR","WEIGHTAT","COINAT"  ,"DENOMS",
	"EXACT"   ,"DISPWGT" ,"ERRORLAT","CALCAT"  ,"DEBON"   ,"PALETTE",
    "SWAPSIZE"
};

OFFICED G_office;

#endif  //  def CONFIG_C

#endif  //  ndef CONFIG_H
