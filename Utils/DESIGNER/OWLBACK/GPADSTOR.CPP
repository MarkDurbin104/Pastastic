#include <owl.h>
#include <stdio.h>
#include <string.h>
#include "gpadstor.h"

LPSTR SDwin::GetClassName()
{
    return "GPAD_StorDesign";
}
SDwin::SDwin(PTWindowsObject p,int t,int x,int y,int x1,int y1)
      :ToolWin(p,t,x,y,x1,y1)
{
    TabList=new TListBox(this,ID_TABLIST,20,20,84,(y1-y)-100);
//    TabList->Attr.Style&=~LBS_SORT;   // must have no sort
    RecList=new RecLBox(this,ID_RECLIST,114,20,164,(y1-y)-100);
    RecList->Attr.Style&=~LBS_SORT;   // must have no sort
    LibList=new LibLBox(this,ID_LIBLIST,288,20,132,(y1-y)-100);
    ds=new DataStores("\\src\\gpa\\poland\\clk\\clerkd.dat");
}
void SDwin::SetupWindow()
{
    int i;
    TWindow::SetupWindow();
    for (i=0;i<ds->nst;i++)
        TabList->AddString(ds->st[i]->name);
    for (i=0;i<ds->nli;i++)
        LibList->AddString(ds->li[i]->line());
    Sfont=CreateFont(9,0,0,0,0,0,0,0,0,0,0,0,0,"Fixedsys");
    SendMessage(TabList->HWindow,WM_SETFONT,(unsigned)Sfont,0);
    SendMessage(RecList->HWindow,WM_SETFONT,(unsigned)Sfont,0);
    SendMessage(LibList->HWindow,WM_SETFONT,(unsigned)Sfont,0);
}
SDwin::~SDwin()
{
    DeleteObject(Sfont);
}
void SDwin::PickTab(RTMessage Msg)
{
    char str[10];
    int i,s;

    if (Msg.LP.Hi==LBN_SELCHANGE) {
        TabList->GetSelString(str,sizeof(str));
        RecList->ClearList();
        s=ds->snum(str);
        for (i=0;i<ds->st[s]->numitem;i++)
            RecList->AddString(ds->line(s,i));
    }
}
void SDwin::PickRec(RTMessage Msg)
{
    char str[10];

    if (Msg.LP.Hi==LBN_SELCHANGE) {
        RecList->GetSelString(str,sizeof(str));
    }
}
void SDwin::PickLib(RTMessage Msg)
{
    char str[10];

    if (Msg.LP.Hi==LBN_SELCHANGE) {
        LibList->GetSelString(str,sizeof(str));
    }
}
void SDwin::SizeBox(RTMessage Msg)
{
    MEASUREITEMSTRUCT *m=(MEASUREITEMSTRUCT far *)Msg.LParam;
    m->itemHeight=16;
}

RecLBox::RecLBox(PTWindowsObject p,int id,int x,int y,int l,int w)
        :TListBox(p,id,x,y,l,w)
{
}
void RecLBox::ODADrawEntire(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2  ,di.rcItem.top,&f[ 0],1);
    TextOut(di.hDC,di.rcItem.left+18 ,di.rcItem.top,&f[ 1],1);
    TextOut(di.hDC,di.rcItem.left+34 ,di.rcItem.top,&f[ 2],8);
    TextOut(di.hDC,di.rcItem.left+102,di.rcItem.top,&f[10],1);
    TextOut(di.hDC,di.rcItem.left+118,di.rcItem.top,&f[11],3);
}
void RecLBox::ODAFocus(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2  ,di.rcItem.top,&f[ 0],1);
    TextOut(di.hDC,di.rcItem.left+18 ,di.rcItem.top,&f[ 1],1);
    TextOut(di.hDC,di.rcItem.left+34 ,di.rcItem.top,&f[ 2],8);
    TextOut(di.hDC,di.rcItem.left+102,di.rcItem.top,&f[10],1);
    TextOut(di.hDC,di.rcItem.left+118,di.rcItem.top,&f[11],3);
}
void RecLBox::ODASelect(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2  ,di.rcItem.top,&f[ 0],1);
    TextOut(di.hDC,di.rcItem.left+18 ,di.rcItem.top,&f[ 1],1);
    TextOut(di.hDC,di.rcItem.left+34 ,di.rcItem.top,&f[ 2],8);
    TextOut(di.hDC,di.rcItem.left+102,di.rcItem.top,&f[10],1);
    TextOut(di.hDC,di.rcItem.left+118,di.rcItem.top,&f[11],3);
}
LibLBox::LibLBox(PTWindowsObject p,int id,int x,int y,int l,int w)
        :TListBox(p,id,x,y,l,w)
{
}
void LibLBox::ODADrawEntire(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2 ,di.rcItem.top,&f[ 0],8);
    TextOut(di.hDC,di.rcItem.left+70,di.rcItem.top,&f[ 8],1);
    TextOut(di.hDC,di.rcItem.left+86,di.rcItem.top,&f[ 9],3);
}
void LibLBox::ODAFocus(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2 ,di.rcItem.top,&f[ 0],8);
    TextOut(di.hDC,di.rcItem.left+70,di.rcItem.top,&f[ 8],1);
    TextOut(di.hDC,di.rcItem.left+86,di.rcItem.top,&f[ 9],3);
}
void LibLBox::ODASelect(DRAWITEMSTRUCT far & di)
{
    char *f=(char *)(di.itemData);
    TextOut(di.hDC,di.rcItem.left+2 ,di.rcItem.top,&f[ 0],8);
    TextOut(di.hDC,di.rcItem.left+70,di.rcItem.top,&f[ 8],1);
    TextOut(di.hDC,di.rcItem.left+86,di.rcItem.top,&f[ 9],3);
}
