//===============|========================================================|
//               |                                                        |
// Module        | VIDEOKBD.C                                             |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | Video & Keyboard Functions for use by COMPKEY.C        |
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


#define __VIDEOKBD_C

#include <stdio.h>       // For stdout printf() etc...
#include <string.h>      // For strlen() etc...
#include <memory.h>      // For memset() etc...
#include <stdarg.h>      // For Variable argument params.
#include <malloc.h>      // Fro free() & malloc()
#include <dos.h>         // BORLAND For delay(), REGPACK etc...
#include <conio.h>       // BORLAND For getch() kbhit() cprintf() etc...

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations
#include "videokbd.h"    // Video & Keyboard declarations

//==========================================================================
//F RestFont
//S Restore the VGA text font to default values
//D Restore the VGA text font to default values
void RestFont(void)
{
    struct REGPACK r;
    r.r_ax=0x1104;
    r.r_bx=0x0000;
    intr(0x10,&r);
    free(G_font);
}
//__________________________________________________________________________

//==========================================================================
//F GetFont
//S Return the address of a VGA font mapping
//D Return the address of a VGA font mapping
//P The font type
//R The address of the font mapping
UCHAR *GetFont(INT type)
{
    struct REGPACK r;
	unsigned char *font;
    r.r_ax=0x1130;
    r.r_bx=type<<8;
    intr(0x10,&r);
    font=(UCHAR *)MK_FP(r.r_es,r.r_bp);
	return(font);
}
//__________________________________________________________________________

//==========================================================================
//F LoadFont
//S Load the VGA font from a local array
//D Load the VGA font from a local array
//P The local array containing the font information
void LoadFont(void)
{
    struct REGPACK r;

    if ((G_font=malloc(256*16))==NULL) return;

    memcpy(G_font,GetFont(6),256*16);
	memcpy(G_font+185*16,G_boxchars,4*16);
    memcpy(G_font+200*16,G_boxchars+4*16,8*16);

    r.r_ax=0x1110;
    r.r_bx=0x1000;
    r.r_cx=255;
    r.r_dx=0;
    r.r_es=FP_SEG(G_font);
    r.r_bp=FP_OFF(G_font);
    intr(0x10,&r);
}
//__________________________________________________________________________

//==========================================================================
//F GetKey
//S Wait for and return a key from the keyboard
//D Wait for and return a key from the keyboard
//R The key pressed or if an extended key 0-the key pressed
INT GetKey(void)
{
    INT k;
    if (!(k=getch())) k=0-getch();
    return k;
}
//__________________________________________________________________________

void DrawCBar(INT x,INT y,INT wid,INT attr)
{
    UINT far *scr=((UINT far *)SCREENBASE)+y*80+x;
    while (wid--) *(scr++)^=attr<<8;
}
//==========================================================================
//F KeyCursor
//S Flash a cursor of inverse video while waiting for a key press
//D Flash a cursor of inverse video while waiting for a key press
//P The x co-ordinate (Zero based) of the top-left corner
//P The y co-ordinate (Zero based) of the top-left corner
//P The width in characters of the cursor
//P The height in characters of the cursor
void KeyCursor(INT x,INT y,INT width,INT height,INT flash)
{
    UINT far *scr;
    INT i,j;
    INT dcount;
    INT curon=0;

    scr=((UINT far *)SCREENBASE)+y*80+x;
    while (!kbhit()) {
        for (i=0;i<height;i++) {
            for (j=0;j<width;j++) {
                *(scr+i*80+j)^=flash<<8;
            }
        }
        dcount=250;
        while ((dcount)&&(!kbhit())) {
            delay(1);
            dcount--;
        }
        curon^=1;
    }
    if (curon) {
        for (i=0;i<height;i++) {
            for (j=0;j<width;j++) {
                *(scr+i*80+j)^=flash<<8;
            }
        }
    }
}
//__________________________________________________________________________

//==========================================================================
//F Rectangle
//S Draw a rectangle
//D Draw a rectangle using the character output device
//P First X Co-ordinate
//P First Y Co-ordinate
//P Second X Co-ordinate
//P Second Y Co-ordinate
//P The attribute of the box characters
//P The type of the box characters i.e. 0 = ÚÄ   1 = ÉÍ   2 = Ûß
void Rectangle(INT x,INT y,INT x1,INT y1,INT colour,INT type)
{
    INT paramswap;                                 // for swapping params
    INT xcount;                                    // counter for x co-ordinate
    INT ycount;                                    // counter for y co-ordinate

    if ( (x==x1) || (y==y1) ) return;              // Not Visible return

    if (x>x1) { paramswap=x; x=x1; x1=paramswap; } // swap x & x1 order
    if (y>y1) { paramswap=y; y=y1; y1=paramswap; } // swap y & y1 order

    OutChar(x ,y ,colour,*(BOXTOPLEFT +type));                    // output the corners
    OutChar(x1,y ,colour,*(BOXTOPRIGHT+type));         
    OutChar(x ,y1,colour,*(BOXBOTLEFT +type));
    OutChar(x1,y1,colour,*(BOXBOTRIGHT+type));

    for (xcount=x+1;xcount<=x1-1;xcount++) {       // output the top & bottom
        OutChar(xcount,y ,colour,*(BOXTOP   +type));
        OutChar(xcount,y1,colour,*(BOXBOTTOM+type));
    }
    for (ycount=y+1;ycount<=y1-1;ycount++) {       // output the left & right
        OutChar(x ,ycount,colour,*(BOXLEFT+type));
        OutChar(x1,ycount,colour,*(BOXLEFT+type));
    }
}
//__________________________________________________________________________

//==========================================================================
//F OutChXY
//S Output a character of a given colour at an X/Y co-ordinate
//D Output a character of a given colour at an X/Y co-ordinate.  
//D NOTE: This function has no bounds checking and should not 
//D be called directly.  Use OutChar() to perform this function.
//P The X co-ordinate (Zero based - origin top left)
//P The Y co-ordinate (Zero based - origin top left)
//P The attribute
//P The character
void OutChXY(INT x,INT y,UINT colour,CHAR ch)
{
#ifdef DIRECT_VIDEO_ACCESS
    UINT far *scr=(UINT far *)SCREENBASE;
    scr+=x+y*80;
    *scr=(colour<<8)|(UCHAR)ch;
#else
    textattr(colour);                              // set attribute;
    gotoxy(x+1,y+1);                               // position cursor
    cprintf("%c",ch);                              // output the character
#endif
}
//__________________________________________________________________________

//==========================================================================
//F OutChar
//S Output a character on the console
//D Output a character on the console at a given x and y co-ordinate.
//D Any character that falls outside the clipping viewport will be ignored.
//D use SetViewPort() to assign the clipping values.
//P Zero based X Co-ordinate (origin Top Left)
//P Zero based Y Co-ordinate (origin Top Left)
//P The character to output
void OutChar(INT x,INT y,INT colour,CHAR ch)
{
    if ( (x<G_viewminx)                            // Off Left
    ||   (y<G_viewminy)                            // Off Top
    ||   (x>G_viewmaxx)                            // Off Right
    ||   (y>G_viewmaxy) )                          // Off Bottom
        return;                                    // So return
    OutChXY(x,y,colour,ch);
}
//__________________________________________________________________________

//==========================================================================
//F OutFormat
//S Formatted String Output on the console
//D Formatted String Output on the console at a given x and y co-ordinate
//D using the same formatting commands as printf().
//D Any character that falls outside the clipping viewport will be ignored.
//D use SetViewPort() to assign the clipping values.
//P Zero based X Co-ordinate (origin Top Left)
//P Zero based Y Co-ordinate (origin Top Left)
//P The attribute
//P The format string. NOTE: must NOT result in string length > MAXSTRLEN
//P variable parameters
void OutFormat (INT x,INT y,INT colour,CHAR *format,...)
{
    static CHAR outstr[MAXSTRLEN];                 // output string buffer
    CHAR *outstrptr;                               // output string start ptr.
	va_list ap;                                    // variable arg. list ptr.

    if ( (y<G_viewminy)                            // Off Top
    ||   (x>G_viewmaxx)                            // Off Right
    ||   (y>G_viewmaxy) )                          // Off Bottom
        return;                                    // So return

    memset(outstr,0,MAXSTRLEN);                    // Zero buffer

    va_start(ap,format);                           // start variable arg. list
    vsprintf(outstr,format,ap);                    // convert args to string
    va_end(ap);                                    // end variable arg. list

    if ( (x+(INT)strlen(outstr)) < G_viewminx)     // Off Left
        return;                                    // So return

    if (x<G_viewminx) {                            // start string Off left
        outstrptr=outstr+(G_viewminx-x);           // move start ptr.
        x=G_viewminx;
    } else {
        outstrptr=outstr;                          // set start ptr.
    }

    if (strlen(outstrptr)+x >= G_viewmaxx)         // Off right 
        *(outstrptr+(G_viewmaxx-(x-1)))='\0';      // Zero terminate

    while (*outstrptr)                             // output within viewport
        OutChXY(x++,y,colour,*(outstrptr++));
}
//__________________________________________________________________________

//==========================================================================
//F SetViewPort
//S Set the View Port clipping parameters
//D Set the View Port clipping parameters.
//D All subsequent video output will be clipped to these boundaries.
//P The minimum X co-ordinated
//P The minimum Y co-ordinated
//P The maximum X co-ordinated
//P The maximum Y co-ordinated
//P Zero to leave, The attribute to clear the area covered by the view port
void SetViewPort(INT minx,INT miny,INT maxx,INT maxy,BOOL attrib)
{
    int ycount;
    G_viewmaxx=maxx;
    G_viewmaxy=maxy;
    G_viewminx=minx; 
    G_viewminy=miny;
    if (attrib) {
        for (ycount=miny;ycount<=maxy;ycount++)
            OutFormat(0,ycount,attrib,"%*.*s",80,80,"");
    }
}
//__________________________________________________________________________

//==========================================================================
//F OutCentre
//S Output a formatted string centred about an X/Y co-ordinate
//D Output a formatted string centred about an X/Y co-ordinate
//P Zero based X Co-ordinate (origin Top Left)
//P Zero based Y Co-ordinate (origin Top Left)
//P The attribute
//P The format string. NOTE: must NOT result in string length > MAXSTRLEN
//P variable parameters
void OutCentre(INT x,INT y,INT attr,CHAR *format,...)
{
    static CHAR str[MAXSTRLEN];                    // output string buffer
    CHAR *sptr;
	va_list ap;                                    // variable arg. list ptr.
    va_start(ap,format);                           // start variable arg. list
    vsprintf(str,format,ap);                       // convert args to string
    va_end(ap);                                    // end variable arg. list

    sptr=CleanBuf(str);
    x-=(strlen(sptr)+1)/2;
    OutFormat(x,y,attr,sptr);
}
//__________________________________________________________________________

//==========================================================================
//F OutWrap
//S Output a string with word wrap, centred.
//D Output a string with word wrap, centred.
//P Zero based X Co-ordinate (origin Top Left)
//P Zero based Y Co-ordinate (origin Top Left)
//P The maximum width of any line
//P The height (i.e. number of lines)
//P The attribute
//P The string
//R The actual height (i.e. number of lines) of the output string
INT OutWrap(INT x,INT y,INT w,INT h,INT attr,CHAR *str)
{
    CHAR *cptr;
    INT ch=0;

    if (strlen(str)<w) {
        OutCentre(x+(w+1)/2,y,attr,"%s",str);
        ch++;
    } else {
        while ((strlen(str)>w)&&(ch!=h)) {
            cptr=str+w;
            while ((cptr!=str)&&(*cptr!=' ')) cptr--;
            if (cptr==str) {
                cptr=str+w-1;
                OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s-",w-1,w-1,str);
            } else {
                OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s",
                    (INT)(cptr-str),(INT)(cptr-str),str);
                cptr++;
            }
            str=cptr;
            ch++;
        }
        if (ch!=h) OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s",w,w,str);
    }
    return ch;
}
//__________________________________________________________________________


//=========================================================================
// End of file (VIDEOKBD.C)
//=========================================================================

