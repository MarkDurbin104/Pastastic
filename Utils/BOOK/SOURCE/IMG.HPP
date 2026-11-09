//--------------------------------------------------------//
//                                                        //
//   File:    IMG.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            GEM IMG format                              //
//                                                        //
//--------------------------------------------------------//

#ifndef _IMG_HPP_
#define _IMG_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"

//.............struct IMGHEADER

struct IMGHEADER
{
   unsigned int version;    // version number
   unsigned int hdrsize;    // size of header in words
   unsigned int nplanes;    // planes in image
   unsigned int patbytes;   // length of pattern in bytes
   unsigned int pxlwidth;   // pixel size in microns
   unsigned int pxlheight;  // pixel size in microns
   unsigned int scanwidth;  // image width in pixels
   unsigned int scancount;  // encoded scan line count

   void swap( void );
   void list( void );
};

//.............class ImgDecoder

class ImgDecoder : public Decoder
{
   protected:
      int   cond;         // condition code
      int   img_planes;   // image planes
      int   img_width;    // image width
      int   img_height;   // image height
      int   row_bytes;    // bytes per plane per row
      FILE *img_file;     // output file

   private:
      int repeatcnt;  // cur scan line repeat count
      int scancnt;    // scan item count from header

      unsigned char *scanline;  // cur scan line buffer
      int curpxl;               // index into scanline

      unsigned char *pattern;  // pattern buffer
      int patlen;              // size of pattern;

      int  readcnt( void );
      int  imagehgt( void );
      void putbyte( int byte, int plmask );
      void readplane( int plmask );
      void readline( void );
      void skipline( void );

   public:
      ImgDecoder( FILE *f_in, IMGHEADER& img );
      virtual ~ImgDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
      int width( void )  { return img_width; }
      int height( void ) { return img_height; }
      int depth( void )  { return img_planes; }
};

#endif
