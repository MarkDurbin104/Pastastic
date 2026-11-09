//--------------------------------------------------------//
//                                                        //
//   File:    QPCX.CPP                                    //
//                                                        //
//   Desc:    PCX File Query Program                      //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "pcx.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "PC Paintbrush PCX File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QPCX  pcx_file  [-p]\n" );
   printf( "\n" );
   printf( "-p includes palette in listing\n" );
   printf( ".PCX extension is assumed\n" );
   printf( "\n" );
}


//..................main

int main( int argc, char *argv[] )
{
   // check args
   if( (argc < 2) || (*argv[1] == '?') )
   {
      explain_pgm();
      return 0;
   }

   // create file name
   char fn[80];
   strcpy( fn, argv[1] );
   char *p = strchr( fn, '.' );
   if( p == 0 )
      strcat( fn, ".pcx" );
   else if( *(p+1) == 0 )
      *p = 0;

   // list palette too?
   int lpal = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-p" ) == 0) ||
         (strcmp( argv[2], "-P" ) == 0) )
        lpal = 1;

   // open the file
   FILE *fpcx = fopen( fn, "rb" );
   if( fpcx == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read the header and list
   PCXHEADER pcx;
   if( fread( &pcx, sizeof(PCXHEADER), 1, fpcx ) != 1 )
   {
      printf( "Error reading header of '%s'\n", fn );
      fclose( fpcx );
      return 0;
   }
   printf( "Listing of PCX file '%s'\n", fn );
   printf( "\n" );
   pcx.list();
   printf( "\n" );

   // compute color count
   int np = (pcx.nplanes == 0) ? 1 : pcx.nplanes;
   int nb = (pcx.bitpx == 0)   ? 1 : pcx.bitpx;
   int nbits = np * nb;
   long ncolors = 1L << nbits;
   printf( "Size of pixel in bits     = %d\n", nbits );
   printf( "Number of colors in image = %ld\n", ncolors );
   printf( "\n" );

   // list palette if requested
   if( lpal )
   {
      int pal_unlikely = 0;
      unsigned char *pal;

      if( nbits < 8 )
      {
         pal = new unsigned char [48];
         memcpy( pal, pcx.colors, 48 );
         if( pcx.version == 3 ) pal_unlikely = 1;
      }
      else if( nbits == 8 )
      {
         pal = new unsigned char [768];
         fseek( fpcx, -769, SEEK_END );
         pal_unlikely = (fgetc(fpcx) == 12) ? 0 : 1;
         fread( pal, 768, 1, fpcx );
      }
      else
      {
         pal = 0;
      }

      if( pal == 0 )
         printf( "Image is not palette based\n" );
      else
      {
         if( pal_unlikely )
            printf( "Note - valid palette is unlikely\n\n" );
         printf( "Image palette...........\n" );
         int n = 0;
         for( int i=0; i<ncolors; i++ )
            printf( "RGB(%3d) = (%3d,%3d,%3d)\n",
                    i, pal[n++], pal[n++], pal[n++] );
         delete pal;
      }
   }

   fclose( fpcx );
   return 0;
}
