//===============|========================================================|
//               |                                                        |
// Module        | COMPKEY.H                                              |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | definitions for use by COMPKEY.C                       |
//               |                                                        |
// Functions     | None                                                   |
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
//               |                                               |        |
//===============|========================================================|


#ifndef __COMPKEY_H // entry sentry
#define __COMPKEY_H

void RunHelp    (INT helplevel);
void StatusLine (CHAR **keys,BOOL flash);

#ifdef __COMPKEY_C
#   define PUBLIC extern
#else
#  define PUBLIC extern
#endif // __COMPKEY_C

PUBLIC INT G_colour[NUMBCOLOUR]
#ifdef __COMPKEY_C
={
    0x7F,   // [00] flash attrib - x'ored with grid text colour for flashing key
    0x16,   // [01] grid colour
    0x1E,   // [02] grid text colour
    0x16,   // [03] menu colour
    0x1E,   // [04] menu text colour
    0x16,   // [05] title box colour
    0x0E,   // [06] title plu colour
    0x1E,   // [07] title background colour
    0x0E,   // [08] title description colour
    0x1A,   // [09] title kitchen print words colour
    0x0A,   // [10] title kitchen print Y/N colour
    0x1C,   // [11] status key colour
    0x1E,   // [12] status text colour
    0x1E,   // [13] status background colour
    0x16,   // [14] status box colour
    0x1A,   // [15] flags colour
    0x1E,   // [16] background colour
    0x1E,   // [17] search box colour
    0x1C,   // [18] search text colour
    0x1C,   // [19] search plu colour
    0x1E,   // [20] start screen title colour
    0x1E,   // [21] start screen text colour
    0x0E,   // [22] start screen input colour
    0x1E,   // [23] start screen search list text colour
    0x17,   // [24] start screen search list box colour
    0x11,   // [25] start screen search list cursor colour x'ored with text
    0x1E,   // [26] help border
    0x1E,   // [27] help background
    0x1E,   // [28] help text
    0x00    // [29]  
}
#endif // __COMPKEY_C
;

#ifdef __COMPKEY_C
CHAR *G_stdkeys[]={
    "F2"    ,"INSTRUCTION",
    "F5"    ,"TOGGLE"       ,
    "F9"    ,"HELP"       ,
    "F10"   ,"SAVE",
    "ESC"   ,"CANCEL"     ,
    "TAB"   ,"NEXT" ,
    "ALT-F1"   ,"LEVEL",
    NULL
};
CHAR *G_tinputkeys[]={
    "F1"   ,"SEARCH",
    "F9"   ,"HELP"       ,
    "TAB"  ,"NEXT FIELD" ,
    "ENTER","ACCEPT"     ,
    NULL
};
CHAR *G_tsearch[]={
    "TAB","DOWN",
    "ENTER","SELECT",
    "","UP",
    "","DOWN",
    "PgUp","PAGE UP",
    "PgDn","PAGE DOWN",
    "ESC","CANCEL",
    NULL
};
CHAR *G_exitstat[]={
    "   Exit Without Saving ?   ","   Press Escape to Confirm   ",
    NULL
};
CHAR *G_exitsstat[]={
    "   Save and Exit Y/N ?   ","   Press [Y] to Confirm  ", 
    NULL
};
#else // __COMPKEY_C

extern CHAR *G_exitstat[];

#endif // __COMPKEY_C

#endif // __COMPKEY_H entry sentry
