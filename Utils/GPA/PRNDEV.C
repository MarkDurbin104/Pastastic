#define PRNDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
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
#include "prndev.h"
#include "config.h"

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
UCHAR G_doubmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
FILE *G_printer;
CHAR  G_boxb[22]={'Ú','¿','À','Ù','³','Ä','Á','Â','Ã','´','Å',
                  'É','»','È','¼','º','Í','Ê','Ë','Ì','¹','Î'};
INT   G_prntype=0;
FILE *G_prndev[8]={stdprn,stdprn,stdprn,stdprn,stdaux,stdaux,stdaux,stdaux};
INT   G_prnnum=0;
INT   G_prndevt[8]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07};
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
void prprintf(CHAR *fmt,...)
{
	va_list ap;
    va_start(ap,fmt);
//    vfprintf(stdout,fmt,ap);
    vfprintf(G_printer,fmt,ap);
    va_end(ap);
}
void putprn(UCHAR c)
{
//	fputc(c,stdout);
	fputc(c,G_printer);
}
// printer character output routine
void ppoutch(INT x,INT y,INT c)
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
void buildtxtab(void)
{
	UCHAR *font;
	INT i,j=32;
	ENTRY(4890);
	if (!sendmsg("FARSI",MESSAGE_f,&font)) {
		for (i=0;i<256;i++) G_cmap[i]=i;
	} else {
		for (i=0;i<256;i++) {
			switch (*(font+i)&0xF0) {
				case 0x00 :
					G_cmap[i]=i;
					break;
				case 0x10 :
					G_cmap[i]=0x100|(j++);
					break;
				case 0x20 :
					G_cmap[i]=*(font+768+i);
					break;
			}
		}
	}
	RETURN;
}
void dlcset(void)
{
	UCHAR *font,*f,fb,sb,mb,mask,fa,sa,ma;
	INT i,j,k;
	ENTRY(4900);
	switch (G_prntype&0x0F) {
		case STDAUX1 :
    		prprintf("%c3%c\n",27,0);
			prprintf("%c!%c",27,1);
			sendmsg("VGA",MESSAGE_f,&font);
			for (k=0;k<256;k++) {
	  			if ((G_cmap[k]&0x100)!=0) {
					fb=G_cmap[k]&0xFF;
					prprintf("%c&%c%c%c%c",27,3,fb,fb,8);
					mask=0x80;
					for (i=0;i<8;i++) {
						f=font+k*16;
						fb=sb=0;
						for (j=0;j<8;j++) if ((*(f++)&mask)!=0) fb|=0x80>>j;
						for (j=0;j<8;j++) if ((*(f++)&mask)!=0) sb|=0x80>>j;
						mask>>=1;
						prprintf("%c%c%c",fb,sb,0);
					}
				}
			}
			break;
		case STDPRN1 :
    		prprintf("%c:%c%c%c\n",27,0,1,0);
			sendmsg("VGA",MESSAGE_f,&font);
			for (k=0;k<256;k++) {
	  			if ((G_cmap[k]&0x100)!=0) {
					fb=G_cmap[k]&0xFF;
					prprintf("%c&%c%c%c%c%c%c",27,0,fb,fb,0,36,0);
					mask=0x80;
					for (i=0;i<8;i++) {
						f=font+k*16;
						fb=mb=sb=0;
						for (j=0;j<4;j++)  if ((*(f++)&mask)!=0) fb|=0x80>>j;
						for (j=4;j<8;j+=2) if ((*(f++)&mask)!=0) fb|=0x80>>j;
						for (j=0;j<8;j+=2) if ((*(f++)&mask)!=0) mb|=0x80>>j;
						for (j=0;j<4;j+=2) if ((*(f++)&mask)!=0) sb|=0x80>>j;
						for (j=4;j<8;j++)  if ((*(f++)&mask)!=0) sb|=0x80>>j;
						mask>>=1;
						fa=(fb>>1);
						ma=(mb>>1);
						sa=(sb>>1);
						fa=(fa^fb)&fa;
						ma=(ma^mb)&ma;
						sa=(sa^sb)&sa;
						if (fa==26) fa=25;
						if (fb==26) fb=25;
						if (ma==26) ma=25;
						if (mb==26) mb=25;
						if (sa==26) sa=25;
						if (sb==26) sb=25;
						if (fa==10) fa=9;
						if (fb==10) fb=9;
						if (ma==10) ma=9;
						if (mb==10) mb=9;
						if (sa==10) sa=9;
						if (sb==10) sb=9;
						if ((i==0)||(i==7)) {
							prprintf("%c%c%c",fb,mb,sb);
							prprintf("%c%c%c",fa,ma,sa);
						}
						prprintf("%c%c%c",fb,mb,sb);
						prprintf("%c%c%c",fa,ma,sa);
						prprintf("%c%c%c",fb,mb,sb);
						prprintf("%c%c%c",fa,ma,sa);
					}
				}
			}
			break;
		case STDPRN2 :
		case STDPRN3 :
		case STDPRN4 :
		case STDAUX2 :
		case STDAUX3 :
		case STDAUX4 :
			break;
	}
	RETURN;
}
UINT translate(UINT c)
{
	static INT cset=(-1);
	INT e=0;
	ENTRY(4910);

	if ((G_cmap[c]&0x100)!=0) e=1;
	c=G_cmap[c]&0xFF;
	G_emphon=e*8+1;

	switch (G_prntype&0x0F) {
		case STDPRN1 :
			if (cset!=e) {
				cset=e;
//				prprintf("%c%c%c%c%c",27,'F'-e,27,37,e);
				prprintf("%c%c%c",27,37,e);
			}
			break;
		case STDAUX1 :
			if (cset!=e) {
				cset=e;
				prprintf("%c%c%c",27,37,e);
        		switch (G_chsize) {
            		case 0 : prprintf("%c!%c",27,0x00|G_emphon); break;
            		case 1 : prprintf("%c!%c",27,0x20|G_emphon); break;
            		case 2 : prprintf("%c!%c",27,0x30|G_emphon); break;
        		}
       		}
			break;
		case STDPRN2 :
		case STDPRN3 :
		case STDPRN4 :
		case STDAUX2 :
		case STDAUX3 :
		case STDAUX4 :
			break;
	}
    RETURNV(c);
}
LONG getfofs(UCHAR **s,INT hgt,INT wid)
{
	LONG ret=0L,sw=hgt*(wid-1),lw=hgt*wid;
	UCHAR *t=*s,a;
	(*s)++;

	a=*t;
	if (a<0x80) return(a*sw);
								 ret=256L*sw;
	if       (a<0xA4)			 ret+=(157L*(a-0xA1))*lw;
	else if  (a<0xC7) 			 ret+=(157L*(a-0xA4))*lw+(408L*lw);
	else if ((a>0xC8)&&(a<0xFA)) ret+=(157L*(a-0xC9))*lw+(5809L*lw);
	else return(-1L);

	a=*(++t); (*s)++;
	if ((a<0x40)||((a>0x7F)&&(a<0xa1))) return(-1L);
	a-=0x40; if (a>0x3F) a-=0x22;
	lw*=a;
	return(ret+lw);
}
void prch(UCHAR c)
{
	if (c==26) c=25; if (c==10) c=9;
	prprintf("%c",c);
}
void prgln(UCHAR *str,INT len)
{
 	CHAR *font=NULL,*f;
	LONG base;
	UCHAR tmp[24*3];
	INT i,j,k,m;
//	INT w,h;
	UCHAR mask=0x80;
	UCHAR o[3],*s=str,*t;
	ENTRY(4920);
/*	switch (G_chsize) {
		case 1 : h=1; w=2; break;
		case 2 : h=2; w=2; break;
		default: h=1; w=1;
	}*/
	switch (G_prntype&0x0F) {
		case STDPRN1 :
			sendmsg("VGA",MESSAGE_f,&font);
			for (i=0;i<24;i++) {
				str=s;
				prprintf("%c",0x11);
				m=0;
				for (k=0;k<len;k++) {
					t=str;
//					if ((base=getfofs(&str,24,3))>=0) {
//						if (str==t+2) k++;
//						j=3;
//						if (base<=(256L*48)) j--;
//						restpblk(font,tmp,base,24*j);
//						prch(tmp[i*j]);
//						prch(tmp[i*j+1]);
//						if (j>2) prch(tmp[i*j+2]);
//						m+=j;
//					}
			   	}
				for (k=m;k<48;k++) prch(0);
			}
			break;
		case STDPRN2 :
		case STDPRN3 :
		case STDPRN4 :
		case STDAUX1 :
		case STDAUX2 :
		case STDAUX3 :
			sendmsg("VGA",MESSAGE_f,&font);
			prprintf("%c*%c%c%c",27,32,(len*8)%256,(len*8)/256);
			for (k=0;k<len;k++) {
				mask=0x80;
				for (i=0;i<8;i++) {
					f=font+(*(str+k)*16);
					o[0]=0;
					for (j=0;j<8;j++) {
						if ((*f&mask)!=0) o[0]|=0x80>>j;
						f++;
					}
					o[1]=0;
					for (;j<16;j++) {
						if ((*f&mask)!=0) o[1]|=0x80>>(j-8);
						f++;
					}
					o[2]=0;
					mask>>=1;
					prprintf("%c%c%c",o[0],o[1],o[2]);
//					if (w==2) prprintf("%c%c%c",o[0],o[1],o[2]);
				}
			}
//    		prprintf("%cJ%c\r",27,16);  //micro line space
    		prprintf("%c3%c\n",27,1);  //micro line space
			break;
		case STDAUX4 :
			sendmsg("VGA",MESSAGE_f,&font);
			prprintf("%c*%c%c%c",27,0,(len*8)%256,(len*8)/256);
			for (k=0;k<len;k++) {
				mask=0x80;
				for (i=0;i<8;i++) {
					f=font+(*(str+k)*16);
					o[0]=0;
					for (j=0;j<8;j++) if ((*(f++)&mask)!=0) o[0]|=0x80>>j;
					mask>>=1;
					prprintf("%c",o[0]);
				}
			}
    		prprintf("%c3%c\n",27,32);  //micro line space
			prprintf("%c*%c%c%c",27,0,(len*8)%256,(len*8)/256);
			for (k=0;k<len;k++) {
				mask=0x80;
				for (i=0;i<8;i++) {
					f=font+(*(str+k)*16)+8;
					o[0]=0;
					for (j=0;j<8;j++) if ((*(f++)&mask)!=0) o[0]|=0x80>>j;
					mask>>=1;
					prprintf("%c",o[0]);
				}
			}
    		prprintf("%c3%c\n",27,32);  //micro line space
			break;
	}
RETURN;
}
void printch(UCHAR c)
{
	ENTRY(4930);

	switch (G_prntype&0xF0) {
		case STANDARD :
			putprn(c);
			break;
		case TRANSLATE :
			putprn(translate(c));
			break;
		case GRAPHIC :
//			gconvchar(c,G_chsize);
			break;
		case MIXED   :
			sendmsg("FARSI",MESSAGE_f,&G_normtab);
			if ((G_normtab[c]&0xF0)!=0)
				putprn(c);
//			else
//				gconvchar(c,G_chsize);
			break;
	}
	RETURN;
}
INT prchar(INT pb)
{
	UCHAR c=pb&0xFF;
	UCHAR s=(pb>>8)&0x0F;
	ENTRY(4940);
	switch (G_prntype&0x0F) {
		case STDPRN1 :
			break;								
		case STDAUX4 :
    		if (G_chsize!=s) {
        		G_chsize=s;
        		switch (G_chsize) {
            		case 0 : prprintf("%c!%c",27,0x00|G_emphon); break;
            		case 1 : prprintf("%c!%c",27,0x20|G_emphon); break;
            		case 2 : prprintf("%c!%c",27,0x30|G_emphon); break;
        		}
    		}
			break;								
		case STDPRN2 :
    		if (G_chsize!=s) {
		        switch (G_chsize) {
		             case 1 : prprintf("%cW0",27);        break;
		             case 2 : prprintf("%cW0%cw0",27,27); break;
		        }
        		G_chsize=s;
        		switch (G_chsize) {
		             case 1 : prprintf("%cW1",27);        break;
		             case 2 : prprintf("%cW1%cw1",27,27); break;
        		}
    		}
			break;								
		case STDPRN3 :
    		if (G_chsize!=s) {
		        switch (G_chsize) {
		             case 1 : prprintf("%c",0x0F);        break;
		             case 2 : prprintf("%c%c",0x13,0x0F); break;
		        }
        		G_chsize=s;
        		switch (G_chsize) {
		             case 1 : prprintf("%c",0x0E);        break;
		             case 2 : prprintf("%c%c",0x12,0x0E); break;
        		}
    		}
            break;
		case STDPRN4 :
		case STDAUX1 :
		case STDAUX2 :
		case STDAUX3 :
			break;								
	}
	if (c) printch(c); else printch(' ');

	if (G_chsize) RETURNV(1);
	RETURNV(0);
}
void preol(void)
{
	ENTRY(4950);
	switch (G_prntype&0x0F) {
		case STDPRN2 :
		case STDPRN1 :
			prprintf("\r\n");
			break;
		case STDPRN3 :
		case STDPRN4 :
			prprintf("\n");
			break;
		case STDAUX1 :
		case STDAUX2 :
		case STDAUX3 :
		case STDAUX4 :
			if (G_chsize!=0) {
				prprintf("%c!%c\n",27,0x09);
				G_chsize=0;
			} else {
				prprintf("\n");
			}
//    		prprintf("%cJ%c\r",27,18);  micro line space
			break;
	}
	G_ox=0;
	RETURN;
}
void preop(void)
{
	ENTRY(4960);
	if ((G_prntype&0x0F)==STDAUX4)
		prprintf("%c3%c\n",27,40);  // default micro line space
	if ((G_prntype&0x0F)==STDPRN3) {
    	prprintf("%c",0x16);
	} else {
    	prprintf("\r%c",12);
	}
	G_curpline=0;
	G_ox=0;
	RETURN;
}
void movetox(INT nx)
{
	if (G_microx) {
//		prprintf("%c*p%dX",27,5*nx*G_microx);
		prprintf("%c$%c%c",27,(nx*G_microx)%256,(nx*G_microx)/256);
	} else {
		if (nx<G_ox) return;
		while (nx!=G_ox) {
			putprn(' ');
			G_ox++;
		}
	}
}
void movetoy(INT ny)
{
    INT mov=0;
	if (G_microy) {
//		prprintf("%c*p%dY",27,5*ny*G_microy);
        if (ny<=G_curpline) return;
        mov=(ny-G_curpline)*G_microy;
        while (mov>255) { prprintf("%cJ%c",27,255); mov-=255; }
		if (mov>0) prprintf("%cJ%c",27,mov);
		G_ox=0;
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
void setattr(INT na)
{
	if (na!=G_oa) {
// 		prprintf("%c(s%dB",27,na*3);
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
void setsize(INT nz)
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
/*
INT outputform(void)
{
    INT x,y,w;
	UCHAR str[255];
	UCHAR *font;
	ENTRY(4970);
	G_chsize=0;
    if (G_prn==NULL) RETURNV(0);
    for (y=0;y<G_ppmaxy;y++) {
        for (w=G_ppmaxx-1;w>=0;w--) {
			if ((G_prn[w+(y*G_ppmaxx)]&0xFF)!=0) break;
		}
		if ((G_prntype&0xF0)==GRAPHIC) {
			sendmsg("OUTPUT1",MESSAGE_f,&font);
			if (font[strlen(font)-1]=='3') {
				G_chsize=0; //((G_prn[w+(y*G_ppmaxx)]>>8)&0x0F);
	        	for (x=0;x<w+1;x++) {
					str[x]=G_prn[x+(y*G_ppmaxx)]&0xFF;
				}
				prgln((UCHAR *)str,x);
			} else {
	        	for (x=0;x<w+1;x++) {
					if (prchar(G_prn[x+(y*G_ppmaxx)])) x++;
	        	}
				preol();
			}
		} else {
	        for (x=0;x<w+1;x++) {
				if (prchar(G_prn[x+(y*G_ppmaxx)])) x++;
	        }
			preol();
		}
 		if (sendmsg("INPUT1",MESSAGE_H)) {
// 			preop();
 			sendmsg("INPUT1",MESSAGE_i);
// 			RETURNV(0);
 		}
    }
	preop();
	RETURNV(1);
}
*/
void setppmode(INT m)
{
	ENTRY(4980);
    G_pprnmode=m;
	RETURN;
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
	G_numpl=0;
	if (G_prnl!=NULL) G_prnl=REALLOC(G_prnl,sizeof(PPRXYSTR));
	sendmsg("OUTPUT1",MESSAGE_o,G_prerrboxx+2,G_prerrboxy+8,"       ");
    RETURNV(1);
}
INT plcmp(PPRXYSTR *a,PPRXYSTR *b)
{
	if ((*a)->y>(*b)->y) return(2);
	if ((*a)->y<(*b)->y) return(-2);
	if ((*a)->x>(*b)->x) return(1);
	if ((*a)->x<(*b)->x) return(-1);
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
			if ((G_prntype&0xF0)==GRAPHIC) {
				G_chsize=G_pprnsize;
				prgln((UCHAR *)s,y);
			} else {
	        	for (x=0;x<y;x++) prchar(*(s++));
			}
			break;
		default   :
			addpline(x,y,s,G_pprnsize,G_pprnattr);
	}
    RETURNV(1);
}
// printer startup routine
INT prn_startup(INT type)
{
	ENTRY(5020);
	buildtxtab();
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
			sendmsg("COMM",MESSAGE_I,0,9600,8,'n',1);
		    G_printer=stdaux;
			break;								
		case STDAUX2 :
			sendmsg("COMM",MESSAGE_I,1,9600,8,'n',1);
			G_printer=fopen("com2","wb");
			break;								
		case STDAUX3 :
			sendmsg("COMM",MESSAGE_I,2,9600,8,'n',1);
			G_printer=fopen("com3","wb");
			break;								
		case STDAUX4 :
			sendmsg("COMM",MESSAGE_I,7,9600,8,'n',1);
			G_printer=fopen("com4","wb");
			break;								
	}
	G_prndev[G_prnnum]=G_printer;
	G_prndevt[G_prnnum]=G_prnnum|type;

/*    if (G_prn!=NULL) FREE(G_prn);
    G_prn=MALLOC(G_ppmaxx*G_ppmaxy*sizeof(INT));
    if (G_prn==NULL) {
		G_ppmaxx=0;
		G_ppmaxy=0;
	    RETURNV(0);
	} */
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
	G_numpl=0;
	switch (G_prnnum) {
		case STDPRN2 : case STDPRN3 : case STDPRN4 :
		case STDAUX2 : case STDAUX3 : case STDAUX4 :
		    fclose(G_printer);
			break;
	}
    RETURNV(1);                 
}
void testpr(INT l,INT p,INT s)
{
	static INT up=0;
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
INT flagerr(void)
{
	CHAR e;
    union REGS r;
	INT y,err=0;
//    return(0);
	if (G_printing==2) {
		y=G_curpline;
	} else if (G_numpl>0) {
		y=G_prnl[G_numpl-1]->y;
	} else {
		y=0;
	}
//asm {
//    mov ax,0x200
//    mov dx,0
//    int 0x17
//    mov e,ah
//}
    r.x.ax=0x0200;
	r.x.dx=0x0000;
	int86(0x17,&r,&r);
    e=r.h.ah;
    if      ((e&0x20)==0x20) err=3+G_pagestyle;
	else if ((e&0x08)==0x08) err=5;
	else if ((e&0x90)==0x00) err=2;
	else                     err=1;
	if (!G_printing) err=0-err;
    testpr(y,G_pagenum,err);
    if ((err==1)||(err==(-1))) err=0;
//    sendmsg("OUTPUT1",MESSAGE_o,0,0,"%02X %d",e&0xFF,err);
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
INT outputform(void)
{
	PPRXYSTR tl;
	INT i;
	CHAR *s;
	G_printing=2;
	prprintf("%c[\\%c%c%c%c%c%c%cl%c%cC%c",27,4,0,0,0,0,180,27,0,27,55);
	G_ox=G_curpline=0;
    G_oa=G_oz=-1;
	for (i=0;i<G_numpl;i++) {
        tl=G_prnl[i];
//        fprintf(stdout,"Fin - %04dX %04dY %02dS %02dA %s\n",tl->x,tl->y,tl->sz,tl->a,tl->s);
		while (flagerr()) {
			if (sendmsg("INPUT1",MESSAGE_H)) {
				if (sendmsg("INPUT1",MESSAGE_i)==27) return(0);
			}
			delay(200);
		}
	    if (tl->mx) G_microx=1; else G_microx=0;
	    if (tl->my) G_microy=1; else G_microy=0;
  	    movetoy(tl->y);
        if (G_ox<=tl->x) {
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
LONG prn_control0(INT type,va_list ap) { ENTRY(5040); G_prnnum=0; RETURNV(prn_control(type,ap)); }
LONG prn_control1(INT type,va_list ap) { ENTRY(5050); G_prnnum=1; RETURNV(prn_control(type,ap)); }
LONG prn_control2(INT type,va_list ap) { ENTRY(5060); G_prnnum=2; RETURNV(prn_control(type,ap)); }
LONG prn_control3(INT type,va_list ap) { ENTRY(5070); G_prnnum=3; RETURNV(prn_control(type,ap)); }
LONG prn_control4(INT type,va_list ap) { ENTRY(5080); G_prnnum=4; RETURNV(prn_control(type,ap)); }
LONG prn_control5(INT type,va_list ap) { ENTRY(5090); G_prnnum=5; RETURNV(prn_control(type,ap)); }
LONG prn_control6(INT type,va_list ap) { ENTRY(5100); G_prnnum=6; RETURNV(prn_control(type,ap)); }
LONG prn_control7(INT type,va_list ap) { ENTRY(5110); G_prnnum=7; RETURNV(prn_control(type,ap)); }

// printer control routine
LONG prn_control(INT type,va_list ap)
{
    INT retval=1;
    INT a,b,c,d;
    static INT resetnext=0;
	CHAR *f,tmp[180];
	ENTRY(5120);

	flagerr();
    if ((resetnext!=0)&&(type!=MESSAGE_RP)) {
        printf("Last Page took %d lines\n",G_numpl);
   		prn_reset();
        resetnext=0;
    }
	G_printer=G_prndev[G_prnnum];
	if ((G_printer==NULL)&&(type!=MESSAGE_I)) RETURNV(1);
	G_prntype=G_prndevt[G_prnnum];

	switch (type) {
        case MESSAGE_R :
			retval=prn_reset();
			break;

        case MESSAGE_o :
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
				retval=prn_output(a,b,"%s",tmp);
			}
			break;

        case MESSAGE_I :
            prn_startup(va_arg(ap,INT));
            break;

        case MESSAGE_i :
            a=va_arg(ap,INT);
            b=va_arg(ap,CHAR);
            c=va_arg(ap,CHAR);
            d=va_arg(ap,CHAR);
			sendmsg("COMM",MESSAGE_I,G_prntype&0x3,a,b,c,d);
            break;

        case MESSAGE_S :
            G_pprnsize=va_arg(ap,INT)-1;
            break;

        case MESSAGE_A :
            G_pprnattr=va_arg(ap,INT);
            break;

        case MESSAGE_OL :
            retval=1;
			preol();
			G_ox=0;
			G_curpline++;
            break;

        case MESSAGE_OF :
            retval=1;
			preop();
			G_ox=0;
			G_curpline=0;
            break;

        case MESSAGE_MY :
            retval=va_arg(ap,INT);
//			sendmsg("OUTPUT1",MESSAGE_o,0,0,"%d",retval);
			movetoy(retval);
            retval=1;
            break;

        case MESSAGE_MS :
            retval=1;
			G_microx=va_arg(ap,INT);
			G_microy=va_arg(ap,INT);
            break;

        case MESSAGE_E :
            prn_shutdown();
            break;

        case MESSAGE_F :
//				if ((G_prntype&0xF0)!=GRAPHIC) dlcset();
       		retval=outputform(); 
            resetnext=1;
            break;

        case MESSAGE_RP :
       		retval=outputform();
            break;

/*
        case MESSAGE_D :
            a=va_arg(ap,INT);
			dlcset();
            for (b=0;(b<a)&&(retval==1);b++) retval=outputform();
            prn_reset();
            break;
*/
        case MESSAGE_B :
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
			if (!G_printing) testpr(G_curpline,G_pagenum,0);
			break;
/*
        case MESSAGE_C :
			if ((G_prntype&0x0F)==STDAUX1) {
            	f=va_arg(ap,CHAR *);
            	s=va_arg(ap,CHAR *);
				if (*f>'6') RETURNV(0);
				prprintf("%ck%c%s%c",29,*f-'0',s,0);
			}
			retval=1;
            break;
        case MESSAGE_M :
            setppmode(va_arg(ap,INT));
            break;
*/
        case MESSAGE_GS :
            retval=G_prerror;
            break;
    }
    RETURNV(retval);
}
//___________________________________________________________________________

