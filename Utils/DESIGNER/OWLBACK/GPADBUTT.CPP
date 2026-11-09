#include <owl.h>
#include "gpadbutt.h"

ToolBut::ToolBut(PTWindowsObject ap,int id,int x,int y,LPSTR bmp) :
    TButton(ap,id,"",x,y,BUTTWID,BUTTHGT,FALSE)
{
    BitMap=LoadBitmap(GetApplication()->hInstance,bmp);
    Attr.Style=WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_OWNERDRAW;
}
inline ToolBut::~ToolBut()
{
    DeleteObject(BitMap);
}
void ToolBut::ODADrawEntire(DRAWITEMSTRUCT far & di)
{
  HDC MemDC;

  MemDC=CreateCompatibleDC(di.hDC);
  SelectObject(MemDC,BitMap);
  BitBlt(di.hDC,0,0,BUTTWID,BUTTHGT,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
}
void ToolBut::ODASelect(DRAWITEMSTRUCT far & di)
{
  HDC MemDC;
  MemDC=CreateCompatibleDC(di.hDC);
  SelectObject(MemDC,BitMap);
  if ((di.itemState&ODS_SELECTED)==ODS_SELECTED)
     BitBlt(di.hDC,0,0,BUTTWID,BUTTHGT,MemDC,0,BUTTHGT,SRCCOPY);
  else
     BitBlt(di.hDC,0,0,BUTTWID,BUTTHGT,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
}
FormBut::FormBut(PTWindowsObject ap,int id,int x,int y,LPSTR bmp) :
    TButton(ap,id,"",x,y,FBUTWID,FBUTHGT,FALSE)
{
    BitMap=LoadBitmap(GetApplication()->hInstance,bmp);
    Attr.Style=WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_OWNERDRAW;
}
inline FormBut::~FormBut()
{
    DeleteObject(BitMap);
}
void FormBut::ODADrawEntire(DRAWITEMSTRUCT far & di)
{
  HDC MemDC;

  MemDC=CreateCompatibleDC(di.hDC);
  SelectObject(MemDC,BitMap);
  BitBlt(di.hDC,0,0,FBUTWID,FBUTHGT,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
}
void FormBut::ODAFocus(DRAWITEMSTRUCT far & di)
{
  HDC MemDC;
  MemDC=CreateCompatibleDC(di.hDC);
  SelectObject(MemDC,BitMap);
  if ((di.itemState&ODS_FOCUS)==ODS_FOCUS)
     BitBlt(di.hDC,0,0,FBUTWID,FBUTHGT,MemDC,0,FBUTHGT,SRCCOPY);
  else
     BitBlt(di.hDC,0,0,FBUTWID,FBUTHGT,MemDC,0,0,SRCCOPY);
  DeleteDC(MemDC);
}
