//--------------------------------------------------------//
//                                                        //
//   File:    QIMG.CPP                                    //
//                                                        //
//   Desc:    IMG File Query Program                      //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "img.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "GEM IMG File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QIMG  img_file\n" );
   printf( "\n" );
   printf( ".IMG extension is assumed\n" );
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
      strcat( fn, ".img" );
   else if( *(p+1) == 0 )
      *p = 0;

   // open the file
   FILE *fimg = fopen( fn, "rb" );
   if( fimg == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read the header and list
   IMGHEADER img;
   if( fread( &img, sizeof(IMGHEADER), 1, fimg ) != 1 )
   {
      printf( "Error reading header of '%s'\n", fn );
      fclose( fimg );
      return 0;
   }
   printf( "Listing of IMG file '%s'\n", fn );
   printf( "\n" );
   img.swap();
   img.list();

   fclose( fimg );
   return 0;
}
