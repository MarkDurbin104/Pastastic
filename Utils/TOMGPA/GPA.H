// ------------------------------ GPASIZES.H START ------------------------------


#define NUMDEV 50           /* maximum */

#define LENOFKEYFUNC 9      /* Maximum of 8 + delim function name */
#define LENOFFIELDFUNC 9     /* Maximum of 8 + delim function name */
// The above two should match logically? :JGQ

#define LENOFFIELDNAME 9    /* Maximum of 8 + delim form field name */
#define LENOFFIELDTYPE 9    /* Maximum of 8 + delim form field type */
#define LENOFFIELDITEM 60    /* Max of 59 chars + delim for table id etc. */
#define LENOFFIELDFMT 40    /* Max of 39 chars + delim for input format */

#define LENOFFORMNAME 9        /* Maximum of 8 + 1 delim form name */

#define LENOFTLDESC 21        /* Max of 20 + delim textual description */
#define LENOFVALUE 16        /* Max of 15 + delim for value */
#define LENOFDATE 9             /* Date is DD-MM-YY + delim */
#define LENOFTIME 12            /* Time is HH:MM:SS:hs + delim */
#define ADDFIELDSQ 6            /* Number of additional fields in translog */
#define LENOFADDFIELD 36    /* Length of each add field is 35 + delim */

#define TEXTITEMQ 20            /* Max qty of text items */
#define FIELDITEMQ 20        /* Max qty of field items */
#define TABLECOLQ 20            /* Max qty of columns in a table */

#define LENOFDEVNAME 10        /* Device name 9 ch + delim */
#define LENOFDEVGROUP 10    /* Device group name 9 ch + delim */

#define LENOFDSNAME 9         /* Data store name length 8 + delim */
#define DSITEMLISTQ 32        /* Data store item list length */

#define SSFIELDQ 32            /* Paradox file max no. of fields in record */
#define LENSSNAME 9            /* Length of store stats name 8 + delim */

#define LENOFACTNAME 9        /* Len of action name 8 + delim */

#define MEMSTOREQ 32            /* No. of entries in the memstore space and map */


#define NUMSTORES  32      /* Size of storestat array */

#define NUMFIELDS  20

#define NUMLIBITEM NUMSTORES*NUMFIELDS

#define LENOFDEVTABLE 30   /* no. of items to be found in dev table. WRONG SHOULD BE 50 :JGQ i.e. NUMDEV */

#define LENOFFUNCTIONSTACK 1000     /* Length of function stack for debug mode */

#define NODAYS 7                    /* No. of days in days names array */
#define NOMONTHS 15                 /* No. of months in months names array */
#define NOGLOBS 10                  /* No. of variables in globals array */
#define NOLANGS 10                  /* No. of entries in languages array */
#define NUMBERLANGS 10

#define LENOFTFNAME 80              /* length of file containing text string */
#define LENOFFFNAME 80              /* Length of file containing font string */
#define FIXEDPRICEQ 20              /* Max Qty of Fixed prices for products */
#define LENOFDOW 10                 /* Max Length of each day of week incl delim */
#define LENOFMON 10                 /* Max len of month name incl delim */
#define LENOFGLOB 80                /* Max len of global var incl delim */
#define LENOFLANG 20                /* Max len of language incl delim */
#define LENOFPFS 81                 /* len of str incl delim to display for pfacing*/
#define LENOFLANGLINE 161           /* size of temp store for language line */
#define LENOFDENOM 5                /* No. of coin denom sets 5 seems a bit small to me :JGQ*/
#define LENOFUPW 5                  /* Length of user password incl delim */
#define LENOFUNAME 9                /* Length of user name incl delim */
#define LENOFPDEF 20                /* Length of printer def field */
#define DAYPMQ 16                   /* size of days per month array */
#define DEFDAYPMQ 13                /* size of default days per month array */
#define LENOFDTO 6                  /* size of Date Order global string incl delim */
#define LENOFLASTVAL 81             /* size of last value string incl delim */
#define LENOFSFN 10                 /* size of secondary search field name */
#define LENOFTSN 10                 /* size of current store name attached to table field */
#define LENOFTFN 10                 /* size of current store field name attached to table field */
#define LENOFPALETTE 48             /* size of palette */
#define LENOFRECLN 20               /* Len of store name bieng accessed */
#define LENOFRECLF 20               /* Len of list of field numbers in search */
#define LENOFGAS 80                 /* Length of global string alsosel */
#define NUMCONFIG 70

#define LENOFAFN 80                 /* Size of Action file name (path + filename *I.DAT)*/
#define MINIXBQ 81                  /* Minimum size acceptable for a name index buffer */

#define MAXRECURSE 25               /* size of Global FSAVE type array */

#define SOUNDER "SOUNDER"           /* Env variable checked for to set initial sound state */

#define MAXSTRLEN  80               /* arith defined before SHOULD PROBABLY BE 81 :JGQ 23/10 */
#define MAXSTACK   50               /* no. of items in arith stack max */
#define LENOFSTACKITEM 81           /* arith stack item length */
#define SKIPPTOKATTR 8              /* ptok attrib during skip operation */
#define SKIPPTOKRATTR 10            /* value rest to - not convinced - see use :JGQ 23/10 */
#define LENOFSTATFNAME 90           /* Size of filename to be written in savestatic */
#define STATICFILE "STATFILE.GPA"   /* static file name */
#define LENOFSTATRBUF 91            /* Length of buffer for stat file read */
#define LENINPUTSBUF 1000           /* Len of input stream buffer */
#define LENOFPUBSLINE 256           /* Len of buffer to read pubs line into */
#define MAXHOT          50
#define LANGUAGESQ 10
#define LENOFLANGNAME 10
#define LENOFDEVICE 10
#define MAXNOOFDEVS 30
#define MAXGVARS 50                 /* No. of Global variables */


// ------------------------------- GPASIZES.H END --------------------------------

// ------------------------------ TYPES.H START ------------------------------



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
#ifndef __WINDOWS_H                 /* prevent multiple includes */
typedef signed   long  LONG;        // define to be 32 bits
#endif
typedef unsigned char  UCHAR;       // define to be  8 bits unsigned
typedef unsigned short UINT16;      // define to be 16 bits unsigned
typedef unsigned int   UINT;        // define to be 32 bits unsigned
typedef unsigned long  ULONG;       // define to be 32 bits unsigned
#endif

typedef LONG (*DFPTR)(INT,void *);  // device function ptr, i.e. control
typedef INT (*FPTR)(void);          // action function ptr
typedef CHAR *(*TFPTR)(CHAR *);     // No longer used
typedef INT (*QSPTR)(const void*, const void*); // qsort() function ptr

typedef struct {                    // Screen attributes
    UCHAR attr;                     // current character attribute
    UCHAR size;                     // current character size
    UCHAR xor;                      // whether written to in xor or not. TRUE is xor
} SCRATTR;

typedef struct {                    // location
    UCHAR x;
    UCHAR y;
} XYPNT;

typedef struct {                    // box
    XYPNT   tl;                     // top left
    XYPNT   br;                     // bottom right
} WIN;

typedef struct {                    // Form index (used for searching)
    CHAR name[9];                   // FINDEX structure not used:JGQ
    LONG index;
} FINDEX;

typedef struct {                    // product key definition (used within serve engine)
    INT prod;                       // product code
    INT key;                        // key press to select
    CHAR func[LENOFKEYFUNC];        // associated action
    INT  access;                    // privilege level
} KEYDEF;

typedef struct {                    // Form Field Structure
    CHAR     name[LENOFFIELDNAME];  // field name
    CHAR     type[LENOFFIELDTYPE];  // field type
    UCHAR    ident;                 // unique field identifier
    XYPNT    pos;                   // x/y co-ordinates
    CHAR     attrib;                // field attributes
    UCHAR    size;                  // field size
    INT16    class;                 // item classification
    CHAR     func[LENOFFIELDFUNC];  // validation function
    CHAR     item[LENOFFIELDITEM];  // item (store.field or table identifiers or text name)
    CHAR     fmt[LENOFFIELDFMT];    // input format (format or table border sizes)
} FORMF;
typedef FORMF   *PFORMF;            // Pointer to Form Field Structure

typedef struct {                    // Form Structure
   CHAR     name[LENOFFORMNAME];    // form name
   UCHAR    numitem;                // the number of items
   INT16    access;                 // form access level
   WIN      bounds;                 // form boundaries
   INT16    type;                   // form type
   CHAR     attribs;                // form attributes 
   INT16    curitem;                // the current item selected
   PFORMF   items;                  // the list of items in order of display
   } FORM;
typedef FORM    *PFORM;             // Pointer to Form Structure

typedef struct {
    INT         idx;                // 2        index, specifies grouping of transactions
    CHAR         desc[LENOFTLDESC]; // 21        textual description of product
    CHAR         val[LENOFVALUE];   // 16        total value
    CHAR         aval[LENOFVALUE];  // 16        actual value
    INT          round;             // 2        rounding applied
    INT          qty;               // 2        quantity
    INT          prod;              // 2        product code
    CHAR         date[LENOFDATE];   // 9           DD-MM-YY
    CHAR         time[LENOFTIME];   // 12          HH:MM:SS.hs
    CHAR         a[ADDFIELDSQ][LENOFADDFIELD]; // 108 additional fields, use is transaction dependant
} TRANSLOG;                         // 170

typedef struct {
    XYPNT      pos;                 // top left hand corner
    INT        id;                  // unique identifier
    INT        numf;                // number of table fields
    CHAR       depth;               // depth of first or all columns (if no modification)
    CHAR       width;               // total width in characters (including copies & separators)
    CHAR       cols;                // number of sets of columns
    CHAR       type;                // type of table - border, no border, titles, no titles
    INT        tid[TEXTITEMQ];      // identifiers of all text items
    INT        fid[FIELDITEMQ];     // identifiers of all fields
    INT        fwid[TABLECOLQ];     // field width for each table column
    UCHAR      sn;                  // store number
    UCHAR      fn[TABLECOLQ];       // field numbers
    CHAR       cd[TABLECOLQ];       // column depths for modified columns
   UCHAR        disponly;           // set to true if the table only contains display fields
} TABDAT;
typedef TABDAT *PTABDAT;

typedef struct {                    // action map, gpa.c, function.c
    CHAR        *name;
    FPTR        func;               // ptr to function
// INT         savescr;             // whether action modifies screen
// INT         access;              // access privilege
} ACTMAP;
typedef ACTMAP *PACTMAP;

/*  Not used
typedef struct {
    CHAR    name[9];
    INT     numact;
    INT     savescr;
    INT     access;
    CHAR    *nlist;
    CHAR    *tlist;
} ACTION;
typedef ACTION *PACTION;
*/

typedef struct {                    // saved forms
    CHAR         name[LENOFFORMNAME];// form name
    CHAR         mark;              // for exit2mark
    INT         item;               // current field
    INT         nitem;              // number of fields
    CHAR         **vars;            // ptr to ptr to variables
    CHAR         *tflds;            // ptr to default table fields
} FSAVE;

typedef FSAVE *PFSAVE;

#define DEVSIG  0xDEF1CE00L         // signature for finding devices at
                                    // the start and end of the device header.


typedef struct {                    // Device header
    ULONG     sig1;                 // signature
    CHAR      *ownership;           // copyright notice
    CHAR      *type;                // type of device
    CHAR      *name;                // device name
    CHAR      *usage;               // which messages it can recieve (not fully implemented)
    FPTR      input;                // not currently used
    FPTR      output;               // not currently used
    DFPTR     control;              // ptr to control function
    FPTR      reset;                // not currently used
    ULONG     sig2;                 // end signature
} DEVHEADER;

typedef struct {                    // Device group mapping
    CHAR         iu;                // in use flag
    CHAR         n[LENOFDEVNAME];   // name
    CHAR         g[LENOFDEVGROUP];  // group of device
    DEVHEADER    *d;                // ptr to it's device header
} DEVTABLE;

#ifdef INCLOFFICED
typedef struct {                    // Office details (to be removed)
    INT          set;               // set to 1 for disk updated
    CHAR         name[40];          // office name
    CHAR         loc[80];           // office location
    CHAR         postc[20];         // office post code
    CHAR         lastd[11];         // last disk generated
    CHAR         mon[11];           // money order out number
    CHAR         min[11];           // money order in number
    CHAR         cpos[5];           // counter position
} OFFICED;      
#endif

typedef struct {                    // Data dictionary field reference
    CHAR     name[LENOFFIELDNAME];  // field name
    CHAR     type;                  // e.g. A,X,9.....
    UCHAR    len;                   // length of field
} LSTOREF;
typedef LSTOREF *PLSTOREF;

typedef struct {                    // datastore
    CHAR        name[LENOFDSNAME];  // name of datastore set
    ULONG       key;                // primary key - bit field (limits to 32 fields)
    ULONG       skey;               // secondary key bit field
    UCHAR       numitem;            // number of fields in the datastore
    INT16       li[DSITEMLISTQ];    // list of items - refernces LSTOREF structures
} STORE;
typedef STORE *PSTORE;

typedef struct {                    // Store status - volatile information
    CHAR       name[LENSSNAME];     // name
    INT        open;                // 0 closed, lowest number is oldest opened, 1 to G_swapsize
    INT        modified;            // dirty flag
    INT        err;                 // last error condition (0 is OK, see Paradox manual for the rest)
    UINT       handle;              // Paradox TABLEHANDLE 
    UINT       rec;                 // Paradox RECORDHANDLE
    CHAR*      buf;                 // internal current record buffer
    UINT       len;                 // length of the record buffer
    UINT       fofs[SSFIELDQ];      // field offsets of the fields
} STORESTAT;
typedef STORESTAT *PSTORESTAT;

typedef struct {                    // Keyboard loop function
   INT          pri;                // function priority 1=maximum 9999=minimum - number of ticks between executions
   INT          num;                // number of times added
   INT          lt;                 // last tick, i.e.number of ticks since last execution
   CHAR         td;                 // to do, i.e. execution to be performed
   CHAR         bd;                 // being done, i.e. currently executing
   FPTR         func;               // function to call
} KLOOPFUNC;

typedef struct {                    // action name array
    CHAR      d;                    // debug flag
    CHAR      t;                    // type , i.e. table, action , variable or static
    CHAR      n[LENOFACTNAME];      // name
    ULONG      o;                   // offset in the buffer
    UCHAR     *b;                   // tokens or variable buffer
} NAMEINDEX;

typedef struct {                    // list of actions and their index (used for finding in search)
    CHAR         n[LENOFACTNAME];   // name of action
    INT          i;                 // index
} NAMEBUFFER;

/*                     not used
typedef struct 
    {                               // item on stack
    CHAR t;                         // type
    union 
        {
        double n;
        CHAR   s[80];
        } u;
} STACK;
*/

// ---------------------------- MESSAGE TYPES --------------------------------
#define MESSAGE_0        0x0001     /* */
#define MESSAGE_1        0x0002     /* */
#define MESSAGE_QUEST    0x0003     /* */
#define MESSAGE_TEXT     0x0004     /* OYTPUT1/2: display field item at x,y */
#define MESSAGE_A        0x0005     /* KBD: Add key loop function, PRN, SCRN: Set attribute */
#define MESSAGE_AN       0x0006     /* OUTPUT1: Animate image */
#define MESSAGE_b        0x0007     /* DBM: blank the record buffer in table 'name' SCRN: draw a bar */
#define MESSAGE_B        0x0008     /* Draw box */
#define MESSAGE_bp       0x0009     /* DBM: primary search table for list of record numbers - no totalling */
#define MESSAGE_bs       0x000A     /* DBM: secondary generate record number list either for all recs or for matching recs */
#define MESSAGE_BT       0x000B     /* SCRN: Button */
#define MESSAGE_c        0x000C     /* DBM:close table */
#define MESSAGE_C        0x000D     /* Get count from device  DISK: copies a file DBM:Create table SCRN: draw a cursor of length num at x,y KBD: Get next key from buffer but don't pop it */
#define MESSAGE_ca       0x000E     /* DBM: close all tables */
#define MESSAGE_CC       0x000F     /* */
#define MESSAGE_CD       0x0010     /* */
#define MESSAGE_CH       0x0011     /* KBD: Check hot key then run kbd loop funcs */
#define MESSAGE_CI       0x0012     /* */
#define MESSAGE_CL       0x0013     /* */
#define MESSAGE_cr       0x0014     /* DBM: copy record */
#define MESSAGE_CT       0x0015     /* */
#define MESSAGE_D        0x0016     /* device DISK - Delete temporary datastore / file DBM:Delete table SCRN: Draw logo KBD: Delete key loop function */
#define MESSAGE_d        0x0017     /* op sys control set sound delay provided not nosound mode DISK: comp file dates DBM: duplicate specified table*/
#define MESSAGE_DA       0x0018     /* SCRN: Deanimate */
#define MESSAGE_DC       0x0019     /* OUTPUT4: Dispense */
#define MESSAGE_dg       0x001A     /* DBM: delete records matching group */
#define MESSAGE_dr       0x001B     /* DBM: delete record */
#define MESSAGE_E        0x001C     /* PRN: Exit call - printer shutdown COM: release port DISK: clears find file memory list DBM: shutdown database KBD: shutdown */
#define MESSAGE_e        0x001D     /* DBM:End read */
#define MESSAGE_f        0x001E     /* DBM: flush modified buffers */
#define MESSAGE_F        0x001F     /* PRN: print form and set reset flag DISK:Format disk SCRN: read font KBD: Flush */
#define MESSAGE_FH       0x0020     /* KBD: someone has hit a key */
#define MESSAGE_g        0x0021     /* DBM:get field by name */
#define MESSAGE_G        0x0022     /* DISK: Get disk info */
#define MESSAGE_GA       0x0023     /* */
#define MESSAGE_GC       0x0024     /* OUTPUT4: Get coinage and return total */
#define MESSAGE_GP       0x0025     /* SCRN: Get RGB palette */
#define MESSAGE_GS       0x0026     /* Get status (e.g. of printer ) */
#define MESSAGE_H        0x0027     /* KBD: someone is hitting a key */
#define MESSAGE_HD       0x0028     /* KBD: Hotkey description */
#define MESSAGE_HN       0x0029     /* KBD: Hotkey name */
#define MESSAGE_I        0x002A     /* initialize device - for e.g. can carry baud rate info COM:init port DISK: init DBM: initialize database KBD: startup */
#define MESSAGE_i        0x002B     /* KBD: input a single character PRN:initialization for serial printers COM:input a string */
#define MESSAGE_in       0x002C     /* COM: input a string */
#define MESSAGE_K        0x002D     /* INPUT1: remove or add hotkey action */
#define MESSAGE_L        0x002E     /* SCRN: Draw line  / Print a line */
#define MESSAGE_l        0x002F     /* */
#define MESSAGE_md       0x0030     /* DBM: move a field from one table/field to another */
#define MESSAGE_MI       0x0031     /* */
#define MESSAGE_MS       0x0032     /* PRN: Set micro space */
#define MESSAGE_MY       0x0033     /* PRN: Move to Y */
#define MESSAGE_N        0x0034     /* DISK:Set up new disk info data SCRN: is new */
#define MESSAGE_NH       0x0035     /* KBD: No. of hotkeys */
#define MESSAGE_NL       0x0036     /* set numlock (1=on) KBD: update flags in real mode */
#define MESSAGE_NONE     0x0037     /* */
#define MESSAGE_nr       0x0038     /* DBM: Number of records */
#define MESSAGE_O        0x0039     /* COM: output null delim string with checkstat on. DBM:Open table*/
#define MESSAGE_o        0x003A     /* output text to device (e.g. screen or printer) can be formatted (e.g. x,y, fmt, params) */
#define MESSAGE_od       0x003B     /* ditto */
#define MESSAGE_OD       0x003C     /* OUTPUT4: Operate door */
#define MESSAGE_OF       0x003D     /* PRN: Output Form Feed */
#define MESSAGE_Ol       0x003E     /* Output fixed length string with check stat off */
#define MESSAGE_OL       0x003F     /* PRN:Output line feed */
#define MESSAGE_On       0x0040     /* Series of print control commands. COM: output delim string with no checkstat on */
#define MESSAGE_ON       0x0041     /* */
#define MESSAGE_p        0x0042     /* op sys control print string to screen. DBM: put field by name */
#define MESSAGE_P        0x0043     /* SCRN: Paint at x,y a bitmap.  PDF:now try this :-wow! COM: rx string with DLE preceeds STX.ETX and allows multiple timeouts DISK:Put disk info KBD: Push key into buffer */
#define MESSAGE_PH       0x0044     /* KBD: Push key into buffer - hot key ignored */
#define MESSAGE_PO       0x0045     /* Output4: Pay out */
#define MESSAGE_PS       0x0046     /* */
#define MESSAGE_qg       0x0047     /* DBM: get field by number */
#define MESSAGE_qp       0x0048     /* DBM: put field by number */
#define MESSAGE_r        0x0049     /* DBM:goto and read rec from table ,  DISK:file(s) rename. SCRN: raise a field */
#define MESSAGE_R        0x004A     /* Reset device e.g. PRN DISK:Get disk info. SCRN:reset KBD: Remove last key in buffer */
#define MESSAGE_RA       0x004B     /* guess Ring Alarms */
#define MESSAGE_RB       0x004C     /* */
#define MESSAGE_RC       0x004D     /* OUTPUT4: Reduce money counter by quantity */
#define MESSAGE_rd       0x004E     /* DBM: remove specified duplicate with optional keep */
#define MESSAGE_RI       0x004F     /* DBM:Reinitialize database / DEV: Reinitialize device KBD: reinit SCRN: reinit */
#define MESSAGE_RK       0x0050     /* KBD: Run keyboard loop functions */
#define MESSAGE_rn       0x0051     /* DBM: return current record number in table */
#define MESSAGE_RP       0x0052     /* PRN:  print form, no reset. DBM: Relative position +/- (no code) */
#define MESSAGE_rt       0x0053     /* KBD: reset exit ticker */
#define MESSAGE_s        0x0054     /* op sys control make sound provided not nosound mode DISK:swaps filenames set a for set b by renaming through TEMPSWAP DBM:search table (secondary) FRST, NEXT, CLOSEST. SCRN:sink a field*/
#define MESSAGE_S        0x0055     /* PRN:set Global printer size DISK: Set disk info SCRN:font size */
#define MESSAGE_S1       0x0056     /* Set (stamp) device to printer 1 */
#define MESSAGE_S2       0x0057     /* Set (stamp) device to printer 2 */
#define MESSAGE_SA       0x0058     /* Safe alarms set / unset */
#define MESSAGE_SC       0x0059     /* SCRN: Rotate image */
#define MESSAGE_SE       0x005A     /* COM:Start up exit NOT CODED */
#define MESSAGE_SI       0x005B     /* COM: start up init NOT CODED */
#define MESSAGE_sp       0x005C     /* DBM:search table (primary) where 'mode' is FRST,NEXT,CLOSEST */
#define MESSAGE_SP       0x005D     /* Test printer status.  SCRN: Set palette */
#define MESSAGE_T        0x005E     /* Test disk for file SCRN: Translate */
#define MESSAGE_tc       0x005F     /* KBD: get ticker value */
#define MESSAGE_TE       0x0060     /* KBD: Temp shutdown kbd */
#define MESSAGE_TL       0x0061     /* SCRN: do nothing with a bit map */
#define MESSAGE_tt       0x0062     /* */
#define MESSAGE_U        0x0063     /* DISK: generate user files */
#define MESSAGE_UZ       0x0064     /* Unzip files */
#define MESSAGE_V        0x0065     /* void contents of device */
#define MESSAGE_w        0x0066     /* DBM:write or update record */
#define MESSAGE_x        0x0067     /* DISK: Build linear list of file names that match spec DBM:Check if table exists */
#define MESSAGE_xt       0x0068     /* KBD: setup exit ticker */
#define MESSAGE_Z        0x0069     /* ZIP files INPUT2:Get scale */
#define MESSAGE_TILDI    0x006A     /* */
#define MESSAGE_RO       0x006B     /* SCRN: flip two images */
#define MESSAGE_3        0x006C     /* SCRN: apply bezel */
#define MESSAGE_Fi       0x006D     /* KBD: Fast input (?) */
#define MESSAGE_SS       0x006E     /* Send Sequence KBD: Set SE ticker - not used */
#define MESSAGE_RM       0x006F     /* KBD: Start record (to file) mode read write mode */
#define MESSAGE_EM       0x0070     /* KBD: end record mode */
#define MESSAGE_PM       0x0071     /* KBD: Start record (to file) mode read only mode */
#define MESSAGE_DT       0x0072     /* KBD: set/reset disable till flag */
#define MESSAGE_AA       0x0073     /* */
#define MESSAGE_Bl       0x0074     /* SCRN: blank at x,y length num */
#define MESSAGE_X        0x0075     /* SCRN: XOR current char */
#define MESSAGE_SB       0x0076     /* save bitmap */
#define MESSAGE_ns       0x0077     /* op sys control set no sound mode */
#define MESSAGE_xy       0x0078     /* op sys control goto xy */
#define MESSAGE_cs       0x0079     /* op sys control clear screen */
#define MESSAGE_ta       0x007A     /* op sys control text attributes */
#define MESSAGE_21       0x007B     /* op sys control issue INT 21 */
#define MESSAGE_pc       0x007C     /* op sys control set cmos value */
#define MESSAGE_fm       0x007D     /* op sys control get current amount of free memory - not DPMI32 mode */
#define MESSAGE_PL       0x007E     /* Add quantity to money counter OUTPUT2:generate printer list */       
#define MESSAGE_tp       0x007F     /* DBM: primary generate record number list with totalling either for all recs or for matching recs */
#define MESSAGE_ts       0x0080     /* DBM: secondary generate record number list with totalling either for all recs or for matching recs */
#define MESSAGE_it       0x0081     /* COM: input string from port with ability to set no. of times to timeout */
#define MESSAGE_PR       0x0082     /* DBM: prepare for read of n recs (no code) */
#define MESSAGE_as       0x0083     /* DBM: secondary generate record number list with upper limit on no. of records */
#define MESSAGE_sl       0x0084     /* */
#define MESSAGE_RS       0x0085     /* */
#define MESSAGE_COPY     0x0086     /* DISK: Copy with renamed destination option */
#define MESSAGE_GD       0x0087     /* Get graphics direction */
#define MESSAGE_W        0x0088     /* */
#define MESSAGE_IA       0x0089     /* */
#define MESSAGE_SR       0x008A     /* */
#define MESSAGE_GI       0x008B     /* */
#define MESSAGE_Sa       0x008C     /* */
#define MESSAGE_Ga       0x008E     /* */
#define MESSAGE_RH       0x008D     /* */
#define MESSAGE_GT       0x008F     /* */
#define MESSAGE_PGBLOCK  0x0090     /* Print Graphic Block */
#define MESSAGE_PRINTSCR 0x0091     /* SCRN: print screen */
#define MESSAGE_LOADKEYS 0x0092     /* KBD: load key map */
#define MESSAGE_GETINCAT 0x0093     /* KBD: Get intact time */
#define MESSAGE_SAVESCRN 0x0094     /* SCRN: save screen */
#define MESSAGE_CLRINACT 0x0095     /* KBD: reset intact time to zero */
#define MESSAGE_SAVEREGION 0x0096   /* SCRN: save region */
#define MESSAGE_RESTREGION 0x0097   /* SCRN: restore region */
#define MESSAGE_LINEPLAIN  0x0098   /* Draw a line with no connector shapes */



#define MESSAGE_USER     0x4000        // For user defined messages, MESSAGE_USER + n
                         

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
#define ABS        26 // no longer in use
#define ACOS       27 // no longer in use
#define ASIN       28 // no longer in use
#define ATAN       29 // no longer in use
#define COSH       30 // no longer in use
#define COS        31 // no longer in use
#define EXP        32 // no longer in use
#define LOG10      33 // no longer in use
#define LOGAR      34 // no longer in use
#define ROUND      35 // no longer in use
#define POW10      36 // no longer in use
#define SINH       37 // no longer in use
#define SIN        38 // no longer in use
#define SQRT       39 // no longer in use
#define SQR        40 // no longer in use
#define TANH       41 // no longer in use
#define TAN        42 // no longer in use
#define TRUNC      43 // no longer in use
#define GOTOXY     44 // no longer in use
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
#define HOTKEY    111
#define SETDEV    112
#define SAVEDEV   113
#define RESTDEV   114
#define XTIMER    115
#define SWAPTO    116 // no longer in use
#define RUN       117
#define STEMPTY   118
#define FILECMD   119 // no longer in use
#define SAVESCR   120 // no longer in use
#define USERVAR   121
#define SETUSRVAR 122
#define STATICS   123
#define SETSTATIC 124
#define STATNAME  125
#define PICKKEY   126
#define STDELREC  127
#define TOTALBOX  128 // no longer in use
#define PRLINE    129
#define PREOL     130
#define PREOF     131
#define JUMPTO    132
#define MOVETCUR  133 // no longer in use
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
#define DSEQUAL   152
#define DIVSPEC   153
#define STCLOSE   154
#define CUSTDISP  155
#define APPLYFMT  156
#define STDELETE  157
#define BLDSLIST  158
#define USESLIST  159
#define DRAWTABL  160
#define PRSEQNCE  161
#define USEPRDEF  162
#define BLDTLIST  163
#define FCDCODE   164
#define SWAPKBD   165
#define RUNDUMMY  166
#define MODIFIED  167
#define SAVESTAT  168
#define RESTSTAT  169

// ------------------------------- INSTRUCT.H END --------------------------------

// ------------------------------ KEYNAMES.H START ------------------------------


// ------------------------------- KEYNAMES.H END --------------------------------

// ------------------------------ KEYDEF.H START ------------------------------

#define KEYOFFSET 176
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
#define VOIDK   ESC
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
#define PRNTSCR     0x37
#define EXTENDED    0xE0

// ------------------------------- SCANCODE.H END --------------------------------

// ------------------------------ CONFIG.H START ------------------------------

#define MAPSIZE     ((5*128)*sizeof(INT))             // size of keyboard mapping
#define FONTSIZE    (32+(16*256)+(14*256)+256+768)    // size of the font
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
#define STANDARD    0x00       // Character mode
#define TRANSLATE   0x10       // Character mode with different font order
#define GRAPHIC     0x20       // Use graphics characters
#define MIXED       0x30       // Graphics and translate
extern  INT     getday       (CHAR *dt);
extern  INT     getmon       (CHAR *dt);
extern  INT     getyear      (CHAR *dt);
extern  void    orddfrom     (INT *y,INT *m,INT *d);
extern  void    orddto       (INT *y,INT *m,INT *d);
extern  CHAR    *datestr     (INT type);
extern  UINT    datetonum    (CHAR *dt);
extern  INT     readconfig   (CHAR *sys);
extern  INT     readlang     (INT lang);
extern  INT     *readkeys    (void);
extern  INT     readoffdet   (void);
extern  INT     writeoffdet  (void);
extern  INT     setoffdet    (CHAR type,CHAR *det);
extern  INT     getoffdet    (CHAR type,CHAR *det);
extern  void    clrconfig    (void);
extern  ULONG   memleft      (void);
extern  CHAR    *G_cache;
extern  CHAR    *G_system;
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
extern  CHAR    *G_name;
extern  CHAR    *G_base;
extern  CHAR    *G_topline;
extern  CHAR    *G_thankyou;
extern  CHAR    *G_total;
extern  CHAR    *G_clerk;
extern  CHAR    *G_fupdate;
extern  CHAR    *G_wallpaper;
extern  CHAR    *G_dispwgt;
extern  CHAR    *G_exact;
extern  STORESTAT *G_sstat;
extern  CHAR    G_days       [NODAYS][LENOFDOW];       // Names of days of week;
extern  CHAR    G_mnths      [NOMONTHS][LENOFMON];     // Name of months;
extern  CHAR    G_globs      [NOGLOBS][LENOFGLOB];     // Global variables for actions;
extern  CHAR    G_langfiles  [NOLANGS][LENOFLANG];     // Language files;
extern  CHAR    G_textfile   [LENOFTFNAME];            // File containing text;
extern  CHAR    G_fontfile   [LENOFFFNAME];            // File containing font;
extern  CHAR    G_fixed[FIXEDPRICEQ];
extern  INT     G_pfacing;
extern  INT     G_barcode;
extern  INT     G_porient;
extern  CHAR    G_pfacestr[LENOFPFS];
extern  INT     G_pickkey;
extern  INT     G_round;
extern  INT     G_roundval;
extern  INT     G_keydisk;
extern  INT     G_yes;
extern  INT     G_no;
extern  INT     G_canswitch;
extern  INT     G_intable;
extern  INT     *G_scanmap;
extern  INT     G_pagenum;
extern  INT     G_numpage;
extern  INT     G_tbspace;
extern  PTABDAT G_tb;
extern  UCHAR   G_position;
extern  INT     G_scaleout;
extern  UCHAR   G_uid;
extern  UCHAR   G_luid;
extern  UCHAR   G_access;
extern  CHAR    G_upass[LENOFUPW];
extern  CHAR    G_uname[LENOFUNAME];
extern  CHAR    G_printdef[LENOFPDEF];
extern  INT     G_qnty;
extern  INT     G_type;
extern  INT     G_flag1;
extern  INT     G_error;
extern  INT     G_prod;
extern  INT     G_loglev;
extern  FORM    G_form;
extern  UCHAR   *G_formspace;
extern  CHAR    **G_langspace;
extern  INT     *G_keyspace;
extern  UINT    *G_prn;
extern  CHAR    G_dpm[DAYPMQ];
extern  CHAR    G_gdpm[DEFDAYPMQ];
extern  INT     G_datetype;
extern  CHAR    G_dateorder[LENOFDTO];
extern  INT     G_nummon;
extern  INT     G_lang;
extern  INT     G_multilang;
extern  INT     G_network;
extern  INT     G_netok;
extern  INT     G_semnet;
extern  CHAR    G_frupd[MEMSTOREQ];
extern  CHAR    G_dbmap[MEMSTOREQ];
extern  CHAR    G_msmap[MEMSTOREQ];
extern  INT     G_finredraw;
extern  INT     G_isserver;
extern  INT     L_debug;
extern  INT     *G_debug;
extern  INT     G_numlang;
extern  CHAR    G_righthand;
extern  CHAR    G_onlyhot;
extern  ULONG   G_formloaded;
extern  ULONG   G_actionrun;
extern  INT     G_exit2top;
extern  INT     G_exit2mrk;
extern  INT     G_keybutt;
extern  INT     G_nocache;
extern  INT     G_refson;
extern  LONG    G_sstart;
extern  INT     G_weighton;
extern  INT     G_lastkey;
extern  INT     G_weightat[3];          // x,y postion and font size of weight output;
extern  INT     G_coinon;
extern  INT     G_coinat[3];            // x,y postion and font size of coin output;
extern  CHAR    G_formmark;
extern  UCHAR   G_denoms[LENOFDENOM];
extern  INT     G_numhopp;
extern  INT     G_scaleact;
extern  INT     G_scond;
extern  INT     G_srec;
extern  INT     G_elineat;
extern  INT     G_elinecl;
extern  INT     G_elinesz;
extern  ULONG   G_modified;
extern  CHAR    G_lastval[LENOFLASTVAL];
extern  CHAR    G_sfname[LENOFSFN];
extern  CHAR    G_tabstore[LENOFTSN];
extern  CHAR    G_tabfield[LENOFTFN];
extern  CHAR    *G_tflds;
extern  INT     G_tabmoved;
extern  INT     G_tabmovet;
extern  INT     G_spacingx;
extern  INT     G_spacingy;
extern  INT     G_curtcol;
extern  INT     G_calcxpos;
extern  INT     G_calcypos;
extern  INT     G_calcon;
extern  INT     G_curpline;
extern  INT     G_fudgeit;
extern  CHAR    G_curdir[80];
extern  CHAR    G_cfgdir[80];
extern  INT     G_debon;
extern  INT     G_hotkeys;
extern  INT     G_waiting;
extern  INT     G_swapsize;
extern  INT     G_aerror;
extern  INT     G_marked;
extern  UCHAR   G_defpal[LENOFPALETTE]; // Default palette;
extern  CHAR *  MONOVIDMEM;             // Macro for base address of mono video memory (varies real,protected 32 or 16 bit);
extern  CHAR *  COLVIDMEM;              // Ditto colour;
extern  CHAR *  TEXTVIDMEM;             // Ditto text;
extern  INT16   COLVIDSEG;              // Colour video segment (real & protected 16 bit modes);
extern  LONG *  G_reclist;
extern  INT     G_reclistlen;
extern  INT     G_reclistcur;
extern  CHAR    G_reclistname[LENOFRECLN];// the store name being accessed;
extern  CHAR    G_reclisttype;
extern  CHAR    G_reclistfld[LENOFRECLF];// the field numbers in the search;
extern  INT     G_numrec;
extern  INT     G_cronly;
extern  INT     G_blankoz;
extern  INT     G_printscron;
extern  INT     G_numlockon;
extern  INT     G_movecto;
extern  LONG    G_savescrnto;
extern  LONG *  G_ridxbuf;
extern  CHAR    G_alsosel[LENOFGAS];     // set to a field name prior to a BLDSLIST with '+';
extern  INT     G_changecols;
extern  INT     G_lasthotkey;
extern  INT     G_runningdummy;
extern  INT     G_incalc;
extern  INT     G_calcredraw;
extern  INT     G_incal;
extern  INT     G_calredraw;
extern  INT     G_ctempformtype;
extern  INT     G_needinputredraw;
extern  INT     G_errlast;
extern  UCHAR   G_palentry[LENOFPALETTE];

// ------------------------------- CONFIG.H END --------------------------------

// ------------------------------ CONTROL.H START ------------------------------

#define  MY_ALLOC      0x5AA5
#define  MY_BOUNDCHECK  0x55
extern  void  OUTPB          (INT16 a,CHAR b);
extern  void  OUTPW          (INT16 a,INT16 b);
#define OUTPB outportb
#define OUTPw outportw
extern  void  myfree           (void *buf);
extern  void  *mymalloc        (size_t size);
extern  void  *myrealloc       (void *block,size_t size);
extern  CHAR  *mystrdup        (const CHAR *s);
extern  void  memerr           (CHAR *e);
extern  INT   memsig           (void *buf);
extern  void  bde              (INT k);
extern  void  funcentry        (INT f);
extern  void  funcexit         (void);
extern  ULONG G_curmem;
extern  ULONG G_maxblk;
extern  ULONG G_maxmem;
extern  ULONG G_numfree;
extern  ULONG G_nummall;
extern  ULONG G_numreal;
extern  ULONG G_numstrd;
extern  ULONG G_numfreeerr;
extern  ULONG G_nummallerr;
extern  ULONG G_numrealerr;
extern  ULONG G_numstrderr;
extern  CHAR *bd;
extern  CHAR *bm;
#define ENTRY(a)
#define RETURN      return
#define RETURNV(a)  return(a)
#define FREE    free
#define MALLOC  malloc
#define REALLOC realloc
#define STRDUP  strdup
#define FARMALLOC farmalloc
#define FARFREE farfree

// ------------------------------- CONTROL.H END --------------------------------

// ------------------------------ ACTIONC.H START ------------------------------

#define gettoken(b) (  (UCHAR   )*(b))
#define gettiny(b)  (  (UCHAR   )*(b))
#define getint(b)   (*((UINT16 *) (b)))
#define getlong(b)  (*((ULONG  *) (b)))
#define getdoub(b)  (*((double *) (b)))
#define getstrg(b)  (  (UCHAR  *) (b))
extern  INT                  loadactions     (CHAR *sys);
extern  void                 freeactions     (void);
extern  LONG                 actionofs       (INT idx);
extern  UCHAR                actiontype      (INT idx);
extern  UCHAR                actiondeb       (INT idx);
extern  CHAR *               actionname      (INT idx);
extern  UCHAR *              actionbuf       (INT idx);
extern  void                 setactionbuf    (INT idx,UCHAR *s);
extern  INT                  findname        (CHAR *name);
extern  NAMEINDEX            *G_nbuf;
extern  INT                  G_numn;
extern  NAMEBUFFER           *G_anamebuf;
extern  CHAR                 G_afilename[LENOFAFN];      // action filename (path + filename *I.DAT);
extern  LONG                 G_buffofs;

// ------------------------------- ACTIONC.H END --------------------------------

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
#define ADF4    "addinf4"
#define ADF5    "addinf5"
#define ADF6    "nennwert"
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
extern  INT             zerotran     (void);
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
extern  UCHAR          rotbyte      (UCHAR b);
extern  INT            setupaction  (INT prod);
extern  INT            sideslip     (void);
extern  INT            getl1        (void);
extern  INT            getl2        (void);
extern  INT            getl3        (void);
extern  INT            dispense     (void);
extern  INT            coinstat     (void);
extern  INT            payoutcn     (void);
extern  INT            getcoins     (void);
extern  INT            operdoor     (void);
extern  INT            reducecn     (void);
extern  ACTMAP G_actmap[];
extern  INT G_numeks[4];
extern  KEYDEF *G_exitkeys[4];
extern  INT G_innext;
extern  INT G_edepth;
extern  INT G_exitkey;
extern  INT G_exit;

// ------------------------------- FUNCTION.H END --------------------------------

// ------------------------------ DST.H START ------------------------------

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

extern  CHAR             *addm       (CHAR *a,CHAR *b);
extern  CHAR             *subm       (CHAR *a,CHAR *b);
extern  CHAR             *divm       (CHAR *a,CHAR *b);
extern  CHAR             *mulm       (CHAR *a,INT b);
extern  CHAR             *rndm       (CHAR *a,INT b);
extern  CHAR             *formatstr  (CHAR *s,CHAR *fmt,INT len);
extern  CHAR             *mstr       (CHAR *val,INT len);

// ------------------------------- MONEY.H END --------------------------------

// ------------------------------ ARITH.H START ------------------------------

#define LONGS        // comment out this line for floating point numbers
#define NUMB      LONG
#define ATON      atol
#define NTOA(a,b) ltoa(b,a,10)
#define PUSHN(a) push('n',(NUMB)(a))
#define PUSHS(a) push('s',(NUMB)(a))
#define POP(a)   pop((void *)a)
extern  NUMB  G_n0,G_n1,G_n2;
extern  CHAR  G_s0[MAXSTRLEN];
extern  CHAR  G_s1[MAXSTRLEN];
extern  CHAR  G_s2[MAXSTRLEN];
extern  CHAR    G_stack        [MAXSTACK][LENOFSTACKITEM];
extern  CHAR    L_stackt       [MAXSTACK];
extern  CHAR    *G_stackt;
extern  INT     G_nstk;
extern  void    push           (CHAR type,NUMB v);
extern  CHAR    pop            (void *var);
extern  CHAR    stktype        (INT place);
extern  CHAR    stknum         (INT place,NUMB *n);
extern  CHAR    stkstr         (INT place,CHAR *s);
extern  INT     stksize        (void);
extern  LONG    popl           (void);
extern  CHAR *  pops           (void);
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

extern  INT        runaction       (CHAR *name);
extern  INT        isaction        (CHAR *name);
extern  INT        subaction       (CHAR *name,INT depth);
extern  UCHAR *    isdefstr        (CHAR *s);
extern  void       setstatic       (INT n,CHAR *s);
extern  CHAR *     setvarib        (INT n,CHAR *s);
extern  CHAR *     getvarib        (INT n);
extern  INT        isfcdcode       (ULONG code);
extern  FSAVE      G_savedf        [MAXRECURSE];
extern  INT        G_numsf;
extern  UCHAR      *G_buff;

// ------------------------------- ACTIONS.H END --------------------------------

// ------------------------------ LANG.H START ------------------------------

extern  void           swaplang      (void);
extern  CHAR           *langtext     (INT idx);
extern  CHAR           *langstr      (CHAR *name,CHAR *s);
extern  void           adddevname    (CHAR *n);
extern  void           addlangname   (CHAR *n);
extern  void           restoreform   (void);
extern  INT            justbutt      (PFORM form);

// ------------------------------- LANG.H END --------------------------------

// ------------------------------ MESSAGE.H START ------------------------------

extern  INT      asigndev            (CHAR *name,CHAR *group,CHAR mode);
extern  LONG     sendmsg             (CHAR *group,INT mtype,...);
extern  INT      initdevices         (void);
extern  void     closedevices        (void);
extern  void     prdevlist           (void);
extern  void     savedevices         (void);
extern  void     restdevices         (void);

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
extern  void     freeformidx     (void);
extern  INT      ficmp           (PFORM a,PFORM b);
extern  INT      getformidx      (CHAR *name);
extern  INT      isform          (CHAR *name);
extern  INT      getfedata       (INT ofs,PFORM sf);
extern  INT      loadformidx     (PFORM sf,INT ofs);
extern  INT      loadform        (PFORM sf);
extern  void     freeform        (PFORM f);
extern  void     orderform       (PFORM f,INT type);
extern  INT      loadtext        (CHAR *sys);
extern  CHAR *   atextstr        (INT i);
extern  void     freetext        (void);
extern  INT                  G_numidx;
extern  PFORM               *G_fid;
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

extern  INT      _cdecl       scmp           (const void *a,const void *b);
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
extern  void            prformname  (PFORM f);
extern  void            prformref   (PFORMF f);
extern  CHAR            **G_formvars;

// ------------------------------- FORMPROC.H END --------------------------------

// ------------------------------ MENUPROC.H START ------------------------------

extern  void         drawmenu    (void);
extern  INT          runmenu     (void);
extern  void         menucur     (void);

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
extern  INT              getnumrec       (UCHAR s);
extern  INT              readrecnum      (UCHAR s,INT rec);

// ------------------------------- TABPROC.H END --------------------------------

// ------------------------------ FLDPROC.H START ------------------------------

extern   INT     prdate      (void);
extern   INT     chkfmt      (CHAR t,INT k);
extern   void    putcur      (INT x,INT y,INT curpos,INT l,CHAR *fmt,INT insert,INT size,CHAR *s);
extern   void    output      (INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size,INT attr);
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

// ------------------------------- KBDDEV.H END --------------------------------

// ------------------------------ VFONDEV.H START ------------------------------

extern  DEVHEADER dev_vfon;

// ------------------------------- VFONDEV.H END --------------------------------

// ------------------------------ DISKDEV.H START ------------------------------

#define  FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define LENOFFULLFILEPATH 80
#define LENOFFULLFILEPATHX 100
#define LENOFFNAME 15
#define SEMNET "SEM.NET"
#define BIGBUFQ 32760
#define FCBIGBUFQ 8192
#define ALLOC1BUFFQ 64000U
#define ALLOC2BUFFQ 32000
#define IMPLODEBUFQ 35256U
#define EXPLODEBUFQ 12574
#define COPYSTOREQ 30000
#define CSUMBUFQ 4096+8
#define FLOPPYBMP "FLOPPY.BMP"
#define  DISKPROMPT      "USUN DYSK I NACISNIJ POTWIERDZ"
#define  DISKNAME        "GPA v1.6"
#define I asm
#define DEFAULT_SECTOR_SIZE 512
#define OUT_OF_MEM (-2)
#define OK 0
#define WRITE_PROTECTION 3
#define RESET_NO 7
#define DISK_IO_NO 10
#define FILEATTR FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

// ------------------------------- DISKDEV.H END --------------------------------

// ------------------------------ PDXDEV.H START ------------------------------

extern  DEVHEADER dev_pdx;

// ------------------------------- PDXDEV.H END --------------------------------

// ------------------------------ CAPRNDEV.H START ------------------------------

extern  DEVHEADER dev_prn;
#define PP_DRAFT       0
#define PP_LETTER      1
#define PP_GRAPH       2
#define PP_HIGHG       3

// ------------------------------- CAPRNDEV.H END --------------------------------

// ------------------------------ OSSDEV.H START ------------------------------

extern  void setprotmodeint(void);
extern  DEVHEADER dev_oss;
extern  CHAR *G_criterrscrnbuf;
#define CE_BYTEWIDTH   22    // values to calculate the size of the screen buffer
#define CE_HEIGHT      70
#define CE_XBYTEPOS    25    // X byte position of saved screen area
#define CE_YPOS        215   // Y pixel position of saved screen area

// ------------------------------- OSSDEV.H END --------------------------------

// ------------------------------ COMMDEV.H START ------------------------------

extern  DEVHEADER dev_comm;

// ------------------------------- COMMDEV.H END --------------------------------

