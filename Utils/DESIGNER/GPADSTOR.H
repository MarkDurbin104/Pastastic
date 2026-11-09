// OWLCVT 07/07/94 00:46:29
#ifndef GPADSTOR_H
#define GPADSTOR_H

#ifndef GPADTOOL_H
#include "owl\compat.h"
#include "gpadtool.h"
#endif

#ifndef GPADSCLS_H
#include "gpadscls.h"
#endif

#ifndef __LISTBOX_H
#include <owl\listbox.h>
#endif

#define ID_TABLIST 320
#define ID_RECLIST 321
#define ID_LIBLIST 322


_CLASSDEF(SDwin)
class _OWLCLASS SDwin : public ToolWin
{
    private:
        TListBox _FAR *   TabList;
        TListBox _FAR *   RecList;
        TListBox _FAR *   LibList;
        PDataStores ds;
        HFONT       Sfont;
    public:
        SDwin(TWindow * p,int t,int x,int y,int x1,int y1);
        ~SDwin();
        virtual LPSTR GetClassName();
        virtual void SetupWindow();
        void PickTab( UINT );
        void PickRec( UINT );
        void PickLib( UINT );
        void EvMeasureItem( UINT, MEASUREITEMSTRUCT __far & );
DECLARE_RESPONSE_TABLE( SDwin );
};

_CLASSDEF(RecLBox)
class _OWLCLASS RecLBox : public TListBox
{
    public:
        RecLBox(TWindow * p,int id,int x,int y,int l,int w);
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di);
        virtual void ODASelect    (DRAWITEMSTRUCT far & di);
};     
_CLASSDEF(LibLBox)
class _OWLCLASS LibLBox : public TListBox
{
    public:
        LibLBox(TWindow * p,int id,int x,int y,int l,int w);
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di);
        virtual void ODASelect    (DRAWITEMSTRUCT far & di);
};     
#endif

