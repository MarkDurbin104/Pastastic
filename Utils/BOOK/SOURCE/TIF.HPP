//--------------------------------------------------------//
//                                                        //
//   File:   TIF.HPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for the      //
//           Tagged Image File Format Revision 6.0        //
//                                                        //
//--------------------------------------------------------//

#ifndef _TIF_HPP_
#define _TIF_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "ctype.h"

#include "gffasm.h"
#include "codec.hpp"
#include "color.hpp"

//..................various constants

#define  IntelORDER   0x4949
#define  MotorORDER   0x4D4D
#define  TIFFIDEN     42

// define for system being used
#define  NativeORDER  IntelORDER

enum TiffDataTypes
{
    tNone,          // unspecified
    tUByte,         // 8-bit unsigned
    tAscii,         // Null terminated string
    tUShort,        // 16-bit unsigned
    tULong,         // 32-bit unsigned
    tURational,     // 32-bit unsigned x 2
    tSByte,         // 8-bit signed
    tByte,          // 8-bit undefined
    tSShort,        // 16-bit signed
    tSLong,         // 32-bit signed
    tSRational,     // 32-bit signed x 2
    tFloat,         // 4-byte IEEE
    tDouble         // 8-byte IEEE
};

enum TiffCompressionTypes
{
   cNone,
   cUncompressed,
   cCCITT1d,
   cGroup3Fax,
   cGroup4Fax,
   cLZW,
   cJPEG,
   cPackBits = 32773u
};

enum TiffImageTypes
{
   iBlackOnWhite,
   iWhiteOnBlack,
   iRGB,
   iColorMapped,
   iTransparency,
   iCMYK,
   iYCbCr,
   iCIELab
};

//..................nonmember functions

char *TiffTagName( int tag );
char *TiffDataTypeName( int type );
int   TiffDataTypeSize( int type );
char *TiffCompressionName( int type );
char *TiffPhotometricName( int type );
char *TiffResolutionName( int type );
char *TiffPlanarName( int type );
int   ReverseByteOrder( void );

//..................struct TIFFHEADER

struct TIFFHEADER
{
   unsigned short order;   // byte order Intel or Motorola
   unsigned short iden;    // magic number identifier (42)
   unsigned long  ifdofs;  // offset to first IFD

   TIFFHEADER( )
   {
      order  = IntelORDER;
      iden   = TIFFIDEN;
      ifdofs = 0;
   }
   TIFFHEADER( unsigned short ord, unsigned long iofs )
   {
      order  = ord;
      iden   = TIFFIDEN;
      ifdofs = iofs;
   }
  ~TIFFHEADER( )
   {
   }
   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );
   int  isvalid( void );
};

//..................struct IFD

struct IFDENTRY
{
   unsigned short tag;     // tag identifier
   unsigned short type;    // data type
   unsigned long  count;   // number of type values
   unsigned long  valofs;  // offset to value

   IFDENTRY( )
   {
      tag = type = 0;
      count = valofs = 0;
   }
   IFDENTRY( unsigned short t, unsigned short typ,
             unsigned long cnt, unsigned long vofs )
   {
      tag    = t;
      type   = typ;
      count  = cnt;
      valofs = vofs;
   }
  ~IFDENTRY( )
   {
   }

   void list( void );
   int  get( FILE *f );
   int  put( FILE *f );

   // some convenient type conversions
   int cnt( void ) { return int(count); }
   int val( void ) { return int(valofs); }
   unsigned int ucnt( void ) { return (unsigned int) count; }
   unsigned int uval( void ) { return (unsigned int) valofs; }
};

//..................struct TIFFIMAGEDEF

struct TIFFIMAGEDEF
{
   unsigned short imgtype;     // image type              *
   unsigned short cmptype;     // compression type        *
   unsigned short width;       // width in pixels         *
   unsigned short height;      // height in pixels        *
   unsigned short depth;       // depth in bits
   unsigned short bitsamp;     // bits per sample         *
   unsigned short samppix;     // samples per pixel       *
   unsigned short planar;      // planar configuration    *
   unsigned short orient;      // orientation             *
   unsigned short hmirror;     // horz mirrored
   unsigned short vmirror;     // vert mirrored
   unsigned short rotate;      // rotated (landscape)
   unsigned short resunit;     // resolution units        *
   unsigned short xres;        // x resolution            *
   unsigned short yres;        // y resolution            *
   unsigned short nstrips;     // strips in image
   unsigned short striphgt;    // strip hgt in rows       *
   unsigned short ncolors;     // color count in pal
   rgb         *  colors;      // color map               *
   long        *  stripofs;    // array of strip offsets  *

   TIFFIMAGEDEF( );
  ~TIFFIMAGEDEF( );
   void list( void );
   int  get( FILE *f );
};

#endif
