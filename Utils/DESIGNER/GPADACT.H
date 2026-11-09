#ifndef GPADACT_H
#define GPADACT_H

#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif

#ifndef __FILEWND_H
#include <filewnd.h>
#endif


_CLASSDEF(AWindow)
class AWindow : public TFileWindow
{
    public:
        HFONT      Afont;
        AWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h);
        ~AWindow();
        virtual void SetupWindow();
        virtual LPSTR GetClassName();
//        virtual void Paint(HDC dc,PAINTSTRUCT &p);
};
_CLASSDEF(AEwin)
class AEwin : public ToolWin
{
    private:
        PAWindow Awin;
    public:
        AEwin(PTWindowsObject p,int t,int x,int y,int x1,int y1);
        void Show(int s);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
};
#endif


