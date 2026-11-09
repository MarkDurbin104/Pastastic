#ifndef GPADBUTT_H
#define GPADBUTT_H

#ifndef __BUTTON_H
#include <button.h>
#endif

#define ID_FDBUTT   900
#define ID_SDBUTT   901
#define ID_AEBUTT   902
#define ID_FEBUTT   903
#define ID_KDBUTT   904
#define ID_CEBUTT   905

#define BUTTWID     100
#define BUTTHGT     75
#define FBUTHGT     46
#define FBUTWID     68

_CLASSDEF(ToolBut)
class ToolBut : public TButton
{
    private:
        HBITMAP BitMap;
    public:
        ToolBut(PTWindowsObject ap,int id,int x,int y,LPSTR bmp);
        ~ToolBut();
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di) {}
        virtual void ODASelect    (DRAWITEMSTRUCT far & di);
};

_CLASSDEF(FormBut)
class FormBut : public TButton
{
    private:
        HBITMAP BitMap;
    public:
        FormBut(PTWindowsObject ap,int id,int x,int y,LPSTR bmp);
        ~FormBut();
        virtual void ODADrawEntire(DRAWITEMSTRUCT far & di);
        virtual void ODAFocus     (DRAWITEMSTRUCT far & di);
        virtual void ODASelect    (DRAWITEMSTRUCT far & di) {}
};

#endif

