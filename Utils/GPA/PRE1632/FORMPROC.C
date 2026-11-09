#define FORMPROC_C

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>

#include "types.h"
#include "keydef.h"
#include "kbddev.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "menuproc.h"
#include "fldproc.h"
#include "tabproc.h"
#include "translog.h"
#include "formhand.h"
#include "dst.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "repproc.h"
#include "lang.h"


void prformname(PFORM f)
{
	ENTRY(2720);
	sendmsg("OUTPUT1",'tt',14,73,1,f->name);
	RETURN;
}
void prformref(PFORMF f)
{
	INT s=1+1*(f->size>1);
	CHAR *i=f->item,*a=f->func;
	INT lf=strlen(f->fmt);
	INT yo=0;
	INT lt=strlen(textstr(f));
	ENTRY(2730);
	if ((!strncmp(a,"NONE",4))||(*a==0)) a=NULL;
	if ((!strncmp(i,"NONE",4))||(*i==0)) i=NULL;
    if (f->class==FF_TEXT) {
		if (a!=NULL) sendmsg("OUTPUT1",'tt',1,f->pos.x+lt*s,f->pos.y,a);
    }
    else {
        if ((f->class&FF_TBLF)==0) {
	        if (f->class!=FF_DISP) lf++;
	        if (f->class==FF_TABL) yo--;
			if (a!=NULL) sendmsg("OUTPUT1",'tt',1,f->pos.x+lf*s,f->pos.y+yo,a);
			if (i!=NULL) sendmsg("OUTPUT1",'tt',4,f->pos.x+lf*s+6,f->pos.y+yo,i);
		}
    }
	RETURN;
}
// get a text string for display
CHAR *textstr(PFORMF fld)
{
	ENTRY(2750);
    RETURNV(langstr("OUTPUT1",fld->item));    
}
void remtspace(UCHAR *s)
{
	CHAR *t;
	ENTRY(2760);
	t=(CHAR *)s+strlen((CHAR *)s)-1;
	while (((*t==' ')||(*t==0))&&(t!=(CHAR *)s)) *(t--)=0;
	RETURN;
}
// load the form fields from the datastores / system variables
void loadffld(INT id)
{
    CHAR sn[10],fn[10],tmp[20];
    PFORMF f;
    INT tft;
	ENTRY(2770);

    tft=G_form.type;
    f=&(G_form.items[id]);

    if (f->item!=NULL) {
        strcpy(tmp,f->item);
        strcpy(sn,strtok(tmp,". "));
        strcpy(fn,strtok(NULL,". "));
    
        sendmsg("DBM",'g',sn,fn,G_formvars[id]);
        sendmsg("OUTPUT1",'A',f->attrib);
        sendmsg("OUTPUT1",'S',f->size);
    }

    G_form.type=0;

    if ((f->fmt[0]=='M')&&(f->class==FF_OPTI)&&(G_fixed[0]!=0))
		strcpy(G_formvars[id],G_fixed);

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
        default :
			remtspace((UCHAR *)G_formvars[id]);
    }
    output(f->pos.x,f->pos.y,G_formvars[id],0,f->fmt,f->size);
    G_form.type=tft;
	RETURN;
}
// initialise the form field variables
INT initform(PFORM f)
{
    INT i,j;
    PFORMF ff;
    CHAR tmp[81];
	ENTRY(2780);

    clrform(f);
    G_formvars=MALLOC(f->numitem*sizeof(CHAR *));
    if (G_formvars==NULL) RETURNV(0);

    for (i=0;i<f->numitem;i++) G_formvars[i]=NULL;

    for (i=0;i<f->numitem;i++) {
        ff=&(f->items[i]);
        if (ff->class!=FF_TEXT) {
			if ((j=isaction(ff->name))<0) {
                strcpy(tmp,getvarib((0-j)-1));
                G_formvars[i]=setvarib((0-j)-1,tmp);
			} else {
            	G_formvars[i]=MALLOC(81);
            	if (G_formvars[i]==NULL) RETURNV(0);
            	G_formvars[i][0]=0;
			}
        } else {
            G_formvars[i]=MALLOC(4);
            if (G_formvars[i]==NULL) RETURNV(0);
            G_formvars[i][0]='0';
            G_formvars[i][1]=0;
		}
    }
    RETURNV(1);
}
// fill the form from the form field variables
void fillform(PFORM f)
{
    INT i;
    PFORMF ff;
	ENTRY(2790);

	for (i=0;i<f->numitem;i++) {
        ff=&(f->items[i]);
        if ((ff->class!=FF_TEXT)
        &&  (ff->class!=FF_TABL)
        &&  ((ff->class&FF_TBLF)==0)) {
            if ((ff->class!=FF_DISP)||(ff->class!=FF_WAIT)||(i>f->curitem))
                loadffld(i);
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
void fillfields(PFORM f)
{
    CHAR sn[10],fn[10],tmp[20];
	INT i;
    PFORMF ff;
    INT tft;
	ENTRY(2800);

    tft=G_form.type;

    G_form.type=0;

    for (i=0;i<f->numitem;i++) {
        ff=&(f->items[i]);
        if ((ff->class!=FF_TEXT)
        &&  (ff->class!=FF_TABL)
        &&  ((ff->class&FF_TBLF)==0)) {
    		if (ff->item!=NULL) {
        		strcpy(tmp,ff->item);
        		strcpy(sn,strtok(tmp,". "));
        		strcpy(fn,strtok(NULL,". "));
        		sendmsg("DBM",'g',sn,fn,G_formvars[i]);
    		}
    		switch (ff->fmt[0]) {
        		case 'T' :
            		if ((G_formvars[i][0]==0)||(G_formvars[i][0]==' ')) {
                		strcpy(G_formvars[i],datestr(MINTIME));
                		G_formvars[i][6]=0;
            		}
            		break;
        		case 'D' :
            		if ((G_formvars[i][0]==0)||(G_formvars[i][0]==' ')) {
                		strcpy(G_formvars[i],datestr(MINDATE));
                		G_formvars[i][6]=0;
					}
            		break;
        		default :
					remtspace((UCHAR *)G_formvars[i]);
    		}
	        sendmsg("OUTPUT1",'A',ff->attrib);
       		output(ff->pos.x,ff->pos.y,G_formvars[i],0,ff->fmt,ff->size);
        }
    }
    G_form.type=tft;
	RETURN;
}
// update all modified datastores
void updatest(void)
{
    INT i;
	ENTRY(2810);
    for (i=0;i<20;i++) {
        if ((G_sstat[i].open)&&(G_sstat[i].modified)) {
            sendmsg("DBM",'w',G_sstat[i].name);
        }
    }
	RETURN;
}
// free the form field variables
void clrform(PFORM f)
{
    INT i;
	ENTRY(2820);

    if (G_formvars!=NULL) {
        for (i=0;i<f->numitem;i++) {
	        if ((f->items[i].class==FF_TEXT)||(isaction(f->items[i].name)>=0)) {
            	if (G_formvars[i]!=NULL) {
                	FREE(G_formvars[i]);
                	G_formvars[i]=NULL;
                }
            } else {
//            	if (G_formvars[i]!=NULL) {
//                	G_formvars[i]=REALLOC(G_formvars[i],strlen(G_formvars[i]));
//              }
            }
        }
        FREE(G_formvars);
        G_formvars=NULL;
    }
	RETURN;
}
// RETURN store.field contents
CHAR *getitem(PFORMF f)
{
    CHAR sn[10],fn[10],tmp[20];
    static CHAR ret[81];
	ENTRY(2830);

    if (f->item==NULL) RETURNV(NULL);

    strcpy(tmp,f->item);
    strcpy(sn,strtok(tmp,". "));
    strcpy(fn,strtok(NULL,". "));
    if (!sendmsg("DBM",'g',sn,fn,ret)) RETURNV(NULL);
    RETURNV(ret);
}
// set store.field contents
void loaditem(PFORMF f)
{
    CHAR sn[10],fn[10],tmp[20];
	ENTRY(2840);

    if (f->item==NULL) RETURN;

    strcpy(tmp,f->item);
    strcpy(sn,strtok(tmp,". "));
    strcpy(fn,strtok(NULL,". "));
    if (snum(sn)<0) RETURN;
    if (fnum(sn,fn)<0) RETURN;
    sendmsg("DBM",'p',sn,fn,G_formvars[G_form.curitem]);
	RETURN;
}
// clear record buffer associated with this form
void blankform(PFORMF f)
{
    CHAR sn[10],tmp[20];
	ENTRY(2850);

    if (f->item==NULL) RETURN;

    strcpy(tmp,f->item);
    strcpy(sn,strtok(tmp,". "));
    sendmsg("DBM",'b',sn);
	RETURN;
}
// search a datastore with current form field information
void srchitem(PFORMF f)
{
    CHAR sn[10],fn[10],tmp[20];
    INT res;
	ENTRY(2860);

    if (f->item==NULL) RETURN;
    if ((f->class==FF_SRCH)||(f->class==FF_SECS)||(f->class==FF_MSRH)||(f->class==FF_MSEC)) {
        strcpy(tmp,f->item);
        strcpy(sn,strtok(tmp,". "));
        strcpy(fn,strtok(NULL,". "));
        if ((f->class==FF_SRCH)||(f->class==FF_MSRH))
            res=sendmsg("DBM",'s',sn,NULL,fnum(sn,fn)+1);
        else
            res=sendmsg("DBM",'s',sn,fn,FRST);
        if (res) {
			sendmsg("DBM",'r',sn,CURR);
			fillform(&G_form);
		}
    }
	RETURN;
}
// find a field by ident
INT findid(INT id)
{
    INT i;
	ENTRY(2870);
    for (i=0;i<G_form.numitem;i++) {
        if (G_form.items[i].ident==id) RETURNV(i);
    }
    RETURNV(-1);
}
// redraw a form that has been partly processed
void redrawform(void) 
{
    INT i;
    PFORMF f;
    CHAR selstr[81];
	ENTRY(2880);

    sendmsg("OUTPUT1",'R');
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',1);
    if (G_form.type==F_SERVE) {
        sendmsg("OUTPUT1",'B',G_parea[0],G_parea[1],G_parea[2],G_parea[3]);
        sendmsg("OUTPUT1",'B',G_tarea[0],G_tarea[1],G_tarea[2],G_tarea[3]);
        sendmsg("OUTPUT1",'B',G_larea[0],G_larea[1],G_larea[2],G_larea[3]);
        displog(G_loglev);
    }
    if (G_form.type==F_PROMPT) {
        sendmsg("OUTPUT1",'B',G_parea[0],G_parea[1],G_parea[2],G_parea[3]);
    }
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if (f->class==FF_TEXT) {
            sendmsg("OUTPUT1",'A',f->attrib);
            sendmsg("OUTPUT1",'S',f->size);
            sendmsg("OUTPUT1",'@',f->pos.x,f->pos.y,f->item);
        }
        else {
            if ((f->class!=FF_TABL)&&(f->class!=FF_DISP)&&((f->class&FF_TBLF)==0))
                sendmsg("OUTPUT1",'s',f->pos.x,f->pos.y,strlen(f->fmt)+1);
        }
    }
    for (i=0;i<=G_form.curitem;i++) {
        f=&(G_form.items[i]);
        strcpy(selstr,f->fmt);
        sendmsg("OUTPUT1",'A',f->attrib);
        sendmsg("OUTPUT1",'S',f->size);
        switch (f->class) {
            case FF_MAND :
            case FF_OPTI :
            case FF_SECS :
            case FF_MSEC :
            case FF_MSRH :
            case FF_SRCH :
            case FF_WAIT :
            case FF_DISP :
                output(f->pos.x,f->pos.y,G_formvars[i],0,selstr,f->size);
                break;
            case FF_TABL :
//				j=f->size;
//				f->size=3;
//				tableinput(i);
//				f->size=j;
                break;
            case FF_TEXT :
                break;
        }
    }
	RETURN;
}
// validdate a date/time field
INT validdt(CHAR type)
{
    INT a=0,b=0,c=0;
	CHAR tdpm;
    CHAR instr[81];
	ENTRY(2890);

    switch (type) {
        case 'D' :
            strcpy(instr,G_formvars[G_form.curitem]);
            if (instr[0]==0) RETURNV(1);
		    a=getday (instr);
		    b=getmon (instr);
		    c=getyear(instr);
			orddfrom(&c,&b,&a);
       		if ((b<1)||(b>12)) RETURNV(0);
			tdpm=G_dpm[b-1];
			switch (G_datetype) {
				case PERSIAN :
					if ((((c-70)%4)==0)&&(b==12)) tdpm++;
					break;
				case GREGORIAN :
					if (((c%4)==0)&&(b==2)) tdpm++;
            		break;
			}
       		if ((a<1)||(a>tdpm)) RETURNV(0);
		    break;
        case 'T' :
            strcpy(instr,G_formvars[G_form.curitem]);
            if (instr[0]==0) RETURNV(1);
            sscanf(instr,"%2d%2d%2d",&a,&b,&c);
            if (a>23) RETURNV(0);
            if (b>59) RETURNV(0);
            if (c>59) RETURNV(0);
            break;
    }
    RETURNV(1);
}
// process a form input and output
INT runform(INT clear) 
{
	INT i,k;
    CHAR *selstr,firstfill=1;
    INT oh=G_onlyhot,runit=0,searchit=0;
    PFORMF f;
	ENTRY(2900);
	if ((G_form.type!=F_SERVE)&&(G_form.type!=F_PROMPT)&&(G_form.type!=F_NORM)) {
        RETURNV(runreport());
    }
	selstr=MALLOC(81);
    if (selstr==NULL) return(0);
    if (clear) {
        sendmsg("OUTPUT1",'R');
        if (clear==2) sendmsg("OUTPUT1",'D',1,23);
        sendmsg("OUTPUT1",'A',0);
        sendmsg("OUTPUT1",'S',1);
        if (G_form.type==F_SERVE) {
            sendmsg("OUTPUT1",'B',G_parea[0],G_parea[1],G_parea[2],G_parea[3]);
            sendmsg("OUTPUT1",'B',G_tarea[0],G_tarea[1],G_tarea[2],G_tarea[3]);
            sendmsg("OUTPUT1",'B',G_larea[0],G_larea[1],G_larea[2],G_larea[3]);
            displog(G_loglev);
        }
        if (G_form.type==F_PROMPT) {
            sendmsg("OUTPUT1",'B',G_parea[0],G_parea[1],G_parea[2],G_parea[3]);
        }
		prdate();
    }
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if ((f->class==FF_SRCH)
        ||  (f->class==FF_SECS)
        ||  (f->class==FF_MSRH)
        ||  (f->class==FF_MSEC)) blankform(f);
    }

	G_onlyhot=1;
	if (G_refson) prformname(&G_form);
    for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
        if (f->class==FF_TEXT) {
            sendmsg("OUTPUT1",'A',f->attrib);
            sendmsg("OUTPUT1",'S',f->size);
            sendmsg("OUTPUT1",'@',f->pos.x,f->pos.y,f->item);
        }
        else {
            if ((f->class!=FF_TABL)&&(f->class!=FF_DISP)&&((f->class&FF_TBLF)==0)) {
                sendmsg("OUTPUT1",'s',f->pos.x,f->pos.y,strlen(f->fmt)+1);
				G_onlyhot=0;
			} else {
                if ((f->class==FF_TABL)&&(f->size!=3)) G_onlyhot=0;
            }
        }
		if (G_refson) prformref(f);
    }
	if (G_refson==2) sendmsg("INPUT1",'i');
	G_form.curitem=0;
	do {
		if (G_form.curitem<0) G_form.curitem=0;
    	for (;G_form.curitem<G_form.numitem;G_form.curitem++) {
        	i=G_form.curitem;
        	f=&(G_form.items[G_form.curitem]);
        	if ((f->fmt[0]=='W')&&(f->class!=FF_DISP))
				G_scaleact=(sendmsg("SCALE",'i')>=0);
        	strcpy(selstr,f->fmt);
        	sendmsg("OUTPUT1",'A',f->attrib);
        	sendmsg("OUTPUT1",'S',f->size);
        	runit=0;
        	searchit=0;
        	switch (f->class) {
            	case FF_MAND :
                	if (selstr[0]=='P') G_formvars[G_form.curitem][0]=0;
                	inputstr(f->pos.x,f->pos.y,G_formvars[G_form.curitem],selstr,0);
                	if (i==G_form.curitem) {
                    	if (G_formvars[G_form.curitem][0]==0) {
                        	beep();
                        	G_form.curitem--;
                    	}
                    	else {
                        	runit=1;
                    	}
                	}
                	break;
            	case FF_OPTI :
                	inputstr(f->pos.x,f->pos.y,G_formvars[G_form.curitem],selstr,0);
                	if (i==G_form.curitem) runit=1;
                	break;
            	case FF_SECS :
            	case FF_SRCH :
                	G_formvars[G_form.curitem][0]=0;
                	inputstr(f->pos.x,f->pos.y,G_formvars[G_form.curitem],selstr,0);
                	if (i==G_form.curitem) {
                    	runit=1;
                    	searchit=1;
                	}
                	break;
            	case FF_MSEC :
            	case FF_MSRH :
                	G_formvars[G_form.curitem][0]=0;
                	inputstr(f->pos.x,f->pos.y,G_formvars[G_form.curitem],selstr,0);
                	if (i==G_form.curitem) {
                    	if (G_formvars[G_form.curitem][0]==0) {
                        	beep();
                        	G_form.curitem--;
                    	}
                    	else {
                        	runit=1;
                        	searchit=1;
                    	}
                	}
                	break;
            	case FF_TEXT :
                	if ((i==G_form.curitem)&&(sendmsg("OUTPUT1",'?',f->item))) {
                    	runit=2;
					}
					break;
            	case FF_DISP :
                	if (i==G_form.curitem) runit=2;
                	break;
            	case FF_WAIT :
                	k=0;
                	output(f->pos.x,f->pos.y,G_formvars[i],0,selstr,1);
                	putcur(f->pos.x,f->pos.y,strlen(G_formvars[i]),0,selstr,1,1,G_formvars[i]);
                	while (!k) {
                    	k=sendmsg("INPUT1",'i');
                    	if ((k!=CR)&&(k!=EXIT_K)) {
                        	k=0;
//                        	beep();
                    	}
                	}
                	putcur(f->pos.x,f->pos.y,strlen(G_formvars[i]),0,selstr,(-1),1,G_formvars[i]);
                	if (k==CR) {
                    	runit=2;
                	}
                	else {
                    	G_form.curitem=G_form.numitem;
                    	G_exitkey=EXIT_K;
                	}
                	break;
            	case FF_TABL :
                	G_intable=1;
					runaction(f->func);
                	tableinput(i);
                	G_intable=0;
					runaction(f->func);
                	break;
        	}
        	if ((G_form.curitem==i)&&(!validdt(selstr[0]))) {
//            	beep();
            	runit=0;
            	G_form.curitem--;
        	}
        	else {
            	if (runit) {
                	if (runit==1) loaditem(f);
                	if (searchit) srchitem(f);
					if ((!runaction(f->func))&&(firstfill)) {
//						firstfill=0;
						fillform(&G_form);
					}
            	}
        	}
			if (bm[0]==(-1)) G_form.curitem=i+1;
//			if ((G_onlyhot)&&(G_exitkey!=EXIT_K)&&(!G_exit2top)&&(!G_exit2mrk)&&(!justbutt(&G_form))) {
			if ((G_onlyhot)&&(G_exitkey!=EXIT_K)&&(!G_exit2top)&&(!G_exit2mrk)) {
				k=sendmsg("INPUT1",'CH');
				if (!k) {
					sendmsg("INPUT1",'i');
//					if (k!=LANGSWITCH) beep();
				}
			}
			if ((G_exit2top)||(G_exit2mrk)) G_exitkey=EXIT_K;
			if (G_exitkey==EXIT_K) G_form.curitem=G_form.numitem;
    	}
		if (justbutt(&G_form)&&(G_exitkey!=EXIT_K)&&(!G_exit2top)&&(!G_exit2mrk)) {
			while ((G_exitkey!=EXIT_K)&&(!G_exit2top)&&(!G_exit2mrk)&&(G_form.curitem==G_form.numitem)) { 
				k=sendmsg("INPUT1",'H');
				if (k) {
					k=sendmsg("INPUT1",'i');
//					if (k!=LANGSWITCH) beep();
				}
			}
		}
	} while ((G_exitkey!=EXIT_K)&&(!G_exit2top)&&(!G_exit2mrk)&&(G_form.curitem<G_form.numitem));
    if (G_exitkey!=EXIT_K) {
        if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
            updatest();
            sendmsg("DBM",'f');
        }
        if (G_innext) exitkcheck();
    }
    else {
        if (G_loglev) removelogt(G_loglev);
    }
	G_exitkey=0;
    G_onlyhot=oh;
	if (selstr!=NULL) FREE(selstr);
	if (G_tflds!=NULL) { FREE(G_tflds); G_tflds=NULL; }
    RETURNV(1);
}
