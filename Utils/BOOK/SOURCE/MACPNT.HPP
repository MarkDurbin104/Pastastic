//--------------------------------------------------------//
//                                                        //
//   File:    MACPNT.HPP                                  //
//                                                        //
//   Desc:    Structures for the MacPaint format          //
//                                                        //
//--------------------------------------------------------//

#ifndef _MACPNT_HPP_
#define _MACPNT_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "color.hpp"
#include "codec.hpp"
#include "revword.h"

#define MACLNWIDTH 72

//..................MacBinary telecommunications header

struct MACBINHDR
{
   unsigned char   version;
   unsigned char   namelen;
   char            macname[63];
   char            filetype[4];
   char            fileownr[4];
   char            fflags1;
   char            resv1;
   unsigned short  xposn;
   unsigned short  yposn;
   unsigned short  id;
   char            prot;
   char            resv2;
   unsigned long   rforklen;
   unsigned long   dforklen;
   unsigned long   credate;
   unsigned long   moddate;
   char            resv3[2];
   char            fflags2;
   char            resv4[14];
   unsigned long   unpcklen;
   char            resv5[2];
   unsigned char   macbver1;
   unsigned char   macbver2;
   unsigned short  crc;
   char            resv6[2];

   MACBINHDR( )
   {
      memset( &version, 0, sizeof(MACBINHDR) );
   }

   MACBINHDR( char *fn )
   {
      memset( &version, 0, sizeof(MACBINHDR) );
      strcpy( macname, fn );
      namelen = strlen( fn );
      filetype[0] = 'P';   // "PNTG"
      filetype[1] = 'N';
      filetype[2] = 'T';
      filetype[3] = 'G';
      fileownr[0] = 'M';   // "MPNT"
      fileownr[1] = 'P';
      fileownr[2] = 'N';
      fileownr[3] = 'T';
   }
  ~MACBINHDR( )
   {
   }
   int  get( FILE *f );
   int  put( FILE *f );
};

//..................MacPaint file header

struct MACPNTHDR
{
   unsigned long  version;
   unsigned char  patterns[304];
   unsigned char  resv[204];

   MACPNTHDR( )
   {
      memset( &version, 0, sizeof(MACPNTHDR) );
   }
  ~MACPNTHDR( )
   {
   }
   int  get( FILE *f );
   int  put( FILE *f );
};

//..................class MacPntDecoder

class MacPntDecoder : public Decoder
{
   protected:
      FILE         *MacFile;     // input file
      int           MacCond;     // condition code
      int           MacFg;       // fg color
      int           MacBg;       // bg color
      unsigned char MacBuf[72];  // scan line buffer

   private:
      int readln( void );
      void unpack( unsigned char *buf, int npxls );

   public:
      MacPntDecoder( FILE *f_in, int fg=0, int bg=15 )
      {
         MacFile = f_in;
         MacCond = xOKAY;
         MacFg   = fg;
         MacBg   = bg;
      }
      virtual ~MacPntDecoder( )
      {
      }
      virtual int decode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

//..................class MacPntEncoder

class MacPntEncoder : public Encoder
{
   protected:
      FILE         *MacFile;     // input file
      int           MacCond;     // condition code
      int           MacFg;       // fg color
      int           MacBg;       // bg color
      int           MacLnCnt;    // scan lines written
      unsigned char MacBuf[72];  // scan line buffer

   private:
      int  writeln( void );
      void pack( unsigned char *buf, int npxls );

   public:
      MacPntEncoder( FILE *f_out, int fg=0, int bg=15 )
      {
         MacFile = f_out;
         MacCond = xOKAY;
      }
      virtual ~MacPntEncoder( )
      {
      }
      virtual int encode( unsigned char *buf, int npxls );
      virtual int init( void );
      virtual int term( void );
      virtual int status( void );
};

#endif
