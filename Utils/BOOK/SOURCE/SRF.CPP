//--------------------------------------------------------//
//                                                        //
//   File:    SRF.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            SUN Raster File format                      //
//                                                        //
//--------------------------------------------------------//

#include "srf.hpp"

//..................various identifiers

struct IMGTYPES
{
   int id;
   char *desc;
}
ImTypes[] =
{
   { imOld,  "Old format version" },
   { imStd,  "Standard uncompressed" },
   { imRle,  "RLE encoded" },
   { imRgb,  "RGB pixels" },
   { imTiff, "TIFF compatible" },
   { imIff,  "IFF compatible" },
   { imExp,  "Experimental" },
   { 999,    "Unknown or Invalid" },
};

static nImTypes = 8;

struct MAPTYPES
{
   int id;
   char *desc;
}
MapTypes[] =
{
   { mapNone,  "No color map present" },
   { mapRgb,   "RGB color map" },
   { mapRaw,   "Raw color map data" },
   { 999,      "Unknown or Invalid" },
};

static nMapTypes = 4;

//..................struct SRFHEADER

SRFHEADER::SRFHEADER( )
{
   iden = RF_IDEN;
   imwidth = imheight = imdepth = 0;
   imlength = imtype = 0;
   maptype = maplength = 0;
}

SRFHEADER::SRFHEADER( int w, int h, int d )
{
   iden = RF_IDEN;
   imwidth = w;
   imheight = h;
   imdepth = d;
   imlength = imtype = 0;
   maptype = maplength = 0;
}

void SRFHEADER::list( )
{
   printf( "SRFHEADER::iden      = %08lXh\n", iden );
   printf( "SRFHEADER::imwidth   = %ld\n", imwidth );
   printf( "SRFHEADER::imheight  = %ld\n", imheight );
   printf( "SRFHEADER::imdepth   = %ld\n", imdepth );
   printf( "SRFHEADER::imlength  = %ld\n", imlength );
   printf( "SRFHEADER::imtype    = %ld, ", imtype );
   for( int i=0; i<nImTypes; i++ )
   {
      if( (imtype == ImTypes[i].id) ||
          (ImTypes[i].id == 999) )
      {
         printf( "%s\n", ImTypes[i].desc );
         break;
      }
   }
   printf( "SRFHEADER::maptype   = %ld, ", maptype );
   for( i=0; i<nMapTypes; i++ )
   {
      if( (maptype == MapTypes[i].id) ||
          (MapTypes[i].id == 999) )
      {
         printf( "%s\n", MapTypes[i].desc );
         break;
      }
   }
   printf( "SRFHEADER::maplength = %ld\n", maplength );
}

int SRFHEADER::get( FILE *f )
{
   int    nlongs = sizeof(SRFHEADER) / sizeof(long);
   long * item   = &iden;

   // Motorola-to-Intel byte order
   for( int i=0; i<nlongs; i++ )
   {
      fread( item+i, sizeof(long), 1, f );
      item[i] = rev_dword( item[i] );
   }

   return ferror(f) ? -1 : 0;
}

int SRFHEADER::put( FILE *f )
{
   int    nlongs = sizeof(SRFHEADER) / sizeof(long);
   long * item   = &iden;

   // Intel-to-Motorola byte order
   for( int i=0; i<nlongs; i++ )
   {
      long v = rev_dword( item[i] );
      fwrite( &v, sizeof(long), 1, f );
   }

   return ferror(f) ? -1 : 0;
}

RgbPalette * SRFHEADER::pal( FILE *f )
{
   RgbPalette *pal = new RgbPalette;
   if( pal )
   {
      pal->colors = 0;
      pal->ncolors = 0;
      if( maplength == 0 )  // color map not present
      {
         if( imdepth == 1 )
         {
            pal->colors = new rgb[2];
            if( pal->colors )
            {
               pal->colors[0] = rgb( 255, 255, 255 );
               pal->colors[1] = rgb(   0,   0,   0 );
               pal->ncolors = 2;
            }
         }
         else if( imdepth == 8 )
         {
            pal->colors = new rgb[256];
            if( pal->colors )
            {
               for( int i=0; i<256; i++ )
                  pal->colors[i] = rgb( i, i, i );
               pal->ncolors = 256;
            }
         }
      }
      else if( maptype == mapRgb )  // RGB values present
      {
         int nc = int( maplength / 3 );
         pal->colors = new rgb[nc];
         if( pal->colors )
         {
            for( int i=0; i<nc; i++ )
            {
               pal->colors[i].red = fgetc( f );
               pal->colors[i].grn = fgetc( f );
               pal->colors[i].blu = fgetc( f );
            }
            pal->ncolors = nc;
         }
      }
   }
   return pal;
}

//..................class SrfDecoder

SrfDecoder::SrfDecoder( FILE *f_in, SRFHEADER& hdr )
{
   srf_file = f_in;
   cnt = dat = 0;
   pxbits = int( hdr.imdepth );
   pxbytes = (pxbits + 7) / 8;
   rwbytes = int( (hdr.imwidth * hdr.imdepth + 7) / 8 );
   if( rwbytes & 1 ) rwbytes++;
   encoded = (hdr.imtype == imRle) ? 1 : 0;
   if( (hdr.imtype==imOld) || (hdr.imtype==imStd) ||
       (hdr.imtype==imRle) || (hdr.imtype==imRgb) )
      cond = xOKAY;
   else
      cond = xUNSUPPORTED;
}

int SrfDecoder::status( void )
{
   if( ferror( srf_file ) ) cond = xIOERROR;
   if( feof( srf_file ) )   cond = xENDOFFILE;
   return cond;
}

int SrfDecoder::init( void )
{
   cnt = dat = 0;
   return status();
}

int SrfDecoder::term( void )
{
   return status();
}

int SrfDecoder::read_byte( void )
{
   if( cnt == 0 )
   {
      if( encoded )
      {
         dat = fgetc( srf_file );
         if( dat != RUN_FLAG )
            cnt = 1;
         else
         {
            cnt = fgetc( srf_file );
            if( cnt > 0 )
            {
               cnt++;
               dat = fgetc( srf_file );
            }
            else
               cnt = 1;
         }
      }
      else
      {
         dat = fgetc( srf_file );
         cnt = 1;
      }
   }
   cnt--;
   return dat;
}

void SrfDecoder::read1( unsigned char *buf, int npxls )
{
   int n=0;
   for( int i=0; i<rwbytes; i++ )
   {
      int v = read_byte();
      int mask = 0x100;
      while( mask >>= 1 )
         if( n < npxls )
            buf[n++] = v & mask ? 1 : 0;
   }
}

void SrfDecoder::read8( unsigned char *buf, int npxls )
{
   int n=0;
   for( int i=0; i<rwbytes; i++ )
   {
      int v = read_byte();
      if( n < npxls )
         buf[n++] = v;
   }
}

void SrfDecoder::read24( unsigned char *buf, int npxls )
{
   int n  = 0;
   int nb = npxls * 3;
   for( int i=0; i<rwbytes; i++ )
   {
      int v = read_byte();
      if( n < nb )
         buf[n++] = v;
   }
}

int SrfDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( pxbits == 24 )
         read24( buf, npxls );
      else if( pxbits == 8 )
         read8( buf, npxls );
      else
         read1( buf, npxls );
   }
   return status();
}

//..................class SrfEncoder

SrfEncoder::SrfEncoder( FILE *f_out, SRFHEADER& hdr )
{
   srf_file = f_out;
   pxbits = int( hdr.imdepth );
   pxbytes = (pxbits + 7) / 8;
   rwbytes = int( (hdr.imwidth * hdr.imdepth + 7) / 8 );
   if( rwbytes & 1 ) rwbytes++;
   encoded = (hdr.imtype == imRle) ? 1 : 0;
   scanln = new unsigned char [rwbytes];
   cond = scanln ? xOKAY : xNOMEMORY;
}

int SrfEncoder::status( void )
{
   if( ferror( srf_file ) ) cond = xIOERROR;
   return cond;
}

int SrfEncoder::init( void )
{
   return status();
}

int SrfEncoder::term( void )
{
   return status();
}

void SrfEncoder::wrt1( unsigned char *buf, int npxls )
{
   memset( scanln, 0, rwbytes );
   unsigned char *p = scanln;
   int mask = 0x80;
   for( int i=0; i<npxls; i++ )
   {
      if( buf[i] ) *p |= mask;
      if( (mask>>=1) == 0 )
      {
         p++;
         mask = 0x80;
      }
   }
}

void SrfEncoder::wrt8( unsigned char *buf, int npxls )
{
   for( int i=0; i<npxls; i++ )
      scanln[i] = buf[i];
}

void SrfEncoder::wrt24( unsigned char *buf, int npxls )
{
   int n = 0;
   for( int i=0; i<npxls; i++ )
   {
      scanln[n] = buf[n];  n++;
      scanln[n] = buf[n];  n++;
      scanln[n] = buf[n];  n++;
   }
}

void SrfEncoder::flush( void )
{
   if( encoded )
   {
      int n1, n2=0;
      while( n2 < rwbytes )
      {
         n1 = n2;
         n2 = n1 + 1;
         while( (n2 < rwbytes) && (scanln[n1] == scanln[n2]) )
              n2++;
         int n = n2 - n1;   // run is n bytes long
         if( n == 1 )
         {
            fputc( scanln[n1], srf_file );
            if( scanln[n1] == RUN_FLAG )
               fputc( 0, srf_file );
         }
         else
         {
            while( n > 256 )
            {
               fputc( RUN_FLAG, srf_file );
               fputc( 255, srf_file );
               fputc( scanln[n1], srf_file );
               n -= 256;
            }
            fputc( RUN_FLAG, srf_file );
            fputc( n-1, srf_file );
            fputc( scanln[n1], srf_file );
         }
      }
   }
   else
      fwrite( scanln, rwbytes, 1, srf_file );
}

int SrfEncoder::encode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( pxbits == 24 )
         wrt24( buf, npxls );
      else if( pxbits == 8 )
         wrt8( buf, npxls );
      else
         wrt1( buf, npxls );
      flush();
   }
   return status();
}
