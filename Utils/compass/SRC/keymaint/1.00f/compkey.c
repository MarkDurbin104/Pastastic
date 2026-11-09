//===============|========================================================|
//               |                                                        |
// Module        | COMPKEY.C                                              |
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
// 23/04/96      | Initial Version DEMO Screen Layout            | MJD    |
//===============|========================================================|
// 03/05/96      | Initial Version Added File read and keyboard  | MJD    |
//               | Functions for moving around                   |        |
//               | Added font overload and layout in file        |        |
//               | for other terminal types                      |        |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|

#define __COMPKEY_C


//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <stdarg.h>      // For va_arg va_start() va_end() etc...
#include <memory.h>      // For memset() etc...
#include <ctype.h>       // For isdigit() isalpha().
#include <time.h>        // For time() & time_t

#include <dos.h>         // BORLAND For delay()
#include <direct.h>      // BORLAND For mkdir()
#include <conio.h>       // BORLAND For getch() kbhit() cprintf() etc...

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations
#include "videokbd.h"    // Video & Keyboard declarations
#include "keydef.h"      // key code definitions
#include "config.h"      // key code definitions
#include "compkey.h"      // key code definitions



//=========================================================================
// Globals Section
//=========================================================================

CHAR G_helpfile   [MAXSTRLEN]; // e.g. \KEYMAINT\HELPFILE.OMR
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
void AuditLog(CHAR *format,...)
{
    static CHAR outstr[MAXSTRLEN];                 // output string buffer
    static BOOL donestart=FALSE;
	va_list ap;                                    // variable arg. list ptr.
    time_t t;
    FILE *fp;

    fp=fopen(AUDITFILE,"a+");
    if (fp==NULL) {
        fprintf(stderr,"Can't Open Audit Trail!\n");
        return;
    }

    va_start(ap,format);                           // start variable arg. list
    vsprintf(outstr,format,ap);                    // convert args to string
    va_end(ap);                                    // end variable arg. list

    t=time(NULL);

    if (!donestart) {
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        fprintf(fp,"Audit Log Start %s",ctime(&t));
        fprintf(fp,"-------------------------------------------------------------------------------\n");
        donestart=TRUE;
    }
    fprintf(fp,"%s %s",outstr,ctime(&t));
    fclose(fp);
}
void RunHelp(INT helplevel)
{
    static UINT scrbuffer[25*80];
    static LINELINK *firstline=NULL;
    static LINELINK *lines=NULL;
    static LINELINK *curline;
    CHAR line[MAXSTRLEN];
    INT linenum=0;
//    BOOL xit=FALSE;
//    INT key;
//    INT topline=0;
//    INT numlines;
    FILE *fp;

    if (lines==NULL) {
        if ((fp=fopen(G_helpfile,"r"))!=NULL) {
            while (fgets(line,MAXSTRLEN,fp)!=NULL) {
                if ((curline=malloc(sizeof(LINELINK)))!=NULL) {
                    curline->line=strdup(CleanBuf(line));
                    curline->next=NULL;
                    if (lines==NULL) {
                        lines=curline;
                        firstline=lines;
                    } else {
                        lines->next=curline;
                        lines=curline;
                    }
                }
            }
        }
        fclose(fp);
        lines=firstline;
    }
    memcpy(scrbuffer,((UINT far *)SCREENBASE),25*80*2);

//    StatusLine(G_tsearch,0);

    SetViewPort(0,0,79,21,G_colour[27]);
    Rectangle(0,0,79,21,G_colour[26],0);
    if (lines==NULL) {
        OutFormat(1,1,G_colour[28],"No Help Available For Help Level %d",helplevel);
    } else {
        curline=lines;
        while ((curline!=NULL) && (linenum<19)) {
            if (curline->line[0]=='0'+helplevel) {
                OutFormat(1,1+(linenum++),G_colour[28],"%s",&(curline->line[2]));
            }
            curline=curline->next;
        }
    }
    getch();
    SetViewPort(0,0,80,25,0);
    memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
}

INT ListPLULines(INT x,INT y,INT len,INT topline,INT highlight,SORTRPLU *plulist,LONG *curplu)
{
    INT retval=0;
    INT starty=y;
    while (plulist!=NULL) {
        if ((retval>=topline)&&(retval<=topline+len)) {
            OutFormat(x   ,y,G_colour[6],"%06ld "   ,plulist->elem->plu_code);
            OutFormat(x+7 ,y,G_colour[8],"%-25.25s ",plulist->elem->desc);
            OutFormat(x+33,y,G_colour[7],
                "    %3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld",
                plulist->elem->price[0]/100L,plulist->elem->price[0]%100L,
                plulist->elem->price[1]/100L,plulist->elem->price[1]%100L,
                plulist->elem->price[2]/100L,plulist->elem->price[2]%100L,
                plulist->elem->price[3]/100L,plulist->elem->price[3]%100L,
                plulist->elem->price[4]/100L,plulist->elem->price[4]%100L,
                plulist->elem->price[5]/100L,plulist->elem->price[5]%100L);
            if (highlight==retval) {
                DrawCBar(x,y,78,G_colour[25]);
                *curplu=plulist->elem->plu_code;
            }
            y++;
        }
        retval++;
        plulist=plulist->next;
    }
    while (y<=starty+len) OutFormat(x,y++,G_colour[7],"%78.78s","");
    return retval;
}

SORTRPLU *SortList(REMACSPLU *plulist,BOOL by_code)
{
    SORTRPLU *firstelem=NULL;
    SORTRPLU *traverse;
    SORTRPLU *lastelem;
    SORTRPLU *curelem;
    BOOL additem;

    while (plulist!=NULL) {
        if ((curelem=malloc(sizeof(SORTRPLU)))==NULL) return NULL;
        curelem->elem=plulist;
        if (firstelem==NULL) {
            firstelem=curelem;
            firstelem->next=NULL;
        } else {
            traverse=firstelem;
            lastelem=NULL;
            while (traverse!=NULL) {
                if (by_code) {
                    additem=(curelem->elem->plu_code<traverse->elem->plu_code);
                } else {
                    additem=(strcmp(curelem->elem->desc,traverse->elem->desc)<=0);
                }
                if (additem) {
                    if (lastelem==NULL) {
                        curelem->next=traverse;
                        firstelem=curelem;
                    } else {
                        curelem->next=traverse;
                        lastelem->next=curelem;
                    }
                    break;
                } else {
                    if (traverse->next==NULL) {
                        curelem->next=NULL;
                        traverse->next=curelem;
                        break;
                    }
                }
                lastelem=traverse;
                traverse=traverse->next;
            }
        }
        plulist=plulist->next;
    }
    return firstelem;
}
//==========================================================================
//F RunSearch
//S Run the Search Function
//D Run the Search Function
//R PLU selected or 0 for none
void RunSearch(MAINDS *ds,LONG *selected_plu)
{
    static UINT scrbuffer[25*80];
    static SORTRPLU *code_list=NULL; 
    static SORTRPLU *desc_list=NULL;
    SORTRPLU *curlist;
    BOOL xit=FALSE;
    INT key;
    INT topline=0;
    INT curline=0;
    INT numlines;
    LONG curplu;

    memcpy(scrbuffer,((UINT far *)SCREENBASE),25*80*2);

    StatusLine(G_tsearch,0);

    SetViewPort(0,0,79,21,G_colour[18]);
    Rectangle(0,0,79,21,G_colour[17],0);

    if (code_list==NULL) code_list=SortList(ds->rplulist,TRUE);
    if (desc_list==NULL) desc_list=SortList(ds->rplulist,FALSE);

    curlist=code_list;
    if (curlist==NULL) return;

    while (!xit) {
        numlines=ListPLULines(1,1,19,topline,curline,curlist,&curplu);
        key=GetKey();
        switch (key) {
            case F09 :
                RunHelp(SEARCHHELP1);
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
                *selected_plu=curplu;
                xit=TRUE;
                break;
            case ESC :
                xit=TRUE;
                break;
            default :
                if ((key>31)&&(key<126)) {
                    curlist=desc_list;
                    topline=0;
                    while (curlist!=NULL) {
                        if (toupper(curlist->elem->desc[0])==toupper(key)) {
                            break;
                        }
                        topline++;
                        curlist=curlist->next;
                    }
                    if (curlist==NULL) {
                        topline=0;
                        Beep();
                    }
                    curlist=desc_list;
                    curline=topline;
                } else {
                    Beep();
                }
        }
    }
    SetViewPort(0,0,80,25,0);
    memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
}
//__________________________________________________________________________
BOOL isvalid(INT *key,CHAR type)
{
    if ((*key<32)||(*key>126)) return FALSE;
    switch (type) {
        case 'D' :
            if (isdigit(*key)||(*key=='/')) return TRUE;
            break;
        case '.' :
            if (isalnum(*key)||(*key=='\\')||(*key=='.')) return TRUE;
            break;
        case 'X' :
            if (isalnum(*key)||(*key==' ')) return TRUE;
            break;
        case '9' :
            if (isdigit(*key)) return TRUE;
            break;
        case 'Y' :
            if ((toupper(*key)=='Y')||(toupper(*key)=='N')) {
                *key=toupper(*key);
                return TRUE;
            }
            break;
    }
    return FALSE;
}
//==========================================================================
//F InputLine
//S Input a character string
//D Input a character string
//P Zero based X co-ordinate (origin Top left)
//P Zero based Y co-ordinate (origin Top left)
//P The attribute
//P The string to start with
//P The maximum width of the input string
//P The current keyboard cursor x co-ordinate (the flashing cursor)
//P The current keyboard cursor y co-ordinate 
//P The current keyboard cursor width 
//P The current keyboard cursor height 
//P The last key pressed (the key that caused exit)
//P input format type 'X' alphanum '9' numeric 'Y' yes/no
//R The input string
CHAR *InputLine(MAINDS *ds,INT x,INT y,INT attr,CHAR *str,INT maxwid,INT cx,INT cy,INT *lastkey,CHAR type)
{
    static CHAR buffer[MAXSTRLEN];
    INT cursor;
    INT key;
    BOOL xit=FALSE;

    if (str==NULL)
        buffer[0]='\0';
    else
        strcpy(buffer,str);

    cursor=strlen(buffer);
    while (!xit) {
        OutFormat(x,y,attr,"%-*.*s",maxwid,maxwid,buffer);
        LargeCursor();
        PlaceCursor(x+cursor+1,y+1);
//        gotoxy(x+cursor+1,y+1);
        if (cx>=0) {
            KeyCursor(GRIDLEFT+1+cx*ds->keys.width,GRIDTOP+1+cy*ds->keys.height,
                  ds->keys.width-1,ds->keys.height-1,G_colour[0]);
        }
        key=GetKey();
        HideCursor();
        switch (key) {
            case BKSP :
                if (cursor>0) cursor--;
                buffer[cursor]='\0';
                break;
            case ESC :
                if (str==NULL)
                    buffer[0]='\0';
                else
                    strcpy(buffer,str);
                cursor=strlen(buffer);
                xit=1;
                break;
            case STAB :
            case TAB :
            case ENTER :
            case F01 :
            case F02 :
            case PGDN:
            case PGUP:
            case INS :
            case DEL :
                xit=TRUE;
                break;
            case F09 :
                RunHelp(EDITHELP);
                break;
            default :
                if ((cursor<maxwid)&&(isvalid(&key,type))) {
                    buffer[cursor++]=(CHAR)key;
                    buffer[cursor]='\0';
                } else {
                    Beep();
                }
        }
    }
    *lastkey=key;
    return buffer;
}
//__________________________________________________________________________

//==========================================================================
//F TitleBar
//S Output the Title bar
//D Output the Title bar
//P The product code i.e. PLU
//P The product description
//P The 12 character product description for the key top
//P Value (price level) 1
//P Value (price level) 2
//P Value (price level) 3
//P Value (price level) 4
//P Value (price level) 5
//P Value (price level) 6
//P TRUE kitchen print == 'Y', FALSE kitchen print == 'N'
//P TRUE key is a MENU key, FALSE key is a Single Shot key
void TitleBar(LONG prodcode,CHAR *desc,CHAR *desc12,LONG v1,LONG v2,LONG v3,LONG v4,LONG v5,LONG v6,BOOL kp,BOOL state)
{
    Rectangle(0,0,79,3,G_colour[5],TOPBTYPE);
    if ((state&1)==1) {
        OutFormat(1,1,G_colour[6],"*MENU* ");
    } else {
        if (prodcode==0) {
            OutFormat(1,1,G_colour[7],"%*.*s",78,78,"");
            OutFormat(1,2,G_colour[7],"%*.*s",78,78,"");
            return;
        }
        OutFormat(1,1,G_colour[6],"%06ld ",prodcode);
    }
    OutFormat(9,1,G_colour[7],"%-24.24s",desc);
    if ((state&1)==1) {
        OutFormat(38,1,G_colour[7],"%*.*s",41,41,"");
    } else {
        OutFormat(38,1,G_colour[7],
          "%3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld %3ld.%02ld",
          v1/100L,v1%100L,v2/100L,v2%100L,v3/100L,v3%100L,
          v4/100L,v4%100L,v5/100L,v5%100L,v6/100L,v6%100L);
    }
    if (desc12==NULL) {
        OutFormat(9,2,G_colour[8],"%-12.12s ",desc);
    } else {
        OutFormat(9,2,G_colour[8],"%-12.12s ",desc12);
    }
    if ((state&2)==2) {
        OutFormat(63,2,G_colour[9],"Kitchen Print");
        OutFormat(77,2,G_colour[10] ,"%c ",((kp)?'Y':'N'));
    } else {
        OutFormat(63,2,G_colour[9],"%*.*s",16,16,"");
    }
}
//__________________________________________________________________________

//==========================================================================
//F StatusLine
//S Output a series of status items in the status box
//D Output a series of status items in the status box
//P A series of string pairs the first is the key the second the action
//P TRUE if the status bar should FLASH
void StatusLine(CHAR **keys,BOOL flash)
{
    CHAR **curkey;
    INT oddeve=0;
    INT dwid=0;
    INT fullwid=-1;
    INT curofs;

    OutFormat(1,23,G_colour[13],"%*.*s",78,78,"");
    curkey=keys;
    while (*curkey!=NULL) {
        if (oddeve) {
            fullwid+=dwid+strlen(*curkey)+1;
        } else {
            dwid=strlen(*curkey)+1;
        }
        oddeve^=1;
        curkey++;
    }                           
    curkey=keys;                
    oddeve=0;                   
    curofs=(78-fullwid)/2;      
    while (*curkey!=NULL) {
        if (oddeve) {
            if (flash)
                OutFormat(curofs+dwid,23,G_colour[12]|0x80,*curkey);
            else 
                OutFormat(curofs+dwid,23,G_colour[12],*curkey);
            curofs+=dwid+strlen(*curkey)+1;
        } else {
            dwid=strlen(*curkey)+1;
            if (flash)
                OutFormat(curofs,23,G_colour[11]|0x80,"%s ",*curkey);
            else 
                OutFormat(curofs,23,G_colour[11],"%s ",*curkey);
        }
        oddeve^=1;
        curkey++;
    }
    Rectangle(0,22,79,24,G_colour[14],BOTBTYPE);
}
//__________________________________________________________________________

//==========================================================================
//F KeyInd
//S Output the key movement indicator
//D Output the key movement indicator i.e. show the key number, level and 
//D available movement keys
//P Zero based X co-ordinate (origin Top left)
//P Zero based Y co-ordinate (origin Top left)
//P The key number (department)
//P Bit flags of available movement keys, bit 4-left 3-right 2-up 1-down 
//P The current keyboard level (0-2)
void KeyInd(INT x,INT y,INT key,INT bounds,INT level)
{
    if ((bounds&8)!=0)                       
        OutChar(x  ,y+1,G_colour[15],27);      
    else                                     
        OutChar(x  ,y+1,G_colour[15],' ');     
    if ((bounds&4)!=0)                       
        OutChar(x+4,y+1,G_colour[15],26);
    else
        OutChar(x+4,y+1,G_colour[15],' ');
    if ((bounds&2)!=0)
        OutChar(x+2,y+0,G_colour[15],24);
    else
        OutChar(x+2,y+0,G_colour[15],' ');
    if ((bounds&1)!=0)  
        OutChar(x+2,y+2,G_colour[15],25);
    else
        OutChar(x+2,y+2,G_colour[15],' ');

    OutFormat(x+1,y+1,G_colour[15],"%03d",key);
    OutFormat(x+8,y+1,G_colour[15],"Keyboard Level %d",level+1);
}
//__________________________________________________________________________

//==========================================================================
//F SetCurXY
//S Set the cursor X and Y co-ordinates from the key number
//D Set the cursor X and Y co-ordinates from the key number
//P The List of keyboard layout information
//P The number of keys on the keyboard
//P The address of the integer to set to the X co-ordinate
//P The address of the integer to set to the Y co-ordinate
void SetCurXY(ULONG *layout,INT numkeys,INT keypos,INT *cx,INT *cy)
{
    INT kindex;
    for (kindex=0;kindex<numkeys;kindex++) {
        if ((KEYVAL(layout[kindex])==keypos)) {
            *cy=LINEVAL(layout[kindex]);
            *cx=COLVAL (layout[kindex]);
            return;
        }
    }
    return;
}
//__________________________________________________________________________

//==========================================================================
//F KeyAtPos
//S Return TRUE if there is a key at a given X/Y co-ordinate
//D Return TRUE if there is a key at a given X/Y co-ordinate
//P The List of keyboard layout information
//P The number of keys on the keyboard
//P The X co-ordinate of the key
//P The Y co-ordinate of the key
//R TRUE there is a key, FALSE there isn't
INT KeyAtPos(ULONG *layout,INT numkeys,INT x,INT y)
{
    INT kindex;
    for (kindex=0;kindex<numkeys;kindex++) {
        if ((LINEVAL(layout[kindex])==y)&&(COLVAL(layout[kindex])==x)) {
            return KEYVAL(layout[kindex]);
        }
    }
    return 0;
}
//__________________________________________________________________________

BOOL HasAssoc(INT dept,PLU *plulist)
{
    while (plulist!=NULL) {
        if (plulist->assoc_dept==dept)
            return TRUE;
        plulist=plulist->next;
    }
//    return FALSE;
    return TRUE;
}
BOOL ismenu(DEPARTMENT *dept)
{
    if (dept==NULL) return(FALSE);

    return (strcmp(dept->status.as_string,"01550050")==0);
}
//==========================================================================
//F DrawKey
//S Draw one key with it's text
//D Draw one key with it's text
//P The List of keyboard layout information
//P The number of keys on the keyboard
//P The key index
//P The start X co-ordinate of the key
//P The start Y co-ordinate of the key
//P The keyboard overlay information
//P The current keyboard level
//P TRUE if the title bar should be draw as well (i.e. the current key)
//P The width in characters of the key
//P The height in characters of the key
//R The available movement key flags (see KeyInd()) if the title is drawn
INT DrawKey(MAINDS *ds,INT kindex,INT startx,INT starty,INT level,BOOL drawt)
{
    INT xofs;
    INT yofs;
    INT bxofs;
    INT byofs;
    INT kl;
    INT kr;
    INT kt;
    INT kb;
    INT lastline;
    DEPARTMENT *dept;
    PLU *plu;
    REMACSPLU *rplu;

    xofs=COLVAL (ds->layout[kindex]);
    yofs=LINEVAL(ds->layout[kindex]);

    kl=KeyAtPos(ds->layout,ds->keys.number,xofs-1,yofs);
    kr=KeyAtPos(ds->layout,ds->keys.number,xofs+1,yofs);
    kt=KeyAtPos(ds->layout,ds->keys.number,xofs,yofs-1);
    kb=KeyAtPos(ds->layout,ds->keys.number,xofs,yofs+1);

    xofs-=startx;
    yofs-=starty;
        
    bxofs=GRIDLEFT+xofs*ds->keys.width;
    byofs=GRIDTOP +yofs*ds->keys.height;
    Rectangle(bxofs,byofs,bxofs+ds->keys.width,byofs+ds->keys.height,
        G_colour[1],KEYMAPBTYPE);
              

    if (kl) {
        if (kt) {
            OutChar(bxofs,byofs,G_colour[1],*(BOXCROSS+KEYMAPBTYPE));
        } else {
            OutChar(bxofs,byofs,G_colour[1],*(BOXTOPIN+KEYMAPBTYPE));
        }
        if (kb) {
            OutChar(bxofs,byofs+ds->keys.height,G_colour[1],*(BOXCROSS+KEYMAPBTYPE));
        } else {
            OutChar(bxofs,byofs+ds->keys.height,G_colour[1],*(BOXBOTIN+KEYMAPBTYPE));
        }
    } else {
        if (kt) {
            OutChar(bxofs,byofs,G_colour[1],*(BOXLEFTIN+KEYMAPBTYPE));
        }
        if (kb) {
            OutChar(bxofs,byofs+ds->keys.height,G_colour[1],*(BOXLEFTIN+KEYMAPBTYPE));
        }
    }
    if (kr) {
        if (kt) {
            OutChar(bxofs+ds->keys.width,byofs,G_colour[1],*(BOXCROSS+KEYMAPBTYPE));
        } else {
            OutChar(bxofs+ds->keys.width,byofs,G_colour[1],*(BOXTOPIN+KEYMAPBTYPE));
        }
        if (kb) {
            OutChar(bxofs+ds->keys.width,byofs+ds->keys.height,G_colour[1],*(BOXCROSS+KEYMAPBTYPE));
        } else {
            OutChar(bxofs+ds->keys.width,byofs+ds->keys.height,G_colour[1],*(BOXBOTIN+KEYMAPBTYPE));
        }
    } else {
        if (kt) {
            OutChar(bxofs+ds->keys.width,byofs,G_colour[1],*(BOXRIGHTIN+KEYMAPBTYPE));
        }
        if (kb) {
            OutChar(bxofs+ds->keys.width,byofs+ds->keys.height,G_colour[1],*(BOXRIGHTIN+KEYMAPBTYPE));
        }
    }

    dept=ds->deptlist;
    while (dept!=NULL) {
       if (dept->dept_number==KEYVAL(ds->layout[kindex])) {
            if ((ismenu(dept))||((plu=FindPLU(ds->plulist,dept->osp_code[level]))!=NULL) 
            && ((rplu=FindRePLU(ds->rplulist,dept->osp_code[level]))!=NULL)
            && (plu->plu_code!=0L) ) {
                if (ismenu(dept)) {
                    lastline=OutWrap(bxofs+1,byofs+1,ds->keys.width-1,ds->keys.height-1,
                        G_colour[2],dept->desc);
                    if (lastline<ds->keys.height-1) {
                        OutChar(bxofs+ds->keys.width/2,byofs+ds->keys.height-1,
                            G_colour[2],MENUXCHAR);
                    } else {
                        OutChar(bxofs+ds->keys.width-1,byofs+ds->keys.height-1,
                            G_colour[2],MENUXCHAR);
                    }
                } else {
                    OutWrap(bxofs+1,byofs+1,ds->keys.width-1,ds->keys.height-1,
                        G_colour[2],plu->desc1);
                }
                if (drawt) {
                    TitleBar(dept->osp_code[level],
                            ((ismenu(dept))?"":rplu->desc),
                            ((ismenu(dept))?dept->desc:plu->desc1),
                            rplu->price[0],
                            rplu->price[1],
                            rplu->price[2],
                            rplu->price[3],
                            rplu->price[4],
                            rplu->price[5],
                            plu->status.as_struct.kitch_prnt!='0',ismenu(dept)?1:2);
                    return ((kl!=0)<<3)|((kr!=0)<<2)|((kt!=0)<<1)|((kb!=0)|(ismenu(dept)<<4));
                }
                return 0;
            }
        }
        dept=dept->next;
    }
    OutFormat(bxofs+1,byofs+1,G_colour[2],"%02d",KEYVAL(ds->layout[kindex]));
    if (drawt) {
        TitleBar(0,"","",0,0,0,0,0,0,FALSE,FALSE);
        return ((kl!=0)<<3)|((kr!=0)<<2)|((kt!=0)<<1)|((kb!=0));
    }
    return 0;
}
//__________________________________________________________________________

//==========================================================================
//F DrawMenu
//S Draw a menu box on the right hand side
//D Draw a menu box on the right hand side
//P The current key
//P The keyboard overlay information
//P The current keyboard level
INT DrawMenu(INT curkey,MAINDS *ds,BOOL draw,INT top)
{
    PLU *plu;
    INT yp=MENUTOP+1;
    INT retval=0;
    SetViewPort(MENULEFT,MENUTOP,MENURIGHT,MENUBOTTOM,G_colour[3]);
    if (draw) {
        Rectangle(MENULEFT,MENUTOP,MENURIGHT,MENUBOTTOM,G_colour[3],MENUBTYPE);
        plu=ds->plulist;
        while (plu!=NULL) {
            if (plu->assoc_dept==curkey) {
                if ((yp<MENUBOTTOM)&&(retval>=top)) {
                    OutFormat(MENULEFT+1,yp  ,G_colour[4],"%06d",plu->plu_code);
                    OutFormat(MENULEFT+1+8,yp,G_colour[4],"%s",plu->desc1);
                    yp++;
                }
                retval++;
            }
            plu=plu->next;
        }
    }
    if (top!=0)
        OutFormat(MENULEFT+7,MENUTOP,G_colour[15],"PAGE UP %c",24);
    if (yp==MENUBOTTOM)
        OutFormat(MENULEFT+6,MENUBOTTOM,G_colour[15],"PAGE DOWN %c",25);
    SetViewPort(0,0,80,25,0);
    return retval;
}
//__________________________________________________________________________

//==========================================================================
//F ToggleState
//S Toggle the state of a key between Menu and Single Shot
//D Toggle the state of a key between Menu and Single Shot
//P The key to toggle
//P The main data structures
void ToggleState(INT key,MAINDS *ds)
{
    DEPARTMENT *dept;
    dept=FindDept(ds->deptlist,key);
    if (dept==NULL) return;
    if (strcmp(dept->status.as_string,"01550050")) {
        strcpy(dept->status.as_string,"01550050");
    } else {
        strcpy(dept->status.as_string,"01550040");
    }
}
//__________________________________________________________________________

//==========================================================================
//F KeyGrid
//S Draw the keyboard grid
//D Draw the keyboard grid
//P The current key
//P The keyboard layout information
//P The number of keys
//P The start X co-ordinate
//P The start Y co-ordinate
//P The keyboard overlay information
//P The current keyboard level
//P The key width in characters
//P The key height in characters
BOOL KeyGrid(INT curkey,MAINDS *ds,INT *startx,INT *starty,INT level,BOOL forcedraw)
{
    static BOOL drawall=TRUE;
    INT curindex;
    INT cursorx;
    INT cursory;
    INT kindex;
    INT bound;

    if (forcedraw) drawall=TRUE;
    for (kindex=0;kindex<ds->keys.number;kindex++) {
        if (KEYVAL(ds->layout[kindex])==curkey) break;
    }
    if (kindex==ds->keys.number) return FALSE;
    curindex=kindex;
    cursorx=COLVAL (ds->layout[kindex])-*startx;
    cursory=LINEVAL(ds->layout[kindex])-*starty;

    if (cursorx<0) { (*startx)+=cursorx;   drawall=TRUE; }
    if (cursory<0) { (*starty)+=cursory;   drawall=TRUE; }
    if (cursorx>3) { (*startx)+=cursorx-3; drawall=TRUE; }
    if (cursory>3) { (*starty)+=cursory-3; drawall=TRUE; }

    cursorx=COLVAL (ds->layout[kindex])-*startx;
    cursory=LINEVAL(ds->layout[kindex])-*starty;

    if (drawall) {
        SetViewPort(1,4,48,21,G_colour[2]);
        for (kindex=0;kindex<ds->keys.number;kindex++) {
            DrawKey(ds,kindex,*startx,*starty,level,FALSE);
        }
        SetViewPort(0,0,80,25,0);
        drawall=FALSE;
    }
    bound=DrawKey(ds,curindex,*startx,*starty,level,TRUE);
    KeyInd(51,19,curkey,bound,level);

    return ((bound&0x10)!=0);
}
BOOL StartUp(MAINDS *ds)
{
    CONFIG *cfglist=NULL;
    CHAR ctrl_centre[3];
    INT  term_id;
    CHAR term_t[4];
    INT key;

    SetBlinkBit();
    LoadColours(COLOURFILE,G_colour);

	LoadFont();

    if ((LoadConfig(CONFIGFILE,&cfglist))==FALSE) {
        printf("Error Loading Configuration File!\n");
        if (cfglist==NULL) return FALSE;
        printf("Some data in the file is correct !\nDo you wish to proceed? Y/N");
        key=getch();
        if ((key!='Y')&&(key!='y')) return FALSE;
    }

    if (!StartScreen(cfglist,ctrl_centre,&term_id)) {
        return FALSE;
    }
    OutFormat(28,14,G_colour[21],"Loading Data Please Wait...");
    strcpy(term_t,TerminalType(cfglist,ctrl_centre,term_id));
    FreeCFGList(&cfglist);

    sprintf(G_layoutfile ,LAYOUTFILE ,term_t);
    sprintf(G_helpfile   ,HELPFILE   ,term_t);
    sprintf(G_keymapfile ,KEYMAPFILE ,ctrl_centre,term_id,term_t);
    sprintf(G_plufile    ,PLUFILE    ,ctrl_centre,term_id,term_t);
    sprintf(G_keymapback ,KEYMAPBACK ,ctrl_centre,term_id);
    sprintf(G_pluback    ,PLUBACK    ,ctrl_centre,term_id);
    sprintf(G_plu_keypath,PLU_KEYPATH,ctrl_centre);
    sprintf(G_rplufile   ,RPLUFILE   ,term_t,ctrl_centre);
    sprintf(G_lrplufile  ,LRPLUFILE  ,ctrl_centre,term_t);
    sprintf(G_lrpluback  ,LRPLUBACK  ,ctrl_centre);
    
    mkdir(G_plu_keypath);

    AuditLog("COMPKEY Started");
    if ((ds->layout=LoadLayout(G_layoutfile,&(ds->keys)))==NULL) {
        AuditLog("Can't Load Keyboard Layout!  %s",G_layoutfile);
        printf("Can't Load Keyboard Layout!  %s\n",G_layoutfile);
        return FALSE;
    }

    LoadLocalPLU(G_lrplufile,&(ds->rplulist));
    if (ds->rplulist==NULL) AuditLog("No Local PLU file %s",G_lrplufile);
    LoadReMACSPLU(G_rplufile,&(ds->rplulist));
    if (ds->rplulist==NULL) AuditLog("No ReMACS PLU file %s",G_rplufile);
    LoadPLU(G_plufile,&(ds->plulist),ds->rplulist);
    if (ds->plulist==NULL) AuditLog("No PLU file %s",G_plufile);
    LoadDepartment(G_keymapfile,&(ds->deptlist),ds->keys.number);
    if (ds->deptlist==NULL) AuditLog("No KEYMAP file %s",G_keymapfile);

    HideCursor();
    SetViewPort(0,0,80,25,G_colour[16]);

    return TRUE;
}
void ShutDown(MAINDS *ds,BOOL save)
{
    if (save) {
        AuditLog("Removing KEYMAP Backup File %s",G_keymapback);
        unlink(G_keymapback);
        AuditLog("Renaming KEYMAP File %s to %s",G_keymapfile,G_keymapback);
        rename(G_keymapfile,G_keymapback);
        AuditLog("Saving KEYMAP File %s",G_plufile);
        SaveDepartment(G_keymapfile,&(ds->deptlist),ds->keys.number,TRUE);
        AuditLog("Removing PLU Backup File %s",G_pluback);
        unlink(G_pluback);
        AuditLog("Renaming PLU File %s to %s",G_plufile,G_pluback);
        rename(G_plufile,G_pluback);
        AuditLog("Saving PLU File %s",G_plufile);
        SavePLU(G_plufile,&(ds->plulist),TRUE);
    } else {
        FreeDeptList(&(ds->deptlist));
        FreePLUList(&(ds->plulist));
    }
    if (ds->rplulist!=NULL) {
        AuditLog("Removing Local PLU Backup File %s",G_lrpluback);
        unlink(G_lrpluback);
        AuditLog("Renaming Local PLU File %s to %s",G_lrplufile,G_lrpluback);
        rename(G_lrplufile,G_lrpluback);
        AuditLog("Saving Local PLU File %s",G_lrplufile);
        SaveLocalPLU(G_lrplufile,&(ds->rplulist),TRUE);
    }
    if (ds->layout!=NULL) free(ds->layout);
    SetViewPort(0,0,80,25,0x07);
    RestFont();
    RestCursor();
    AuditLog("COMPKEY Finished");
}
INT PLUInput(MAINDS *ds,INT keypos,INT cursorx,INT cursory,INT level,INT lastkey,CHAR *curdesc,BOOL *kitprnt,LONG update)
{
    CHAR ibuffer[MAXSTRLEN];
    CHAR ibuffercopy[MAXSTRLEN];
    REMACSPLU *rplu;
    PLU *plu;
    DEPARTMENT *dept;

    dept=FindDept(ds->deptlist,keypos);
    if (update==0L) {
        if (dept!=NULL) {
            sprintf(ibuffer,"%ld",dept->osp_code[level]);
        } else {
            ibuffer[0]='\0';
        }
        strcpy(ibuffercopy,ibuffer);
        strcpy(ibuffer,InputLine(ds,1,1,G_colour[6],ibuffer,6,cursorx,cursory,&lastkey,'9'));
    } else {
        sprintf(ibuffer,"%ld",update);
        ibuffercopy[0]='\0';
    }
    if (strcmp(ibuffercopy,ibuffer)) {
        rplu=FindRePLU(ds->rplulist,atol(ibuffer));
        plu=FindPLU(ds->plulist,atol(ibuffer));
        if (plu!=NULL)
            *kitprnt=plu->status.as_struct.kitch_prnt!='0';
        else {
            *kitprnt=FALSE;
        }
        if (rplu!=NULL) {
            dept=FindDept(ds->deptlist,keypos);
            if (dept!=NULL) {
                dept->osp_code[level]=rplu->plu_code;
                if (plu==NULL) {
                    if (rplu==NULL)
                        curdesc[0]='\0';
                    else
                        sprintf(curdesc,"%-.12s",rplu->desc);
                } else {
                    strcpy(curdesc,CleanBuf(plu->desc1));
                }
                TitleBar(dept->osp_code[level],
                        rplu->desc,
                        curdesc,
                        rplu->price[0],
                        rplu->price[1],
                        rplu->price[2],
                        rplu->price[3],
                        rplu->price[4],
                        rplu->price[5],
                        *kitprnt,2);
            }
        } else {
             Beep();
        }
        if (lastkey==F01) lastkey=0;
    }
    return lastkey;
}
INT InputDesc(MAINDS *ds,INT cursorx,INT cursory,CHAR *curdesc,INT len)
{
    INT lastkey;
    strcpy(curdesc,InputLine(ds,9,2,G_colour[8],curdesc,len,cursorx,cursory,&lastkey,'X'));
    return lastkey;
}
INT InputKP(MAINDS *ds,INT cursorx,INT cursory,BOOL *kitprnt)
{
    CHAR ibuffer[MAXSTRLEN];
    INT lastkey;

    ibuffer[1]='\0';
    if (*kitprnt) {
        ibuffer[0]='Y';
    } else {
        ibuffer[0]='N';
    }
    strcpy(ibuffer,InputLine(ds,77,2,G_colour[10],ibuffer,1,cursorx,cursory,&lastkey,'Y'));
    if (ibuffer[0]=='Y') {
        *kitprnt=TRUE;
    } else {
        *kitprnt=FALSE;
    }
    return lastkey;
}
INT MenuPLUInput(MAINDS *ds,PLU *plu,INT cursorx,INT cursory,INT lastkey,CHAR *curdesc,BOOL *kitprnt,LONG *update)
{
    CHAR ibuffer[MAXSTRLEN];
    CHAR ibuffercopy[MAXSTRLEN];
    REMACSPLU *rplu;

    if (*update==0L) {
        if (plu==NULL) {
            ibuffer[0]='\0';
            ibuffercopy[0]='\0';
        } else {
            sprintf(ibuffer,"%ld",plu->plu_code);
            strcpy(ibuffercopy,ibuffer);
        }
        strcpy(ibuffer,InputLine(ds,1,1,G_colour[6],ibuffer,6,cursorx,cursory,&lastkey,'9'));
        *update=atol(ibuffer);
    } else {
        sprintf(ibuffer,"%ld",*update);
        ibuffercopy[0]='\0';
    }
    if (strcmp(ibuffercopy,ibuffer)) {
        rplu=FindRePLU(ds->rplulist,atol(ibuffer));
        plu=FindPLU(ds->plulist,atol(ibuffer));
        if (plu!=NULL) {
            *kitprnt=plu->status.as_struct.kitch_prnt!='0';
            strcpy(curdesc,CleanBuf(plu->desc1));
        } else {
            *kitprnt=FALSE;
            if (rplu==NULL)
                curdesc[0]='\0';
            else
                sprintf(curdesc,"%-.12s",rplu->desc);
        }
        if (rplu!=NULL) {
            TitleBar(atol(ibuffer),
                    rplu->desc,
                    curdesc,
                    rplu->price[0],
                    rplu->price[1],
                    rplu->price[2],
                    rplu->price[3],
                    rplu->price[4],
                    rplu->price[5],
                    *kitprnt,2);
        }
        if (lastkey==F01) lastkey=0;
    }
    return lastkey;
}
BOOL MenuInput(MAINDS *ds,INT keypos,INT cursorx,INT cursory)
{
    REMACSPLU *rplu;
    LONG plu_code;
    PLU *plu;
    CHAR curdesc[13];
    BOOL xit=FALSE;
    BOOL retval=FALSE;
    INT  lastkey=0;
    INT  ipos;
    LONG newcode;
    BOOL kitprnt=FALSE;
    INT  menutop=0;
    INT  menulines;
    DEPARTMENT *dept;

    dept=FindDept(ds->deptlist,keypos);
    if (dept==NULL) return FALSE;
    strcpy(curdesc,CleanBuf(dept->desc)); 
    lastkey=InputDesc(ds,cursorx,cursory,curdesc,8);
    if (lastkey==ENTER)
        strcpy(dept->desc,curdesc);

    menulines=DrawMenu(keypos,ds,TRUE,menutop);
    plu_code=0;
    plu=ds->plulist;
    while (plu!=NULL) {
        if (plu->assoc_dept==keypos) {
            plu_code=plu->plu_code;
            break;
        }
        plu=plu->next;
    }
    if ((plu=FindPLU(ds->plulist,plu_code))==NULL) {
        kitprnt=FALSE;
        if ((rplu=FindRePLU(ds->rplulist,plu_code))==NULL)
            curdesc[0]='\0';
        else
            sprintf(curdesc,"%-.12s",rplu->desc);
    } else {
         kitprnt=plu->status.as_struct.kitch_prnt!='0';
         strcpy(curdesc,CleanBuf(plu->desc1));
    }

    StatusLine(G_tinputkeys,0);
    ipos=0;

    if (plu_code!=0L) MenuPLUInput(ds,plu,cursorx,cursory,lastkey,curdesc,&kitprnt,&plu_code);
    while (!xit) {
        switch (ipos) {
            case 0 :
                plu=FindPLU(ds->plulist,plu_code);
                newcode=0L;
                lastkey=MenuPLUInput(ds,plu,cursorx,cursory,lastkey,curdesc,&kitprnt,&newcode);
                plu=FindPLU(ds->plulist,newcode);
                if ((plu==NULL)&&(lastkey!=F01)) {
                    plu=FindPLU(ds->plulist,plu_code);
                    MenuPLUInput(ds,plu,cursorx,cursory,lastkey,curdesc,&kitprnt,&plu_code);
                    Beep();
                } else {
                    plu_code=newcode;
                }
                break;
            case 1 :
                lastkey=InputDesc(ds,cursorx,cursory,curdesc,12);
                break;
            case 2 :
                lastkey=InputKP(ds,cursorx,cursory,&kitprnt);
                break;
        }
        switch (lastkey) {
            case PGUP :
                if (menutop>MENULENGTH) {
                    menutop-=MENULENGTH-1;
                } else {
                    menutop=0;
                }
                menulines=DrawMenu(keypos,ds,TRUE,menutop);
                break;
            case PGDN :
                if (menutop+MENULENGTH<=menulines) {
                    menutop+=MENULENGTH-1;
                    menulines=DrawMenu(keypos,ds,TRUE,menutop);
                }
                break;
            case F01 :
                RunSearch(ds,&plu_code);
                plu=FindPLU(ds->plulist,plu_code);
                MenuPLUInput(ds,plu,cursorx,cursory,lastkey,curdesc,&kitprnt,&plu_code);
                break;
            case TAB :
                ipos++;
                ipos%=3;
                break;
            case STAB :
                ipos+=2;
                ipos%=3;
                break;
            case F02 :
                xit=TRUE;
                break;
            case DEL :
                if (plu_code!=0L) {
                    menutop=0;
                    plu->assoc_dept=0;
                    menulines=DrawMenu(keypos,ds,TRUE,menutop);
                }
                break;
            case INS :
            case ENTER :
                if (ipos==1) {
                    if (plu!=NULL) strcpy(plu->desc1,curdesc);
                    ipos=0;
                } else if (ipos==2) {
                    if (plu!=NULL) {
                        if (kitprnt)
                            strcpy(plu->status.as_string,"1000000004");
                        else
                            strcpy(plu->status.as_string,"0000000004");
                    }
                } else {
                    if (plu_code!=0L) {
                        menutop=0;
                        plu->assoc_dept=keypos;
                        menulines=DrawMenu(keypos,ds,TRUE,menutop);
                    }
                }
                break;
        }
    }
    StatusLine(G_stdkeys,0);
    return retval;
}
BOOL TitleInput(MAINDS *ds,INT keypos,INT cursorx,INT cursory,INT level)
{
    REMACSPLU *rplu;
    LONG plu_code;
    PLU *plu;
    DEPARTMENT *dept;
    CHAR curdesc[13];
    LONG oldcode;
    BOOL xit=FALSE;
    BOOL retval=FALSE;
    INT  lastkey=0;
    INT  ipos;
    BOOL kitprnt=FALSE;


    dept=FindDept(ds->deptlist,keypos);

    if (ismenu(dept)) {
        return MenuInput(ds,keypos,cursorx,cursory);
    }
    if (dept!=NULL) {
        oldcode=dept->osp_code[level];
        if ((plu=FindPLU(ds->plulist,oldcode))==NULL) {
            kitprnt=FALSE;
            if ((rplu=FindRePLU(ds->rplulist,oldcode))==NULL)
                curdesc[0]='\0';
            else
                sprintf(curdesc,"%-.12s",rplu->desc);
        } else {
            kitprnt=plu->status.as_struct.kitch_prnt!='0';
            strcpy(curdesc,CleanBuf(plu->desc1));
        }
    } else {
        oldcode=0;
    }
    StatusLine(G_tinputkeys,0);
    ipos=0;
    while (!xit) {
        switch (ipos) {
            case 0 :
                lastkey=PLUInput(ds,keypos,cursorx,cursory,level,lastkey,curdesc,&kitprnt,0L);
                break;
            case 1 :
                lastkey=InputDesc(ds,cursorx,cursory,curdesc,12);
                break;
            case 2 :
                lastkey=InputKP(ds,cursorx,cursory,&kitprnt);
                break;
        }
        if (lastkey==F01) {
            RunSearch(ds,&plu_code);
            PLUInput(ds,keypos,cursorx,cursory,level,lastkey,curdesc,&kitprnt,plu_code);
        }
        if (lastkey==TAB)  { ipos++; ipos%=3; }
        if (lastkey==STAB) { ipos+=2; ipos%=3; }
        if ((lastkey==ENTER)||(lastkey==ESC)) xit=TRUE;
        if ((lastkey==DEL)&&(ipos==0)) {
            dept=FindDept(ds->deptlist,keypos);
            dept->osp_code[level]=0;
            strcpy(dept->status.as_string,"00000000");
            strcpy(dept->desc,"        ");
            strcpy(dept->active,"00");
            dept->action=1;
            StatusLine(G_stdkeys,0);
            return TRUE;
        }
    }
    dept=FindDept(ds->deptlist,keypos);
    plu=FindPLU(ds->plulist,dept->osp_code[level]);
    if (dept!=NULL) {
        if (lastkey==ENTER) {
            strcpy(dept->status.as_string,"01550040");
            if (FindRePLU(ds->rplulist,dept->osp_code[level])!=NULL) {
                strcpy(plu->desc1,curdesc);
            } else {
                dept->osp_code[level]=oldcode;
                retval=FALSE;
            }
            if (kitprnt)
                strcpy(plu->status.as_string,"1000000004");
            else
                strcpy(plu->status.as_string,"0000000004");
        } else {
            dept->osp_code[level]=oldcode;
            retval=FALSE;
        }
    }
    StatusLine(G_stdkeys,0);
    return retval;
}

CHAR *GetWrapLine(char *str,INT w,INT h,INT line)
{
    static CHAR retval[MAXSTRLEN];
    CHAR *cptr;
    INT ch;

    if (strlen(str)<w) {
        if (line==0)
            return str;
        else
            return "";
    } else {
        ch=0;
        while ((strlen(str)>w)&&(ch!=h)) {
            cptr=str+w;
            while ((cptr!=str)&&(*cptr!=' ')&&(!ispunct(*cptr))) cptr--;
            if (cptr==str) {
                cptr=str+w-1;
                if (ch==line) {
                    sprintf(retval,"%-*.*s-",w-1,w-1,str);
                    return retval;
                }
            } else {
                if (ch==line) {
                    if (ispunct(*cptr)) cptr++;
                    sprintf(retval,"%-*.*s",
                        (INT)(cptr-str),(INT)(cptr-str),str);
                    return retval;
                }
                cptr++;
            }
            str=cptr;
            ch++;
        }
        if ((ch!=h)&&(ch==line)) {
            if (ch==line) {
                sprintf(retval,"%-*.*s",w-1,w-1,str);
                return retval;
            }
        }    
    }
    return "";
}
void SetPrYofs(FILE *fp,LONG ofs)
{
    static LONG lofs=0;
    LONG tempofs;

    if (G_prtype==PCL) {
        fprintf(fp,"%c%c%c%ld%c",ESC,'*','p',ofs,'Y');
    } else {
        ofs-=94;
        ofs*=100L;
        ofs/=167L;
        if (lofs>ofs) lofs=0;
        tempofs=ofs;
        ofs-=lofs;
        lofs=tempofs;

        while (ofs>255) {
            fprintf(fp,"%c%c%c",ESC,'J',255);
            ofs-=255;
        }
        fprintf(fp,"%c%c%c",ESC,'J',ofs);
    }
}
void SetPrXofs(FILE *fp,INT ofs)
{
    if (G_prtype==PCL) {
        fprintf(fp,"%c%c%c%d%c",ESC,'*','p',ofs,'X');
    } else {
        ofs-=61;
        ofs/=5;
        fprintf(fp,"%c%c%c%c",ESC,'$',ofs%256,ofs/256);
    }
}
void Set15CPI(FILE *fp)
{
    if (G_prtype==PCL) {
        fprintf(fp,"%c%c%c%c%c",ESC,'&','k',50,'S');
    } else {
        fprintf(fp,"%c%c",ESC,'g');
    }
}
void Set10CPI(FILE *fp)
{
    if (G_prtype==PCL) {
        fprintf(fp,"%c%c%c%c%c",ESC,'&','k',48,'S');
    } else {
        fprintf(fp,"%c%c",ESC,'P');
    }
}

void PrintLine(FILE *fp,MAINDS *ds,DEPARTMENT *dept,INT x,INT line,INT level)
{
    INT ofs;
    PLU *plu;
    CHAR *str;
    ofs=PRINTXOFS+PRINTXSTEP*x+PRINTXMID;

    if (ismenu(dept)) {
        switch (line) {
            case 0 :
                ofs-=(strlen(CleanBuf(dept->desc))*PRINTCHARWID)/2;
                SetPrXofs(fp,ofs);
                fprintf(fp,"%s",CleanBuf(dept->desc));
                break;
            case 2 :
                ofs-=PRINTCHARWID;
                SetPrXofs(fp,ofs);
                Set10CPI(fp);
                fprintf(fp,"X");
                Set15CPI(fp);
                break;
        }
    } else {
        if (dept->osp_code[level]!=0) {
            plu=FindPLU(ds->plulist,dept->osp_code[level]);
            if (plu!=NULL) {
                str=CleanBuf(GetWrapLine(CleanBuf(plu->desc1),ds->keys.width-1,ds->keys.height,line));
                ofs-=(strlen(str)*PRINTCHARWID)/2;
                SetPrXofs(fp,ofs);
                fprintf(fp,"%s",str);
            }
        }
    }
}
void PrintKeyboard(MAINDS *ds,INT level)
{
    INT kindex;
    INT maxc=0,maxl=0,line;
    INT c,l;
    DEPARTMENT *dept;
    FILE *fp;

    
//    fp=fopen("TEST.PRN","w");
//    if (fp==NULL) {
        fp=stdprn;
//    }
    for (kindex=0;kindex<ds->keys.number;kindex++) {
        maxc=max(maxc,COLVAL (ds->layout[kindex]));
        maxl=max(maxl,LINEVAL(ds->layout[kindex]));
    }
    Set15CPI(fp);
    for (l=0;l<=maxl;l++) {
        for (line=0;line<3;line++) {
            SetPrYofs(fp,PRINTYOFS+PRINTYSTEP*l+line*PRINTLINESTEP);
            for (c=0;c<=maxc;c++) {
                kindex=KeyAtPos(ds->layout,ds->keys.number,c,l);
                dept=FindDept(ds->deptlist,kindex);
                if (dept!=NULL) {
                    PrintLine(fp,ds,dept,c,line,level);
                }
            }

        }
    }
    Set10CPI(fp);
    fprintf(fp,"%c",12);
    if (fp!=stdprn) fclose(fp);
}
BOOL ExitMenu(MAINDS *ds)
{
    static UINT scrbuffer[25*80];
    BOOL xit=FALSE;
    CHAR ibuffer[MAXSTRLEN];
    INT lastkey;
    memcpy(scrbuffer,((UINT far *)SCREENBASE),25*80*2);
    SetViewPort(0,0,80,25,G_colour[18]);
    StatusLine(G_exitsstat,0);

    OutFormat(10, 3,G_colour[18],"1 - Transmit to EPos Now");
    OutFormat(10, 5,G_colour[18],"2 - Transmit to EPos at End-of-Day");
    OutFormat(10, 7,G_colour[18],"3 - Transmit to EPos on Specific date");
    OutFormat(10, 9,G_colour[18],"4 - Print Layout Keyboard Levels 1, 2 & 3");
    OutFormat(10,11,G_colour[18],"5 - Print Layout Keyboard Level 1");
    OutFormat(10,13,G_colour[18],"6 - Print Layout Keyboard Level 2");
    OutFormat(10,15,G_colour[18],"7 - Print Layout Keyboard Level 3");
    OutFormat(10,17,G_colour[18],"8 - Exit");
    while (!xit) {
        lastkey=GetKey();
        switch (lastkey) {
            case ESC :
                memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
                return FALSE;
            case '1' : // transmit now
                AuditLog("Transmit Now Selected");
                break;
            case '2' : // transmit EoD
                AuditLog("Transmit End-of-Day Selected");
                break;
            case '3' : // transmit Date
                OutFormat(10,19,G_colour[18],"Enter The Date in the format YY/MM/DD [        ]");
                strcpy(ibuffer,"96/06/11");
                strcpy(ibuffer,InputLine(ds,49,19,G_colour[6],ibuffer,8,-1,-1,&lastkey,'D'));
                if (lastkey==ENTER) {
                    OutFormat(10,19,G_colour[18],"                                                ");
                    AuditLog("Transmit Date Selected [%s]",ibuffer);
                }
                break; 
            case '4' : // Print Levels 1-3
                OutFormat(10,19,G_colour[18],"Insert Paper and press a key (Escape to abort)");
                if (GetKey()!=ESC) {
                    OutFormat(10,19,G_colour[18],"                                              ");
                    PrintKeyboard(ds,0);
                    AuditLog("Print KeyMap Level %d",1);
                    OutFormat(10,19,G_colour[18],"Insert Paper and press a key (Escape to abort)");
                    if (GetKey()!=ESC) {
                        OutFormat(10,19,G_colour[18],"                                              ");
                        PrintKeyboard(ds,1);
                        AuditLog("Print KeyMap Level %d",2);
                        OutFormat(10,19,G_colour[18],"Insert Paper and press a key (Escape to abort)");
                        if (GetKey()!=ESC) {
                            PrintKeyboard(ds,2);
                            AuditLog("Print KeyMap Level %d",3);
                        }
                    }
                }
                OutFormat(10,19,G_colour[18],"                                              ");
                break;
            case '5' : // Print Level 1
            case '6' : // Print Level 2
            case '7' : // Print Level 3
                OutFormat(10,19,G_colour[18],"Insert Paper and press a key (Escape to abort)");
                if (GetKey()!=ESC) {
                    OutFormat(10,19,G_colour[18],"                                              ");
                    PrintKeyboard(ds,lastkey-'5');
                    AuditLog("Print KeyMap Level %d",lastkey-'4');
                } else {
                    OutFormat(10,19,G_colour[18],"                                              ");
                }
//                xit=TRUE;
                break;
            case '8' : // Exit
                StatusLine(G_exitstat2,1);
                if (toupper(GetKey())=='Y') {
                    xit=TRUE;
                    AuditLog("Save and Exit Selected");
                } else {
                    memcpy(((UINT far *)SCREENBASE),scrbuffer,25*80*2);
                    return FALSE;
                }
                break;
            default :
                Beep();
        }
    }
    return TRUE;
}
//==========================================================================
//F main
//S COMPKEY.EXE
//D COMPKEY.EXE
//R ErrorLevel = 0 on error 1 OK
int main(void)
{
    MAINDS ds;
    BOOL save;
    BOOL modified=FALSE;
    BOOL forcedraw=TRUE;
    BOOL xit=FALSE;
    BOOL onmenu;
    DEPARTMENT *dept;
    INT menulines;
    INT menutop=0;
    INT keypos;
    INT kp;
    INT level=0;
    INT x,y;
    INT cx,cy;

    ds.layout  =NULL;
    ds.deptlist=NULL;
    ds.plulist =NULL;
    ds.rplulist=NULL;
    
    sprintf(G_helpfile,HELPFILE,"DEF");

    if (!StartUp(&ds)) {
        RestCursor();
        SetViewPort(0,0,80,25,0x07);
        return 0;
    }

    StatusLine(G_stdkeys,0);

    x=0;
    y=0;
    cx=0;
    cy=0;
    keypos=1;

    while (!xit) {
        onmenu=KeyGrid(keypos,&ds,&x,&y,level,forcedraw);
        forcedraw=FALSE;
        menulines=DrawMenu(keypos,&ds,onmenu,menutop);
        KeyCursor(GRIDLEFT+1+(cx-x)*ds.keys.width,GRIDTOP+1+(cy-y)*ds.keys.height,ds.keys.width-1,ds.keys.height-1,G_colour[0]);
        switch(GetKey()) {
            case AF01 :
                level++;
                level%=3;
                forcedraw=TRUE;
                break;
            case F09 :
                RunHelp(MAINHELP);
                break;
            case F10:
                if (ExitMenu(&ds)) {
                    xit=TRUE;
                    save=TRUE;
                }
                break;
            case ESC :
                modified=TRUE; // force question !!!
                if (modified) {
                    StatusLine(G_exitstat,1);
                    if (GetKey()==ESC) {
                        xit=TRUE;
                        save=FALSE;
                    } else {
                        StatusLine(G_stdkeys,0);
                    }
                } else {
                    xit=TRUE;
                    save=FALSE;
                }
                break;
            case UP :
                if ((kp=KeyAtPos(ds.layout,ds.keys.number,cx,cy-1))!=0) {
                    menutop=0;
                    keypos=kp;
                    cy--;
                }
                break;
            case DOWN :
                if ((kp=KeyAtPos(ds.layout,ds.keys.number,cx,cy+1))!=0) {
                    menutop=0;
                    keypos=kp;
                    cy++;
                }
                break;
            case LEFT :
                if ((kp=KeyAtPos(ds.layout,ds.keys.number,cx-1,cy))!=0) {
                    menutop=0;
                    keypos=kp;
                    cx--;
                }
                break;
            case RGT :
                if ((kp=KeyAtPos(ds.layout,ds.keys.number,cx+1,cy))!=0) {
                    menutop=0;
                    keypos=kp;
                    cx++;
                }
                break;
            case TAB :
                if (keypos<ds.keys.number) {
                    keypos++;
                } else {
                    keypos=1;
                }
                menutop=0;
                SetCurXY(ds.layout,ds.keys.number,keypos,&cx,&cy);
                break;
            case STAB :
                if (keypos>1) {
                    keypos--;
                } else {
                    keypos=ds.keys.number;
                }
                menutop=0;
                SetCurXY(ds.layout,ds.keys.number,keypos,&cx,&cy);
                break;
            case HOME :
                keypos=1;
                menutop=0;
                SetCurXY(ds.layout,ds.keys.number,keypos,&cx,&cy);
                break;
            case END :
                keypos=ds.keys.number;
                menutop=0;
                SetCurXY(ds.layout,ds.keys.number,keypos,&cx,&cy);
                break;
            case F05 :
                menutop=0;
                forcedraw=TRUE;
                ToggleState(keypos,&ds);
                break;
            case F02 :
                if (TitleInput(&ds,keypos,cx-x,cy-y,level)) {
                    modified=TRUE;
                    forcedraw=TRUE;
                }
                break;
            case DEL :
                dept=FindDept(ds.deptlist,keypos);
                if (dept!=NULL) {
                    if (ismenu(dept)) {
                        dept->osp_code[0]=0;
                        dept->osp_code[1]=0;
                        dept->osp_code[2]=0;
                    } else {
                        dept->osp_code[level]=0;
                    }
                    strcpy(dept->status.as_string,"00000000");
                    strcpy(dept->desc,"        ");
                    strcpy(dept->active,"00");
                    dept->action=1;
                    forcedraw=TRUE;
                }
            case PGUP :
                if (onmenu) {
                    if (menutop>MENULENGTH) {
                        menutop-=MENULENGTH-1;
                    } else {
                        menutop=0;
                    }
                }
                break;
            case PGDN :
                if (onmenu) {
                    if (menutop+MENULENGTH<=menulines) {
                        menutop+=MENULENGTH-1;
                    } 
                }
                break;
        }
    }

    ShutDown(&ds,save);

    return 1;
}
//__________________________________________________________________________


//=========================================================================
// End of file (COMPKEY.C)
//=========================================================================
