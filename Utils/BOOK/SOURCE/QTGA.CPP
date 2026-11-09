//--------------------------------------------------------//
//                                                        //
//   File:    QTGA.CPP                                    //
//                                                        //
//   Desc:    TARGA File Query Program                    //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "tga.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "TARGA Graphics File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QTGA  tga_file  [ -p ]\n" );
   printf( "\n" );
   printf( "-p includes palette in listing\n" );
   printf( ".TGA extension is assumed\n" );
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
      strcat( fn, ".tga" );
   else if( *(p+1) == 0 )
      *p = 0;

   // list palette ?
   int lpal = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-p" ) == 0) ||
         (strcmp( argv[2], "-P" ) == 0) )
        lpal = 1;

   // open the file
   FILE *ftga = fopen( fn, "rb" );
   if( ftga == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   TGAHEADER tgah;
   tgah.get( ftga );

   printf( "Listing of TGA file '%s'\n", fn );
   printf( "\n" );
   tgah.list();
   printf( "\n" );

   // is there an ID string?
   if( tgah.idlen > 0 )
   {
      while( tgah.idlen-- > 0 )
         printf( "%c", fgetc(ftga) );
      printf( "\n" );
      printf( "\n" );
   }

   // list palette ?
   if( lpal )
   {
      if( tgah.cmtype == 0 )
      {
         printf( "TGA file is not color mapped\n" );
      }
      else
      {
         rgb * pal = tgah.pal( ftga );
         int ncolors = tgah.cmorg + tgah.cmcnt;
         for( int i=0; i<ncolors; i++ )
            printf( "RGB(%3d) = (%3d,%3d,%3d)\n", i,
                     pal->colors[i].red,
                     pal->colors[i].grn,
                     pal->colors[i].blu );
      }
   }

   return 0;
}
