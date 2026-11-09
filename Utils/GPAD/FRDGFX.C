#define FRDGFX_C
#include <dos.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <alloc.h>
#include <graphics.h>
#include <io.h>
#include <fcntl.h>

#include "types.h"
#include "win.h"
#include "tfont.h"
#include "frdgfx.h"
#include "frdscr.h"
#include "frdwin.h"

// unpack the graphics file for the screen
void unpack(INT fd,UINT *buf)
{
    UINT i,j;
    UINT num;
    UINT cnt=0;
    UCHAR *wbuf;

    read(fd,&num,sizeof(INT));
    if ((wbuf=malloc(num))==NULL) return;
    read(fd,wbuf,num);
    for (j=0;j<num;j+=3) {
        for (i=0;i<wbuf[j];i++) {
            buf[cnt++]=(wbuf[j+1]&0xFF)|(wbuf[j+2]<<8);
		}
	}
	free(wbuf);
}
// put up the start screen
void upscr(void)
{
	INT fd,i,j,k;
//    INT sty;
	UCHAR *d=(UCHAR *)MK_FP(__SegA000,0000);
    UCHAR *sbuf[4];
    fd=open("GPAD.SCR",O_RDONLY|O_BINARY);
    if (fd==(-1)) return;
    read(fd,&i,sizeof(INT));
    read(fd,&i,sizeof(INT));
    read(fd,&i,sizeof(INT));
    for (i=0;i<4;i++)
		if ((sbuf[i]=malloc((INT)38400))!=NULL) {
			memset(sbuf[i],0,(INT)38400);
			unpack(fd,(UINT *)sbuf[i]);
		}
    close(fd);
    k=0;
    for (j=0;j<4;j++) {
        for (i=0;i<4;i++) {
            if (sbuf[i]!=NULL) {
                outp(0x3C4,2);
                outp(0x3C5,1<<i);
                memcpy(d,&sbuf[i][k],9600);
            }
        }
        d+=9600;
        k+=9600;
    }
    for (i=0;i<4;i++) if (sbuf[i]!=NULL) free(sbuf[i]);
    putpixel(0,0,0);
}
void downscr(void)
{
    cleardevice();
    setpalette(0,0x3F);
    setpalette(1,17);
    setpalette(15,0);
}
UINT highn(UINT a)
{
    INT ret=0,mask=0x80,i;
    for (i=0;i<3;i++) {
        if (a&mask) ret|=0xC000>>(i*2);
        mask>>=1;
    }
    return(ret);
}
UINT lown(UINT a)
{
    INT ret=0,mask=0x10,i;
    for (i=0;i<3;i++) {
        if (a&mask) ret|=0xC000>>(i*2);
        mask>>=1;
    }
    return(ret);
}
void putlntoscr(INT c,UCHAR *sp,UCHAR lm,UCHAR rm,INT bp,UCHAR *ol,INT siz)
{
    INT j,i;
    UCHAR *s,*o;

    if (c&0x10) {
        for (j=0;j<4;j++) {
            s=sp; o=ol;
    	    outportb(0x3CE,4);
    	    outportb(0x3CF,j);
    	    outportb(0x3C4,2);
    	    outportb(0x3C5,1<<j);
            if (c&(1<<j)) {
                for (i=0;i<=(bp>>3);i++) *(s++)^=*(o++);
                if (siz==2) {
                    s=sp+80; o=ol;
                    for (i=0;i<=(bp>>3);i++) *(s++)^=*(o++);
                }
            }
        }
    } else if (c&0x20) {
        for (j=0;j<4;j++) {
    	    outportb(0x3CE,4);
    	    outportb(0x3CF,j);
    	    outportb(0x3C4,2);
    	    outportb(0x3C5,1<<j);
            s=sp; o=ol;
            for (i=0;i<=(bp>>3);i++) *(s++)&=~(*(o++));
            if (siz==2) {
                s=sp+80; o=ol;
                for (i=0;i<=(bp>>3);i++) *(s++)&=~(*(o++));
            }
            for (i=0;i<=(bp>>3);i++) *(s++)&=~(*(o++));
            if (c&(1<<j)) {
                s=sp; o=ol;
                for (i=0;i<=(bp>>3);i++) *(s++)|=*(o++);
                if (siz==2) {
                    s=sp+80; o=ol;
                    for (i=0;i<=(bp>>3);i++) *(s++)|=*(o++);
                }
            }
        }
    } else {
        for (j=0;j<4;j++) {
    	    outportb(0x3CE,4);
    	    outportb(0x3CF,j);
    	    outportb(0x3C4,2);
    	    outportb(0x3C5,1<<j);
            if (c&(1<<j)) {
                *sp&=lm;
                *sp^=*ol;
                if (bp>>3) memcpy(sp+1,ol+1,(bp>>3)-1);
                *(sp+(bp>>3))&=rm;
                *(sp+(bp>>3))^=*(ol+(bp>>3));
                if (siz==2) {
                    sp+=80;
                    *sp&=lm;
                    *sp^=*ol;
                    if (bp>>3) memcpy(sp+1,ol+1,(bp>>3)-1);
                    *(sp+(bp>>3))&=rm;
                    *(sp+(bp>>3))^=*(ol+(bp>>3));
                    sp-=80;
                }
            }
            else {
                *sp&=lm;
                if (bp>>3) memset(sp+1,0,(bp>>3)-1);
                *(sp+(bp>>3))&=rm;
                if (siz==2) {
                    sp+=80;
                    *sp&=lm;
                    if (bp>>3) memset(sp+1,0,(bp>>3)-1);
                    *(sp+(bp>>3))&=rm;
                    sp-=80;
                }
            }
        }
    }
}
void opln(INT x,INT y,INT s,INT l,INT c)
{
	UCHAR *scr=(UCHAR *)MK_FP(__SegA000,0000)+(y<<6)+(y<<4)+(x>>3);
	UCHAR *sp;
	INT i,j;  //,k;
	UINT tmp;
	INT bp;
	UCHAR *ol=G_ol;
	UCHAR lm=0,rm=0;
    lm=(0xFF>>(x&7))^0xFF;
    for (i=0;i<G_fnth;i++) {
        bp=x&7;
        memset(ol,0,320);
        for (j=0;j<l;j++) {
            if (s>0) {
                tmp=highn(*(G_fp[j]));
                tmp>>=bp&7;
                tmp=(tmp>>8)|((tmp&0xFF)<<8);
                *((INT*)(ol+(bp>>3)))|=tmp;
                bp+=G_fntw;

                tmp=lown(*(G_fp[j]));
                tmp>>=bp&7;
                tmp=(tmp>>8)|((tmp&0xFF)<<8);
                *((INT*)(ol+(bp>>3)))|=tmp;
                bp+=G_fntw;

                G_fp[j]++;
            }
            else {
                tmp=*(G_fp[j]);
                tmp<<=8-(bp&7);
                tmp=(tmp>>8)|((tmp&0xFF)<<8);
                *((INT*)(ol+(bp>>3)))|=tmp;
                bp+=G_fntw;

                G_fp[j]++;
            }
        }
        if (i==0) rm=0xFF>>(bp&7);
        sp=scr;
		putlntoscr(c,sp,lm,rm,bp,ol,s);
		if (s==2) scr+=160; else scr+=80;
	}
}

void outxy(INT x,INT y,INT col,INT siz,CHAR *fmt,...)
{
    INT i,j,l;
    UCHAR *s,str[140];
    va_list ap;
    s=str;

    va_start(ap,fmt);
	vsprintf((CHAR *)s,fmt,ap);
    va_end(ap);
	l=strlen((CHAR *)s);

    i=(siz==2); j=(siz>1);
	if (y>G_vpy1) return;
    if (y+i<G_vpy) return;
    if (x>G_vpx1) return;
    if (x+(l*G_fntw*(j+1))<G_vpx) return;

    while ((x+(l*G_fntw*(j+1)))>G_vpx1) l--;

    while (x<G_vpx) {
        x+=G_fntw*(j+1);
        s++;
        l--;
    }

    if (l>80) l=80;
    for (i=0;i<l;i++) G_fp[i]=&G_tfont[s[i]*12];
    opln(x,y,siz,l,col);

    putpixel(0,0,getpixel(0,0));
}
void drawbox(INT x,INT y,INT x1,INT y1,INT c)
{
    INT xs,xe,ys,ye;
    G_scrx-=G_vpx;
    G_scry-=G_vpy;
    x -=G_formx;
    y -=G_formy;
    x1-=G_formx;
    y1-=G_formy;
    if (c>15) setwritemode(1);
    if (c!=(-1)) setcolor(c); 
    if (c==(-1)) setcolor(8);

    xs=G_scrx+x *G_fntw+(G_fntw>>1);
    ys=G_scry+y *G_fnth+(G_fnth>>1);
    xe=G_scrx+x1*G_fntw+(G_fntw>>1);
    ye=G_scry+y1*G_fnth+(G_fnth>>1);

    moveto(xs,ye);
    if (c==(-1)) setcolor(7);
    lineto(xs,ys); lineto(xe,ys);
    if (c==(-1)) setcolor(15);
    lineto(xe,ye); lineto(xs,ye);
    xs--; ys--; xe++; ye++;
    moveto(xs,ye);
    if (c==(-1)) setcolor(7);
    lineto(xs,ys); lineto(xe,ys);
    if (c==(-1)) setcolor(15);
    lineto(xe,ye); lineto(xs,ye);
    G_scrx+=G_vpx;
    G_scry+=G_vpy;
    if (c>15) setwritemode(0);
}
#pragma warn +pro
// draw a line on the screen
void drawline(INT x,INT y,INT x1,INT y1,INT c)
{
    G_scrx-=G_vpx;
    G_scry-=G_vpy;
    x -=G_formx;
    y -=G_formy;
    x1-=G_formx;
    y1-=G_formy;

    if (c>15) setwritemode(1);
    if (c!=(-1)) setcolor(c); 
    if (c==(-1)) setcolor(15);
    line(G_scrx+x *G_fntw+(G_fntw/2),
         G_scry+y *G_fnth+(G_fnth/2),
         G_scrx+x1*G_fntw+(G_fntw/2),
         G_scry+y1*G_fnth+(G_fnth/2));

    if (c==(-1)) setcolor(7);
    line(G_scrx+x *G_fntw+(G_fntw/2)+1,
         G_scry+y *G_fnth+(G_fnth/2)+1,
         G_scrx+x1*G_fntw+(G_fntw/2)+1,
         G_scry+y1*G_fnth+(G_fnth/2)+1);
    G_scrx+=G_vpx;
    G_scry+=G_vpy;
    if (c>15) setwritemode(0);
}
// graphics routines
void setvp(INT x,INT y,INT x1,INT y1)
{
    setviewport(x,y,x1,y1,1);
    G_vpx =x;
    G_vpy =y;
	 G_vpx1=x1;
    G_vpy1=y1;
}
INT grafix(void)
{
//	INT gm,gd = DETECT;
	INT gm = VGAHI, gd = VGA;
    INT err;

//	err=registerfarbgidriver(EGAVGA_driver_far);
//	if (err<0) {
//		printf("graphics System Error: %s\n",grapherrormsg(err));
//		return(0);
//	}
    initgraph(&gd,&gm,"\\BC\\BGI");
    err=graphresult();
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
	}
    G_maxx=getmaxx();
    G_maxy=getmaxy();
    setvp(0,0,G_maxx,G_maxy);
    return(1);
}




