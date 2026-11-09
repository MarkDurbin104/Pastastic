//--------------------------------------------------------//
//                                                        //
//   File:    PCX.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            PC Paintbrush PCX format                    //
//                                                        //
//--------------------------------------------------------//

#include "pcx.hpp"

#define  RUN_MASK  0xC0     // mask top 2 bits
#define  CNT_MASK  0x3F     // mask bottom 6 bits
#define  MAX_RUN   0x3F     // max repeat count

//..................struct PCXHEADER

PCXHEADER::PCXHEADER( )
{
   format  = 10;
   version = 5;
   rleflag = 1;
   paltype = 1;
   vmode   = 0;
   memset( colors, 0, 48 );
   memset( xtra, 0, 54 );
}

void PCXHEADER::list( void )
{
   printf( "PCXHEADER::format  = %d\n", format );
   printf( "PCXHEADER::version = %d, ", version );
   switch( version )
   {
      case 0  : printf( "version 2.5\n" );
                break;
      case 2  : printf( "version 2.8 with palette\n" );
                break;
      case 3  : printf( "version 2.8 without palette\n" );
                break;
      case 5  : printf( "version 3.0 or later\n" );
                break;
      default : printf( "unknown version\n" );
   }
   printf( "PCXHEADER::rleflag = %d\n", rleflag );
   printf( "PCXHEADER::paltype = %d, ", paltype );
   switch( paltype )
   {
      case 1  : printf( "color image\n" );
                break;
      case 2  : printf( "grayscale image\n" );
                break;
      default : printf( "unknown image type\n" );
   }
   printf( "PCXHEADER::vmode   = %d\n", vmode );
   printf( "PCXHEADER::bitpx   = %d\n", bitpx );
   printf( "PCXHEADER::nplanes = %d\n", nplanes );
   printf( "PCXHEADER::bplin   = %d\n", bplin );
   printf( "PCXHEADER::x1      = %d\n", x1 );
   printf( "PCXHEADER::y1      = %d\n", y1 );
   printf( "PCXHEADER::x2      = %d\n", x2 );
   printf( "PCXHEADER::y2      = %d\n", y2 );
   printf( "PCXHEADER::hres    = %d\n", hres );
   printf( "PCXHEADER::vres    = %d\n", vres );
   printf( "PCXHEADER::scrnw   = %d\n", scrnw );
   printf( "PCXHEADER::scrnh   = %d\n", scrnh );
}

//..................struct PCXPALETTE

PCXPALETTE::PCXPALETTE( FILE *f, PCXHEADER& h )
{
   ncolors = nopal = 0;
   colors = 0;
   // 16 colors or less
   if( h.bitpx < 8 )
   {
      ncolors = 1 << (h.bitpx * h.nplanes);
      if( ncolors == 2 )
      {
         colors = new rgb[2];
         colors[0] = rgb( 0, 0, 0 );
         colors[1] = rgb( 255, 255, 255 );
      }
      else
      {
         colors = new rgb[16];
         if( colors )
         {
           int n = 0;
           for( int i=0; i<16; i++ )
              colors[i] = rgb( h.colors[n++],
                               h.colors[n++],
                               h.colors[n++] );
         }
         else
            ncolors = 0;
      }
      nopal = (h.version == 3) ? 1 : 0;
   }
   // 256 colors
   else if( (h.bitpx == 8) && (h.nplanes == 1) )
   {
      fseek( f, -769, SEEK_END );
      nopal = (fgetc( f ) == 12) ? 0 : 1;
      ncolors = 256;
      colors = new rgb[256];
      if( colors )
      {
        for( int i=0; i<256; i++ )
        {
           int r = fgetc( f );
           int g = fgetc( f );
           int b = fgetc( f );
           colors[i] = rgb( r, g, b );
        }
      }
      else
         ncolors = 0;
   }
}

//..................class PcxDecoder

PcxDecoder::PcxDecoder( FILE *f_in, PCXHEADER& pcx )
{
   pxl_bits   = (pcx.bitpx==0)   ? 1 : pcx.bitpx;
   pxl_planes = (pcx.nplanes==0) ? 1 : pcx.nplanes;
   row_bytes  = pcx.bplin;

   pcx_file = f_in;

   shift_cnt = pxl_bits;
   shift_msk = (1 << pxl_bits) - 1;
   cond = xOKAY;
}

int PcxDecoder::status( void )
{
   if( ferror( pcx_file ) ) cond = xIOERROR;
   if( feof( pcx_file ) )   cond = xENDOFFILE;
   return cond;
}

int PcxDecoder::init( void )
{
   cond = xOKAY;
   hdr_byte = cnt_byte = dat_byte = 0;
   // seek to start of bitmap
   fseek( pcx_file, 128, SEEK_SET );
   return status();
}

int PcxDecoder::term( void )
{
   return status();
}

// decodes 1, 2, or 4 bits per pixel
void PcxDecoder::read_124( unsigned char *buf, int npxls )
{
   // initial values
   int bytecnt        = 0;
   int curplane       = 0;
   int pixelsperbyte  = 8 / pxl_bits;
   int setpxlshfitcnt = 0;
   int curpxl         = 0;

   // zero the buffer
   memset( buf, 0, npxls );

   while( bytecnt < row_bytes )
   {
      // time to get a data byte?
      if( cnt_byte < 1 )
      {
         // get a byte
         if ( (hdr_byte=fgetc(pcx_file)) < 0 )
            break;

         // decode it
         if ( (hdr_byte & RUN_MASK) == RUN_MASK )
         {
            cnt_byte = hdr_byte & CNT_MASK;
            if ( (dat_byte=fgetc(pcx_file)) < 0 )
               break;
         }
         else
         {
            cnt_byte = 1;
            dat_byte = hdr_byte;
         }

         // reverse the data byte's pixel pattern
         dat_byte = reverse( dat_byte, pxl_bits );
      }

      // fill in pixel buffer
      while( cnt_byte-- )
      {
         int p = dat_byte;
         int n = pixelsperbyte;
         while( n-- )
         {
            // isolate pixel value
            unsigned char mask = p & shift_msk;
                                 p >>= shift_cnt;
            // shift into current plane position
            mask <<= setpxlshfitcnt;
            // OR into pixel buffer
            if( curpxl < npxls )
               buf[curpxl++] |= mask;
         }
         if( ++bytecnt == row_bytes )
         {
            if( ++curplane < pxl_planes )
            {
               bytecnt = curpxl = 0;
               setpxlshfitcnt += shift_cnt;
            }
         }
      }
   }
}

// decodes 8 bits per pixel
void PcxDecoder::read_8( unsigned char *buf, int npxls )
{
   // initial values
   int bytecnt  = 0;
   int curplane = 0;
   int curpxl   = 0;
   int pxlindex = 0;

   // zero the buffer
   memset( buf, 0, npxls*pxl_planes );

   while( bytecnt < row_bytes )
   {
      // time to get a data byte?
      if( cnt_byte < 1 )
      {
         // get a byte
         if ( (hdr_byte=fgetc(pcx_file)) < 0 )
            break;

         // decode it
         if ( (hdr_byte & RUN_MASK) == RUN_MASK )
         {
            cnt_byte = hdr_byte & CNT_MASK;
            if ( (dat_byte=fgetc(pcx_file)) < 0 )
               break;
         }
         else
         {
            cnt_byte = 1;
            dat_byte = hdr_byte;
         }
      }

      // fill in pixel buffer
      while( cnt_byte-- )
      {
         if( curpxl++ < npxls )
         {
             buf[pxlindex] = dat_byte;
             pxlindex += pxl_planes;
         }
         if( ++bytecnt == row_bytes )
         {
            if( ++curplane < pxl_planes )
            {
               bytecnt = curpxl = 0;
               pxlindex = curplane;
            }
         }
      }
   }
}

int PcxDecoder::decode( unsigned char *buf, int npxls )
{
   if( cond == xOKAY )
   {
      if( pxl_bits == 8 )
         read_8( buf, npxls );
      else
         read_124( buf, npxls );
   }
   return status();
}

//..................class PcxEncoder

PcxEncoder::PcxEncoder( FILE *f_out, PCXHEADER& pcx )
{
   pxl_bits   = (pcx.bitpx==0)   ? 1 : pcx.bitpx;
   pxl_planes = (pcx.nplanes==0) ? 1 : pcx.nplanes;
   row_bytes  = pcx.bplin;

   pcx_file = f_out;
   scanbuffer = new char[row_bytes];
   cond = (scanbuffer == 0) ? xNOMEMORY : xOKAY;
}

int PcxEncoder::status( void )
{
   if( ferror( pcx_file ) ) cond = xIOERROR;
   return cond;
}

int PcxEncoder::init( void )
{
   cond = (scanbuffer == 0) ? xNOMEMORY : xOKAY;
   return status();
}

int PcxEncoder::term( void )
{
   return status();
}

void PcxEncoder::initbuffer( void )
{
   memset( scanbuffer, 0, row_bytes );
   scanmask = 0x80;
   scanbyte = 0;
}

void PcxEncoder::putbits( int bits, int nbits )
{
   int mask = 1 << nbits;
   while( (mask >>= 1) != 0 )
   {
      if( bits & mask )
         scanbuffer[scanbyte] |= scanmask;
      if( (scanmask >>= 1) == 0 )
      {
         scanbyte++;
         scanmask = 0x80;
      }
   }
}

void PcxEncoder::putbyte( int byte )
{
   scanbuffer[scanbyte++] = byte;
}

int PcxEncoder::flush( void )
{
   // encode and write scanbuffer
   int n1, n2=0;
   while( n2 < row_bytes )
   {
      n1 = n2;
      n2 = n1 + 1;
      while( (scanbuffer[n2] == scanbuffer[n1]) &&
             (n2 < row_bytes) )
         n2++;
      // n is number of bytes in this run
      int n = n2 - n1;
      while( n > MAX_RUN )
      {
         fputc( 0xFF, pcx_file );
         fputc( scanbuffer[n1], pcx_file );
         n -= MAX_RUN;
      }
      if( (n > 1) || ((scanbuffer[n1]&RUN_MASK) == RUN_MASK) )
         fputc( n|RUN_MASK, pcx_file );
      fputc( scanbuffer[n1], pcx_file );
   }

   return status();
}

// encodes 1, 2, or 4 bits per pixel
void PcxEncoder::write_124( unsigned char *buf, int npxls )
{
   int n = pxl_planes;
   int shft = 0;
   while( n-- )
   {
      initbuffer();
      int m = 0;
      while( m < npxls )
      {
         int p = buf[m++] >> shft;
         putbits( p, pxl_bits );
      }
      if( flush() != xOKAY )
         break;
      shft += pxl_bits;
   }
}

// encodes 8 bits per pixel
void PcxEncoder::write_8( unsigned char *buf, int npxls )
{
   int n = 0;
   while( n < pxl_planes )
   {
      initbuffer();
      int m = 0;
      int i = n;
      while( m++ < npxls )
      {
         putbyte( buf[i] );
         i += pxl_planes;
      }
      if( flush() != xOKAY )
         break;
      n++;
   }
}

int PcxEncoder::encode( unsigned char *buf, int npxls )
{
   if( cond == xOKAY )
   {
      if( pxl_bits == 8 )
         write_8( buf, npxls );
      else
         write_124( buf, npxls );
   }
   return status();
}

