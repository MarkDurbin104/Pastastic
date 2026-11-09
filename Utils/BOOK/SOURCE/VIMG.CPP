//--------------------------------------------------------//
//                                                        //
//   File:    VIMG.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a GEM IMG file.    //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "img.hpp"
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

char fn[80];           // path to IMG file

int gmode;             // video display mode
int pmode;             // printer ID
int negate;            // image negative flag

ImgStore *imgmap;      // image bitmap

rgb monopal[] =        // mono palette
{
   rgb( 0, 0, 0 ),
   rgb( 255, 255, 255 )
};

rgb colorpal[] =       // 16-color palette
{
   rgb(   0,   0,   0 ),
   rgb(   0,   0, 170 ),
   rgb(   0, 170,   0 ),
   rgb(   0, 170, 170 ),
   rgb( 170,   0,   0 ),
   rgb( 170,   0, 170 ),
   rgb( 170,  85,   0 ),
   rgb( 170, 170, 170 ),
   rgb(  85,  85,  85 ),
   rgb(  85,  85, 255 ),
   rgb(  85, 255,  85 ),
   rgb(  85, 255, 255 ),
   rgb( 255,  85,  85 ),
   rgb( 255,  85, 255 ),
   rgb( 255, 255,  85 ),
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
   printf( "............GEM IMG File Viewer/Printer............\n" );
   printf( "\n" );
   printf( "Usage:      VIMG  img_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h      = display program usage\n" );
   printf( "           -vXX    = force video display mode XX\n" );
   printf( "                     (XX = 12, 13, 2E, 62)\n" );
   printf( "           -pXX    = print using printer XX\n" );
   printf( "                     (XX = LJ, PJ, JX, LQ, PS)\n" );
   printf( "           -n      = use negative of image\n" );
   printf( "\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0]  = 0;
   gmode  = 0x12;
   pmode  = 0;
   negate = 0;

   // process the program's argument list
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

            case 'P' :
               pmode = toupper( *(argv[i]+2) );
               pmode <<= 8;
               pmode += toupper( *(argv[i]+3) );
               break;

            case 'N' :
               negate = 1;
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
         char *p = strchr( fn, '.' );
         if( p == 0 )
            strcat( fn, ".img" );
         else if( *(p+1) == 0 )
            *p = 0;
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

//..................Load the IMG file

int load_img( void )
{
   // open file
   FILE *fimg = fopen( fn, "rb" );
   if( fimg == 0 )
      exit_pgm( "IMG file not found" );

   // read header
   IMGHEADER imgh;
   if( fread( &imgh, sizeof(IMGHEADER), 1, fimg ) != 1 )
      exit_pgm( "Error reading IMG header" );

   ImgDecoder imgd( fimg, imgh );

   // create bitmap
   int ncols = imgh.scanwidth;
   int nrows = imgd.height();

   unsigned char *scanln = new unsigned char [ncols];
   imgmap = istore( nrows, ncols, 8 );
   if( (imgmap == 0) || (scanln == 0) )
   {
      if( imgmap ) delete imgmap;
      if( scanln ) delete scanln;
      exit_pgm( "Insufficient memory to load image" );
   }

   // load bitmap
   printf( "Loading IMG image from '%s'...", fn );
   imgd.init();
   for( int i=0; i<nrows; i++ )
   {
      if( imgd.decode( scanln, ncols ) != xOKAY )
         break;
      if( negate && (imgh.nplanes==1) )
         for( int j=0; j<ncols; j++ )
            scanln[j] = 1 - scanln[j];
      imgmap->put( scanln, i );
   }
   imgd.term();
   printf( "done\n" );

   delete scanln;

   // return number of image colors
   return (imgh.nplanes == 1) ? 2 : 16;
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   int ncolors = load_img( );
   rgb *imgpal = (ncolors == 2) ? monopal : colorpal;

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, imgpal, ncolors,
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
      ImageViewer iv( &vga, imgmap, imgpal, ncolors, 0, 0 );
      iv.view( );
   }

   delete imgmap;

   return 0;
}
