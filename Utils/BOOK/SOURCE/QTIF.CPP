//--------------------------------------------------------//
//                                                        //
//   File:    QTIF.CPP                                    //
//                                                        //
//   Desc:    TIFF File Query Program                     //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "conio.h"

#include "tif.hpp"

//..................program globals

char fn[80];
int  list;
int  pglen;

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( ".............TIFF File Query Program..............\n" );
   printf( "\n" );
   printf( "Usage:      QTIF  tif_file  [ switches ]\n" );
   printf( "\n" );
   printf( "Switches:  -h      = display program usage\n" );
   printf( "           -d      = list image definition\n" );
   printf( "           -lNN    = page length is NN lines\n" );
   printf( "\n" );
   printf( ".TIF extension assumed\n" );
   printf( "Continuous page length assumed\n" );
   printf( "...................................................\n" );
   printf( "\n" );
}

//..................process args

void process_args( int argc, char *argv[] )
{
   // establish default values
   fn[0] = 0;
   list  = 0;
   pglen = 0;

   // process the program's argument list
   for( int i=1; i<argc; i++ )
   {
      if( (*argv[i] == '-') || (*argv[i] == '/') )
      {
         char sw = *(argv[i] + 1);
         switch( toupper(sw) )
         {
            case 'H' :
               explain_pgm();
               exit( 0 );
               break;

            case 'L' :
               sscanf( argv[i]+2, "%d", &pglen );
               break;

            case 'D' :
               list = 1;
               break;
            default:
               printf( "Unknown switch '%s' ignored\n",
                        argv[i] );
               break;
         }
      }
      else  // presumably a file identifier
      {
         strcpy( fn, argv[i] );
         char *p = strchr( fn, '.' );
         if( p == 0 )
            strcat( fn, ".tif" );
         else if( *(p+1) == 0 )
            *p = 0;
      }
   }

   // was a file name specified?
   if( fn[0] == 0 )
   {
      explain_pgm();
      exit( 0 );
   }
}

//..................check for end-of-page

static int nlines = 0;

void more( int n )
{
   if( pglen > 0 )
   {
      nlines += n;
      if( nlines > pglen )
      {
         nlines = 0;
         printf( "(more...)\n" );
         getch();
      }
   }
}

//..................main

int main( int argc, char *argv[] )
{
   process_args( argc, argv );

   // open the file
   FILE *ftif = fopen( fn, "rb" );
   if( ftif == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read header and validate
   TIFFHEADER tifh;
   tifh.get( ftif );
   if( ! tifh.isvalid() )
   {
      printf( "Error - file is not a TIFF file\n" );
      exit( 0 );
   }

   printf( "Listing of TIF file '%s'\n", fn );
   printf( "\n" );
   tifh.list();
   more( 5 );

   // list each TIF subfile
   long ifd_offset = tifh.ifdofs;
   while( ifd_offset )
   {
      // seek to start
      fseek( ftif, ifd_offset, SEEK_SET );
      long cur_offset = ifd_offset;

      // get IFD entry count
      unsigned short nentries;
      fread( &nentries, 2, 1, ftif );
      if( ReverseByteOrder() )
         nentries = rev_word( nentries );

      // printf subfile header
      more( 2 );
      printf( "\nIFD at Offset %ld has %d Entries.....\n",
               ifd_offset, nentries );

      // list each IFD entrie
      for( int i=0; i<nentries; i++ )
      {
         more( 5 );
         IFDENTRY ifde;
         ifde.get( ftif );
         printf( "\n" );
         ifde.list();
      }

      // get offset to next subfile
      fread( &ifd_offset, 4, 1, ftif );
      if( ReverseByteOrder() )
         ifd_offset = rev_dword( ifd_offset );

      // create and list image def?
      if( list )
      {
         more( 999 );
         fseek( ftif, cur_offset, SEEK_SET );
         TIFFIMAGEDEF idef;
         idef.get( ftif );
         printf( "\n" );
         idef.list( );
      }
   }

   return 0;
}
