//--------------------------------------------------------//
//                                                        //
//   File:    DISPTEST.CPP                                //
//                                                        //
//   Desc:    Prorgam to illustrate the use of the        //
//            VgaDisplay class hierarchy                  //
//                                                        //
//--------------------------------------------------------//

#include "stdio.h"
#include "conio.h"

#include "display.hpp"

// test image metrics

#define  PALNAME    "EL-GRECO.PAL"
#define  IMGNAME    "EL-GRECO.IMG"
#define  IMGWIDTH   354
#define  IMGHEIGHT  446
#define  IMGCOLORS  256

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

   // create display and set palette
   VgaDisplay Vga( 0x2E );
   Vga.putpalette( imgpalette, IMGCOLORS );

   // read and display the image
   unsigned char line[IMGWIDTH];
   FILE *fimg = fopen( IMGNAME, "rb" );
   for( int i=0; i<IMGHEIGHT; i++ )
   {
      fread( line, IMGWIDTH, 1, fimg );
      Vga.putscanline( line, IMGWIDTH, 150, 10+i );
   }
   fclose( fimg );

   // wait for a key and exit
   getch();
   return 0;
}
