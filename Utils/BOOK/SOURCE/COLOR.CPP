//--------------------------------------------------------//
//                                                        //
//   File:    COLOR.CPP                                   //
//                                                        //
//   Desc:    Classes for implementation of various       //
//            color models and their conversion.          //
//                                                        //
//--------------------------------------------------------//

extern "C"
{
   // see iscale.asm
   int iscale( int i, int m, int d );
}

#include "color.hpp"

//..............the RGB class

rgb::rgb( cmy& x )
{
   red = 255 - x.cyn;
   grn = 255 - x.mag;
   blu = 255 - x.yel;
}

rgb::rgb( cmyk& x )
{
   int i = x.cyn + x.blk;
   red = (i > 255) ? 0 : 255 - i;
   i = x.mag + x.blk;
   grn = (i > 255) ? 0 : 255 - i;
   i = x.yel + x.blk;
   blu = (i > 255) ? 0 : 255 - i;
}

unsigned char rgb::graylevel( void )
{
   int gry = iscale( red, 299, 1000 );
   gry += iscale( grn, 587, 1000 );
   gry += iscale( blu, 114, 1000 );
   return (unsigned char) gry;
}

//..............the CMY class

cmy::cmy( rgb& x )
{
   cyn = 255 - x.red;
   mag = 255 - x.grn;
   yel = 255 - x.blu;
}

cmy::cmy( cmyk& x )
{
   int i = x.cyn + x.blk;
   cyn = (i > 255) ? 255 : i;
   i = x.mag + x.blk;
   mag = (i > 255) ? 255 : i;
   i = x.yel + x.blk;
   yel = (i > 255) ? 255 : i;
}

unsigned char cmy::graylevel( void )
{
   int gry = iscale( 255-cyn, 299, 1000 );
   gry += iscale( 255-mag, 587, 1000 );
   gry += iscale( 255-yel, 114, 1000 );
   return (unsigned char) gry;
}

//..............the CMYK class

cmyk::cmyk( rgb& x )
{
   cmy C( x );
   int k = C.cyn;
   if( C.mag < k ) k = C.mag;
   if( C.yel < k ) k = C.yel;
   cyn = C.cyn - k;
   mag = C.mag - k;
   yel = C.yel - k;
   blk = k;
}

cmyk::cmyk( cmy& x )
{
   int k = x.cyn;
   if( x.mag < k ) k = x.mag;
   if( x.yel < k ) k = x.yel;
   cyn = x.cyn - k;
   mag = x.mag - k;
   yel = x.yel - k;
   blk = k;
}

unsigned char cmyk::graylevel( void )
{
   cmy C( *this );
   return C.graylevel();
}
