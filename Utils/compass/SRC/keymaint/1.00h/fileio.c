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

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // file i/o declarations


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
void AuditLog(CHAR *format,...)
{
    static CHAR outstr[MAXSTRLEN];                 // output string buffer
    static BOOL donestart=FALSE;
	va_list ap;                                    // variable arg. list ptr.
    time_t t;
    FILE *fp;

    fp=fopen(AUDITFILE,"a+");
    if (fp==NULL) {
        fprintf(stderr,"Can't Open Audit Trail!\n");
        return;
    }

    va_start(ap,format);                           // start variable arg. list
    vsprintf(outstr,format,ap);                    // convert args to string
    va_end(ap);                                    // end variable arg. list

    t=time(NULL);

    if (!donestart) {
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        fprintf(fp,"Audit Log Start %s",ctime(&t));
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        donestart=TRUE;
    }
    fprintf(fp,"%s %s",outstr,ctime(&t));
    fclose(fp);
}
INT LoadPrinterParams(void)
{
    FILE *fp;
    CHAR buffer[MAXSTRLEN];

    fp=fopen(PRINTERFILE,"r");
    if (fp==NULL) return PCL;

    if (fgets(buffer,MAXSTRLEN,fp)!=NULL) {
        if (buffer[0]=='E') {
            fclose(fp);
            return EPSON;
        }
    }
    fclose(fp);
    return PCL;
}
//==========================================================================
//F CleanBuf
//S Remove any spaces at the start and end of a string
//D Remove any spaces at the start and end of a string
//P The padded string
//R The cleaned string
CHAR *CleanBuf(CHAR *str)
{
    static CHAR buffer[MAXSTRLEN];                    // output string buffer
    CHAR *bufend;

    if (str==NULL) return str;

    while ((*str)&&(*str==' ')) str++;

    strcpy(buffer,str);

    bufend=buffer+strlen(buffer)-1;
    while ((bufend!=buffer)
       &&  ((*bufend==' ')
       ||   (*bufend=='\r')
       ||   (*bufend=='\n')
       ||   (*bufend=='\t')  ) )
        *(bufend--)=0;
    return buffer;
}
//__________________________________________________________________________

BOOL ismenu(DEPARTMENT *dept)
{
    if (dept==NULL) return(FALSE);

    return (strcmp(dept->status.as_string,"01550050")==0);
}
PLU *FindPLU(PLU *plulist,LONG plu_code)
{
    while (plulist!=NULL) {
        if (plulist->plu_code==plu_code)
            return plulist;
        plulist=plulist->next;
    }
    return NULL;
}
REMACSPLU *FindRePLU(REMACSPLU *plulist,LONG plu_code)
{
    while (plulist!=NULL) {
        if (plulist->plu_code==plu_code)
            return plulist;
        plulist=plulist->next;
    }
    return NULL;
}
DEPARTMENT *FindDept(DEPARTMENT *deptlist,INT dept)
{
    while (deptlist!=NULL) {
        if (deptlist->dept_number==dept)
            return deptlist;
        deptlist=deptlist->next;
    }
    return NULL;
}
//==========================================================================
//F GetLong
//S Get a LONG from an ASCII string
//D Get a LONG from an ASCII string given an offset and length
//P The source string
//P The offset of the start of the long
//P The length of the string containing a long
//P The address of the returned long
//R TRUE return value OK.  FALSE on error
BOOL GetLong(CHAR *line,INT fieldofs,INT fieldlen,LONG *val)
{
    static CHAR buf[MAXFIELDLEN+1];
    char *str;

    if (((fieldofs+fieldlen)>strlen(line))||(fieldlen>MAXFIELDLEN))
        return FALSE;
    memcpy(buf,line+fieldofs,fieldlen);
    *(buf+fieldlen)='\0';
    str=CleanBuf(buf);
    *val=atol(str);
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F GetInt
//S Get a INT from an ASCII string
//D Get a INT from an ASCII string given an offset and length
//P The source string
//P The offset of the start of the INT
//P The length of the string containing a INT
//P The address of the returned INT
//R TRUE return value OK.  FALSE on error
BOOL GetInt(CHAR *line,INT fieldofs,INT fieldlen,INT *val)
{
    BOOL retval;
    LONG tempval;
    retval=GetLong(line,fieldofs,fieldlen,&tempval);
    if (retval) *val=(INT)tempval;
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F GetString
//S Get a String from an ASCII string
//D Get a String from an ASCII string given an offset and length
//P The source string
//P The offset of the start of the String
//P The length of the string containing a String
//P The address of the returned String
//R TRUE return value OK.  FALSE on error
BOOL GetString(CHAR *line,INT fieldofs,INT fieldlen,CHAR *buf)
{
    if (((fieldofs+fieldlen)>strlen(line))||(fieldlen>MAXFIELDLEN))
        return FALSE;
    memcpy(buf,line+fieldofs,fieldlen);
    *(buf+fieldlen)='\0';
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F LoadConfig
//S Load the configurations file into a linked list
//D Load the configurations file into a linked list
//P A pointer to the empty linked list i.e. *(cfglist)==NULL
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadConfig(CHAR *name,CONFIG **cfglist)
{
    BOOL retval=TRUE;
    static CHAR line[1000];
    CONFIG *cfg;
    CONFIG *nextc;
    CONFIG *prevc;
    FILE *fp;
    
    if ((fp=fopen(name,"r"))==NULL) return FALSE;

    while ((fgets(line,1000,fp))!=NULL) {
        if ((cfg=malloc(sizeof(CONFIG)))==NULL)          ERROREXIT
        if (!GetString(line, 0, 2,  cfg->ctrl_centre))   ERROREXIT
        if (!GetString(line, 2,15,  cfg->cc_desc    ))   ERROREXIT
        if (!GetInt   (line,17, 2,&(cfg->term_id    )))  ERROREXIT
        if (!GetString(line,19,15,  cfg->term_desc  ))   ERROREXIT
        if (!GetString(line,34, 3,  cfg->term_type  ))   ERROREXIT
        cfg->next=*cfglist;
        *cfglist=cfg;
    }
    fclose(fp);

    cfg=*cfglist;   // reverse the list
    prevc=NULL;
    while (cfg!=NULL) {
        nextc=cfg->next;
        cfg->next=prevc;
        prevc=cfg;
        cfg=nextc;
    }
    *cfglist=prevc;
    return retval;
}
//__________________________________________________________________________


void FreeCFGList(CONFIG **cfglist)
{
    CONFIG *cfg;
    while (*cfglist!=NULL) {
        cfg=(*cfglist)->next;
        free(*cfglist);
        *cfglist=cfg;
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
    FILE *fp;
    CONFIG *cfg;

    if ((cfglist==NULL)||(*cfglist==NULL))
        return FALSE;

    if ((fp=fopen(name,"w"))==NULL)
        return FALSE;

    cfg=*cfglist;
    while (cfg!=NULL) {
        fprintf(fp,"%03d%-15.15s%02d%-15.15s%-3.3s\n",
            cfg->ctrl_centre,
            cfg->cc_desc    ,
            cfg->term_id    ,
            cfg->term_desc  ,
            cfg->term_type  );
        cfg=cfg->next;
    }

    fclose(fp);

    if (freelist) FreeCFGList(cfglist);
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
    BOOL retval=TRUE;
    static CHAR line[1000];
    char emptybuf[20];
    DEPARTMENT *dept;
    DEPARTMENT *nextd;
    DEPARTMENT *prevd;
    FILE *fp;
    
    if ((fp=fopen(name,"r"))==NULL) {
        if (!SaveDepartment(name,NULL,numbkey,FALSE)) return FALSE;
        if ((fp=fopen(name,"r"))==NULL) {
            return FALSE;
        }
    }

    while ((fgets(line,1000,fp))!=NULL) {
        if ((dept=malloc(sizeof(DEPARTMENT)))==NULL)      ERROREXIT
        if (!GetString(line, 0,8,emptybuf))               ERROREXIT
        if (!GetInt   (line, 8,2,&(dept->dept_number)))   ERROREXIT
        if (!GetString(line,10,8,dept->status.as_string)) ERROREXIT
        if (!GetString(line,18,2,dept->active))           ERROREXIT
        if (!GetString(line,20,8,dept->desc))             ERROREXIT
        if (!GetLong  (line,28,6,&(dept->osp_code[0])))   ERROREXIT
        if (!GetLong  (line,34,6,&(dept->osp_code[1])))   ERROREXIT
        if (!GetLong  (line,40,6,&(dept->osp_code[2])))   ERROREXIT
        if (!GetInt   (line,46,1,&(dept->action)))        ERROREXIT
        dept->next=*deptlist;
        *deptlist=dept;
    }
    fclose(fp);

    dept=*deptlist;   // reverse the list
    prevd=NULL;
    while (dept!=NULL) {
        nextd=dept->next;
        dept->next=prevd;
        prevd=dept;
        dept=nextd;
    }
    *deptlist=prevd;
    return retval;
}
//__________________________________________________________________________

void AddReMACSPLU(REMACSPLU **plulist,REMACSPLU *plu,LONG price,INT plevel)
{
    static LONG today=0L;
    struct tm *t;
    struct timeb tb;
    REMACSPLU *pluptr;

    if (today==0L) {
       	ftime(&tb);
    	t=localtime(&tb.time);
        t->tm_mon++;
        today =(LONG)t->tm_year*10000L;
        today+=(LONG)t->tm_mon *100L  ;
        today+=(LONG)t->tm_mday       ;
    }
    if (plulist==NULL) return;

    pluptr=*plulist;
    while (pluptr!=NULL) {
        if (pluptr->plu_code==plu->plu_code) {
            if (pluptr->edate==plu->edate) {    // same date - add price
//                if (pluptr->price[plevel]!=price)
//                    AuditLog("PLU updated %ld %ld %s",plu->edate,plu->plu_code,plu->desc);
                pluptr->price[plevel]=price;
                pluptr->done1=TRUE;
                free(plu);
                return;
            }
            if (pluptr->edate<plu->edate) {     // later date 
                if (plu->edate<=today+1L) {     // if ready for load - change
                    pluptr->edate=plu->edate;
//                    if (pluptr->price[plevel]!=price)
//                        AuditLog("PLU Date updated %ld %ld %s",plu->edate,plu->plu_code,plu->desc);
                    pluptr->price[plevel]=price;
                    pluptr->done1=TRUE;
                    free(plu);
                    return;
                }
            } else {    // current is newer than latest - ignore latest
//                AuditLog("PLU Ignored - Out of date %ld %ld %s",plu->edate,plu->plu_code,plu->desc);
                pluptr->done1=TRUE;
                free(plu);
                return;
            }
        }
        pluptr=pluptr->next;
    }
    plu->price[plevel]=price;  // add new or add one for later
    plu->next=*plulist;
//    AuditLog("New PLU %ld %ld %s",plu->edate,plu->plu_code,plu->desc);
    plu->done1=TRUE;
    *plulist=plu;
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
    BOOL retval=TRUE;
    static CHAR line[1000];
    char tempbuf[20];
    INT plevel;
    REMACSPLU *plu;
    REMACSPLU *nextp;
    REMACSPLU *prevp;
    FILE *fp;

    if ((fp=fopen(name,"r"))==NULL) return FALSE;

    while ((fgets(line,1000,fp))!=NULL) {
        if ((plu=malloc(sizeof(REMACSPLU)))==NULL)        ERROREXIT
        if (!GetString(line, 0, 1,tempbuf))               ERROREXIT

        if (tempbuf[0]=='P') {
            if (!GetLong  (line, 1,15,&(plu->plu_code)))  ERROREXIT
            if (!GetString(line,16,25,plu->desc))         ERROREXIT
            if (!GetLong  (line,41, 6,&(plu->edate)))     ERROREXIT
            if (!GetInt   (line,47,10,&(plevel)))         ERROREXIT
            if (!GetString(line,67,10,tempbuf))           ERROREXIT
            AddReMACSPLU(plulist,plu,(LONG)(atof(tempbuf)*100.00),plevel-1);
        }

    }
    fclose(fp);

    plu=*plulist;   // remove redundant data
    prevp=NULL;
    while (plu!=NULL) {
        nextp=plu->next;
        if (!plu->done1) {
            if (prevp==NULL) {
                *plulist=nextp;
            } else {
                prevp->next=nextp;
            }
            AuditLog("PLU Deleted\n%010ld%-25.25s%06ld%010ld%010ld%010ld%010ld%010ld%010ld\nat",
                plu->plu_code,plu->desc,plu->edate,plu->price[0],plu->price[1],
                plu->price[2],plu->price[3],plu->price[4],plu->price[5]);
            free(plu);
        } else {
            prevp=plu;
        }
        plu=nextp;
    }
    plu=*plulist;   // reverse the list
    prevp=NULL;
    while (plu!=NULL) {
        nextp=plu->next;
        plu->next=prevp;
        prevp=plu;
        plu=nextp;
    }
    *plulist=prevp;
    
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
    BOOL retval=TRUE;
    static CHAR line[1000];
    INT plevel;
    REMACSPLU *plu;
    FILE *fp;

    if ((fp=fopen(name,"r"))==NULL) return FALSE;

    while ((fgets(line,1000,fp))!=NULL) {
        if ((plu=malloc(sizeof(REMACSPLU)))==NULL)       ERROREXIT
        if (!GetLong  (line, 0,10,&(plu->plu_code)))     ERROREXIT
        if (!GetString(line,10,25,plu->desc))            ERROREXIT
        if (!GetLong  (line,35, 6,&(plu->edate)))        ERROREXIT
        for (plevel=0;plevel<6;plevel++) {
            if (!GetLong(line,41+plevel*10,10,&(plu->price[plevel])))
                ERROREXIT
        }
        plu->next=*plulist;
        plu->done1=FALSE;
        *plulist=plu;
//        plu=NULL;
    }
    fclose(fp);

    return retval;
}
//__________________________________________________________________________

void FreeReMACSPLUList(REMACSPLU **plulist)
{
    REMACSPLU *plu;
    while (*plulist!=NULL) {
        plu=(*plulist)->next;
        free(*plulist);
        *plulist=plu;
    }
}
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
    FILE *fp;
    REMACSPLU *plu;

    if ((plulist==NULL)||(*plulist==NULL))
        return FALSE;

    if ((fp=fopen(name,"w"))==NULL)
        return FALSE;

    plu=*plulist;
    while (plu!=NULL) {
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
        plu=plu->next;
    }

    fclose(fp);

    if (freelist) FreeReMACSPLUList(plulist);
    return TRUE;
}
//__________________________________________________________________________

//==========================================================================
//F LoadPLU
//S Load a PLU file into a linked list
//D Load a PLU file into a linked list
//P the file name
//P A pointer to the empty linked list i.e. *(plulist)==NULL
//R TRUE if all OK. FALSE if memory or file error. 
BOOL LoadPLU(CHAR *name,PLU **plulist,REMACSPLU *rplulist)
{
    BOOL retval=TRUE;
    static CHAR line[1000];
    char emptybuf[20];
    REMACSPLU *rplu;
    PLU *plu;
    PLU *nextp;
    PLU *prevp;
    FILE *fp;

    if ((fp=fopen(name,"r"))!=NULL) {
        while ((fgets(line,1000,fp))!=NULL) {
            if ((plu=malloc(sizeof(PLU)))==NULL)              ERROREXIT
            if (!GetString(line, 0, 8,emptybuf))              ERROREXIT
            if (!GetLong  (line, 8, 6,&(plu->plu_code)))      ERROREXIT
            if (!GetString(line,14,10,plu->status.as_string)) ERROREXIT
            if (!GetString(line,24,12,plu->desc1))            ERROREXIT
            if (!GetString(line,36,12,plu->desc2))            ERROREXIT
            if (!GetLong  (line,48, 6,&(plu->price[0])))      ERROREXIT
            if (!GetLong  (line,54, 6,&(plu->price[1])))      ERROREXIT
            if (!GetLong  (line,60, 6,&(plu->price[2])))      ERROREXIT
            if (!GetLong  (line,66, 6,&(plu->price[3])))      ERROREXIT
            if (!GetLong  (line,72, 6,&(plu->price[4])))      ERROREXIT
            if (!GetLong  (line,78, 6,&(plu->price[5])))      ERROREXIT
            if (!GetInt   (line,84, 2,&(plu->iosmtab[0])))    ERROREXIT
            if (!GetInt   (line,86, 2,&(plu->iosmtab[1])))    ERROREXIT
            if (!GetInt   (line,88, 2,&(plu->iosmtab[2])))    ERROREXIT
            if (!GetInt   (line,90, 2,&(plu->iosmtab[3])))    ERROREXIT
            if (!GetInt   (line,92, 2,&(plu->iosmtab[4])))    ERROREXIT
            if (!GetInt   (line,94, 2,&(plu->iosmtab[5])))    ERROREXIT
            if (!GetInt   (line,96, 2,&(plu->assoc_dept)))    ERROREXIT
            if (!GetInt   (line,98, 1,&(plu->action)))        ERROREXIT
            rplu=FindRePLU(rplulist,plu->plu_code);
            if (rplu!=NULL) {
                plu->price[0]=rplu->price[0];
                plu->price[1]=rplu->price[1];
                plu->price[2]=rplu->price[2];
                plu->price[3]=rplu->price[3];
                plu->price[4]=rplu->price[4];
                plu->price[5]=rplu->price[5];
            } else {
                // remove plu ???
//                plu->price[0]=0;
//                plu->price[1]=0;
//                plu->price[2]=0;
//                plu->price[3]=0;
//                plu->price[4]=0;
//                plu->price[5]=0;
            }
            plu->next=*plulist;
            *plulist=plu;
        }
        fclose(fp);
    }

    rplu=rplulist;
    while (rplu!=NULL) {
        plu=FindPLU(*plulist,rplu->plu_code);
        if (plu==NULL) {
            if ((plu=malloc(sizeof(PLU)))==NULL)              ERROREXIT
            plu->plu_code=rplu->plu_code;
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
        rplu=rplu->next;
    }
    plu=*plulist;   // reverse the list
    prevp=NULL;
    while (plu!=NULL) {
        nextp=plu->next;
        plu->next=prevp;
        prevp=plu;
        plu=nextp;
    }
    *plulist=prevp;
    
    return retval;
}
//__________________________________________________________________________

void FreeDeptList(DEPARTMENT **deptlist)
{
    DEPARTMENT *dept;
    while (*deptlist!=NULL) {
        dept=(*deptlist)->next;
        free(*deptlist);
        *deptlist=dept;
    }
}
//==========================================================================
//F SaveDepartment
//S Save a department file from a linked list
//D Save a department file from a linked list and conditionally
//D free the memory associated with the list
//P The department file
//P The department linked list
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error or deptlist==NULL or deptlist empty
BOOL SaveDepartment(CHAR *name,DEPARTMENT **deptlist,INT numbkey,BOOL freelist)
{
    FILE *fp;
    DEPARTMENT *dept;
    INT kindex;

    if ((fp=fopen(name,"w"))==NULL)
        return FALSE;

    if ((deptlist==NULL)||(*deptlist==NULL)) {
        for (kindex=0;kindex<numbkey;kindex++) {
            fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                kindex+1,"00000000","00","",0L,0L,0L,1);
        }
        fclose(fp);
        return TRUE;
    }

    for (kindex=0;kindex<numbkey;kindex++) {
        dept=FindDept(*deptlist,kindex+1);
        if (dept!=NULL) {
            // single shot
            if (!strcmp(dept->status.as_string,"01550040")) {
                fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                    dept->dept_number,"01550040","00","",
                    dept->osp_code[0],
                    dept->osp_code[1],
                    dept->osp_code[2],
                    0);
            } else { // menu
                if (strcmp(dept->status.as_string,"00000000")) {
                    fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                        dept->dept_number,"01550050","00",dept->desc,0L,0L,0L,0);
                } else {
                    fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                        kindex+1,"00000000","00","",0L,0L,0L,1);
                }
            }
        } else {
            fprintf(fp,"00000000%02d%s%s%-8.8s%06ld%06ld%06ld%d0000000000\n",
                kindex+1,"00000000","00","",0L,0L,0L,1);
        }
    }
    fclose(fp);

    if (freelist) FreeDeptList(deptlist);
    return TRUE;
}
//__________________________________________________________________________

void FreePLUList(PLU **plulist)
{
    PLU *plu;
    while (*plulist!=NULL) {
        plu=(*plulist)->next;
        free(*plulist);
        *plulist=plu;
    }
}
//==========================================================================
//F SavePLU
//S Save a PLU file from a linked list
//D Save a PLU file from a linked list and conditionally
//D free the memory associated with the list
//P The PLU file
//P The PLU linked list
//P TRUE if the memory associated with the list should be free'd
//R TRUE if OK, FALSE on file error or plulist==NULL or plulist empty
BOOL SavePLU(CHAR *name,PLU **plulist,DEPARTMENT *deptlist,BOOL freelist)
{
    FILE *fp;
    PLU *plu;
    INT pindex;
    INT tindex;
    if ((plulist==NULL)||(*plulist==NULL)) return FALSE;

    if ((fp=fopen(name,"w"))==NULL) return FALSE;

    plu=*plulist;
    while (plu!=NULL) {
        fprintf(fp,"00000000%06ld%s%-12.12s%-12.12s",
            plu->plu_code,plu->status.as_string,plu->desc1,plu->desc2);

        for (pindex=0;pindex<6;pindex++) 
            fprintf(fp,"%06ld",plu->price[pindex]);

        for (tindex=0;tindex<6;tindex++) 
            fprintf(fp,"%02d",plu->iosmtab[tindex]);

        plu->action=4; // set to always replace

        if ( (plu->assoc_dept!=0) &&
             ismenu(FindDept(deptlist,plu->assoc_dept)) ) {
            fprintf(fp,"%02d%d0000000000\n",plu->assoc_dept,plu->action);
        } else {
            fprintf(fp,"%02d%d0000000000\n",99,plu->action);
        }
        plu=plu->next;
    }

    fclose(fp);

    if (freelist) FreePLUList(plulist);
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
//P The address of an INT for the returned number of keys
//P The address of an INT for the returned key width in characters
//P The address of an INT for the returned key height in characters
//R a pointer to an array of ULONGs allocated from the heap
ULONG *LoadLayout(CHAR *name,KEYMETRICS *keys)
{
    static CHAR line[1000];
    CHAR *token;
    FILE *fp;
    ULONG *layout;
    INT curkey=0;
    ULONG curline=0L;
    ULONG curcol;

    fp=fopen(name,"r");
    if (fp==NULL) return NULL;
    if ((fgets(line,1000,fp))==NULL) {
        fclose(fp);
        return NULL;
    }
    if ((token=strtok(line," ,.;\r\n\t"))==NULL) {
        fclose(fp);
        return NULL;
    }
    keys->number=atoi(token);
    if ((layout=malloc(keys->number*sizeof(ULONG)))==NULL) {
        fclose(fp);
        return NULL;
    }
    if ((token=strtok(NULL," ,.;\r\n\t"))==NULL) {
        fclose(fp);
        return NULL;
    }
    keys->width=atoi(token)+1;

    if ((token=strtok(NULL," ,.;\r\n\t"))==NULL) {
        fclose(fp);
        return NULL;
    }
    keys->height=atoi(token)+1;

    while ((fgets(line,1000,fp))!=NULL) {
        token=strtok(line," ,.;\r\n\t");
        curcol=0L;
        while (token!=NULL) {
            layout[curkey++]=(curline<<24)|(curcol<<16)|atol(token);
            curcol++;
            token=strtok(NULL," ,.;\r\n\t");
        }
        curline++;
    }

    fclose(fp);
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
    static CHAR line[1000];
    FILE *fp;
    INT curcol=0;

    fp=fopen(name,"r");
    if (fp==NULL) return;

    while ((fgets(line,1000,fp))!=NULL) {
        if (line[0]!=';') {
            if ((line[0]>='0')&&(line[0]<='9')) {
                cbuf[curcol]=(line[0]-'0')*16;
            } else if ((line[0]>='A')&&(line[0]<='F')) {
                cbuf[curcol]=(line[0]-'A')*16 +160;
            }
            if ((line[1]>='0')&&(line[1]<='9')) {
                cbuf[curcol]+=(line[1]-'0');
            } else if ((line[1]>='A')&&(line[1]<='F')) {
                cbuf[curcol]+=(line[1]-'A')+10;
            }
            curcol++;
            if (curcol>=NUMBCOLOUR) break;
        }
    }
    fclose(fp);
}
//__________________________________________________________________________
#ifdef UNIT_TESTING
#include "filetest.c"
#endif // UNIT_TESTING


//=========================================================================
// End of file (FILEIO.C)
//=========================================================================

