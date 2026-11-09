//--------------------------------------------------------//
//                                                        //
//   File:    LASERJET.HPP                                //
//                                                        //
//   Desc:    Driver class for HP LaserJet and            //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _LASERJET_HPP_
#define _LASERJET_HPP_

#include "printer.hpp"

class LaserJet : public PrinterDriver
{
   public:
      LaserJet( char *device );
     ~LaserJet( );
      virtual void setres( int r );
      virtual rgb *devpalette( void );
      virtual int  devcolors( void );
      virtual int  imgprolog( ImageDescriptor& imd );
      virtual int  putscanline( unsigned char *pxls,
                               int npxls );
      virtual int  imgepilog( void );
};

#endif
