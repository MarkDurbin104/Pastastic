//--------------------------------------------------------//
//                                                        //
//   File:    IMAGSTORE.CPP                               //
//                                                        //
//   Desc:    Memory management classes for storing and   //
//            manipulating bitmapped images.              //
//                                                        //
//--------------------------------------------------------//

#include "imgstore.hpp"

//................Conventional Memory

CnvImgStore::CnvImgStore( int nrows, int ncols, int nbits ) :
             ImgStore( nrows, ncols, nbits )
{
   int nerrors = 1;
   rowptrs = new unsigned char * [rowcnt];
   if( rowptrs )
   {
      nerrors--;
      for( int i=0; i<rowcnt; i++ )
      {
         rowptrs[i] = new unsigned char [rowbytes];
         if( rowptrs[i] )
            memset( rowptrs[i], 0, rowbytes );
         else
            nerrors++;
      }
   }
   if( nerrors > 0 ) status = imgstoreNOMEM;
}

CnvImgStore::~CnvImgStore( )
{
   if( rowptrs )
   {
      for( int i=0; i<rowcnt; i++ )
      {
         if( rowptrs[i] ) delete rowptrs[i];
      }
      delete rowptrs;
   }
}

void CnvImgStore::put( unsigned char *data, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( rowptrs[row], data, rowbytes );
}

unsigned char * CnvImgStore::get( int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         return rowptrs[row];
   return 0;
}

void CnvImgStore::cpy( unsigned char *dest, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, rowptrs[row], rowbytes );
}

void CnvImgStore::cpy( unsigned char *dest, int row,
                       int col, int cnt )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, rowptrs[row]+col, cnt );
}

//................EMS Memory

EmsImgStore::EmsImgStore( int nrows, int ncols, int nbits ) :
             ImgStore( nrows, ncols, nbits )
{
   if( EMS_installed() )
   {
      // we use only 1 of the 4 physical pages
      // in the page frame buffer.  phypage
      // is set to desired page (0-3).
      phypage = 0;
      pgframe = EMS_pgframeaddr( phypage );

      // blklen is rowlen padded to multiple of 4.
      // blkcnt is number of padded rows that
      // fit in a 16K page.
      int n  = (rowbytes + 3) / 4;
      blklen = n * 4;
      blkcnt = 16384 / blklen;

      npages = (rowcnt + blkcnt - 1) / blkcnt;
      handle = EMS_alloc( npages );
      if( handle != -1 )
      {
         for( int i=0; i<npages; i++ )
         {
            EMS_mappage( handle, i, phypage );
            memset( pgframe, 0, 16384 );
         }
      }
      else
         status = imgstoreNOMEM;
   }
   else
      status = imgstoreNODRVR;
}

EmsImgStore::~EmsImgStore( )
{
   if( status == imgstoreOKAY )
      EMS_free( handle );
}

void EmsImgStore::put( unsigned char *data, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         int page = row / blkcnt;
         EMS_mappage( handle, page, phypage );
         int ofs  = (row % blkcnt) * blklen;
         memcpy( pgframe+ofs, data, rowbytes );
      }
}

unsigned char * EmsImgStore::get( int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         int page = row / blkcnt;
         EMS_mappage( handle, page, phypage );
         int ofs  = (row % blkcnt) * blklen;
         return (unsigned char *) pgframe+ofs;
      }
   return 0;
}

void EmsImgStore::cpy( unsigned char *dest, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row), rowbytes );
}

void EmsImgStore::cpy( unsigned char *dest, int row,
                       int col, int cnt )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row)+col, cnt );
}

//................XMS Memory

XmsImgStore::XmsImgStore( int nrows, int ncols, int nbits ) :
             ImgStore( nrows, ncols, nbits )
{
   if( XMS_installed() )
   {
      // blklen is rowlen padded to multiple of 4.
      int n  = (rowbytes + 3) / 4;
      blklen = n * 4;

      // allocate a cnv mem row buffer
      buffer = new char [blklen];
      if( buffer )
      {
         memset( buffer, 0, blklen );

         // total xms bytes required
         long nbytes = blklen; nbytes *= rowcnt;

         // convert to KB
         nbytes += 1023;
         nbytes /= 1024;
         n = (int) nbytes;

         // and attempt to allocate
         handle = XMS_alloc( n );
         if( handle != 0 )
         {
            // set up move structs
            c2x.nbytes = blklen;
            c2x.srchandle = 0;
            c2x.srcoffset = (long) buffer;
            c2x.dsthandle = handle;
            c2x.dstoffset = 0;

            x2c.nbytes = blklen;
            x2c.srchandle = handle;
            x2c.srcoffset = 0;
            x2c.dsthandle = 0;
            x2c.dstoffset = (long) buffer;

            // zero the image
            for( int i=0; i<rowcnt; i++ )
            {
               XMS_move( &c2x );
               c2x.dstoffset += blklen;
            }
         }
         else
         {
            status = imgstoreNOMEM;
            delete buffer;
         }
      }
      else
         status = imgstoreNOMEM;
   }
   else
      status = imgstoreNODRVR;
}

XmsImgStore::~XmsImgStore( )
{
   if( status == imgstoreOKAY )
   {
      delete buffer;
      XMS_free( handle );
   }
}

void XmsImgStore::put( unsigned char *data, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         c2x.srcoffset = (long) data;
         c2x.dstoffset = long( blklen ) * row;
         XMS_move( &c2x );
      }
}

unsigned char * XmsImgStore::get( int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         x2c.srcoffset = long( blklen ) * row;
         XMS_move( &x2c );
         return (unsigned char *) buffer;
      }
   return 0;
}

void XmsImgStore::cpy( unsigned char *dest, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row), rowbytes );
}

void XmsImgStore::cpy( unsigned char *dest, int row,
                       int col, int cnt )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row)+col, cnt );
}

//................Disk Memory

DskImgStore::DskImgStore( int nrows, int ncols, int nbits ) :
             ImgStore( nrows, ncols, nbits )
{
   // blklen is rowlen padded to multiple of 4.
   int n  = (rowbytes + 3) / 4;
   blklen = n * 4;

   // allocate a cnv mem row buffer
   buffer = new char [blklen];
   if( buffer )
   {
      memset( buffer, 0, blklen );

      // initialize the disk file
      fstor = fopen( "IMGSTORE.MEM", "w+b" );
      if( fstor )
      {
         for( int i=0; i<nrows; i++ )
         {
            fwrite( buffer, blklen, 1, fstor );
            if( ferror(fstor) )
            {
               fclose( fstor );
               delete buffer;
               status = imgstoreNODISK;
               break;
            }
         }
      }
      else
      {
         delete buffer;
         status = imgstoreNODISK;
      }
   }
   else
      status = imgstoreNOMEM;
}

DskImgStore::~DskImgStore( )
{
   if( status == imgstoreOKAY )
   {
      delete buffer;
      fclose( fstor );
   }
}

void DskImgStore::put( unsigned char *data, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         long offset = blklen;
         offset *= row;
         fseek( fstor, offset, SEEK_SET );
         fwrite( (char *) data, blklen, 1, fstor );
      }
}

unsigned char * DskImgStore::get( int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
      {
         long offset = blklen;
         offset *= row;
         fseek( fstor, offset, SEEK_SET );
         fread( buffer, blklen, 1, fstor );
         return (unsigned char *) buffer;
      }
   return 0;
}

void DskImgStore::cpy( unsigned char *dest, int row )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row), rowbytes );
}

void DskImgStore::cpy( unsigned char *dest, int row,
                       int col, int cnt )
{
   if( status == imgstoreOKAY )
      if( (row >= 0) && (row < rowcnt) )
         memcpy( dest, get(row)+col, cnt );
}
