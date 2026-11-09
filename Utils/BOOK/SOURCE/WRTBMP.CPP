//--------------------------------------------------------//
//                                                        //
//   File:    WRTBMP.CPP                                  //
//                                                        //
//   Desc:    Code to output a BMP file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "display.hpp"
#include "imgstore.hpp"
#include "bmp.hpp"

//..................Abort macro

#define  ABORT( f, r )  { fclose(f); return r; }

//..................Write VGA screen to BMP file 'fn'

int WriteBMP( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   FILE *f = fopen( fn, "wb" );
   if( f == 0 )
      ABORT( f, xIOERROR );

   // image metrics
   int nrows    = y2 - y1 + 1;
   int ncols    = x2 - x1 + 1;
   int nbits    = vga.metric.nplanes * vga.metric.nbits;
   int ncolors  = (nbits <= 8) ? 1 << nbits : 0;
   int rowbytes = ((ncols*nbits + 31) / 32) * 4;

   // write an empty file header as a place holder
   xBITMAPFILEHEADER fh;
   if( fwrite( &fh, sizeof(xBITMAPFILEHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // initialize and write the image header
   xBITMAPINFOHEADER ih;
   ih.biSize = sizeof(xBITMAPINFOHEADER);
   ih.biWidth = ncols;
   ih.biHeight = nrows;
   ih.biPlanes = 1;
   ih.biBitCount = nbits;
   ih.biSizeImage = ((long) nrows)  * ((long) rowbytes);
   if( fwrite( &ih, sizeof(xBITMAPINFOHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // write the display's palette
   xRGBQUAD x;
   if( ncolors > 2 )
   {
      rgb *pal = new rgb[ncolors];
      if( pal == 0 )
         ABORT( f, xNOMEMORY );
      vga.getpalette( pal, ncolors );
      for( int i=0; i<ncolors; i++ )
      {
         x.set( pal[i].red, pal[i].grn, pal[i].blu );
         if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         {
            delete [] pal;
            ABORT( f, xIOERROR );
         }
      }
      delete [] pal;
   }
   else if( ncolors > 0 )
   {
      x.set( 0, 0, 0 );
      if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         ABORT( f, xIOERROR );
      x.set( 255, 255, 255 );
      if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         ABORT( f, xIOERROR );
   }

   // save offset to start of bitmap
   long bmofs = ftell( f );

   // output the bitmap
   unsigned char *pxls = new unsigned char [ncols];
   if( pxls == 0 )
      ABORT( f, xNOMEMORY );
   BmpEncoder bmp( f, nbits );
   for( int i=y2; i>=y1; i-- )
   {
      vga.getscanline( pxls, ncols, x1, i );
      bmp.encode( pxls, ncols );
      if( bmp.status() != xOKAY )
      {
         delete pxls;
         ABORT( f, bmp.status() );
      }
   }

   // save offset to end of file
   long fisiz = ftell( f );

   // update and rewrite file header
   fh.bfSize = fisiz;
   fh.bfOffBits = bmofs;
   fseek( f, 0L, SEEK_SET );
   if( fwrite( &fh, sizeof(xBITMAPFILEHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   fclose( f );
   return xOKAY;
}

//..................Write an ImgStore to BMP file 'fn'

int WriteBMP( ImgStore& img, rgb *pal, char *fn )
{
   FILE *f = fopen( fn, "wb" );
   if( f == 0 )
      ABORT( f, xIOERROR );

   // image metrics
   int nrows    = img.height();
   int ncols    = img.width();
   int nbits    = img.depth();
   int ncolors  = (nbits <= 8) ? 1 << nbits : 0;
   int rowbytes = ((ncols*nbits + 31) / 32) * 4;

   // write an empty file header as a place holder
   xBITMAPFILEHEADER fh;
   if( fwrite( &fh, sizeof(xBITMAPFILEHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // initialize and write the image header
   xBITMAPINFOHEADER ih;
   ih.biSize = sizeof(xBITMAPINFOHEADER);
   ih.biWidth = ncols;
   ih.biHeight = nrows;
   ih.biPlanes = 1;
   ih.biBitCount = nbits;
   ih.biSizeImage = ((long) nrows)  * ((long) rowbytes);
   if( fwrite( &ih, sizeof(xBITMAPINFOHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // write the palette
   xRGBQUAD x;
   if( ncolors > 2 )
   {
      for( int i=0; i<ncolors; i++ )
      {
         x.set( pal[i].red, pal[i].grn, pal[i].blu );
         if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         {
            delete [] pal;
            ABORT( f, xIOERROR );
         }
      }
   }
   else if( ncolors > 0 )
   {
      x.set( 0, 0, 0 );
      if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         ABORT( f, xIOERROR );
      x.set( 255, 255, 255 );
      if( fwrite( &x, sizeof(xRGBQUAD), 1, f ) != 1 )
         ABORT( f, xIOERROR );
   }

   // save offset to start of bitmap
   long bmofs = ftell( f );

   // output the bitmap
   BmpEncoder bmp( f, nbits );
   for( int i=nrows-1; i>=0; i-- )
   {
      bmp.encode( img.get(i), ncols );
      if( bmp.status() != xOKAY )
         ABORT( f, bmp.status() );
   }

   // save offset to end of file
   long fisiz = ftell( f );

   // update and rewrite file header
   fh.bfSize = fisiz;
   fh.bfOffBits = bmofs;
   fseek( f, 0L, SEEK_SET );
   if( fwrite( &fh, sizeof(xBITMAPFILEHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   fclose( f );
   return xOKAY;
}
