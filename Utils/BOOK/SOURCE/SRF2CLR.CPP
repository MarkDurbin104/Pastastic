//--------------------------------------------------------//
//                                                        //
//   File:    SRF2CLR.CPP                                 //
//                                                        //
//   Desc:    Program to colorize Monochrome  SUN         //
//            Raster Files.                               //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"
#include "ctype.h"

#include "color.hpp"
#include "srf.hpp"

//..................Program globals

char        ifn[80],            // path to input SRF file
            ofn[80];            // path to output SRF file

rgb         cmin,               // min/max palette colors
            cmax;

//..................Exit with a message

void exit_pgm( char *msg )
{
   printf( "%s\n", msg );
   exit( 0 );
}

//..................Program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "..............Sun Raster File Colorizer.............\n" );
   printf( "\n" );
   printf( "Usage:      SRF2CLR  srf_in  srf_out  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h         = display program usage\n" );
   printf( "           -minR,G,B  = palette min color\n" );
   printf( "           -maxR,G,B  = palette max color\n" );
   printf( "\n" );
   printf( "Default extension is .RF\n" );
   printf( "Default colorization is 5-level gray scale\n" );
   printf( "\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................Process pgm argument list

void process_args( int argc, char *argv[] )
{
   // establish default values
   ifn[0] = 0;
   ofn[0] = 0;
   cmin = rgb( 0, 0, 0 );
   cmax = rgb( 255, 255, 255 );

   // process the program's argument list
   for( int i=1; i<argc; i++ )
   {
      if( (*argv[i] == '-') || (*argv[i] == '/') )
      {
         int r, g, b;
         strupr( argv[i] );
         if( strncmp( argv[i], "-MIN", 4 ) == 0 )
         {
            char *p = argv[i] + 4;
            sscanf( p, "%d,%d,%d", &r, &g, &b );
            cmin = rgb( r, g, b );
         }
         else if( strncmp( argv[i], "-MAX", 4 ) == 0 )
         {
            char *p = argv[i] + 4;
            sscanf( p, "%d,%d,%d", &r, &g, &b );
            cmax = rgb( r, g, b );
         }
         else
            printf( "Unknown switch '%s' ignored\n", argv[i] );
      }
      else  // presumably a file identifier
      {
         if( ifn[0] == 0 )
         {
            strcpy( ifn, argv[i] );
            char *p = strchr( ifn, '.' );
            if( p == 0 )
               strcat( ifn, ".rf" );
            else if( *(p+1) == 0 )
               *p = 0;
         }
         else if( ofn[0] == 0 )
         {
            strcpy( ofn, argv[i] );
            char *p = strchr( ofn, '.' );
            if( p == 0 )
               strcat( ofn, ".rf" );
            else if( *(p+1) == 0 )
               *p = 0;
         }
      }
   }

   // were file names specified?
   if( (ifn[0] == 0) || (ofn[0] == 0) )
   {
      explain_pgm();
      exit( 0 );
   }
}

//..................Write the color palette

void wrt_pal( FILE *f )
{
   int dr = cmax.red;  dr -= cmin.red;
   int dg = cmax.grn;  dg -= cmin.grn;
   int db = cmax.blu;  db -= cmin.blu;

   for( int i=0; i<5; i++ )
   {
      int r = cmin.red;
      if( dr != 0 )
      {
         int x = dr;
         x *= i;
         x /= 4;
         r += x;
      }
      int g = cmin.grn;
      if( dg != 0 )
      {
         int x = dg;
         x *= i;
         x /= 4;
         g += x;
      }

      int b = cmin.blu;
      if( db != 0 )
      {
         int x = db;
         x *= i;
         x /= 4;
         b += x;
      }
      fputc( r, f );
      fputc( g, f );
      fputc( b, f );
      printf( "color[%d] = rgb(%d,%d,%d)\n",
               i, r, g, b );
   }
}

//..................Process the files

void colorize_srf( void )
{
   FILE *fi = fopen( ifn, "rb" );
   if( fi == 0 )
      exit_pgm( "Input file not found" );
   FILE *fo = fopen( ofn, "wb" );

   // get input header and palette
   SRFHEADER ihdr;
   ihdr.get( fi );
   if( ihdr.iden != RF_IDEN )
      exit_pgm( "Input file not a Sun Raster File" );
   if( ihdr.imdepth > 1 )
      exit_pgm( "Input file not a monochrome Sun Raster File" );
   // skip over any color map
   if( ihdr.maplength > 0 )
      fseek( fi, ihdr.maplength, SEEK_CUR );

   // put output header and palette
   SRFHEADER ohdr;
   ohdr.iden = RF_IDEN;
   ohdr.imwidth = ihdr.imwidth / 2;
   ohdr.imheight = ihdr.imheight / 2;
   ohdr.imdepth = 8;
   ohdr.imtype = imRle;
   ohdr.imlength = 0;
   ohdr.maptype = mapRgb;
   ohdr.maplength = 15;
   ohdr.put( fo );
   wrt_pal( fo );

   // Perform the procedure

   unsigned char *iln1, *iln2, *oln;
   iln1 = new unsigned char [ int(ihdr.imwidth) ];
   iln2 = new unsigned char [ int(ihdr.imwidth) ];
   oln  = new unsigned char [ int(ohdr.imwidth) ];
   if( (iln1==0) || (iln2==0) || (oln==0) )
      exit_pgm( "Out of memory allocating buffers" );

   SrfDecoder srfin( fi, ihdr );
   SrfEncoder srfout( fo, ohdr );

   if( (srfin.status() != xOKAY) || (srfout.status() != xOKAY) )
   {
      printf( "in.status() = %d\n", srfin.status() );
      printf( "out.status() = %d\n", srfout.status() );
      exit_pgm( "Error instantiating encoder/decoder" );
   }

   printf( "Converting %s to %s...", ifn, ofn );

   srfin.init();
   srfout.init();

   int icols = int( ihdr.imwidth );
   int ocols = int( ohdr.imwidth );
   int orows = int( ohdr.imheight );
   for( int i=0; i<orows; i++ )
   {
      srfin.decode( iln1, icols );
      srfin.decode( iln2, icols );
      for( int j=0; j<ocols; j++ )
      {
         // since 0=white and 1=black
         // we invert the pixel value
         oln[j]  = 4;
         oln[j] -= iln1[j*2];
         oln[j] -= iln1[j*2+1];
         oln[j] -= iln2[j*2];
         oln[j] -= iln2[j*2+1];
      }
      srfout.encode( oln, ocols );
      // let the world know we're alive...
      if( ((i+1) % 80) == 0 ) printf( "." );
   }

   srfin.term();
   srfout.term();

   // update header image length field
   long n = ftell( fo );
   n -= sizeof(SRFHEADER) + 15;
   ohdr.imlength = n;
   fseek( fo, 0, SEEK_SET );
   ohdr.put( fo );

   fclose( fi );
   fclose( fo );

   printf( "done\n" );
}

//..................Main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   colorize_srf( );

   return 0;
}
