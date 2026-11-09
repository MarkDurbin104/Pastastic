/****************************************************************************
* Project     : GPA
* File        : gprim.h
* Description : graphics primitives support
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:56  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/gprim.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:56   JGRAY
 *  
* 
****************************************************************************/
#ifndef GPRIM_H
#define GPRIM_H


#ifdef GPRIM_C
#define PUBLIC 
#else
#define PUBLIC extern
#endif

typedef struct tagBITMAPFILEHEADER { /* bmfh */
    UINT    bfType;
    ULONG   bfSize;
    UINT    bfReserved1;
    UINT    bfReserved2;
    ULONG   bfOffBits;
} BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER {    /* bmih */
    ULONG   biSize;
    LONG    biWidth;
    LONG    biHeight;
    UINT    biPlanes;
    UINT    biBitCount;
    ULONG   biCompression;
    ULONG   biSizeImage;
    LONG    biXPelsPerMeter;
    LONG    biYPelsPerMeter;
    ULONG   biClrUsed;
    ULONG   biClrImportant;
} BITMAPINFOHEADER;

typedef struct {
    BITMAPFILEHEADER    bmfh;
    BITMAPINFOHEADER    bmih;
} BMPH;

//typedef struct {
//    UINT  name;     // file header
//    ULONG sizi;
//    UINT  res[2];
//    ULONG ofs;
//    ULONG sizx;     // file info
//             LONG wid;
//             LONG hgt;
//    UINT  nump;
//    UINT  bcnt;
//    ULONG cflg;
//    ULONG size;
//             LONG hres;
//             LONG vres;
//    ULONG cusd;
//    ULONG cimp;
//} BMPH;

typedef struct {
    CHAR name[40];
    INT w;
    INT h;
    LONG ofs;
    INT del;
    INT x;
    INT y;
    INT ln;
    INT sz;
    INT st;
    UCHAR type;
    INT bw;
    CHAR huge *buf;
} IMAGE;

#define NORM_WM 0
#define AND_WM  1
#define OR_WM   2
#define XOR_WM  3

#define BITMASK(a) OUTPB(0x3CE,8); OUTPB(0x3CF,a)
#define MAPMASK(a) OUTPB(0x3C4,2); OUTPB(0x3C5,a)
#define ESETRES(a) OUTPB(0x3CE,1); OUTPB(0x3CF,a)
#define SETRES(a)  OUTPB(0x3CE,0); OUTPB(0x3CF,a)
#define SETMODE(a) OUTPB(0x3CE,5); OUTPB(0x3CF,a)
    
PUBLIC INT      grafix(INT type);
PUBLIC void     usegdev(INT idx);
PUBLIC void     closegraf(void);
PUBLIC void     cls(void);
PUBLIC void     flipscr(void);
PUBLIC void     dontdraw(INT v);
PUBLIC void     line(INT x1,INT y1,INT x2,INT y2);
PUBLIC void     rectangle(INT x1,INT y1,INT x2,INT y2);
PUBLIC void     bar(INT x,INT y,INT x1,INT y1);
PUBLIC void     setcol(UCHAR c);
PUBLIC void     moveto(INT x,INT y);
PUBLIC void     lineto(INT x,INT y);
PUBLIC void     moverel(INT dx,INT dy);
PUBLIC void     linerel(INT dx,INT dy);
PUBLIC void     poly(INT np,INT *p);
PUBLIC void     movpoly(INT x,INT y,INT np,INT *p);
PUBLIC void     magpoly(INT x,INT y,INT xm,INT ym,INT np,INT *p);
PUBLIC void     plot(INT x,INT y);
PUBLIC void     circle(INT xc,INT yc,INT rad);
PUBLIC void     prln(INT x,INT y,CHAR *fmt, ... );
PUBLIC void     printg(CHAR *fmt, ... );
PUBLIC void     setfont(UCHAR *f,UCHAR *w,UCHAR bw,UCHAR ph,UCHAR fh,UCHAR fix);
PUBLIC UCHAR huge *loadffont(CHAR *fontfile);
PUBLIC UCHAR huge *loadfont(CHAR *fname);
PUBLIC INT      attachfont(UCHAR huge *f,UCHAR type,UCHAR h,UCHAR w);
PUBLIC void     selectfont(UINT idx);
PUBLIC INT      savefont(CHAR *fname,UCHAR *f);
PUBLIC void     setwmode(UCHAR m);
PUBLIC void     setmag(UCHAR m);
PUBLIC void     setpalette(UCHAR col,UCHAR attr);
PUBLIC void     setrgbpalette(INT  c,UCHAR r,UCHAR g,UCHAR b);
PUBLIC void     getrgbpalette(INT  c,UCHAR *r,UCHAR *g,UCHAR *b);
PUBLIC void     setborder(UCHAR attr);
PUBLIC LONG     getbmpsiz(CHAR *name);
PUBLIC IMAGE *  getbmp(CHAR *name);
PUBLIC INT      savebmp(CHAR *name);
PUBLIC void     putimage(INT x,INT y,IMAGE *img);
PUBLIC void     freeimg(IMAGE *img);
PUBLIC void     button(INT x,INT y,INT x1,INT y1,INT t,INT up,CHAR *c,INT split);
PUBLIC void     bmpbutt(INT x,INT y,IMAGE *img,INT t,INT up);
PUBLIC void     bezel(INT x,INT y,INT x1,INT y1,INT depth);
PUBLIC void     rotimage(INT x,INT y,INT size,INT step,INT del,IMAGE *img);
PUBLIC void     delfromanim(CHAR *name);
PUBLIC void     animimage(INT x,INT y,INT size,INT del,IMAGE *img);
PUBLIC void     flipimages(INT x,INT y,INT del,IMAGE *img,IMAGE *img2);
PUBLIC UCHAR huge *loadlfont(CHAR *name,INT type);
PUBLIC INT      restart(INT idx);
PUBLIC void     monomode(void);
PUBLIC void     tinyxy(INT c,INT x,INT y,CHAR *fmt,...);
PUBLIC void     scrprint(INT type,CHAR *name);
PUBLIC void     savescrn(INT swapcols);
PUBLIC CHAR     **saveregion(INT bx,INT y,INT bw,INT h);
PUBLIC void     restregion(INT bx,INT y,INT bw,INT h,CHAR **b);

#ifdef GPRIM_C

#define WRITEPLANE(a) OUTPW(0x3C4,(UINT16)((0x100<<(a))|2));
#define READPLANE(a)  OUTPW(0x3CE,(UINT16)(((a)<<8)|4));

                        
UCHAR col[32] ={
   2 ,4 ,7, 6 ,1 ,5 ,3 ,8 ,0 ,12,10,14, 9,13,11,15,                        
   1 ,2 ,0, 6 ,8 ,10,12,4 ,14,3 ,5 , 7, 9,11,13,15 };
// 0  1  2  3  4  5  6  7  8  9     10    11 12 13 14 15

UCHAR pcx_header[128]= {
    0x0A, 0x05, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
    0x7F, 0x02, 0xDF, 0x01, 0x96, 0x00, 0x96, 0x00,
    0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x50, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

UCHAR G_obmph[0x76]={
0x42,0x4D,0x76,0x58,0x02,0x00,0x00,0x00,0x00,0x00,0x76,0x00,0x00,0x00,0x28,0x00,
0x00,0x00,0x80,0x02,0x00,0x00,0xE0,0x01,0x00,0x00,0x01,0x00,0x04,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,
//blue green red  res            
  0x00,0x00,0x00,0x00,  //     0  black
  0x00,0x00,0x80,0x00,  //     1    d red
  0x00,0x80,0x00,0x00,  //     2    d green
  0x00,0x80,0x80,0x00,  //     3    d yellow
  0x80,0x00,0x00,0x00,  //     4    d blue    
  0x80,0x00,0x80,0x00,  //     5    d magenta
  0x80,0x80,0x00,0x00,  //     6    d cyan
  0x80,0x80,0x80,0x00,  //     7    d grey
  0xC0,0xC0,0xC0,0x00,  //     8    grey
  0x00,0x00,0xFF,0x00,  //     9    red
  0x00,0xFF,0x00,0x00,  //    10    green
  0x00,0xFF,0xFF,0x00,  //    11    yellow
  0xFF,0x00,0x00,0x00,  //    12    blue
  0xFF,0x00,0xFF,0x00,  //    13    magenta
  0xFF,0xFF,0x00,0x00,  //    14    cyan    
  0xFF,0xFF,0xFF,0x00   //    15    white
};

INT   G_col;
INT   G_lx;
INT   G_ly;
UINT  G_fhgt;
UINT  G_bwid;
UINT  G_phgt;
UINT  G_mag;
UINT  G_fixwid;
UCHAR *G_fwid;
UCHAR *font;
UCHAR 
G_wmode;

void p8(INT x,INT y,INT xo,INT yo);
void outbyte(UCHAR *sadd,INT x,UCHAR *f,UCHAR nl,UCHAR nfl,UCHAR nfc,UCHAR c);
INT  outstr(INT x,INT y,UCHAR *s);
void magbyte(UCHAR *d,UCHAR *s,INT mag,INT hgt,INT wid);
void magchar(UCHAR *d,UCHAR *s,INT mag,INT hgt,INT wid);
void yline(INT x,INT y,INT deltax,INT deltay,INT o);
void xline(INT x,INT y,INT deltax,INT deltay,INT o);
void setfgcol(void);
void setbgcol(void);
void outln(INT x,INT y,INT w,UCHAR *buf,INT newbmp);
void mov4(UCHAR *d,UCHAR *s);
void reorg(UCHAR *d,UCHAR *s,INT w);

#endif

#endif

// **************************************************************************
// gprim.h <end-of-file>

