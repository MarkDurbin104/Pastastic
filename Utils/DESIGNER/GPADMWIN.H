// OWLCVT 07/07/94 00:42:48
#ifndef GPADMWIN_H
#define GPADMWIN_H

#ifndef GPADBUTT_H
#include "owl\compat.h"
#include "gpadbutt.h"
#endif
#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif
#ifndef MAXPATH
#include <dir.h>
#endif

_CLASSDEF(Mainwin)
class _OWLCLASS Mainwin : public TFrameWindow
{
    public:
        char     FileName[MAXPATH];
        int      CurTool;
        PToolWin DesTool[6];
        HBITMAP  BitMap;

        Mainwin(LPSTR n,LPSTR m);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
        virtual void GetWindowClass(WNDCLASS& wc);
        virtual void Paint(HDC DC,PAINTSTRUCT&);
        virtual int  FBox  (HWND hw,char *file,char *tit);
        void Save();
        void SaveAs();
        void Exit();
        void FDPres( UINT );
        void SDPres( UINT );
        void AEPres( UINT );
        void FEPres( UINT );
        void KDPres( UINT );
        void CFPres( UINT );
DECLARE_RESPONSE_TABLE( Mainwin );
};

#endif

