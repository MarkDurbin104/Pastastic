//--------------------------------------------------------//
//                                                        //
//   File:    TGA.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            TARGA Format                                //
//                                                        //
//--------------------------------------------------------//

#ifndef _TGA_HPP_
#define _TGA_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"

struct TGAHEADER
{
   unsigned char  idlen;      // ID field length
   unsigned char  cmtype;     // color map type
   unsigned char  imtype;     // image type
   unsigned short cmorg;      // index of first cm entry
   unsigned short cmcnt;      // number of cm entries
   unsigned char  cmsiz;      // bits per cm entry
   unsigned short imxorg;     // image x origin
   unsigned short imyorg;     // image y origin
   unsigned short imwidth;    // image width in pixels
   unsigned short imheight;   // image height in pixels
   unsigned char  imdepth;    // bits per pixel
   unsigned char  imdesc;     // image descriptor

   TGAHEADER( );
   TGAHEADER( int w, int h, int d );
  ~TGAHEADER( ) { }
   void list( void );
   int  get( FILE * f );
   int  put( FILE * f );
   rgb *pal( FILE *f );
   int  isvertmirror( void )
   {
      return (imdesc & 0x20) ? 0 : 1;
   }
   int  ishorzmirror( void )
   {
      return (imdesc & 0x10) ? 1 : 0;
   }
};

//.............class TgaDecoder

class TgaDecoder : public Decoder
{
   protected:
      FILE *tga_file;       // input file
      int   cond;           // condition code
      int   width;          // image width in pixels
      int   height;         // image height in pixels
      int   pxbits;         // bits per pixel - 8,16,24,32
      int   pxbytes;        // bytes per pixel - 1,2,3,4
      int   mapped;         // color mapped flag
      int   encoded;        // rle flag
      int   mirrored;       // horz mirror flag

   private:
      void readmapped( unsigned char *buf, int npxls );
      void readrlemapped( unsigned char *buf, int npxls );
      void readrgb( unsigned char *buf, int npxls );
      void readrlergb( unsigned char *buf, int npxls );
      void reverse1( unsigned char *buf, int npxls );
      void reverse3( unsigned char *buf, int npxls );

   public:
      TgaDecoder( FILE *f_in, TGAHEADER& hdr );
      virtual ~TgaDecoder( );
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//.............class TgaEncoder

class TgaEncoder : public Encoder
{
   protected:
      int   cond;          // condition code
      int   pxl_bytes;     // bytes per pixel - 1 or 3
      FILE *tga_file;      // output file

   private:
      unsigned char *scanln;

   public:
      TgaEncoder( FILE *f_out, TGAHEADER& tga );
      virtual ~TgaEncoder( ) { delete scanln; }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
