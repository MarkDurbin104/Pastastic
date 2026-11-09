//--------------------------------------------------------//
//                                                        //
//   File:    PDRVTEST.CPP                                //
//                                                        //
//   Desc:    Prorgam to illustrate the use of the        //
//            PrinterDriver class hierarchy               //
//                                                        //
//--------------------------------------------------------//

#include "stdio.h"
#include "conio.h"

#include "dither.hpp"
#include "printer.hpp"
#include "eplq24.hpp"

// test image metrics

#define  PALNAME    "EL-GRECO.PAL"
#define  IMGNAME    "EL-GRECO.IMG"
#define  IMGWIDTH   354
#define  IMGHEIGHT  446
#define  IMGCOLORS  256
#define  IMGBITS    8

rgb imgpalette[IMGCOLORS];

void read_palette( void )
{
   FILE *f = fopen( PALNAME, "rt" );
   for( int i=0; i<IMGCOLORS; i++ )
   {
      int r, g, b;
      fscanf( f, "%d %d %d", &r, &g, &b );
      imgpalette[i] = rgb( r, g, b );
   }
   fclose( f );
}

int main( void )
{
   // read the image's palette
   read_palette();

   // create the printer
   PrinterDriver *prt = new EpsonLQ24( "LPT1" );

   // create an image descriptor
   ImageDescriptor imd( IMGWIDTH, IMGHEIGHT, IMGBITS );

   // create a dither instance
   Dither *dit = new DiffusionDither( 127, IMGWIDTH );

   // read and print the image...

   unsigned char line[IMGWIDTH];
   FILE *fimg = fopen( IMGNAME, "rb" );

   printf( "printing..." );
   prt->imgprolog( imd );
   for( int i=0; i<IMGHEIGHT; i++ )
   {
      // get scanline
      fread( line, IMGWIDTH, 1, fimg );
      // convert to gray values
      for( int j=0; j<IMGWIDTH; j++ )
         line[j] = imgpalette[line[j]].graylevel();
      // dither the scan line
      dit->dither( line, IMGWIDTH );
      // and print it
      prt->putscanline( line, IMGWIDTH );
   }
   prt->imgprolog( imd );
   printf( "done\n" );
   prt->eject( );

   fclose( fimg );

   return 0;
}
