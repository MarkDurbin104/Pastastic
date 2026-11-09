#include <stdio.h>
#include <dos.h>
#include <stdarg.h>
#include <alloc.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include <mem.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

#include "mouse.h"
#include "keydef.h"
#include "keynames.h"
#include "scancode.h"

#define KEYBH 10
#define KEYBW 40
#define MAPSIZE 1280
#define CAPS_A     0x01
#define NUML_A     0x02
#define EXTENDED_A 0x04

#define FONTSIZE (32+14*256+16*256)
#define NUMODD   10
int G_oddkey[NUMODD]={ 0,DOUB0,TREB0,KLSFT,KRSFT,KCTRL,KALT,KNUML,KCAPL,KSCRL};
typedef struct {
    unsigned char st;
    unsigned char x;
    unsigned char y;
    unsigned char fc;
    unsigned char bc;
    int           e;   // 1=EXTENDED 0=NORMAL
    int           res;
    int           sc;
} KEY;

typedef struct {
    unsigned char fc;
    unsigned char bc;
    KEY           k[KEYBH][KEYBW];
} KEYB;

         KEYB G_keys;
         int  *G_scanmap=NULL;
         int  G_state=0;
         int  G_fontin=0;
         int  G_xmul=13;
         int  G_ymul=26;
         int  G_xofs=20;
         int  G_yofs=40;
         int  G_maxx=0;
         int  G_maxy=0;
		 int  G_fby=0;
unsigned int  G_selkey=0xFFFF;
unsigned char G_font[FONTSIZE];
unsigned char G_addinfo[256];
unsigned char G_cmap[768];


#define ENDOFBUF     0x100

void interrupt (*oldkeyb)();

volatile unsigned char  G_shiftstat=0;
volatile int            G_extnext=0;
volatile int            G_keybuf[ENDOFBUF+1];
volatile int            G_kpstart=0;
volatile int            G_kpend=0;

void bufferkey(int k)
{
    G_keybuf[G_kpend++]=k;
    if (G_kpend>ENDOFBUF) G_kpend=0;
}
void interrupt mykeyb(void)
{
    unsigned char stat;
    int kpress,mappos;
    int k;
    int shift,ctrl,alt,numl,capsl;

    disable();

    k=inp(0x60);
    kpress=scanmap[((k&0x7F)*5)+0];
    if (k&0x80) {       // release code
        switch (kpress) {
            case KLSFT  :
                G_shiftstat&=~(LSHIFT);
                break;
            case KRSFT  :
                G_shiftstat&=~(RSHIFT);
                break;
            case KCTRL    :
                G_shiftstat&=~(CTRL);
                break;
            case KALT     :
                G_shiftstat&=~(ALT);
                break;
        }
    }
    else {                  // press code
        switch (kpress) {
            case KLSFT  :
                G_shiftstat|=LSHIFT;
                break;
            case KRSFT  :
                G_shiftstat|=RSHIFT;
                break;
            case KCTRL    :
                G_shiftstat|=CTRL;
                break;
            case KALT     :
                G_shiftstat|=ALT;
                break;
            case KCAPL   :
                G_shiftstat^=CAPSL;
                break;
            case KNUML    :
                G_shiftstat^=NUML;
                break;
            case KSCRL :
                G_shiftstat^=SCROLLL;
                bufferkey(-254);
                break;
            default :
                if (kpress==INS) G_shiftstat^=INSL;
                mappos=0;
                if (!G_extnext) {
                    if ((G_shiftstat&(LSHIFT|RSHIFT))!=0) mappos=1;
                    if (  ((scanmap[(k*5)+4]==1)&&((G_shiftstat&CAPSL)!=0))
                      ||  ((scanmap[(k*5)+4]==2)&&((G_shiftstat&NUML )!=0)))
                        mappos^=1;
                }
                if ((G_shiftstat&CTRL)!=0) mappos=2;
                if ((G_shiftstat&ALT)!=0)  mappos=3;
                kpress=scanmap[(k*5)+mappos];
                if (kpress!=(-1)) bufferkey(kpress);
        }
    }
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);
    G_extnext=(k==EXTENDED);
    enable();
}
int keyhit(void)
{
    return((G_kpstart!=G_kpend));
}
int getkey(void)
{
    int k;

    while (G_kpstart==G_kpend);  // wait for key press

    k=G_keybuf[G_kpstart++];

    if (G_kpstart>ENDOFBUF) G_kpstart=0;

    return(k);
}
void setkb(int onoff)
{
    if (onoff) {
        oldkeyb=getvect(0x09);
        setvect(0x09,mykeyb);
    } else {
        setvect(0x09,oldkeyb);
    }
}
void setpol(void)
{
    int i;
    for (i=0;i<128;i++) {
        if (G_scanmap[i*5]=='z') { G_scanmap[i*5+2]=190; G_scanmap[i*5+3]=189; }
        if (G_scanmap[i*5]=='l') { G_scanmap[i*5+2]=136; G_scanmap[i*5+3]=157; }
        if (G_scanmap[i*5]=='a') { G_scanmap[i*5+2]=165; G_scanmap[i*5+3]=164; }
        if (G_scanmap[i*5]=='c') { G_scanmap[i*5+2]=134; G_scanmap[i*5+3]=143; }
        if (G_scanmap[i*5]=='e') { G_scanmap[i*5+2]=169; G_scanmap[i*5+3]=168; }
        if (G_scanmap[i*5]=='s') { G_scanmap[i*5+2]=152; G_scanmap[i*5+3]=151; }
        if (G_scanmap[i*5]=='o') { G_scanmap[i*5+2]=162; G_scanmap[i*5+3]=224; }
        if (G_scanmap[i*5]=='n') { G_scanmap[i*5+2]=228; G_scanmap[i*5+3]=227; }
        if (G_scanmap[i*5]=='x') { G_scanmap[i*5+2]=171; G_scanmap[i*5+3]=141; }
    }
}
int findshifts(int k)
{
    int i;
    for (i=0;i<12;i++) if (G_scanmap[640+i*2]==k) return(G_scanmap[640+i*2+1]);
    return(k);
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
    return(1);
}
int readkeys(char *style,char *def)
{
    int fd;
    fd=open(style,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(-1);
    if (read(fd,&G_keys,sizeof(G_keys))!=sizeof(G_keys)) {
        close(fd);
        return(-2);
    }
    close(fd);

    fd=open(def,O_RDONLY|O_BINARY);
    if (G_scanmap!=NULL) free(G_scanmap);
    G_scanmap=malloc(MAPSIZE);
    if (G_scanmap!=NULL) {
        if (read(fd,G_scanmap,MAPSIZE)<MAPSIZE) {
            memcpy(G_scanmap,scanmap,MAPSIZE);
        }
    }
    close(fd);
    return(0);
}
int savekb(char *def)
{
    int fd;

    if (G_scanmap==NULL) return(0);
    fd=open(def,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
    if (fd==(-1)) return(0);
    write(fd,G_scanmap,MAPSIZE);
    close(fd);
    return(1);
}
void keytop(int st,int x,int y,int fc,int bc)
{
    int wid,hgt;
    int draw=0;

    x*=G_xmul;
    y*=G_ymul;
    x+=G_xofs;
    y+=G_yofs;

    setcolor(fc);
    setfillstyle(1,bc);
    switch (st) {
        case 1 :
            wid=G_xmul*2;
            hgt=G_ymul;
            draw=1;
            break;
        case 2 :
            wid=G_xmul*3;
            hgt=G_ymul;
            draw=1;
            break;
        case 3 :
            wid=G_xmul*4;
            hgt=G_ymul;
            draw=1;
            break;
        case 4 :
            wid=G_xmul*5;
            hgt=G_ymul;
            draw=1;
            break;
        case 5 :
            wid=G_xmul*14;
            hgt=G_ymul;
            draw=1;
            break;
        case 6 :
            wid=G_xmul*2;
            hgt=G_ymul*2;
            draw=1;
            break;
        case 7 :
            wid=G_xmul*3;
            hgt=G_ymul*2;
            bar(x,y,x+wid-1,y+G_ymul);
            bar(x+G_xmul,y+G_ymul,x+wid-1,y+hgt-1);
            moveto(x,y);
            lineto(x+wid-1,y);
            lineto(x+wid-1,y+hgt-1);
            lineto(x+G_xmul,y+hgt-1);
            lineto(x+G_xmul,y+hgt-G_ymul-1);
            lineto(x,y+hgt-G_ymul-1);
            lineto(x,y);
            break;
        case 8:
            wid=G_xmul*4;
            hgt=G_ymul*2;
            draw=1;
            break;
        case 9:
            wid=G_xmul*6;
            hgt=G_ymul;
            draw=1;
            break;
        case 10 :
            wid=G_xmul*2;
            hgt=(G_ymul*3)/4;
			fillellipse(x+wid,y+hgt,wid,hgt);
			ellipse(x+wid,y+hgt,0,360,wid,hgt);
            break;
        case 11 :
            wid=G_xmul*4;
            hgt=(G_ymul*3)/4;
			fillellipse(x+wid,y+hgt,wid,hgt);
			ellipse(x+wid,y+hgt,0,360,wid,hgt);
            break;
    }
    if (draw) {
        bar(x,y,x+wid-1,y+hgt-1);
        rectangle(x,y,x+wid-1,y+hgt-1);
    }
}
char *keyname(int k)
{
    static char tmp[10];
    int i;

    if (k<33) {
        strcpy(tmp,G_keyname[k+176]);
    }
    else {
        tmp[0]=k;
        tmp[1]=0;
        if (k==127) strcpy(tmp,G_keyname[199]);
    }
    for (i=0;i<10;i++) if (tmp[i]==32) tmp[i]=0;
    if (!strcmp(tmp,"NONE")) tmp[0]=0;
    return(tmp);
}
void outbyte(unsigned char *s,int x,unsigned char c,int onoff)
{
	unsigned int b;
	b=((int)c)<<(8-x);
	b=((b>>8)|(b<<8));
	*((unsigned int *)s)&=~b;
	if (onoff) *((unsigned int *)s)^=b;
}
void putfcap(int x,int y,unsigned char b,int col)
{
	unsigned int j,k,i;
	unsigned char *scr,*s,*f;
	scr=(unsigned char *)0xA0000000L+(y*80)+(x>>3);
	x&=7;
	for (k=0;k<4;k++) {
		i=(((1<<k)&col)!=0);
		f=G_font+32+b*16;
		outpw(0x3C4,(0x100<<k)|2);
		outpw(0x3CE,(k<<8)    |4);
		s=scr;
		for (j=0;j<16;j++) {
			outbyte(s,x,*(f++),i);
		    s+=80;	
		}
	}
	j=getpixel(0,0); putpixel(0,0,j+1); putpixel(0,0,j);
}
void face(int st,int x,int y,int c,int n)
{
    char tmp[10];
    int i;
    int size=4;

    x*=G_xmul;
    y*=G_ymul;
    x+=G_xofs;
    y+=G_yofs;

    strcpy(tmp,keyname(n));

    switch(st) {
        case 1 :
        case 6 :
            x+=G_xmul;
            if (strlen(tmp)>4) size=3;
            break;
        case 2 :
        case 7 :
            x+=(G_xmul*3)/2;
            break;
        case 3 :
        case 8 :
            x+=(G_xmul*2);
            break;
        case 4 :
            x+=(G_xmul*5)/2;
            break;
        case 5 :
            x+=(G_xmul*7);
            break;
        case 9:
            x+=(G_xmul*3);
            break;
        case 10 :
            x+=G_xmul*2;
            y+=G_ymul/4;
            break;
        case 11 :
            x+=G_xmul*4;
            y+=G_ymul/4;
            break;
    }
	if (G_fontin&&(strlen(tmp)==1)) {
		putfcap(x-4,y+2,tmp[0],c);
	} else {
    	setcolor(c);
    	settextjustify(CENTER_TEXT,TOP_TEXT);
    	settextstyle(SMALL_FONT,0,size);
    	outtextxy(x,y,tmp);
	}
}
void drawkey(int i,int j,int s)
{
    static int st;
    KEY *kp;
    int fc,bc;

    kp=&G_keys.k[i][j];
    bc=kp->bc;
    fc=kp->fc;

    if (s<0) {
        if (s==(-1)) {
            bc=kp->fc;
            fc=kp->bc;
        }
    } else st=s;

    if (kp->st) {
        keytop(kp->st,kp->x,kp->y,fc,bc);
        face(kp->st,kp->x,kp->y,fc,G_scanmap[(kp->sc*5)+st]);
    }
}
int ktsize(int type,int wh)
{
	int wid=0,hgt=0;
    switch(type) {
        case 1 :
            wid=2;
            hgt=2;
            break;
        case 2 :
            wid=3;
            hgt=2;
            break;
        case 3 :
            wid=4;
            hgt=2;
            break;
        case 4 :
            wid=5;
            hgt=2;
            break;
        case 5 :
            wid=14;
            hgt=2;
            break;
        case 6 :
            wid=2;
            hgt=4;
            break;
        case 7 :
            wid=3;
            hgt=4;
            break;
        case 8:
            wid=4;
            hgt=4;
            break;
        case 9:
            wid=6;
            hgt=2;
            break;
        case 10 :
            wid=4;
            hgt=3;
            break;
        case 11 :
            wid=8;
            hgt=3;
            break;
    }
	if (wh) return(wid);
	return(hgt);
}
void drawkb(int state,int n)
{
    int xw=0,yw=0;
    int i,j;

    if (n) {
        for (i=0;i<KEYBH;i++) {
            for (j=0;j<KEYBW;j++) {
                xw=max(xw,G_keys.k[i][j].x+ktsize(G_keys.k[i][j].st,1));
                yw=max(yw,(G_keys.k[i][j].y*2)+ktsize(G_keys.k[i][j].st,0));
            }
        }
		yw/=2;
        G_xmul=G_maxx/(xw+2);
        G_ymul=G_maxy/(yw+2);
        if (G_xmul<G_ymul) {
            G_ymul=G_xmul*2;
            G_xofs=(G_maxx-(G_xmul*xw))/2;
            G_yofs=G_xofs*2;
        } else {
            G_xmul=G_ymul/2;
            G_xofs=(G_maxx-(G_xmul*xw))/2;
            G_yofs=G_ymul+1;
        }
		if ((G_xmul>13)||(G_ymul>26)) {
			G_xmul=13; G_ymul=26;
			G_yofs=40;
            G_xofs=(G_maxx-(G_xmul*xw))/2;
		}
        setcolor(G_keys.fc);
        setfillstyle(1,G_keys.bc);
        bar(G_xofs-G_xmul,G_yofs-G_ymul,G_xofs+G_xmul*(xw+1),G_yofs+G_ymul*(yw+1));
        rectangle(G_xofs-G_xmul,G_yofs-G_ymul,G_xofs+G_xmul*(xw+1),G_yofs+G_ymul*(yw+1));
    }
    for (i=0;i<KEYBH;i++) for (j=0;j<KEYBW;j++) drawkey(i,j,state);
}
unsigned int findkey(int x,int y)
{
    int i,j;
    KEY *kp;

    for (i=0;i<KEYBH;i++) {
        for (j=0;j<KEYBW;j++) {
            kp=&G_keys.k[i][j];
            switch (kp->st) {
                case 1 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 2 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 3 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 4 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+4))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 5 :
                    if ((x==(kp->x   ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 3))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 4))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 5))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 6))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 7))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 8))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 9))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+10))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+11))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+12))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+13))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 6 :
                    if ((x==(kp->x  ))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x  ))&&(y==(kp->y+1))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y+1))) return(i<<8|j);
                    break;
                case 7 :
                    if ((x==(kp->x  ))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y+1))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y+1))) return(i<<8|j);
                    break;
                case 8 :
                    if ((x==(kp->x  ))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y  ))) return(i<<8|j);
                    if ((x==(kp->x  ))&&(y==(kp->y+1))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y+1))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y+1))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y+1))) return(i<<8|j);
                    break;
                case 9 :
                    if ((x==(kp->x   ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 3))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 4))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+ 5))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 10 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y))) return(i<<8|j);
                    break;
                case 11 :
                    if ((x==(kp->x  ))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+1))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+2))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+3))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+4))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+5))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+6))&&(y==(kp->y))) return(i<<8|j);
                    if ((x==(kp->x+7))&&(y==(kp->y))) return(i<<8|j);
                    break;
            }
        }
    }
    return(0xFFFF);
}
void switchkey(unsigned int kv)
{
    if (G_selkey!=0xFFFF) drawkey(G_selkey>>8,G_selkey&0xFF,(-2));

    G_selkey=kv;

    if (G_selkey!=0xFFFF) drawkey(G_selkey>>8,G_selkey&0xFF,(-1));
}
void mcur(void)
{
    setwritemode(1);
    setcolor(15);
    line(G_msex-5,G_msey,G_msex+5,G_msey);
    line(G_msex,G_msey-5,G_msex,G_msey+5);
    setwritemode(0);
}
void gprintf(int x,int y,char *fmt, ... )
{
    unsigned char str[140];
    va_list ap;

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    outtextxy(x,y,str);
}
int signif(unsigned char c)
{
	int i;
	unsigned char *f=G_cmap;
	if (!c) return(1);
	for (i=0;i<768;i++) if ((*(f++)==c)&&(i%256!=c)) return(0);
	return(1);
}
void drawbg(char *s,char *n)
{
    int h,i;
    if (!grafix()) return;
    cleardevice();

    settextjustify(LEFT_TEXT,TOP_TEXT);
    settextstyle(0,0,0);
    i=textheight("8");
    setcolor(14);
    gprintf(0,480-(i*3),"G.P.A. Keyboard Device Designer");
    setcolor(12);
    gprintf(0,480-(i*2),"Copyright (c) Unisys Limited 1992");
    setcolor(9);
	gprintf(0,480-i,"Style %s  Overlay %s",s,n);
	i*=4;
	i+=8*18;
	i=480-i;
	if (G_fontin) {
		G_fby=i;
		for (h=0;h<256;h++) {
			putfcap(((h%32)*16)+64,(h/32)*18+i,h,14+signif(h));
		}
	}
}
char getscr(int x,int y,unsigned char *b)
{
    unsigned char *scr=(unsigned char *)0xA0000000L+(y<<6)+(y<<4)+(x>>3);
    unsigned char xmask,ymask;
    unsigned char buf[10];
    int i,j;
    for (i=0;i<10;i++) {
        buf[i]=0;
        for (j=0;j<4;j++) {
            outportb(0x3CE,4);
            outportb(0x3CF,j);
            outportb(0x3C4,2);
            outportb(0x3C5,1<<j);
            buf[i]|=(*scr);
        }
        scr+=80; 
    }
    ymask=0x80;
    for (i=0;i<20;i++) {
        xmask=0x80;
        for (j=0;j<8;j++) {
            if ((buf[i>>1]&xmask)) *(b+j*3)|=ymask;
            xmask>>=1;
        }
        ymask>>=1;
        if (!ymask) {
            ymask=0x80;
            b++;
        }
    }
    b-=2;
    for (i=0;i<24;i++) if (*(b++)) return(1);
    return(0);
}
void printscr(void)
{
    int i,j,k;
    unsigned char *buf,d,st,s;
    char cbuf[80];

    buf=malloc(1920);
    if (buf==NULL) { return; }

    fprintf(stdprn,"%c%c%c%c%c%c",27,'*',38,132,2);
    for (i=0;i<644;i++) { fputc(0,stdprn); fputc(0,stdprn); fputc(0x80,stdprn); }
    fprintf(stdprn,"%cJ%c\r",27,20);

    for (i=0;i<48;i++) {
        fprintf(stdprn,"%c%c%c%c%c%c%c%c%c%c%c",27,'*',38,2,0,255,255,255,0,0,0);
        d=0;
        memset(buf,0,1920);
        memset(cbuf,0,80);
        for (j=0;j<80;j++) {
            if ((cbuf[j]=getscr(j*8,i*10,buf+j*24))!=0) d=1;
        }
        if (d) {
            st=cbuf[0];
            s=0;
            for (j=0;j<80;j++) {
                if (st!=cbuf[j]) {
                    if (st) {
                        fprintf(stdprn,"%c%c%c%c%c",27,'*',38,(((j-s)*8)%256),(((j-s)*8)/256));
                        for (k=(s*24);k<(j*24);k++) fputc(buf[k],stdprn);
                    } else {
                        fprintf(stdprn,"%c%c%c%c",27,92,(((j-s)*16)%256),(((j-s)*16)/256));
                    }
                    st=cbuf[j];
                    s=j;
                }
            }
            if (st) {
                fprintf(stdprn,"%c%c%c%c%c",27,'*',38,(((j-s)*8)%256),(((j-s)*8)/256));
                for (k=(s*24);k<(j*24);k++) fputc(buf[k],stdprn);
            } else {
                fprintf(stdprn,"%c%c%c%c",27,92,(((j-s)*16)%256),(((j-s)*16)/256));
            }
        } else {
            fprintf(stdprn,"%c%c%c%c",27,92,0,5);
        }
        fprintf(stdprn,"%c%c%c%c%c%c%c%c%c%c%c%cJ%c\r",27,'*',38,2,0,0,0,0,255,255,255,27,20);
        if (keyhit()) break;
    }
    if (!keyhit()) {
        fprintf(stdprn,"%c%c%c%c%c%c",27,'*',38,132,2);
        for (i=0;i<644;i++) { fputc(0x01,stdprn); fputc(0,stdprn); fputc(0,stdprn); }
        fprintf(stdprn,"%cJ%c\r",27,20);
    }
    fprintf(stdprn,"%c",12);
    free(buf);
}
void mainloop(char *name)
{
    int xit=0;
    int l=0;
    int i,j,k;
    int oddnum=0;

    drawkb(0,1);
    mcur();
    while (!xit) {
        if (keyhit()) {
            oddnum=0;
            mcur();
            k=getkey();
            if (G_selkey!=0xFFFF) {
                G_scanmap[(G_keys.k[G_selkey>>8][G_selkey&0xFF].sc*5)+l]=k;
                drawkey(G_selkey>>8,G_selkey&0xFF,(-1));
            }
            else {
                switch (k) {
                    case F01 :
                        if ((++l)==4) l=0;
                        drawkb(l,0);
                        break;
                    case F02 :
                        for (i=0;i<KEYBH;i++)
                            for (j=0;j<KEYBW;j++)
                                if (G_scanmap[(G_keys.k[i][j].sc*5)+4]==1)
                                    drawkey(i,j,(-1));
                                else
                                    drawkey(i,j,(-2));
                        break;
                    case F03 :
                        for (i=0;i<KEYBH;i++)
                            for (j=0;j<KEYBW;j++)
                                if (G_scanmap[(G_keys.k[i][j].sc*5)+4]==2)
                                    drawkey(i,j,(-1));
                                else
                                    drawkey(i,j,(-2));

                        break;
                    case F08 :
						printscr();
                    case F09 :
                        savekb(name);
                    case F10 :
                        xit=1;
                        break;
                }
            }
            mcur();
        }
        if (mousestat(2)) {
            mcur();
            mousetrap(2);
            if (G_mseb==1) {
                oddnum=0;
                if ((G_selkey!=0xFFFF)&&(G_fontin)&&mousein(64,G_fby,64+32*16,G_fby+18*8)) {
	                G_scanmap[(G_keys.k[G_selkey>>8][G_selkey&0xFF].sc*5)+l]=
						((G_msex-64)/16)+(((G_msey-G_fby)/18)*32);
	                drawkey(G_selkey>>8,G_selkey&0xFF,(-1));
				} else {
                	switchkey(findkey((G_msex-G_xofs)/G_xmul,(G_msey-G_yofs)/G_ymul));
				}
            }
            if (G_mseb==2) {
				if (G_selkey!=0xFFFF) {
	                G_scanmap[(G_keys.k[G_selkey>>8][G_selkey&0xFF].sc*5)+l]=G_oddkey[oddnum];
	                drawkey(G_selkey>>8,G_selkey&0xFF,(-1));
	                if (++oddnum==NUMODD) oddnum=0;
				}
            }
            mcur();
        }
    }
}
void prktab(void)
{
    int i,j,k;
    KEY *kp;

    printf("X  Y    SCAN  NORM  SHFT  CTRL  ALT  LOCK\n\n");
    for (i=0;i<KEYBH;i++) {
        for (j=0;j<KEYBW;j++) {
            kp=&G_keys.k[i][j];
            if (kp->sc) {
                printf("%02d %02d - [%02X]  ",j,i,kp->sc);
                for (k=0;k<4;k++) {
                    printf("%-5.5s ",keyname(G_scanmap[(kp->sc*5)+k]));
                }
                if (G_scanmap[(kp->sc*5)+4]) {
                    if (G_scanmap[(kp->sc*5)+4]==1) {
                        printf("CAPS");
                    } else {
                        printf("NUM");
                    }
                }
                printf("\n");
            }
        }
    }
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
	G_fontin=1;
    return(1);
}
int main(int argc,char *argv[])
{
    if (argc<3) {
        printf("KD stylefile keyfile [fontfile] [report]\n");
        return(1);
    }
    switch(readkeys(argv[1],argv[2])) {
        case 0 :
            if (argc==5) {
				prktab();
            } else {
	            if (argc>3) readfont(argv[3]);
                drawbg(argv[1],argv[2]);
                if (!setupmouse(319,239,0,632,0,479,0)) {
                    closegraph();
                    printf("No Mouse Connected\n");
                    return(1);
                }
                setkb(1);
                mainloop(argv[2]);
                setkb(0);
                closegraph();
            }
            break;
        case (-1) :
            printf("Can't open %s\n",argv[1]);
            break;
        case (-2) :
            printf("Can't read %s\n",argv[1]);
            break;
        case (-3) :
            printf("Can't open %s\n",argv[2]);
            break;
    }
//	printf("G_xmul %d  G_ymul %d  G_xofs %d  G_yofs %d\n",G_xmul,G_ymul,G_xofs,G_yofs);
    return(0);
}


