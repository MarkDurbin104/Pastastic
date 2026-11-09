//--------------------------------------------------------//
//                                                        //
//   File:    TGA.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            TARGA Format                                //
//                                                        //
//--------------------------------------------------------//

#include "tga.hpp"

//.............struct TGATYPES

struct TGATYPES
{
   int   id;
   char *desc;
}
tgatypes[] =
{
   {   0, "No Image Data" },
   {   1, "Uncompressed, Color Mapped" },
   {   2, "Uncompressed, RGB" },
   {   3, "Uncompressed, Gray Scale" },
   {   9, "Run-Length Encoded, Color Mapped" },
   {  10, "Run-Length Encoded, RGB" },
   {  11, "Run-Length Encoded, Gray Scale" },
   {  32, "Huffman Encoded, Color Mapped" },
   {  33, "Huffman Encoded, 4-Pass, Color Mapped" },
   { 999, "Unknown or Invalid" }
};
static ntypes = 10;

//.............struct TGAHEADER

TGAHEADER::TGAHEADER( )
{
   idlen = cmtype = imtype = 0;
   cmorg = cmcnt = cmsiz = 0;
   imxorg = imyorg = 0;
   imwidth = imheight = 0;
   imdepth = imdesc = 0;
}

TGAHEADER::TGAHEADER( int w, int h, int d )
{
   idlen = 0;
   cmtype = (d == 8) ? 1 : 0;
   imtype = (d == 8) ? 1 : 2;
   cmorg = cmcnt = cmsiz = 0;
   imxorg = imyorg = 0;
   imwidth = w;
   imheight = h;
   imdepth = d;
   imdesc = 0x20;
}

void TGAHEADER::list( void )
{
   printf( "TGAHEADER::idlen    = %d\n", idlen );
   printf( "TGAHEADER::cmtype   = %d\n", cmtype );
   printf( "TGAHEADER::imtype   = %d - ", imtype );
   for( int i=0; i<ntypes; i++ )
   {
      if( (imtype == tgatypes[i].id) ||
          (tgatypes[i].id == 999) )
      {
         printf( "%s\n", tgatypes[i].desc );
         break;
      }
   }
   printf( "TGAHEADER::cmorg    = %d\n", cmorg );
   printf( "TGAHEADER::cmcnt    = %d\n", cmcnt );
   printf( "TGAHEADER::cmsiz    = %d\n", cmsiz );
   printf( "TGAHEADER::imxorg   = %d\n", imxorg );
   printf( "TGAHEADER::imyorg   = %d\n", imyorg );
   printf( "TGAHEADER::imwidth  = %d\n", imwidth );
   printf( "TGAHEADER::imheight = %d\n", imheight );
   printf( "TGAHEADER::imdepth  = %d\n", imdepth );
   printf( "TGAHEADER::imdesc   = %02Xh\n", imdesc );
}

int TGAHEADER::get( FILE *f )
{
   return( fread( &idlen, sizeof(TGAHEADER), 1, f ) == 1 ?
           0 : -1 );
}

int TGAHEADER::put( FILE *f )
{
   return( fwrite( &idlen, sizeof(TGAHEADER), 1, f ) == 1 ?
           0 : -1 );
}

rgb * TGAHEADER::pal( FILE *f )
{
   if( cmcnt == 0 ) return 0;
   rgb *pal = new rgb [cmcnt];
   if( pal )
   {
      long v;
      int  nbytes, nbits, mask;

      if( cmsiz == 32 )
      {
         nbytes = 4;
         nbits = 8;
      }
      else if( cmsiz == 24 )
      {
         nbytes = 3;
         nbits = 8;
      }
      else
      {
         nbytes = 2;
         nbits = 5;
      }
      mask = (1 << nbits) - 1;

      for( int i=0; i<cmcnt; i++ )
      {
         fread( &v, nbytes, 1, f );
         pal[i].blu = v & mask;
         v >>= nbits;
         pal[i].grn = v & mask;
         v >>= nbits;
         pal[i].red = v & mask;
      }
   }
   return pal;
}

//.............class TgaDecoder

TgaDecoder::TgaDecoder( FILE *f_in, TGAHEADER& hdr )
{
   tga_file = f_in;
   width    = hdr.imwidth;
   height   = hdr.imheight;
   pxbits   = hdr.imdepth;
   pxbytes  = (hdr.imdepth + 7) / 8;
   mapped   = hdr.cmtype;
   cond     = xOKAY;
   encoded  = 0;
   mirrored = hdr.ishorzmirror();
   if( (hdr.imtype==9)  ||
       (hdr.imtype==10) ||
       (hdr.imtype==11) )
      encoded = 1;
   else if( (hdr.imtype!=1) &&
            (hdr.imtype!=2) &&
            (hdr.imtype!=3) )
      cond = xUNSUPPORTED;
}

TgaDecoder::~TgaDecoder( )
{
}

int TgaDecoder::status( void )
{
   if( ferror( tga_file ) ) cond = xIOERROR;
   if( feof( tga_file ) )   cond = xENDOFFILE;
   return cond;
}

int TgaDecoder::init( void )
{
   return status();
}

int TgaDecoder::term( void )
{
   return status();
}

void TgaDecoder::reverse1( unsigned char *buf, int npxls )
{
   int i1 = 0;
   int i2 = npxls-1;
   while( i1 < i2 )
   {
      int i = buf[i1];  buf[i1] = buf[i2];  buf[i2] = i;
      i1++;
      i2--;
   }
}

void TgaDecoder::reverse3( unsigned char *buf, int npxls )
{
   int i1 = 0;
   int i2 = npxls-3;
   while( i1 < i2 )
   {
      int i = buf[i1];  buf[i1] = buf[i2];  buf[i2] = i;
      i = buf[i1+1];  buf[i1+1] = buf[i2+1];  buf[i2+1] = i;
      i = buf[i1+2];  buf[i1+2] = buf[i2+2];  buf[i2+2] = i;
      i1 += 3;
      i2 -= 3;
   }
}

void TgaDecoder::readmapped( unsigned char *buf, int npxls )
{
   fread( buf, npxls, 1, tga_file );
   if( mirrored )
      reverse1( buf, npxls );
}

void TgaDecoder::readrlemapped( unsigned char *buf, int npxls )
{
   int n = 0;
   int cnt;
   while( n < npxls )
   {
      if( (cnt = fgetc( tga_file )) < 0 )
         break;
      if( cnt > 127 )
      {
         cnt -= 126;
         int pxv = fgetc( tga_file );
         while( cnt-- > 0 )
            buf[n++] = pxv;
      }
      else
      {
         cnt++;
         fread( buf+n, cnt, 1, tga_file );
         n += cnt;
      }
   }
   if( mirrored )
      reverse1( buf, npxls );
}

void TgaDecoder::readrgb( unsigned char *buf, int npxls )
{
   int nbits = (pxbytes == 2) ? 5 : 8;
   int nshft = (pxbytes == 2) ? 3 : 0;
   int mask = (1 << nbits) - 1;
   int n = 0;
   for( int i=0; i<npxls; i++ )
   {
      long pxv;
      if( fread( &pxv, pxbytes, 1, tga_file ) != 1 )
         break;
      buf[n+2] = (pxv & mask) << nshft;
      pxv >>= nbits;
      buf[n+1] = (pxv & mask) << nshft;
      pxv >>= nbits;
      buf[n] = (pxv & mask) << nshft;
      n += 3;
   }
   if( mirrored )
      reverse3( buf, npxls );
}

void TgaDecoder::readrlergb( unsigned char *buf, int npxls )
{
   int nbits = (pxbytes == 2) ? 5 : 8;
   int nshft = (pxbytes == 2) ? 3 : 0;
   int mask = (1 << nbits) - 1;
   int n = 0;
   int cnt;
   long pxv;
   while( n < npxls * 3 )
   {
      if( (cnt = fgetc( tga_file )) < 0 )
         break;
      if( cnt > 127 )
      {
         cnt -= 126;
         fread( &pxv, pxbytes, 1, tga_file );
         int b = (int) ((pxv & mask) << nshft);
         pxv >>= nbits;
         int g = (int) ((pxv & mask) << nshft);
         pxv >>= nbits;
         int r = (int) ((pxv & mask) << nshft);
         while( cnt-- > 0 )
         {
            buf[n++] = r;
            buf[n++] = g;
            buf[n++] = b;
         }
      }
      else
      {
         while( cnt-- > 0 )
         {
            fread( &pxv, pxbytes, 1, tga_file );
            int b = (int) ((pxv & mask) << nshft);
            pxv >>= nbits;
            int g = (int) ((pxv & mask) << nshft);
            pxv >>= nbits;
            int r = (int) ((pxv & mask) << nshft);
            buf[n++] = r;
            buf[n++] = g;
            buf[n++] = b;
         }
      }
   }
   if( mirrored )
      reverse3( buf, npxls );
}

int TgaDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( mapped )  // pixels are indexes
      {
         if( encoded )
            readrlemapped( buf, npxls );
         else
            readmapped( buf, npxls );
      }
      else          // pixels are colors
      {
         if( encoded )
            readrlergb( buf, npxls );
         else
            readrgb( buf, npxls );
      }
   }
   return status();
}

//.............class TgaEncoder

TgaEncoder::TgaEncoder( FILE *f_out, TGAHEADER& hdr )
{
   tga_file = f_out;
   cond = xOKAY;
   pxl_bytes = (hdr.cmtype == 0) ? 3 : 1;
   scanln = 0;
   if( pxl_bytes == 3 )
   {
      int n = pxl_bytes * hdr.imwidth;
      scanln = new unsigned char [n];
      cond = (scanln == 0) ? xNOMEMORY : xOKAY;
   }
}

int TgaEncoder::status( void )
{
   if( ferror( tga_file ) ) cond = xIOERROR;
   return cond;
}

int TgaEncoder::init( void )
{
   return status();
}

int TgaEncoder::term( void )
{
   return status();
}

int TgaEncoder::encode( unsigned char *buf, int npxls )
{
   if( pxl_bytes == 1 )
      fwrite( buf, npxls, 1, tga_file );
   else
   {
      int n = 0;
      for( int i=0; i<npxls; i++ )
      {
         scanln[n] = buf[n+2];
         scanln[n+1] = buf[n+1];
         scanln[n+2] = buf[n];
         n += 3;
      }
      fwrite( scanln, n, 1, tga_file );
   }
   return status();
}
