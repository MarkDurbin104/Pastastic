//--------------------------------------------------------//
//                                                        //
//   File:    PACKBITS.CPP                                //
//                                                        //
//   Desc:    Encode and Decode functions for the         //
//            PackBits compression algorithm              //
//                                                        //
//--------------------------------------------------------//

#include "packbits.hpp"

//..................class PackBitsEncoder

int PackBitsEncoder::init( void )
{
   return status( );
}

int PackBitsEncoder::term( void )
{
   return status( );
}

int PackBitsEncoder::status( void )
{
   if( ferror(outfile) ) return xIOERROR;
   return xOKAY;
}

int PackBitsEncoder::encode( unsigned char *line, int size )
{
   int cnt = 0;  // bytes encoded

   while( cnt < size )
   {
      int i = cnt;
      int j = i + 1;
      int jmax = i + 126;
      if( jmax >= size ) jmax = size-1;

      if( i == size-1 )  //................last byte alone
      {
         fputc( 0, outfile );
         fputc( line[i], outfile );
         cnt++;
      }
      else if( line[i] == line[j] )  //....run
      {
         while( (j<jmax) && (line[j]==line[j+1]) )
            j++;
         fputc( i-j, outfile );
         fputc( line[i], outfile );
         cnt += j-i+1;
      }
      else  //.............................sequence
      {
         while( (j<jmax) && (line[j]!=line[j+1]) )
            j++;
         fputc( j-i, outfile );
         fwrite( line+i, j-i+1, 1, outfile );
         cnt += j-i+1;
      }
   }

   return status( );
}

//..................class PackBitsDecoder

int PackBitsDecoder::init( void )
{
   return status( );
}

int PackBitsDecoder::term( void )
{
   return status( );
}

int PackBitsDecoder::status( void )
{
   if( feof(infile) )   return xENDOFFILE;
   if( ferror(infile) ) return xIOERROR;
   return xOKAY;
}

int PackBitsDecoder::decode( unsigned char *line, int size )
{
   int n = 0;            // number of bytes decoded

   while( n < size )
   {
      int ix = fgetc( infile );   // get index byte
      if( feof( infile ) ) break;

      char cx = ix;
      if( cx == -128 ) { cx=0; }

      if( cx < 0 )  //.............run
      {
         int i = 1 - cx;
         char ch = fgetc( infile );
         while( i-- )
         {
            // test for buffer overflow
            if( n == size ) return -1;
            line[n++] = ch;
         }
      }
      else  //.....................seq
      {
         int i = cx + 1;
         while( i-- )
         {
            // test for buffer overflow
            if( n == size ) return -1;
            line[n++] = fgetc( infile );
         }
      }
   }

   return feof( infile );
}
