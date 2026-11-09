//--------------------------------------------------------//
//                                                        //
//   File:    WRTXBM.CPP                                  //
//                                                        //
//   Desc:    Code to output a XBM file from a            //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "xbm.hpp"
#include "display.hpp"
#include "imgstore.hpp"

static int threshold = 127;

//..................Extract file name from path

void xtrname( char *path, char *name )
{
   int n = strlen( path ) - 1;
   int m = n;
   while( n > 0 )
   {
      if( path[n] == '.' )  m = n;
      if( path[n] == '\\' ) break;
      n--;
   }
   if( path[n] == '\\' ) n++;
   strncpy( name, path+n, m-n+1 );
   name[m-n+1] = 0;
   strlwr( name );
}

//..................Write VGA screen to XBM file 'fn'

int WriteXBM( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // image metrics
   int nrows   = y2 - y1 + 1;
   int ncols   = x2 - x1 + 1;
   int ncolors = vga.metric.ncolors;

   // scan line buffer and palette
   unsigned char *scanln = new unsigned char [ncols];
   rgb *vgapal = new rgb [ncolors];
   if( (scanln == 0) || (vgapal == 0) )
   {
      delete scanln;
      delete [] vgapal;
      return xNOMEMORY;
   }
   vga.getpalette( vgapal, ncolors );

   // XBM output file
   FILE *f = fopen( fn, "wt" );

   // initialize and write the XBM header
   char name[16];
   xtrname( fn, name );
   XBMHEADER xbm( ncols, nrows, name );
   xbm.put( f );

   // write the image
   XbmEncoder enc( f );
   enc.init();
   for( int i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      // convert to mono
      for( int j=0; j<ncols; j++ )
      {
         int lu = vgapal[ scanln[j] ].graylevel();
         scanln[j] = (lu > threshold) ? 1 : 0;
      }
      enc.encode( scanln, ncols );
   }
   enc.term();

   int retv = ferror( f );
   fclose( f );
   delete scanln;
   delete [] vgapal;
   return retv ? xIOERROR : xOKAY;
}

//..................Write an image to XBM file 'fn'

int WriteXBM( ImgStore& img, rgb *pal, char *fn )
{
   // image metrics
   int nrows = img.height();
   int ncols = img.width();
   int ncolors = 2;
   if( img.depth() == 24 ) ncolors = 0;
   else if( img.depth() > 1 ) ncolors = 256;

   // scan line buffer
   unsigned char *scanln = new unsigned char [ncols];
   if( scanln == 0 )
      return xNOMEMORY;

   // XBM output file
   FILE *f = fopen( fn, "wt" );

   // initialize and write the XBM header
   char name[16];
   xtrname( fn, name );
   XBMHEADER xbm( ncols, nrows, name );
   xbm.put( f );

   // write the image
   XbmEncoder enc( f );
   enc.init();
   for( int i=0; i<nrows; i++ )
   {
      unsigned char *p = img.get(i);

      // convert to monochrome
      if( ncolors == 0 )
      {
         int n = 0;
         for( int j=0; j<ncols; j++ )
         {
            rgb X( p[n++], p[n++], p[n++] );
            scanln[j] = (X.graylevel() > threshold) ? 1 : 0;
         }
      }
      else
      {
         for( int j=0; j<ncols; j++ )
         {
            int lu = pal[ p[j] ].graylevel();
            scanln[j] = (lu > threshold) ? 1 : 0;
         }
      }

      enc.encode( scanln, ncols );
   }
   enc.term();

   int retv = ferror( f );
   fclose( f );
   return retv ? xIOERROR : xOKAY;
}
