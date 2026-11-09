//--------------------------------------------------------//
//                                                        //
//   File:   TIFCODEC.HPP                                 //
//                                                        //
//   Desc:   TIFF Encoder and Decoder classes for         //
//           Tagged Image File Format Revision 6.0        //
//                                                        //
//--------------------------------------------------------//

#ifndef _TIFCODEC_HPP_
#define _TIFCODEC_HPP_

#include "tif.hpp"
#include "revbyte.hpp"

//..................Scan Line I/O Functions

typedef int (*SCANIO)( FILE *, unsigned char *, int );

int ReadG3( FILE *fi, unsigned char *buf, int nbytes );
int ReadPB( FILE *fi, unsigned char *buf, int nbytes );
int ReadNC( FILE *fi, unsigned char *buf, int nbytes );

int WriteG3( FILE *fo, unsigned char *buf, int nbytes );
int WritePB( FILE *fo, unsigned char *buf, int nbytes );
int WriteNC( FILE *fo, unsigned char *buf, int nbytes );

//..................Class TiffDecoder

class TiffDecoder : public Decoder
{
   protected:
      FILE           *ftif;
      SCANIO          read;
      TIFFIMAGEDEF   *idef;
      unsigned char  *ibuf;
      unsigned short  rwbytes;
      int             curline;
      int             curstrip;
      int             cond;

   private:
      void unpack( unsigned char *buf, int npxls );

   public:
      TiffDecoder( FILE *fi, TIFFIMAGEDEF *tid );
      virtual ~TiffDecoder( );
      virtual int init( void );
      virtual int term( void );
      virtual int decode( unsigned char *buf, int npxls );
      virtual int status( void );
};

//..................Class TiffEncoder

class TiffEncoder : public Encoder
{
   protected:
      FILE           *ftif;
      SCANIO          write;
      TIFFIMAGEDEF   *idef;
      unsigned char  *ibuf;
      unsigned short  rwbytes;
      int             cond;

   private:
      void pack( unsigned char *buf, int npxls );

   public:
      TiffEncoder( FILE *fo, TIFFIMAGEDEF *tid );
      virtual ~TiffEncoder( );
      virtual int init( void );
      virtual int term( void );
      virtual int encode( unsigned char *buf, int npxls );
      virtual int status( void );
};

#endif
