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
//#include <memory.h>      // For memset() etc...
#include <conio.h>       // For getch() etc...
//#include <dir.h>         // For mkdir()
#include <time.h>
//#include <sys\timeb.h>

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

void LogTime(BOOL start,CHAR *cc,INT tid)
{
    static BOOL donestart=FALSE;
    time_t t;

    t=time(NULL);

    if (start) {
        if (!donestart) {
            printf("-------------------------------------------------------------------------------\n");
            printf("PLU Difference Log Control Centre %s Terminal %d Start %s",cc,tid,ctime(&t));
            donestart=TRUE;
        }
    } else {
        if (donestart) {
            printf("PLU Difference Log Control Centre %s Terminal %d Ended %s",cc,tid,ctime(&t));
            printf("-------------------------------------------------------------------------------\n");
        }
    }
}
INT main(INT argc,char *argv[])
{
    PLU             *oplu,*oplulist =NULL;
    PLU             *plu ,*plulist  =NULL;
    PLU             *foundplu;
    CHAR            ctrl_centre[3];
    INT             term_id;
    CHAR            plufile[MAXSTRLEN]; // e.g. \KEYMAINT\XX\PLU99.OMR
    CHAR            pluback[MAXSTRLEN]; // e.g. \KEYMAINT\XX\PLU99.BAK
    INT             i;

    if ((argc<3)||(strlen(argv[1])>2)) {
        fprintf(stdout,"Invalid arguments!\nUsage:\n       %s CONTROL_CENTRE TERMINAL\npress a key...",argv[0]);
        getch();
        return 1;
    }

    strcpy(ctrl_centre,argv[1]);
    term_id    =atoi(argv[2]);

    sprintf(plufile,PLUFILE,ctrl_centre,term_id,"OMR");
    sprintf(pluback,PLUBACK,ctrl_centre,term_id);

    LoadPLU(plufile,&(plulist),NULL);
    LoadPLU(pluback,&(oplulist),NULL);

    plu=plulist;
    while (plu!=NULL) {
        foundplu=FindPLU(oplulist,plu->plu_code);
        if (foundplu==NULL) {
            LogTime(TRUE,ctrl_centre,term_id);
            printf("Added PLU Code %ld\n",plu->plu_code);
        }
        plu=plu->next;
    }
    oplu=oplulist;
    while (oplu!=NULL) {
        foundplu=FindPLU(plulist,oplu->plu_code);
        if (foundplu==NULL) {
            LogTime(TRUE,ctrl_centre,term_id);
            printf("Deleted PLU Code %ld\n",oplu->plu_code);
        }
        oplu=oplu->next;
    }
    plu=plulist;
    while (plu!=NULL) {
        foundplu=FindPLU(oplulist,plu->plu_code);
        if (foundplu!=NULL) {
            for (i=0;i<6;i++) {
                if (plu->price[i]!=foundplu->price[i]) {
                    LogTime(TRUE,ctrl_centre,term_id);
                    printf("PLU %ld Price Change at Level %d From %3ld.%02ld To %3ld.%02ld\n",
                        plu->plu_code,i+1,foundplu->price[i]/100,foundplu->price[i]%100,
                        plu->price[i]/100,plu->price[i]%100);
                }
            }
        }
        plu=plu->next;
    }
    LogTime(FALSE,ctrl_centre,term_id);
    return 0;
}
//=========================================================================
// End of file (OMRPLUCP.C)
//=========================================================================

