//===============|========================================================|
//               |                                                        |
// Module        | DEFINES.H                                               |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | File I/O definitions for use by COMPKEY.C              |
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
// 10/05/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|


#ifndef __DEFINES_H // entry sentry
#define __DEFINES_H

#define BOXTOPLEFT  "ÚÉÜ" // character for top left corner of box
#define BOXTOPRIGHT "¿»Ü" // character for top right corner of box
#define BOXBOTLEFT  "ÀÈß" // character for bottom left corner of box
#define BOXBOTRIGHT "Ù¼ß" // character for bottom right corner of box
#define BOXLEFT     "³ºÛ" // character for left (and right) side of box
#define BOXRIGHT    "³ºÛ" // character for left (and right) side of box
#define BOXTOP      "ÄÍÜ" // character for top (and bottom) side of box
#define BOXBOTTOM   "ÄÍß" // character for top (and bottom) side of box
#define BOXLEFTIN   "ÃÌÛ" // character for cut in from left side of box
#define BOXTOPIN    "ÂËÜ" // character for cut in from top side of box
#define BOXRIGHTIN  "´¹Û" // character for cut in from right side of box
#define BOXBOTIN    "ÁÊß" // character for cut in from bottom side of box
#define BOXCROSS    "ÅÎÛ" // character for crossing lines in box

#define SEARCHHELP1     1
#define SEARCHHELP2     2
#define STARTHELP       3
#define MAINHELP        4
#define EDITHELP        5

#define MAXSTRLEN   160   // the maximum length of a string

#define DIRECT_VIDEO_ACCESS

#define LINEVAL(a) ( (INT)(a>>24    ))           // bits 31-24 
#define COLVAL(a)  (((INT)(a>>16    ))&0xFF)     // bits 23-16
#define KEYVAL(a)  ( (INT)(a&0xFFFFL))           // bits 15-00

#define TOPBTYPE 0
#define BOTBTYPE 0
#define MENUBTYPE 0
#define KEYMAPBTYPE 1

#define GRIDTOP      4
#define GRIDLEFT     2
#define GRIDKEYWID   11
#define GRIDKEYHGT   5
#define GRIDNUMKEYX  5
#define GRIDNUMKEYY  4
#define GRIDBOT      (GRIDTOP+(GRIDNUMKEYY*GRIDKEYHGT))
#define GRIDRIGHT    (GRIDLEFT+(GRIDNUMKEYX*GRIDKEYWID))

#define MENUTOP     4
#define MENUBOTTOM  18
#define MENULEFT    56
#define MENURIGHT   78
#define MENULENGTH  (MENUBOTTOM-MENUTOP)

#define MAXFIELDLEN 100

#define NUMBCOLOUR  30

#ifdef DIRECT_VIDEO_ACCESS
#define SCREENBASE  0xB8000000L // the Base address of colour screen memory
#endif

#define CFGPATH     "\\KEYMAINT\\"
#define PLU_KEYPATH CFGPATH "%-2.2s"
#define ISSPATH     "\\ISS\\"
#define ISSPUPATH   "\\ISS\\POSUPDT\\"
#define XMTPATH     CFGPATH "XMT\\"
#define POSUPPATH   ISSPATH "\\ISS\\"
#define CONFIGFILE  CFGPATH "KEYMAINT.CFG"
#define AUDITFILE   CFGPATH "KEYMAINT.AUD"
#define COLOURFILE  CFGPATH "COLOURS.INI"
#define LAYOUTFILE  CFGPATH "LAYOUT.%-3.3s"
#define KEYMAPFILE  PLU_KEYPATH "\\KEYMAP%02d.%-3.3s"
#define PLUFILE     PLU_KEYPATH "\\PLU%02d.%-3.3s"
#define KEYMAPBACK  PLU_KEYPATH "\\KEYMAP%02d.BAK"
#define PLUBACK     PLU_KEYPATH "\\PLU%02d.BAK"
#define RPLUFILE    ISSPUPATH "POS%-3.3s%-2.2s.FLT"
#define LRPLUFILE   PLU_KEYPATH "\\LOCALPLU.%-3.3s"
#define LRPLUBACK   PLU_KEYPATH "\\LOCALPLU.BAK"
#define HELPFILE    CFGPATH "HELPFILE.%-3.3s"


#define PCL             1
#define EPSON           2

#define PRINTXOFS       61
#define PRINTXSTEP      213
#define PRINTXMID       (PRINTXSTEP/2)
#define PRINTCHARWID    (PRINTXSTEP/10)

#define PRINTYOFS       94
#define PRINTYSTEP      171
#define PRINTLINESTEP   40
#ifdef __BORLANDC__
#define MENUXCHAR 'Ï'
#else
#define MENUXCHAR 'X'
#endif

#endif // __DEFINES_H

