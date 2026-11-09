//--------------------------------------------------------//
//                                                        //
//   File:    QSRF.CPP                                    //
//                                                        //
//   Desc:    Sun Raster File Query Program               //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "srf.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "Sun Raster File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QSRF  srf_file  [ -p ]\n" );
   printf( "\n" );
   printf( "-p includes palette in listing\n" );
   printf( ".RF extension is assumed\n" );
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
      strcat( fn, ".rf" );
   else if( *(p+1) == 0 )
      *p = 0;

   // list palette ?
   int lpal = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-p" ) == 0) ||
         (strcmp( argv[2], "-P" ) == 0) )
        lpal = 1;

   // open the file
   FILE *fsrf = fopen( fn, "rb" );
   if( fsrf == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   SRFHEADER srfh;
   srfh.get( fsrf );

   printf( "Listing of SRF file '%s'\n", fn );
   printf( "\n" );
   srfh.list();
   printf( "\n" );

   // list palette ?
   if( lpal )
   {
      if( srfh.maplength == 0 )
         printf( "File does not have a color map\n" );
      else if( srfh.maptype == mapRaw )
         printf( "File has an undefined color map\n" );
      else
      {
         RgbPalette *pal = srfh.pal( fsrf );
         if( pal )
         {
            for( int i=0; i<pal->ncolors; i++ )
               printf( "RGB(%3d) = (%3d,%3d,%3d)\n", i,
                        pal->colors[i].red,
                        pal->colors[i].grn,
                        pal->colors[i].blu );
         }
         else
            printf( "Error reading file's color map\n" );
      }
   }

   return 0;
}
