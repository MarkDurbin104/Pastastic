//===============|========================================================|
//               |                                                        |
// Module        | VIDEOKBD.H                                             |
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


#ifndef __VIDEOKBD_H // entry sentry
#define __VIDEOKBD_H

void    SetBlinkBit (void);
void    HideCursor  (void);
void    LargeCursor (void);
void    RestCursor  (void);
void    RestFont    (void);
void    LoadFont    (void);
UCHAR * GetFont     (INT type);
INT     GetKey      (void);
void    DrawCBar    (INT x,INT y,INT wid,INT attr);
void    KeyCursor   (INT x,INT y,INT width,INT height,INT flash);
void    Rectangle   (INT x,INT y,INT x1,INT y1,INT colour,INT type);
void    OutChXY     (INT x,INT y,UINT colour,CHAR ch);
void    OutChar     (INT x,INT y,INT colour,CHAR ch);
void    OutFormat   (INT x,INT y,INT colour,CHAR *format,...);
void    SetViewPort (INT minx,INT miny,INT maxx,INT maxy,BOOL attrib);
void    OutCentre   (INT x,INT y,INT attr,CHAR *format,...);
INT     OutWrap     (INT x,INT y,INT w,INT h,INT attr,CHAR *str);

#ifdef __VIDEOKBD_C 
INT G_viewmaxx=80;        // the maximum X extent of the viewport
INT G_viewmaxy=25;        // the maximum Y extent of the viewport
INT G_viewminx=0;         // the minimum X extent of the viewport
INT G_viewminy=0;         // the minimum Y extent of the viewport


UCHAR *G_font;

CHAR G_boxchars[12*16]={
/*¹*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x7C,0xFC,0xFC,0xFC,0xFC,0x7C,0x3C,0x3C,0x3C,0x3C,0x3C,
/*º*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,
/*»*/  0x00,0x00,0x00,0x00,0x00,0x00,0xFC,0xFC,0xFC,0xFC,0x7C,0x3C,0x3C,0x3C,0x3C,0x3C,
/*¼*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x3C,0xFC,0xFC,0xFC,0xFC,0x00,0x00,0x00,0x00,0x00,0x00,

/*È*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x3E,0x3F,0x3F,0x3F,0x3F,0x00,0x00,0x00,0x00,0x00,0x00,
/*É*/  0x00,0x00,0x00,0x00,0x00,0x00,0x3F,0x3F,0x3F,0x3F,0x3E,0x3C,0x3C,0x3C,0x3C,0x3C,
/*Ê*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x7E,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,
/*Ë*/  0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0xFF,0x7E,0x3C,0x3C,0x3C,0x3C,0x3C,
/*Ì*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x3E,0x3F,0x3F,0x3F,0x3F,0x3E,0x3C,0x3C,0x3C,0x3C,0x3C,
/*Í*/  0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,
/*Î*/  0x3C,0x3C,0x3C,0x3C,0x3C,0x7E,0xFF,0xFF,0xFF,0xFF,0x7E,0x3C,0x3C,0x3C,0x3C,0x3C,
/*Ï*/  0xE3,0xE3,0xE3,0xE3,0x22,0x22,0x14,0x08,0x08,0x14,0x22,0x22,0xE3,0xE3,0xE3,0xE3
};

#endif // __VIDEOKBD_C

#endif // __VIDEOKBD_H
