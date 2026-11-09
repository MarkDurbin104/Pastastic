//--------------------------------------------------------//
//                                                        //
//   File:    DITHER.CPP                                  //
//                                                        //
//   Desc:    Bilevel and Color Dithering Classes         //
//                                                        //
//--------------------------------------------------------//

#include "string.h"

#include "dither.hpp"

extern "C"
{
   int iscale( int, int, int );
   long dist3( int, int, int, int, int, int );
}

//..................dither matrix

DitherMatrix::DitherMatrix( )
{
   width = height = 0;
   order = 0;
}

DitherMatrix::DitherMatrix( int w, int h, unsigned char *ord )
{
   width = height = 0;
   order = new unsigned char [w*h];
   if( order == 0 ) return;
   width = w;
   height = h;
   for( int i=0; i<w*h; i++ )
      order[i] = ord[i];
}

DitherMatrix::~DitherMatrix( )
{
   if( order ) delete order;
}

//..................ordered dither (bilevel)

OrderedDither::OrderedDither( ) : Dither( )
{
   type = ditOrdered;
   cellw = cellh = ncells = 0;
   on_value = off_value = 0;
   rowcnt = rowbytes = 0;
   cells = 0;
}

OrderedDither::OrderedDither( DitherMatrix& dm,
                    int von, int voff ) : Dither( )
{
   type = ditOrdered;
   cellw = dm.width;
   cellh = dm.height;
   ncells = cellw * cellh;
   rowbytes = (cellw + 7) / 8;
   on_value = von;
   off_value = voff;
   rowcnt = 0;
   cells = new unsigned char * [ncells];
   if( cells == 0 ) return;
   int nbytes = rowbytes * cellh;
   for( int i=0; i<ncells; i++ )
   {
      cells[i] = new unsigned char [nbytes];
      if( cells[i] == 0 ) return;
      memset( cells[i], 0, nbytes );
      // fill in cell pattern
      unsigned char *ord = dm.order;
      for( int m=0; m<cellh; m++ )
      {
         unsigned char *row = cells[i] + rowbytes * m;
         unsigned char mask = 0x80;
         for( int n=0; n<cellw; n++ )
         {
            if( *ord++ <= i ) *row |= mask;
            if( (mask >>= 1 ) == 0 )
            {
               mask = 0x80;
               row++;
            }
         }
      }
   }
}

OrderedDither::~OrderedDither( )
{
   if( cells )
   {
      for( int i=0; i<ncells; i++ )
         if( cells[i] ) delete cells[i];
      delete cells;
   }
}

int OrderedDither::dotval( int p, int x, int y )
{
   int ix = x % cellw;
   int iy = y % cellh;
   unsigned char *byte = cells[p] +
                         (iy * rowbytes) +
                         (ix >> 3);
   unsigned char mask = 0x80 >> (ix & 7);
   return (*byte & mask) ? on_value : off_value;
}

void OrderedDither::dither( unsigned char *pxls, int npxls )
{
   for( int i=0; i<npxls; i++ )
   {
      int p = iscale( pxls[i], ncells-1, 255 );
      pxls[i] = dotval( p, i, rowcnt );
   }
   rowcnt++;
}

//..................thresholded dither (bilevel)

ThresholdDither::ThresholdDither( ) : Dither( )
{
   type = ditThresholded;
   threshold = 127;
   on_value  = 1;
   off_value = 0;
}

ThresholdDither::ThresholdDither( int t,
           int von, int voff ) : Dither( )
{
   type = ditThresholded;
   threshold = t;
   on_value  = von;
   off_value = voff;
}

ThresholdDither::~ThresholdDither( )
{
}

void ThresholdDither::dither( unsigned char *pxls, int npxls )
{
   for( int i=0; i<npxls; i++ )
      pxls[i] = pxls[i] > threshold ? on_value : off_value;
}

//..................diffusion dither (bilevel)

DiffusionDither::DiffusionDither( ) : Dither( )
{
   type = ditErrDiffused;
   threshold = 127;
   on_value  = 1;
   off_value = 0;
   err1 = err2 = 0;
   ewidth = 0;
}

DiffusionDither::DiffusionDither( int t, int maxwidth,
           int von, int voff ) : Dither( )
{
   type = ditErrDiffused;
   threshold = t;
   on_value  = von;
   off_value = voff;
   ewidth = maxwidth;
   err1 = new int [ewidth*2];
   if( err1 )
   {
      err2 = err1 + ewidth;
      memset( err1, 0, ewidth*2*sizeof(int) );
   }
   else
   {
      err2 = 0;
      ewidth = 0;
   }
}

DiffusionDither::~DiffusionDither( )
{
   if( err1 ) delete [] err1;
}

void DiffusionDither::dither( unsigned char *pxls, int npxls )
{
   int n = (ewidth < npxls) ? ewidth : npxls;

   // add error from previous call to current scan line
   for( int i=0; i<n; i++ )
   {
      err1[i] = err2[i] + pxls[i];
      err2[i] = 0;
   }

   // threshold each error-corrected pixel value
   pxls[0] = (err1[0] > threshold) ? on_value :
                                     off_value;
   for( i=1; i<n-1; i++ )
   {
      int err = (err1[i] > threshold ) ? err1[i]-255 :
                                         err1[i];
      pxls[i] = (err1[i] > threshold ) ? on_value :
                                         off_value;
      // diffuse error
      err1[i+1] += (err * 7) >> 4;
      err2[i-1] += (err * 3) >> 4;
      err2[i]   += (err * 5) >> 4;
      err2[i+1] += (err * 1) >> 4;
   }
   pxls[n-1] = (err1[n-1] > threshold) ? on_value :
                                         off_value;
}

void DiffusionDither::reset( void )
{
   if( err1 )
      memset( err1, 0, ewidth*2*sizeof(int) );
}

//..................palette for color threshold dither

static rgb threshold_pal[] =
{
   rgb(   0,   0,   0 ),
   rgb(   0,   0, 255 ),
   rgb(   0, 255,   0 ),
   rgb(   0, 255, 255 ),
   rgb( 255,   0,   0 ),
   rgb( 255,   0, 255 ),
   rgb( 255, 255,   0 ),
   rgb( 255, 255, 255 )
};

rgb * ColorThresholdPalette( void )
{
   return threshold_pal;
}

int ColorThresholdSize( void )
{
   return sizeof(threshold_pal) / sizeof(rgb);
}

//..................thresholded dither (color)

ColorThresholdDither::ColorThresholdDither( ) : Dither( )
{
   type = ditClrThresholded;
   threshold = nimgcolors = 0;
   imgcolors = 0;
}

ColorThresholdDither::ColorThresholdDither( int t, rgb *img,
                       int nimg ) : Dither( )
{
   type = ditClrThresholded;
   threshold  = t;
   nimgcolors = nimg;
   imgcolors  = img;
}

ColorThresholdDither::~ColorThresholdDither( )
{
}

void ColorThresholdDither::dither( unsigned char *pxls,
                                   int npxls )
{
   for( int i=0; i<npxls; i++ )
   {
      int j = pxls[i];
      int k = 0;
      k += (imgcolors[j].red > threshold) ? 4 : 0;
      k += (imgcolors[j].grn > threshold) ? 2 : 0;
      k += (imgcolors[j].blu > threshold) ? 1 : 0;
      pxls[i] = k;
   }
}

//..................palette for color diffusion dither

static rgb diffusion_pal[] =
{
   rgb(   0,   0,   0 ),   // 0
   rgb(   0,   0, 255 ),   // 1
   rgb(   0, 255,   0 ),   // 2
   rgb(   0, 255, 255 ),   // 3
   rgb( 255,   0,   0 ),   // 4
   rgb( 255,   0, 255 ),   // 5
   rgb( 255, 255,   0 ),   // 6
   rgb( 255, 255, 255 ),   // 7
   rgb(  85,  85,  85 ),   // 8
   rgb(   0,   0, 127 ),   // 9
   rgb(   0, 127,   0 ),   // 10
   rgb(   0, 127, 127 ),   // 11
   rgb( 127,   0,   0 ),   // 12
   rgb( 127,   0, 127 ),   // 13
   rgb( 127, 127,   0 ),   // 14
   rgb( 170, 170, 170 ),   // 15
   rgb(   0,   0, 170 ),   // 16
   rgb(   0, 170,   0 ),   // 17
   rgb(   0, 170, 170 ),   // 18
   rgb( 170,   0,   0 ),   // 19
   rgb( 170,   0, 170 ),   // 20
   rgb(   0,   0,  85 ),   // 21
   rgb(   0,  85,   0 ),   // 22
   rgb(   0,  85,  85 ),   // 23
   rgb(  85,   0,   0 ),   // 24
   rgb(  85,   0,  85 ),   // 25
   rgb(  85,  85,  85 ),   // 26
};

rgb * ColorDiffusionPalette( void )
{
   return diffusion_pal;
}

int ColorDiffusionSize( int maxcolors )
{
   int n = sizeof(diffusion_pal) / sizeof(rgb);
   return (n < maxcolors) ? n : maxcolors;
}

//..................error diffusion dither (color)

ColorDiffusionDither::ColorDiffusionDither( ) : Dither( )
{
   type = ditClrErrDiffused;
   ndevcolors = nimgcolors = 0;
   devcolors  = imgcolors  = 0;
   rerr1 = rerr2 = 0;
   gerr1 = gerr2 = 0;
   berr1 = berr2 = 0;
   ewidth = 0;
}

ColorDiffusionDither::ColorDiffusionDither( int maxw,
                     rgb *img, int nimg,
                rgb *dev, int ndev ) : Dither( )
{
   type = ditClrErrDiffused;
   ndevcolors = ndev;
   nimgcolors = nimg;
   devcolors  = dev;
   imgcolors  = img;
   ewidth = maxw;
   rerr1 = new int [ewidth*2];
   gerr1 = new int [ewidth*2];
   berr1 = new int [ewidth*2];
   if( (rerr1==0) || (gerr1==0) || (berr1==0) )
   {
      ewidth = 0;
      rerr2 = gerr2 = berr2 = 0;
   }
   else
   {
      memset( rerr1, 0, sizeof(int)*2*ewidth );
      rerr2 = rerr1 + ewidth;
      memset( gerr1, 0, sizeof(int)*2*ewidth );
      gerr2 = gerr1 + ewidth;
      memset( berr1, 0, sizeof(int)*2*ewidth );
      berr2 = berr1 + ewidth;
   }
}

ColorDiffusionDither::~ColorDiffusionDither( )
{
   if( rerr1 ) delete [] rerr1;
   if( gerr1 ) delete [] gerr1;
   if( berr1 ) delete [] berr1;
}

int ColorDiffusionDither::bestdevclr( int r, int g, int b )
{
   long dmin = dist3( r, devcolors[0].red,
                      g, devcolors[0].grn,
                      b, devcolors[0].blu );
   int best = 0;
   for( int i=1; i<ndevcolors; i++ )
   {
      long d = dist3( r, devcolors[i].red,
                      g, devcolors[i].grn,
                      b, devcolors[i].blu );
      if( d < dmin )
      {
         dmin = d;
         best = i;
      }
   }
   return best;
}

void ColorDiffusionDither::reset( void )
{
   if( ewidth > 0 )
   {
      memset( rerr1, 0, sizeof(int)*2*ewidth );
      memset( gerr1, 0, sizeof(int)*2*ewidth );
      memset( berr1, 0, sizeof(int)*2*ewidth );
   }
}

void ColorDiffusionDither::dither( unsigned char *pxls,
                                  int npxls )
{
   int npx = (ewidth < npxls) ? ewidth : npxls;

   // ?err1 contains current primary intensities plus
   // error accumulated from previous line...
   for( int i=0; i<npx; i++ )
   {
      int n = pxls[i];
      rerr1[i] = rerr2[i] + imgcolors[n].red;
      rerr2[i] = 0;
      gerr1[i] = gerr2[i] + imgcolors[n].grn;
      gerr2[i] = 0;
      berr1[i] = berr2[i] + imgcolors[n].blu;
      berr2[i] = 0;
   }

   // traverse current image line and set pixel values
   // for this line from available device palette
   pxls[0] = bestdevclr( rerr1[0], gerr1[0], berr1[0] );
   for( i=1; i<npx-1; i++ )
   {
      int j = bestdevclr( rerr1[i], gerr1[i], berr1[i] );
      pxls[i] = j;

      // compute error in each primary
      int rerr = rerr1[i];  rerr -= devcolors[j].red;
      int gerr = gerr1[i];  gerr -= devcolors[j].grn;
      int berr = berr1[i];  berr -= devcolors[j].blu;

      // diffuse red error
      rerr1[i+1] += (rerr * 7) >> 4;
      rerr2[i-1] += (rerr * 3) >> 4;
      rerr2[i]   += (rerr * 5) >> 4;
      rerr2[i+1] += (rerr * 1) >> 4;

      // diffuse green error
      gerr1[i+1] += (gerr * 7) >> 4;
      gerr2[i-1] += (gerr * 3) >> 4;
      gerr2[i]   += (gerr * 5) >> 4;
      gerr2[i+1] += (gerr * 1) >> 4;

      // diffuse blue error
      berr1[i+1] += (berr * 7) >> 4;
      berr2[i-1] += (berr * 3) >> 4;
      berr2[i]   += (berr * 5) >> 4;
      berr2[i+1] += (berr * 1) >> 4;
   }
   pxls[npx-1] = bestdevclr( rerr1[npx-1],
                             gerr1[npx-1],
                             berr1[npx-1] );
}

void ColorDiffusionDither::rgbdither( unsigned char *pxls,
                                      rgb *clrs, int npxls )
{
   int npx = (ewidth < npxls) ? ewidth : npxls;

   // ?err1 contains current primary intensities plus
   // error accumulated from previous line...
   for( int i=0; i<npx; i++ )
   {
      rerr1[i] = rerr2[i] + clrs[i].red;
      rerr2[i] = 0;
      gerr1[i] = gerr2[i] + clrs[i].grn;
      gerr2[i] = 0;
      berr1[i] = berr2[i] + clrs[i].blu;
      berr2[i] = 0;
   }

   // traverse current image line and set pixel values
   // for this line from available device palette
   pxls[0] = bestdevclr( rerr1[0], gerr1[0], berr1[0] );
   for( i=1; i<npx-1; i++ )
   {
      int j = bestdevclr( rerr1[i], gerr1[i], berr1[i] );
      pxls[i] = j;

      // compute error in each primary
      int rerr = rerr1[i];  rerr -= devcolors[j].red;
      int gerr = gerr1[i];  gerr -= devcolors[j].grn;
      int berr = berr1[i];  berr -= devcolors[j].blu;

      // diffuse red error
      rerr1[i+1] += (rerr * 7) >> 4;
      rerr2[i-1] += (rerr * 3) >> 4;
      rerr2[i]   += (rerr * 5) >> 4;
      rerr2[i+1] += (rerr * 1) >> 4;

      // diffuse green error
      gerr1[i+1] += (gerr * 7) >> 4;
      gerr2[i-1] += (gerr * 3) >> 4;
      gerr2[i]   += (gerr * 5) >> 4;
      gerr2[i+1] += (gerr * 1) >> 4;

      // diffuse blue error
      berr1[i+1] += (berr * 7) >> 4;
      berr2[i-1] += (berr * 3) >> 4;
      berr2[i]   += (berr * 5) >> 4;
      berr2[i+1] += (berr * 1) >> 4;
   }
   pxls[npx-1] = bestdevclr( rerr1[npx-1],
                             gerr1[npx-1],
                             berr1[npx-1] );
}
