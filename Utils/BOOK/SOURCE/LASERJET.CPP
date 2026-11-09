//--------------------------------------------------------//
//                                                        //
//   File:    LASERJET.CPP                                //
//                                                        //
//   Desc:    Driver class for HP LaserJet and            //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#include "laserjet.hpp"

static rgb printerpal[] =
{
   rgb(   0,   0,   0 ),
   rgb( 255, 255, 255 )
};

static int nprinterpal = 2;

LaserJet::LaserJet( char *device ) : PrinterDriver( device )
{
   // send reset escape sequence
   if( fptr )
      prtseq( "E" );

   // set features
   feat = fLOWRES | fMEDRES | fHIRES | fPOSN;

   // set default parameters
   setres( rMEDIUM );
}

LaserJet::~LaserJet( )
{
}

void LaserJet::setres( int r )
{
   switch( r )
   {
      case rLOW :
           res = r;  hdpi = vdpi = 75;   break;
      case rMEDIUM :
           res = r;  hdpi = vdpi = 150;  break;
      case rHIGH :
           res = r;  hdpi = vdpi = 300;  break;
   }
}

int LaserJet::devcolors( void )
{
   return nprinterpal;
}

rgb * LaserJet::devpalette( void )
{
   return printerpal;
}

int LaserJet::imgprolog( ImageDescriptor& imd )
{
   char buf[16];

   // set image position
   sprintf( buf, "*p%dx%dY", xorg, yorg );
   prtseq( buf );

   // set image resolution
   sprintf( buf, "*t%dR", hdpi );
   prtseq( buf );

   // enter raster graphics mode
   prtseq( "*r1A" );

   return status( );
}

int LaserJet::imgepilog( void )
{
   // exit raster graphics mode
   prtseq( "*rB" );

   return status( );
}

int LaserJet::putscanline( unsigned char *pxls, int npxls )
{
   // send transfer-raster-data sequence
   int nbytes = (npxls + 7) / 8;
   char buf[16];
   sprintf( buf, "*b%dW", nbytes );
   prtseq( buf );

   // send the raster data
   unsigned char byte = 0;
   unsigned char mask = 0x80;
   for( int i=0; i<npxls; i++ )
   {
      if( pxls[i] == 0 )
         byte |= mask;
      if( (mask >>= 1) == 0 )
      {
         if( fputc( byte, fptr ) < 0 )
            return status( );
         byte = 0;
         mask = 0x80;
      }
   }
   if( mask != 0x80 )
      fputc( byte, fptr );

   return status( );

}
