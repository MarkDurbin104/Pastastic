#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>
#include "types.h"

#define I asm

typedef void interrupt (*ISRPTR)(void);
ISRPTR                   oldkeyb; 

#define BITMASK(a) OUTPB(0x3CE,8); OUTPB(0x3CF,a)
#define MAPMASK(a) OUTPB(0x3C4,2); OUTPB(0x3C5,a)
#define ESETRES(a) OUTPB(0x3CE,1); OUTPB(0x3CF,a)
#define SETRES(a)  OUTPB(0x3CE,0); OUTPB(0x3CF,a)
#define SETMODE(a) OUTPB(0x3CE,5); OUTPB(0x3CF,a)
#define WRITEPLANE(a) OUTPW(0x3C4,(UINT16)((0x100<<(a))|2));
#define READPLANE(a)  OUTPW(0x3CE,(UINT16)(((a)<<8)|4));


typedef struct tagBITMAPFILEHEADER { /* bmfh */
	UINT    bfType;
	ULONG   bfSize;
	UINT    bfReserved1;
	UINT    bfReserved2;
	ULONG   bfOffBits;
} BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER {    /* bmih */
	ULONG   biSize;
	LONG    biWidth;
	LONG    biHeight;
	UINT    biPlanes;
	UINT    biBitCount;
	ULONG   biCompression;
	ULONG   biSizeImage;
	LONG    biXPelsPerMeter;
	LONG    biYPelsPerMeter;
	ULONG   biClrUsed;
	ULONG   biClrImportant;
} BITMAPINFOHEADER;

typedef struct {
	BITMAPFILEHEADER	bmfh;
	BITMAPINFOHEADER	bmih;
} BMPH;
typedef struct {
	CHAR name[40];
	INT w;
	INT h;
	LONG ofs;
	INT del;
	INT x;
	INT y;
	INT ln;
	INT sz;
	INT st;
	UCHAR type;
	INT bw;
    CHAR *buf;
} IMAGE;
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
UCHAR *G_lnbuf=NULL;        // Current line of printed font
INT    G_lnbufsize=0;       // Current size of line buffer
CHAR *           MONOVIDMEM;		// Macro for base address of mono video memory (varies real,protected 32 or 16 bit)
CHAR *           COLVIDMEM;			// Ditto colour
CHAR *           TEXTVIDMEM;		// Ditto text
INT16            COLVIDSEG;			// Colour video segment (real & protected 16 bit modes)
volatile  INT    G_hadkey=0;

// keyboard interrupt routine
void interrupt mykeyb(void)
{
    unsigned char stat;
    static int down=0;
    int k;

    disable();
    k=inp(0x60);
    if (k&0x80) {
        if (down) G_hadkey=1;
    } else {
        down=1;
    }
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);
    enable();
}
void waitrf(void)
{
I	mov  dx,0x3DA
waithere:
I	in   al,dx
I	test al,8
I	je   waithere
}
//*****************************************************
//F freeimg
//S
//P
void freeimg(IMAGE *img)
{
    INT i;
    if (img==NULL) return;
    for (i=0;i<NUMIMINLIST;i++) {
        if (G_lastloadbmps[i].name!=NULL) {
            if (!strcmp(G_lastloadbmps[i].name,img->name)) { // if bitmap already loaded
                G_lastloadbmps[i].image=NULL;
                free(G_lastloadbmps[i].name);
                G_lastloadbmps[i].name=NULL;
                G_lastloadbmps[i].age=0;
            }
        }
    }
	if (img==NULL) return;
	if (img->buf!=NULL) free(img->buf);
    img->buf=NULL;
	free(img);
    img=NULL;
}
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
                if (G_lastloadbmps[i].name!=NULL) free(G_lastloadbmps[i].name);
                G_lastloadbmps[i].age=youngest;   // add new one
                G_lastloadbmps[i].image=im;
                G_lastloadbmps[i].name=strdup(name);
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
    _EAX=0;
    _AX=rax;
    geninterrupt(0x10);
}
//*****************************************************
//F setlnbuf
//S
//P
INT setlnbuf(INT size)
{
	if (G_lnbuf==NULL) {
		G_lnbufsize=size;
		G_lnbuf=malloc(256*G_lnbufsize);
		if (G_lnbuf==NULL) {
			G_lnbufsize=0;
			return(0);
		}
	} else {
		if (size>G_lnbufsize) {
			G_lnbufsize=size;
			G_lnbuf=realloc(G_lnbuf,256*G_lnbufsize);
			if (G_lnbuf==NULL) {
				G_lnbufsize=0;
				return(0);
			}
		}
	}
	memset(G_lnbuf,0,256*G_lnbufsize);
	return(1);
}
//*****************************************************
//F intsize
//S
//P
INT intsize(INT a)
{
	if (a&1) return(a+1);
	return(a);
}
//*****************************************************
//F mov4
//S Move bits into the four bitplanes for display.
//P
void mov4(UCHAR *d,UCHAR *s)
{
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
}
//*****************************************************
//F reorg
//S Re-organise 
//P Destination buffer
//P Source buffer
//P Width in bytes
void reorg(UCHAR *d,UCHAR *s,INT w)
{
	INT i,j;
	UCHAR buf[4];

	w/=4;
	for (i=0;i<w;i++) {
		mov4(buf,&s[i*4]);
		for (j=0;j<4;j++) d[i+j*w]=buf[j];
	}
}
//*****************************************************
//F getbmp
//S
//P
IMAGE *getbmp(CHAR *name)
{
	FILE *fp;
	INT i,j,w,k;
	INT ofs;
	BMPH bmph;
	IMAGE *im;
	UCHAR *buf;
	UCHAR rb[360];
		
    for (i=0;i<NUMIMINLIST;i++) {
        if (G_lastloadbmps[i].name!=NULL) {
            if (!strcmp(G_lastloadbmps[i].name,name)) { // if bitmap already loaded
                 return(G_lastloadbmps[i].image);        // return it
            }
        }
    }
    
	setlnbuf(16);
	buf=G_lnbuf;

	if ((fp=fopen(name,"rb"))==NULL) return(NULL);
	fread(&bmph,sizeof(BMPH),1,fp);
	w=(((INT)(bmph.bmih.biWidth)+7)/8)*4;
	if (w==0) {
		fclose(fp);
		return(NULL);
	}
	ofs=(int)bmph.bmih.biHeight;
	ofs*=intsize(w);
	im=malloc(sizeof(IMAGE));
	if (im==NULL) return(NULL);
	fseek(fp,bmph.bmfh.bfOffBits,SEEK_SET);
    im->buf=malloc(ofs);
	if (im->buf==NULL) {
        return(NULL);
    }
    if (bmph.bmih.biWidth==640) {
		for (i=(INT)(bmph.bmih.biHeight)-1;i>=0;i--) {
			fread(rb,w,1,fp);
			reorg(buf,rb,w);
			for (j=0;j<4;j++) {
				ofs=j;
				ofs*=(int)(bmph.bmih.biHeight)*80;
				ofs+=i*80;
                for (k=0;k<80;k++) (im->buf+ofs)[k]=(buf+j*80)[k];
			}
		}
	} else {
		for (i=0;i<bmph.bmih.biHeight;i++) {
			ofs-=intsize(w);
			fread(rb,w,1,fp);
			reorg(buf,rb,w);
       		memcpy(im->buf+ofs,buf,w);
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
	return(im);
}
void OUTPB(INT16 a,CHAR b)
{
    _EDX=0;
    _EAX=0;
    _DX=a;
    _AL=b;
    __emit__(0xEE);
}
void OUTPW(INT16 a,INT16 b)
{
    OUTPB(a++,(CHAR)(b&0xFF));
    b>>=8;
    OUTPB(a,(CHAR)(b&0xFF));
}
//*****************************************************
//F shiftbits
//S shift an image buffer rignt by 'sft' bits
//P the buffer
//P the buffer width (in bytes)
//P the number of bits to shift
void shiftbits(UCHAR *buf,UCHAR w,UCHAR sft)
{
	if (!sft) return;
I { push es
    les bx,buf
    mov cl,sft
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
    pop es
}
}

//*****************************************************
//F outln
//S Output a line
void outln(INT x,INT y,INT w,UCHAR *buf,INT newbmp)
{
	INT i;
	static UCHAR mask;
	static UCHAR *scr;
	static UCHAR *eol;
	static INT   wid;
	if (newbmp) {
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
	if (img==NULL) return;
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
		for (i=0;i<img->h;i++) {
   	        memcpy(buf,img->buf+tl,img->bw);
			outln(x,y++,img->w,buf,i==0);
			tl+=img->bw;
		}
	}
	BITMASK(255); ESETRES(0); MAPMASK(15);
}
void fputimage(INT x,INT y,IMAGE *img)
{
	UCHAR *scr=(UCHAR *)(COLVIDMEM+(INT)((LONG)y*80L)+(INT)(x>>3));
    UCHAR *buf;
    UCHAR *s;
    UCHAR *b;
    UCHAR tbuf[81];
    INT   i,j,k,w,w2,shft=x&7;
    UCHAR mask=0xFF,emask=0xFF;
    if (img==NULL) return;
    if (img->buf==NULL) return;
    w2=img->bw;
    w=w2/4;
    b=(UCHAR *)img->buf;
    j=img->h;
    emask>>=((x+img->w)&7);
    emask=~emask;
    if (shft) {
        mask>>=shft;
        mask=~mask;
    }
	for (i=0;i<4;i++) {
		WRITEPLANE(i);
//        if ((shft)||(emask))
            READPLANE(i);
        s=scr;
        buf=b;
        for (k=0;k<j;k++) {
            if (shft) {
                memcpy(tbuf,buf,w);
                shiftbits(tbuf,w,x&7);
                *s&=mask;
                *s|=*tbuf;
                if (emask) {
                    memcpy(s+1,tbuf+1,w);
                    *(s+w)&=~emask;
                    *(s+w)|=*(tbuf+w)&emask;
                } else {
                    memcpy(s+1,tbuf+1,w);
                }
            } else {
                if (emask) {
                    memcpy(s,buf,w);
                    *(s+w)&=~emask;
                    *(s+w)|=*(buf+w)&emask; 
                } else {
                    memcpy(s,buf,w);
                }
            }
            buf+=w2;
            s+=80;
        }
        b+=w;
	}
}
//*****************************************************
//F setborder
//S Set the border colour register using INT 10h
//P colour value to store
void setborder(UCHAR attr)
{
    attr=(UCHAR)((attr==6)?0x14:((attr<8)?attr:0x30+attr));
    _EAX=0;
    _AX=0x1001;
    _EBX=0;
    _BL=0;
    _BH=attr;
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
}
void setbmppal(char *file)
{
    BMPH  bmph;
    UCHAR pal[49];
    int i;
    FILE *fp;
    if ((fp=fopen(file,"rb"))!=NULL) {
		fread(&bmph,sizeof(BMPH),1,fp); // Skip header
		for (i=0;i<48;i+=3) {
			fread(&pal[i],1,4,fp);	// blue,green,red
		}
        fclose(fp);
        for (i=0;i<48;i++) pal[i]>>=2;
    }
    for (i=0;i<16;i++)
        setrgbpalette(((i==6)?0x14:((i<8)?i:0x30+i)),*(pal+i*3+2),*(pal+i*3+1),*(pal+i*3));
}
//*****************************************************
//F putpixel
//S Set a pixel at location x,y
//P X position
//P Y position
void putpixel(INT x,INT y,UCHAR c)
{
	UCHAR *scr,m=(UCHAR)(0x80>>(x&7));
	scr=(UCHAR *)COLVIDMEM+(y*80)+(x>>3);
	OUTPW(0x3CE,0x0F01);
    OUTPB(0x3CE,0);
	OUTPB(0x3CF,c);
    OUTPB(0x3CE,8);
	OUTPB(0x3CF,m);
	*scr&=m;
	OUTPW(0x3C4,0x0F02);
	OUTPW(0x3CE,0xFF08);
	OUTPW(0x3CE,0x0001);
}
int movepoint(int *x,int *y,int dir,int speed)
{                                               //  3   0
    switch (dir) {            // 'dir' from origin--> *
        case 0  : *x+=speed; *y-=speed; break;  //  2   1
        case 1  : *x+=speed; *y+=speed; break;  
        case 2  : *x-=speed; *y+=speed; break;  
        default : *x-=speed; *y-=speed;
    }
    if (*y<0 )  { *y=0-*y;   if (dir==0) dir++; else dir--; }
    if (*x>544) { *x=1088-*x; if (dir==1) dir++; else dir--; }   
    if (*y>296) { *y=592-*y; if (dir==2) dir++; else dir--; }
    if (*x<0 )  { *x=0-*x;   if (dir==3) dir++; else dir--; }
    dir&=3; 
    return(dir);
}
void cls(void)
{
	OUTPW(0x3C4,0x0F02);
	OUTPW(0x3CE,0xFF08);
	memset(COLVIDMEM,0,38400U);
}
int main(int argc)
{
    INT x,y,d,i,j,q,k=252;
    INT spin=0;
    IMAGE *a[6],*b;
    INT spinat=random(800)+2000;
//    long farfreemem;
//    long farfreememstart;
#ifdef __DPMI32__
    COLVIDMEM=MK_FP(0xA000,0x0000,0x00020000);
    MONOVIDMEM=COLVIDMEM+0x00010000;
    TEXTVIDMEM=COLVIDMEM+0x00018000;
#else
    COLVIDMEM=MK_FP(__SegA000,0x0000);
    COLVIDSEG=__SegA000;
    MONOVIDMEM=MK_FP(__SegB000,0x0000);
    TEXTVIDMEM=MK_FP(__SegB800,0x0000);
#endif
//    farfreememstart=farfreemem=farcoreleft();
    oldkeyb=getvect(0x09);
    setvect(0x09,mykeyb);

    b=getbmp("POWALL.BMP");
//    farfreemem=min(farfreemem,farcoreleft());
    vidint(0x12);
    setbmppal("POWALL.BMP");
    setborder(0);
    setrgbpalette(0x3C,0,0,0);
    setrgbpalette(0x3F,0,0,0x3F);
    putimage(0,0,b);
    freeimg(b);

    a[0]=getbmp("SPOBALL.BMP");
    a[1]=getbmp("SPOBALL1.BMP");
    a[2]=getbmp("SPOBALL2.BMP");
    a[3]=getbmp("SPOBALL3.BMP");
    a[4]=getbmp("SPOBALL4.BMP");
    a[5]=getbmp("SPOBALL5.BMP");
//    farfreemem=min(farfreemem,farcoreleft());
    x=22;
    y=14;
    d=1;
    i=0;
    j=0; q=1;
    while (!G_hadkey) {
        setrgbpalette(0x3C,0,0,i);
        i+=q;
        if ((i>62)||(i<1)) q=0-q;
        if (k) {
            if (k>0) k--;
            setrgbpalette(0x3F,0,0,k/4);
        } else {
            delay(20);
        }
        d=movepoint(&x,&y,d,4);
        fputimage(x,95+y,a[j]);
        if (G_hadkey) break;
        if (spin==spinat) {
            for (spin=0;spin<4;spin++) {
                for (j=0;j<5;j++) {
                    delay(20);
                    fputimage(x,95+y,a[j]);
                    if (G_hadkey) break;
                }
                for (;j>0;j--) {
                    delay(20);
                    fputimage(x,95+y,a[j]);
                    if (G_hadkey) break;
                }
            }
            spin=0;
            spinat=random(800)+200;
        }
        spin++;
    }
    for (j=0;j<6;j++) freeimg(a[j]);
    setvect(0x09,oldkeyb);
    if (argc>1) vidint(3); else vidint(0x12);
//    printf("Memory Used %ld\n",farfreememstart-farfreemem);
    return 0;
}
