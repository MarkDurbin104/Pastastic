/****************************************************************************
* Project     : GPA
* File        : config.h
* Description : Public global definitions configuring the code and
*               setting up constants.  Date defines and (unused) office details
* 
* $Revision:   1.4  $  $Date:   Nov 13 1995 09:00:50  $  $Author:   TBARTON  $
*
* $Log:   I:/pvcs/gpa/h/config.h_v  $
 * 
 *    Rev 1.4   Nov 13 1995 09:00:50   TBARTON
 * Added global GFLAG1.
 * 
 *    Rev 1.3   Nov 01 1995 16:06:42   JGRAY
 *  
 * 
 *    Rev 1.2   Oct 20 1995 15:16:34   JGRAY
 * Annotations
* 
****************************************************************************/
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
#define DOIT 1	                    // Initialise if include by config.c
#else
#define PUBLIC extern
#define INIT(a)   ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

#define MAPSIZE     ((5*128)*sizeof(INT))             // size of keyboard mapping
#define FONTSIZE    (32+(16*256)+(14*256)+256+768)    // size of the font

// set top bit if no ACKNOLEDGED required
#define RECUPDATE    0x01           // record update
#define RECDELETE    0x02           // record delete
#define FILEUPDATE   0x03           // file update   - sent by server --+
#define FILETX       0x04           // file transmit - resp by client --+
#define FILERXDONE   0x05           // file receive complete  - sent by server --+
#define FILETXDONE   0x06           // file transmit complete - resp by client --+
#define WHOSTHERE    0x87           // sent by server to find whos on the network   
#define NODESTARTUP  0x08           // new node startup  - sent by client
#define NODESHUTDOWN 0x09           // new node shutdown - sent by client
#define USERLOGON    0x0A           // user logon          - sent by client
#define USERLOGOFF   0x0B           // user logoff         - sent by client
#define CLSE        (-6)            // closest record
#define FRST        (-5)            // first    "
#define LAST        (-4)            // last     "
#define PREV        (-3)            // previous "
#define NEXT        (-2)            // next     "
#define CURR        (-1)            // current  "

#define MAXDGSIZE   512             // max datagram size (netbios packet)
#define MAXDGBUFS   80              // maximum datagram buffers
#define DGRAMACK    0x55AA          // datagram acknowledge
#define DGTIMOUT    182             // datagram timeout
#define DGNUMSEND   4               // number of times to resend a datagram
#define BUFLEN      0x4000          // buffer size
#define NUMTRXNCB   10              // number of transmit receive network control blocks

#define GREGORIAN   0               // Gregorian date format
#define JULIAN      1               // Julian date format
#define HEGIRA      2               // Hegira date format
#define PERSIAN     3               // Persian date format
#define CHINESE     4               // Chinese date format

#define GREGYEAR    1980            // Gregorian start year
#define HEGYEAR     1413            // Hegra start year (Saudi)
#define PERYEAR     1370            // Persian start year
#define CHINYEAR    69              // Taiwanese start year

#define PERSTART    (4462-365)      // Persian start days
#define HEGSTART    4565            // Hegra start days
#define GREGSTART   0               // Gregorian start days

#define CALCDATE    (-1)         // calculate the date from a number of days
                                 // returns YYMMDD reorderable
#define LOCDATEL    0            // local date LONG format
#define LOCDATES    1            // local date short format
#define UKDATE      2            // UK date
#define USDATE      3            // US date
#define TIMES       4            // Time to seconds
#define TIMEM       5            // Time to minutes
#define UKDATEL     6            // UK date 19?? format
#define USDATEL     7            // US date 19?? format
#define MINDATE     8            // YYMMDD reorderable
#define MINTIME     9            // HHMMSShh
#define MINDT       10           // DDMMYY-HHMMSS
#define NUMDAYS     11           // NUMBER OF DAYS SINCE 01/01/1980
#define LOCDATEL2   12           // Alternative local date LONG format
#define DEBDATE     13           // Debug
#define NODATE      14           // No date
#define DAYOFWEEK   15           // Day of Week
#define DDMMFORMAT  16           // Day and month only reorderable
#define REVDATE     17           // reverse of MINDATE i.e. DDMMYY format reorderable
#define THOUSAND    1000         // str_day str_month ccyear, hh:mm:ss

#define STDPRN1     0x00         // Port identifiers
#define STDPRN2     0x01  
#define STDPRN3     0x02  
#define STDPRN4     0x03  
#define STDAUX1     0x04  
#define STDAUX2     0x05  
#define STDAUX3     0x06
#define STDAUX4     0x07

                                         // Type of printer
#define STANDARD    0x00       // Character mode
#define TRANSLATE   0x10       // Character mode with different font order
#define GRAPHIC     0x20       // Use graphics characters
#define MIXED       0x30       // Graphics and translate

// CONFIG.C
PUBLIC INT     getday       (CHAR *dt);
PUBLIC INT     getmon       (CHAR *dt);
PUBLIC INT     getyear      (CHAR *dt);
PUBLIC void    orddfrom     (INT *y,INT *m,INT *d);
PUBLIC void    orddto       (INT *y,INT *m,INT *d);
PUBLIC CHAR    *datestr     (INT type);
PUBLIC UINT    datetonum    (CHAR *dt);
PUBLIC INT     readconfig   (CHAR *sys);
PUBLIC INT     readlang     (INT lang);
PUBLIC INT     *readkeys    (void);
#ifdef INCLOFFICED
PUBLIC INT     readoffdet   (void);
PUBLIC INT     writeoffdet  (void);
PUBLIC INT     setoffdet    (CHAR type,CHAR *det);
PUBLIC INT     getoffdet    (CHAR type,CHAR *det);
#endif
PUBLIC void    clrconfig    (void);
PUBLIC ULONG   memleft      (void);

// Global variables
PUBLIC CHAR    *G_cache     INIT(NULL)    // cacheing, ON, OFF, 23 is ON exit to DOS
PUBLIC CHAR    *G_system    INIT(NULL)    // Sytem name (i.e. CAPTURE)
PUBLIC CHAR    *G_moneys    INIT(NULL)    // Money format string, i.e. $
PUBLIC CHAR    *G_scrname   INIT(NULL)    // Screen name from configuration files
PUBLIC CHAR    *G_toname    INIT(NULL)    // Network group send to name
PUBLIC CHAR    *G_moneyf    INIT(NULL)    // Money format
PUBLIC CHAR    *G_weightf   INIT(NULL)    // Weight format
PUBLIC CHAR    *G_weights   INIT(NULL)    // Weight string, i.e. kg
PUBLIC CHAR    *G_database  INIT(NULL)    // database path
PUBLIC CHAR    *G_databas2  INIT(NULL)    // secondary database path
PUBLIC CHAR    *G_config    INIT(NULL)    // Configuration directory
PUBLIC CHAR    *G_backup    INIT(NULL)    // backup path
PUBLIC CHAR    *G_kbdfile   INIT(NULL)    // keyboard file
PUBLIC CHAR    *G_harderr   INIT(NULL)    // TRUE if hardware error
PUBLIC CHAR    *G_noacc     INIT(NULL)    // ACCESS DENIED string
PUBLIC CHAR    *G_nopass    INIT(NULL)    // Invalid password string
PUBLIC CHAR    *G_offdets   INIT(NULL)    // Office details file
PUBLIC CHAR    *G_insertd   INIT(NULL)    // Message  Insert disk..
PUBLIC CHAR    *G_newdisk   INIT(NULL)    // Message  Do you want to format..
PUBLIC CHAR    *G_olddisk   INIT(NULL)    // Message  Do you want to reformat..
PUBLIC CHAR    *G_format    INIT(NULL)    // Message  Format in progress..
PUBLIC CHAR    *G_formatf   INIT(NULL)    // Message  Format failed
PUBLIC CHAR    *G_formatok  INIT(NULL)    // Message  Format OK
PUBLIC CHAR    *G_posierr   INIT(NULL)    // Positon error. Return to position N for data..
PUBLIC CHAR    *G_stoplist  INIT(NULL)    // Message  "Stopped!"
PUBLIC CHAR    *G_newdata   INIT(NULL)    // Message  New data transferred..
PUBLIC CHAR    *G_revprmt   INIT(NULL)    // Message  Reverse transaction?
PUBLIC CHAR    *G_clrstok   INIT(NULL)    // Message  Clear stock Y/N?
PUBLIC CHAR    *G_netpath   INIT(NULL)    // Network path
PUBLIC CHAR    *G_rupdate   INIT(NULL)    // Tables for record update only
PUBLIC CHAR    *G_none      INIT(NULL)    // Message  NONE
PUBLIC CHAR    *G_name      INIT(NULL)    // The NAME of the Language i.e. "ENGLISH"  (unused as yet)
PUBLIC CHAR    *G_base      INIT(NULL)    // The base directory for the configuration (unused as yet)
PUBLIC CHAR    *G_topline   INIT(NULL)    // Receipt ???
PUBLIC CHAR    *G_thankyou  INIT(NULL)    // Message  Thank you
PUBLIC CHAR    *G_total     INIT(NULL)    // Variable to pass/return total value to C funcs
PUBLIC CHAR    *G_clerk     INIT(NULL)    // Clerk name
PUBLIC CHAR    *G_fupdate   INIT(NULL)    // Tables for file update
PUBLIC CHAR    *G_wallpaper INIT(NULL)    // Background bitmap
PUBLIC CHAR    *G_dispwgt   INIT(NULL)    // Whether weights should be permanently displayed on-screen
PUBLIC CHAR    *G_exact     INIT(NULL)    // Message  Uses exact change
PUBLIC STORESTAT *G_sstat   INIT(NULL)                // Store status
PUBLIC CHAR    G_days       [NODAYS][LENOFDOW];       // Names of days of week
PUBLIC CHAR    G_mnths      [NOMONTHS][LENOFMON];     // Name of months
PUBLIC CHAR    G_globs      [NOGLOBS][LENOFGLOB];     // Global variables for actions
PUBLIC CHAR    G_langfiles  [NOLANGS][LENOFLANG];     // Language files
PUBLIC CHAR    G_textfile   [LENOFTFNAME];            // File containing text
PUBLIC CHAR    G_fontfile   [LENOFFFNAME];            // File containing font

                                        // Up to 20 fixed prices for products
PUBLIC CHAR    G_fixed[FIXEDPRICEQ]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT     G_pfacing    INIT(0) // Pre-printed paper to face away (0) or towards (1) when loaded into printer
PUBLIC INT     G_barcode    INIT(0) // BARCODE command in config
PUBLIC INT     G_porient    INIT(0) // Paper orientation - 0=Page Top Down   1=Bottom Down - when loading paper
                                        // String to display for pfacing, porient
PUBLIC CHAR    G_pfacestr[LENOFPFS] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT     G_pickkey    INIT(0)    // Pickey used in tables. Usually ENTER
PUBLIC INT     G_round      INIT(0)    // Rounding off or on
PUBLIC INT     G_roundval   INIT(0)    // Rounding value
PUBLIC INT     G_keydisk    INIT(0)    // Whether key disk facility being used
PUBLIC INT     G_yes        INIT('Y')  // The YES character
PUBLIC INT     G_no         INIT('N')  // The NO character
PUBLIC INT     G_canswitch  INIT(0)    // Set if we can change language
PUBLIC INT     G_intable    INIT(0)    // TRUE whilst in table processing
PUBLIC INT     *G_scanmap   INIT(NULL) // Keyboard scan code mapping
PUBLIC INT     G_pagenum    INIT(0)    // Page number
PUBLIC INT     G_numpage    INIT(1)    // Number of pages
PUBLIC INT     G_tbspace    INIT(0)    // Space between each column of a report table
PUBLIC PTABDAT G_tb         INIT(NULL) // table data
PUBLIC UCHAR   G_position   INIT(0)    // current counter position (synch with G_office)
PUBLIC INT     G_scaleout   INIT(0)    // last reading from scale (-1 for error)
PUBLIC UCHAR   G_uid        INIT(99)   // users id
PUBLIC UCHAR   G_luid       INIT(0)    // last users id
PUBLIC UCHAR   G_access     INIT(9)    // access privilege of current user
PUBLIC CHAR    G_upass[LENOFUPW]     INIT("\0\0\0\0\0")    // users password
PUBLIC CHAR    G_uname[LENOFUNAME]   INIT("\0\0\0\0\0\0\0\0\0")  // users name
PUBLIC CHAR    G_printdef[LENOFPDEF] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT     G_qnty       INIT(1)  // quantity
PUBLIC INT     G_type       INIT(0)  // type
PUBLIC INT     G_flag1      INIT(0)  // flag set/passed from 4GL code
PUBLIC INT     G_error      INIT(0)  // Error
PUBLIC INT     G_prod       INIT(0)  // Last sold product
PUBLIC INT     G_loglev     INIT(0)  // Transaction log level, i.e. group level
PUBLIC FORM    G_form;
PUBLIC UCHAR   *G_formspace INIT(NULL)  // form storage ptr (to be discontinued?)
PUBLIC CHAR    **G_langspace INIT(NULL) // Language files information
PUBLIC INT     *G_keyspace  INIT(NULL)  // Keyboard files space
PUBLIC UINT    *G_prn       INIT(NULL)  // no longer used
PUBLIC CHAR    G_dpm[DAYPMQ] INIT("   ")  // Days per month
PUBLIC CHAR    G_gdpm[DEFDAYPMQ] INIT("")    // Default days per month
PUBLIC INT     G_datetype   INIT(GREGORIAN)    // Date type defaults to Gregorian
PUBLIC CHAR    G_dateorder[LENOFDTO] INIT("DMY0 ")    // Date order (default)
PUBLIC INT     G_nummon     INIT(12)    // Number of months
PUBLIC INT     G_lang       INIT(0)    // Language number
PUBLIC INT     G_multilang  INIT(0)    // TRUE - running multi lingually
PUBLIC INT     G_network    INIT(0)    // Network type
PUBLIC INT     G_netok      INIT(0)    // Whether the network is OK
PUBLIC INT     G_semnet     INIT(0)    // Semaphore network (incomplete)
                                       // file or record update flags
PUBLIC CHAR    G_frupd[MEMSTOREQ]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
                                       // database map flags
PUBLIC CHAR    G_dbmap[MEMSTOREQ]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
                                       // memory store flags
PUBLIC CHAR    G_msmap[MEMSTOREQ]  INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
// This initialisation mechanism leaves no room for variable size? :JGQ
PUBLIC INT     G_finredraw  INIT(0)    // TRUE if table redraw complete
PUBLIC INT     G_isserver   INIT(0)    // TRUE if this is the server of a network
PUBLIC INT     L_debug      INIT(0)    // Flag to say if debug on/off
PUBLIC INT     *G_debug     INIT(&L_debug) // ptr to L_debug at start, modified by real mode part of program
PUBLIC INT     G_numlang    INIT(1)    // Number of languages
PUBLIC CHAR    G_righthand  INIT(0)    // Whether output system is right anchored
PUBLIC CHAR    G_onlyhot    INIT(0)    // TRUE if a form only contains hotkeys or buttons
PUBLIC ULONG   G_formloaded INIT(0L)   // Incremented each time a form is loaded
PUBLIC ULONG   G_actionrun  INIT(0L)   // Incremented each time an action is run
PUBLIC INT     G_exit2top   INIT(0)    // TRUE if we are exiting to top
PUBLIC INT     G_exit2mrk   INIT(0)    // TRUE if we are exiting to mark
PUBLIC INT     G_keybutt     INIT(0)   // The key of the last Button pressed
PUBLIC INT     G_nocache    INIT(0)    // TRUE if cacheing is off
PUBLIC INT     G_refson     INIT(0)    // TRUE if references on
PUBLIC LONG    G_sstart      INIT(0L)  // The starting value of the stack (SP)
PUBLIC INT     G_weighton   INIT(0)    // TRUE if weight on-screen
PUBLIC INT     G_lastkey    INIT(0)    // Last key pressed
PUBLIC INT     G_weightat[3];          // x,y postion and font size of weight output
PUBLIC INT     G_coinon     INIT(0)    // TRUE coin on
PUBLIC INT     G_coinat[3];            // x,y postion and font size of coin output
PUBLIC CHAR    G_formmark   INIT(0)    // TRUE if this form has been marked
PUBLIC UCHAR   G_denoms[LENOFDENOM]  INIT("ddddd")         // US default coin hopper denominations: 1,5,10,25,100
PUBLIC INT     G_numhopp    INIT(5)    // Number of hoppers ??? init to LENOFDENOM:JGQ
PUBLIC INT     G_scaleact   INIT(0)    // TRUE if scale active
PUBLIC INT     G_scond      INIT(0)    // Search condition, 1 primary, 2 secondary, 0 none
PUBLIC INT     G_srec       INIT(0)    // Number of key fields
PUBLIC INT     G_elineat    INIT(17)   // Error line y pos
PUBLIC INT     G_elinecl    INIT(1)    // Error line colour
PUBLIC INT     G_elinesz    INIT(3)    // Error line character size
PUBLIC ULONG   G_modified   INIT(0L)   // TRUE if any datastore has been modified one bit per Store
                                       // Value prior to last input
PUBLIC CHAR    G_lastval[LENOFLASTVAL] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC CHAR    G_sfname[LENOFSFN] INIT("\0\0\0\0\0\0\0\0\0\0")  // secondary search field name
PUBLIC CHAR    G_tabstore[LENOFTSN] INIT("\0\0\0\0\0\0\0\0\0\0") // current store attached to table field       (not yet used)
PUBLIC CHAR    G_tabfield[LENOFTFN] INIT("\0\0\0\0\0\0\0\0\0\0") // current store.field attached to table field (not yet used)
PUBLIC CHAR    *G_tflds     INIT(NULL) // Default table fields
PUBLIC INT     G_tabmoved   INIT(0)    // move table cursor from actions (not yet used)
PUBLIC INT     G_tabmovet   INIT(0)    // move table cursor type (i.e. U=Up D=Down...)  from actions (not yet used)
PUBLIC INT     G_spacingx   INIT(0)    // Spacing for pre-printed forms
PUBLIC INT     G_spacingy   INIT(0)    // Spacing for pre-printed forms
PUBLIC INT     G_curtcol    INIT(0)    // Current table column
PUBLIC INT     G_calcxpos   INIT(40)   // Calculator xpos
PUBLIC INT     G_calcypos   INIT(3)    // Calculator ypos
PUBLIC INT     G_calcon     INIT(0)    // TRUE calculator available
PUBLIC INT     G_curpline   INIT(0)    // Current print line
PUBLIC INT     G_fudgeit    INIT(0)    // Column moved down by one row adjustment
                                       // Current directory
PUBLIC CHAR    G_curdir[80] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
                                       // Configuration directory
PUBLIC CHAR    G_cfgdir[80] INIT("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
PUBLIC INT     G_debon      INIT(0)    // Debug on/off
PUBLIC INT     G_hotkeys    INIT(1)    // TRUE if hotkeys on (default on)
PUBLIC INT     G_waiting    INIT(0)    // TRUE if wait flag (cute dangly mobile) is active
PUBLIC INT     G_swapsize   INIT(10)   // maximum number of open files
PUBLIC INT     G_aerror     INIT(0)    // Action error
PUBLIC INT     G_marked     INIT(0)    // Set if mark placed on current form
PUBLIC UCHAR   G_defpal[LENOFPALETTE]; // Default palette
PUBLIC CHAR *  MONOVIDMEM;             // Macro for base address of mono video memory (varies real,protected 32 or 16 bit)
PUBLIC CHAR *  COLVIDMEM;              // Ditto colour
PUBLIC CHAR *  TEXTVIDMEM;             // Ditto text
PUBLIC INT16   COLVIDSEG;              // Colour video segment (real & protected 16 bit modes)
PUBLIC LONG *  G_reclist    INIT(NULL) // The list of records within a search condition i.e. BLDSLIST
PUBLIC INT     G_reclistlen INIT(0)    // the length of the list
PUBLIC INT     G_reclistcur INIT(0)    // the current record
PUBLIC CHAR    G_reclistname[LENOFRECLN];// the store name being accessed
PUBLIC CHAR    G_reclisttype INIT(0)    // the type i.e. G_scond =1,2 or 3
PUBLIC CHAR    G_reclistfld[LENOFRECLF];// the field numbers in the search
PUBLIC INT     G_numrec      INIT(0)    // total number of records in the store
PUBLIC INT     G_cronly      INIT(0)    // (1) - CR or EXIT key are only means to exit field entry fields, (0)- exit on field completion
PUBLIC INT     G_blankoz     INIT(0)    // (1) - Fill numeric fields of value with blanks rather than 0.00
PUBLIC INT     G_printscron  INIT(0)    // 1=if SHIFT PRINTSCREEN calls print screen 2=if PCX dump 0=nothing
PUBLIC INT     G_numlockon   INIT(0)    // 0=NUML taken from DOS 1=NUML SET 2=NUML CLEAR 
PUBLIC INT     G_movecto     INIT(0)    // move cursor to column in table processing 0=don't move
PUBLIC LONG    G_savescrnto  INIT(0)    // save screen time out in seconds 0=NOSAVE
PUBLIC LONG *  G_ridxbuf     INIT(NULL) // record index buffer for table processing
PUBLIC CHAR    G_alsosel[LENOFGAS];     // set to a field name prior to a BLDSLIST with '+'
PUBLIC INT     G_changecols  INIT(1)    // set to false if BMPPALET is used
PUBLIC INT     G_lasthotkey  INIT(0)    // The Last Hot Key Pressed
PUBLIC INT     G_runningdummy INIT(0)   // TRUE during RUNCOPY command
                                        // Current palette - default values below
PUBLIC INT     G_incalc      INIT(0)    // TRUE if in calculator
PUBLIC INT     G_calcredraw  INIT(0)    // TRUE if calc needs redrawing
PUBLIC INT     G_incal       INIT(0)    // TRUE if in calendar
PUBLIC INT     G_calredraw   INIT(0)    // TRUE if cal needs redrawing
PUBLIC INT     G_ctempformtype INIT(0)  // The actual form type when in the calculator
PUBLIC INT     G_needinputredraw INIT(0)// TRUE if input field needs redrawing
PUBLIC INT     G_errlast     INIT(1)    // TRUE if there was an error last time GPA ran
PUBLIC UCHAR   G_palentry[LENOFPALETTE]
#ifdef DOIT
= { 
    0x00,0x00,0x00, // 0
    0x00,0x00,0x2A, // 1
    0x00,0x2F,0x00, // 2
    0x00,0x2A,0x2A, // 3
    0x2A,0x00,0x00, // 4
    0x2A,0x00,0x2A, // 5
    0x2A,0x23,0x00, // 6
    0x2D,0x2D,0x2D, // 7
    0x10,0x10,0x10, // 8
    0x15,0x1A,0x3F, // 9
    0x15,0x3F,0x15, // 10
    0x15,0x3F,0x3F, // 11
    0x3F,0x15,0x15, // 12
    0x3F,0x0E,0x3F, // 13
    0x3F,0x3F,0x15, // 14
    0x3F,0x3F,0x3F  // 15
}
#endif
;
// PUBLIC SYMBOLS E

#ifdef CONFIG_C

//------------------------PRIVATE Prototypes & Variables-------------------

INT     G_confread=0;            // 1 if configuration file read
CHAR    *G_confs[NUMCONFIG]={
    "SYSTEM"  ,"CACHE"   ,"MONEY"   ,"WEIGHT"  ,"DAYS"    ,"MONTHS"  ,  
    "DATABASE","CONFIG"  ,"LANG"    ,"BACKUP"  ,"FONT"    ,"SCREEN"  ,
    "KEYBOARD","HARDERR" ,"NOACCESS","NOPASS"  ,"OFFICE"  ,"INSERTD" ,
    "NEWDISK" ,"OLDDISK" ,"FORMAT"  ,"FORMATF" ,"FORMATOK","YES-NO"  ,
    "POSIERR" ,"STOPLIST","KEYDISK" ,"NEWDATA" ,"TEXT"    ,"REVPROMP",
    "ROUNDTO" ,"CLRSTOK" ,"NETWORK" ,"NETPATH" ,"RUPDATE" ,"FUPDATE",
    "TONAME"  ,"DEBUG"   ,"NONE"     ,"NAME"   ,"BASE"    ,"DATETYPE",
    "SERVER"  ,"TOPLINE" ,"THANKYOU","TOTAL"   ,"CLERK"   ,"ONLYHOT",
    "DBM2"    ,"REFSON"  ,"WALLPAPR","WEIGHTAT","COINAT"  ,"DENOMS",
    "EXACT"   ,"DISPWGT" ,"ERRORLAT","CALCAT"  ,"DEBON"   ,"PALETTE",
    "SWAPSIZE","MEMSTORE","PRINTER" ,"CRONLY"  ,"BLANKOZ" ,"BARCODE",
    "BMPPALET","PRINTSCR","NUMLOCK" ,"SAVESCRN"
};

#ifdef INCLOFFICED
#define OFFICE_N    1            // office name
#define OFFICE_L    2            // office location
#define OFFICE_P    3            // office postcode
#define OFFICE_LD   4            // office last disk generated
#define OFFICE_MON  5            // office money order out number
#define OFFICE_MIN  6            // office money order in number
#define COUNTERPOS  7            // counter position

OFFICED G_office;    // Office details array of strings
#endif  // def INCLOFFICED

#endif  //  def CONFIG_C

#endif  //  ndef CONFIG_H

// **************************************************************************
// config.h <end-of-file>

