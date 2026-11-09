/****************************************************************************
* Project     : GPA
* File        : capgpa.c
* Description : GPA elements for the direct support of CAPTURE
* 
*
* $Revision:   1.7  $  $Date:   Nov 10 1995 16:30:04  $  $Author:   TBARTON  $
*
* $Log:   I:/pvcs/gpa/c/capgpa.c_v  $
* 
*    Rev 1.7   Nov 10 1995 16:30:04   TBARTON
* Modified builddec to mark transaction entries to
* cadec groups for sorted P&A.
* 
*    Rev 1.6   Nov 03 1995 11:32:46   JGRAY
* Annotations
* 
*    Rev 1.4   Oct 17 1995 16:24:26   TBARTON
* Chenged decslist to use addinf2 field. Addinf3 is used for addlists.
* Change is inconjunction with update to CAPDEC to rev 1.5
* 
*    Rev 1.3   Oct 13 1995 16:34:46   TBARTON
* Version changed to 5.3test. Hook function added.
* Major rewrite of decslist function. This change is in parallel with
* changes to CAPDEC.DAT rev 1.4
*
****************************************************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <io.h>
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "realprot.h"
#include "gpa.h"

#define LENOFALARMCOMM 20
#define LENOFALARML1 80
#define LENOFALARML2 80
#define LENOFAPPLINE 20
#define LENOFINPUTDLINE 80
#define LENOFVERSION 10
#define LENOFSTATTLSDATA 80
#define LENOFB62STR 5
#define LENOFWKDATE 20
#define LENOFTMPDATE 10
#define LENOFTEMPDUMPC 20
#define TRANSFLATFILE "trans"
#define MAXALARMS 400
#define NOTAGBITMAP "notag.bmp"
#define GREENTAGBITMAP "greentag.bmp"
#define REDTAGBITMAP "redtag.bmp"
#define BELLBITMAP "bell.bmp"
#define LENOFTEMPDATESTR 10
#define GPATODO "GPATODO.DAT"
#define LENOFTODONAME 80
#define LENOFTEMPINTSTR 10
#define PRINTERLISTQ 100
#define LENOFTEMPSTRDCLU 100
#define LENOFTEMPMVL 80
#define LENOFTEMPSTRMVL 100
#define LENOFTEMPCAVSTR 20
#define PDF417 "PDF417.GPA"
#define PDF417OP "PDF417OP.GPA"
#define LENOFPDFIOBUF 256
#define TAXBUFPTRQ 14
#define LENOFTMPTAXBUF 20
#define LENOFREADTMP 20
#define LENOFREADDATE 10
#define LENOFREADCASH 10
#define LENOFSCANPDFBUF 2000
#define LENOFTEMPDECBUF 100
#define LENOFSETALISTTMP 80
#define LENOFTIDYUPTEMP 80

typedef struct {
    CHAR t;                   // time
    INT  d;                   // date
    CHAR c[LENOFALARMCOMM];   // comment
    CHAR l0[LENOFALARML1];    // first line
    CHAR l1[LENOFALARML2];    // second line
} ALARMDEF;                   // Alarm Definition

typedef struct {
    INT grp;                  // group
    LONG unitval;             // unit value
    LONG amount;              // amount  i.e. unitval * quantity
    INT qty;                  // quantity
    INT mt;                   // milk tokens
} PEALSORT;                   // Pension and Alllowances Sort Struct

//#define PDFSCANNER

#ifdef PDFSCANNER

CHAR *lookupc[4]= {
     "None",
     "PLG",
     "BICYCLE",
     "HGV"
};
CHAR *lookupm[5]= {
     "None",
     "ROVER",
     "KAWASAKI",
     "FORD",
     "BEDFORD"
};                                              
CHAR *axleconf[2]= {
     "None",
     "2 ARTIC"
};                                              

typedef struct {
    INT   s;                  // shedule
    ULONG q;                  // quantity
    ULONG v;                  // value
} MVLTOTS;                    // Motor Vehicle Lic. Totals

INT   G_numvl[2]={0L,0L};     // number of mvl lines in search 0=code 85, 1=code 90
LONG *G_vlist[2]={NULL,NULL}; // the mvl records in search 0=code 85, 1=code 90
MVLTOTS *G_shedlist=NULL;     // the totals for mvl shedules
INT   G_numshed=0;            // the number of shedules
CHAR  G_absweek;              // the absolute week number i.e. 54=2, -2=50.
INT   G_region;               // the region code for this office
INT16 G_first;                // the first line with data in the cash accountline with data in the cash account
INT16 G_last;                 // the last line with data in the cash account
CHAR *G_savetbuf=NULL;        // temp buffer for transferring barcode data to tax disk print

#define CABUFSIZE 1034        // size of maximum PDF417 barcode buffer

INT     G_caerror=0;          // ca error code
INT     G_nfl2bit[11]={0,4,7,10,14,17,20,24,27,30,32}; // number of fields to bits requited lookup i.e. 999=10 bits
#endif                        // PDFSCANNER

ULONG G_office;               // the office code for this office
UCHAR G_week=1;               // the current week number for this office
ALARMDEF *G_calm=NULL;        // current (on screen) alarm definitions
ALARMDEF **G_als=NULL;        // list of alarm definitions
INT G_numals=0;               // number of alarm definitions in list
CHAR G_appt[LENOFAPPLINE];    // currently input appointment line
CHAR G_line[2][LENOFINPUTDLINE]; // currently input detail lines
INT G_calmod=0;               // TRUE if calendar modified
CHAR *b62nums="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ?"; // base 62 number lookup
CHAR *tpassnums= "QWERTYUIOPASDFGHJKLZXCVBNM0132457698mnbvcxzlkjhgfdsapoiuytrewq ?"; // base 62 number lookup for temp password
CHAR *mtpassnums="5qwert4yuiop3lkjhg2fdsaz7xcvbn0m1ASDFGHJKL2POIUYTREWQ8ZXCV9BNM ?"; // base 62 number lookup for managers temp password !!
extern LONG  G_vars[MAXGVARS];// reference to V[0]-V[50]
LONG *G_peallist=NULL;        // pension and allowance list
INT   G_peallistlen=0;        // pension and allowance list length
//--------------------------------------------------------------------------
//                  FUNCTION DECLARATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   INT funcname(void);

INT             prbar        (void);
INT             pay          (void);    
INT             showg1       (void);
INT             stamp1       (void);
INT             stamp2       (void);
INT             stsel1       (void);
INT             stsel2       (void);
INT             stgtct       (void);
INT             stopst       (void);
INT             stinz        (void);
INT             stinrz       (void);
INT             stgtst       (void);
INT             stvost       (void);
INT             strest       (void);
INT             openta       (void);   
INT             dumptxn      (void);
INT             closeta      (void);
INT             reduce       (void);
INT             increase     (void);
INT             changalr     (void);             
INT             rcptstat     (void);
INT             stmpstat     (void);
INT             caklf       (void);
INT             cainfo      (void);
CHAR           *cagetvar    (CHAR *);
INT             backup      (void);
INT             calendar    (void);

INT             datecvt     (void);
INT             getalm      (INT d,INT ofs,INT h,INT today);
INT             addalm      (INT d,INT h,INT b);
INT             isestr      (CHAR *s);
INT             setalm      (INT d,INT h,INT b);
INT             firstday    (INT m,INT y);
INT             daypm       (INT m,INT y);
void            prcald      (INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h,INT da);
void            edithour    (INT x,INT y,INT h,CHAR *s,CHAR *l0,CHAR *l1,INT k);
void            editday     (INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h);
INT             chkalm      (void);
void            chkday      (void);
void            ringbell    (void);
void            savemon     (INT y,INT m);
void            loadmon     (INT y,INT m);
INT             chktpass    (void);
INT             gentpass    (void);
INT             genmpass    (void);
INT             chkmpass    (void);
INT             carestor    (void);
INT             cabackup    (void);
INT             bprnlist    (void);
INT             resetvrs    (void);
INT             builddec    (void);
INT             decelist    (void);
INT             decslist    (void);
INT             closedec    (void);
INT             setalist    (void);
INT             setvrsng    (void);
INT             init96      (void);
INT             init95      (void);
INT             init94      (void);
INT             lupdate     (void);
INT             pupdate     (void);
INT             pushvrs     (void);
INT             popvrs      (void);
INT             delotot     (void);
INT             delostk     (void);
INT             prinstat    (void);
INT             runcalc     (void);
INT             sregion     (void);
INT             rregion     (void);
INT             startcal    (void);
INT             chmvltxn    (void);
INT             hook        (void);
#ifdef PDFSCANNER
INT             pdf417      (void);
INT             cabar       (void);
INT             dcslubar    (void);
INT             mvlbar      (void);
INT             sendprn     (void);
INT             taxdiskp    (void);
INT             scanpdf     (void);
#endif

//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "capfunc.h"
FILE *trans_file_fp;
//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------
#define STX             0x02    // Start Of Text character
#define ETX             0x03    // End Of Text character
#define ENQ             0x05    // Enquire character
#define ACK             0x06    // ACKnowledge character
#define DLE             0x10    // Data Line Enable shift character
#define NAK             0x15    // Negative AcKnowledge character

//************************************************************
//S date conversion i.e YYMMDD becomes DDMMYY (accesses F[CF])
//R always TRUE

INT datecvt(void)
{
    INT d,m,y;
    CHAR *s=G_formvars[G_form.curitem];
    d=getday(s); m=getmon(s); y=getyear(s);
      orddfrom(&y,&m,&d);
    sprintf(s,"%02d%02d%02d",d,m,y);
    return(1);
}

//************************************************************
//S Return the VALUE associated with the VARIABLE
//R char string ptr to value 

CHAR *cagetvar(CHAR *name)
{
   INT i=isaction(name);
   if (i>=0) return("                    ");
   return(getvarib((0-i)-1));
}

//************************************************************
//S Set the value of a STATIC
//P char string name of static to set
//P char string value to set it to

void casetstat(CHAR *name,CHAR *val)
{
   INT i=isaction(name);
   if (i>=0) return;
   setstatic((0-i)-1,val);
}

//************************************************************
//S Set the value of a VARIABLE
//P char string name of variable to set
//P char string value to set it to

void setv(CHAR *name,CHAR *val)
{
   INT i=isaction(name);
   if (i>=0) return;
   setvarib((0-i)-1,val);
}

#define RELEASE_VER     // use release version number
#ifdef RELEASE_VER
//************************************************************
//S Set STATIC "VERSION" to release version number
//R VERSION number

CHAR *ver(void)
{
    static CHAR tmp[LENOFVERSION] = "5.3Test";

    casetstat("VERSION",tmp);
    return(tmp);
}

#else

//************************************************************
//S Set STATIC "VERSION" to calculated (testing) version number
//D Set STATIC "VERSION" to calculated version number from 
//D creation DATE and TIME of PP'ed action file (G_afilename)
//D if current version is 0 otherwise leave as is
//R VERSION number

CHAR *ver(void)
{
    INT fd;
    static CHAR tmp[LENOFVERSION];
    UINT d,t;

    strcpy(tmp,cagetvar("VERSION"));
    if (atoi(tmp)==0) {
        if ((fd=open(G_afilename,O_RDONLY))==(-1)) return("NO_VER");
        _dos_getftime(fd,&d,&t);
        close(fd);
        sprintf(tmp,"%d.%02d",(d-7434),(t>>11));
        casetstat("VERSION",tmp);
    }
    return(tmp);
}
#endif

//************************************************************
//S CAPTURE keyboard loop function flashes top left screen data if prev week
//R TRUE

INT caklf(void)
{
    static CHAR tmp[LENOFSTATTLSDATA];
    INT size;
    CHAR wrkdate[LENOFWKDATE];
    INT wkday;
    static CHAR attrib=1;
    static CHAR flash=1;
    static INT ro=0;
    INT d,m,y;

    size=(INT)sendmsg("OUTPUT1",MESSAGE_i);

    if (ro==0) {
        strcpy(wrkdate,cagetvar("WRKDATE"));
        d=getday(wrkdate); m=getmon(wrkdate); y=getyear(wrkdate);
        orddfrom(&y,&m,&d);
        wkday=((atoi(cagetvar("WRKDAY"))-1)%6)+1;
        if (wkday>=4) wkday-=3; else wkday+=3;
        if (atol(wrkdate)!=atol(cagetvar("CURDATE"))) flash=1; else flash=0;
        sprintf(tmp,"CA WEEK:%2s DAY:%s %3s %02d/%02d/%02d V%s ",
            cagetvar("WRKWK"),cagetvar("WRKDAY"),G_days[wkday],d,m,y,ver());
    }
    if ((++ro)==10) ro=0;
    if (flash)
        {
        attrib^=1;
        if (attrib)
            sendmsg("OUTPUT1",MESSAGE_A,0x07);
        else
            sendmsg("OUTPUT1",MESSAGE_A,0x43);
        }
    else
        {
        attrib=1;
        sendmsg("OUTPUT1",MESSAGE_A,attrib);
        }
    sendmsg("OUTPUT1",MESSAGE_S,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,0,"%30s",tmp);

    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_S,size);
    return(1);
}
//************************************************************
//S Start calculator up
//R returns TRUE 

INT startcal(void)
{
    chkday();
    sendmsg("INPUT1",MESSAGE_A,182,chkalm); /* add chkalm to key loop */
    return(1);
}

//************************************************************
//S CAPTURE start code to setup keyloop functions
//R returns TRUE 

INT cainfo(void)
{
    sendmsg("INPUT1",MESSAGE_A,5,caklf);
    return(1);
}

//************************************************************
//S flip round timed password (so that it doesn't look sequential)
//P char str points to password (4 char)

void flipround(CHAR *s)
{
    CHAR t;
    t=s[0]; s[0]=s[3]; s[3]=t;
    t=s[1]; s[1]=s[2]; s[2]=t;
}

//************************************************************
//S Password date number
//P date string
//P time string
//R an unique number for every 10 second period since 01-01-80

LONG pdnum(CHAR *date,CHAR *time)
{
    LONG d;
    d=(LONG)datetonum(date)*144L;
    d+=(LONG)((((time[0]-'0')*10)+(time[1]-'0'))*6)+(time[2]-'0');
    return(d);
}

//************************************************************
//S Convert number(LONG) to a base 62 string
//P the number to convert
//P 1=Manager 2=Temp or 0=Normal conversion
//R Converted base 62 string

CHAR *numtob62(LONG n,INT mtn)
{
    INT i,j;
    static CHAR ret[LENOFB62STR];
    for (i=3;i>=0;i--)
        {
        j=(INT)(n%62L);
        n/=62;
        switch (mtn) { // ManagerTempNormal
            case 1 :    // Manager
                ret[i]=mtpassnums[j];
                break;
            case 2 :    // Temp
                ret[i]=tpassnums[j];
                break;
            case 0 :    // Normal
            default:
                ret[i]=b62nums[j];
                break;
        }
    }
    ret[LENOFB62STR-1]=0;
    return(ret);
}

//************************************************************
//S return the offset of a symbol in an array 
//P Symbol - a single char
//P list of symbols - a string of chars
//R integer offset

INT symbolofs(CHAR s,CHAR *l)
{
    CHAR *t;
    t=strchr(l,s);
    if (t==NULL)
        return(0);
    return((INT)(t-l));
}

//************************************************************
//S Convert base 62 string to a long
//P char string to convert
//P integer conv type : 1=Manager 2=Temp or 0=Normal conversion
//R long integer Converted number

LONG b62tonum(CHAR *n,INT mtn)
{
    static CHAR tmp[LENOFB62STR];
    LONG ret=0;
    strcpy(tmp,n);
    n=tmp;
    while (*n) {
        ret*=62L;
        switch (mtn) { // ManagerTempNormal
            case 1 :    // Manager
                ret+=(LONG)symbolofs(*n,mtpassnums);
                break;
            case 2 :    // Temp
                ret+=(LONG)symbolofs(*n,tpassnums);
                break;
            case 0 :    // Normal
            default:
                ret+=(LONG)symbolofs(*n,b62nums);
                break;
        }
        n++;
    }
    return(ret);
}

//************************************************************
//S Check the input password against the current date and time for validity
//P integer mtn (see func b62tonum)
//R TRUE if ok else FALSE (Exit Action with GNOACCESS) CF=CF-1

INT chkpass(INT mtn)
{
    CHAR tmp[LENOFTMPDATE];
    LONG d;
    strcpy(tmp,datestr(8));     // should use appropriate enum :JGQ 24/10
    d=pdnum(tmp,datestr(9));    // should use appropriate enum :JGQ 24/10
    if (d==b62tonum(G_formvars[G_form.curitem],mtn))
        return(1);
    G_form.curitem--;
    return(0);
}

//************************************************************
//S Generate a TEMP password into F[CF]
//P integer mtn (see func b62tonum)

void genpass(INT mtn)
{
    LONG d;
    d=pdnum(G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],numtob62(d,mtn));
}

//************************************************************
//S Check the input password against the current date and time for validity
//D temp version
//R TRUE if ok else FALSE (Exit Action with GNOACCESS) CF=CF-1

INT chktpass(void)
{
    return(chkpass(2));
}

//************************************************************
//S Generate a TEMP password into F[CF]
//D temp version
//R TRUE

INT gentpass(void)
{
    genpass(2);
    return(1);
}

//************************************************************
//S Check the input password against the current date and time for validity
//D managers version
//R TRUE if ok else FALSE (Exit Action with GNOACCESS) CF=CF-1

INT chkmpass(void)
{
    return(chkpass(1));
}

//************************************************************
//S Generate a TEMP password into F[CF]
//D temp version
//R TRUE

INT genmpass(void)
{
    genpass(1);
    return(1);
}

//************************************************************
//S Barcode  print routine for EPSON label printer
//R TRUE

INT prbar(void)
{
    sendmsg("OUTPUT2",MESSAGE_C,G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
    return(1);
}

//************************************************************
//S Status of receipt printer
//D updates global var quantity
//R TRUE

INT rcptstat(void)
{
    G_qnty=(INT)sendmsg("PRN",MESSAGE_GS);
    return(1);
}

//************************************************************
//S Stamp printer status
//D updates global var quantity
//R TRUE

INT stmpstat(void)
{
    G_qnty=(INT)sendmsg("STAMP",MESSAGE_GS,G_type);
    return(1);
}

//************************************************************
//S payout (using minimum number of coins) value in GLOB3
//R TRUE

INT pay(void)
{
 sendmsg("8255",MESSAGE_PO,G_globs[3]);
 return(1);
}

//************************************************************
//S Change the state of the 8255 safe alarms (for door opening)
//R TRUE

INT changalr(void)
{
    if((atoi(G_globs[6])) == 1)
        {
        sendmsg("8255",MESSAGE_SA,1);
        }
    else
        {
        sendmsg("8255",MESSAGE_RA);
        }
    return(1);                
}

//************************************************************
//S reduce the quantity in the currently input money counter
//R TRUE

INT reduce(void)
{
    sendmsg("8255",MESSAGE_RC,G_qnty);
    return(1);
}

//************************************************************
//S increase the quantity in the currently input money counter
//R TRUE

INT increase(void)
{
    sendmsg("8255",MESSAGE_PL,G_qnty);
    return(1);
}

//************************************************************
//S print GLOB1 at 20,20 on the OUTPUT1 device
//R TRUE

INT showg1(void)
{
//    beep();
    sendmsg("OUTPUT1",MESSAGE_o,20,20,"%s",G_globs[1]);
//    beep();
    return(1);
}

//************************************************************
//S Print a stamp on printer 1 
//R TRUE

INT stamp1(void)
{
    INT counter = 0;
    INT temp = 0 ;
    sendmsg("STAMP",MESSAGE_S1);
    counter = (INT)sendmsg("STAMP",MESSAGE_C);
    /*sendmsg("STAMP",MESSAGE_O,G_qnty,G_globs[4]);*/
    sendmsg("STAMP",MESSAGE_O,1,1);
    if ((sendmsg("STAMP",MESSAGE_C) - counter)!=3)
        {
        temp = (INT)sendmsg("STAMP",MESSAGE_I);
        itoa(temp,G_globs[1],10); 
//        showg1();
//        beep();
        }
    return(1);
}

//************************************************************
//S Print a stamp on printer 2
//R TRUE

INT stamp2(void)
{
    INT counter = 0;
    INT temp= 0;
    sendmsg("STAMP",MESSAGE_S2);
    counter = (INT)sendmsg("STAMP",MESSAGE_C);
    /*sendmsg("STAMP",MESSAGE_O,G_qnty,G_globs[4]);*/
    sendmsg("STAMP",MESSAGE_O,22,1);
    if ((sendmsg("STAMP",MESSAGE_C) - counter)!=3)
        {
        temp = (INT)sendmsg("STAMP",MESSAGE_I);
        itoa(temp,G_globs[1],10); 
//        showg1();
//        beep();
    }
    return(1); 
}

//************************************************************
//S Select stamp printer 1
//R TRUE

INT stsel1(void) 
{
    sendmsg("STAMP",MESSAGE_S1);   
    return(1);
}

//************************************************************
//S Select stamp printer 2 
//R TRUE

INT stsel2(void)
{
    sendmsg("STAMP",MESSAGE_S2);   
    return(1);
}

//************************************************************
//S Get count from stamp printer
INT stgtct(void)
{
    INT counter = 990;
    counter = (INT)sendmsg("STAMP",MESSAGE_C);
    itoa(counter,G_globs[6],10);
    itoa(counter,G_globs[1],10); 
    //    showg1();
    return(1);
}

//************************************************************
//S print a stamp
//R TRUE

INT stopst(void)
{
    G_qnty=(INT)sendmsg("STAMP",MESSAGE_O,atoi(G_globs[4]),G_qnty);       
    return(1);
}
 
//************************************************************
//S initialise the stamp printer
//R TRUE

INT stinz(void)
{
    sendmsg("STAMP",MESSAGE_I);
    return(1);
}

//************************************************************
//S re-initialise the stamp printer
//R TRUE

INT stinrz(void)
{
    sendmsg("STAMP",MESSAGE_RI);
    return(1);
}

//************************************************************
//S get status from stamp printer
//R TRUE

INT stgtst(void)
{
    INT temp;   
    LONG stat;
    stat = 999;
    temp = (INT)sendmsg("STAMP",MESSAGE_i,&stat);
    sprintf(G_globs[6],"%ld",&stat);
    sprintf(G_globs[1],"%d",temp);
    return(1);
}

//************************************************************
//S void the stamp in the stamp printer 
//R TRUE

INT stvost(void)
{
    INT temp;
    temp = (INT)sendmsg("STAMP",MESSAGE_V);
    itoa(temp,G_globs[1],10); 
//    showg1();
    return(1);
}

//************************************************************
//S reset the stamp printer
//R TRUE

INT strest(void)
{
    INT temp;
    temp = (INT)sendmsg("STAMP",MESSAGE_R);
    itoa(temp,G_globs[1],10); 
//  showg1();
    return(1);
}

//************************************************************
//S Open Door - not implemented yet
//R TRUE

INT openta(void)
{
    return(1);
}

//************************************************************
//S Close Door - not implemented yet
//R TRUE

INT closeta(void)
{
    return(1);
}

//************************************************************
//S Dump transation log to an flat file called TRANSFLATFILE 
//D copies it to A:\ - assumed to mean floppy? 
//D and deletes current directory copy
//R TRUE

INT dumptxn(void)
{
    LONG i=(LONG)FRST;
    CHAR d[LENOFTEMPDUMPC],q[LENOFTEMPDUMPC],t[LENOFTEMPDUMPC],a[LENOFTEMPDUMPC],l[LENOFTEMPDUMPC];

    trans_file_fp = fopen(TRANSFLATFILE,"a+");
    if (trans_file_fp==NULL)
        return(0);
     while (sendmsg("DBM",MESSAGE_r,"transact",i))
        {
        sendmsg("DBM",MESSAGE_g,"transact","date",d);
        sendmsg("DBM",MESSAGE_g,"transact","time",t);  
        sendmsg("DBM",MESSAGE_g,"transact","quantity",q);        
        sendmsg("DBM",MESSAGE_g,"transact","amount",a);    
        sendmsg("DBM",MESSAGE_g,"transact","location",l);  
        fprintf(trans_file_fp,"%s,%s,%s,%s,%s\n",d,t,q,a,l);
        i=(LONG)NEXT;
        }
    fclose(trans_file_fp);
    sendmsg("DBM",MESSAGE_e,"transact");
    if (!sendmsg("DISK",MESSAGE_C,TRANSFLATFILE,".\\","a:\\"))
        return(0);
    if (!sendmsg("DISK",MESSAGE_D,TRANSFLATFILE,".\\"))
        return(0);
      return(1);
}
//************************************************************
//S get an alarm entry - matches against date and hour
//P integer date
//P integer offset from today for request
//P integer hours of alarm
//P integer day of month
//R special computed non zero reply value, or 0 if not found

INT getalm(INT d,INT ofs,INT h,INT today)
{
    INT r,i;
    if (ofs<today)
        r=3;
    else
        r=1;
    d+=ofs-1;
    G_calm=NULL;            // set current on screen alarm to void
    for (i=0;i<G_numals;i++) {
        if ((G_als[i]->d==d)&&((G_als[i]->t&0x0F)==h))
            {
            G_calm=G_als[i];
            return(r+((G_calm->t&0x80)==0x80)); // Compiler specific :JGQ 24/10
        }
    }
    return(0);
}
//************************************************************
//S add an alarm entry
//P integer date
//P integer hour
//P integer boolean to set hours to just bit 5 or use it all
//P BOOL FALSE malloc failure or more than MAXALARMS,  TRUE ok

INT addalm(INT d,INT h,INT b)
{
    if (G_numals>=MAXALARMS)
        return(0);
    G_als[G_numals]=MALLOC(sizeof(ALARMDEF));
    if (G_als[G_numals]==NULL)
        return(0);
    G_calm=G_als[G_numals];
    G_numals++;
    G_calm->d=d;
    if (b) G_calm->t=(CHAR)(h|0x80); else G_calm->t=(CHAR)h;
    strcpy(G_calm->c,G_appt);
    strcpy(G_calm->l0,G_line[0]);
    strcpy(G_calm->l1,G_line[1]);
    return(1);
}

//************************************************************
//S determine if a stringf is empty - just white space
//R BOOL TRUE if empty, FALSE if not empty

INT isestr(CHAR *s)
{
    while (*s)
        if (!isspace(*s++))
            return(0);
    return(1);
}

//************************************************************
//S set an alarm entry
//D if empty strings and bflag FALSE deletes alarm entry
//D if any of the strings are set then updates the alarm entry
//P integer date
//P integer hour
//P integer BOOL hour flag (see addalm)
//R BOOL TRUE means updated existing entry, FALSE means new one added

INT setalm(INT d,INT h,INT b)
{
    INT i,j,a=1;
    if (isestr(G_appt)&&isestr(G_line[0])&&isestr(G_line[1])&&(b==0))
        a=0;
    for (i=0;i<G_numals;i++)
        {
        if ((G_als[i]->d==d)&&((G_als[i]->t&0x0F)==h))
            {
            if (a)
                {
                G_calm=G_als[i];
                strcpy(G_calm->c,G_appt);
                strcpy(G_calm->l0,G_line[0]);
                strcpy(G_calm->l1,G_line[1]);
                if (b) G_calm->t|=0x80; else G_calm->t&=0x7F;
                }
            else
                {
                FREE(G_als[i]);
                G_numals--;
                for (j=i;j<G_numals;j++)
                    G_als[j]=G_als[j+1];
                }
            return(1);
        }
    }
    if (a) addalm(d,h,b);
    return(0);
}

//************************************************************
//S return the first day of the month
//P integer month
//P integer year - doesn't matter if century is supplied
//R integer date

INT firstday(INT m,INT y)
{
    INT d;
    CHAR tmp[LENOFTEMPDATESTR];
    sprintf(tmp,"%02d%02d01",y%100,m);
    d=datetonum(tmp);
    return(d);
}

//************************************************************
//S return days per month for y & m
//D Routine is only true for 12 month year :JGQ 24/10
//D Routine doesn't allow for century/millenium :JGQ 24/10
//P integer month to check
//P year concerned
//R days in that month

INT daypm(INT m,INT y)
{
    INT d;
    if (m==0) m=12;
    d=G_dpm[m-1];
    if ((m==2)&&((y%4)==0)) d++;
    return(d);
}
//************************************************************
//S Print calander details
//P integer x coord
//P integer y coord
//P integer year
//P integer month
//P integer day
//P integer todays day of month
//P integer hour
//P integer BOOL force notag.bmp to print

void prcald(INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h,INT da)
{
    INT nd,i,dr=0;
    INT fd,j,k,l;
    static INT lm=0,ly=0;
    if (((lm!=mn)||(ly!=yr))||(da))
        dr=1;
    lm=mn; ly=yr;
    fd=firstday(mn,yr);
    nd=(fd+2)%7;
    sendmsg("OUTPUT1",MESSAGE_A,0);
    for (i=0;i<7;i++)
        sendmsg("OUTPUT1",MESSAGE_o,x+1+i*5,y+1,"%-4.4s",G_days[i]);
    for (i=0;i<nd;i++)
        {
        sendmsg("OUTPUT1",MESSAGE_o,x+2+i*5,y+3,"  ");
        if (dr)
            sendmsg("OUTPUT1",MESSAGE_P,x+1+i*5,y+4,NOTAGBITMAP);
        }
    for (i=0;i<daypm(mn,yr);i++)
        {
        if (dy==(i+1)) k=2; else k=0;
        sendmsg("OUTPUT1",MESSAGE_A,k);
        sendmsg("OUTPUT1",MESSAGE_o,x+2+((i+nd)%7)*5,y+3+((i+nd)/7)*2,"%2d",i+1);
        if (dr)
            {
            k=l=0;
            for (j=0;j<12;j++) { l=getalm(fd,i+1,j,td); k=max(l,k); }
            switch (k)
                {
                case 0 :
                    sendmsg("OUTPUT1",MESSAGE_P,x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,NOTAGBITMAP);
                    break;
                case 1 :
                case 3 :
                    sendmsg("OUTPUT1",MESSAGE_P,x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,GREENTAGBITMAP);
                    break;
                case 2 :
                case 4 :
                    sendmsg("OUTPUT1",MESSAGE_P,x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,REDTAGBITMAP);
                    break;
                }
            }
        }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    for (;i<((6*7)-nd)-5;i++)
        {
        sendmsg("OUTPUT1",MESSAGE_o,x+2+((i+nd)%7)*5,y+3+((i+nd)/7)*2,"  ");
        if (dr) sendmsg("OUTPUT1",MESSAGE_P,x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,NOTAGBITMAP);
        }
    for (i=7;i<20;i++)
        {
        if (h==i) sendmsg("OUTPUT1",MESSAGE_A,2); else sendmsg("OUTPUT1",MESSAGE_A,0);
        l=getalm(fd,dy,i-7,td);
        sendmsg("OUTPUT1",MESSAGE_o,x+36,(y+i)-4,"%02d:00",i);
        if (l) {
            sendmsg("OUTPUT1",MESSAGE_o,x+43,(y+i)-4,"  %s",G_calm->c);
            if ((l==2)||(l==4)) sendmsg("OUTPUT1",MESSAGE_P,x+43,(y+i)-4,BELLBITMAP);
        } else {
            sendmsg("OUTPUT1",MESSAGE_o,x+43,(y+i)-4,"                    ",i);
        }
    }
    i=(31-strlen(datestr(0)))/2;
    sendmsg("OUTPUT1",MESSAGE_o,x+1,y+15,"%*.*s%s%*.*s",i,i,"",datestr(0),i,i,"");
    sendmsg("OUTPUT1",MESSAGE_o,x+44,y+1,"%d %s %d  ",dy,G_mnths[mn-1],yr+1900);
    l=getalm(fd,dy,h-7,td);
    if (l) {
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+17,"%-64.64s",G_calm->l0);
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+18,"%-64.64s",G_calm->l1);
    } else {
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+17,"%-64.64s","");
        sendmsg("OUTPUT1",MESSAGE_o,x+1,y+18,"%-64.64s","");
    }
}
//************************************************************
//S Edit hour information
//P integer x coordinate
//P integer y coord
//P integer hour
//P char string alarm comment
//P char string first line
//P char string second line
//P integer first char entered for first string

void edithour(INT x,INT y,INT h,CHAR *s,CHAR *l0,CHAR *l1,INT k)
{
    INT cf=G_form.curitem;
    if (inputstr(x+45,(y+h)-4,s,"XXXXXXXXXXXXXXXXXX",k))
        G_calmod=1;
    if (inputstr(x+1,y+17,l0,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0))
        G_calmod=1;
    if (inputstr(x+1,y+18,l1,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0))
        G_calmod=1;
    G_exitkey=0;
    G_form.curitem=(CHAR)cf;
}

//************************************************************
//S Calendar help screen

void calhelp(void)
{
    INT x,y;
    x=G_form.items[G_form.curitem].pos.x+1;
    y=G_form.items[G_form.curitem].pos.y+1;
    sendmsg("OUTPUT1",MESSAGE_SAVEREGION,x*8,y*19,38*8,19*19);
    sendmsg("OUTPUT1",MESSAGE_AA,0);
    sendmsg("OUTPUT1",MESSAGE_b,x*8,y*19,38*8,19*19); // bar;
    sendmsg("OUTPUT1",MESSAGE_S,1);
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,x  ,y   ,"Help Keys");
    sendmsg("OUTPUT1",MESSAGE_o,x+1,y+1 ,"Calendar");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+2 ,"PAGE UP     Previous year");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+3 ,"PAGE DOWN   Next year");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+4 ,"UP ARROW    Previous month");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+5 ,"DOWN ARROW  Next month");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+6 ,"LEFT ARROW  Previous day");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+7 ,"RIGHT ARROW Next day");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+8 ,"ENTER       Select Diary");
    sendmsg("OUTPUT1",MESSAGE_o,x+1,y+9 ,"Diary");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+10,"UP ARROW    Previous hour");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+11,"DOWN ARROW  Next hour");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+12,"ENTER       Confirm diary entry");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+13,"INSERT      Switch alarm on/off");
    sendmsg("OUTPUT1",MESSAGE_o,x+2,y+14,"DELETE      Delete diary entry");
    sendmsg("INPUT1",MESSAGE_i);
    sendmsg("OUTPUT1",MESSAGE_RESTREGION,x*8,y*19,38*8,19*19);
}

//************************************************************
//S Edit day information in an alarm
//P integer x coord
//P integer y coord
//P integer year
//P integer month
//P integer day
//P integer today
//P integer hour

void editday(INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h)
{
    INT xit=0,k,fd,oh=-1;
    INT l,bell;
    fd=firstday(mn,yr);
    if (h<7) h=7;
    if (h>19) h=19;
    while (!xit)
        {
        if (h!=oh)
            {
            l=getalm(fd,dy,h-7,td);
            if (l)
                {
                strcpy(G_appt,G_calm->c);
                strcpy(G_line[0],G_calm->l0);
                strcpy(G_line[1],G_calm->l1);
                if ((l==2)||(l==4)) bell=1; else bell=0;
                sendmsg("OUTPUT1",MESSAGE_o,x+1,y+17,"%-64.64s",G_calm->l0);
                sendmsg("OUTPUT1",MESSAGE_o,x+1,y+18,"%-64.64s",G_calm->l1);
                }
            else
                {
                G_appt[0]=0;
                G_line[0][0]=0;
                G_line[1][0]=0;
                bell=0;
                sendmsg("OUTPUT1",MESSAGE_o,x+43,(y+h)-4,"                    ");
                sendmsg("OUTPUT1",MESSAGE_o,x+1,y+17,"%-64.64s","");
                sendmsg("OUTPUT1",MESSAGE_o,x+1,y+18,"%-64.64s","");
                }
            oh=h;
            }
        sendmsg("OUTPUT1",MESSAGE_C,x+45,0,(y+h)-4,19,1);
        while (sendmsg("INPUT1",MESSAGE_H)==0)
            {
            if (G_calredraw)
                {
                prcald(x,y,yr,mn,dy,td,h,1);
                sendmsg("OUTPUT1",MESSAGE_C,x+45,0,(y+h)-4,19,1);
                G_calredraw=0;
                }
            }
        k=(INT)sendmsg("INPUT1",MESSAGE_i);
        sendmsg("OUTPUT1",MESSAGE_C,x+45,0,(y+h)-4,19,1);
        switch (k)
            {
            case DEL  :
                G_appt[0]=0;
                G_line[0][0]=0;
                G_line[1][0]=0;
                bell=0;
                G_calmod=1;
                   setalm((fd+dy)-1,h-7,bell);
                oh=h-1;
                break;
            case INS  :
                bell^=1;
                if (bell) {
                    sendmsg("OUTPUT1",MESSAGE_P,x+43,(y+h)-4,BELLBITMAP);
                    G_calmod=1;
                } else {
                    sendmsg("OUTPUT1",MESSAGE_o,x+43,(y+h)-4,"  ");
                    G_calmod=1;
                }
                  setalm((fd+dy)-1,h-7,bell);
                break;
            case F10 :
                xit=1;
                break;
            case DOWN : if (h<19) h++; break;
            case UP   : if (h>7)  h--; break;
            case CR   :
                edithour(x,y,h,G_appt,G_line[0],G_line[1],0);
                   setalm((fd+dy)-1,h-7,bell);
                break;
            case F01  : calhelp(); break;
            default   :
                if (chkfmt('X',k))
                    {
                    edithour(x,y,h,G_appt,G_line[0],G_line[1],k);
                    setalm((fd+dy)-1,h-7,bell);
                    }
                else
                    {
                    beep();
                    }
            }                             
        }
}

//************************************************************
//S check today for alarms that need calendar to be run

void chkday(void)
{
    INT d,m,y,fd,i;
    CHAR dt[LENOFTEMPDATESTR];

    strcpy(dt,datestr(MINDATE));
    d=getday(dt);
    m=getmon(dt);
    y=getyear(dt);
    orddfrom(&y,&m,&d);
    fd=firstday(m,y);
    loadmon(y,m);
    for (i=0;i<16;i++)
        {
        if (getalm(fd,d,i,d))
            {
            ringbell();
            runaction("calendar");
            return;
            }
        }
}

//************************************************************
//S Check to see if an alarm is currently active
//R TRUE

INT chkalm(void)
{
    INT d,m,y,h,fd,l;
//    INT lm,ly,dy,td;
    CHAR dt[LENOFTEMPDATESTR];
    static CHAR inhere=0;
    if (inhere)
        return(1);
    if (!strcmp(G_form.name,"calendar"))
        return(1);

    inhere=1;
    strcpy(dt,datestr(MINDATE)); d=getday(dt); m=getmon(dt); y=getyear(dt);
    orddfrom(&y,&m,&d);
    strcpy(dt,datestr(TIMEM)); h=atoi(dt);
    fd=firstday(m,y);
    loadmon(y,m);
    l=getalm(fd,d,h-7,d);
    if ((l==2)||(l==4)) {
         setalm((fd+d)-1,h-7,0);
        savemon(y,m);
        loadmon(y,m+1);
        ringbell();
        runaction("calendar");
    }
    inhere=0;
    return(1);
}
//************************************************************
//S ring bell on calander activation

void ringbell(void)
{
    INT i;
    beep();
    beep();
    for (i=0;i<10;i++) {
        sendmsg("OSSDEV",MESSAGE_s,3000);
        sendmsg("OSSDEV",MESSAGE_d,10);
        sendmsg("OSSDEV",MESSAGE_s,1000);
        sendmsg("OSSDEV",MESSAGE_d,20);
    }
    sendmsg("OSSDEV",MESSAGE_ns);
    sendmsg("OSSDEV",MESSAGE_d,100);
    for (i=0;i<10;i++) {
        sendmsg("OSSDEV",MESSAGE_s,3000);
        sendmsg("OSSDEV",MESSAGE_d,10);
        sendmsg("OSSDEV",MESSAGE_s,1000);
        sendmsg("OSSDEV",MESSAGE_d,20);
    }
    sendmsg("OSSDEV",MESSAGE_ns);
}

//************************************************************
//S save months to GPATODO file
//D WARNING : Assumes 12 months to the year only
//P integer year
//P integer month

void savemon(INT y,INT m)
{
    INT fd,i;
    LONG ofs,last,tmp[12];
    CHAR filename[LENOFTODONAME];

    if (!G_calmod) return;

    memset(tmp,0,12*sizeof(LONG));
    y-=94;
    m-=1;
    ofs=m+(y*12);
    sprintf(filename,"%s"GPATODO,G_database);
    fd=open(filename,O_RDWR|O_BINARY);
    last=(156L*12L*sizeof(LONG))+sizeof(LONG);
    if (fd==(-1))
        {
        fd=open(filename,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
        if (fd==(-1)) return;
        write(fd,&last,sizeof(LONG));
        for(i=0;i<156;i++)
            write(fd,tmp,sizeof(tmp));
        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        write(fd,&last,sizeof(LONG));
        ofs=last;
        lseek(fd,0L,SEEK_SET);
        last+=(31L*(LONG)sizeof(ALARMDEF))+sizeof(INT);
        write(fd,&last,sizeof(LONG));
        }
    else
        {
        lseek(fd,0L,SEEK_SET);
        read(fd,&last,sizeof(LONG));
        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        read(fd,tmp,sizeof(LONG));
        if (tmp[0]==0L)
            {
            lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
            write(fd,&last,sizeof(LONG));
            ofs=last;
            lseek(fd,0L,SEEK_SET);
            last+=(31L*(LONG)sizeof(ALARMDEF))+sizeof(INT);
            write(fd,&last,sizeof(LONG));
            }
        else
            {
            ofs=tmp[0];
            }
    }
    lseek(fd,ofs,SEEK_SET);
    write(fd,&G_numals,sizeof(INT));
    for (i=0;i<G_numals;i++)
        {
        write(fd,G_als[i],sizeof(ALARMDEF));
        }
    close(fd);
    G_calmod=0;
}

//************************************************************
//S load months from GPATODO file
//P integer year
//P integer month

void loadmon(INT y,INT m)
{
    CHAR filename[LENOFTODONAME];

    ALARMDEF ad;
    static INT lm=0,ly=0;
    INT fd,i;
    LONG ofs;
    if (G_als==NULL) G_als=MALLOC(MAXALARMS*sizeof(ALARMDEF *));
    if (G_als==NULL) return;
    if ((lm!=m)||(ly!=y)) {
        for (i=0;i<G_numals;i++) if(G_als[i]!=NULL) FREE(G_als[i]);
        G_numals=0;
        lm=m;
        ly=y;
        y-=94;
        m-=1;
        ofs=m+(y*12);
        sprintf(filename,"%s"GPATODO,G_database);
        fd=open(filename,O_RDONLY|O_BINARY);
        if (fd==(-1))
            return;
        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        read(fd,&ofs,sizeof(LONG));
        if (ofs!=0L)
            {
            lseek(fd,ofs,SEEK_SET);
            read(fd,&m,sizeof(INT));
            for (i=0;i<m;i++)
                {
                read(fd,&ad,sizeof(ALARMDEF));
                G_als[G_numals]=MALLOC(sizeof(ALARMDEF));
                if (G_als[G_numals]==NULL)
                    {
                    close(fd);
                    return;
                    }
                memcpy(G_als[G_numals],&ad,sizeof(ALARMDEF));
                G_numals++;
                }
            }
        close(fd);
        }
    G_calmod=0;
}

//************************************************************
//S display and edit calendar
//D movement is restrained between 1994 and 2050
//R TRUE in all cases - even if malloc failed

INT calendar(void)
{
    INT i,xit=0,dr=0;
    INT d,m,y,td;
    INT lm,ly;
    CHAR dt[LENOFTEMPDATESTR];
    INT Saved_G_intable=G_intable;      // Store the flag
    INT printscron=G_printscron;     // entry state of G_printscron
    G_hotkeys=0;        // turn off hotkeys      in calculator
    G_finredraw=1;      // turn off table redraw in calculator
    G_printscron=0;     // turn off print screen in calculator
    if (G_als==NULL)
        G_als=MALLOC(MAXALARMS*sizeof(ALARMDEF *));
    if (G_als==NULL)
        return(1);
    G_incal=1;
    strcpy(dt,datestr(MINDATE));
    d=getday(dt); m=getmon(dt); y=getyear(dt);
    orddfrom(&y,&m,&d);
    strcpy(dt,datestr(TIMEM));
    i=atoi(dt);
    td=d;
    loadmon(y,m);
    while (!xit) {
        prcald(G_form.items[G_form.curitem].pos.x,G_form.items[G_form.curitem].pos.y,y,m,d,td,i,dr);
        dr=0;
        lm=m;
        ly=y;
        while (sendmsg("INPUT1",MESSAGE_H)==0) {
            if (G_calredraw) {
                prcald(G_form.items[G_form.curitem].pos.x,G_form.items[G_form.curitem].pos.y,y,m,d,td,i,dr);
                G_calredraw=0;
            }
        }
        switch (sendmsg("INPUT1",MESSAGE_i)) {
            case F10 :
                xit=1;
                break;
            case PGDN : y++; break;
            case PGUP : y--; break;
            case DOWN : m++; break;
            case UP   : m--; break;
            case RGT  : d++; break;
            case LEFT : d--; break;
            case CR   : editday(G_form.items[G_form.curitem].pos.x,G_form.items[G_form.curitem].pos.y,y,m,d,td,i); dr=1; break;
            case F01  : calhelp(); break;
        }
        if (d>daypm(m,y)) { d=1;  m++; } 
        if (d<1)      { m--; d=daypm(m,y); } 
        if (m>12)     { m=1;  y++; } 
        if (m<1)      { m=12; y--; } 
        if (y<94)       y=94;
        if (y>150)      y=150;
        if ((lm!=m)||(ly!=y)) {
            savemon(ly,lm);
            loadmon(y,m);
        }
    }
    G_incal=0;
    savemon(ly,lm);
    G_intable=Saved_G_intable;      // Restore the flag
    G_hotkeys=1;
    G_printscron=printscron; // reset print screen to entry value
    return(1);
}

//************************************************************
//S backup all DBM directory to floppy (COPY)
//R TRUE

INT backup(void)
{
    INT err=0;
    if (G_modified) {
        sendmsg("OUTPUT1",MESSAGE_A,7);
        sendmsg("OUTPUT1",MESSAGE_S,1);
        sendmsg("OUTPUT1",MESSAGE_o,0,10,"%s",isdefstr("DATAMOD1"));
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,0,13,"%s",isdefstr("DATAMOD2"));
    }
    while (err==0)
        {
        switch (sendmsg("INPUT1",MESSAGE_i))
            {
            case 'y' : case 'Y' : err=1; break;
            case 'n' : case 'N' : err=2; break;
            default  : beep();
        }
    }
    if (err==2)
        return(1);
    err=0;
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,16,"%s",isdefstr("INSERTDP"));
    sendmsg("OUTPUT1",MESSAGE_A,0);
    switch (sendmsg("INPUT1",MESSAGE_i)) { case F10 : case ESC : return(1); }
    sendmsg("OUTPUT1",MESSAGE_o,0,18,"%s",isdefstr("BACKUPPW"));
    switch (sendmsg("DISK",MESSAGE_T,G_backup,"*.*")) {
        case (-1) :
            err=1;
            break;
        case 2 :
            if (!sendmsg("DISK",MESSAGE_C,"*.*",G_database,G_backup)) err=2;
            break;
        default :
            if (!sendmsg("DISK",MESSAGE_D,"*.*",G_backup)) {
                err=3;
            } else {
                if (!sendmsg("DISK",MESSAGE_C,"*.*",G_database,G_backup)) err=4;
            }
    }
    beep();
    switch (err) {
        case 0 :
            sendmsg("OUTPUT1",MESSAGE_o,0,18,"%s",isdefstr("BACKUPCO"));
            sendmsg("INPUT1",MESSAGE_i);
            break;
        case 1 :
            sendmsg("OUTPUT1",MESSAGE_o,0,18,"%s",isdefstr("DATAERRO"));
            break;
        case 2 :
        case 4 :
            sendmsg("OUTPUT1",MESSAGE_o,0,18,"%s",isdefstr("WRITEERR"));
            break;
        case 3 :
            sendmsg("OUTPUT1",MESSAGE_o,0,18,"%s",isdefstr("DELERROR"));
            break;
    }
    if (err) {
        switch (sendmsg("INPUT1",MESSAGE_i)) { case F10 : case ESC : return(1); }
        sendmsg("OUTPUT1",MESSAGE_R);
        G_form.curitem=-1;
    }
    return(1);
}

//************************************************************
//S backup all DBM directory to floppy (ZIP)
//R TRUE
 
INT cabackup(void)
{
    INT err=0;
    G_aerror=0;
    if ((G_lastkey!='Y')&&(G_lastkey!='y'))
        {
        beep();
        sendmsg("OUTPUT1",MESSAGE_S,1);
        sendmsg("OUTPUT1",MESSAGE_A,1);
        sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("BACKUPYN"));
        while (err==0) {
            switch (sendmsg("INPUT1",MESSAGE_i)) {
                case 'y' : case 'Y' : err=1; break;
                case 'n' : case 'N' : err=2; G_aerror=1; break;
                default  : beep();
            }
        }
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
        if (err==2) return(1);
    }
    err=0;
    beep();
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("INSERTDP"));
    switch (sendmsg("INPUT1",MESSAGE_i))
        {
        case F10 : case ESC :
            sendmsg("OUTPUT1",MESSAGE_A,0);
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
            return(1);
        }

    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
   
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("BACKUPPW"));

    switch (sendmsg("DISK",MESSAGE_T,G_backup,"*.*"))
        {
        case (-1) :
            err=1;
            break;
        case 0 :
            if (!sendmsg("DISK",MESSAGE_Z,"*.*",G_database,"CAPTURE.BAK",G_backup))
                {
                err=2;
                }
            break;
        default :
            if (!sendmsg("DISK",MESSAGE_D,"*.*",G_backup))
                {
                err=3;
                }
            else
                {
                if (!sendmsg("DISK",MESSAGE_Z,"*.*",G_database,"CAPTURE.BAK",G_backup))
                    {
                    err=4;
                    }
                }
        }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");

    beep();
    sendmsg("OUTPUT1",MESSAGE_A,1);
    switch (err)
        {
        case 0 :
//            G_aerror=1;       // N to backup also generates this!!!!
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("BACKUPCO"));
            break;
        case 1 :
            G_aerror=-1;
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("DATAERRO"));
            break;
        case 2 :
        case 4 :
            G_aerror=-2;
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("WRITEERR"));
            break;
        case 3 :
            G_aerror=-3;
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("DELERROR"));
            break;
    }
    sendmsg("INPUT1",MESSAGE_i);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
    return(1);
}

//************************************************************
//S restore all DBM directory from floppy (ZIP)
//R TRUE
 
INT carestor(void)
{
    INT err=0;
    G_aerror=0;
    beep();
    sendmsg("OUTPUT1",MESSAGE_S,1);
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("RESTORYN"));
    while (err==0) {
        switch (sendmsg("INPUT1",MESSAGE_i)) {
            case 'y' : case 'Y' : err=1; break;
            case 'n' : case 'N' : err=2; break;
            default  : beep();
        }
    }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
    if (err==2) return(1);
    err=0;
    beep();
    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("INSERTDP"));

    switch (sendmsg("INPUT1",MESSAGE_i)) {
        case F10 :
        case ESC :
            sendmsg("OUTPUT1",MESSAGE_A,0);
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
            return(1); 
    }

    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");

    sendmsg("OUTPUT1",MESSAGE_A,1);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("RESTORPW"));

    switch (sendmsg("DISK",MESSAGE_T,G_backup,"*.*")) {
        case (-1) :
        case 0    :
            err=1;
            break;
        default :
            if (!sendmsg("DISK",MESSAGE_UZ,"CAPTURE.BAK",G_backup)) err=1;
    }
    sendmsg("OUTPUT1",MESSAGE_A,0);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");

    beep();
    sendmsg("OUTPUT1",MESSAGE_A,1);
    switch (err) {
        case 0 :
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("RESTORCO"));
            break;
        case 1 :
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("DATAERRO"));
            break;
    }
    sendmsg("INPUT1",MESSAGE_i);
    sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
    return(1);
}

//************************************************************
//S Build a printer list
//R TRUE

INT bprnlist(void)
{
    CHAR **list,tmp[LENOFTEMPINTSTR],*t;
    INT i,j;
    sendmsg("DBM",MESSAGE_e,"display");
    list=MALLOC(PRINTERLISTQ*sizeof(CHAR *));
    if (list!=NULL)
        {
        i=(INT)sendmsg("OUTPUT2",MESSAGE_PL,list);
        if (i!=0)
            {
            for (j=0;j<i;j++)
                {
                sprintf(tmp,"%d",j);
                sendmsg("DBM",MESSAGE_p,"display","num1",tmp);
                sendmsg("DBM",MESSAGE_p,"display","num2","0");
                t=strtok(list[j],"^");
                if (t!=NULL) {
                    sendmsg("DBM",MESSAGE_p,"display","field2",t);
                    t=strtok(NULL,"^");
                    if (t!=NULL) {
                        sendmsg("DBM",MESSAGE_p,"display","field1",t);
                    }
                }
                sendmsg("DBM",MESSAGE_w,"display");
                FREE(list[j]);
                }
            }
        FREE(list);
        }
    return(1);
}

#ifdef PDFSCANNER
//****************************************************************
//S check input string to see if it is a valid PDF417 input barcode
//P char string input
//P integer length
//R new pointer to string, or NULL

UCHAR *chkpdfstr(UCHAR *s,INT l)
{
    INT j,k;
    UCHAR c,i;
    UCHAR *a,*b;
    while ((*s)&&(*s!=STX)) { // Skip all input until STX
        s++;
    }
    b=a=s;
    a+=l;
    while ((a>s)&&(*a!=ETX)) a--;  // find last ETX
    if (a==s) return(NULL);
    c=0;
    while (b<=a) c^=*(b++)&0xFF;   // build LRC
    *a=0;                          // get LRC from rx-buf
    a++;
    i=(*(a)&0xFF);
    j=k=0;
    if (c==i) {                     // if LRC the same
        s++;
        for (j=0;j<a-s;j++) {
            if (*(s+k)==DLE) k++;   // Expand out all DLE codes
            *(s+j)=*(s+k);
            k++;
        }
        return(s);                  // return new string
    }
    return(NULL);                   // LRC fail
}

//****************************************************************
//S examine barcode data to see if valid and return type if so.
//P char string barcode
//R integer barcode type (no version), zero if bad

INT bartype(UCHAR *s)
{
    if ((*s=='A')&&(*(s+1)=='^')) return(16);
    G_office=*((LONG *)s);                // get office code
    if (!isfcdcode(G_office)) return(0);  // check office code is %11
    G_week  =*(s+4);                      // get week
    G_type  =*(s+5);                      // get bar type
    G_first =*((INT *)(s+6));             // get first entry
    G_last  =*((INT *)(s+8));             // get last entry
    if ((G_type&0x0F)!=1) G_region=*((INT *)(s+10)); // if not cash account get region
    return(G_type&0x0F);                  // return type (mask out version)
}

//****************************************************************
//S return the value of a number bits in buf at pos bitpos length bitlen must be<8
//P Uchar buffer address
//P integer bit position
//P bit length
//R unsigned 8 bit char result

UCHAR BitGet(UCHAR *buf,INT bitpos,UCHAR bitlen)
{
    UINT tb;
    buf+=bitpos/8;
    tb=(UINT)*(buf++)<<8;
    tb|=(UINT)*(buf);
    tb>>=(16-bitlen)-(bitpos%8);
    tb&=(0xFF>>(8-bitlen));
    return((UCHAR)tb);
}

//****************************************************************
//S return three bit number at pos on buf
//P buffer address
//P integer position in buffer
//R unsigned 8 bit number

UCHAR Get3Bit(UCHAR *buf,INT pos)
{
    return BitGet(buf,pos*3,3);
}

//****************************************************************
//S return the value of a number at bitpos in buf for bitsize(must be <32)
//P buffer address
//P integer bit position
//P integer bit length
//R unsigned long value

ULONG GetBitNum(UCHAR *buf,INT bitpos,UCHAR bitsize)
{
    ULONG val;
    if (bitsize<=8) {
        val=(ULONG)BitGet(buf,bitpos    ,bitsize);
    } else if (bitsize<=16) {
        val=(ULONG)BitGet(buf,bitpos    ,8);
        val<<=bitsize-8;
        val|=(ULONG)BitGet(buf,bitpos+8 ,bitsize-8);
    } else if (bitsize<=24) {
        val=(ULONG)BitGet(buf,bitpos    ,8);
        val<<=8L;
        val|=(ULONG)BitGet(buf,bitpos+8 ,8);
        val<<=bitsize-16;
        val|=(ULONG)BitGet(buf,bitpos+16,bitsize-16);
    } else {
        val=(ULONG)BitGet(buf,bitpos    ,8);
        val<<=8L;
        val|=(ULONG)BitGet(buf,bitpos+8 ,8);
        val<<=8L;
        val|=(ULONG)BitGet(buf,bitpos+16,8);
        val<<=bitsize-24;
        val|=(ULONG)BitGet(buf,bitpos+24,bitsize-24);
    }
    return val;
}

//****************************************************************
//S set the value of a number bits in buf at pos bitpos to val length bitlen must be<8 
//P buffer address
//P integer position to set
//P 8bit value to set (UCHAR)
//P unsigned char number of bits

void BitAssign(UCHAR *buf,INT bitpos,UCHAR val,UCHAR bitlen)
{
    UINT tb;
    tb=(INT)val;
    tb<<=(16-bitlen)-(bitpos%8);
    buf+=bitpos/8;
    *(buf++)|=(UCHAR)((tb>>8)&0xFF);
    *buf    |=(UCHAR)( tb    &0xFF);
}

//****************************************************************
//S set three bit number at pos on buf to val
//P buffer address
//P integer position to set
//P 8 bit value

void Set3Bit(UCHAR *buf,INT pos,UCHAR val)
{
    BitAssign(buf,pos*3,val,3);
}

//****************************************************************
//S set the value of a number at bitpos in buf to val for bitsize(must be <32)
//P buffer address
//P integer position to set
//P integer 32 bit value
//P integer 8 bit no. of bits to set

void SetBitNum(UCHAR *buf,INT bitpos,ULONG val,UCHAR bitsize)
{
    UCHAR mask=0xFF;
    mask>>=8-(bitsize%8);
    if (!mask) mask=0xFF;
    if (bitsize<=8) {
        BitAssign(buf,bitpos   ,(UCHAR)(val)&mask,bitsize);
    } else if (bitsize<=16) {
        BitAssign(buf,bitpos   ,(UCHAR)(val>>(bitsize-8))&0xFF,8);
        BitAssign(buf,bitpos+8 ,(UCHAR)(val)&mask,bitsize-8);
    } else if (bitsize<=24) {
        BitAssign(buf,bitpos   ,(UCHAR)(val>>(bitsize-8 ))&0xFF,8);
        BitAssign(buf,bitpos+8 ,(UCHAR)(val>>(bitsize-16))&0xFF,8);
        BitAssign(buf,bitpos+16,(UCHAR)(val)&mask,bitsize-16);
    } else {
        BitAssign(buf,bitpos   ,(UCHAR)(val>>(bitsize-8 ))&0xFF,8);
        BitAssign(buf,bitpos+8 ,(UCHAR)(val>>(bitsize-16))&0xFF,8);
        BitAssign(buf,bitpos+16,(UCHAR)(val>>(bitsize-24))&0xFF,8);
        BitAssign(buf,bitpos+24,(UCHAR)(val)&mask,bitsize-24);
    }
}

//****************************************************************
//S set a cash account line values in the barcode buffer
//P integer line number
//P integer quantity
//P long integer value
//P integer offset in buffer
//P address of buffer
//R returns the (new) integer offset in the buffer

INT SetCALine(INT lineno,INT qty,LONG val,INT ofs,UCHAR *buf)
{
    INT valsize,qtysize,blktype;

    if ((qty==0)&&(val==0L)) {
        if (G_first!=(-1)) Set3Bit(buf+10,lineno-G_first,0);
        return ofs;
    }
    if (G_first==(-1)) G_first=lineno;
    G_last=lineno;
    if        (qty<16) {
        qtysize=1;
    } else if (qty<128) {
        qtysize=2;
    } else if (qty<1024) {
        qtysize=3;
    } else {
        qtysize=4;
    }
    if        (val<16384L) {
        valsize=1;
    } else if (val<131072L) {
        valsize=2;
    } else if (val<1048576L) {
        valsize=3;
    } else {
        valsize=4;
    }
    switch (valsize) {
        case 1 :
            switch (qtysize) {
                case 1 : blktype=1; break;
                case 2 : blktype=4; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 2 :
            switch (qtysize) {
                case 1 : blktype=2; break;
                case 2 : blktype=4; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 3 :
            switch (qtysize) {
                case 1 : blktype=3; break;
                case 2 : blktype=5; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 4 :
            blktype=7;
            break;
    }
    switch (blktype) {
        case 1 : valsize=14; qtysize= 4; break;
        case 2 : valsize=17; qtysize= 4; break;
        case 3 : valsize=20; qtysize= 4; break;
        case 4 : valsize=17; qtysize= 7; break;
        case 5 : valsize=20; qtysize= 7; break;
        case 6 : valsize=20; qtysize=10; break;
        case 7 : valsize=32; qtysize=16; break;
    }
    if ((ofs+valsize+qtysize)>(CABUFSIZE*8) ) {
        G_caerror=1;
        return ofs;
    }
    Set3Bit(buf+10,lineno-G_first,blktype);
    SetBitNum(buf+10,ofs,(LONG)qty,qtysize);
    SetBitNum(buf+10,ofs+qtysize,val,valsize);
    ofs+=valsize+qtysize;
    return ofs;
}

//****************************************************************
//S Get the quantity from the caform database record(lineno)
//P integer line number
//R returns the integer quantity 

INT GetCAQty(INT lineno)
{
    CHAR tmp[80];
    if (sendmsg("DBM",MESSAGE_r,"caform",(LONG)lineno+1)) {
        if (sendmsg("DBM",MESSAGE_g,"caform","quantity",tmp)) {
            if (tmp[0]=='-')
                return atoi(&tmp[1]);
            else
                return atoi(tmp);
        }
    }
    return(0);
}

//****************************************************************
//S Get the value from the caform database record(lineno)
//P integer line number
//R returns the long amount value
 
LONG GetCAVal(INT lineno)
{
    CHAR tmp[80];
    if (sendmsg("DBM",MESSAGE_r,"caform",(LONG)lineno+1)) {
        if (sendmsg("DBM",MESSAGE_g,"caform","amount",tmp)) {
            if (tmp[0]=='-')
                return atol(&tmp[1]);
            else
                return atol(tmp);
        }
    }
    return(0L);
}

//****************************************************************
//S Setup the barcode buffer for all the lines in the Cash account.
//P buffer address
//R new integer offset

INT SetCALines(UCHAR *buf)
{
    INT i,j,ofs;
    G_caerror=0;
    memset(buf,0,CABUFSIZE);
    *((LONG*)buf)=G_office;
    *(buf+4)=G_week;
    *(buf+5)=0x11;              // 0x01=cash account 0x10=version 1
    G_first=(-1);
    ofs=1032;
    for (i=0;i<344;i++) {
        ofs=SetCALine(i,GetCAQty(i),GetCAVal(i),ofs,buf);
        if (G_caerror==1) break;
    }
    if (G_first==(-1)) { // no cash account data
        G_first=1000;
        G_last=0;
        ofs=1;
        *((INT*)(buf+6))=G_first;
        *((INT*)(buf+8))=G_last;
        return ofs;
    }
    *((INT*)(buf+6))=G_first;
    *((INT*)(buf+8))=G_last;
    i=((((G_last+1)-G_first)*3)+7)/8;
    for (j=0;j<((ofs-1032)+7)/8;j++) buf[i+j+10]=buf[139+j];
    ofs=(ofs-1032)+(i*8);
    return ofs;
}

//****************************************************************
//S Pack a text string str of length slen into a base 64 number at pos bitpos in buf
//P char string to work with
//P address of buffer to load
//P integer offset to work from
//P integer length of string to work with
//R (new) resultant integer offset

INT paktext(CHAR *str,UCHAR *buf,INT bitofs,INT slen)
{
    while (slen) {
        if ((*str>='0')&&(*str<='9')) {
            BitAssign(buf,bitofs,(*str)-'0',6);
        } else if ((*str>='A')&&(*str<='Z')) {
            BitAssign(buf,bitofs,((*str)-'A')+10,6);
        } else if ((*str>='a')&&(*str<='z')) {
            BitAssign(buf,bitofs,((*str)-'a')+36,6);
        } else if  ((*str==' ')||(*str==0)) {
            BitAssign(buf,bitofs,62,6);
        } else {
            BitAssign(buf,bitofs,63,6);
        }
        bitofs+=6;
        str++;
        slen--;
    }
    return bitofs;
}

//****************************************************************
// Pack a number numb of length nlen into a base 64 number at pos bitpos in buf
//P long integer to be put into buffer
//P addres of buffer
//P integger current offset to work at
//P length of the number
//R new integer resultant offset

INT paknumb(LONG numb,UCHAR *buf,INT bitofs,UINT nlen)
{
    if (nlen) {
        if (nlen>10) nlen=10;
        SetBitNum(buf,bitofs,numb,G_nfl2bit[nlen]);
        bitofs+=G_nfl2bit[nlen];
    }
    return bitofs;
}

//****************************************************************
//S Unpack a text string str of length slen into a base 64 number at pos bitpos in buf
//P char String to work with - doesn't seem to set a string delim
//P buffer address
//P integer offset to work from
//P integer string length expected
//R new buffer offset

INT unpaktext(CHAR *str,UCHAR *buf,INT bitofs,INT slen)
{
    while (slen) {
        *str++=b62nums[(INT)GetBitNum(buf,bitofs,6)];
        bitofs+=6;
        slen--;
    }
    return bitofs;
}

//****************************************************************
//S Unpack a number numb of length nlen into a base 64 number at pos bitpos in buf
//P Char string of number to work with
//P buffer address
//P integer offset to work from
//P unsigned integer length of number - gets limited to 10
//R new integer offset

INT unpaknumb(CHAR *numb,UCHAR *buf,INT bitofs,UINT nlen)
{
    if (nlen) {
        if (nlen>10) nlen=10;
        sprintf(numb,"%ld",GetBitNum(buf,bitofs,G_nfl2bit[nlen]));
        bitofs+=G_nfl2bit[nlen];
    }
    return bitofs;
}

//****************************************************************
//S build record list using primary key
//P Store name
//P number of fields
//R TRUE if OK else FALSE (e.g. malloc failed)

INT brl(CHAR *s,INT nf)
{
    LONG l;
    strcpy(G_reclistname,s);
    if (G_reclist!=NULL)
        {
        FREE(G_reclist);
        G_reclist=NULL;
        }
    G_reclistlen=0;
    if (G_reclist==NULL)
        {
        l=sendmsg("DBM",MESSAGE_nr,G_reclistname);
        if (!l)
            return(1);
        G_reclist=MALLOC((INT)l*sizeof(LONG));
        if (G_reclist!=NULL)
            {
            G_reclistlen=(INT)sendmsg("DBM",MESSAGE_bp,G_reclistname,nf,G_reclist);
            if (G_reclistlen)
                {
                G_reclist=REALLOC(G_reclist,G_reclistlen*sizeof(LONG));
                if (G_reclist!=NULL)
                    {
                    return(1);
                    }
                else
                    {
                    G_reclistlen=0;
                    }
                }
            else
                {
                FREE(G_reclist);
                G_reclist=NULL;
                return(1);
                }
            }
        }
    return(0);
}

//****************************************************************
//S Get Daily Cash Locked Up quantity & value from castock using record(line)
//P integer line to work with
//P long pointer to target value
//P long pointer to target quantity
//R BOOL TRUE

INT GetDCLULine(INT line,LONG *v,LONG *q)
{
    CHAR tmp[LENOFTEMPSTRDCLU];
    INT i,j;
    i=line/6;       // code 0-10 & 21
    if (i==11) i=21;
    j=(line%6)+1;   // day number 1-6 (id)
    sprintf(tmp,"%d",j);
    sendmsg("DBM",MESSAGE_p,"castock","id",tmp);
    sendmsg("DBM",MESSAGE_p,"castock","category","DC");
    sendmsg("DBM",MESSAGE_p,"castock","type","DC");
    sprintf(tmp,"%d",i);
    sendmsg("DBM",MESSAGE_p,"castock","code",tmp);
    if (sendmsg("DBM",MESSAGE_sp,"castock",4,FRST))
        {
        sendmsg("DBM",MESSAGE_r,"castock",(LONG)CURR);
        sendmsg("DBM",MESSAGE_g,"castock","amount",tmp);
        *v=atol(tmp);
        sendmsg("DBM",MESSAGE_g,"castock","quantity",tmp);
        *q=atol(tmp);
//        printf("ID %02d CODE %02d QNTY %ld VAL %ld\n",j,i,*q,*v);
        }
    else
        {
        *v=0L;
        *q=0L;
    } 
    return(1);
}

//****************************************************************
//S Set Daily Cash Locked Up quantity & values barcode buffer
//P buffer address
//R new integer offset

INT SetDCLULines(UCHAR *buf)
{
    INT i,ofs;
    LONG q,v;
    memset(buf,0,CABUFSIZE);
    *((LONG*)buf)=G_office;
    *(buf+4)=G_week;
    *(buf+5)=0x15;              // 0x04=DCLU 0x10=version 1
    *((INT*)(buf+8))=(6*12);
    *((INT*)(buf+10))=G_region;
    ofs=12*8;
    ofs=paktext(datestr(8),buf,ofs,6);
    for (i=0;i<(6*12);i++) {
        if (GetDCLULine(i,&v,&q)) {
            ofs=paknumb(v,buf,ofs,8);
            ofs=paknumb(q,buf,ofs,5);
        }
    }
    return(ofs);
}

//****************************************************************
//S Set up record lists for MVL barcode print

void SetUpMVL(void)
{
    INT i,st;
    CHAR tmp[LENOFTEMPMVL];

    sprintf(tmp,"%d",G_absweek);
    sendmsg("DBM",MESSAGE_p,"catxn","week",tmp);
    sprintf(tmp,"%d",G_uid);
    sendmsg("DBM",MESSAGE_p,"catxn","userid",tmp);
    sendmsg("DBM",MESSAGE_p,"catxn","stockid","0");
    sendmsg("DBM",MESSAGE_p,"catxn","category","RE");
    sendmsg("DBM",MESSAGE_p,"catxn","type","RE");
    sendmsg("DBM",MESSAGE_p,"catxn","code","85"); // 85 == V10
    if (!brl("catxn",6)) return;
    G_numvl[0]=G_reclistlen;
    G_vlist[0]=G_reclist;
    G_reclistlen=0;
    G_reclist=NULL;
    sendmsg("DBM",MESSAGE_p,"catxn","code","90"); // 90 == V11
    if (!brl("catxn",6)) return;
    G_numvl[1]=G_reclistlen;
    G_vlist[1]=G_reclist;
    G_reclistlen=0;
    G_reclist=NULL;
    if (G_shedlist!=NULL) FREE(G_shedlist);
    G_numshed=((G_numvl[1]+39)/40)+((G_numvl[0]+49)/50);
    G_shedlist=MALLOC(G_numshed*sizeof(MVLTOTS));
    if (G_shedlist==NULL) return;

    sprintf(tmp,"%d",G_absweek);
    sendmsg("DBM",MESSAGE_p,"catotal","id",tmp);
    sprintf(tmp,"%d",G_uid);
    sendmsg("DBM",MESSAGE_p,"catotal","userid",tmp);
    sendmsg("DBM",MESSAGE_p,"catotal","category","REMV");
    for (i=0;i<(G_numvl[0]+49)/50;i++) {  // 50 lines per page
        st=FRST;
        while (sendmsg("DBM",MESSAGE_sp,"catotal",3,st)) {
            sendmsg("DBM",MESSAGE_r,"catotal",(LONG)CURR);
            sendmsg("DBM",MESSAGE_g,"catotal","assoc1",tmp);
            if (atoi(tmp)==i+1) {
                sendmsg("DBM",MESSAGE_g,"catotal","code",tmp);
                if (atoi(tmp)==85) {
                    sendmsg("DBM",MESSAGE_g,"catotal","type",tmp);
                    st=atoi(tmp);
                    if (st>0) G_shedlist[i].s=st;
                    break;
                }
            }
            st=NEXT;
        }
    }
    for (i=0;i<(G_numvl[1]+39)/40;i++) {  // 40 lines per page
        st=FRST;
        while (sendmsg("DBM",MESSAGE_sp,"catotal",3,st)) {
            sendmsg("DBM",MESSAGE_r,"catotal",(LONG)CURR);
            sendmsg("DBM",MESSAGE_g,"catotal","assoc1",tmp);
            if (atoi(tmp)==i+1) {
                sendmsg("DBM",MESSAGE_g,"catotal","code",tmp);
                if (atoi(tmp)==90) {
                    sendmsg("DBM",MESSAGE_g,"catotal","type",tmp);
                    st=atoi(tmp);
                    if (st>0) G_shedlist[(G_numvl[0]+49)/50+i].s=st;
                    break;
                }
            }
            st=NEXT;
        }
    }
            
}

//****************************************************************
//S Get an MVL 10 barcode line for printing
//P integer s
//P integer line
//P long address n set by function from addinf1 n.b. not stragiht forward
//P long address r 7 bytes+delim <= addinf2 set by function
//P char address of single char rc set by function
//P long address of value set by function
//P long address of quantity set by function
//R integer

INT GetMVL10Line(INT s,INT line,LONG *n,CHAR *r,CHAR *rc,LONG *v,INT *q)
{
    CHAR tmp[LENOFTEMPSTRMVL];
    if (s*50+line>G_numvl[0])
        return(0);
    if (sendmsg("DBM",MESSAGE_r,"catxn",G_vlist[0][s*50+line]))
        {
        sendmsg("DBM",MESSAGE_g,"catxn","addinf1",tmp);
        if (tmp[0]!=' ')
            {
            tmp[1]=tmp[0];
            }
        *n=atol(&tmp[1]);
        sendmsg("DBM",MESSAGE_g,"catxn","addinf2",tmp);
        strncpy(r,tmp,7); r[8]=0;
        sendmsg("DBM",MESSAGE_g,"catxn","addinf3",tmp);
        *rc=tmp[0];
        sendmsg("DBM",MESSAGE_g,"catxn","quantity",tmp);
        *q=atoi(tmp);
        sendmsg("DBM",MESSAGE_g,"catxn","amount",tmp);
        *v=atol(tmp);
        return(1);
    } 
    return(0);
}

//****************************************************************
//S Return an number of MVL 10 barcode lines for printing in shedule s
//P integer s to process
//R integer:either zero, number mod 50, or 50

INT GetNumMVL10(INT s)
{
    if (s*50>G_numvl[0]) return(0);
    if (s*50+50>G_numvl[0]) return(G_numvl[0]%50);
    return(50);
}

//****************************************************************
//S set all MVL 10 barcode lines for printing
//P integer s to process
//P buffer address
//R integer offset in buffer

INT SetMVL10Lines(INT s,UCHAR *buf)
{
    INT i,ofs,q;
    LONG n,v;
    CHAR r[8],rc;
    memset(buf,0,CABUFSIZE);
    *((LONG*)buf)=G_office;
    *(buf+4)=G_week;
    *(buf+5)=0x12;              // 0x02=MVL10 0x10=version 1
    *((INT*)(buf+6))=G_shedlist[s].s;
    *((INT*)(buf+8))=GetNumMVL10(s);
    *((INT*)(buf+10))=G_region;
    ofs=12*8;
    ofs=paktext(datestr(8),buf,ofs,6);
    G_shedlist[s].q=0L;
    G_shedlist[s].v=0L;
    for (i=0;i<GetNumMVL10(s);i++)
        {
        if (GetMVL10Line(s,i,&n,r,&rc,&v,&q))
            {
            ofs=paknumb(n  ,buf,ofs,8);
            ofs=paktext(r  ,buf,ofs,7);
            ofs=paktext(&rc,buf,ofs,1);
            ofs=paknumb(q  ,buf,ofs,4);
            ofs=paknumb(v  ,buf,ofs,8);
            G_shedlist[s].q+=q;
            G_shedlist[s].v+=v;
            }
        }
    return(ofs);
}

//****************************************************************
//S Get an MVL 11 barcode line for printing
//P integer s
//P integer line
//P long address n set by function from addinf1 n.b. not stragiht forward
//P long address r 7 bytes+delim <= addinf2 set by function
//P char address of single char rc set by function
//P long address of value set by function
//P long address of quantity set by function
//R integer

INT GetMVL11Line(INT s,INT line,LONG *n,CHAR *r,CHAR *rc,LONG *v,INT *q)
{
    CHAR tmp[LENOFTEMPSTRMVL];
    if (s*40+line>G_numvl[1])
        return(0);
    if (sendmsg("DBM",MESSAGE_r,"catxn",G_vlist[1][s*40+line])) {
        sendmsg("DBM",MESSAGE_g,"catxn","addinf1",tmp);
        *rc=tmp[0];
        *n=atol(&tmp[1]);
        sendmsg("DBM",MESSAGE_g,"catxn","addinf2",tmp);
        strncpy(r,tmp,7); r[8]=0;
        sendmsg("DBM",MESSAGE_g,"catxn","quantity",tmp);
        *q=atoi(tmp);
        sendmsg("DBM",MESSAGE_g,"catxn","amount",tmp);
        *v=atol(tmp);
        return(1);
    } 
    return(0);
}

//****************************************************************
//S Return an number of MVL 11 barcode lines for printing in shedule s
//P integer s to process
//R integer:either zero, number mod 40, or 40

INT GetNumMVL11(INT s)
{
    if (s*40>G_numvl[1]) return(0);
    if (s*40+40>G_numvl[1]) return(G_numvl[1]%40);
    return(40);
}

//****************************************************************
//S set all MVL 11 barcode lines for printing
//P integer s to process
//P buffer address
//R integer offset in buffer

INT SetMVL11Lines(INT s,UCHAR *buf)
{
    INT i,ofs,q;
    LONG n,v;
    CHAR r[8],rc;
    memset(buf,0,CABUFSIZE);
    *((LONG*)buf)=G_office;
    *(buf+4)=G_week;
    *(buf+5)=0x13;              // 0x03=MVL11 0x10=version 1
    *((INT*)(buf+6))=G_shedlist[s+(G_numvl[0]+49)/50].s;
    *((INT*)(buf+8))=GetNumMVL11(s);
    *((INT*)(buf+10))=G_region;
    ofs=12*8;
    ofs=paktext(datestr(8),buf,ofs,6);
    G_shedlist[s+(G_numvl[0]+49)/50].q=0L;
    G_shedlist[s+(G_numvl[0]+49)/50].v=0L;
    for (i=0;i<GetNumMVL11(s);i++) {
        if (GetMVL11Line(s,i,&n,r,&rc,&v,&q))
            {
            ofs=paktext(&rc,buf,ofs,1);
            ofs=paknumb(n  ,buf,ofs,7);
            ofs=paktext(r  ,buf,ofs,7);
            ofs=paknumb(q  ,buf,ofs,4);
            ofs=paknumb(v  ,buf,ofs,7);
            G_shedlist[s+(G_numvl[0]+49)/50].q+=q;
            G_shedlist[s+(G_numvl[0]+49)/50].v+=v;
            }
        }
    return(ofs);
}

//****************************************************************
//S Get an MVL 570 barcode line for printing
//P integer s
//P integer line
//P long address n set by function from addinf1 n.b. not stragiht forward
//P long address of value set by function
//R integer

INT GetV570Line(INT s,INT line,LONG *n,LONG *v)
{
    INT i;
    for (i=0;i<G_numshed;i++) {
        if ((s*60+line+1)==G_shedlist[i].s) {
            *v=G_shedlist[i].q;
            *n=G_shedlist[i].v;
            return(1);
        }
    }
    *v=9999L;
    *n=99999999L;
    return(1);
}

//****************************************************************
//S Return an number of MVL 570 barcode lines for printing in shedule s
//P integer s to process
//R integer:either zero, number mod 60, or 60

INT GetNumV570(INT s)
{
    if (s*60>G_numshed) return(0);
    if (s*60+60>G_numshed) return(G_numshed%60);
    return(60);
}

//****************************************************************
//S set all MVL 570 barcode lines for printing
//P integer s to process
//P buffer address
//R integer offset in buffer

INT SetV570Lines(INT s,UCHAR *buf)
{
    INT i,ofs;
    LONG n,v;
    memset(buf,0,CABUFSIZE);
    *((LONG*)buf)=G_office;
    *(buf+4)=G_week;
    *(buf+5)=0x14;              // 0x04=V570 0x10=version 1
    *((INT*)(buf+6))=s;
    *((INT*)(buf+8))=GetNumV570(s);
    *((INT*)(buf+10))=G_region;
    ofs=12*8;
    ofs=paktext(datestr(8),buf,ofs,6);
    for (i=0;i<GetNumV570(s);i++)
        {
        if (GetV570Line(s,i,&n,&v))
            {
            ofs=paknumb(n,buf,ofs,8);
            ofs=paknumb(v,buf,ofs,4);
            }
        }
    return(ofs);
}

//****************************************************************
//S Get Cash account line info from barcode
//P char string to work with
//P integer line number
//P integer quantity
//P long integer value
//P integer offset in buffer
//R returns the (new) integer offset in the buffer

INT GetCALine(UCHAR *s,INT lineno,INT *qty,LONG *val,INT ofs)
{
    INT valsize,qtysize;

    switch (Get3Bit(s+10,lineno)) {
        case 0 : *qty=0; *val=0L; return ofs;

        case 1 : valsize=14; qtysize= 4; break;
        case 2 : valsize=17; qtysize= 4; break;
        case 3 : valsize=20; qtysize= 4; break;
        case 4 : valsize=17; qtysize= 7; break;
        case 5 : valsize=20; qtysize= 7; break;
        case 6 : valsize=20; qtysize=10; break;
        case 7 : valsize=32; qtysize=16; break;
    }
    *qty=(INT)GetBitNum(s+10,ofs,qtysize);
    *val=GetBitNum(s+10,ofs+qtysize,valsize);
    ofs+=valsize+qtysize;
    return ofs;
}

//****************************************************************
//S Get Cash account line in "caline"
//P integer line number
//P long integer value
//P integer quantity
//R BOOL TRUE = ok, FALSE = write fail

INT SetCAValQty(INT lineno,LONG val,INT qty)
{
    CHAR tmp[LENOFTEMPCAVSTR];
    sprintf(tmp,"%ld",G_office);
    if (!sendmsg("DBM",MESSAGE_p,"caline","code",tmp)) return(0);
    sprintf(tmp,"%d",G_week&0x7F);
    if (!sendmsg("DBM",MESSAGE_p,"caline","week",tmp)) return(0);
    sprintf(tmp,"%d",lineno);
    if (!sendmsg("DBM",MESSAGE_p,"caline","line",tmp)) return(0);
    sprintf(tmp,"%ld",val);
    if (!sendmsg("DBM",MESSAGE_p,"caline","amount",tmp)) return(0);
    sprintf(tmp,"%d",qty);
    if (!sendmsg("DBM",MESSAGE_p,"caline","quantity",tmp)) return(0);
    if (!sendmsg("DBM",MESSAGE_w,"caline"))
        return(0);
    return 1;
}

//****************************************************************
//S Get all Cash account line info from barcode
//P char address string to work with
//R BOOL TRUE=Ok, FALSE=fail

INT GetCALines(UCHAR *s)
{
    INT i,ofs;
    INT qty;
    LONG val;
    if ((G_last==0)&&(G_first==1000))
        {
        for (i=G_last;i<344;i++)
            if (!SetCAValQty(i,0L,0))
                return(0);
        return 1;
    }
    ofs=(((((G_last+1)-G_first)*3)+7)/8)*8;
    for (i=0;i<G_first;i++)
        if (!SetCAValQty(i,0L,0))
            return(0);
    for (i=G_last+1;i<344;i++)
        if (!SetCAValQty(i,0L,0))
            return(0);
    for (i=G_first;i<=G_last;i++)
        {
        ofs=GetCALine(s,i-G_first,&qty,&val,ofs);
        if (!SetCAValQty(i,val,qty))
            return(0);
        }
    return 1;
}

//****************************************************************
//S set the value of a number bits in buf at pos bitpos length bitlen must be<8
//P buffer address
//P integer position
//P 8 bit value
//P length to set (no. of bits)

void BitSet(UCHAR *buf,INT bitpos,UCHAR val,UCHAR bitlen)
{
    UINT tb;
    if (val)
        {
        val=0xFF>>(8-bitlen);
        tb=(INT)val;
        tb<<=(16-bitlen)-(bitpos%8);
        buf+=bitpos/8;
        *(buf++)|=(UCHAR)((tb>>8)&0xFF);
        *buf    |=(UCHAR)( tb    &0xFF);
        }
}

//****************************************************************
//S build a barcode print line from the "81031301..." data output by PDF std lib.
//P string to work
//P integer mag
//P integer line no.
//P pointer to var cont. buffer address
//R integer 0 = fail, cumulative size of impact othwerwise (j*mag)

INT buildline(CHAR *l,INT mag,INT lno,UCHAR **buf)
{
    INT i,j,k,m;
    j=0;
    for (i=0;i<strlen(l);i++) {
        if (isdigit(l[i])) j+=(l[i]-'0');
    }
    j*=mag;
    buf[lno]=MALLOC((j+7)/8+1);
    if (buf[lno]==NULL) return(0);
    memset(buf[lno],0,(j+7)/8+1);
    j=0;
    for (i=0;i<strlen(l);i++) {
        k=l[i]-'0';
        for (m=0;m<k;m++) {
            BitSet(buf[lno],j,!(i&1),mag);
            j+=mag;
        }
    }
    return(j);
}

//****************************************************************
//S Print a pdf417 barcode
//P integer week
//P long integer office
//P integer region
//P integer number
//P integer barcode type
//R FALSE = fail, TRUE = OK

INT prpdfbar(INT week,ULONG office,INT region,INT num,INT bartype)
{
    CHAR  tmp[LENOFPDFIOBUF];
    UCHAR **buf;
    INT   i=0,j,k;
    INT   gdirect;
    FILE *fp;
    UCHAR *cabuf;
    G_week=week;
    G_office=office;
    G_region=region;

    gdirect=(INT)sendmsg("OUTPUT2",MESSAGE_GD); // get the graphics direction
    cabuf=MALLOC(CABUFSIZE);
    if (cabuf==NULL)
        return(0);
    if ((fp=fopen(PDF417,"wb"))!=NULL)
        {
        switch (bartype) {
            case 1 :
                i=SetCALines(cabuf);
                break;
            case 2 :
                i=SetMVL10Lines(num,cabuf);
                break;
            case 3 :
                i=SetMVL11Lines(num,cabuf);
                break;
            case 4 :
                i=SetV570Lines(num,cabuf);
                break;
            case 5 :
                i=SetDCLULines(cabuf);
                break;
            default :   
                fclose(fp);
                FREE(cabuf);
                return(0);
        }
        fwrite(cabuf,1,10+((i+7)/8),fp);
        fclose(fp);
        FREE(cabuf);
        buf=MALLOC(130*sizeof(UCHAR *));
        if (buf==NULL) return(0);
        unlink("PDF417OP.GPA");
        system("genpdf PDF417.GPA PDF417OP.GPA");
        i=0;
        if ((fp=fopen(PDF417OP,"r"))!=NULL) {
            while (fgets(tmp,LENOFPDFIOBUF-1,fp)!=NULL) {
                if (isdigit(tmp[0])) j=buildline(tmp,gdirect?3:1,i++,buf); // HP
            }
            fclose(fp);
            for (k=i;k<i+4;k++)
                {
                buf[k]=MALLOC((j+7)/8+1);
                if (buf[k]==NULL)
                    return(0);
                memset(buf[k],0,(j+7)/8+1);
                }
            sendmsg("OUTPUT2",MESSAGE_PGBLOCK,buf,i,j);
            }
        FREE(buf);
        }
    else
        {
        FREE(cabuf);
        return(0);
        }
    return(1);
}

//***************************************************************************
//S Setup tax disk variables from barcode buffer
//P barcode buffer

void settaxvars(CHAR *buf)
{
    CHAR *t,b[20];
    buf++;
    t=strtok(buf,"^");
    setv("TAXADDR1",t);
    t=strtok(NULL,"^");
    setv("TAXADDR2",t);
    t=strtok(NULL,"^");
    setv("TAXADDR3",t);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXADDR4",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0; 
    t=b+strlen(b)-2; *t=0; t++; // get check byte
    setv("TAXRGNUM",b);
    setv("TAXRGCHK",t);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXCLASS",lookupc[atoi(b)]);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXVMAKE",lookupm[atoi(b)]);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    if (atoi(b)==0)
        setv("TAXENGIN","N/A");
    else
        setv("TAXENGIN",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    if (atoi(b)==0)
        setv("TAXWEIGT","N/A");
    else
        setv("TAXWEIGT",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    if (atoi(b)==0)
        setv("TAXTCONF","N/A");
    else
        setv("TAXTCONF",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    if (atoi(b)==0)
        setv("TAXSEATS","N/A");
    else
        setv("TAXSEATS",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXTWMTH",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXSXMTH",b);
    t=strtok(NULL,"^");
    strcpy(b,t);
    b[strlen(b)-1]=0;
    setv("TAXDLINE",b);
    setv("TAXSNUMB","");
    setv("TAXPEROD","12");
    setv("TAXCLERK","");
}

//***************************************************************************
//S send Taxdisk vars to prn
//R TRUE

INT sendprn(void)
{
    CHAR *tbuf[TAXBUFPTRQ];
    CHAR *var,tmp[LENOFTMPTAXBUF];
    INT i,j;
    LONG price;

//    static INT first=1;
//    if (first) { // SETUP PORT FOR PRINTER 1st time in
//        sendmsg("INOUT1",MESSAGE_I,6,9600,8,'n',1);
//        first=0;
//    }

    for (i=0;i<TAXBUFPTRQ;i++) {                            // setup print buffer
        tbuf[i]=STRDUP("                        ");
    }
    memcpy(&(tbuf[11][8]),datestr(UKDATE),8);       // Date
    var=cagetvar("TAXRGNUM");                       // Reg No.
    memcpy(&(tbuf[0][0]),var,strlen(var));          
    var=cagetvar("TAXRGCHK");                       // Reg Check No.
    memcpy(&(tbuf[0][11]),var,strlen(var));          
    var=cagetvar("TAXCLASS");                       // Vehicle Class
    memcpy(&(tbuf[3][0]),var,strlen(var));
    var=cagetvar("TAXVMAKE");                       // Vehicle Make
    memcpy(&(tbuf[6][0]),var,strlen(var));
    var=cagetvar("TAXWEIGT");                       // Unladen Weight
    if ((i=atoi(var))!=0) {
        sprintf(&tbuf[0][16],"%2d000 Kg",i);
    } else {
        var=cagetvar("TAXENGIN");                   // Engine Capacity
        if ((i=atoi(var))!=0) {
            sprintf(&tbuf[0][16],"%5d cc",i);
        } else {
            var=cagetvar("TAXSEATS");               // Seating Capacity
            sprintf(&tbuf[0][16],"%2d Seats",i);
        }
    }
    var=cagetvar("TAXTCONF");                       // Axle Configuration
    if ((i=atoi(var))!=0) sprintf(&tbuf[3][16],"%8s",axleconf[i]);
    var=cagetvar("TAXPEROD");                       // Period Required
    if (*var=='6') {
        tbuf[9][2]='6';
        price=atol(cagetvar("TAXSXMTH"));           // 6 Months
    } else {
        tbuf[9][2]='1';
        tbuf[9][3]='2';
        price=atol(cagetvar("TAXTWMTH"));           // 12 Months
    }
    sprintf(tmp,"%ld.%02ld",price/100L,price%100L); // 9999.99
    for (i=0;i<strlen(tmp);i++)
        tbuf[9][(22-strlen(tmp))+i]=tmp[i];
    var=cagetvar("TAXSNUMB");                       // Tax Disk Serial Number
    memcpy(&(tbuf[13][8]),var,strlen(var));
    var=cagetvar("TAXCLERK");                       // Clerk Id
    memcpy(&(tbuf[9][11]),var,strlen(var));

    sprintf(tmp,"%c@%c!%c",27,27,0);                // Reset Printer set 5*7
    sendmsg("INOUT1",MESSAGE_Ol,0,tmp,5);
    sprintf(tmp,"%cV%c",27,1);                      // Select Rotation
    sendmsg("INOUT1",MESSAGE_On,0,tmp);
    sprintf(tmp,"%cc0%c",27,4);                     // Select Slip print
    sendmsg("INOUT1",MESSAGE_On,0,tmp);
    sprintf(tmp,"%cf%c%c",27,1,1);                  // Set Paper accept delay
    sendmsg("INOUT1",MESSAGE_On,0,tmp);
    sprintf(tmp,"%c3%c\n",27,18);                   // Set feed spacing
    sendmsg("INOUT1",MESSAGE_On,0,tmp);

    for (i=0;i<24;i++) {
        sendmsg("INOUT1",MESSAGE_On,0,"    ");
        for (j=13;j>=0;j--) {
            sendmsg("INOUT1",MESSAGE_Ol,0,&tbuf[j][i],1);
        }
        sendmsg("INOUT1",MESSAGE_On,0,"\n");
    }
    // Release paper return to roll feed
    sprintf(tmp,"%c\n",12);                         // Release paper
    sendmsg("INOUT1",MESSAGE_On,0,tmp);
    sprintf(tmp,"%c@",27);                          // Reset Printer
    sendmsg("INOUT1",MESSAGE_On,0,tmp);
    for (i=0;i<14;i++) {                            // clear print buffer
        FREE(tbuf[i]);
    }
    return(1);
}

//***************************************************************************
//S Print Tax Disk
//R TRUE

INT taxdiskp(void)
{
    sound(3000); delay(100); nosound(); delay(50);
    sendmsg("INPUT1",MESSAGE_K,CF12,"NONE"," "); // Remove hotkey action
    if (G_savetbuf!=NULL)  {
        sound(3000); delay(100); nosound(); delay(50);
        if (isform("taxdisk")) {
            sound(1000); delay(100); nosound(); delay(50);
            settaxvars(G_savetbuf);              // get data from buffer
            runaction("DoTaxPrn");
        }
        FREE(G_savetbuf);                        // Release buffer
        G_savetbuf=NULL;
    }
    sendmsg("INPUT1",MESSAGE_A,18,scanpdf);      // Replace the scanning klf
    return(1);
}

//***************************************************************************
//S read barcode for Tax Disk
//P buffer read from taxdisk barcode
//P length of buffer

void readTaxDisk(UCHAR *s,INT len)
{
    G_savetbuf=MALLOC(len);                          // setup save buffer
    if (G_savetbuf==NULL) return;                    // malloc error
    sound(500); delay(100); nosound(); delay(50);
    memcpy(G_savetbuf,s,len);                        // save buffer
    sendmsg("INPUT1",MESSAGE_D,scanpdf);             // Remove the scanning klfunc
    sendmsg("INPUT1",MESSAGE_K,CF12,"TAXDISKP"," "); // Setup hotkey action
    sendmsg("INPUT1",MESSAGE_P,CF12);                // setup keystrokes to call 
    sendmsg("INPUT1",MESSAGE_P,KBDPUSHEND);          // Action "TAXDISKP"rint
    sound(500); delay(100); nosound(); delay(50);
}


//***************************************************************************
//S read DCLU
//P char string item to read

void readDCLU(UCHAR *s)
{
    CHAR tmp[LENOFREADTMP];
    CHAR date[LENOFREADDATE];
    INT i,ofs;
    ULONG v=0L,q=0L;

    sound(1000); delay(150); sound(5000); delay(300); nosound();

    ofs=12*8;
    ofs=unpaktext(date,s,ofs,6);

    sendmsg("DBM",MESSAGE_p,"dclusum","date",date);
    sendmsg("DBM",MESSAGE_p,"dclusum","detail","Y");
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"dclusum","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"dclusum","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"dclusum","region",tmp);
    sendmsg("DBM",MESSAGE_p,"dclusum","done","û");
    for (i=0;i<(6*12);i++) {
        ofs=unpaknumb(tmp,s,ofs,8);
        if ((i/6)!=11) v+=atol(tmp);
//        printf("LINE %02d VAL %s ",i,tmp);
        sendmsg("DBM",MESSAGE_p,"dclusum","amount",tmp);
        ofs=unpaknumb(tmp,s,ofs,5);
        if ((i/6)!=11) q+=atol(tmp);
//        printf("QNTY %s\n",tmp);
        sendmsg("DBM",MESSAGE_p,"dclusum","quantity",tmp);
        sprintf(tmp,"%d",i+1);
        sendmsg("DBM",MESSAGE_p,"dclusum","line",tmp);
        sendmsg("DBM",MESSAGE_w,"dclusum");
    }
    sendmsg("DBM",MESSAGE_p,"dclusum","line","0");
    sendmsg("DBM",MESSAGE_p,"dclusum","date",date);
    sendmsg("DBM",MESSAGE_p,"dclusum","detail","N");
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"dclusum","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"dclusum","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"dclusum","region",tmp);
    sendmsg("DBM",MESSAGE_p,"dclusum","done","û");
    sprintf(tmp,"%ld",v);
    sendmsg("DBM",MESSAGE_p,"dclusum","amount",tmp);
    sprintf(tmp,"%ld",q);
    sendmsg("DBM",MESSAGE_p,"dclusum","quantity",tmp);
    sendmsg("DBM",MESSAGE_w,"dclusum");

    sound(5000); delay(150); sound(1000); delay(300); nosound();

    if (G_intable) G_finredraw=0;
}

//***************************************************************************
//S read barcode for V570 and write to "mvlsum" store
//P char string item to read

void readv570(UCHAR *s)
{
    CHAR tmp[LENOFREADTMP];
    CHAR date[LENOFREADDATE];
    INT i,ofs;
    ULONG v=0L,q=0L;

    sound(1000); delay(150); sound(5000); delay(300); nosound();
    ofs=12*8;
    ofs=unpaktext(date,s,ofs,6);
    sendmsg("DBM",MESSAGE_p,"mvlsum","detail","Y");
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"mvlsum","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"mvlsum","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"mvlsum","region",tmp);
    for (i=0;i<G_last;i++) {
        sprintf(tmp,"%d",i+1); // Schedule no
        sendmsg("DBM",MESSAGE_p,"mvlsum","numb",tmp);
        sendmsg("DBM",MESSAGE_p,"mvlsum","line","0");
        ofs=unpaknumb(tmp,s,ofs,8);
        v+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvlsum","amount",tmp);
        ofs=unpaknumb(tmp,s,ofs,4);
        q+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvlsum","quantity",tmp);
        sendmsg("DBM",MESSAGE_p,"mvlsum","date","      ");
        sendmsg("DBM",MESSAGE_p,"mvlsum","done","X");
        sendmsg("DBM",MESSAGE_w,"mvlsum");
    }
    sendmsg("DBM",MESSAGE_p,"mvlsum","detail","N");
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"mvlsum","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"mvlsum","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"mvlsum","region",tmp);
    sprintf(tmp,"%d",G_first); // Schedule no
    sendmsg("DBM",MESSAGE_p,"mvlsum","numb",tmp);
    sprintf(tmp,"%d",G_last);  // number of entries
    sendmsg("DBM",MESSAGE_p,"mvlsum","line",tmp);
    sendmsg("DBM",MESSAGE_p,"mvlsum","date",date);
    sprintf(tmp,"%ld",v);
    sendmsg("DBM",MESSAGE_p,"mvlsum","amount",tmp);
    sprintf(tmp,"%ld",q);
    sendmsg("DBM",MESSAGE_p,"mvlsum","quantity",tmp);
    sendmsg("DBM",MESSAGE_p,"mvlsum","done","X");
    sendmsg("DBM",MESSAGE_w,"mvlsum");

    sound(5000); delay(150); sound(1000); delay(300); nosound();

    if (G_intable) G_finredraw=0;
}

//***************************************************************************
//S read barcode for MVL10/11 and write to "mvlsum" store - update V570
//P long integer value
//P long integer quantity
//P char string date
//P char string tmp

void updatesum(ULONG v,ULONG q,CHAR * date,CHAR * tmp)
{
    INT st;
    sendmsg("DBM",MESSAGE_p,"mvlsum","detail","Y");
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"mvlsum","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"mvlsum","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"mvlsum","region",tmp);
    sprintf(tmp,"%d",G_first); // Schedule no
    sendmsg("DBM",MESSAGE_p,"mvlsum","numb",tmp);
    if (sendmsg("DBM",MESSAGE_sp,"mvlsum",5,FRST)) {
        sendmsg("DBM",MESSAGE_r,"mvlsum",(LONG)CURR);
        sprintf(tmp,"%ld",v);
        sendmsg("DBM",MESSAGE_p,"mvlsum","amount",tmp);
        sprintf(tmp,"%ld",q);
        sendmsg("DBM",MESSAGE_p,"mvlsum","quantity",tmp);
        sendmsg("DBM",MESSAGE_p,"mvlsum","date",date);
        sendmsg("DBM",MESSAGE_p,"mvlsum","done","û");
        sendmsg("DBM",MESSAGE_w,"mvlsum");
    }
    st=FRST;
    while (sendmsg("DBM",MESSAGE_sp,"mvlsum",4,st)) {
        sendmsg("DBM",MESSAGE_r,"mvlsum",(LONG)CURR);
        sendmsg("DBM",MESSAGE_g,"mvlsum","done",tmp);
        if (tmp[0]=='X') return;
        st=NEXT;
    }
    sendmsg("DBM",MESSAGE_p,"mvlsum","detail","N");
    if (sendmsg("DBM",MESSAGE_sp,"mvlsum",4,FRST)) {
        sendmsg("DBM",MESSAGE_r,"mvlsum",(LONG)CURR);
        sendmsg("DBM",MESSAGE_p,"mvlsum","done","û");
        sendmsg("DBM",MESSAGE_w,"mvlsum");
        sound(3000); delay(100); sound(4000); delay(100);
        sound(2000); delay(100); sound(5000); delay(100); nosound();
    }
    
}

//***************************************************************************
//S read barcode for MVL10 and write to "mvlsum" store
//P char string item

void readMVL10(UCHAR *s)
{
    CHAR tmp[LENOFREADTMP];
    CHAR date[LENOFREADDATE];
    INT i,ofs;
    ULONG v=0L,q=0L;

    sound(1000); delay(150); sound(5000); delay(300); nosound();

    ofs=12*8;
    ofs=unpaktext(date,s,ofs,6);
    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"mvldet","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"mvldet","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"mvldet","region",tmp);
    for (i=0;i<G_last;i++) {
        sprintf(tmp,"%d",G_first); // Schedule no
        sendmsg("DBM",MESSAGE_p,"mvldet","numb",tmp);
        sprintf(tmp,"%d",i+1);    // Line no
        sendmsg("DBM",MESSAGE_p,"mvldet","line",tmp);
        ofs=unpaknumb(tmp,s,ofs,8);
        sendmsg("DBM",MESSAGE_p,"mvldet","dockit",tmp);
        ofs=unpaktext(tmp,s,ofs,7);
        sendmsg("DBM",MESSAGE_p,"mvldet","reg",tmp);
        ofs=unpaktext(tmp,s,ofs,1);
        sendmsg("DBM",MESSAGE_p,"mvldet","vc",tmp);
        ofs=unpaknumb(tmp,s,ofs,4);
        q+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvldet","quantity",tmp);
        ofs=unpaknumb(tmp,s,ofs,8);
        v+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvldet","amount",tmp);
        sendmsg("DBM",MESSAGE_w,"mvldet");
    }
    sound(5000); delay(150); sound(1000); delay(300); nosound();
    updatesum(v,q,date,tmp);

    if (G_intable) G_finredraw=0;
}

//***************************************************************************
//S read barcode for MVL11 and write to "mvlsum" store
//P char string item

void readMVL11(UCHAR *s)
{
    CHAR tmp[LENOFREADTMP];
    CHAR date[LENOFREADDATE];
    INT i,ofs;
    ULONG v=0L,q=0L;

    sound(1000); delay(150); sound(5000); delay(300); nosound();

    ofs=12*8;
    ofs=unpaktext(date,s,ofs,6);

    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"mvldet","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"mvldet","week",tmp);
    sprintf(tmp,"%d",G_region);
    sendmsg("DBM",MESSAGE_p,"mvldet","region",tmp);
    for (i=0;i<G_last;i++) {
        sprintf(tmp,"%d",G_first); // Schedule no
        sendmsg("DBM",MESSAGE_p,"mvldet","numb",tmp);
        sprintf(tmp,"%d",i+1);    // Line no
        sendmsg("DBM",MESSAGE_p,"mvldet","line",tmp);
        ofs=unpaktext(tmp,s,ofs,1);
        ofs=unpaknumb(&tmp[1],s,ofs,7);
        sendmsg("DBM",MESSAGE_p,"mvldet","dockit",tmp);
        ofs=unpaktext(tmp,s,ofs,7);
        sendmsg("DBM",MESSAGE_p,"mvldet","reg",tmp);
        sendmsg("DBM",MESSAGE_p,"mvldet","vc","+");
        ofs=unpaknumb(tmp,s,ofs,4);
        q+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvldet","quantity",tmp);
        ofs=unpaknumb(tmp,s,ofs,7);
        v+=atol(tmp);
        sendmsg("DBM",MESSAGE_p,"mvldet","amount",tmp);
        sendmsg("DBM",MESSAGE_w,"mvldet");
    }
    updatesum(v,q,date,tmp);

    sound(5000); delay(150); sound(1000); delay(300); nosound();

    if (G_intable) G_finredraw=0;
}

//***************************************************************************
//S read barcode for Cash account and write to "office" store
//P char string item

void readcash(UCHAR *s)
{
    CHAR tmp[LENOFREADCASH];

    sound(1000); delay(150); sound(5000); delay(300); nosound();

    sprintf(tmp,"%ld",G_office);
    sendmsg("DBM",MESSAGE_p,"office","code",tmp);
    sprintf(tmp,"%d",G_week);
    sendmsg("DBM",MESSAGE_p,"office","week",tmp);
    sendmsg("DBM",MESSAGE_p,"office","done","û");
    if (!GetCALines(s)) {
        sendmsg("DBM",MESSAGE_p,"office","done","X");
    }
    sendmsg("DBM",MESSAGE_w,"office");

    sound(5000); delay(150); sound(1000); delay(300); nosound();

    if (G_intable) G_finredraw=0;
}

//***************************************************************************
//S Scan comm port for pdf417 barcode 
//D If it's a cash account add 1 record to "office" and then add
//D each line of cash account to "caline"
//R BOOL TRUE=Ok FALSE=(malloc)Failed

INT scanpdf(void)
{
    UCHAR *buf,*s,e;
    INT l;
    static INT frst=0;

    buf=MALLOC(LENOFSCANPDFBUF);
    if (buf==NULL)
        return(0);
    memset(buf,0,LENOFSCANPDFBUF);
    if (!frst) {
        sendmsg("INOUT1",MESSAGE_I,0,9600,8,'n',1);
    }
    frst++;
    e=ENQ;
    sendmsg("INOUT1",MESSAGE_Ol,0,&e,1);
    if ((l=(INT)sendmsg("INOUT1",MESSAGE_P,0,buf,2000,ETX,DLE,1,0))!=0) {
        s=chkpdfstr(buf,l);
        if (s!=NULL) {
            e=ACK;
            sendmsg("INOUT1",MESSAGE_Ol,0,&e,1);
            switch (bartype(s)) {
                case 1 :
                    readcash(s);
                    break;
                case 2 :
                    readMVL10(s);
                    break;
                case 3 :
                    readMVL11(s);
                    break;
                case 4 :
                    readv570(s);
                    break;
                case 5 :
                    readDCLU(s);
                    break;
                case 16 :
                    readTaxDisk(s,l);
                    break;
                default :
                    sound(400);
                    delay(800);
                    nosound();
            }
        } else {
            e=NAK;
            sendmsg("INOUT1",MESSAGE_Ol,0,&e,1);
        }
    }
    FREE(buf);
    return(1);
}

//***************************************************************************
//S setup scan comm port for a barcode every second
//R BOOL TRUE

INT pdf417(void)
{
    sendmsg("INPUT1",MESSAGE_A,18,scanpdf);
    return(1);
}

//***************************************************************************
//S print pdf417 cash account barcode
//R BOOL TRUE

INT cabar(void)
{
    INT w;
    LONG o;
    w=atoi(cagetvar("WRKWK"));
    while (w<0) w+=52;
    w%=52;
    o=atol(cagetvar("ODCODE"));
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"Post Office PDF417 Symbols for Cash Account - Office %ld Week %d\n\r",o,w);
    prpdfbar(w,o,0,0,1);    // Cash account barcode
    sendmsg("OUTPUT2",MESSAGE_SS,"FORMFEED",0);
    return(1);
}

//***************************************************************************
//S print pdf417 daily cash locked up barcode (CHANGE FUNCTION NAME)
//R BOOL TRUE

INT dcslubar(void)
{
    INT w;
    LONG o;
    w=atoi(cagetvar("WRKWK"));
    while (w<0) w+=52;
    w%=52;
    o=atol(cagetvar("ODCODE"));
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"Post Office PDF417 Symbols for Daily Cash Locked Up - Office %ld Week %d\n\r",o,w);
    prpdfbar(w,o,0,0,5);    // Daily Cash Locked Up barcode
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_SS,"FORMFEED",0);
    return(1);
}

//***************************************************************************
//S print pdf417 MVL barcodes
//R BOOL TRUE

INT mvlbar(void)
{
    INT r,w,i;
    INT gdirect;
    LONG o;
    w=atoi(cagetvar("WRKWK"));
    G_absweek=w;
    SetUpMVL();
    while (w<0) w+=52;
    w%=52;
    o=atol(cagetvar("ODCODE"));
    r=atoi(cagetvar("ODRGCD"));
    gdirect=(INT)sendmsg("OUTPUT2",MESSAGE_GD); // get the graphics direction
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"Post Office PDF417 Symbols for Office %ld Week %d [CAPTURE]",o,w);
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"\nMVL10's - %d Schedule(s)",(G_numvl[0]+49)/50);
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    for (i=0;i<(G_numvl[0]+49)/50;i++) {
        prpdfbar(w,o,r,i,2);    // MVL10 barcode Schedule
        if (gdirect) sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    }
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"%c\nMVL11's - %d Schedule(s)",10,(G_numvl[1]+39)/40);
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    for (i=0;i<(G_numvl[1]+39)/40;i++) {
        prpdfbar(w,o,r,i,3);    // MVL11 barcode Schedule
        sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    }
    sendmsg("OUTPUT2",MESSAGE_o,(-1),0,"%c\nV570's - %d Schedule(s)",10,(G_numshed+59)/60);
    sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    for (i=0;i<(G_numshed+59)/60;i++) {
        prpdfbar(w,o,r,i,4);    // V570 barcode Schedule 1
        sendmsg("OUTPUT2",MESSAGE_SS,"NORMY",0);
    }
    sendmsg("OUTPUT2",MESSAGE_SS,"FORMFEED",0);

    G_numvl[0]=0; G_numvl[1]=0; G_numshed=0;
    if (G_vlist[0]!=NULL) FREE(G_vlist[0]); G_vlist[0]=NULL;
    if (G_vlist[1]!=NULL) FREE(G_vlist[1]); G_vlist[1]=NULL;
    if (G_shedlist!=NULL) FREE(G_shedlist); G_shedlist=NULL;
    return(1);
}
#endif          // PDFSCANNER

//****************************************************************
//S reset v[0]-50 to 0
//R BOOL TRUE

INT resetvrs(void)
{
    memset(G_vars,0,sizeof(G_vars));
    return(1);
}

//****************************************************************
//S Set all the V[0] - V[49] variables to -1
//D Variation of resetvrs - change these to accept a parameter, the
//D value we wish to set the variables to???
//R BOOL TRUE

INT setvrsng(void)
{
    memset(G_vars,-1,sizeof(G_vars));
    return(1);
}

//*********************************
static LONG *G_varssave=NULL;
static INT  Pushcount=0;        // For use in debugging

//****************************************************************
//S Malloc a new set of globals (V[0] - V[49]) cloning the existing values
//R BOOL TRUE

INT pushvrs(void)
{
    G_varssave = MALLOC(sizeof(G_vars));
    memcpy(G_varssave,G_vars,sizeof(G_vars));  // copy
    Pushcount++;
    return(1);
}

//****************************************************************
//S Deallocate the temporary globals (V[0] - V[49] set) and restore saved values.
//D Only use after a call to pushvrs.
//R BOOL TRUE

INT popvrs(void)
{
    if (G_varssave)
        {
        memcpy(G_vars,G_varssave,sizeof(G_vars));  // copy variables back
        FREE(G_varssave);
        G_varssave = NULL;
        }
    Pushcount--;
    return(1);
}

//***************************************************************************
//S Function to sort pension and allowance data according to group and value
//P pointer to array sort item 1
//P pointer to array sort item 2
//R integer = {-2, -1, 0, 1, 2}

INT pealcmp(PEALSORT *a,PEALSORT *b)
{
    if (a->grp>b->grp) return(2);
    if (a->grp<b->grp) return(-2);
    if (a->unitval>b->unitval) return(1);
    if (a->unitval<b->unitval) return(-1);
    return(0);
}

//***************************************************************************
//S Function to build/create double entry check datastor
//D Relies upon 4GL code setting GTYPE - if set indicates include bulk entries
//D	                         GFLAG1 - if set indicates mark transactions
//D	                                  as to which cadec group they belong to.
//D Value of GERROR returns to 4GL code number of non bulk entry transactions
//D found.
//R BOOL TRUE=Ok, FALSE=Failed

INT builddec(void)
{
    INT i,j,s,g,q,m;
    INT done=0;
    LONG unitval,amount;
    INT numbuf=10,nb=0;
    CHAR tmp[80];
    PEALSORT *b;

    G_error=0;
    if ((s=snum("catxn"))<0) return(0);
    if ((G_reclist==NULL)&&(G_reclistlen==0)) return(0);
    b=MALLOC(sizeof(PEALSORT)*numbuf);
    if (b==NULL) return(0);
    G_peallist=MALLOC(sizeof(LONG)*G_reclistlen);
    if (G_peallist==NULL) return(0);
    for (i=0;i<G_reclistlen;i++) {
        if (sendmsg("DBM",MESSAGE_r,"catxn",G_reclist[i])) {
            sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)13,tmp); // addinf1 =13
            g=atoi(tmp);
            sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)9 ,tmp); // quantity=9
            q=atoi(tmp);
            sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)10,tmp); // unitval =10
            unitval=atol(tmp);
            if (G_type) {
                sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)11,tmp); // amount =11
                amount=atol(tmp);
            }
            if (!unitval) G_error++;		// Increment count of txns (excluding bulk entries)
            if ((G_type)||(unitval)) {    // ignore Bulk entries if G_type==0
                sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)12,tmp); // assoc1  =12
                m=atoi(tmp);
                done=0;
                if (unitval!=0) {
                    for (j=0;j<nb;j++) {
                        if ((b[j].grp==g)&&(b[j].unitval==unitval)) {
                            b[j].mt+=m;
                            b[j].qty+=q;
                            done=1;
                            break;
                        }
                    }
                }  // else - must be a bulk entry which has a 0 unit value
                if (!done) {
                    if ((nb+1)>=numbuf) {
                        numbuf+=10;
                        b=REALLOC(b,sizeof(PEALSORT)*numbuf);
                        if (b==NULL) return(0);
                    }
                    b[nb].grp=g;
                    b[nb].unitval=unitval;
                    if (unitval==0) {         // Bulk entry
                        b[nb].amount=amount;
                    } else {
                        b[nb].amount=0;
                    }
                    b[nb].mt =m;                
                    b[nb].qty=q;
                    nb++;
                }
            } else { // remove bulk entry from list
                G_reclistlen--;
                for (j=i;j<G_reclistlen;j++) {
                    G_reclist[j]=G_reclist[j]+1;
                }
                i--;
            }
        }
    }
    G_peallistlen=G_reclistlen;
    memcpy(G_peallist,G_reclist,sizeof(LONG)*G_reclistlen);
    qsort(b,nb,sizeof(PEALSORT),(QSPTR)pealcmp);
    sendmsg("DBM",MESSAGE_e,"cadec");
    for (i=0;i<nb;i++) {
        sprintf(tmp,"%d",i);
        sendmsg("DBM",MESSAGE_p,"cadec","number",tmp);   // sorting index
        sprintf(tmp,"%d",b[i].grp);
        sendmsg("DBM",MESSAGE_p,"cadec","addinf1",tmp);  // group code
        sprintf(tmp,"%ld",b[i].unitval);
        sendmsg("DBM",MESSAGE_p,"cadec","unitval",tmp);  // unit value
        sprintf(tmp,"%d",b[i].qty);
        sendmsg("DBM",MESSAGE_p,"cadec","quantity",tmp); // quantity
        if (b[i].unitval!=0) {
            sprintf(tmp,"%ld",(LONG)b[i].qty*b[i].unitval);
        } else {
            sprintf(tmp,"%ld",b[i].amount);              // bulk entry
        }
        sendmsg("DBM",MESSAGE_p,"cadec","amount",tmp);   // total value
        sprintf(tmp,"%d",b[i].mt);
        sendmsg("DBM",MESSAGE_p,"cadec","assoc1",tmp);   // milk tokens
        sendmsg("DBM",MESSAGE_p,"cadec","checked","N");  // Checked flag
        sendmsg("DBM",MESSAGE_w,"cadec");
    }

    if (G_flag1)
    {
        INT index, found;

        // Go through the transaction list marking which cadec group each
        // transaction belongs to.
        for (i=0;i<G_reclistlen;i++)
        {
            if (sendmsg("DBM",MESSAGE_r,"catxn",G_reclist[i]))
            {
                sendmsg("DBM",MESSAGE_qg,(UCHAR)s,(UCHAR)10,tmp); // unitval =10
                unitval=atoi(tmp);
					// now find the cadec group to which this transaction belongs
                found=0;
				for (index=0 ; index<nb ; index++)
                {
                    if (b[index].unitval == unitval)
                    {
                        found=1;
                        break;
                    }
                }

                if (found)
                {
                    sprintf(tmp,"%d",index);
                    sendmsg("DBM",MESSAGE_qp,(UCHAR)s,(UCHAR)14,tmp); // addinf2 =14
                    sendmsg("DBM",MESSAGE_w,"catxn");
                }
            }
        }
    }

    FREE(b);
    return(1);
}

//***************************************************************************
//S Function to release dec
//R BOOL TRUE

INT closedec(void)
{
    if (G_peallist!=NULL)
        FREE(G_peallist);
    G_peallist=NULL;
    G_peallistlen=0;
    return(1);
}

//***************************************************************************
//S Creation of a Double Entry Check search group
//D DECGROUP is set in the 4GL code to identify which group
//D of catxn P&A entries we are looking for. These have already
//D been 'tagged' by placing values in the addinf2 field.
//R BOOL TRUE=OK, FALSE=Fail

INT decslist(void)
{
    CHAR tmp[LENOFTEMPDECBUF];
    INT i,groupread,group,storenumber;

    if ((storenumber=snum("catxn"))<0) {
        return(0);
    }
    group=atoi(cagetvar("DECGROUP"));       // parameter set by 4GL code
    if (G_reclist!=NULL) {
        FREE(G_reclist);
    }
    G_reclistlen=0;
    G_reclist=MALLOC(sizeof(LONG)*G_peallistlen);
    if (G_reclist==NULL) {
        return(0);
    }
    strcpy(G_reclistname,"catxn");
    G_reclisttype=2;
    G_reclistcur=0;
    for (i=0;i<G_peallistlen;i++) {
        if (sendmsg("DBM",MESSAGE_r,"catxn",G_peallist[i])) {
            sendmsg("DBM",MESSAGE_qg,(UCHAR)storenumber,(UCHAR)14,tmp); // addinf2 =14
            groupread=atoi(tmp);
            if (group==groupread) {
                G_reclist[G_reclistlen++]=G_peallist[i];
            }
        }
    }
    G_reclist=REALLOC(G_reclist,sizeof(LONG)*G_reclistlen);
    if (G_reclist==NULL) G_reclistlen=0;
    return(1);
}

//***************************************************************************
//S Set a selected group of P&A's as an addlist
//D Assumes that builddec has already created a pensions and allowances
//D list that contains entries to be assigned, and that the variable
//D ADDLGRP is set with the addlist number.
//R BOOL TRUE=Ok, FALSE=Failed

INT setalist(void)
{
    CHAR tmp[LENOFSETALISTTMP];
    INT addlist,i;

    if ((snum("catxn"))<0)
        return(0);
    addlist=atoi(cagetvar("ADDLGRP"));  // Set the addlist number for all selected items
    for (i=0;i<G_peallistlen;i++)
        {
        if (sendmsg("DBM",MESSAGE_r,"catxn",G_peallist[i]))
            {
            sprintf(tmp,"%d",addlist);
            sendmsg("DBM",MESSAGE_p,"catxn","addinf3",tmp);
            // P&A's in an addlist are assumed, and hence marked, as checked. 13/7/95
            sendmsg("DBM",MESSAGE_p,"catxn","checked","Y");
            sendmsg("DBM",MESSAGE_w,"catxn");
            }
        }
    return(1);
}

//***************************************************************************
//S Initialisation to 96/97 - also end of year roll-over file manipulation
//D Filenames assumed:  caweek,  96week etc
//D If any problems occur during this routine the user wil have to
//D restore the backup made at the beginning of the end of week (end
//D of year) action code.  If problem occurs during system initialisation
//D program should abort.  Sets Global error G_error.
//R BOOL TRUE

INT init96(void)
{
    G_error = 0;        // Reset.  1 indicates delete error, 2 rename error

                        // Rename 96/97 files
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96week.*","caweek.*")) G_error=2;
//    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96form.*","caform.*")) G_error=2;
//    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96prod.*","caprod.*")) G_error=2;
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96param.*","caparam.*")) G_error=2;

      return(1);
}

//***************************************************************************
//S Initialisation to 95/96 - also end of year roll-over file manipulation
//D Filenames assumed:  caweek,  95week etc
//D If any problems occur during this routine the user wil have to
//D restore the backup made at the beginning of the end of week (end
//D of year) action code.  If problem occurs during system initialisation
//D program should abort
//R BOOL TRUE

INT init95(void)
{
    G_error = 0;        // Reset.  1 indicates delete error, 2 rename error

                        // Delete the old files.
//    if (!sendmsg("DISK",MESSAGE_D,"caform.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caprod.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caparam.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caweek.*",".\\DBM\\")) G_error = 1;

                        // Rename 95/96 files
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95week.*","caweek.*")) G_error=2;
//    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95form.*","caform.*")) G_error=2;
//    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95prod.*","caprod.*")) G_error=2;
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95param.*","caparam.*")) G_error=2;

      return(1);
}

//***************************************************************************
//S Initialisation of CAPTURE  - set to 94/95
//D Filenames assumed:  caweek,  94week etc
//D If any problems occur during this routine the user wil have to
//D restore the backup made at the beginning of the end of week (end
//D of year) action code.
//R BOOL TRUE

INT init94(void)
{
    G_error = 0;        // Reset.  1 indicates delete error, 2 rename error

                        // Delete the old files.
//    if (!sendmsg("DISK",MESSAGE_D,"caform.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caprod.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caparam.*",".\\DBM\\")) G_error = 1;
//    if (!sendmsg("DISK",MESSAGE_D,"caweek.*",".\\DBM\\")) G_error = 1;

                        // Rename 94/95 files
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"94week.*","caweek.*")) G_error=2;
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"94form.*","caform.*")) G_error=2;
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"94prod.*","caprod.*")) G_error=2;
    if (!sendmsg("DISK",MESSAGE_COPY,G_database,"94param.*","caparam.*")) G_error=2;

      return(1);
}
//***************************************************************************
//S Update of Provincial CAPTURE - used by update program
//R BOOL TRUE

INT pupdate(void)
{
    G_error = 0;        // Reset.  1 indicates delete error, 2 rename error

                        // Rename 94/95 files
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95param8.*","95param.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95param8.*","caparam.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"caprod80.*","caprod.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"caform80.*","caform.*")) G_error=2;
// carev not updated!
//      if (!sendmsg("DISK",MESSAGE_COPY,G_database,"carev80.*","carev.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96param8.*","96param.*")) G_error=2;

                        // Delete the unused files
        if (!sendmsg("DISK",MESSAGE_D,"95param8.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"96param8.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caprod80.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caform80.*",".\\DBM\\")) G_error = 1;
//      if (!sendmsg("DISK",MESSAGE_D,"carev80.*",".\\DBM\\")) G_error = 1;

        if (!sendmsg("DISK",MESSAGE_D,"95param6.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"96param6.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caprod60.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caform60.*",".\\DBM\\")) G_error = 1;
//      if (!sendmsg("DISK",MESSAGE_D,"carev60.*",".\\DBM\\")) G_error = 1;

        return(1);
}

//***************************************************************************
//S Update of London CAPTURE - used by update program
//R BOOL TRUE

INT lupdate(void)
{
    G_error = 0;        // Reset.  1 indicates delete error, 2 rename error

                        // Rename 94/95 files
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95param6.*","95param.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"95param6.*","caparam.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"caprod60.*","caprod.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"caform60.*","caform.*")) G_error=2;
// carev not updated!
//      if (!sendmsg("DISK",MESSAGE_COPY,G_database,"carev60.*","carev.*")) G_error=2;
        if (!sendmsg("DISK",MESSAGE_COPY,G_database,"96param6.*","96param.*")) G_error=2;

                        // Delete the unused files
        if (!sendmsg("DISK",MESSAGE_D,"95param8.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"96param8.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caprod80.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caform80.*",".\\DBM\\")) G_error = 1;
//      if (!sendmsg("DISK",MESSAGE_D,"carev80.*",".\\DBM\\")) G_error = 1;

        if (!sendmsg("DISK",MESSAGE_D,"95param6.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"96param6.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caprod60.*",".\\DBM\\")) G_error = 1;
        if (!sendmsg("DISK",MESSAGE_D,"caform60.*",".\\DBM\\")) G_error = 1;
//      if (!sendmsg("DISK",MESSAGE_D,"carev60.*",".\\DBM\\")) G_error = 1;

        return(1);
}

//***************************************************************************
//S Deletion of all catotal records for which there is no caprod
//D Used at end of year to update carried over entries to match
//D a new years product list. Requires that a transaction group has
//D been built before this is called.
//R TRUE

INT delotot(void)
{
    INT i;
    CHAR tmp[LENOFTIDYUPTEMP];
    LONG o=0L;

    if (   (G_reclist==NULL)
        || (G_reclistlen==0)
        || (strcmp(G_reclistname,"catotal")!=0)  ) return(1);

    for (i=0;i<G_reclistlen;i++) {
        if (sendmsg("DBM",MESSAGE_r,"catotal",G_reclist[i]-o)) {
            sendmsg("DBM",MESSAGE_g,"catotal","category",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"category",tmp);
            sendmsg("DBM",MESSAGE_g,"catotal","type",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"type",tmp);
            sendmsg("DBM",MESSAGE_g,"catotal","code",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"code",tmp);
            if (!sendmsg("DBM",MESSAGE_sp,"caprod",3,FRST)) {
                if (sendmsg("DBM",MESSAGE_dr,"catotal",(LONG)CURR)) {
                    o++;
                }
            }
        }
    }
    return(1);
}

//***************************************************************************
//S Deletion of all castock records for which there is no caprod
//D Used at end of year to update carried over entries to match
//D a new years product list. Requires that a transaction group has
//D been built before this is called.
//R BOOL TRUE

INT delostk(void)
{
    INT i;
    CHAR tmp[LENOFTIDYUPTEMP];
    LONG o=0L;

    if (   (G_reclist==NULL)
        || (G_reclistlen==0)
        || (strcmp(G_reclistname,"castock")!=0)  ) return(1);

    for (i=0;i<G_reclistlen;i++) {
        if (sendmsg("DBM",MESSAGE_r,"castock",G_reclist[i]-o)) {
            sendmsg("DBM",MESSAGE_g,"castock","category",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"category",tmp);
            sendmsg("DBM",MESSAGE_g,"castock","type",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"type",tmp);
            sendmsg("DBM",MESSAGE_g,"castock","code",tmp);
            sendmsg("DBM",MESSAGE_p,"caprod" ,"code",tmp);
            if (!sendmsg("DBM",MESSAGE_sp,"caprod",3,FRST)) {
                if (sendmsg("DBM",MESSAGE_dr,"castock",(LONG)CURR)) {
                    o++;
                }
            }
        }
    }
    return(1);
}

//***************************************************************************
//S If user decides to abort print then sets G_error to 1 , else G_error is 0
//D Checks the printer status - call before printing
//R BOOL TRUE

INT prinstat(void)
{
    INT message_flag=0;

    G_error=0;    // Clear status
    while ((sendmsg("OUTPUT2",MESSAGE_GS))!=0) {    // Why ref OUTPUT2 here? :JGQ
        if (message_flag == 0) {
            sendmsg("OUTPUT1",MESSAGE_S,1);
            sendmsg("OUTPUT1",MESSAGE_A,1);
            sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s",isdefstr("PRNSETAB"));
            message_flag=1;
        }
        if (sendmsg("INPUT1",MESSAGE_H)) {
                // Escape key (27) has been reassigned as F10 for CAPTURE
            if (sendmsg("INPUT1",MESSAGE_i)==F10) {
                G_error=1;    // Test G_error for status in action code
                break;
            }
        }
        sendmsg("OSSDEV",MESSAGE_d,200);
    }
    if (message_flag == 1) {
        sendmsg("OUTPUT1",MESSAGE_A,0);
        sendmsg("OUTPUT1",MESSAGE_o,0,22,"%s","                                                              ");
    }
    return(1);
}

//***************************************************************************
//S Run calculator
//R BOOL TRUE

INT runcalc(void)
{
    INT cl;
    CHAR *dat;
    if ((G_calcon)&&(G_form.curitem>=0)) {
        cl=(G_form.items[G_form.curitem].class)&(~FF_TBLF);
        dat=proccalc(G_calcxpos,G_calcypos);
        if (*dat!=0){
            if ((cl!=FF_TEXT)&&(cl!=FF_TABL)&&(cl!=FF_DISP)&&(cl!=FF_WAIT)) {
                sendmsg("INPUT1",MESSAGE_P,27);
                while (*dat) {
                    sendmsg("INPUT1",MESSAGE_P,(INT)(*dat++));
                }
                sendmsg("INPUT1",MESSAGE_P,KBDPUSHEND);
            }
        }
    }
    return(1);
}

//***************************************************************************
//S save region - not implemented 
//R BOOL TRUE

INT sregion(void)
{
    return 1;
}

//***************************************************************************
//S Restore region
//R BOOL TRUE

INT rregion(void)
{
    sendmsg("OUTPUT1",MESSAGE_SAVEREGION,0,0,320,240);
    sendmsg("OUTPUT1",MESSAGE_o,0,0,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,1,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,2,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,3,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,4,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,5,"TEST TEST TEST TEST TEST");
    sendmsg("OUTPUT1",MESSAGE_o,0,6,"TEST TEST TEST TEST TEST");
    beep();
    sendmsg("INPUT1",MESSAGE_i);
    sendmsg("OUTPUT1",MESSAGE_RESTREGION,0,0,320,240);
    beep();
    sendmsg("INPUT1",MESSAGE_i);
    return 1;
}

//***************************************************************
//S Check for MVLTXN datastore. 
//D If it exists and there is no CATXN
//D datastore then rename it, else we have a serious error, advise
//D user to restore from a backup.
//R BOOL TRUE

INT chmvltxn(void)
{
    G_error = 0;        // Reset.  1 indicates error

                        // Check for MVLTXN existence
    if (sendmsg("DISK",MESSAGE_T,G_database,"mvltxn.db")) {
        // mvltxn database exists!
        G_error=1;
        if (!sendmsg("DISK",MESSAGE_r,G_database,"mvltxn.*","catxn.*")) {
            G_error = 2;
        }
    }

      return(1);
}

//***************************************************************
//S Hook for debugging
//D Default hook resets global error to zero
//R BOOL TRUE

INT hook(void)
{
    G_error = 0;

      return(1);
}
// **************************************************************************
// capgpa.c <end-of-file>

