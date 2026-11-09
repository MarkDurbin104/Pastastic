//--------------------------------------------------------//
//                                                        //
//   File:    MACPNT.CPP                                  //
//                                                        //
//   Desc:    Structures for the MacPaint format          //
//                                                        //
//--------------------------------------------------------//

#include "macpnt.hpp"

//.................struct MACBINHDR

int MACBINHDR::get( FILE *f )
{
   return (fread( &version, sizeof(MACBINHDR), 1, f ) == 1)
          ? 0 : -1;
}

int MACBINHDR::put( FILE *f )
{
   return (fwrite( &version, sizeof(MACBINHDR), 1, f ) == 1)
          ? 0 : -1;
}

//.................struct MACPNTHDR

int MACPNTHDR::get( FILE *f )
{
   return (fread( &version, sizeof(MACPNTHDR), 1, f ) == 1)
          ? 0 : -1;
}

int MACPNTHDR::put( FILE *f )
{
   return (fwrite( &version, sizeof(MACPNTHDR), 1, f ) == 1)
          ? 0 : -1;
}

//.................class MacPntDecoder

int MacPntDecoder::readln( void )
{
   int n = 0;            // number of bytes decoded

   while( (n < MACLNWIDTH) && ! feof(MacFile) )
   {
      int ix = fgetc( MacFile );   // get index byte
      if( ix < 0 ) return xIOERROR;

      char cx = ix;
      if( cx == -128 ) continue;

      if( cx < 0 )  //.............run
      {
         int i = 1 - cx;
         char ch = fgetc( MacFile );
         while( i-- )
            if( n < MACLNWIDTH )
               MacBuf[n++] = ch;
      }
      else  //.....................seq
      {
         int i = cx + 1;
         while( i-- )
            if( n < MACLNWIDTH )
               MacBuf[n++] = fgetc( MacFile );
      }
   }
   return feof( MacFile ) ? xENDOFFILE : xOKAY;
}

void MacPntDecoder::unpack( unsigned char *buf, int npxls )
{
   int MacMask = 0x80;
   int MacByte = 0;
   for( int i=0; i<npxls; i++ )
   {
      buf[i] = (MacBuf[MacByte] & MacMask) ?
                MacFg : MacBg;
      if( (MacMask >>= 1) == 0 )
      {
         MacByte++;
         MacMask = 0x80;
      }
   }
}

int MacPntDecoder::init( void )
{
   return status();
}

int MacPntDecoder::term( void )
{
   return status();
}

int MacPntDecoder::status( void )
{
   if( ferror(MacFile) ) return xIOERROR;
   if( feof(MacFile) )   return xENDOFFILE;
   return xOKAY;
}

int MacPntDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      readln();
      unpack( buf, npxls );
   }
   return status();
}

//.................class MacPntEncoder

int MacPntEncoder::writeln( void )
{
   int cnt = 0;  // bytes encoded

   while( cnt < MACLNWIDTH )
   {
      int i = cnt;
      int j = i + 1;
      int jmax = i + 126;
      if( jmax >= MACLNWIDTH ) jmax = MACLNWIDTH-1;

      if( i == MACLNWIDTH-1 )  //..........last byte alone
      {
         fputc( 0, MacFile );
         fputc( MacBuf[i], MacFile );
         cnt++;
      }
      else if( MacBuf[i] == MacBuf[j] )  //......run
      {
         while( (j<jmax) && (MacBuf[j]==MacBuf[j+1]) )
            j++;
         fputc( i-j, MacFile );
         fputc( MacBuf[i], MacFile );
         cnt += j-i+1;
      }
      else  //.............................sequence
      {
         while( (j<jmax) && (MacBuf[j]!=MacBuf[j+1]) )
            j++;
         fputc( j-i, MacFile );
         fwrite( MacBuf+i, j-i+1, 1, MacFile );
         cnt += j-i+1;
      }
   }
   return xOKAY;
}

void MacPntEncoder::pack( unsigned char *buf, int npxls )
{
   memset( MacBuf, 0, MACLNWIDTH );
   int MacMask = 0x80;
   int MacByte = 0;
   for( int i=0; i<npxls; i++ )
   {
      if( buf[i] == MacFg )
         MacBuf[MacByte] |= MacMask;
      if( (MacMask >>= 1) == 0 )
      {
         MacMask = 0x80;
         MacByte++;
         if( MacByte == MACLNWIDTH )
            break;
      }
   }
}

int MacPntEncoder::init( void )
{
   MacLnCnt = 0;
   return status();
}

int MacPntEncoder::term( void )
{
   while( (MacLnCnt++ < 720) && (status() == xOKAY) )
   {
      fputc( 185, MacFile );
      fputc( 0, MacFile );
   }
   return status();
}

int MacPntEncoder::status( void )
{
   if( ferror(MacFile) ) return xIOERROR;
   if( feof(MacFile) )   return xENDOFFILE;
   return xOKAY;
}

int MacPntEncoder::encode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      pack( buf, npxls );
      writeln();
      MacLnCnt++;
   }
   return status();
}

