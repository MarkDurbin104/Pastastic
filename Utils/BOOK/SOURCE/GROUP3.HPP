//--------------------------------------------------------//
//                                                        //
//   File:    GROUP3.HPP                                  //
//                                                        //
//   Desc:    Class definitions for CCITT Group 3         //
//            compressor and decompressor.                //
//                                                        //
//--------------------------------------------------------//

#ifndef _GROUP3_HPP_
#define _GROUP3_HPP_

#include "stdio.h"

#include "codec.hpp"

//..................Group 3 encoder

class Group3Encoder : public Encoder
{
   protected:
      FILE          *outfile;
      unsigned char  codebyte;
      unsigned char  codemask;

   private:
      int  runlength( int pxval, int maxcnt,
                      unsigned char *pxls );
      int  wrtbitcode( int code, int len );
      int  wrtrun( int pxval, int cnt );

   public:
      Group3Encoder( FILE *f_out ) : Encoder( tGROUP3 )
      {
         outfile = f_out;
      }
     ~Group3Encoder( )
      {
      }
      virtual int init( void );
      virtual int term( void );
      virtual int encode( unsigned char *line, int size );
      virtual int status( void );
};

//..................Group 3 decoder

class Group3Decoder : public Decoder
{
   protected:
      FILE          *infile;
      int            cond;
      unsigned char  codebyte;
      unsigned char  codemask;

   private:
      int  rdbit( void );
      int  rdcode( int pxval );

   public:
      Group3Decoder( FILE *f_in ) : Decoder( tGROUP3 )
      {
         infile = f_in;
         cond = xOKAY;
      }
     ~Group3Decoder( )
      {
      }
      virtual int init( void );
      virtual int term( void );
      virtual int decode( unsigned char *line, int size );
      virtual int status( void );
};

#endif
