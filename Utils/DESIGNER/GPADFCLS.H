#ifndef GPADFCLS_H
#define GPADFCLS_H
#define NUM_FCLASS  10
#define FF_MAND   0x0000
#define FF_OPTI   0x0001
#define FF_SRCH   0x0002
#define FF_TEXT   0x0003
#define FF_MSRH   0x0004
#define FF_MSEC   0x0005
#define FF_WAIT   0x0006
#define FF_DISP   0x0007
#define FF_SECS   0x0008
#define FF_TABL   0x0009

#define FF_TBLF   0x8000

#define IT_MENU   0x01
#define IT_FORM   0x02
#define IT_FUNC   0x03

#define MI_ENAB   0x00
#define MI_DISA   0x01


#define FA_UPDS   0x01

#define PAREA1    0
#define PAREA2    17
#define PAREA3    79
#define PAREA4    20
#define TAREA1    43
#define TAREA2    21
#define TAREA3    79
#define TAREA4    24
#define LAREA1    47
#define LAREA2    2
#define LAREA3    79
#define LAREA4    16

#define NORMPEN   0x00000000L
#define TEXTPEN   0x00000000L
#define DISPPEN   0x00008000L
#define FIELDPEN  0x00800000L
#define SELPEN    0x00000080L
#define BGNDPEN   0x00808080L

#ifndef __OWL_H
#include <owl.h>
#endif

#ifndef STRCLASS_H
#include "strclass.h"
#endif

#ifndef max
#define max(a,b) ((a>b)?a:b)
#endif


_CLASSDEF(Form)
_CLASSDEF(FItem)
_CLASSDEF(FField)
_CLASSDEF(TxtField)
_CLASSDEF(NrmField)
_CLASSDEF(HidNField)
_CLASSDEF(HidTField)
_CLASSDEF(TabField)
_CLASSDEF(FormText)
_CLASSDEF(FormArray)

typedef struct {
	 unsigned char x;
    unsigned char y;
} PNT;

typedef struct {
    PNT   tl;
    PNT   br;
} WIN;
//----------------------------------------------------------------------------
typedef struct {                  // Form Field Structure
        char            name[9];  // field name
        char            type[9];  // field type
		  unsigned char   ident;    // unique field identifier
        PNT             pos;      // x/y co-ordinates
        char            attrib;   // field attributes
        unsigned char   size;     // field size
        unsigned int    cls;      // item classification
        char            func[9];  // validation function
        char            item[60]; // item
        char            fmt[40];  // input format
    } FFstruct;
typedef FFstruct *PFFstruct;      // Pointer to Form Field Structure
//----------------------------------------------------------------------------
typedef struct {                  // Form Structure
        char            name[9];  // form name
        unsigned char   numitem;  // the number of items
        int             access;   // form access level
        WIN             fb;       // form boundaries
        int             type;     // form type
        char            attribs;  // form attributes 
        int             curitem;  // the current item selected
        PFFstruct       items;    // the list of items in order of display
    } Fstruct;
typedef Fstruct *PFstruct;        // Pointer to Form Structure
//----------------------------------------------------------------------------
class FItem
{
    protected:
        Str           name;   // field name
        Str           func;   // validation function
        Str           eefunc; // field entry/exit function
        unsigned char ident;   // unique field identifier
        int           xc;      // x co-ordinate
        int           yc;      // y co-ordinate
        char          attrib;  // field attributes
        unsigned char size;    // field size
        unsigned int  cls;     // item classification
        virtual void setup(int x,int y,int a,int c,int s,int l);
        int           len;
        int           selected;
        unsigned char snx,sny;
    public:
        FItem(char *n,int id);
        ~FItem();
        virtual void setfunc(int t,char *f);
        virtual int  isunder(int x,int y);
        virtual int  iswithin(int x,int y,int x1,int y1);
        virtual int  id(void) { return ident; }
        virtual int  isselected(void) { return selected; }
        virtual void select(int s)    { selected=s;      }
        virtual int  attr(void)       { return cls&(~FF_TBLF);   }
        virtual int  move(int dx,int dy);
        virtual int  snapx(void) { return (xc/snx)*snx; }
        virtual int  snapy(void) { return (yc/sny)*sny; }
        virtual void setpos(void) { xc=snapx(); yc=snapy(); }
        virtual void setsnap(int x,int y) { snx=x; sny=y; }
};
//----------------------------------------------------------------------------
class FField : public FItem
{
//    protected:
    public:
        Str item;
        Str fmt;
        FField(char *n,int id);
        ~FField();
        virtual void setup(int x,int y,int a,int c,int s,char *i,char *f);
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
};
class NrmField : public FField
{
    public:
        NrmField(char *n,int id) : FField(n,id) {}
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
};
class TxtField : public FField
{
    public:
        TxtField(char *n,int id) : FField(n,id) {}
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
};
class HidNField : public NrmField
{
    public:
        HidNField(char *n,int id) : NrmField(n,id) {}
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
};
class HidTField : public TxtField
{
    public:
        HidTField(char *n,int id) : TxtField(n,id) {}
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
};
class TabField : public FField
{
    private:
        PFField    Nflds[20];
        PFField    Tflds[20];
        int        TabType;
        int        TabLen;
        int        TabWid;
        int        TabCols;
        int        TabNumf;
        Str        Store;
        Str        Fields[20];
        int        Fpos[20];
    public:
        TabField(char *n,int id) : FField(n,id) {}
        virtual void display(PForm p,HDC DC,HFONT *f,PFormText ft);
        int gettbldata(PForm p,PFormText ft);
};
//----------------------------------------------------------------------------
class Form
{
    private:
        int           acc;      // form access level
        int           xc;       // x co-ordinate
        int           yc;       // y co-ordinate
        int           wi;       // width
        int           hi;       // height
        int           type;     // form type
        char          attribs;  // form attributes
        int           lx;       // the origin mouse xpos
        int           ly;       // the origin mouse ypos
        int           snx;      // x snap distance
        int           sny;      // y snap distance
    public:
        Str           name;    // form name
        PFField       *items;
        unsigned char numitem;  // the number of items
        int           curitem;  // the current item selected
        Form(char *n);
        Form();
        ~Form();
        virtual int read(int fd,HWND h);
        void display(HDC DC,HFONT *f,PFormText ft);
        int FFindex(int ident);
        void SetType(int t) { type=t; }
        int Selectln(int x,int y,int type);
};
//----------------------------------------------------------------------------
class FormArray
{
    private:
        PForm    *Forms;
        int       numgot;
        int       number;
        int       lastacc;
    public:
        FormArray(char *f,HWND h);
        ~FormArray();
        char *Name(int idx=(-1));
        int Num() { return number; }
        Add(PForm f);
        void SetType(int t);
        void display(HDC DC,HFONT *f,PFormText ft,int idx=(-1));
        void Selectln(int x,int y,int type,HWND win);
        void Modifyln(int x,int y,int type) { MessageBeep(0); }
};
//----------------------------------------------------------------------------
class FormText
{
    private:
        PStr names;
        PStr items;
        int numitem;
    public:
        FormText(char *n,HWND h);
        ~FormText();
        char *str(char *s);
        char *str(int idx);
        int len(char *s);
        int len(int idx);
        char *operator [](int index);
};
#endif