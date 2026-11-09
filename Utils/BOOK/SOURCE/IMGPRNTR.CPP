//--------------------------------------------------------//
//                                                        //
//   File:    IMGPRNTR.CPP                                //
//                                                        //
//   Desc:    Image printer class                         //
//                                                        //
//--------------------------------------------------------//

#include "stdlib.h"
#include "string.h"
#include "conio.h"

extern "C"
{
   int iscale( int, int, int );
}

#include "imgprntr.hpp"

//..................the printer class

ImagePrinter::ImagePrinter( PrinterDriver *prt,
                            ImgStore *map,
                            rgb *clrs, int nclrs,
                            int ropt, int iopt,
                            int xres, int yres )
{
   prnt    = prt;
   image   = map;
   dit     = 0;
   imd     = 0;
   imgpal  = 0;
   imgcnt  = 0;
   rendopt = ropt;
   intnopt = iopt;
   status  = 0;

   // image descriptor - reflects printed dimensions
   if( xres == 0 ) xres = prt->xres();
   if( yres == 0 ) yres = prt->yres();
   int w = iscale( map->width(), prt->xres(), xres );
   int h = iscale( map->height(), prt->yres(), yres );
   imd = new ImageDescriptor( w, h, map->depth(),
                              xres, yres );
   if( imd == 0 )
   {
      status = 1;
      return;
   }

   // printed image and scan line buffer
   scanwid = imd->width;
   scanhgt = imd->height;
   scanbuf = new unsigned char [scanwid];
   if( scanbuf == 0 )
   {
      status = 1;
      return;
   }

   // allocate and initialize palette
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
      imgcnt = nclrs;
      for( i=0; i<imgcnt; i++ )
         imgpal[i] = clrs[i];

      // apply any intensity mapping
      if( intnopt & intensICNT )
         contrast_alter( imgpal, imgcnt, iMORE );
      if( intnopt & intensDCNT )
         contrast_alter( imgpal, imgcnt, iLESS );
      if( intnopt & intensIBRI )
         brightness_alter( imgpal, imgcnt, iMORE );
      if( intnopt & intensDBRI )
         brightness_alter( imgpal, imgcnt, iLESS );

      // force grayscale?
      if( (ropt & renderGRAY) || (prnt->devcolors() == 2) )
      {
         for( i=0; i<imgcnt; i++ )
         {
            int g = imgpal[i].graylevel();
            imgpal[i] = rgb( g, g, g );
         }
      }
   }

   // nclrs==0, image is 24-bit
   else
   {
      imgpal = new rgb [scanwid];
      if( imgpal == 0 )
      {
         status = 1;
         return;
      }
   }

   // if the image must be approximated...
   if( (prnt->devcolors() < imgcnt) || (imgcnt == 0) )
   {
      dit = new ColorDiffusionDither( scanwid, imgpal, imgcnt,
                                      prnt->devpalette(),
                                      prnt->devcolors() );
      if( dit == 0 )
      {
         status = 1;
         return;
      }
   }
}

ImagePrinter::~ImagePrinter( )
{
   if( scanbuf ) delete [] scanbuf;
   if( imgpal )  delete [] imgpal;
   if( dit )     delete    dit;
   if( imd )     delete    imd;
}

unsigned char * ImagePrinter::getscan( int row )
{
   int irow = iscale( image->height(), row, scanhgt );
   unsigned char *p = image->get( irow );
   for( int j=0; j<scanwid; j++ )
   {
      int jcol = iscale( image->width(), j, scanwid );
      scanbuf[j] = p[jcol];
   }
   return scanbuf;
}

unsigned char * ImagePrinter::getscan_dit( int row )
{
   int irow = iscale( image->height(), row, scanhgt );
   unsigned char *p = image->get( irow );
   for( int j=0; j<scanwid; j++ )
   {
      int jcol = iscale( image->width(), j, scanwid );
      scanbuf[j] = p[jcol];
   }
   dit->dither( scanbuf, scanwid );
   return scanbuf;
}

unsigned char * ImagePrinter::getscan_24( int row )
{
   int irow = iscale( image->height(), row, scanhgt );
   unsigned char *p = image->get( irow );
   for( int j=0; j<scanwid; j++ )
   {
      int jcol = iscale( image->width()*3, j, scanwid );
      imgpal[j] = rgb( p[jcol], p[jcol+1], p[jcol+2] );
   }
   ColorDiffusionDither *d = (ColorDiffusionDither *) dit;
   d->rgbdither( scanbuf, imgpal, scanwid );
   return scanbuf;
}

int ImagePrinter::print( int eject_pg )
{
   if( status != 0 ) return status;

   if( prnt->imgprolog( *imd ) != pOKAY )
      return prnt->status();

   for( int i=0; i<scanhgt; i++ )
   {
      if( prnt->status() != pOKAY )
         return prnt->status();

      unsigned char *p;

      if( imgcnt == 0 )
         p = getscan_24( i );
      else if( dit == 0 )
         p = getscan( i );
      else
         p = getscan_dit( i );

      prnt->putscanline( p, scanwid );
   }

   if( prnt->imgepilog( ) != pOKAY )
      return prnt->status();

   if( eject_pg )
      if( prnt->eject( ) != pOKAY )
         return prnt->status();

   return status;
}
