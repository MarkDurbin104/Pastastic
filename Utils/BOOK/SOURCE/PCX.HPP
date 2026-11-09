//--------------------------------------------------------//
//                                                        //
//   File:    PCX.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            PC Paintbrush PCX format                    //
//                                                        //
//--------------------------------------------------------//

#ifndef _PCX_HPP_
#define _PCX_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"
#include "revbyte.hpp"

//.............struct PCXHEADER

struct PCXHEADER
{
      char           format;      // Always 10 for PCX
      char           version;     // Version info
      char           rleflag;     // Set to 1
      char           bitpx;       // Bits per pixel
      unsigned short x1;          // Image bounds in pixels
      unsigned short y1;          //     "
      unsigned short x2;          //     "
      unsigned short y2;          //     "
      unsigned short hres;        // Image resolution in dpi
      unsigned short vres;        //     "
      unsigned char  colors[48];  // Palette
      char           vmode;       // (ignored)
      char           nplanes;     // Plane count (v2.5=0)
      unsigned short bplin;       // Bytes per line
      unsigned short paltype;     // 1 for color, 2 for gray
      unsigned short scrnw;       // Screen size in pixels
      unsigned short scrnh;       //     "
      char           xtra[54];    // Extra space (filler)

      PCXHEADER( );
     ~PCXHEADER( ) { }
      void list( void );
};

//.............struct PCXPALETTE

struct PCXPALETTE
{
   int nopal;
   int ncolors;
   rgb *colors;
   PCXPALETTE( FILE *f, PCXHEADER& h );
   PCXPALETTE( )
   {
      nopal = 0;
      ncolors = 0;
      colors = 0;
   }
   ~PCXPALETTE( )
   {
      if( colors )
         delete colors;
   }
};

//.............class PcxDecoder

class PcxDecoder : public Decoder
{
   protected:
      int   cond;         // condition code
      int   pxl_bits;     // bits per pixel
      int   pxl_planes;   // planes per pixel
      int   row_bytes;    // bytes per plane
      FILE *pcx_file;     // output file

   private:
      int   hdr_byte;     // decode variables
      int   cnt_byte;
      int   dat_byte;
      int   shift_msk;
      int   shift_cnt;
      void  read_124( unsigned char *buf, int npxls );
      void  read_8( unsigned char *buf, int npxls );

   public:
      PcxDecoder( FILE *f_in, PCXHEADER& pcx );
      virtual ~PcxDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//.............class PcxEncoder

class PcxEncoder : public Encoder
{
   protected:
      int   cond;          // condition code
      int   pxl_bits;      // bits per pixel
      int   pxl_planes;    // planes per pixel
      int   row_bytes;     // bytes per plane
      FILE *pcx_file;      // output file

   private:
      char *scanbuffer;    // output buffer
      int   scanmask;      // output bit mask
      int   scanbyte;      // output byte pointer
      void  initbuffer( void );
      void  putbits( int bits, int nbits );
      void  putbyte( int byte );
      int   flush( void );
      void  write_124( unsigned char *buf, int npxls );
      void  write_8( unsigned char *buf, int npxls );

   public:
      PcxEncoder( FILE *f_out, PCXHEADER& pcx );
      virtual ~PcxEncoder( )
      {
         if( scanbuffer )
            delete scanbuffer;
      }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
