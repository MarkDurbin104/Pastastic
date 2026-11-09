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
#include "types.h"
#include "tintext.h"
//#include "gprim.h"

#define COLVIDMEM       ((UCHAR *)(0xA0000000L)) // Base address of screen
#define COLVIDSEG       (0xA000)                 // segment of ----"----
#define I               asm                      // define for inline assembler
#define XOFFSET         10                       // X offset of top left box
#define YOFFSET         0                        // Y offset of top left box
#define NUMBOXACROSS    4                        // number of boxes across the screen
#define SPACING         5                        // space between boxes
#define BOXWIDTH        155                      // width of box
#define BOXHEIGHT       75                       // height of box

typedef struct {                                 // BMP header
	UINT  name;
	ULONG sizi;
	UINT  res[2];
	ULONG ofs;
	ULONG sizx;
    LONG  wid;
    LONG  hgt;
	UINT  nump;
	UINT  bcnt;
	ULONG cflg;
	ULONG size;
    LONG  hres;
    LONG  vres;
	ULONG cusd;
	ULONG cimp;
} BMPH;

CHAR  G_colour=15;          // current draw colour (default 15=White in default palette)
UINT  G_curpixelx;          // current draw x point
UINT  G_curpixely;          // current draw y point
UCHAR G_palentry[48]= {     //   GPA Default Colour Palette
    0x2D,0x2D,0x2D, // 7    // Note 7 at pos 0 ---+   These are due to GPA's 
    0x00,0x00,0x2A, // 1    //                    |   Original use of Green
    0x00,0x00,0x00, // 0    // Note 0 at pos 2 ---+---Screen to emulate the
    0x00,0x2A,0x2A, // 3    //                    |   Hercules monitor
    0x2A,0x00,0x00, // 4    //                    |   i.e. Black background  
    0x2A,0x00,0x2A, // 5    //                    |   with green chars. Has 
    0x2A,0x23,0x00, // 6    //                    |   become Black chars on 
    0x00,0x2F,0x00, // 2    // Note 2 at pos 7 ---+   grey background
    0x10,0x10,0x10, // 8
    0x15,0x1A,0x3F, // 9
    0x15,0x3F,0x15, // 10
    0x15,0x3F,0x3F, // 11
    0x3F,0x15,0x15, // 12
    0x3F,0x0E,0x3F, // 13
    0x3F,0x3F,0x15, // 14
    0x3F,0x3F,0x3F  // 15
};
// Show the default GPA colours first followed by the unused colours in order
INT G_colmap[16]={0,2,8,15,1,3,4,5,6,7,9,10,11,12,13,14};

//*****************************************************
//F vidint
//S Generate an INT 10h Video interrupt
//P AX value to use
void vidint(INT16 rax)
{
    _EAX=0;
    _AX=rax;
    geninterrupt(0x10);
	return;
}
//*****************************************************
//F closegraf
//S close down graphics and return to text mode
void closegraf(void)
{
	vidint(0x0003); // Text mode
}
//*****************************************************
//F grafix
//S Set screen to mode 12h
void grafix(void)
{
    vidint(0x0012); // graphics mode
}
//*****************************************************
//F cls
//S Clear screen
void cls(void)
{
	outpw(0x3C4,(G_colour<<8)+2); // 0x0F02 = all planes
	outpw(0x3CE,0xFF08);
	outpw(0x3CE,0x0001);
	outpw(0x3CE,0x0003);
	memset(COLVIDMEM,0xFF,38400U);
}
//*****************************************************
//F horizln
//S draw a horizontal line
//P start x pos
//P end x pos
//P y pos
void horizln(INT x1,INT x2,INT y)
{
	UCHAR *t,*s;
	UCHAR m1=0xFF,m2=0xFF;
	INT w,i;
	m1>>=(UCHAR)(x1&7); m2>>=(UCHAR)((x2&7)+1); m2=(CHAR)(m2^0xFF);
	w=(x2>>3)-(x1>>3);
	s=COLVIDMEM+(y*80)+(x1>>3);
    for (i=0;i<4;i++) {
	    t=s;
        outportb(0x3CE,4);
        outportb(0x3CF,(CHAR)i);
        outportb(0x3C4,2);
	    outportb(0x3C5,(CHAR)(1<<i));
	    if (((1<<i)&G_colour)!=0) {
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
//*****************************************************
//F yline
//S draw a line in the y direction
//P start x pos
//P start y pos
//P number of pixels before change in x pos
//P number of pixels before change in y pos
//P number of steps
void yline(INT x,INT y,INT deltax,INT deltay,INT o)
{
	INT i2;
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
}
//*****************************************************
//F xline
//S draw a line in the x direction
//P start x pos
//P start y pos
//P number of pixels before change in x pos
//P number of pixels before change in y pos
//P number of steps
void xline(INT x,INT y,INT deltax,INT deltay,INT o) 
{
	INT i2;
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
}
//*****************************************************
//F moveto
//S Set the current x,y pixel location
//P Absolute x location
//P Absolute y location
void moveto(INT x,INT y)
{
	G_curpixelx=x;
	G_curpixely=y;
}
//*****************************************************
//F lineto
//S draw a line from the current x,y pos to this x,y pos
//P Absolute x location
//P Absolute y location
void lineto(INT x,INT y)
{
	INT s,e;
	INT dx,dy,inc;
	dx=abs(x-G_curpixelx); dy=abs(y-G_curpixely);
	if (!dy) {
		if (x<G_curpixelx) { e=G_curpixelx; s=x; } else { e=x; s=G_curpixelx;}
		horizln(s,e,y);
	} else {
		outpw(0x3C4,0x0F02);
		outpw(0x3CE,0xFF08);
		outpw(0x3CE,0x0F01);
		outpw(0x3CE,(UINT16)(G_colour<<8));
		if (dx>dy) {
			if (G_curpixelx>x) {
				if (y>G_curpixely) inc=(-80); else inc=80;
				xline(x,y,dx,dy,inc);
			} else {
				if (y>G_curpixely) inc=80; else inc=(-80);
				xline(G_curpixelx,G_curpixely,dx,dy,inc);
			}
		} else {
			if (G_curpixely>y) {
				if (x>G_curpixelx) {
					inc=(-80);
					yline(G_curpixelx,G_curpixely,dx,dy,inc);
				} else {
					inc=80;
					yline(x,y,dx,dy,inc);
				}
			} else {
				if (x>G_curpixelx) {
					inc=80;
					yline(G_curpixelx,G_curpixely,dx,dy,inc);
				} else {
					inc=(-80);
					yline(x,y,dx,dy,inc);
				}
			}
		}
		outpw(0x3C4,0x0F02);
		outpw(0x3CE,0xFF08);
		outpw(0x3CE,0x0001);
	}
	moveto(x,y);
}
//*****************************************************
//F setcol
//S Set the default colour for the current screen
//P Colour - Range 0 to 15 - Value in top nibble for inverted text, bottom nibble normal text
void setcol(UCHAR col)
{
	if ((col&0xF0)!=0) {
		col>>=4;
	}
	col&=15;
	if (G_colour!=col) {
		G_colour=col;
	}
}
//*****************************************************
//F setborder
//S Set the border colour register using INT 10h
//P colour value to store
void setborder(UCHAR attr)
{
    attr=((attr==6)?0x14:((attr<8)?attr:0x30+attr));
    _EAX=0;
    _AX=0x1001;
    _EBX=0;
    _BL=0;
    _BH=(UCHAR)attr;
    geninterrupt(0x10);
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
    c=((c==6)?0x14:((c<8)?c:0x30+c));
    _EAX=0;
    _AX=0x1010;                 // Set individual DAC register
    _EBX=0;
    _BX=(INT16)c; // register
    _EDX=0;
    _DH=red;
    _ECX=0;
    _CH=green;
    _CL=blue;
    geninterrupt(0x10);         // Video interrupt
}
//*****************************************************
//F setallrgbpal
//S Set all the rgb palette registers
//P palette array r,g,b *16
void setallrgbpal(UCHAR *pal)
{
    INT j;
    for (j=0;j<16;j++) {
        setrgbpalette(j,*(pal+j*3),*(pal+j*3+1),*(pal+j*3+2));
    }
}
//*****************************************************
//F setmonopalette
//S Set all the rgb palette registers to mono values
//P palette array intensity@16
//P border colour
void setmonopalette(INT *pal,INT bc)
{
    int j;
    for (j=0;j<16;j++) {
        setrgbpalette(j,*(pal+j),*(pal+j),*(pal+j));
    }
    setborder(bc);
}
//*****************************************************
//F tinyxy
//S print tiny vector mapped text at x,y pos
//P x co-ord
//P y co-ord
//P format string as printf
//P variable args as printf
void tinyxy(INT x,INT y,CHAR *fmt,...)
{
	INT xp,yp,i,mx;
	UCHAR *t,tmp[160],*s;
	va_list ap;
	va_start(ap,fmt);
	vsprintf((CHAR *)tmp,fmt,ap);
	va_end(ap);
	s=tmp;
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
}
//*****************************************************
//F rectangle
//S Draw a rectangle
//P Top Left X pos
//P Top Left Y pos
//P Bottom Right X pos
//P Bottom Right Y pos
void rectangle(INT x1,INT y1,INT x2,INT y2)
{
	moveto(x1,y1);
	lineto(x2,y1);
	lineto(x2,y2);
	lineto(x1,y2);
	lineto(x1,y1);
}
//*****************************************************
//F bar
//S Draw a filled rectangle
//P Top Left X pos
//P Top Left Y pos
//P Bottom Right X pos
//P Bottom Right Y pos
void bar(INT x1,INT y1,INT x2,INT y2)
{
    INT i;
    for (i=y1;i<=y2;i++) {
        horizln(x1,x2,i);
    }
}
int main(int argc,char *argv[])
{
    FILE *fp;
    UCHAR tmpcolour;
    INT j,k;
    INT monoval[16],avemono,avecolnum;
    INT maxmono=0  ,maxcolnum=15;
    INT minmono=255,mincolnum=0;
    INT defcolours=1;
    if (argc>=2) {
        defcolours=0;
        if ((fp=fopen(argv[1],"rb"))!=NULL) {
            fseek(fp,sizeof(BMPH),SEEK_SET); // skip header
            for (j=0;j<16;j++) { // 16 lots of 4 (b,g,r,empty)
                fread(&(G_palentry[j*3]),1,3,fp); // read bgr
                fread(&tmpcolour,1,1,fp); // skip empty
                tmpcolour=G_palentry[j*3];   
                G_palentry[j*3]=G_palentry[j*3+2];
                G_palentry[j*3+2]=tmpcolour;
            }
            fclose(fp);
            for (j=0;j<48;j++) G_palentry[j]>>=2; // make 0-63 not 0-255
        } else {
            sound(1000);
            delay(100);
            nosound();
        }
    }
    for (j=0;j<16;j++) { // get relative grey intensities;
        monoval[j]=((G_palentry[j*3]*30)+(G_palentry[j*3+1]*59)+(G_palentry[j*3+2]*11))/100;
        if (maxmono<=monoval[j]) {
            maxcolnum=j;
            maxmono=monoval[j];
        }
        if (minmono>=monoval[j]) {
            mincolnum=j;
            minmono=monoval[j];
        }
    }
    avemono=(maxmono+minmono)/2;
    for (j=avemono;j<maxmono;j++) { // find nearest above average
        for (k=0;k<16;k++) {
            if (monoval[k]==j) {
                avecolnum=k;
                break;
            }
        }
        if (k<16) break;
    }
    grafix();
    setallrgbpal(G_palentry);
    setborder(avecolnum);
    setcol(avecolnum);
    cls();
    for (k=0;k<16;k++) { // draw boxes
        j=G_colmap[k];
        setcol(j);
        bar((XOFFSET+1)+(k/NUMBOXACROSS)*BOXWIDTH,
            (YOFFSET)+(k%NUMBOXACROSS)*BOXHEIGHT,
            (XOFFSET+BOXWIDTH-(SPACING+1))+(k/NUMBOXACROSS)*BOXWIDTH,
            (YOFFSET)+(k%NUMBOXACROSS)*BOXHEIGHT+(BOXHEIGHT-SPACING-1));
        if (monoval[j]<avemono) setcol(maxcolnum); else setcol(mincolnum);
        rectangle((XOFFSET                  )+(k/NUMBOXACROSS)*BOXWIDTH  ,
                  (YOFFSET                  )+(k%NUMBOXACROSS)*BOXHEIGHT ,
                  (XOFFSET+BOXWIDTH -SPACING)+(k/NUMBOXACROSS)*BOXWIDTH  ,
                  (YOFFSET+BOXHEIGHT-SPACING)+(k%NUMBOXACROSS)*BOXHEIGHT );
        tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
               10+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
               "Palette Colour %d VGA %02X",j,((j==6)?0x14:((j<8)?j:0x30+j)));
        tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
               25+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
               "Intensity %d",monoval[j]);
        tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
               40+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
               "R(%02d) G(%02d) B(%02d)",G_palentry[j*3],G_palentry[j*3+1],G_palentry[j*3+2]);
        if (j==0) {
            tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
                   55+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
                   "GPA Background Colour");
        } else if (j==2) {
            tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
                   55+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
                   "GPA Foreground Colour");
        } else if (j==8) {
            tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
                   55+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
                   "GPA Dark Line Colour");
        } else if (j==15) {
            tinyxy(10+XOFFSET+(k/NUMBOXACROSS)*BOXWIDTH,
                   55+YOFFSET+(k%NUMBOXACROSS)*BOXHEIGHT,
                   "GPA Light Line Colour");
        }
    }
    if (monoval[0]<avemono) setcol(maxcolnum); else setcol(mincolnum);
    rectangle(0,310,230,479);
    setcol(0);
    bar(1,311,229,478);
    setcol(2);
    tinyxy(10,320,"GPA TEXT COLOR 1");
    bar(9,329,105,339);
    setcol(0);
    tinyxy(10,330,"GPA TEXT COLOR 2");
    setcol(14);
    tinyxy(10,340,"GPA TEXT COLOR 3");
    setcol(1);
    tinyxy(10,350,"GPA TEXT COLOR 4");
    setcol(2);
    tinyxy(10,360,"GPA TEXT COLOR 5");
    setcol(3);
    tinyxy(10,370,"GPA TEXT COLOR 6");
    setcol(4);
    tinyxy(10,380,"GPA TEXT COLOR 7");
    setcol(5);
    tinyxy(10,390,"GPA TEXT COLOR 8");
    setcol(6);
    tinyxy(115,320,"GPA TEXT COLOR 9");
    setcol(7);
    tinyxy(115,330,"GPA TEXT COLOR 10");
    setcol(8);
    tinyxy(115,340,"GPA TEXT COLOR 11");
    setcol(9);
    tinyxy(115,350,"GPA TEXT COLOR 12");
    setcol(10);
    tinyxy(115,360,"GPA TEXT COLOR 13");
    setcol(11);
    tinyxy(115,370,"GPA TEXT COLOR 14");
    setcol(12);
    tinyxy(115,380,"GPA TEXT COLOR 15");
    setcol(13);
    tinyxy(115,390,"GPA TEXT COLOR 16");
    if (monoval[0]<avemono) setcol(maxcolnum); else setcol(mincolnum);
    tinyxy(16,430,"RECESSED REGION");
    tinyxy(135,430,"RAISED REGION");
    setcol(15);
    moveto(10,445); lineto(110,445); lineto(110,425);
    setcol(8);
    lineto(10,425); lineto(10,445);
    setcol(8);
    moveto(115,445); lineto(220,445); lineto(220,425);
    setcol(15);
    lineto(115,425); lineto(115,445);
    setcol(maxcolnum);
    if (defcolours) {
        tinyxy(300,410,"GPA DEFAULT COLOUR PALETTE SETUP");
    } else {
        tinyxy(300,410,"COLOUR PALETTE SETUP FROM %s",strupr(argv[1]));
    }
    getch();
    setmonopalette(monoval,avecolnum);
    tinyxy(300,430,"VIEW ON MONOCHROME MONITOR");
    getch();
    closegraf();
    return(1);
}
