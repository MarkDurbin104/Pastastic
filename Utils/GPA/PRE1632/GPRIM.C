#define GPRIM_C
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>

#include <conio.h>
#include <time.h>
#include "types.h"
#include "gprim.h"
#include "control.h"
#include "message.h"
#include "memory.h"
#include "tintext.h"
#include "dpmie.h"

#ifndef max
#define max(a,b) ((a>b)?a:b)
#endif

#ifndef NON_GPA
extern CHAR G_righthand;
#else
CHAR G_righthand=0;
#endif

#ifdef __TURBOC__
#define I asm
#else
#define I __asm
#endif
#define MAXGD 2
#define SOMAP 0x56

INT animate(void);

typedef INT (*FPTR)(void);

typedef struct {
	UCHAR len;
	UCHAR type;
	UCHAR fc;
	UCHAR lc;
	LONG  ofs;
} FMAP;
typedef struct {
	FMAP b;
	UCHAR len;
	UCHAR type;
	UCHAR fc;
	UCHAR lc;
} FMAP1;

typedef struct {
	UCHAR pwid;
	UCHAR phgt;
	UCHAR bwid;
	UCHAR size;
	UCHAR *ftab;
} FDET;
typedef FDET *PFDET;

typedef struct {
	INT   numf;
	UCHAR type;
	UINT  fchar;
	UINT  lchar;
	FDET  f[3];
} FONTDIM;

typedef FONTDIM *PFONTDIM;

typedef struct {
	INT    type;
	INT    px;
	INT    py;
	INT    cx;
	INT    cy;
	INT    col;
	INT    inv;
	INT    wm;
	FONTDIM  f;
	PFDET    cf;
} GDEV;
typedef GDEV *PGDEV;
typedef struct {
	INT x,y,x1,y1;
} BOX;
GDEV   *G_grdevs=NULL;
INT    G_numgd=0;
PGDEV  G_curgd=NULL;
UCHAR  G_nybbmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
UINT   G_sdata[9]={0x3500,0x2D01,0x2E02,0x0703,0x5B04,0x0205,0x5706,0x5707,0x0309};
UCHAR *G_lnbuf=NULL;
INT    G_lnbufsize=0;
INT    G_check=1;
INT    G_dontdraw=0;
UINT *G_scrc=NULL;
BOX    G_boxes[10];
UINT G_numbx;
UCHAR  G_testbuf[32]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
FPTR   G_runtest=(FPTR)G_testbuf;
INT  G_animtick=0;
IMAGE *G_images[10];


void vidint(INT rax)
{
	ENTRY(3210);
I	mov ax,rax
I	INT 0x10
	RETURN;
}
void monomode(void)
{
	ENTRY(3211);
	vidint(3);
	RETURN;
}
INT restart(INT idx)
{
	ENTRY(3212);
	if (idx<G_numgd) G_curgd=&G_grdevs[idx];
	vidint(0x12);
	RETURNV(G_numgd-1);
}
void closegraf(void)
{
	INT i;
	ENTRY(3220);
	if (G_numgd==0) RETURN;
	G_dontdraw=0;
	for (i=0;i<G_numgd;i++) {
		cls();
		G_curgd=&G_grdevs[i];
		if ((G_curgd->f.numf)&&(G_curgd->f.type==1)) {
			FREE(G_curgd->f.f[1].ftab);
		}
	}
	if (G_grdevs!=NULL) {
		FREE(G_grdevs);
		G_grdevs=NULL;
	}
	if (G_scrc!=NULL) {
		FREE(G_scrc);
		G_scrc=NULL;
	}
	if (G_lnbuf!=NULL) {
		FREE(G_lnbuf);
		G_lnbuf=NULL;
	}
	vidint(3);
	G_numgd=0;
	RETURN;
}
INT grafix(INT type)
{
	INT i;
	ENTRY(3230);
	if (G_numgd>=MAXGD) RETURNV(-1);
	if (G_grdevs==NULL) G_grdevs=MALLOC(MAXGD*sizeof(GDEV));
	if (G_grdevs==NULL) RETURNV(-1);
	G_grdevs[G_numgd].type=type;
	G_grdevs[G_numgd].px=0;
	G_grdevs[G_numgd].py=0;
	G_grdevs[G_numgd].cx=0;
	G_grdevs[G_numgd].cy=0;
	G_grdevs[G_numgd].col=15;
	G_grdevs[G_numgd].inv=0;
	G_grdevs[G_numgd].wm=0;
	G_grdevs[G_numgd].f.numf=0;
	G_grdevs[G_numgd].cf=NULL;
	G_curgd=&G_grdevs[G_numgd];
	G_numgd++;
	switch (G_curgd->type) {
		case 1 :
			if (G_scrc==NULL) G_scrc=MALLOC(4000*sizeof(INT));
			if (G_scrc==NULL) RETURNV(-1);
			cls();
			outp(0x3BF,1);
			outp(0x3B8,0);
			for (i=0;i<9;i++) outpw(0x3B4,G_sdata[i]);
			outp(0x3B8,0x0A);
			G_dontdraw=0;
			break;
		default :
			vidint(0x12);
	}
	RETURNV(G_numgd-1);
}
void usegdev(INT idx)
{
	ENTRY(3240);
	if (idx<G_numgd) G_curgd=&G_grdevs[idx];
	RETURN;
}
void cls(void)
{
	INT i;
	ENTRY(3250);
	switch (G_curgd->type) {
		case 1 :
//			if (!G_dontdraw) {
				memset((UCHAR *)0xB0000000L,0,0x8000);
//			}
			if (G_scrc!=NULL) memset(G_scrc,0,8000);
			G_numbx=0;
			break;
		default :
#ifndef NON_GPA
		    sendmsg("INPUT1",'D',animate);
#endif
			for (i=0;i<G_animtick;i++) freeimg(G_images[i]);
			G_animtick=0;
			outpw(0x3C4,0x0F02);
			outpw(0x3CE,0xFF08);
			outpw(0x3CE,0x0001);
			outpw(0x3CE,0x0003);
			memset((UCHAR *)0xA0000000L,0,38400U);
	}
#ifndef NON_GPA
	sendmsg("REMHOT",'~');
	sendmsg("INPUT1",'K',0,"~~"," ");
#endif
	G_curgd->px=0;
	G_curgd->py=0;
	G_curgd->cx=0;
	G_curgd->cy=0;
	RETURN;
}
void flipscr(void)
{
	INT i;
	ULONG *s;
	ENTRY(3260);
	if ((G_curgd->type==1)&&(G_dontdraw)) {
	  	s=(ULONG *)0xB0000000L;
		for (i=0;i<0x2000;i++) *(s++)^=0xFFFFFFFFL;
	}
	RETURN;
}
INT maxx(void)
{
	ENTRY(3270);
	switch (G_curgd->type) {
		case 1 :
			RETURNV(719);
		default :
			RETURNV(639);
	}
}
INT maxy(void)
{
	ENTRY(3280);
	switch (G_curgd->type) {
		case 1 :
			RETURNV(383);
		default :
			RETURNV(479);
	}
}
void putpixel(INT x,INT y)
{
	UCHAR *scr,m=0x80>>(x&7);
	ENTRY(3290);

	switch (G_curgd->type) {
		case 1 :
//			if (G_dontdraw) RETURN;
			scr=(UCHAR *)0xB0000000L+(x>>3)+((y&3)<<13)+((y>>2)*90);
			if (G_curgd->wm) 
				*scr^=m;
			else
				if (G_curgd->col&2) *scr|=m; else *scr&=~m;
			break;
		default :
			scr=(UCHAR *)0xA0000000L+(y*80)+(x>>3);
			if (G_curgd->wm) outpw(0x3CE,0x1803);
			outpw(0x3CE,0x0F01);
			outpw(0x3CE,G_curgd->col<<8);
			outpw(0x3CE,(m<<8)|8);
			*scr&=m;
			outpw(0x3C4,0x0F02);
			outpw(0x3CE,0xFF08);
			outpw(0x3CE,0x0001);
			if (G_curgd->wm) outpw(0x3CE,0x0003);
	}
	RETURN;
}
INT getpixel(INT x,INT y)
{
	UCHAR *scr,m=0x80>>(x&7);
	INT ret,i;
	ENTRY(3300);
	switch (G_curgd->type) {
		case 1 :
			scr=(UCHAR *)(0xB0000000L+(x>>3)+((y&3)<<13)+((y>>2)*90));
			ret=((*scr&m)!=0);
			break;
		default :
			scr=(UCHAR *)(0xA0000000L+((LONG)y*80L)+(x>>3));
			ret=0;
			for (i=3;i>=0;i--) {
				outpw(0x3C4,(0x100<<i)|2);
				outpw(0x3CE,(i<<8)|4);
				if ((*scr&m)==m) ret|=1;
				ret<<=1;
			}
			ret>>=1;
	}
	RETURNV(ret);
}
void setwmode(UCHAR mode)
{
	ENTRY(3310);
	mode&=1;
	if (G_curgd->wm!=mode) {
		G_curgd->wm=mode;
	}
	RETURN;
}
void invtext(void)
{
	ENTRY(3320);
	G_curgd->inv=1;
	RETURN;
}
void normtext(void)
{
	ENTRY(3330);
	G_curgd->inv=0;
	RETURN;
}
void setcol(INT col)
{
	ENTRY(3340);
	if ((col&0xF0)!=0) {
		col>>=4;
		invtext();
	} else {
		normtext();
	}
	col&=15;
	if (G_curgd->col!=col) {
		G_curgd->col=col;
	}
	RETURN;
}
void moveto(INT x,INT y)
{
	ENTRY(3350);
	G_curgd->px=x;
	G_curgd->py=y;
	RETURN;
}
void moverel(INT dx,INT dy)
{
	ENTRY(3360);
	G_curgd->px+=dx;
	G_curgd->py+=dy;
	RETURN;
}
void yline(INT x,INT y,INT deltax,INT deltay,INT o)
{
	INT i2;
	ENTRY(3370);
I {
    mov bx,deltay
    push bx
    mov ax,deltax
    push ax
    sub ax,bx
    shl ax,1
    mov i2,ax
    pop ax
    shl ax,1
    mov deltax,ax
    sub ax,bx
    mov bx,ax
    push bx
   	mov ax,0xA000
    mov es,ax
    mov di,x
    mov cx,di
    and cl,7
    mov ch,0x80
    shr ch,cl
    shr di,1
    shr di,1
    shr di,1
    mov bx,y
    shl bx,1
    shl bx,1
    shl bx,1
    shl bx,1
    mov ax,bx
    shl bx,1
    shl bx,1
    add ax,bx
    add di,ax
    mov dx,0x3CE
    mov ax,8
    out dx,ax
    inc dx
    mov al,ch
    pop si
    pop cx
    inc cx
    mov bh,0
}
runloop:
I {         
    out dx,al
    mov ah,es:[di]
    mov es:[di],ah
    add di,o
    cmp si,0
    jl noinc
    add si,i2
    shr al,1
    jnc check
    mov al,0x80
    inc di
    jmp check
}
noinc:
I	add si,deltax
check:
I	loop runloop
	RETURN;
}
void xline(INT x,INT y,INT deltax,INT deltay,INT o)
{
	INT i2;
	ENTRY(3380);
I {	mov bx,deltax
    push bx
    mov ax,deltay
    push ax
    sub ax,bx
    shl ax,1
    mov i2,ax
    pop ax
    shl ax,1
    mov deltay,ax
    sub ax,bx
    mov bx,ax
    push bx
    mov ax,0xA000
    mov es,ax
    mov di,x
    mov cx,di
    and cl,7
    mov ch,0x80
    shr ch,cl
    shr di,1
    shr di,1
    shr di,1
    mov bx,y
    shl bx,1
    shl bx,1
    shl bx,1
    shl bx,1
    mov ax,bx
    shl bx,1
    shl bx,1
    add ax,bx
    add di,ax
    mov dx,0x3CE
    mov ax,8
    out dx,ax
    inc dx
    mov al,ch
    pop si
    pop cx
    inc cx
    mov bh,0
}
runloop:
I { or  bh,al
    shr al,1
    jnc same
    mov al,bh
    out dx,al
    mov ah,es:[di]
    mov es:[di],ah
    xor bh,bh
    mov al,0x80
    inc di
}
same:
I {	cmp si,0
    jl  noinc
    cmp bh,0
    je dontout
    xchg ah,al
    mov al,bh
    out dx,al
    xchg ah,al
    mov ah,es:[di]
    mov es:[di],ah
    xor bh,bh
}
dontout:
I {	add si,i2;
    add di,o;
    jmp check
}
noinc:
I	add si,deltay
check:
I {	loop runloop
    cmp bh,0
    je nolastbit
    mov al,bh
    out dx,al
    mov ah,es:[di]
    mov es:[di],ah
}
nolastbit:
	RETURN;
}
void vlineh(INT x,INT y1,INT y2)
{
	UCHAR *t=(UCHAR *)0xB0000000L,*s; 
	UCHAR m1=0x80>>(x&7),m2;
	INT y;
	ENTRY(3390);
	m2=~m1;
	t+=x>>3;
	for (y=y1;y<=y2;y++) {
		s=(t+((y&3)*0x2000)+((y>>2)*90));
		*s&=m2;
		*s|=m1;
	}
	RETURN;
}
void horizln(INT x1,INT x2,INT y)
{
	UCHAR *t,*s;
	UCHAR m1=0xFF,m2=0xFF;
	INT w,i,j;
	ENTRY(3400);
	m1>>=(x1&7); m2>>=(x2&7)+1; m2=~m2;
	w=(x2>>3)-(x1>>3);
	switch (G_curgd->type) {
		case 1  :
			t=(UCHAR *)0xB0000000L+((y&3)*0x2000)+((y>>2)*90)+(x1>>3);
			switch (w) {
				case 0 :
					m1&=m2;	*t|=m1; break;
				case 1:
					*t|=m1; t++; *t|=m2; break;
				default:
					*t|=m1; t++;
					memset(t,0xFF,w-1); t+=w-1;
					*t|=m2;
			}
			break;
		case 0  :
		default :
			s=(UCHAR *)0xA0000000L+(y*80)+(x1>>3);
			if (G_curgd->wm) {
				for (i=0;i<4;i++) {
					t=s;
					if (((1<<i)&G_curgd->col)!=0) {
						outpw(0x3C4,(0x100<<i)|2);
						outpw(0x3CE,(i<<8)|4);
						switch (w) {
							case 0 :
								m1&=m2;	*t^=m1; break;
							case 1:
								*t^=m1; t++; *t^=m2; break;
							default:
								*t^=m1; t++;
								for (j=0;j<w-1;j++) *(t++)^=0xFF;
								*t^=m2;
						}
					}
				}
			} else {
				for (i=0;i<4;i++) {
					t=s;
					outpw(0x3C4,(0x100<<i)|2);
					outpw(0x3CE,(i<<8)|4);
					if (((1<<i)&G_curgd->col)!=0) {
						switch (w) {
							case 0 :
								m1&=m2;	*t|=m1; break;
							case 1:
								*t|=m1; t++; *t|=m2; break;
							default:
								*t|=m1; t++;
								memset(t,0xFF,w-1); t+=w-1;
								*t|=m2;
						}
					} else {
						switch (w) {
							case 0 :
								m1&=m2;	*t&=~m1; break;
							case 1:
								*t&=~m1; t++; *t&=~m2; break;
							default:
								*t&=~m1; t++;
								memset(t,0,w-1); t+=w-1;
								*t&=~m2;
						}
					}
				}
			}
			break;
	}
	RETURN;
}
void lineto(INT x,INT y)
{
	INT s,e;
	INT dx,dy,inc;
	ENTRY(3410);
	switch (G_curgd->type) {
		case 1 :
//			if (!G_dontdraw) {
				if (x==G_curgd->px) {
					if (y<G_curgd->py) { e=G_curgd->py; s=y; } else { e=y; s=G_curgd->py;}
					vlineh(x,s,e);
				} else {
					if (x<G_curgd->px) { e=G_curgd->px; s=x; } else { e=x; s=G_curgd->px;}
					horizln(s,e,y);
				}
//			}
			break;
		default :
			dx=abs(x-G_curgd->px); dy=abs(y-G_curgd->py);
			if (!dy) {
				if (x<G_curgd->px) { e=G_curgd->px; s=x; } else { e=x; s=G_curgd->px;}
				horizln(s,e,y);
			} else {
				outpw(0x3C4,0x0F02);
				outpw(0x3CE,0xFF08);
				outpw(0x3CE,0x0F01);
				outpw(0x3CE,G_curgd->col<<8);
				if (G_curgd->wm) outpw(0x3CE,0x1803);
				if (dx>dy) {
					if (G_curgd->px>x) {
						if (y>G_curgd->py) inc=(-80); else inc=80;
						xline(x,y,dx,dy,inc);
					} else {
						if (y>G_curgd->py) inc=80; else inc=(-80);
						xline(G_curgd->px,G_curgd->py,dx,dy,inc);
					}
				} else {
					if (G_curgd->py>y) {
						if (x>G_curgd->px) {
							inc=(-80);
							yline(G_curgd->px,G_curgd->py,dx,dy,inc);
						} else {
							inc=80;
							yline(x,y,dx,dy,inc);
						}
					} else {
						if (x>G_curgd->px) {
							inc=80;
							yline(G_curgd->px,G_curgd->py,dx,dy,inc);
						} else {
							inc=(-80);
							yline(x,y,dx,dy,inc);
						}
					}
				}
				outpw(0x3C4,0x0F02);
				outpw(0x3CE,0xFF08);
				outpw(0x3CE,0x0001);
				if (G_curgd->wm) outpw(0x3CE,0x0003);
			}
	}
	moveto(x,y);
	RETURN;
}
void linerel(INT dx,INT dy)
{
	ENTRY(3420);
	lineto(G_curgd->px+dx,G_curgd->py+dy);
	RETURN;
}
void line(INT x1,INT y1,INT x2,INT y2)
{
	ENTRY(3430);
	moveto(x1,y1);
	lineto(x2,y2);
	RETURN;
}
INT chkbx(INT x1,INT y1,INT x2,INT y2)
{
	INT i;
	ENTRY(3440);

	if (G_numbx>9) RETURNV(0);

	for (i=0;i<G_numbx;i++) {
		if ((G_boxes[i].x ==x1)
		&&  (G_boxes[i].y ==y1)
		&&  (G_boxes[i].x1==x2)
		&&  (G_boxes[i].y1==y2)) RETURNV(1);
	}
	G_boxes[i].x =x1;
	G_boxes[i].y =y1;
	G_boxes[i].x1=x2;
	G_boxes[i].y1=y2;
	G_numbx++;

	RETURNV(0);
}
void rectangle(INT x1,INT y1,INT x2,INT y2)
{
	ENTRY(3450);
	if ((G_curgd->type==1)&&(G_check)&&(chkbx(x1,y1,x2,y2))) RETURN;
	moveto(x1,y1);
	lineto(x2,y1);
	lineto(x2,y2);
	lineto(x1,y2);
	lineto(x1,y1);
	RETURN;
}
void bar(INT x1,INT y1,INT x2,INT y2)
{
	INT i;
	ENTRY(3460);
	if (x1>x2) { i=x1; x1=x2; x2=i; }
	if (y1>y2) { i=y1; y1=y2; y2=i; }
	for (i=y1;i<=y2;i++) horizln(x1,x2,i);
	RETURN;
}
UINT dublit(UCHAR c,UCHAR swap)
{
    UINT r;
	ENTRY(3470);
I   mov ah,c
I   xor al,al
I   shr ax,1
I   shr ax,1
I   shr ax,1
I   shr ax,1
I   shr al,1
I   shr al,1
I   shr al,1
I   shr al,1
I	mov si,offset G_nybbmap
I   xor bh,bh
I   mov bl,ah
I   mov dh,byte ptr ds:[si+bx]
I   mov bl,al
I   mov dl,byte ptr ds:[si+bx]
I   cmp swap,1
I   jne done
I   xchg dl,dh
I   mov r,dx
done:
    RETURNV(r);
}
void putin(UCHAR *a,UCHAR *b,UCHAR c)
{
	b++;
I { mov ah,c
    xor al,al
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr al,1
    shr al,1
    shr al,1
    shr al,1
    mov si,offset G_nybbmap
    xor bh,bh
    mov bl,ah
    mov dh,byte ptr ds:[si+bx]
    mov bl,al
    mov dl,byte ptr ds:[si+bx]
    les di,a
    mov byte ptr es:[di],dh
    mov byte ptr es:[di+16],dl
}
}
void magnify(UCHAR *f,UCHAR *a,UCHAR *b)
{
	UINT i,j;
	ENTRY(3490);
	for (i=0;i<256;i++) {
		for (j=0;j<16;j++) { putin(a++,b++,*(f++)); b++; }
		a+=16; b+=32;
	}
	RETURN;
}
LONG getofs(UCHAR **s,INT hgt,INT wid)
{
	LONG ret=0L,sw=hgt*(wid-1),lw=hgt*wid;
	UCHAR *t=*s,a;
	ENTRY(3491);
	(*s)++;

	a=*t;
	if (a<0x80) RETURNV(a*sw);
								 ret=256L*sw;
	if       (a<0xA4)			 ret+=(157L*(a-0xA1))*lw;
	else if  (a<0xC7) 			 ret+=(157L*(a-0xA4))*lw+(408L*lw);
	else if ((a>0xC8)&&(a<0xFA)) ret+=(157L*(a-0xC9))*lw+(5809L*lw);
	else RETURNV(-1L);

	a=*(++t); (*s)++;
	if ((a<0x40)||((a>0x7F)&&(a<0xa1))) RETURNV(-1L);
	a-=0x40; if (a>0x3F) a-=0x22;
	lw*=a;
	RETURNV(ret+lw);
}
INT lstr2buf(UCHAR *buf,UCHAR *name,UCHAR *str,UCHAR hgt,UCHAR wid,INT inv)
{
	LONG base,fmaps;
	UCHAR o,tmp[72],*b,dh,dw;
	INT i,ret=0;
	UINT j,k;
	FMAP1 bfont;
	FMAP  font;
	ENTRY(3500);
	if (!isblk((CHAR *)name)) RETURNV(0);
	dw=((G_curgd->cf->size-1)>0)*2;
	dh=((G_curgd->cf->size-1)==2);
	if (dh) hgt/=2;
	if (G_curgd->f.type==201) {
		restpblk((CHAR *)name,&bfont,2L,sizeof(FMAP1));
		fmaps=2L+(LONG)sizeof(FMAP1);
		while (*str) {
			if (*str>0xA0) {
				o=*(str++)-0xA1;
				if (*str<0xA1) {
					b=buf;
					for (i=0;i<hgt;i++) {
						if (inv) memset(b,0,wid*dw); else memset(b,0xFF,wid*dw);
						b+=256;
						if (dh) {
							if (inv) memset(b,0,wid*dw); else memset(b,0xFF,wid*dw);
							b+=256;
						}
					}
				} else {
					restpblk((CHAR *)name,&font,fmaps+(o*sizeof(FMAP)),sizeof(FMAP));
					o=*(str++)-0xA1;
					restpblk((CHAR *)name,tmp,font.ofs+o*hgt*wid,hgt*wid);
					b=buf;
					if (inv) for (i=0;i<hgt*wid;i++) tmp[i]=~tmp[i];
					for (i=0;i<hgt;i++) {
						if (dw) {
							for (j=0;j<wid;j++) {
								k=dublit(tmp[i*wid+j],1);
								memcpy(b+j*2,&k,2);
							}
							b+=256;
							if (dh) {
								for (j=0;j<wid;j++) {
									k=dublit(tmp[i*wid+j],1);
									memcpy(b+j*2,&k,2);
								}
								b+=256;
							}
						} else {
							memcpy(b,&tmp[i*wid],wid);
							b+=256;
							if (dh) {
								memcpy(b,&tmp[i*wid],wid);
								b+=256;
							}
						}
					}
				}
				if (dw) {
					ret+=4;
					buf+=wid*2;
				} else {
					ret+=2;
					buf+=wid;
				}
			} else {
				if (*str>31) {
					restpblk((CHAR *)name,tmp,bfont.b.ofs+(*str)*hgt*(wid-1),hgt*(wid-1));
					if (inv) for (i=0;i<hgt*(wid-1);i++) tmp[i]=~tmp[i];
					b=buf;
					for (i=0;i<hgt;i++) {
						if (dw) {
							for (j=0;j<wid-1;j++) {
								k=dublit(tmp[i*(wid-1)+j],1);
								memcpy(b+j*2,&k,2);
							}
							b+=256;
							if (dh) {
								for (j=0;j<wid-1;j++) {
									k=dublit(tmp[i*(wid-1)+j],1);
									memcpy(b+j*2,&k,2);
								}
								b+=256;
							}
						} else {
							memcpy(b,&tmp[i*(wid-1)],wid-1);
							b+=256;
							if (dh) {
								memcpy(b,&tmp[i*(wid-1)],wid-1);
								b+=256;
							}
						}
					}
					if (dw) {
						ret+=2;
						buf+=(wid-1)*2;
					} else {
						ret++;
						buf+=wid-1;
					}
				}
				str++;
			}
		}
	} else {
		hgt=24;
		wid=3;
		while (*str) {
			b=buf;
			if ((base=getofs(&str,hgt,wid))>=0) {
				j=wid;
				if (base<=256L*hgt*(wid-1)) j--;
				restpblk((CHAR *)name,tmp,base,hgt*j);
				for (i=0;i<hgt;i++) {
					memcpy(b,&tmp[i*j],j);
//					if (j!=wid) *(b+j)=0;
					b+=256;
				}
				ret+=j;
				buf+=j;
			}
		}
	}
	RETURNV(ret);
}
INT str2buf(UCHAR *buf,UCHAR *f,UCHAR *s,UCHAR hgt,UCHAR wid,INT inv)
{
    INT r;
I { push ds
    push es
    les di,buf
    mov dh,hgt
    xor ch,ch;
    mov al,wid
    mul dh
    mov bl,al
    xor al,al
    cmp inv,1
    jne eachnch
}
eachchar:
I { mov dl,wid
    xor ah,ah
    push ax
    lds si,s
    add si,ax
    lodsb
    cmp al,0
    je finish
    mul bl
    lds si,f
    add si,ax
}
eachln:
I   { mov bx,di
    mov cl,dh
}
eachbyte:
I   { lodsb
    not al
    mov es:[bx],al
    inc bh
    loop eachbyte
    dec dl
    inc di
    cmp  dl,0
    jg eachln
    mov al,wid
    mul dh
    mov bl,al
    pop ax
    inc al
    jmp eachchar
}
eachnch:
I { mov dl,wid
    xor ah,ah
    push ax
    lds si,s
    add si,ax
    lodsb
    cmp al,0
    je finish
    mul bl
    lds si,f
    add si,ax
}
eachnln:
I { mov bx,di
    mov cl,dh
}
eachnb:
I { lodsb
    mov es:[bx],al
    inc bh
    loop eachnb
    dec dl
    inc di
    cmp  dl,0
    jg eachnln
    mov al,wid
    mul dh
    mov bl,al
    pop ax
    inc al
    jmp eachnch
}
finish:
I { pop ax
    pop es
    pop ds
    mov dh,wid
    mul dh
    mov r,ax
}
    return(r);
}
void shiftln(UCHAR *buf,UCHAR w,UCHAR hgt,UCHAR sft)
{
	ENTRY(3520);
	if (!sft) RETURN;
I { push es
    les bx,buf
    mov dh,hgt
    mov cl,sft
}
eachln:
I {
   push bx
   xor dl,dl
   mov ch,w
}
eachbyte:
I { xor al,al
    mov ah,es:[bx]
    shr ax,cl
    or  ah,dl
    mov es:[bx],ah
    mov dl,al
    inc bx
    dec ch
    cmp ch,0
    jg  eachbyte
    mov es:[bx],al
    pop bx
    inc bh
    dec dh
    cmp dh,0
    jg  eachln
    pop es
}
	RETURN;
}
// swap two bytes in a word
UINT hswapbytes(UINT i)
{
	ENTRY(3530);
I   mov  ax,i
I   xchg ah,al
I   mov  i,ax
    RETURNV(i);
}
// put a word bitmap into HERC screen
void putint(INT x,INT y,UINT i,UINT j)
{
	UCHAR *t=(UCHAR *)0xB0000000L; 
	ENTRY(3540);
    t+=x+((y&3)<<13)+((y>>2)*90);
    
    if (G_curgd->wm) {
        *((INT *)t)^=hswapbytes(i);
    }
    else {
        *((INT *)t)&=hswapbytes(j);
        *((INT *)t)|=hswapbytes(i);
    }
	RETURN;
}
// set the ninth bit for HERC output
INT nthbit(INT ch)
{
	ENTRY(3550);
    RETURNV((ch<<1)|(ch&1));
}
// get the character value
INT getcval(INT cpos)
{
	ENTRY(3560);
    if (G_curgd->inv) RETURNV(G_curgd->cf->ftab[cpos]^0xFF);
    RETURNV(G_curgd->cf->ftab[cpos]);
}
// true if the screen is currently set to the same
INT scrsetto(INT x,INT y,UINT v)
{
	INT o=x+y*80;
	ENTRY(3570);
    if (G_scrc[o]==v) RETURNV(1);
	G_scrc[o]=v;
    RETURNV(0);
}
// HERC character output routine
void houtch(UINT x,UINT y,UCHAR c) 
{
	INT i;
    UCHAR ch;
    UINT mask;
    UINT amask1,amask2;
    UINT wide;
    UINT cpos,yofs;
    UINT xofs1,mmap1;
    UINT xofs2,mmap2;
	UINT val;
	ENTRY(3580);

	if (G_check) {
	  	yofs=y/G_curgd->cf->phgt;
	    if ((x>79)||(yofs>24)) RETURN;
		val=(((INT)c)<<8)|(G_curgd->col<<4)|(G_curgd->inv<<3)|G_curgd->cf->size;
	    if (scrsetto(x,yofs,val)&&(G_curgd->wm==0)) RETURN;
	}
//	if (G_dontdraw) RETURN;

    cpos=(c*G_curgd->cf->phgt);
    yofs=y;
    xofs1=(x+(x>>3));
    mmap1=7-(x&7);
    amask1=~(0x1FF<<mmap1);
    x++;
    xofs2=(x+(x>>3));
    mmap2=7-(x&7);
    amask2=(0x1FF<<mmap2)^0xFFFF;

    switch (G_curgd->cf->size) {
        case 1 :
            for (i=0;i<G_curgd->cf->phgt;i++) {
                mask=nthbit(getcval(cpos));
                mask<<=mmap1;
                putint(xofs1,yofs,mask,amask1);
                cpos++;
                yofs++;
            }
            break;
        case 2 :
            for (i=0;i<G_curgd->cf->phgt;i++) {
                ch=getcval(cpos);
                wide=dublit(ch,0);
                mask=nthbit(wide>>8);
                mask<<=mmap1;
                putint(xofs1,yofs,mask,amask1);
                mask=nthbit(wide&0xFF);
                mask<<=mmap2;
                putint(xofs2,yofs,mask,amask2);
                cpos++;
                yofs++;
            }
            break;
        case 3 :
            for (i=0;i<G_curgd->cf->phgt;i++) {
                ch=getcval(cpos);
                wide=dublit(ch,0);
                mask=nthbit(wide>>8);
                mask<<=mmap1;
                putint(xofs1,yofs,mask,amask1);
                yofs++;
                putint(xofs1,yofs,mask,amask1);
                yofs--;
                mask=nthbit(wide&0xFF);
                mask<<=mmap2;
                putint(xofs2,yofs,mask,amask2);
                yofs++;
                putint(xofs2,yofs,mask,amask2);
                yofs++;
                cpos++;
            }
            break;
    }
	RETURN;
}
void scrredraw(void)
{
	INT i,j,o;
	INT cl,iv,sz;
	ENTRY(3590);

	if (G_curgd->type!=1) RETURN;

	cl=G_curgd->col;
	iv=G_curgd->inv;
	sz=G_curgd->cf->size;
	memset((UCHAR *)0xB0000000L,0,0x8000);
	G_check=0;
	for (j=0;j<25;j++) {
		for (i=0;i<80;i++) {
			o=G_scrc[j*80+i];
			if ((o)&&((o>>8)!=' ')) {
				G_curgd->col     =(o>>4)&15;
				G_curgd->inv     =(o>>3)&1;
				G_curgd->cf->size=o&15;
				houtch(i,j*G_curgd->cf->phgt,(CHAR)(o>>8));
			}
		}
	}
	G_curgd->col=2;
	G_curgd->inv=0;
	for (i=0;i<G_numbx;i++) 
		rectangle(G_boxes[i].x,G_boxes[i].y,G_boxes[i].x1,G_boxes[i].y1);
	G_check=1;
	G_curgd->col     =cl;
	G_curgd->inv     =iv;
	G_curgd->cf->size=sz;
	RETURN;
}
void dontdraw(INT v)
{
	ENTRY(3600);
	if (G_dontdraw==v) RETURN;
	G_dontdraw=v;
//	if (!v) scrredraw();
	RETURN;
}
void prln(INT x,INT y,CHAR *fmt, ... )
{
    UCHAR str[140];
	UCHAR w,xofs=(x>>3);
	UCHAR xsft=x&7;
	UINT col=(G_curgd->col<<8)|2;
	UCHAR *smem;
	UCHAR ht,*s,*buf=G_lnbuf,*b;
	UCHAR h,i,j;
	va_list ap;
	ENTRY(3610);
	if ((G_curgd->cf==NULL)||(G_lnbufsize==0)) RETURN;

	if (G_testbuf[0]!=0) { (G_runtest)(); G_testbuf[0]=0; }

	h=G_curgd->cf->phgt;

    va_start(ap,fmt);
    vsprintf((CHAR *)str,fmt,ap);
    va_end(ap);

	switch (G_curgd->type) {
		case 1 :
		    s=str;
		    while (*s) {
		        houtch(x++,y,*(s++));
		        if (G_curgd->cf->size!=1) x++;
		    }
			break;
		default :
			smem=(UCHAR *)0xA0000000L+(y*80)+xofs;
			if (G_curgd->f.type>=200) {
				w=lstr2buf(buf,G_curgd->cf->ftab,str,h,G_curgd->cf->bwid,G_curgd->inv);
			} else {
				w=str2buf(buf,G_curgd->cf->ftab,str,h,G_curgd->cf->bwid,G_curgd->inv);
			}
			if (xsft) shiftln(buf,w++,h,xsft);
			if ((xofs+w)>80) w=80-xofs;
			if (G_curgd->wm) {
				for (i=0;i<4;i++) {
					if (((1<<i)&G_curgd->col)!=0) {
						s=smem; ht=h; buf=G_lnbuf;
						outpw(0x3C4,(0x100<<i)|2);
						outpw(0x3CE,(i<<8)|4);
						while (ht--) {
							if (G_curgd->cf->size==3) {
								b=buf;
								for (j=0;j<w;j++) *(s++)^=*(b++);
								s+=80-w;
							}
							for (j=0;j<w;j++) *(s++)^=*(buf++);
							s+=80-w;
							buf+=256-w;
						}
					}
				}
			} else {
				if (col!=2) {
					s=smem; ht=h;
					outpw(0x3C4,col);
					while (ht--) {
						if (G_curgd->cf->size==3) {
							b=buf;
							memcpy(s,b,w);
							s+=80;
						}
						memcpy(s,buf,w);
						s+=80;
						buf+=256;
					}
				}
				col^=0x0F00;
				if (col!=2) {
					outpw(0x3C4,col);
					while (h--) {
						if (G_curgd->cf->size==3) {
							memset(smem,0,w);
							smem+=80;
						}
						memset(smem,0,w);
						smem+=80;
					}
				}
			}
	}
	RETURN;
}
INT setlnbuf(INT size)
{
	ENTRY(3620);
	if (G_lnbuf==NULL) {
		G_lnbufsize=size;
		G_lnbuf=MALLOC(256*G_lnbufsize);
		if (G_lnbuf==NULL) {
			G_lnbufsize=0;
			RETURNV(0);
		}
	} else {
		if (size>G_lnbufsize) {
			G_lnbufsize=size;
			G_lnbuf=REALLOC(G_lnbuf,256*G_lnbufsize);
			if (G_lnbuf==NULL) {
				G_lnbufsize=0;
				RETURNV(0);
			}
		}
	}
	memset(G_lnbuf,0,256*G_lnbufsize);
	RETURNV(1);
}
INT attachfont(UCHAR *f,UCHAR type,UCHAR h,UCHAR w)
{
	UCHAR bwid=(w+7)/8,*tmp,i;
	UINT hw;
	ENTRY(3630);
	setlnbuf(h*bwid);
	if (G_curgd->f.numf) {
		switch (G_curgd->f.type) {
			case 1 :
				FREE(G_curgd->f.f[1].ftab);
				break;
		}
	}
	G_curgd->f.type=type;
	switch (type) {
		case 1 :
			G_curgd->f.numf=3;
			G_curgd->f.fchar=0;
			G_curgd->f.lchar=255;
			G_curgd->f.f[0].pwid=w;
			G_curgd->f.f[0].phgt=h;
			G_curgd->f.f[0].bwid=bwid;
			G_curgd->f.f[0].size=1;
			G_curgd->f.f[0].ftab=f;
			G_curgd->cf=&(G_curgd->f.f[0]);
			tmp=MALLOC(0x2000);
			if (tmp==NULL) {
				G_curgd->f.numf=1;
				G_curgd->f.type=2;
				RETURNV(1);
			}
			magnify(f,tmp,tmp+0x1000);
			w*=2;
			bwid*=2;
			for (i=1;i<3;i++) {
				G_curgd->f.f[i].pwid=w;
				G_curgd->f.f[i].phgt=h;
				G_curgd->f.f[i].bwid=bwid;
				G_curgd->f.f[i].size=i+1;
				G_curgd->f.f[i].ftab=tmp;
			}
			setlnbuf(h*bwid);
			RETURNV(1);
		case 101 :
			G_curgd->f.numf=3;
			G_curgd->f.fchar=0;
			G_curgd->f.lchar=255;
			for (i=0;i<3;i++) {
				G_curgd->f.f[i].pwid=w;
				G_curgd->f.f[i].phgt=h;
				G_curgd->f.f[i].bwid=bwid;
				G_curgd->f.f[i].size=i+1;
				G_curgd->f.f[i].ftab=f;
			}
			G_curgd->cf=&(G_curgd->f.f[0]);
			RETURNV(1);
		case 201 :
			if (isblk((CHAR *)f)) {
				restpblk((CHAR *)f,&hw,0L,2L);
				h=hw&0xFF;
				w=(hw>>8)&0xFF;
				bwid=(w+7)/8;
				setlnbuf(h*2*bwid*2);
				G_curgd->f.numf=3;
				G_curgd->f.fchar=0;
				G_curgd->f.lchar=255;
				for (i=0;i<3;i++) {
					G_curgd->f.f[i].pwid=w;
					G_curgd->f.f[i].phgt=h+(h*(i==2));
					G_curgd->f.f[i].bwid=bwid;
					G_curgd->f.f[i].size=i+1;
					G_curgd->f.f[i].ftab=f;
				}
				G_curgd->cf=&(G_curgd->f.f[0]);
				RETURNV(1);
			}
			break;
		case 202 :
			if (isblk((CHAR *)f)) {
				setlnbuf(288);
				G_curgd->f.numf=3;
				G_curgd->f.fchar=0;
				G_curgd->f.lchar=255;
				for (i=0;i<3;i++) {
					G_curgd->f.f[i].pwid=24;
					G_curgd->f.f[i].phgt=24;
					G_curgd->f.f[i].bwid=3;
					G_curgd->f.f[i].size=1;
					G_curgd->f.f[i].ftab=f;
				}
				G_curgd->cf=&(G_curgd->f.f[0]);
				RETURNV(1);
			}
			break;
	}
	RETURNV(0);
}
void selectfont(UINT idx)
{
	ENTRY(3640);
	if (idx<G_curgd->f.numf) {
		G_curgd->cf=&(G_curgd->f.f[idx]);
	}
	RETURN;
}
void getrgbpalette(INT c,UCHAR *r,UCHAR *g,UCHAR *b)
{
    UCHAR rr,gg,bb;
	ENTRY(3644);
I   mov ax,0x1015
I	mov bx,c
I	INT 0x10
I	mov rr,dh
I	mov gg,ch
I	mov bb,cl
    *r=rr;
    *g=gg;
    *b=bb;
	RETURN;
}
void setrgbpalette(INT c,UCHAR r,UCHAR g,UCHAR b)
{
	ENTRY(3645);
I   mov ax,0x1010
I	mov bx,c
I	mov dh,r
I	mov ch,g
I	mov cl,b
I	INT 0x10
	RETURN;
}
void setpalette(UCHAR c,UCHAR attr)
{
	ENTRY(3650);
I   mov ax,0x1000
I	mov bl,c
I	mov bh,attr
I	INT 0x10
	RETURN;
}
void setborder(UCHAR attr)
{
	ENTRY(3660);
I   mov ax,0x1001
I	xor bl,bl
I	mov bh,attr
I	INT 0x10
	RETURN;
}
void outln(INT x,INT y,INT w,UCHAR *buf,INT newbmp)
{
	INT i;
	static UCHAR mask;
	static UCHAR *scr;
	static UCHAR *eol;
	static INT   wid;
	ENTRY(3670);
	if (newbmp) {
//	 	prln(x,y,"%d %d %s",x,y,img->name);
		mask=0xFF<<(8-((w+x)&7));
		scr=(UCHAR *)(0xA0000000L+((LONG)y*80L)+(LONG)(x>>3));
		wid=w/8;
		eol=scr+wid;
	} else {
		scr+=80;
		eol+=80;
	}
	for (i=0;i<4;i++) {
		WRITEPLANE(i);
		READPLANE(i);
		memcpy(scr,buf,wid);
		buf+=wid;
		if (mask) {
			*eol&=~mask;
			*eol|=*(buf++)&mask;
		}
	}
//	sendmsg("INPUT1",'i');
	RETURN;
}
void mov4b(UCHAR *d,UCHAR *s)
{
//	ENTRY(3680);
I { push ds
    push es
    push si
    push di
	les di,s
	lds si,d
	mov cx,4
	mov bh,es:[di]
	mov bl,es:[di+256]
	mov dh,es:[di+512]
	mov dl,es:[di+768]
}
eachbyte:
I { or ah,ah
	mov al,bh
    shl ax,1
    mov al,bl
    shl ax,1  
	mov al,dh
    shl ax,1
    mov al,dl
    shl ax,1
	shl bx,1
    shl dx,1 
	mov al,bh
    shl ax,1
    mov al,bl
    shl ax,1 
	mov al,dh
    shl ax,1
    mov al,dl
    shl ax,1
	shl bx,1
    shl dx,1 
	mov ds:[si],ah
	inc si
    loop eachbyte
    pop di
    pop si
    pop es
    pop ds
}
//	RETURN;
}
void mov4(UCHAR *d,UCHAR *s)
{
//	ENTRY(3681);
I { les di,s
	xor bx,bx
	xor dx,dx
	mov cx,4
}
eachbyte:
I { mov al,es:[di]
    shl bx,1
    shl dx,1
	xor ah,ah
    shl ax,1
    or bh,ah
    xor ah,ah
    shl ax,1
    or bl,ah
    xor ah,ah
    shl ax,1
    or dh,ah
    xor ah,ah
    shl ax,1
    or dl,ah
    shl bx,1
    shl dx,1
    xor ah,ah
    shl ax,1
    or bh,ah
    xor ah,ah
    shl ax,1
    or bl,ah
    xor ah,ah
    shl ax,1
    or dh,ah
    xor ah,ah
    shl ax,1
    or dl,ah
	inc di
    loop eachbyte
	les di,d
	mov es:[di]  ,dl
	mov es:[di+1],dh
	mov es:[di+2],bl
	mov es:[di+3],bh
}
//	RETURN;
}
void setcols(UCHAR *s,INT w,INT dir)
{
	ENTRY(3690);
I { mov si,offset col
    add si,dir
    les di,s
    mov cx,w
}
eachbyte:
I { xor ah,ah
    mov al,es:[di]
    shl ax,1
    shl ax,1
    shl ax,1
    shl ax,1
    shr al,1
    shr al,1
    shr al,1
    shr al,1
    xor bh,bh
    mov bl,ah
    mov ah,ds:[si+bx]
    mov bl,al
    mov al,ds:[si+bx]
    shl al,1
    shl al,1
    shl al,1
    shl al,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    mov es:[di],al
    inc di
    loop eachbyte
}
	RETURN;
}
void reorg(UCHAR *d,UCHAR *s,INT w)
{
	INT i,j;
	UCHAR buf[4];
	ENTRY(3700);

	setcols(s,w,0);
	w/=4;
	for (i=0;i<w;i++) {
		mov4(buf,&s[i*4]);
		for (j=0;j<4;j++) d[i+j*w]=buf[j];
	}
	RETURN;
}
INT intsize(INT a)
{
	ENTRY(3710);
	if (a&1) RETURNV(a+1);
	RETURNV(a);
}
LONG getbmpsiz(CHAR *name)
{
	INT fd;
	BMPH b;
	LONG l;
	ENTRY(3720);
	if (!isblk(name)) {
		fd=open(name,O_RDONLY|O_BINARY);
		if (fd==(-1)) RETURNV(0L);
		read(fd,&b,sizeof(BMPH));
		close(fd);
	} else {
       	restpblk(name,&b,0L,intsize(sizeof(BMPH)));
	}
	l=(LONG)(((b.wid+7)/8)*8);
	l<<=16;
	l|=(LONG)b.hgt;
	RETURNV(l);
}
INT savebmp(CHAR *name)
{
	FILE *fp;
	INT i,j;
	ENTRY(3725);

	setlnbuf(8);
	if ((fp=fopen(name,"wb"))==NULL) RETURNV(0);
	fwrite(G_obmph,1,0x76,fp);

	for (i=0;i<16;i++) {
		setcol(i);
		bar(i*10,0,10+i*10,10);
	}

	for (i=479;i>=0;i--) {
		for (j=3;j>=0;j--) {
			outpw(0x3C4,(0x100<<j)|2);
			outpw(0x3CE,(j<<8)|4);
			memcpy(G_lnbuf+j*256,(UCHAR *)(0xA0000000L+((LONG)i*80L)),80);
		}
		for (j=0;j<80;j++) mov4b(G_lnbuf+1024+j*4,G_lnbuf+j);
		setcols(G_lnbuf+1024,320,16);
		fwrite(G_lnbuf+1024,320,1,fp);
	}
	fclose(fp);
	RETURNV(1);
}
IMAGE *getbmp(CHAR *name)
{
	FILE *fp;
	INT i,j,w;
	ULONG ofs;
	BMPH b;
	IMAGE *im;
	UCHAR *buf;
	UCHAR rb[360];
	ENTRY(3730);
		
	setlnbuf(16);
	buf=G_lnbuf;

	if (!isblk(name)) {
		if ((fp=fopen(name,"rb"))==NULL) RETURNV(NULL);
		fread(&b,sizeof(BMPH),1,fp);
		w=(((INT)(b.wid)+7)/8)*4;
		if (w==0) {
			fclose(fp);
			RETURNV(NULL);
		}
		ofs=(LONG)(b.hgt);
		ofs*=(LONG)intsize(w);
		ofs+=(LONG)intsize(sizeof(BMPH));
       	if (!setupblk(name,ofs)) {
#ifndef NON_GPA
			sendmsg("OUTPUT1",'o',0,0,"Can't setup %s %ld",name,ofs);
			sendmsg("INPUT1",'i');
#endif
			fclose(fp);
			RETURNV(NULL);
		}
       	savepblk(name,&b,0L,intsize(sizeof(BMPH)));
		fseek(fp,b.ofs,SEEK_SET);
		if (b.wid==640) {
			for (i=(INT)(b.hgt)-1;i>=0;i--) {
				fread(rb,w,1,fp);
				reorg(buf,rb,w);
				for (j=0;j<4;j++) {
					ofs=(LONG)j;
					ofs*=((LONG)b.hgt)*80L;
					ofs+=((LONG)i)*80L;
					ofs+=(LONG)intsize(sizeof(BMPH));
		       		savepblk(name,buf+j*80,ofs,80L);
				}
			}
		} else {
			for (i=0;i<b.hgt;i++) {
				ofs-=(LONG)intsize(w);
				fread(rb,w,1,fp);
				reorg(buf,rb,w);
	       		savepblk(name,buf,ofs,w);
			}
		}
		fclose(fp);
	} else {
       	restpblk(name,&b,0L,intsize(sizeof(BMPH)));
		w=(((INT)(b.wid)+7)/8)*4;
	}
	im=MALLOC(sizeof(IMAGE));
	if (im==NULL) RETURNV(NULL);
	strcpy(im->name,name);
	im->w=(INT)(b.wid);
	im->h=(INT)(b.hgt);
	im->sz=(INT)(b.hgt);
	im->ofs=(LONG)intsize(sizeof(BMPH));
	im->ln=0;
	im->bw=intsize((INT)(((b.wid+7)/8)*4));
	im->type=0;
	RETURNV(im);
}
void outhln(INT x,INT y,INT w,UCHAR *ln)
{
	UCHAR *scr=(UCHAR *)0xB0000000L+(x>>3)+((y&3)<<13)+((y>>2)*90);
	ENTRY(3740);
	w/=8;
	memcpy(scr,ln,w);
	RETURN;
}
INT animate(void)
{
	static UINT ticker=0;
	IMAGE *im;
	INT i,j;
	ENTRY(3750);
	ticker++;
	
	for (i=0;i<G_animtick;i++) {
		im=G_images[i];
		if (!(ticker%im->del)) {
			switch (im->type) {
				case 1 :
#ifndef NON_GPA
					j=sendmsg("INPUT3",'MI',im->x,im->y,im->x+im->w,im->y+im->sz);
					if (j) sendmsg("INPUT3",'C',0);
#endif
					animimage(im->x,im->y,im->sz,im->del,im);
#ifndef NON_GPA
					if (j) sendmsg("INPUT3",'C',-1);
#endif
					break;
				case 2 :
#ifndef NON_GPA
					j=sendmsg("INPUT3",'MI',im->x,im->y,im->x+im->w,im->y+im->sz);
					if (j) sendmsg("INPUT3",'C',0);
#endif
					rotimage(im->x,im->y,im->sz,im->st,im->del,im);
#ifndef NON_GPA
					if (j) sendmsg("INPUT3",'C',-1);
#endif
					break;
				case 3 :
					i++;
					if (im->ofs) {
						im->ofs=0;
						putimage(im->x,im->y,im);
					} else {
						im->ofs=1;
						im=G_images[i];
						putimage(im->x,im->y,im);
					}
					break;
			}
		}
	}
	RETURNV(1);
}
void delfromanim(CHAR *name)
{
    INT i;
    for (i=0;i<G_animtick;i++) {
        if (!strcmp(G_images[i]->name,name)) {
            freeimg(G_images[i]);
            for (;i<G_animtick-1;i++) {
                G_images[i]=G_images[i]+1;
            }
            G_animtick--;
            return;
        }
    }
}
void addtoanim(IMAGE *img)
{
	ENTRY(3760);
	if (G_animtick==0) {
#ifndef NON_GPA
		sendmsg("INPUT1",'A',1,animate);
#endif
	}
	if (G_animtick<10) {
		G_images[G_animtick++]=img;
	}
	RETURN;
}
void flipimages(INT x,INT y,INT del,IMAGE *img,IMAGE *img2)
{
	if (img==NULL) RETURN;
	if (img2==NULL) RETURN;
	if (img->type==0) {
		img->type=3;
		img->del=del;
		img->sz=0;
		img->ln=0;
		img->ofs=0;
		img->x=x;
		img->y=y;
		addtoanim(img);
	}
	if (img2->type==0) {
		img2->type=3;
		img2->del=del;
		img2->sz=0;
		img2->ln=0;
		img2->ofs=0;
		img2->x=x;
		img2->y=y;
		addtoanim(img2);
	}
	putimage(x,y,img);
	RETURN;
}
void animimage(INT x,INT y,INT size,INT del,IMAGE *img)
{
	INT i;
	LONG tl;
	UCHAR *buf=G_lnbuf;
	ENTRY(3770);
	if (img==NULL) RETURN;

	if (img->type==0) {
		img->type=1;
		img->del=del;
		img->sz=size;
		img->ln=0;
		img->ofs=intsize(sizeof(BMPH));
		img->x=x;
		img->y=y;
		addtoanim(img);
	} 
	if (isblk(img->name)) {
		tl=img->ofs;
		BITMASK(255); ESETRES(0); MAPMASK(15);
		for (i=0;i<size;i++) {
	    	restpblk(img->name,buf,tl,img->bw);
			outln(x,y++,img->w,buf,i==0);
			tl+=img->bw;
		}
		BITMASK(255); ESETRES(0); MAPMASK(15);
		img->ln+=size;
		if (img->ln>=img->h) {
			tl=sizeof(BMPH);
			img->ln=0;
		}
		img->ofs=tl;
	}
	RETURN;
}
void rotimage(INT x,INT y,INT size,INT step,INT del,IMAGE *img)
{
	INT i,j;
	LONG tl;
	UCHAR *buf=G_lnbuf;
	ENTRY(3780);
	if (img==NULL) RETURN;

	if (img->type==0) {
		bezel(x-3,y-2,x+img->w+1,y+size+2,1);
		img->type=2;
		img->del=del;
		img->sz=size;
		img->st=step;
		img->ln=0;
		img->ofs=(LONG)intsize(sizeof(BMPH));
		img->x=x;
		img->y=y;
		addtoanim(img);
	} 
	if (isblk(img->name)) {
		tl=img->ofs;
		j=img->ln;
		BITMASK(255); ESETRES(0); MAPMASK(15);
		for (i=0;i<size;i++) {
	    	restpblk(img->name,buf,tl,img->bw);
			outln(x,y++,img->w,buf,i==0);
			if (((j+i)>=size)&&((j+i)<(img->h+size)-1)) tl+=img->bw;
		}
		BITMASK(255); ESETRES(0); MAPMASK(15);
		img->ln+=step;
		if (img->ln>size) {
			img->ofs=(LONG)intsize(sizeof(BMPH));
			img->ofs+=((LONG)(img->ln-size)*(LONG)img->bw);
		}
		if (img->ln>=(img->h+size)) {
			img->ln=0;
			img->ofs=sizeof(BMPH);
		}
	}
	RETURN;
}
void putimage(INT x,INT y,IMAGE *img)
{
	INT i;
	LONG tl;
	UCHAR *buf=G_lnbuf;
	ENTRY(3790);
	if (img==NULL) RETURN;
	switch (G_curgd->type) {
		case 1 :
		    if (isblk(img->name)) {
				tl=(LONG)intsize(sizeof(BMPH));
				for (i=0;i<img->h;i++) {
	    			restpblk(img->name,buf,tl,img->bw);
					outhln(x,y+i,img->w,buf);
					tl+=img->bw;
				}
			}
			break;

		default :
		    if (isblk(img->name)) {
				tl=(LONG)intsize(sizeof(BMPH));
				BITMASK(255); ESETRES(0); MAPMASK(15);
				if (img->w==640) {
					for (i=0;i<4;i++) {
						WRITEPLANE(i);
	    				restpblk(img->name,(UCHAR *)(0xA0000000L+(y*80)),tl,((LONG)img->h)*80L);
						tl+=((LONG)img->h)*80L;
					}
				} else {
					for (i=0;i<img->h;i++) {
	    				restpblk(img->name,buf,tl,img->bw);
						outln(x,y++,img->w,buf,i==0);
						tl+=img->bw;
					}
				}
				BITMASK(255); ESETRES(0); MAPMASK(15);
			}
	}
	RETURN;
}
void freeimg(IMAGE *img)
{
	ENTRY(3800);
	if (img==NULL) RETURN;
	FREE(img);
	RETURN;
}
UCHAR *loadffont(CHAR *fontfile)
{
	CHAR *tmp;
	INT fd;
	UINT wid,ofs;
	ENTRY(3810);

	switch (G_curgd->type) {
		case 1 :
			ofs=256*16+32;
			wid=14;
			break;
		case 0 :
		default :
			ofs=32;
			wid=16;
			break;
	}
	if ((tmp=MALLOC(256*wid))==NULL) RETURNV(NULL);
	if ((fd=open(fontfile,O_RDONLY|O_BINARY))==(-1)) RETURNV(NULL);
	read(fd,G_testbuf,32);
	if (G_testbuf[31]=='R') G_righthand=1;
	lseek(fd,ofs,SEEK_SET);
	read(fd,tmp,256*wid);
	close(fd);
	RETURNV((UCHAR *)tmp);
}
void loadlfont(CHAR *name,INT type)
{
	INT fd,i,j;
	LONG ofs;
	FMAP1 bfont;
	FMAP *fonts;
	UINT fhw;
	UCHAR fwid,fhgt,fbw;
	UCHAR *ch,tmp;
	ENTRY(3820);
	
	if ((fd=open(name,O_RDONLY|O_BINARY))==(-1)) RETURN;
	if (type==1) {
		lseek(fd,0x3E,SEEK_SET);
		read(fd,&fwid,1); read(fd,&fhgt,1); fbw=fwid/8;
		fhw=(fwid<<8)|fhgt;
		lseek(fd,SOMAP,SEEK_SET);
		read(fd,&bfont,sizeof(FMAP1));
		fonts=MALLOC(bfont.len*sizeof(FMAP));
		if (fonts==NULL) { close(fd); RETURN; }
		read(fd,fonts,bfont.len*sizeof(FMAP));
		ofs=2L+(LONG)sizeof(FMAP1)+(LONG)(bfont.len*sizeof(FMAP));
		ofs+=(LONG)(bfont.b.len*((fbw-1)*fhgt));
		for (i=0;i<bfont.len;i++) ofs+=(LONG)(fonts[i].len*fbw*fhgt);
		ch=MALLOC(bfont.b.len*((fbw-1)*fhgt));
		if (ch==NULL) { close(fd); RETURN; }
		if (!setupblk(name,ofs)) { FREE(ch); close(fd); RETURN; }
		lseek(fd,bfont.b.ofs,SEEK_SET);
		for (j=0;j<bfont.b.len;j++) {
			read(fd,&tmp,1);
			read(fd,ch+j*((fbw-1)*fhgt),((fbw-1)*fhgt));
		}
		ofs=2L+sizeof(FMAP1)+(bfont.len*sizeof(FMAP));
		bfont.b.ofs=ofs;
		savepblk(name,&fhw,0L,2L);
		savepblk(name,&bfont,2L,sizeof(FMAP1));
		savepblk(name,ch,ofs,(bfont.b.len*((fbw-1)*fhgt)));
		ofs+=(bfont.b.len*((fbw-1)*fhgt));
		FREE(ch);
		for (i=0;i<bfont.len;i++) {
			if (fonts[i].len) {
 				ch=MALLOC(fonts[i].len*fbw*fhgt);
				lseek(fd,fonts[i].ofs,SEEK_SET);
				for (j=0;j<fonts[i].len;j++) {
					read(fd,&tmp,1);
					read(fd,ch+j*fbw*fhgt,fbw*fhgt);
				}
				fonts[i].ofs=ofs;
				savepblk(name,ch,ofs,fonts[i].len*fbw*fhgt);
				ofs+=fonts[i].len*fbw*fhgt;
				FREE(ch);
			}
		}
		savepblk(name,fonts,2L+sizeof(FMAP1),(LONG)(bfont.len*sizeof(FMAP)));
		FREE(fonts);
	} else {
		ch=MALLOC(15000);
		if (ch==NULL) { close(fd); RETURN; }
		if (!setupblk(name,942768L)) { FREE(ch); close(fd); RETURN; }
		for (j=0;j<62;j++) {
			read(fd,ch,15000);
			savepblk(name,ch,((LONG)j)*15000L,15000L);
		}
		read(fd,ch,144*7);
		savepblk(name,ch,((LONG)j)*15000L,12768);
		FREE(ch);
	}
    close(fd);
	RETURN;
}
void button(INT x,INT y,INT x1,INT y1,INT t,INT up,CHAR *c,INT split)
{
	INT i,w,h,sw,sh;
	INT xo,yo;
	CHAR tmp[80],*s;
	CHAR tst[2];
	ENTRY(3830);
	if (G_curgd->type!=0) RETURN;
	tst[1]=0;
	sh=0;
	sw=0;
	if (split) tst[0]='^'; else tst[0]='\n';
	s=tmp;	
	strcpy(tmp,c);
	s=strtok(tmp,tst);
	while (s!=NULL) {
		sh++;
		s=strtok(NULL,tst);
	}
	sw=1+(G_curgd->cf->size>1);
	if (G_curgd->f.type<200) sh*=1+(G_curgd->cf->size==3);
	sw*=G_curgd->cf->pwid;
	sh*=G_curgd->cf->phgt;
	sw/=4;
	sh/=2;
	w=(x1-x);
	h=(y1-y);

	xo=(x+(w/2))+(t*(!up));
	yo=((y+(h/2))-sh)+(t*(!up));

	setcol(0);
	bar(x,y,x1,y1);
	setcol(2);
	moveto(x+1,y);
	lineto(x1-1,y);
	moveto(x1,y+1);
	lineto(x1,y1-1);
	moveto(x1-1,y1);
	lineto(x+1,y1);
	moveto(x,y1-1);
	lineto(x,y+1);

	s=tmp;	
	strcpy(tmp,c);
	s=strtok(tmp,tst);
	while (s!=NULL) {
		prln(xo-(sw*strlen(s)),yo,"%s",s);
		yo+=G_curgd->cf->phgt;
		s=strtok(NULL,tst);
	}
	if (up) {
		moveto(x+1,y1-1);
		for (i=1;i<=t;i++) {
			w-=2;
			h-=2;
			setcol(15);
			linerel(0,-h);
			linerel(w,0);
			setcol(8);
			linerel(0,h);
			linerel(-w,0);
			moverel(1,-1);
		}
	} else {
		setcol(8);
		moveto(x+1,y1-1);
		linerel(0,0-(h-2));
		linerel(w-1,0);
	}
	RETURN;
}
void bmpbutt(INT x,INT y,IMAGE *img,INT t,INT up)
{
	ENTRY(3840);
	button(x,y,x+t*2+img->w+2,y+t*2+img->h+2,t,up,"",0);
	if (up) {
		putimage(1+x+t,1+y+t,img);
	} else {
		putimage(1+x+t*2,1+y+t*2,img);
	}
	RETURN;
}
void bezel(INT x,INT y,INT x1,INT y1,INT depth)
{
	INT i,w,h;
	ENTRY(3850);
	w=(x1-x);
	h=(y1-y);
	moveto(x+1,y1-1);
	for (i=0;i<depth;i++) {
		setcol(15);
		linerel(w,0);
		linerel(0,-h);
		setcol(8);
		linerel(-w,0);
		linerel(0,h);
		moverel(1,-1);
		w-=2;
		h-=2;
	}
	for (i=0;i<depth;i++) {
		setcol(15);
		linerel(0,-h);
		linerel(w,0);
		setcol(8);
		linerel(0,h);
		linerel(-w,0);
		moverel(1,-1);
		w-=2;
		h-=2;
	}
	RETURN;
}
void tinyxy(INT c,INT x,INT y,CHAR *fmt,...)
{
	INT xp,yp,i,mx,col;
	UCHAR *t,tmp[160],*s;
	va_list ap;
	ENTRY(3860);
	va_start(ap,fmt);
	vsprintf((CHAR *)tmp,fmt,ap);
	va_end(ap);
	s=tmp;
	col=G_curgd->col;
	setcol(c);
	y+=7;
	while (*s) {
		mx=0;
		if ((*s>31)&&(*s<=127)) {
			i=G_charofs[*s-32];
			t=G_chardefs+i;
			i=((G_charofs[*s-31]-i)/2)-1;
			while (i--) {
				xp=(*t&0x3F)-(64*((*(t++)&0x40)!=0));
				yp=(*t&0x3F)-(64*((*(t  )&0x40)!=0));
				if (!(*(t)&0x80)) {
					moveto(x+xp,y-yp);
				} else {
					lineto(x+xp,y-yp);
				}
			  	mx=max(mx,x+xp);
				t++;
			}
		}
		s++;
		x=mx;
	}
	G_curgd->col=col;
	RETURN;
}

