//--------------------------------------------------------//
//                                                        //
//   File:   GIF.CPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for          //
//           a Gif Coder and Decoder                      //
//                                                        //
//--------------------------------------------------------//

#include "gifcodec.hpp"

//..................class BitString

BitString::BitString( int bits, int width )
{
   int mask = 1 << width;
   for( int n=0; n<width; n++ )
   {
      mask >>= 1;
      str[n] = (bits & mask) ? '1' : '0';
   }
   str[width] = 0;
}

//..................class iCodeStream

iCodeStream::iCodeStream( FILE *f, int size )
{
   ifile = f;
   nbytes = curbyte = 0;
   nbits = size;
   bytecode = 0;
   bytemask = 0x80;
   bitcode = 0;
   bitmask = 0x01;
}

iCodeStream::~iCodeStream( )
{
}

int iCodeStream::getbyte( void )
{
   if( curbyte >= nbytes )
   {
      if( (nbytes = fgetc( ifile )) < 1 )
         return -1;
      if( fread( buffer, nbytes, 1, ifile ) != 1 )
         return -1;
      curbyte = 0;
   }
   return buffer[curbyte++];
}

int iCodeStream::getcode( void )
{
   bitcode = 0;
   bitmask = 1;
   int n = nbits;
   while( n-- > 0 )
   {
      if( (bytemask<<=1) > 0x80 )
      {
         bytemask = 1;
         if( (bytecode = getbyte( )) < 0 )
            return -1;
      }
      if( bytecode & bytemask )
         bitcode |= bitmask;
      bitmask <<= 1;
   }
   return bitcode;
}

//..................class GifDecoder

GifDecoder::GifDecoder( FILE* infile, int cobits, int pxcnt ) :
            Decoder( ), iCodeStream( infile, cobits+1 )
{
   cond     = xOKAY;
   minsize  = cobits + 1;
   maxsize  = 12;
   nroots   = 1 << cobits;
   capacity = 1 << maxsize;
   rwbytes  = pxcnt;
   prefix   = new int [capacity];
   suffix   = new unsigned char [capacity];
   stack    = new unsigned char [capacity];
   bytes    = new unsigned char [rwbytes];
   if( ! prefix || ! suffix || ! stack || ! bytes )
      cond = xNOMEMORY;
   else
   {
      stkp = 0;
      clear();
   }
}

GifDecoder::~GifDecoder( )
{
   delete prefix;
   delete suffix;
   delete stack;
   delete bytes;
}

int GifDecoder::push( int s )
{
   if( stkp < capacity )
   {
      stack[stkp++] = s;
      return xOKAY;
   }
   return xOVERFLOW;
}

void GifDecoder::clear( void )
{
   cursize = minsize;
   width( cursize );
   clrc = nroots;
   endc = clrc + 1;
   curcode = endc + 1;
   maxcode = 1 << cursize;
   for( int i=0; i<curcode; i++ )
   {
      suffix[i] = i;
      prefix[i] = 0;
   }
}

int GifDecoder::init( void )
{
   clear();
   while( (oldc=getcode()) == clrc ) { ; }
   newc = oldc;
   return status();
}

int GifDecoder::term( void )
{
   return status();
}

int GifDecoder::status( void )
{
   if( cond != xOKAY ) return cond;
   if( feof(ifile) ) cond = xENDOFFILE;
   if( ferror(ifile) ) cond = xIOERROR;
   return cond;
}

int GifDecoder::decode( unsigned char *buf, int npxls )
{
    int nb = 0;

    // empty stack into scan line buffer
    while( (stkp > 0) && (nb < rwbytes) )
       bytes[nb++] = stack[--stkp];

    // loop until a row has been decoded
    int code;
    while( nb < rwbytes )
    {
       //....... get next code
       if( (code=getcode()) < 0 ) break;

       //....... check for a clear code
       if( code == clrc )
       {
          init();
          if( oldc == endc ) break;
          bytes[nb++] = oldc;
          if( nb == rwbytes ) break;
       }

       //....... check for an end code
       else if( code == endc )
       {
          break;
       }

       //....... code is a data code
       else
       {
          if( code == curcode )
          {
             code = oldc;
             cond = push( newc );
          }
          else if( code > curcode )
          {
             cond = xOUTOFSYNC;
             break;
          }
          while( code > endc )
          {
             cond = push( suffix[code] );
             code = prefix[code];
          }
          cond = push( code );

          // add code to table
          if( curcode < maxcode )
          {
             newc = code;
             suffix[curcode] = newc;
             prefix[curcode] = oldc;
             oldc = lastcode();
             curcode++;
          }

          // current width exhausted?
          if( curcode >= maxcode )
          {
             if( cursize < maxsize )
             {
                cursize++;
                width( cursize );
                maxcode <<= 1;
             }
             else if( (code=getcode()) == clrc )
             {
                init();
                if( oldc == endc ) break;
                bytes[nb++] = oldc;
                if( nb == rwbytes ) break;
             }
             else
             {
                cond = xOVERFLOW;
                break;
             }
          }

          // transfer string from stack to buffer
          while( (stkp > 0) && (nb < rwbytes) )
             bytes[nb++] = stack[--stkp];
       }
    }

    memcpy( buf, bytes, npxls );

    return status();
}

//..................class oCodeStream

oCodeStream::oCodeStream( FILE *f, int size )
{
   ofile = f;
   nbytes = 0;
   nbits = size;
   bytecode = 0;
   bytemask = 1;
}

oCodeStream::~oCodeStream( )
{
}

int oCodeStream::putbyte( int byt )
{
   buffer[nbytes++] = byt;
   if( nbytes == 255 )
   {
      fputc( nbytes, ofile );
      fwrite( buffer, nbytes, 1, ofile );
      nbytes = 0;
   }
   return ferror(ofile) ? xIOERROR : xOKAY;
}

int oCodeStream::putcode( int code )
{
   int mask = 1;
   int n = nbits;
   while( n-- > 0 )
   {
      if( code & mask )
         bytecode |= bytemask;
      if( (bytemask <<= 1) > 0x80 )
      {
         if( putbyte( bytecode ) != xOKAY )
            return xIOERROR;
         bytecode = 0;
         bytemask = 1;
      }
      mask <<= 1;
   }
   return xOKAY;
}

int oCodeStream::flush( void )
{
   if( bytemask != 1 )
   {
      putbyte( bytecode );
      bytecode = 0;
      bytemask = 1;
   }
   if( nbytes > 0 )
   {
      fputc( nbytes, ofile );
      fwrite( buffer, nbytes, 1, ofile );
      nbytes = 0;
   }
   return ferror(ofile) ? xIOERROR : xOKAY;
}

//..................class GifEncoder

#define  HASHSIZE  5101
#define  HASHBITS  4
#define  TABLSIZE  4096
#define  EMPTY     -1

GifEncoder::GifEncoder( FILE* outfile, int cobits ) :
            Encoder( ),
            oCodeStream( outfile, cobits+1 )
{
   cond     = xOKAY;
   started  = 0;
   minsize  = cobits + 1;
   maxsize  = 12;
   nroots   = 1 << cobits;
   capacity = HASHSIZE;
   clrc     = nroots;
   endc     = clrc + 1;
   codes    = new int [capacity];
   prefix   = new int [capacity];
   suffix   = new int [capacity];
   if( ! codes || ! prefix || ! suffix )
      cond = xNOMEMORY;
   else
      clear();
}

GifEncoder::~GifEncoder( )
{
   delete codes;
   delete prefix;
   delete suffix;
}

void GifEncoder::clear( void )
{
   cursize = minsize;
   width( cursize );
   curcode = endc + 1;
   maxcode = 1 << cursize;
   for( int i=0; i<HASHSIZE; i++ )
   {
      codes[i] = EMPTY;
   }
}

int GifEncoder::findstr( int pfx, int sfx )
{
   int i = (sfx << HASHBITS) ^ pfx;
   int di = (i==0) ? 1 : capacity - i;
   while( 1 )
   {
      if( codes[i] == EMPTY )
         break;
      if( (prefix[i] == pfx) && (suffix[i] == sfx) )
         break;
      i -= di;
      if( i < 0 ) i += capacity;
   }
   return i;
}

int GifEncoder::init( void )
{
   started = 0;
   clear();
   putcode( clrc );
   return status();
}

int GifEncoder::term( void )
{
   putcode( strc );
   putcode( endc );
   flush();
   return status();
}

int GifEncoder::status( void )
{
   if( cond != xOKAY ) return cond;
   if( ferror( ofile ) ) cond = xIOERROR;
   return cond;
}

int GifEncoder::encode( unsigned char *buf, int npxls )
{
   int np = 0;

   // is this the first call?
   if( ! started )
   {
      strc = buf[np++];
      started = 1;
   }

   while( (np < npxls) && (status() == xOKAY) )
   {
      chrc = buf[np++];
      int i = findstr( strc, chrc );
      if( codes[i] != EMPTY )  //...... string found
      {
         strc = codes[i];
      }
      else //........................... string not found
      {
         // add to table
         codes[i]  = curcode;
         prefix[i] = strc;
         suffix[i] = chrc;
         putcode( strc );
         strc = chrc;
         curcode++;
         if( curcode > maxcode )
         {
            cursize++;
            if( cursize > maxsize )
            {
               putcode( clrc );
               clear();
            }
            else
            {
               width( cursize );
               maxcode <<= 1;
               if( cursize == maxsize )
                  maxcode--;
            }
         }
      }
   }

   return status();
}
