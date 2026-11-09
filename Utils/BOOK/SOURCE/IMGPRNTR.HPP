//--------------------------------------------------------//
//                                                        //
//   File:    IMGPRNTR.HPP                                //
//                                                        //
//   Desc:    Image printer class                         //
//                                                        //
//--------------------------------------------------------//

#ifndef _IMGPRNTR_HPP_
#define _IMGPRNTR_HPP_

#include "color.hpp"
#include "colormap.hpp"
#include "intenmap.hpp"
#include "dither.hpp"
#include "printer.hpp"
#include "imgstore.hpp"

#ifndef _IMAGE_OPTIONS_
#define _IMAGE_OPTIONS_

//..................option values

#define  renderNONE    0x0000   // none specified
#define  renderMAP     0x0001   // palette mapping
#define  renderDITHER  0x0002   // dithering
#define  renderGRAY    0x0004   // force gray scale

#define  intensNONE    0x0000   // as-is
#define  intensICNT    0x0001   // increased contrast
#define  intensDCNT    0x0002   // decreased contrast
#define  intensIBRI    0x0004   // increased brightness
#define  intensDBRI    0x0008   // decreased brightness

#endif

//..................the image printer class

class ImagePrinter
{
   protected :
      // various stuff
      PrinterDriver   *prnt;
      ImgStore        *image;
      Dither          *dit;
      ImageDescriptor *imd;
      // image and display palettes
      rgb             *imgpal;
      int              imgcnt;
      // printed image dimensions
      int              scanwid;
      int              scanhgt;
      unsigned char   *scanbuf;
      // options and flags
      int              rendopt;
      int              intnopt;
      int              status;

   private :
      unsigned char * getscan( int row );
      unsigned char * getscan_24( int row );
      unsigned char * getscan_dit( int row );

   public :
      ImagePrinter( PrinterDriver *prt, ImgStore *map,
                    rgb *clrs, int nclrs,
                    int ropt, int iopt,
                    int xres=0, int yres=0 );
     ~ImagePrinter( );
      int print( int eject_pg );
};

#endif
