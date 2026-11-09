//--------------------------------------------------------//
//                                                        //
//   File:    WRTTIF.CPP                                  //
//                                                        //
//   Desc:    Code to output a TIFF file from a           //
//            a VGA Display or a Memory Bitmap            //
//                                                        //
//--------------------------------------------------------//

#include "tif.hpp"
#include "tifcodec.hpp"
#include "display.hpp"
#include "imgstore.hpp"

//..................Tag set for color-mapped images

enum ColorMappedTagSet
{
   cmWidth,
   cmHeight,
   cmBitSamp,
   cmCompress,
   cmPhotoMet,
   cmStripOfs,
   cmStripHgt,
   cmXres,
   cmYres,
   cmResUnit,
   cmColorMap,
};

static IFDENTRY ColorMappedIFD[] =
{
   IFDENTRY( 256, tUShort,    1, 0L ),   // width
   IFDENTRY( 257, tUShort,    1, 0L ),   // height
   IFDENTRY( 258, tUShort,    1, 0L ),   // bits/samp
   IFDENTRY( 259, tUShort,    1, 0L ),   // compression
   IFDENTRY( 262, tUShort,    1, 0L ),   // photomet intrp
   IFDENTRY( 273, tULong,     1, 0L ),   // strip offsets
   IFDENTRY( 278, tUShort,    1, 0L ),   // rows/strip
   IFDENTRY( 282, tURational, 1, 0L ),   // x res
   IFDENTRY( 283, tURational, 1, 0L ),   // y res
   IFDENTRY( 296, tUShort,    1, 0L ),   // res unit
   IFDENTRY( 320, tUShort,    1, 0L ),   // color map
};

int ColorMappedCnt( void )
{
   return sizeof(ColorMappedIFD) / sizeof(IFDENTRY);
}

IFDENTRY * ColorMappedTags( void )
{
   IFDENTRY *cmt = new IFDENTRY [ ColorMappedCnt() ];
   if( cmt )
      for( int i=0; i<ColorMappedCnt(); i++ )
         cmt[i] = ColorMappedIFD[i];
   return cmt;
}

//..................Tag set for RGB images

enum RgbTagSet
{
   rgbWidth,
   rgbHeight,
   rgbBitSamp,
   rgbCompress,
   rgbPhotoMet,
   rgbStripOfs,
   rgbSampPix,
   rgbStripHgt,
   rgbXres,
   rgbYres,
   rgbResUnit,
};

static IFDENTRY RgbIFD[] =
{
   IFDENTRY( 256, tUShort,    1, 0L ),   // width
   IFDENTRY( 257, tUShort,    1, 0L ),   // height
   IFDENTRY( 258, tUShort,    1, 0L ),   // bits/samp
   IFDENTRY( 259, tUShort,    1, 0L ),   // compression
   IFDENTRY( 262, tUShort,    1, 0L ),   // photomet intrp
   IFDENTRY( 273, tULong,     1, 0L ),   // strip offsets
   IFDENTRY( 277, tUShort,    1, 0L ),   // samps/pixel
   IFDENTRY( 278, tUShort,    1, 0L ),   // rows/strip
   IFDENTRY( 282, tURational, 1, 0L ),   // x res
   IFDENTRY( 283, tURational, 1, 0L ),   // y res
   IFDENTRY( 296, tUShort,    1, 0L ),   // res unit
   IFDENTRY( 320, tUShort,    1, 0L ),   // color map
};

int RgbCnt( void )
{
   return sizeof(RgbIFD) / sizeof(IFDENTRY);
}

IFDENTRY * RgbTags( void )
{
   IFDENTRY *rgbt = new IFDENTRY [ RgbCnt() ];
   if( rgbt )
      for( int i=0; i<RgbCnt(); i++ )
         rgbt[i] = RgbIFD[i];
   return rgbt;
}

//..................Write VGA screen to TIFF file 'fn'

int WriteTIF( VgaDisplay& vga, char *fn,
              int x1, int y1, int x2, int y2 )
{
   // image metrics
   int nrows   = y2 - y1 + 1;
   int ncols   = x2 - x1 + 1;
   int nbits   = 8;
   int ncolors = vga.metric.ncolors;

   // scan line buffer for encoder
   unsigned char *scanln = new unsigned char [ncols];
   if( scanln == 0 ) return xNOMEMORY;

   // create and initialize a Tiff Image Definition
   TIFFIMAGEDEF idef;
   idef.imgtype = iColorMapped;
   idef.cmptype = cPackBits;
   idef.width = ncols;
   idef.height = nrows;
   idef.depth = nbits;
   idef.bitsamp = nbits;
   idef.nstrips = 1;
   idef.ncolors = ncolors;
   idef.colors = new rgb [ncolors];
   if( idef.colors == 0 ) return xNOMEMORY;
   vga.getpalette( idef.colors, idef.ncolors );

   // create a TIFF header
   TIFFHEADER thdr;

   // create and initialize the tag set
   IFDENTRY *tags = ColorMappedTags();
   if( tags == 0 ) return xNOMEMORY;
   tags[cmWidth].valofs = idef.width;
   tags[cmHeight].valofs = idef.height;
   tags[cmBitSamp].valofs = idef.bitsamp;
   tags[cmCompress].valofs = idef.cmptype;
   tags[cmPhotoMet].valofs = idef.imgtype;
   tags[cmStripHgt].valofs = idef.height;
   tags[cmXres].valofs = idef.xres;
   tags[cmYres].valofs = idef.yres;
   tags[cmResUnit].valofs = idef.resunit;
   tags[cmColorMap].count = idef.ncolors * 3;

   // open and write the file
   FILE *f = fopen( fn, "wb" );

   // output a placeholder for the header
   if( thdr.put( f ) ) return xIOERROR;

   // output the color map
   tags[cmColorMap].valofs = ftell( f );
   unsigned short pri;
   for( int i=0; i<idef.ncolors; i++ )
   {
      pri = idef.colors[i].red;
      pri <<= 8;
      fwrite( &pri, 2, 1, f );
   }
   for( i=0; i<idef.ncolors; i++ )
   {
      pri = idef.colors[i].grn;
      pri <<= 8;
      fwrite( &pri, 2, 1, f );
   }
   for( i=0; i<idef.ncolors; i++ )
   {
      pri = idef.colors[i].blu;
      pri <<= 8;
      fwrite( &pri, 2, 1, f );
   }

   // output the X/Y resolutions
   tags[cmXres].valofs = ftell( f );
   long ltmp = idef.xres;
   fwrite( &ltmp, 4, 1, f );
   ltmp = 1L;
   fwrite( &ltmp, 4, 1, f );
   tags[cmYres].valofs = ftell( f );
   ltmp = idef.yres;
   fwrite( &ltmp, 4, 1, f );
   ltmp = 1L;
   fwrite( &ltmp, 4, 1, f );

   // output the encoded bitmap
   tags[cmStripOfs].valofs = ftell( f );
   TiffEncoder enc( f, &idef );
   enc.init();
   for( i=0; i<nrows; i++ )
   {
      vga.getscanline( scanln, ncols, x1, y1+i );
      if( enc.encode( scanln, ncols ) != xOKAY )
      {
         delete scanln;
         fclose( f );
         return enc.status();
      }
   }
   enc.term();

   // output the IFD
   thdr.ifdofs = ftell( f );
   short ntags = ColorMappedCnt();
   fwrite( &ntags, 2, 1, f );
   for( i=0; i<ntags; i++ )
      tags[i].put( f );
   ltmp = 0L;
   fwrite( &ltmp, 4, 1, f );

   // rewrite the updated header
   fseek( f, 0L, SEEK_SET );
   thdr.put( f );

   // finished!
   delete scanln;
   int retv = ferror(f) ? xIOERROR : xOKAY;
   fclose( f );
   return retv;
}

//..................Write an image to TIFF file 'fn'

int WriteTIF( ImgStore& img, rgb *pal, char *fn )
{
   // image metrics
   int nrows   = img.height();
   int ncols   = img.width();
   int nbits   = (img.depth() == 24) ? 24 : 8;
   int ncolors = 2;
   if( img.depth() == 24 ) ncolors = 0;
   else if( img.depth() > 1 ) ncolors = 256;

   // create and initialize a Tiff Image Definition
   TIFFIMAGEDEF idef;
   idef.imgtype = (nbits==24) ? iRGB : iColorMapped;
   idef.cmptype = (nbits==24) ? cUncompressed : cPackBits;
   idef.width = ncols;
   idef.height = nrows;
   idef.depth = nbits;
   idef.bitsamp = 8;
   idef.samppix = nbits / 8;
   idef.nstrips = 1;
   idef.ncolors = ncolors;
   if( ncolors > 0 )
   {
      idef.colors = new rgb [ncolors];
      if( idef.colors == 0 ) return xNOMEMORY;
      for( int i=0; i<ncolors; i++ )
         idef.colors[i] = pal[i];
   }

   // create a TIFF header
   TIFFHEADER thdr;

   // create and initialize the tag set
   IFDENTRY *tags;
   if( idef.ncolors > 0 )
   {
      tags = ColorMappedTags();
      if( tags == 0 ) return xNOMEMORY;
      tags[cmWidth].valofs = idef.width;
      tags[cmHeight].valofs = idef.height;
      tags[cmBitSamp].valofs = idef.bitsamp;
      tags[cmCompress].valofs = idef.cmptype;
      tags[cmPhotoMet].valofs = idef.imgtype;
      tags[cmStripHgt].valofs = idef.height;
      tags[cmXres].valofs = idef.xres;
      tags[cmYres].valofs = idef.yres;
      tags[cmResUnit].valofs = idef.resunit;
      tags[cmColorMap].count = idef.ncolors * 3;
   }
   else
   {
      tags = RgbTags();
      if( tags == 0 ) return xNOMEMORY;
      tags[rgbWidth].valofs = idef.width;
      tags[rgbHeight].valofs = idef.height;
      tags[rgbBitSamp].valofs = idef.bitsamp;
      tags[rgbCompress].valofs = idef.cmptype;
      tags[rgbPhotoMet].valofs = idef.imgtype;
      tags[rgbSampPix].valofs = idef.samppix;
      tags[rgbStripHgt].valofs = idef.height;
      tags[rgbXres].valofs = idef.xres;
      tags[rgbYres].valofs = idef.yres;
      tags[rgbResUnit].valofs = idef.resunit;
   }

   // open and write the file
   FILE *f = fopen( fn, "wb" );

   // output a placeholder for the header
   if( thdr.put( f ) ) return xIOERROR;

   // output the color map if present
   if( idef.ncolors > 0 )
   {
      tags[cmColorMap].valofs = ftell( f );
      unsigned short pri;
      for( int i=0; i<idef.ncolors; i++ )
      {
         pri = idef.colors[i].red;
         pri <<= 8;
         fwrite( &pri, 2, 1, f );
      }
      for( i=0; i<idef.ncolors; i++ )
      {
         pri = idef.colors[i].grn;
         pri <<= 8;
         fwrite( &pri, 2, 1, f );
      }
      for( i=0; i<idef.ncolors; i++ )
      {
         pri = idef.colors[i].blu;
         pri <<= 8;
         fwrite( &pri, 2, 1, f );
      }
   }

   // output the X/Y resolutions
   int ir = (idef.ncolors > 0) ? cmXres : rgbXres;
   tags[ir].valofs = ftell( f );
   long ltmp = idef.xres;
   fwrite( &ltmp, 4, 1, f );
   ltmp = 1L;
   fwrite( &ltmp, 4, 1, f );
   ir = (idef.ncolors > 0) ? cmYres : rgbYres;
   tags[ir].valofs = ftell( f );
   ltmp = idef.yres;
   fwrite( &ltmp, 4, 1, f );
   ltmp = 1L;
   fwrite( &ltmp, 4, 1, f );

   // output the encoded bitmap
   ir = (idef.ncolors > 0) ? cmStripOfs : rgbStripOfs;
   tags[ir].valofs = ftell( f );
   TiffEncoder enc( f, &idef );
   enc.init();
   for( int i=0; i<nrows; i++ )
   {
      unsigned char *p = img.get( i );
      if( enc.encode( p, ncols ) != xOKAY )
      {
         fclose( f );
         return enc.status();
      }
   }
   enc.term();

   // output the IFD
   thdr.ifdofs = ftell( f );
   short ntags = (ncolors > 0) ?
                 ColorMappedCnt() : RgbCnt();
   fwrite( &ntags, 2, 1, f );
   for( i=0; i<ntags; i++ )
      tags[i].put( f );
   ltmp = 0L;
   fwrite( &ltmp, 4, 1, f );

   // rewrite the updated header
   fseek( f, 0L, SEEK_SET );
   thdr.put( f );

   // finished!
   int retv = ferror(f) ? xIOERROR : xOKAY;
   fclose( f );
   return retv;
}
