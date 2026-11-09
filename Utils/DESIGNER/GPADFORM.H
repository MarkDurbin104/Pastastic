// OWLCVT 07/07/94 00:45:49
#ifndef GPADFORM_H
#define GPADFORM_H

#ifndef GPADTOOL_H
#include "owl\compat.h"
#include "gpadtool.h"
#endif

#ifndef __LISTBOX_H
#include <owl\listbox.h>
#endif

#ifndef __BUTTON_H
#include <owl\button.h>
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
class FWindow : public TFrameWindow
{
    public:
        PFormArray Fforms;
        HFONT      Ffont[3];
        PFormText  Ftext[2];
        int        CurFtext;
        int        lbpressed;
        int        rbpressed;
        FWindow(TWindow * p,LPSTR t,int x,int y,int w,int h);
        ~FWindow();
        virtual LPSTR GetClassName();
        virtual void Paint(HDC dc,PAINTSTRUCT &p);
        virtual int ScrollXPos(void);
        virtual int ScrollYPos(void);
        void EvLButtonDown( UINT, TPoint& );
        void EvRButtonDown( UINT, TPoint& );
        void EvLButtonUp( UINT, TPoint& );
        void EvRButtonUp( UINT, TPoint& );
        void EvMouseMove( UINT, TPoint& );
DECLARE_RESPONSE_TABLE( FWindow );
};

_CLASSDEF(FDwin)
class _OWLCLASS FDwin : public ToolWin
{
    private:
        TListBox _FAR * Flist;
        TButton _FAR *  Flang;
        TButton _FAR *  Fattr;
        PFWindow  Fwin;
    public:
        FDwin(TWindow * p,int t,int x,int y,int x1,int y1);
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
        virtual void Show(int);
        void PickForm( UINT );
        void PickLang( UINT );
        void FormSetup( UINT );
DECLARE_RESPONSE_TABLE( FDwin );
};
_CLASSDEF(Ftypewin)
class Ftypewin : public TFrameWindow
{
    PFWindow fwin;
    int newtype;
    public:
        Ftypewin(TWindow * p,PFWindow w);
        virtual LPSTR GetClassName();
        virtual void SetupWindow() { TFrameWindow::SetupWindow(); }
        void FTPress( UINT );
        void PTPress( UINT );
        void STPress( UINT );
        void MTPress( UINT );
        void RTPress( UINT );
        void PPPress( UINT );
        void OKPress( UINT );
        void CanPress( UINT );
DECLARE_RESPONSE_TABLE( Ftypewin );
};
#endif

