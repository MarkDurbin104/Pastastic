//--------------------------------------------------------//
//                                                        //
//   File:    PSCRIPT.CPP                                 //
//                                                        //
//   Desc:    Driver class for PostScript Level 1 and     //
//            compatible printers                         //
//                                                        //
//--------------------------------------------------------//

#include "pscript.hpp"

extern "C"
{
   int iscale( int, int, int );
}

//..................device palette

static rgb printerpal[] =
{
   rgb(   0,   0,   0 ),
   rgb( 255, 255, 255 )
};

static int nprinterpal = 2;

//..................PostScript code

static char *prologbody[] =
{
   "/scanline nbytes string def",
   "gsave",
   "xorg 756 yorg sub ysiz sub translate",
   "xsiz ysiz scale",
   "width height depth",
   "[ width 0 0 height neg 0 height ]",
   "{ currentfile scanline readhexstring pop }",
   "image"
};

static int nprologbody = sizeof(prologbody) / sizeof(char *);

static char *prologhdr[] =
{
   "%..........Begin Image.........."
};

static int nprologhdr = sizeof(prologhdr) / sizeof(char *);

static char *epiloghdr[] =
{
   "grestore",
   "%..........End Image.........."
};

static int nepiloghdr = sizeof(epiloghdr) / sizeof(char *);

//..................class PsPrinter

PsPrinter::PsPrinter( char *device ) : PrinterDriver( device )
{
   // various initialization
   setres( rMEDIUM );

   // PostScript job header
   prtline( "\x04%!PS-Adobe-2.0" );
   prtline( "%%Title: Graphics File Programming in C++" );
   prtline( "%%Creator: Class PsPrinter" );
}

PsPrinter::~PsPrinter( )
{
   prtline( "\x04" );
}

void PsPrinter::setres( int r )
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

int PsPrinter::devcolors( void )
{
   return nprinterpal;
}

rgb * PsPrinter::devpalette( void )
{
   return printerpal;
}

int PsPrinter::eject( void )
{
   prtline( "showpage" );

   return status( );
}

int PsPrinter::vardef( char *name, int value )
{
   char buf[80];
   sprintf( buf, "/%s %d def", name, value );
   prtline( buf );
   return status( );
}

int PsPrinter::imgprolog( ImageDescriptor& imd )
{
   // print prolog header
   for( int i=0; i<nprologhdr; i++ )
      if( prtline( prologhdr[i] ) != pOKAY )
         return status( );

   // print variable definitions
   if( vardef( "width", imd.width )
       != pOKAY ) return status( );
   if( vardef( "height", imd.height )
       != pOKAY ) return status( );
   if( vardef( "depth", 1 )
       != pOKAY ) return status( );
   if( vardef( "nbytes", (imd.width+7)/8 )
       != pOKAY ) return status( );
   if( vardef( "xorg", iscale(xorg,72,hdpi) )
       != pOKAY ) return status( );
   if( vardef( "yorg", iscale(yorg,72,vdpi) )
       != pOKAY ) return status( );
   if( vardef( "xsiz", iscale(imd.width,72,hdpi) )
       != pOKAY ) return status( );
   if( vardef( "ysiz", iscale(imd.height,72,vdpi) )
       != pOKAY ) return status( );

   // print prolog body
   for( i=0; i<nprologbody; i++ )
      if( prtline( prologbody[i] ) != pOKAY )
         return status( );

   return status( );
}

int PsPrinter::imgepilog( void )
{
   // print epilog header
   for( int i=0; i<nepiloghdr; i++ )
      if( prtline( epiloghdr[i] ) != pOKAY )
         return status( );

   return status( );
}

int PsPrinter::putscanline( unsigned char *pxls, int npxls )
{
   unsigned char byte = 0;
   unsigned char mask = 0x80;
   for( int i=0; i<npxls; i++ )
   {
      if( pxls[i] == 0 )
         byte |= mask;
      if( (mask >>= 1) == 0 )
      {
         byte ^= 255;
         fprintf( fptr, "%02X", byte );
         if( status( ) != pOKAY ) return status( );
         if( (i%320) == 0 ) fprintf( fptr, "\n" );
         byte = 0;
         mask = 0x80;
      }
   }

   if( mask != 0x80 )
   {
      byte ^= 255;
      fprintf( fptr, "%02X", byte );
   }
   fprintf( fptr, "\n" );

   return status( );

}
