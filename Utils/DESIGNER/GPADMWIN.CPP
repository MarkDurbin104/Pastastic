// OWLCVT 07/07/94 00:46:31
#include "owl\compat.h"
#include <dir.h>
#include <owl\owlall.h>
#include <owl\inputdia.h>
#include <owl\filedial.h>
#include <commdlg.h>
#include "gpadbutt.h"
#include "gpadtool.h"
#include "gpadform.h"
#include "gpadconf.h"
#include "gpadact.h"
#include "gpadstor.h"
#include "gpadmwin.h"

Mainwin::Mainwin(LPSTR t,LPSTR m) : TFrameWindow(NULL,t)
{
    RECT r;

    CurTool=(-1);
    DisableAutoCreate();
    AssignMenu(m);
    Attr.Style=WS_OVERLAPPEDWINDOW|WS_MAXIMIZE;
    Attr.Style&=~(WS_MAXIMIZEBOX|WS_SIZEBOX);
    ::GetWindowRect(::GetDesktopWindow(),(LPRECT)&r);
    Attr.X=r.left;
	 Attr.Y=r.top;
    Attr.W=r.right-r.left;
    Attr.H=r.bottom-r.top;
    int i=(Attr.W-(BUTTWID*6))/2;
    new ToolBut(this,ID_FDBUTT,i,r.top+5,"FDBUTT"); i+=BUTTWID;
    new ToolBut(this,ID_SDBUTT,i,r.top+5,"SDBUTT"); i+=BUTTWID;
    new ToolBut(this,ID_AEBUTT,i,r.top+5,"AEBUTT"); i+=BUTTWID;
    new ToolBut(this,ID_FEBUTT,i,r.top+5,"FEBUTT"); i+=BUTTWID;
    new ToolBut(this,ID_KDBUTT,i,r.top+5,"KDBUTT"); i+=BUTTWID;
    new ToolBut(this,ID_CEBUTT,i,r.top+5,"CEBUTT"); i+=BUTTWID;
    DesTool[0]=new   FDwin(this,0,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[0]->Show(SW_HIDE);
    DesTool[1]=new   SDwin(this,1,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[1]->Show(SW_HIDE);
	 DesTool[2]=new   AEwin(this,2,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[2]->Show(SW_HIDE);
    DesTool[3]=new ToolWin(this,3,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[3]->Show(SW_HIDE);
    DesTool[4]=new ToolWin(this,4,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[4]->Show(SW_HIDE);
    DesTool[5]=new   CEwin(this,5,0,BUTTHGT+5,Attr.W,Attr.H-37); DesTool[5]->Show(SW_HIDE);
    BitMap=LoadBitmap(GetApplication()->hInstance,"STARTUP");
}
LPSTR Mainwin::GetClassName()
{
    return "GPAD_Window";
}
void Mainwin::GetWindowClass(WNDCLASS& wc)
{
	 TFrameWindow::GetWindowClass(wc);
    wc.hIcon=LoadIcon(GetApplication()->hInstance,"GPADICON");
}
void Mainwin::SetupWindow()
{
  TFrameWindow::SetupWindow();
}
void Mainwin::FDPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=0]->Show(SW_SHOW);
}
void Mainwin::SDPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=1]->Show(SW_SHOW);
}
void Mainwin::AEPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=2]->Show(SW_SHOW);
}
void Mainwin::FEPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=3]->Show(SW_SHOW);
}
void Mainwin::KDPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=4]->Show(SW_SHOW);
}
void Mainwin::CFPres( UINT )
{

    if (BitMap!=NULL) { DeleteObject(BitMap); BitMap=NULL; }
    if (CurTool!=(-1)) DesTool[CurTool]->Show(SW_HIDE);
    DesTool[CurTool=5]->Show(SW_SHOW);
}
void Mainwin::Exit()
{

    CloseWindow();
}
void Mainwin::Paint(HDC DC,PAINTSTRUCT&)
{
  HDC MemDC;
  if (BitMap==NULL) return;
  MemDC=CreateCompatibleDC(DC);
  SelectObject(MemDC,BitMap);
  BitBlt(DC,(Attr.W-443)/2,BUTTHGT+12,443,273,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
}

int Mainwin::FBox(HWND hw,char *file,char *tit)
{
	OPENFILENAME ofn;
	 int res;
	char szTemp[]="All Files (*.*)\0*.*\0Text Files (*.txt)\0*.txt\0";
	ofn.lStructSize=sizeof( OPENFILENAME );
	ofn.hwndOwner=hw;
	ofn.hInstance=0;
	ofn.lpstrFilter=(LPSTR)szTemp;
	ofn.lpstrCustomFilter=NULL;
	ofn.nMaxCustFilter=0;
	ofn.nFilterIndex=1;
	ofn.lpstrFile=(LPSTR)file;
	ofn.nMaxFile=sizeof( file );
	ofn.lpstrFileTitle=NULL;
	ofn.nMaxFileTitle=0;
	ofn.lpstrInitialDir=NULL;
	ofn.lpstrTitle=tit;
	ofn.Flags=OFN_FILEMUSTEXIST|OFN_HIDEREADONLY|OFN_PATHMUSTEXIST;
	ofn.nFileOffset=0;
	ofn.nFileExtension=0;
	ofn.lpstrDefExt="*";
	ofn.lCustData=NULL;
	ofn.lpfnHook=NULL;
	ofn.lpTemplateName=NULL;

	res=GetOpenFileName(&ofn);
	::InvalidateRect(hw,NULL,TRUE);
    return res;
}
void Mainwin::Save()
{

    FBox(HWindow,"Test.cmp","File Save");
}

void Mainwin::SaveAs()
{

    FBox(HWindow,"*.cmp","File Save As");
}


DEFINE_RESPONSE_TABLE1( Mainwin, TFrameWindow )
    EV_COMMAND( 101, Save ),
    EV_COMMAND( 102, SaveAs ),
    EV_COMMAND( 106, Exit ),
    EV_CHILD_NOTIFY_ALL_CODES( 900, FDPres ),
    EV_CHILD_NOTIFY_ALL_CODES( 901, SDPres ),
    EV_CHILD_NOTIFY_ALL_CODES( 902, AEPres ),
    EV_CHILD_NOTIFY_ALL_CODES( 903, FEPres ),
    EV_CHILD_NOTIFY_ALL_CODES( 904, KDPres ),
    EV_CHILD_NOTIFY_ALL_CODES( 905, CFPres ),
END_RESPONSE_TABLE;
