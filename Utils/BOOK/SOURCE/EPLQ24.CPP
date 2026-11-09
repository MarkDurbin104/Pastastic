//--------------------------------------------------------//
//                                                        //
//   File:    EPLQ24.CPP                                  //
//                                                        //
//   Desc:    Driver class for Epson 24-pin LQ and        //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "eplq24.hpp"

static rgb printerpal[] =
{
   rgb(   0,   0,   0 ),
   rgb( 255, 255, 255 )
};

static int nprinterpal = 2;

EpsonLQ24::EpsonLQ24( char *device ) : PrinterDriver( device )
{
   // send reset escape sequence
   if( fptr )
      prtseq( "@" );

   // set features
   feat = fLOWRES | fMEDRES | fHIRES;

   // other initialization
   swath = 0;
   rowmask = 0;

   // set default parameters
   setres( rMEDIUM );
}

EpsonLQ24::~EpsonLQ24( )
{
}

void EpsonLQ24::setres( int r )
{
   switch( r )
   {
      case rLOW :
           res = r;     reschar = 32;
           hdpi = 60;   vdpi = 180;
           maxdots = 480;
           break;
      case rMEDIUM :
           res = r;     reschar = 38;
           hdpi = 90;   vdpi = 180;
           maxdots = 720;
           break;
      case rHIGH :
           res = r;     reschar = 39;
           hdpi = 180;  vdpi = 180;
           maxdots = 1440;
           break;
   }

   // allocate swath buffer
   if( swath ) delete [] swath;
   swath = new long [maxdots];
}

int EpsonLQ24::devcolors( void )
{
   return nprinterpal;
}

rgb * EpsonLQ24::devpalette( void )
{
   return printerpal;
}

int EpsonLQ24::imgprolog( ImageDescriptor& imd )
{
   if( swath == 0 ) return pNOMEMORY;

   // set 24/180 inch line size
   char buf[2];
   buf[0] = '3';
   buf[1] = 24;
   prtseq( buf, 2 );

   // clear swath buffer
   memset( swath, 0, maxdots*sizeof(long) );
   rowmask = 0x800000L;

   // set swath width
   prtdots = (imd.width < maxdots) ?
              imd.width : maxdots;

   return status( );
}

int EpsonLQ24::imgepilog( void )
{
   if( swath == 0 ) return pNOMEMORY;

   // set 30/180 inch line size
   char buf[2];
   buf[0] = '3';
   buf[1] = 30;
   prtseq( buf, 2 );

   // pending partial swath?
   if( rowmask != 0x800000L )
      sendswath();

   return status( );
}

void EpsonLQ24::sendswath( void )
{
   // send swath prefix
   char buf[4];
   buf[0] = '*';
   buf[1] = reschar;
   buf[2] = prtdots & 0xFF;
   buf[3] = (prtdots>>8) & 0xFF;
   prtseq( buf, 4 );

   // send swath
   for( int i=0; i<prtdots; i++ )
   {
      char *p = (char *) & swath[i];
      if( fputc( p[2], fptr ) < 0 ) return;
      if( fputc( p[1], fptr ) < 0 ) return;
      if( fputc( p[0], fptr ) < 0 ) return;
   }

   // send carriage-return line-feed
   fputc( 13, fptr );
   fputc( 10, fptr );
}

int EpsonLQ24::putscanline( unsigned char *pxls, int npxls )
{
   if( swath == 0 ) return pNOMEMORY;

   int n = (npxls < prtdots) ? npxls : prtdots;
   for( int i=0; i<n; i++ )
      if( pxls[i] == 0 )
         swath[i] |= rowmask;

   if( (rowmask >>= 1) == 0 )
   {
      sendswath( );
      memset( swath, 0, maxdots*sizeof(long) );
      rowmask = 0x800000L;
   }

   return status( );
}
