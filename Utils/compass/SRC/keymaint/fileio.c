//===============|========================================================|
//               |                                                        |
// Module        | FILEIO.C                                               |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | EPoS Keymap Maintenance Application                    |
//               |                                                        |
// Functions     |                                                        |
//               |                                                        |
// Global Vars.  | None.                                                  |
//               |                                                        |
//===============|========================================================|
//               |                                                        |
// Copyright (c) | Unisys Limited                                         |
//               | 22 Southwark Bridge Road                               |
//               | London SE1 9HB                                         |
//               |                                                        |
// Author        | Mark Durbin                                            |
//               | P.S.L.                                                 |
//               | 160 Charles street, Greenhithe, Kent. DA9 9AJ          |
//               |                                                        |
//===============|========================================================|
// Date          | Modifications                                 | By     |
//===============|===============================================|========|
// 10/05/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|

#define __FILEIO_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For atol()
#include <string.h>      // For strlen() etc...
#include <stdarg.h>      // For va_arg va_start() va_end() etc...
#include <memory.h>      // For memset() etc...
#include <time.h>        // For time()
#include <sys\timeb.h>   // For tb struct
#include <dir.h>         // For mkdir()
#include <dos.h>         // For file attributes

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // file i/o declarations
#include "deballoc.h"    // debug memory allocation routines
#include "videokbd.h"    // video & keyboard routines
#include "seqfiles.h"    // sequence file layout


//=========================================================================
// Globals Section
//=========================================================================

//=========================================================================
// Define Section
//=========================================================================

#define ERROREXIT { retval=FALSE; break; }

//=========================================================================
// Declarations Section
//=========================================================================

BOOL  GetLong        (CHAR *line,INT fieldofs,INT fieldlen,LONG *val);
BOOL  GetInt         (CHAR *line,INT fieldofs,INT fieldlen,INT  *val);
BOOL  GetString      (CHAR *line,INT fieldofs,INT fieldlen,CHAR *buf);

//=========================================================================
// Definitions Section
//=========================================================================

//=========================================================================
//F Exists
//S Return TRUE if a file exists
//D Return TRUE if a file exists
//P The file name including full path
//R TRUE if file exists, otherwise FALSE
BOOL Exists(CHAR *file)
{
    struct ffblk f;
    return (findfirst(file,&f,FILEATTR)!=(-1));
}
//_________________________________________________________________________

//==========================================================================
//F AuditLog
//S Write dated string to audit log
//D Write dated string to audit log 
//P format of string in printf() format
//P variable parameters
void AuditLog(CHAR *format,...)
{
    static CHAR outstr[MAXSTRLEN];                 // output string buffer
    static BOOL donestart=FALSE;                   // static used for heading at start
	va_list ap;                                    // variable arg. list ptr.
    time_t t;                                      // for time stamp
    FILE *fp;                                      // audit log file pointer

    strcpy(outstr,AUDITFILE);
    fp=fopen(outstr,"a+");                      // open audit log
    if (fp==NULL) {                                // can't open audit log!!!
        fprintf(stderr,"Can't Open Audit Trail!\n");
        return;
    }

    va_start(ap,format);                           // start variable arg. list
    vsprintf(outstr,format,ap);                    // convert args to string
    va_end(ap);                                    // end variable arg. list

    t=time(NULL);                                  // get time stamp

    if (!donestart) {                              // this is the first time through
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        fprintf(fp,"Audit Log Start %s",ctime(&t));
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        donestart=TRUE;                            // reset for next call
    }
    fprintf(fp,"%s %s",outstr,ctime(&t));          // output the string with time
    fclose(fp);                                    // close audit log
}
//__________________________________________________________________________

//==========================================================================
//F LoadPrinterParams
//S Load the printer parameters
//D Load the printer parameters (currently only loads printer type 
//D i.e. EPSON or PCL)
//R Printer type i.e. EPSON or PCL(default)
INT LoadPrinterParams(void)
{
    FILE *fp;                   // printer file pointer
    CHAR buffer[MAXSTRLEN];     // buffer for read string

    fp=fopen(PRINTERFILE,"r");  // open the file
    if (fp==NULL) return PCL;   // no file or error, return default

    if (fgets(buffer,MAXSTRLEN,fp)!=NULL) { // get string ok
        if (buffer[0]=='E') {               // starts with 'E' assume EPSON
            fclose(fp);                     // close printer file
            return EPSON;                  
        }
    }
    fclose(fp);                            // first char != 'E', close file
    return PCL;                            // return default
}
//__________________________________________________________________________

//==========================================================================
//F CleanBuf
//S Remove any spaces at the start and end of a string
//D Remove any spaces at the start and end of a string, including TAB CR & LF
//P The padded string
//R The cleaned string
CHAR *CleanBuf(CHAR *str)
{
    static CHAR buffer[MAXSTRLEN];                    // output string buffer
    CHAR *bufend;                                     // pointer to end of string

    if (str==NULL) return str;

    while ((*str)&&(*str==' ')) str++;                // skip space at beginning

    strcpy(buffer,str);                               // make a copy

    bufend=buffer+strlen(buffer)-1;                   // point to end
    while ((bufend!=buffer)                           // while end not start
       &&  ((*bufend==' ')                            // and end spaces
       ||   (*bufend=='\r')
       ||   (*bufend=='\n')
       ||   (*bufend=='\t')  ) )
        *(bufend--)=0;                                // remove
    return buffer;                                    // return clean string
}
//__________________________________________________________________________

//==========================================================================
//F ismenu
//S TRUE if department struct refers to a menu key
//D TRUE if department struct refers to a menu key
//P The department structure
//R TRUE if it's a menu, otherwise FALSE.
BOOL ismenu(DEPARTMENT *dept)
{
    if (dept==NULL) return(FALSE);                  // catch error call

    return (strcmp(dept->status.as_string,"01550050")==0); // use status string
}
//__________________________________________________________________________

//==========================================================================
//F FindPLU
//S Find a plu in a list
//D Find a plu in a list given the PLU code
//P The list of PLU's
//P The PLU code to find
//R Pointer to PLU structure or NULL if not found
PLU *FindPLU(PLU *plulist,LONG plu_code)
{
    while (plulist!=NULL) {                 // work through list
        if (plulist->plu_code==plu_code)    // same plu code
            return plulist;
        plulist=plulist->next;              // next item in list
    }
    return NULL;                            // not found
}
//__________________________________________________________________________

//==========================================================================
//F FindRePLU
//S Find a remacs plu in a list
//D Find a remacs plu in a list given the PLU code
//P The list of remacs PLU's
//P The PLU code to find
//R Pointer to remacs PLU structure or NULL if not found
REMACSPLU *FindRePLU(REMACSPLU *plulist,LONG plu_code)
{
    while (plulist!=NULL) {                // work through list
        if (plulist->plu_code==plu_code)   // same plu code
            return plulist;
        plulist=plulist->next;             // next item in list
    }
    return NULL;                           // not found
}
//__________________________________________________________________________

//==========================================================================
//F FindPLU
//S Find a department in a list
//D Find a department in a list given the department number
//P The list of departments
//P The department number to find
//R Pointer to department structure or NULL if not found
DEPARTMENT *FindDept(DEPARTMENT *deptlist,INT dept)
{
    while (deptlist!=NULL) {               // work through list
        if (deptlist->dept_number==dept)   // same department(key) number
            return deptlist;
        deptlist=deptlist->next;           // next item in list
    }
    return NULL;                           // not found
}
//__________________________________________________________________________

//==========================================================================
//F GetLong
//S Get a LONG from an ASCII record buffer
//D Get a LONG from an ASCII record buffer given an offset and length
//P The source string
//P The offset of the start of the long
//P The length of the string containing a long
//P The address of the returned long
//R TRUE return value OK.  FALSE on error
BOOL GetLong(CHAR *line,INT fieldofs,INT fieldlen,LONG *val)
{
    static CHAR buf[MAXFIELDLEN+1];   // holding buffer
    char *str;                        // returned clean string

    if (((fieldofs+fieldlen)>strlen(line))||(fieldlen>MAXFIELDLEN))
        return FALSE;                     // out of range
    memcpy(buf,line+fieldofs,fieldlen);   // get the buffer
    *(buf+fieldlen)='\0';                 // terminate
    str=CleanBuf(buf);                    // remove white space
    *val=atol(str);                       // convert to LONG
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F GetInt
//S Get a INT from an ASCII record buffer
//D Get a INT from an ASCII record buffer given an offset and length
//P The source string
//P The offset of the start of the INT
//P The length of the string containing a INT
//P The address of the returned INT
//R TRUE return value OK.  FALSE on error
BOOL GetInt(CHAR *line,INT fieldofs,INT fieldlen,INT *val)
{
    BOOL retval;    // temp hold for return from GetLong()
    LONG tempval;   // temp hold for returned value from GetLong()
    retval=GetLong(line,fieldofs,fieldlen,&tempval); // use GetLong and cast to int
    if (retval) *val=(INT)tempval;
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F GetString
//S Get a String from an ASCII record buffer
//D Get a String from an ASCII record buffer given an offset and length
//P The source string
//P The offset of the start of the String
//P The length of the string containing a String
//P The address of the returned String
//R TRUE return value OK.  FALSE on error
BOOL GetString(CHAR *line,INT fieldofs,INT fieldlen,CHAR *buf)
{
    if (((fieldofs+fieldlen)>strlen(line))||(fieldlen>MAXFIELDLEN))
        return FALSE;                       // out of range
    memcpy(buf,line+fieldofs,fieldlen);     // get the buffer
    *(buf+fieldlen)='\0';                   // terminate
    return TRUE;                            
}
//__________________________________________________________________________
//=========================================================================
//F GenDatFiles
//S Generate the STORE.DAT and TERM.DAT files
//D Generate the STORE.DAT and TERM.DAT files
//P The configuration list
void GenDatFiles(CONFIG *cfglist)
{
    FILE *fp;
    CHAR filename[100];
    INT termcount;
    INT terms[20];
    INT i;

    while (cfglist!=NULL) {
        sprintf(filename,STOREDAT,cfglist->ctrl_centre);
        if ((fp=fopen(filename,"w"))!=NULL) {
            fprintf(fp,"0000,%-35.35s,%-35.35s,%d,050,Y,%-15.15s,000,16,Y,N,21,%-20s\n",cfglist->cc_desc,cfglist->phone_num,cfglist->comport,"","");
            fclose(fp);
        }
        sprintf(filename,TERMDAT,cfglist->ctrl_centre);

        if ((fp=fopen(filename,"w"))!=NULL) {
            termcount=0;
            for (i=0;i<20;i++) {
                G_compassdat [COMPASSOFS1+i*2  ]=(i==termcount)?0x1c:' ';
                G_compassdat [COMPASSOFS1+i*2+1]=' ';
                G_compassdat [COMPASSOFS2+i*2  ]=(i==termcount)?0x1c:' ';
                G_compassdat [COMPASSOFS2+i*2+1]=' ';
                G_testpolldat[TESTPOLLOFS+i*2  ]=(i==termcount)?0x1c:' ';
                G_testpolldat[TESTPOLLOFS+i*2+1]=' ';
            }
            while ((cfglist->next!=NULL)
            && (strcmp(cfglist->ctrl_centre,cfglist->next->ctrl_centre)==0)) {
                fprintf(fp,"0000,%-10.10s,%03d,%02d,%-20.20s\n",cfglist->term_desc,termcount+1,cfglist->term_id,"","");
                terms[termcount++]=cfglist->term_id;
                cfglist=cfglist->next;
            }
            fprintf(fp,"0000,%-10.10s,%03d,%02d,%-20.20s\n",cfglist->term_desc,termcount+1,cfglist->term_id,"","");
            terms[termcount++]=cfglist->term_id;
            fclose(fp);
            for (i=0;i<20;i++) {
                if (i<termcount) {
                    sprintf(&G_testpolldat[TESTPOLLOFS+i*2],"%02d",terms[i]);
                    sprintf(&G_compassdat [COMPASSOFS1+i*2],"%02d",terms[i]);
                    sprintf(&G_compassdat [COMPASSOFS2+i*2],"%02d",terms[i]);
                } else {
                    G_compassdat [COMPASSOFS1+i*2  ]=(i==termcount)?0x1c:' ';
                    G_compassdat [COMPASSOFS1+i*2+1]=' ';
                    G_compassdat [COMPASSOFS2+i*2  ]=(i==termcount)?0x1c:' ';
                    G_compassdat [COMPASSOFS2+i*2+1]=' ';
                    G_testpolldat[TESTPOLLOFS+i*2  ]=(i==termcount)?0x1c:' ';
                    G_testpolldat[TESTPOLLOFS+i*2+1]=' ';
                }
            }
            sprintf(filename,SEQFILE,cfglist->ctrl_centre);
            if ((fp=fopen(filename,"wb"))!=NULL) {
                fwrite(G_compassdat,1,COMPASSSIZE,fp);
            }
            sprintf(filename,POLLFILE,cfglist->ctrl_centre);
            if ((fp=fopen(filename,"wb"))!=NULL) {
                fwrite(G_testpolldat,1,TESTPOLLSIZE,fp);
            }
            fclose(fp);
        }
        cfglist=cfglist->next;
    }
}
//_________________________________________________________________________

CHAR *GetPhoneNumber(CHAR *file,INT cc)
{
    static CHAR phone[36];
    CONFIG *cfglist=NULL,*cfg;

    phone[0]='\0';
    if ((LoadConfig(file,&cfglist))==TRUE) {
        cfg=cfglist;
        while (cfg!=NULL) {
            if (atoi(cfg->ctrl_centre)==cc) {
                strcpy(phone,cfg->phone_num);
                break;
            }
            cfg=cfg->next;
        }
        FreeCFGList(&cfglist);
    }
    return phone;
}
//_________________________________________________________________________

void SetPhoneNumber(CHAR *file,INT cc,CHAR *phone)
{
    CONFIG *cfglist=NULL,*cfg;

    if ((LoadConfig(file,&cfglist))==TRUE) {
        cfg=cfglist;
        while (cfg!=NULL) {
            if (atoi(cfg->ctrl_centre)==cc) {
                strcpy(cfg->phone_num,phone);
                break;
            }
            cfg=cfg->next;
        }
        GenDatFiles(cfglist);
        SaveConfig(file,&cfglist,TRUE);
    }
}
//_________________________________________________________________________

//==========================================================================
//F LoadConfig
//S Load the configurations file into a linked list
//D Load the configurations file into a linked list
//P The name of the configuration file
//P A pointer to the empty linked list i.e. *(cfglist)==NULL
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadConfig(CHAR *name,CONFIG **cfglist)
{
    BOOL retval=TRUE;             // return value (set by ERROREXIT macro)
    static CHAR line[MAXSTRLEN];  // read line buffer
    CONFIG *cfg;                  // current configuration structure
    CONFIG *nextc;                // next configuration structure
    CONFIG *prevc;                // previous configuration structure
    FILE *fp;                     // configuration file pointer
    
    if ((fp=fopen(name,"r"))==NULL) return FALSE; // no file, return error

    while ((fgets(line,1000,fp))!=NULL) {       // for each line in file
        if ((cfg=MALLOC(sizeof(CONFIG)))==NULL)          ERROREXIT // get space
        if (!GetString(line, 0, 2,  cfg->ctrl_centre))   ERROREXIT // get control centre
        if (!GetString(line, 2,15,  cfg->cc_desc    ))   ERROREXIT // description
        if (!GetInt   (line,17, 2,&(cfg->term_id    )))  ERROREXIT // terminal identifier
        if (!GetString(line,19,15,  cfg->term_desc  ))   ERROREXIT // terminal description
        if (!GetString(line,34, 3,  cfg->term_type  ))   ERROREXIT // terminal type
        if (!GetInt   (line,37, 2,&(cfg->comport    )))  ERROREXIT // terminal identifier
        if (!GetString(line,39,35,  cfg->phone_num  ))   ERROREXIT // phone number
        cfg->next=*cfglist;                                        // add to linked list at start
        *cfglist=cfg;                                               
    }
    fclose(fp);                                                    // close file

    cfg=*cfglist;               // reverse the list
    prevc=NULL;                 // new end of list
    while (cfg!=NULL) {         // for each item in list
        nextc=cfg->next;        // get next item
        cfg->next=prevc;        // set next to previous
        prevc=cfg;              // set previous to current
        cfg=nextc;              // move to next
    }
    *cfglist=prevc;             // point to new start
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F FreeCFGList
//S Free the memory associated with a configuration list
//D Free the memory associated with a configuration list
//P A pointer to a pointer to the configuration list
void FreeCFGList(CONFIG **cfglist)
{
    CONFIG *cfg;                // current item
    while (*cfglist!=NULL) {    // for each item
        cfg=(*cfglist)->next;   // point to the next
        FREE(*cfglist);         // free the current
        *cfglist=cfg;           // move current to next
    }
}
//==========================================================================
//F SaveConfig
//S Save a configuration file from a linked list
//D Save a configuration file from a linked list and conditionally
//D free the memory associated with the list
//P The configuration file
//P The configuration linked list
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error or cfglist==NULL or cfglist empty
BOOL SaveConfig(CHAR *name,CONFIG **cfglist,BOOL freelist)
{
    FILE *fp;       // configuation file pointer
    CONFIG *cfg;    // current item

    if ((cfglist==NULL)||(*cfglist==NULL))
        return FALSE;           // empty list, or error - return ERROR

    if ((fp=fopen(name,"w"))==NULL) // can't open
        return FALSE;               // return ERROR

    cfg=*cfglist;                   // point to start of list
    while (cfg!=NULL) {             // for each item in list
        fprintf(fp,"%2.2s%-15.15s%02d%-15.15s%-3.3s%02d%-35.35s\n",
            cfg->ctrl_centre,
            cfg->cc_desc    ,
            cfg->term_id    ,
            cfg->term_desc  ,
            cfg->term_type  ,
            cfg->comport    ,
            cfg->phone_num  );
        cfg=cfg->next;          // next item
    }

    fclose(fp); // close file

    if (freelist) FreeCFGList(cfglist); // free associated memory
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F LoadDepartment
//S Load a department file into a linked list
//D Load a department file into a linked list
//P the file name
//P A pointer to the empty linked list i.e. *(deptlist)==NULL
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadDepartment(CHAR *name,DEPARTMENT **deptlist,INT numbkey)
{
    BOOL retval=TRUE;            // return value (set by ERROREXIT macro)
    static CHAR line[MAXSTRLEN]; // read line buffer
    DEPARTMENT *dept;            // current department struct
    DEPARTMENT *nextd;           // next department struct
    DEPARTMENT *prevd;           // previous department struct
    FILE *fp;
    
    if ((fp=fopen(name,"r"))==NULL) { // can't open so create an empty one
        if (!SaveDepartment(name,NULL,numbkey,FALSE)) return FALSE; // can't create - return ERROR
        if ((fp=fopen(name,"r"))==NULL) { // still can't read - return ERROR
            return FALSE;
        }
    }

    while ((fgets(line,1000,fp))!=NULL) {   // for each line
        if ((dept=MALLOC(sizeof(DEPARTMENT)))==NULL)      ERROREXIT // get space
        if (!GetInt   (line, 8,2,&(dept->dept_number)))   ERROREXIT // read department number
        if (!GetString(line,10,8,dept->status.as_string)) ERROREXIT // status
        if (!GetString(line,18,2,dept->active))           ERROREXIT // active flag
        if (!GetString(line,20,8,dept->desc))             ERROREXIT // description
        if (!GetLong  (line,28,6,&(dept->osp_code[0])))   ERROREXIT // keyboard level 1 code
        if (!GetLong  (line,34,6,&(dept->osp_code[1])))   ERROREXIT // keyboard level 2 code
        if (!GetLong  (line,40,6,&(dept->osp_code[2])))   ERROREXIT // keyboard level 3 code
        if (!GetInt   (line,46,1,&(dept->action)))        ERROREXIT // action flag
        dept->next=*deptlist;                                       // add at begining of list
        *deptlist=dept;
    }
    fclose(fp);

    dept=*deptlist;             // reverse the list
    prevd=NULL;                 // new end of list
    while (dept!=NULL) {        // for each item
        nextd=dept->next;       // get next
        dept->next=prevd;       // set next to previous
        prevd=dept;             // set previous to current
        dept=nextd;             // move to next item
    }
    *deptlist=prevd;            // point to new start
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F AddReMACSPLU
//S Add a ReMACS PLU structure into a list
//D Add a ReMACS PLU structure into a list (i.e. add the FLT file into the 
//D local file)
//P The ReMACS PLU structure list
//P The ReMACS PLU structure to add ( one price level )
//P The price of this level
//P The price level [0-5]
void AddReMACSPLU(REMACSPLU **plulist,REMACSPLU *plu,LONG price,INT plevel)
{
    static LONG today=0L;   // integer of today's date 
    struct tm *t;           // used to find if PLU newer than current
    struct timeb tb;        // used to find if PLU newer than current
    REMACSPLU *pluptr;      // current PLU in list
    INT pindex;             // price level index counter

    if (today==0L) {        // first time in - get date
       	ftime(&tb);
    	t=localtime(&tb.time);
        t->tm_mon++;
        today =(LONG)t->tm_year*10000L;  // date as number i.e. 960618L
        today+=(LONG)t->tm_mon *100L  ;  // is 18th June 1996
        today+=(LONG)t->tm_mday       ;
    }
    if (plulist==NULL) return;  // this is not a pointer to a list return
                                                                   
    pluptr=*plulist;        // point to start of list
    while (pluptr!=NULL) {  // for each item in list
        if (pluptr->plu_code==plu->plu_code) { // the same plu code
            if (pluptr->edate==plu->edate) {   // same date - add price
                strcpy(pluptr->desc,plu->desc); // copy new description
                pluptr->price[plevel]=price;
//                pluptr->done1=TRUE;            // set flag to stop removal of PLU
                FREE(plu);                     // don't need this structure
                return;
            }
            if (pluptr->edate<plu->edate) {     // later date 
                if (plu->edate<=today+1L) {     // if ready for load - change
                    strcpy(pluptr->desc,plu->desc); // copy new description
                    pluptr->edate=plu->edate;
                    pluptr->price[plevel]=price;
//                    pluptr->done1=TRUE;         // set flag to stop removal of PLU
                    FREE(plu);                  // don't need this structure
                    return;
                } else {
                    plu->usethisone=FALSE;
                }
            } else {                            // current is newer than latest - ignore latest
//                pluptr->done1=TRUE;             // set flag to stop removal of PLU
                FREE(plu);                      // don't need this structure
                return;
            }
        }
        pluptr=pluptr->next;   // next item in list
    }
    for (pindex=0;pindex<6;pindex++) {
        if (pindex==plevel) {
            plu->price[pindex]=price;  // add new or add one for later
        } else {
            plu->price[pindex]=0;      // Zero other price levels
        }
    }
//    plu->done1=TRUE;           // set flag to stop removal of PLU
    plu->next=*plulist;        // add at begining of list
    *plulist=plu;      
}
LONG StrVal(CHAR *buf)
{
    CHAR *pptr; // point pointer
    LONG retval;
    pptr=buf;
    while ((*pptr)&&((*pptr)!='.')) pptr++;
    if (*pptr=='.') {
        *(pptr++)='\0';
        retval=atol(buf)*100L;
        retval+=atol(pptr);
    } else {
        retval=atol(buf);
    }
    return retval;
}
//==========================================================================
//F LoadReMACSPLU
//S Load a ReMACS PLU file into a linked list
//D Load a ReMACS PLU file into a linked list
//P the file name
//P A pointer to the linked list
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadReMACSPLU(CHAR *name,REMACSPLU **plulist)
{
    BOOL retval=TRUE;            // return value (set by ERROREXIT macro)
    static CHAR line[MAXSTRLEN]; // read line buffer
    char tempbuf[20];            // temporary buffer for each price line
    INT plevel;                  // current price level
    REMACSPLU *plu;              // current ReMACS plu structure
    REMACSPLU *nextp;            // next ReMACS plu structure
    REMACSPLU *prevp;            // previous ReMACS plu structure
    FILE *fp;                    // ReMACS PLU file pointer

    if ((fp=fopen(name,"r"))==NULL) return FALSE; // can't open return error

    while ((fgets(line,1000,fp))!=NULL) {   // for each line in the file
        if (!GetString(line, 0, 1,tempbuf))               ERROREXIT // get the first character

        if (tempbuf[0]=='P') {                                      // if it's a P process line
            if ((plu=MALLOC(sizeof(REMACSPLU)))==NULL)    ERROREXIT // get space
            plu->usethisone=TRUE;
            if (!GetLong  (line, 1,15,&(plu->plu_code)))  ERROREXIT // read the plu code
            if (plu->plu_code>999999L) {
                fclose(fp);
                SetViewPort(0,0,79,21,0x4F);
                AuditLog("Error in input file PLU CODE = %ld",plu->plu_code);
                OutFormat(10,10,0xCF,"Error in input file PLU CODE = %ld",plu->plu_code);
                OutFormat(10,11,0xCF,"Correct this problem in the POS Cross Reference, and re-transmit!");
                OutFormat(10,12,0xCF,"PRESS [ESC] TO EXIT PROGRAM");
                while (GetKey()!=27);
                exit(-1);
            }
            if (!GetString(line,16,25,plu->desc))         ERROREXIT // description
            if (!GetLong  (line,41, 6,&(plu->edate)))     ERROREXIT // effective date
            if (!GetInt   (line,47,10,&(plevel)))         ERROREXIT // price level [1-6]
            if (!GetString(line,67,10,tempbuf))           ERROREXIT // price
            AddReMACSPLU(plulist,plu,StrVal(tempbuf),plevel-1); // add PLU to list
        }

    }
    fclose(fp);  // done, close file
//
//
//
//    PLU NOT NOW DELETED WHEN NOT PRESENT IN THE .FLT FILE
//
//
//    plu=*plulist;   // remove redundant data ( any PLU not in FLT file is removed from local PLU list)
//    prevp=NULL;                 // previous structure
//    while (plu!=NULL) {         // go through list
//        nextp=plu->next;        // get next item
//        if (!plu->done1) {      // if flag has not been set
//            if (prevp==NULL) {  // first item
//                *plulist=nextp; // move start
//            } else {
//                prevp->next=nextp; // move previous item's next pointer
//            }
//            // signal removal
//            AuditLog("PLU Deleted\n%010ld%-25.25s%06ld%010ld%010ld%010ld%010ld%010ld%010ld\nat",
//                plu->plu_code,plu->desc,plu->edate,plu->price[0],plu->price[1],
//                plu->price[2],plu->price[3],plu->price[4],plu->price[5]);
//            FREE(plu); // free associated memory
//        } else {
//            prevp=plu;  // this on is ok - move prev pointer to here
//        }
//        plu=nextp; // next item
//    }
//
//
//
//    PLU NOT NOW DELETED WHEN NOT PRESENT IN THE .FLT FILE
//
//

    plu=*plulist;        // reverse the list
    prevp=NULL;          // new end of list
    while (plu!=NULL) {  // for each item
        nextp=plu->next; // get next
        plu->next=prevp; // set next to previous
        prevp=plu;       // set previous to current
        plu=nextp;       // move to next item
    }
    *plulist=prevp;      // point to new start
    
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F LoadLocalPLU
//S Load a Local ReMACS PLU file into a linked list
//D Load a Local ReMACS PLU file into a linked list
//P the file name
//P A pointer to the linked list
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadLocalPLU(CHAR *name,REMACSPLU **plulist)
{
    BOOL retval=TRUE;               // return value (set by ERROREXIT macro)
    static CHAR line[MAXSTRLEN];    // read line buffer
    INT plevel;                     // price level counter
    REMACSPLU *plu;                 // current plu
    REMACSPLU aplu;                 // plu buffer
    FILE *fp;                       // local plu file pointer

    if ((fp=fopen(name,"r"))==NULL) return FALSE; // can't open file - return error

    while ((fgets(line,1000,fp))!=NULL) {  // for each line in file
        if (!GetLong  (line, 0,10,&(aplu.plu_code)))     ERROREXIT  // read plu code
        if (!GetString(line,10,25,aplu.desc))            ERROREXIT  // description
        if (!GetLong  (line,35, 6,&(aplu.edate)))        ERROREXIT  // effective date
        for (plevel=0;plevel<6;plevel++) {
            if ((plu=MALLOC(sizeof(REMACSPLU)))==NULL)       ERROREXIT  // get space
            plu->usethisone=TRUE;
            plu->plu_code=aplu.plu_code;
            strcpy(plu->desc,aplu.desc);
            plu->edate=aplu.edate;
            if (!GetLong(line,41+plevel*10,10,&(aplu.price[plevel]))) // each price
                ERROREXIT
            AddReMACSPLU(plulist,plu,aplu.price[plevel],plevel); // add PLU to list
        }
//        plu->next=*plulist;  // add at begining of list
//        *plulist=plu;
//        plu->done1=FALSE;    // if this is not set to TRUE by LoadReMACS PLU it wil be deleted
    }
    fclose(fp);  // dne - close file

    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F FreeReMACSPLUList
//S Free the memory associated with a ReMACS PLU linked list
//D Free the memory associated with a ReMACS PLU linked list
//P a pointer to the pointer to the list
void FreeReMACSPLUList(REMACSPLU **plulist)
{
    REMACSPLU *plu;           // next item in list
    while (*plulist!=NULL) {  // for each item in list
        plu=(*plulist)->next; // get next item
        FREE(*plulist);       // free current item
        *plulist=plu;         // move current to next
    }
}
//__________________________________________________________________________

//==========================================================================
//F SaveLocalPLU
//S Save a Local ReMACS PLU file from a linked list
//D Save a Local ReMACS PLU file from a linked list and conditionally
//D free the memory associated with the list
//P The Local ReMACS PLU file
//P The ReMACS PLU linked list
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error or deptlist==NULL or deptlist empty
BOOL SaveLocalPLU(CHAR *name,REMACSPLU **plulist,BOOL freelist)
{
    FILE *fp;       // local plu file pointer
    REMACSPLU *plu; // current plu

    if ((plulist==NULL)||(*plulist==NULL)) // empty or invalid ptr - return error;
        return FALSE;

    if ((fp=fopen(name,"w"))==NULL) // can't open file - return error
        return FALSE;

    plu=*plulist;   // start of list
    while (plu!=NULL) { // for each item
        fprintf(fp,"%010ld%-25.25s%06ld%010ld%010ld%010ld%010ld%010ld%010ld\n",
            plu->plu_code,
            plu->desc,
            plu->edate,
            plu->price[0],
            plu->price[1],
            plu->price[2],
            plu->price[3],
            plu->price[4],
            plu->price[5]);
        plu=plu->next;  // next item
    } 

    fclose(fp); // done - close file

    if (freelist) FreeReMACSPLUList(plulist); // free associated memory
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F LoadPLU
//S Load a PLU file into a linked list
//D Load a PLU file into a linked list
//P The file name
//P A pointer to the empty linked list i.e. *(plulist)==NULL
//P A pointer to the ReMACS plu list (for price updates)
//R 1 PLU file changed 2 of PLU file not changed. 0 if memory or file error. 
INT LoadPLU(CHAR *name,PLU **plulist,REMACSPLU *rplulist)
{
    BOOL retval=2;          // return value (set by ERROREXIT macro)
    static CHAR line[1000]; // read line buffer
    REMACSPLU *rplu;        // current ReMACS PLU
    PLU *plu;               // current PLU
    PLU *nextp;             // next PLU
    PLU *prevp;             // previous PLU
    FILE *fp;               // PLU file pointer
    INT pindex;             // Price level index counter

    if ((fp=fopen(name,"r"))!=NULL) { // if open OK
        while ((fgets(line,1000,fp))!=NULL) { // for each line
            if ((plu=MALLOC(sizeof(PLU)))==NULL)              ERROREXIT // get space
            if (!GetLong  (line, 8, 6,&(plu->plu_code)))      ERROREXIT // read plu code
            if (!GetString(line,14,10,plu->status.as_string)) ERROREXIT // status string
            if (!GetString(line,24,12,plu->desc1))            ERROREXIT // first description
            if (!GetString(line,36,12,plu->desc2))            ERROREXIT // second description (unused)
            if (!GetLong  (line,48, 6,&(plu->price[0])))      ERROREXIT // price level 1
            if (!GetLong  (line,54, 6,&(plu->price[1])))      ERROREXIT // price level 2
            if (!GetLong  (line,60, 6,&(plu->price[2])))      ERROREXIT // price level 3
            if (!GetLong  (line,66, 6,&(plu->price[3])))      ERROREXIT // price level 4
            if (!GetLong  (line,72, 6,&(plu->price[4])))      ERROREXIT // price level 5
            if (!GetLong  (line,78, 6,&(plu->price[5])))      ERROREXIT // price level 6
            if (!GetInt   (line,84, 2,&(plu->iosmtab[0])))    ERROREXIT // iosm table 1 (unused)
            if (!GetInt   (line,86, 2,&(plu->iosmtab[1])))    ERROREXIT // iosm table 2 (unused)
            if (!GetInt   (line,88, 2,&(plu->iosmtab[2])))    ERROREXIT // iosm table 3 (unused)
            if (!GetInt   (line,90, 2,&(plu->iosmtab[3])))    ERROREXIT // iosm table 4 (unused)
            if (!GetInt   (line,92, 2,&(plu->iosmtab[4])))    ERROREXIT // iosm table 5 (unused)
            if (!GetInt   (line,94, 2,&(plu->iosmtab[5])))    ERROREXIT // iosm table 6 (unused)
            if (!GetInt   (line,96, 2,&(plu->assoc_dept)))    ERROREXIT // associated department
            if (!GetInt   (line,98, 1,&(plu->action)))        ERROREXIT // action
            rplu=FindRePLU(rplulist,plu->plu_code); // find PLU in ReMACS list
            if (rplu!=NULL) {                       // if found
                for (pindex=0;pindex<6;pindex++) {
                    if (plu->price[pindex]!=rplu->price[pindex]) {
                        AuditLog("PLU Price Change PLU %ld Price level %d From %ld to %ld",
                            plu->plu_code,pindex,plu->price[pindex],rplu->price[pindex]);
                        plu->price[pindex] =rplu->price[pindex];       // reset pricing
                        retval=1;
                    }
                }
            }
            plu->next=*plulist; // add to start of list
            *plulist=plu;
        }
        fclose(fp); // done - close file
    } 

    rplu=rplulist;       // start of ReMACS plu list
    while (rplu!=NULL) { // for each item
        plu=FindPLU(*plulist,rplu->plu_code); // find the ReMACS PLU in the PLU list
        if (plu==NULL) { // if not found - add a new one
            retval=1;
            AuditLog("PLU %ld Added",rplu->plu_code);
            if ((plu=MALLOC(sizeof(PLU)))==NULL)              ERROREXIT // get space
            plu->plu_code=rplu->plu_code;        // assign values from ReMACS plu list
            strcpy(plu->status.as_string,"0000000000");
            sprintf(plu->desc1,"%-12.12s",rplu->desc);
            strcpy(plu->desc2,"            ");
            plu->price[0]=rplu->price[0];
            plu->price[1]=rplu->price[1];
            plu->price[2]=rplu->price[2];
            plu->price[3]=rplu->price[3];
            plu->price[4]=rplu->price[4];
            plu->price[5]=rplu->price[5];
            plu->iosmtab[0]=0;
            plu->iosmtab[1]=0;
            plu->iosmtab[2]=0;
            plu->iosmtab[3]=0;
            plu->iosmtab[4]=0;
            plu->iosmtab[5]=0;
            plu->assoc_dept=0;
            plu->action    =0;
            plu->next=*plulist;
            *plulist=plu;
        }
        rplu=rplu->next; // next item in list
    }
    plu=*plulist;         // reverse the list
    prevp=NULL;           // new end of list
    while (plu!=NULL) {   // for each item
        nextp=plu->next;  // get next
        plu->next=prevp;  // set next to previous
        prevp=plu;        // set previous to current
        plu=nextp;        // move to next item
    }
    *plulist=prevp;       // point to new start
    
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F FreeDeptList
//S Free memory associated with a department list
//D Free memory associated with a department list
//P The department linked list
void FreeDeptList(DEPARTMENT **deptlist)
{
    DEPARTMENT *dept;           // next item in list
    while (*deptlist!=NULL) {   // for each item in list
        dept=(*deptlist)->next; // get next
        FREE(*deptlist);        // free current
        *deptlist=dept;         // move current to next
    }
}
//__________________________________________________________________________

//==========================================================================
//F SaveDepartment
//S Save a department file from a linked list
//D Save a department file from a linked list and conditionally
//D free the memory associated with the list. If the department lis
//D is empty or NULL, this function creates a file of numbkey departments
//P The department file
//P The department linked list
//P The number of keys in the list (used to generate a new list)
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error
BOOL SaveDepartment(CHAR *name,DEPARTMENT **deptlist,INT numbkey,BOOL freelist)
{
    FILE *fp;         // the department file pointer
    DEPARTMENT *dept; // the current department
    INT kindex;       // key index counter

    if ((fp=fopen(name,"w"))==NULL) // can't open - return error
        return FALSE;

    if ((deptlist==NULL)||(*deptlist==NULL)) { // no department info
        for (kindex=0;kindex<numbkey;kindex++) { // create empty dept. file
            fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                kindex+1,"00000000","00","",0L,0L,0L,1);
        }
        fclose(fp); // done - close file
        return TRUE;
    }

    for (kindex=0;kindex<numbkey;kindex++) { // output in key order
        dept=FindDept(*deptlist,kindex+1); // find the department structure
        if (dept!=NULL) {   
            // if key is a single shot
            if (!strcmp(dept->status.as_string,"01550040")) {
                fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                    dept->dept_number,"01550040","00","",
                    dept->osp_code[0],dept->osp_code[1],dept->osp_code[2],0);
            } else { // otherwise save as menu
                if (strcmp(dept->status.as_string,"00000000")) {
                    fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                        dept->dept_number,"01550050","00",dept->desc,0L,0L,0L,0);
                } else { // or empty (deleted) key
                    fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                        kindex+1,"00000000","00","",0L,0L,0L,1);
                }
            }
        } else { // not found - create new, empty key
            fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                kindex+1,"00000000","00","",0L,0L,0L,1);
        }
    }
    fclose(fp); // done - close file

    if (freelist) FreeDeptList(deptlist); // free associated memory
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F FreePLUList
//S Free memory associated with a PLU list
//D Free memory associated with a PLU list
//P The department linked list
void FreePLUList(PLU **plulist)
{
    PLU *plu;                       // next item in list
    while (*plulist!=NULL) {        // for each item in list
        plu=(*plulist)->next;       // get next
        FREE(*plulist);             // free current
        *plulist=plu;               // move current to next
    }
}
//__________________________________________________________________________

//==========================================================================
//F SavePLU
//S Save a PLU file from a linked list
//D Save a PLU file from a linked list and conditionally
//D free the memory associated with the list
//P The PLU file
//P The PLU linked list
//P The Department list (used to see if an item is not a menu i.e. assoc=99)
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error or plulist==NULL or plulist empty
BOOL SavePLU(CHAR *name,PLU **plulist,DEPARTMENT *deptlist,BOOL freelist)
{
    FILE *fp;   // PLU file pointer
    PLU *plu;   // current PLU
    INT pindex; // price level index counter
    INT tindex; // iosm table index counter

    if ((plulist==NULL)||(*plulist==NULL)) return FALSE; // empty or invalid - return error

    if ((fp=fopen(name,"w"))==NULL) return FALSE; // can't open - return error

    plu=*plulist;           // start of list
    while (plu!=NULL) {     // for each item in list
        fprintf(fp,"00000000%06ld%s%-12.12s%-12.12s",
            plu->plu_code,plu->status.as_string,plu->desc1,plu->desc2);

        for (pindex=0;pindex<6;pindex++)  // for each price level
            fprintf(fp,"%06ld",plu->price[pindex]);

        for (tindex=0;tindex<6;tindex++)  // for iosm table item
            fprintf(fp,"%02d",plu->iosmtab[tindex]);

        plu->action=4; // set to always replace

        // if item is not 0 and a menu then save as-is
        if ( (plu->assoc_dept!=0)
        && ismenu(FindDept(deptlist,plu->assoc_dept)) ) {
            fprintf(fp,"%02d%d0000000000\n",plu->assoc_dept,plu->action);
        } else { // otherwise set associated department to 99
            fprintf(fp,"%02d%d0000000000\n",99,plu->action);
        }
        plu=plu->next; // next item
    }

    fclose(fp); // done - close file

    if (freelist) FreePLUList(plulist); // free associated memory
    return TRUE;
}
//__________________________________________________________________________


//==========================================================================
//F LoadLayout
//S Load a keyboard layout file
//D Load a keyboard layout file into an array of ULONGs in the format
//D bits 31-24 the line of the key
//D bits 23-16 the column of the key
//D bits 15-00 the key number (department)
//P The keyboard layout file
//P The address of a KEYMETRICS structure
//R a pointer to an array of ULONGs allocated from the heap
ULONG *LoadLayout(CHAR *name,KEYMETRICS *keys)
{
    static CHAR line[MAXSTRLEN]; // read line buffer
    CHAR *token;                 // current token
    FILE *fp;                    // Layout file pointer
    ULONG *layout;               // list of department numbers & flags
    INT curkey=0;                // the current key
    ULONG curline=0L;            // the current line i.e. y coordinate
    ULONG curcol;                // the current column i.e. x coordinate

    if ((fp=fopen(name,"r"))==NULL) // can't open - return error
        return NULL;

    if ((fgets(line,1000,fp))==NULL) { // can't read first line - return error
        fclose(fp);         // close file first
        return NULL;
    }
    if ((token=strtok(line," ,.;\r\n\t"))==NULL) { // no tokens on line
        fclose(fp);   // close file first
        return NULL;
    }
    keys->number=atoi(token); // first token = number of keys

    if ((layout=MALLOC(keys->number*sizeof(ULONG)))==NULL) { // can't get memory
        fclose(fp);
        return NULL;
    }
    if ((token=strtok(NULL," ,.;\r\n\t"))==NULL) { // no second token
        fclose(fp);
        return NULL;
    }
    keys->width=atoi(token)+1; // second token - character width of key

    if ((token=strtok(NULL," ,.;\r\n\t"))==NULL) { // no third token
        fclose(fp);
        return NULL;
    }
    keys->height=atoi(token)+1; // third token - character height of key

    while ((fgets(line,1000,fp))!=NULL) { // for each line in the rest of the file
        token=strtok(line," ,.;\r\n\t"); // get first token
        curcol=0L;                       // column = 0
        while (token!=NULL) { // while there is a token
            // set key to bits [31-24]=line [23-16]=column [15-0]=department
            layout[curkey++]=(curline<<24)|(curcol<<16)|atol(token);
            curcol++;  // next column
            token=strtok(NULL," ,.;\r\n\t"); // next token
        }
        curline++; // next line
    }

    fclose(fp); // done - close file
    return layout;
}
//__________________________________________________________________________

//==========================================================================
//F LoadColours
//S Load the colour file
//D Load the colour file
//P The colour file
//P The address of an array of colour values
void LoadColours(CHAR *name,INT *cbuf)
{
    static CHAR line[MAXSTRLEN]; // read line buffer
    FILE *fp;                    // colour file pointer
    INT curcol=0;                // current colour array offset

    fp=fopen(name,"r");          // no file - use defaults
    if (fp==NULL) return;

    while ((fgets(line,1000,fp))!=NULL) { // for each line in file
        if (line[0]!=';') {               // if line not commented
            if ((line[0]>='0')&&(line[0]<='9')) {  // convert 2 hex digits
                cbuf[curcol]=(line[0]-'0')*16;
            } else if ((line[0]>='A')&&(line[0]<='F')) {
                cbuf[curcol]=(line[0]-'A')*16 +160;
            }
            if ((line[1]>='0')&&(line[1]<='9')) {
                cbuf[curcol]+=(line[1]-'0');
            } else if ((line[1]>='A')&&(line[1]<='F')) {
                cbuf[curcol]+=(line[1]-'A')+10;
            }
            curcol++;                       // next colour
            if (curcol>=NUMBCOLOUR) break;  // stop overflow
        }
    }
    fclose(fp); // done - close file
}
//__________________________________________________________________________

// compile with -DMODULE_TESTING to test as stand alone application
#ifdef MODULE_TESTING 
#include "filetest.c"
#endif // MODULE_TESTING


//=========================================================================
// End of file (FILEIO.C)
//=========================================================================


