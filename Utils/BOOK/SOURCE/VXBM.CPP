//--------------------------------------------------------//
//                                                        //
//   File:    VXBM.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a XBM file.        //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "xbm.hpp"
#include "imgviewr.hpp"
#include "imgprntr.hpp"
#include "laserjet.hpp"
#include "paintjet.hpp"
#include "epjx80.hpp"
#include "eplq24.hpp"
#include "pscript.hpp"

//..................Printer types

#define  LJ  0x4C4A
#define  PJ  0x504A
#define  JX  0x4A58
#define  LQ  0x4C51
#define  PS  0x5053

//..................Program globals

char      fn[80],       // path to XBM file
          name[40];     // XBM var root

int       gmode,        // video display mode
          pmode;        // printer ID

ImgStore   *imgmap;     // image bitmap

rgb pal[] =
{
   rgb( 0, 0, 0 ),
   rgb( 0, 0, 0 ),
   rgb( 255, 255, 255 )
};

//..................Exit with a message

void exit_pgm( char *msg )
{
   printf( "%s\n", msg );
   exit( 0 );
}

//..................Program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "...........X Window Bitmap Viewer/Printer...........\n" );
   printf( "\n" );
   printf( "Usage:      VXBM  xbm_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h      = display program usage\n" );
   printf( "           -vXX    = force video display mode XX\n" );
   printf( "                     (XX = 12, 13, 2E, 62)\n" );
   printf( "           -pXX    = print using printer XX\n" );
   printf( "                     (XX = LJ, PJ, JX, LQ, PS)\n" );
   printf( "           -fR,G,B = set foreground color to (R,G,B)\n" );
   printf( "           -bR,G,B = set foreground color to (R,G,B)\n" );
   printf( "           -nXXX   = use root name XXX\n" );
   printf( "\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0]   = 0;
   name[0] = 0;
   gmode   = 0x12;
   pmode   = 0;

   // process the program's argument list
   int   r, g, b;
   char *p;
   for( int i=1; i<argc; i++ )
   {
      if( (*argv[i] == '-') || (*argv[i] == '/') )
      {
         char sw = *(argv[i] + 1);
         switch( toupper(sw) )
         {
            case 'H' :
               explain_pgm();
               exit( 0 );
               break;

            case 'V' :
               sscanf( argv[i]+2, "%x", &gmode );
               break;

            case 'N' :
               strcpy( name, argv[i]+2 );
               break;

            case 'P' :
               pmode = toupper( *(argv[i]+2) );
               pmode <<= 8;
               pmode += toupper( *(argv[i]+3) );
               break;

            case 'B' :
               p = argv[i] + 2;
               sscanf( p, "%d,%d,%d", &r, &g, &b );
               pal[1] = rgb( r, g, b );
               break;

            case 'F' :
               p = argv[i] + 2;
               sscanf( p, "%d,%d,%d", &r, &g, &b );
               pal[2] = rgb( r, g, b );
               break;

            default:
               printf( "Unknown switch '%s' ignored\n",
                        argv[i] );
               break;
         }
      }
      else  // presumably a file identifier
      {
         strcpy( fn, argv[i] );
      }
   }

   // was a file name specified?
   if( fn[0] == 0 )
   {
      explain_pgm();
      exit( 0 );
   }
}

//..................Create an image storage buffer

ImgStore * istore( int h, int w, int d )
{
   ImgStore *ist = 0;

   // attempt to create in order of preference
   ist = new XmsImgStore( h, w, d );
   if( (ist != 0) && (ist->status != imgstoreOKAY) )
   {
      delete ist;
      ist = new EmsImgStore( h, w, d );
      if( (ist != 0) && (ist->status != imgstoreOKAY) )
      {
         delete ist;
         ist = new CnvImgStore( h, w, d );
         if( (ist != 0) && (ist->status != imgstoreOKAY) )
         {
            delete ist;
            ist = new DskImgStore( h, w, d );
            if( (ist != 0) && (ist->status != imgstoreOKAY) )
            {
               delete ist;
               ist = 0;
            }
         }
      }
   }

   return ist;
}

//..................Create a printer

PrinterDriver * printer( int which )
{
   PrinterDriver *p;

   switch( which )
   {
      case LJ : p = new LaserJet( "LPT1" );
                break;
      case PJ : p = new PaintJet( "LPT1" );
                break;
      case JX : p = new EpsonJX80( "LPT1" );
                break;
      case LQ : p = new EpsonLQ24( "LPT1" );
                break;
      default : p = new PsPrinter( "LPT1" );
                break;
   }

   return p;
}

//..................Load the XBM file

void load_xbm( void )
{
   // open file
   TKNFILE fxbm( fn );
   if( fxbm.status() != xOKAY )
      exit_pgm( "X Bitmap File file not found" );

   // extract bitmap name prefix from file name
   if( name[0] == 0 )
   {
      int n = strlen( fn ) - 1;
      while( n > 0 )
      {
         if( fn[n] == '.' ) fn[n] = 0;
         if( fn[n] == '\\' ) break;
         n--;
      }
      if( fn[n] == '\\' ) n++;
      strcpy( name, fn+n );
   }

   // read header
   XBMHEADER xbm( name );
   if( xbm.get( &fxbm ) != xOKAY )
      exit_pgm( "Error reading X Bitmap header" );

   // create bitmap
   unsigned char *scanln = new unsigned char [xbm.width];
   imgmap = istore( xbm.height, xbm.width, 8 );
   if( (imgmap == 0) || (scanln == 0) )
   {
      delete imgmap;
      delete scanln;
      exit_pgm( "Insufficient memory to load image" );
   }

   // load bitmap
   printf( "Loading XBM image from '%s'...", fn );
   XbmDecoder xbmd( &fxbm );
   xbmd.init();
   memset( scanln, 0, xbm.width );
   for( int i=0; i<xbm.height; i++ )
   {
      if( xbmd.decode( scanln, xbm.width ) != xOKAY )
         break;
      // convert 0-or-1 to 1-or-2
      for( int j=0; j<xbm.width; j++ )
         scanln[j] += 1;
      imgmap->put( scanln, i );
   }
   xbmd.term();
   printf( "done\n" );

   delete scanln;
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   load_xbm( );

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, pal, 3,
                          0, 0, 100, 100 );
         ip.print( 1 );
         printf( "done\n" );
         delete prt;
      }
      else
         printf( "Printer instantiation failed\n" );
   }

   // display the image
   else
   {
      VgaDisplay vga( gmode );
      ImageViewer iv( &vga, imgmap, pal, 3, 0, 0 );
      iv.view( );
   }

   delete imgmap;

   return 0;
}
