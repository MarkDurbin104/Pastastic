#ifndef GPADSTOR_H
#define GPADSTOR_H

#ifndef GPADTOOL_H
#include "gpadtool.h"
#endif

#ifndef GPADSCLS_H
#include "gpadscls.h"
#endif

#ifndef __LISTBOX_H
#include <listbox.h>
#endif

#define ID_TABLIST 320
#define ID_RECLIST 321
#define ID_LIBLIST 322


_CLASSDEF(SDwin)
class _EXPORT SDwin : public ToolWin
{
    private:
        PTListBox   TabList;
        PTListBox   RecList;
        PTListBox   LibList;
        PDataStores ds;
        HFONT       Sfont;
    public:
        SDwin(PTWindowsObject p,int t,int x,int y,int x1,int y1);
        ~SDwin();
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
        virtual void PickTab(RTMessage Msg)=[ID_FIRST+ID_TABLIST];
        virtual void PickRec(RTMessage Msg)=[ID_FIRST+ID_RECLIST];
        virtual void PickLib(RTMessage Msg)=[ID_FIRST+ID_LIBLIST];
        virtual void SizeBox(RTMessage Msg)=[WM_FIRST+WM_MEASUREITEM];
};

_CLASSDEF(RecLBox)
class _EXPORT RecLBox : public TListBox
{
    public:
        RecLBox(PTWindowsObject p,int id,int x,int y,int l,int w);
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di);
        virtual void ODASelect    (DRAWITEMSTRUCT far & di);
};     
_CLASSDEF(LibLBox)
class _EXPORT LibLBox : public TListBox
{
    public:
        LibLBox(PTWindowsObject p,int id,int x,int y,int l,int w);
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di);
        virtual void ODASelect    (DRAWITEMSTRUCT far & di);
};     
#endif

