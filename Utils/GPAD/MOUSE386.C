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
	union REGS regsin, regsout;
	if (G_rotate) newx++;
	regsin.x.eax=4;
	regsin.x.ecx=newx;
	regsin.x.edx=G_msey;
	int386(0x33,&regsin,&regsout);
	G_msex=newx;
}
void setmousebto(INT newb) 
{
	 G_mseb=(0-newb);
}

void setmouseyto(INT newy) 
{
	union REGS regsin, regsout;
	if (G_rotate) newy++;
	regsin.x.eax=4;
	regsin.x.ecx=G_msex;
	regsin.x.edx=newy;
	int386(0x33,&regsin,&regsout);
	G_msey=newy;
}

INT mousecur(INT onoff) 
{
	union REGS regsin, regsout;
	static curstat=0;
	switch (onoff) {
		case 0: {
			if (curstat) {
				regsin.x.eax=2;
				int386(0x33,&regsin,&regsout);
				curstat=0;
			}
		} break;
		case 1: {
			if (!curstat) {
				regsin.x.eax=1;
				int386(0x33,&regsin,&regsout);
				curstat=1;
			}
		} break;
	}
	return(curstat);
}

INT setupmouse(INT x,INT y,INT xmin,INT xmax,INT ymin,INT ymax,INT r) 
{
	union REGS regsin, regsout;
	regsin.x.eax=0;
	int386(0x33,&regsin,&regsout);
	if (regsout.x.eax==0) return(0);
	regsin.x.eax=8;
	regsin.x.ecx=ymin;
	regsin.x.edx=ymax+2*r;
	int386(0x33,&regsin,&regsout);
	regsin.x.eax=7;
	regsin.x.ecx=xmin;
	regsin.x.edx=xmax+2*r;
	int386(0x33,&regsin,&regsout);
	regsin.x.eax=4;
	regsin.x.ecx=x+r;
	regsin.x.edx=y+r;
	int386(0x33,&regsin,&regsout);
	G_msex=x+r;
	G_msey=y+r;
	G_mseb=0;
	G_rotate=r;
	G_maxmx=xmax+2*r;
	G_maxmy=ymax+2*r;
	return(1);
}
INT mousetrap(INT step) 
{
	union REGS regsin, regsout;
	INT retval=0;
	INT butset=0;
	INT x,y;

	if (G_mseb<0) butset=0-G_mseb;

	regsin.x.eax=3;
	int386(0x33,&regsin,&regsout);

	if (butset) regsout.x.ebx=butset;
	if (G_rotate) {
		x=regsout.x.ecx; y=regsout.x.edx; x--; y--;
		
		if (x<0) x=G_maxmx-2;
		if (y<0) y=G_maxmy-2;

		if (x==(G_maxmx-1)) x=0;
		if (y==(G_maxmy-1)) y=0;

		if (x+1!=regsout.x.ecx) setmousexto(x);
		if (y+1!=regsout.x.edx) setmouseyto(y);

		regsout.x.ecx=x; regsout.x.edx=y;
	 }
	regsout.x.ecx=(regsout.x.ecx/step)*step;
	regsout.x.edx=(regsout.x.edx/step)*step;
	if (G_msey>regsout.x.edx) retval|=1;
	if (G_msey<regsout.x.edx) retval|=2;
	if (G_msex<regsout.x.ecx) retval|=4;
	if (G_msex>regsout.x.ecx) retval|=8;
	if (G_mseb!=regsout.x.ebx) {
		retval|=0x80;
		if (regsout.x.ebx!=0) retval|=((regsout.x.ebx&&0x07)<<5);
	}
	G_msex=regsout.x.ecx;
	G_msey=regsout.x.edx;
	G_mseb=regsout.x.ebx;
	return(retval);
}
INT mousestat(INT step) 
{
	union REGS regsin, regsout;
	INT retval=0;
	INT butset=0;
	INT x,y;

	if (G_mseb<0) butset=0-G_mseb;

	regsin.x.eax=3;
	int386(0x33,&regsin,&regsout);

	if (butset) regsout.x.ebx=butset;
	if (G_rotate) {
		x=regsout.x.ecx; y=regsout.x.edx; x--; y--;

		if (x<0) x=G_maxmx-2;
		if (y<0) y=G_maxmy-2;

		if (x==(G_maxmx-1)) x=0;
		if (y==(G_maxmy-1)) y=0;

		if (x+1!=regsout.x.ecx) setmousexto(x);
		if (y+1!=regsout.x.edx) setmouseyto(y);

		regsout.x.ecx=x; regsout.x.edx=y;
	}
	regsout.x.ecx=(regsout.x.ecx/step)*step;
	regsout.x.edx=(regsout.x.edx/step)*step;

	if (G_msey>regsout.x.edx) retval|=1;
	if (G_msey<regsout.x.edx) retval|=2;
	if (G_msex<regsout.x.ecx) retval|=4;
	if (G_msex>regsout.x.ecx) retval|=8;
	if (G_mseb!=regsout.x.ebx) {
		retval|=0x80;
		if (regsout.x.ebx!=0) retval|=((regsout.x.ebx&&0x07)<<5);
	}
	return(retval);
}

void  mousecuroffin(INT x,INT y,INT x1,INT y1) 
{
	union REGS regsin, regsout;
	regsin.x.eax=0x0010;
	regsin.x.ecx=x1+G_rotate;
	regsin.x.edx=y1+G_rotate;
	regsin.x.esi=x+G_rotate;
	regsin.x.edi=y+G_rotate;
	int386(0x33,&regsin,&regsout);
	mousecur(1);
}
void setmcurto(INT type) 
{
	union REGS regsin, regsout;
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
			regsin.x.ebx=7;
			regsin.x.ecx=6;
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
			regsin.x.ebx=7;
			regsin.x.ecx=7;
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
			regsin.x.ebx=7;
			regsin.x.ecx=7;
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
			regsin.x.ebx=0;
			regsin.x.ecx=0;
		}
	}
	regsin.x.eax=0x0009;
//	regs.r_dx=FP_OFF(G_curarray);
//	regs.r_es=FP_SEG(G_curarray);
//	int386(0x33,&regsin,&regsout);
}

