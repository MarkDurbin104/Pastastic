#ifndef GPADFORM_H
#define GPADFORM_H

#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif

#ifndef __LISTBOX_H
#include <listbox.h>
#endif

#ifndef __BUTTON_H
#include <button.h>
#endif

#ifndef GPADFCLS_H
#include "gpadfcls.h"
#endif

#define ID_FORMBOX  300
#define ID_FORMLBUT 301
#define ID_FORMABUT 302

#define ID_FTBUTT   350
#define ID_PTBUTT   351
#define ID_STBUTT   352
#define ID_MTBUTT   353
#define ID_RTBUTT   354
#define ID_PPBUTT   355
#define ID_FAOK     356
#define ID_FACAN    357
#define ID_FAWID    358
#define ID_FAHGT    359
#define ID_FAWIDT   360
#define ID_FAHGTT   361

#define ID_FORMNOC   400
#define ID_FORMCTF   401
#define ID_FORMCTP   402
#define ID_FORMCTS   403
#define ID_FORMCTM   404
#define ID_FORMCTR   405
#define ID_FORMCTPP  406
#define ID_CFORMTYPE 410

_CLASSDEF(FWindow)
class FWindow : public TWindow
{
    public:
        PFormArray Fforms;
        HFONT      Ffont[3];
        PFormText  Ftext[2];
        int        CurFtext;
        int        lbpressed;
        int        rbpressed;
        FWindow(PTWindowsObject p,LPSTR t,int x,int y,int w,int h);
        ~FWindow();
        virtual LPSTR GetClassName();
        virtual void Paint(HDC dc,PAINTSTRUCT &p);
        virtual int ScrollXPos(void);
        virtual int ScrollYPos(void);
        virtual void WMLButtonDown(RTMessage Msg)=[WM_FIRST+WM_LBUTTONDOWN];
        virtual void WMRButtonDown(RTMessage Msg)=[WM_FIRST+WM_RBUTTONDOWN];
        virtual void WMLButtonUp  (RTMessage Msg)=[WM_FIRST+WM_LBUTTONUP];
        virtual void WMRButtonUp  (RTMessage Msg)=[WM_FIRST+WM_RBUTTONUP];
        virtual void WMMouseMove  (RTMessage Msg)=[WM_FIRST+WM_MOUSEMOVE];
};

_CLASSDEF(FDwin)
class _EXPORT FDwin : public ToolWin
{
    private:
        PTListBox Flist;
        PTButton  Flang;
        PTButton  Fattr;
        PFWindow  Fwin;
    public:
        FDwin(PTWindowsObject p,int t,int x,int y,int x1,int y1);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
        virtual void Show(int);
        virtual void PickForm (RTMessage)=[ID_FIRST+ID_FORMBOX];
        virtual void PickLang (RTMessage)=[ID_FIRST+ID_FORMLBUT];
        virtual void FormSetup(RTMessage)=[ID_FIRST+ID_FORMABUT];
};
_CLASSDEF(Ftypewin)
class Ftypewin : public TWindow
{
    PFWindow fwin;
    int newtype;
    public:
        Ftypewin(PTWindowsObject p,PFWindow w);
        virtual LPSTR GetClassName();
        virtual void SetupWindow() { TWindow::SetupWindow(); }
        virtual void FTPress(RTMessage) =[ID_FIRST+ID_FTBUTT];
        virtual void PTPress(RTMessage) =[ID_FIRST+ID_PTBUTT];
        virtual void STPress(RTMessage) =[ID_FIRST+ID_STBUTT];
        virtual void MTPress(RTMessage) =[ID_FIRST+ID_MTBUTT];
        virtual void RTPress(RTMessage) =[ID_FIRST+ID_RTBUTT];
        virtual void PPPress(RTMessage) =[ID_FIRST+ID_PPBUTT];
        virtual void OKPress(RTMessage) =[ID_FIRST+ID_FAOK  ];
        virtual void CanPress(RTMessage)=[ID_FIRST+ID_FACAN ];
};
#endif

