//--------------------------------------------------------//
//                                                        //
//   File:    IMGVIEWR.CPP                                //
//                                                        //
//   Desc:    Image viewer class                          //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "string.h"
#include "conio.h"

#include "imgviewr.hpp"

//..................keyboard interface stuff

enum ViewerCommands
{
   cmdError,
   cmdEscape,
   cmdEnter,
   cmdPanHalf,
   cmdPanFull,
   cmdHome,
   cmdEnd,
};

static int keys[] =
{
   0x1B, 0x0D,                  // esc, enter
   0x47, 0x4F,                  // home, end
   0x34, 0x4B, 0x36, 0x4D,      // left/right arrow
   0x38, 0x48, 0x32, 0x50,      // up/down arrow
   0x39, 0x49, 0x33, 0x51       // up/down page
};

static int keycmds[] =
{
   cmdEscape,  cmdEnter,
   cmdHome,    cmdEnd,
   cmdPanHalf, cmdPanFull, cmdPanHalf, cmdPanFull,
   cmdPanHalf, cmdPanFull, cmdPanHalf, cmdPanFull,
   cmdPanHalf, cmdPanFull, cmdPanHalf, cmdPanFull
};

static int keydxs[] =
{
    0,  0,
   -1,  1,
   -1, -2,  1,  2,
    0,  0,  0,  0,
    0,  0,  0,  0
};

static int keydys[] =
{
    0,  0,
   -1,  1,
    0,  0,  0,  0,
   -1, -2,  1,  2,
   -1, -2,  1,  2
};

static int nkeys = sizeof(keys) / sizeof(int);

static int getkey( int& dx, int& dy )
{
   while( 1 )
   {
      int k = getch();
      if( k == 0 ) k = getch();

      for( int i=0; i<nkeys; i++ )
         if( k == keys[i] )
         {
            dx = keydxs[i];
            dy = keydys[i];
            return keycmds[i];
         }
   }
}

//..................the viewer class

ImageViewer::ImageViewer( VgaDisplay *vga, ImgStore *map,
                          rgb *clrs, int nclrs,
                          int ropt, int iopt )
{
   disp    = vga;
   image   = map;
   dit     = 0;
   imgpal  = 0;
   imgcnt  = 0;
   devpal  = 0;
   devcnt  = 0;
   clrmap  = 0;
   rendopt = ropt;
   intnopt = iopt;
   status  = 0;
   panning = 0;

   // scan line buffer
   scanwid = disp->metric.ncolumns;
   scanhgt = disp->metric.nrows;
   scanbuf = new unsigned char [scanwid];
   if( scanbuf == 0 )
   {
      status = 1;
      return;
   }

   // allocate and initialize palettes
   // if image is palette based
   int i;
   if( nclrs > 0 )
   {
      imgpal = new rgb [nclrs];
      if( imgpal == 0 )
      {
         status = 1;
         return;
      }
      devpal = new rgb [nclrs];
      if( devpal == 0 )
      {
         status = 1;
         return;
      }
      clrmap = new int [nclrs];
      if( clrmap == 0 )
      {
         status = 1;
         return;
      }
      imgcnt = nclrs;
      for( i=0; i<imgcnt; i++ )
      {
         imgpal[i] = clrs[i];
         clrmap[i] = i;
      }

      // apply any requested palette modifications
      alter_palette( imgpal, imgcnt );

      // initialize device palette to image palette
      devcnt = imgcnt;
      for( i=0; i<imgcnt; i++ )
         devpal[i] = imgpal[i];
   }

   // nclrs == 0 implies a 24-bit color image,
   // which has no palette
   else
   {
      devcnt = ColorDiffusionSize(disp->metric.ncolors);
      devpal = new rgb [devcnt];
      if( devpal == 0 )
      {
         status = 1;
         return;
      }
      imgpal = new rgb [scanwid];
      if( imgpal == 0 )
      {
         status = 1;
         return;
      }
   }

   // if the image must be approximated...
   if( (disp->metric.ncolors < imgcnt) || (imgcnt == 0) )
   {
      if( (ropt & renderDITHER) || (imgcnt == 0) )
      {
         dit = new ColorDiffusionDither( scanwid,
                      imgpal, imgcnt,
                      ColorDiffusionPalette(),
                      ColorDiffusionSize(disp->metric.ncolors) );
         if( dit == 0 )
         {
            status = 1;
            return;
         }
         devcnt = ColorDiffusionSize(disp->metric.ncolors);
         for( i=0; i<devcnt; i++ )
            devpal[i] = ColorDiffusionPalette()[i];
      }
      else
      {
         devcnt = disp->metric.ncolors;
         reduce_palette( devpal, imgcnt, devcnt );
         color_map( imgpal, imgcnt, devpal, devcnt,
                    clrmap, 2 );
      }
   }

   // set the device palette
   disp->putpalette( devpal, devcnt );

   // panning necessary?
   if( (image->width() > scanwid) ||
       (image->height() > scanhgt) )
      panning = 1;
}

ImageViewer::~ImageViewer( )
{
   if( scanbuf ) delete [] scanbuf;
   if( imgpal )  delete [] imgpal;
   if( devpal )  delete [] devpal;
   if( clrmap )  delete [] clrmap;
   if( dit )     delete    dit;
}

void ImageViewer::alter_palette( rgb *pal, int npal )
{
   // apply any intensity mapping
   if( intnopt & intensICNT )
      contrast_alter( pal, npal, iMORE );
   if( intnopt & intensDCNT )
      contrast_alter( pal, npal, iLESS );
   if( intnopt & intensIBRI )
      brightness_alter( pal, npal, iMORE );
   if( intnopt & intensDBRI )
      brightness_alter( pal, npal, iLESS );

   // force grayscale?
   if( (rendopt & renderGRAY) || (disp->metric.ncolors == 2) )
   {
      for( int i=0; i<npal; i++ )
      {
         int g = pal[i].graylevel();
         pal[i] = rgb( g, g, g );
      }
   }
}

void ImageViewer::go_home( ImCoord& ic )
{
   if( image->width() > scanwid )
   {
      ic.xo = 0;
      ic.x1 = 0;
      ic.x2 = scanwid - 1;
   }
   else
   {
      ic.xo = (scanwid - image->width()) / 2;
      ic.x1 = 0;
      ic.x2 = image->width() - 1;
   }

   if( image->height() > scanhgt )
   {
      ic.yo = 0;
      ic.y1 = 0;
      ic.y2 = scanhgt - 1;
   }
   else
   {
      ic.yo = (scanhgt - image->height()) / 2;
      ic.y1 = 0;
      ic.y2 = image->height() - 1;
   }
}

void ImageViewer::go_end( ImCoord& ic )
{
   if( image->width() > scanwid )
   {
      ic.xo = 0;
      ic.x2 = image->width() - 1;
      ic.x1 = ic.x2 - scanwid + 1;
   }
   else
   {
      ic.xo = (scanwid - image->width()) / 2;
      ic.x1 = 0;
      ic.x2 = image->width() - 1;
   }

   if( image->height() > scanhgt )
   {
      ic.yo = 0;
      ic.y2 = image->height() - 1;
      ic.y1 = ic.y2 - scanhgt + 1;
   }
   else
   {
      ic.yo = (scanhgt - image->height()) / 2;
      ic.y1 = 0;
      ic.y2 = image->height() - 1;
   }
}

void ImageViewer::mv_horz( ImCoord& ic, int dx )
{
   int ds = scanwid - ic.xo - 1;
   if( (dx > 0) && (ic.x2 < image->width()-1) )
   {
      ic.x1 += dx;
      if( ic.x1 > ic.x2 )
          ic.x1 = ic.x2;
      ic.x2 = ic.x1 + ds;
      if( ic.x2 >= image->width() )
          ic.x2 = image->width() - 1;
   }
   else if( (dx < 0) && (ic.x1 > 0) )
   {
      ic.x1 += dx;
      if( ic.x1 < 0 )
          ic.x1 = 0;
      ic.x2 = ic.x1 + ds;
      if( ic.x2 >= image->width() )
          ic.x2 = image->width() - 1;
   }
}

void ImageViewer::mv_vert( ImCoord& ic, int dy )
{
   int ds = scanhgt - ic.yo - 1;
   if( (dy > 0) && (ic.y2 < image->height()-1) )
   {
      ic.y1 += dy;
      if( ic.y1 > ic.y2 )
          ic.y1 = ic.y2;
      ic.y2 = ic.y1 + ds;
      if( ic.y2 >= image->height() )
          ic.y2 = image->height() - 1;
   }
   else if( (dy < 0) && (ic.y1 > 0) )
   {
      ic.y1 += dy;
      if( ic.y1 < 0 )
          ic.y1 = 0;
      ic.y2 = ic.y1 + ds;
      if( ic.y2 >= image->height() )
          ic.y2 = image->height() - 1;
   }
}

void ImageViewer::erase( void )
{
   memset( scanbuf, 0, scanwid );
   for( int i=0; i<scanhgt; i++ )
      disp->putscanline( scanbuf, scanwid, 0, i );
}

void ImageViewer::draw( ImCoord& ic )
{
   int            n = ic.x2 - ic.x1 + 1;
   int            y = ic.yo;
   unsigned char *p = scanbuf;

   for( int i=ic.y1; i<=ic.y2; i++ )
   {
      if( dit )
      {
         if( imgcnt > 0 )
         {
            image->cpy( scanbuf, i, ic.x1, n );
            dit->dither( scanbuf, n );
         }
         else // 24-bit image
         {
            unsigned char *s;
            s = image->get( i ) + ic.x1*3;
            for( int j=0; j<n; j++ )
               imgpal[j] = rgb( *s++, *s++, *s++ );
            alter_palette( imgpal, n );
            ColorDiffusionDither *d =
            (ColorDiffusionDither *) dit;
            d->rgbdither( scanbuf, imgpal, n );
         }
      }
      else if( imgcnt > devcnt )
      {
         image->cpy( scanbuf, i, ic.x1, n );
         for( int j=0; j<n; j++ )
            scanbuf[j] = clrmap[scanbuf[j]];
      }
      else
      {
         p = image->get( i ) + ic.x1;
      }
      disp->putscanline( p, n, ic.xo, y++ );
   }
}

int ImageViewer::view( void )
{
   if( status != 0 ) return status;

   ImCoord ic;      // image/screen coords
   int     dx, dy;  // panning deltas

   erase();
   go_home( ic );
   draw( ic );

   while( status == 0 )
   {
      int k = getkey( dx, dy );

      if( (k==cmdEscape) || (k==cmdEnter) )
         status = k;

      else if( panning )
      {
         dx *= scanwid;  dx /= 2;
         dy *= scanhgt;  dy /= 2;

         // home
         if( (dx < 0) && (dy < 0) )
         {
            go_home( ic );
            erase();
            draw( ic );
         }

         // end
         else if( (dx > 0) && (dy > 0) )
         {
            go_end( ic );
            erase();
            draw( ic );
         }

         // pan left/right
         else if( ((dx > 0) && (ic.x2 < image->width()-1)) ||
                  ((dx < 0) && (ic.x1 > 0)) )
         {
            mv_horz( ic, dx );
            erase();
            draw( ic );
         }

         // pan left/right
         else if( ((dy > 0) && (ic.y2 < image->height()-1)) ||
                  ((dy < 0) && (ic.y1 > 0)) )
         {
            mv_vert( ic, dy );
            erase();
            draw( ic );
         }

         // anything else
         else
         {
            // printf( "\x07" );
         }
      }
   }

   return status;
}
