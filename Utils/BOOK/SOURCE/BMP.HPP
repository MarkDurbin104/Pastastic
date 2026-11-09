//--------------------------------------------------------//
//                                                        //
//   File:    BMP.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Windows BMP format - DOS version            //
//                                                        //
//--------------------------------------------------------//

// Note: This file duplicates structure and member names
//       from windows.h, so it cannot be used in a wn app.

#ifdef WINVER
#error Use WBMP.HPP for Windows - BMP.HPP is for DOS
#endif

#ifndef _BMP_HPP_
#define _BMP_HPP_

#include "color.hpp"
#include "codec.hpp"

//..................File signature

#define BMP_SIGNATURE_WORD 0x4D42

//..................Bitmap compression schemes

enum BiCompressionMethods
{
   xBI_NONE = 0,
   xBI_RGB  = 0,
   xBI_RLE4 = 2,
   xBI_RLE8 = 1
};

//..................xBITMAPFILEHEADER

struct xBITMAPFILEHEADER
{
   unsigned short bfType;        // signature - 'BM'
   unsigned long  bfSize;        // file size in bytes
   unsigned short bfReserved1;   // 0
   unsigned short bfReserved2;   // 0
   unsigned long  bfOffBits;     // offset to bitmap
   xBITMAPFILEHEADER( )
   {
      bfType = BMP_SIGNATURE_WORD;
      bfSize = bfOffBits = 0;
      bfReserved1 = bfReserved2 = 0;
   }
   void list( void );
};

//.............xRGBTRIPLE, xBITMAPCOREHEADER, xBITMAPCOREINFO

struct xRGBTRIPLE
{
   unsigned char rgbBlue;    // 0..255
   unsigned char rgbGreen;   // 0..255
   unsigned char rgbRed;     // 0..255
   xRGBTRIPLE( )
   {
      rgbBlue = rgbGreen = rgbRed = 0;
   }
   xRGBTRIPLE( int r, int g, int b )
   {
      rgbBlue  = b;
      rgbGreen = g;
      rgbRed   = r;
   }
   void set( int r, int g, int b )
   {
      rgbBlue  = b;
      rgbGreen = g;
      rgbRed   = r;
   }
   void list( int index );
};

struct xBITMAPCOREHEADER
{
   unsigned long  bcSize;      // size of this struct
   short          bcWidth;     // bitmap width in pixels
   short          bcHeight;    // bitmap height in pixels
   unsigned short bcPlanes;    // num planes - always 1
   unsigned short bcBitCount;  // bits per pixel
   xBITMAPCOREHEADER( )
   {
      bcSize = sizeof(xBITMAPCOREHEADER);
      bcWidth = bcHeight = 0;
      bcPlanes = 1;
      bcBitCount = 0;
   }
   void list( void );
};

struct xBITMAPCOREINFO
{
   xBITMAPCOREHEADER bmciHeader;
   xRGBTRIPLE        bmciColors[1];
};

//.............xRGBQUAD, xBITMAPINFOHEADER, xBITMAPIFO

struct xRGBQUAD
{
   unsigned char rgbBlue;       // 0..255
   unsigned char rgbGreen;      // 0..255
   unsigned char rgbRed;        // 0..255
   unsigned char rgbReserved;   // 0
   xRGBQUAD( )
   {
      rgbBlue = rgbGreen = rgbRed = 0;
      rgbReserved = 0;
   }
   xRGBQUAD( int r, int g, int b )
   {
      rgbBlue  = b;
      rgbGreen = g;
      rgbRed   = r;
      rgbReserved = 0;
   }
   void set( int r, int g, int b )
   {
      rgbBlue  = b;
      rgbGreen = g;
      rgbRed   = r;
   }
   void list( int index );
};

struct xBITMAPINFOHEADER
{
   unsigned long  biSize;          // size of this struct
   long           biWidth;         // bmap width in pixels
   long           biHeight;        // bmap height in pixels
   unsigned short biPlanes;        // num planes - always 1
   unsigned short biBitCount;      // bits per pixel
   unsigned long  biCompression;   // compression flag
   unsigned long  biSizeImage;     // image size in bytes
   long           biXPelsPerMeter; // horz resolution
   long           biYPelsPerMeter; // vert resolution
   unsigned long  biClrUsed;       // 0 -> color table size
   unsigned long  biClrImportant;  // important color count
   xBITMAPINFOHEADER( )
   {
      biSize = sizeof(xBITMAPINFOHEADER);
      biWidth = biHeight = 0;
      biPlanes = 1;
      biBitCount = 0;
      biCompression = biSizeImage = 0;
      biXPelsPerMeter = biYPelsPerMeter = 0;
      biClrUsed = biClrImportant = 0;
   }
   void list( void );
};

struct xBITMAPINFO
{
   xBITMAPINFOHEADER  bmiHeader;
   xRGBQUAD           bmiColors[1];
};

//.............class BmpDecoder

class BmpDecoder : public Decoder
{
   public:
      int cond;           // condition code

   protected:
      int   rle_method;   // RLE compression method
      int   pxl_size;     // bits per pixel
      FILE *bmp_file;     // input file

   private:
      void read_none( unsigned char *buf, int npxls );
      void read_rle4( unsigned char *buf, int npxls );
      void read_rle8( unsigned char *buf, int npxls );

   public:
      BmpDecoder( FILE *f_in, int rle, int nbits );
     ~BmpDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//.............class BmpEncoder

class BmpEncoder : public Encoder
{
   protected:
      int   pxl_size;     // bits per pixel
      FILE *bmp_file;     // output file

   private:
      void wrt_line( unsigned char *buf, int npxls );

   public:
      BmpEncoder( FILE *f_out, int nbits );
     ~BmpEncoder( ) { }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
