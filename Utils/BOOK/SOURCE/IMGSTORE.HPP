//--------------------------------------------------------//
//                                                        //
//   File:    IMAGSTORE.HPP                               //
//                                                        //
//   Desc:    Memory management classes for storing and   //
//            manipulating bitmapped images.              //
//                                                        //
//--------------------------------------------------------//

#ifndef _IMGSTORE_HPP_
#define _IMGSTORE_HPP_

#include "stdio.h"
#include "string.h"
#include "ems.h"
#include "xms.h"

//...............status codes

enum ImgStoreStatus
{
   imgstoreOKAY,
   imgstoreNOMEM,
   imgstoreNODRVR,
   imgstoreNODISK
};

//...............the base class

class ImgStore
{
   public:
      int status;     // okay or failed
      int flags;      // for the app's use

   protected:
      int rowcnt;     // row count
      int colcnt;     // pixels per row
      int pxlbits;    // bits per pixel
      int rowbytes;   // bytes per row

   public:
      ImgStore( int nrows, int ncols, int nbits )
      {
         status = imgstoreOKAY;
         flags = 0;
         rowcnt = nrows;
         colcnt = ncols;
         pxlbits = nbits;
         rowbytes = ((nbits * ncols) + 7) / 8;
      }
      virtual ~ImgStore( )
      {
      }
      virtual void put( unsigned char *data, int row ) = 0;
      virtual unsigned char *get( int row ) = 0;
      virtual void cpy( unsigned char *dest, int row ) = 0;
      virtual void cpy( unsigned char *dest, int row,
                        int col, int cnt ) = 0;
      int width( void )     { return colcnt; }
      int height( void )    { return rowcnt; }
      int depth( void )     { return pxlbits; }
      int scanbytes( void ) { return rowbytes; }
};

//...............conventional memory

class CnvImgStore : public ImgStore
{
   protected:
      unsigned char **rowptrs;

   public:
      CnvImgStore( int nrows, int ncols, int nbits );
      virtual ~CnvImgStore( );
      virtual void put( unsigned char *data, int row );
      virtual unsigned char *get( int row );
      virtual void cpy( unsigned char *dest, int row );
      virtual void cpy( unsigned char *dest, int row,
                        int col, int cnt );
};

//...............EMS memory

class EmsImgStore : public ImgStore
{
   protected:
      int handle;     // EMS handle
      int npages;     // number of alloc'd pages
      int phypage;    // physical page used
      int blkcnt;     // rows per 16K page
      int blklen;     // padded row length
      char *pgframe;  // pointer to physical page

   public:
      EmsImgStore( int nrows, int ncols, int nbits );
      virtual ~EmsImgStore( );
      virtual void put( unsigned char *data, int row );
      virtual unsigned char *get( int row );
      virtual void cpy( unsigned char *dest, int row );
      virtual void cpy( unsigned char *dest, int row,
                        int col, int cnt );
};

//...............XMS memory

class XmsImgStore : public ImgStore
{
   protected:
      unsigned handle;     // xms handle
      int blklen;          // padded row length
      char *buffer;        // cnv mem buffer
      XMSmovestruct c2x;   // for move to xms
      XMSmovestruct x2c;   // for move to cnv

   public:
      XmsImgStore( int nrows, int ncols, int nbits );
      virtual ~XmsImgStore( );
      virtual void put( unsigned char *data, int row );
      virtual unsigned char *get( int row );
      virtual void cpy( unsigned char *dest, int row );
      virtual void cpy( unsigned char *dest, int row,
                        int col, int cnt );
};

//...............Disk memory

class DskImgStore : public ImgStore
{
   protected:
      FILE *fstor;      // file pointer
      int blklen;       // padded row length
      char *buffer;     // cnv mem buffer

   public:
      DskImgStore( int nrows, int ncols, int nbits );
      virtual ~DskImgStore( );
      virtual void put( unsigned char *data, int row );
      virtual unsigned char *get( int row );
      virtual void cpy( unsigned char *dest, int row );
      virtual void cpy( unsigned char *dest, int row,
                        int col, int cnt );
};

#endif
