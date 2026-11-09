//--------------------------------------------------------//
//                                                        //
//   File:    VMSP.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a MSP file.        //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "msp.hpp"
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

char fn[80];           // path to MSP file

int gmode;             // video display mode
int pmode;             // printer ID
int negate;            // image negative flag

ImgStore *imgmap;      // image bitmap

rgb monopal[] =        // image palette
{
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
   printf( ".........MS Paint MSP File Viewer/Printer..........\n" );
   printf( "\n" );
   printf( "Usage:      VMSP  msp_file  [ switches ]\n" );
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
            strcat( fn, ".msp" );
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

//..................Load the MSP file

void load_msp( void )
{
   // open file
   FILE *fmsp = fopen( fn, "rb" );
   if( fmsp == 0 )
      exit_pgm( "MSP file not found" );

   // read header
   MSPHEADER msph;
   if( fread( &msph, sizeof(MSPHEADER), 1, fmsp ) != 1 )
      exit_pgm( "Error reading MSP header" );

   // validate file
   int version = 0;
   if( (msph.key1 == V1KEY1) && (msph.key2 == V1KEY2) )
      version = 1;
   if( (msph.key1 == V2KEY1) && (msph.key2 == V2KEY2) )
      version = 2;
   if( version == 0 )
      exit_pgm( "File is not a MSP file" );

   // create bitmap
   int ncols = msph.width;
   int nrows = msph.height;

   unsigned char *scanln = new unsigned char [ncols];
   imgmap = istore( nrows, ncols, 8 );
   if( (imgmap == 0) || (scanln == 0) )
   {
      if( imgmap ) delete imgmap;
      if( scanln ) delete scanln;
      exit_pgm( "Insufficient memory to load image" );
   }

   // load bitmap
   printf( "Loading MSP image from '%s'...", fn );
   MspDecoder mspd( fmsp, msph );
   mspd.init();
   for( int i=0; i<nrows; i++ )
   {
      if( mspd.decode( scanln, ncols ) != xOKAY )
         break;
      if( negate )
         for( int j=0; j<ncols; j++ )
            scanln[j] = 1 - scanln[j];
      imgmap->put( scanln, i );
   }
   mspd.term();
   printf( "done\n" );

   delete scanln;
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   load_msp( );

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, monopal, 2,
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
      ImageViewer iv( &vga, imgmap, monopal, 2, 0, 0 );
      iv.view( );
   }

   delete imgmap;

   return 0;
}
