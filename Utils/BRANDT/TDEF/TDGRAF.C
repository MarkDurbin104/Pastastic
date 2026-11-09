#include <graphics.h>
#include <stdio.h>
#include <alloc.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <time.h>
#include "tdef.h"

#define swap(a,b) c=a; a=b; b=c
#define sign(x) ((x<0)?(-1):1)
void puticon(int x,int y,int icon,int mode,int col);
int boxinbox(int l,int l1,int r,int r1,int t,int t1,int b,int b1);
int psdtextht(char *text);
void procbx(int type,shape *e,int dotext,int wid,int hgt);
void dstbx(int type,shape *e,int dotext,int wid,int hgt);
void entbx(int type,shape *e,int dotext,int wid,int hgt);
void dprocbx(int type,shape *e,int dotext,int wid,int hgt);
void psdnbx(int type,shape *e,int dotext,int wid,int hgt);
void psdobx(int type,shape *e,int wid,int hgt);
void psdlbx(int type,shape *e,int dotext,int wid,int hgt);
void psdsbx(int type,shape *e,int wid,int hgt);
void idsmbx(int type,shape *e,int dotext,int wid,int hgt);
void idsfbx(int type,shape *e,int dotext,int wid,int hgt);
void idshbx(int type,shape *e,int wid,int hgt);
void idscbx(int type,shape *e,int wid,int hgt);
void tdsbx(int type,shape *e,int dotext,int wid,int hgt);
void infbx(int type,shape *e,int dotext,int wid,int hgt);
void titbx(int type,shape *e,int dotext,int wid,int hgt);

void grafix(void) {					/* sets up graphics mode */
	int errormode;
	G_driver = VGA;
	G_mode = VGAHI;
	errormode=registerbgidriver(EGAVGA_driver);
	if( errormode < 0 ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	G_maxx=getmaxx();
	G_maxy=getmaxy();
}

/************* Draw element
				type 0=normal 1=xor
				x	 negative offset of page
				y
				a	shape to draw
				dotext 1=draw text				**************/
void drelem(int type,int x,int y,shape *a,int dotext) {
	char textln[400],*t;
	int i,j,wid,hgt;
	shape e;
	struct viewporttype v;
	getviewsettings(&v);		/* get current settings max/min scr coords */
	e.colour=a->colour;			/* copy shape for my use */
	e.type=a->type;
	e.text=a->text;
	e.deled=a->deled;
	e.ident=a->ident;
	e.level=a->level;
	e.xpos=a->xpos+x;           /* x and y are negative offsets onto curr page */
	e.ypos=a->ypos+y;
	wid=G_wid[e.type]/2;
	hgt=G_hgt[e.type];
	/* if not deleted and any part currently on screen draw it */
	if ((!e.deled)&&(boxinbox(e.xpos-wid,v.left,e.xpos+wid,v.right,e.ypos+hgt,v.top,e.ypos,v.bottom))) {
		setcolor(e.colour&0x0F);            /* line color */
		movto(type,e.xpos,e.ypos);          /* type=1 is xor */
		switch (e.type) {
			case 1 :						/* DFD Menu Box */
			case 2 :						/* DFD Process Box */
			case 3 :						/* DFD Port Box */
			case 4 :						/* DFD Supervisor Box */
			case 5 :						/* DFD Alarm/Calendar Box */
			case 6 :						/* DFD Report Box */
			case 7 : {						/* DFD Printer Box */
				procbx(type,&e,dotext,wid,hgt);
				i=25;                      /* text offset y,x */
				j=0;
			} break;
			case 8 : {						/* DFD Data Store Box */
				dstbx(type,&e,dotext,wid,hgt);
				i=5;
				j=10;
			} break;
			case 9 : {						/* DFD Entity Box */
				entbx(type,&e,dotext,wid,hgt);
				i=10;
				j=0;
			} break;
			case 10 : {						/* DFD Duplicate-Process Box */
				dprocbx(type,&e,dotext,wid,hgt);
				i=25;
				j=0;
			} break;
			case 11 : {						/* PSD Normal Box */
				psdnbx(type,&e,dotext,wid,hgt);
			} break;
			case 12 : {						/* PSD OR Box */
				psdobx(type,&e,wid,hgt);
			} break;
			case 13 : {						/* PSD Loop Box */
				psdlbx(type,&e,dotext,wid,hgt);
			} break;
			case 14 : {						/* PSD Subroutine Box */
				psdsbx(type,&e,wid,hgt);
			} break;
			case 15 : {						/* IDS Menu Box */
				idsmbx(type,&e,dotext,wid,hgt);
				i=20;
				j=0;
			} break;
			case 16 : {						/* IDS Form Box */
				idsfbx(type,&e,dotext,wid,hgt);
				i=20;
				j=0;
			} break;
			case 17 : {						/* IDS Hot Key Box */
				idshbx(type,&e,wid,hgt);
				i=5;
				j=0;
			} break;
			case 18 : {						/* IDS Function Box */
				idscbx(type,&e,wid,hgt);
				i=5;
				j=0;
			} break;
			case 19 : 						/* TDS Form Box */
			case 20 : {						/* TDS Window Box */
				tdsbx(type,&e,dotext,wid,hgt);
				i=20;
				j=0;
			} break;
			case 21 : {						/* Imported Flow */
				i=0;
				j=0-wid-55;
			} break;
			case 22 : {						/* Title Box */
				i=22;
				j=(0-wid)+(G_wid[1]/2);
			} break;
			default : {
			}
		}
		/* if we need text then doit - Not PSD or task? */
		if (((e.type<10)||(e.type>14))&&(dotext)&&((e.type>7)||(e.type<4))) {
			settextjustify(1,2);
			setcolor(e.colour>>4);
			strcpy(textln,e.text);
			t=strtok(textln,"\n");
			while (t!=(char *)NULL) {
				outtxtxy(e.xpos+j,e.ypos+i,t);
				t=strtok((char *)NULL,"\n");
				i+=10;
			}
		}
		/* if PSD then do that */
		if ((e.type>10)&&(e.type<15)) {
			if (dotext) printpsdln(e.xpos,e.ypos,e.text,e.colour>>4);
		}
	}
}


/************* Draw line
				type 0=normal 1=xor
				x	 negative offset of page
				y
				e	line to draw
				dotext 1=draw text	(off when scrolling)*************/

void drcont(int type,int x,int y,join *e,int dotext) {
	int i,lp,llp;
	if (!e->deled) {
		setcolor(e->flags.LCOL);
		movto(type,x+e->pos.x,y+e->pos.y);
		if (e->flags.DIR) {							/* RIGHT/LEFT */
			llp=e->pos.x;
			lp=e->pos.y;
									/* one more line when no text */
			for(i=0;i<e->flags.NOPNT-(dotext!=0);i++) {
				if (i&1) { 							/* VERT */
					linto(type,x+lp,y+e->points[i]);
					llp=lp;
					lp=e->points[i];
				}
				else {								/* HORIZ */
					linto(type,x+e->points[i],y+lp);
					llp=lp;
					lp=e->points[i];
				}
			}
			if (dotext) {
				if (i==0) {		/* arrow draws line as well */
					arrow(1,x+e->pos.x,y+e->pos.y,x+e->points[i],y+e->pos.y);
				}
				else {
					if (i&1) { 							/* VERT */
						arrow(1,x+lp,y+llp,x+lp,y+e->points[i]);
					}
					else {								/* HORIZ */
						arrow(1,x+llp,y+lp,x+e->points[i],y+lp);
					}
				}
				setcolor(e->flags.TCOL);
				if (e->flags.TXTON) outtxtxy(x+e->tpos.x,y+e->tpos.y,e->text);
			}
		}
		else {										/* UP/DOWN */
			llp=e->pos.y;
			lp=e->pos.x;
			for(i=0;i<e->flags.NOPNT-(dotext!=0);i++) {
				if (i&1) {
					linto(type,x+e->points[i],y+lp);
					llp=lp;
					lp=e->points[i];
				}
				else {
					linto(type,x+lp,y+e->points[i]);
					llp=lp;
					lp=e->points[i];
				}
			}
			if (dotext) {
				if (i==0) {
					arrow(1,x+e->pos.x,y+e->pos.y,x+e->pos.x,y+e->points[i]);
				}
				else {
					if (i&1) { 							/* HORIZ */
						arrow(1,x+llp,y+lp,x+e->points[i],y+lp);
					}
					else {								/* VERT */
						arrow(1,x+lp,y+llp,x+lp,y+e->points[i]);
					}
				}
				setcolor(e->flags.TCOL);
				if (e->flags.TXTON) outtxtxy(x+e->tpos.x,y+e->tpos.y,e->text);
			}
		}
	}
}

/**************** Clear screen and repaint std bits, not scroll bars *************/
void cls(void) {
	int i;
	static int levt=10;
	levt=G_levtype;
	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	for (i=0;i<18;i++) {                   /* ICONS */
		puticon(10+((i/9)*(WINX/2)),WINY+5+((i%9)*45),G_icontype[(i>8)*G_levtype][i-((i>8)*9)],0,11);
	}
	puticon(34,WINY+415,34,0,8+((G_nowlev!=0)*6)); /* up a level */
	setcolor(14);
	rectangle(0,0,G_maxx,G_maxy);                  /* screen */
	line(0,WINY-1,G_maxx,WINY-1);
	line(WINX-1,WINY-1,WINX-1,G_maxy-1);
	line(WINX-1,G_maxy-10,G_maxx,G_maxy-10);
	line(G_maxx-10,WINY-1,G_maxx-10,G_maxy);
	line(WINX+10,G_maxy-9,WINX+10,G_maxy-1);
	line(G_maxx-21,G_maxy-9,G_maxx-21,G_maxy-1);
	line(G_maxx-9,WINY+10,G_maxx-1,WINY+10);
	line(G_maxx-9,G_maxy-21,G_maxx-1,G_maxy-21);
	for (i=0;i<10;i++) line(0,WINY+(i*45),WINX-2,WINY+(i*45)); /* icon lines */
	line(WINX/2,WINY,WINX/2,WINY+405);
	setfillstyle(11,14);					/* fill pat for scroll bars */
	bar(WINX+11,G_maxy-9,G_maxx-22,G_maxy-1);
	bar(G_maxx-9,WINY+11,G_maxx-1,G_maxy-22);
	headings(WINX,"File.Options.Dictionary.Report");
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	selelem(0);                            /* select arrow */
}

/****************** Scroll bars proportionaly sized according to size of
					drawing *******/
void markpoints(void) {
	long bx,by,sx,sy;
	long xp,yp;
	int	a;
	bx=((G_maxx-WINX)-33)-((G_maxx-WINX-11)/WID);
	by=((G_maxy-WINY)-33)-((G_maxy-WINY-11)/HGT);
	sx=(long)(G_maxx*WID)-(long)(G_maxx-WINX-11);
	sy=(long)(G_maxy*HGT)-(long)(G_maxy-WINY-11);
	xp=0L-(long)G_xpos;
	yp=0L-(long)G_ypos;
	G_xtos=(int)(((bx*xp)/sx)+(long)WINX+11L);
	G_ytos=(int)(((by*yp)/sy)+(long)WINY+11L);
	G_xbos=G_xtos+(int)(bx/(long)(WID-1));
	G_ybos=G_ytos+(int)(by/(long)(HGT-1));
	setviewport(0,0,G_maxx,G_maxy,1);
	setfillstyle(11,14);
	if ((a=mousecur(2))==1) mousecur(0);
	bar(WINX+11,G_maxy-9,G_maxx-22,G_maxy-1);
	bar(G_maxx-9,WINY+11,G_maxx-1,G_maxy-22);
	setfillstyle(1,15);
	bar(G_xtos,G_maxy-9,G_xbos,G_maxy-1);
	bar(G_maxx-9,G_ytos,G_maxx-1,G_ybos);
	if (a) mousecur(1);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
}
/************ draws a line to a position
					type    1=turboc, 0=mjd
					x       x_pos
					y       y_pos		*************/
void linto(int type,int x,int y) {
	int i=0,col,lim;
	int sx,sy,dx,dy;
	register int e;
	int x1,x2,y1,y2;
	if (G_ltype) type=0;		/* set if printing therefore must use 0 */
	switch (type) {
		case 1 : {
			lineto(x,y);
		} break;
		default : {
			x1=G_line.x2;
			x2=x;
			y1=G_line.y2;
			y2=y;
			col=15;
			dx=abs(x2-x1); sx=sign(x2-x1);
			dy=abs(y2-y1); sy=sign(y2-y1);
			if (dx<dy) {
				dx<<=1;	e=dx-dy; lim=dy+1; dy<<=1;
				while (++i<lim) {
					putpix(x1,y1,col,1);
					while (e>=0) { x1+=sx; e-=dy; }
					y1+=sy; e+=dx;
				}
			}
			else {
				dy<<=1;	e=dy-dx; lim=dx+1; dx<<=1;
				while (++i<lim) {
					putpix(x1,y1,col,1);
					while (e>=0) { y1+=sy; e-=dx; }
					x1+=sx;	e+=dy;
				}
			}
			putpix(x2,y2,col,1);
		}
	}
	G_line.x1=G_line.x2;
	G_line.y1=G_line.y2;
	G_line.x2=x;
	G_line.y2=y;
}

/*************** Sets globals or does turbo c routine *******/
void movto(int type,int x,int y) {
	if (G_ltype) type=0;
	if (type) {
		moveto(x,y);
	}
	G_line.x1=G_line.x2;
	G_line.y1=G_line.y2;
	G_line.x2=x;
	G_line.y2=y;
}

/********** putpix - print to screen or printer array
		x
		y
		colour
		mode 		xor or normal

		G_ltype = 0 screen
				= 1 horizontal
				= 2 vertical					**********/

int putpix(int x,int y,int col,int mode) {
	int i,xl,yl;
	struct viewporttype tt;
	unsigned char sval;
	if (G_ltype) {            /* Going to printer */
		switch (G_pwid) {     /* Magnification factor */
			case 1 : sval=0x80; break;      /* normal */
			case 2 : sval=0xC0; break;      /* *2 */
			case 4 : sval=0xF0; break;      /* *4 */
		}
		if (G_ltype==2) {
			if (col) {              /* Only if not black */
						/* if x,y are within array  then print */
				if (((x>=G_scx)&&(x<G_scx+((G_szpbuf*24)/G_pwid)))
				&&	((y>=G_scy)&&(y<G_scy+(1440/G_pwid)))) {
					for (i=0;i<G_pwid;i++) {
						G_scr[(x-G_scx)/(8/G_pwid)][G_dpl-((y-G_scy)*G_pwid+i)]|=
							sval>>(G_pwid*((x-G_scx)%(8/G_pwid)));
					}
				}
			}
		}
		if (G_ltype==1) {
			if (col) {
				if (((y>=G_scy)&&(y<G_scy+((G_szpbuf*24)/G_pwid)))
				&&	((x>=G_scx)&&(x<G_scx+(1440/G_pwid)))) {
					for (i=0;i<G_pwid;i++) {
						G_scr[(y-G_scy)/(8/G_pwid)][(x-G_scx)*G_pwid+i]|=
							sval>>(G_pwid*((y-G_scy)%(8/G_pwid)));
					}
				}
			}
		}
	}
	else {
		getviewsettings(&tt);
		xl=tt.right-tt.left;
		yl=tt.bottom-tt.top;
		if (x>=0&&x<xl&&y>=0&&y<yl) { /* if on screen */
			switch (mode) {
				case 1 : {
					putpixel(x,y,col^getpixel(x,y));
				} break;
				default : {
					putpixel(x,y,col);
				}
			}
		}
	}
	return(1);
}


/**************redraw the drawing.
				quick draws outlines and no arrows   ********/
void redraw(int quick) {
	int i,m;
	if ((m=mousecur(3))==1) mousecur(0);
	if (G_ltype) {
		for (i=0;i<G_noelem[G_nowlev];i++) {
			drelem(1,0,0,&(lev[G_nowlev].G_elem[i]),quick);
		}
		for (i=0;i<G_nocont[G_nowlev];i++) {
			drcont(1,0,0,&(lev[G_nowlev].G_cont[i]),quick);
		}
	}
	else {
		for (i=0;i<G_noelem[G_nowlev];i++) {
			drelem(1,G_xpos,G_ypos,&(lev[G_nowlev].G_elem[i]),quick);
		}
		for (i=0;i<G_nocont[G_nowlev];i++) {
			drcont(1,G_xpos,G_ypos,&(lev[G_nowlev].G_cont[i]),quick);
		}
	}
	if (m) mousecur(1);
}


void tmpdraw(void) {		/* always does a quick draw */
	markpoints();
	clearviewport();
	redraw(0);
}


/* Draws an arrow from x1,y1 to x2,y2       t=1 - XOR */
void arrow(int t,int x1,int y1,int x2,int y2) {
	if (x1<x2) {
		movto(t,x1,y1);
		linto(t,x2,y1);
		linto(t,x2-10,y1+2);
		linto(t,x2-10,y1-2);
		linto(t,x2,y1);
	}
	else {
		if (x1>x2) {
			movto(t,x1,y1);
			linto(t,x2,y1);
			linto(t,x2+10,y1+2);
			linto(t,x2+10,y1-2);
			linto(t,x2,y1);
		}
		else {
			if (y1<y2) {
				movto(t,x1,y1);
				linto(t,x1,y2);
				linto(t,x1+2,y2-10);
				linto(t,x1-2,y2-10);
				linto(t,x1,y2);
			}
			else {
				if (y1>y2) {
					movto(t,x1,y1);
					linto(t,x1,y2);
					linto(t,x1+2,y2+10);
					linto(t,x1-2,y2+10);
					linto(t,x1,y2);
				}
			}
		}
	}
}

/*	in the act of drawing a line */
void drawline(void) {
	int i,j,k,l,x,y,d,dir;
	int from,to;
	int ix,iy,iw,ih,tx,ty;
	int xit=0;
	int cur=0,points[17][2];     /* points is local containing both x and y */
	join t;
	char tmp[20];

	memset(points,0,sizeof(points));    /* clear all points */
	if ((from=findelem())!=(-1)) {      /* only enter if cursor on an element */
		ix=((lev[G_nowlev].G_elem[from].xpos)+G_xpos); /* relitive elem pos */
		iy=((lev[G_nowlev].G_elem[from].ypos)+G_ypos);
		iw=G_wid[lev[G_nowlev].G_elem[from].type];     /* elem size */
		ih=G_hgt[lev[G_nowlev].G_elem[from].type];
		x=msex;                                        /* cursor pos (screen)*/
		y=msey;
		while (!xit) {
			while (mseb) {                            /* while mousey button */
				if (mousestat(G_snapto)!=32) {     /* while moveing & left button */
					mousecur(0);
					dln(x,y,ix,iy,ih,iw);          /* clever line drawing routine Xor only*/
					mousetrap(G_snapto);
					dln(x,y,ix,iy,ih,iw);
					mousecur(1);
				}
			}
			tx=msex;	/* save mouse pos */
			ty=msey;
			setmousexto(G_line.x2+WINX); /* ignore real mouse pos. use end of line */
			setmouseyto(G_line.y2+WINY);
			if ((to=findelem())==(-1)) {		/* if not on element */
				setmousexto(tx);		/* restore mouse pos */
				setmouseyto(ty);
				if (cur<14) {           /* check not too many points */
					/* if clicked twice in same place then cancel */
					if ((x==G_line.x2+WINX)&&(y==G_line.y2+WINY)) {
						xit=1;
						mousecur(0);
						clearviewport();
						redraw(1);
						mousecur(1);
					}
					/* else add line to local array */
					else {
						iw=0;
						ih=0;
						ix=G_line.x2;
						x=ix+WINX;
						iy=G_line.y2;
						y=iy+WINY;
						if (cur==0) {
							points[cur][0]=G_line.x1+(0-G_xpos);
							points[cur][1]=G_line.y1+(0-G_ypos);
							if (G_line.x1!=G_line.x2) d=1; else d=0;
						}
						cur++;
						points[cur][0]=G_line.x2+(0-G_xpos);
						points[cur][1]=G_line.y2+(0-G_ypos);
						while (!mseb) mousetrap(G_snapto); /* wait until mouse */
						mousecur(0);
						dln(x,y,ix,iy,ih,iw);
						mousecur(1);
					}
				}
				else { /* if > 14 lines not catered for */
					xit=1;
					mousecur(0);
					clearviewport();
					redraw(1);
					mousecur(1);
				}
			}
			else {
				setmousexto(tx);		/* restore mouse pos */
				setmouseyto(ty);
				if (cur==0) {   		/* if first point */
					points[cur][0]=G_line.x1+(0-G_xpos); /* set start points */
					points[cur][1]=G_line.y1+(0-G_ypos);
					if (G_line.x1!=G_line.x2) d=1; else d=0; /* Horiz or vert */
				}
				/* if from to is not same elem or more than one bit of line
					and line is valid then do it */
				if (((to!=from)||(cur>1))&&(chkline(from,to))) {
					if (G_line.x1>G_line.x2) {  	/* which side of to box do we enter */
						dir=0;									/*R*/
					}
					else {
						if (G_line.x1<G_line.x2) {
							dir=1;								/*L*/
						}
						else {
							if (G_line.y1>G_line.y2) {
								dir=2;							/*B*/
							}
							else {
								dir=3;							/*T*/
							}
						}
					}
					ix=((lev[G_nowlev].G_elem[to].xpos)+G_xpos);
					iy=((lev[G_nowlev].G_elem[to].ypos)+G_ypos);
					iw=G_wid[lev[G_nowlev].G_elem[to].type];
					ih=G_hgt[lev[G_nowlev].G_elem[to].type];
					cur++;
					switch(dir) {	/* set up last point */
						case 0 : {        					/*R*/
							points[cur][0]=ix+(iw/2)+(0-G_xpos);
							points[cur][1]=G_line.y2+(0-G_ypos);
						} break;
						case 1 : {							/*L*/
							points[cur][0]=ix-(iw/2)+(0-G_xpos);
							points[cur][1]=G_line.y2+(0-G_ypos);
						} break;
						case 2 : {							/*B*/
							points[cur][0]=G_line.x2+(0-G_xpos);
							points[cur][1]=iy+ih+(0-G_ypos);
						} break;
						case 3 : {							/*T*/
							points[cur][0]=G_line.x2+(0-G_xpos);
							points[cur][1]=iy+(0-G_ypos);
						} break;
					}
					xit=1;
					t.from=from;		/* Start setting up new cont */
					t.to=to;
					if ((G_levtype==1)||(G_levtype==2)) { /* if DFD or PSD/DFD */
						sprintf(tmp,"%d.%d",lev[G_nowlev].G_elem[from].ident, /* name is flow.flow */
											lev[G_nowlev].G_elem[to].ident);
					}
					if (G_levtype==3) {		/* menu */
						l=0;
						for (k=0;k<G_nocont[G_nowlev];k++) {
							if (from==lev[G_nowlev].G_cont[k].from) l++;
						} /*menu flows called 1-0 A-.... */
						if (l<9) tmp[0]='1'+l;	else if (l==9) tmp[0]='0'; else tmp[0]='A'+(l-10);
						tmp[1]=0;
					}
					if (G_levtype==4) {  /* TDS */
						strcpy(tmp,"CR");
					}
                             /* external flow name */
/*					getuplev();
					if (lev[G_nowlev].G_elem[from].type==21) {
						for (i=0;i<G_nocont[ablev];i++) {
							if ((lev[ablev].G_cont[i].to==abit)&&(lev[ablev].G_cont[i].from==lev[G_nowlev].G_elem[from].ident)) {
								strcpy(tmp,lev[ablev].G_cont[i].text);
							}
						}
					}*/
					t.text=malloc(strlen(tmp)+1);
					strcpy(t.text,tmp);
					/* text position is mid point on middle line */
					t.tpos.x=((mid(points[cur/2][0],points[(cur/2)+1][0]))/G_snapto)*G_snapto;
					t.tpos.y=((mid(points[cur/2][1],points[(cur/2)+1][1])-10)/G_snapto)*G_snapto;
					t.pos.x=points[0][0];        /* start point of line  */
					t.pos.y=points[0][1];
					t.flags.TXTON=1;
					t.flags.TYPE=1;              /* line type */
					t.flags.LCOL=G_lcol;         /* def colours */
					t.flags.TCOL=G_tcol;
					t.flags.DIR=d;               /* start dir HORIZ/VERT */
					t.points=(int far *)malloc(cur*sizeof(int));
					j=1;						/* Counter for points */
					for (i=0;i<cur;i++) {
						if (i&1) {		        /* counter for t.points (ignores two in a row) */
							/* If going in same direc as last time */
							if (points[i+j][(d!=1)]==points[i+j+1][(d!=1)])	{
								j++;
								cur--;
							}
							t.points[i]=points[i+j][(d==1)];
						}
						else {
							if (points[i+j][(d==1)]==points[i+j+1][(d==1)]) {
								j++;
								cur--;
							}
							t.points[i]=points[i+j][(d!=1)];
						}
					}
					t.flags.NOPNT=cur;		/* total real points on line */
					addcont(&t);			/* Adds to global bits */
					free(t.points);
					free(t.text);
					mousecur(0);
					clearviewport();
					redraw(1);
					mousecur(1);
				}
				else {		/* line not valid redraw old screen */
					xit=1;
					mousecur(0);
					clearviewport();
					redraw(1);
					mousecur(1);
				}
			}
		}
	}
}



/******			An clever line drawing routine    by mark. mark wrote it he did */
/* find which quadrant we are in and which line we are nearest to then
	draw correct line .   Sinch really */

void dln(int x,int y,int ix,int iy,int ih,int iw) {
	int mx,my;
	mx=msex;
	my=msey;
	if (mx>=x) {
		if (my>=y) {							/* BOTTOM RIGHT Q */
			if ((mx-x)>(my-y)) {            	/* go right */
				if ((mx-WINX)>(ix+(iw/2))) {
					movto(0,ix+(iw/2),y-WINY);
					linto(0,mx-WINX,y-WINY);
				}
			}
			else {
				if ((my-WINY)>iy+ih) {			/* go down */
					movto(0,x-WINX,iy+ih);
					linto(0,x-WINX,my-WINY);
				}
			}
		}						/* etc etc yawn yawn boring boring ... ad infinitum */
		else {									/* TOP RIGHT Q */
			if ((mx-x)>(y-my)) {
				if ((mx-WINX)>(ix+(iw/2))) {
					movto(0,ix+(iw/2),y-WINY);
					linto(0,mx-WINX,y-WINY);
				}
			}
			else {
				if ((my-WINY)<iy) {
					movto(0,x-WINX,iy);
					linto(0,x-WINX,my-WINY);
				}
			}
		}
	}
	else {
		if (my>=y) {							/* BOTTOM LEFT Q */
			if ((x-mx)>(my-y)) {
				if ((mx-WINX)<(ix-(iw/2))) {
					movto(0,ix-(iw/2),y-WINY);
					linto(0,mx-WINX,y-WINY);
				}
			}
			else {
				if ((my-WINY)>iy+ih) {
					movto(0,x-WINX,iy+ih);
					linto(0,x-WINX,my-WINY);
				}
			}
		}
		else {									/* TOP LEFT Q */
			if ((x-mx)>(y-my)) {
				if ((mx-WINX)<(ix-(iw/2))) {
					movto(0,ix-(iw/2),y-WINY);
					linto(0,mx-WINX,y-WINY);
				}
			}
			else {
				if ((my-WINY)<iy) {
					movto(0,x-WINX,iy);
					linto(0,x-WINX,my-WINY);
				}
			}
		}
	}
}


/* is line valid between elements f and t */
int chkline(int f,int t) {
	switch(lev[G_nowlev].G_elem[f].type) {
/*			Element types are
			 1 			 DFD Menu Box
			 2 			 DFD Process Box
			 3 			 DFD Port Box
			 4 			 DFD Supervisor Box
			 5 			 DFD Alarm /Calendar Box
			 6 			 DFD Report Box
			 7 			 DFD Printer Box
			 8 			 DFD Data Store Box
			 9 			 DFD Entity Box
			 10			 DFD Duplicate-Process Box
			 11			 PSD Normal Box
			 12			 PSD OR Box
			 13			 PSD Loop Box
			 14			 PSD Subroutine Box
			 15			 IDS Menu Box
			 16			 IDS Form Box
			 17			 IDS Hot Key Box
			 18			 IDS Function Box
			 19			 TDS Form Box
			 20			 TDS Window Box
			 21			 Imported Flow
			 22			 Title Box				*/
		case 1 : {
				switch (lev[G_nowlev].G_elem[t].type) {
				case 2 :
				case 3 :
				case 4 :
				case 5 :
				case 6 :
				case 7 :
				case 8 :
				case 9 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 2 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 1 :
				case 2 :
				case 3 :
				case 4 :
				case 5 :
				case 6 :
				case 7 :
				case 8 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 3 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 2 :
				case 9 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 4 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 1 :
				case 2 :
				case 7 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 5 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 1 :
				case 2 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 6 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 7 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 7 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 9 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 8 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 1 :
				case 2 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 9 : {
			switch (lev[G_nowlev].G_elem[t].type) {
				case 1 :
				case 3 : {
					return(1);
				}
				default : {
					return(0);
				}
			}
		}
		case 10 :
		case 11 :
		case 12 :
		case 13 :
		case 14 : {
			return(0);
		}
	}
	return(1);
}

/* is any part of l,r,t,b  with in l1,r1,t1,b1			thats x,x1,y,y1 */
int boxinbox(int l,int l1,int r,int r1,int t,int t1,int b,int b1) {
	if (G_ltype) return(1);
	if ((l<l1)&&((t<t1)||(b>b1))) return(0);
	if ((r>r1)&&((t<t1)||(b>b1))) return(0);
	if ((t<t1)&&((l<l1)||(r>r1))) return(0);
	if ((b>b1)&&((l<l1)||(r>r1))) return(0);
	return(1);
}

/* puts an icon on a screen */
void puticon(int x,int y,int icon,int mode,int col) {
	int i,j;
	unsigned char *t=MK_FP(0xA000,0);	/* segment,offset of vga,ega screen */
	union {
		unsigned char *t;
		unsigned long *l;
	} s;
	if (icon==(-1)) return;
	for (i=0;i<4;i++) {
		outportb(0x3CE,4);   /*set read plane */
		outportb(0x3CF,i); /* 0,1,2,3 */
		outportb(0x3C4,2);   /* set write plane */
		outportb(0x3C5,1<<i); /* 1,2,4,8 */
		if (col&(1<<i)) {		/* for each bit in colour */
			for (j=0;j<32;j++) {    /* if set */
				s.t=t+(x/8)+((y+j)*80);			/* get pos on screen */
				if (mode) *(s.l)=(long)G_icon[icon][j]^0xFFFFFFFFL; /* and dump it */
				else *(s.l)=(long)G_icon[icon][j];
			}
		}
		else {
			for (j=0;j<32;j++) {    /* get pos and put in 0 */
				s.t=t+(x/8)+((y+j)*80);
				*(s.l)=0L;
			}
		}
	}
	i=getpixel(0,0);
	putpixel(0,0,col);
	putpixel(0,0,i);
}

/* works out height of text for box adjustment */
int psdtextht(char *text) {
	char *t,*st,tmp[50];
	int i;
	st=malloc(strlen(tpsdln(text))+2);
	strcpy(st,tpsdln(text));
	t=strtok(st," \n\r");
	i=2;
	tmp[0]=0;
	while (t!=(char *)NULL) {
		strcat(tmp,t);
		strcat(tmp," ");
		if (strlen(tmp)>20) {
			sprintf(tmp,"%s ",t);
			i++;
		}
		t=strtok((char *)NULL," \n\r");
	}
	free(st);
	return(i);
}

/* Draw a process box - any sort */
void procbx(int type,shape *e,int dotext,int wid,int hgt) {
	char textln[400];
	int i;
	/* outline */
	linto(type,e->xpos+(wid-5),e->ypos);
	linto(type,e->xpos+wid,e->ypos+5);
	linto(type,e->xpos+wid,e->ypos+(hgt-5));
	linto(type,e->xpos+(wid-5),e->ypos+hgt);
	linto(type,e->xpos-(wid-5),e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+(hgt-5));
	linto(type,e->xpos-wid,e->ypos+5);
	linto(type,e->xpos-(wid-5),e->ypos);
	linto(type,e->xpos,e->ypos);
	movto(type,e->xpos-wid,e->ypos+(hgt/4));
	linto(type,e->xpos+wid,e->ypos+(hgt/4));
	movto(type,e->xpos-(wid-(hgt/4)),e->ypos);
	linto(type,e->xpos-(wid-(hgt/4)),e->ypos+(hgt/4));
	for (i=e->xpos+(wid-(hgt/4));i<e->xpos+wid;i+=2) {
		movto(type,i,e->ypos+(i>(e->xpos+wid-5))*(5-(e->xpos+wid-i)));
		linto(type,i,e->ypos+(hgt/4));
	}
	if (dotext) {
		if ((e->type<4)||(e->type>7)) {		/* do normal text */
			settextjustify(1,2);
			textln[1]=0;
			textln[0]=G_proctypes[e->type-1];
			outtxtxy(e->xpos-(wid-10),e->ypos+5,textln);
			outixy(e->xpos,e->ypos+5,e->ident);
		}
		else {                            /* Do Big letters */
			setcolor(e->colour>>4);
			settextjustify(1,1);
			settextstyle(2,0,20);
			if (e->type==5) {
			   textln[0]='C';
			   textln[1]='-';
			   textln[2]='A';
			   textln[3]=0;
			}
			else {
				textln[1]=0;
				textln[0]=G_proctypes[e->type-1];
			}
			outtxtxy(e->xpos,e->ypos+(hgt/2),textln);
			outtxtxy(e->xpos,e->ypos+(hgt/2)+1,textln);
			outtxtxy(e->xpos+1,e->ypos+(hgt/2),textln);
			outtxtxy(e->xpos+1,e->ypos+(hgt/2)+1,textln);
			settextjustify(1,2);
			settextstyle(2,0,4);
		}
	}
}

/* datastore box */
void dstbx(int type,shape *e,int dotext,int wid,int hgt) {
	movto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos+wid,e->ypos+hgt);
	if (dotext) {
		movto(type,e->xpos-(wid-(hgt/2)),e->ypos);
		linto(type,e->xpos-(wid-(hgt/2)),e->ypos+hgt);
		settextjustify(1,1);
		outixy(e->xpos-(wid-(hgt/4)),e->ypos+(hgt/2),e->ident);
		settextjustify(1,2);
	}
}

/* draw entity box */
void entbx(int type,shape *e,int dotext,int wid,int hgt) {
	int i;
	linto(type,e->xpos+(wid-5),e->ypos);
	linto(type,e->xpos+(wid-5),e->ypos+(hgt-5));
	linto(type,e->xpos-wid,e->ypos+(hgt-5));
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		for (i=0;i<5;i++) {
			movto(type,e->xpos+wid-i,e->ypos+5);
			linto(type,e->xpos+wid-i,e->ypos+hgt-i);
			linto(type,e->xpos-(wid-5),e->ypos+hgt-i);
		}
	}
}

/* duplicate process box */
void dprocbx(int type,shape *e,int dotext,int wid,int hgt) {
	linto(type,e->xpos+(wid-5),e->ypos);
	linto(type,e->xpos+wid,e->ypos+5);
	linto(type,e->xpos+wid,e->ypos+(hgt-5));
	linto(type,e->xpos+(wid-5),e->ypos+hgt);
	linto(type,e->xpos+(wid-10),e->ypos+hgt);
	movto(type,e->xpos-wid,e->ypos+(hgt/4));
	linto(type,e->xpos-wid,e->ypos+5);
	linto(type,e->xpos-(wid-5),e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		movto(type,e->xpos-wid,e->ypos+(hgt/4));
		linto(type,e->xpos+wid,e->ypos+(hgt/4));
		movto(type,e->xpos-(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos-(wid-(hgt/4)),e->ypos+(hgt/4));
		movto(type,e->xpos+(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos+(wid-(hgt/4)),e->ypos+(hgt/4));
		settextjustify(1,2);
		outixy(e->xpos,e->ypos+5,e->ident);
	}
}

/* PSD Normal box */
void psdnbx(int type,shape *e,int dotext,int wid,int hgt) {
	char textln[400];
	int i;
	union {
		char *c;
		int  *i;
	} u;
	if ((i=psdtextht(e->text))>6) hgt=10*(i+1);
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		u.c=e->text+1;
		if (*e->text!='C' || ((*u.i!=0)&&(*u.i!=1))) {	/* if not command or not IF/CP do err seq */
			movto(type,e->xpos-wid,e->ypos+(4*(hgt/5)));
			linto(type,e->xpos+wid,e->ypos+(4*(hgt/5)));
			setcolor(e->colour>>4);
			settextjustify(0,2);
			sprintf(textln,"BAD ERROR SEQUENCE");
			if (e->ident==(-1)) {
				sprintf(textln,"On Error DEF_ERR_SEQ");
			}
			else {
				if (e->ident==0) {
					sprintf(textln,"NO ERROR SEQUENCE");
				}
				else {
					for(i=0;i<G_noseqs;i++) {
						if (G_seqs[i].seq==e->ident) {
							sprintf(textln,"On Error %s",tpsdln(G_seqs[i].name));
							break;
						}
					}
				}
			}
			textln[21]=0;
			outtxtxy((e->xpos-wid)+2,e->ypos+1+(4*(hgt/5)),textln);
		}
	}
}

/* PSD or box */
void psdobx(int type,shape *e,int wid,int hgt) {
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	movto(type,e->xpos+(wid-7),e->ypos+2);
	linto(type,e->xpos+(wid-7),e->ypos+6);
	linto(type,e->xpos+(wid-3),e->ypos+6);
	linto(type,e->xpos+(wid-3),e->ypos+2);
	linto(type,e->xpos+(wid-7),e->ypos+2);
}

/* PSD loop box */
void psdlbx(int type,shape *e,int dotext,int wid,int hgt) {
	char textln[400];
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	movto(type,e->xpos-wid,e->ypos+(4*(hgt/5)));
	linto(type,e->xpos+wid,e->ypos+(4*(hgt/5)));
	movto(type,e->xpos+(wid-7),e->ypos+2);
	linto(type,e->xpos+(wid-3),e->ypos+6);
	movto(type,e->xpos+(wid-3),e->ypos+2);
	linto(type,e->xpos+(wid-7),e->ypos+6);
	movto(type,e->xpos+(wid-5),e->ypos+2);
	linto(type,e->xpos+(wid-5),e->ypos+6);
	movto(type,e->xpos+(wid-3),e->ypos+4);
	linto(type,e->xpos+(wid-7),e->ypos+4);
	if (dotext&&e->ident!=(-1)&&e->ident<G_noutl) {
		setcolor(e->colour>>4);
		settextjustify(0,2);
		strcpy(textln,tpsdln(G_utl[e->ident]));
		textln[20]=0;
		outtxtxy((e->xpos-wid)+2,e->ypos+1+(4*(hgt/5)),textln);
	}
}

/* PSD subroutine box */
void psdsbx(int type,shape *e,int wid,int hgt) {
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	movto(type,e->xpos+(wid-3),e->ypos+2);
	linto(type,e->xpos+(wid-7),e->ypos+2);
	linto(type,e->xpos+(wid-7),e->ypos+4);
	linto(type,e->xpos+(wid-3),e->ypos+4);
	linto(type,e->xpos+(wid-3),e->ypos+6);
	linto(type,e->xpos+(wid-7),e->ypos+6);
}

/* IDS menu box */
void idsmbx(int type,shape *e,int dotext,int wid,int hgt) {
	linto(type,e->xpos+(wid-(hgt/2)),e->ypos);
	linto(type,e->xpos+wid,e->ypos+(hgt/2));
	linto(type,e->xpos+(wid-(hgt/2)),e->ypos+hgt);
	linto(type,e->xpos-(wid-(hgt/2)),e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+(hgt/2));
	linto(type,e->xpos-(wid-(hgt/2)),e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		movto(type,e->xpos-(wid-(hgt/4)),e->ypos+(hgt/4));
		linto(type,e->xpos+(wid-(hgt/4)),e->ypos+(hgt/4));
		movto(type,e->xpos-(wid-((hgt/4)*3)),e->ypos);
		linto(type,e->xpos-(wid-((hgt/4)*3)),e->ypos+(hgt/4));
		movto(type,e->xpos+(wid-((hgt/4)*3)),e->ypos);
		linto(type,e->xpos+(wid-((hgt/4)*3)),e->ypos+(hgt/4));
		outixy(e->xpos,e->ypos+5,e->ident);
	}
}

/* IDS form box */
void idsfbx(int type,shape *e,int dotext,int wid,int hgt) {
	linto(type,e->xpos+(wid-5),e->ypos);
	linto(type,e->xpos+wid,e->ypos+5);
	linto(type,e->xpos+wid,e->ypos+(hgt-5));
	linto(type,e->xpos+(wid-5),e->ypos+hgt);
	linto(type,e->xpos-(wid-5),e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+(hgt-5));
	linto(type,e->xpos-wid,e->ypos+5);
	linto(type,e->xpos-(wid-5),e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		movto(type,e->xpos-wid,e->ypos+(hgt/4));
		linto(type,e->xpos+wid,e->ypos+(hgt/4));
		movto(type,e->xpos-(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos-(wid-(hgt/4)),e->ypos+(hgt/4));
		movto(type,e->xpos+(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos+(wid-(hgt/4)),e->ypos+(hgt/4));
		outixy(e->xpos,e->ypos+5,e->ident);
	}
}

/* IDS hot key box */
void idshbx(int type,shape *e,int wid,int hgt) {
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+(hgt/2));
	linto(type,e->xpos,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+(hgt/2));
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
}

/* IDS  command box */
void idscbx(int type,shape *e,int wid,int hgt) {
	linto(type,e->xpos+(wid-5),e->ypos);
	linto(type,e->xpos+wid,e->ypos+5);
	linto(type,e->xpos+wid,e->ypos+(hgt-5));
	linto(type,e->xpos+(wid-5),e->ypos+hgt);
	linto(type,e->xpos-(wid-5),e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+(hgt-5));
	linto(type,e->xpos-wid,e->ypos+5);
	linto(type,e->xpos-(wid-5),e->ypos);
	linto(type,e->xpos,e->ypos);
}

/* TDS Box */
void tdsbx(int type,shape *e,int dotext,int wid,int hgt) {
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		movto(type,e->xpos-wid,e->ypos+(hgt/4));
		linto(type,e->xpos+wid,e->ypos+(hgt/4));
		movto(type,e->xpos-(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos-(wid-(hgt/4)),e->ypos+(hgt/4));
		movto(type,e->xpos+(wid-(hgt/4)),e->ypos);
		linto(type,e->xpos+(wid-(hgt/4)),e->ypos+(hgt/4));
		movto(type,e->xpos-wid,e->ypos+(3*(hgt/4)));
		linto(type,e->xpos+wid,e->ypos+(3*(hgt/4)));
		movto(type,e->xpos,e->ypos+(3*(hgt/4)));
		linto(type,e->xpos,e->ypos+hgt);
		outcxy(e->xpos+(wid-(hgt/8)),e->ypos+5,G_fldtypes[e->level&15]);
		outixy(e->xpos+(wid-(hgt/4)),e->ypos+(7*(hgt/8)),((e->level>>4)&31));
		outixy(e->xpos-(wid-(hgt/4)),e->ypos+(7*(hgt/8)),((e->level>>9)&127));
		outixy(e->xpos,e->ypos+5,e->ident);
		if (e->type==19) outcxy(e->xpos-(wid-(hgt/8)),e->ypos+5,'W');
	}
}

/*  Imported flow box */
void infbx(int type,shape *e,int dotext,int wid,int hgt) {
	linto(type,e->xpos+wid,e->ypos+hgt/2);
	linto(type,e->xpos,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt/2);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		setcolor(e->colour>>4);
		settextjustify(1,2);
		outcxy(e->xpos,e->ypos+5,G_proctypes[lev[G_nowlev].G_elem[e->ident].type-1]);
	}
}

/* title box */
void titbx(int type,shape *e,int dotext,int wid,int hgt) {
	time_t tt;
	char textln[400];
	linto(type,e->xpos+wid,e->ypos);
	linto(type,e->xpos+wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos+hgt);
	linto(type,e->xpos-wid,e->ypos);
	linto(type,e->xpos,e->ypos);
	if (dotext) {
		movto(type,e->xpos-wid,e->ypos+hgt/4);
		linto(type,e->xpos+wid,e->ypos+hgt/4);
		movto(type,(e->xpos-wid)+G_wid[1],e->ypos+hgt/4);
		linto(type,(e->xpos-wid)+G_wid[1],e->ypos+hgt);
		setcolor(e->colour>>4);
		settextjustify(1,2);
		sprintf(textln,"P.M.A. Task Define - Task Centre Configuration Tool");
		outtxtxy(e->xpos,e->ypos+2,textln);
		sprintf(textln,"Cell Controller %s",G_cellname);
		outtxtxy(e->xpos,e->ypos+12,textln);
		settextjustify(0,2);
		sprintf(textln,"Drawn By  %s","Andy Mayes");
		outtxtxy((e->xpos-wid)+G_wid[1]+5,e->ypos+32,textln);
		sprintf(textln,"For       %s","Lansing Linde Limited.");
		outtxtxy((e->xpos-wid)+G_wid[1]+5,e->ypos+52,textln);
		tt=time(&tt);
		sprintf(textln,"%s",ctime(&tt));
		outtxtxy((e->xpos-wid)+G_wid[1]+5,e->ypos+72,textln);
	}
}