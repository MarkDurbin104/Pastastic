//--------------------------------------------------------//
//                                                        //
//   File:    BMPDEMO.CPP                                 //
//                                                        //
//   Desc:    Example code to write a BMP file.           //
//                                                        //
//--------------------------------------------------------//

#include "wrtbmp.cpp"

char *        palname    = "EL-GRECO.PAL";
char *        imgname    = "EL-GRECO.IMG";
int           imgwidth   = 354;
int           imgheight  = 446;
int           imgcolors  = 256;
rgb           imgpalette[256];
unsigned char scanline[354];

// read the test image's palette

void read_palette( VgaDisplay& vga )
{
   FILE *f = fopen( palname, "rt" );
   for( int i=0; i<imgcolors; i++ )
   {
      int r, g, b;
      fscanf( f, "%d %d %d", &r, &g, &b );
      imgpalette[i] = rgb( r, g, b );
   }
   fclose( f );
   vga.putpalette( imgpalette, imgcolors );
}

// read the test image onto the screen

void read_image( VgaDisplay& vga )
{
   FILE *f = fopen( imgname, "rb" );
   for( int i=0; i<imgheight; i++ )
   {
      fread( scanline, imgwidth, 1, f );
      vga.putscanline( scanline, imgwidth, 0, i );
   }
   fclose( f );
}

// output a BMP file

int main( void )
{
   VgaDisplay vga( 0x2E );

   read_palette( vga );
   read_image( vga );

   WriteBMP( vga, "BMPDEMO.BMP", 0, 0, imgwidth-1, imgheight-1 );

   return 0;
}
