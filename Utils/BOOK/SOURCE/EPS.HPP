//--------------------------------------------------------//
//                                                        //
//   File:    EPS.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Encapsulated PostScript format              //
//                                                        //
//--------------------------------------------------------//

#ifndef _EPS_HPP_
#define _EPS_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"
#include "dither.hpp"

//..................struct EPSPROLOG

struct EPSPROLOG
{
   char *title;
   char *creator;
   int   llx;
   int   lly;
   int   urx;
   int   ury;

   EPSPROLOG( )
   {
      title = creator = 0;
      llx = lly = urx = ury = 0;
   }
   EPSPROLOG( char *t, char *c, int x1, int y1,
                 int x2, int y2 )
   {
      title = t;
      creator = c;
      llx = x1;
      lly = y1;
      urx = x2;
      ury = y2;
   }
  ~EPSPROLOG( )
   {
   }
   int put( FILE *f );
};

//..................struct EPSEPILOG

struct EPSEPILOG
{
   int x;   // dummy variable

   EPSEPILOG( )
   {
      x = 0;
   }
  ~EPSEPILOG( )
   {
   }
   int put( FILE *f );
};

//..................struct IMGPROLOG

struct IMGPROLOG
{
   int width;
   int height;
   int depth;
   int xorg;
   int yorg;

   IMGPROLOG( )
   {
      width = height = depth = 0;
      xorg = yorg = 0;
   }
   IMGPROLOG( int w, int h, int d, int xo, int yo )
   {
      width  = w;
      height = h;
      depth  = d;
      xorg   = xo;
      yorg   = yo;
   }
  ~IMGPROLOG( )
   {
   }
   int put( FILE *f );
};

//..................struct IMGEPILOG

struct IMGEPILOG
{
   int x;   // dummy variable

   IMGEPILOG( )
   {
      x = 0;
   }
  ~IMGEPILOG( )
   {
   }
   int put( FILE *f );
};

//..................class  EpsEncoder

class EpsEncoder : public Encoder
{
   protected:
      int              cond;        // condition code
      int              width;       // image width
      FILE            *eps_file;    // output file
      int              nout;        // bytes written
      rgb             *impal;       // image palette
      unsigned char   *scanln;      // scanline buffer
      DiffusionDither *dit;         // dither

   private:
      void writeln( void );

   public:
      EpsEncoder( FILE *f_out, int w, rgb *pal );
      virtual ~EpsEncoder( );
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
