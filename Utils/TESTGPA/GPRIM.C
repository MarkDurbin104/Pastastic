#define GPRIM_C
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <alloc.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>

#include <conio.h>
#include <time.h>
#include "types.h"
#include "gprim.h"
#include "config.h"
#include "control.h"
#include "message.h"
#include "tintext.h"
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

typedef struct {        // Structure in file ???? check.
	UCHAR len;          // Length
	UCHAR type;         // type 
	UCHAR fc;           // First char
	UCHAR lc;           // Last char
	LONG  ofs;          // offset
} FMAP;
typedef struct {
	FMAP b;
	UCHAR len;
	UCHAR type;
	UCHAR fc;
	UCHAR lc;
} FMAP1;

typedef struct {
	UCHAR pwid;             // Pixel width
	UCHAR phgt;             // Pixel height
	UCHAR bwid;             // number of bytes
	UCHAR size;             // Font detail structure. 1,2,3 sizes
	UCHAR huge *ftab;       // Font table
} FDET;
typedef FDET *PFDET;

typedef struct {
	INT   numf;         // Number of fonts
	UCHAR type;         // Type - what types are available. 1 Latin, 2 Chinese, 3 Madarin
	UINT  fchar;        // First character
	UINT  lchar;        // Last Character
	FDET  f[3];         // Font details (1,2, or 3)
} FONTDIM;

typedef FONTDIM *PFONTDIM;

typedef struct {            // Graphics device
	INT    type;        // 0 VGA, 1 Herc
	INT    px;          // Current pixel coord x    (lineto)
	INT    py;          // Current pixel coord y
	INT    cx;          // Current character coord x (prline)
	INT    cy;          // Current character coord y
	CHAR   col;         // Current default colour
	INT    inv;         // Whether inverting or not (1 == inverted)
	INT    wm;          // Write mode (1 == XOR)
	FONTDIM  f;         // Font dimensions
	PFDET    cf;        // Pointer font details
} GDEV;
typedef GDEV *PGDEV;
typedef struct {
	INT x,y,x1,y1;
} BOX;
typedef struct {
    CHAR  *name;  // bitmap name
    IMAGE *image; // bitmap image struct
    INT    age;   // the oldest bitmap has the lowest number
} LOADBMP;
#define NUMIMINLIST 10
LOADBMP G_lastloadbmps[NUMIMINLIST]={
    {NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0},
    {NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0},{NULL,NULL,0}
};
GDEV   *G_grdevs=NULL;      // Pointer to array of graphics devices
INT    G_numgd=0;           // Number of graphics devices
PGDEV  G_curgd=NULL;        // Pointer to current graphics device
        // Lookup table for magnifying fonts by two
UCHAR  G_nybbmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
        // Screen data for Herc controller (register data)
UINT16 G_sdata[9]={0x3500,0x2D01,0x2E02,0x0703,0x5B04,0x0205,0x5706,0x5707,0x0309};
UCHAR *G_lnbuf=NULL;        // Current line of printed font
INT    G_lnbufsize=0;       // Current size of line buffer
INT    G_check=1;
INT    G_dontdraw=0;        // Screen saver switch, 1 for on, 0 for off
UINT *G_scrc=NULL;          // Character data map for herc redraw (doesn't do graphics)
BOX    G_boxes[10];         // Box        "    "    "  "    "
UINT G_numbx;               // Number of boxes currently saved
                // Date security (doesn't work in protected mode)
UCHAR  G_testbuf[32]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
FPTR   G_runtest=(FPTR)G_testbuf;
INT  G_animtick=0;          // Animation tick count
IMAGE *G_images[10];        // Animation images

//S Add an image to the maintained list of images
//D Add an image to the maintained list of images if there is
//D no room - remove the oldest one and add there
//P the IMAGE structure
//P the name of the image
void addimage2list(IMAGE *im,CHAR *name)
{
    UINT youngest=0,oldest=65535U;
    INT i,freeone=0;
    for (i=0;i<NUMIMINLIST;i++) { // find oldest youngest and available image
        youngest=max(youngest,G_lastloadbmps[i].age); 
        oldest=min(oldest,G_lastloadbmps[i].age);
        if ((G_lastloadbmps[i].age==0)&&(!freeone)) {
            freeone=i+1;
        }
    }
    youngest++;       // this one's age
    if (freeone) {    // one availavble - add here
        G_lastloadbmps[freeone-1].age=youngest;
        G_lastloadbmps[freeone-1].image=im;
        G_lastloadbmps[freeone-1].name=strdup(name);
    } else {        // none available
        for (i=0;i<NUMIMINLIST;i++) {
            if (G_lastloadbmps[i].age==oldest) {  // find the oldest
                freeimg(G_lastloadbmps[i].image); // release it
                if (G_lastloadbmps[i].name!=NULL) FREE(G_lastloadbmps[i].name);
                G_lastloadbmps[i].age=youngest;   // add new one
                G_lastloadbmps[i].image=im;
                G_lastloadbmps[i].name=STRDUP(name);
                break;
            }
        }
    }
}
//*****************************************************
//F vidint
//S Generate an INT 10h Video interrupt
//P AX value to use
void vidint(INT16 rax)
{
	ENTRY(3210);
    _EAX=0;
    _AX=rax;
    geninterrupt(0x10);
	RETURN;
}
//*****************************************************
//F monomode
//S Set screen mode to text 80x25
void monomode(void)
{
	ENTRY(3211);
         //         text  pixel colors disp scrn  system
         //         resol  box         page addr
         //   03h = 80x25  8x8     16     4 B800 CGA
         //       = 80x25  8x8     16     8 B800 EGA,MCGA,VGA
	vidint(3);
	RETURN;
}
//*****************************************************
//F restart
//S Sets G_curgd to point to device index supplied
//D Checks that the index supplied is a valid index number.  Does not
//D indicate failure. Returns number of graphics devices less 1.
//D Calls int 10h AH=0 AL=12 - To Set VGA at 640x480 16 colours
//P Graphics device index
INT restart(INT idx)
{
	ENTRY(3212);
	if (idx<G_numgd) G_curgd=&G_grdevs[idx];
	vidint(0x0012); // Mode 12h - VGA 640x480 16 colours
	RETURNV(G_numgd-1);
}
//*****************************************************
//F closegraf
//S Close down all graphics devices, free memory up
void closegraf(void)
{
	INT i;
	ENTRY(3220);
	if (G_numgd==0) RETURN;         // No graphics devices open
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
         //         text  pixel colors disp scrn  system
         //         resol  box         page addr
         //   03h = 80x25  8x8     16     4 B800 CGA
         //       = 80x25  8x8     16     8 B800 EGA,MCGA,VGA
	vidint(3); // Text mode
	G_numgd=0;
	RETURN;
}
//*****************************************************
//F grafix
//S Set up a graphics device
//P Type of graphic device
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
	G_grdevs[G_numgd].col=15;       // default colour ????white????
	G_grdevs[G_numgd].inv=0;
	G_grdevs[G_numgd].wm=0;
	G_grdevs[G_numgd].f.numf=0;
	G_grdevs[G_numgd].cf=NULL;
	G_curgd=&G_grdevs[G_numgd];
	G_numgd++;
	if (G_scrc==NULL) G_scrc=MALLOC(4000*sizeof(INT));
	if (G_scrc==NULL) RETURNV(-1);
	switch (G_curgd->type) {
		case 1 :                    // Hercules
			cls();
			OUTPB(0x3BF,1);
			OUTPB(0x3B8,0);
			for (i=0;i<9;i++) OUTPW(0x3B4,G_sdata[i]);
			OUTPB(0x3B8,0x0A);
			G_dontdraw=0;
			break;
		default :
			vidint(0x0012);
	}
	RETURNV(G_numgd-1);
}
//*****************************************************
//F usegdev
//S Set the current graphics device to use (sets G_curgd)
//P Index of device to make current
void usegdev(INT idx)
{
	ENTRY(3240);
	if (idx<G_numgd) G_curgd=&G_grdevs[idx];
	RETURN;
}
//*****************************************************
//F cls
//S Clear screen
void cls(void)
{
	INT i;
	ENTRY(3250);
    if (G_scrc!=NULL) memset(G_scrc,0,8000);
	G_numbx=0;
	switch (G_curgd->type) {
		case 1 :
//			if (!G_dontdraw) {
				memset(MONOVIDMEM,0,0x8000);
//			}
			break;
		default :
#ifndef NON_GPA
		    sendmsg("INPUT1",MESSAGE_D,animate);
#endif
			for (i=0;i<G_animtick;i++) freeimg(G_images[i]);
			G_animtick=0;
		    OUTPW(0x3C4,0x0F02);
		    OUTPW(0x3CE,0xFF08);
		    OUTPW(0x3CE,0x0001);
		    OUTPW(0x3CE,0x0003);
		    memset(COLVIDMEM,0,38400U);
	}
#ifndef NON_GPA
	sendmsg("REMHOT",MESSAGE_TILDI);
	sendmsg("INPUT1",MESSAGE_K,0,"~~"," ");
#endif
	G_curgd->px=0;
	G_curgd->py=0;
	G_curgd->cx=0;
	G_curgd->cy=0;
	RETURN;
}
//*****************************************************
//F flipscr
//S XOR screen if hercules and not currently updating
void flipscr(void)
{
	INT i;
	ULONG *s;
	ENTRY(3260);
	if ((G_curgd->type==1)&&(G_dontdraw)) {
	  	s=(ULONG *)MONOVIDMEM;
		for (i=0;i<0x2000;i++) *(s++)^=0xFFFFFFFFL;
	}
	RETURN;
}
//*****************************************************
//F maxx
//S Returns maximum x value for current screen
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
//*****************************************************
//F maxy
//S Returns maximum y value for current screen
//P
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
//*****************************************************
//F putpixel
//S Set a pixel at location x,y
//P X position
//P Y position
void putpixel(INT x,INT y)
{
	UCHAR *scr,m=(UCHAR)(0x80>>(x&7));
	ENTRY(3290);

	switch (G_curgd->type) {
		case 1 :
//			if (G_dontdraw) RETURN;
			scr=(UCHAR *)MONOVIDMEM+(x>>3)+((y&3)<<13)+((y>>2)*90);
			if (G_curgd->wm) 
				*scr^=m;
			else
				if (G_curgd->col&(CHAR)2) *scr|=m; else *scr&=(CHAR)(m^0xFF);
			break;
		default :
			scr=(UCHAR *)COLVIDMEM+(y*80)+(x>>3);
			if (G_curgd->wm) OUTPW(0x3CE,0x1803);
			OUTPW(0x3CE,0x0F01);
            OUTPB(0x3CE,0);
			OUTPB(0x3CF,G_curgd->col);
            OUTPB(0x3CE,8);
			OUTPB(0x3CF,m);
			*scr&=m;
			OUTPW(0x3C4,0x0F02);
			OUTPW(0x3CE,0xFF08);
			OUTPW(0x3CE,0x0001);
			if (G_curgd->wm) OUTPW(0x3CE,0x0003);
	}
	RETURN;
}
//*****************************************************
//F getpixel
//S Get pixel value location at x,y.  Returns 1 or 0
//P X position
//P Y position
INT getpixel(INT x,INT y)
{
	UCHAR *scr,m=(UCHAR)(0x80>>(x&7));
	INT ret,i;
	ENTRY(3300);
	switch (G_curgd->type) {
		case 1 :
			scr=(UCHAR *)(MONOVIDMEM+(x>>3)+((y&3)<<13)+((y>>2)*90));
			ret=((*scr&m)!=0);
			break;
		default :
			scr=(UCHAR *)(COLVIDMEM+(INT)((LONG)y*80L)+(x>>3));
			ret=0;
			for (i=3;i>=0;i--) {
                OUTPB(0x3CE,4);
                OUTPB(0x3CF,(CHAR)i);
                OUTPB(0x3C4,2);
				OUTPB(0x3C5,(CHAR)(1<<i));
				if ((*scr&m)==m) ret|=1;
				ret<<=1;
			}
			ret>>=1;
	}
	RETURNV(ret);
}
//*****************************************************
//F setwmode
//S Set the write mode for the current device
//P Write mode
void setwmode(UCHAR mode)
{
	ENTRY(3310);
	mode&=1;
	if (G_curgd->wm!=mode) {
		G_curgd->wm=mode;
	}
	RETURN;
}
//*****************************************************
//F invtext
//S Set current device output to inverse mode
void invtext(void)
{
	ENTRY(3320);
	G_curgd->inv=1;
	RETURN;
}
//*****************************************************
//F normtext
//S Set current device output to normal mode
void normtext(void)
{
	ENTRY(3330);
	G_curgd->inv=0;
	RETURN;
}
//*****************************************************
//F setcol
//S Set the default colour for the current screen
//P Colour - Range 0 to 15 - Value in top nibble for inverted text, bottom nibble normal text
void setcol(UCHAR col)
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
//*****************************************************
//F moveto
//S Set the current device x,y pixel location
//P Absolute x location
//P Absolute y location
void moveto(INT x,INT y)
{
	ENTRY(3350);
	G_curgd->px=x;
	G_curgd->py=y;
	RETURN;
}
//*****************************************************
//F moverel
//S Relative move of the current device x,y pixel location
//P Relative x movement
//P Relative y movement
void moverel(INT dx,INT dy)
{
	ENTRY(3360);
	G_curgd->px+=dx;
	G_curgd->py+=dy;
	RETURN;
}

//*****************************************************
//F yline
//S
//P
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
   	mov ax,COLVIDSEG
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

//*****************************************************
//F xline
//S
//P
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
    mov ax,COLVIDSEG
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

//*****************************************************
//F vlineh
//S
//P
void vlineh(INT x,INT y1,INT y2)
{
	UCHAR *t=(UCHAR *)MONOVIDMEM,*s; 
	UCHAR m1=(UCHAR)(0x80>>(x&7)),m2;
	INT y;
	ENTRY(3390);
	m2=(CHAR)(m1^0xFF);
	t+=x>>3;
	for (y=y1;y<=y2;y++) {
		s=(t+((y&3)*0x2000)+((y>>2)*90));
		*s&=m2;
		*s|=m1;
	}
	RETURN;
}
//*****************************************************
//F horizln
//S
//P
void horizln(INT x1,INT x2,INT y)
{
	UCHAR *t,*s;
	UCHAR m1=0xFF,m2=0xFF;
	INT w,i,j;
	ENTRY(3400);
	m1>>=(UCHAR)(x1&7); m2>>=(UCHAR)((x2&7)+1); m2=(CHAR)(m2^0xFF);
	w=(x2>>3)-(x1>>3);
	switch (G_curgd->type) {
		case 1  :
			t=(UCHAR *)MONOVIDMEM+((y&3)*0x2000)+((y>>2)*90)+(x1>>3);
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
			s=(UCHAR *)COLVIDMEM+(y*80)+(x1>>3);
			if (G_curgd->wm) {
				for (i=0;i<4;i++) {
					t=s;
					if (((1<<i)&G_curgd->col)!=0) {
                        OUTPB(0x3CE,4);
                        OUTPB(0x3CF,(CHAR)i);
                        OUTPB(0x3C4,2);
				        OUTPB(0x3C5,(CHAR)(1<<i));
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
                    OUTPB(0x3CE,4);
                    OUTPB(0x3CF,(CHAR)i);
                    OUTPB(0x3C4,2);
				    OUTPB(0x3C5,(CHAR)(1<<i));
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
								m1&=m2;	*t&=(CHAR)(m1^0xFF); break;
							case 1:
								*t&=(CHAR)(m1^0xFF); t++; *t&=(CHAR)(m2^0xFF); break;
							default:
								*t&=(CHAR)(m1^0xFF); t++;
								memset(t,0,w-1); t+=w-1;
								*t&=(CHAR)(m2^0xFF);
						}
					}
				}
			}
			break;
	}
	RETURN;
}
//*****************************************************
//F lineto
//S
//P
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
				OUTPW(0x3C4,0x0F02);
				OUTPW(0x3CE,0xFF08);
				OUTPW(0x3CE,0x0F01);
				OUTPW(0x3CE,(UINT16)(G_curgd->col<<8));
				if (G_curgd->wm) OUTPW(0x3CE,0x1803);
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
				OUTPW(0x3C4,0x0F02);
				OUTPW(0x3CE,0xFF08);
				OUTPW(0x3CE,0x0001);
				if (G_curgd->wm) OUTPW(0x3CE,0x0003);
			}
	}
	moveto(x,y);
	RETURN;
}
//*****************************************************
//F linerel
//S
//P
void linerel(INT dx,INT dy)
{
	ENTRY(3420);
	lineto(G_curgd->px+dx,G_curgd->py+dy);
	RETURN;
}
//*****************************************************
//F line
//S
//P
void line(INT x1,INT y1,INT x2,INT y2)
{
	ENTRY(3430);
	moveto(x1,y1);
	lineto(x2,y2);
	RETURN;
}
//*****************************************************
//F chkbx
//S
//P
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
//*****************************************************
//F rectangle
//S
//P
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
//*****************************************************
//F bar
//S
//P
void bar(INT x1,INT y1,INT x2,INT y2)
{
	INT i;
	ENTRY(3460);
	if (x1>x2) { i=x1; x1=x2; x2=i; }
	if (y1>y2) { i=y1; y1=y2; y2=i; }
	for (i=y1;i<=y2;i++) horizln(x1,x2,i);
	RETURN;
}
//*****************************************************
//F dublit
//S
//P
UINT dublit(UCHAR c,UCHAR swap)
{
    UINT r;
	ENTRY(3470);
    if (swap)
        r=(G_nybbmap[c>>4]<<8)|G_nybbmap[c&0xF];
    else 
        r=(G_nybbmap[c&0xF]<<8)|G_nybbmap[c>>4];
    RETURNV(r);
}
//*****************************************************
//F putin
//S
//P
void putin(UCHAR *a,UCHAR c)
{
    *a     =G_nybbmap[c>>4];
    *(a+16)=G_nybbmap[c&0xF];
}
//*****************************************************
//F magnify
//S
//P
void magnify(UCHAR huge *f,UCHAR *a)
{
	UINT i,j;
	ENTRY(3490);
	for (i=0;i<256;i++) {
		for (j=0;j<16;j++) putin(a++,*(f++));
		a+=16;
	}
	RETURN;
}
//*****************************************************
//F getofs
//S
//P
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
	a-=(CHAR)0x40; if (a>0x3F) a-=(CHAR)0x22;
	lw*=a;
	RETURNV(ret+lw);
}

//*****************************************************
//F lstr2buf
//S
//P
INT lstr2buf(UCHAR *buf,UCHAR huge *name,UCHAR *str,UCHAR hgt,UCHAR wid,INT inv)
{
	LONG base,fmaps;
	UCHAR o,tmp[72],*b,dh,dw;
    UCHAR huge *f;
	INT i,ret=0,l;
	UINT j,k;
	FMAP1 bfont;
	FMAP  font;
	ENTRY(3500);
	if (name==NULL) RETURNV(0);
	dw=((G_curgd->cf->size-1)>0)*2;
	dh=((G_curgd->cf->size-1)==2);
	if (dh) hgt/=2;
	if (G_curgd->f.type==201) {
		_fmemcpy(&bfont,name+2,sizeof(FMAP1));
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
            		_fmemcpy(&font,name+fmaps+(o*sizeof(FMAP)),sizeof(FMAP));
					o=*(str++)-0xA1;
            		_fmemcpy(tmp,name+font.ofs+o*hgt*wid,hgt*wid);
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
            		_fmemcpy(tmp,name+bfont.b.ofs+(*str)*hgt*(wid-1),hgt*(wid-1));
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
                f=name+base;
//				for (fmaps=0;fmaps<base;fmaps++) f++; 
				for (i=0;i<hgt;i++) {
              		for (l=0;l<j;l++) *(b+l)=*(f++);
					b+=256;
				}
				ret+=j;
				buf+=j;
			}
		}
	}
	RETURNV(ret);
}

//*****************************************************
//F str2buf
//S
//P
INT str2buf(UCHAR *buf,UCHAR huge *f,UCHAR *s,UCHAR hgt,UCHAR wid,INT inv)
{
    INT r=0;
    INT i,j;
    UCHAR *b;
    UCHAR huge *c;
    if ((buf==NULL)||(s==NULL)||(f==NULL)) return(0);
    while (*s) {
        c=f+(*s*wid*hgt);
        for (i=0;i<wid;i++) {
            b=buf;
            for (j=0;j<hgt;j++) {
                if (inv) *b=(CHAR)(*c^0xFF); else *b=*c;
                c++;
                b+=256;
            }
            r++;
            buf++;
        }
        s++;
    }
    return(r);
}
//*****************************************************
//F shiftln
//S
//P
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
//*****************************************************
//F hswapbytes
//S
//P
UINT16 hswapbytes(UINT16 i)
{
	ENTRY(3530);
    RETURNV((UINT16)(i>>8)|(UINT16)(i<<8));
}
// put a word bitmap into HERC screen
//*****************************************************
//F putint
//S
//P
void putint(INT x,INT y,UINT i,UINT j)
{
	UCHAR *t=(UCHAR *)MONOVIDMEM;
	ENTRY(3540);
    t+=x+((y&3)<<13)+((y>>2)*90);
    
    if (G_curgd->wm) {
        *((INT16 *)t)^=hswapbytes((INT16)i);
    }
    else {
        *((INT16 *)t)&=hswapbytes((INT16)j);
        *((INT16 *)t)|=hswapbytes((INT16)i);
    }
	RETURN;
}
// set the ninth bit for HERC output
//*****************************************************
//F nthbit
//S
//P
INT nthbit(INT ch)
{
	ENTRY(3550);
    RETURNV((ch<<1)|(ch&1));
}
// get the character value
//*****************************************************
//F getcval
//S
//P
INT getcval(INT cpos)
{
	ENTRY(3560);
    if (G_curgd->inv) RETURNV(G_curgd->cf->ftab[cpos]^0xFF);
    RETURNV(G_curgd->cf->ftab[cpos]);
}
// true if the screen is currently set to the same
//*****************************************************
//F scrsetto
//S
//P
INT scrsetto(INT x,INT y,UINT v)
{
	INT o=x+y*80;
	ENTRY(3570);
    if ((x>79)||(y>25)) RETURNV(1);
    if (G_scrc[o]==v) RETURNV(1);
	G_scrc[o]=v;
    RETURNV(0);
}
// HERC character output routine
//*****************************************************
//F houtch
//S
//P
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
                ch=(UCHAR)getcval(cpos);
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
                ch=(UCHAR)getcval(cpos);
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
//*****************************************************
//F scrredraw
//S
//P
void scrredraw(void)
{
	INT i,j,o;
	INT cl,iv,sz;
	ENTRY(3590);

	if (G_curgd->type!=1) RETURN;

	cl=G_curgd->col;
	iv=G_curgd->inv;
	sz=G_curgd->cf->size;
	memset((UCHAR *)MONOVIDMEM,0,0x8000);
	G_check=0;
	for (j=0;j<25;j++) {
		for (i=0;i<80;i++) {
			o=G_scrc[j*80+i];
			if ((o)&&((o>>8)!=' ')) {
				G_curgd->col     =(CHAR)((o>>4)&15);
				G_curgd->inv     =(o>>3)&1;
				G_curgd->cf->size=(CHAR)(o&15);
				houtch(i,j*G_curgd->cf->phgt,(CHAR)(o>>8));
			}
		}
	}
	G_curgd->col=2;
	G_curgd->inv=0;
	for (i=0;i<G_numbx;i++) 
		rectangle(G_boxes[i].x,G_boxes[i].y,G_boxes[i].x1,G_boxes[i].y1);
	G_check=1;
	G_curgd->col     =(CHAR)cl;
	G_curgd->inv     =iv;
	G_curgd->cf->size=(CHAR)sz;
	RETURN;
}
//*****************************************************
//F dontdraw
//S Screen saver switch
//P 1 screensave on, 0 screen save off.
void dontdraw(INT v)
{
	ENTRY(3600);
	if (G_dontdraw==v) RETURN;
	G_dontdraw=v;
//	if (!v) scrredraw();
	RETURN;
}
//*****************************************************
//F prln
//S
//P
void prln(INT x,INT y,CHAR *fmt, ... )
{
    UCHAR str[140];
	UCHAR w,xofs=(UCHAR)(x>>3);
	UCHAR xsft=(UCHAR)(x&7);
	UINT col=(G_curgd->col<<8)|2;
    UINT val;
	UCHAR *smem;
	UCHAR ht,*s,*buf=G_lnbuf,*b,*t;
	UCHAR h,i,j;
	va_list ap;
	ENTRY(3610);
	if ((G_curgd->cf==NULL)||(G_lnbufsize==0)) RETURN;
                   
//	if (G_testbuf[0]!=0) { (G_runtest)(); G_testbuf[0]=0; }

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
		    t=str;
            i=x/8;
		    while (*t) {
        		val=(((UINT)*t)<<8)|(G_curgd->col<<4)|(G_curgd->inv<<3)|G_curgd->cf->size;
        	    scrsetto(i++,y/19,val);
                if (G_curgd->cf->size!=1) i++;
                t++;
            }
			smem=(UCHAR *)COLVIDMEM+(y*80)+xofs;
			if (G_curgd->f.type>=200) {
				w=lstr2buf(buf,G_curgd->cf->ftab,str,h,G_curgd->cf->bwid,G_curgd->inv);
			} else {
				w=(UCHAR)str2buf(buf,G_curgd->cf->ftab,str,h,G_curgd->cf->bwid,G_curgd->inv);
			}
			if (xsft) shiftln(buf,w++,h,xsft);
			if ((xofs+w)>80) w=(UCHAR)(80-xofs);
			if (G_curgd->wm) {
				for (i=0;i<4;i++) {
					if (((1<<i)&G_curgd->col)!=0) {
						s=smem; ht=h; buf=G_lnbuf;
                        OUTPB(0x3CE,4);
                        OUTPB(0x3CF,(CHAR)i);
                        OUTPB(0x3C4,2);
    				    OUTPB(0x3C5,(CHAR)(1<<i));
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
					OUTPW(0x3C4,(UINT16)col);
					while (ht--) {
						if (G_curgd->cf->size==3) {
							memcpy(s,buf,w);
							s+=80;
						}
						memcpy(s,buf,w);
						s+=80;
						buf+=256;
					}
				}
				col^=0x0F00;
				if (col!=2) {
					OUTPW(0x3C4,(UINT16)col);
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
//*****************************************************
//F setlnbuf
//S
//P
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
//*****************************************************
//F attachfont
//S
//P
INT attachfont(UCHAR huge *f,UCHAR type,UCHAR h,UCHAR w)
{
	UCHAR bwid=(UCHAR)((w+7)/8),*tmp,i;
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
			magnify(f,tmp);
			w*=(UCHAR)(2);
			bwid*=(UCHAR)(2);
			for (i=1;i<3;i++) {
				G_curgd->f.f[i].pwid=w;
				G_curgd->f.f[i].phgt=h;
				G_curgd->f.f[i].bwid=bwid;
				G_curgd->f.f[i].size=(UCHAR)(i+1);
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
				G_curgd->f.f[i].size=(UCHAR)(i+1);
				G_curgd->f.f[i].ftab=f;
			}
			G_curgd->cf=&(G_curgd->f.f[0]);
			RETURNV(1);
		case 201 :
			_fmemcpy(&hw,f,2);
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
		case 202 :
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
//*****************************************************
//F getrgbpalette
//S Get the rgb palette for register c using INT 10h
//P register
//P Pointer for returned red value (0-63)
//P Pointer for returned green value (0-63)
//P Pointer for returned blue value (0-63)
void getrgbpalette(INT c,UCHAR *r,UCHAR *g,UCHAR *b)
{
    UCHAR rr,gg,bb;
	ENTRY(3644);
//    if (c>7) c+=0x30;
    _EAX=0;
    _AX=0x1015;
    _EBX=0;
    _BX=(INT16)c;
    geninterrupt(0x10);
    rr=_DH;
    gg=_CH;
    bb=_CL;
    *r=rr;
    *g=gg;
    *b=bb;
	RETURN;
}
//*****************************************************
//F setrgbpalette
//S Set the rgb palette for register c using INT 10h
//P register
//P red value (0-63)
//P green value (0-63)
//P blue value (0-63)
void setrgbpalette(INT c,UCHAR red,UCHAR green,UCHAR blue)
{
	ENTRY(3645);
//    if (c>7) c+=0x30;
    _EAX=0;
    _AX=0x1010;                 // Set individual DAC register
    _EBX=0;
    _BX=(INT16)c;               // register
    _EDX=0;
    _DH=red;
    _ECX=0;
    _CH=green;
    _CL=blue;
    geninterrupt(0x10);         // Video interrupt
	RETURN;
}
//*****************************************************
//F setpalette
//S Set the colour value for palette c using INT 10h
//P palette register
//P colour value
void setpalette(UCHAR c,UCHAR attr)
{
	ENTRY(3650);
    _EAX=0;
    _AX=0x1000;
    _EBX=0;
    _BL=c;
    _BH=attr;
    geninterrupt(0x10);
	RETURN;
}
//*****************************************************
//F setborder
//S Set the border colour register using INT 10h
//P colour value to store
void setborder(UCHAR attr)
{
	ENTRY(3660);
    attr=(UCHAR)((attr==6)?0x14:((attr<8)?attr:0x30+attr));
    _EAX=0;
    _AX=0x1001;
    _EBX=0;
    _BL=0;
    _BH=attr;
    geninterrupt(0x10);
	RETURN;
}
//*****************************************************
//F outln
//S Output a line
//P colour value to store
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
		mask=(UCHAR)(0xFF<<(8-((w+x)&7)));
		scr=(UCHAR *)(COLVIDMEM+(INT)((LONG)y*80L)+(INT)(x>>3));
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
			*eol&=(CHAR)(mask^0xFF);
			*eol|=*(buf++)&mask;
		}
	}
//	sendmsg("INPUT1",MESSAGE_i);
	RETURN;
}

//*****************************************************
//F mov4b
//S Move bits back from the four bitplanes to save
//D NOT CURRENTLY USED
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
//*****************************************************
//F mov4
//S Move bits into the four bitplanes for display.
//P
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
//*****************************************************
//F setcols
//S
//P
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
//*****************************************************
//F reorg
//S Reorder 
//P Destination buffer
//P Source buffer
//P Width in bytes
void reorg(UCHAR *d,UCHAR *s,INT w)
{
	INT i,j;
	UCHAR buf[4];
	ENTRY(3700);

     // don't change colour map if bmp palette used
	if (G_changecols) setcols(s,w,0);
	w/=4;
	for (i=0;i<w;i++) {
		mov4(buf,&s[i*4]);
		for (j=0;j<4;j++) d[i+j*w]=buf[j];
	}
	RETURN;
}
//*****************************************************
//F intsize
//S
//P
INT intsize(INT a)
{
	ENTRY(3710);
	if (a&1) RETURNV(a+1);
	RETURNV(a);
}
//*****************************************************
//F getbmpsiz
//S
//P
LONG getbmpsiz(CHAR *name)
{
	INT fd;
	BMPH bmph;
	LONG l;
	ENTRY(3720);
    fd=open(name,O_RDONLY|O_BINARY);
	if (fd==(-1)) RETURNV(0L);
	read(fd,&bmph,sizeof(BMPH));
	close(fd);
	l = ((bmph.bmih.biWidth+7)/8)*8;
	l<<=16;
	l |= bmph.bmih.biHeight;
	RETURNV(l);
}
//*****************************************************
//F savebmp
//S
//P
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
			OUTPW(0x3C4,(0x100<<j)|2);
			OUTPW(0x3CE,(j<<8)|4);
			_fmemcpy(G_lnbuf+j*256,(UCHAR *)(COLVIDMEM+(i*80)),80);
		}
		for (j=0;j<80;j++) mov4b(G_lnbuf+1024+j*4,G_lnbuf+j);
		setcols(G_lnbuf+1024,320,16);
		fwrite(G_lnbuf+1024,320,1,fp);
	}
	fclose(fp);
	RETURNV(1);
}
//*****************************************************
//F getbmp
//S
//P
IMAGE *getbmp(CHAR *name)
{
	FILE *fp;
	INT i,j,w,k;
	ULONG ofs;
	BMPH bmph;
	IMAGE *im;
	UCHAR *buf;
	UCHAR rb[360];
	ENTRY(3730);
		
    for (i=0;i<NUMIMINLIST;i++) {
        if (G_lastloadbmps[i].name!=NULL) {
            if (!strcmp(G_lastloadbmps[i].name,name)) { // if bitmap already loaded
                 return(G_lastloadbmps[i].image);        // return it
            }
        }
    }
    
	setlnbuf(16);
	buf=G_lnbuf;

	if ((fp=fopen(name,"rb"))==NULL) RETURNV(NULL);
	fread(&bmph,sizeof(BMPH),1,fp);
	w=(((INT)(bmph.bmih.biWidth)+7)/8)*4;
	if (w==0) {
		fclose(fp);
		RETURNV(NULL);
	}
	ofs=bmph.bmih.biHeight;
	ofs*=(LONG)intsize(w);
	im=MALLOC(sizeof(IMAGE));
	if (im==NULL) RETURNV(NULL);
	fseek(fp,bmph.bmfh.bfOffBits,SEEK_SET);
    im->buf=farmalloc(ofs);
	if (im->buf==NULL) {
        RETURNV(NULL);
    }
    if (bmph.bmih.biWidth==640) {
		for (i=(INT)(bmph.bmih.biHeight)-1;i>=0;i--) {
			fread(rb,w,1,fp);
			reorg(buf,rb,w);
			for (j=0;j<4;j++) {
				ofs=(LONG)j;
				ofs*=(bmph.bmih.biHeight)*80L;
				ofs+=((LONG)i)*80L;
                for (k=0;k<80;k++) (im->buf+ofs)[k]=(buf+j*80)[k];
			}
		}
	} else {
		for (i=0;i<bmph.bmih.biHeight;i++) {
			ofs-=(LONG)intsize(w);
			fread(rb,w,1,fp);
			reorg(buf,rb,w);
            for (k=0;k<w;k++) *(im->buf+ofs+k)=*(buf+k);
//       		_fmemcpy(im->buf+ofs,buf,w);
		}
	}
	fclose(fp);
	strcpy(im->name,name);
	im->w=(INT)(bmph.bmih.biWidth);
	im->h=(INT)(bmph.bmih.biHeight);
	im->sz=(INT)(bmph.bmih.biHeight);
	im->ofs=0L;
	im->ln=0;
	im->bw=intsize((INT)(((bmph.bmih.biWidth+7)/8)*4));
	im->type=0;
    addimage2list(im,name);
	RETURNV(im);
}
//*****************************************************
//F outhln
//S
//P
void outhln(INT x,INT y,INT w,UCHAR *ln)
{
	UCHAR *scr=(UCHAR *)MONOVIDMEM+(x>>3)+((y&3)<<13)+((y>>2)*90);
	ENTRY(3740);
	w/=8;
	memcpy(scr,ln,w);
	RETURN;
}
//*****************************************************
//F animate
//S
//P
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
					j=(INT)sendmsg("INPUT3",MESSAGE_MI,im->x,im->y,im->x+im->w,im->y+im->sz);
					if (j) sendmsg("INPUT3",MESSAGE_C,0);
#endif
					animimage(im->x,im->y,im->sz,im->del,im);
#ifndef NON_GPA
					if (j) sendmsg("INPUT3",MESSAGE_C,-1);
#endif
					break;
				case 2 :
#ifndef NON_GPA
					j=(INT)sendmsg("INPUT3",MESSAGE_MI,im->x,im->y,im->x+im->w,im->y+im->sz);
					if (j) sendmsg("INPUT3",MESSAGE_C,0);
#endif
					rotimage(im->x,im->y,im->sz,im->st,im->del,im);
#ifndef NON_GPA
					if (j) sendmsg("INPUT3",MESSAGE_C,-1);
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
//*****************************************************
//F delfromanim
//S
//P
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
//*****************************************************
//F addtoanim
//S
//P
void addtoanim(IMAGE *img)
{
	ENTRY(3760);
	if (G_animtick==0) {
#ifndef NON_GPA
		sendmsg("INPUT1",MESSAGE_A,1,animate);
#endif
	}
	if (G_animtick<10) {
		G_images[G_animtick++]=img;
	}
	RETURN;
}
//*****************************************************
//F flipimages
//S
//P
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
//*****************************************************
//F animimage
//S
//P
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
		img->ofs=0L;
		img->x=x;
		img->y=y;
		addtoanim(img);
	} 
	tl=img->ofs;
	BITMASK(255); ESETRES(0); MAPMASK(15);
	for (i=0;i<size;i++) {
    	_fmemcpy(buf,img->buf+tl,img->bw);
		outln(x,y++,img->w,buf,i==0);
		tl+=img->bw;
	}
	BITMASK(255); ESETRES(0); MAPMASK(15);
	img->ln+=size;
	if (img->ln>=img->h) {
		tl=0L;
		img->ln=0;
	}
	img->ofs=tl;
	RETURN;
}
//*****************************************************
//F rotimage
//S
//P
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
		img->ofs=0L;
		img->x=x;
		img->y=y;
		addtoanim(img);
	} 
	tl=img->ofs;
	j=img->ln;
	BITMASK(255); ESETRES(0); MAPMASK(15);
	for (i=0;i<size;i++) {
    	_fmemcpy(buf,img->buf+tl,img->bw);
		outln(x,y++,img->w,buf,i==0);
		if (((j+i)>=size)&&((j+i)<(img->h+size)-1)) tl+=img->bw;
	}
	BITMASK(255); ESETRES(0); MAPMASK(15);
	img->ln+=step;
	if (img->ln>size) {
		img->ofs=((LONG)(img->ln-size)*(LONG)img->bw);
	}
	if (img->ln>=(img->h+size)) {
		img->ln=0;
		img->ofs=0L;
	}
	RETURN;
}
//*****************************************************
//F putimage
//S
//P
void putimage(INT x,INT y,IMAGE *img)
{
	UINT i,j;
	LONG tl;
	UCHAR *buf=G_lnbuf;
    LONG huge *t;
    LONG huge *scr;
	ENTRY(3790);
	if (img==NULL) RETURN;
	switch (G_curgd->type) {
		case 1 :
			tl=0L;
			for (i=0;i<img->h;i++) {
            	_fmemcpy(buf,img->buf+tl,img->bw);
				outhln(x,y+i,img->w,buf);
				tl+=img->bw;
			}
			break;

		default :
			tl=0L;
			BITMASK(255); ESETRES(0); MAPMASK(15);
			if (img->w==640) {
                t=(LONG huge *)(img->buf);
				for (i=0;i<4;i++) {
					WRITEPLANE(i);
                    scr=(LONG huge *)COLVIDMEM;
                    for (j=0;j<9600U;j++) *(scr++)=*(t++);
				}
			} else {
                t=(LONG huge *)(img->buf);
				for (i=0;i<img->h;i++) {
                    scr=(LONG huge *)buf;
                    for (j=0;j<img->bw;j+=4) *(scr++)=*(t++);
					outln(x,y++,img->w,buf,i==0);
				}
			}
			BITMASK(255); ESETRES(0); MAPMASK(15);
	}
	RETURN;
}
//*****************************************************
//F freeimg
//S
//P
void freeimg(IMAGE *img)
{
    INT i;
	ENTRY(3800);
    for (i=0;i<NUMIMINLIST;i++) {
        if (G_lastloadbmps[i].name!=NULL) {
            if (!strcmp(G_lastloadbmps[i].name,img->name)) { // if bitmap already loaded
                G_lastloadbmps[i].image=NULL;
                FREE(G_lastloadbmps[i].name);
                G_lastloadbmps[i].name=NULL;
                G_lastloadbmps[i].age=0;
            }
        }
    }
	if (img==NULL) RETURN;
	if (img->buf!=NULL) farfree(img->buf);
    img->buf=NULL;
	FREE(img);
    img=NULL;
	RETURN;
}

//*****************************************************
//F loadffont
//S load fixed font
//P
UCHAR huge *loadffont(CHAR *fontfile)
{
	CHAR huge *tmp;
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
	if ((tmp=farmalloc(256*wid))==NULL) RETURNV(NULL);
	if ((fd=open(fontfile,O_RDONLY|O_BINARY))==(-1)) RETURNV(NULL);
	read(fd,G_testbuf,32);
	if (G_testbuf[31]=='R') G_righthand=1;
	lseek(fd,ofs,SEEK_SET);
	read(fd,tmp,256*wid);
	close(fd);
	RETURNV((UCHAR huge *)tmp);
}
//*****************************************************
//F loadlfont
//S Load large font ????
//P
UCHAR huge *loadlfont(CHAR *name,INT type)
{
	INT fd,i,j;
	LONG ofs;
	FMAP1 bfont;
	FMAP *fonts;
	UINT fhw;
	UCHAR fwid,fhgt,fbw;
    UCHAR huge *font;
    UCHAR huge *tfon;
	UCHAR *ch,tmp;
	ENTRY(3820);
	
	if ((fd=open(name,O_RDONLY|O_BINARY))==(-1)) RETURN(NULL);
	if (type==1) {
		lseek(fd,0x3E,SEEK_SET);
		read(fd,&fwid,1); read(fd,&fhgt,1); fbw=fwid/8;
		fhw=(fwid<<8)|fhgt;
		lseek(fd,SOMAP,SEEK_SET);
		read(fd,&bfont,sizeof(FMAP1));
		fonts=MALLOC(bfont.len*sizeof(FMAP));
		if (fonts==NULL) { close(fd); RETURN(NULL); }
		read(fd,fonts,bfont.len*sizeof(FMAP));
		ofs=2L+(LONG)sizeof(FMAP1)+(LONG)(bfont.len*sizeof(FMAP));
		ofs+=(LONG)(bfont.b.len*((fbw-1)*fhgt));
		for (i=0;i<bfont.len;i++) ofs+=(LONG)(fonts[i].len*fbw*fhgt);
		ch=MALLOC(bfont.b.len*((fbw-1)*fhgt));
		if (ch==NULL) { close(fd); RETURN(NULL); }
        font=farmalloc(ofs);
		lseek(fd,bfont.b.ofs,SEEK_SET);
		for (j=0;j<bfont.b.len;j++) {
			read(fd,&tmp,1);
			read(fd,ch+j*((fbw-1)*fhgt),((fbw-1)*fhgt));
		}
		ofs=2L+sizeof(FMAP1)+(bfont.len*sizeof(FMAP));
		bfont.b.ofs=ofs;
        _fmemcpy(font,&fhw,2);
        _fmemcpy(font+2,&bfont,sizeof(FMAP1));
        _fmemcpy(font+ofs,ch,(bfont.b.len*((fbw-1)*fhgt)));
		ofs+=(bfont.b.len*((fbw-1)*fhgt));
		for (i=0;i<bfont.len;i++) {
			if (fonts[i].len) {
 				ch=MALLOC(fonts[i].len*fbw*fhgt);
				lseek(fd,fonts[i].ofs,SEEK_SET);
				for (j=0;j<fonts[i].len;j++) {
					read(fd,&tmp,1);
					read(fd,ch+j*fbw*fhgt,fbw*fhgt);
				}
				fonts[i].ofs=ofs;
                _fmemcpy(font+ofs,ch,fonts[i].len*fbw*fhgt);
				ofs+=fonts[i].len*fbw*fhgt;
				FREE(ch);
			}
		}
        _fmemcpy(font+2+sizeof(FMAP1),fonts,(bfont.len*sizeof(FMAP)));
		FREE(fonts);
        close(fd);
        RETURNV(font);
	} else {
		ch=MALLOC(15000);
		if (ch==NULL) { close(fd); RETURN(NULL); }
        font=farmalloc(942768L);
        tfon=font;
		for (j=0;j<62;j++) {
			read(fd,ch,15000);
            for (i=0;i<15000;i++) *(tfon++)=*(ch+i);
		}
		read(fd,ch,144*7);
        for (i=0;i<12768;i++) *(tfon++)=*(ch+i);
		FREE(ch);
        close(fd);
        RETURNV(font);
	}
//    close(fd);
//	RETURN(NULL);
}

//*****************************************************
//F button
//S draw a button with text on top if text starts ~P call bmpbutt
//P co-ord in characters
//P co-ord in characters
//P co-ord in characters
//P co-ord in characters
//P thickness of the edges
//P 1 for up 0 for down
//P pointer to text
//P true if text dilimited with '^' should be put on different lines
void button(INT x,INT y,INT x1,INT y1,INT t,INT up,CHAR *c,INT split)
{
	IMAGE *im;
	INT i,w,h,sw,sh;
	INT xo,yo;
	CHAR tmp[80],*s;
	CHAR tst[2];
	ENTRY(3830);
	if (G_curgd->type!=0) RETURN;
    if ((c[0]=='~')&&(c[1]=='P')) {
        im=getbmp(&c[2]);
        if (im!=NULL) bmpbutt(x,y,im,t,up);
        RETURN;
    }
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
	sw/=2;
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
//*****************************************************
//F bmpbutt
//S draw a button with a bitmap ontop
//P co-ord in characters
//P co-ord in characters
//P pointer to image structure
//P thickness of the edges
//P 1 for up 0 for down
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
//*****************************************************
//F bezel
//S
//P
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
//*****************************************************
//F tinyxy
//S
//P
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
	setcol((UCHAR)c);
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
	G_curgd->col=(CHAR)col;
	RETURN;
}

//*****************************************************
//F lastcol
//S return the last column from the save screen data
int lastcol(int row)
{
    int x;
    row*=80;
    for (x=79;x>=0;x--) {
        if (G_scrc[row+x]) return(x+1);
    }
    return(0);
}
//*****************************************************
//F exists
//S Return TRUE if file exists
//P File name
//R TRUE/FALSE
int exists(char *file)
{
    FILE *fp;
    fp=fopen(file,"r");
    if (fp==NULL) return(0);
    fclose(fp);
    return(1);
}
//*****************************************************
//F pcxfile
//S generate a pcx filename form the formname
//P form name
//R file name
CHAR *pcxfile(CHAR *name)
{
    static char tmp[15];
    int index=0,i;
    sprintf(tmp,"%-8s.PCX",name);
    for (i=0;i<8;i++) if (tmp[i]==' ') tmp[i]='_';
    do {
        if (index<10) {
            tmp[7]='0'+index;
        } else {
            tmp[6]='0'+index/10;
            tmp[7]='0'+index%10;
        }
        index++;
    } while (exists(tmp)&&(index<100));
    return(tmp);
}
//*****************************************************
//F getpix
//S get 8 pixels amalgamated from all four planes
//P Screen pointer
//R value of pixel
UCHAR getpix(UCHAR *scr)
{
    UCHAR ret=0;
    OUTPW(0x3CE,0x0004); ret=*scr;  // select 1st plane and read byte
    OUTPW(0x3CE,0x0104); ret|=*scr; // select 2nd plane and read byte
    OUTPW(0x3CE,0x0204); ret|=*scr; // select 3rd plane and read byte
    OUTPW(0x3CE,0x0304); ret|=*scr; // select 4th plane and read byte
	return(ret^0xFF);               // invert and return
}
//*****************************************************
void dumppcx(char *name)
{
    INT   k,l,i;
    FILE *fp;
	UCHAR *scr=(UCHAR *)(COLVIDMEM);
    UCHAR next,current,count;
    unlink(name);                                   // delete file if it exists
    if ((fp=fopen(name,"wb"))!=NULL) {              // open new file
    	fwrite(pcx_header,sizeof(pcx_header),1,fp); // write the header
        for (k=0;k<480;k++) {                       // for every line
            count=0;                                // run-length encode
            current=getpix(scr);                    // setup data
	        for (l=0;l<80;l++) {                    // for every byte accross
                next=getpix(scr);                   // get next byte
        		WRITEPLANE(0); READPLANE(0);        // select plane 0
                *(scr++)^=0xFF;                     // show on screen flag
	            if ((next==current)&&(count<63)) {  // if same amalgamate
    			    count++;
                } else {
			        count|=0xc0;                    // mark count flag
			        fwrite(&count,1,1,fp);          // write count
			        fwrite(&current,1,1,fp);        // write data
			        current=next;                   // select next byte
			        count=1;                        // reset count
	            }
            }
			count|=0xc0;                            // finished the line
            fwrite(&count,1,1,fp);                  // output the remaining count
            fwrite(&current,1,1,fp);                // output data
       		WRITEPLANE(0); READPLANE(0);            // select plane 0
            for (i=1;i<81;i++) *(scr-i)^=0xFF;      // hide on screen flag
        }
    }
    fclose(fp);                                     // close
}
//*****************************************************
//F scrprint
//S print a textual representation of the screen data for PRINT-SCREEN
void scrprint(INT type,CHAR *name)
{
	UINT x,y,lc,outdat;
	ENTRY(3865);

    if (type==1) {
        sendmsg("OUTPUT2",MESSAGE_MS,0,0);      // disable micro spacing
        sendmsg("OUTPUT2",MESSAGE_S,1);
        sendmsg("OUTPUT2",MESSAGE_A,0);
	    for (y=0;y<25;y++) {
            lc=lastcol(y);
		    for (x=0;x<lc;x++) {
			    outdat=G_scrc[y*80+x];
			    if ((outdat)&&((outdat>>8)!=0)) {
                    sendmsg("OUTPUT2",MESSAGE_o,x,y,"%c",(CHAR)((outdat>>8)&0xFF));
			    } else {
                    sendmsg("OUTPUT2",MESSAGE_o,x,y," ");
			    }
		    }
	    }
        sendmsg("OUTPUT2",MESSAGE_F);
	    sendmsg("OUTPUT2",MESSAGE_SP,0,1);
    } else if (type==2) {
        dumppcx(pcxfile(name));
    }
	RETURN;
}
void savescrn(INT swapcols)
{
    UCHAR palbuf[48];
    UCHAR *pal=palbuf;
    int  x;
	setcol(7);
    for (x=0;x<16;x++) {
        getrgbpalette(((x==6)?0x14:((x<8)?x:0x30+x)),pal+x*3,pal+x*3+1,pal+x*3+2);
    }
    if ((x=open("SCRNSAVE.EXE",O_RDONLY))!=(-1)) {
        close(x);
        system("SCRNSAVE");
        sendmsg("INPUT1",MESSAGE_CLRINACT);
    } else {
        for (x=0;x<16;x++) {
            setrgbpalette(((x==6)?0x14:((x<8)?x:0x30+x)),0,0,0);
        }
        while (sendmsg("INPUT1",MESSAGE_GETINCAT)>=G_savescrnto);
    }
    for (x=0;x<16;x++) {
        setrgbpalette(((x==6)?0x14:((x<8)?x:0x30+x)),*(pal+x*3)&0xFF,*(pal+x*3+1)&0xFF,*(pal+x*3+2)&0xFF);
    }
    if (swapcols) {
        setpalette(2,0);
        setpalette(7,2);
        setpalette(0,7);
        setborder(7);
    } else {
        setborder(0);
    }
    if (G_ctempformtype!=0) G_form.type=G_ctempformtype;
    sendmsg("OUTPUT1",MESSAGE_RS);
    if (G_ctempformtype!=0) G_form.type=0;
}
CHAR **saveregion(INT bx,INT y,INT bw,INT h)
{
    CHAR **tmp,*s,*b;
    INT i,j;

    tmp=MALLOC(4*sizeof(CHAR *));
    if (tmp==NULL) return(tmp);

    for (i=0;i<4;i++) {
        tmp[i]=MALLOC(bw*h);
        if (tmp[i]==NULL) return(NULL);
    }
    for (i=0;i<4;i++) {
        b=tmp[i];
        s=COLVIDMEM+bx+y*80;
        READPLANE(i);
        for (j=0;j<h;j++) {
            memcpy(b,s,bw);
            s+=80;
            b+=bw;
        }
    }
    return(tmp);
}
void restregion(INT bx,INT y,INT bw,INT h,CHAR **buf)
{
    CHAR *s,*b;
    INT i,j;
    if (buf==NULL) return;
    for (i=0;i<4;i++) {
        b=buf[i];
        s=COLVIDMEM+bx+y*80;
        WRITEPLANE(i);
        for (j=0;j<h;j++) {
            memcpy(s,b,bw);
            s+=80;
            b+=bw;
        }
        FREE(buf[i]);
        buf[i]=NULL;
    }
    FREE(buf);
    buf=NULL;
}
//*****************************************************
// End of file - GPRIM.C
