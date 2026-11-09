//--------------------------------------------------------//
//                                                        //
//   File:    QWPG.CPP                                    //
//                                                        //
//   Desc:    WPG File Query Program                      //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "wpg.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "WordPerfect WPG Graphics File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QWPG  wpg_file  [ -p | -s ]\n" );
   printf( "\n" );
   printf( "-p includes palette in listing\n" );
   printf( "-s scans and lists all opcodes\n" );
   printf( ".WPG extension is assumed\n" );
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
      strcat( fn, ".wpg" );
   else if( *(p+1) == 0 )
      *p = 0;

   // list palette ?
   int lpal = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-p" ) == 0) ||
         (strcmp( argv[2], "-P" ) == 0) )
        lpal = 1;

   // scan for opcodes ?
   int scan = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-s" ) == 0) ||
         (strcmp( argv[2], "-S" ) == 0) )
        scan = 1;

   // open the file
   FILE *fwpg = fopen( fn, "rb" );
   if( fwpg == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   WPGHEADER wpgh;
   wpgh.get( fwpg );
   if( wpgh.validate() != 0 )
   {
      printf( "File '%s' is not a valid WPG file\n", fn );
      return 0;
   }

   printf( "Listing of WPG file '%s'\n", fn );
   printf( "\n" );
   wpgh.list();
   printf( "\n" );

   WPGTAG tag;
   RgbPalette * pal = WpgPalette();
   while( ! tag.get( fwpg ) )
   {
      if( scan )
      {
         tag.list();
         fseek( fwpg, tag.reclength, SEEK_CUR );
      }
      else
      {
         WPGBMHEADER bmh;
         switch( tag.rectype )
         {
            case wpgBitmap :
                 bmh.get( fwpg );
                 bmh.list();
                 fseek( fwpg,
                        tag.reclength-sizeof(WPGBMHEADER),
                        SEEK_CUR );
                 break;

            case wpgColorMap :
                 pal = WpgPalette( fwpg );
                 break;

            default :
                 fseek( fwpg, tag.reclength, SEEK_CUR );
                 break;
         }
      }
   }

   // list palette ?
   if( lpal )
   {
      printf( "\n" );
      for( int i=0; i<pal->ncolors; i++ )
         printf( "pal->colors[%d] = rgb(%d,%d,%d)\n",
                  i, pal->colors[i].red,
                     pal->colors[i].grn,
                     pal->colors[i].blu );
   }

   return 0;
}
