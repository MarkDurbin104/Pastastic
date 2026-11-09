//--------------------------------------------------------//
//                                                        //
//   File:    MSP.CPP                                     //
//                                                        //
//   Desc:    Class and structure definitions for the     //
//            Microsoft Paint MSP format                  //
//                                                        //
//--------------------------------------------------------//

#include "msp.hpp"

//.............struct MSPHEADER

void MSPHEADER::list( void )
{
   printf( "MSPHEADER::key1   = %04Xh\n", key1 );
   printf( "MSPHEADER::key2   = %04Xh\n", key2 );
   printf( "MSPHEADER::width  = %d\n", width );
   printf( "MSPHEADER::height = %d\n", height );
   printf( "MSPHEADER::saspx  = %d\n", saspx  );
   printf( "MSPHEADER::saspy  = %d\n", saspy  );
   printf( "MSPHEADER::paspx  = %d\n", paspx  );
   printf( "MSPHEADER::paspy  = %d\n", paspy  );
   printf( "MSPHEADER::pdx    = %d\n", pdx    );
   printf( "MSPHEADER::pdy    = %d\n", pdy    );
   printf( "MSPHEADER::acx    = %d\n", acx    );
   printf( "MSPHEADER::acy    = %d\n", acy    );
   printf( "MSPHEADER::cksum  = %d\n", cksum  );
   printf( "MSPHEADER::resv1  = %d\n", resv1  );
   printf( "MSPHEADER::resv2  = %d\n", resv2  );
   printf( "MSPHEADER::resv3  = %d\n", resv3  );
}

//.............class MspDecoder

MspDecoder::MspDecoder( FILE *f_in, MSPHEADER& msp )
{
   msp_file = f_in;
   rwbytes = ((msp.width + 15) / 16) * 2;
   lncnt = msp.height;
   curln = 0;
   lnlen = 0;
   version = 0;
   if( (msp.key1==V1KEY1) && (msp.key2==V1KEY2) )
      version = 1;
   if( (msp.key1==V2KEY1) && (msp.key2==V2KEY2) )
   {
      version = 2;
      lnlen = new unsigned short [lncnt];
      if( lnlen )
         fread( lnlen, 2, lncnt, msp_file );
   }
   // for either format, at this point the
   // file pointer is positioned at the start
   // of the bitmap.
}

int MspDecoder::status( void )
{
   if( (version == 2) && (lnlen == 0) )
      return xNOMEMORY;
   if( version == 0 )
      return xBADPARAM;
   if( feof(msp_file) )
      return xENDOFIMAGE;
   if( ferror(msp_file) )
      return xIOERROR;
   return xOKAY;
}

int MspDecoder::init( void )
{
   curln = 0;
   return status();
}

int MspDecoder::term( void )
{
   return status();
}

void MspDecoder::read_v1( unsigned char *buf, int npxls )
{
   int bytecnt = 0;
   int n = 0;
   while( (bytecnt < rwbytes) && (status() == xOKAY) )
   {
      bytecnt++;
      int b = fgetc( msp_file );
      int mask = 0x100;
      while( (mask >>= 1) != 0 )
         if( n < npxls )
            buf[n++] = (b & mask) ? 1 : 0;
   }
}

void MspDecoder::read_v2( unsigned char *buf, int npxls )
{
   // missing pixels are assumed to be white!
   memset( buf, 1, npxls );
   // decode the scan line
   int bytecnt = 0;
   int pixelcnt = 0;
   int scancnt = lnlen[curln++];
   while( (bytecnt < scancnt) && (status() == xOKAY) )
   {
      int hdr, cnt, dat;
      hdr = fgetc(msp_file);
      if( hdr == 0 )  // repeating run
      {
         cnt = fgetc(msp_file);
         dat = fgetc(msp_file);
         bytecnt += 3;
      }
      else            // unencoded sequence
      {
         cnt = hdr;
         bytecnt += cnt + 1;
      }
      while( cnt-- )
      {
         if( hdr ) dat = fgetc( msp_file );
         int mask = 0x100;
         while( (mask >>= 1) != 0 )
            if( pixelcnt < npxls )
               buf[pixelcnt++] = (dat & mask) ? 1 : 0;
      }
   }
}

int MspDecoder::decode( unsigned char *buf, int npxls )
{
   if( status() == xOKAY )
   {
      if( version == 1 )
        read_v1( buf, npxls );
      else if( version == 2 )
        read_v2( buf, npxls );
   }
   return status();
}
