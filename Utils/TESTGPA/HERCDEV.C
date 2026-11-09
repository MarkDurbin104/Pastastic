#define HERCDEV_C
//___________________________________________________________________________

#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <time.h>
#include <fcntl.h>
#include <malloc.h>
#include "types.h"
#include "config.h"
#include "control.h"
#include "message.h"
#include "gprim.h"
#include "hercdev.h"
INT 			  G_herchand=(-1);
INT 			  G_hlsp=14;
INT               G_hfontwide=8;
INT               G_hfonthigh=14;
UCHAR    huge    *G_hfontspace=NULL;
INT				  G_hnewscr=1;

// draw a box on the screen
void hdbox(INT x,INT y,INT x1,INT y1)
{
    INT xs,xe,ys,ye;
	ENTRY(4140);
	setcol(2);
    xs=x *G_hfontwide +(G_hfontwide >>1);
    ys=y *G_hlsp+(G_hlsp>>1);
    xe=x1*G_hfontwide +(G_hfontwide >>1);
    ye=y1*G_hlsp+(G_hlsp>>1);

	rectangle(xs,ys,xe,ye);
    xs--; ys--; xe++; ye++;
	rectangle(xs,ys,xe,ye);

	setcol(G_screen.attr);
	RETURN;
}
// draw a line on the screen
void hdline(INT x,INT y,INT x1,INT y1)
{
	ENTRY(4150);
	setcol(2);
    line(x*G_hfontwide+(G_hfontwide/2),
            y*G_hlsp+(G_hlsp/2),
            x1*G_hfontwide+(G_hfontwide/2),
            y1*G_hlsp+(G_hlsp/2));

    line(x*G_hfontwide+(G_hfontwide/2)+1,
            y*G_hlsp+(G_hlsp/2)+1,
            x1*G_hfontwide+(G_hfontwide/2)+1,
            y1*G_hlsp+(G_hlsp/2)+1);
	setcol(G_screen.attr);
	RETURN;
}
//___________________________________________________________________________
// draw a cursor of length 'num' on the screen
void hcursor(INT x,INT y,INT num)
{
	ENTRY(4160);
	setcol(0x20);
	setwmode(1);
	prln(x,y*G_hlsp,"%*.*s",num,num,"");
	setwmode(0);
	setcol(G_screen.attr);
	RETURN;
}
// screen reset routine
INT hscr_reset(void)
{
	ENTRY(4170);
	G_hnewscr=1;
    cls();
    RETURNV(1);
} 
// screen input routine RETURNs current character size
INT hscr_input(void)
{
    INT i=(INT)G_screen.size;
	ENTRY(4180);
    RETURNV(i);
} 
INT checkflip(void)
{
	ENTRY(4190);
	flipscr();
	RETURNV(1);
}
// read the font information into memory
CHAR *readhfont(CHAR *fontfile)
{
	CHAR tmp[16];
	ENTRY(4200);
	sprintf(tmp,"H%s",fontfile);
	if (G_hfontspace!=NULL) FREE(G_hfontspace);
	G_hfontspace=loadffont(fontfile);
	if (!attachfont(G_hfontspace,101,14,8)) RETURNV(NULL);
	selectfont(G_screen.size-1);

    RETURNV((CHAR *)G_hfontspace);
}
// screen shutdown routine
INT hscr_shutdown(void)
{
	ENTRY(4210);
    sendmsg("INPUT1",MESSAGE_D,checkflip);
    if (G_hfontspace!=NULL) {
		FREE(G_hfontspace);
		G_hfontspace=NULL;
	}
    closegraf();
    RETURNV(1);                 
}
// screen startup routine
INT hscr_startup(void)
{
	IMAGE *img;
	ENTRY(4220);

	G_hnewscr=1;
    G_screen.size=1;
    G_screen.xor=0;

    G_screen.attr=2;
	G_herchand=grafix(1);
	if (G_herchand<0) RETURNV(0);
	usegdev(G_herchand);
    G_hlsp=14;
    G_hfonthigh=14;
    G_hfontwide=9;
	img=getbmp("GPASTARH.BMP");
	if (img!=NULL) {
		putimage(0,0,img);
		freeimg(img);
//		if (!isblk("POPUP_CUST")) saveblk("POPUP_CUST",32768U,(UCHAR *)0xB0000000L);
	}
    sendmsg("INPUT1",MESSAGE_A,10*18,checkflip);
    RETURNV(1);
}
// screen control routine
INT hscr_control(INT type,va_list ap)
{
	IMAGE *img;
    CHAR tmp[160],*f,**ff;
    INT x,y,x1,y1,num;
    INT retval=1;
	ENTRY(4230);
	if (G_herchand>=0) usegdev(G_herchand);
	
    switch (type) {

		case 'i' :
			retval=(INT)G_screen.size;
			break;

		case 'o' :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			if (!(x>80||x<0||y>30||y<0)) {
            	f=va_arg(ap,CHAR *);
		    	vsprintf(tmp,f,ap);
		    	prln(x,y*G_hlsp,"%s",tmp);
			}
			retval=1;
			break;

		case 'R' :
			retval=hscr_reset();
			break;

        case 'A' :
            G_screen.attr=G_hattr[va_arg(ap,INT)&0xFF];
			setcol(G_screen.attr);
            break;

        case 'C' :
            x=va_arg(ap,INT);
			x+=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
            hcursor(x,y,num);
            break;

        case 'B' :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
            hdbox(x,y,x1,y1);
            break;

        case 'L' :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
            hdline(x,y,x1,y1);
            break;

        case 'X' :
            G_screen.xor=va_arg(ap,INT)&0xFF;
			setwmode(G_screen.xor);
            break;

        case 'S' :
            G_screen.size=(va_arg(ap,INT)%4);
            if (G_screen.size<1) G_screen.size=1;
			selectfont(G_screen.size-1);
            break;

        case 'I' :
            retval=hscr_startup();
            break;

        case 'E' :
            hscr_shutdown();
            break;

        case 'p' :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
			retval=x+y;
			break;

        case 'F' :
            f=va_arg(ap,CHAR *);
			readhfont(f);
			retval=1;
			break;

        case 'N' :
			if (G_hnewscr) {
				G_hnewscr=0;
				retval=1;
			} else {
				retval=0;
			}
			break;

        case '0' :
			dontdraw(1);
		    prln(0,0,"SCREENSAVE OFF");
//			if (isblk("POPUP_CUST"))
//			   	restblk("POPUP_CUST",(UCHAR *)0xB0000000L);
			retval=1;
			break;

        case '1' :
			dontdraw(0);
		    prln(0,0,"SCREENSAVE ON");
			retval=1;
			break;

		case 'T' :					// TRANSLATE
            retval=strlen(va_arg(ap,CHAR *));
			break;

        case 'f' :
            ff=va_arg(ap,CHAR **);
			*ff=(CHAR *)G_hfontspace;
			if (G_hfontspace==NULL) retval=0; 
			break;

		case 'K' :					// DIRECTION KEY PRESS
            retval=va_arg(ap,INT);
			break;

        case 'P' :
            x=va_arg(ap,INT)*G_hfontwide;
            y=va_arg(ap,INT)*G_hlsp;
            f=va_arg(ap,CHAR *);
			retval=0;
			if ((img=getbmp(f))!=NULL) {
				putimage(x,y,img);
				freeimg(img);
				retval=1;
			} else {
				prln(x,y,"!%s!",f);
			}
			break;

        case '3' :
            x=va_arg(ap,INT)*G_hfontwide;
            y=va_arg(ap,INT)*G_hlsp;
            x1=va_arg(ap,INT)*G_hfontwide;
            y1=va_arg(ap,INT)*G_hlsp;
            bezel(x,y+G_hlsp/2,x1-1,y1+G_hlsp/2,1);
            break;

    }
    RETURNV(retval);
} 
