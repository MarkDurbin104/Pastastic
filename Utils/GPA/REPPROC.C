//SYSDOC REPPROC.CMT
#define REPPROC_C

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>

#include "types.h"
#include "config.h"
#include "scaledev.h"
#include "message.h"
#include "fldproc.h"
#include "formproc.h"
#include "tabproc.h"
#include "formhand.h"
#include "dst.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "money.h"
#include "repproc.h"

TABDAT *G_tbs=NULL;
INT    G_toprec[10];
INT		G_suppress=0;
extern INT G_pnr;

void loadpffld(INT id)
{
    CHAR sn[10],fn[10],tmp[20],*t;
    PFORMF f;
	ENTRY(3140);

    f=&(G_form.items[id]);

    if (f->item!=NULL) {
        strcpy(tmp,f->item);
        t=strtok(tmp,". ");
        if (t!=NULL) {
            strcpy(sn,t);
            t=strtok(NULL,". ");
            if (t!=NULL) {
                strcpy(fn,t);
                sendmsg("DBM",MESSAGE_g,sn,fn,G_formvars[id]);
            }
        }
    }

    if ((f->class==FF_OPTI)&&(G_fixed[0]!=0)) strcpy(G_formvars[id],G_fixed);

    switch (f->fmt[0]) {
        case 'T' :
            if ((G_formvars[id][0]==0)||(G_formvars[id][0]==' ')) {
                strcpy(G_formvars[id],datestr(MINTIME));
                G_formvars[id][6]=0;
            }
            break;
        case 'D' :
            if ((G_formvars[id][0]==0)||(G_formvars[id][0]==' '))
                strcpy(G_formvars[id],datestr(MINDATE));
            break;
    }
	RETURN;
}
// fill the form from the form field variables
void fillpform(PFORM f)
{
    INT i;
    PFORMF ff;
	ENTRY(3150);

    for (i=0;i<f->numitem;i++) {
        ff=&(f->items[i]);
        if ((ff->class!=FF_TEXT)
        &&  (ff->class!=FF_TABL)
        &&  ((ff->class&FF_TBLF)==0)) {
            if ((ff->class!=FF_DISP)||(ff->class!=FF_WAIT)||(i>f->curitem))
                loadpffld(i);
            if (((ff->class==FF_SRCH)
              || (ff->class==FF_SECS)
              || (ff->class==FF_MSRH)
              || (ff->class==FF_MSEC)
              || (ff->class==FF_MAND))
            &&  (i>f->curitem))
                break;
        }
    }
	RETURN;
}
// output a field on the printer
void poutput(INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size,INT attr)
{
    CHAR tmp[80];
    INT i,t;
	ENTRY(3160);

	if (l==0) {
		l=strlen(fmt);
		t=fmt[0];
		for (i=1;i<l;i++) if (t!=fmt[i]) { t='Q'; break; }
	} else {
		t=fmt[0];
	}
    sendmsg("OUTPUT2",MESSAGE_S,size);
    sendmsg("OUTPUT2",MESSAGE_A,attr);
    switch (t) {
        case 'K' :
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%-*.*s",l,l,keyname(atoi(s)));
            break;

        case 'M' :
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%s",mstr(s,l));
            break;

        case 'D' :
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%s",dstr(s,l));
            break;

        case 'T' :
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%s",tstr(s,l));
            break;

        case 'W' :
            if (G_scaleact) {
                i=(INT)sendmsg("SCALE",MESSAGE_i);
                if (i>=0) {
                    sprintf(tmp,"%d",i);
                }
                else {      
                    strcpy(tmp,s);
                }
            }
            else {      
                strcpy(tmp,s);
            }
            sendmsg("OUTPUT2",MESSAGE_o,x,y,formatstr(tmp,G_weightf,l));
            break;

        case 'P' :
            for (i=0;i<strlen(s);i++) tmp[i]='*';
            tmp[i]=0;
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%-*.*s",l,l,tmp);
            break;

        case 'Q' :
			strcpy(tmp,applyformat(s,fmt,0));
			if (strlen(tmp)>l) tmp[l]=0;
           	sendmsg("OUTPUT2",MESSAGE_o,x,y,"%-*.*s",l,l,tmp);
            break;

        default :
            sendmsg("OUTPUT2",MESSAGE_o,x,y,"%-*.*s",l,l,s);
    }
	RETURN;
}
// draw the border/background for a table
void tablepbdr(PTABDAT tb)
{
    INT i,j,l;
    INT ofs,x,y,x1,y1;
	ENTRY(3170);
                                                 
    if (tb->type=='N') return;
    x=tb->pos.x;
    y=tb->pos.y;
    x1=tb->pos.x+tb->width;
    y1=tb->pos.y+tb->depth+3;

    if ((tb->type=='S')||(tb->type=='B')) {
        for (j=0;j<tb->cols;j++) {
            if (tb->cols>1) {
                y1=y+tb->cd[j]+3;
            }
            ofs=x;
            if (tb->type=='B') {
                sendmsg("OUTPUT2",MESSAGE_B,x,y,x1,y1-2);
                for (i=0;i<tb->numf-1;i++) {
                    ofs+=tb->fwid[i]+1;
                    sendmsg("OUTPUT2",MESSAGE_L,ofs,y,ofs,y1-2);
                }
            } else {
                sendmsg("OUTPUT2",MESSAGE_B,x,y,x1,y1);
                sendmsg("OUTPUT2",MESSAGE_L,x,y+2,x1,y+2);
                for (i=0;i<tb->numf-1;i++) {
                    ofs+=tb->fwid[i]+1;
                    sendmsg("OUTPUT2",MESSAGE_L,ofs,y,ofs,y1);
                    sendmsg("OUTPUT2",MESSAGE_L,ofs,y+2,ofs,y+2);
                }
            }
            ofs+=tb->fwid[i]+1;
            ofs-=x;
            x+=ofs;
            x1+=ofs;
        }
    }
    l=1;
    if (tb->type!='B') {
        for (j=0;j<tb->cols;j++) {
            for (i=0;i<tb->numf;i++) {
                sendmsg("OUTPUT2",MESSAGE_TEXT,tb->pos.x+l,tb->pos.y+1,G_form.items[tb->tid[i]].item);
                l+=tb->fwid[i]+1;
            }
        }
    }
	RETURN;
}
// redraw the table contents
void printtab(PTABDAT tb,INT top)
{
    PFORMF fldp;
    CHAR tmp[80];
    static CHAR fmt[80];
    INT l,ofs,i,j,k,res,d,m=0;
    INT xo=1,yo=1;
    INT xm=1,ym=1;
    INT x,y;
	ENTRY(3180);
    
	if ((G_form.type!=F_REPORT)&&((G_spacingx!=0)||(G_spacingy!=0))) {
		sendmsg("OUTPUT2",MESSAGE_MS,1,1);
        xo=G_spacingx*3;
        yo=G_spacingy;
        xm=3;
        ym=9;
        if (xo<=0) xo=1;
        if (yo<=0) yo=1;
    }
    if (tb->type=='N') {
        l=0;
        x=tb->pos.x*xm;
        if (x<0) x=0;
        y=tb->pos.y*ym;
        if (y<0) y=0;
    } else if (tb->type=='B') {
        l=1;
        x=(tb->pos.x*xm);
        y=(tb->pos.y+1)*ym;
        if (y<0) y=0;
    } else {
        l=1;
        x=(tb->pos.x*xm);
        y=((tb->pos.y+3)*ym);
    }
	res=readrecnum(tb->sn,top+1);
    for (k=0;k<tb->cols;k++) {
        ofs=l;
        if (tb->cols>1) d=tb->cd[k]; else d=tb->depth;
        for (j=1;j<=d;j++) {
            l=ofs;
            if (res) {
                for (i=0;i<tb->numf;i++) {
                    fldp=&(G_form.items[tb->fid[i]]);
                    getflddata(tb,i,tmp);
                    strcpy((CHAR *)fmt,fldp->fmt);
    				if (fldp->size==1) fmt[tb->fwid[i]]=0; else fmt[tb->fwid[i]/2]=0;
                    poutput(x+(l*xo)+(k*G_tbspace),y+(((j-1)+m)*yo),tmp,0,(CHAR *)fmt,fldp->size,fldp->attrib);
                    l+=tb->fwid[i]+1;
                }
                top++;
				res=readrecnum(tb->sn,top+1);
            }
        }
        if (G_fudgeit) m++;
    }
    if (G_form.type!=F_REPORT) sendmsg("OUTPUT2",MESSAGE_MS,3,9);
	RETURN;
}
// calculate the table contents
void calctab(PTABDAT tb,INT top)
{
    CHAR tmp[80];
    INT i,j,k,res,d;
	ENTRY(3185);
    
	res=readrecnum(tb->sn,top+1);
    for (k=0;k<tb->cols;k++) {
        if (tb->cols>1) d=tb->cd[k]; else d=tb->depth;
        for (j=1;j<=d;j++) {
            if (res) {
                for (i=0;i<tb->numf;i++) {
                    getflddata(tb,i,tmp);
                }
                top++;
				res=readrecnum(tb->sn,top+1);
            }
        }
    }
	RETURN;
}
void tableoutput(INT id)
{
    INT k;
	ENTRY(3190);
    if (!G_suppress) {
	    tablepbdr(&G_tbs[id]);
	    printtab(&G_tbs[id],G_toprec[id]);
	} else {
	    calctab(&G_tbs[id],G_toprec[id]);
    }
    if (G_tbs[id].cols>1) { 
        for (k=0;k<G_tbs[id].cols;k++) G_toprec[id]+=G_tbs[id].cd[k];
    } else {
        G_toprec[id]+=G_tbs[id].depth;
    }
	RETURN;
}
INT dopage(INT nt)
{
    PFORMF f;
    INT searchit=0;
    UINT i;
    INT j,runit=0;
	ENTRY(3195);
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if (f->fmt[0]=='W') G_scaleact=(sendmsg("SCALE",MESSAGE_i)>=0);
    }
	if (G_form.type!=F_REPORT) sendmsg("OUTPUT2",MESSAGE_MS,3,9);
    for (G_form.curitem=0;G_form.curitem<G_form.numitem;G_form.curitem++) {
		i=G_form.curitem;
        f=&(G_form.items[G_form.curitem]);
        searchit=0;
        switch (f->class) {
            case FF_TEXT :
			    if (!G_suppress) {
     	            sendmsg("OUTPUT2",MESSAGE_A,f->attrib);
	                sendmsg("OUTPUT2",MESSAGE_S,f->size);
	                sendmsg("OUTPUT2",MESSAGE_TEXT,f->pos.x,f->pos.y,f->item);
				}
                runit=1;
                break;
            case FF_SECS : case FF_SRCH : case FF_MSEC : case FF_MSRH :
                searchit=1;
            case FF_WAIT : case FF_MAND : case FF_OPTI : case FF_DISP :
			    if (!G_suppress) {
	                poutput(f->pos.x,f->pos.y,G_formvars[G_form.curitem],0,f->fmt,f->size,f->attrib);
				}
                runit=1;
                break;
            case FF_TABL :
                for (j=0;j<nt;j++) {
                    if (G_tbs[j].id==G_form.curitem) {
                        G_intable=1;
                        runaction(f->func);
                        tableoutput(j);
                        G_intable=0;
                        j=nt;
                    }
                }
                runit=0;
                break;
            default:
                runit=0;
        }
        if (searchit) srchitem(f);
        if (runit) runaction(f->func);
        fillpform(&G_form);
		G_form.curitem=i;
    }
    if (!G_suppress) {
        for (G_form.curitem=0;G_form.curitem<G_form.numitem;G_form.curitem++) {
            f=&(G_form.items[G_form.curitem]);
            switch (f->class) {
                case FF_SECS : case FF_SRCH : case FF_MSEC : case FF_MSRH :
                case FF_WAIT : case FF_MAND : case FF_OPTI : case FF_DISP :
                    poutput(f->pos.x,f->pos.y,G_formvars[G_form.curitem],0,f->fmt,f->size,f->attrib);
                    break;
            }
		}
        sendmsg("OUTPUT2",MESSAGE_MS,0,0);
	    if (!sendmsg("OUTPUT2",MESSAGE_F)) RETURNV(0);
    }
    RETURNV(1);
}
// process a form input and output
INT runreport(void) 
{
    PFORMF f;
    INT i=0,nt=0,d,k;
    INT numrec=0,numpage;
	ENTRY(3200);

	G_pnr=(-100);
	
	if (G_tbs==NULL) G_tbs=MALLOC(10*sizeof(TABDAT));
	if (G_tbs==NULL) RETURNV(0);

    if (G_form.type==F_REPORT)
		sendmsg("OUTPUT2",MESSAGE_SP,1,1);
	else
		sendmsg("OUTPUT2",MESSAGE_SP,1,0);

    sendmsg("OUTPUT2",MESSAGE_MS,0,0);
    sendmsg("OUTPUT2",MESSAGE_b,G_form.bounds.br.x-G_form.bounds.tl.x,G_form.bounds.br.y-G_form.bounds.tl.y);
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if (f->class==FF_TABL) {
            G_tbs[nt].id=i;
            if (gettabledata(&G_tbs[nt])) {
                numrec=getnumrec(G_tbs[nt].sn);
                if (G_tbs[nt].cols>1) {
                    d=0;
                    for (k=0;k<G_tbs[nt].cols;k++) d+=G_tbs[nt].cd[k];
                } else {
                    d=G_tbs[nt].depth;
                }
                numpage=numrec/d;
                if (numrec%d) numpage++;
                if (G_numpage<numpage) G_numpage=numpage;
                G_toprec[nt]=0;
                nt++;
            }
        }
    }
    if (G_pagenum==0) {
        for (G_pagenum=1;G_pagenum<=G_numpage;G_pagenum++) {
            if (!dopage(nt)) break;
        }
    } else {
		if (G_pagenum<0) {
			d=0-G_pagenum;
	        for (G_pagenum=1;G_pagenum<=G_numpage;G_pagenum++) {
				if (G_pagenum==d) G_suppress=0; else G_suppress=1;
	            if (!dopage(nt)) break;
	        }
		} else {
        	for (i=0;i<nt;i++) {
                if (G_tbs[nt].cols>1) {
                    d=G_tbs[nt].depth;
                } else {
                    d=0;
                    for (k=0;k<G_tbs[nt].cols;k++) d+=G_tbs[nt].cd[k];
                }
            	G_toprec[i]=d*(G_pagenum-1);
        	}
        	dopage(nt);
		}
    }

	if (G_tbs!=NULL) FREE(G_tbs);
	G_tbs=NULL;
    G_pagenum=0;
    G_numpage=1;
	G_suppress=0;
	sendmsg("OUTPUT2",MESSAGE_SP,0,1);
    RETURNV(1);
}

