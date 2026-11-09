/****************************************************************************
* Project     : GPA
* File        : Gpasizes.h
* Description : This file contains two types of element:
*               1) size information about field lengths and array sizes.
*               2) Constant preset values.
*               It does generally not contain variable preset values.
*               n.b. this file should be included before types.h
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:54  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/gpasizes.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:54   JGRAY
 *  
 * 
 *    Rev 1.0   Oct 20 1995 15:19:58   JGRAY
 *  
* 
****************************************************************************/

#ifndef GPASIZES_H
#define GPASIZES_H
// PUBLIC SYMBOLS S

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

// PUBLIC SYMBOLS E      

#endif //ndef GPASIZES_H
// **************************************************************************
// gpasizes.h <end-of-file>
