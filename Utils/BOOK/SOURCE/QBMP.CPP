//--------------------------------------------------------//
//                                                        //
//   File:    QBMP.CPP                                    //
//                                                        //
//   Desc:    Program to list information in a            //
//            Windows BMP Graphics File                   //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "bmp.hpp"

//..................program usage

void explain_pgm( void )
{
   printf( "\n" );
   printf( "Windows BMP File Query Program\n" );
   printf( "\n" );
   printf( "Usage:  QBMP  bmp_file  [-p]\n" );
   printf( "\n" );
   printf( "-p includes palette in listing\n" );
   printf( ".BMP extension is assumed\n" );
   printf( "\n" );
}

//..................listing of core-based format

void core_listing( FILE *fbmp, int listpal )
{
   xBITMAPCOREHEADER bmch;
   if( fread(&bmch,sizeof(xBITMAPCOREHEADER),1,fbmp) != 1 )
   {
      printf( "Error reading xBITMAPCOREHEADER\n" );
      return;
   }
   bmch.list();

   if( listpal )
   {
      // list palette
      printf( "\n" );
      int ncolors = 0;
      switch( bmch.bcBitCount )
      {
         case 1 : ncolors = 2;   break;
         case 4 : ncolors = 16;  break;
         case 8 : ncolors = 256; break;
      }
      for( int i=0; i<ncolors; i++ )
      {
         xRGBTRIPLE rgb;
         fread( &rgb, sizeof(xRGBTRIPLE), 1, fbmp );
         rgb.list( i );
      }
   }
}

//..................listing of info-based format

void info_listing( FILE *fbmp, int listpal )
{
   xBITMAPINFOHEADER bmih;
   if( fread(&bmih,sizeof(xBITMAPINFOHEADER),1,fbmp) != 1 )
   {
      printf( "Error reading xBITMAPINFOHEADER\n" );
      return;
   }
   bmih.list();

   if( listpal )
   {
      // list palette
      printf( "\n" );
      int ncolors = 0;
      switch( bmih.biBitCount )
      {
         case 1 : ncolors = 2;   break;
         case 4 : ncolors = 16;  break;
         case 8 : ncolors = 256; break;
      }
      for( int i=0; i<ncolors; i++ )
      {
         xRGBQUAD rgb;
         fread( &rgb, sizeof(xRGBQUAD), 1, fbmp );
         rgb.list( i );
      }
   }
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
      strcat( fn, ".bmp" );
   else if( *(p+1) == 0 )
      *p = 0;

   // open file
   FILE *fbmp = fopen( fn, "rb" );
   if( fbmp == 0 )
   {
      printf( "File '%s' not found\n", fn );
      return 0;
   }

   // read header and check
   xBITMAPFILEHEADER bmfh;
   if( fread(&bmfh,sizeof(xBITMAPFILEHEADER),1,fbmp) != 1 )
   {
      printf( "Error reading file '%s'\n", fn );
      return 0;
   }
   if( bmfh.bfType != BMP_SIGNATURE_WORD )
   {
      printf( "File '%s' is not a valid BMP file\n", fn );
      return 0;
   }

   printf( "Listing of BMP file '%s'\n", fn );
   printf( "\n" );
   bmfh.list();
   printf( "\n" );

   // determine which format version is used
   // from structure size field value
   long offset = ftell( fbmp );
   long nbytes = 0;
   fread( &nbytes, sizeof(long), 1, fbmp );
   fseek( fbmp, offset, SEEK_SET );

   // list palette ?
   int lpal = 0;
   if( argc > 2 )
     if( (strcmp( argv[2], "-p" ) == 0) ||
         (strcmp( argv[2], "-P" ) == 0) )
        lpal = 1;

   // list bitmap header and palette
   if( nbytes == sizeof(xBITMAPCOREHEADER) )
      core_listing( fbmp, lpal );
   else if( nbytes == sizeof(xBITMAPINFOHEADER) )
      info_listing( fbmp, lpal );
   else
      printf( "Format error or not a BMP file\n" );

   fclose( fbmp );
   return 0;
}
