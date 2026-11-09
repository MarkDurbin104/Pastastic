#ifndef GPADCONF_H
#define GPADCONF_H

#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif

#ifndef __FILEWND_H
#include <filewnd.h>
#endif


_CLASSDEF(CWindow)
class CWindow : public TFileWindow
{
    public:
        HFONT      Cfont;
        CWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h);
        ~CWindow();
        virtual void SetupWindow();
        virtual LPSTR GetClassName();
};
_CLASSDEF(CEwin)
class CEwin : public ToolWin
{
    private:
        PCWindow Cwin;
    public:
        CEwin(PTWindowsObject p,int t,int x,int y,int x1,int y1);
        void Show(int s);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
};
#endif


