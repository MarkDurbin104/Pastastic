//--------------------------------------------------------//
//                                                        //
//   File:    CDITDEMO.CPP                                //
//                                                        //
//   Desc:    Color dithering demonstration               //
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

//..................test image metrics

char * palname    = "EL-GRECO.PAL";
char * imgname    = "EL-GRECO.IMG";
int    imgwidth   = 354;
int    imgheight  = 446;
int    imgcolors  = 256;
rgb  * imgpalette = 0;

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

//..................dither and display the image

unsigned char scanline[640];

void dither_image( FILE *img, VgaDisplay& vga, Dither& dit )
{
   fseek( img, 0L, SEEK_SET );
   for( int i=0; i<imgheight; i++ )
   {
      fread( scanline, imgwidth, 1, img );
      dit.dither( scanline, imgwidth );
      vga.putscanline( scanline, imgwidth, 0, i );
   }
   getch();
}

//..................main

int main( void )
{
   // get image palette
   imgpalette = read_palette( palname, imgcolors );

   // open image file for reading
   FILE *f = fopen( imgname, "rb" );
   if( f == 0 )
   {
      printf( "Image file not found\n" );
      exit( 0 );
   }

   // create mode 12h display, set special palette
   VgaDisplay vga( 0x12 );

   // thresholded dither...
   vga.putpalette( ColorThresholdPalette(),
                   ColorThresholdSize() );
   ColorThresholdDither tdit( 127, imgpalette, imgcolors );
   dither_image( f, vga, tdit );

   // error diffusion dither....
   vga.putpalette( ColorDiffusionPalette(),
                   ColorDiffusionSize() );
   ColorDiffusionDither ddit( imgwidth, imgpalette, imgcolors,
                              ColorDiffusionPalette(),
                              ColorDiffusionSize() );
   dither_image( f, vga, ddit );

   // error diffusion dither with enhanced contrast...
   contrast_alter( imgpalette, imgcolors, iMORE );
   ddit.reset( );
   dither_image( f, vga, ddit );

   // cleanup and exit
   fclose( f );
   delete [] imgpalette;
   return 0;
}
