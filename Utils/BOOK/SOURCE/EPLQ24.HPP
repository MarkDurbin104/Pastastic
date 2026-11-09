//--------------------------------------------------------//
//                                                        //
//   File:    EPLQ24.HPP                                  //
//                                                        //
//   Desc:    Driver class for Epson 24-pin LQ and        //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _EPLQ24_HPP_
#define _EPLQ24_HPP_

#include "printer.hpp"

class EpsonLQ24 : public PrinterDriver
{
   private :
      int   reschar;     // resolution character
      int   maxdots;     // max dots per line
      int   prtdots;     // printed dots per line
      long  rowmask;     // current row mask
      long *swath;       // swath buffer
      void  sendswath( void );

   public:
      EpsonLQ24( char *device );
     ~EpsonLQ24( );
      virtual rgb *devpalette( void );
      virtual int  devcolors( void );
      virtual void setres( int r );
      virtual int  imgprolog( ImageDescriptor& imd );
      virtual int  putscanline( unsigned char *pxls,
                                int npxls );
      virtual int  imgepilog( void );
};

#endif
