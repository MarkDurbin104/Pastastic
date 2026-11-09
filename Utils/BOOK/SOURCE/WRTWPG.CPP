//--------------------------------------------------------//
//                                                        //
//   File:    WRTWPG.CPP                                  //
//                                                        //
//   Desc:    Code to output a WPG file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "wpg.hpp"
#include "display.hpp"
#include "imgstore.hpp"
#include "iscale.h"

//..................Write VGA screen to WPG file 'fn'

int WriteWPG( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // various image metrics
   int ncols = x2 - x1 + 1;
   int nrows = y2 - y1 + 1;
   int nbits = vga.metric.nplanes * vga.metric.nbits;
   int nclrs = vga.metric.ncolors;
   rgb *pal = new rgb[nclrs];
   unsigned char *pxl = new unsigned char [ncols];
   if( (pal == 0) || (pxl == 0) )
   {
      delete pal;
      delete pxl;
      return xNOMEMORY;
   }
   vga.getpalette( pal, nclrs );

   // file header
   WPGHEADER wpg( 22 );

   // bitmap header
   WPGBMHEADER hdr( ncols, nrows, nbits );

   // begin WPG data
   int wpuW = iscale( ncols, 1200, hdr.bmxres );
   int wpuH = iscale( nrows, 1200, hdr.bmyres );
   WPGBEGIN bgn( wpuW, wpuH );

   // the four object tags
   WPGTAG bgntag( wpgBegin, 6 );
   WPGTAG clrtag( wpgColorMap, nclrs*3+4 );
   WPGTAG maptag( wpgBitmap, 999999L );
   WPGTAG endtag( wpgEnd, 0 );

   // Write the WPG file
   FILE *f = fopen( fn, "wb" );

   // file header
   wpg.put( f );

   // begin WPG data
   bgntag.put( f,0 );
   bgn.put( f );

   // define color map
   clrtag.put( f, 0 );
   int ibgn = 0;
   fwrite( &ibgn, 2, 1, f );
   fwrite( &nclrs, 2, 1, f );
   for( int i=0; i<nclrs; i++ )
   {
      fputc( pal[i].red, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].blu, f );
   }

   // bitmap header and data
   long maptagofs = ftell( f );
   maptag.put( f, 4 );

   long mapofs1 = ftell( f );
   hdr.put( f );
   WpgEncoder enc( f, hdr );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      vga.getscanline( pxl, ncols, x1, y1+i );
      enc.encode( pxl, ncols );
   }
   enc.term();
   long mapofs2 = ftell( f );

   // end WPG data
   endtag.put( f, 0 );

   // update bitmap tag length field
   fseek( f, maptagofs, SEEK_SET );
   maptag.reclength = mapofs2 - mapofs1;
   maptag.put( f, 4 );

   int retv = ferror( f );
   fclose( f );
   return retv;
}

//..................Write an image to WPG file 'fn'

int WriteWPG( ImgStore& img, rgb *pal, char *fn )
{
   // various image metrics
   int ncols = img.width();
   int nrows = img.height();
   int nclrs = 1 << img.depth();
   int nbits = img.depth();

   // file header
   WPGHEADER wpg( 22 );

   // bitmap header
   WPGBMHEADER hdr( ncols, nrows, nbits );

   // begin WPG data
   int wpuW = iscale( ncols, 1200, hdr.bmxres );
   int wpuH = iscale( nrows, 1200, hdr.bmyres );
   WPGBEGIN bgn( wpuW, wpuH );

   // the four object tags
   WPGTAG bgntag( wpgBegin, 6 );
   WPGTAG clrtag( wpgColorMap, nclrs*3+4 );
   WPGTAG maptag( wpgBitmap, 0 );
   WPGTAG endtag( wpgEnd, 0 );

   // Write the WPG file
   FILE *f = fopen( fn, "wb" );

   // file header
   wpg.put( f );

   // begin WPG data
   bgntag.put( f, 0 );
   bgn.put( f );

   // define color map
   clrtag.put( f, 0 );
   int ibgn = 0;
   fwrite( &ibgn, 2, 1, f );
   fwrite( &nclrs, 2, 1, f );
   for( int i=0; i<nclrs; i++ )
   {
      fputc( pal[i].red, f );
      fputc( pal[i].grn, f );
      fputc( pal[i].blu, f );
   }

   // bitmap header and data
   long maptagofs = ftell( f );
   maptag.put( f, 4 );

   long mapofs1 = ftell( f );
   hdr.put( f );
   WpgEncoder enc( f, hdr );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      enc.encode( img.get(i), ncols );
   }
   enc.term();
   long mapofs2 = ftell( f );

   // end WPG data
   endtag.put( f, 0 );

   // update bitmap tag length field
   fseek( f, maptagofs, SEEK_SET );
   maptag.reclength = mapofs2 - mapofs1;
   maptag.put( f, 4 );

   int retv = ferror( f );
   fclose( f );
   return retv;
}
