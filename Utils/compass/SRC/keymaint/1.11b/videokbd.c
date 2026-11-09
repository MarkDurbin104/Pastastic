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

//=========================================================================
// Include Section
//=========================================================================


#include <stdio.h>       // For stdout printf() etc...
#include <string.h>      // For strlen() etc...
#include <memory.h>      // For memset() etc...
#include <stdarg.h>      // For Variable argument params.
#include <malloc.h>      // For free() & malloc()
#include <ctype.h>       // For ispunct()
#include <dos.h>         // BORLAND For delay(), REGPACK etc...
#include <conio.h>       // BORLAND For getch() kbhit() etc...
#include <time.h>        // C700 clock_ clock();

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations
#include "videokbd.h"    // Video & Keyboard declarations
#include "deballoc.h"    // debug memory allocation routines


#define DIRECTVIDEO 1

//=========================================================================
// Globals Section
//=========================================================================

#ifndef DIRECTVIDEO
INT G_screenmem[26*80];
#endif

//=========================================================================
// Define Section
//=========================================================================

//=========================================================================
// Declarations Section
//=========================================================================

//=========================================================================
// Definitions Section
//=========================================================================

void SaveScreen(INT *addr)
{
#ifdef DIRECTVIDEO
    memcpy(addr,((UINT far *)SCREENBASE),25*80*2);
#else
    memcpy(addr,G_screenmem,25*80*2);
#endif
}
void CopyOnScreen(INT *addr)
{
    INT i;
    for (i=0;i<1999;i++) {
        PlaceCursor(i%80+1,i/80+1);
        textattr((((*addr)>>8)&0xFF));
        putch((INT)((*addr)&0xFF));
        addr++;
    }
}
void RestScreen(INT *addr)
{
#ifdef DIRECTVIDEO
    memcpy(((UINT far *)SCREENBASE),addr,25*80*2);
#else
    CopyOnScreen(addr);
#endif
}

//==========================================================================
//F DrawCBar
//S Draw a cursor bar 
//D Draw a cursor bar 
//P 0 based x co-ordinate
//P 0 based y co-ordinate
//P The width of the bar in characters
//P The attribute to XOR the video memory with
void DrawCBar(INT x,INT y,INT w,INT h,INT attr)
{
#ifdef DIRECTVIDEO
    UINT far *scr=((UINT far *)SCREENBASE)+y*80+x; // address video buffer
    UINT far *scrptr;                             // address video buffer
    INT wid;
    while (h--) {
        wid=w;
        scrptr=scr;
        scr+=80;
        while (wid--) *(scrptr++)^=attr<<8;          // flip attribute
    }
#else
    INT i,j;

    for (i=x;i<x+w;i++) {
        for (j=y;j<y+h;j++) {
            G_screenmem[i+j*80]^=(attr<<8);
            textattr((G_screenmem[i+j*80]>>8)&0xFF);
            PlaceCursor(i+1,j+1);
            putch(G_screenmem[i+j*80]&0x00FF);
        }
    }
#endif
}
//==========================================================================
//F Beep
//S sound the speaker at 1Khz for 100ms
//D sound the speaker at 1Khz for 100ms
void Beep(void)
{
#ifdef __BORLANDC__
    if (G_usinginputfile==NULL) {
        sound(1000);            // 1Khz
        delay(100);             // 100 ms
        nosound();              // switch off
    }
#else
    CHAR ctrl;              // control port flags
    clock_t endt;           // timer counter

    _outp(0x43,0xB6);       // set time period to
    _outp(0x42,168);        // 1/1000 s
    _outp(0x42,4);          // load
    ctrl=_inp(0x61);        // get control flags
    _outp(0x61,ctrl|3);     // turn on speaker clock
    endt=clock()+100;       // get the ms clock + 100ms
    while (endt>clock());   // wait for the ms clock
    _outp(0x61,ctrl);       // turn off the speaker clock
#endif
}
//__________________________________________________________________________

//==========================================================================
//F SetBlinkBit
//S Set The Blink attribute bit
//D Set The Blink attribute bit
void SetBlinkBit(void)
{
    union REGS r;      // registers for interrupt call
    r.x.ax=0x1003;     // call bios to set the text attribute
    r.x.bx=0x0001;     // bit 7 for flashing
    int86(0x10,&r,&r); // interrupt call
}
//__________________________________________________________________________

//==========================================================================
//F RestCursor
//S Restore the cursor
//D Restore the cursor
void RestCursor(void)
{
    union REGS r;      // registers for interrupt call
    r.x.ax=0x0100;
    r.x.cx=0x0708;
    int86(0x10,&r,&r);
}
//__________________________________________________________________________

//==========================================================================
//F LargeCursor
//S Set the cursor to full height
//D Set the cursor to full height
void LargeCursor(void)
{
    union REGS r;      // registers for interrupt call
    r.x.ax=0x0100;
    r.x.cx=0x0008;
    int86(0x10,&r,&r);
}
//__________________________________________________________________________

//==========================================================================
//F HideCursor
//S Hide the cursor
//D Hide the cursor
void HideCursor(void)
{
    union REGS r;      // registers for interrupt call
    r.x.ax=0x0100;
    r.x.cx=0x2000;
    int86(0x10,&r,&r);
}
//__________________________________________________________________________

//==========================================================================
//F PlaceCursor
//S Place the cursor at a given X/Y coordinate
//D Place the cursor at a given X/Y coordinate
//P 1 based x co-ordinate
//P 1 based y co-ordinate
void PlaceCursor(INT x,INT y)
{
    union REGS r;      // registers for interrupt call
    x--;               // make x zero offset
    y--;               // make y zero offset
    r.x.ax=0x0200;
    r.x.bx=0x0000;
    r.x.dx=(y<<8)|x;
    int86(0x10,&r,&r);
}
//__________________________________________________________________________

//==========================================================================
//F RestFont
//S Restore the VGA text font to default values
//D Restore the VGA text font to default values
void RestFont(void)
{
    union REGS r;      // registers for interrupt call
    r.x.ax=0x1104;
    r.x.bx=0x0000;
    int86(0x10,&r,&r);
    FREE(G_font);
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
	unsigned char *font;
#ifdef __BORLANDC__
#ifndef __DPMI16__
    struct REGPACK r;    // regpack not supported by Microsoft
    r.r_ax=0x1130;       // and no other way of assigning to _bp
    r.r_bx=type<<8;      // unless this routine is written in Assembler
    intr(0x10,&r);       // so only support under Borland
    font=(UCHAR *)MK_FP(r.r_es,r.r_bp);
#endif
#endif
	return(font);
}
//__________________________________________________________________________

//==========================================================================
//F LoadFont
//S Load the VGA font from a local array
//D Load the VGA font from a local array
void LoadFont(void)
{
#ifdef __BORLANDC__                            // regpack not supported by Microsoft
#ifndef __DPMI16__
    struct REGPACK r;                          // and no other way of assigning to _bp
                                               // unless this routine is written in Assembler
    if ((G_font=MALLOC(256*16))==NULL) return; // so only support under Borland

    memcpy(G_font,GetFont(6),256*16);           // get the font into local memory
	memcpy(G_font+185*16,G_boxchars,4*16);      // overload the box characters
    memcpy(G_font+200*16,G_boxchars+4*16,8*16); // and the X for menus

    r.r_ax=0x1110;
    r.r_bx=0x1000;
    r.r_cx=255;
    r.r_dx=0;
    r.r_es=FP_SEG(G_font);
    r.r_bp=FP_OFF(G_font);
    intr(0x10,&r);
#endif
#endif
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
    if (G_usinginputfile!=NULL) {
        if (kbhit()) {
            fclose(G_usinginputfile);
            G_usinginputfile=NULL;
        } else {
            if ((G_usinginputfile->flags&_F_EOF)==_F_EOF) {
                fclose(G_usinginputfile);
                G_usinginputfile=NULL;
            } else {
                fread(&k,1,sizeof(int),G_usinginputfile);
                return k;
            }
        }
    }
    if (!(k=getch())) k=0-getch();   // Return -ive key value for extended keys
    if (G_usingoutputfile!=NULL) {
        fwrite(&k,1,sizeof(int),G_usingoutputfile);
        fflush(G_usingoutputfile);
    }
    return k;
}
//==========================================================================
//F KeyHit
//S return TRUE if a key is available
//D return TRUE if a key is available
//R TRUE if a key is available, otherwise FALSE
BOOL KeyHit(void)
{
    if (G_usinginputfile!=NULL) {
        if (kbhit()) {
            fclose(G_usinginputfile);
            G_usinginputfile=NULL;
        } else {
            if ((G_usinginputfile->flags&_F_EOF)==_F_EOF) {
                fclose(G_usinginputfile);
                G_usinginputfile=NULL;
            } else {
                return TRUE;
            }
        }
    }
    return kbhit();
}
//__________________________________________________________________________
//__________________________________________________________________________

//==========================================================================
//F KeyCursor
//S Flash a cursor of inverse video while waiting for a key press
//D Flash a cursor of inverse video while waiting for a key press
//P The x co-ordinate (Zero based) of the top-left corner
//P The y co-ordinate (Zero based) of the top-left corner
//P The width in characters of the cursor
//P The height in characters of the cursor
//P The attribute to XOR the video memory with
void KeyCursor(INT x,INT y,INT width,INT height,INT flash)
{
    INT dcount;     // width counter
    INT curon=0;    // cursor on/off flag (bit 0)
#ifndef __BORLANDC__
    LONG timeloop;  // timer counter
#endif

    while (!KeyHit()) {
        DrawCBar(x,y,width,height,flash);
#ifdef __BORLANDC__
        dcount=25;                        // wait for 1/4 seccond 
        while ((dcount)&&(!KeyHit())) {    // in steps of 10ms
            delay(10);                    // to help with keyboard
            dcount--;                     // responce
        }
#else
        dcount=5;                         // same time under Microsoft 
        while ((dcount)&&(!KeyHit())) {    // but the call to clock()
            timeloop=clock()+10;          // has a high overhead
            while (timeloop>clock());     // so only 5 calls
            dcount--;
        }
#endif
        curon^=1;                         // flip the cursor state
    }
    if (curon) {                          // if the cursor is still on
        DrawCBar(x,y,width,height,flash);
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

    OutChar(x ,y ,colour,*(BOXTOPLEFT +type));     // output the corners
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
#ifdef DIRECTVIDEO
    UINT far *scr=(UINT far *)SCREENBASE;  // video memory base address
    scr+=x+y*80;                           // offset to x/y
    *scr=((colour&0xFF)<<8)|(UCHAR)ch;     // place the char and attribute
#else
    if ((x>=79)&&(y>=24)) return;
    textattr(colour);
    PlaceCursor(x+1,y+1);
    putch((INT)ch);
    G_screenmem[x+y*80]=(INT)ch+(colour<<8);
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
    OutChXY(x,y,colour,ch);                        // do the work
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
    int ycount;         // counter for view port fill 
    G_viewmaxx=maxx;    if (G_viewmaxx>79) G_viewmaxx=79;
    G_viewmaxy=maxy;    if (G_viewmaxy>24) G_viewmaxy=24;
    G_viewminx=minx;    if (G_viewminx<0 ) G_viewminx=0 ;
    G_viewminy=miny;    if (G_viewminy<0 ) G_viewminy=0 ;
    if (attrib) {       // if the atribute is non-zero, fill the area
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

    sptr=CleanBuf(str);                            // remove white space
    x-=(strlen(sptr)+1)/2;                         // adjust x for centre
    OutFormat(x,y,attr,sptr);                      // output
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
    CHAR *cptr; // current end pointer
    INT ch;     // current height position

    for (ch=0;ch<h;ch++) // blank fill the area
        OutFormat(x,y+ch,attr,"%*.*s",w,w,"");

    ch=0;                        // set to first line
    if (strlen(str)<w) {         // whole string fits in width so output
        OutCentre(x+(w+1)/2,y,attr,"%s",str);
        ch++;
    } else {
        while ((strlen(str)>w)&&(ch!=h)) { // still within box
            cptr=str+w;                    // move end pointer
            while ((cptr!=str)&&(*cptr!=' ')&&(!ispunct(*cptr))) cptr--;
            if (cptr==str) {   // no spaces or punctuation found - hyphenate
                cptr=str+w-1;
                OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s-",w-1,w-1,str);
            } else {
                if (ispunct(*cptr)) { // punctuation found split at punct.
                    cptr++;
                    OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s",
                        (INT)(cptr-str),(INT)(cptr-str),str);
                } else {              // space found split string and drop space
                    OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s",
                        (INT)(cptr-str),(INT)(cptr-str),str);
                    cptr++;
                }
            }
            str=cptr; // move start of string
            ch++;     // next line
        }
        if (ch!=h) { // some left - output it
            OutCentre(x+(w+1)/2,y+ch,attr,"%-*.*s",w,w,str);
        }
    }
    return ch; // return where we got to
}
//__________________________________________________________________________


//=========================================================================
// End of file (VIDEOKBD.C)
//=========================================================================

