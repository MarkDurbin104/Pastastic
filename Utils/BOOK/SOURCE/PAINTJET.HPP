//--------------------------------------------------------//
//                                                        //
//   File:    PAINTJET.HPP                                //
//                                                        //
//   Desc:    Driver class for HP PaintJet and            //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _PAINTJET_HPP_
#define _PAINTJET_HPP_

#include "printer.hpp"

class PaintJet : public PrinterDriver
{
   private:
      int  sendraster( unsigned char *pxls, int npxls,
                       int mask, int passch );

   public:
      PaintJet( char *device );
     ~PaintJet( );
      virtual void setres( int r );
      virtual rgb *devpalette( void );
      virtual int  devcolors( void );
      virtual int  imgprolog( ImageDescriptor& imd );
      virtual int  putscanline( unsigned char *pxls,
                               int npxls );
      virtual int  imgepilog( void );
};

#endif
