//--------------------------------------------------------//
//                                                        //
//   File:   GIF.HPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for          //
//           CompuServe's GIF Format, Version 89a         //
//                                                        //
//--------------------------------------------------------//

#ifndef _GIF_HPP_
#define _GIF_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "ctype.h"
#include "iostream.h"

#include "codec.hpp"
#include "color.hpp"

//..................struct GIFHEADER

struct GIFHEADER             // GIF File Header
{
   char sig[3];              // "GIF"
   char ver[3];              // "87a" or "89a"
   GIFHEADER( )
   {
      sig[0] = 'G';
      sig[1] = 'I';
      sig[2] = 'F';
      ver[0] = '8';
      ver[1] = '9';
      ver[2] = 'a';
   }
  ~GIFHEADER( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
   int  isvalid( void );
};

//..................struct GIFSCDESC

#define scdGCT       0x80    // global color table
#define scdGCTCRES   0x70    // color res : nbits-1
#define scdGCTSORT   0x08    // sort flag
#define scdGCTSIZE   0x07    // color cnt as 2^(sss+1)

struct GIFSCDESC             // Screen Descriptor
{
   unsigned short scwidth;   // width in pixels
   unsigned short scheight;  // height in pixels
   unsigned char  flags;     // various flags
   unsigned char  bgclr;     // background color
   unsigned char  pixasp;    // pixel aspect ratio
   GIFSCDESC( )
   {
      scwidth = scheight = 0;
      flags = bgclr = pixasp = 0;
   }
   GIFSCDESC( int w, int h, int d )
   {
      scwidth  = w;
      scheight = h;
      flags = scdGCT | ((d-1)<<4) | (d-1);
      bgclr = pixasp = 0;
   }
  ~GIFSCDESC( )
   {
   }
   void list( void );
   int get( FILE *f );
   int put( FILE *f );
   int isgct( void )
   {
      return (flags & scdGCT) ? 1 : 0;
   }
   int issorted( void )
   {
      return (flags & scdGCTSORT) ? 1 : 0;
   }
   int depth( void )    // bits per pixel
   {
      return ((flags & scdGCTCRES) >> 4) + 1;
   }
   int ncolors( void )  // # entries in GCT
   {
      return 1 << ((flags & scdGCTSIZE) + 1);
   }
};

//..................struct GIFIMDESC

#define imdLCT       0x80    // local color table
#define imdINTRLACE  0x40    // interlace flag
#define imdLCTSORT   0x20    // sort flag
#define imdRESV      0x18    // reserved
#define imdLCTSIZE   0x07    // color cnt as 2^(sss+1)

struct GIFIMDESC             // Image Descriptor
{
   unsigned char  id;        // 0x2C
   unsigned short xleft;     // x origin
   unsigned short ytop;      // y origin
   unsigned short imwidth;   // image width
   unsigned short imheight;  // image height
   unsigned char  flags;     // various flags
   GIFIMDESC( )
   {
      id = 0x2C;
      xleft = ytop = 0;
      imwidth = imheight = 0;
      flags = 0;
   }
   GIFIMDESC( int w, int h, int d )
   {
      id = 0x2C;
      xleft = ytop = 0;
      imwidth = w;
      imheight = h;
      flags = 0;
   }
  ~GIFIMDESC( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
   int islct( void )
   {
      return (flags & imdLCT) ? 1 : 0;
   }
   int issorted( void )
   {
      return (flags & imdLCTSORT) ? 1 : 0;
   }
   int isinterlaced( void )
   {
      return (flags & imdINTRLACE) ? 1 : 0;
   }
   int ncolors( void )  // # entries in LCT
   {
      if( islct() )
         return 1 << ((flags & imdLCTSIZE) + 1);
      return 0;
   }
};

//..................struct GIFCTLEXT

#define ctlRESV      0xE0    // reserved
#define ctlDISPOSE   0x1C    // disposal method
#define ctlINPUT     0x02    // user input flag
#define ctlTRANSPAR  0x01    // transparency flag

struct GIFCTLEXT             // Control Extension
{
   unsigned char  id;        // 0x21 - extension
   unsigned char  label;     // 0xF9 - extension type
   unsigned char  size;      // always 4
   unsigned char  flags;     // various flags
   unsigned short delay;     // 1/100th seconds
   unsigned char  trclr;     // transparency color
   GIFCTLEXT( )
   {
      id = 0x21;
      label = 0xF9;
      flags = trclr = 0;
      delay = 0;
   }
  ~GIFCTLEXT( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
};

//..................struct GIFCOMEXT

struct GIFCOMEXT             // Comment Extension
{
   unsigned char  id;        // 0x21 - extension
   unsigned char  label;     // 0xFE - extension type
   GIFCOMEXT( )
   {
      id = 0x21;
      label = 0xFE;
   }
  ~GIFCOMEXT( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
};

//..................struct GIFTXTEXT

struct GIFTXTEXT             // Text Extension
{
   unsigned char  id;        // 0x21 - extension
   unsigned char  label;     // 0x01 - extension type
   unsigned char  size;      // always 12
   unsigned short xleft;     // x origin
   unsigned short ytop;      // y origin
   unsigned short txwidth;   // text width
   unsigned short txheight;  // text height
   unsigned char  cewidth;   // cell width
   unsigned char  ceheight;  // cell height
   unsigned char  fgclr;     // foreground color
   unsigned char  bgclr;     // background color
   GIFTXTEXT( )
   {
      id = 0x21;
      label = 0x01;
      size = 12;
      xleft = ytop = 0;
      txwidth = txheight = 0;
      cewidth = ceheight = 0;
      fgclr = bgclr = 0;
   }
  ~GIFTXTEXT( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
};

//..................struct GIFAPPEXT

struct GIFAPPEXT              // Application Extension
{
   unsigned char  id;         // 0x21 - extension
   unsigned char  label;      // 0xFF - extension type
   unsigned char  size;       // always 11
   char           apname[8];  // application name
   char           apcode[3];  // application code
   GIFAPPEXT( )
   {
      id = 0x21;
      label = 0xFF;
      size = 11;
      memset( apname, 0, 8 );
      memset( apcode, 0, 3 );
   }
  ~GIFAPPEXT( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
};

#endif
