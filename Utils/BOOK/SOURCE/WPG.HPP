//--------------------------------------------------------//
//                                                        //
//   File:    WPG.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            WordPerfect Graphics File Format            //
//                                                        //
//--------------------------------------------------------//

#ifndef _WPG_HPP_
#define _WPG_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"

//.............record types and characteristics

enum WpgRecordTypes
{
   wpgFirst,
   wpgFillAttr,
   wpgLineAttr,
   wpgMarkerAttr,
   wpgPolyMarker,
   wpgLine,
   wpgPolyLine,
   wpgRectangle,
   wpgPolygon,
   wpgEllipse,
   wpgCurve,
   wpgBitmap,
   wpgText,
   wpgTextAttr,
   wpgColorMap,
   wpgBegin,
   wpgEnd,
   wpgPostScript,
   wpgOutputAttr,
   wpgLast,
};

//.............misc nonmember functions

RgbPalette * WpgPalette( void );
RgbPalette * WpgPalette( FILE *f );

//.............struct WPGHEADER

struct WPGHEADER
{
   char  fileid[4];   // the bytes 0xFF, W, P, C
   long  dataofs;     // offset to start of data
   char  prodtype;    // product type = 1
   char  filetype;    // file type = 22
   char  majver;      // major version number
   char  minver;      // minor version number
   int   enckey;      // encryption key
   int   resv;        // reserved

   WPGHEADER( ) { }
   WPGHEADER( int ftype );
  ~WPGHEADER( ) { }
   int  get( FILE *f );
   int  put( FILE *f );
   int  validate( void );
   void list( void );
};

//.............struct WPGTAG

struct WPGTAG
{
   char rectype;      // record type identifier
   long reclength;    // length of record following

   WPGTAG( ) { rectype=0; reclength=0; }
   WPGTAG( char rt, long rl ) { rectype=rt; reclength=rl; }
  ~WPGTAG( ) { }
   int get( FILE *f );
   int put( FILE *f, int lenbytes );
   void list( void );
};

//.............struct WPGBEGIN

struct WPGBEGIN
{
   char  version;    // WPG version number
   char  flags;      // various flags
   int   imwidth;    // image space width in wpu
   int   imheight;   // image space height in wpu

   WPGBEGIN( )
   {
      version = 1;
      flags = 0;
      imwidth = imheight = 0;
   }
   WPGBEGIN( int w, int h )
   {
      version = 1;
      flags = 0;
      imwidth = w;
      imheight = h;
   }
  ~WPGBEGIN( )
   {
   }
   int get( FILE *f );
   int put( FILE *f );
};

//.............struct WPGBMHEADER

struct WPGBMHEADER
{
   int bmwidth;    // width in pixels
   int bmheight;   // height in pixels
   int bmdepth;    // pixel size in bits
   int bmxres;     // x res as pixels/inch
   int bmyres;     // y res as pixels/inch

   WPGBMHEADER( )
   {
      bmwidth = bmheight = bmdepth = bmxres = bmyres = 0;
   }
   WPGBMHEADER( int w, int h, int d )
   {
      bmwidth  = w;
      bmheight = h;
      bmdepth  = d;
      bmxres = bmyres = 75;
   }
  ~WPGBMHEADER( )
   {
   }
   int get( FILE *f );
   int put( FILE *f );
   void list( void );
};

//.............class WpgDecoder

class WpgDecoder : public Decoder
{
   protected:
      FILE *wpg_file;       // output file
      int   cond;           // condition code
      int   pxbits;         // bits per pixel - 1,2,4,8
      int   width;          // image width in pixels
      int   height;         // image height in pixels

   private:
      int count;            // repeats of current scan line
      int pxmask;           // masks 1 pixel's width
      unsigned char *pxls;  // pixel buffer
      int readline( void );
      int putpixel( int pxbyte, int curpx );

   public:
      WpgDecoder( FILE *f_in, int nbits, int w, int h );
      virtual ~WpgDecoder( );
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//.............class WpgEncoder

class WpgEncoder : public Encoder
{
   protected:
      int   cond;          // condition code
      int   pxl_bits;      // bits per pixel
      int   row_bytes;     // bytes per row
      FILE *wpg_file;      // output file

   private:
      char *scanbuffer;    // output buffer
      int   scanmask;      // output bit mask
      int   scanbyte;      // output byte pointer
      void  initbuffer( void );
      void  putbits( int bits, int nbits );
      void  putbyte( int byte );
      int   flush( void );
      void  write_124( unsigned char *buf, int npxls );
      void  write_8( unsigned char *buf, int npxls );

   public:
      WpgEncoder( FILE *f_out, WPGBMHEADER& wpg );
      virtual ~WpgEncoder( )
      {
         if( scanbuffer )
            delete scanbuffer;
      }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
