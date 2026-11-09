//--------------------------------------------------------//
//                                                        //
//   File:   XBM.HPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for dealing  //
//           with an X Windows bitmap file                //
//                                                        //
//--------------------------------------------------------//

#ifndef _XBM_HPP_
#define _XBM_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "ctype.h"

#include "codec.hpp"

//..................token handling primitives

int iswhite( int ch );
int tokencnt( char *s );
int token( char *src, char *dst, int which );

//..................class TKNFILE

class TKNFILE
{
   protected:
      FILE   * fin;     // input file
      char   * ln;      // line buffer
      char   * tok;     // extracted token buffer
      int      maxch;   // size of buffers
      int      curtk;   // current token number
      int      cond;    // condition code

   public:
      TKNFILE( char *path );
     ~TKNFILE( );
      int    status( void );
      char * get( void );
};

//..................struct XBMNAMES

#define NAMECNT 5

enum XbmNames
{
   xWidth,
   xHeight,
   xXHot,
   xYHot,
   xBits
};

struct XBMNAMES
{
   char *names[NAMECNT];

   XBMNAMES( char *prefix );
  ~XBMNAMES( );
   int which( char *tok );
};

//..................struct XBMHEADER

struct XBMHEADER
{
   int   width;
   int   height;
   int   xhot;
   int   yhot;
   char *name;

   XBMHEADER( char *n )
   {
      width = height = 0;
      xhot = yhot = -1;
      name = 0;
      name = new char [strlen(n)+1];
      if( name )
         strcpy( name, n );
   }
   XBMHEADER( int w, int h, char *n )
   {
      width = w;
      height = h;
      xhot = yhot = -1;
      name = new char [strlen(n)+1];
      if( name )
         strcpy( name, n );
   }
  ~XBMHEADER( )
   {
      delete name;
   }
   void list( void );
   int  get( TKNFILE *tf );
   int  put( FILE *f );
};

//..................class  XbmEncoder

class XbmDecoder : public Decoder
{
   protected:
      TKNFILE *xbm_file;    // input file
      int      cond;        // condition code

   public:
      XbmDecoder( TKNFILE *f_in );
      virtual ~XbmDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//..................class  XbmEncoder

class XbmEncoder : public Encoder
{
   protected:
      FILE *xbm_file;      // output file
      int   cond;          // condition code
      int   cnt;           // bytes written

   public:
      XbmEncoder( FILE *f_out );
      virtual ~XbmEncoder( ) { }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
