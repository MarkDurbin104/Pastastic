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

CHAR G_layoutfile [MAXSTRLEN]; // e.g. \KEYMAINT\LAYOUT.OMR
CHAR G_keymapfile [MAXSTRLEN]; // e.g. \KEYMAINT\999\KEYMAP99.OMR
CHAR G_plufile    [MAXSTRLEN]; // e.g. \KEYMAINT\999\PLU99.OMR
CHAR G_keymapback [MAXSTRLEN]; // e.g. \KEYMAINT\999\KEYMAP99.BAK
CHAR G_pluback    [MAXSTRLEN]; // e.g. \KEYMAINT\999\PLU99.BAK
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
    KEYMETRICS      keys;             // buffer for keys
    DEPARTMENT      *deptlist=NULL;   // department list
    PLU             *plulist =NULL;   // PLU list
    REMACSPLU       *rplulist=NULL;   // ReMACS plu list
    ULONG           *layout;          // layout array
    CHAR            ctrl_centre[3];   // control centre
    INT             term_id;          // terminal identifier

    if ((argc<3)||(strlen(argv[1])>2)) { // invalid args - return
        fprintf(stdout,"Invalid arguments!\nUsage:\n       %s CONTROL_CENTRE TERMINAL\npress a key...",argv[0]);
        getch();
        return 1;
    }

    strcpy(ctrl_centre,argv[1]); // get args
    term_id    =atoi(argv[2]);

    // set file and path information
    sprintf(G_layoutfile ,LAYOUTFILE ,"OMR"); 
    sprintf(G_keymapfile ,KEYMAPFILE ,ctrl_centre,term_id,"OMR");
    sprintf(G_plufile    ,PLUFILE    ,ctrl_centre,term_id,"OMR");
    sprintf(G_keymapback ,KEYMAPBACK ,ctrl_centre,term_id);      
    sprintf(G_pluback    ,PLUBACK    ,ctrl_centre,term_id);
    sprintf(G_plu_keypath,PLU_KEYPATH,ctrl_centre);
    sprintf(G_rplufile   ,RPLUFILE   ,"OMR",ctrl_centre);
    sprintf(G_lrplufile  ,LRPLUFILE  ,ctrl_centre,"OMR");
    sprintf(G_lrpluback  ,LRPLUBACK  ,ctrl_centre);
    
    mkdir(G_plu_keypath); // create dir ( if is doesn't exist)

    layout=LoadLayout(G_layoutfile,&keys); // load layout (needed for save dept)

    LoadLocalPLU(G_lrplufile,&(rplulist)); // local PLU
    LoadReMACSPLU(G_rplufile,&(rplulist)); // ReMACS PLU
    LoadPLU(G_plufile,&(plulist),rplulist); // PLU
    LoadDepartment(G_keymapfile,&(deptlist),keys.number); // Deaprtment

    unlink(G_pluback);                                          // delete backup 
    rename(G_plufile,G_pluback);                                // rename
    SavePLU(G_plufile,&(plulist),deptlist,TRUE);                // save new
    unlink(G_keymapback);                                       // delete backup 
    rename(G_keymapfile,G_keymapback);                          // rename
    SaveDepartment(G_keymapfile,&(deptlist),keys.number,TRUE);  // save new
    if (rplulist!=NULL) {                                       // need to save localPLU ?
        unlink(G_lrpluback);                                    // delete backup 
        rename(G_lrplufile,G_lrpluback);                        // rename
        SaveLocalPLU(G_lrplufile,&(rplulist),TRUE);             // save new
    }
    if (layout!=NULL) free(layout); // free associated memory

    return 0; // done return OK
}
//=========================================================================
// End of file (OMRPLUCN.C)
//=========================================================================

