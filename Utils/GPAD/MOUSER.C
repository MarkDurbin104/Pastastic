#define MOUSE_C
#include <dos.h>

#include "types.h"
#include "mouse.h"

INT mousein(INT x,INT y,INT x1,INT y1)
{
    return((G_msex>=x)&&(G_msex<=x1)&&(G_msey>=y)&&(G_msey<=y1));
}
void setmousexto(INT newx) 
{
	union REGS regs;
    if (G_rotate) newx++;
	regs.x.ax=4;					// Set mouse position
	regs.x.cx=newx;
    regs.x.dx=G_msey;
    int86(0x33,&regs,&regs);
    G_msex=newx;
}
void setmousebto(INT newb) 
{
    G_mseb=(0-newb);
}

void setmouseyto(INT newy) 
{
	union REGS regs;
    if (G_rotate) newy++;
    regs.x.ax=4;					// Set mouse position
	regs.x.cx=G_msex;
	regs.x.dx=newy;
	int86(0x33,&regs,&regs);
    G_msey=newy;
}

INT mousecur(INT onoff) 
{
	union REGS regs;
	static curstat=0;
	switch (onoff) {
		case 0: {                       // Mouse cursor OFF 
			if (curstat) {
				regs.x.ax=2;
				int86(0x33,&regs,&regs);
				curstat=0;
			}
		} break;
		case 1: {						// Mouse cursor ON
			if (!curstat) {
				regs.x.ax=1;
				int86(0x33,&regs,&regs);
				curstat=1;
			}
		} break;
	}
	return(curstat);
}

INT setupmouse(INT x,INT y,INT xmin,INT xmax,INT ymin,INT ymax,INT r) 
{
	union REGS regs;
	regs.x.ax=0;					// Reset mouse and get status
	int86(0x33,&regs,&regs);
	if (regs.x.ax==0) return(0);
	regs.x.ax=8;					// Set vertical mouse pointer range
	regs.x.cx=ymin;
	regs.x.dx=ymax+2*r;
	int86(0x33,&regs,&regs);
	regs.x.ax=7;					// Set horizontal mouse pointer range
	regs.x.cx=xmin;
	regs.x.dx=xmax+2*r;
	int86(0x33,&regs,&regs);
	regs.x.ax=4;                    // Set mouse position
	regs.x.cx=x+r;
	regs.x.dx=y+r;
	int86(0x33,&regs,&regs);
	G_msex=x+r;
	G_msey=y+r;
	G_mseb=0;
	G_rotate=r;
	G_maxmx=xmax+2*r;
	G_maxmy=ymax+2*r;
	return(1);
}
void mousereset(INT x, INT y, INT mbut)
{
	union REGS regs;
	regs.x.ax=0x21;				// Software reset
	int86(0x33,&regs,&regs);
	if (mbut==1)			// left mouse button down
	{
		regs.x.ax=4;	 				// Set mouse position
		regs.x.cx=x;
		regs.x.dx=y;
		int86(0x33,&regs,&regs);
	}
}
INT mousetrap(INT step) 
{
	union REGS regs;
	INT retval=0;
	INT butset=0;
	INT x,y;

	if (G_mseb<0) butset=0-G_mseb;

	if (G_mseb)
	{
		regs.x.ax=3;			// get mouse position and button status
		int86(0x33,&regs,&regs);
		mousereset(regs.x.cx, regs.x.dx, regs.x.bx);
	}
	
	regs.x.ax=3;				// get mouse position and button status
	int86(0x33,&regs,&regs);
// Return: BX = button status
//		bit 0  left button pressed if 1
//		bit 1  right button pressed if 1
//		bit 2  middle button pressed if 1 (Mouse Systems/Logitech mouse)
//	 CX = column
//	 DX = row
	
	if (butset) regs.x.bx=butset;
	if (G_rotate) {
		x=regs.x.cx; y=regs.x.dx; x--; y--;

		if (x<0) x=G_maxmx-2;
		if (y<0) y=G_maxmy-2;

		if (x==(G_maxmx-1)) x=0;
		if (y==(G_maxmy-1)) y=0;

		if (x+1!=regs.x.cx) setmousexto(x);
		if (y+1!=regs.x.dx) setmouseyto(y);

		regs.x.cx=x; regs.x.dx=y;
	}
	regs.x.cx=(regs.x.cx/step)*step;
	regs.x.dx=(regs.x.dx/step)*step;
	if (G_msey>regs.x.dx) retval|=1;
	if (G_msey<regs.x.dx) retval|=2;
	if (G_msex<regs.x.cx) retval|=4;
	if (G_msex>regs.x.cx) retval|=8;
	if (G_mseb!=regs.x.bx) {
		retval|=0x80;
		if (regs.x.bx!=0) retval|=((regs.x.bx&&0x07)<<5);
	}
	G_msex=regs.x.cx;
	G_msey=regs.x.dx;
	G_mseb=regs.x.bx;
	return(retval);
}
INT mousestat(INT step) 
{
	union REGS regs;
	INT retval=0;
	INT butset=0;
	INT x,y;

	if (G_mseb<0) butset=0-G_mseb;

	regs.x.ax=3;				// get mouse position and button status
	int86(0x33,&regs,&regs);

	if (butset) regs.x.bx=butset;
	if (G_rotate) {
		x=regs.x.cx; y=regs.x.dx; x--; y--;

		if (x<0) x=G_maxmx-2;
		if (y<0) y=G_maxmy-2;

        if (x==(G_maxmx-1)) x=0;
        if (y==(G_maxmy-1)) y=0;

        if (x+1!=regs.x.cx) setmousexto(x);
        if (y+1!=regs.x.dx) setmouseyto(y);

        regs.x.cx=x; regs.x.dx=y;
	}
	regs.x.cx=(regs.x.cx/step)*step;
	regs.x.dx=(regs.x.dx/step)*step;

	if (G_msey>regs.x.dx) retval|=1;
	if (G_msey<regs.x.dx) retval|=2;
	if (G_msex<regs.x.cx) retval|=4;
	if (G_msex>regs.x.cx) retval|=8;
	if (G_mseb!=regs.x.bx) {
		retval|=0x80;
    	if (regs.x.bx!=0) retval|=((regs.x.bx&&0x07)<<5);
    }

	return(retval);
}
void  mousecuroffin(INT x,INT y,INT x1,INT y1) 
{
	union REGS regs;
	regs.x.ax=0x0010;				// Set mouse pointer exclusion area
	regs.x.cx=x1+G_rotate;
	regs.x.dx=y1+G_rotate;
	regs.x.si=x+G_rotate;
	regs.x.di=y+G_rotate;
	int86(0x33,&regs,&regs);
	mousecur(1);
}

void setmcurto(INT type) 
{
	static  INT lasttype=-1;
	union REGS regs;
	struct SREGS sregs;

	if (lasttype == type) return;
	lasttype = type;

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
			regs.x.bx=7;
			regs.x.cx=6;
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
			regs.x.bx=7;
			regs.x.cx=7;
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
			regs.x.bx=7;
			regs.x.cx=7;
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
			regs.x.bx=0;
			regs.x.cx=0;
		}
	}
	regs.x.ax=0x0009;
	regs.x.dx=FP_OFF(G_curarray);
	sregs.es=FP_SEG(G_curarray);
	int86x(0x33,&regs,&regs,&sregs);
}


