// OWLCVT 07/07/94 00:47:48
#include "owl\compat.h"
#include <owl\owlall.h>
#include "gpadtool.h"

LPSTR ToolWin::GetClassName()
{
    return "GPAD_Tool";
}
ToolWin::ToolWin(TWindow * p,int t,int x,int y,int x1,int y1)
        :TFrameWindow(p,(LPSTR)"TEST")
{
    Attr.Style=WS_CHILD;
    Attr.X=x;
    Attr.Y=y;
    Attr.W=x1-x;
    Attr.H=y1-y;
    type=t;
}
void ToolWin::SetupWindow()
{ 
    TFrameWindow::SetupWindow();
}


