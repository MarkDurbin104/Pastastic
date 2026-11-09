//--------------------------------------------------------//
//                                                        //
//   File:    PSCRIPT.HPP                                 //
//                                                        //
//   Desc:    Driver class for PostScript Level 1 and     //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _PSCRIPT_HPP_
#define _PSCRIPT_HPP_

#include "printer.hpp"

class PsPrinter : public PrinterDriver
{
   private:
      int vardef( char *name, int value );

   public:
      PsPrinter( char *device );
     ~PsPrinter( );
      virtual void setres( int r );
      virtual rgb *devpalette( void );
      virtual int  devcolors( void );
      virtual int  imgprolog( ImageDescriptor& imd );
      virtual int  putscanline( unsigned char *pxls,
                               int npxls );
      virtual int  imgepilog( void );
      virtual int  eject( void );
};

#endif
