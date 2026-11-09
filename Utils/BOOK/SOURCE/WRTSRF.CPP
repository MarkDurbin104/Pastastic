//--------------------------------------------------------//
//                                                        //
//   File:    WRTSRF.CPP                                  //
//                                                        //
//   Desc:    Code to output a SRF file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "srf.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Write VGA screen to SRF file 'fn'

int WriteSRF( VgaDisplay& vga, char *fn,
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

   // Sun Raster File output file
   FILE *f = fopen( fn, "wb" );

   // initialize and write the SRF header
   SRFHEADER srf( ncols, nrows, nbits );
   srf.imtype = imRle;
   srf.maptype = mapRgb;
   srf.maplength = ncolors * 3;
   srf.put( f );

   // write the color map
   vga.getpalette( vgapal, ncolors );
   for( int i=0; i<ncolors; i++ )
   {
      fputc( vgapal[i].red, f );
      fputc( vgapal[i].grn, f );
      fputc( vgapal[i].blu, f );
   }

   // write the image
   SrfEncoder enc( f, srf );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      enc.encode( scanln, ncols );
   }
   enc.term();

   // update header image size field
   long n = ftell( f );
   n -= sizeof( SRFHEADER ) + srf.maplength;
   srf.imlength = n;
   fseek( f, 0, SEEK_SET );
   srf.put( f );

   int retv = ferror( f );
   fclose( f );
   delete scanln;
   delete [] vgapal;
   return retv ? xIOERROR : xOKAY;
}

//..................Write an image to SRF file 'fn'

int WriteSRF( ImgStore& img, rgb *pal, char *fn )
{
   // image metrics
   int nrows = img.height();
   int ncols = img.width();
   int nbits = 1;
   if( img.depth() == 24 ) nbits = 24;
   else if( img.depth() > 1 ) nbits = 8;
   int ncolors = 2;
   if( img.depth() == 24 ) ncolors = 0;
   else if( img.depth() > 1 ) ncolors = 256;

   // Sun Raster File output file
   FILE *f = fopen( fn, "wb" );

   // initialize and write the SRF header
   SRFHEADER srf( ncols, nrows, nbits );
   srf.imtype = imRle;
   srf.maptype = mapRgb;
   srf.maplength = ncolors * 3;
   srf.put( f );

   // write the color map
   for( int i=0; i<ncolors; i++ )
   {
      fputc( pal[i].red, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].blu, f );
   }

   // write the image
   SrfEncoder enc( f, srf );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      enc.encode( img.get(i), ncols );
   }
   enc.term();

   // update header image size field
   long n = ftell( f );
   n -= sizeof( SRFHEADER ) + srf.maplength;
   srf.imlength = n;
   fseek( f, 0, SEEK_SET );
   srf.put( f );

   int retv = ferror( f );
   fclose( f );
   return retv ? xIOERROR : xOKAY;
}
