//--------------------------------------------------------//
//                                                        //
//   File:    VBMP.CPP                                    //
//                                                        //
//   Desc:    Program to view or print a BMP file.        //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "bmp.hpp"
#include "imgviewr.hpp"
#include "imgprntr.hpp"
#include "laserjet.hpp"
#include "paintjet.hpp"
#include "epjx80.hpp"
#include "eplq24.hpp"
#include "pscript.hpp"

#include "wrtbmp.cpp"

//..................Printer types

#define  LJ  0x4C4A
#define  PJ  0x504A
#define  JX  0x4A58
#define  LQ  0x4C51
#define  PS  0x5053

//..................Program globals

char      fn[80];       // path to BMP file
char      sfn[80];      // path to saved BMP file

int       gmode;        // video display mode
int       pmode;        // printer ID
int       ropt;         // rendering flags
int       iopt;         // itensity mapping flags

ImgStore *imgmap;       // image bitmap
rgb      *imgpal;       // image palette
int       imgcnt;       // number of palette colors

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
   printf( "..........Windows BMP File Viewer/Printer..........\n" );
   printf( "\n" );
   printf( "Usage:      VBMP  bmp_file  [ switches ]\n" );
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
   printf( "           -sXXX   = save screen image as XXX.BMP\n" );
   printf( "\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0]  = 0;
   sfn[0] = 0;
   gmode  = 0x12;
   pmode  = 0;
   ropt   = 0;
   iopt   = 0;

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

            case 'S' :
               strcpy( sfn, argv[i]+2 );
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
            strcat( fn, ".bmp" );
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

   // save file name ?
   if( sfn[0] != 0 )
   {
      char *p = strchr( sfn, '.' );
      if( p == 0 )
         strcat( sfn, ".bmp" );
   }

}

//..................Determine palette size

int color_count( int nbits )
{
   int ncolors = 0;
   if( nbits < 24 )
      ncolors = 1 << nbits;
   return ncolors;
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
      default : p = new PsPrinter( "TEST.PS" );
                break;
   }

   return p;
}

//..................Load the BMP file

void load_bmp( void )
{
   // open file
   FILE *fbmp = fopen( fn, "rb" );
   if( fbmp == 0 )
      exit_pgm( "BMP file not found" );

   // read header and check
   xBITMAPFILEHEADER bmfh;
   if( fread(&bmfh,sizeof(xBITMAPFILEHEADER),1,fbmp) != 1 )
      exit_pgm( "Error reading BMP file" );
   if( bmfh.bfType != BMP_SIGNATURE_WORD )
      exit_pgm( "File is not a valid BMP file" );

   // determine which format version is used
   // from structure size field
   long offset = ftell( fbmp );
   long nbytes = 0;
   fread( &nbytes, sizeof(long), 1, fbmp );
   fseek( fbmp, offset, SEEK_SET );

   // read bitmap header and palette
   int width, height, depth, rle;

   // pre Windows 3.0 version
   if( nbytes == sizeof(xBITMAPCOREHEADER) )
   {
      xBITMAPCOREHEADER bmch;
      if( fread(&bmch,sizeof(xBITMAPCOREHEADER),1,fbmp) != 1 )
         exit_pgm( "Error reading xBITMAPCOREHEADER" );
      width  = bmch.bcWidth;
      height = bmch.bcHeight;
      depth  = bmch.bcBitCount;
      rle    = 0;
      imgcnt = color_count( depth );
      if( imgcnt > 0 )
      {
         imgpal = new rgb [imgcnt];
         if( imgpal == 0 )
            exit_pgm( "Error allocating image palette" );
         xRGBTRIPLE t;
         for( int i=0; i<imgcnt; i++ )
         {
            if( fread(&t,sizeof(xRGBTRIPLE),1,fbmp) != 1 )
               exit_pgm( "Error reading xRGBTRIPLE" );
            imgpal[i] = rgb(t.rgbRed,t.rgbGreen,t.rgbBlue);
         }
      }
   }

   // Windows 3.0 and later version
   else if( nbytes == sizeof(xBITMAPINFOHEADER) )
   {
      xBITMAPINFOHEADER bmih;
      if( fread(&bmih,sizeof(xBITMAPINFOHEADER),1,fbmp) != 1 )
         exit_pgm( "Error reading xBITMAPINFOHEADER" );
      width  = (int) bmih.biWidth;
      height = (int) bmih.biHeight;
      depth  = bmih.biBitCount;
      rle    = (int) bmih.biCompression;
      imgcnt = color_count( depth );
      if( imgcnt > 0 )
      {
         imgpal = new rgb [imgcnt];
         if( imgpal == 0 )
            exit_pgm( "Error allocating image palette" );
         xRGBQUAD q;
         for( int i=0; i<imgcnt; i++ )
         {
            if( fread(&q,sizeof(xRGBQUAD),1,fbmp) != 1 )
               exit_pgm( "Error reading xRGBQUAD" );
            imgpal[i] = rgb(q.rgbRed,q.rgbGreen,q.rgbBlue);
         }
      }
   }

   // unknown format
   else
   {
      exit_pgm( "Format error or file is not a BMP file" );
   }

   // set pixel size in bytes
   int pxlsize = 1;
   if( depth == 24 ) pxlsize = 3;

   // position to start of bitmap
   fseek( fbmp, bmfh.bfOffBits, SEEK_SET );

   // create a scan line buffer
   int rowbytes = (width * pxlsize + 3) / 4;
   rowbytes *= 4;
   unsigned char *scanline = new unsigned char [rowbytes];

   // create an image storage buffer
   imgmap = istore( height, width, pxlsize*8 );

   // and check
   if( (imgmap == 0) || (scanline == 0) )
   {
      if( imgmap )   delete imgmap;
      if( scanline ) delete scanline;
      exit_pgm( "Insufficient memory to load image" );
   }

   // load the image
   printf( "Loading file '%s' (%dW x %dH x %dD)...",
            fn, width, height, depth );
   BmpDecoder bmp( fbmp, rle, depth );
   bmp.init( );
   int n = height;
   for( int i=0; i<height; i++ )
   {
      bmp.decode( scanline, width );
      imgmap->put( scanline, --n );
   }
   bmp.term( );
   printf( "done\n" );

   // at this point we're done with the file
   // and the scan line buffer
   fclose( fbmp );
   delete scanline;
}

//..................Main

int main( int argc, char *argv[] )
{
   int retv = xOKAY;

   process_args( argc, argv );

   load_bmp( );

   // print the image
   if( pmode != 0 )
   {
      PrinterDriver *prt = printer( pmode );
      if( prt )
      {
         printf( "Printing..." );
         ImagePrinter ip( prt, imgmap, imgpal, imgcnt,
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
      ImageViewer iv( &vga, imgmap, imgpal, imgcnt,
                      ropt, iopt );
      iv.view( );
      if( sfn[0] )
      {
         int x1 = (vga.metric.ncolumns - imgmap->width()) / 2;
         int x2 = x1 + imgmap->width() - 1;
         int y1 = (vga.metric.nrows - imgmap->height()) / 2;
         int y2 = y1 + imgmap->height() - 1;
         retv = WriteBMP( vga, sfn, x1, y1, x2, y2 );
      }
   }

   delete [] imgpal;
   delete imgmap;

   if( retv != xOKAY )
      printf( "WriteBMP failed, retv = %d\n", retv );

   return 0;
}
