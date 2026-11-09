#include <io.h>
#include <fcntl.h>
#include <owl.h>
#include <edit.h>
#include <stdio.h>
#include "gpadconf.h"

LPSTR CEwin::GetClassName()
{
    return "GPAD_ConfigEdit";
}
CEwin::CEwin(PTWindowsObject p,int t,int x,int y,int x1,int y1)
      :ToolWin(p,t,x,y,x1,y1)
{
    Cwin=new CWindow(this,"Config",2,1,(x1-x)-120,(y1-y)-5);
    Cwin->Attr.Style=WS_CHILD|WS_VISIBLE|WS_CAPTION;
}
void CEwin::Show(int s)
{ 
    TWindow::Show(s);
}
void CEwin::SetupWindow()
{ 
    TWindow::SetupWindow();
    Cwin->SetCaption("Config");
}
LPSTR CWindow::GetClassName()
{
    return "GPAD_Config";
}
CWindow::CWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h)
        :TFileWindow(p,t,"\\src\\gpa\\clk.cfg")
{
    Attr.X=x;
    Attr.Y=y;
    Attr.W=w;
    Attr.H=h;
    Cfont=CreateFont(9,0,0,0,0,0,0,0,0,0,0,0,0,"Polish Fixed");
}
void CWindow::SetupWindow()
{ 
    TFileWindow::SetupWindow();
    SendMessage(Editor->HWindow,WM_SETFONT,(unsigned)Cfont,0);
}

CWindow::~CWindow()
{
    DeleteObject(Cfont);
}

