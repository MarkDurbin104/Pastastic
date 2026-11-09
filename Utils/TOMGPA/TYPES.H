/****************************************************************************
* Project     : GPA
* File        : types.h
* Description : 1) Contains the type definitions for both redeclared standard c
                   and specific GPA structure definitions.
                2) Defines for the message types
* 
* $Revision:   1.2  $  $Date:   Nov 03 1995 11:52:18  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/types.h_v  $
 * 
 *    Rev 1.2   Nov 03 1995 11:52:18   JGRAY
 *  
 * 
 *    Rev 1.1   Nov 01 1995 16:07:12   JGRAY
 *  
* 
****************************************************************************/
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
                         
// PUBLIC SYMBOLS E      

#endif  //  ndef TYPES_H
//*********************************************************************
// types.h  - End of file
