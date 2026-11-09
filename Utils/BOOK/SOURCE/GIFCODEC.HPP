//--------------------------------------------------------//
//                                                        //
//   File:   GIFCODEC.HPP                                 //
//                                                        //
//   Desc:   Structure and Class definitions for          //
//           a GIF Coder and Decoder.                     //
//                                                        //
//--------------------------------------------------------//

#ifndef _GIFCODEC_HPP_
#define _GIFCODEC_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "ctype.h"
#include "iostream.h"

#include "codec.hpp"
#include "color.hpp"

//..................class BitString

#define MAXDIGITS ( (sizeof(int) * 8) + 1 )

class BitString
{
   protected :

      char str[MAXDIGITS];

   public :

      BitString( int bits, int width );
     ~BitString( ) { }
      char *rep( void ) { return str; }
};

inline ostream& operator << ( ostream& os, BitString& bs )
{
   return os << bs.rep();
}

//..................class iCodeStream

class iCodeStream
{
   protected :

      FILE *        ifile;          // input file
      unsigned char buffer[255];    // data buffer
      int           nbytes;         // bytes in buffer
      int           curbyte;        // index of current byte
      int           nbits;          // current element width
      int           bytecode;       // last byte read
      int           bytemask;       // mask for bytecode
      int           bitcode;        // last bit code read
      int           bitmask;        // mask for bitcode

   private :

      int  getbyte( void );

   public :

      iCodeStream( FILE *f, int size );
      virtual ~iCodeStream( );
      int getcode( void );
      int lastcode( void )
      {
         return bitcode;
      }
      int width( void )
      {
         return nbits;
      }
      int width( int nb )
      {
        nbits = nb;
        return nbits;
      }
};

//..................class GifDecoder

class GifDecoder : public Decoder, public iCodeStream
{
   protected:
      int  cond;      // condition code
      int  nroots;    // 1 << pixelsize
      int  capacity;  // 1 << 12
      int  rwbytes;   // bytes per scan line

      int  minsize;   // code sizes
      int  cursize;
      int  maxsize;
      int  curcode;   // code values
      int  maxcode;

      int  newc;       // new code
      int  oldc;       // old code
      int  clrc;       // clear code
      int  endc;       // end code
      int  stkp;       // stack pointer

      int *           prefix;
      unsigned char * suffix;
      unsigned char * stack;
      unsigned char * bytes;

   private:
      void clear( void );
      int  push( int s );

   public:
      GifDecoder( FILE* infile, int cobits, int pxcnt );
     ~GifDecoder( );
      virtual int init( void );
      virtual int term( void );
      virtual int decode( unsigned char *line, int size );
      virtual int status( void );
};

//..................class oCodeStream

class oCodeStream
{
   protected :

      FILE *        ofile;          // output file
      unsigned char buffer[255];    // data buffer
      int           nbytes;         // bytes in buffer
      int           nbits;          // current element width
      int           bytecode;       // current output byte
      int           bytemask;       // mask for bytecode

   private :

      int putbyte( int byt );

   public :

      oCodeStream( FILE *f, int size );
      virtual ~oCodeStream( );
      int putcode( int code );
      int flush( void );
      int width( void )
      {
         return nbits;
      }
      int width( int nb )
      {
        nbits = nb;
        return nbits;
      }
};

//..................class GifEncoder

class GifEncoder : public Encoder, public oCodeStream
{
   protected :
      int  cond;      // condition code
      int  started;   // semiphore flag
      int  nroots;    // 1 << pixelsize
      int  capacity;  // prime > (1<<12)

      int  minsize;   // code sizes
      int  cursize;
      int  maxsize;
      int  curcode;   // code values
      int  maxcode;

      int  strc;       // "string"
      int  chrc;       // "character"
      int  clrc;       // clear code
      int  endc;       // end code

      int * codes;
      int * prefix;
      int * suffix;

   private:
      void clear( void );
      int findstr( int pfx, int sfx );

   public:
      GifEncoder( FILE* outfile, int cobits );
     ~GifEncoder( );
      virtual int init( void );
      virtual int term( void );
      virtual int encode( unsigned char *line, int size );
      virtual int status( void );
};

#endif
