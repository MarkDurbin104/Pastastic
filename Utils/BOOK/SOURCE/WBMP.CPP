//--------------------------------------------------------//
//                                                        //
//   File:  WBMP.CPP                                      //
//                                                        //
//   Desc:  Version of BMP.CPP for MS Windows             //
//                                                        //
//--------------------------------------------------------//

#include "wbmp.hpp"

// Note: This version assumes an uncompressed BMP file
//       compatible with Windows 3.0 or later.

//..................class xBMP

xBMP::xBMP( char *bmppath )
{
   // set uninitialized state
   hhdr = hbits = 0;
   phdr = 0;
   pbits = 0;
   status = -1;

   // open file
   HFILE hIN = _lopen( bmppath, READ );
   if( hIN == 0 ) { status = xIOERROR; return; }

   // read header and validate
   if( _lread( hIN, &bmfh, sizeof(BITMAPFILEHEADER) ) !=
      sizeof(BITMAPFILEHEADER) )
   {
      _lclose( hIN ); status = xIOERROR; return;
   }
   if( bmfh.bfType != BMPSGN )
   {
      _lclose( hIN ); status = xBADPARAM; return;
   }

   // load bitmap header and palette
   hhdr = GlobalAlloc( GMEM_MOVEABLE, HDRSIZ );
   if( hhdr == 0 )
   {
      _lclose( hIN ); status = xNOMEMORY; return;
   }
   phdr = GlobalLock( hhdr );
   if( _lread( hIN, phdr, HDRSIZ ) != HDRSIZ )
   {
      _lclose( hIN ); status = xIOERROR; return;
   }
   bmi  = (BITMAPINFO *) phdr;
   bmih = (BITMAPINFOHEADER *) phdr;
   rgbq = bmi->bmiColors;

   // compute row,bitmap sizes
   long rowbytes = (bmih->biWidth + 3) / 4;
   rowbytes *= 4;
   long nbytes = bmih->biHeight * rowbytes;

   // load bitmap
   hbits = GlobalAlloc( GMEM_MOVEABLE, nbytes );
   if( hbits == 0 )
   {
      _lclose( hIN ); status = xNOMEMORY; return;
   }
   pbits = (char _huge *) GlobalLock( hbits );
   _llseek( hIN, bmfh.bfOffBits, 0 );
   if( _hread( hIN, pbits, nbytes ) != nbytes )
   {
      _lclose( hIN ); status = xIOERROR; return;
   }

   // done!
   _lclose( hIN );
   status = xOKAY;
}

xBMP::~xBMP( )
{
   if( hhdr )
   {
      GlobalUnlock( hhdr );
      GlobalFree( hhdr );
   }
   if( hbits )
   {
      GlobalUnlock( hbits );
      GlobalFree( hbits );
   }
}

HBITMAP xBMP::dib( HDC hdc )
{
   return CreateDIBitmap( hdc, bmih, CBM_INIT, pbits,
                          bmi, DIB_RGB_COLORS );
}
