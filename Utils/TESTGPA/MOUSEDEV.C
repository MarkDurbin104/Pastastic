#define MOUSEDEV_C
#include <stdio.h>
#include <stdarg.h>
#include <alloc.h>
#include <dos.h>
#include "types.h"
#include "control.h"
#include "message.h"
#include "mousedev.h"

INT mousein(INT x,INT y,INT x1,INT y1)
{
	ENTRY(5790);
    RETURNV((G_msex>=x)&&(G_msex<=x1)&&(G_msey>=y)&&(G_msey<=y1));
}
void setmousexto(INT newx) 
{
	struct REGPACK regs;
	ENTRY(5800);
    if (G_rotate) newx++;
	regs.r_ax=4;
	regs.r_cx=newx;
    regs.r_dx=G_msey;
    intr(0x33,&regs);
    G_msex=newx;
	RETURN;
}
void setmousebto(INT newb) 
{
	ENTRY(5810);
    G_mseb=(0-newb);
	RETURN;
}

void setmouseyto(INT newy) 
{
	struct REGPACK regs;
	ENTRY(5820);
    if (G_rotate) newy++;
    regs.r_ax=4;
    regs.r_cx=G_msex;
    regs.r_dx=newy;
    intr(0x33,&regs);
    G_msey=newy;
	RETURN;
}

INT mousecur(INT onoff) 
{
	struct REGPACK regs;
	static curstat=0;
	ENTRY(5830);
	switch (onoff) {
		case 0: {
			if (curstat) {
				regs.r_ax=2;
				intr(0x33,&regs);
				curstat=0;
			}
		} break;
		case 1: {
			if (!curstat) {
				regs.r_ax=1;
				intr(0x33,&regs);
				curstat=1;
			}
		} break;
	}
	RETURNV(curstat);
}

INT setupmouse(INT x,INT y,INT xmin,INT xmax,INT ymin,INT ymax,INT r) 
{
	struct REGPACK regs;
	ENTRY(5840);
	regs.r_ax=0;
	intr(0x33,&regs);
	if (regs.r_ax==0) RETURNV(0);
    regs.r_ax=8;
	regs.r_cx=ymin;
	regs.r_dx=ymax+2*r;
    intr(0x33,&regs);
    regs.r_ax=7;
	regs.r_cx=xmin;
	regs.r_dx=xmax+2*r;
	intr(0x33,&regs);
    regs.r_ax=4;
	regs.r_cx=x+r;
	regs.r_dx=y+r;
    intr(0x33,&regs);
	G_msex=x+r;
	G_msey=y+r;
	G_mseb=0;
    G_rotate=r;
    G_maxmx=xmax+2*r;
    G_maxmy=ymax+2*r;
	RETURNV(1);
}
INT mousetrap(INT step) 
{
	struct REGPACK regs;
	INT retval=0;
    INT butset=0;
    INT x,y;
	ENTRY(5850);
	if (step<1) step=1;
    if (G_mseb<0) butset=0-G_mseb;

    regs.r_ax=3;
    intr(0x33,&regs);

    if (butset) regs.r_bx=butset;
    if (G_rotate) {
        x=regs.r_cx; y=regs.r_dx; x--; y--;

        if (x<0) x=G_maxmx-2;
        if (y<0) y=G_maxmy-2;

        if (x==(G_maxmx-1)) x=0;
        if (y==(G_maxmy-1)) y=0;

        if (x+1!=regs.r_cx) setmousexto(x);
        if (y+1!=regs.r_dx) setmouseyto(y);

        regs.r_cx=x; regs.r_dx=y;
    }
	regs.r_cx=(regs.r_cx/step)*step;
	regs.r_dx=(regs.r_dx/step)*step;
	if (G_msey>regs.r_dx) retval|=1;
	if (G_msey<regs.r_dx) retval|=2;
	if (G_msex<regs.r_cx) retval|=4;
	if (G_msex>regs.r_cx) retval|=8;
	if (G_mseb!=regs.r_bx) {
        retval|=0x80;
    	if (regs.r_bx!=0) retval|=((regs.r_bx&&0x07)<<5);
    }
	G_msex=regs.r_cx;
	G_msey=regs.r_dx;
	G_mseb=regs.r_bx;
	RETURNV(retval);
}
INT mousestat(INT step) 
{
	struct REGPACK regs;
	INT retval=0;
    INT butset=0;
    INT x,y;
	ENTRY(5860);
	if (step<1) step=1;

    if (G_mseb<0) butset=0-G_mseb;

    regs.r_ax=3;
    intr(0x33,&regs);

    if (butset) regs.r_bx=butset;
    if (G_rotate) {
        x=regs.r_cx; y=regs.r_dx; x--; y--;

        if (x<0) x=G_maxmx-2;
        if (y<0) y=G_maxmy-2;

        if (x==(G_maxmx-1)) x=0;
        if (y==(G_maxmy-1)) y=0;

        if (x+1!=regs.r_cx) setmousexto(x);
        if (y+1!=regs.r_dx) setmouseyto(y);

        regs.r_cx=x; regs.r_dx=y;
    }
	regs.r_cx=(regs.r_cx/step)*step;
	regs.r_dx=(regs.r_dx/step)*step;

	if (G_msey>regs.r_dx) retval|=1;
	if (G_msey<regs.r_dx) retval|=2;
	if (G_msex<regs.r_cx) retval|=4;
	if (G_msex>regs.r_cx) retval|=8;
	if (G_mseb!=regs.r_bx) {
        retval|=0x80;
    	if (regs.r_bx!=0) retval|=((regs.r_bx&&0x07)<<5);
    }

	RETURNV(retval);
}
void  mousecuroffin(INT x,INT y,INT x1,INT y1) 
{
	struct REGPACK regs;
	ENTRY(5870);
	regs.r_ax=0x0010;
	regs.r_cx=x1+G_rotate;
	regs.r_dx=y1+G_rotate;
	regs.r_si=x+G_rotate;
	regs.r_di=y+G_rotate;
	intr(0x33,&regs);
	mousecur(1);
	RETURN;
}
void setmcurto(INT type) 
{
	static INT ltype=1000;
	struct REGPACK regs;
	ENTRY(5880);
	if (type==ltype) RETURN;
	ltype=type;
	switch (type) {
		case 1 : {
			G_curarray[ 0]=0xE00F;			G_curarray[ 1]=0xF01F;
			G_curarray[ 2]=0xF01F;			G_curarray[ 3]=0xFC7F;
			G_curarray[ 4]=0xFC7F;			G_curarray[ 5]=0xFC7F;
			G_curarray[ 6]=0xFC7F;			G_curarray[ 7]=0xFC7F;
			G_curarray[ 8]=0xFC7F;			G_curarray[ 9]=0xFC7F;
			G_curarray[10]=0xF01F;			G_curarray[11]=0xF01F;
			G_curarray[12]=0xE00F;			G_curarray[13]=0xFFFF;
			G_curarray[14]=0xFFFF;			G_curarray[15]=0xFFFF;
			G_curarray[16]=0x0820;			G_curarray[17]=0x07C0;
			G_curarray[18]=0x0100;			G_curarray[19]=0x0100;
			G_curarray[20]=0x0100;			G_curarray[21]=0x0100;
			G_curarray[22]=0x0100;			G_curarray[23]=0x0100;
			G_curarray[24]=0x0100;			G_curarray[25]=0x0100;
			G_curarray[26]=0x0100;			G_curarray[27]=0x07C0;
			G_curarray[28]=0x0820;			G_curarray[29]=0x0000;
			G_curarray[30]=0x0000;			G_curarray[31]=0x0000;
			regs.r_bx=7;
			regs.r_cx=6;
		} break;
		case 2 : {
			G_curarray[ 0]=0xFC7F;			G_curarray[ 1]=0xFC7F;
			G_curarray[ 2]=0xFC7F;			G_curarray[ 3]=0xFC7F;
			G_curarray[ 4]=0xF83F;			G_curarray[ 5]=0xF01F;
			G_curarray[ 6]=0x0001;			G_curarray[ 7]=0x0001;
			G_curarray[ 8]=0x0001;			G_curarray[ 9]=0xF01F;
			G_curarray[10]=0xF83F;			G_curarray[11]=0xFC7F;
			G_curarray[12]=0xFC7F;			G_curarray[13]=0xFC7F;
			G_curarray[14]=0xFC7F;			G_curarray[15]=0xFFFF;
			G_curarray[16]=0x0000;			G_curarray[17]=0x0100;
			G_curarray[18]=0x0100;			G_curarray[19]=0x0100;
			G_curarray[20]=0x0380;			G_curarray[21]=0x0540;
			G_curarray[22]=0x0920;			G_curarray[23]=0x7FFC;
			G_curarray[24]=0x0920;			G_curarray[25]=0x0540;
			G_curarray[26]=0x0380;			G_curarray[27]=0x0100;
			G_curarray[28]=0x0100;			G_curarray[29]=0x0100;
			G_curarray[30]=0x0000;			G_curarray[31]=0x0000;
			regs.r_bx=7;
			regs.r_cx=7;
		} break;
		case 3 : {
			G_curarray[ 0]=0xFFFF;			G_curarray[ 1]=0xFFFF;
			G_curarray[ 2]=0xFFFF;			G_curarray[ 3]=0xFFFF;
			G_curarray[ 4]=0xF00F;			G_curarray[ 5]=0xF00F;
			G_curarray[ 6]=0xF00F;			G_curarray[ 7]=0xF00F;
			G_curarray[ 8]=0xFFFF;			G_curarray[ 9]=0xFFFF;
			G_curarray[10]=0xFFFF;			G_curarray[11]=0xFFFF;
			G_curarray[12]=0xFFFF;			G_curarray[13]=0xFFFF;
			G_curarray[14]=0xFFFF;			G_curarray[15]=0xFFFF;
			G_curarray[16]=0x0000;			G_curarray[17]=0x0000;
			G_curarray[18]=0x0000;			G_curarray[19]=0x0000;
			G_curarray[20]=0x0FF0;			G_curarray[21]=0x0FF0;
			G_curarray[22]=0x0FF0;			G_curarray[23]=0x0FF0;
			G_curarray[24]=0x0000;			G_curarray[25]=0x0000;
			G_curarray[26]=0x0000;			G_curarray[27]=0x0000;
			G_curarray[28]=0x0000;			G_curarray[29]=0x0000;
			G_curarray[30]=0x0000;			G_curarray[31]=0x0000;
			regs.r_bx=7;
			regs.r_cx=7;
		} break;
		default : {
			G_curarray[ 0]=0x1FFF;			G_curarray[ 1]=0x1FFF;
			G_curarray[ 2]=0x0FFF;			G_curarray[ 3]=0x07FF;
			G_curarray[ 4]=0x03FF;			G_curarray[ 5]=0x01FF;
			G_curarray[ 6]=0x00FF;			G_curarray[ 7]=0x007F;
			G_curarray[ 8]=0x003F;			G_curarray[ 9]=0x001F;
			G_curarray[10]=0x000F;			G_curarray[11]=0x000F;
			G_curarray[12]=0xF07F;			G_curarray[13]=0xF83F;
			G_curarray[14]=0xF83F;			G_curarray[15]=0xF83F;
			G_curarray[16]=0x0000;			G_curarray[17]=0x4000;
			G_curarray[18]=0x6000;			G_curarray[19]=0x7000;
			G_curarray[20]=0x7800;			G_curarray[21]=0x7C00;
			G_curarray[22]=0x7E00;			G_curarray[23]=0x7F00;
			G_curarray[24]=0x7F80;			G_curarray[25]=0x7FC0;
			G_curarray[26]=0x7FE0;			G_curarray[27]=0x0700;
			G_curarray[28]=0x0700;			G_curarray[29]=0x0380;
			G_curarray[30]=0x0380;			G_curarray[31]=0x0000;
			regs.r_bx=0;
			regs.r_cx=0;
		}
	}
	regs.r_ax=0x0009;
	regs.r_dx=FP_OFF(G_curarray);
	regs.r_es=FP_SEG(G_curarray);
	intr(0x33,&regs);
	RETURN;
}
INT setupar(void)
{
	ENTRY(5890);
	G_numar=0;
	if (G_ar!=NULL) RETURNV(0);
	if ((G_ar=MALLOC(MAXNUMAR*sizeof(ACTR)))==NULL) RETURNV(0);
	RETURNV(1);
}
INT freear(void)
{
	ENTRY(5900);
	G_numar=0;
	if (G_ar!=NULL) {
		FREE(G_ar);
		G_ar=NULL;
	}
	RETURNV(1);
}
INT clearar(void)
{
	ENTRY(5910);
	G_numar=0;
	RETURNV(1);
}
INT aregion(INT x,INT y,INT x1,INT y1,INT key)
{
	ENTRY(5920);
	if ((G_ar==NULL)||(G_numar>=MAXNUMAR)) RETURNV(0);
	G_ar[G_numar].x =x*8;
	G_ar[G_numar].y =y*19;
	G_ar[G_numar].x1=x1*8;
	G_ar[G_numar].y1=y1*19;
	G_ar[G_numar].k =key;
	G_numar++;
	RETURNV(1);
}
INT checkmouse(void)
{
	INT i;
	ENTRY(5930);
	if (mousestat(0)) {
		mousetrap(0);
		if (G_mseb==1) {
			for (i=0;i<G_numar;i++) {
				if (mousein(G_ar[i].x,G_ar[i].y,G_ar[i].x1,G_ar[i].y1)) {
                    sendmsg("OUTPUT1",MESSAGE_OF);
					sendmsg("INPUT1",MESSAGE_P,G_ar[i].k);
       				sendmsg("INPUT1",MESSAGE_P,5000);
					break;
				}
			}
		}
	}
	RETURNV(1);
}
//___________________________________________________________________________
// mouserdev control routine mouse without cursor
LONG mouse_control(INT type,va_list ap)
{
    INT retval=1;
	INT *x,*y,*b;
	INT x1,x2,y1,y2,k;
	ENTRY(5940);
	if ((!G_mouseok)&&(type!=MESSAGE_I)) RETURNV(0);
    switch(type) {
        case MESSAGE_i : // INPUT
		    x=va_arg(ap,INT *);
		    y=va_arg(ap,INT *);
		    b=va_arg(ap,INT *);
			mousetrap(0);
			*x=G_msex;
			*y=G_msey;
			*b=G_mseb;
            retval=1;
            break;
        case MESSAGE_I : // INITIALISE
			G_mouseok=setupmouse(320,240,0,640,0,480,0);
			if (G_mouseok) {
				setupar();
				sendmsg("INPUT1",MESSAGE_A,1,checkmouse);
				mousecur(0);
			}
			retval=G_mouseok;
            break;
        case MESSAGE_E : // END
			mousecur(0);
			freear();
			sendmsg("INPUT1",MESSAGE_D,checkmouse);
			G_mouseok=0;
            retval=1;
            break;
        case MESSAGE_C : // CURSOR
            break;
        case MESSAGE_A : // ACTIVATE region
		    x1=va_arg(ap,INT);
		    y1=va_arg(ap,INT);
		    x2=va_arg(ap,INT);
		    y2=va_arg(ap,INT);
		    k=va_arg(ap,INT);
			retval=aregion(x1,y1,x2,y2,k);
            break;

        case MESSAGE_MI : // Mouse in region
		    x1=va_arg(ap,INT);
		    y1=va_arg(ap,INT);
		    x2=va_arg(ap,INT);
		    y2=va_arg(ap,INT);
			retval=mousein(x1,y1,x2,y2);
//			sendmsg("OUTPUT1",MESSAGE_o,0,0,"%d %d %d %d %d   ",x1,y1,x2,y2,retval);
            break;

        case MESSAGE_r : // RESET Activate regions
			retval=clearar();
			break;
    }
    RETURNV((LONG)retval);
}
// mousecurdev control routine mouse with cursor
LONG mousecur_control(INT type,va_list ap)
{
	static INT lonoff=1;
	INT onoff=0,retval=1;
	ENTRY(5950);
	if ((!G_mouseok)&&(type!=MESSAGE_I)) RETURNV(0);
	if (type!=MESSAGE_C) {
		retval=mouse_control(type,ap);
		if ((type!=MESSAGE_I)||(!G_mouseok)) RETURNV((LONG)retval);
	}
	if (type==MESSAGE_I) {
		onoff=-1;
	} else {
    	onoff=va_arg(ap,INT);
	}
	if (onoff==(-1)) {
		onoff=lonoff;
	} else if (onoff) {
		lonoff=onoff;
	}
	if (onoff) {
		setmcurto(onoff-1);
		mousecur(1);
	} else {
		mousecur(0);
	}
	RETURNV((LONG)retval);
}
//___________________________________________________________________________
