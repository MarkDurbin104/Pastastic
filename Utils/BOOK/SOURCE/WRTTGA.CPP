//--------------------------------------------------------//
//                                                        //
//   File:    WRTTGA.CPP                                  //
//                                                        //
//   Desc:    Code to output a TGA file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "tga.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Write VGA screen to TGA file 'fn'

int WriteTGA( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // image metrics
   int nrows   = y2 - y1 + 1;
   int ncols   = x2 - x1 + 1;
   int nbits   = 8;
   int ncolors = vga.metric.ncolors;

   // scan line buffer
   unsigned char *scanln = new unsigned char [ncols];
   rgb *vgapal = new rgb [ncolors];
   if( (scanln == 0) || (vgapal == 0) )
   {
      delete scanln;
      delete [] vgapal;
      return xNOMEMORY;
   }

   // TARGA output file
   FILE *f = fopen( fn, "wb" );

   // initialize and write the TGA header
   TGAHEADER tga( ncols, nrows, nbits );
   tga.cmcnt = vga.metric.ncolors;
   tga.cmsiz = 24;
   tga.put( f );

   // write the color map
   vga.getpalette( vgapal, ncolors );
   for( int i=0; i<ncolors; i++ )
   {
      fputc( vgapal[i].blu, f );
      fputc( vgapal[i].grn, f );
      fputc( vgapal[i].red, f );
   }

   // write the image
   TgaEncoder enc( f, tga );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      enc.encode( scanln, ncols );
   }
   enc.term();

   int retv = ferror( f );
   fclose( f );
   delete scanln;
   delete [] vgapal;
   return retv ? xIOERROR : xOKAY;
}

//..................Write an image to TGA file 'fn'

int WriteTGA( ImgStore& img, rgb *pal, char *fn )
{
   // image metrics
   int nrows   = img.height();
   int ncols   = img.width();
   int nbits   = (img.depth() == 24) ? 24 : 8;
   int ncolors = (img.depth() <= 8) ? (1 << img.depth()) : 0;

   // TARGA output file
   FILE *f = fopen( fn, "wb" );

   // initialize and write the TGA header
   TGAHEADER tga( ncols, nrows, nbits );
   tga.cmcnt =  ncolors;
   tga.cmsiz = (ncolors > 0) ? 24 : 0;
   tga.put( f );

   // write the color map
   for( int i=0; i<ncolors; i++ )
   {
      fputc( pal[i].blu, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].red, f );
   }

   // write the image
   TgaEncoder enc( f, tga );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      enc.encode( img.get(i), ncols );
      printf( "." );
   }
   enc.term();

   int retv = ferror( f );
   fclose( f );
   return retv ? xIOERROR : xOKAY;
}
