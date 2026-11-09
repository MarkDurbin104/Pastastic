//--------------------------------------------------------//
//                                                        //
//   File:    WRTGIF.CPP                                  //
//                                                        //
//   Desc:    Code to output a GIF file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "gif.hpp"
#include "gifcodec.hpp"
#include "color.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Write VGA screen to GIF file 'fn'

int WriteGIF( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // image metrics
   int nrows   = y2 - y1 + 1;
   int ncols   = x2 - x1 + 1;
   int nbits   = vga.metric.nbits * vga.metric.nplanes;
   int size    = (nbits < 8) ? nbits+1 : nbits;
   int ncolors = vga.metric.ncolors;
   rgb *pal    = new rgb [ncolors];
   if( pal == 0 ) return xNOMEMORY;
   vga.getpalette( pal );

   // scan line buffer for encoder
   unsigned char *scanln = new unsigned char [ncols];
   if( scanln == 0 ) return xNOMEMORY;

   // open and write the file
   FILE *f = fopen( fn, "wb" );

   // GIF header - since we don't employ any of the
   // 89a extensions we set the version to 87a
   GIFHEADER hdr;
   hdr.ver[1] = '7';
   if( hdr.put( f ) ) return xIOERROR;

   // GIF screen descriptor
   GIFSCDESC scd( ncols, nrows, nbits );
   if( scd.put( f ) ) return xIOERROR;

   // the Global Color Table
   for( int i=0; i<ncolors; i++ )
   {
      fputc( pal[i].red, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].blu, f );
   }

   // GIF image descriptor
   GIFIMDESC imd( ncols, nrows, nbits );
   if( imd.put( f ) ) return xIOERROR;

   // min LZW code size
   fputc( size, f );

   // output the encoded bitmap
   GifEncoder enc( f, size );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      if( enc.encode( scanln, ncols ) != xOKAY )
      {
         delete scanln;
         fclose( f );
         return enc.status();
      }
   }
   enc.term();

   // output block terminator
   fputc( 0, f );

   // output trailer
   fputc( 0x3B, f );

   // finished
   delete scanln;
   int retv = ferror(f) ? xIOERROR : xOKAY;
   fclose( f );
   return retv;
}

//..................Write an image to GIF file 'fn'

int WriteGIF( ImgStore& img, rgb *pal, char *fn )
{
   if( img.depth() == 25 )
      return xUNSUPPORTED;

   // image metrics
   int nrows   = img.height();
   int ncols   = img.width();
   int nbits   = (img.depth() == 1) ? 1 : 8;
   int size    = (nbits < 8) ? nbits+1 : nbits;
   int ncolors = 1 << img.depth();

   // open and write the file
   FILE *f = fopen( fn, "wb" );

   // GIF header - since we don't employ any of the
   // 89a extensions we set the version to 87a
   GIFHEADER hdr;
   hdr.ver[1] = '7';
   if( hdr.put( f ) ) return xIOERROR;

   // GIF screen descriptor
   GIFSCDESC scd( ncols, nrows, nbits );
   if( scd.put( f ) ) return xIOERROR;

   // the Global Color Table
   for( int i=0; i<ncolors; i++ )
   {
      fputc( pal[i].red, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].blu, f );
   }

   // GIF image descriptor
   GIFIMDESC imd( ncols, nrows, nbits );
   if( imd.put( f ) ) return xIOERROR;

   // min LZW code size
   fputc( size, f );

   // output the encoded bitmap
   GifEncoder enc( f, size );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      unsigned char *p = img.get( i );
      if( enc.encode( p, ncols ) != xOKAY )
      {
         fclose( f );
         return enc.status();
      }
   }
   enc.term();

   // output block terminator
   fputc( 0, f );

   // output trailer
   fputc( 0x3B, f );

   // finished
   int retv = ferror(f) ? xIOERROR : xOKAY;
   fclose( f );
   return retv;
}
