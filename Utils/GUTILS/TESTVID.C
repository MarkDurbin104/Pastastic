#include <windows.h>
#include <dos.h>

#define DLLFUNC FAR PASCAL _export

unsigned char *COLVIDMEM;
int G_vidset=0;

void vidint(void)
{
    _AX=0x12;
    geninterrupt(0x10);
}

void putpixel(int x,int y,unsigned char col)
{
    unsigned char *scr,m=(unsigned char)(0x80>>(x&7));
    COLVIDMEM=(unsigned char *)MK_FP(__SegA000,0x0000);
    scr=(unsigned char *)COLVIDMEM+(y*80)+(x>>3);
//    if (G_curgd->wm) OUTPW(0x3CE,0x1803);
    outpw(0x3CE,0x0F01);
    outportb(0x3CE,0);
    outportb(0x3CF,col);
    outportb(0x3CE,8);
    outportb(0x3CF,m);
    *scr&=m;
    outpw(0x3C4,0x0F02);
    outpw(0x3CE,0xFF08);
    outpw(0x3CE,0x0001);
//    if (G_curgd->wm) outpw(0x3CE,0x0003);
}

void DLLFUNC PutAPixel(int x,int y,int col)
{
    if (!G_vidset) vidint();
    G_vidset=1;
    putpixel(x,y,(unsigned char)col);
}
