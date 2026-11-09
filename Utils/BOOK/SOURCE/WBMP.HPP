//--------------------------------------------------------//
//                                                        //
//   File:  WBMP.HPP                                      //
//                                                        //
//   Desc:  Version of BMP.HPP for MS Windows             //
//                                                        //
//--------------------------------------------------------//

#ifndef _WBMP_HPP_
#define _WBMP_HPP_

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "windows.h"

#include "codec.hpp"

#define  BMPSGN  0x4D42
#define  HDRSIZ  (sizeof(BITMAPINFO)+(sizeof(RGBQUAD)*256))

//..................class xBMP

class xBMP
{
   public:

      BITMAPFILEHEADER   bmfh;
      BITMAPINFO        *bmi;
      BITMAPINFOHEADER  *bmih;
      RGBQUAD           *rgbq;

   private:

      HGLOBAL      hhdr;
      LPSTR        phdr;
      HGLOBAL      hbits;
      char _huge * pbits;
      int          status;

   public:

      xBMP( char *bmppath );
     ~xBMP( );
      HBITMAP dib( HDC hdc );
      int okay( void ) { return status; }
};

#endif
