//--------------------------------------------------------//
//                                                        //
//   File:    WRTPCX.CPP                                  //
//                                                        //
//   Desc:    Code to output a PCX file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "pcx.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Abort macro

#define  ABORT( f, r )  { fclose(f); return r; }

//..................Write VGA screen to PCX file 'fn'

int WritePCX( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   FILE *f = fopen( fn, "wb" );
   if( f == 0 )
      ABORT( f, xIOERROR );

   // image metrics
   int nrows      = y2 - y1 + 1;
   int ncols      = x2 - x1 + 1;
   int nbits      = vga.metric.nbits;
   int nplanes    = vga.metric.nplanes;
   int pxlsize    = nbits * nplanes;
   int pxlbytes   = (nbits * nplanes + 7) / 8;
   int ncolors    = (pxlsize <= 8) ? 1 << pxlsize : 0;
   int planebytes = ((ncols * nbits + 15) / 16) * 2;

   // initialize and write the PCX header
   PCXHEADER pcxh;
   pcxh.x1 = x1;
   pcxh.y1 = y1;
   pcxh.x2 = x2;
   pcxh.y2 = y2;
   pcxh.bitpx = nbits;
   pcxh.nplanes = nplanes;
   pcxh.bplin = planebytes;
   pcxh.hres = 100;  // a typical value
   pcxh.vres = 100;
   pcxh.scrnw = vga.metric.ncolumns;
   pcxh.scrnh = vga.metric.nrows;
   if( (ncolors <= 16) && (ncolors > 0) )
   {
      rgb *pal = new rgb [16];
      if( pal == 0 )
         ABORT( f, xNOMEMORY );
      vga.getpalette( pal, ncolors );
      int n = 0;
      for( int i=0; i<ncolors; i++ )
      {
         pcxh.colors[n++] = pal[i].red;
         pcxh.colors[n++] = pal[i].grn;
         pcxh.colors[n++] = pal[i].blu;
      }
      delete [] pal;
   }
   if( fwrite( &pcxh, sizeof(PCXHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // encode and write the image
   unsigned char *scanln = new unsigned char [ncols*pxlbytes];
   if( scanln == 0 )
      ABORT( f, xNOMEMORY );
   PcxEncoder pcxe( f, pcxh );
   if( pcxe.status() != xOKAY )
      ABORT( f, pcxe.status() );
   pcxe.init();
   for( int i=y1; i<=y2; i++ )
   {
      vga.getscanline( scanln, ncols, x1, i );
      pcxe.encode( scanln, ncols );
   }
   pcxe.term();
   delete scanln;

   // if 256-colors, append the palette
   if( ncolors == 256 )
   {
      fputc( 12, f );
      rgb *pal = new rgb [256];
      if( pal == 0 )
         ABORT( f, xNOMEMORY );
      vga.getpalette( pal, ncolors );
      for( int i=0; i<ncolors; i++ )
      {
         fputc( pal[i].red, f );
         fputc( pal[i].grn, f );
         fputc( pal[i].blu, f );
      }
      delete [] pal;
   }

   fclose( f );
   return xOKAY;
}

//..................Write an image to PCX file 'fn'

int WritePCX( ImgStore& img, rgb *pal, char *fn )
{
   FILE *f = fopen( fn, "wb" );
   if( f == 0 )
      ABORT( f, xIOERROR );

   // image metrics
   int nrows   = img.height();
   int ncols   = img.width();
   int nbits   = 1;
   int nplanes = 1;
   switch( img.depth() )
   {
      case 4 :
           nplanes = 4;
           break;
      case 8 :
           nbits = 8;
           break;
      case 24 :
           nbits = 8;
           nplanes = 3;
           break;
   }
   int pxlsize     = nbits * nplanes;
   // int pxlbytes = (nbits * nplanes + 7) / 8;
   int ncolors     = (pxlsize <= 8) ? 1 << pxlsize : 0;
   int planebytes  = ((ncols * nbits + 15) / 16) * 2;

   // initialize and write the PCX header
   PCXHEADER pcxh;
   pcxh.x1 = 0;
   pcxh.y1 = 0;
   pcxh.x2 = ncols - 1;
   pcxh.y2 = nrows - 1;
   pcxh.bitpx = nbits;
   pcxh.nplanes = nplanes;
   pcxh.bplin = planebytes;
   pcxh.hres = 100;  // a typical value
   pcxh.vres = 100;
   pcxh.scrnw = 0;
   pcxh.scrnh = 0;
   if( (ncolors <= 16) && (ncolors > 0) )
   {
      int n = 0;
      for( int i=0; i<ncolors; i++ )
      {
         pcxh.colors[n++] = pal[i].red;
         pcxh.colors[n++] = pal[i].grn;
         pcxh.colors[n++] = pal[i].blu;
      }
   }
   if( fwrite( &pcxh, sizeof(PCXHEADER), 1, f ) != 1 )
      ABORT( f, xIOERROR );

   // encode and write the image
   PcxEncoder pcxe( f, pcxh );
   if( pcxe.status() != xOKAY )
      ABORT( f, pcxe.status() );
   pcxe.init();
   for( int i=0; i<nrows; i++ )
   {
      pcxe.encode( img.get(i), ncols );
   }
   pcxe.term();

   // if 256-colors, append the palette
   if( ncolors == 256 )
   {
      fputc( 12, f );
      for( int i=0; i<ncolors; i++ )
      {
         fputc( pal[i].red, f );
         fputc( pal[i].grn, f );
         fputc( pal[i].blu, f );
      }
   }

   fclose( f );
   return xOKAY;
}
