#define VGADEV_C
//___________________________________________________________________________

#include <graphics.h>
#include <stdio.h>
#include <alloc.h>
#include <string.h>
#include <stdarg.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include "types.h"
#include "control.h"
#include "vgadev.h"
#include "config.h"

//int G_fastv=0;
int G_entry=1;
unsigned char G_ln[2560];
unsigned int G_wmap[4]={0x0004,0x0104,0x0204,0x0304};
unsigned int G_rmap[4]={0x0102,0x0202,0x0402,0x0802};

unsigned char G_palette[17]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
                             0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,1};
int G_lights=0;
unsigned long slights[7][2];
unsigned char G_smaps[5][7]={
    {0x1C,0x63,0x63,0x7F,0x63,0x63,0x63}, // 'A'
    {0x63,0x73,0x7B,0x7F,0x6F,0x67,0x63}, // 'N'
    {0x3E,0x63,0x60,0x60,0x60,0x63,0x3E}, // 'C'
    {0x3E,0x60,0x60,0x3E,0x03,0x03,0x3E}, // 'S'
    {0x7E,0x18,0x18,0x18,0x18,0x18,0x7E}  // 'I'
};
unsigned char spos[8]={4,3,1,2,0,2,3,3};

unsigned int G_lchar[40];
unsigned int G_ochar[40];

// draw the unisys logo on the screen
void drawlogo(int x,int y,int col)
{
	int i,j,k;
	unsigned char *s,*t=(unsigned char *)0xA0000000L; 
    y*=19;
    for (k=0;k<38;k++) {  
        for (j=0;j<17;j++) {  
	        for (i=0;i<4;i++) {
		        outportb(0x3CE,4);
		        outportb(0x3CF,i);
		        outportb(0x3C4,2);
		        outportb(0x3C5,1<<i);
  	            s=t+x+j+((y+k)*80);
		        if (col&(1<<i)) *s=G_logo[k][j]; else *s=0;
	        }
        }
    }
	i=getpixel(0,0); putpixel(0,0,col); putpixel(0,0,i);
}
// set the shift status lights 
void setlights(void)
{
	unsigned long *t=(unsigned long *)0xA0000000L;
    int i,j;

    for (j=0;j<7;j++) {
        slights[j][0]=0L;
        slights[j][1]=0L;
    }

    for (i=0;i<4;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][0]|=(((long)G_smaps[spos[i]][j])<<((3-i)*8));
            }
        }
    }
    for (i=4;i<8;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][1]|=(((long)G_smaps[spos[i]][j])<<((7-i)*8));
            }
        }
    }
    t+=(471*20)+17;
    for (i=0;i<4;i++) {
		outportb(0x3CE,4);
		outportb(0x3CF,i);
		outportb(0x3C4,2);
		outportb(0x3C5,1<<i);
        for (j=0;j<7;j++) {
      		*(t++)=(slights[j][0]*(i==2));
      		*t=(slights[j][1]*(i==2));
            t+=19;
        }
        t-=140;
    }
	i=getpixel(0,0); putpixel(0,0,15); putpixel(0,0,i);
}
// expand a byte to a word for bitmap output
unsigned int dublit(unsigned char c)
{
    unsigned int  res=0;
    unsigned char sm=0x80;
    unsigned int  lm=0xC000;
    int i;

    while (sm) {
        if (c&sm) res|=lm;
        sm>>=1;
        lm>>=2;
    }

    return(res);
}
// get the font details
void getfont(void)
{
    struct REGPACK r;
    r.r_ax=0x1130;
    r.r_bx=0x0600;
    intr(0x10,&r);
    G_font=(unsigned char *)MK_FP(r.r_es,r.r_bp);
}
// swap two bytes in a word
unsigned int swapbytes(unsigned int i)
{
    asm mov  ax,i
    asm xchg ah,al
    asm mov  i,ax
    return(i);
}
// double a char and add filling bits for diagonal edges
unsigned int *doubchar(unsigned char *pc,int l)
{
    unsigned char *p,a,b,c;
    int i,j;

    p=pc;
    G_ochar[0]=0;
    for (i=0;i<l;i++) {
        G_lchar[(i<<1)]=G_lchar[(i<<1)+1]=dublit(*p);
        G_ochar[i+1]=((unsigned int)*(p++))<<1;
    }
    G_ochar[i+1]=0;
    
    for (j=0;j<8;j++) {
        for (i=0;i<l;i++) {
            b=G_ochar[i  ]&7;
            a=G_ochar[i+1]&7;
            c=G_ochar[i+2]&7;
            if (a==1) {
                if (((b==0)||(b==4))&&((c==3)||(c==2)||(c==7)))
                    G_lchar[(i<<1)+1]|=(1<<(j<<1));
                if (((c==0)||(c==4))&&((b==3)||(b==2)||(b==7)))
                    G_lchar[(i<<1)  ]|=(1<<(j<<1));
            } else if (a==4) {
                if (((c==0)||(c==1))&&((b==6)||(b==2)||(b==7)))
                    G_lchar[(i<<1)  ]|=(2<<(j<<1));
                if (((b==0)||(b==1))&&((c==6)||(c==2)||(c==7)))
                    G_lchar[(i<<1)+1]|=(2<<(j<<1));
            }
            G_ochar[i]>>=1;
        }
        G_ochar[i]>>=1;
    }
    return(G_lchar);
}
// copy character from font to buffer
void copychar(char *fp,char *lp,int wid,int s)
{
    int i;
    unsigned int *dc;
    if (fp==NULL) {
        switch (s) {
            case 0 :
                for (i=0;i<G_fonthigh;i++) {
                    *lp=0;
                    lp+=wid;
                }
                break;
            case 1 :
                for (i=0;i<G_fonthigh;i++) {
                    *lp=0xFF;
                    lp+=wid;
                }
                break;
            case 2 :
                for (i=0;i<G_fonthigh;i++) {
                    *((unsigned int *)lp)=0;
                    lp+=wid;
                }
                break;
            case 3 :
                for (i=0;i<G_fonthigh;i++) {
                    *((unsigned int *)lp)=0xFFFF;
                    lp+=wid;
                }
                break;
            case 4 :
                for (i=0;i<(G_fonthigh<<1);i++) {
                    *((unsigned int *)lp)=0;
                    lp+=wid;
                }
                break;
            case 5 :
                for (i=0;i<(G_fonthigh<<1);i++) {
                    *((unsigned int *)lp)=0xFFFF;
                    lp+=wid;
                }
                break;
        }
    }
    else {
        switch (s) {
            case 0 :
                for (i=0;i<G_fonthigh;i++) {
                    *lp=*(fp++);
                    lp+=wid;
                }
                break;
            case 1 :
                for (i=0;i<G_fonthigh;i++) {
                    *lp=~(*(fp++));
                    lp+=wid;
                }
                break;
            case 2 :
                for (i=0;i<G_fonthigh;i++) {
                    *((unsigned int *)lp)=swapbytes(dublit(*(fp++)));
                    lp+=wid;
                }
                break;
            case 3 :
                for (i=0;i<G_fonthigh;i++) {
                    *((unsigned int *)lp)=~swapbytes(dublit(*(fp++)));
                    lp+=wid;
                }
                break;
            case 4 :
                dc=doubchar((unsigned char *)fp,G_fonthigh);
                for (i=0;i<(G_fonthigh<<1);i++) {
                    *((unsigned int *)lp)=swapbytes(*(dc++));
                    lp+=wid;
                }
                break;
            case 5 :
                dc=doubchar((unsigned char *)fp,G_fonthigh);
                for (i=0;i<(G_fonthigh<<1);i++) {
                    *((unsigned int *)lp)=~swapbytes(*(dc++));
                    lp+=wid;
                }
                break;
        }
    }
}
// VGA line output routine
void voutln(int x,int y,char *fmt,...)
{
	int i,j,k,l,sm,fh=G_fonthigh,wid,flip;
	unsigned char *t=(unsigned char *)0xA0000000L; 
    unsigned char *s,*sa[40];
    int cpos,cwid;
    int col,fo;
    unsigned char str[140];
    va_list ap;

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    cwid=(G_screen.size>1)+1;
    wid=strlen(str)*cwid;

    if ((x+wid)>G_maxx) return;
    if ((x>=G_maxx)||(y>=G_maxy)||(x<0)||(y<0)) return;

    col=G_screen.attr&0x0F;
    fo=((G_font==G_fontspace)*32);
    s=str;
    i=0;

    if ((G_screen.attr&0x77)==0x22) {
        memset(G_ln,0xFF,fh*wid);
        flip=((G_screen.size-1)<<1)+1;
    } else {
        flip=(G_screen.size-1)<<1;
    }

    while (*s) {
        if (*s==' ') 
            copychar(NULL,&G_ln[i],wid,flip);
        else
            copychar(&G_font[(*s)*fh+fo],&G_ln[i],wid,flip);
        i+=cwid;
        s++;
    }
    y*=G_linespace;
    y+=2;

  	s=t+x+(y*G_maxx);

    for (j=0;j<(fh<<1);j++) { sa[j]=s; s+=G_maxx; }

    if (G_screen.xor) {
        switch (G_screen.size) {
            case 1 :
            case 2 :
        	    for (i=0;i<4;i++) {                      
                    outpw(0x3CE,G_wmap[i]);
                    outpw(0x3C4,G_rmap[i]);
		            if ((col&(1<<i))!=0) {
                        l=0;
        	            for (j=0;j<fh;j++) {
                            for (k=0;k<wid;k++) {
                                *(sa[j]+k)^=G_ln[l++];
                            }
                        }
        		    } else {
      			        for (j=0;j<fh;j++) memset(sa[j],0,wid);
                    }
                }
                break;
            case 3 :
        	    for (i=0;i<4;i++) {
                    outpw(0x3CE,G_wmap[i]);
                    outpw(0x3C4,G_rmap[i]);
		            if ((col&(1<<i))!=0) {
                        l=0;
        			    for (j=0;j<fh<<1;j+=2) {
                            for (k=0;k<wid;k++) {
                                *(sa[j  ]+k)^=G_ln[l];
                                *(sa[j+1]+k)^=G_ln[l++];
                            }
                        }
        		    } else {
      			        for (j=0;j<fh<<1;j++) memset(sa[j],0,wid);
                    }
                }
                break;
	    }
    } else {
        switch (G_screen.size) {
            case 1 :
            case 2 :
        	    for (i=0;i<4;i++) {                      
                    outpw(0x3CE,G_wmap[i]);
                    outpw(0x3C4,G_rmap[i]);
		            if ((col&(1<<i))!=0) {
        			    for (k=0,j=0;j<fh;j++,k+=wid) {
                            memcpy(sa[j],&G_ln[k],wid);
                        }
        		    } else {
      			        for (j=0;j<fh;j++) memset(sa[j],0,wid);
                    }
                }
                break;
            case 3 :
        	    for (i=0;i<4;i++) {
                    outpw(0x3CE,G_wmap[i]);
                    outpw(0x3C4,G_rmap[i]);
		            if ((col&(1<<i))!=0) {
        			    for (k=0,j=0;j<fh<<1;j++,k+=wid) {
                            memcpy(sa[j],&G_ln[k],wid);
                        }
        		    } else {
      			        for (j=0;j<fh<<1;j++) memset(sa[j],0,wid);
                    }
                }
                break;
	    }
    }
}
#pragma warn -pro
// draw a box on the screen
void dbox(int x,int y,int x1,int y1)
{
//    FPTR f=(FPTR)(G_font);
    int xs,xe,ys,ye;

    setcolor(8); //7+f());

    xs=x *G_fontwide +(G_fontwide >>1);
    ys=y *G_linespace+(G_linespace>>1);
    xe=x1*G_fontwide +(G_fontwide >>1);
    ye=y1*G_linespace+(G_linespace>>1);

    moveto(xs,ye);
    setcolor(15);
    lineto(xs,ys); lineto(xe,ys);
    setcolor(8);
    lineto(xe,ye); lineto(xs,ye);
    xs--; ys--; xe++; ye++;
    moveto(xs,ye);
    setcolor(15);
    lineto(xs,ys); lineto(xe,ys);
    setcolor(8);
    lineto(xe,ye); lineto(xs,ye);
}
#pragma warn +pro
// draw a line on the screen
void dline(int x,int y,int x1,int y1)
{
    setcolor(8);
    line(x*G_fontwide+(G_fontwide/2),
            y*G_linespace+(G_linespace/2),
            x1*G_fontwide+(G_fontwide/2),
            y1*G_linespace+(G_linespace/2));

    setcolor(15);
    line(x*G_fontwide+(G_fontwide/2)+1,
            y*G_linespace+(G_linespace/2)+1,
            x1*G_fontwide+(G_fontwide/2)+1,
            y1*G_linespace+(G_linespace/2)+1);
}
//___________________________________________________________________________
// draw a cursor of length 'num' on the screen
void cursor(int x,int y,int num)
{
    int tx=G_screen.xor,ta=G_screen.attr;
    int ts=G_screen.size;
    G_screen.attr=0x22;
    G_screen.xor=1;
    G_screen.size=1;
    voutln(x,y,"%*.*s",num,num,"");
    G_screen.size=ts;
    G_screen.xor=tx;
    G_screen.attr=ta;
}
// sink a field on the screen
void sink(int x,int y,int len)
{
    int xs,xe,ys,ye;

    xs=x*G_fontwide-1;
    ys=y*G_linespace+1;
    xe=xs+G_fontwide*len+2;
    ye=ys+G_linespace-2;

    moveto(xs,ye);
    setcolor(8);
    lineto(xs,ys);
    lineto(xe,ys);
    setcolor(15);
    lineto(xe,ye);
    lineto(xs,ye);
}
// raise a field on the screen
void raise(int x,int y,int len)
{
    int xs,xe,ys,ye;

    xs=x*G_fontwide-1;
    ys=y*G_linespace+1;
    xe=xs+G_fontwide*len+2;
    ye=ys+G_linespace-2;

    moveto(xs,ye);
    setcolor(15);
    lineto(xs,ys);
    lineto(xe,ys);
    setcolor(8);
    lineto(xe,ye);
    lineto(xs,ye);
}
// screen reset routine
int scr_reset(void)
{
    struct REGPACK r;

    if (G_entry) {
        r.r_ax=0x1001;
        r.r_bx=0x0700;
        intr(0x10,&r);
        setpalette(0,7);
        setpalette(2,0);
    }
    G_entry=0;
    putpixel(0,0,1);
    cleardevice();
    return(1);
} 
// screen shutdown routine
int scr_shutdown(void)
{
    struct REGPACK r;
    r.r_ax=0x1001;
    r.r_bx=0x0000;
    intr(0x10,&r);
    closegraph();
    G_maxx=0;
    return(1);                 
}
// screen startup routine
int scr_startup(void)
{
    int gd;
	int gm;
    int err;

    G_entry=1;
    G_screen.size=1;
    G_screen.xor=0;

    G_screen.attr=0x07;
    gd = VGA;
    gm = VGAHI;
    err=registerfarbgidriver(EGAVGA_driver_far);
    G_linespace=19;
    G_fonthigh=16;
    G_fontwide=8;
	if (err<0) {
		return(0);
	}
    initgraph(&gd,&gm,"");
    err=graphresult();
	if (err<0) return(0);
    if ((G_font=loadfont(G_fontfile))==NULL) {
        sound(2500);
        delay(500);
        nosound();
        getfont();
    }
    else { // Adjust font for VGA LOW RES
        if (err!=grOk) G_font[16]=255;
    }
    G_maxx=80;
    G_maxy=25;
    return(1);
}
// read the font information into memory
char *loadfont(char *fontfile)
{
    int fd;
    fd=open(fontfile,O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        return(NULL);
    }
    if (G_fontspace!=NULL) FREE(G_fontspace);
    G_fontspace=MALLOC(FONTSIZE);
    if (G_fontspace!=NULL) {
		memset(G_fontspace,0,FONTSIZE);
        read(fd,G_fontspace,FONTSIZE);
    }
    close(fd);
    return(G_fontspace);
}
// screen control routine
int scr_control(int type,va_list ap)
{
    char tmp[160],*f;
    int x,y,x1,y1,onoff,num;
    int retval=0;

 	if ((G_maxx==0)&&(type!='I')) return(1);

    switch (type) {
		case 'i' :
			retval=(int)G_screen.size;
			break;
		case 'o' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
		    voutln(x,y,"%s",tmp);
		    setlights();
			retval=1;
			break;
		case 'R' :
			retval=scr_reset();
			break;
        case 'A' :
            G_screen.attr=G_hattr[va_arg(ap,int)&0xFF];
            break;

        case 'C' :
            x=va_arg(ap,int);
			x+=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
            cursor(x,y,num);
            break;

        case 'B' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            x1=va_arg(ap,int);
            y1=va_arg(ap,int);
            dbox(x,y,x1,y1);
            break;

        case 'L' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            x1=va_arg(ap,int);
            y1=va_arg(ap,int);
            dline(x,y,x1,y1);
            break;

        case 'X' :
            G_screen.xor=va_arg(ap,int)&0xFF;
            break;

        case 'S' :
            G_screen.size=(va_arg(ap,int)%4);
            if (G_screen.size<1) G_screen.size=1;
            break;

        case 'l' :
            G_lights=va_arg(ap,int)&0xFF;
            break;

        case 'I' :
            scr_startup();
            break;

        case 'E' :
            scr_shutdown();
            break;

        case 'D' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            drawlogo(x,y,4);
            break;

        case 's' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
            sink(x,y,num);
            break;

        case 'r' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
            raise(x,y,num);
            break;
        case 'p' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
			retval=x+y;
			break;
        case 'F' :
            f=va_arg(ap,char *);
			G_font=loadfont(f);
			retval=1;
			break;
    }
    return(retval);
}
//___________________________________________________________________________

