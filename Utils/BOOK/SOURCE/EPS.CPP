//--------------------------------------------------------//
//                                                        //
//   File:    EPS.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Encapsulated PostScript format              //
//                                                        //
//--------------------------------------------------------//

#include "eps.hpp"

static char *p0 = "%!";
static char *p1 = "%";
static char *p2 = "%%";

//..................EPS Prolog/Epilog

int EPSPROLOG::put( FILE *f )
{
   fprintf( f, "%sPS-Adobe-3.0 EPSF-3.0\n", p0 );
   if( title && *title )
      fprintf( f, "%sTitle: %s\n", p2, title );
   if( creator && *creator )
      fprintf( f, "%sCreator: %s\n", p2, creator );
   fprintf( f, "%sBoundingBox: %d %d %d %d\n",
            p2, llx, lly, urx, ury );
   fprintf( f, "%sEndComments\n", p2 );
   return ferror(f);
}

int EPSEPILOG::put( FILE *f )
{
   fprintf( f, "showpage\n" );
   fprintf( f, "%sTrailer\n", p2 );
   return ferror(f);
}

//..................Image Prolog/Epilog

int IMGPROLOG::put( FILE *f )
{
   fprintf( f, "%sBeginProlog\n", p2 );
   fprintf( f, "/width %d def\n", width );
   fprintf( f, "/height %d def\n", height );
   fprintf( f, "/depth %d def\n", depth );
   fprintf( f, "/xorg %d def\n", xorg );
   fprintf( f, "/yorg %d def\n", yorg );
   int rwbytes = (width + 7) / 8;
   fprintf( f, "/rwbytes %d def\n", rwbytes );
   fprintf( f, "/scanline rwbytes string def\n" );
   fprintf( f, "%sEndProlog\n", p2 );
   fprintf( f, "%s begin image.....\n", p1 );
   fprintf( f, "gsave\n" );
   fprintf( f, "xorg 756 yorg sub height sub translate\n" );
   fprintf( f, "width height scale\n" );
   fprintf( f, "width height depth\n" );
   fprintf( f, "[width 0 0 height neg 0 height]\n" );
   fprintf( f, "{currentfile scanline readhexstring pop}\n" );
   fprintf( f, "image\n" );
   return ferror(f);
}

int IMGEPILOG::put( FILE *f )
{
   fprintf( f, "grestore\n" );
   fprintf( f, "%s .....end image\n", p1 );
   return ferror(f);
}

//..................class EpsEncoder

EpsEncoder::EpsEncoder( FILE *f_out, int w, rgb *pal )
{
   cond = xOKAY;
   eps_file = f_out;
   impal = pal;
   width = w;
   scanln = new unsigned char [width];
   if( scanln )
   {
      memset( scanln, 0, width );
      dit = new DiffusionDither( 127, width );
      if( ! dit )
         cond = xNOMEMORY;
   }
   else
      cond = xNOMEMORY;
}

EpsEncoder::~EpsEncoder( )
{
   delete scanln;
   delete dit;
}

int EpsEncoder::init( void )
{
   nout = 0;
   return status();
}

int EpsEncoder::term( void )
{
   if( nout != 0 ) fprintf( eps_file, "\n" );
   return status();
}

int EpsEncoder::status( void )
{
   if( cond == xOKAY )
      if( ferror( eps_file ) )
         cond = xIOERROR;
   return cond;
}

void EpsEncoder::writeln( void )
{
   int mask = 0x80;
   int byte = 0;

   for( int i=0; i<width; i++ )
   {
      if( scanln[i] )
         byte |= mask;
      if( (mask >>= 1) == 0 )
      {
         fprintf( eps_file, "%02X", byte );
         if( status() != xOKAY ) return;
         mask = 0x80;
         byte = 0;
         nout += 2;
         if( nout == 72 )
         {
            fprintf( eps_file, "\n" );
            nout = 0;
         }
      }
   }

   if( mask != 0x80 )
   {
      fprintf( eps_file, "%02X", byte );
      nout += 2;
      if( nout == 72 )
      {
         fprintf( eps_file, "\n" );
         nout = 0;
      }
   }
}

int EpsEncoder::encode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      // convert pixel indexes to gray levels
      for( int i=0; i<npxls; i++ )
      {
         int j = buf[i];
         scanln[i] = impal[j].graylevel();
      }

      // dither the gray values
      dit->dither( scanln, npxls );

      // output the PS source
      writeln();
   }
   return status();
}
