// OWLCVT 07/07/94 00:43:35
#include "owl\compat.h"
#include <io.h>
#include <fcntl.h>
#include <owl\owlall.h>
#include <owl\edit.h>
#include <stdio.h>
#include "gpadact.h"

LPSTR AEwin::GetClassName()
{
    return "GPAD_ActionEdit";
}
AEwin::AEwin(TWindow * p,int t,int x,int y,int x1,int y1)
      :ToolWin(p,t,x,y,x1,y1)
{
    Awin=new AWindow(this,"Actions",2,1,(x1-x)-120,(y1-y)-5);
    Awin->Attr.Style=WS_CHILD|WS_VISIBLE|WS_CAPTION;
}
void AEwin::Show(int s)
{ 
    TFrameWindow::Show(s);
}
void AEwin::SetupWindow()
{ 
    TFrameWindow::SetupWindow();
    Awin->SetCaption("Actions");
}
LPSTR AWindow::GetClassName()
{
    return "GPAD_Action";
}
AWindow::AWindow(TWindow * p,LPSTR t,int x,int y,int w,int h)
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
    ::SendMessage(Editor->HWindow,WM_SETFONT,(unsigned)Afont,0);
}

AWindow::~AWindow()
{
    DeleteObject(Afont);
}

