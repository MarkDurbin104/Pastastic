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
void unpack(int fd,UINT *buf)
{
    UINT i,j;
    UINT num;
    UINT cnt=0;
    UCHAR *wbuf;

    read(fd,&num,sizeof(int));
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
    int fd,i,j,k;
    int sty;
	UCHAR *d=(UCHAR *)0xA0000000L;
    UCHAR *sbuf[4];
    fd=open("GPAD.SCR",O_RDONLY|O_BINARY);
    if (fd==(-1)) return;
    read(fd,&i,sizeof(int));
    read(fd,&i,sizeof(int));
    read(fd,&i,sizeof(int));
    for (i=0;i<4;i++)
        if ((sbuf[i]=malloc(38400))!=NULL) {
            memset(sbuf[i],0,38400);
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
    int ret=0,mask=0x80,i;
    for (i=0;i<3;i++) {
        if (a&mask) ret|=0xC000>>(i*2);
        mask>>=1;
    }
    return(ret);
}
UINT lown(UINT a)
{
    int ret=0,mask=0x10,i;
    for (i=0;i<3;i++) {
        if (a&mask) ret|=0xC000>>(i*2);
        mask>>=1;
    }
    return(ret);
}
void putlntoscr(int c,UCHAR *sp,UCHAR lm,UCHAR rm,int bp,UCHAR *ol,int siz)
{
    int j,i;
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
void opln(int x,int y,int s,int l,int c)
{
	UCHAR *scr=(UCHAR *)0xA0000000L+(y<<6)+(y<<4)+(x>>3);
	UCHAR *sp;
    int i,j,k;
    UINT tmp;
    int bp;
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
                *((int*)(ol+(bp>>3)))|=tmp;
                bp+=G_fntw;

                tmp=lown(*(G_fp[j]));
                tmp>>=bp&7;
                tmp=(tmp>>8)|((tmp&0xFF)<<8);
                *((int*)(ol+(bp>>3)))|=tmp;
                bp+=G_fntw;

                G_fp[j]++;
            }
            else {
                tmp=*(G_fp[j]);
                tmp<<=8-(bp&7);
                tmp=(tmp>>8)|((tmp&0xFF)<<8);
                *((int*)(ol+(bp>>3)))|=tmp;
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

void outxy(int x,int y,int col,int siz,char *fmt,...)
{
    int i,j,l,px,py;
    UCHAR *s,str[140];
    va_list ap;
    s=str;

    va_start(ap,fmt);
    vsprintf(s,fmt,ap);
    va_end(ap);
    l=strlen(s);

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
void drawbox(int x,int y,int x1,int y1,int c)
{
    int xs,xe,ys,ye;
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
void drawline(int x,int y,int x1,int y1,int c)
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
void setvp(int x,int y,int x1,int y1)
{
    setviewport(x,y,x1,y1,1);
    G_vpx =x;
    G_vpy =y;
    G_vpx1=x1;
    G_vpy1=y1;
}
int grafix(void)
{
    int gd = VGA;
	int gm = VGAHI;
    int err;

	err=registerfarbgidriver(EGAVGA_driver_far);
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
		return(0);
	}
    initgraph(&gd,&gm,"");
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
