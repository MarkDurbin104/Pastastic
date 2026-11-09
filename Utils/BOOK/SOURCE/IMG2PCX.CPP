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

#include "imgstore.hpp"
#include "pcx.hpp"
#include "img.hpp"

//..................Program globals

char img_fn[80];       // path to IMG file
char pcx_fn[80];       // path to PCX file

ImgStore *imgmap;      // image bitmap
int       ncolors;     //    and
rgb      *imgpal;      // palette

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
   printf( "............IMG to PCX File Converter..........\n" );
   printf( "\n" );
   printf( "Usage:      IMG2PCX  img_file  [ pcx_file ]\n" );
   printf( "\n" );
   printf( "Default extensions of IMG and PCX are assumed\n" );
   printf( "\n" );
   printf( "...............................................\n" );
   printf( "\n" );
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

//..................Load the IMG file

int load_img( char *fn )
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
   imgd.init();
   for( int i=0; i<nrows; i++ )
   {
      if( imgd.decode( scanln, ncols ) != xOKAY )
      {
         delete scanln;
         delete imgmap;
         exit_pgm( "Error reading IMG bitmap" );
      }
      imgmap->put( scanln, i );
   }
   imgd.term();

   delete scanln;

   // return number of image colors
   return (imgh.nplanes == 1) ? 2 : 16;
}

//..................Load the IMG file

void write_pcx( char *fn )
{
   // open file
   FILE *fpcx = fopen( fn, "wb" );

   // create and write the header
   PCXHEADER pcxh;
   pcxh.bitpx = 1;
   pcxh.nplanes = (ncolors == 2) ? 1 : 4;
   pcxh.x1 = 0;
   pcxh.y1 = 0;
   pcxh.x2 = imgmap->width() - 1;
   pcxh.y2 = imgmap->height() - 1;
   pcxh.bplin = ((imgmap->width() + 15) / 16) * 2;
   int n = 0;
   for( int i=0; i<ncolors; i++ )
   {
      pcxh.colors[n++] = imgpal[i].red;
      pcxh.colors[n++] = imgpal[i].grn;
      pcxh.colors[n++] = imgpal[i].blu;
   }
   if( fwrite( &pcxh, sizeof(PCXHEADER), 1, fpcx ) != 1 )
   {
      delete imgmap;
      exit_pgm( "Error writing PCX header" );
   }

   // encode and write the bitmap
   PcxEncoder pcxe( fpcx, pcxh );
   pcxe.init();
   for( i=0; i<imgmap->height(); i++ )
   {
      if( pcxe.encode( imgmap->get(i), imgmap->width() )
          != xOKAY )
      {
         delete imgmap;
         exit_pgm( "Error writing PCX bitmap" );
      }
   }
   pcxe.term();
}

//..................Main

int main( int argc, char *argv[] )
{
   // we need at least one argument
   if( argc < 2 )
   {
      explain_pgm();
      exit( 0 );
   }

   // create file names
   if( argc < 3 )
   {
      strcpy( img_fn, argv[1] );
      int n = 0;
      char *p = argv[1];
      while( (*p != 0) && (*p != '.') )
         pcx_fn[n++] = *p++;
      pcx_fn[n] = 0;
   }
   else
   {
      strcpy( img_fn, argv[1] );
      strcpy( pcx_fn, argv[2] );
   }

   // supply default extensions
   if( strchr( img_fn, '.' ) == 0 )
      strcat( img_fn, ".IMG" );
   if( strchr( pcx_fn, '.' ) == 0 )
      strcat( pcx_fn, ".PCX" );

   // load IMG file
   printf( "Loading '%s'...", img_fn );
   ncolors = load_img( img_fn );
   imgpal = (ncolors == 2) ? monopal : colorpal;
   printf( "done\n" );

   // write PCX file
   printf( "Writing '%s'...", pcx_fn );
   write_pcx( pcx_fn );
   printf( "done\n" );

   delete imgmap;
   return 0;
}
