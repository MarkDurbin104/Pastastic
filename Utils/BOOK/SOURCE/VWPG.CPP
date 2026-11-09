//--------------------------------------------------------//
//                                                        //
//   File:    VWPG.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a WPG file.        //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "wpg.hpp"
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

char      fn[80];       // path to PCX file

int       gmode;        // video display mode
int       pmode;        // printer ID
int       ropt;         // rendering flags
int       iopt;         // itensity mapping flags

ImgStore     *imgmap;   // image bitmap
RgbPalette   *imgpal;   // image palette

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
   printf( ".......WordPerfect WPG File Viewer/Printer.......\n" );
   printf( "\n" );
   printf( "Usage:      VWPG  wpg_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h      = display program usage\n" );
   printf( "           -vXX    = force video display mode XX\n" );
   printf( "                     (XX = 12, 13, 2E, 62)\n" );
   printf( "           -pXX    = print using printer XX\n" );
   printf( "                     (XX = LJ, PJ, JX, LQ, PS)\n" );
   printf( "           -b[+|-] = increase or decrease brightness\n" );
   printf( "           -c[+|-] = increase or decrease contrast\n" );
   printf( "           -d      = force dithered rendering\n" );
   printf( "           -g      = force gray scale rendering\n" );
   printf( "           -m      = force palette mapping\n" );
   printf( "\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0] = 0;
   gmode = 0x12;
   pmode = 0;
   ropt  = 0;
   iopt  = 0;

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

            case 'B' :
               if( *(argv[i]+2) == '-' )
                  iopt |= intensDBRI;
               else
                  iopt |= intensIBRI;
               break;

            case 'C' :
               if( *(argv[i]+2) == '-' )
                  iopt |= intensDCNT;
               else
                  iopt |= intensICNT;
               break;

            case 'D' :
               ropt |= renderDITHER;
               break;

            case 'G' :
               ropt |= renderGRAY;
               break;

            case 'M' :
               ropt |= renderMAP;
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
            strcat( fn, ".wpg" );
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

//..................Load a bitmap

ImgStore * read_bm( FILE * f, WPGBMHEADER * h )
{
   unsigned char *scanln = new unsigned char [h->bmwidth];
   ImgStore *imap = istore( h->bmheight, h->bmwidth, 8 );
   if( (imap == 0) || (scanln == 0) )
   {
      if( imap ) delete imap;
      if( scanln ) delete scanln;
      exit_pgm( "Insufficient memory to load image" );
   }

   WpgDecoder d( f, h->bmdepth, h->bmwidth, h->bmheight );
   d.init();
   for( int i=0; i<h->bmheight; i++ )
   {
      d.decode( scanln, h->bmwidth );
      imap->put( scanln, i );
   }
   d.term();

   delete scanln;
   return imap;
}

//..................Load the WPG file

void load_wpg( void )
{
   // open file
   FILE *fwpg = fopen( fn, "rb" );
   if( fwpg == 0 )
      exit_pgm( "WPG file not found" );

   // read header
   WPGHEADER wpgh;
   if( fread( &wpgh, sizeof(WPGHEADER), 1, fwpg ) != 1 )
      exit_pgm( "Error reading WPG header" );

   // validate file
   if( wpgh.validate() != 0 )
      exit_pgm( "File is not a WPG file" );

   // scan file for palette and bitmap
   imgmap = 0;
   imgpal = WpgPalette();
   WPGTAG tag;
   while( ! tag.get( fwpg ) )
   {
      WPGBMHEADER bmh;
      switch( tag.rectype )
      {
         case wpgBitmap :
              bmh.get( fwpg );
              imgmap = read_bm( fwpg, &bmh );
              break;

         case wpgColorMap :
              imgpal = WpgPalette( fwpg );
              break;

         default :
              fseek( fwpg, tag.reclength, SEEK_CUR );
              break;
      }
   }
   fclose( fwpg );
   if( imgmap == 0 )
      exit_pgm( "WPG file lacks a bitmap" );
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   load_wpg( );

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, imgpal->colors,
                          imgpal->ncolors,
                          ropt, iopt, 100, 100 );
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
      ImageViewer iv( &vga, imgmap, imgpal->colors,
                      imgpal->ncolors, ropt, iopt );
      iv.view( );
   }

   delete imgmap;

   return 0;
}
