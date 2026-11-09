//--------------------------------------------------------//
//                                                        //
//   File:    COLOR.HPP                                   //
//                                                        //
//   Desc:    Classes for implementation of various       //
//            color models and their conversion.          //
//                                                        //
//--------------------------------------------------------//

#ifndef _COLOR_HPP_
#define _COLOR_HPP_

struct rgb;
struct cmy;
struct cmyk;

//...............an RGB class

struct rgb
{
   unsigned char red;
   unsigned char grn;
   unsigned char blu;

   rgb( )
   {
      red = grn = blu = 0;
   }
   rgb( int r, int g, int b )
   {
      red = r;
      grn = g;
      blu = b;
   }
   rgb( rgb& x )
   {
      red = x.red;
      grn = x.grn;
      blu = x.blu;
   }

   rgb( cmy& x );
   rgb( cmyk& x );
   unsigned char graylevel( void );

   rgb& operator = ( rgb& x )
   {
      red = x.red;
      grn = x.grn;
      blu = x.blu;
      return *this;
   }
   rgb operator << ( int i )
   {
      rgb x( red<<i, grn<<i, blu<<i );
      return x;
   }
   rgb& operator <<= ( int i )
   {
      red <<= i;
      grn <<= i;
      blu <<= i;
      return *this;
   }
   rgb operator >> ( int i )
   {
      rgb x( red>>i, grn>>i, blu>>i );
      return x;
   }
   rgb& operator >>= ( int i )
   {
      red >>= i;
      grn >>= i;
      blu >>= i;
      return *this;
   }
};

//...............a CMY class

struct cmy
{
   unsigned char cyn;
   unsigned char mag;
   unsigned char yel;

   cmy( )
   {
      cyn = mag = yel = 0;
   }
   cmy( int c, int m, int y )
   {
      cyn = c;
      mag = m;
      yel = y;
   }
   cmy( cmy& x )
   {
      cyn = x.cyn;
      mag = x.mag;
      yel = x.yel;
   }

   cmy( rgb& x );
   cmy( cmyk& x );
   unsigned char graylevel( void );

   cmy& operator = ( cmy& x )
   {
      cyn = x.cyn;
      mag = x.mag;
      yel = x.yel;
      return *this;
   }
   cmy operator << ( int i )
   {
      cmy x( cyn<<i, mag<<i, yel<<i );
      return x;
   }
   cmy& operator <<= ( int i )
   {
      cyn <<= i;
      mag <<= i;
      yel <<= i;
      return *this;
   }
   cmy operator >> ( int i )
   {
      cmy x( cyn>>i, mag>>i, yel>>i );
      return x;
   }
   cmy& operator >>= ( int i )
   {
      cyn >>= i;
      mag >>= i;
      yel >>= i;
      return *this;
   }
};

//...............a CMYK class

struct cmyk
{
   unsigned char cyn;
   unsigned char mag;
   unsigned char yel;
   unsigned char blk;

   cmyk( )
   {
      cyn = mag = yel = blk = 0;
   }
   cmyk( int c, int y, int m, int k )
   {
      cyn = c;
      mag = m;
      yel = y;
      blk = k;
   }
   cmyk( cmyk& x )
   {
      cyn = x.cyn;
      mag = x.mag;
      yel = x.yel;
      blk = x.blk;
   }

   cmyk( rgb& x );
   cmyk( cmy& x );
   unsigned char graylevel( void );

   cmyk& operator = ( cmyk& x )
   {
      cyn = x.cyn;
      mag = x.mag;
      yel = x.yel;
      blk = x.blk;
      return *this;
   }
   cmyk operator << ( int i )
   {
      cmyk x( cyn<<i, mag<<i, yel<<i, blk<<i );
      return x;
   }
   cmyk& operator <<= ( int i )
   {
      cyn <<= i;
      mag <<= i;
      yel <<= i;
      blk <<= i;
      return *this;
   }
   cmyk operator >> ( int i )
   {
      cmyk x( cyn>>i, mag>>i, yel>>i, blk>>i );
      return x;
   }
   cmyk& operator >>= ( int i )
   {
      cyn >>= i;
      mag >>= i;
      yel >>= i;
      blk >>= i;
      return *this;
   }
};

//...............an RGB palette class

struct RgbPalette
{
   rgb *colors;
   int  ncolors;

   RgbPalette( )
   {
      colors = 0;
      ncolors = 0;
   }
   RgbPalette( rgb *clrs, int nclrs )
   {
      colors = clrs;
      ncolors = nclrs;
   }
  ~RgbPalette( )
   {
   }
};

#endif
