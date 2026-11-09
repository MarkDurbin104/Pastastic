/*****************************************************************************/
/******************************  MOUSE.H    **********************************/
/*************************  M.J.D -  06/08/89  *******************************/
/*****************************************************************************/
#ifndef MOUSE
int		msex,msey,mseb;
int		G_curarray[32];

extern  void	setmousexto(int newx);
extern  void	setmouseyto(int newy);
extern  int		mousecur(int onoff);
extern  int		setupmouse(int x,int y,int xmin,int xmax,int ymin,int ymax);
extern  int		mousetrap(int step);
extern  int		mousestat(int step);
extern	void	mousecuroffin(int x,int y,int x1,int y1);
extern	void	setmcurto(int type);
#endif

void setmousexto(int newx) {
	struct REGPACK regs;
    regs.r_ax=4;
    regs.r_cx=newx;
    regs.r_dx=msey;
    intr(0x33,&regs);
    msex=newx;
}

void setmouseyto(int newy) {
	struct REGPACK regs;
    regs.r_ax=4;
    regs.r_cx=msex;
    regs.r_dx=newy;
    intr(0x33,&regs);
    msey=newy;
}

int mousecur(int onoff) {
	struct REGPACK regs;
	static curstat=0;
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
	return(curstat);
}

int setupmouse(int x,int y,int xmin,int xmax,int ymin,int ymax) {
	struct REGPACK regs;
	regs.r_ax=0;
	intr(0x33,&regs);
	if (regs.r_ax==0) return(0);
    regs.r_ax=4;
	regs.r_cx=x;
	regs.r_dx=y;
    intr(0x33,&regs);
    regs.r_ax=8;
	regs.r_cx=ymin;
	regs.r_dx=ymax;
    intr(0x33,&regs);
    regs.r_ax=7;
	regs.r_cx=xmin;
	regs.r_dx=xmax;
	intr(0x33,&regs);
	msex=x;
	msey=y;
	mseb=0;
	return(1);
}
int mousetrap(int step) {
	struct REGPACK regs;
	int retval=0;
    regs.r_ax=3;
    intr(0x33,&regs);
	regs.r_cx=(regs.r_cx/step)*step;
	regs.r_dx=(regs.r_dx/step)*step;
	if (msey>regs.r_dx) retval|=1;
	if (msey<regs.r_dx) retval|=2;
	if (msex<regs.r_cx) retval|=4;
	if (msex>regs.r_cx) retval|=8;
	if (regs.r_bx!=0) retval|=((regs.r_bx&&0x07)<<5);
	msex=regs.r_cx;
	msey=regs.r_dx;
	mseb=regs.r_bx;
	return(retval);
}
int mousestat(int step) {
	struct REGPACK regs;
	int retval=0;
    regs.r_ax=3;
	intr(0x33,&regs);
	regs.r_cx=(regs.r_cx/step)*step;
	regs.r_dx=(regs.r_dx/step)*step;

	if (msey>regs.r_dx) retval|=1;
	if (msey<regs.r_dx) retval|=2;
	if (msex<regs.r_cx) retval|=4;
	if (msex>regs.r_cx) retval|=8;
	if (regs.r_bx!=0) retval|=((regs.r_bx&&0x07)<<5);

	return(retval);
}
extern	void  mousecuroffin(int x,int y,int x1,int y1) {
	struct REGPACK regs;
	regs.r_ax=0x0010;
	regs.r_cx=x1;
	regs.r_dx=y1;
	regs.r_si=x;
	regs.r_di=y;
	intr(0x33,&regs);
	mousecur(1);
}
void setmcurto(int type) {
	struct REGPACK regs;
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
}