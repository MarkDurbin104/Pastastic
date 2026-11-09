//===============|========================================================|
//               |                                                        |
// Module        | CONFIG.C                                               |
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

#define __CONFIG_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <memory.h>      // For memset() etc...
#include <ctype.h>       // For isdigit() isalpha().

#include <conio.h>       // BORLAND For getch() kbhit() cprintf() etc...
#include <dos.h>         // BORLAND For delay()

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "videokbd.h"    // Video & Keyboard declarations
#include "compkey.h"     // key code definitions
#include "keydef.h"      // key code definitions
#include "config.h"      // key code definitions

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



INT ListCFGLines(INT x,INT y,INT len,INT topline,INT highlight,CONFIG *cfglist)
{
    INT retval=0;
    INT starty=y;
    while (cfglist!=NULL) {
        if ((retval>=topline)&&(retval<=topline+len)) {
            OutFormat(x,y,G_colour[23],"Control Centre %2.2s %-15.15s     Terminal %02d %-15.15s         %-3.3s",
                cfglist->ctrl_centre,
                cfglist->cc_desc    ,
                cfglist->term_id    ,
                cfglist->term_desc  ,
                cfglist->term_type  );
            if (highlight==retval) {
                DrawCBar(x,y,78,G_colour[25]);
            }
            y++;
        }
        retval++;
        cfglist=cfglist->next;
    }
    while (y<=starty+len) OutFormat(x,y++,G_colour[23],"%78.78s","");
    return retval;
}
void SetCFGLine(INT linenum,CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id)
{
    INT curline=0;
    while (cfglist!=NULL) {
        if (linenum==curline) {
            strcpy(ctrl_centre,cfglist->ctrl_centre);
            *term_id     =cfglist->term_id;
            return;
        }
        curline++;
        cfglist=cfglist->next;
    }
}
BOOL SelectCFGLine(CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id)
{
    static UINT scrbuffer[25*80];
    BOOL xit=FALSE;
    INT key;
    INT topline=0;
    INT curline=0;
    INT numlines;
    memcpy(scrbuffer,((UINT far *)SCREENBASE),25*80*2);
    Rectangle(0,0,79,21,G_colour[24],0);
    StatusLine(G_startsstat,FALSE);
    while (!xit) {
        numlines=ListCFGLines(1,1,19,topline,curline,cfglist);
        key=GetKey();
        switch (key) {
            case F09 :
                RunHelp(SEARCHHELP2);
                break;
            case STAB :
            case UP :
                if (curline>topline) {
                    curline--;
                } else {
                    if (topline>0) {
                        topline--;
                        curline--;
                    }
                }
                break;
            case PGUP :
                if (topline>19) {
                    topline-=19;
                    curline-=19;
                } else {
                    topline=0;
                    curline=0;
                }
                break;
            case TAB :
            case DOWN :
                if (curline<numlines-1) {
                    if (curline>=topline+19) {
                        topline++;
                    }
                    curline++;
                }
                break;
            case PGDN :
                if (topline<numlines-20) {
                    topline+=19;
                    curline+=19;
                } else {
                    topline=numlines-20;
                    curline=numlines-1;
                }
                break;
            case ENTER :
                SetCFGLine(curline,cfglist,ctrl_centre,term_id);
                xit=TRUE;
                break;
            case ESC :
                memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
                return FALSE;
            default :
                Beep();
        }
    }
    memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
    return TRUE;
}
INT InputNumber(INT x,INT y,INT attr,INT *value,INT maxwid)
{
    static CHAR buffer[MAXSTRLEN];
    INT cursor;
    INT key;
    BOOL xit=FALSE;

    if (*value!=0) {
        sprintf(buffer,"%d",*value);
    } else {
        buffer[0]='\0';
    }

    cursor=strlen(buffer);
    while (!xit) {
        OutFormat(x,y,attr,"%-*.*s",maxwid,maxwid,buffer);
        LargeCursor();
        PlaceCursor(x+cursor+1,y+1);
//        gotoxy(x+cursor+1,y+1);
        key=GetKey();
        HideCursor();
        switch (key) {
            case F09 :
                RunHelp(STARTHELP);
                break;
            case BKSP :
                if (cursor>0) cursor--;
                buffer[cursor]='\0';
                break;
            default :
                if ((key<32)||(key>127)) {
                    xit=TRUE;
                } else {
                    if ((cursor<maxwid)&&(isdigit(key))) {
                        buffer[cursor++]=(CHAR)key;
                        buffer[cursor]='\0';
                    } else {
                        Beep();
                    }

                }
        }
    }
    *value=atoi(buffer);
    return key;
}
INT InputAlNum(INT x,INT y,INT attr,CHAR *value,INT maxwid)
{
    static CHAR buffer[MAXSTRLEN];
    INT cursor;
    INT key;
    BOOL xit=FALSE;

    strcpy(buffer,value);

    cursor=strlen(buffer);
    while (!xit) {
        OutFormat(x,y,attr,"%-*.*s",maxwid,maxwid,buffer);
        LargeCursor();
        PlaceCursor(x+cursor+1,y+1);
//        gotoxy(x+cursor+1,y+1);
        key=GetKey();
        HideCursor();
        switch (key) {
            case F09 :
                RunHelp(STARTHELP);
                break;
            case BKSP :
                if (cursor>0) cursor--;
                buffer[cursor]='\0';
                break;
            default :
                if ((key<32)||(key>127)) {
                    xit=TRUE;
                } else {
                    if ((cursor<maxwid)&&(isalnum(key))) {
                        buffer[cursor++]=(CHAR)toupper(key);
                        buffer[cursor]='\0';
                    } else {
                        Beep();
                    }

                }
        }
    }
    strcpy(value,buffer);
    return key;
}
//__________________________________________________________________________

BOOL IsControlCentre(CHAR *value,CONFIG *cfglist)
{
    while (cfglist!=NULL) {
        if (!strcmp(cfglist->ctrl_centre,value))
            return TRUE;
        cfglist=cfglist->next;
    }
    return FALSE;
}
BOOL IsTerminal(INT value,CHAR *ctrl_centre,CONFIG *cfglist)
{
    while (cfglist!=NULL) {
        if ((!strcmp(cfglist->ctrl_centre,ctrl_centre))
        &&  (cfglist->term_id==value))
            return TRUE;
        cfglist=cfglist->next;
    }
    return FALSE;
}
CHAR *TerminalType(CONFIG *cfglist,CHAR *ctrl_centre,INT term_id)
{
    while (cfglist!=NULL) {
        if ((!strcmp(cfglist->ctrl_centre,ctrl_centre))
        &&  (cfglist->term_id==term_id))
            return cfglist->term_type;
        cfglist=cfglist->next;
    }
    return "OMR";
}
//==========================================================================
//F StartScreen
//S Present and Run the terminal selection screen
//D Present and Run the terminal selection screen
//P The configuration linked list
//P The selected control centre
//P The selected terminal id
//P The selected terminal type
//R TRUE if valid control center and terminal id selected, otherwise FALSE
BOOL StartScreen(CONFIG *cfglist,CHAR *ctrl_centre,INT *term_id)
{
    INT xit=FALSE;
    INT outer=FALSE;
    INT key;
    INT value1;
    CHAR svalue[3];

    SetViewPort(0,0,80,25,G_colour[16]);
    StatusLine(G_startstat,FALSE);
    OutFormat(28, 2,G_colour[20],"Compass Till Maintenance");
    OutFormat(28,10,G_colour[21],"Enter Control Centre [  ]");
    OutFormat(50,10,G_colour[22],"  ");
    OutFormat(28,11,G_colour[21],"Enter Till Number    [  ]");
    OutFormat(50,11,G_colour[22],"  ");
    value1=0;
    svalue[0]='\0';
    while (!outer) {
        xit=FALSE;
        while (!xit) {
            key=InputAlNum(50,10,G_colour[22],svalue,2);
            switch (key) {
                case F01 :
                    if (SelectCFGLine(cfglist,ctrl_centre,term_id)) {
                        OutFormat(50,10,G_colour[22],"%2.2s",ctrl_centre);
                        OutFormat(50,11,G_colour[22],"%02d",*term_id);
                        return TRUE;
                    }
                    break;
                case STAB :
                case TAB :
                case ENTER :
                    if (IsControlCentre(svalue,cfglist)) {
                        strcpy(ctrl_centre,svalue);
                        xit=TRUE;
                    } else {
                        StatusLine(G_startecc,FALSE);
                        Beep();
                    }
                    break;
                case ESC :
                    StatusLine(G_exitstat,1);
                    if (GetKey()==ESC) {
                        return FALSE;
                    } else {
                        StatusLine(G_startstat,FALSE);
                    }
                    break;
                default:
                    Beep();
            }
        }
        xit=FALSE;
        while (!xit) {
            key=InputNumber(50,11,G_colour[22],&value1,2);
            switch (key) {
                case F01 :
                    if (SelectCFGLine(cfglist,ctrl_centre,term_id)) {
                        OutFormat(50,10,G_colour[22],"%2.2s",ctrl_centre);
                        OutFormat(50,11,G_colour[22],"%02d",*term_id);
                        return TRUE;
                    }
                    break;
                case ENTER :
                    if (IsTerminal(value1,ctrl_centre,cfglist)) {
                        *term_id=value1;
                        xit=TRUE;
                        outer=TRUE;
                    } else {
                        StatusLine(G_startetn,FALSE);
                        Beep();
                    }
                    break;
                case ESC :
                    StatusLine(G_exitstat,TRUE);
                    if (GetKey()==ESC) {
                        return FALSE;
                    } else {
                        StatusLine(G_startstat,FALSE);
                    }
                    break;
                case STAB :
                case TAB :
                    xit=TRUE;
                    break;
                default:
                    Beep();
            }
        }
    }
    return TRUE;
}
//=========================================================================
// End of file (CONFIG.C)
//=========================================================================

