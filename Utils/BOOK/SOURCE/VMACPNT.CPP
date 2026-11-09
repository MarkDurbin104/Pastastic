//--------------------------------------------------------//
//                                                        //
//   File:    VMACPNT.CPP                                 //
//                                                        //
//   Desc:    Program to view or print a MacPaint file    //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "macpnt.hpp"
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

char fn[80];           // path to MACPNT file

int gmode;             // video display mode
int pmode;             // printer ID
int negate;            // image negative flag
int reduce;            // scale by 1/2 flag

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
   printf( ".........MacPaint File Viewer/Printer..........\n" );
   printf( "\n" );
   printf( "Usage:      VMACPNT  macpnt_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h    = display program usage\n" );
   printf( "           -vXX  = force video display mode XX\n" );
   printf( "                   (XX = 12, 13, 2E, 62)\n" );
   printf( "           -pXX  = print using printer XX\n" );
   printf( "                   (XX = LJ, PJ, JX, LQ, PS)\n" );
   printf( "           -n    = use negative of image\n" );
   printf( "           -r    = reduce image by half\n" );
   printf( "\n" );
   printf( "...............................................\n" );
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
   reduce = 0;

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

            case 'R' :
               reduce = 1;
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
            strcat( fn, ".mac" );
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

//..................Load the MACPNT file

void load_macpnt( void )
{
   // open file
   FILE *fmacpnt = fopen( fn, "rb" );
   if( fmacpnt == 0 )
      exit_pgm( "MACPNT file not found" );

   // test first 128 bytes for a MacBinary header
   MACBINHDR bhdr;
   if( bhdr.get( fmacpnt ) != 0 )
      exit_pgm( "Error reading MacBinary header" );

   // if found, bitmap is at offset 640, otherwise 512
   if( (strncmp( bhdr.filetype, "PNTG", 4 ) == 0) &&
       (strncmp( bhdr.fileownr, "MPNT", 4 ) == 0) )
      fseek( fmacpnt, 640, SEEK_SET );
   else
      fseek( fmacpnt, 512, SEEK_SET );

   // bitmap metrics
   int ncols = 576;
   int nrows = 720;
   int fg    = 0;
   int bg    = 1;
   if( negate )
   {
      fg = 1;
      bg = 0;
   }

   unsigned char *scanln  = 0,
                 *scanln1 = 0,
                 *scanln2 = 0;

   if( reduce )
   {
      scanln1 = new unsigned char [ncols];
      scanln2 = new unsigned char [ncols];
      scanln = new unsigned char [ncols/2];
      imgmap = istore( nrows/2, ncols/2, 8 );
      if( (imgmap == 0)  || (scanln == 0) ||
          (scanln1 == 0) || (scanln2 == 0) )
      {
         delete imgmap;
         delete scanln;
         delete scanln1;
         delete scanln2;
         exit_pgm( "Insufficient memory to load image" );
      }
      printf( "Loading MACPNT image from '%s'...", fn );
      MacPntDecoder macpdec( fmacpnt, fg, bg );
      macpdec.init();
      for( int i=0; i<nrows/2; i++ )
      {
         if( macpdec.decode( scanln1, ncols ) != xOKAY )
            break;
         if( macpdec.decode( scanln2, ncols ) != xOKAY )
            break;
         for( int j=0; j<ncols/2; j++ )
         {
            int n = scanln1[j*2] + scanln1[j*2+1] +
                    scanln2[j*2] + scanln2[j*2+1];
            scanln[j] = (n >= 2) ? 1 : 0;
         }
         imgmap->put( scanln, i );
      }
      macpdec.term();
      printf( "done\n" );
   }
   else
   {
      scanln = new unsigned char [ncols];
      imgmap = istore( nrows, ncols, 8 );
      if( (imgmap == 0) || (scanln == 0) )
      {
         delete imgmap;
         delete scanln;
         exit_pgm( "Insufficient memory to load image" );
      }
      printf( "Loading MACPNT image from '%s'...", fn );
      MacPntDecoder macpdec( fmacpnt, fg, bg );
      macpdec.init();
      for( int i=0; i<nrows; i++ )
      {
         if( macpdec.decode( scanln, ncols ) != xOKAY )
            break;
         imgmap->put( scanln, i );
      }
      macpdec.term();
      printf( "done\n" );
   }

   delete scanln;
   delete scanln1;
   delete scanln2;
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   load_macpnt( );

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
