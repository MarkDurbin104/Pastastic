#include <owl.h>
#include <edit.h>
#include <stdio.h>
#include "gpadform.h"
#include "gpadbutt.h"
#include "formdefs.h"

LPSTR FDwin::GetClassName()
{
    return "GPAD_FormDesign";
}
FDwin::FDwin(PTWindowsObject p,int t,int x,int y,int x1,int y1)
      :ToolWin(p,t,x,y,x1,y1)
{
    Fwin=new FWindow(this,"TestForm",2,1,(x1-x)-120,(y1-y)-5);
    Fwin->Attr.Style=WS_CHILD|WS_VISIBLE|WS_CAPTION;
    Flist=new TListBox(this,ID_FORMBOX,(x1-x)-110,4,100,(y1-y)-100);
    Flang=new TButton(this,ID_FORMLBUT,"Language",(x1-x)-110,(y1-y)-95,100,30,FALSE);
    Fattr=new TButton(this,ID_FORMABUT,"Form Type",(x1-x)-110,(y1-y)-50,100,30,FALSE);
}
void FDwin::Show(int s)
{ 
    TWindow::Show(s);
}
void FDwin::SetupWindow()
{ 
    TWindow::SetupWindow();
    Flist->Attr.Style&=~LBS_SORT;
    for (int i=0;i<Fwin->Fforms->Num();i++)
        Flist->AddString(Fwin->Fforms->Name(i));
    Flist->SetSelIndex(0);
    Fwin->SetCaption(Fwin->Fforms->Name(0));
    InvalidateRect(Fwin->HWindow,NULL,1);
}
void FDwin::PickForm(RTMessage Msg)
{
    int i;

    if (Msg.LP.Hi==LBN_SELCHANGE) {
        i=Flist->GetSelIndex();
        Fwin->SetCaption(Fwin->Fforms->Name(i));
        InvalidateRect(Fwin->HWindow,NULL,1);
    }
}
void FDwin::PickLang(RTMessage)
{
    Fwin->CurFtext^=1;
    InvalidateRect(Fwin->HWindow,NULL,1);
}
void FDwin::FormSetup(RTMessage)
{
    PTWindow ft;
    ft=new Ftypewin(this,Fwin);
    GetApplication()->MakeWindow(ft);
}
LPSTR FWindow::GetClassName()
{
    return "GPAD_Form";
}
FWindow::FWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h)
        :TWindow(p,t)
{
    Attr.Style|=WS_VSCROLL|WS_HSCROLL;
    Attr.X=x;
    Attr.Y=y;
    Attr.W=w;
    Attr.H=h;
    Scroller=new TScroller(this,8,14,80-((w-32)/8),25-((h-32)/14));
    Ffont[0]=CreateFont(14,8 ,0,0,0,0,0,0,0,0,0,0,0,"Polish Fixed");
    Ffont[1]=CreateFont(14,16,0,0,0,0,0,0,0,0,0,0,0,"Polish Fixed");
    Ffont[2]=CreateFont(28,16,0,0,0,0,0,0,0,0,0,0,0,"Polish Fixed");
    Fforms=new FormArray("d:\\src\\gpa\\poland\\clk\\clerkn.dat",HWindow);
    Ftext[0]=new FormText("d:\\src\\gpa\\clerk.eng",HWindow);
    Ftext[1]=new FormText("d:\\src\\gpa\\clerk.pol",HWindow);
    CurFtext=0;
    lbpressed=0;
    rbpressed=0;
}
FWindow::~FWindow()
{
    DeleteObject(Ffont[0]);
    DeleteObject(Ffont[1]);
    DeleteObject(Ffont[2]);
    delete Fforms;
    delete Ftext[0];
    delete Ftext[1];
}
void FWindow::Paint(HDC dc,PAINTSTRUCT &)
{
    HFONT hfontOld=(HFONT)SelectObject(dc,Ffont[0]);
    Fforms->display(dc,Ffont,Ftext[CurFtext]);
    SelectObject(dc,hfontOld);
}
void FWindow::WMMouseMove(RTMessage Msg)
{
    if (lbpressed)
       Fforms->Selectln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),2,HWindow);
    if (rbpressed)
       Fforms->Modifyln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),2);
}
void FWindow::WMLButtonUp(RTMessage Msg)
{
    Fforms->Selectln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),0,HWindow);
    lbpressed=0;
}
void FWindow::WMRButtonUp(RTMessage Msg)
{
    Fforms->Modifyln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),0);
    rbpressed=0;
}
int FWindow::ScrollXPos(void)
{
    return int(Scroller->XPos)*Scroller->XUnit;
}
int FWindow::ScrollYPos(void)
{
    return int(Scroller->YPos)*Scroller->YUnit;
}
void FWindow::WMLButtonDown(RTMessage Msg)
{
    Fforms->Selectln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),1,HWindow);
    lbpressed=1;
    TWindow::WMLButtonDown(Msg);
}
void FWindow::WMRButtonDown(RTMessage Msg)
{
    Fforms->Modifyln(Msg.LP.Lo+ScrollXPos(),Msg.LP.Hi+ScrollYPos(),1);
    rbpressed=1;
}
LPSTR Ftypewin::GetClassName()
{
    return "GPAD_FormAttr";
}
Ftypewin::Ftypewin(PTWindowsObject p,PFWindow w)
      :TWindow(p,"Form Attributes")
{
    DisableAutoCreate();
    Attr.Style=WS_POPUPWINDOW|WS_CAPTION|WS_VISIBLE;
    Attr.X=390;
    Attr.Y=250;
    Attr.W=242;
    Attr.H=180;
    fwin=w;
    newtype=ID_FORMNOC;                
    new FormBut(this,ID_FTBUTT,10 ,10   ,"FTBUTT");
    new FormBut(this,ID_PTBUTT,79 ,10   ,"PTBUTT");
    new FormBut(this,ID_STBUTT,10 ,57   ,"STBUTT");
    new FormBut(this,ID_MTBUTT,79 ,57   ,"MTBUTT");
    new FormBut(this,ID_RTBUTT,10 ,103  ,"RTBUTT");
    new FormBut(this,ID_PPBUTT,79 ,103  ,"PPBUTT");
    new TButton(this,ID_FAOK  ,"Ok"     ,150,10,82,30,TRUE);
    new TButton(this,ID_FACAN ,"Cancel" ,150,45,82,30,FALSE);
    new TStatic(this,ID_FAWIDT,"Width"  ,150,84 ,50,25,5);
    new TStatic(this,ID_FAHGTT,"Height" ,150,114,50,25,6);
    new TEdit  (this,ID_FAWID ,"80" ,200,80 ,32,25,3,FALSE);
    new TEdit  (this,ID_FAHGT ,"24" ,200,110,32,25,3,FALSE);
}
void Ftypewin::FTPress(RTMessage)  { newtype=ID_FORMCTF; }
void Ftypewin::PTPress(RTMessage)  { newtype=ID_FORMCTP; }
void Ftypewin::STPress(RTMessage)  { newtype=ID_FORMCTS; }
void Ftypewin::MTPress(RTMessage)  { newtype=ID_FORMCTM; }
void Ftypewin::RTPress(RTMessage)  { newtype=ID_FORMCTR; }
void Ftypewin::PPPress(RTMessage)  { newtype=ID_FORMCTPP; }
void Ftypewin::CanPress(RTMessage) { CloseWindow(); }
void Ftypewin::OKPress(RTMessage)
{
    switch (newtype) {
        case ID_FORMNOC :
            break;
        case ID_FORMCTF :
            fwin->Fforms->SetType(F_NORM);
            break;
        case ID_FORMCTP :
            fwin->Fforms->SetType(F_PROMPT);
            break;
        case ID_FORMCTS :
            fwin->Fforms->SetType(F_SERVE);
            break;
        case ID_FORMCTM :
            fwin->Fforms->SetType(F_MENU);
            break;
        case ID_FORMCTR :
            fwin->Fforms->SetType(F_REPORT);
            break;
        case ID_FORMCTPP:
            fwin->Fforms->SetType(F_PPFORM);
            break;
        default :
            MessageBeep(0);
    }
    InvalidateRect(fwin->HWindow,NULL,1);
    CloseWindow();
}
