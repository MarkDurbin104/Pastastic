// OWLCVT 07/07/94 00:45:12
#include "owl\compat.h"
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include "gpadfcls.h"
#include "formdefs.h"
//----------------------------------------------------------------------------
FItem::FItem(char *n,int id)
{
    len=0;
    name=n;
    ident=id;
    selected=0;
    snx=1;
    sny=1;
}
FItem::~FItem()
{
}
void FItem::setup(int x,int y,int a,int c,int s,int l)
{
    xc=x;
    yc=y;
    attrib=a;
    cls=c;
    size=s;
    len=l;
}
void FItem::setfunc(int t,char *f)
{
    switch (t) {
        case 0 :
            func=f;
            break;
        case 1 :
            eefunc=f;
            break;
    }
}
int FItem::isunder(int x,int y)
{
    if ((x>=snapx())
    &&  (x<=snapx()+(len*(1+(size>1)))*8)
    &&  (y>=snapy())
    &&  (y<=snapy()+(1+(size>2))*14)) return 1;
    return 0;
}
int FItem::iswithin(int x,int y,int x1,int y1)
{
    return (x>=snapx())&&(x1<=(snapx()+len)*(1+(size>1)))&&(y>=snapy())&&(y1<=(snapy()+(size>2)));
}
int FItem::move(int dx,int dy)
{
    int ret=0;
    int tx=dx+xc;
    int ty=dy+yc;

    if (tx>0) {
        if (snapx()!=(((tx)/snx)*snx)) ret=1;
        xc=tx;
    }
    if (ty>0) {
        if (snapy()!=(((ty)/sny)*sny)) ret=1;
        yc=ty;
    }
    return ret;
}

//----------------------------------------------------------------------------
FField::FField(char *n,int id)
       : FItem(n,id)
{
    ;
}
FField::~FField()
{
}
void FField::setup(int x,int y,int a,int c,int s,char *i,char *f)
{
    item=i;
    fmt=f;
    FItem::setup(x,y,a,c,s,0);
}
void FField::display(PForm,HDC,HFONT *,PFormText)
{
      ;
}
void NrmField::display(PForm,HDC DC,HFONT *f,PFormText)
{
    SelectObject(DC,f[size-1]);
    len=fmt.Len();
    if (selected) {
        SetTextColor(DC,SELPEN);
    } else {
        if (attr()==FF_DISP)
            SetTextColor(DC,DISPPEN);
        else
            SetTextColor(DC,FIELDPEN);
    }
    TextOut(DC,snapx(),snapy(),fmt,len);
}
void TxtField::display(PForm,HDC DC,HFONT *f,PFormText ft)
{
    SelectObject(DC,f[size-1]);
    len=ft->len(item);
    if (selected) SetTextColor(DC,SELPEN); else SetTextColor(DC,TEXTPEN);
    TextOut(DC,snapx(),snapy(),ft->str(item),len);
}
void HidNField::display(PForm,HDC,HFONT *,PFormText)
{
    len=0;
}
void HidTField::display(PForm,HDC,HFONT *,PFormText)
{
    len=0;
}
int TabField::gettbldata(PForm p,PFormText ft)
{
    char *t,tmp[130];
//    PFORMF fld=&(G_form.items[findid(tb->id)]);
    int i,l,o;

    TabLen=atoi(&((char *)fmt)[2]);
    TabType=((char *)fmt)[0];
    TabCols=((char *)fmt)[5];
    TabNumf=atoi(&((char *)fmt)[7]);

    strcpy(tmp,item);
    
    t=strtok(tmp,"~");
    l=0;
    for (i=0;i<TabNumf;i++) {
        o=p->FFindex(atoi(t));
        if (o==(-1)) return 0;
        Tflds[i]=p->items[o];
        t=strtok(NULL,"~");
        o=p->FFindex(atoi(t));
        if (o==(-1)) return 0;
        Nflds[i]=p->items[o];
        t=strtok(NULL,"~");
        Fpos[i]=l+1;
        l+=max(ft->len(Tflds[i]->item),Nflds[i]->fmt.Len())+1;
    }
    TabWid=l;
    for (i=0;i<TabNumf;i++) {
        strcpy(tmp,Nflds[i]->item);
        t=strtok(tmp,". ");
        if (i==0) Store=t;
        Fields[i]=strtok(NULL,". ");
    }
    return(1);
    
}
void TabField::display(PForm p,HDC DC,HFONT *f,PFormText ft)
{
    int i,j;
    gettbldata(p,ft);
    if (TabType=='S') {
        Rectangle(DC,snapx()+4,snapy()+7,snapx()+TabWid*snx+4,snapy()+(TabLen+3)*sny+7);
        MoveTo(DC,snapx()+4,snapy()+2*sny+7);
        LineTo(DC,snapx()+TabWid*snx+4,snapy()+2*sny+7);
        for (i=1;i<TabNumf;i++) {
            MoveTo(DC,snapx()+Fpos[i]*snx-4,snapy()+7);
            LineTo(DC,snapx()+Fpos[i]*snx-4,snapy()+(TabLen+3)*sny+7);
        }
    }
    SelectObject(DC,f[size-1]);
    if (selected) SetTextColor(DC,SELPEN); else SetTextColor(DC,TEXTPEN);
    for (i=0;i<TabNumf;i++)
        TextOut(DC,snapx()+Fpos[i]*snx,snapy()+sny,ft->str(Tflds[i]->item),ft->len(Tflds[i]->item));

    for (i=0;i<TabNumf;i++) {
        if (!selected) {
           if (Nflds[i]->attr()==FF_DISP)
               SetTextColor(DC,DISPPEN);
           else
               SetTextColor(DC,FIELDPEN);
        }
        for (j=0;j<TabLen;j++) {
            TextOut(DC,snapx()+(Fpos[i]*snx),snapy()+(j+3)*sny,Nflds[i]->fmt,Nflds[i]->fmt.Len());
        }
    }
    len=TabWid;
}
//----------------------------------------------------------------------------
int Form::FFindex(int ident)
{
    for (int i=0;i<numitem;i++) if (items[i]->id()==ident) return i;
    return -1;
}
Form::Form(char *n)
{
    name=n;
    curitem=0;
    numitem=0;
    snx=8;
    sny=14;
    lx=(-1);
    items=NULL;
}
Form::Form()
{
    curitem=0;
    numitem=0;
    snx=8;
    sny=14;
    lx=(-1);
    items=NULL;
}
Form::~Form()
{
    for (int i=0;i<numitem;i++) {
        delete items[i];
    }
}
int Form::read(int fd,HWND)
{
    Fstruct f;
    FFstruct ff;

    if (::read(fd,&f,sizeof(Fstruct))!=sizeof(Fstruct)) return 0;
    name   =f.name;
    acc    =f.access;
    xc     =f.fb.tl.x;
    yc     =f.fb.tl.y;
    wi     =f.fb.br.x-f.fb.tl.x;  if (wi==0) wi=80;
    hi     =f.fb.br.y-f.fb.tl.y;  if (hi==0) hi=24;
    type   =f.type;
    numitem=f.numitem;
    curitem=0;
    attribs=f.attribs;

    items=new PFField[numitem];
    for (int i=0;i<numitem;i++) {
        if (::read(fd,&ff,sizeof(FFstruct))!=sizeof(FFstruct)) return 0;

        if (ff.cls==FF_TEXT) {
            items[i]=new TxtField(ff.name,ff.ident);
        } else if (ff.cls==FF_TABL) {
            items[i]=new TabField(ff.name,ff.ident);
        } else if ((ff.cls&FF_TBLF)==FF_TBLF) {
            if ((ff.cls^FF_TBLF)==FF_TEXT) {
                items[i]=new HidTField(ff.name,ff.ident);
            } else {
                items[i]=new HidNField(ff.name,ff.ident);
            }
        } else {
            items[i]=new NrmField(ff.name,ff.ident);
        }
        items[i]->setup((int)ff.pos.x*snx,(int)ff.pos.y*sny,(int)ff.attrib,(int)ff.cls,(int)ff.size,ff.item,ff.fmt);
        items[i]->setsnap(snx,sny);
    }
    return 1;
}
void Form::display(HDC DC,HFONT *f,PFormText ft)
{
    char tmp[2];
    int i;
    SetTextColor(DC,BGNDPEN);
    switch (type) {
        case F_NORM :
            SelectObject(DC,f[0]);
            TextOut(DC,42*snx,0,"DAY MONTH DD, YEAR  HH:MM",25);
            break;
        case F_SERVE  :
            SelectObject(DC,f[0]);
            TextOut(DC,42*snx,0,"DAY MONTH DD, YEAR  HH:MM",25);
            Rectangle(DC,PAREA1*snx+4,PAREA2*sny+7,PAREA3*snx+4,PAREA4*sny+7);
            Rectangle(DC,TAREA1*snx+4,TAREA2*sny+7,TAREA3*snx+4,TAREA4*sny+7);
            Rectangle(DC,LAREA1*snx+4,LAREA2*sny+7,LAREA3*snx+4,LAREA4*sny+7);
            break;
        case F_PROMPT :
            SelectObject(DC,f[0]);
            TextOut(DC,42*snx,0,"DAY MONTH DD, YEAR  HH:MM",25);
            Rectangle(DC,PAREA1*snx+4,PAREA2*sny+7,PAREA3*snx+4,PAREA4*sny+7);
            break;
        case F_MENU   :
            SelectObject(DC,f[0]);
            TextOut(DC,42*snx,0,"DAY MONTH DD, YEAR  HH:MM",25);
            SelectObject(DC,f[1]);
            for (i=1;i<numitem-1;i++) {
                sprintf(tmp,"%d",i);
                TextOut(DC,0,(6+i)*sny,tmp,1);
            }
            break;
        case F_REPORT :
            break;
        case F_PPFORM  :
            break;
        default :
            ;
    }

    for (i=0;i<numitem;i++) {
        items[i]->display(this,DC,f,ft);
    }
}
int Form::Selectln(int x,int y,int type)
{
    int i;
    int oni=(-1);

    if (!type) {
        for (i=0;i<numitem;i++) {
            if (items[i]->isselected()) items[i]->setpos();
        }
        lx=(-1);
        return 0;
    }
    if (type==2) {
        if (lx==(-1)) return 0;
        oni=0;
        for (i=0;i<numitem;i++) {
            if (items[i]->isselected()) {
                if (items[i]->move(x-lx,y-ly))
                    oni=1;
            }
        }
        lx=x; ly=y;
        return oni;
    }
    lx=-1;
    for (i=0;i<numitem;i++) {
        if (items[i]->isunder(x,y)) {
           oni=i;
           break;
        }
    }

    if (oni==(-1)) {
        oni=0;
        for (i=0;i<numitem;i++) {
            if (items[i]->isselected()) {
                items[i]->select(0);
                oni=1;
            }
        }
        return oni;
    }


    if (items[oni]->isselected()) {
       items[oni]->select(0);
    } else {
       items[oni]->select(1);
    }
    lx=x; ly=y;

    return 1;
}
FormText::FormText(char *n,HWND h)
{
    FILE *fp;
    char instr[160];
    numitem=0;
    fp=fopen(n,"r");
    if (fp==NULL) {
        ::MessageBox(h,"Failed to open Text","Press OK",MB_OK|MB_ICONQUESTION);
        names=NULL;
        items=NULL;
    } else {
        while (fgets(instr,160,fp)!=NULL) numitem++;
        fseek(fp,0,SEEK_SET);
        names=new Str[numitem];
        if (names==NULL) ::MessageBox(h,"Failed to get names","Press OK",MB_OK|MB_ICONQUESTION);
        items=new Str[numitem];
        if (items==NULL) ::MessageBox(h,"Failed to get names","Press OK",MB_OK|MB_ICONQUESTION);
        int i=0;
        while (fgets(instr,160,fp)!=NULL) {    
            if (strlen(instr)>8) {
                instr[strlen(instr)-1]=0;
                instr[8]=0;
                names[i]=instr;
                items[i]=&instr[9];
                i++;
            }
        }
        fclose(fp);
    }
}
FormText::~FormText()
{
    if (names!=NULL) delete names;
    if (items!=NULL) delete items;
    numitem=0;
}
char * FormText::str(char *s)
{
    int i;
    for (i=0;i<numitem;i++) {
        if (names[i]==s) return items[i];
    }
    return NULL;
}
char * FormText::str(int idx)
{
    return items[idx];
}
int FormText::len(char *s)
{
    int i;
    for (i=0;i<numitem;i++) {
        if (names[i]==s) return items[i].Len();
    }
    return 0;
}
int FormText::len(int idx)
{
    if (idx>=numitem) return 0;
    return items[idx].Len();
}

char * FormText::operator [](int index)
{
    return items[index];
}
FormArray::FormArray(char *f,HWND h)
{
    PForm tmpf;
    int ok=1;
    int i;
    number=0;
    lastacc=0;
    Forms=new PForm[250];
    if (Forms!=NULL) numgot=250; else numgot=0;
    

    int fd=open(f,O_RDONLY|O_BINARY);
    ::read(fd,&i,sizeof(int));
    if (i!=0x5A4B) {
        lseek(fd,0,SEEK_SET);
    } else {
        lseek(fd,8,SEEK_SET);
    }

    do {
        tmpf=new Form();
        ok=tmpf->read(fd,h);
        if (ok) Add(tmpf);
    } while (ok); 
    close(fd);
}
FormArray::~FormArray()
{
    if (Forms!=NULL) {
       for (int i=0;i<number;i++) delete Forms[i];
       delete Forms;
       Forms=NULL;
    }
    number=0;
    lastacc=0;
}
char *FormArray::Name(int idx)
{
    if (idx==(-1)) idx=lastacc;
    if ((idx>=number)||(idx<0)) return "OUTRANGE";
    lastacc=idx;
    return Forms[idx]->name;
}
int FormArray::Add(PForm f)
{
    if (number==numgot) return 0;
    Forms[number++]=f;
    return number;
}
void FormArray::display(HDC DC,HFONT *f,PFormText ft,int idx)
{
    if (idx==(-1)) idx=lastacc;
    if ((idx>=number)||(idx<0)) return;
    lastacc=idx;
    Forms[idx]->display(DC,f,ft);
}
void FormArray::SetType(int t)
{
    Forms[lastacc]->SetType(t);
}
void FormArray::Selectln(int x,int y,int type,HWND win)
{
    if (Forms[lastacc]->Selectln(x,y,type))
        ::InvalidateRect(win,NULL,1);
}
