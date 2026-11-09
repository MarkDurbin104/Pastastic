#define PRNDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <ctype.h>
#include <search.h>
#include "types.h"
#include "message.h"
#include "control.h"
#include "diskdev.h"
#ifdef WIEN
 #include "ptprndev.h"
#else
 #include "caprndev.h"
#endif
#include "config.h"

INT flagerr(INT full);

typedef INT (*qsptr)(const void*, const void*);
typedef struct {
	INT   x ;
	INT   y ;
	CHAR *s ;
	UCHAR sz;
	UCHAR a ;
	UCHAR mx ;
	UCHAR my ;
} PRXYSTR;
typedef PRXYSTR *PPRXYSTR;

INT prn_output(INT x,INT y,CHAR *fmt,...);

PPRXYSTR *G_prnl=NULL;
INT   G_numpl=0;
INT   G_numplmal=0;

UCHAR G_doubmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
FILE *G_printer;
CHAR  G_boxb[22]={'Ú','¿','À','Ù','³','Ä','Á','Â','Ã','´','Å',
                  'É','»','È','¼','º','Í','Ê','Ë','Ì','¹','Î'};
INT   G_prntype=0;
INT   G_chsize=1;
INT   G_emphon=1;
INT   G_prerror=0;
CHAR  *G_normtab;
extern UCHAR *G_vfontspace;
extern UCHAR *G_hfontspace;
UINT   G_cmap[256];
INT G_ox=0;
INT G_oa=-1;
INT G_oz=-1;
INT G_microx=0;
INT G_microy=0;
INT G_prerrboxx=67;
INT G_prerrboxy=14;
INT G_printing=0;
INT G_pagestyle=0;
UCHAR G_multip=1;
UCHAR G_dividr=1;

INT G_ptype='P';
INT G_paddr=0x378;
INT G_prate=9600;
INT G_pbits=8;
INT G_ppari='N';
INT G_pstop=1;
CHAR G_pfile[80];
INT xtoi(char *s)
{
    INT rv=0;
    while ((*s)&&isxdigit(*s)) {
        if (*s<='9') {
            rv|=*s-'0';
        } else if (*s<='Z') {
            rv|=(*s-'A')+10;
        } else {
            rv|=(*s-'a')+10;
        }
        rv<<=4;
        s++;
    }
    return(rv);
}
void putprn(UCHAR c)
{
    fputc(c,G_printer);
}
INT getseqtok(CHAR **s)
{
    INT rv=(-100);
    switch (**s) {
        case ']' :
            rv=(-200);
            break;
        case '\'' :
            rv=(INT)*(++(*s));
            (*s)++;
            break;
        case 'e':
        case 'E':
            rv=27;
            break;
        case 'n':
        case 'N':
            if (*(++(*s))=='1') rv=(-1); else rv=(-2);
            break;
        case 'D':
            rv=(-3);
            break;
        case '*':
            rv=(-4);
            if (isdigit(*((*s)+1))) {
                (*s)++;
                G_multip=atoi(*s);
                while ((**s)&&(isdigit(**s))) (*s)++;
                (*s)--;
            } else {
                G_multip=1;
            }
            break;
        case '/':
            rv=(-5);
            if (isdigit(*((*s)+1))) {
                (*s)++;
                G_dividr=atoi(*s);
                while ((**s)&&(isdigit(**s))) (*s)++;
                (*s)--;
            } else {
                G_dividr=1;
            }
            break;
        case '0':
            if ((*((*s)+1)=='x')||(*((*s)+1)=='X')) {
                (*s)+=2;
                rv=xtoi((*s));
                while ((**s)&&(isdigit(**s))) (*s)++;
                (*s)--;
                break;              // <<--  ONLY break if HEX
            }
                  case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
            rv=atoi(*s);
            while ((**s)&&(isdigit(**s))) (*s)++;
            (*s)--;
            break;
    }
    (*s)++;
    return(rv);
}
void applyseq(INT idx,CHAR *seq)
{
    INT c,len=0,buf[160],xit=0;
    char *s;
    if (G_sequence[idx]!=NULL) FREE(G_sequence[idx]);
    G_seqlen[idx]=0;
    if (idx==PRS_SETPORT) {
        G_ptype=(-1);
        while ((*seq)&&(G_ptype<0)) if ((G_ptype=getseqtok(&seq))==(-200)) return;
        G_paddr=(-1);
        while ((*seq)&&(G_paddr<0)) if ((G_paddr=getseqtok(&seq))==(-200)) return;
        G_prate=(-1);
        while ((*seq)&&(G_prate<0)) if ((G_prate=getseqtok(&seq))==(-200)) return;
        G_pbits=(-1);
        while ((*seq)&&(G_pbits<0)) if ((G_pbits=getseqtok(&seq))==(-200)) return;
        G_ppari=(-1);
        while ((*seq)&&(G_ppari<0)) if ((G_ppari=getseqtok(&seq))==(-200)) return;
        G_pstop=(-1);
        while ((*seq)&&(G_pstop<0)) if ((G_pstop=getseqtok(&seq))==(-200)) return;
    } else if (idx==PRS_SETFILE) {
        if ((s=strtok(seq," ]\r\n"))!=NULL) {
            G_ptype='F';
            strncpy(G_pfile,s,80);
        }
    } else {
        while ((*seq)&&(!xit)&&(len<160)) {
            switch (c=getseqtok(&seq)) {
                case (-100) :
                    break;
                case (-200) :
                    xit=1;
                    break;
                case (-4) :
                    buf[len++]=c;
                    buf[len++]=G_multip;
                    break;
                case (-5) :
                    buf[len++]=c;
                    buf[len++]=G_dividr;
                    break;
                default :
                    buf[len++]=c;
            }
        }
        if (xit) {
            G_sequence[idx]=MALLOC((len+1)*sizeof(INT));
            if (G_sequence[idx]!=NULL) {
                memcpy(G_sequence[idx],buf,len*sizeof(INT));
                G_seqlen[idx]=len;
            }
        }
    }
}
void checkln(CHAR *ln)
{
    CHAR buf[161],*t,*s;
    INT i;
    strncpy(buf,ln,160);
    buf[160]=0;
    if ((t=strtok(buf,"["))==NULL)  return;
    t+=strlen(t)+1;
    s=buf;
    while ((*s)&&(*s!=32)&&(*s!=9)) s++;
    if (*s) *s=0;
    i=0;
    while ((s=G_keywords[i])!=NULL) {
        if (!strncmp(buf,s,strlen(s))) {
            if (i==6) {
                i=buf[strlen(s)];
                if ((i>'0')&&(i<='9')) {
                    i=PRS_ATTRON1+(i-'1');
                    applyseq(i,t);
                }
            } else if (i==7) {
                i=buf[strlen(s)];
                if ((i>'0')&&(i<='9')) {
                    i=PRS_ATTROFF1+(i-'1');
                    applyseq(i,t);
                }
            } else if (i==8) {
                i=buf[strlen(s)];
                if ((i>'0')&&(i<'4')) {
                    i=PRS_SIZE1+(i-'1');
                    applyseq(i,t);
                }
            } else if (i>8) {
                applyseq(PRS_FORMFEED+(i-9),t);
            } else {
                applyseq(i,t);
            }
            break;
        }
        i++;
    }
}
INT getprseqs(CHAR *file)
{
    CHAR buf[161];
    FILE *fp;
    memset(G_sequence,0,sizeof(G_sequence));
    memset(G_seqlen  ,0,sizeof(G_seqlen  ));
    if ((fp=fopen(file,"r"))==NULL) return(0);
    while (fgets(buf,160,fp)!=NULL) checkln(buf);
    fclose(fp);
    return(1);
}
void sendseqln(INT *buf,INT len,INT n)
{
    INT i,an;
    G_multip=1;
    G_dividr=1;
    for (i=0;i<len;i++) {
        an=((n*G_multip)/G_dividr);
        switch (buf[i]) {
            case -1 : putprn((UCHAR)(an%256));             break;
            case -2 : putprn((UCHAR)(an/256));             break;
            case -3 : fprintf(G_printer,"%d",an); break;
            case -4 : G_multip=buf[++i]; break;
            case -5 : G_dividr=buf[++i]; break;
            default : putprn((UCHAR)buf[i]);
        }
    }
}
INT seqset(INT idx)
{
    if ((G_seqlen[idx]==0)||(G_sequence[idx]==NULL)) return(0);
    return(1);
}
int repeat(INT idx)
{
    INT i,rpt=0;
    for (i=0;i<G_seqlen[idx];i++) if (G_sequence[idx][i]==(-1)) break;
    if (i!=G_seqlen[idx]) {
        for (i=0;i<G_seqlen[idx];i++) if (G_sequence[idx][i]==(-2)) break;
        if (i==G_seqlen[idx]) rpt=1;
    }
    return(rpt);
}
void sendseq(INT idx,INT n)
{
    if (!seqset(idx)) return;
    if (repeat(idx)) {
        while (n>255) {
            sendseqln(G_sequence[idx],G_seqlen[idx],255);
            n-=255;
        }
        if (n) sendseqln(G_sequence[idx],G_seqlen[idx],n);
    } else {
        sendseqln(G_sequence[idx],G_seqlen[idx],n);
    }
}
void sendseqn(CHAR *seqname,INT n)
{
    INT i=0;
    char *s;
    while ((s=G_keywords[i])!=NULL) {
        if (!strncmp(seqname,s,strlen(s))) {
            if (i==6) {
                i=seqname[strlen(s)];
                if ((i>'0')&&(i<='9')) {
                    i=PRS_ATTRON1+(i-'1');
                    sendseq(i,n);
                }
            } else if (i==7) {
                i=seqname[strlen(s)];
                if ((i>'0')&&(i<='9')) {
                    i=PRS_ATTROFF1+(i-'1');
                    sendseq(i,n);
                }
            } else if (i==8) {
                i=seqname[strlen(s)];
                if ((i>'0')&&(i<'4')) {
                    i=PRS_SIZE1+(i-'1');
                    sendseq(i,n);
                }
            } else if (i>8) {
                i=PRS_FORMFEED+(i-9);
                sendseq(i,n);
            } else {
                sendseq(i,n);
            }
            return;
        }
        i++;
    }
}
void ppbox(INT x,INT y,INT x1,INT y1)
{
    INT i;
    INT s=G_pprnsize;
	ENTRY(4870);
	if (x>x1) { i=x; x=x1; x1=i; }
	if (y>y1) { i=y; y=y1; y1=i; }
    G_pprnsize=0;
    for (i=x+1;i<x1;i++) {
        prn_output(i,y,"%c",G_boxb[5]);
        prn_output(i,y1,"%c",G_boxb[5]);
    }
    for (i=y+1;i<y1;i++) {
        prn_output(x,i,"%c",G_boxb[4]);
        prn_output(x1,i,"%c",G_boxb[4]);
    }
    prn_output(x,y,"%c",G_boxb[0]);
    prn_output(x1,y,"%c",G_boxb[1]);
    prn_output(x,y1,"%c",G_boxb[2]);
    prn_output(x1,y1,"%c",G_boxb[3]);
    G_pprnsize=s;
	RETURN;
}
void ppline(INT x,INT y,INT x1,INT y1)
{
    INT i;
    INT s=G_pprnsize;
	ENTRY(4880);
	if (x>x1) { i=x; x=x1; x1=i; }
	if (y>y1) { i=y; y=y1; y1=i; }
    G_pprnsize=0;
    if ((x==x1)&&(y==y1)) {
        prn_output(x,y,"%c",G_boxb[10]);
    } else if (x==x1) {
        for (i=y+1;i<y1;i++) {
            prn_output(x,i,"%c",G_boxb[4]);
        }
        prn_output(x,y,"%c",G_boxb[7]);
        prn_output(x,y1,"%c",G_boxb[6]);
    } else if (y==y1) {
        for (i=x+1;i<x1;i++) {
            prn_output(i,y,"%c",G_boxb[5]);
        }
        prn_output(x,y,"%c",G_boxb[8]);
        prn_output(x1,y,"%c",G_boxb[9]);
    }
    G_pprnsize=s;
	RETURN;
}
void preol(void)
{
	ENTRY(4950);
    sendseq(PRS_LINEFEED,0);
	G_ox=0;
	RETURN;
}
void preop(void)
{
	ENTRY(4960);
    sendseq(PRS_FORMFEED,0);
	G_curpline=0;
	G_ox=0;
	RETURN;
}
void movetox(INT nx)
{
	if (G_microx) {
        if (seqset(PRS_MICROX)) {
            sendseq(PRS_MICROX,(nx*G_microx));
        } else {
            if ((nx-G_ox)>0) {
                sendseq(PRS_MICROXR,((nx-G_ox)*G_microx));
                G_ox=nx;
            }
        }
	} else {
		if (nx<G_ox) return;
		while (nx!=G_ox) {
            sendseq(PRS_NORMX,0);
			G_ox++;
		}
	}
}
void movetoy(INT ny)
{
	if (G_microy) {
        if (ny<=G_curpline) return;
		G_ox=0;
        if (seqset(PRS_MICROY)) {
//            sendmsg("OUTPUT1",MESSAGE_o,0,3,"MICROY Set");
            sendseq(PRS_MICROY,(ny*G_microy));
        } else {
//            sendmsg("OUTPUT1",MESSAGE_o,0,3,"MICROY Relative Set");
            sendseq(PRS_MICROYR,(ny-G_curpline)*G_microy);
        }
        G_curpline=ny;
	} else {
		if (ny<G_curpline) return;
		while (ny!=G_curpline) {
            sendseq(PRS_NORMY,0);
			G_curpline++;
			G_ox=0;
		}
	}
}
void setattr(INT na)
{
	if (na!=G_oa) {
        sendseq(PRS_ATTROFF1+G_oa,0);
        sendseq(PRS_ATTRON1+na,0);
		G_oa=na;
	}
}
void setsize(INT nz)
{
	if (G_oz!=nz) {
        sendseq(PRS_SIZE1+nz,0);
		G_oz=nz;
	}
}
// printer reset routine
INT prn_reset(void)
{
	INT i;
	ENTRY(5000);
	sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8," RESET ");
	for (i=0;i<G_numpl;i++) {
	  	if (G_prnl[i]->s!=NULL) FREE(G_prnl[i]->s);
	  	if (G_prnl[i]   !=NULL) FREE(G_prnl[i]   );
	}
    G_numplmal=0;
	G_numpl=0;
	if (G_prnl!=NULL) G_prnl=REALLOC(G_prnl,sizeof(PPRXYSTR));
	sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"       ");
    RETURNV(1);
}
INT plcmp(PPRXYSTR *a,PPRXYSTR *b)
{
    INT x1,y1,x2,y2;
    y1=(*a)->y; y2=(*b)->y;
	if (y1>y2) return(2);
	if (y1<y2) return(-2);
    x1=(*a)->x; x2=(*b)->x;
	if (x1>x2) return(1);
	if (x1<x2) return(-1);
	return(0);
}
INT swithin(INT x,INT ox,INT ol)
{
    return((x>=ox)&&(x<=(ox+ol)));
}
void addpline(INT x,INT y,CHAR *s,UCHAR sz,UCHAR a)
{
	PPRXYSTR *tprnl;
	PPRXYSTR tl;
    static CHAR tbuf[160];
	CHAR *str;
    INT tx,ty;
    INT i;
	if ((s==NULL)||(*s==0)||(x<0)||(y<0)) return;
	if (G_microx) tx=x*G_microx; else tx=x; 
	if (G_microy) ty=y*G_microy; else ty=y;
    for (i=0;i<G_numpl;i++) {
        tl=G_prnl[i];
        if ((ty==tl->y)&&(sz==tl->sz)) {
            if (swithin(tx,tl->x,strlen(tl->s))) {
                memset(tbuf,0,160);
                memcpy(tbuf,tl->s,strlen(tl->s));
                memcpy(tbuf+(tx-tl->x),s,strlen(s));
                if (tl->s!=NULL) FREE(tl->s);
                tl->s=STRDUP(tbuf);
                return;
            }
        }
    }
	if ((str=STRDUP(s))==NULL) return;
	if ((tl=MALLOC(sizeof(PRXYSTR)))==NULL) {
		FREE(str);
		return;
	}
	tprnl=G_prnl;
    if (G_numpl>=G_numplmal) {
        G_numplmal+=100;
        G_prnl=REALLOC(G_prnl,(G_numplmal)*sizeof(PPRXYSTR));
    	if (G_prnl==NULL) {
    		G_prnl=tprnl;
    		return;
    	}
    }
	G_prnl[G_numpl++]=tl;
    tl->mx=G_microx;
    tl->my=G_microy;
	tl->x=tx; 
	tl->y=ty;
	tl->s =str;
	tl->sz=sz;
	tl->a =a;
	qsort(G_prnl,G_numpl,sizeof(PPRXYSTR),(qsptr)plcmp);
}
// printer output routine
INT prn_output(INT x,INT y,CHAR *fmt,...)
{
    CHAR str[140],*s;
    va_list ap;
	ENTRY(5010);

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    s=str;
	switch (x) {
		case (-1) :
			y=strlen(s);
		case (-2) :
           	for (x=0;x<y;x++) {
            	while (flagerr(0)) {
            		if (sendmsg("INPUT1",MESSAGE_H)) {
            			if (sendmsg("INPUT1",MESSAGE_i)==27) return(0);
            		}
            		sendmsg("OSSDEV",MESSAGE_d,200);
            	}
                putprn(*(s++));
            }
			break;
		default   :
			addpline(x,y,s,G_pprnsize,G_pprnattr);
	}
    RETURNV(1);
}
// printer startup routine
INT prn_startup(void)
{
	ENTRY(5020);
    G_numplmal=0;
    if (G_prnl!=NULL) prn_shutdown();
	G_prnl=MALLOC(sizeof(PPRXYSTR));
    strcpy(G_pfile,"gpadruck.txt");
    G_ptype='F';
    G_paddr=1;
    G_prate=9600;
    G_pbits=8;
    G_ppari='N';
    G_pstop=1;
    if (G_printdef[0]!=0) {
        getprseqs(G_printdef);
    } else {
#ifdef WIEN
        getprseqs("ptvprd.prd");
#else
        getprseqs("default.prd");
#endif
    }
    switch (G_ptype) {
        case 'P' :
        case 'p' :
            switch (G_paddr) {
                case 1 :
                    if (G_printer!=stdprn) fclose(G_printer);
                	G_printer=stdprn;
                    break;
                case 2 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("LPT2","w");
                    break;
                case 3 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("LPT3","w");
                    break;
                case 4 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("LPT4","w");
                    break;
                default:
                    if (G_printer!=stdprn) fclose(G_printer);
                    sendmsg("OSSDEV",MESSAGE_SB,7,G_paddr);
                    G_printer=fopen("LPT4","w");
            }
            break;
        case 'S' :
        case 's' :
            switch (G_paddr) {
                case 1 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("COM1","w");
                    sendmsg("INOUT1",MESSAGE_I,-1,G_prate,G_pbits,G_ppari,G_pstop);
                    break;
                case 2 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("COM2","w");
                    sendmsg("INOUT1",MESSAGE_I,-2,G_prate,G_pbits,G_ppari,G_pstop);
                    break;
                case 3 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("COM3","w");
                    sendmsg("INOUT1",MESSAGE_I,-3,G_prate,G_pbits,G_ppari,G_pstop);
                    break;
                case 4 :
                    if (G_printer!=stdprn) fclose(G_printer);
                    G_printer=fopen("COM4","w");
                    sendmsg("INOUT1",MESSAGE_I,-4,G_prate,G_pbits,G_ppari,G_pstop);
                    break;
                default:
                    if (G_printer!=stdprn) fclose(G_printer);
                    sendmsg("OSSDEV",MESSAGE_SB,3,G_paddr);
                    G_printer=fopen("COM4","w");
                    sendmsg("INOUT1",MESSAGE_I,-4,G_prate,G_pbits,G_ppari,G_pstop);
            }
            break;
        case 'F' :
        case 'f' :
            if (G_printer!=stdprn) fclose(G_printer);
            G_printer=fopen(G_pfile,"a+");
            break;
        default  :
            if (G_printer!=stdprn) fclose(G_printer);
        	G_printer=stdprn;
    }
    prn_reset();
    RETURNV(1);
}
// printer shutdown routine
INT prn_shutdown(void)
{
	INT i;
	ENTRY(5030);
  	if (G_prnl!=NULL) {
		for (i=0;i<G_numpl;i++) {
	  		if (G_prnl[i]->s!=NULL) FREE(G_prnl[i]->s);
	  		if (G_prnl[i]   !=NULL) FREE(G_prnl[i]   );
		}
  		FREE(G_prnl);
		G_prnl=NULL;
	}
    G_numplmal=0;
	G_numpl=0;
    RETURNV(1);                 
}
void testpr(INT l,INT p,INT s,INT full)
{
	static INT up=0;
    static INT ll=0,lp=0,ls=0,cnt=0;
    if (G_printer!=stdprn) return;
    if ((!(full))&&(ll==l)&&(lp==p)&&(ls==s)) {
        cnt++;
        if (cnt<20) return;
    }
    ll=l; lp=p; ls=s; cnt=0;
    if (s>0) {
		if (!up) {
			sendmsg("OUTPUT1",MESSAGE_P,71,22,"NOPRN.BMP");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx,G_prerrboxy,"PRNBOX.BMP");
			up=1;
		}
		sendmsg("OUTPUT1",MESSAGE_S,1);
		sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+1,"%04d",p);
		sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+7,G_prerrboxy+1,"%04d",l);
	}
    switch (s) {
		case 1 :
			sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"   OK    ");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx+2,G_prerrboxy+3,"PRNOK.BMP");
			break;
		case 2 :
			sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"OFF  LINE");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx+2,G_prerrboxy+3,"PRNOFFL.BMP");
			break;
		case 3 :
			sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"NO  PAPER");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx+2,G_prerrboxy+3,"PRNNOP1.BMP");
			break;
		case 4 :
			sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"NO  PAPER");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx+2,G_prerrboxy+3,"PRNNOP2.BMP");
			break;
		case 5 :
			sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"  ERROR  ");
			sendmsg("OUTPUT1",MESSAGE_P,G_prerrboxx+2,G_prerrboxy+3,"PRNERR.BMP");
			break;
		case -1 :
			if (!G_waiting) sendmsg("OUTPUT1",MESSAGE_P,71,22,"NOPRN.BMP");
			break;
		case -2 :
			if (!G_waiting) sendmsg("OUTPUT1",MESSAGE_P,71,22,"PRNOFFL.BMP");
			break;
		case -3 :
			if (!G_waiting) sendmsg("OUTPUT1",MESSAGE_P,71,22,"PRNNOP1.BMP");
			break;
		case -4 :
			if (!G_waiting) sendmsg("OUTPUT1",MESSAGE_P,71,22,"PRNNOP2.BMP");
			break;
		case -5 :
			if (!G_waiting) sendmsg("OUTPUT1",MESSAGE_P,71,22,"PRNERR.BMP");
			break;
		default :
			if (up) {
				sendmsg("OUTPUT1",MESSAGE_ON);
				up=0;
			}
	}
}
INT flagerr(INT full)
{
	CHAR e;
    union REGS r;
	INT y,err=0;
    if (G_printer!=stdprn) return(0);
	if (G_printing==2) {
		y=G_curpline;
	} else if (G_numpl>0) {
		y=G_prnl[G_numpl-1]->y;
	} else {
		y=0;
	}
    r.x.ax=0x0200;
	r.x.dx=0x0000;
	int86(0x17,&r,&r);
    e=r.h.ah;
    if      ((e&0x20)==0x20) err=3+G_pagestyle;
	else if ((e&0x08)==0x08) err=5;
	else if ((e&0x90)==0x00) err=2;
	else                     err=1;
	if (!G_printing) err=0-err;
    testpr(y,G_pagenum,err,full);
    if ((err==1)||(err==(-1))) err=0;
    return(err);
}
INT outputform(void)
{
	PPRXYSTR tl;
	INT i;
	CHAR *s;
	G_printing=2;
	while (flagerr(0)) {
		if (sendmsg("INPUT1",MESSAGE_H)) {
			if (sendmsg("INPUT1",MESSAGE_i)==27) return(0);
		}
		sendmsg("OSSDEV",MESSAGE_d,200);
	}
    sendseq(PRS_STARTUP,0);
    sendseq(PRS_PGSETUP,0);
//	qsort(G_prnl,G_numpl,sizeof(PPRXYSTR),(qsptr)plcmp);
	G_ox=G_curpline=0;
    G_oa=G_oz=-1;
	for (i=0;i<G_numpl;i++) {
        tl=G_prnl[i];
		while (flagerr(0)) {
			if (sendmsg("INPUT1",MESSAGE_H)) {
				if (sendmsg("INPUT1",MESSAGE_i)==27) return(0);
			}
			sendmsg("OSSDEV",MESSAGE_d,200);
		}
	    if (tl->mx) G_microx=1; else G_microx=0;
	    if (tl->my) G_microy=1; else G_microy=0;
  	    movetoy(tl->y);
        if (G_ox<=tl->x) {
	  	    movetox(tl->x);
	  	    setsize(tl->sz);
	  	    setattr(tl->a);
		    s=tl->s;
		    while (*s) {
			    putprn(*(s++));
			    G_ox++;
                if (tl->sz) G_ox++;
            }
		}
	}
	while (flagerr(0)) {
		if (sendmsg("INPUT1",MESSAGE_H)) {
			if (sendmsg("INPUT1",MESSAGE_i)==27) return(0);
		}
		sendmsg("OSSDEV",MESSAGE_d,200);
	}
	preop();
	G_printing=1;
	return(1);
}
CHAR *getprname(CHAR *f)
{
    static CHAR buf[161];
    CHAR *t;
    FILE *fp;
    if ((fp=fopen(f,"r"))==NULL) return(0);
    while (fgets(buf,160,fp)!=NULL) {
        t=strtok(buf,"[");
        if ((t!=NULL)&&(*t)&&(!strncmp(t,"NAME",4))) {
            while (*t) t++;
            t++;
            while ((*t)&&((*t==' ')||(*t==9))) t++;
            t=strtok(NULL,"[]\r\n");
            if ((t!=NULL)&&(*t)) {
                fclose(fp);
                return(t);
            }
        }
    }
    fclose(fp);
    return(f);
}
INT buildplist(CHAR **list)
{
    INT i,j;
    CHAR buf[100];
    i=(INT)sendmsg("DISK",MESSAGE_T,".\\","*.prd");
    if (!i) return(0);
    for (j=0;j<i;j++) {
        sprintf(buf,"%s^%s",G_filesfd[j].n,getprname(G_filesfd[j].n));
        list[j]=STRDUP(buf);
    }
    return(i);
}
// printer control routine
LONG prn_control(INT type,va_list ap)
{
    LONG retval=1L;
    INT a,b,c,d;
    static INT resetnext=0;
	CHAR *f,tmp[180];
	ENTRY(5120);

	switch (type) {
        case MESSAGE_R :
			retval=(LONG)prn_reset();
			break;

        case MESSAGE_o :
       		if (resetnext) { prn_reset(); resetnext=0; }
			if (!G_prerror) {
            	a=va_arg(ap,INT);
            	b=va_arg(ap,INT);
            	f=va_arg(ap,CHAR *);
		    	vsprintf(tmp,f,ap);
				if (a>=0) {
					c=(INT)sendmsg("OUTPUT1",MESSAGE_T,tmp);
					if (G_righthand) {
						if (G_pprnsize) c*=2;
						a=G_ppmaxx-(a+c);
					}
				}
				retval=(LONG)prn_output(a,b,"%s",tmp);
			}
			break;

        case MESSAGE_I :
       		if (resetnext) { prn_reset(); resetnext=0; }
            prn_startup();
            break;

        case MESSAGE_i :
            a=va_arg(ap,INT);
            b=va_arg(ap,CHAR);
            c=va_arg(ap,CHAR);
            d=va_arg(ap,CHAR);
			sendmsg("COMM",MESSAGE_I,G_prntype&0x3,a,b,c,d);
            break;

        case MESSAGE_S :
       		if (resetnext) { prn_reset(); resetnext=0; }
            G_pprnsize=va_arg(ap,INT)-1;
            break;

        case MESSAGE_A :
       		if (resetnext) { prn_reset(); resetnext=0; }
            G_pprnattr=va_arg(ap,INT);
            break;

        case MESSAGE_OL :
       		if (resetnext) { prn_reset(); resetnext=0; }
            retval=1L;
			preol();
			G_ox=0;
			G_curpline++;
            break;

        case MESSAGE_OF :
       		if (resetnext) { prn_reset(); resetnext=0; }
            retval=1L;
			preop();
			G_ox=0;
			G_curpline=0;
            break;

        case MESSAGE_MY :
       		if (resetnext) { prn_reset(); resetnext=0; }
			movetoy(va_arg(ap,INT));
            retval=1L;
            break;

        case MESSAGE_MS :
            retval=1L;
			G_microx=va_arg(ap,INT);
			G_microy=va_arg(ap,INT);
            break;

        case MESSAGE_E :
       		if (resetnext) { prn_reset(); resetnext=0; }
            prn_shutdown();
            break;

        case MESSAGE_F :
       		retval=(LONG)outputform(); 
            resetnext=1;
            break;

        case MESSAGE_RP :
       		retval=(LONG)outputform();
            break;

        case MESSAGE_B :
       		if (resetnext) { prn_reset(); resetnext=0; }
            a=va_arg(ap,INT);
            b=va_arg(ap,INT);
            c=va_arg(ap,INT);
            d=va_arg(ap,INT);
			if (G_righthand) {
	            ppbox((G_ppmaxx-1)-a,b,(G_ppmaxx-1)-c,d);
			} else {
	            ppbox(a,b,c,d);
			}
            break;
        case MESSAGE_L :
       		if (resetnext) { prn_reset(); resetnext=0; }
            a=va_arg(ap,INT);
            b=va_arg(ap,INT);
            c=va_arg(ap,INT);
            d=va_arg(ap,INT);
			if (G_righthand) {
	            ppline((G_ppmaxx-1)-a,b,(G_ppmaxx-1)-c,d);
			} else {
	            ppline(a,b,c,d);
			}
            break;
		case MESSAGE_SP :
			G_printing=va_arg(ap,INT);
			G_pagestyle=va_arg(ap,INT);
			if (!G_printing) testpr(G_curpline,G_pagenum,0,1);
			break;
        case MESSAGE_GS :
          	flagerr(1);
            retval=(LONG)G_prerror;
            break;
        case MESSAGE_SS :
          	f=va_arg(ap,CHAR *);
            a=va_arg(ap,INT);
            sendseqn(f,a);
            retval=1L;
            break;
        case MESSAGE_PL :
            retval=(LONG)buildplist(va_arg(ap,CHAR **));
            break;
    }
    RETURNV(retval);
}
//___________________________________________________________________________

