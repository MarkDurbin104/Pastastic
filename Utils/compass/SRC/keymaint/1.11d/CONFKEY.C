//===============|========================================================|
//               |                                                        |
// Module        | CONFKEY.C                                               |
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
// 15/05/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//               |                                               |        |
//===============|========================================================|

#define __CONFKEY_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <memory.h>      // For memset() etc...
#include <ctype.h>       // For isdigit() isalpha().

#include <dos.h>         // BORLAND For delay()

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "videokbd.h"    // Video & Keyboard declarations
#include "compkey.h"     // compkey definitions
#include "keydef.h"      // key code definitions
#include "fileio.h"      // file input/output
#include "deballoc.h"    // debug memory allocation routines

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
void DisplayCentre(CONFIG *cfg,INT cc,INT tofs)
{
    INT ofs=0;
    CHAR lastid[3];
    SetViewPort(0,0,80,25,0x0E);
    OutFormat(1,3,0x0B,"ID CONTROL CENTRE  PORT PHONE");
    lastid[0]='\0';
    while (cfg!=NULL) {
        if (strcmp(lastid,cfg->ctrl_centre)) {
            OutFormat(1,4+ofs,(ofs==cc)?0x1E:0x0E,"%2.2s %-15s %-4d %s",
                cfg->ctrl_centre,
                cfg->cc_desc    ,
                cfg->comport    ,
                cfg->phone_num  );
            strcpy(lastid,cfg->ctrl_centre);
            ofs++;
        }
        cfg=cfg->next;
    }
}
//=========================================================================
INT main(void)
{
    CONFIG *cfglist=NULL;
    if ((LoadConfig(CONFIGFILE,&cfglist))==FALSE) {
        printf("Can't Read Configuration file\n");
        return 1;
    }
    DisplayCentre(cfglist,0,0);
    return 0;
}
//_________________________________________________________________________

//=========================================================================
// End of file (CONFKEY.C)
//=========================================================================


