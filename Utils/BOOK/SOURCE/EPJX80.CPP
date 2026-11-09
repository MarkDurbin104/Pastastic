//--------------------------------------------------------//
//                                                        //
//   File:    EPJX80.CPP                                  //
//                                                        //
//   Desc:    Driver class for Epson JX-80 color dot      //
//            matrix and compatible printers              //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "epjx80.hpp"

// Ribbon color RGBs based upon standardized NTSC RGB
// color definitions.  An index into this palette can
// be used as a mask for determining which ribbon(s)
// are required to produce the color.  The lower 4 bits
// of the index are interpreted as follows:
//         3      2     1     0
//       Black  Blue   Red  Yellow

static rgb printerpal[] =
{
   rgb( 255, 255, 255 ),   // white
   rgb( 252, 240,  23 ),   // yellow
   rgb( 145,  12,  26 ),   // red
   rgb( 202, 112,  23 ),   // orange
   rgb(   0,   0,  74 ),   // blue
   rgb(   0,  67,  52 ),   // green
   rgb(  24,   6,  58 ),   // violet
   rgb(  24,  12,  13 ),   // brown
   rgb(   0,   0,   0 )    // black
};

static int nprinterpal =  sizeof(printerpal) / sizeof(rgb);

EpsonJX80::EpsonJX80( char *device ) : PrinterDriver( device )
{
   // send reset escape sequence
   if( fptr )
      prtseq( "@" );

   // set features
   feat = fLOWRES | fMEDRES | fHIRES | fCOLOR;

   // other initialization
   rowmask = 0x80;
   Yel = Red = Blu = Blk = 0;

   // set default parameters
   setres( rMEDIUM );
}

EpsonJX80::~EpsonJX80( )
{
   if( Yel )
      delete [] Yel;
}

int EpsonJX80::devcolors( void )
{
   return nprinterpal;
}

rgb * EpsonJX80::devpalette( void )
{
   return printerpal;
}

void EpsonJX80::setres( int r )
{
   switch( r )
   {
      case rLOW :
           res = r;     reschar = 'K';
           hdpi = 60;   vdpi = 72;
           maxdots = 480;
           break;
      case rMEDIUM :
           res = r;     reschar = 'L';
           hdpi = 120;  vdpi = 72;
           maxdots = 960;
           break;
      case rHIGH :
           res = r;     reschar = 'Z';
           hdpi = 240;  vdpi = 72;
           maxdots = 1920;
           break;
   }

   // allocate swath buffers
   if( Yel )
   {
      delete [] Yel;
      Yel = Red = Blu = Blk = 0;
   }
   Yel = new unsigned char [maxdots * 4];
   if( Yel )
   {
      Red = Yel + maxdots;
      Blu = Red + maxdots;
      Blk = Blu + maxdots;
   }
}

void EpsonJX80::sendswath( void )
{
   char buf[4];
   buf[0] = reschar;
   buf[1] = prtdots & 0xFF;
   buf[2] = (prtdots>>8) & 0xFF;

   // yellow pass
   prtseq( "r\x04", 2 );
   prtseq( buf, 3 );
   for( int i=0; i<prtdots; i++ )
      if( fputc( Yel[i], fptr ) < 0 )
         return;
   fputc( 13, fptr );

   // red pass
   prtseq( "r\x01", 2 );
   prtseq( buf, 3 );
   for( i=0; i<prtdots; i++ )
      if( fputc( Red[i], fptr ) < 0 )
         return;
   fputc( 13, fptr );

   // blue pass
   prtseq( "r\x02", 2 );
   prtseq( buf, 3 );
   for( i=0; i<prtdots; i++ )
      if( fputc( Blu[i], fptr ) < 0 )
         return;
   fputc( 13, fptr );

   // black pass
   prtseq( "r\x00", 2 );
   prtseq( buf, 3 );
   for( i=0; i<prtdots; i++ )
      if( fputc( Blk[i], fptr ) < 0 )
         return;
   fputc( 13, fptr );

   fputc( 10, fptr );
}

int EpsonJX80::imgprolog( ImageDescriptor& imd )
{
   if( Yel == 0 ) return pNOMEMORY;

   // set graphics line spacing
   prtseq( "A\x08", 2 );

   // clear swath buffer
   memset( Yel, 0, maxdots*4 );
   rowmask = 0x80;

   // set swath width
   prtdots = (imd.width < maxdots) ?
              imd.width : maxdots;

   return status( );
}

int EpsonJX80::imgepilog( void )
{
   if( Yel == 0 ) return pNOMEMORY;

   // partial swath pending?
   if( rowmask != 0x80 )
      sendswath( );

   // set text line spacing
   prtseq( "2" );

   return status( );
}

int EpsonJX80::putscanline( unsigned char *pxls, int npxls )
{
   if( Yel == 0 ) return pNOMEMORY;

   int n = (npxls < prtdots) ? npxls : prtdots;
   for( int i=0; i<n; i++ )
   {
      if( pxls[i] & 1 ) Yel[i] |= rowmask;
      if( pxls[i] & 2 ) Red[i] |= rowmask;
      if( pxls[i] & 4 ) Blu[i] |= rowmask;
      if( pxls[i] & 8 ) Blk[i] |= rowmask;
   }

   if( (rowmask >>= 1) == 0 )
   {
      sendswath( );
      memset( Yel, 0, maxdots*4 );
      rowmask = 0x80;
   }

   return status( );
}
