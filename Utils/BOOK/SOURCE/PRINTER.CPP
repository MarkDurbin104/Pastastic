//--------------------------------------------------------//
//                                                        //
//   File:    PRINTER.CPP                                 //
//                                                        //
//   Desc:    Base class for printer driver classes       //
//                                                        //
//--------------------------------------------------------//

#include "string.h"

#include "printer.hpp"

extern "C"
{
   void setbinary( int );
}

//..................class PrinterDriver

PrinterDriver::PrinterDriver( char *device )
{
   fptr = fopen( device, "wb" );
   if( fptr ) setbinary( fileno(fptr) );
   hdpi = vdpi = 0;
   xorg = yorg = 0;
   feat = 0;
   pal = 0;
   res = 0;
   nclrs = 0;
}

PrinterDriver::~PrinterDriver( )
{
   if( fptr ) fclose( fptr );
}

int PrinterDriver::status( )
{
   if( fptr == 0 ) return pNOPORT;
   if( ferror(fptr) ) return pIOERROR;
   return pOKAY;
}

void PrinterDriver::setres( int r )
{
   res = r;
}

void PrinterDriver::setorg( int xo, int yo )
{
   xorg = xo;
   yorg = yo;
}

int PrinterDriver::prtseq( char *seq, int len )
{
   // write escape character to printer
   fputc( 27, fptr );
   // len=0 implies use string length
   int n = (len < 1) ? strlen(seq) : len;
   fwrite( seq, n, 1, fptr );
   fflush( fptr );
   return status();
}

int PrinterDriver::prttext( char *text, int len )
{
   // len=0 implies use string length
   int n = (len < 1) ? strlen(text) : len;
   fwrite( text, n, 1, fptr );
   fflush( fptr );
   return status();
}

int PrinterDriver::prtline( char *text, int len )
{
   // len=0 implies use string length
   int n = (len < 1) ? strlen(text) : len;
   fwrite( text, n, 1, fptr );
   // send carriage-return line-feed
   fputc( 13, fptr );
   fputc( 10, fptr );
   fflush( fptr );
   return status();
}

int PrinterDriver::eject( void )
{
   // write formfeed char to printer
   fputc( 12, fptr );
   fflush( fptr );
   return status();
}
