//--------------------------------------------------------//
//                                                        //
//   File:   XBM.CPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for dealing  //
//           with an X Windows bitmap file                //
//                                                        //
//--------------------------------------------------------//

#include "xbm.hpp"

//..................token handling primitives

inline int iswhite( int ch )
{
   if( ch == '_' ) return 0;
   if( ch == '#' ) return 0;
   if( isspace(ch) ) return 1;
   if( ispunct(ch) ) return 1;
   if( (ch=='[') || (ch==']') ) return 1;
   if( (ch=='{') || (ch=='}') ) return 1;
   if( (ch=='(') || (ch==')') ) return 1;
   return 0;
}

int tokencnt( char *s )
{
   int n = 0;

   while( *s )
   {
      while( iswhite( *s ) )
      {
         if( *s == 0 ) break;
         s++;
      }
      n++;
      while( ! iswhite( *s ) )
      {
         if( *s == 0 ) break;
         s++;
      }
   }

   return n;
}

int token( char *src, char *dst, int which )
{
   // skip leading tokens
   while( which-- > 0 )
   {
      while( iswhite( *src ) )
      {
         if( *src == 0 ) return 0;
         src++;
      }

      while( ! iswhite( *src ) )
      {
         if( *src == 0 ) return 0;
         src++;
      }
   }

   // extact the desired token
   while( iswhite( *src ) )
   {
      if( *src == 0 ) return 0;
      src++;
   }
   int n = 0;
   while( ! iswhite( *src ) )
   {
      if( *src == 0 ) break;
      *dst++ = *src++;
      n++;
   }
   *dst = 0;
   return n;
}

//..................class TKNFILE

TKNFILE::TKNFILE( char *path )
{
   maxch = 133;
   curtk = -1;
   fin = fopen( path, "rt" );
   ln = new char [maxch+1];
   if( ln ) memset( ln, 0, maxch+1 );
   tok = new char [maxch+1];
   if( tok ) memset( tok, 0, maxch+1 );
}

TKNFILE::~TKNFILE( )
{
   if( fin ) fclose( fin );
   delete ln;
   delete tok;
}

int TKNFILE::status( void )
{
   if( ln == 0 )     return xNOMEMORY;
   if( tok == 0 )    return xNOMEMORY;
   if( fin == 0 )    return xIOERROR;
   if( ferror(fin) ) return xIOERROR;
   if( feof(fin) )   return xENDOFFILE;
   return xOKAY;
}

char * TKNFILE::get( void )
{
   curtk++;
   while( token(ln,tok,curtk) == 0 )
   {
      if( fgets(ln,maxch,fin) == 0 )
         return 0;
      curtk = 0;
   }
   return tok;
}

//..................struct XBMNAMES

static char *suffix[NAMECNT] =
{
   "_width",
   "_height",
   "_x_hot",
   "_y_hot",
   "_bits"
};

XBMNAMES::XBMNAMES( char *prefix )
{
   int n = strlen(prefix) + 8;
   for( int i=0; i<NAMECNT; i++ )
   {
      names[i] = new char [n];
      if( names[i] )
      {
         strcpy( names[i], prefix );
         strcat( names[i], suffix[i] );
      }
   }
}

XBMNAMES::~XBMNAMES( )
{
   for( int i=0; i<NAMECNT; i++ )
      delete names[i];
}

int XBMNAMES::which( char *tok )
{
   for( int i=0; i<NAMECNT; i++ )
      if( strcmp(names[i],tok) == 0 )
         return i;
   return -1;
}

//..................struct XBMHEADER

void XBMHEADER::list( void )
{
   printf( "XBMHEADER::width  = %d\n", width );
   printf( "XBMHEADER::height = %d\n", height );
   printf( "XBMHEADER::xhot   = %d\n", xhot );
   printf( "XBMHEADER::yhot   = %d\n", yhot );
   printf( "XBMHEADER::name   = %s\n", name );
}

int XBMHEADER::get( TKNFILE *tf )
{
   // set some defaults
   width = height = 0;
   xhot = yhot = -1;

   // now scan tokens from file
   XBMNAMES xn( name );
   int  done = 0;
   while( ! done )
   {
      char *t = tf->get();
      if( t == 0 ) break;
      switch( xn.which( t ) )
      {
         case xWidth:
              width = atoi( tf->get() );
              break;
         case xHeight:
              height = atoi( tf->get() );
              break;
         case xXHot:
              xhot = atoi( tf->get() );
              break;
         case xYHot:
              yhot = atoi( tf->get() );
              break;
         case xBits:
              done = 1;
              break;
      }
   }
   return tf->status();
}

int XBMHEADER::put( FILE *f )
{
   int hdrvals[4];
   XBMNAMES xn( name );

   hdrvals[0] = width;
   hdrvals[1] = height;
   hdrvals[2] = xhot;
   hdrvals[3] = yhot;

   for( int i=0; i<4; i++ )
      fprintf( f, "#define %s %d\n",
               xn.names[i], hdrvals[i] );

   fprintf( f, "static unsigned char %s[] =\n",
               xn.names[4] );

   return ferror(f) ? -1 : 0;
}

//..................class XbmDecoder

XbmDecoder::XbmDecoder( TKNFILE *f_in )
{
   xbm_file = f_in;
   cond = xbm_file->status();
}

int XbmDecoder::init( void )
{
   return status();
}

int XbmDecoder::term( void )
{
   return status();
}

int XbmDecoder::status( void )
{
   cond = xbm_file->status();
   return cond;
}

int XbmDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      int i, n = 0;
      while( n < npxls )
      {
         sscanf( xbm_file->get(), "%x", &i );
         int mask = 1;
         while( mask < 255 )
         {
            if( n < npxls )
               buf[n++] = (i & mask) ? 1 : 0;
            mask <<= 1;
         }
      }
   }
   return status();
}

//..................class XbmEncoder

XbmEncoder::XbmEncoder( FILE *f_out )
{
   xbm_file = f_out;
}

int XbmEncoder::init( void )
{
   cnt = 0;
   fprintf( xbm_file, "{\n" );
   return status();
}

int XbmEncoder::term( void )
{
   if( cnt > 0 )
      fprintf( xbm_file, "\n" );
   fprintf( xbm_file, "};\n" );
   return status();
}

int XbmEncoder::status( void )
{
   cond = ferror(xbm_file) ? xIOERROR : xOKAY;
   return cond;
}

int XbmEncoder::encode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      int n=0;
      int mask = 1;
      for( int i=0; i<npxls; i++ )
      {
         if( buf[i] ) n |= mask;
         if( (mask <<= 1) > 255 )
         {
            fprintf( xbm_file, " 0x%02x,", n );
            cnt++;
            if( cnt == 12 )
            {
               fprintf( xbm_file, "\n" );
               cnt = 0;
            }
            n = 0;
            mask = 1;
         }
      }
      if( mask != 1 )
      {
         fprintf( xbm_file, " 0x%02x,", n );
         cnt++;
         if( cnt == 12 )
         {
            fprintf( xbm_file, "\n" );
            cnt = 0;
         }
      }
   }
   return status();
}
