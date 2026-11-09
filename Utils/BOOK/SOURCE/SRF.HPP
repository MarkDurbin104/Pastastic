//--------------------------------------------------------//
//                                                        //
//   File:    SRF.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            SUN Raster File format                      //
//                                                        //
//--------------------------------------------------------//

#ifndef _SRF_HPP_
#define _SRF_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"
#include "gffasm.h"

#define  RF_IDEN    0x59A66A95L
#define  RUN_FLAG   0x80

enum SrfImageTypes
{
   imOld  = 0,      // uncompressed
   imStd  = 1,      // same as 0
   imRle  = 2,      // RLE encoded
   imRgb  = 3,      // RGBs
   imTiff = 4,      // TIFF compatible
   imIff  = 5,      // TAAC compatible
   imExp = 0xFFFF   // experimental
};

enum SrfMapTypes
{
   mapNone = 0,     // no color map present
   mapRgb  = 1,     // RGB color map
   mapRaw  = 2      // nonstandard
};

//..................struct SRFHEADER

struct SRFHEADER        // SRF == Sun Raster File
{
   long   iden;         // rf identifier
   long   imwidth;      // width of image in pixels
   long   imheight;     // height of image in pixels
   long   imdepth;      // bits per pixel - 1, 8, 24
   long   imlength;     // length of image in bytes
   long   imtype;       // image type
   long   maptype;      // colormap type
   long   maplength;    // colormap length in bytes

   SRFHEADER( );
   SRFHEADER( int w, int h, int d );
  ~SRFHEADER( ) { }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
   RgbPalette * pal( FILE *f );
};

//..................class  SrfDecoder

class SrfDecoder : public Decoder
{
   protected:
      FILE *srf_file;       // input file
      int   cond;           // condition code
      int   rwbytes;        // image width in bytes
      int   pxbits;         // bits per pixel - 1,8,24
      int   pxbytes;        // bytes per pixel - 1,3
      int   encoded;        // flag - RLE or uncompressed

   private:
      int   cnt;
      int   dat;
      int   read_byte( void );
      void  read1( unsigned char *buf, int npxls );
      void  read8( unsigned char *buf, int npxls );
      void  read24( unsigned char *buf, int npxls );

   public:
      SrfDecoder( FILE *f_in, SRFHEADER& hdr );
      virtual ~SrfDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//..................class  SrfEncoder

class SrfEncoder : public Encoder
{
   protected:
      int   cond;          // condition code
      int   pxbits;        // bits per pixel - 1,8,24
      int   pxbytes;       // bytes per pixel - 1 or 3
      int   rwbytes;       // image width in bytes
      int   encoded;       // flag - set for RLE output
      FILE *srf_file;      // output file

   private:
      unsigned char *scanln;
      void flush( void );
      void wrt1( unsigned char *buf, int npxls );
      void wrt8( unsigned char *buf, int npxls );
      void wrt24( unsigned char *buf, int npxls );

   public:
      SrfEncoder( FILE *f_out, SRFHEADER& hdr );
      virtual ~SrfEncoder( ) { delete scanln; }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
