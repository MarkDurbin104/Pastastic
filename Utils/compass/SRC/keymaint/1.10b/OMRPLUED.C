//===============|========================================================|
//               |                                                        |
// Module        | OMRPLUED.C                                             |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | EPoS Keymap End of Day process                         |
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
// 10/06/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|

#define __OMRPLUED_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <dir.h>         // For mkdir()
#include <dos.h>         // For file attributes
#include <conio.h>       // For getch() etc...
#include <malloc.h>      // For getch() etc...
#include <time.h>
#include <sys\timeb.h>
#include <ctype.h>

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations

//=========================================================================
// Globals Section
//=========================================================================

CHAR G_layoutfile [MAXSTRLEN]; // e.g. \KEYMAINT\LAYOUT.OMR
CHAR G_keymapfile [MAXSTRLEN]; // e.g. \KEYMAINT\999\KEYMAP99.OMR
CHAR G_plufile    [MAXSTRLEN]; // e.g. \KEYMAINT\999\PLU99.OMR
CHAR G_keymapback [MAXSTRLEN]; // e.g. \KEYMAINT\999\KEYMAP99.BAK
CHAR G_pluback    [MAXSTRLEN]; // e.g. \KEYMAINT\999\PLU99.BAK
CHAR G_plu_keypath[MAXSTRLEN]; // e.g. \KEYMAINT\999
CHAR G_rplufile   [MAXSTRLEN]; // e.g. \ISS\POSUPDT\POSom999.FLT
CHAR G_lrplufile  [MAXSTRLEN]; // e.g. \KEYMAINT\999\LOCALPLU.OMR
CHAR G_lrpluback  [MAXSTRLEN]; // e.g. \KEYMAINT\999\LOCALPLU.BAK
CHAR G_xmitplufile[MAXSTRLEN]; // e.g. PLUOMRXX.FLT
CHAR G_xmitkeyfile[MAXSTRLEN]; // e.g. OSPOMRXX.FLT
CHAR G_xmitbatch  [MAXSTRLEN]; // e.g. \KEYMAINT\COMPKEYX A7 99

//=========================================================================
// Define Section
//=========================================================================

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC

#define MAXNUMBLINES  500       // maximum number of lines in the list
#define FILEERROR     1         // errorlevel for exit on file error
#define MEMORYERROR   2         // errorlevel for exit on memory error

//=========================================================================
// Types Section
//=========================================================================

typedef struct file_list {      // file linked list structure
    CHAR * name;                // the file name
    struct file_list * next;    // the next file in the list or NULL
} FILELIST;

typedef struct line_list {      // line linked list structure
    CHAR * line;                // the text line from the file
    struct line_list * next;    // the next line in the list or NULL
    struct line_list * prev;    // the previous line in the list or NULL
} LINELIST;

//=========================================================================
// Declarations Section
//=========================================================================

//=========================================================================
// Definitions Section
//=========================================================================

//==========================================================================
//F FindSubDirs
//S Find all the sub-directories of a given directory
//D Find all the sub-directories of a given directory
//P the parent directory
//P the file list to fill
void FindSubDirs(CHAR *path,FILELIST **subdirs)
{
    FILELIST *curdir;
    struct ffblk f;
    static int done;
    static char dirpath[MAXSTRLEN];

    sprintf(dirpath,"%s\\*.*",path);
    done=findfirst(dirpath,&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            if ((curdir=malloc(sizeof(FILELIST)))==NULL) return;
            curdir->name=strdup(f.ff_name);
            curdir->next=*subdirs;
            *subdirs=curdir;
        }
        done=findnext(&f);
    }
}
//__________________________________________________________________________

//==========================================================================
//F RemoveDir
//S Remove a directory and all the files therein ( does not recurse )
//D Remove a directory and all the files therein ( does not recurse )
//P The directory
void RemoveDir(CHAR *dirname)
{
//    FILELIST *curdir;
    struct ffblk f;
    static int done;
    static char dirpath[MAXSTRLEN];

    sprintf(dirpath,"%s\\*.*",dirname);
    done=findfirst(dirpath,&f,FILEATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))) {
            sprintf(dirpath,"%s\\%s",dirname,f.ff_name);
            AuditLog("Removing File %s",dirpath);
            unlink(dirpath);
        }
        done=findnext(&f);
    }
    AuditLog("Removing Directory %s",dirname);
    rmdir(dirname);
}
//__________________________________________________________________________

//==========================================================================
//F DelDirsOlderThan
//S Delete the directories older then a specified date
//D Delete the directories older then a specified date
//P The date as a number i.e. 960618 - 18th June 1996
void DelDirsOlderThan(LONG date)
{
    LONG dirdate;               // date of current directory as a number
    CHAR path[MAXSTRLEN];       // used for path concatination
    FILELIST *subdirs=NULL;     // list of sub-directories under \KEYMAINT
    FILELIST *curdir;           // current sub-directory

    FindSubDirs(XMITPATH1,&subdirs); // get the sub-directories

    curdir=subdirs;                         // select the first
    while (curdir!=NULL) {                  // for each dir
        if (isdigit(curdir->name[0])) {     // if the first char is a digit
            dirdate=atol(curdir->name);     // if > 01/01/96 and < today-8
            if ((dirdate>960101L)&&(dirdate<date)) {
                sprintf(path,"%s\\%s",XMITPATH1,curdir->name);
                RemoveDir(path);            // delete it and its contents
            }
        }
        curdir=curdir->next; // next sub-directory
    }
}
//__________________________________________________________________________

void CleanDirs(void)
{
    LONG todayminus8;       // today's date minus 8 days as a number
    struct tm *t;           // Used to get current date
    struct timeb tb;        // Used to get current date

   	ftime(&tb);
    t=localtime(&tb.time);
    t->tm_mon++;
    if (t->tm_mday<9) {             // subtract 8 days from today
        switch (t->tm_mon) {          
            case 1 :                // Janruary - go back to December
                t->tm_mon=12;
                t->tm_year--;
                t->tm_mday+=(31-8); 
                break;
            case 3 :                    // back to february
                t->tm_mon--;
                if ((t->tm_year%4)==0)  // leap year
                    t->tm_mday+=(29-8);
                else
                    t->tm_mday+=(28-8);
                break;
            case 2 :                // back to a 31 day month
            case 4 :
            case 6 :
            case 8 :
            case 9 :
            case 11 :
                t->tm_mon--;
                t->tm_mday+=(31-8);
                break;
            case 5 :                // back to a 30 day month
            case 7 :
            case 10 :
            case 12 :
                t->tm_mon--;
                t->tm_mday+=(30-8);
                break;
        }
    } else {
        t->tm_mday-=8;   // just take off 8 days
    }
    todayminus8 =(LONG)t->tm_year*10000L;  // date as number i.e. 960618L
    todayminus8+=(LONG)t->tm_mon *100L  ;  // is 18th June 1996
    todayminus8+=(LONG)t->tm_mday       ;

    DelDirsOlderThan(todayminus8);
}
//__________________________________________________________________________
//==========================================================================
//F CleanLog
//S Clean the audit log to the last 500 lines
//D Clean the audit log to the last 500 lines
void CleanLog(void)
{
    FILE *fp;                 // audit trail file pointer
    INT linecount;            // current niumber of lines
    CHAR line[MAXSTRLEN];     // read line buffer
    LINELIST *lastline=NULL;  // list of lines
    LINELIST *firstline;      // last line in list
    LINELIST *curline;        // current line

    fp=fopen(AUDITFILE,"r");  // open the audit trail for read
    if (fp==NULL) return;
    linecount=0;
    while (fgets(line,MAXSTRLEN,fp)!=NULL) { // for each line
        // allocate space for the link
        if ((curline=malloc(sizeof(LINELIST)))==NULL) {
            fclose(fp);
            return;
        }
        curline->line=strdup(line);  // save the read line
        if (curline->line==NULL) {
            fclose(fp);
            return;
        }
        curline->prev=lastline;     // append to end of list
        curline->next=NULL;
        if (lastline==NULL) {
            firstline=curline;
        } else {
            lastline->next=curline;
        }
        lastline=curline;
        linecount++;
        if (linecount>MAXNUMBLINES) {   // remove first line if max count reached
            curline=firstline;
            firstline=firstline->next;
            firstline->prev=NULL;
            free(curline->line);
            free(curline);
            linecount--;
        }
    }   
    fclose(fp);
    fp=fopen(AUDITFILE,"w");  // open the audit trail for write
    if (fp==NULL) {
        return;
    }
    curline=firstline;                   // goto start of list
    while (curline!=NULL) {              // for each line
        firstline=curline;               // move the firstline
        fprintf(fp,"%s",curline->line);  // output the current line
        free(curline->line);             // free the line memory
        curline=curline->next;           // move to next item
        free(firstline);                 // fre the first item
    }
    fclose(fp);  // done - close file
}

//=========================================================================
//F TodaysDate
//S Return a string containing todays date
//D Return a string containing todays date in the format YYMMDD
//R The date string
CHAR *TodaysDate(void)
{
    static struct tm *t;
    static struct timeb tb;
    static CHAR retstring[9];

   	ftime(&tb);
	t=localtime(&tb.time);
    sprintf(retstring,"%02d%02d%02d",t->tm_year%100,t->tm_mon+1,t->tm_mday);
    return retstring;
}
//_________________________________________________________________________

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

//=========================================================================
//F TxForToday
//S Return TRUE if there are files ready for transmition today
//D Return TRUE if there are files ready for transmition today
//R TRUE if tx files exist, otherwise FALSE
BOOL TxForToday(void)
{
    if (!Exists(G_xmitplufile)) return FALSE;
    if (!Exists(G_xmitkeyfile)) return FALSE;
    return TRUE;
}
//_________________________________________________________________________
void CopyFile(CHAR *to,CHAR *from)
{
    CHAR *buffer; // copy buffer
    FILE *ifp;    // input file pointer
    FILE *ofp;    // output file pointer
    UINT len;
    if ((ifp=fopen(from,"r"))!=NULL) {
        if ((ofp=fopen(to,"w"))!=NULL) {
            if ((buffer=malloc(0x4000))!=NULL) {

                while ((len=fread(buffer,1,0x4000,ifp))>0)
                    fwrite(buffer,1,len,ofp);
                free(buffer);
            } else {
                while (fputc(fgetc(ifp),ofp));
            }
            fclose(ofp);
        }
        fclose(ifp);
    }
}
#pragma warn -par
//=========================================================================
//F main
//S process updates from ReMACS into PLU KEYMAP and LOCALPLU files
//D process updates from ReMACS into PLU KEYMAP and LOCALPLU files
//P argument count should be 3
//P arguments - control centre, terminal id.
//R errorlevel 1 = invlaid arguments 2 = error in config file
INT main(INT argc,char *argv[])
{
    CHAR            txpath[MAXSTRLEN];// path to transmit directory
    CHAR            path[MAXSTRLEN];  // path to transmit file
    KEYMETRICS      keys;             // buffer for keys
    DEPARTMENT      *deptlist=NULL;   // department list
    PLU             *plulist =NULL;   // PLU list
    REMACSPLU       *rplulist=NULL;   // ReMACS plu list
    ULONG           *layout;          // layout array
    INT             key;              // the key pressed on error
    CONFIG          *cfglist=NULL;    // configuration list
    CONFIG          *cfg;             // current config line
    BOOL            changed;          // TRUE if files changed

    CleanLog();
    AuditLog("End of Day Procedure Started");
    if ((LoadConfig(CONFIGFILE,&cfglist))==FALSE) {
        printf("Error Loading Configuration File!\n");
        AuditLog("Error Loading Configuration File! %s",CONFIGFILE);
        if (cfglist==NULL) {
            AuditLog("End of Day Procedure Complete");
            return FALSE;
        }
        printf("Some data in the file is correct !\nDo you wish to proceed? Y/N");
        key=getch();
        if ((key!='Y')&&(key!='y')) {
            AuditLog("End of Day Procedure Complete");
            return 2;
        }
        AuditLog("Some data in the file is correct - selected to continue %s",CONFIGFILE);
    }
    cfg=cfglist;
    mkdir(XMITPATH1);                      
    sprintf(txpath,XMITPATH2,TodaysDate());

    sprintf(G_layoutfile ,LAYOUTFILE ,"OMR"); 
    layout=LoadLayout(G_layoutfile,&keys); // load layout (needed for save dept)
    while (cfg!=NULL) {
        changed=FALSE;
        cfg->txnow=FALSE;
        if (!strcmp(cfg->term_type,"OMR")) {
            // set file and path information
            sprintf(G_keymapfile ,KEYMAPFILE ,cfg->ctrl_centre,cfg->term_id,"OMR");
            sprintf(G_plufile    ,PLUFILE    ,cfg->ctrl_centre,cfg->term_id,"OMR");
            sprintf(G_keymapback ,KEYMAPBACK ,cfg->ctrl_centre,cfg->term_id);      
            sprintf(G_pluback    ,PLUBACK    ,cfg->ctrl_centre,cfg->term_id);
            sprintf(G_plu_keypath,PLU_KEYPATH,cfg->ctrl_centre);
            sprintf(G_rplufile   ,RPLUFILE   ,"OMR",cfg->ctrl_centre);
            sprintf(G_lrplufile  ,LRPLUFILE  ,cfg->ctrl_centre,"OMR");
            sprintf(G_lrpluback  ,LRPLUBACK  ,cfg->ctrl_centre);

            sprintf(G_xmitbatch  ,XMITBATCH  ,cfg->ctrl_centre,cfg->term_id);

            sprintf(G_xmitplufile,XMITPLUFILE,"OMR",cfg->ctrl_centre);
            sprintf(path,XMITPATH2 "\\%s",TodaysDate(),G_xmitplufile);
            strcpy(G_xmitplufile,path);

            sprintf(G_xmitkeyfile,XMITKEYFILE,"OMR",cfg->ctrl_centre);
            sprintf(path,XMITPATH2 "\\%s",TodaysDate(),G_xmitkeyfile);
            strcpy(G_xmitkeyfile,path);
    
            mkdir(G_plu_keypath); // create dir ( if it doesn't exist)

            LoadLocalPLU(G_lrplufile,&(rplulist)); // local PLU
            LoadReMACSPLU(G_rplufile,&(rplulist)); // ReMACS PLU
            if (LoadPLU(G_plufile,&(plulist),rplulist)==1) { // PLU Changed
                changed=TRUE;
                LoadDepartment(G_keymapfile,&(deptlist),keys.number); // Department

                AuditLog("Removing %s",G_pluback);
                unlink(G_pluback);                                          // delete backup
                AuditLog("Renaming %s to %s",G_plufile,G_pluback);
                rename(G_plufile,G_pluback);                                // rename
                AuditLog("Saving %s",G_plufile);
                SavePLU(G_plufile,&(plulist),deptlist,TRUE);                // save new

                AuditLog("Removing %s",G_keymapback);
                unlink(G_keymapback);                                       // delete backup 
                AuditLog("Renaming %s to %s",G_keymapfile,G_keymapback);
                rename(G_keymapfile,G_keymapback);                          // rename
                AuditLog("Saving %s",G_keymapfile);
                SaveDepartment(G_keymapfile,&(deptlist),keys.number,TRUE);  // save new
                if (rplulist!=NULL) {                                       // need to save localPLU ?
                    AuditLog("Removing %s",G_lrpluback);
                    unlink(G_lrpluback);                                    // delete backup 
                    AuditLog("Renaming %s to %s",G_lrplufile,G_lrpluback);
                    rename(G_lrplufile,G_lrpluback);                        // rename
                    AuditLog("Saving %s",G_lrplufile);
                    SaveLocalPLU(G_lrplufile,&(rplulist),TRUE);             // save new
                }
            } else {
                FreeReMACSPLUList(&(rplulist));
                FreePLUList(&(plulist));
            }
            if (TxForToday()) {
                AuditLog("Files Already Queued For Transmition in %s",txpath);
                LoadLocalPLU(G_lrplufile,&(rplulist)); // local PLU
                LoadReMACSPLU(G_rplufile,&(rplulist)); // ReMACS PLU
                if (LoadPLU(G_xmitplufile,&(plulist),rplulist)==1) { // PLU Changed
                    AuditLog("Transmition files updated from %s",G_rplufile);
                    LoadDepartment(G_xmitkeyfile,&(deptlist),keys.number); // Department
                    SavePLU(G_xmitplufile,&(plulist),deptlist,TRUE);                // save new
                    AuditLog("Saving %s",G_xmitplufile);
                    FreeDeptList(&(deptlist));
                    cfg->txnow=TRUE;
                } else {
                    FreeReMACSPLUList(&(rplulist));
                    FreePLUList(&(plulist));
                }
            } else {
                if (changed) {
                    AuditLog("Queueing Files For Transmition");
                    mkdir(txpath);
                    CopyFile(G_xmitplufile,G_plufile   );
                    AuditLog("Copyied file %s to %s",G_plufile   ,G_xmitplufile);
                    CopyFile(G_xmitkeyfile,G_keymapfile);
                    AuditLog("Copyied file %s to %s",G_keymapfile,G_xmitkeyfile);
                    cfg->txnow=TRUE;
                }
            }
        }
        cfg=cfg->next;
    }
    cfg=cfglist;
    while (cfg!=NULL) {
        if (cfg->txnow) {
            sprintf(G_xmitplufile,XMITPLUFILE,"OMR",cfg->ctrl_centre);
            sprintf(path,XMITPATH2 "\\%s",TodaysDate(),G_xmitplufile);
            strcpy(G_xmitplufile,path);

            sprintf(G_xmitkeyfile,XMITKEYFILE,"OMR",cfg->ctrl_centre);
            sprintf(path,XMITPATH2 "\\%s",TodaysDate(),G_xmitkeyfile);
            strcpy(G_xmitkeyfile,path);

            AuditLog("Transmitting Files For Control Centre %s terminal %d",cfg->ctrl_centre,cfg->term_id);
        
            CopyFile(TXPLU ,G_xmitplufile);
            CopyFile(TXDEPT,G_xmitkeyfile);
            unlink(UNLINK1);
            unlink(UNLINK2);
            sprintf(path,"%s",G_xmitbatch);
			system(path);

            cfg->txnow=FALSE;
        }
        cfg=cfg->next;
    }
    if (layout!=NULL) free(layout); // free associated memory
    if (cfglist!=NULL) FreeCFGList(&cfglist);
    CleanDirs();
    AuditLog("End of Day Procedure Complete");
    return 0; // done return OK
}
//__________________________________________________________________________
#pragma warn +par

//=========================================================================
// End of file (OMRPLUED.C)
//=========================================================================


