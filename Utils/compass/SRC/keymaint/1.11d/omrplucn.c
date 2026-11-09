//===============|========================================================|
//               |                                                        |
// Module        | OMRPLUCN.C                                              |
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

#define __OMRPLUCN_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <memory.h>      // For memset() etc...
#include <conio.h>       // For getch() etc...
#include <dir.h>         // For mkdir()

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations

//=========================================================================
// Globals Section
//=========================================================================

CHAR G_plu_keypath[MAXSTRLEN]; // e.g. \KEYMAINT\999
CHAR G_rplufile   [MAXSTRLEN]; // e.g. \ISS\POSUPDT\POSom999.FLT
CHAR G_lrplufile  [MAXSTRLEN]; // e.g. \KEYMAINT\999\LOCALPLU.OMR
CHAR G_lrpluback  [MAXSTRLEN]; // e.g. \KEYMAINT\999\LOCALPLU.BAK

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
//F main
//S process updates from ReMACS into PLU KEYMAP and LOCALPLU files
//D process updates from ReMACS into PLU KEYMAP and LOCALPLU files
//P argument count should be 3
//P arguments - control centre, terminal id.
//R errorlevel 1 = invlaid arguments
INT main(INT argc,char *argv[])
{
    REMACSPLU       *rplulist=NULL;   // ReMACS plu list
    CHAR            ctrl_centre[3];   // control centre
    CHAR            cc[MAXSTRLEN];    // control centre EMPTY=ALL
    CHAR *          envstr;           // environment string ptr

    AuditLog("Update Local PLU 'OMRPLUCN' started");
    cc[0]='\0';
    if (argc>1) {
        strcpy(cc,argv[1]);
        AuditLog("Command line argument - Control Centre %s",cc);
    } else {
        envstr=getenv("CC");
        if (envstr!=NULL) {
            strcpy(cc,envstr);
            AuditLog("Environment Variable 'CC' set - Control Centre %s",cc);
        } else {
            AuditLog("No arguments or Environment Variable 'CC' set");
            AuditLog("Update Local PLU 'OMRPLUCN' finished");
            return 1;
        }
    }
    if (strlen(cc)>2) {
        AuditLog("Control Centre %s truncated to 2 positions",cc);
        cc[2]=0;
        AuditLog("Truncated Control Centre %s",cc);
    }

    strcpy(ctrl_centre,cc);

    sprintf(G_plu_keypath,PLU_KEYPATH,ctrl_centre);
    sprintf(G_rplufile   ,RPLUFILE   ,"OMR",ctrl_centre);
    sprintf(G_lrplufile  ,LRPLUFILE  ,ctrl_centre,"OMR");
    sprintf(G_lrpluback  ,LRPLUBACK  ,ctrl_centre);
    
    mkdir(G_plu_keypath); // create dir ( if is doesn't exist)

    LoadLocalPLU(G_lrplufile,&(rplulist)); // local PLU
    LoadReMACSPLU(G_rplufile,&(rplulist)); // ReMACS PLU

    if (rplulist!=NULL) {                                       // need to save localPLU ?
        AuditLog("Removing Localplu backup file");
        unlink(G_lrpluback);                                    // delete backup 
        AuditLog("Renaming Localplu to backup file");
        rename(G_lrplufile,G_lrpluback);                        // rename
        AuditLog("Saving Localplu file");
        SaveLocalPLU(G_lrplufile,&(rplulist),TRUE);             // save new
    }
    AuditLog("Update Local PLU 'OMRPLUCN' finished");

    return 0; // done return OK
}
//=========================================================================
// End of file (OMRPLUCN.C)
//=========================================================================

