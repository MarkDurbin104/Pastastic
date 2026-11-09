//--------------------------------------------------------//
//                                                        //
//   File:    GIFLZW.CPP                                  //
//                                                        //
//   Desc:    Encoder and Decoder classes for GIF/LZW     //
//                                                        //
//--------------------------------------------------------//

#include "giflzw.hpp"

//..................defines

#define  MAXBITS       12
#define  TBLSIZE       (1 << MAXBITS)
#define  HASHSIZE      5101
#define  HASHBITS      4
#define  NULLCHAR      0
#define  NULLCODE      -1
#define  SIGNAL        -99
#define  BUFSIZE       255
#define  ROOTSIZ( x )  ( x > 1 ? x+1 : 3 )
#define  NROOTS( x )   ( x > 1 ? (1 << x) : 4 )

//..................class CodeFile

CodeFile::CodeFile( FILE* f, int nbits )
{
   cond = xOKAY;
   capacity = BUFSIZE;
   buffer = new char [capacity];
   if( buffer == 0 )
   {
      cond = xNOMEMORY;
      capacity = 0;
      return;
   }
   filep = f;
   codesize = nbits+1;
}

CodeFile::~CodeFile( )
{
   if( buffer ) delete buffer;
}

void CodeFile::clearbuf( void )
{
   memset( buffer, 0, capacity );
   bytecnt = 0;
   curbyte = 0;
   curbit = 1;
}

int CodeFile::flushbuf( void )
{
   if( bytecnt > 0 )
   {
      fputc( bytecnt, filep );
      fwrite( buffer, bytecnt, 1, filep );
      if( ferror(filep) ) cond = xIOERROR;
      clearbuf();
   }
   return cond;
}

int CodeFile::loadbuf( void )
{
   curbyte = 0;
   curbit = 1;
   bytecnt = fgetc( filep );
   if( bytecnt > 0 )
      fread( buffer, bytecnt, 1, filep );
   if( feof(filep) )
      cond = xENDOFFILE;
   else if( ferror(filep) )
      cond = xIOERROR;
   return cond;
}

int CodeFile::getcode( void )
{
   if( bytecnt == 0 )
      loadbuf();
   int code = 0;
   int mask = 1;
   for( int i=0; i<codesize; i++ )
   {
      if( buffer[curbyte] & curbit )
         code |= mask;
      mask <<= 1;
      curbit <<= 1;
      if( curbit > 128 )
      {
         curbit = 1;
         curbyte++;
         bytecnt--;
         if( bytecnt == 0 )
            loadbuf();
      }
   }
   return code;
}

void CodeFile::putcode( int code )
{
   int mask = 1;
   for( int i=0; i<codesize; i++ )
   {
      if( code & mask )
         buffer[curbyte] |= curbit;
      mask <<= 1;
      curbit <<= 1;
      if( curbit > 128 )
      {
         curbit = 1;
         curbyte++;
         if( curbyte == capacity )
            flushbuf();
      }
      else if( curbit == 2 )
         bytecnt++;
   }
}

// this function is not required, but is handy
// for debugging and other purposes.

void CodeFile::dumpcode( int code )
{
   int mask = 1 << codesize;
   for( int i=0; i<codesize; i++ )
   {
      mask >>= 1;
      if( code & mask ) printf( "1" );
      else              printf( "0" );
   }
}

//..................class LzwEncoderTable

LzwEncoderTable::LzwEncoderTable( int rootsize )
{
   cond = xOKAY;
   capacity = HASHSIZE;
   root_size = rootsize;
   code_value = new int [capacity];
   prefix_code = new int [capacity];
   append_char = new int [capacity];
   if( (code_value == 0) ||
       (prefix_code == 0) ||
       (append_char == 0) )
   {
      cond = xNOMEMORY;
      capacity = 0;
   }
   else
      cleartbl();
}

LzwEncoderTable::~LzwEncoderTable( )
{
   if( code_value ) delete code_value;
   if( prefix_code ) delete prefix_code;
   if( append_char ) delete append_char;
}

void LzwEncoderTable::cleartbl( void )
{
   next_code = (1 << root_size) + 2;
   for( int i=0; i<capacity; i++ )
      code_value[i] = NULLCODE;
}

int LzwEncoderTable::findstr( int pfx, int chr )
{
   int i = (chr << HASHBITS) ^ pfx;
   int di = (i==0) ? 1 : capacity - i;
   while( 1 )
   {
      if( code_value[i] == NULLCODE )
         break;
      if( (prefix_code[i] == pfx) &&
          (append_char[i] == chr) )
         break;
      i -= di;
      if( i < 0 ) i += capacity;
   }
   return i;
}

int LzwEncoderTable::addstr( int pfx, int chr, int index )
{
   code_value[index]  = next_code++;
   prefix_code[index] = pfx;
   append_char[index] = chr;
   if( next_code > TBLSIZE ) cond = xOVERFLOW;
   return code_value[index];
}

//..................class GifEncoder

GifEncoder::GifEncoder( FILE* outfile, int pixelsize ) :
            Encoder( tGIFLZW ),
            CodeFile( outfile, pixelsize ),
            LzwEncoderTable( pixelsize )
{
   minbits = pixelsize > 1 ? pixelsize+1 : pixelsize+2;
   clearcode = 1 << pixelsize;
   endcode = clearcode + 1;
}

GifEncoder::~GifEncoder( )
{
}

int GifEncoder::init( void )
{
   cond = xOKAY;
   curbits = minbits;
   maxcode = (1 << curbits) - 1;
   clearbuf();
   putcode( clearcode );
   string = SIGNAL;
   return status();
}

int GifEncoder::term( void )
{
   putcode( string );
   putcode( endcode );
   flushbuf();
   return status();
}

int GifEncoder::encode( unsigned char *line, int size )
{
   if( string == SIGNAL )
   {
      string = *line++;
      size--;
   }
   while( (size > 0) && (status() == xOKAY) )
   {
      character = *line++;
      size--;
      int index = findstr( string, character );
      if( code_value[index] != -1 )  // string found
      {
         string = code_value[index];
      }
      else // string not found
      {
         int code = addstr( string, character, index );
         putcode( string );
         string = character;
         if( code > maxcode )
         {
            curbits++;
            if( curbits > MAXBITS )
            {
               putcode( clearcode );
               curbits = minbits;
               cleartbl();
            }
            maxcode = (1 << curbits) - 1;
            if( curbits == MAXBITS ) maxcode--;
            setsize( curbits );
         }
      }
   }
   return status();
}

int GifEncoder::status( void )
{
   return cond | CodeFile::cond | LzwEncoderTable::cond;
}

//..................class ByteStack

ByteStack::ByteStack( int size )
{
   cond = xOKAY;
   capacity = size;
   top = bot = sp = 0;
   bot = new char [size];
   if( bot == 0 )
   {
      cond = xNOMEMORY;
      capacity = 0;
      return;
   }
   top = bot + size;
   sp = top;
}

ByteStack::~ByteStack(  )
{
   if( bot ) delete bot;
}

void ByteStack::push( int x )
{
   if( sp > bot ) *--sp = x;
   else cond = xOVERFLOW;
}

int ByteStack::pop( void )
{
   if( sp < top ) return *sp++;
   return NULLCHAR;
}

void ByteStack::purge( void )
{
   sp = top;
}

//.................. class LzwDecoderTable

LzwDecoderTable::LzwDecoderTable( int rootsize )
{
   cond = xOKAY;
   capacity = TBLSIZE;
   root_size = rootsize;
   prefix_code = new int [capacity];
   append_char = new int [capacity];
   if( (prefix_code == 0) ||
       (append_char == 0) )
   {
      cond = xNOMEMORY;
      capacity = 0;
   }
   else
      cleartbl();
}

LzwDecoderTable::~LzwDecoderTable( )
{
   if( prefix_code ) delete prefix_code;
   if( append_char ) delete append_char;
}

void LzwDecoderTable::cleartbl( void )
{
   next_code = (1 << root_size) + 2;
   for( int i=0; i<next_code; i++ )
   {
      append_char[i] = i;
      prefix_code[i] = NULLCODE;
   }
}

int LzwDecoderTable::addstr( int pfx, int chr )
{
   if( next_code < capacity )
   {
      prefix_code[next_code] = pfx;
      append_char[next_code] = chr;
      next_code++;
      return next_code;
   }
   cond = xOVERFLOW;
   return 32000;
}

//..................class GifDecoder

GifDecoder::GifDecoder( FILE* infile, int pixelsize ) :
            Decoder( tGIFLZW ),
            CodeFile( infile, pixelsize ),
            ByteStack( TBLSIZE+TBLSIZE ),
            LzwDecoderTable( pixelsize )
{
   minbits = pixelsize > 1 ? pixelsize+1 : pixelsize+2;
   clearcode = 1 << pixelsize;
   endcode = clearcode + 1;
}

GifDecoder::~GifDecoder( )
{
}

int GifDecoder::pushstr( int code )
{
   while( code != NULLCODE )
   {
      push( append_char[code] );
      code = prefix_code[code];
      if( code == prefix_code[code] ) break;
   }
   return *sp;
}

int GifDecoder::init( void )
{
   cond = xOKAY;
   curbits = minbits;
   maxcode = (1 << curbits) - 1;
   cleartbl();
   purge();
   clearbuf();
   oldcode = SIGNAL;
   return status();
}

int GifDecoder::term( void )
{
   return status();
}

int GifDecoder::status( void )
{
   return cond | CodeFile::cond |
          LzwDecoderTable::cond | ByteStack::cond;
}

int GifDecoder::decode(  unsigned char *line, int size )
{
   // output any previously decoded bytes
   while( (! empty()) && (size > 0) )
   {
      *line++ = pop();
       size--;
   }

   if( oldcode == SIGNAL )
   {
      while( (oldcode = getcode()) == clearcode ) { }
      push( oldcode );
   }

   // decode remainder of the row
   while( (size > 0) && (status() == xOKAY) )
   {
      // get a new code
      newcode = getcode();

      // decode it
      if( (newcode == endcode) || (newcode == NULLCODE) )
         break;
      else if( newcode == clearcode )
      {
         cleartbl();
         setsize( minbits );
         curbits = minbits;
         maxcode = (1 << codesize) - 1;
         oldcode = getcode();
         push( oldcode );
      }
      else
      {
         if( findstr( newcode ) )
         {
            firstch = pushstr( newcode );
         }
         else
         {
            push( firstch );
            firstch = pushstr( oldcode );
         }
         if( addstr( oldcode, firstch ) > maxcode )
         {
            curbits++;
            if( curbits > MAXBITS )
            {
               // we should have gotten a clearcode
               // before this - we try to continue
               cond = xOUTOFSYNC;
               curbits = minbits;
               cleartbl();
            }
            setsize( curbits );
            maxcode = (1 << curbits) - 1;
         }
         oldcode = newcode;
      }

      // output the just-decoded string
      while( (! empty()) && (size > 0) )
      {
         *line++ = pop();
         size--;
      }
   }

   return status();
}
