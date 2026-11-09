//--------------------------------------------------------//
//                                                        //
//   File:    PAINTJET.CPP                                //
//                                                        //
//   Desc:    Driver class for HP PaintJet and            //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#include "paintjet.hpp"

extern "C"
{
   int iscale( int, int, int );
}

// palette downloaded to printer
// uses NTSC primary color definitions

static rgb printerpal[] =
{
   rgb(  4,  4,  6 ),
   rgb(  4,  4, 85 ),
   rgb(  4, 88,  6 ),
   rgb(  4, 88, 85 ),
   rgb( 90,  4,  6 ),
   rgb( 90,  4, 85 ),
   rgb( 90, 88,  6 ),
   rgb( 90, 88, 85 )
};

// printer's palette scaled to 0..255
// used for actual dithering

static rgb devicepal[] =
{
   rgb(  10,  10,  15 ),
   rgb(  10,  10, 217 ),
   rgb(  10, 224,  15 ),
   rgb(  10, 224, 217 ),
   rgb( 230,  10,  15 ),
   rgb( 230,  10, 217 ),
   rgb( 230, 224,  15 ),
   rgb( 230, 224, 217 )
};

static int nprinterpal = sizeof(printerpal) / sizeof(rgb);

PaintJet::PaintJet( char *device ) : PrinterDriver( device )
{
   // send reset escape sequence
   if( fptr )
      prtseq( "E" );

   // set features
   feat = fHIRES | fLOWRES | fPOSN | fCOLOR;

   // set default parameters
   setres( rMEDIUM );
}

PaintJet::~PaintJet( )
{
}

void PaintJet::setres( int r )
{
   switch( r )
   {
      case rLOW :
           res = r;  hdpi = vdpi = 90;   break;

      case rMEDIUM :
      case rHIGH :
           res = r;  hdpi = vdpi = 180;  break;
   }
}

int PaintJet::devcolors( void )
{
   return nprinterpal;
}

rgb * PaintJet::devpalette( void )
{
   return devicepal;
}

int PaintJet::imgprolog( ImageDescriptor& imd )
{
   char buf[16];

   // specify 3 color planes
   prtseq( "*r3U" );

   // set printer's RGB palette
   for( int i=0; i<nprinterpal; i++ )
   {
      sprintf( buf, "*v%da%db%dc%dI",
               printerpal[i].red,
               printerpal[i].grn,
               printerpal[i].blu,
               i );
      prtseq( buf );
   }

   // set image position in decipoints
   int x = iscale( xorg, 720, hdpi );
   int y = iscale( yorg, 720, vdpi );
   sprintf( buf, "&a%dh%dV", x, y );
   prtseq( buf );

   // set image resolution
   sprintf( buf, "*t%dR", hdpi );
   prtseq( buf );

   // set image width
   sprintf( buf, "*r%dS", imd.width+xorg );
   prtseq( buf );

   // enter raster graphics mode
   prtseq( "*r1A" );

   return status( );
}

int PaintJet::imgepilog( void )
{
   // exit raster graphics mode
   prtseq( "*rB" );

   return status( );
}

int  PaintJet::sendraster( unsigned char *pxls, int npxls,
                           int mask, int passch )
{
   int nbytes = (npxls + 7) / 8;
   char buf[16];
   sprintf( buf, "*b%d%c", nbytes, passch );
   prtseq( buf );

   unsigned char byte = 0;
   unsigned char bit  = 0x80;
   for( int i=0; i<npxls; i++ )
   {
      if( pxls[i] & mask )
         byte |= bit;
      if( (bit >>= 1) == 0 )
      {
         if( fputc( byte, fptr ) < 0 )
            return status( );
         bit = 0x80;
         byte = 0;
      }
   }
   if( bit != 0x80 )
      fputc( byte, fptr );
   return status( );
}

int PaintJet::putscanline( unsigned char *pxls, int npxls )
{
   if( sendraster( pxls, npxls, 0x01, 'V' ) == pOKAY )
      if( sendraster( pxls, npxls, 0x02, 'V' ) == pOKAY )
         sendraster( pxls, npxls, 0x04, 'W' );

   return status( );
}
