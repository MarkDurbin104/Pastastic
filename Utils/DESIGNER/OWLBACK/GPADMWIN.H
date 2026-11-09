#ifndef GPADMWIN_H
#define GPADMWIN_H

#ifndef GPADBUTT_H
#include "gpadbutt.h"
#endif
#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif
#ifndef MAXPATH
#include <dir.h>
#endif

_CLASSDEF(Mainwin)
class _EXPORT Mainwin : public TWindow
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
        virtual void Save  (RTMessage)=[CM_FIRST+101];
        virtual void SaveAs(RTMessage)=[CM_FIRST+102];
        virtual void Exit  (RTMessage)=[CM_FIRST+106];
        virtual void FDPres(RTMessage)=[ID_FIRST+ID_FDBUTT];
        virtual void SDPres(RTMessage)=[ID_FIRST+ID_SDBUTT];
        virtual void AEPres(RTMessage)=[ID_FIRST+ID_AEBUTT];
        virtual void FEPres(RTMessage)=[ID_FIRST+ID_FEBUTT];
        virtual void KDPres(RTMessage)=[ID_FIRST+ID_KDBUTT];
        virtual void CFPres(RTMessage)=[ID_FIRST+ID_CEBUTT];
};

#endif

