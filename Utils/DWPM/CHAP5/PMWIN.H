/* Header for WIndows test bed
   see PMWIN.C for compile instructions */

#ifndef _PMWIN_H
#define _PMWIN_H

#define IDM_ABOUT 100
#define IDM_STOP 101
#define IDM_TEST 102

int PASCAL WinMain(HANDLE, HANDLE, LPSTR, int);
BOOL InitApplication(HANDLE);
BOOL InitInstance(HANDLE, int);
long FAR PASCAL _export MainWndProc(HWND, WORD, WORD, LONG);
BOOL FAR PASCAL _export About(HWND, unsigned, WORD, LONG);

#endif
