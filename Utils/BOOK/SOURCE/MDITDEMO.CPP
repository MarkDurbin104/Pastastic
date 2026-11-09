//--------------------------------------------------------//
//                                                        //
//   File:    MDITDEMO.CPP                                //
//                                                        //
//   Desc:    Monochrome dithering demonstration          //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"

#include "color.hpp"
#include "colormap.hpp"
#include "intenmap.hpp"
#include "display.hpp"
#include "dither.hpp"
#include "dithers.hpp"

//..................test image metrics

char * palname    = "EL-GRECO.PAL";
char * imgname    = "EL-GRECO.IMG";
int    imgwidth   = 354;
int    imgheight  = 446;
int    imgcolors  = 256;
rgb  * imgpalette = 0;
int  * imggrays   = 0;

//..................read test image palette

rgb * read_palette( char *fn, int ncolors )
{
   rgb *pal = new rgb [ncolors];
   if( pal == 0 )
   {
      printf( "No memory for palette\n" );
      exit( 0 );
   }
   FILE *f = fopen( fn, "rt" );
   if( f == 0 )
   {
      printf( "Palette file not found\n" );
      exit( 0 );
   }
   for( int i=0; i<ncolors; i++ )
   {
      int r, g, b;
      fscanf( f, "%d %d %d", &r, &g, &b );
      if( ferror(f) || feof(f) )
      {
         printf( "Error reading palette\n" );
         exit( 0 );
      }
      pal[i] = rgb( r, g, b );
   }
   fclose( f );
   return pal;
}

//..................get grayscale values from palette

int * compute_grays( rgb *pal, int ncolors )
{
   int *glvl = new int [ncolors];
   if( glvl == 0 )
   {
      printf( "No memory for grayscale\n" );
      exit( 0 );
   }
   for( int i=0; i<ncolors; i++ )
       glvl[i] = pal[i].graylevel();
   return glvl;
}

//..................dither and display the image

unsigned char scanline[640];

void dither_image( FILE *img, VgaDisplay& vga, Dither& dit )
{
   fseek( img, 0L, SEEK_SET );
   for( int i=0; i<imgheight; i++ )
   {
      fread( scanline, imgwidth, 1, img );
      for( int j=0; j<imgwidth; j++ )
         scanline[j] = imggrays[ scanline[j] ];
      dit.dither( scanline, imgwidth );
      vga.putscanline( scanline, imgwidth, 0, i );
   }
   getch();
}

//..................main

int main( void )
{
   // get image palette and grayscale
   imgpalette = read_palette( palname, imgcolors );
   imggrays   = compute_grays( imgpalette, imgcolors );

   // open image file for reading
   FILE *f = fopen( imgname, "rb" );
   if( f == 0 )
   {
      printf( "Image file not found\n" );
      exit( 0 );
   }

   // create a mode 12h VGA display
   VgaDisplay vga( 0x12 );

   // perform the demonstrations...
   // notes:  (1) in a mono display mode use 1, 0
   //             in place of 15, 0.
   //         (2) in a color mode try using 7, 8
   //             in place of 15, 0.

   OrderedDither cdit( ClustMat, 15, 0 );
   dither_image( f, vga, cdit );

   OrderedDither ddit( DispMat, 15, 0 );
   dither_image( f, vga, ddit );

   ThresholdDither tdit( 127, 15, 0 );
   dither_image( f, vga, tdit );

   DiffusionDither edit( 127, imgwidth, 15, 0 );
   dither_image( f, vga, edit );

   contrast_alter( imggrays, imgcolors, iMORE );
   edit.reset( );
   dither_image( f, vga, edit );

   // cleanup and exit
   fclose( f );
   delete [] imgpalette;
   delete [] imggrays;
   return 0;
}
