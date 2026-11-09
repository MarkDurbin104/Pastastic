//--------------------------------------------------------//
//                                                        //
//   File:    PRINTER.HPP                                 //
//                                                        //
//   Desc:    Base class for printer driver classes       //
//                                                        //
//--------------------------------------------------------//

#ifndef _PRINTER_HPP_
#define _PRINTER_HPP_

#include "stdio.h"

#include "color.hpp"

enum PrinterResolutions
{
   rLOW,
   rMEDIUM,
   rHIGH
};

enum PrinterConditions
{
   pOKAY,
   pNOMEMORY,
   pNOPORT,
   pIOERROR
};

enum PrinterFeatures
{
   fLOWRES = 1,
   fMEDRES = 2,
   fHIRES  = 4,
   fPOSN   = 8,
   fCOLOR  = 16
};

//..................Structure to hold image metrics

struct ImageDescriptor
{
   int width;     // width in pixels
   int height;    // height in pixels
   int depth;     // bits per pixel
   int xres;      // horz dots per inch
   int yres;      // vert dots per inch

   ImageDescriptor( )
   {
      width = height = depth = 0;
      xres = yres = 0;
   }
   ImageDescriptor( int w, int h, int d )
   {
      width = w;  height = h;  depth = d;
      xres = yres = 0;
   }
   ImageDescriptor( int w, int h, int d, int x, int y )
   {
      width = w;  height = h;  depth = d;
      xres  = x;  yres = y;
   }
  ~ImageDescriptor( )
   {
   }
};

//..................A printer driver base class

class PrinterDriver
{
   protected:
      FILE   * fptr;     // printer stream
      int      feat;     // printer features
      int      res;      // resolution
      int      hdpi;     // horz resolution
      int      vdpi;     // vert resolution
      int      xorg;     // x origin in res units
      int      yorg;     // y origin in res units
      rgb    * pal;      // device palette
      int      nclrs;    // number of palette colors

   public:
      PrinterDriver( char *device );
     ~PrinterDriver( );
      int status( void );
      int features( void ) { return feat; }
      int xres( void )     { return hdpi; }
      int yres( void )     { return vdpi; }
      virtual rgb *devpalette( void ) = 0;
      virtual int  devcolors( void ) = 0;
      virtual void setorg( int xo, int yo );
      virtual void setres( int r );
      virtual int  prtseq( char *seq, int len=0 );
      virtual int  prttext( char *text, int len=0 );
      virtual int  prtline( char *text, int len=0 );
      virtual int  eject( void );
      virtual int  imgprolog( ImageDescriptor& imd ) = 0;
      virtual int  putscanline( unsigned char *pxls,
                                int npxls ) = 0;
      virtual int  imgepilog( void ) = 0;
};

#endif
