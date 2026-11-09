#include <io.h>
#include <fcntl.h>
#include <owl.h>
#include <edit.h>
#include <stdio.h>
#include "gpadact.h"

LPSTR AEwin::GetClassName()
{
    return "GPAD_ActionEdit";
}
AEwin::AEwin(PTWindowsObject p,int t,int x,int y,int x1,int y1)
      :ToolWin(p,t,x,y,x1,y1)
{
    Awin=new AWindow(this,"Actions",2,1,(x1-x)-120,(y1-y)-5);
    Awin->Attr.Style=WS_CHILD|WS_VISIBLE|WS_CAPTION;
}
void AEwin::Show(int s)
{ 
    TWindow::Show(s);
}
void AEwin::SetupWindow()
{ 
    TWindow::SetupWindow();
    Awin->SetCaption("Actions");
}
LPSTR AWindow::GetClassName()
{
    return "GPAD_Action";
}
AWindow::AWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h)
        :TFileWindow(p,t,"\\src\\gpa\\poland\\clk\\clerka.dat")
{
    Attr.X=x;
    Attr.Y=y;
    Attr.W=w;
    Attr.H=h;
    Afont=CreateFont(9,0,0,0,0,0,0,0,0,0,0,0,0,"Fixedsys");
}
void AWindow::SetupWindow()
{ 
    TFileWindow::SetupWindow();
    SendMessage(Editor->HWindow,WM_SETFONT,(unsigned)Afont,0);
}

AWindow::~AWindow()
{
    DeleteObject(Afont);
}

