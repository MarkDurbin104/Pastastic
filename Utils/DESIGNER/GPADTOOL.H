#ifndef GPADTOOL_H
#define GPADTOOL_H

#ifndef __OWL_H
#include <owl.h>
#endif

_CLASSDEF(ToolWin)
class ToolWin : public TWindow
{
    protected:
        int type;
    public:
        ToolWin(PTWindowsObject p,int t,int x,int y,int x1,int y1);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
};

#endif


