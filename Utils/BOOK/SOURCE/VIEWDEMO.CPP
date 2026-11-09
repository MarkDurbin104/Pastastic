//--------------------------------------------------------//
//                                                        //
//   File:    VIEWDEMO.CPP                                //
//                                                        //
//   Desc:    ImageViewer class demonstration program.    //
//                                                        //
//--------------------------------------------------------//

#include "stdio.h"
#include "conio.h"

#include "imgviewr.hpp"

char * palname    = "EL-GRECO.PAL";
char * imgname    = "EL-GRECO.IMG";
int    imgwidth   = 354;
int    imgheight  = 446;
int    imgcolors  = 256;
rgb    imgpalette[256];
CnvImgStore img( 446, 354, 8 );
unsigned char scanline[354];

// read the test image's palette

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

// read the test image into an ImgStore instance

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
   // set defaults for display mode, rendering options,
   // and intensity mapping options -- see IMGVIEWR.HPP.
   int mode = 0x12;
   int ropt = 0;
   int iopt = 0;

   // override defaults from the command line
   if( argc > 1 ) sscanf( argv[1], "%x", &mode );
   if( argc > 2 ) sscanf( argv[2], "%d", &ropt );
   if( argc > 3 ) sscanf( argv[3], "%d", &iopt );

   // load the image and palette
   printf( "Loading %s...", imgname );
   read_palette();
   read_image();
   printf( "done, press a key\n" );
   getch();

   // instantiate a display and view the image
   VgaDisplay  vga( mode );
   ImageViewer viewer( &vga, &img, imgpalette, imgcolors,
                        ropt, iopt );
   viewer.view();

   return 0;
}
