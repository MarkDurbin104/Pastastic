#define FRDSCR_C
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <search.h>
#include <conio.h>
#include <alloc.h>
#include <graphics.h>
#include <io.h>
#include <ctype.h>
#include <fcntl.h>

#include "types.h"
#include "control.h"
#include "formhand.h"
#include "dst.h"
#include "config.h"
#include "win.h"
#include "frdscr.h"
#include "frdwin.h"
#include "frdgfx.h"

int scmp(const void *a,const void *b)
{
    return(strcmp(*((CHAR **)a),*((CHAR **)b)));
}
void formbg(void)
{
    INT i,ox,oy;
//    FORMF *f;
    G_snapoff=0;
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);

    if (G_form.type==F_NORM) {
        outxy(G_scrx+46*G_fntw-(G_formx*G_fntw),G_scry-(G_formy*G_fnth),7,0,"%s",datestr(0));
    } else if (G_form.type==F_SERVE) {
        drawbox(G_parea[0],G_parea[1],G_parea[2],G_parea[3],(-1));
        drawbox(G_tarea[0],G_tarea[1],G_tarea[2],G_tarea[3],(-1));
        drawbox(G_larea[0],G_larea[1],G_larea[2],G_larea[3],(-1));
        outxy(G_scrx+46*G_fntw-(G_formx*G_fntw),G_scry-(G_formy*G_fnth),7,0,"%s",datestr(0));
    } else if (G_form.type==F_PROMPT) {
        drawbox(G_parea[0],G_parea[1],G_parea[2],G_parea[3],(-1));
        outxy(G_scrx+46*G_fntw-(G_formx*G_fntw),G_scry-(G_formy*G_fnth),7,0,"%s",datestr(0));
    } else if (G_form.type==F_MENU) {
        for (i=1;i<(G_form.numitem-1);i++) 
            outxy(G_scrx-(G_formx*G_fntw),G_scry+(6+i)*G_fnth-(G_formy*G_fnth),7,1,"%d",i%10);
        outxy(G_scrx+46*G_fntw-(G_formx*G_fntw),G_scry-(G_formy*G_fnth),7,0,"%s",datestr(0));
    } else if (G_form.type==F_PPFORM) {
		ox=(G_formx*G_fntw)%6;
		oy=(G_formy*G_fnth)%12;
        for (i=((G_formx*G_fntw)-ox);i<(G_scrw*G_fntw)+((G_formx*G_fntw)-ox);i+=12) {
	        setcolor(11-8*(((i-ox)%60)==0));
            if (!((i-ox)%120)) setcolor(1);
            line((i-((G_formx*G_fntw)-ox))+ox,0,(i-((G_formx*G_fntw)-ox))+ox,G_scrh*G_fnth);
        }
        for (i=((G_formy*G_fnth)-oy);i<(G_scrh*G_fnth)+((G_formy*G_fnth)-oy);i+=24) {
	        setcolor(11-8*(((i-oy)%60)==0));
            if (!((i-ox)%240)) setcolor(1);
            line(0,(i-((G_formy*G_fnth)-oy))+oy,G_scrw*G_fntw,(i-((G_formy*G_fnth)-oy))+oy);
        }
    }
    setvp(0,0,G_maxx,G_maxy);
}
// get a text string for display
CHAR *textstr(PFORMF fld)
{
	CHAR **s;
    CHAR *tmp=fld->item;

    s=(CHAR **)bsearch(&tmp,G_tname,G_tcnt,sizeof(CHAR *),scmp);
    if (s==NULL) return(fld->item);
    return(G_text[s-G_tname]);    
}
INT findid(INT id)
{
    INT i;
    for (i=0;i<G_form.numitem;i++) {
        if (G_form.items[i].ident==id) return(i);
    }
    return(-1);
}
INT nextid(void)
{
    INT i=0;
    while (findid(i)!=(-1)) i++;
    return(i);
}
INT gettabledata(PTABDAT tb)
{
    CHAR *t,tmp[130];
    PFORMF fld=&(G_form.items[findid(tb->id)]);
    INT i,l;

    tb->pos.x=fld->pos.x;
    tb->pos.y=fld->pos.y;
    tb->depth=atoi(&(fld->fmt[2]));
    tb->type=fld->fmt[0];
    tb->cols=fld->fmt[5];
    tb->numf=atoi(&(fld->fmt[7]));
    for (i=0;i<tb->cols;i++) tb->cd[i]=fld->fmt[9+i];
    strcpy(tmp,fld->item);
    t=strtok(tmp,"~");
    l=0;
    for (i=0;i<tb->numf;i++) {
		if (isdigit(*t)) {
	        tb->tid[i]=findid(atoi(t));
		} else {
	        tb->tid[i]=findid(*t-'A');
		}
        if (tb->tid[i]==(-1)) return(0);
        t=strtok(NULL,"~");
		if (isdigit(*t)) {
	        tb->fid[i]=findid(atoi(t));
		} else {
	        tb->fid[i]=findid(*t-'A');
		}
        if (tb->fid[i]==(-1)) return(0);
        t=strtok(NULL,"~");
        tb->fwid[i]=max(strlen(textstr(&(G_form.items[tb->tid[i]]))),strlen(G_form.items[tb->fid[i]].fmt));
        l+=tb->fwid[i]+1;
    }
    tb->width=l;
    for (i=0;i<tb->numf;i++) {
        strcpy(tmp,G_form.items[tb->fid[i]].item);
        strcpy(tb->sn,strtok(tmp,". "));
        strcpy(tb->fn[i],strtok(NULL,". "));
    }
    return(1);
}
void square(INT x,INT y,INT x1,INT y1)
{
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);
    rectangle(x,y,x1,y1);
    setvp(0,0,G_maxx,G_maxy);
}
void tablebdr(PTABDAT tb,INT col,INT xpos,INT ypos)
{
    INT i,j;
    INT ofs,x,y,x1,y1;
    x=tb->pos.x;
    y=tb->pos.y;
    if (col!=(-1)) {
        x+=xpos;
        y+=ypos;
    }
    x1=x+tb->width;
    y1=y+tb->depth+3;
    for (j=0;j<tb->cols;j++) {
        if (tb->cols>1) {
            y1=y+tb->cd[j]+3;
        }
        drawbox(x,y,x1,y1,col);
        ofs=x;
        drawline(x,y+2,x1,y+2,col);
        for (i=0;i<tb->numf-1;i++) {
            ofs+=tb->fwid[i]+1;
            drawline(ofs,y,ofs,y1,col);
        }
        ofs+=tb->fwid[i]+1;
        ofs-=x;
        x+=ofs;
        x1+=ofs;
    }
}
void disptable(PTABDAT tb,INT col,INT xpos,INT ypos)
{
    INT l,i,k,j,d;
    INT x=tb->pos.x;
    INT y=tb->pos.y;
    INT c=15;

    if (col!=(-1)) { c=col; x+=xpos; y+=ypos; }
    
    if (tb->type=='S') {
        tablebdr(tb,col,xpos,ypos);
    }
    x-=G_formx; y-=G_formy;
    if (tb->type=='N') {
        x-=1; y-=3;
    } else {
        l=1;
        for (k=0;k<tb->cols;k++) {
            for (i=0;i<tb->numf;i++) {
                outxy(G_scrx+(x+l)*G_fntw,
                    G_scry+(y+1)*G_fnth,
                    c|(0x20*G_snapoff),0,"%-*.*s",tb->fwid[i],tb->fwid[i],
                    textstr(&(G_form.items[tb->tid[i]])));
                l+=tb->fwid[i]+1;
            }
        }
    }
    l=1;
    if (col==(-1)) c=1;
    if ((tb->type=='N')||(tb->type=='T')) {
        for (k=0;k<tb->cols;k++) {
            for (i=0;i<tb->numf;i++) {
                if (tb->cols>1) d=tb->cd[k]; else d=tb->depth;
                for (j=0;j<d;j++) {
                    outxy(G_scrx+(x+l)*G_fntw,
                        G_scry+(y+3+j)*G_fnth,
                        c|(0x20*G_snapoff),0,"%-*.*s",tb->fwid[i],tb->fwid[i],
                        G_form.items[tb->fid[i]].fmt);
                }
                l+=tb->fwid[i]+1;
            }
        }
    } else {
        for (k=0;k<tb->cols;k++) {
            for (i=0;i<tb->numf;i++) {
                outxy(G_scrx+(x+l)*G_fntw,
                    G_scry+(y+3)*G_fnth,
                    c|(0x20*G_snapoff),0,"%-*.*s",tb->fwid[i],tb->fwid[i],
                    G_form.items[tb->fid[i]].fmt);
                l+=tb->fwid[i]+1;
            }
        }
    }
}
CHAR *itemtext(INT i)
{
    FORMF *f;
    static CHAR selstr[160];

    f=&(G_form.items[i]);
    if (!(f->class&FF_TBLF)) {
        if (f->class==FF_TABL) {
            return(NULL);
        }
        else {
            if (f->class==FF_TEXT) {
                strcpy(selstr,textstr(f));
            }
            else {
                strcpy(selstr,f->fmt);
            }
            return(selstr);
        }
	}
	return(NULL);
}
void dispitem(INT i,INT col,INT xpos,INT ypos)
{
	TABDAT tb;
	FORMF *f;
	INT s,x,y,c;
	CHAR *selstr;
    if ((i<0)||(i>=G_form.numitem)) return;
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);
    f=&(G_form.items[i]);
    if ((f != NULL) && (G_form.items != NULL))
    {
        if (!(f->class&FF_TBLF)) {
            if (f->class==FF_TABL) {
                tb.id=f->ident;
                if (gettabledata(&tb)) disptable(&tb,col,xpos,ypos);
            }
            else {
			    if (f->class==FF_TEXT) {
                    selstr=textstr(f);
                    c=15;
                }
                else {
                    if ((f->class!=FF_TABL)
                        && (f->class!=FF_DISP)
                        && ((f->class&FF_TBLF)==0)) c=1; else c=2;
                    selstr=f->fmt;
                }
                x=f->pos.x-G_formx;
                y=f->pos.y-G_formy;
                s=f->size-1;
                if (col!=(-1)) { c=col; x+=xpos; y+=ypos; }
                outxy(G_scrx+x*G_fntw,G_scry+y*G_fnth,c|(0x20*G_snapoff),s,"%s",selstr);
            }
        }
    }
    setvp(0,0,G_maxx,G_maxy);
}
void dispform(void)
{
    INT i;
    formbg();
    for (i=0;i<G_form.numitem;i++) {
        dispitem(i,-1,0,0);
    }
    G_fillbuf=0;
}
INT onitem(INT x,INT y)
{
    INT i,l,h,d,j;
    FORMF *f;
    TABDAT tb;
    x+=G_formx;
    y+=G_formy;
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if ((f != NULL) && (G_form.items != NULL)) {
            if (!(f->class&FF_TBLF)) {
                if (f->class==FF_TABL) {
                    tb.id=f->ident;
                    if (gettabledata(&tb)) {
                        d=tb.width*tb.cols;
                        if (tb.cols==1) {
                            if ((x>=tb.pos.x+d)
                            && (y>=tb.pos.y)
                            && (x<tb.pos.x+d+2)
                            && (y<tb.pos.y+tb.depth+3)) return(i+1001);
                            if ((x>=tb.pos.x)
                            && (y>=tb.pos.y)
                            && (x<tb.pos.x+d)
                            && (y<tb.pos.y+tb.depth+3)) return(i+1);
                            if ((x>=tb.pos.x)
                            && (y>=tb.pos.y)
                            && (x<tb.pos.x+tb.width)
                            && (y<=tb.pos.y+tb.depth+3)) return(i+2001);
                        } else {
                            if ((x>=tb.pos.x+d)
                            && (y>=tb.pos.y)
                            && (x<tb.pos.x+d+2)
                            && (y<tb.pos.y+tb.cd[tb.cols-1]+3)) return(i+1001);
                            for (j=0;j<tb.cols;j++) {
                                if ((x>=tb.pos.x)
                                && (y>=tb.pos.y)
                                && (x<tb.pos.x+d)
                                && (y<tb.pos.y+tb.cd[j]+2)) return(i+1);
                                if ((x>=tb.pos.x+tb.width*j)
                                && (y>=tb.pos.y)
                                && (x<tb.pos.x+tb.width*(j+1))
                                && (y<=tb.pos.y+tb.cd[j]+4)) return(i+2001+(j*1000));
                            }
                        }
                    }
                }
                else {
                    if (f->class==FF_TEXT) {
                        l=strlen(textstr(f))-1;
                    } else {
                        l=strlen(f->fmt)-1;
                    }
                    if (f->size>1) { l*=2; l++; }
                    if (f->size==3) h=1; else h=0;
                    if ((y>=f->pos.y)
                    && (y<=f->pos.y+h)
                    && (x>=f->pos.x)
                    && (x<=f->pos.x+l))
                        return(i+1);
                }
            }
        }
    }
    return(0);
}
INT iteminbox(INT i,INT x,INT y,INT x1,INT y1)
{
    INT l,h;
    FORMF *f;
    TABDAT tb;
    INT ix,iy,ix1,iy1;
    x+=G_formx; x1+=G_formx;
    y+=G_formy; y1+=G_formy;
    if (x>x1) { l=x; x=x1; x1=l; }
    if (y>y1) { l=y; y=y1; y1=l; }

    f=&(G_form.items[i]);

    if (!(f->class&FF_TBLF)) {
        if (f->class==FF_TABL) {
            tb.id=f->ident;
            if (gettabledata(&tb)) {
                ix=tb.pos.x;
                iy=tb.pos.y;
                ix1=tb.pos.x+tb.width;
                iy1=tb.pos.y+tb.depth+3;
            }
        }
        else {
            if (f->class==FF_TEXT) {
                l=strlen(textstr(f))-1;
            } else {
                l=strlen(f->fmt)-1;
            }
            if (f->size>1) { l*=2; l++; }
            if (f->size==3) h=1; else h=0;

            ix=f->pos.x; ix1=f->pos.x+l;
            iy=f->pos.y; iy1=f->pos.y+h;
        }
        if ((((ix>=x)&&(ix<=x1))||((ix1>=x)&&(ix1<=x1))||((ix<x)&&(ix1>x1)))
         && (((iy>=y)&&(iy<=y1))||((iy1>=y)&&(iy1<=y1))||((iy<y)&&(iy1>y1))))
            return(1);
    }
    return(0);
}
INT itemselected(INT item)
{
    INT i;
    for (i=0;i<G_numsel;i++) if (G_sel[i]==item) return(1);
    return(0);
}
void selectfmitem(INT item)
{
    if (itemselected(item)) return;
    G_sel[G_numsel++]=item;
    dispitem(item,0,0,0);
    dispitem(item,20,0,0);
    cutavail(1);
    if (G_numsel==1) {
        fldattr(1,G_sel[0]);
    }
}
void selectitem(INT item)
{
    if (itemselected(item)) return;
    G_sel[G_numsel++]=item;
    dispitem(item,0,0,0);
    dispitem(item,20,0,0);
    cutavail(1);
    if (G_numsel==1) {
        if (G_form.items[G_sel[0]].class!=FF_TABL)
            fldattr(2,G_sel[0]);
        else
            fldattr(1,G_sel[0]);
    } else if (G_numsel==2) {
        fldattr(1,G_sel[0]);
    }
}
void selectitems(INT x,INT y,INT x1,INT y1)
{
    INT i;
    for (i=0;i<G_form.numitem;i++) {
        if (iteminbox(i,x,y,x1,y1)) {
            if (!itemselected(i)) {
                G_sel[G_numsel++]=i;
                dispitem(i,0,0,0);
                dispitem(i,20,0,0);
            }
        }
    }
    if (G_numsel) {
        cutavail(1);
        if (G_numsel==1) fldattr(2,G_sel[0]); else fldattr(1,G_sel[0]);
    }
}
void moveitems(INT mx,INT my)
{
    INT i,j;
    PFORMF f;
    if (((mx)||(my))&&(G_numsel)) {
        modified();
        for (i=0;i<G_numsel;i++) {
            f=&(G_form.items[G_sel[i]]);
            dispitem(G_sel[i],20,0,0);

            j=f->pos.x; j+=mx;
            if (j<0) f->pos.x=0; else f->pos.x=j;
            j=f->pos.y; j+=my;
            if (j<0) f->pos.y=0; else f->pos.y=j;

            dispitem(G_sel[i],20,0,0);
        }
    }
//  Modify the scr pos if off bottom/top/left or right
//  scrsbf(G_scrrsb,1,G_formy+1); // down
//  scrsbf(G_scrrsb,1,G_formy-1); // up
//  scrsbf(G_scrbsb,1,G_formx+1); // right
//  scrsbf(G_scrbsb,1,G_formx-1); // left
}
void deselectitems(void)
{
    INT i;
    if (G_numsel<1) return;
    fldattr(0,G_sel[0]);
    for (i=0;i<G_numsel;i++) dispitem(G_sel[i],-1,0,0);
    G_numsel=0;
    cutavail(0);
}




