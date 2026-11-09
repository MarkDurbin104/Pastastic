#define PRNDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <ctype.h>
#include <search.h>
#include "types.h"
#include "message.h"
#include "control.h"
#include "memory.h"
#include "prndev.h"
#include "config.h"

typedef int (*qsptr)(const void*, const void*);
typedef unsigned char uchar;
typedef struct {
	int   x ;
	int   y ;
	char *s ;
	uchar sz;
	uchar a ;
	uchar mx ;
	uchar my ;
} PRXYSTR;
typedef PRXYSTR *PPRXYSTR;

int prn_output(int x,int y,char *fmt,...);

PPRXYSTR *G_prnl=NULL;
int   G_numpl=0;
FILE *G_printer;
char  G_boxb[22]={'Ú','¿','À','Ù','³','Ä','Á','Â','Ã','´','Å',
                  'É','»','È','¼','º','Í','Ê','Ë','Ì','¹','Î'};
int   G_prntype=0;
FILE *G_prndev[8]={stdprn,stdprn,stdprn,stdprn,stdaux,stdaux,stdaux,stdaux};
int   G_prnnum=0;
int   G_prndevt[8]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07};
int   G_chsize=1;
int   G_emphon=1;
int   G_prerror=0;
char  *G_normtab;
extern unsigned char *G_vfontspace;
extern unsigned char *G_hfontspace;
int G_ox=0;
int G_oa=-1;
int G_oz=-1;
int G_microx=0;
int G_microy=0;
int G_prerrboxx=67;
int G_prerrboxy=14;
int G_printing=0;
int G_pagestyle=0;
void prprintf(char *fmt,...)
{
	va_list ap;
    va_start(ap,fmt);
    vfprintf(G_printer,fmt,ap);
    va_end(ap);
}
void putprn(unsigned char c)
{
	fputc(c,G_printer);
}
// printer character output routine
void ppoutch(int x,int y,int c)
{
	ENTRY(4860);
    c&=0xFF;

    if ((x>G_ppmaxx)||(y>G_ppmaxy)||(x<0)||(y<0)) RETURN;
    if (G_prn==NULL) RETURN;

    
    c|=(G_pprnattr<<12);
    c|=(G_pprnsize<<8);
    G_prn[x+G_ppmaxx*y]=c;

    G_ppcurx=x+1+(G_pprnsize>0);
    G_ppcury=y;
    if (G_ppcurx>G_ppmaxx) {
        G_ppcurx=0;
        G_ppcury++;
    }
	RETURN;
}
void ppbox(int x,int y,int x1,int y1)
{
    int i;
    int s=G_pprnsize;
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
void ppline(int x,int y,int x1,int y1)
{
    int i;
    int s=G_pprnsize;
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
void prch(unsigned char c)
{
	if (c==26) c=25; if (c==10) c=9;
	prprintf("%c",c);
}
int prchar(int pb)
{
	unsigned char c=pb&0xFF;
	ENTRY(4940);
	if (c) prch(c); else prch(' ');
	if (G_chsize) RETURNV(1);
	RETURNV(0);
}
void preol(void)
{
	ENTRY(4950);
	prprintf("\r\n");
	G_ox=0;
	RETURN;
}
void preop(void)
{
	ENTRY(4960);
   	prprintf("\r%c",12);
	G_curpline=0;
	G_ox=0;
	RETURN;
}
void movetox(int nx)
{
	if (G_microx) {
		prprintf("%c$%c%c",27,(nx*G_microx)%256,(nx*G_microx)/256);
	} else {
		if (nx<G_ox) return;
		while (nx!=G_ox) {
			putprn(' ');
			G_ox++;
		}
	}
}
void movetoy(int ny)
{
    int mov=0;
	if (G_microy) {
        if (ny<=G_curpline) return;
        mov=(ny-G_curpline)*G_microy;
        while (mov>255) { prprintf("%cJ%c",27,255); mov-=255; }
		if (mov>0) prprintf("%cJ%c",27,mov);
        G_curpline=ny;
	} else {
		if (ny<G_curpline) return;
		while (ny!=G_curpline) {
			preol();
			G_curpline++;
			G_ox=0;
		}
	}
}
void setattr(int na)
{
	if (na!=G_oa) {
        switch (na) {
            case 0 :
        		prprintf("%cH",27); // if ((G_oa&1)==1) 
        		prprintf("%c",18);  // if ((G_oa&2)==2) 
                break;
            case 1 :
        		prprintf("%cG",27); // if ((G_oa&1)!=1) 
        		prprintf("%c",18);  // if ((G_oa&2)==2) 
                break;
            case 2 :
        		prprintf("%cH",27); // if ((G_oa&1)==1) 
        		prprintf("%c",15);  // if ((G_oa&2)!=2) 
                break;
            case 3 :
        		prprintf("%cG",27); // if ((G_oa&1)!=1) 
        		prprintf("%c",15);  // if ((G_oa&2)!=2) 
                break;
        }
		G_oa=na;
	}
}
void setsize(int nz)
{
	if (G_oz!=nz) {
		switch (nz) {
			case 1 :
				prprintf("%cw0%cW1",27,27);
				break;
			case 2 :
				prprintf("%cw1%cW1",27,27);
				break;
			default :
				prprintf("%cw0%cW0",27,27);
		}
		G_oz=nz;
	}
}
void setppmode(int m)
{
	ENTRY(4980);
    G_pprnmode=m;
	RETURN;
}
// printer reset routine
int prn_reset(void)
{
	int i;
	ENTRY(5000);
	sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8," RESET ");
	for (i=0;i<G_numpl;i++) {
	  	if (G_prnl[i]->s!=NULL) FREE(G_prnl[i]->s);
	  	if (G_prnl[i]   !=NULL) FREE(G_prnl[i]   );
	}
	G_numpl=0;
	if (G_prnl!=NULL) G_prnl=REALLOC(G_prnl,sizeof(PPRXYSTR));
	sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"       ");
    RETURNV(1);
}
int plcmp(PPRXYSTR *a,PPRXYSTR *b)
{
	if ((*a)->y>(*b)->y) return(2);
	if ((*a)->y<(*b)->y) return(-2);
	if ((*a)->x>(*b)->x) return(1);
	if ((*a)->x<(*b)->x) return(-1);
	return(0);
}
int swithin(int x,int ox,int ol)
{
    return((x>=ox)&&(x<=(ox+ol)));
}
void addpline(int x,int y,char *s,uchar sz,uchar a)
{
	PPRXYSTR *tprnl;
	PPRXYSTR tl;
    static char tbuf[160];
	char *str;
    int tx,ty;
    int i;
	if (G_microx) tx=x*G_microx; else tx=x; 
	if (G_microy) ty=y*G_microy; else ty=y;
    for (i=0;i<G_numpl;i++) {
        tl=G_prnl[i];
        if ((ty==tl->y)&&(sz==tl->sz)&&(a==tl->a)) {
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
	if ((*s!=0)&&(s!=NULL)&&(x>=0)&&(y>=0)) {
		if ((str=STRDUP(s))==NULL) return;
		if ((tl=MALLOC(sizeof(PRXYSTR)))==NULL) {
			FREE(str);
			return;
		}
		tprnl=G_prnl;
		G_prnl=REALLOC(G_prnl,(G_numpl+1)*sizeof(PPRXYSTR));
		if (G_prnl==NULL) {
			G_prnl=tprnl;
			return;
		}
		G_prnl[G_numpl++]=tl;
        tl->mx=G_microx;
        tl->my=G_microy;
		tl->x=tx; 
		tl->y=ty;
		tl->s =str;
		tl->sz=sz;
		tl->a =a;
//        fprintf(stdout,"N-%04dX %04dY %02dS %02dA %s\n",tl->x,tl->y,tl->sz,tl->a,tl->s);
		qsort(G_prnl,G_numpl,sizeof(PPRXYSTR),(qsptr)plcmp);
	}
}
// printer output routine
int prn_output(int x,int y,char *fmt,...)
{
    char str[140],*s;
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
	      	for (x=0;x<y;x++) prchar(*(s++));
			break;
		default   :
			addpline(x,y,s,G_pprnsize,G_pprnattr);
	}
    RETURNV(1);
}
// printer startup routine
int prn_startup(int type)
{
	ENTRY(5020);
    if (G_prnl!=NULL) prn_shutdown();
	G_prnl=MALLOC(sizeof(PPRXYSTR));
	switch (G_prnnum) {
		case STDPRN1 :
//			G_printer=fopen("PRINTER.TST","wb");
		    G_printer=stdprn;					
			break;								
		case STDPRN2 :
			G_printer=fopen("lpt1","wb");		
			break;								
		case STDPRN3 :
			G_printer=fopen("lpt3","wb");		
			break;								
		case STDPRN4 :
			G_printer=fopen("lpt4","wb");
			break;								
		case STDAUX1 :
			sendmsg("COMM",'I',0,9600,8,'n',1);
		    G_printer=stdaux;
			break;								
		case STDAUX2 :
			sendmsg("COMM",'I',1,9600,8,'n',1);
			G_printer=fopen("com2","wb");
			break;								
		case STDAUX3 :
			sendmsg("COMM",'I',2,9600,8,'n',1);
			G_printer=fopen("com3","wb");
			break;								
		case STDAUX4 :
			sendmsg("COMM",'I',7,9600,8,'n',1);
			G_printer=fopen("com4","wb");
			break;								
	}
	G_prndev[G_prnnum]=G_printer;
	G_prndevt[G_prnnum]=G_prnnum|type;

/*    if (G_prn!=NULL) FREE(G_prn);
    G_prn=MALLOC(G_ppmaxx*G_ppmaxy*sizeof(int));
    if (G_prn==NULL) {
		G_ppmaxx=0;
		G_ppmaxy=0;
	    RETURNV(0);
	} */
    prn_reset();
    RETURNV(1);
}
// printer shutdown routine
int prn_shutdown(void)
{
	int i;
	ENTRY(5030);
  	if (G_prnl!=NULL) {
		for (i=0;i<G_numpl;i++) {
	  		if (G_prnl[i]->s!=NULL) FREE(G_prnl[i]->s);
	  		if (G_prnl[i]   !=NULL) FREE(G_prnl[i]   );
		}
  		FREE(G_prnl);
		G_prnl=NULL;
	}
	G_numpl=0;
	switch (G_prnnum) {
		case STDPRN2 : case STDPRN3 : case STDPRN4 :
		case STDAUX2 : case STDAUX3 : case STDAUX4 :
		    fclose(G_printer);
			break;
	}
    RETURNV(1);                 
}
void testpr(int l,int p,int s)
{
	static int up=0;
    if (s>0) {
		if (!up) {
			sendmsg("OUTPUT1",'P',71,22,"NOPRN.BMP");
			sendmsg("OUTPUT1",'P',G_prerrboxx,G_prerrboxy,"PRNBOX.BMP");
			up=1;
		}
		sendmsg("OUTPUT1",'S',1);
		sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+1,"%04d",p);
		sendmsg("OUTPUT1",'o',G_prerrboxx+7,G_prerrboxy+1,"%04d",l);
	}
    switch (s) {
		case 1 :
			sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"   OK    ");
			sendmsg("OUTPUT1",'P',G_prerrboxx+2,G_prerrboxy+3,"PRNOK.BMP");
			break;
		case 2 :
			sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"OFF  LINE");
			sendmsg("OUTPUT1",'P',G_prerrboxx+2,G_prerrboxy+3,"PRNOFFL.BMP");
			break;
		case 3 :
			sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"NO  PAPER");
			sendmsg("OUTPUT1",'P',G_prerrboxx+2,G_prerrboxy+3,"PRNNOP1.BMP");
			break;
		case 4 :
			sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"NO  PAPER");
			sendmsg("OUTPUT1",'P',G_prerrboxx+2,G_prerrboxy+3,"PRNNOP2.BMP");
			break;
		case 5 :
			sendmsg("OUTPUT1",'o',G_prerrboxx+2,G_prerrboxy+8,"  ERROR  ");
			sendmsg("OUTPUT1",'P',G_prerrboxx+2,G_prerrboxy+3,"PRNERR.BMP");
			break;
		case -1 :
			if (!G_waiting) sendmsg("OUTPUT1",'P',71,22,"NOPRN.BMP");
			break;
		case -2 :
			if (!G_waiting) sendmsg("OUTPUT1",'P',71,22,"PRNOFFL.BMP");
			break;
		case -3 :
			if (!G_waiting) sendmsg("OUTPUT1",'P',71,22,"PRNNOP1.BMP");
			break;
		case -4 :
			if (!G_waiting) sendmsg("OUTPUT1",'P',71,22,"PRNNOP2.BMP");
			break;
		case -5 :
			if (!G_waiting) sendmsg("OUTPUT1",'P',71,22,"PRNERR.BMP");
			break;
		default :
			if (up) {
				sendmsg("OUTPUT1",'ON');
				up=0;
			}
	}
}
int flagerr(void)
{
	char e;
	int y,err=0;
//    return(0);
	if (G_printing==2) {
		y=G_curpline;
	} else if (G_numpl>0) {
		y=G_prnl[G_numpl-1]->y;
	} else {
		y=0;
	}
	asm mov ax,0x0200
	asm mov dx,0x0000
	asm int 0x17
	asm mov e,ah
//    sendmsg("OUTPUT1",'o',0,0,"%02X",e&0xFF);

    if      ((e&0x20)==0x20) err=3+G_pagestyle;
	else if ((e&0x08)==0x08) err=5;
	else if ((e&0x90)==0x00) err=2;
	else                     err=1;
	if (!G_printing) err=0-err;
    testpr(y,G_pagenum,err);
    if ((err==1)||(err==(-1))) err=0;
/*
	if (G_printing) {
		if ((e&0x08)!=0x00) testpr(y,G_pagenum,err=5);
		else if ((e&0x10)!=0x10) testpr(y,G_pagenum,err=2);
		else if ((e&0x20)==0x20) testpr(y,G_pagenum,err=(3+G_pagestyle));
		else testpr(y,G_pagenum,1);
	} else {
		if ((e&0x08)!=0x00) testpr(y,G_pagenum,err=-5);
		else if ((e&0x10)!=0x10) testpr(y,G_pagenum,err=-2);
		else if ((e&0x20)==0x20) testpr(y,G_pagenum,err=0-(3+G_pagestyle));
		else testpr(y,G_pagenum,-1);
	}
*/
return(err);
}
int outputform(void)
{
	PPRXYSTR tl;
	int i;
	char *s;
	G_printing=2;
	prprintf("%c[\\%c%c%c%c%c%c%cl%c%cC%c",27,4,0,0,0,0,180,27,0,27,55);
	G_ox=G_curpline=0;
    G_oa=G_oz=-1;
	for (i=0;i<G_numpl;i++) {
        tl=G_prnl[i];
//        fprintf(stdout,"Fin - %04dX %04dY %02dS %02dA %s\n",tl->x,tl->y,tl->sz,tl->a,tl->s);
		while (flagerr()) {
			if (sendmsg("INPUT1",'H')) {
				if (sendmsg("INPUT1",'i')==27) return(0);
			}
			delay(200);
		}
        if (G_ox<=tl->x) {
		    if (tl->mx) G_microx=1; else G_microx=0; //tl->mx;
		    if (tl->my) G_microy=1; else G_microy=0; //tl->my;
	  	    movetoy(tl->y);
	  	    movetox(tl->x);
	  	    setattr(tl->a);
	  	    setsize(tl->sz);
		    s=tl->s;
		    while (*s) {
			    putprn(*(s++));
			    G_ox++;
                if (tl->sz) G_ox++;
            }
		}
	}
	preop();
	G_printing=1;
	return(1);
}
int prn_control0(int type,va_list ap) { ENTRY(5040); G_prnnum=0; RETURNV(prn_control(type,ap)); }
int prn_control1(int type,va_list ap) { ENTRY(5050); G_prnnum=1; RETURNV(prn_control(type,ap)); }
int prn_control2(int type,va_list ap) { ENTRY(5060); G_prnnum=2; RETURNV(prn_control(type,ap)); }
int prn_control3(int type,va_list ap) { ENTRY(5070); G_prnnum=3; RETURNV(prn_control(type,ap)); }
int prn_control4(int type,va_list ap) { ENTRY(5080); G_prnnum=4; RETURNV(prn_control(type,ap)); }
int prn_control5(int type,va_list ap) { ENTRY(5090); G_prnnum=5; RETURNV(prn_control(type,ap)); }
int prn_control6(int type,va_list ap) { ENTRY(5100); G_prnnum=6; RETURNV(prn_control(type,ap)); }
int prn_control7(int type,va_list ap) { ENTRY(5110); G_prnnum=7; RETURNV(prn_control(type,ap)); }

// printer control routine
int prn_control(int type,va_list ap)
{
    int retval=1;
    int a,b,c,d;
    static int resetnext=0;
	char *f,tmp[180];
	ENTRY(5120);

	flagerr();
    if ((resetnext!=0)&&(type!='RP')) {
   		prn_reset();
        resetnext=0;
    }
	G_printer=G_prndev[G_prnnum];
	if ((G_printer==NULL)&&(type!='I')) RETURNV(1);
	G_prntype=G_prndevt[G_prnnum];

	switch (type) {
        case 'R' :
			retval=prn_reset();
			break;

        case 'o' :
			if (!G_prerror) {
            	a=va_arg(ap,int);
            	b=va_arg(ap,int);
            	f=va_arg(ap,char *);
		    	vsprintf(tmp,f,ap);
				if (a>=0) {
					c=sendmsg("OUTPUT1",'T',tmp);
					if (G_righthand) {
						if (G_pprnsize) c*=2;
						a=G_ppmaxx-(a+c);
					}
				}
				retval=prn_output(a,b,"%s",tmp);
			}
			break;

        case 'I' :
            prn_startup(va_arg(ap,int));
            break;

        case 'i' :
            a=va_arg(ap,int);
            b=va_arg(ap,char);
            c=va_arg(ap,char);
            d=va_arg(ap,char);
			sendmsg("COMM",'I',G_prntype&0x3,a,b,c,d);
            break;

        case 'S' :
            G_pprnsize=va_arg(ap,int)-1;
            break;

        case 'A' :
            G_pprnattr=va_arg(ap,int);
            break;

        case 'OL' :
            retval=1;
			preol();
			G_ox=0;
			G_curpline++;
            break;

        case 'OF' :
            retval=1;
			preop();
			G_ox=0;
			G_curpline=0;
            break;

        case 'MY' :
            retval=va_arg(ap,int);
//			sendmsg("OUTPUT1",'o',0,0,"%d",retval);
			movetoy(retval);
            retval=1;
            break;

        case 'MS' :
            retval=1;
			G_microx=va_arg(ap,int);
			G_microy=va_arg(ap,int);
            break;

        case 'E' :
            prn_shutdown();
            break;

        case 'F' :
//				if ((G_prntype&0xF0)!=GRAPHIC) dlcset();
       		retval=outputform(); 
            resetnext=1;
            break;

        case 'RP' :
       		retval=outputform();
            break;

/*
        case 'D' :
            a=va_arg(ap,int);
			dlcset();
            for (b=0;(b<a)&&(retval==1);b++) retval=outputform();
            prn_reset();
            break;
*/
        case 'B' :
            a=va_arg(ap,int);
            b=va_arg(ap,int);
            c=va_arg(ap,int);
            d=va_arg(ap,int);
			if (G_righthand) {
	            ppbox((G_ppmaxx-1)-a,b,(G_ppmaxx-1)-c,d);
			} else {
	            ppbox(a,b,c,d);
			}
            break;
        case 'L' :
            a=va_arg(ap,int);
            b=va_arg(ap,int);
            c=va_arg(ap,int);
            d=va_arg(ap,int);
			if (G_righthand) {
	            ppline((G_ppmaxx-1)-a,b,(G_ppmaxx-1)-c,d);
			} else {
	            ppline(a,b,c,d);
			}
            break;
		case 'SP' :
			G_printing=va_arg(ap,int);
			G_pagestyle=va_arg(ap,int);
			if (!G_printing) testpr(G_curpline,G_pagenum,0);
			break;
/*
        case 'C' :
			if ((G_prntype&0x0F)==STDAUX1) {
            	f=va_arg(ap,char *);
            	s=va_arg(ap,char *);
				if (*f>'6') RETURNV(0);
				prprintf("%ck%c%s%c",29,*f-'0',s,0);
			}
			retval=1;
            break;
        case 'M' :
            setppmode(va_arg(ap,int));
            break;
*/
        case 'GS' :
            retval=G_prerror;
            break;
    }
    RETURNV(retval);
}
//___________________________________________________________________________

