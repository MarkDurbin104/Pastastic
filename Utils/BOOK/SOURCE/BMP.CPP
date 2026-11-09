//--------------------------------------------------------//
//                                                        //
//   File:    BMP.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Windows BMP format - DOS version            //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "bmp.hpp"

//..................struct xBITMAPFILEHEADER

void xBITMAPFILEHEADER::list( void )
{
   printf( "xBITMAPFILEHEADER::bfType      = '%c%c'\n",
            bfType & 0xFF, (bfType>>8) & 0xFF );
   printf( "xBITMAPFILEHEADER::bfSize      = %lu\n",
            bfSize );
   printf( "xBITMAPFILEHEADER::bfReserved1 = %d\n",
            bfReserved1 );
   printf( "xBITMAPFILEHEADER::bfReserved2 = %d\n",
            bfReserved2 );
   printf( "xBITMAPFILEHEADER::bfOffBits   = %lu\n",
            bfOffBits );
}

//..................struct xRGBTRIPLE

void xRGBTRIPLE::list( int index )
{
   printf( "xRGBTRIPLE[%3d]::  ", index );
   printf( "rgbRed=%3d  rgbGreen=%3d  rgbBlue=%3d\n",
            rgbRed&0xFF, rgbGreen&0xFF, rgbBlue&0xFF );
}

//..................struct xBITMAPCOREHEADER

void xBITMAPCOREHEADER::list( void )
{
   printf( "xBITMAPCOREHEADER::bcSize     = %lu\n",
            bcSize );
   printf( "xBITMAPCOREHEADER::bcWidth    = %d\n",
            bcWidth );
   printf( "xBITMAPCOREHEADER::bcHeight   = %d\n",
            bcHeight );
   printf( "xBITMAPCOREHEADER::bcPlanes   = %u\n",
            bcPlanes );
   printf( "xBITMAPCOREHEADER::bcBitCount = %u\n",
            bcBitCount );
}

//..................struct xRGBQUAD

void xRGBQUAD::list( int index )
{
   printf( "xRGBQUAD[%3d]::  ", index );
   printf( "rgbRed=%3d  rgbGreen=%3d  rgbBlue=%3d",
            rgbRed&0xFF, rgbGreen&0xFF, rgbBlue&0xFF );
   printf( "  rgbReserved=%d\n", rgbReserved );
}

//..................struct xBITMAPINFOHEADER

void xBITMAPINFOHEADER::list( void )
{
   printf( "xBITMAPINFOHEADER::biSize          = %lu\n",
            biSize );
   printf( "xBITMAPINFOHEADER::biWidth         = %ld\n",
            biWidth );
   printf( "xBITMAPINFOHEADER::biHeight        = %ld\n",
            biHeight );
   printf( "xBITMAPINFOHEADER::biPlanes        = %d\n",
            biPlanes );
   printf( "xBITMAPINFOHEADER::biBitCount      = %d\n",
            biBitCount );
   printf( "xBITMAPINFOHEADER::biCompression   = %lu\n",
            biCompression );
   printf( "xBITMAPINFOHEADER::biSizeImage     = %lu\n",
            biSizeImage );
   printf( "xBITMAPINFOHEADER::biXPelsPerMeter = %ld\n",
            biXPelsPerMeter );
   printf( "xBITMAPINFOHEADER::biYPelsPerMeter = %ld\n",
            biYPelsPerMeter );
   printf( "xBITMAPINFOHEADER::biClrUsed       = %lu\n",
            biClrUsed );
   printf( "xBITMAPINFOHEADER::biClrImportant  = %lu\n",
            biClrImportant );
}

//..................class BmpDecoder

BmpDecoder::BmpDecoder( FILE *f_in, int rle, int nbits ) :
            Decoder( tRLE )
{
   cond = xOKAY;
   rle_method = rle;
   pxl_size = nbits;
   bmp_file = f_in;
}

int BmpDecoder::status( void )
{
   if( ferror(bmp_file) ) cond = xIOERROR;
   if( feof(bmp_file) ) cond = xOUTOFSYNC;
   return cond;
}

int BmpDecoder::init( void )
{
   return status();
}

int BmpDecoder::term( void )
{
   return status();
}

void BmpDecoder::read_none( unsigned char *buf, int npxls )
{
   int i, j, nbytes;
   switch( pxl_size )
   {
      case 1 :
         nbytes = (npxls + 7) / 8;
         nbytes = (nbytes + 3) / 4;
         nbytes *= 4;
         while( npxls > 0 )
         {
            nbytes--;
            int x = fgetc( bmp_file );
            int m = 0x80;
            while( (npxls > 0) && (m != 0) )
            {
               *buf++ = (x & m) ? 1 : 0;
               m >>= 1;
               npxls--;
            }
         }
         while( nbytes-- > 0 )
            fgetc( bmp_file );
         break;

      case 4 :
         nbytes = (npxls + 1) / 2;
         nbytes = (nbytes + 3) / 4;
         nbytes *= 4;
         while( npxls > 0 )
         {
            nbytes--;
            int x = fgetc( bmp_file );
            int p2 = x & 0x0F;
            int p1 = (x>>4) & 0x0F;
            *buf++ = p1;
            npxls--;
            *buf++ = p2;
            npxls--;
         }
         while( nbytes-- > 0 )
            fgetc( bmp_file );
         break;

      case 8 :
         nbytes = (npxls + 3) / 4;
         nbytes *= 4;
         fread( buf, npxls, 1, bmp_file );
         nbytes -= npxls;
         while( nbytes-- > 0 )
            fgetc( bmp_file );
         break;

      case 24 :
         nbytes = (npxls*3 + 3) / 4;
         nbytes *= 4;
         fread( buf, npxls, 3, bmp_file );
         nbytes -= npxls*3;
         while( nbytes-- > 0 )
            fgetc( bmp_file );
         // reorder bgr to rgb
         for( i=0, j=0; i<npxls; i++, j+=3 )
         {
            int k = buf[j];
            buf[j] = buf[j+2];
            buf[j+2] = k;
         }
         break;
   }
}

void BmpDecoder::read_rle4( unsigned char *buf, int npxls )
{
   int b1, b2;
   while( cond == xOKAY )
   {
      b1 = fgetc( bmp_file );
      b2 = fgetc( bmp_file );
      if( b1 == 0 )  //.... absolute or escape
      {
         switch( b2 )
         {
            case 0 :  //.... end-of-line
               return;

            case 1 :  //.... end-of-image
               cond = xENDOFIMAGE;
               return;

            case 2 :  //.... delta
               cond = xUNSUPPORTED;
               return;

            default : //.... nonrepeating run
               while( b2-- )
               {
                  if( npxls > 0 )
                  {
                     *buf++ = fgetc( bmp_file );
                     npxls--;
                  }
               }
               break;
         }
      }
      else  //............. encoded
      {
         unsigned char p1 = b2      & 0x0F;
         unsigned char p2 = (b2>>4) & 0x0F;
         unsigned char p;
         if( b1 & 1 ) { p=p1; p1=p2; p2=p; }
         while( b1-- )
         {
            if( npxls > 0 )
            {
               *buf++ = (b1 & 1 ) ? p1 : p2;
               npxls--;
            }
         }
      }
   }
}

void BmpDecoder::read_rle8( unsigned char *buf, int npxls )
{
   int b1, b2;
   while( cond == xOKAY )
   {
      b1 = fgetc( bmp_file );
      b2 = fgetc( bmp_file );
      if( b1 == 0 )  //.... absolute or escape
      {
         switch( b2 )
         {
            case 0 :  //.... end-of-line
               return;

            case 1 :  //.... end-of-image
               cond = xENDOFIMAGE;
               return;

            case 2 :  //.... delta
               cond = xUNSUPPORTED;
               return;

            default : //.... nonrepeating run
               while( b2-- )
               {
                  if( npxls > 0 )
                  {
                     *buf++ = fgetc( bmp_file );
                     npxls--;
                  }
               }
               break;
         }
      }
      else  //............. encoded
      {
         while( b1-- )
         {
            if( npxls > 0 )
            {
               *buf++ = b2;
               npxls--;
            }
         }
      }
   }
}

int BmpDecoder::decode( unsigned char *buf, int npxls )
{
   switch( rle_method )
   {
      case xBI_NONE :
           read_none( buf, npxls );
           break;

      case xBI_RLE8 :
           read_rle8( buf, npxls );
           break;

      case xBI_RLE4 :
           read_rle4( buf, npxls );
           break;

      default :
           cond = xBADPARAM;
           break;
   }

   return status();
}

//..................class BmpEncoder

BmpEncoder::BmpEncoder( FILE *f_out, int nbits ) :
            Encoder( tRLE )
{
   pxl_size = nbits;
   bmp_file = f_out;
}

int BmpEncoder::status( void )
{
   return ferror(bmp_file);
}

int BmpEncoder::init( void )
{
   return status();
}

int BmpEncoder::term( void )
{
   return status();
}

void BmpEncoder::wrt_line( unsigned char *buf, int npxls )
{
   int i, j, nbytes, x, m;
   switch( pxl_size )
   {
      case 1 :
         nbytes = (npxls + 7) / 8;
         nbytes = (nbytes + 3) / 4;
         nbytes *= 4;
         x = 0;
         m = 0x80;
         while( npxls-- > 0 )
         {
            if( *buf++ )
               x |= m;
            if( (m>>=1) == 0 )
            {
               fputc( x, bmp_file );
               x = 0;
               m = 0x80;
               nbytes--;
            }
         }
         if( m != 0x80 )
         {
            fputc( x, bmp_file );
            nbytes--;
         }
         while( nbytes-- > 0 )
            fputc( 0, bmp_file );
         break;

      case 4 :
         nbytes = (npxls + 1) / 2;
         nbytes = (nbytes + 3) / 4;
         nbytes *= 4;
         x = 0;
         while( npxls > 0 )
         {
            x = (*buf++) << 4;
            if( npxls > 1 )
               x |= *buf++;
            fputc( x, bmp_file );
            npxls -= 2;
            nbytes--;
         }
         while( nbytes-- > 0 )
            fputc( 0, bmp_file );
         break;

      case 8 :
         nbytes = (npxls + 3) / 4;
         nbytes *= 4;
         fwrite( buf, npxls, 1, bmp_file );
         nbytes -= npxls;
         while( nbytes-- > 0 )
            fputc( 0, bmp_file );
         break;

      case 24 :
         // reorder rgb to bgr
         for( i=0, j=0; i<npxls; i++, j+=3 )
         {
            int k = buf[j];
            buf[j] = buf[j+2];
            buf[j+2] = k;
         }
         nbytes = (npxls*3 + 3) / 4;
         nbytes *= 4;
         fwrite( buf, npxls, 3, bmp_file );
         nbytes -= npxls*3;
         while( nbytes-- > 0 )
            fputc( 0, bmp_file );
         break;
   }
}

int BmpEncoder::encode( unsigned char *buf, int npxls )
{
   wrt_line( buf, npxls );
   return status();
}
