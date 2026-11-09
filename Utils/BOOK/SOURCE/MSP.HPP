//--------------------------------------------------------//
//                                                        //
//   File:    MSP.HPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Microsoft Paint MSP format                  //
//                                                        //
//--------------------------------------------------------//

#ifndef _MSP_HPP_
#define _MSP_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"

//.............format keys

#define V1KEY1 0x6144
#define V1KEY2 0x4D6E
#define V2KEY1 0x694C
#define V2KEY2 0x536E

//.............struct MSPHEADER

struct MSPHEADER
{
   unsigned short key1;
   unsigned short key2;
   unsigned short width;
   unsigned short height;
   unsigned short saspx;
   unsigned short saspy;
   unsigned short paspx;
   unsigned short paspy;
   unsigned short pdx;
   unsigned short pdy;
   unsigned short acx;
   unsigned short acy;
   unsigned short cksum;
   unsigned short resv1;
   unsigned short resv2;
   unsigned short resv3;

   void list( void );
};

//.............class MspDecoder

class MspDecoder : public Decoder
{
   protected:
      FILE           *msp_file;
      int             version;
      int             lncnt;
      int             curln;
      int             rwbytes;
      unsigned short *lnlen;

   private:
      void read_v1( unsigned char *buf, int npxls );
      void read_v2( unsigned char *buf, int npxls );

   public:
      MspDecoder( FILE *f_in, MSPHEADER& msp );
      virtual ~MspDecoder( ) { }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
