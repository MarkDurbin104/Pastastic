//--------------------------------------------------------//
//                                                        //
//   File:    DISPLAY.HPP                                 //
//                                                        //
//   Desc:    A video display class for handling the      //
//            display of bitmapped images on VGA          //
//            compatible hardware                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _DISPLAY_HPP_
#define _DISPLAY_HPP_

#include "color.hpp"
#include "gffasm.h"

//...............function pointer types

typedef void (*ScanLinePrim) ( unsigned char *,
                               int, int, int );

typedef void (*PalettePrim) ( rgb *, int );

//...............a display mode metric structure

struct ModeMetric
{
   int mode;       // mode for this metric set
   int nrows;      // display height in pixels
   int ncolumns;   // display width in pixels
   int nbits;      // pixel size in bits
   int nplanes;    // number of bit planes
   int ncolors;    // max simultaneous colors
   ModeMetric( )
   {
      mode = nrows = ncolumns = 0;
      nbits = nplanes = ncolors = 0;
   }
   ModeMetric( int m, int nr, int nc,
                int nb, int np, int ns )
   {
      mode = m;  nrows = nr;  ncolumns = nc;
      nbits = nb;  nplanes = np;  ncolors = ns;
   }
  ~ModeMetric( )
   {
   }
};

//...............a display mode driver structure

struct ModeDriver
{
   int mode;              // mode for this driver
   ScanLinePrim putln;    // write a scan line
   ScanLinePrim getln;    // read a scan line
   PalettePrim  putpl;    // set a palette
   PalettePrim  getpl;    // read the palette
   ModeDriver( )
   {
      mode = 0;
      putln = getln = 0;
      putpl = getpl = 0;
   }
   ModeDriver( int m,
               ScanLinePrim pl, ScanLinePrim gl,
               PalettePrim pp, PalettePrim gp )
   {
      mode = m;
      putln = pl;  getln = gl;
      putpl = pp;  getpl = gp;
   }
  ~ModeDriver( )
   {
   }
};

//...............the display class

class VgaDisplay
{
   public:
      int gmode;           // current graphics mode
      int pmode;           // previous mode
      ModeMetric metric;   // current mode's metrics
      ModeDriver driver;   // current mode's driver

      VgaDisplay( int mode=0x12 );
     ~VgaDisplay( );
      void putscanline( unsigned char *pxls, int npxls,
                        int x, int y )
      {
         (*driver.putln)( pxls, npxls, x, y );
      }
      void getscanline( unsigned char *pxls, int npxls,
                        int x, int y )
      {
         (*driver.getln)( pxls, npxls, x, y );
      }
      void putpalette( rgb * pal, int nc = 0 )
      {
         (*driver.putpl)( pal, nc );
      }
      void getpalette( rgb * pal, int nc = 0 )
      {
         (*driver.getpl)( pal, nc );
      }
};

#endif
