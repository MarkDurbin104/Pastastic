//--------------------------------------------------------//
//                                                        //
//   File:    IMG.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            GEM IMG format                              //
//                                                        //
//--------------------------------------------------------//

#include "img.hpp"

//.............struct IMGHEADER

static unsigned int uswap( unsigned int u )
{
   return( ((u >> 8) & 0x00FF) | ((u << 8) & 0xFF00) );
}

// reverse byte order in each word
void IMGHEADER::swap( void )
{
   version   = uswap( version);
   hdrsize   = uswap( hdrsize );
   nplanes   = uswap( nplanes );
   patbytes  = uswap( patbytes );
   pxlwidth  = uswap( pxlwidth );
   pxlheight = uswap( pxlheight );
   scanwidth = uswap( scanwidth );
   scancount = uswap( scancount );
}

// list header values
void IMGHEADER::list( void )
{
   printf( "IMGHEADER::version   = %d\n", version );
   printf( "IMGHEADER::hdrsize   = %d words\n", hdrsize );
   printf( "IMGHEADER::nplanes   = %d\n", nplanes );
   printf( "IMGHEADER::patbytes  = %d\n", patbytes );
   printf( "IMGHEADER::pxlwidth  = %d microns\n", pxlwidth );
   printf( "IMGHEADER::pxlheight = %d microns\n", pxlheight );
   printf( "IMGHEADER::scanwidth = %d\n", scanwidth );
   printf( "IMGHEADER::scancount = %d\n", scancount );
}

//.............class ImgDecoder

ImgDecoder::ImgDecoder( FILE *f_in, IMGHEADER& img )
{
   cond = xOKAY;

   // we use the header length field to determine
   // if header words have the proper byte order
   if( img.hdrsize != 8 )  img.swap();

   img_file   = f_in;
   img_planes = img.nplanes;
   img_width  = img.scanwidth;
   row_bytes  = (img_width + 7) / 8;
   scancnt    = img.scancount;
   patlen     = img.patbytes;
   img_height = imagehgt();
}

int ImgDecoder::init( void )
{
   cond = xOKAY;
   repeatcnt = 0;
   scanline = new unsigned char [img_width];
   if( scanline == 0 ) cond = xNOMEMORY;
   pattern = new unsigned char [patlen];
   if( pattern == 0 ) cond = xNOMEMORY;
   return status();
}

int ImgDecoder::term( void )
{
   if( scanline )
   {
      delete scanline;
      scanline = 0;
   }
   if( pattern )
   {
      delete pattern;
      pattern = 0;
   }
   return status();
}

int ImgDecoder::status( void )
{
   if( cond == xOKAY )
   {
      if( feof(img_file) )   cond = xENDOFIMAGE;
      if( ferror(img_file) ) cond = xIOERROR;
   }
   return cond;
}

int ImgDecoder::readcnt( void )
{
   // if present, count is 4 bytes formatted
   // as follows:  00 00 FF CNT
   unsigned char uc[4];
   if( fread( uc, 1, 4, img_file ) != 4 )
      return -1;
   if( uc[0] == 0 )
      if( uc[1] == 0 )
         if( uc[2] == 255 )
            return uc[3];
   fseek( img_file, -4, SEEK_CUR );
   return 1;
}

void ImgDecoder::putbyte( int byte, int plmask )
{
   int mask = 0x100;
   while( ((mask>>=1) > 0) && (curpxl < img_width) )
   {
      if( (byte & mask) == 0 )  scanline[curpxl] |= plmask;
      curpxl++;
   }
}

void ImgDecoder::readplane( int plmask )
{
   curpxl = 0;
   int nbytes = 0;
   while( nbytes < row_bytes )
   {
      // get construct type
      int type = fgetc( img_file );
      if( type < 0 ) return;

      // process the construct
      int i, j, cnt;
      switch( type )
      {
         case 0x00 :  // a pattern run
              cnt = fgetc( img_file );
              fread( pattern, patlen, 1, img_file );
              for( i=0; i<cnt; i++ )
              {
                 for( j=0; j<patlen; j++ )
                 {
                    putbyte( pattern[j], plmask );
                 }
                 nbytes += patlen;
              }
              break;

         case 0x80 :  // an unencoded run
              cnt = fgetc( img_file );
              for( i=0; i<cnt; i++ )
              {
                 j = fgetc( img_file );
                 putbyte( j, plmask );
              }
              nbytes += cnt;
              break;

         default :    // a solid run
              j = (type & 0x80) ? 0xFF : 0x00;
              cnt = type & 0x7F;
              for( i=0; i<cnt; i++ )
                 putbyte( j, plmask );
              nbytes += cnt;
              break;
      }
   }
}

void ImgDecoder::readline( void )
{
   int i, mask;
   memset( scanline, 0, img_width );
   for( i=0, mask=1; i<img_planes; i++, mask<<=1 )
      readplane( mask );
}

void ImgDecoder::skipline( void )
{
   for( int i=0; i<img_planes; i++ )
   {
      int nbytes = 0;
      while( nbytes < row_bytes )
      {
         // get construct type
         int type = fgetc( img_file );
         if( type < 0 ) return;

         // process the construct
         int cnt;
         switch( type )
         {
            case 0x00 :  // a pattern run
                 cnt = fgetc( img_file );
                 fseek( img_file, patlen, SEEK_CUR);
                 nbytes += patlen*cnt;
                 break;

            case 0x80 :  // an unencoded run
                 cnt = fgetc( img_file );
                 fseek( img_file, cnt, SEEK_CUR);
                 nbytes += cnt;
                 break;

            default :    // a solid run
                 cnt = type & 0x7F;
                 nbytes += cnt;
                 break;
         }
      }
   }
}

int ImgDecoder::imagehgt( void )
{
   int cnt = 0;
   fseek( img_file, sizeof(IMGHEADER), SEEK_SET );
   for( int i=0; i<scancnt; i++ )
   {
      cnt += readcnt();
      skipline();
   }
   fseek( img_file, sizeof(IMGHEADER), SEEK_SET );
   return cnt;
}

int ImgDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( repeatcnt < 1 )
      {
         repeatcnt = readcnt();
         if( repeatcnt > 0 )
            readline();
      }
      if( repeatcnt > 0 )
         memcpy( buf, scanline, npxls );
      repeatcnt--;
   }
   return status();
}
