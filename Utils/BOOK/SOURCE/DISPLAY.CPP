//--------------------------------------------------------//
//                                                        //
//   File:    DISPLAY.CPP                                 //
//                                                        //
//   Desc:    A video display class for handling the      //
//            display of bitmapped images on VGA          //
//            compatible hardware                         //
//                                                        //
//--------------------------------------------------------//

#include "display.hpp"

#define NMODES ( sizeof(supported_modes) / \
                 sizeof(ModeMetric) )

//...............a mode metrics table

static ModeMetric supported_modes[] =
{
   ModeMetric( 0x12, 480, 640, 1, 4, 16 ),
   ModeMetric( 0x13, 200, 320, 8, 1, 256 ),
   ModeMetric( 0x2e, 480, 640, 8, 1, 256 ),
   ModeMetric( 0x62, 480, 640, 8, 1, 256 )
};

static ModeMetric null_metric;

//...............select a metric from a mode

static ModeMetric& get_metric( int mode )
{
   for( int i=0; i<NMODES; i++ )
      if( mode == supported_modes[i].mode )
         return supported_modes[i];
   return null_metric;
}

//...............palette setting, 16 and 256 colors

static void set16( rgb * pal, int nclrs )
{
   int nc = (nclrs==0) ? 16 : nclrs;
   for( int i=0; i<nc; i++ )
   {
      rgb c = pal[i] >> 2;
      int r = get_vga_pal_reg( i );
      set_vga_dac_reg( r, c.red, c.grn, c.blu );
   }
}

static void set256( rgb * pal, int nclrs )
{
   int nc = (nclrs==0) ? 256 : nclrs;
   if( nc == 256 )
   {
      unsigned char *buf = new unsigned char [768];
      if( buf == 0 ) return;
      int n = 0;
      for( int m=0; m<256; m++ )
      {
         buf[n++] = pal[m].red >> 2;
         buf[n++] = pal[m].grn >> 2;
         buf[n++] = pal[m].blu >> 2;
      }
      set_vga_dac_256( buf );
      delete buf;
   }
   else for( int i=0; i<nc; i++ )
   {
      rgb c = pal[i] >> 2;
      set_vga_dac_reg( i, c.red, c.grn, c.blu );
   }
}

//...............palette reading, 16 and 256 colors

static void get16( rgb * pal, int nclrs )
{
   int nc = (nclrs==0) ? 16 : nclrs;
   for( int i=0; i<nc; i++ )
   {
      int  r = get_vga_pal_reg( i );
      long c = get_vga_dac_reg( r );
      int blu = int( c & 0x3F );
      c >>= 8;
      int grn = int( c & 0x3F );
      c >>= 8;
      int red = int( c & 0x3F );
      pal[i] = rgb( red, grn, blu ) << 2;
   }
}

static void get256( rgb * pal, int nclrs )
{
   int nc = (nclrs==0) ? 256 : nclrs;
   if( nc == 256 )
   {
      unsigned char *buf = new unsigned char [768];
      if( buf == 0 ) return;
      get_vga_dac_256( buf );
      int n = 0;
      for( int m=0; m<256; m++ )
      {
         pal[m].red = buf[n++] << 2;
         pal[m].grn = buf[n++] << 2;
         pal[m].blu = buf[n++] << 2;
      }
      delete buf;
   }
   else for( int i=0; i<nc; i++ )
   {
      long c = get_vga_dac_reg( i );
      int blu = int( c & 0x3F );
      c >>= 8;
      int grn = int( c & 0x3F );
      c >>= 8;
      int red = int( c & 0x3F );
      pal[i] = rgb( red, grn, blu ) << 2;
   }
}

//...............a mode driver table

static ModeDriver drivers[] =
{
   ModeDriver( 0x12, put_pixels_12, get_pixels_12,
               set16, get16 ),
   ModeDriver( 0x13, put_pixels_13, get_pixels_13,
               set256, get256 ),
   ModeDriver( 0x2e, put_pixels_2e, get_pixels_2e,
               set256, get256 ),
   ModeDriver( 0x62, put_pixels_62, get_pixels_62,
               set256, get256 )
};

static ModeDriver null_driver;

//...............select a driver from a mode

static ModeDriver& get_driver( int mode )
{
   for( int i=0; i<NMODES; i++ )
      if( mode == drivers[i].mode )
         return drivers[i];
   return null_driver;
}

//...............the display class

VgaDisplay::VgaDisplay( int mode ) :
            metric( ), driver( )
{
   pmode = getvideomode();
   metric = get_metric( mode );
   driver = get_driver( mode );
   gmode = metric.mode;
   if( gmode )
      setvideomode( gmode );
}

VgaDisplay::~VgaDisplay( )
{
   if( getvideomode() != pmode )
      setvideomode( pmode );
}
