//--------------------------------------------------------//
//                                                        //
//   File:    WRTEPS.CPP                                  //
//                                                        //
//   Desc:    Code to output an EPS file from a           //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "eps.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Write VGA screen to EPS file 'fn'

int WriteEPS( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // image metrics
   int nrows   = y2 - y1 + 1;
   int ncols   = x2 - x1 + 1;
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

   // EPS output file
   FILE *f = fopen( fn, "wb" );

   // Prolog code
   EPSPROLOG epsP( fn, "WrtEps.Cpp", 0, 0, ncols, nrows );
   epsP.put( f );
   IMGPROLOG imgP( ncols, nrows, 1, 0, 0 );
   imgP.put( f );

   // write the image
   EpsEncoder enc( f, ncols, vgapal );
   enc.init();
   for( int i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      enc.encode( scanln, ncols );
   }
   enc.term();

   // Epilog code
   IMGEPILOG imgE;
   imgE.put( f );
   EPSEPILOG epsE;
   epsE.put( f );

   int retv = ferror( f );
   fclose( f );
   delete scanln;
   delete [] vgapal;
   return retv ? xIOERROR : xOKAY;
}

//..................Write an image to EPS file 'fn'

int WriteEPS( ImgStore& img, rgb *pal, char *fn )
{
   // image metrics - 24 bit not supported
   int ncols   = img.width();
   int nrows   = img.height();

   // scan line buffer
   unsigned char *scanln = new unsigned char [ncols];
   if( scanln == 0 )
   {
      delete scanln;
      return xNOMEMORY;
   }

   // EPS output file
   FILE *f = fopen( fn, "wb" );

   // Prolog code
   EPSPROLOG epsP( fn, "WrtEps.Cpp", 0, 0, ncols, nrows );
   epsP.put( f );
   IMGPROLOG imgP( ncols, nrows, 1, 0, 0 );
   imgP.put( f );

   // write the image
   EpsEncoder enc( f, ncols, pal );
   enc.init();
   for( int i=0; i<nrows; i++ )
   {
      img.cpy( scanln, i );
      enc.encode( scanln, ncols );
      if( (i & 7) == 0 ) printf( "." );
   }
   enc.term();

   // Epilog code
   IMGEPILOG imgE;
   imgE.put( f );
   EPSEPILOG epsE;
   epsE.put( f );

   int retv = ferror( f );
   fclose( f );
   delete scanln;
   return retv ? xIOERROR : xOKAY;
}
