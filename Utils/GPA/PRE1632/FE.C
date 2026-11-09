#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <conio.h>
#include <memory.h>
#include <alloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

#include "keydef.h"

#define FONTSIZE (32+14*256+16*256)
unsigned char   G_font[FONTSIZE];
unsigned char   *G_tfont;
unsigned char   G_sb[16]="\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
unsigned char   G_cb[16]="\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
int             G_topbot=0;
int             G_px=0;
int             G_py=0;
unsigned char   G_addinfo[256];
unsigned char   G_cmap[768];

void getfont(void)
{
    struct REGPACK r;
    r.r_ax=0x1130;
    r.r_bx=0x0600;
    intr(0x10,&r);
    G_tfont=(unsigned char *)MK_FP(r.r_es,r.r_bp);
}
int getkey(void) 
{
    int k;
    if (!(k=getch())) k=0-getch();
    return(k);
}
void beep(void)
{
    sound(500);
    delay(200);
    nosound();
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
    return(1);
}
int readfont(char *file)
{
    int fd;
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    read(fd,G_font,FONTSIZE);
    read(fd,G_addinfo,256);
    read(fd,G_cmap,768);
    close(fd);
	if ((G_font[31]!='L')&&(G_font[31]!='R')) G_font[31]='L';
    return(1);
}
int writefont(char *file)
{
    int fd;
    fd=open(file,O_RDWR|O_CREAT|O_TRUNC|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) return(0);
    write(fd,G_font,FONTSIZE);
    write(fd,G_addinfo,256);
    write(fd,G_cmap,768);
    close(fd);
    return(1);
}
void outch(int x,int y,unsigned char c,int set,int col,int flip,int xor) 
{
	unsigned char *t=(unsigned char *)0xA0000000L; 
    char *s;
    unsigned char *f;
	int i,j;
    unsigned char mask;
    int cpos;
    int linespace;
    if (set==3) {
        f=G_tfont;
        linespace=16;
        cpos=c*linespace;
    }
    else {
        f=G_font;
        linespace=16-set*2;
        cpos=(c*linespace)+32+(set*4096);
    }

    y*=linespace;
	for (i=0;i<4;i++) {
		outportb(0x3CE,4);
		outportb(0x3CF,i);
		outportb(0x3C4,2);
		outportb(0x3C5,(1<<i));
        s=t+x+(y*80);
		if (col&(1<<i)) {
        	for (j=0;j<linespace;j++) {
                if (flip) mask=f[cpos+j]^0xFF; else mask=f[cpos+j];
          		if (xor) *s^=mask; else *s=mask;
                s+=80;
        	}
		}
		else {
        	for (j=0;j<linespace;j++) {
   				*s=0;
                s+=80;
   			}
		}
	}
	i=getpixel(0,0);
	putpixel(0,0,col);
	putpixel(0,0,i);
}
void put9w(int x,int y,unsigned char c,int set,int col)
{
    int i,j,offset;

    offset=c*(16-(set<<1))+32+(set*4096);
    y*=16-(set<<1);
    x*=9;

    setfillstyle(1,0);
    bar(x,y,x+9,y+16-(set<<1));
    for (i=0;i<16-(set<<1);i++) {
        for (j=0;j<8;j++) {
            if ((G_font[offset+i]&(0x80>>j))!=0) putpixel(x+j,y+i,col);
        }
    }
    if (c>=128) {
        for (i=0;i<16-(set<<1);i++) {
            if ((G_font[offset+i]&1)!=0) putpixel(x+j,y+i,col);
        }
    }
}
void prat(int x,int y,int set,int col,char *fmt, ... )
{
    unsigned char str[140],*s;
    va_list ap;

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    s=str;
    while (*s) outch(x++,y,*(s++),set,col,0,0);
}
void copychar(unsigned char c)
{
    int offset;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    memcpy(G_cb,&G_font[offset],(16-(G_topbot*2)));
}
void cputchar(unsigned char c)
{
    int offset;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    memcpy(&G_font[offset],G_cb,(16-(G_topbot*2)));
}
void cxorchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(16-(G_topbot*2));i++) G_font[offset+i]^=G_cb[i];
}
void candchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(16-(G_topbot*2));i++) G_font[offset+i]&=G_cb[i];
}
void blnkchar(unsigned char c)
{
    int offset;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    memset(&G_font[offset],0,(16-(G_topbot*2)));
}
void flipvchar(unsigned char c)
{
    int offset;
    int i,tmp;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<8-G_topbot;i++) {
        tmp=G_font[offset+i];
        G_font[offset+i]=G_font[offset+((15-(G_topbot*2))-i)];
        G_font[offset+((15-(G_topbot*2))-i)]=tmp;
    }
}
void fliphchar(unsigned char c)
{
    int offset;
    int i,j,tmp;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(16-(G_topbot*2));i++) {
        tmp=0;
        for (j=0;j<8;j++) if ((G_font[offset+i]&(0x80>>j))!=0) tmp|=(0x01<<j);
        G_font[offset+i]=tmp;
    }
}
void shlchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(16-(G_topbot*2));i++) {
        G_font[offset+i]<<=1;
    }
}
void shrchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(16-(G_topbot*2));i++) {
        G_font[offset+i]>>=1;
    }
}
void shdchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=(15-(G_topbot*2));i>0;i--) {
        G_font[offset+i]=G_font[offset+i-1];
    }
    G_font[offset+i]=0;
}
void shuchar(unsigned char c)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    for (i=0;i<(15-(G_topbot*2));i++) {
        G_font[offset+i]=G_font[offset+i+1];
    }
    G_font[offset+i]=0;
}
void moveallb2(void)
{
    int offset;
    int i;
    unsigned char tmp;
    unsigned int c;
    for (c=0;c<256;c++) {
        offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
        if (c>31&&c<128) {
            for (i=0;i<(16-(G_topbot*2));i++) {
                tmp=
                ((G_font[offset+i]&0x80)>>1)
                |((G_font[offset+i]&0x38))
                |((G_font[offset+i]&0x03)<<1);

                G_font[offset+i]=tmp<<1;
            }
            if (c>='a'&&c<='z') {
                G_font[offset+ 0]=G_font[offset+3];
                G_font[offset+ 1]=G_font[offset+4];
                G_font[offset+ 2]=G_font[offset+5];
                G_font[offset+ 3]=G_font[offset+6];
                G_font[offset+ 4]=G_font[offset+7];
                G_font[offset+ 5]=G_font[offset+8];
                G_font[offset+ 6]=G_font[offset+9];
                G_font[offset+ 7]=G_font[offset+10];
                G_font[offset+ 8]=G_font[offset+11];
                G_font[offset+ 9]=G_font[offset+12];
                G_font[offset+10]=G_font[offset+13];
                G_font[offset+11]=G_font[offset+14];
                G_font[offset+12]=0;
                G_font[offset+13]=0;
                G_font[offset+14]=0;
                G_font[offset+15]=0;
            } else {
                G_font[offset+ 0]=G_font[offset+1];
                G_font[offset+ 1]=G_font[offset+2];
                G_font[offset+ 2]=G_font[offset+3];
                G_font[offset+ 3]=G_font[offset+4];
                G_font[offset+ 4]=G_font[offset+5];
                G_font[offset+ 5]=G_font[offset+6];
                G_font[offset+ 6]=G_font[offset+7];
                G_font[offset+ 7]=G_font[offset+8];
                G_font[offset+ 8]=G_font[offset+9];
                G_font[offset+ 9]=G_font[offset+10];
                G_font[offset+10]=G_font[offset+11];
                G_font[offset+11]=G_font[offset+12];
                G_font[offset+12]=0;
                G_font[offset+13]=0;
                G_font[offset+14]=0;
                G_font[offset+15]=0;
            }
            
        } else {
            for (i=0;i<(16-(G_topbot*2));i++) {
                tmp=
                ((G_font[offset+i]&0xC0)>>1)
                |((G_font[offset+i]&0x18))
                |((G_font[offset+i]&0x03)<<1);

                G_font[offset+i]=tmp<<1;
            }
            G_font[offset+ 0]=G_font[offset+1];
            G_font[offset+ 1]=G_font[offset+2];
            G_font[offset+ 2]=G_font[offset+4];
            G_font[offset+ 3]=G_font[offset+5];
            G_font[offset+ 4]=G_font[offset+6];
            G_font[offset+ 5]=G_font[offset+7];
            G_font[offset+ 6]=G_font[offset+8];
            G_font[offset+ 7]=G_font[offset+9];
            G_font[offset+ 8]=G_font[offset+10];
            G_font[offset+ 9]=G_font[offset+12];
            G_font[offset+10]=G_font[offset+13];
            G_font[offset+11]=G_font[offset+14];
            G_font[offset+12]=0;
            G_font[offset+13]=0;
            G_font[offset+14]=0;
            G_font[offset+15]=0;
        }
    }
    for (i=0;i<255;i++) outch(2+(i%32),13+i/32,i,0,8,0,0);
}
void dispfonts(char *file)
{
    int i,j;
    setcolor(14);
    rectangle(0,0,639,320);
    line(0,159,639,159);


    for (j=0;j<2;j++) {
        for (i=0;i<255;i++) {
            outch(2+(i%32),(j*12)+1+i/32,i,j,8,0,0);
        }
    }
    setcolor(9);
    for (i=0;i<16;i++) {
        for (j=0;j<8;j++) {
            rectangle(300+j*8,16+i*8,300+j*8+8,16+i*8+8);
            rectangle(400+j*8,16+i*8,400+j*8+8,16+i*8+8);
            if (i<14) {
                rectangle(300+j*8,183+i*8,300+j*8+8,183+i*8+8);
                rectangle(400+j*8,183+i*8,400+j*8+8,183+i*8+8);
            }
        }
    }
    setcolor(1);
    for (i=0;i<16;i++) {
        rectangle(402+j*8,16+i*8,402+j*8+8,16+i*8+8);
        if (i<14) rectangle(402+j*8,183+i*8,402+j*8+8,183+i*8+8);
    }

    prat(62,3 ,3,12,"16x8");
    prat(62,7 ,3,12,"16x9");
    prat(62,13,3,12,"14x8");
    prat(62,17,3,12,"14x9");

    prat(7,21,3,10,"%s",strupr(file));

    prat(4,23,3,9,"ESC   - UNDO      TOP      - T          CUT   - F1      FLIPHORIZ - F6 ");
    prat(4,24,3,9,"UP    - UP        BOTTOM   - B          PASTE - F2      FLIPVERT  - F7 ");
    prat(4,25,3,9,"DOWN  - DOWN      TOGGLE   - SPACE      COPY  - F3      RE-LOAD   - F8 ");
    prat(4,26,3,9,"LEFT  - LEFT      SET      - S          XOR   - F4      SAVE      - F9 ");
    prat(4,27,3,9,"RIGHT - RIGHT     CLEAR    - C          AND   - F5      EXIT      - F10");

    prat(2,29,3,14,"Font Editor Version 0.1                       Copyright (c) 1992 Unisys Ltd.");
}
void putdot(int x,int y)
{
    if (G_topbot) {
        setfillstyle(1,14^getpixel(401+x*8,184+y*8));
        bar(401+x*8,184+y*8,407+x*8,190+y*8);
    }
    else {
        setfillstyle(1,14^getpixel(401+x*8,17+y*8));
        bar(401+x*8,17+y*8,407+x*8,23+y*8);
    }
}
void bigchar(int x,int y,int len,int dup,int col,unsigned char *buf)
{
    int i,j;
    for (i=0;i<len;i++) {
        for (j=0;j<8;j++) {
            setfillstyle(1,col*((buf[i]&(0x80>>j))!=0));
            bar(x+j*8+1,y+i*8+1,x+j*8+7,y+i*8+7);
            if (kbhit()) return;
        }
    }
    if (dup) {
        if (dup>0) {
            for (i=0;i<len;i++) {
                setfillstyle(1,col*((buf[i]&1)!=0));
                bar(2+x+j*8+1,y+i*8+1,2+x+j*8+7,y+i*8+7);
                if (kbhit()) return;
            }
        }
    }
    else {
        setfillstyle(1,0);
        for (i=0;i<len;i++) {
            bar(2+x+j*8+1,y+i*8+1,2+x+j*8+7,y+i*8+7);
            if (kbhit()) return;
        }
    }
}
void markchar(unsigned char c,int rd)
{
    int j,i;
    void *bm;
    for (j=0;j<2;j++) outch(2+(c%32),(j*12)+1+c/32,c,j,11,1,0);
    if ((rd)&&(!kbhit())) {

        setcolor(11);
        if (G_topbot)
            rectangle(399,182,465,296);
        else
            rectangle(399,15,465,145);

        bigchar(400,16,16,(c>=128),11,&G_font[(c<<4)+32]);
        bigchar(400,183,14,(c>=128),11,&G_font[c*14+4128]);

        for (i=0;i<3;i++) {
            outch(70+i,1,c,0,11,0,0);
            outch(70+i,2,c,0,11,0,0);
            outch(70+i,3,c,0,11,0,0);
            put9w(62+i,5,c,0,11);
            put9w(62+i,6,c,0,11);
            put9w(62+i,7,c,0,11);
            outch(70+i,13,c,1,11,0,0);
            outch(70+i,14,c,1,11,0,0);
            outch(70+i,15,c,1,11,0,0);
            put9w(62+i,17,c,1,11);
            put9w(62+i,18,c,1,11);
            put9w(62+i,19,c,1,11);
        }
        prat(25,21,3,12,"%c Decimal-%03d  Hexidecimal-%02X  Octal-%d%d%d %d %d",G_font[31],c,c,((c>>6)&7),((c>>3)&7),(c&7),G_addinfo[c]>>4,G_addinfo[c]&0x0F);
    }
    putdot(G_px,G_py);
}
void unmarkchar(unsigned char c,int rd)
{
    int j;
    setcolor(0);
    for (j=0;j<2;j++) outch(2+(c%32),(j*12)+1+c/32,c,j,8,0,0);
    if ((rd)&&(!kbhit())) {
        if (G_topbot)
            rectangle(399,182,465,296);
        else
            rectangle(399,15,465,145);
    
    }
    putdot(G_px,G_py);
}
void savechar(unsigned char c)
{
    int offset;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    memcpy(G_sb,&G_font[offset],(16-(G_topbot*2)));
    if (!kbhit()) {
        bigchar(300,16,16,0,11,&G_font[(c<<4)+32]);
        bigchar(300,183,14,0,11,&G_font[c*14+4128]);
    }
}
void restchar(unsigned char c)
{
    int offset;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096);
    memcpy(&G_font[offset],G_sb,(16-(G_topbot*2)));
}
void setcbit(unsigned char c,int setmode)
{
    int offset;
    int i;
    offset=c*(16-(G_topbot*2))+32+(G_topbot*4096)+G_py;
    switch (setmode) {
        case 0 :
            G_font[offset]&=~(0x80>>G_px);
            break;
        case 1 :
            G_font[offset]|=(0x80>>G_px);
            break;
        default :
            G_font[offset]^=(0x80>>G_px);
    }
}
int main(int argc,char *argv[])
{
    int xit=0;
    int curpos=0,k,l;
    unsigned char i,j;
	char *ss=(char *)0x00000417L;    // Shift key status 0000ACSS
	memset(G_addinfo,0,256);
    if (argc<2) {
        printf("FE fontfile\n");
        return(0);
    }
    if (!readfont(argv[1])) {
        printf("Can't open fontfile %s\n",argv[1]);
        return(0);
    }
    getfont();
    if (!grafix()) return(0);

    dispfonts(argv[1]);

    markchar(curpos,1);
    savechar(curpos);
    while (!xit) {
        if (kbhit()) {
            switch (getkey()) {
                case PGUP :
                    unmarkchar(curpos,1);
                    shuchar(curpos);
                    markchar(curpos,1);
                    break;
                case PGDN :
                    unmarkchar(curpos,1);
                    shdchar(curpos);
                    markchar(curpos,1);
                    break;
                case CLEFT :
                    unmarkchar(curpos,1);
                    shlchar(curpos);
                    markchar(curpos,1);
                    break;
                case CRGT :
                    unmarkchar(curpos,1);
                    shrchar(curpos);
                    markchar(curpos,1);
                    break;
                case UP :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos-=32;
                        if (curpos<0) curpos+=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    else {
                        if ((*(ss)&15)==0) {
                            unmarkchar(curpos,0);
                            G_py--;
                            if (G_py<0) G_py=15-(G_topbot*2);
                            markchar(curpos,0);
                        }
                    }
                    break;
                case DOWN :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos+=32;
                        if (curpos>255) curpos-=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    else {
                        if ((*(ss)&15)==0) {
                            unmarkchar(curpos,0);
                            G_py++;
                            if (G_py>15-(G_topbot*2)) G_py=0;
                            markchar(curpos,0);
                        }
                    }
                    break;
                case LEFT :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos--;
                        if (curpos<0) curpos+=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    else {
                        if ((*(ss)&15)==0) {
                            unmarkchar(curpos,0);
                            G_px--;
                            if (G_px<0) G_px=7;
                            markchar(curpos,0);
                        }
                    }
                    break;
                case RGT :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos++;
                        if (curpos>255) curpos-=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    else {
                        if ((*(ss)&15)==0) {
                            unmarkchar(curpos,0);
                            G_px++;
                            if (G_px>7) G_px=0;
                            markchar(curpos,0);
                        }
                    }
                    break;
                case '8' :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos-=32;
                        if (curpos<0) curpos+=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    break;
                case '2' :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos+=32;
                        if (curpos>255) curpos-=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    break;
                case '4' :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos--;
                        if (curpos<0) curpos+=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    break;
                case '6' :
                    if ((*(ss)&3)!=0) {
                        unmarkchar(curpos,1);
                        curpos++;
                        if (curpos>255) curpos-=256;
                        savechar(curpos);
                        markchar(curpos,1);
                    }
                    break;
                case 'b' :
                case 'B' :
                    unmarkchar(curpos,1);
                    G_topbot=1;
                    savechar(curpos);
                    markchar(curpos,1);
                    break;
                case 't' :
                case 'T' :
                    unmarkchar(curpos,1);
                    G_topbot=0;
                    savechar(curpos);
                    markchar(curpos,1);
                    break;
                case SF01 :
                    unmarkchar(curpos,1);
                    moveallb2();
                    markchar(curpos,1);
                    break;
                case F01 :
                    unmarkchar(curpos,1);
                    copychar(curpos);
                    blnkchar(curpos);
                    markchar(curpos,1);
                    break;
                case F02 :
                    unmarkchar(curpos,1);
                    cputchar(curpos);
                    markchar(curpos,1);
                    break;
                case F03 :
                    unmarkchar(curpos,1);
                    copychar(curpos);
                    markchar(curpos,1);
                    break;
                case F04 :
                    unmarkchar(curpos,1);
                    cxorchar(curpos);
                    markchar(curpos,1);
                    break;
                case F05 :
                    unmarkchar(curpos,1);
                    candchar(curpos);
                    markchar(curpos,1);
                    break;
                case F06 :
                    unmarkchar(curpos,1);
                    fliphchar(curpos);
                    markchar(curpos,1);
                    break;
                case F07 :
                    unmarkchar(curpos,1);
                    flipvchar(curpos);
                    markchar(curpos,1);
                    break;
                case F08 :
                    unmarkchar(curpos,1);
                    readfont(argv[1]);
                    dispfonts(argv[1]);
                    markchar(curpos,1);
                    break;
                case F09 :
                    unmarkchar(curpos,1);
                    writefont(argv[1]);
                    markchar(curpos,1);
                    break;
                case F10 :
                    xit=1;
                    break;
                case ESC :
                    unmarkchar(curpos,1);
                    restchar(curpos);
                    markchar(curpos,1);
                    break;
                case SPACE :
                    unmarkchar(curpos,1);
                    setcbit(curpos,(-1));
                    markchar(curpos,1);
                    break;
                case 'S' :
                case 's' :
                    unmarkchar(curpos,1);
                    setcbit(curpos,1);
                    markchar(curpos,1);
                    break;
                case 'C' :
                case 'c' :
                    unmarkchar(curpos,1);
                    setcbit(curpos,0);
                    markchar(curpos,1);
                    break;
                case 'm' :
                case 'M' :
                    unmarkchar(curpos,1);
					i=G_addinfo[curpos]&0x0F;
					j=G_addinfo[curpos]&0xF0;
					i++;
					i&=0x0F;
					G_addinfo[curpos]=j|i;
                    markchar(curpos,1);
                    break;
                case 'p' :
                case 'P' :
                    unmarkchar(curpos,1);
					i=G_addinfo[curpos]&0x0F;
					j=G_addinfo[curpos]&0xF0;
					j>>=4;
					j++;
					j&=0x0F;
					j<<=4;
					G_addinfo[curpos]=j|i;
                    markchar(curpos,1);
                    break;
                case 'l' :
                case 'L' :
                    unmarkchar(curpos,1);
					G_font[31]='L';
                    markchar(curpos,1);
                    break;
                case 'r' :
                case 'R' :
                    unmarkchar(curpos,1);
					G_font[31]='R';
                    markchar(curpos,1);
                    break;
                default :
                    beep();
            }
        }
    }
    unmarkchar(curpos,1);

    closegraph();
    if (argc==3) {
        printf("unsigned char G_font[]={\n");
        for (k=0;k<256;k++) {
            printf("    ");
            for (l=0;l<16;l++) {
                printf("0x%02X",G_font[k*16+l+32]);
                if (l<15) printf(",");
            }
            if (k<255) printf(", // %d\n",k); else printf("// %d\n",k);
        }
        printf("};\n\n");
    }
    return(1);
}

