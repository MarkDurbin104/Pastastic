#include "stdio.h"
#include "conio.h"

#include "imgprntr.hpp"

#include "eplq24.hpp"
#include "epjx80.hpp"
#include "laserjet.hpp"
#include "paintjet.hpp"

// test image metrics

char * palname    = "EL-GRECO.PAL";
char * imgname    = "EL-GRECO.IMG";
int    imgwidth   = 354;
int    imgheight  = 446;
int    imgcolors  = 256;
rgb    imgpalette[256];
CnvImgStore img( 446, 354, 8 );
unsigned char scanline[354];

// read test image palette

void read_palette( void )
{
   FILE *f = fopen( palname, "rt" );
   for( int i=0; i<imgcolors; i++ )
   {
      int r, g, b;
      fscanf( f, "%d %d %d", &r, &g, &b );
      imgpalette[i] = rgb( r, g, b );
   }
   fclose( f );
}

// read test image bitmap

void read_image( void )
{
   FILE *f = fopen( imgname, "rb" );
   for( int i=0; i<imgheight; i++ )
   {
      fread( scanline, imgwidth, 1, f );
      img.put( scanline, i );
   }
   fclose( f );
}

// perform the demo

int main( int argc, char *argv[] )
{
   // rendering and intensity mapping options
   int ropt = 0;
   int iopt = 0;
   if( argc > 1 ) sscanf( argv[1], "%d", &ropt );
   if( argc > 2 ) sscanf( argv[2], "%d", &iopt );

   // load image palette and bitmap
   printf( "Loading %s...", imgname );
   read_palette();
   read_image();
   printf( "done, press a key\n" );
   getch();

   // print the image
   EpsonLQ24 prt( "LPT1" );
   prt.setres( rHIGH );
   ImagePrinter iprt( &prt, &img, imgpalette, imgcolors,
                      ropt, iopt, 100, 100 );
   printf( "Printing..." );
   iprt.print( 1 );
   printf( "done\n" );

   return 0;
}
