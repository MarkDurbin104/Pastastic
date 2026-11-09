//--------------------------------------------------------//
//                                                        //
//   File:    WPG.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            WordPerfect Graphics File Format            //
//                                                        //
//--------------------------------------------------------//

#include "wpg.hpp"

#define  RUN_MASK  0x80     // mask top bit
#define  CNT_MASK  0x7F     // mask bottom 7 bits
#define  MAX_RUN   0x7F     // max repeat count

static char *WpgRecordNames[] =
{
   "Undefined",           // 0
   "Fill Attribute",      // 1
   "Line Attribute",      // 2
   "Marker Attribute",    // 3
   "Poly Marker",         // 4
   "Line",                // 5
   "Poly Line",           // 6
   "Rectangle",           // 7
   "Polygon",             // 8
   "Ellipse",             // 9
   "Curve",               // 10
   "Bitmap",              // 11
   "Text",                // 12
   "Text Attribute",      // 13
   "Color Map",           // 14
   "Begin WPG",           // 15
   "End WPG",             // 16
   "PostScript Data",     // 17
   "Output Attribute",    // 18
};

//.............default WPG palette

static rgb default_colors[] =
{
   rgb(   0,   0,   0 ),
   rgb(   0,   0, 170 ),
   rgb(   0, 170,   0 ),
   rgb(   0, 170, 170 ),
   rgb( 170,   0,   0 ),
   rgb( 170,   0, 170 ),
   rgb( 170,  85,   0 ),
   rgb( 170, 170, 170 ),
   rgb(  85,  85,  85 ),
   rgb(  85,  85, 255 ),
   rgb(  85, 255,  85 ),
   rgb(  85, 255, 255 ),
   rgb( 255,  85,  85 ),
   rgb( 255,  85, 255 ),
   rgb( 255, 255,  85 ),
   rgb( 255, 155, 255 )
};

static RgbPalette palette;

// return the current palette

RgbPalette * WpgPalette( void )
{
   // if palette is undefined, supply a default
   if( palette.ncolors == 0 )
   {
      palette.ncolors = 16;
      palette.colors = new rgb[16];
      if( palette.colors )
      {
         for( int i=0; i<16; i++ )
         palette.colors[i] = default_colors[i];
      }
      else
         palette.ncolors = 0;
   }

   return &palette;
}

// read a color map from WPG file

RgbPalette * WpgPalette( FILE *f )
{
   // read start index, color count
   int c1, cc;
   fread( &c1, 2, 1, f );
   fread( &cc, 2, 1, f );
   if( (c1 < 0) || (cc < 0) )
      return &palette;

   // total colors
   int nc = cc + c1;

   // need to allocate or reallocate?
   if( palette.ncolors == 0 )
   {
      palette.colors = new rgb[nc];
      palette.ncolors = palette.colors ? nc : 0;
   }
   else if( palette.ncolors < nc )
   {
      rgb *newcolors = new rgb[nc];
      if( newcolors == 0 )
         return &palette;
      for( int i=0; i<palette.ncolors; i++ )
         newcolors[i] = palette.colors[i];
      delete palette.colors;
      palette.colors = newcolors;
      palette.ncolors = nc;
   }

   // read the colors
   while( cc-- )
   {
      palette.colors[c1].red = fgetc( f );
      palette.colors[c1].grn = fgetc( f );
      palette.colors[c1].blu = fgetc( f );
      c1++;
   }

   return &palette;
}

//.............struct WPGHEADER

WPGHEADER::WPGHEADER( int ftype )
{
   fileid[0] = -1;
   fileid[1] = 'W';
   fileid[2] = 'P';
   fileid[3] = 'C';
   dataofs = 16;
   prodtype = 1;
   filetype = ftype;
   majver = 1;
   minver = 0;
   enckey = 0;
   resv = 0;
}

int WPGHEADER::get( FILE *f )
{
   return ( fread(fileid,sizeof(WPGHEADER),1,f) == 1 ) ?
          0 : -1;
}

int WPGHEADER::put( FILE *f )
{
   return ( fwrite(fileid,sizeof(WPGHEADER),1,f) == 1 ) ?
          0 : -1;
}

int WPGHEADER::validate( void )
{
   if( fileid[0] != -1 )  return -1;
   if( fileid[1] != 'W' ) return 'W';
   if( fileid[2] != 'P' ) return 'P';
   if( fileid[3] != 'C' ) return 'C';
   if( filetype != 22 )   return 22;
   return 0;
}

void WPGHEADER::list( void )
{
   printf( "WPGHEADER::fileid   = %d %c %c %c\n",
            fileid[0], fileid[1], fileid[2], fileid[3] );
   printf( "WPGHEADER::dataofs  = %ld\n", dataofs );
   printf( "WPGHEADER::prodtype = %d\n", prodtype );
   printf( "WPGHEADER::filetype = %d\n", filetype );
   printf( "WPGHEADER::majver   = %d\n", majver );
   printf( "WPGHEADER::minver   = %d\n", minver );
   printf( "WPGHEADER::enckey   = %d\n", enckey );
   printf( "WPGHEADER::resv     = %d\n", resv );
}

//.............struct WPGTAG

int WPGTAG::get( FILE *f )
{
   reclength = 0;
   if( (rectype = fgetc( f )) < 0 ) return -1;
   int i;
   if( (i = fgetc(f)) < 0 ) return -1;
   if( i < 255 ) { reclength = i; return 0; }
   if( fread(&i,1,2,f) != 2 ) return -1;
   if( i > 0 ) { reclength = i; return 0; }
   i &= 0x7FFF;
   reclength = i;
   reclength <<= 16;
   if( fread(&i,1,2,f) != 2 ) return -1;
   reclength |= ((long) i ) & 0x0000FFFFL;
   return 0;
}

int WPGTAG::put( FILE *f, int lenbytes )
{
   char  ch;
   short hi, lo;

   fputc( rectype, f );
   switch( lenbytes )
   {
      case 0 :  // determine appropriate size
           if( reclength < 255 )
           {
              ch = (char) reclength;
              fputc( ch, f );
           }
           else if( reclength < 32767L )
           {
              fputc( 255, f );
              lo = (short) reclength;
              fwrite( &lo, 2, 1, f );
           }
           else
           {
              fputc( 255, f );
              lo = (short) reclength;
              hi = (short) ((long) reclength >> 16);
              hi |= 0x8000;
              fwrite( &hi, 2, 1, f );
              fwrite( &lo, 2, 1, f );
           }
           break;

      case 1 :  // byte
           ch = (char) reclength;
           fputc( ch, f );
           break;

      case 2 :  // word
           fputc( 255, f );
           lo = (short) reclength;
           fwrite( &lo, 2, 1, f );
           break;

      case 4 :  // double word
           fputc( 255, f );
           lo = (short) reclength;
           hi = (short) ((long) reclength >> 16);
           hi |= 0x8000;
           fwrite( &hi, 2, 1, f );
           fwrite( &lo, 2, 1, f );
           break;

      default : // error
           return lenbytes;
   }
   return ferror( f );
}

void WPGTAG::list( void )
{
   printf( "Type = %d", rectype );
   if( (rectype > wpgFirst) && (rectype < wpgLast) )
      printf( ", \"%s\", ", WpgRecordNames[rectype] );
   else
      printf( ", \"(Unknown, Unused, or Undefined)\", " );
   printf( "Length = %ld\n", reclength );
}

//.............struct WPGBEGIN

int WPGBEGIN::get( FILE *f )
{
   return ( fread(&version,sizeof(WPGBEGIN),1,f) == 1 ) ?
            0 : -1;
}

int WPGBEGIN::put( FILE *f )
{
   return ( fwrite(&version,sizeof(WPGBEGIN),1,f) == 1 ) ?
            0 : -1;
}

//.............struct WPGBMHEADER

int WPGBMHEADER::get( FILE *f )
{
   return ( fread(&bmwidth,sizeof(WPGBMHEADER),1,f) == 1 ) ?
            0 : -1;
}

int WPGBMHEADER::put( FILE *f )
{
   return ( fwrite(&bmwidth,sizeof(WPGBMHEADER),1,f) == 1 ) ?
            0 : -1;
}

void WPGBMHEADER::list( void )
{
   printf( "WPGBMHEADER::bmwidth  = %d\n", bmwidth );
   printf( "WPGBMHEADER::bmheight = %d\n", bmheight );
   printf( "WPGBMHEADER::bmdepth  = %d\n", bmdepth );
   printf( "WPGBMHEADER::bmxres   = %d px/in\n", bmxres );
   printf( "WPGBMHEADER::bmyres   = %d px/in\n", bmyres );
}

//.............class WpgDecoder

WpgDecoder::WpgDecoder( FILE *f_in, int nbits, int w, int h )
{
   wpg_file = f_in;
   pxbits   = nbits;
   pxmask   = (1 << pxbits) - 1;
   if( pxbits < 8 )
      pxmask <<= 8 - pxbits;
   width    = w;
   height   = h;
   count    = 0;
   pxls     = new unsigned char [width];
   cond     = pxls ? xOKAY : xNOMEMORY;
}

WpgDecoder::~WpgDecoder( )
{
   if( pxls ) delete pxls;
}

int WpgDecoder::status( void )
{
   if( ferror( wpg_file ) ) cond = xIOERROR;
   if( feof( wpg_file ) )   cond = xENDOFFILE;
   return cond;
}

int WpgDecoder::init( void )
{
   count = 0;
   cond  = pxls ? xOKAY : xNOMEMORY;
   return status();
}

int WpgDecoder::term( void )
{
   return status();
}

int WpgDecoder::putpixel( int pxbyte, int curpx )
{
   int mask = pxmask;
   int n = 8 - pxbits;
   while( mask )
   {
      pxls[curpx++] = (pxbyte & mask) >> n;
      mask >>= pxbits;
      n -= pxbits;
   }
   return curpx;
}

int WpgDecoder::readline( void )
{
   int nlines = 1;
   int n = 0;
   while( n < width )
   {
     int x = fgetc( wpg_file );
     if( x < 0 ) break;
     int highbit = (x & 0x80) ? 1 : 0;
     int cnt = x & 0x7F;
     if( highbit )
     {
        if( cnt > 0 )
        {
           int dat = fgetc( wpg_file );
           while( cnt-- > 0 )
              n = putpixel( dat, n );
        }
        else
        {
           cnt = fgetc( wpg_file );
           while( cnt-- > 0 )
              n = putpixel( 0xFF, n );
        }
     }
     else
     {
        if( cnt > 0 )
        {
           while( cnt-- > 0 )
           {
              int dat = fgetc( wpg_file );
              n = putpixel( dat, n );
           }
        }
        else
        {
           nlines = fgetc( wpg_file );
           break;
        }
     }
   }
   return nlines;
}

int WpgDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( count == 0 )
         count = readline();
      memcpy( buf, pxls, npxls );
      count--;
   }
   return status();
}

//..................class WpgEncoder

WpgEncoder::WpgEncoder( FILE *f_out, WPGBMHEADER& wpg )
{
   pxl_bits = wpg.bmdepth;
   row_bytes = (wpg.bmwidth*wpg.bmdepth + 7) / 8;
   wpg_file = f_out;
   scanbuffer = new char[row_bytes];
   cond = (scanbuffer == 0) ? xNOMEMORY : xOKAY;
}

int WpgEncoder::status( void )
{
   if( ferror( wpg_file ) ) cond = xIOERROR;
   return cond;
}

int WpgEncoder::init( void )
{
   cond = (scanbuffer == 0) ? xNOMEMORY : xOKAY;
   return status();
}

int WpgEncoder::term( void )
{
   return status();
}

void WpgEncoder::initbuffer( void )
{
   memset( scanbuffer, 0, row_bytes );
   scanmask = 0x80;
   scanbyte = 0;
}

void WpgEncoder::putbits( int bits, int nbits )
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

void WpgEncoder::putbyte( int byte )
{
   scanbuffer[scanbyte++] = byte;
}

int WpgEncoder::flush( void )
{
   // encode and write scanbuffer
   int n1, n2=-1, n, nt=0;

   while( nt < row_bytes )
   {
      n1 = n2 + 1;
      n2 = n1 + 1;

      // single byte left
      if( n1 == row_bytes - 1 )
      {
         fputc( 1, wpg_file );
         fputc( scanbuffer[n1], wpg_file );
         nt++;
      }

      // repeating run of 2 or more bytes
      else if( scanbuffer[n1] == scanbuffer[n2] )
      {
         while( (scanbuffer[n1] == scanbuffer[n2]) &&
                (n2 < row_bytes) )
            n2++;
         if( n2 == row_bytes )
            n2--;
         n = n2 - n1 + 1;
         nt += n;
         while( n > MAX_RUN )
         {
            fputc( MAX_RUN|RUN_MASK, wpg_file );
            fputc( scanbuffer[n1], wpg_file );
            n -= MAX_RUN;
         }
         fputc( n|RUN_MASK, wpg_file );
         fputc( scanbuffer[n1], wpg_file );
      }

      // nonrepeating run of 2 or more bytes
      else
      {
         while( (scanbuffer[n2] != scanbuffer[n2-1]) &&
                (n2 < row_bytes) )
            n2++;
         if( n2 == row_bytes )
            n2--;
         n = n2 - n1 + 1;
         nt += n;
         while( n > MAX_RUN )
         {
            fputc( MAX_RUN, wpg_file );
            fwrite( scanbuffer+n1, MAX_RUN, 1, wpg_file );
            n -= MAX_RUN;
            n1 += MAX_RUN;
         }
         fputc( n, wpg_file );
         fwrite( scanbuffer+n1, n, 1, wpg_file );
      }
   }

   return status();
}

// encodes 1, 2, or 4 bits per pixel
void WpgEncoder::write_124( unsigned char *buf, int npxls )
{
    initbuffer();
    int n = 0;
    while( n < npxls )
       putbits( buf[n++], pxl_bits );
    flush();
}

// encodes 8 bits per pixel
void WpgEncoder::write_8( unsigned char *buf, int npxls )
{
    initbuffer();
    int n = 0;
    while( n < npxls )
       putbyte( buf[n++] );
    flush();
}

int WpgEncoder::encode( unsigned char *buf, int npxls )
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
