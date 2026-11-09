//--------------------------------------------------------//
//                                                        //
//   File:   GIF.CPP                                      //
//                                                        //
//   Desc:   Structure and Class definitions for          //
//           CompuServe's GIF Format, Version 89a         //
//                                                        //
//--------------------------------------------------------//

#include "gif.hpp"

//..................struct GIFHEADER

void GIFHEADER::list( void )
{
   printf( "GIFHEADER::sig = %c%c%c\n",
           sig[0], sig[1], sig[2] );
   printf( "GIFHEADER::ver = %c%c%c\n",
           ver[0], ver[1], ver[2] );
}

int GIFHEADER::get( FILE *f )
{
   return (fread( sig, sizeof(GIFHEADER), 1, f ) == 1) ?
      0 : -1;
}

int GIFHEADER::put( FILE *f )
{
   return (fwrite( sig, sizeof(GIFHEADER), 1, f ) == 1) ?
      0 : -1;
}

int GIFHEADER::isvalid( void )
{
   if( strncmp( sig, "GIF", 3 ) != 0 )
      return 0;
   if( (strncmp( ver, "87a", 3 ) != 0) &&
       (strncmp( ver, "89a", 3 ) != 0) )
      return 0;
   return 1;
}

//..................struct GIFSCDESC

void GIFSCDESC::list( void )
{
   printf( "GIFSCDESC::scwidth  = %d\n", scwidth );
   printf( "GIFSCDESC::scheight = %d\n", scheight );
   printf( "GIFSCDESC::flags    = %02Xh\n", flags );
   printf( "           gct?     = %c\n",
           isgct() ? 'Y' : 'N' );
   printf( "           sorted?  = %c\n",
           issorted() ? 'Y' : 'N' );
   printf( "           depth    = %d\n", depth() );
   printf( "           ncolors  = %d\n", ncolors() );
   printf( "GIFSCDESC::pixasp   = %d\n", pixasp );
}

int GIFSCDESC::get( FILE *f )
{
   return (fread( &scwidth, sizeof(GIFSCDESC), 1, f ) == 1) ?
      0 : -1;
}

int GIFSCDESC::put( FILE *f )
{
   return (fwrite( &scwidth, sizeof(GIFSCDESC), 1, f ) == 1) ?
      0 : -1;
}

//..................struct GIFIMDESC

void GIFIMDESC::list( void )
{
   printf( "GIFIMDESC::id          = %02Xh\n", id );
   printf( "GIFIMDESC::xleft       = %d\n", xleft );
   printf( "GIFIMDESC::ytop        = %d\n", ytop );
   printf( "GIFIMDESC::imwidth     = %d\n", imwidth );
   printf( "GIFIMDESC::imheight    = %d\n", imheight );
   printf( "GIFIMDESC::flags       = %02Xh\n", flags );
   printf( "           lct?        = %c\n",
           islct() ? 'Y' : 'N' );
   printf( "           sorted?     = %c\n",
           issorted() ? 'Y' : 'N' );
   printf( "           interlaced? = %c\n",
           isinterlaced() ? 'Y' : 'N' );
   printf( "           ncolors     = %d\n", ncolors() );
}

int GIFIMDESC::get( FILE *f )
{
   // assume id has already been read
   return (fread( &xleft, sizeof(GIFIMDESC)-1, 1, f ) == 1)
          ? 0 : -1;
}

int GIFIMDESC::put( FILE *f )
{
   return (fwrite( &id, sizeof(GIFIMDESC), 1, f ) == 1)
          ? 0 : -1;
}

//..................struct GIFCTLEXT

void GIFCTLEXT::list( void )
{
   printf( "GIFCTLEXT::id    = %02Xh\n", id );
   printf( "GIFCTLEXT::label = %02Xh\n", label );
   printf( "GIFCTLEXT::size  = %d\n", size );
   printf( "GIFCTLEXT::flags = %02Xh\n", flags );
   printf( "GIFCTLEXT::delay = %d\n", delay );
   printf( "GIFCTLEXT::trclr = %d\n", trclr );
}

int GIFCTLEXT::get( FILE *f )
{
   // assume id-label has already been read
   return (fread( &size, sizeof(GIFCTLEXT)-2, 1, f ) == 1)
          ? 0 : -1;
}

int GIFCTLEXT::put( FILE *f )
{
   return (fwrite( &id, sizeof(GIFCTLEXT), 1, f ) == 1)
          ? 0 : -1;
}

//..................struct GIFCOMEXT

void GIFCOMEXT::list( void )
{
   printf( "GIFCOMEXT::id    = %02Xh\n", id );
   printf( "GIFCOMEXT::label = %02Xh\n", label );
}

int GIFCOMEXT::get( FILE *f )
{
   // assume id-label has already been read
   return 0;
}

int GIFCOMEXT::put( FILE *f )
{
   return (fwrite( &id, sizeof(GIFCOMEXT), 1, f ) == 1)
          ? 0 : -1;
}

//..................struct GIFTXTEXT

void GIFTXTEXT::list( void )
{
   printf( "GIFTXTEXT::id       = %02Xh\n", id );
   printf( "GIFTXTEXT::label    = %02Xh\n", label );
   printf( "GIFTXTEXT::size     = %d\n", size );
   printf( "GIFTXTEXT::xleft    = %d\n", xleft );
   printf( "GIFTXTEXT::ytop     = %d\n", ytop );
   printf( "GIFTXTEXT::txwidth  = %d\n", txwidth );
   printf( "GIFTXTEXT::txheight = %d\n", txheight );
   printf( "GIFTXTEXT::cewidth  = %d\n", cewidth );
   printf( "GIFTXTEXT::ceheight = %d\n", ceheight );
   printf( "GIFTXTEXT::fgclr    = %d\n", fgclr );
   printf( "GIFTXTEXT::bgclr    = %d\n", bgclr );
}

int GIFTXTEXT::get( FILE *f )
{
   // assume id-label has already been read
   return (fread( &size, sizeof(GIFTXTEXT)-2, 1, f ) == 1)
          ? 0 : -1;
}

int GIFTXTEXT::put( FILE *f )
{
   return (fwrite( &id, sizeof(GIFTXTEXT), 1, f ) == 1)
          ? 0 : -1;
}

//..................struct GIFAPPEXT

void GIFAPPEXT::list( void )
{
   printf( "GIFAPPEXT::id       = %02Xh\n", id );
   printf( "GIFAPPEXT::label    = %02Xh\n", label );
   printf( "GIFAPPEXT::size     = %d\n", size );
   printf( "GIFAPPEXT::apname   = " );
   for( int i=0; i<sizeof(apname); i++ )
      printf( "%c", apname[i] );
   printf( "\n" );
   printf( "GIFAPPEXT::apcode   = " );
   printf( "%d.%d.%d",
           apcode[0], apcode[1], apcode[2] );
   printf( "\n" );
}

int GIFAPPEXT::get( FILE *f )
{
   // assume id-label has already been read
   return (fread( &size, sizeof(GIFAPPEXT)-2, 1, f ) == 1)
          ? 0 : -1;
}

int GIFAPPEXT::put( FILE *f )
{
   return (fwrite( &id, sizeof(GIFAPPEXT), 1, f ) == 1)
          ? 0 : -1;
}
