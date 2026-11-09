//--------------------------------------------------------//
//                                                        //
//   File:    QMSP.CPP                                    //
//                                                        //
//   Desc:    MSP File Query Program                      //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "msp.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "MS Paint MSP File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QMSP  msp_file  [-t]\n" );
   printf( "\n" );
   printf( "-t includes scan table listing"
           " if format is version 2\n" );
   printf( ".MSP extension is assumed\n" );
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
      strcat( fn, ".msp" );
   else if( *(p+1) == 0 )
      *p = 0;

   // list scan table too?
   int ltbl = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-t" ) == 0) ||
         (strcmp( argv[2], "-T" ) == 0) )
        ltbl = 1;

   // open the file
   FILE *fmsp = fopen( fn, "rb" );
   if( fmsp == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read the header and list
   MSPHEADER msp;
   if( fread( &msp, sizeof(MSPHEADER), 1, fmsp ) != 1 )
   {
      printf( "Error reading header of '%s'\n", fn );
      fclose( fmsp );
      return 0;
   }
   printf( "Listing of MSP file '%s'\n", fn );
   printf( "\n" );
   msp.list();
   printf( "\n" );

   // compute actual checksum for comparison with header
   unsigned short *ix = (unsigned short *) &msp.key1;
   unsigned short cksum = 0;
   for( int i=0; i<12; i++ )
      cksum ^= *ix++;

   // indicate version and checksum
   int version = 0;
   if( (msp.key1==V1KEY1) && (msp.key2==V1KEY2) )
   {
      printf( "Format Version = 1\n" );
      version = 1;
   }
   else if( (msp.key1==V2KEY1) && (msp.key2==V2KEY2) )
   {
      printf( "Format Version = 2\n" );
      version = 2;
   }
   else
      printf( "Format keys are invalid\n" );
   printf( "Computed Header Checksum = %u\n", cksum );
   printf( "\n" );

   // if requested, list scan length table
   if( ltbl )
   {
      if( version == 1 )
         printf( "Version 1 has no scan length table\n" );
      else if ( version == 2 )
      {
         printf( "Listing of encoded scan line lengths:\n" );
         for( i=0; i<msp.height; i++ )
         {
            unsigned int sclen;
            fread( &sclen, 2, 1, fmsp );
            printf( "%3d = %u\n", i, sclen );
         }
      }
   }

   fclose( fmsp );
   return 0;
}
