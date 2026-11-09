//--------------------------------------------------------//
//                                                        //
//   File:  WVBmp.Cpp                                     //
//                                                        //
//   Desc:  A simple Windows BMP file viewer              //
//                                                        //
//--------------------------------------------------------//

#include "intenmap.hpp"
#include "wbmp.hpp"
#include "wvbmp.h"

static HWND main_window_handle;

// contrast and brightness options
static  int  copt = idCNONE;
static  int  bopt = idBNONE;

//..................draw a bitmap

void draw_bitmap( HDC hdc, HBITMAP hbm, short xo, short yo )
{
   BITMAP  bm;
   HDC     hdcMem;
   POINT   bmSiz, bmOrg;

   hdcMem = CreateCompatibleDC( hdc );
   SelectObject( hdcMem, hbm );
   SetMapMode( hdcMem, GetMapMode( hdc ) );
   GetObject( hbm, sizeof( BITMAP ), (LPSTR) &bm );

   bmSiz.x = bm.bmWidth;
   bmSiz.y = bm.bmHeight;
   DPtoLP( hdc, &bmSiz, 1 );

   bmOrg.x = 0;
   bmOrg.y = 0;
   DPtoLP( hdc, &bmOrg, 1 );

   BitBlt( hdc, xo, yo, bmSiz.x, bmSiz.y,
           hdcMem, bmOrg.x, bmOrg.y, SRCCOPY );

   DeleteDC( hdcMem );
}

//..................load BMP file

static xBMP    *xbmp = 0;
static HBITMAP  hbmp = 0;

void load_bmp( char *fn, HDC hdc )
{
   if( xbmp ) delete xbmp;
   xbmp = new xBMP( fn );
   if( xbmp->okay() != xOKAY )
   {
      char msg[40];
      sprintf( msg, "Error %d loading file!", xbmp->okay() );
      TextOut( hdc, 10, 10, msg, strlen(msg) );
      MessageBeep( 0 );
      delete xbmp;
      xbmp = 0;
      hbmp = 0;
   }
   else
   {
      if( copt != idCNONE )
      {
         int sgn = (copt == idCMORE) ? 1 : -1;
         for( int i=0; i<256; i++ )
         {
            int r = xbmp->rgbq[i].rgbRed;
            int g = xbmp->rgbq[i].rgbGreen;
            int b = xbmp->rgbq[i].rgbBlue;
            rgb x( r, g, b );
            contrast_alter( &x, 1, sgn );
            xbmp->rgbq[i].rgbRed   = x.red;
            xbmp->rgbq[i].rgbGreen = x.grn;;
            xbmp->rgbq[i].rgbBlue  = x.blu;
         }
      }
      if( bopt != idBNONE )
      {
         int sgn = (bopt == idBMORE) ? 1 : -1;
         for( int i=0; i<256; i++ )
         {
            int r = xbmp->rgbq[i].rgbRed;
            int g = xbmp->rgbq[i].rgbGreen;
            int b = xbmp->rgbq[i].rgbBlue;
            rgb x( r, g, b );
            brightness_alter( &x, 1, sgn );
            xbmp->rgbq[i].rgbRed   = x.red;
            xbmp->rgbq[i].rgbGreen = x.grn;;
            xbmp->rgbq[i].rgbBlue  = x.blu;
         }
      }
      hbmp = xbmp->dib( hdc );
      if( hbmp == 0 )
      {
         TextOut( hdc, 10, 10, "DIB creation failed!", 20 );
         MessageBeep( 0 );
      }
      else
         draw_bitmap( hdc, hbmp, 0, 0 );
   }
}

//..................load-file dialog procedure

static  HANDLE   load_file_hand;
static  FARPROC  load_file_proc;
static  char     file_name[81] = "";

BOOL FAR PASCAL load_file( HWND hdlg, UINT message,
                           WPARAM wParam, LPARAM lParam )
{
   switch( message )
   {
      case WM_INITDIALOG :
           SendDlgItemMessage( hdlg, idFNAME,
                           EM_LIMITTEXT, 80, 0L );
           SetDlgItemText( hdlg, idFNAME, file_name );
           return 1;

      case WM_COMMAND :
           switch( wParam )
           {
              case idFNAME :
                   if( HIWORD(lParam) == EN_CHANGE )
                   {
                      HWND h = GetDlgItem( hdlg, IDOK );
                      LONG r = SendMessage( LOWORD(lParam),
                                 WM_GETTEXTLENGTH, 0, 0L );

                      EnableWindow( h, (BOOL) r );
                   }
                   return 1;

              case IDOK :
                   GetDlgItemText( hdlg, idFNAME, file_name, 80 );
              case IDCANCEL :
                   EndDialog( hdlg, 0 );
                   if( wParam == IDOK )
                   {
                      HDC hdc = GetDC( main_window_handle );
                      load_bmp( file_name, hdc );
                      ReleaseDC( main_window_handle, hdc );
                   }
                   return 1;
           }
           break;
   }

   return 0;
}

//..................load-options dialog procedure

static  HANDLE   get_opt_hand;
static  FARPROC  get_opt_proc;
BOOL FAR PASCAL get_opt( HWND hdlg, UINT message,
                         WPARAM wParam, LPARAM lParam )
{
   switch( message )
   {
      case WM_INITDIALOG :
           CheckRadioButton( hdlg, idCNONE, idCLESS, copt );
           CheckRadioButton( hdlg, idBNONE, idBLESS, bopt );
           return 1;

      case WM_COMMAND :
           switch( wParam )
           {
              case idCNONE :
              case idCMORE :
              case idCLESS :
                   copt = wParam;
                   CheckRadioButton( hdlg, idCNONE,
                                     idCLESS, copt );
                   return 1;

              case idBNONE :
              case idBMORE :
              case idBLESS :
                   bopt = wParam;
                   CheckRadioButton( hdlg, idBNONE,
                                     idBLESS, bopt );
                   return 1;

              case IDOK :
              case IDCANCEL :
                   EndDialog( hdlg, 0 );
                   return 1;
           }
           break;
   }

   return 0;
}

//..................main window procedure

long FAR PASCAL WndProc( HWND hwnd, UINT message,
                         WPARAM wParam, LPARAM lParam )
{
   HDC          hdc;
   PAINTSTRUCT  ps;

   switch( message )
   {
      case WM_COMMAND :
           switch( wParam )
           {
              case 1 : // Load
                   DialogBox( load_file_hand,
                              "LoadFile",
                              hwnd,
                              load_file_proc );
                   return 0;

              case 2 : // Options
                   DialogBox( get_opt_hand,
                              "GetOptions",
                              hwnd,
                              get_opt_proc );
                   return 0;

              case 3 : // Quit
                   SendMessage( hwnd, WM_CLOSE, 0, 0L );
                   return 0;
           }
           break;

      case WM_CREATE :
           load_file_hand =
               ((LPCREATESTRUCT) lParam)->hInstance;
           load_file_proc =
               MakeProcInstance( (FARPROC) load_file,
                                 load_file_hand );
           get_opt_hand =
               ((LPCREATESTRUCT) lParam)->hInstance;
           get_opt_proc =
               MakeProcInstance( (FARPROC) get_opt,
                                 get_opt_hand );
           return 0;

      case WM_PAINT :
           hdc = BeginPaint( hwnd, &ps );
           if( hbmp )
           {
                hbmp = xbmp->dib( hdc );
                draw_bitmap( hdc, hbmp, 0, 0 );
           }
           EndPaint( hwnd, &ps );
           return 0;

      case WM_DESTROY :
           if( xbmp ) delete xbmp;
           PostQuitMessage( 0 );
           return 0;
   }

   return DefWindowProc( hwnd, message, wParam, lParam );
}

//..................windows main

static char AppName[] = "WVBmp";

int PASCAL WinMain( HANDLE hInstance, HANDLE hPrevInstance,
                    LPSTR lpszCmdParam, int nCmdShow )
{
   WNDCLASS  wc;
   if( ! hPrevInstance )
   {
      wc.style         = CS_HREDRAW | CS_VREDRAW;
      wc.lpfnWndProc   = WndProc;
      wc.cbClsExtra    = 0;
      wc.cbWndExtra    = 0;
      wc.hInstance     = hInstance;
      wc.hIcon         = LoadIcon( NULL, IDI_APPLICATION );
      wc.hCursor       = LoadCursor( NULL, IDC_ARROW );
      wc.hbrBackground = GetStockObject( WHITE_BRUSH );
      wc.lpszMenuName  = AppName;
      wc.lpszClassName = AppName;
      RegisterClass( &wc );
   }

   // get screen dimensions
   int sw = GetSystemMetrics( SM_CXSCREEN );
   int sh = GetSystemMetrics( SM_CYSCREEN );

   HWND hwnd;
   hwnd = CreateWindow( AppName,
                        "BMP File Viewer",
                        WS_OVERLAPPEDWINDOW,
                        sw/4,
                        sh/4,
                        sw/2,
                        sh/2,
                        NULL,
                        NULL,
                        hInstance,
                        NULL );

   main_window_handle = hwnd;
   ShowWindow( hwnd, nCmdShow );
   UpdateWindow( hwnd );

   MSG msg;
   while( GetMessage( &msg, NULL, 0, 0 ) )
   {
      TranslateMessage( &msg );
      DispatchMessage( &msg );
   }

   return msg.wParam;
}
