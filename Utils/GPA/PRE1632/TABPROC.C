#define TABPROC_C

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "types.h"
#include "keydef.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "formhand.h"
#include "fldproc.h"
#include "tabproc.h"
#include "dst.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "config.h"

TABDAT  *G_wtb;
INT     G_wxpos;
INT     G_wypos;
INT     G_wcurrec;
INT     G_wnumrec;
INT     G_wtoprec;

INT 	G_recnum=1;
INT 	G_numrec=0;
INT     G_pnr=(-1);
INT 	G_activeflds[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
INT     G_numaf=0;
INT		G_deffld[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
INT     G_numdffld=0;
INT    *G_ridxbuf=NULL;

INT checkflds(void)
{
	CHAR *t;
	CHAR s[80];
	INT i;
	ENTRY(2921);
	G_numaf=0;
    G_numdffld=0;
	if (G_tflds!=NULL) {
		strncpy(s,G_tflds,79);
		t=strtok(s,",\r\n. ");
		while (t!=NULL) {
			if (*t=='~') {
				t++;
				G_deffld[G_numdffld++]=atoi(t);
			}
			if ((i=atoi(t))!=0) G_activeflds[G_numaf++]=i;
			t=strtok(NULL,",\r\n. ");
		}
	}
	RETURNV(G_numaf);
}
INT getnumrec(CHAR *name)
{
	INT nr=0,i=FRST;
    UINT rn;
	ENTRY(2922);
   	nr=sendmsg("DBM",'nr',name);
	switch (G_scond) {
		case 1 :
			if (G_pnr!=nr) {
                if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
				G_pnr=nr;
				G_numrec=0;
                G_ridxbuf=MALLOC(nr*sizeof(INT));
                if (G_ridxbuf!=NULL) {
				    while ((rn=sendmsg("DBM",'sp',name,G_srec,i))!=0) {
                        G_ridxbuf[G_numrec++]=rn;
					    i=NEXT;
				    }
				    sendmsg("DBM",'r',name,G_ridxbuf[0]);
                } else {
				    while (sendmsg("DBM",'sp',name,G_srec,i)) G_numrec++;
    				sendmsg("DBM",'sp',name,G_srec,FRST);
    				sendmsg("DBM",'r',name,CURR);
                }
				G_recnum=1;
			}
			nr=G_numrec;
			break;
		case 2 :
			if (G_pnr!=nr) {
                if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
				G_pnr=nr;
				G_numrec=0;
                G_ridxbuf=MALLOC(nr*sizeof(INT));
                if (G_ridxbuf!=NULL) { 
				    while ((rn=sendmsg("DBM",'s',name,G_sfname,i))!=0) {
                        G_ridxbuf[G_numrec++]=rn;
					    i=NEXT;
				    }
				    sendmsg("DBM",'r',name,G_ridxbuf[0]);
                } else {
				    while ((rn=sendmsg("DBM",'s',name,G_sfname,i))!=0) G_numrec++;
				    sendmsg("DBM",'s',name,G_sfname,FRST);
				    sendmsg("DBM",'r',name,CURR);
                }
				G_recnum=1;
			}
			nr=G_numrec;
			break;
	}
	RETURNV(nr);
}
INT flushtab(void)
{
	ENTRY(2923);
	RETURNV(sendmsg("DBM",'f'));
}
INT getrecnum(CHAR *name)
{
	INT nr=0;
    INT i;
	ENTRY(2924);
	nr=sendmsg("DBM",'rn',name);
	switch (G_scond) {
		case 0 :
			break;
		case 1 :
		case 2 :
            if ((G_ridxbuf!=NULL)&&(G_recnum>0)) {
                for (i=0;i<G_numrec;i++) {
                    if (nr==G_ridxbuf[i]) { G_recnum=nr=i; break; }
                }
                
            } else {
    			nr=G_recnum;
            }
			break;
	}
	RETURNV(nr);
}
INT readrecnum(CHAR *name,INT rec)
{
	INT nr=0;
	ENTRY(2925);
    if (!getnumrec(name)) RETURNV(0);

	switch (G_scond) {
		case 0 :
			nr=sendmsg("DBM",'r',name,rec);
			break;
		case 1 :
            if (G_numrec==0) {
                nr=0;
            } else {
			    switch (rec) {
				    case FRST : rec=1;          break;
				    case NEXT : rec=G_recnum+1; break;
				    case CURR : rec=G_recnum;   break;
				    case PREV : rec=G_recnum-1; break;
				    case LAST : rec=G_numrec;   break;
			    }
                if (rec<1) RETURNV(0);
                if ((G_ridxbuf!=NULL)&&(rec<=G_numrec)) {
			        nr=sendmsg("DBM",'r',name,G_ridxbuf[rec-1]);
                } else {
			        if (rec!=G_recnum) {
				        if (rec<G_recnum) {
					        G_recnum=1;
					        sendmsg("DBM",'sp',name,G_srec,FRST);
				        }
				        while (rec>G_recnum) {
					        if (sendmsg("DBM",'sp',name,G_srec,NEXT)) {
						        G_recnum++;
					        } else {
						        G_recnum=G_numrec;
						        RETURNV(0);
					        }
				        }
			        }
			        nr=sendmsg("DBM",'r',name,CURR);
                }
            }
            break;
		case 2 :
            if (G_numrec==0) {
                nr=0;
            } else {
			    switch (rec) {
				    case FRST : rec=1;          break;
				    case NEXT : rec=G_recnum+1; break;
				    case CURR : rec=G_recnum;   break;
				    case PREV : rec=G_recnum-1; break;
				    case LAST : rec=G_numrec;   break;
			    }
                if (rec<1) RETURNV(0);
                if ((G_ridxbuf!=NULL)&&(rec<=G_numrec)) {
			        nr=sendmsg("DBM",'r',name,G_ridxbuf[rec-1]);
                } else {
			        if (rec!=G_recnum) {
				        if (rec<G_recnum) {
					        G_recnum=1;
					        sendmsg("DBM",'s',name,G_sfname,FRST);
				        }
				        while (rec>G_recnum) {
					        if (sendmsg("DBM",'s',name,G_sfname,NEXT)) {
						        G_recnum++;
					        } else {
						        G_recnum=G_numrec;
						        RETURNV(0);
					        }
				        }
		            }
			        nr=sendmsg("DBM",'r',name,CURR);
		        }
			}
			break;
	}
	RETURNV(nr);
}
INT delrec(CHAR *name,INT rec)
{
	ENTRY(2926);
	readrecnum(name,rec);
	RETURNV(sendmsg("DBM",'dr',name,CURR));
}
// collect all field information for a given table
INT getflddata(PTABDAT tb,INT i,CHAR *v)
{
    INT item=G_form.curitem;
	ENTRY(2930);
    if (((G_form.items[tb->fid[i]].class^FF_TBLF)==FF_DISP)
	||   (G_form.type==F_REPORT)
	||   (G_form.type==F_PPFORM)) {
        if (strncmp(G_form.items[tb->fid[i]].func,"NONE",4)) {
            if (!sendmsg("DBM",'g',tb->sn,tb->fn[i],G_formvars[tb->fid[i]])) RETURNV(0);
            G_form.curitem=tb->fid[i];
            G_curtcol=G_wcurrec;
            runaction(G_form.items[tb->fid[i]].func);
            G_form.curitem=item;
            strcpy(v,G_formvars[tb->fid[i]]);
            RETURNV(1);
        }
    }
    RETURNV(sendmsg("DBM",'g',tb->sn,tb->fn[i],v));
}
// draw the border/bacground for a table
void tablebdr(PTABDAT tb)
{
    INT i,j,l;
    INT ofs,x,y,x1,y1;
	ENTRY(2940);
    if (tb->type=='N') RETURN;
    x=tb->pos.x;
    y=tb->pos.y;
    x1=tb->pos.x+tb->width;
    y1=tb->pos.y+tb->depth+3;

    sendmsg("OUTPUT1",'S',1);

    if ((tb->type=='S')||(tb->type=='D')) {
        for (j=0;j<tb->cols;j++) {
            sendmsg("OUTPUT1",'B',x,y,x1,y1);
            ofs=x;
            sendmsg("OUTPUT1",'L',x,y+2,x1,y+2);
            for (i=0;i<tb->numf-1;i++) {
                ofs+=tb->fwid[i]+1;
                sendmsg("OUTPUT1",'L',ofs,y,ofs,y1);
            }
            ofs+=tb->fwid[i]+1;
            ofs-=x;
            x+=ofs;
            x1+=ofs;
        }
    }
    l=1;
    for (j=0;j<tb->cols;j++) {
        for (i=0;i<tb->numf;i++) {
            sendmsg("OUTPUT1",'o',tb->pos.x+l,tb->pos.y+1,"%-*.*s",tb->fwid[i],tb->fwid[i],"");
            sendmsg("OUTPUT1",'@',tb->pos.x+l,tb->pos.y+1,G_form.items[tb->tid[i]].item);
            l+=tb->fwid[i]+1;
        }
    }
	RETURN;
}
// collect all dimension information for a given table
INT gettabledata(PTABDAT tb)
{
    CHAR *t,tmp[80];
    PFORMF fld=&(G_form.items[tb->id]);
    INT i,l;
	ENTRY(2950);

    tb->pos.x=fld->pos.x;
    tb->pos.y=fld->pos.y;
    tb->depth=atoi(&(fld->fmt[2]));
    tb->type=fld->fmt[0];
    tb->cols=fld->fmt[5];
    tb->numf=atoi(&(fld->fmt[7]));
    for (i=0;i<tb->cols;i++) tb->cd[i]=fld->fmt[9+i];

	if (fld->size==3) tb->type='D';		// do this in the designer

    strcpy(tmp,fld->item);
    t=strtok(tmp,"~");
    l=0;
    for (i=0;i<tb->numf;i++) {
		if (isdigit(*t)) {
	        tb->tid[i]=findid(atoi(t));
		} else {
	        tb->tid[i]=findid(*t-'A');
		}
        if (tb->tid[i]==(-1)) RETURNV(0);
        t=strtok(NULL,"~");
		if (isdigit(*t)) {
	        tb->fid[i]=findid(atoi(t));
		} else {
	        tb->fid[i]=findid(*t-'A');
		}
        t=strtok(NULL,"~");
        tb->fwid[i]=max(strlen(textstr(&(G_form.items[tb->tid[i]]))),strlen(G_form.items[tb->fid[i]].fmt));
		if (G_form.items[tb->fid[i]].size>1) tb->fwid[i]*=2;
        l+=tb->fwid[i]+1;
    }
    tb->width=l;
    for (i=0;i<tb->numf;i++) {
        strcpy(tmp,G_form.items[tb->fid[i]].item);
        strcpy(tb->sn,strtok(tmp,". "));
        strcpy(tb->fn[i],strtok(NULL,". "));
    }
    if (isaction(fld->func)) tb->sn[0]='~';
    RETURNV(1);
}
// redraw the table contents
void tabredraw(PTABDAT tb,INT top,INT botup,INT quick)
{
    PFORMF fldp;
    CHAR tmp[80];
    static CHAR fmt[61];
    INT l,ofs,i,j,k,res,rec;
    INT tft=G_form.type;
    static INT dir=0;
	ENTRY(2960);

    if (botup==2) botup=dir; else dir=botup;
    G_form.type=0;
    G_finredraw=0;
    l=tb->width*tb->cols;
    if (botup) {
		rec=top+(tb->depth*tb->cols);
        res=readrecnum(tb->sn,rec);
        for (k=tb->cols-1;k>=0;k--) {
            ofs=l;
            for (j=tb->depth;j>0;j--) {
                l=ofs;
                if (res) {
                    for (i=tb->numf-1;i>=0;i--) {
                        fldp=&(G_form.items[tb->fid[i]]);
                        l-=tb->fwid[i];
                        getflddata(tb,i,tmp);
                        strcpy(fmt,fldp->fmt);
						if (fldp->size==1) fmt[tb->fwid[i]]=0; else fmt[tb->fwid[i]/2]=0;
                        output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size);
                        l--;
                    }
				    sendmsg("OUTPUT1",'S',1);
                    if (quick&&sendmsg("INPUT1",'FH')) {
                        G_form.type=tft;
                        RETURN;
                    }
                    res=readrecnum(tb->sn,--rec);
                }
                else {
					if (tb->type!='D') {
                    	for (i=tb->numf-1;i>=0;i--) {
                            fldp=&(G_form.items[tb->fid[i]]);
                            l-=tb->fwid[i];
                            strcpy(fmt,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                            strcpy(tmp,"                                        ");
    						if (fldp->size==1) fmt[tb->fwid[i]]=0; else fmt[(tb->fwid[i]/2)]=0;
                            output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size);
                            l--;
                        	if (quick&&sendmsg("INPUT1",'FH')) {
                            	G_form.type=tft;
                            	RETURN;
                        	}
                    	}
					}
                    res=readrecnum(tb->sn,--rec);
                }
            }
        }
    }
    else {
        l=1;
		rec=top+1;
        res=readrecnum(tb->sn,rec);
        for (k=0;k<tb->cols;k++) {
            ofs=l;
            for (j=1;j<=tb->depth;j++) {
                l=ofs;
                if (res) {
                    for (i=0;i<tb->numf;i++) {
                        fldp=&(G_form.items[tb->fid[i]]);
                        getflddata(tb,i,tmp);
                        strcpy(fmt,fldp->fmt);
						if (fldp->size==1) fmt[tb->fwid[i]]=0; else fmt[tb->fwid[i]/2]=0;
                        output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size);
                        l+=tb->fwid[i]+1;
                    }
				    sendmsg("OUTPUT1",'S',1);
                    if (quick&&sendmsg("INPUT1",'FH')) {
                        G_form.type=tft;
                        RETURN;
                    }
                    res=readrecnum(tb->sn,++rec);
                }
                else {
					if (tb->type!='D') {
                    	for (i=0;i<tb->numf;i++) {
                            fldp=&(G_form.items[tb->fid[i]]);
                            strcpy(fmt,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                            strcpy(tmp,"                                        ");
    						if (fldp->size==1) fmt[tb->fwid[i]]=0; else fmt[(tb->fwid[i]/2)]=0;
                            output(tb->pos.x+l,tb->pos.y+j+2,tmp,0,fmt,fldp->size);
                            l+=tb->fwid[i]+1;
                    	}
                       	if (quick&&sendmsg("INPUT1",'FH')) {
                           	G_form.type=tft;
                           	RETURN;
                       	}
                   	}
                }
            }
        }
    }
    G_finredraw=1;
    G_form.type=tft;
	RETURN;
}
// find the x/y position of the cursor - given the field offset in the table
INT allto(PTABDAT tb,INT pos)
{
    INT ret=0;
    INT i,j,k=0;
	ENTRY(2970);
    for (i=0;i<tb->cols;i++) {
        for (j=0;j<tb->numf;j++) {
            if (pos==k) RETURNV(ret);
            k++;
            ret+=tb->fwid[j]+1;
        }
    }
    RETURNV(0);
}
// edit a field in a table
INT editfield(PTABDAT tb,INT x,INT y,INT recnum,INT fldnum,INT kp)
{
    INT curpos,r;
    CHAR tmp[81];
	ENTRY(2980);

    curpos=G_form.curitem;
    if (getrecnum(tb->sn)!=recnum+1) {
        if (!readrecnum(tb->sn,recnum+1)) RETURNV(0);
    }
    if (!getflddata(tb,fldnum,tmp)) RETURNV(0);
    if ((r=inputstr(x,y,tmp,G_form.items[tb->fid[fldnum]].fmt,kp))==(-1)) RETURNV(0);
    if (!sendmsg("DBM",'p',tb->sn,tb->fn[fldnum],tmp)) RETURNV(0);
    G_form.curitem=curpos;
    RETURNV(r);
}
// output a field in a table
void outfield(PTABDAT tb,INT x,INT y,INT recnum,INT fldnum)
{
    CHAR tmp[81];
	ENTRY(2990);

//    if (getrecnum(tb->sn)!=recnum+1) {
        if (!readrecnum(tb->sn,recnum+1)) RETURN;
//    }
    if (!getflddata(tb,fldnum,tmp)) RETURN;
    output(x,y,tmp,tb->fwid[fldnum],G_form.items[tb->fid[fldnum]].fmt,1);
	RETURN;
}
void upnamedatest(CHAR *name)
{
    INT i;
	ENTRY(2991);
    for (i=0;i<20;i++) {
        if ((!strcmp(G_sstat[i].name,name))
        &&  (G_sstat[i].open)&&(G_sstat[i].modified)) {
            sendmsg("DBM",'w',name);
            RETURN;
        }
    }
	RETURN;
}
// input a record in a table on field at a time
void inputrec(PTABDAT tb,INT x,INT y)
{
    INT i,ofs;
    CHAR tmp[81];
	ENTRY(3000);
    ofs=0;
    for (i=0;i<tb->numf;i++) {
        sendmsg("OUTPUT1",'o',x+ofs,y,"%*.*s",tb->fwid[i],tb->fwid[i],"");
        ofs+=1+tb->fwid[i];
    }
    ofs=0;
    for (i=0;i<tb->numf;i++) {
        tmp[0]=0;
        inputstr(x+ofs,y,tmp,G_form.items[tb->fid[i]].fmt,0);
        if (((G_form.items[tb->fid[i]].class&FF_DISP)==FF_DISP)&&(tmp[0]==0)) {
            beep();
            i--;
        }
        else {
            sendmsg("DBM",'p',tb->sn,tb->fn[i],tmp);
            ofs+=1+tb->fwid[i];
        }
    }
    upnamedatest(tb->sn);
//    updatest();
}
// called to finish redrawing a table when there is no keyboard activity
INT finred(void)
{
	ENTRY(3010);
    if (G_finredraw!=1) {
	    if (G_finredraw==(-1)) tablebdr(G_wtb);
		if (G_wtb->type!='D') sendmsg("OUTPUT1",'C',G_wtb->pos.x,1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wtb->fwid[G_wxpos%G_wtb->numf],(-1));
		G_wnumrec=getnumrec(G_wtb->sn);
        if (G_wnumrec!=0)
            if (G_wcurrec>G_wnumrec-1) sendmsg("INPUT1",'P',UP);
        tabredraw(G_wtb,G_wtoprec,2,1);
        outfield(G_wtb,G_wtb->pos.x+1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wcurrec,G_wxpos%G_wtb->numf);
        if (G_wtb->type!='D') sendmsg("OUTPUT1",'C',G_wtb->pos.x,1+allto(G_wtb,G_wxpos),G_wtb->pos.y+3+G_wypos,G_wtb->fwid[G_wxpos%G_wtb->numf],1);
    }
    RETURNV(1);
}
INT lastfield(PTABDAT tb)
{
	INT i,j=0;
	ENTRY(3011);
	if (G_numaf==0) RETURNV(tb->numf-1);
	for (i=0;i<G_numaf;i++) j=max(j,(G_activeflds[i]-1));
	RETURNV(j);
}
INT firstfield(void)
{
	INT i,j=32000;
	ENTRY(3012);
	if (G_numaf==0) RETURNV(0);
	for (i=0;i<G_numaf;i++) j=min(j,(G_activeflds[i]-1));
	RETURNV(j);
}
void setcheck(PTABDAT tb,INT *xpos,INT dir)
{
	INT i;
	ENTRY(3013);
	if (G_numaf==0) RETURN;
    if (dir==4) {
        if (G_numdffld<1) RETURN;
		while (*xpos<=tb->numf) {
			for (i=0;i<G_numdffld;i++) {
				if ((G_deffld[i]-1)==*xpos) RETURN;
			}
			(*xpos)++;
        }
		(*xpos)=G_deffld[0];
        RETURN;
    }
	for (i=0;i<G_numaf;i++) {
		if ((G_activeflds[i]-1)==*xpos) RETURN;
	}
	if ((dir==1)||(dir==2)) {
		while (*xpos<=tb->numf) {
			(*xpos)++;
			for (i=0;i<G_numaf;i++) {
				if ((G_activeflds[i]-1)==*xpos) RETURN;
			}
		}
		if (dir!=2) {
			*xpos=0;
			while (*xpos<=tb->numf) {
				for (i=0;i<G_numaf;i++) {
					if ((G_activeflds[i]-1)==*xpos) RETURN;
				}
				(*xpos)++;
			}
			RETURN;
		}
	} 
	while (*xpos>=0) {
		(*xpos)--;
		for (i=0;i<G_numaf;i++) {
			if ((G_activeflds[i]-1)==*xpos) RETURN;
		}
	}
	if (dir!=3) {
		*xpos=tb->numf;
		while (*xpos>0) {
			for (i=0;i<G_numaf;i++) {
				if ((G_activeflds[i]-1)==*xpos) RETURN;
			}
			(*xpos)--;
		}
		RETURN;
	}
	while (*xpos<=tb->numf) {
		(*xpos)++;
		for (i=0;i<G_numaf;i++) {
			if ((G_activeflds[i]-1)==*xpos) RETURN;
		}
	}
    RETURN;
}
INT movecur(INT *o,INT m,INT t,PTABDAT tb)
{
	INT retval=0;
	ENTRY(3014);
    if (t<100) {
	    switch (t) {
		    case 0 	  : 					break;
		    case FRST :	*o=firstfield(); 	break;
		    case LAST :	*o=lastfield(tb);  	break;
		    case CURR : *o+=m;				break;
		    default   :	*o=m;
	    }
	    if (*o>lastfield(tb))  *o=lastfield(tb);
	    if (*o<firstfield())   *o=firstfield();
    } else {
        t-=100;
        retval=1;
	    switch (t) {
		    case 0    :	retval=0;			  break;
		    case FRST : *o=0;		     	  break;
		    case LAST : *o=getnumrec(tb->sn); break;
		    case CURR : *o+=m;			      break;
		    default   : *o=m;		     		
	    }
	    if (*o>getnumrec(tb->sn)) *o=getnumrec(tb->sn);
	    if (*o<0)                 *o=0;
    }
	RETURNV(retval);
}
// handle all table input/output processing
void tableinput(INT id)
{
    PTABDAT tb;
	LONG fl,cr,de=0;
    INT xpos=0;
    INT item=0;
    INT ypos=0;
    CHAR xit=0,suppress=0;
	CHAR dobeep=0;
	CHAR dir=1;
    INT currec=0;
    INT toprec=0;
    INT numrec=0;
    INT k;
	ENTRY(3020);
    tb=MALLOC(sizeof(TABDAT));
    if (tb==NULL) RETURN;
    tb->id=id;

	checkflds();

    G_finredraw=0;
    if (!gettabledata(tb)) {
        FREE(tb);
        RETURN;
    }
	G_pnr=(-1);
    numrec=getnumrec(tb->sn);
    tablebdr(tb);
	if (tb->type=='D') {
        tabredraw(tb,toprec,0,0);
        if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
        G_ridxbuf=NULL;
        FREE(tb);
		RETURN;
	}
	if (G_numdffld!=0) xpos=G_deffld[0]-1;
	setcheck(tb,&xpos,dir);
    outfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf);
    sendmsg("OUTPUT1",'C',tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],1);
    G_wtb=tb; G_wxpos=xpos; G_wypos=ypos; G_wcurrec=currec; G_wnumrec=numrec; G_wtoprec=toprec;
	prdate();
    sendmsg("INPUT1",'A',2,finred);
	fl=G_formloaded;
	cr=getnumrec(tb->sn);
    while (!xit) {
        G_wtb=tb; G_wxpos=xpos; G_wypos=ypos; G_wcurrec=currec; G_wnumrec=numrec; G_wtoprec=toprec;
        G_curtcol=currec;
        k=sendmsg("INPUT1",'i');
		if ((k==LEFT)||(k==RGT)) k=sendmsg("OUTPUT1",'K',k);
        numrec=G_wnumrec;
        sendmsg("OUTPUT1",'C',tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1));
		if ((k==G_pickkey)
        &&  (strncmp(G_form.items[tb->fid[xpos]].func,"NONE",4))
        &&  ((G_form.items[tb->fid[xpos]].class^FF_TBLF)!=FF_DISP)) {
            if (readrecnum(tb->sn,currec+1)) {
		        item=G_form.curitem;
    	        G_form.curitem=tb->fid[xpos];
                G_curtcol=currec;
                if (!de) sendmsg("DBM",'g',tb->sn,tb->fn[xpos],G_lastval);
		        runaction(G_form.items[tb->fid[xpos]].func);
				if (fl!=G_formloaded) {
					fl=G_formloaded;
		    		if (!gettabledata(tb)) {
                        FREE(tb);
                        RETURN;
                    }
                    if (G_form.curitem!=tb->fid[xpos]) movecur(&xpos,1,xpos+(G_form.curitem-tb->fid[xpos]),tb);
    		        if (G_form.curitem!=G_form.numitem) G_form.curitem=item;
		    		tablebdr(tb);
					G_pnr=(-1);
            		numrec=getnumrec(tb->sn);
		    		G_wtb=tb;
					G_wxpos=xpos;
					G_wypos=ypos;
					G_wcurrec=currec;
					G_wnumrec=numrec;
					G_wtoprec=toprec;
					G_intable=1;
                    checkflds();
            		tabredraw(tb,toprec,0,0);
				} else {
                    if (G_form.curitem!=tb->fid[xpos]) xpos+=(G_form.curitem-tb->fid[xpos]);
    		        if (G_form.curitem!=G_form.numitem) G_form.curitem=item;
					fillfields(&G_form);
            		numrec=getnumrec(tb->sn);
                    if (cr!=numrec) {
                    	G_pnr=(-1);
                		cr=numrec=getnumrec(tb->sn);
                    }
		    		G_wtb=tb;
					G_wxpos=xpos;
					G_wypos=ypos;
					G_wcurrec=currec;
					G_wnumrec=numrec;
					G_wtoprec=toprec;
            		if (G_finredraw==1) G_finredraw=0;
				}
            }
			if (suppress) k=suppress;
			suppress=0;
            switch(k) {
                case CPGUP : case CPGDN : case PGUP : case PGDN :
                case HOME  : case END   : case UP   : case DOWN :
                case LEFT  : case RGT   : case INS  : case DEL  :
                case CR    : case EXIT_K : 
                    break;
				default :
					k=0;
            }
		}
        de=0;
        switch(k) {
            case 0 :
				break;
            case PRINT :
                if (readrecnum(tb->sn,currec+1)) {
                    G_tb=tb;
                    subaction("PRINTKEY",1);
                    G_tb=NULL;
                    numrec=getnumrec(tb->sn);
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case HOME :
                xpos=0;
                if (G_numdffld) xpos=G_deffld[0]-1;
                break;

            case END :
                xpos=(tb->numf*tb->cols)-1;
                if (G_numdffld) xpos=G_deffld[G_numdffld-1]-1;
				dir=0;
                break;

            case CPGUP :
                if (currec>0) {
                    currec=0;
                    toprec=0;
                    ypos=0;
					xpos=0;
                    if (G_numdffld) xpos=G_deffld[0]-1;
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case CPGDN :
                if (currec<=numrec) {
                    currec=numrec-1;
                    toprec=currec-((tb->depth*tb->cols)-1);
                    if (toprec<0) toprec=0;
                    ypos=(currec-toprec)%tb->depth;
					xpos=(tb->cols-1)*tb->numf;
                    if (G_numdffld) xpos=G_deffld[0]-1;
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case PGUP :
                if (currec>0) {
                    currec-=(tb->depth*tb->cols);
                    toprec-=(tb->depth*tb->cols);
                    if (toprec<0) {
                        toprec=0;
                        currec=0;
                        ypos=0;
						xpos=0;
                    }
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case PGDN :
                if (currec<=numrec) {
                    currec+=(tb->depth*tb->cols);
                    toprec+=(tb->depth*tb->cols);
                    if (currec>=numrec) {
                        currec=numrec-1;
                        toprec=currec-((tb->depth*tb->cols)-1);
                        if (toprec<0) toprec=0;
                        ypos=(currec-toprec)%tb->depth;
						xpos=0;
                    }
                    tabredraw(tb,toprec,0,1);
                }
                break;

            case UP : 
                if (ypos>0) {
                    ypos--;
                    currec--;
                } else {
                    if (xpos>=tb->numf) {
                        xpos-=tb->numf;
                        ypos=tb->depth-1;
                        currec--;
                    } else {
                        if (toprec!=0) {
                            toprec--;
                            currec--;
                            tabredraw(tb,toprec,0,(toprec!=0));
                        }
                    }
                }
                break;
            case DEL :
                if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                    if (numrec>0) {
                        delrec(tb->sn,currec+1);
                        tabredraw(tb,toprec,0,1);
                        numrec=getnumrec(tb->sn);
                        if (currec>numrec-1) sendmsg("INPUT1",'P',UP);
                    }
                } else {
                    beep();
                }
                break;
            case INS :
                if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                    xpos=(xpos/tb->numf)*tb->numf;
					if (xpos<0) xpos=0;
                    inputrec(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos);
                    tabredraw(tb,toprec,0,1);
                    numrec=getnumrec(tb->sn);
                } else {
                    beep();
                }
                break;
            case DOWN :
                if (currec<(numrec-1)) {
                    if (ypos<tb->depth-1) {
                        ypos++;
                        currec++;
                    } else {
                        if (xpos<(tb->numf*(tb->cols-1))) {
                            xpos+=tb->numf;
							if (xpos<0) xpos=0;
                            ypos=0;
                            currec++;
                        } else {
                            if (currec<numrec-1) {
                                toprec++;
                                currec++;
                                tabredraw(tb,toprec,1,(currec<numrec-1));
                            }
                        }
                    }
                }
                break;
            case CR :
               	if ((xpos==lastfield(tb))||(G_numdffld==1)||(xpos==G_deffld[G_numdffld-1]-1)) {
                    dir=xpos;
                   	if (currec<numrec-1) {
                       	if (ypos<tb->depth-1) {
                           	currec++;
                           	ypos++;
                           	xpos=(xpos/tb->numf)*tb->numf;
							if (xpos<0) xpos=0;
                       	} else {
                           	if (xpos<(tb->numf*(tb->cols-1))) {
                               	xpos+=tb->numf;
                               	xpos=(xpos/tb->numf)*tb->numf;
								if (xpos<0) xpos=0;
                               	ypos=0;
                               	currec++;
                           	} else {
                               	if (currec<numrec-1) {
                                   	toprec++;
                                   	currec++;
                                   	tabredraw(tb,toprec,1,(currec<numrec-1));
                                   	xpos=(xpos/tb->numf)*tb->numf;
									if (xpos<0) xpos=0;
                               	}
                           	}
                       	}
                   	}
    				if ((G_numdffld==1)||(dir==G_deffld[G_numdffld-1]-1))
                        xpos=G_deffld[0]-1;
                    dir=1;
               	} else {
                    dir=4;
                   	if (xpos<(tb->numf*tb->cols)-1) xpos++;
               	}
                break;
            case LEFT :
               	if (xpos>0) {
                   	xpos--;
                   	if ((xpos%tb->numf)==tb->numf-1) {
                       	currec-=tb->depth;
                   	}
               	}
				dir=3;
                break;
            case RGT : 
               	if (((xpos%tb->numf)!=tb->numf-1)||(currec<numrec-tb->depth)) {
                   	if (xpos<(tb->numf*tb->cols)-1) {
                       	xpos++;
                       	if ((xpos%tb->numf)==0) currec+=tb->depth;
                   	}
               	}
				dir=2;
                break;

            case EXIT_K :
                flushtab();
                G_exitkey=EXIT_K;
                xit=1;
                break;

            case LANGSWITCH :
				if (fl!=G_formloaded) {
				    G_finredraw=1;
				}
				if (G_form.numitem==G_form.curitem) {
	                flushtab();
	                xit=1;
				}
				break;

            default :
                if ((G_form.items[tb->fid[xpos%tb->numf]].class&FF_DISP)==FF_DISP) {
                    dobeep=1;
                } else {
                    if (numrec>=1) {
                        if ((k=editfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf,k))!=0) {
                            upnamedatest(tb->sn);
//                            updatest();
                            numrec=getnumrec(tb->sn);
                            tabredraw(tb,toprec,0,1);
                        }
                        de=1;
                        switch(k) {
                            case CPGUP : case CPGDN : case PGUP : case PGDN :
                            case HOME  : case END   : case UP   : case DOWN :
                            case LEFT  : case RGT   : case INS  : case DEL  :
                            case CR    : case EXIT_K :
								if (G_pickkey==CR) {
	                                sendmsg("INPUT1",'P',CR);
									suppress=k;
								} else {
	                                sendmsg("INPUT1",'P',k);
								}
                                break;
							case 0 :
                            case ESC   :
                                break;
							default :
                                sendmsg("INPUT1",'P',CR);
                        }
                    }
                    else {
                        if ((G_form.attribs&FA_UPDS)==FA_UPDS) {
                            xpos=(xpos/tb->numf)*tb->numf;
							if (xpos<0) xpos=0;
                            inputrec(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos);
                            tabredraw(tb,toprec,0,1);
                            numrec=getnumrec(tb->sn);
                        }
                        else {
		                    dobeep=1;
                        }
                    }
                }
        }
		if (fl!=G_formloaded) {
	        sendmsg("OUTPUT1",'C',tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1));
			fl=G_formloaded;
		    if (!gettabledata(tb)) {
                FREE(tb);
                RETURN;
            }
		    tablebdr(tb);
            numrec=getnumrec(tb->sn);
            if (cr!=numrec) {
              	G_pnr=(-1);
           		cr=numrec=getnumrec(tb->sn);
            }
		    G_wtb=tb;
			G_wxpos=xpos;
			G_wypos=ypos;
			G_wcurrec=currec;
			G_wnumrec=numrec;
			G_wtoprec=toprec;
			G_intable=1;
            tabredraw(tb,toprec,0,0);
            checkflds();
			dobeep=0;
		} else {
			if (k==LANGSWITCH) {
            	numrec=getnumrec(tb->sn);
				fillfields(&G_form);
				G_pnr=(-1);
           		numrec=getnumrec(tb->sn);
	    		G_wtb=tb;
				G_wxpos=xpos;
				G_wypos=ypos;
				G_wcurrec=currec;
				G_wnumrec=numrec;
				G_wtoprec=toprec;
           		if (G_finredraw==1) G_finredraw=0;
            }
        }
		if (dobeep) {
			if (k!=LANGSWITCH) beep();
			dobeep=0;
		}
		checkflds();
		setcheck(tb,&xpos,dir);
        outfield(tb,tb->pos.x+1+allto(tb,xpos),tb->pos.y+3+ypos,currec,xpos%tb->numf);
        sendmsg("OUTPUT1",'C',tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],1);
		dir=1;
    	if (G_form.curitem==G_form.numitem) xit=1;
    }
    sendmsg("INPUT1",'D',finred);
    sendmsg("OUTPUT1",'C',tb->pos.x,1+allto(tb,xpos),tb->pos.y+3+ypos,tb->fwid[xpos%tb->numf],(-1));
    if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
    G_ridxbuf=NULL;
    FREE(tb);
	RETURN;
}

