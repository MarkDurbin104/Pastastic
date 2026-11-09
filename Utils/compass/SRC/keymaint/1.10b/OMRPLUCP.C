//===============|========================================================|
//               |                                                        |
// Module        | OMRPLUCP.C                                              |
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
// 10/06/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|

#define __OMRPLUCP_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <conio.h>       // For getch() etc...
#include <time.h>

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations

//=========================================================================
// Globals Section
//=========================================================================

//=========================================================================
// Define Section
//=========================================================================

//=========================================================================
// Declarations Section
//=========================================================================

//=========================================================================
// Definitions Section
//=========================================================================

//=========================================================================
//F LogTime
//S Print Time Stamp For Log
//D Print Time Stamp For Log
//P TRUE if start  of log FALSE if end
//P The Control Centre
//P The Terminal Identifier
void LogTime(BOOL start,CHAR *cc,INT tid)
{
    static BOOL donestart=FALSE;    // entry flag
    time_t t;                       // for time stamp

    t=time(NULL);                   // get time

    if (start) {                    // start of log
        if (!donestart) {
            printf("-------------------------------------------------------------------------------\n");
            printf("PLU Difference Log Control Centre %s Terminal %d Start %s",cc,tid,ctime(&t));
            donestart=TRUE;
        }
    } else {                        // End of log
        if (donestart) {
            printf("PLU Difference Log Control Centre %s Terminal %d Ended %s",cc,tid,ctime(&t));
            printf("-------------------------------------------------------------------------------\n");
        }
    }
}
//=========================================================================
//F main
//S generate a difference log to stdout between the PLU file and backup
//D generate a difference log to stdout between the PLU file and backup
//P argument count - should be 3
//P arguments Control Centre, Terminal Identifier
//R Errorlevel = 1 - Invalid Arguments
INT main(INT argc,char *argv[])
{
    PLU  *oplu;              // current backup plu
    PLU  *oplulist =NULL;    // backup plu list
    PLU  *plu;               // current plu
    PLU  *plulist  =NULL;    // plu list
    PLU  *foundplu;          // returned plu from find function
    CHAR ctrl_centre[3];     // Control Centre
    INT  term_id;            // Terminal Identifier
    CHAR plufile[MAXSTRLEN]; // e.g. \KEYMAINT\XX\PLU99.OMR
    CHAR pluback[MAXSTRLEN]; // e.g. \KEYMAINT\XX\PLU99.BAK
    INT  pindex;             // price level index counter

    if ((argc<3)||(strlen(argv[1])>2)) { 
        fprintf(stdout,"Invalid arguments!\nUsage:\n       %s CONTROL_CENTRE TERMINAL\npress a key...",argv[0]);
        getch();
        return 1;
    }

    strcpy(ctrl_centre,argv[1]); // save control centre & terminal identifier
    term_id    =atoi(argv[2]);

    // set paths
    sprintf(plufile,PLUFILE,ctrl_centre,term_id,"OMR");
    sprintf(pluback,PLUBACK,ctrl_centre,term_id);

    LoadPLU(plufile,&(plulist),NULL);  // load current plu file
    LoadPLU(pluback,&(oplulist),NULL); // load backup plu file

    plu=plulist;        // start of list
    while (plu!=NULL) { // for each item
        foundplu=FindPLU(oplulist,plu->plu_code); // find in backup
        if (foundplu==NULL) {  // not found - Added
            LogTime(TRUE,ctrl_centre,term_id); // output log Entry
            printf("Added PLU Code %ld\n",plu->plu_code);
        }
        plu=plu->next; // next item
    }
    oplu=oplulist;      // start of backup list
    while (oplu!=NULL) { // for each item
        foundplu=FindPLU(plulist,oplu->plu_code); // find in current list
        if (foundplu==NULL) {  // not found - Deleted
            LogTime(TRUE,ctrl_centre,term_id); // output log Entry
            printf("Deleted PLU Code %ld\n",oplu->plu_code); 
        }
        oplu=oplu->next;
    }
    plu=plulist;       // next item
    while (plu!=NULL) { // for each item 
        foundplu=FindPLU(oplulist,plu->plu_code);
        if (foundplu!=NULL) { // if found check price changes
            for (pindex=0;pindex<6;pindex++) {
                if (plu->price[pindex]!=foundplu->price[pindex]) {
                    LogTime(TRUE,ctrl_centre,term_id); // output log Entry
                    printf("PLU %ld Price Change at Level %d From %3ld.%02ld To %3ld.%02ld\n",
                        plu->plu_code,pindex+1,foundplu->price[pindex]/100,foundplu->price[pindex]%100,
                        plu->price[pindex]/100,plu->price[pindex]%100);
                }
            }
        }
        plu=plu->next; // next item
    }
    LogTime(FALSE,ctrl_centre,term_id); // output log Footer
    return 0; // return OK
}
//=========================================================================
// End of file (OMRPLUCP.C)
//=========================================================================

