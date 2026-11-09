#define VFONDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <stdarg.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include "types.h"
#include "gprim.h"
#include "control.h"
#include "config.h"
#include "message.h"
#include "keydef.h"

#pragma option -p-
#include "vfondev.h"

#define CMAPOFS (32+(16*256)+(14*256))

#define DCARE	0x01
#define NREFL	0x02
#define SREFL	0x04
#define DREFL	0x08
#define DDREFL	0x10
#define DNREFL	0x20
#define DCNOMV	0x40




UCHAR    *G_contspace=NULL;
INT 			  G_vgahand=(-1);
INT 			  G_vlsp=19;
INT               G_vfontwide=8;
INT               G_vfonthigh=16;
UCHAR huge   *G_vfontspace=NULL;
INT               G_vfontaw=8;
INT               G_vfontah=16;
INT		          G_backoneng=0;
INT				  G_onoff=1;

INT G_entry=1;
INT G_newscr=0;
UCHAR G_palette[17]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
                             0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,1};
INT G_lights=0;
ULONG slights[7][2];
UCHAR G_smaps[5][7]={
    {0x1C,0x63,0x63,0x7F,0x63,0x63,0x63}, // 'A'
    {0x63,0x73,0x7B,0x7F,0x6F,0x67,0x63}, // 'N'
    {0x3E,0x63,0x60,0x60,0x60,0x63,0x3E}, // 'C'
    {0x3E,0x60,0x60,0x3E,0x03,0x03,0x3E}, // 'S'
    {0x7E,0x18,0x18,0x18,0x18,0x18,0x7E}  // 'I'
};
UCHAR spos[8]={4,3,1,2,0,2,3,3};

// draw the unisys logo on the screen
void drawlogo(INT x,INT y,INT col)
{
	INT i,j,k;
	UCHAR *s,*t=(UCHAR *)COLVIDMEM;
	ENTRY(3870);
    y*=19;
	BITMASK(255); ESETRES(0); MAPMASK(15);
    for (k=0;k<38;k++) {  
        for (j=0;j<17;j++) {  
	        for (i=0;i<4;i++) {
		        OUTPB(0x3CE,4);
				  OUTPB(0x3CF,(CHAR)i);
		        OUTPB(0x3C4,2);
				  OUTPB(0x3C5,(CHAR)(1<<i));
  	            s=t+x+j+((y+k)*80);
		        if (col&(1<<i)) *s=G_logo[k][j]; else *s=0;
	        }
        }
    }
	BITMASK(255); ESETRES(0); MAPMASK(15);
//	setcol(0);
	setcol(G_screen.attr);
	RETURN;
}
// set the shift status lights 
void setlights(void)
{
	ULONG *t=(ULONG *)COLVIDMEM;
    INT i,j;
	ENTRY(3880);

    for (j=0;j<7;j++) {
        slights[j][0]=0L;
        slights[j][1]=0L;
    }

    for (i=0;i<4;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][0]|=(((LONG)G_smaps[spos[i]][j])<<((3-i)*8));
            }
        }
    }
    for (i=4;i<8;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][1]|=(((LONG)G_smaps[spos[i]][j])<<((7-i)*8));
            }
        }
    }
    t+=(471*20)+17;
	BITMASK(255); ESETRES(0); MAPMASK(15);
    for (i=0;i<4;i++) {
		OUTPB(0x3CE,4);
		OUTPB(0x3CF,(CHAR)i);
		OUTPB(0x3C4,2);
		OUTPB(0x3C5,(CHAR)(1<<i));
        for (j=0;j<7;j++) {
      		*(t++)=(slights[j][0]*(i==2));
      		*t=(slights[j][1]*(i==2));
            t+=19;
        }
        t-=140;
    }
	BITMASK(255); ESETRES(0); MAPMASK(15);
	setcol(0);
	setcol(G_screen.attr);
	RETURN;
}
// draw a box on the screen
void vfdbox(INT x,INT y,INT x1,INT y1)
{
    INT xs,xe,ys,ye;
	ENTRY(3890);

    setcol(8);

    xs=x *G_vfontwide +(G_vfontwide >>1);
    ys=y *G_vlsp+(G_vlsp>>1);
    xe=x1*G_vfontwide +(G_vfontwide >>1);
    ye=y1*G_vlsp+(G_vlsp>>1);

    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys); lineto(xe,ys);
    setcol(8);
    lineto(xe,ye); lineto(xs,ye);
    xs--; ys--; xe++; ye++;
    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys); lineto(xe,ys);
    setcol(8);
    lineto(xe,ye); lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
#pragma warn +pro
// draw a line on the screen
void vfdline(INT x,INT y,INT x1,INT y1)
{
	ENTRY(3900);
    setcol(8);
    line(x*G_vfontwide+(G_vfontwide/2),
            y*G_vlsp+(G_vlsp/2),
            x1*G_vfontwide+(G_vfontwide/2),
            y1*G_vlsp+(G_vlsp/2));

    setcol(15);
    line(x*G_vfontwide+(G_vfontwide/2)+1,
            y*G_vlsp+(G_vlsp/2)+1,
            x1*G_vfontwide+(G_vfontwide/2)+1,
            y1*G_vlsp+(G_vlsp/2)+1);
	setcol(G_screen.attr);
	RETURN;
}
//___________________________________________________________________________
// draw a cursor of length 'num' on the screen
void cursor(INT x,INT y,INT num)
{
	ENTRY(3910);
	setcol(2);
	setwmode(XOR_WM);
	bar(x,y,(x+num*(G_vfontaw-G_backoneng))-1,(y+G_vfontah)-1);
	setwmode(NORM_WM);
	setcol(G_screen.attr);
	RETURN;
}
// blank an area of length 'num' on the screen
void blank(INT x,INT y,INT num)
{
	ENTRY(3910);
	setcol(0);
	setwmode(XOR_WM);
	bar(x,y,x+(num*G_vfontaw),y+G_vfontah);
	setwmode(NORM_WM);
	setcol(G_screen.attr);
	RETURN;
}
// sink a field on the screen
void vfsink(INT x,INT y,INT len)
{
    INT xs,xe,ys,ye;
	ENTRY(3920);

    xs=x*G_vfontwide-1;
    ys=y*G_vlsp-1;
    xe=xs+(G_vfontaw-G_backoneng)*len+2;
    ye=ys+G_vfontah+2;

    moveto(xs,ye);
    setcol(8);
    lineto(xs,ys);
    lineto(xe,ys);
    setcol(15);
    lineto(xe,ye);
    lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
// raise a field on the screen
void vfraise(INT x,INT y,INT len)
{
    INT xs,xe,ys,ye;
	ENTRY(3930);

    xs=x*G_vfontwide-1;
    ys=y*G_vlsp-1;
    xe=xs+G_vfontwide*len+2;
    ye=ys+G_vfonthigh+2;

    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys);
    lineto(xe,ys);
    setcol(8);
    lineto(xe,ye);
    lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
// screen reset routine
INT scr_reset(void)
{
	IMAGE *img;
	ENTRY(3940);
    if (G_entry) {
        setborder(7);
    }
    G_entry=0;
	G_newscr=1;
	cls();
	if ((img=getbmp(G_wallpaper))!=NULL) {
		putimage(0,0,img);
		freeimg(img);
	}
    RETURNV(1);
} 
// read the font information into memory
CHAR huge *readfont(CHAR *fontfile)
{
	ENTRY(3960);
    if (G_vfontspace!=NULL) FREE(G_vfontspace);
	switch (fontfile[strlen(fontfile)-1]) {
        case '2' :
   	        G_vfontspace=loadlfont(fontfile,1);
            if (G_vfontspace==NULL) RETURNV(NULL);
		    if (!attachfont(G_vfontspace,201,16,16)) RETURNV(NULL);
		    G_vfontaw=16;
		    G_vfontah=16;
	        G_backoneng=0;
            break;
        case '3' :
   	        G_vfontspace=loadlfont(fontfile,2);
            if (G_vfontspace==NULL) RETURNV(NULL);
		    if (!attachfont(G_vfontspace,202,24,24)) RETURNV(NULL);
		    G_vfontaw=24;
		    G_vfontah=24;
		    G_backoneng=8;
            break;
        default  :
   	        G_vfontspace=loadffont(fontfile);
            if (G_vfontspace==NULL) RETURNV(NULL);
            if (!attachfont(G_vfontspace,1,16,8)) RETURNV(NULL);
	        G_vfontaw=8;
	        G_vfontah=16;
	        G_backoneng=0;
    }
    selectfont(G_screen.size-1);
    RETURNV((CHAR huge *)G_vfontspace);
}
// screen startup routine
INT scr_startup(void)
{
	IMAGE *img;
    int i;
	ENTRY(3970);

    G_entry=1;
	G_newscr=1;
    G_screen.size=1;
    G_screen.xor=0;

    G_screen.attr=G_hattr[1];
//    G_screen.attr=0x07;
    G_vlsp=19;
    G_vfonthigh=16;
    G_vfontwide=8;
    G_maxx=79;
    G_maxy=24;
	img=getbmp("GPASTART.BMP");
	G_vgahand=grafix(0);
	if (G_vgahand<0) RETURNV(0);
	usegdev(G_vgahand);
    for (i=0;i<8;i++) getrgbpalette(i,G_defpal+i*3,G_defpal+i*3+1,G_defpal+i*3+2);
    for (   ;i<16;i++) getrgbpalette(0x30+i,G_defpal+i*3,G_defpal+i*3+1,G_defpal+i*3+2);
	if (img!=NULL) {
        setrgbpalette(0x00,0x00,0x00,0x00);
        setrgbpalette(0x01,0x00,0x00,0x20);
        setrgbpalette(0x02,0x00,0x20,0x00);
        setrgbpalette(0x03,0x00,0x20,0x20);
        setrgbpalette(0x04,0x20,0x00,0x00);
        setrgbpalette(0x05,0x20,0x00,0x20);
        setrgbpalette(0x06,0x20,0x20,0x00);
        setrgbpalette(0x07,0x30,0x30,0x30);
        setrgbpalette(0x38,0x20,0x20,0x20);
        setrgbpalette(0x39,0x00,0x00,0x3F);
        setrgbpalette(0x3A,0x00,0x3F,0x00);
        setrgbpalette(0x3B,0x00,0x3F,0x3F);
        setrgbpalette(0x3C,0x3F,0x00,0x00);
        setrgbpalette(0x3D,0x3F,0x00,0x3F);
        setrgbpalette(0x3E,0x3F,0x3F,0x00);
        setrgbpalette(0x3F,0x3F,0x3F,0x3F);
		putimage(0,0,img);
        setpalette(2,0);
        setpalette(7,2);
        setpalette(0,7);
		freeimg(img);
	} else {
        setpalette(2,0);
        setpalette(7,2);
        setrgbpalette(0,57,51,38);
        setrgbpalette(7,57,51,38);
	}
    RETURNV(1);
}
// screen re-startup routine
INT scr_restartup(void)
{
	restart(G_vgahand);
    setpalette(2,0);
    setpalette(7,2);
    setpalette(0,7);
    RETURNV(1);
}
// screen shutdown routine
INT scr_shutdown(void)
{
	ENTRY(3950);
	if (G_contspace!=NULL) FREE(G_contspace);
    if (G_vfontspace!=NULL) FREE(G_vfontspace);
    setborder(0);
	closegraf();
    RETURNV(1);                 
}
// screen shutdown routine
INT scr_tmpshutdown(void)
{
    setborder(0);
	monomode();
    RETURNV(1);                 
}
INT isnew(void)
{
	ENTRY(3980);
	if (G_newscr) {
		G_newscr=0;
		RETURNV(1);
	}
	RETURNV(0);
}
// screen control routine
LONG vfscr_control(INT type,va_list ap)
{
	IMAGE *img,*img2;
    CHAR tmp[160],*f,*s,**ff;
    INT x,y,x1,y1,num,c;
    UCHAR *pal;
    LONG retval=1L;
	ENTRY(4120);

	if (G_vgahand>=0) usegdev(G_vgahand);
	if (!G_onoff) {
	    switch (type) {
	        case MESSAGE_E :
	        case MESSAGE_ON :
	        case MESSAGE_RI :
	        case MESSAGE_TE :
	        case MESSAGE_I :
				break;
			default :
				return(1L);
		}
	} 
    switch (type) {
		case MESSAGE_i :
			retval=(LONG)G_screen.size;
			break;
		case MESSAGE_o :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=(INT)sendmsg("INPUT3",MESSAGE_MI,x*G_vfontwide,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,CHAR *);
            if (f!=NULL) {
		        vsprintf(tmp,f,ap);
			    if (c) sendmsg("INPUT3",MESSAGE_C,0);
			    prln(x*G_vfontwide,y*G_vlsp,"%s",tmp);
			    if (c) sendmsg("INPUT3",MESSAGE_C,-1);
			    retval=1L;
            } else {
			    retval=0L;
            } 
			break;

		case MESSAGE_od :
            x=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y=va_arg(ap,INT);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=(INT)sendmsg("INPUT3",MESSAGE_MI,x*G_vfontaw,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,CHAR *);
		    vsprintf(tmp,f,ap);
			if (c) sendmsg("INPUT3",MESSAGE_C,0);
			prln((x*G_vfontwide)+(x1*G_vfontaw),y*G_vlsp,"%s",tmp);
			if (c) sendmsg("INPUT3",MESSAGE_C,-1);
			retval=1L;
			break;

		case MESSAGE_tt :
            x1=va_arg(ap,INT);
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=(INT)sendmsg("INPUT3",MESSAGE_MI,x*G_vfontwide,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,CHAR *);
		    vsprintf(tmp,f,ap);
			if (c) sendmsg("INPUT3",MESSAGE_C,0);
			tinyxy(x1,x*G_vfontwide,y*G_vlsp,"%s",tmp);
			if (c) sendmsg("INPUT3",MESSAGE_C,-1);
			retval=1L;
			break;

		case MESSAGE_R :
			sendmsg("INPUT3",MESSAGE_C,0);
			retval=(LONG)scr_reset();
			sendmsg("INPUT3",MESSAGE_C,1);
			break;
        case MESSAGE_A :
            c=va_arg(ap,INT)&0xFF;
			if (c<4) {
				G_screen.attr=G_hattr[c];
			} else {
				G_screen.attr=(CHAR)(c-3);
			}
			setcol(G_screen.attr);
            break;

        case MESSAGE_AA :
				G_screen.attr=(CHAR)(va_arg(ap,INT)&0xFF);
			setcol(G_screen.attr);
            break;

        case MESSAGE_C :
            x=va_arg(ap,INT);
			x1=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
			c=(INT)sendmsg("INPUT3",MESSAGE_MI,(x+x1)*G_vfontwide,y*G_vlsp,(x+x1+num)*G_vfontwide,(y+2)*G_vlsp);
			if (c) sendmsg("INPUT3",MESSAGE_C,0);
            cursor((x*G_vfontwide)+(x1*(G_vfontaw-G_backoneng)),y*G_vlsp,num);
			if (c) sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_Bl :
            x=va_arg(ap,INT);
			x1=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
			c=(INT)sendmsg("INPUT3",MESSAGE_MI,(x+x1)*G_vfontwide,y*G_vlsp,(x+x1+num)*G_vfontwide,(y+2)*G_vlsp);
			if (c) sendmsg("INPUT3",MESSAGE_C,0);
            blank((x*G_vfontwide)+(x1*G_vfontaw),y*G_vlsp,num);
			if (c) sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_B :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            vfdbox(x,y,x1,y1);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_b :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            bar(x,y,x1,y1);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_L :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            vfdline(x,y,x1,y1);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_X :
				G_screen.xor=(CHAR)(va_arg(ap,INT)&0xFF);
            break;


		  case MESSAGE_S :
				G_screen.size=(CHAR)(va_arg(ap,INT)%4);
				if (G_screen.size<1) G_screen.size=1;
			selectfont(G_screen.size-1);
            break;

        case MESSAGE_l :
            G_lights=va_arg(ap,INT)&0xFF;
//		    setlights();
            break;

        case MESSAGE_I :
			sendmsg("INPUT3",MESSAGE_C,0);
            retval=(LONG)scr_startup();
			G_onoff=1;
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;
        case MESSAGE_RI :
			sendmsg("INPUT3",MESSAGE_C,0);
            retval=(LONG)scr_restartup();
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_E :
			G_onoff=0;
			sendmsg("INPUT3",MESSAGE_C,0);
            scr_shutdown();
            break;
        case MESSAGE_TE :
			sendmsg("INPUT3",MESSAGE_C,0);
            scr_tmpshutdown();
            break;

        case MESSAGE_D :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            drawlogo(x,y,4);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_s :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            vfsink(x,y,num);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_r :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
			sendmsg("INPUT3",MESSAGE_C,0);
            vfraise(x,y,num);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;
        case MESSAGE_p :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			retval=(LONG)(x+y);
			break;

        case MESSAGE_SB :
            f=va_arg(ap,CHAR *);
			retval=(LONG)savebmp(f);
			break;

        case MESSAGE_P :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            f=va_arg(ap,CHAR *);
			retval=0L;
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",MESSAGE_C,0);
				putimage(x,y,img);
				sendmsg("INPUT3",MESSAGE_C,-1);
				freeimg(img);
				retval=1L;
			} else {
				prln(x,y,"!%s!",f);
			}
			break;

        case MESSAGE_3 :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            x1=va_arg(ap,INT)*G_vfontwide;
            y1=va_arg(ap,INT)*G_vlsp;
			sendmsg("INPUT3",MESSAGE_C,0);
            bezel(x,y,x1-1,y1-1,1);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_BT :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            x1=va_arg(ap,INT)*G_vfontwide;
            y1=va_arg(ap,INT)*G_vlsp;
            num=va_arg(ap,INT);
            f=va_arg(ap,CHAR *);
			sendmsg("INPUT3",MESSAGE_C,0);
            button(x+G_vfontwide/2,y+G_vlsp/2,x1-G_vfontwide/2,y1-G_vlsp/2,4,num,f,0);
			sendmsg("INPUT3",MESSAGE_C,-1);
            break;

        case MESSAGE_AN :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            x1=va_arg(ap,INT)*G_vlsp;
            y1=va_arg(ap,INT);
            f=va_arg(ap,CHAR *);
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",MESSAGE_C,0);
	            animimage(x,y,x1,y1,img);
				sendmsg("INPUT3",MESSAGE_C,-1);
				retval=1L;
			} else {
				sendmsg("INPUT3",MESSAGE_C,0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!",f);
				sendmsg("INPUT3",MESSAGE_C,-1);
			}
            break;

        case MESSAGE_DA :
            f=va_arg(ap,CHAR *);
            delfromanim(f);
    		retval=1L;
            break;

        case MESSAGE_TL :
            f=va_arg(ap,CHAR *);
			if ((img=getbmp(f))!=NULL) {
				freeimg(img);
            }
            retval=1L;
            break;
        case MESSAGE_RO :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            x1=va_arg(ap,INT);
            f=va_arg(ap,CHAR *);
            s=va_arg(ap,CHAR *);
			retval=0L;
			if ((img=getbmp(f))!=NULL) {
				if ((img2=getbmp(s))!=NULL) {
					sendmsg("INPUT3",MESSAGE_C,0);
		            flipimages(x,y,x1,img,img2);
					sendmsg("INPUT3",MESSAGE_C,-1);
					retval=1L;
				}
			}
			if (!retval) {
				sendmsg("INPUT3",MESSAGE_C,0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!%s!",f,s);
				sendmsg("INPUT3",MESSAGE_C,-1);
			}
            break;

        case MESSAGE_SC :
            x=va_arg(ap,INT)*G_vfontwide;
            y=va_arg(ap,INT)*G_vlsp;
            x1=va_arg(ap,INT)*G_vlsp;
            num=va_arg(ap,INT);
            y1=va_arg(ap,INT);
            f=va_arg(ap,CHAR *);
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",MESSAGE_C,0);
	            rotimage(x,y,x1,num,y1,img);
				sendmsg("INPUT3",MESSAGE_C,-1);
				retval=1L;
			} else {
				sendmsg("INPUT3",MESSAGE_C,0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!",f);
				sendmsg("INPUT3",MESSAGE_C,-1);
			}
            break;

        case MESSAGE_F :
            f=va_arg(ap,CHAR *);
			if (readfont(f)==NULL) retval=0L; else retval=1L;
			break;

        case MESSAGE_f :
            ff=va_arg(ap,CHAR **);
			*ff=(CHAR *)G_vfontspace;
			if (G_vfontspace==NULL) retval=0L; 
			break;

        case MESSAGE_N :
			retval=(LONG)isnew();
			break;
		case MESSAGE_T :					// TRANSLATE
            retval=(LONG)strlen(va_arg(ap,CHAR *));
			break;
			
		case MESSAGE_K :					// DIRECTION KEY PRESS
            retval=(LONG)va_arg(ap,INT);
			break;
		case MESSAGE_OF :
			G_onoff=0;
			retval=1L;
			break;
		case MESSAGE_ON :
			G_onoff=1;
			retval=1L;
			break;

        case MESSAGE_SP :
            pal=va_arg(ap,UCHAR *);
            for (x=0;x<8;x++)  setrgbpalette(x,pal[x*3],pal[x*3+1],pal[x*3+2]);
            for (   ;x<16;x++) setrgbpalette(0x30+x,pal[x*3],pal[x*3+1],pal[x*3+2]);
            retval=1L;
            break;

        case MESSAGE_GP :
            pal=va_arg(ap,UCHAR *);
			setcol(7);
            for (x=0;x<16;x++) getrgbpalette(x,pal+x*3,pal+x*3+1,pal+x*3+2);
            for (   ;x<16;x++) getrgbpalette(0x30+x,pal+x*3,pal+x*3+1,pal+x*3+2);
            retval=1L;
            break;

    }
    RETURNV(retval);
}
#pragma option -p.

