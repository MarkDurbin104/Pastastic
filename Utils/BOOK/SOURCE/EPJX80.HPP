//--------------------------------------------------------//
//                                                        //
//   File:    EPJX80.HPP                                  //
//                                                        //
//   Desc:    Driver class for Epson JX-80 and            //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _EPJX80_HPP_
#define _EPJX80_HPP_

#include "printer.hpp"

class EpsonJX80 : public PrinterDriver
{
   private:
      int reschar;         // resolution character
      int maxdots;         // max dots per line
      int prtdots;         // printed dots per line
      int rowmask;         // current row mask
      unsigned char *Yel;  // swath pointers
      unsigned char *Red;
      unsigned char *Blu;
      unsigned char *Blk;
      void sendswath( void );

   public:
      EpsonJX80( char *device );
     ~EpsonJX80( );
      virtual rgb *devpalette( void );
      virtual int  devcolors( void );
      virtual void setres( int r );
      virtual int  imgprolog( ImageDescriptor& imd );
      virtual int  putscanline( unsigned char *pxls,
                                int npxls );
      virtual int  imgepilog( void );
};

#endif
