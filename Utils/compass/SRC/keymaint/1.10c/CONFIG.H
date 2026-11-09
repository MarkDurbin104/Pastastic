//===============|========================================================|
//               |                                                        |
// Module        | CONFIG.H                                               |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | definitions for use by CONFIG.C                        |
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


#ifndef __CONFIG_H // entry sentry
#define __CONFIG_H

BOOL   StartScreen    (CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id);
CHAR * TerminalType   (CONFIG *cfglist,CHAR *ctrl_centre,INT term_id);

#ifdef __CONFIG_C

INT    ListCFGLines   (INT x,INT y,INT len,INT topline,INT highlight,CONFIG *cfglist);
void   SetCFGLine     (INT linenum,CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id);
BOOL   SelectCFGLine  (CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id);
INT    InputNumber    (INT x,INT y,INT attr,INT *value,INT maxwid);
BOOL   IsControlCentre(CHAR *value,CONFIG *cfglist);
BOOL   IsTerminal     (INT value,CHAR *ctrl_centre,CONFIG *cfglist);

CHAR *G_startstat[]={
    "F1","SEARCH",
    "ESC","EXIT",
    "ENTER","ACCEPT",
    "TAB","NEXT FIELD",
    NULL
};
CHAR *G_startsstat[]={
    "TAB","DOWN",
    "ENTER","SELECT",
    "","UP",
    "","DOWN",
    "PgUp","PAGE UP",
    "PgDn","PAGE DOWN",
    "ESC","CANCEL",
    NULL
};
CHAR *G_startecc[]={
    "ERROR","Invalid Control Centre",
    NULL
};
CHAR *G_startetn[]={
    "ERROR","Invalid Terminal Number for this Control Centre!",
    NULL
};

#endif // __CONFIG_C

#endif // __CONFIG_H
//=========================================================================
// End of file (CONFIG.C)
//=========================================================================

