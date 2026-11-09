#include <owl.h>
#include "gpadtool.h"

LPSTR ToolWin::GetClassName()
{
    return "GPAD_Tool";
}
ToolWin::ToolWin(PTWindowsObject p,int t,int x,int y,int x1,int y1)
        :TWindow(p,(LPSTR)"TEST")
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
    TWindow::SetupWindow();
}


