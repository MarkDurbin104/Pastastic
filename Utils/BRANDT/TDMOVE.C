#include <graphics.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <dos.h>
#include "tdef.h"
void boxing(int x,int y);				/* selecting an area */
void moveumto(int stx,int sty);         /* move group of objects */
void changelev(int item,int lt);        /* Change level down */
int calcftype(char type);               /* Calculate from type */
void gentds(shape *e,int item,int noflds);

/* is mouse cursor in a particular area */
int inbox(int x1,int y1,int x2,int y2) {
	if ((msex>x1)&&(msex<x2)&&(msey>y1)&&(msey<y2)) return(1);
	return(0);
}

/* Move screen pos in paper - red is redraw at end or not */
/* Called when button has been clicked somewhere. Returns 1 if in scrollbars */
int movecur(void) {
	int red=0;
	if (inbox(WINX,G_maxy-10,WINX+10,G_maxy)) { /* LEFT  by 1/4 page */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurl((G_maxx-WINX-11)/4);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_maxx-20,G_maxy-10,G_maxx-10,G_maxy)) { /* RIGHT */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurr((G_maxx-WINX-11)/4);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_maxx-10,WINY,G_maxx,WINY+10)) { /* UP */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecuru((G_maxy-WINY-11)/4);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_maxx-10,G_maxy-20,G_maxx,G_maxy-10)) { /*DOWN */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurd((G_maxy-WINY-11)/4);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(WINX+10,G_maxy-10,G_xbos,G_maxy)) { /* LLEFT  by 1 page*/
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurl(G_maxx-WINX-11);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_xtos,G_maxy-10,G_maxx-20,G_maxy)) { /* RRIGHT */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurr(G_maxx-WINX-11);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_maxx-10,WINY+10,G_maxx,G_ytos)) { /* UUP */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecuru(G_maxy-WINY-11);
		if (red) redraw(1);
		return(1);
	}
	if (inbox(G_maxx-10,G_ybos,G_maxx,G_maxy-20)) { /* DDOWN */
		while (((mousetrap(G_snapto)>>5)&&0x07)==1) red=movecurd(G_maxy-WINY-11);
		if (red) redraw(1);
		return(1);
	}
	return(0);
}

/* scroll region of screen left by amount rounded down to G_snapto */
int movecurl(int amount) {
	amount=(amount/G_snapto)*G_snapto;
	if (G_xpos<(0-amount)) {
		G_xpos+=amount;
		tmpdraw();
	}
	else {
		if (G_xpos!=0) {
			G_xpos=0;
			tmpdraw();
		}
	}
	return(1);
}

/* scroll region of screen right by amount rounded down to G_snapto */
int movecurr(int amount) {
	amount=(amount/G_snapto)*G_snapto;
	if (G_xpos>(amount-(G_maxx*WID-(G_maxx-WINX-11)))) {
		G_xpos-=amount;
		tmpdraw();
	}
	else {
		if (G_xpos!=0-(G_maxx*WID-(G_maxx-WINX-11))) {
			G_xpos=0-(G_maxx*WID-(G_maxx-WINX-11));
			tmpdraw();
		}
	}
	return(1);
}

/* scroll region of screen up by amount rounded down to G_snapto */
int movecuru(int amount) {
	amount=(amount/G_snapto)*G_snapto;
	if (G_ypos<(0-amount)) {
		G_ypos+=amount;
		tmpdraw();
	}
	else {
		if (G_ypos!=0) {
			G_ypos=0;
			tmpdraw();
		}
	}
	return(1);
}

/* scroll region of screen down by amount rounded down to G_snapto */
int movecurd(int amount) {
	amount=(amount/G_snapto)*G_snapto;
	if (G_ypos>(amount-(G_maxy*HGT-(G_maxy-WINY-11)))) {
		G_ypos-=amount;
		tmpdraw();
	}
	else {
		if (G_ypos!=0-(G_maxy*HGT-(G_maxy-WINY-11))) {
			G_ypos=0-(G_maxy*HGT-(G_maxy-WINY-11));
			tmpdraw();
		}
	}
	return(1);
}

/* Element selected for movement or double clicked on */
void moveelem(void) {
	int item,i,j,k,l,noflds;
	int fex,fey,cex,cey;
	int count,stx,sty;
	char tmp[100];
	unsigned char far *t=MK_FP(0x0000,0x0417);  /* gives shft/alt/ctrl status */
	shape *e=lev[G_nowlev].G_elem;	/* elements on current level */
	join *c=lev[G_nowlev].G_cont;	/* lines on current level */
	int *s=G_selected;                  /* array on items currently selected */
	union {
		char *c;
		int  *i;
	} u;

	mousecur(0);
	if ((item=findelem())!=(-1)) {		/* if not on element bog off */
		if (G_lsel!=(-1)) {             /* If line selected then deselect it */
			c[G_lsel].flags.LCOL^=1;    /* change color of line back to original */
			drcont(1,G_xpos,G_ypos,&(c[G_lsel]),1); /* Draw it */
			G_lsel=(-1);
		}
		if ((e[item].type>10)&&(e[item].type<17)) { /* If PSD or IDS do tree style selection */
			e[item].colour^=0x11;				/* toggle text + line cols */
			drelem(1,G_xpos,G_ypos,&(e[item]),1);  /* redraw quick */
			for (i=0;i<G_noselc;i++) {             /* repeat for all currently selected to deselect them*/
				e[s[i]].colour^=0x11;
				drelem(1,G_xpos,G_ypos,&(e[s[i]]),1);
			}
			if ((*t)&0x0f) {					/* If Alt / shft / cntl */
				G_noselc=0;
				if ((*t)&3) getsubsels(item);  /* If Shift */
				else if ((*t)&4) getsidsels(item);  /* If cntl */
					else if ((*t)&8) getrsidsels(item); /* If alt */
			}
			else {                       /* one item only */
				e[item].colour^=0x11;
				drelem(1,G_xpos,G_ypos,&(e[item]),1);
				G_noselc=1;
				s[0]=item;
			}
		}
		else {				/* if not PSD / IDS */
			if ((*t)&3) {         /* shift means toggle current in/out */
				for (i=0;i<G_noselc;i++) {	/* see if item is there */
					if (s[i]==item) {
						break;
					}
				}
				if (i==G_noselc) {			/* If it isn't add it to end */
					s[G_noselc++]=item;
				}
				else {                      /* else shuffle down */
					G_noselc--;
					for (j=i;j<G_noselc;j++) s[j]=s[j+1];
				}
			}
			else {                        /* toggle my colour off if selected already */
				for (i=0;i<G_noselc;i++) {
					if (s[i]==item) {
						e[s[i]].colour^=0x11;
						break;
					}
				}
				if (i==G_noselc) {        /* toggle all selected off and reselect current */
					for (i=0;i<G_noselc;i++) {
						e[s[i]].colour^=0x11;
						drelem(1,G_xpos,G_ypos,&(e[s[i]]),1);
					}
					G_noselc=1;
					s[0]=item;
				}
			}
		}
		e[item].colour^=0x11;
		stx=msex;						/* start pos for mouse */
		sty=msey;
			 /* if mse has moved move outlines for all selected items */
		if (mousestat(G_snapto)&0x0F) moving(stx,sty);
		while (((mousestat(G_snapto)>>5)&&7)==1) {		/* while mouse button pressed */
			if (mousestat(G_snapto)&0x0F) { /* moved */
				moving(stx,sty);            /* delete old */
				mousetrap(G_snapto);        /* update globals */
				moving(stx,sty);            /* draw new */
			}
		}
		if ((msex!=stx)||(msey!=sty)) {    /* if overall move then moveum (Good Grief Charlie Brown) */
			moveumto(stx,sty);
		}
		count=0;
		drelem(1,G_xpos,G_ypos,&(e[item]),1);	/* put curnt elm col bk 2 nrml */
		while ((((mousestat(G_snapto)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
		if (count!=CLICKRATE) {							/* double click */
			switch(e[item].type) {
				case 1 : {						/* Menu */
					changelev(item,3);          /* Down to level type 3 (IDS)*/
				} break;
				case 2 : {                      /* Process box */
					changelev(item,2);          /* Dwn 2 lt2 (DFD/PSD) */
					if (G_lused[G_nowlev]==1) G_inpsd=1;
				} break;
				case 6 : {                      /* Report process */
					for (i=0;i<G_noselc;i++) e[s[i]].colour^=0x11;
					G_noselc=0;
					repdef(item);
					cls();
					markpoints();
					redraw(1);
				} break;
				case 8 : {           			/* Datastore box */
					dstoredef(item);
					cls();
					markpoints();
					e[item].colour^=0x11;
					G_noselc--;
					redraw(1);
				} break;
				case 15 :
				case 16 : {			/* if Menu or Form */
					if (e[item].type==15) strcpy(tmp,"MENU.TEXT"); else strcpy(tmp,"FORM.TDS.TEXT");
					switch(popup(50,150,300,70,"Select Menu/Form Definition",0,tmp)) {
						case 0 : {		/* menu or form */
							for (i=0;i<G_noselc;i++) e[s[i]].colour^=0x11;
							G_noselc=0;
							mousecur(0);
							if (e[item].type==15)  mnudef(item);
							else
							{	noflds=frmdef(item);
								gentds(e,item,noflds);
							}
/*							cls();
							markpoints();
							redraw(1); */
						} break;
						case 1 : {		/* menu TEXT or form TDS */
							for (i=0;i<G_noselc;i++) e[s[i]].colour^=0x11;
							G_noselc=0;
							if (e[item].type==15) {
								mousecur(0);
								clearviewport();
								redraw(1);
								selelem(0);
								setmcurto(0);
								mousecur(1);
								G_elemt=0;
							}
							else {
								mousecur(0);
								e[item].colour^=0x11;
								changelev(item,4);
								mousecur(1);
							}
						} break;
						default : {      /* Form Text */
							mousecur(0);
							clearviewport();
							redraw(1);
							mousecur(1);
							G_elemt=0;
						}
					}
				} break;
				case 14 : { 		/* PSD subroutine */
								/* If subroutine at top (Has line coming FROM it ) do nothing */
					for (i=0;i<G_nocont[G_nowlev];i++) if (lev[G_nowlev].G_cont[i].from==item) break;
					if (i==G_nocont[G_nowlev]) changelev(item,5);
				} break;
				case 13 : {			/* PSD Loop box */
					psddef(item);
					cls();
					markpoints();
					e[item].colour^=0x11;
					G_noselc--;
					redraw(1);
					mousecur(1);
				} break;
				case 11 : {       /* PSD Normal */
					l=0;
					if (lev[G_nowlev].G_elem[item].text[0]=='C') { /* If command */
						u.c=&lev[G_nowlev].G_elem[item].text[1];   /* get cmd type */
						if (*u.i<2) l=1;        /* if IF or CP ... */
					}
					if (lev[G_nowlev].G_elem[item].ident==0) l=1; /* or no error seq cant go down*/
					/* if inside bottom section and allowed then down a lev */
					if (((msey-WINY)>(lev[G_nowlev].G_elem[item].ypos+48)+G_ypos)&&(l==0)) {
						changelev(item,5);
					}
					else {		/* Else define a PSD line */
						psddef(item);
						cls();
						markpoints();
						e[item].colour^=0x11;
						G_noselc--;
						redraw(1);
						mousecur(1);
					}
				} break;
			}
			selelem(0);		/* Select current icon*/
			setmcurto(0);	/* set cursor to pointer */
		}
		else {    /* Else single click */
		}
	}
	else {					/* not on an element check if we are on a line */
		if ((item=findcont())==(-1)) {		/* not on line are we on text */
			if ((item=findtext())!=(-1)) {	/* Yipee found something to do */
				if (G_noselc!=0) {          /* if stuff selected get rid of it */
					for (i=0;i<G_noselc;i++) {
						e[s[i]].colour^=0x11;
						drelem(1,G_xpos,G_ypos,&(e[s[i]]),1);
					}
					G_noselc=0;
				}
				if (G_lsel!=(-1)) {				/* if line selected deselect */
					c[G_lsel].flags.LCOL^=1;
					drcont(1,G_xpos,G_ypos,&(c[G_lsel]),1);
					G_lsel=(-1);
				}
				drcont(0,G_xpos,G_ypos,&(c[item]),0);	/* Draw line in diff col */
				settextjustify(1,2);
				setmousexto(c[item].tpos.x+WINX+G_xpos);	/* put mouse on correct pos */
				setmouseyto(c[item].tpos.y+WINY+G_ypos);
				c[item].tpos.x=msex-WINX+(0-G_xpos);		/* Make sure text is snapped */
				c[item].tpos.y=msey-WINY+(0-G_ypos);
				setcolor(c[item].flags.TCOL^1);
				outtxtxy(c[item].tpos.x+G_xpos,c[item].tpos.y+G_ypos,c[item].text);
				while (mseb) {
					if (mousestat(G_snapto)!=32) { /* while moving and msebut */
						setcolor(0);
						outtxtxy(c[item].tpos.x+G_xpos,c[item].tpos.y+G_ypos,c[item].text);
						mousetrap(G_snapto);
						c[item].tpos.x=msex-WINX+(0-G_xpos);
						c[item].tpos.y=msey-WINY+(0-G_ypos);
						setcolor(c[item].flags.TCOL^1);
						outtxtxy(c[item].tpos.x+G_xpos,c[item].tpos.y+G_ypos,c[item].text);
					}
				}
/*				clearviewport();*/
				redraw(0);
			}
			else {			/* not on nothing. Draw select box on screen */
				stx=msex;
				sty=msey;
				if (!G_inpsd) {
					boxing(stx,sty);		/* draw first box */
					while (((mousestat(G_snapto)>>5)&&7)==1) {
						if (mousestat(G_snapto)&0x0F) {
							boxing(stx,sty);
							mousetrap(G_snapto);
							boxing(stx,sty);
						}
					}
					boxing(stx,sty);
					fex=max(stx,msex);
					cex=min(stx,msex);
					fey=max(sty,msey);
					cey=min(sty,msey);
					if (!((*t)&3)) {     /* If Not shift */
						if (G_noselc!=0) {  /* If some selected get rid */
							for (i=0;i<G_noselc;i++) {
								e[s[i]].colour^=0x11;
								drelem(1,G_xpos,G_ypos,&(e[s[i]]),1);
							}
							G_noselc=0;
						}
					}
					if (G_lsel!=(-1)) {       /* Dump line selected */
						c[G_lsel].flags.LCOL^=1;
						drcont(1,G_xpos,G_ypos,&(c[G_lsel]),1);
						G_lsel=(-1);
					}
					for (i=0;i<G_noelem[G_nowlev];i++) { /* For all elements on layer */
						/* Check to see if element in box totally */
						if((e[i].xpos+(G_wid[e[i].type]/2)<((0-G_xpos)+(fex-WINX)))
						&& (e[i].xpos-(G_wid[e[i].type]/2)>((0-G_xpos)+(cex-WINX)))
						&& (e[i].ypos>((0-G_ypos)+(cey-WINY)))
						&& (e[i].ypos+G_hgt[e[i].type]<((0-G_ypos)+(fey-WINY)))) {
							/* if yes reverse current selection */
							e[i].colour^=0x11;
							drelem(1,G_xpos,G_ypos,&(e[i]),1);
							for (j=0;j<G_noselc;j++) {
								if (s[j]==i) {
									break;
								}
							}
							if (j==G_noselc) {
								s[G_noselc++]=i;
							}
							else {
								G_noselc--;
								for (k=j;k<G_noselc;k++) s[k]=s[k+1];
							}
						}
					}
				}
			}
		}
		else {				/* On a line */
			/* 	If double click then go to msgdef */
			while ((((mousestat(G_snapto)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
			if (count!=CLICKRATE) {
				msgdef(item);
				mousecur(0);
				cls();
				markpoints();
				redraw(1);
			}
			else {
				if (G_lsel!=(-1)) {
					c[G_lsel].flags.LCOL^=1;
					drcont(1,G_xpos,G_ypos,&(c[G_lsel]),1);
				}
				c[item].flags.LCOL^=1;
				G_lsel=item;

				if (G_noselc!=0) {					/* deselect elements */
					for (i=0;i<G_noselc;i++) {
						e[s[i]].colour^=0x11;
						drelem(1,G_xpos,G_ypos,&(e[s[i]]),1);
					}
					G_noselc=0;
				}
				while (mseb) {					/* while button move line */
					drcont(0,G_xpos,G_ypos,&(c[item]),0);
					mousetrap(G_snapto);
					if (!G_partln.dir) {            /* Filled by find line */
						if (G_partln.pos==(-1)) {   /* if first point change start point */
							c[item].pos.y=msey-WINY+(0-G_ypos);
						}
						else {		/* else change point along line */
							c[item].points[G_partln.pos]=msey-WINY+(0-G_ypos);
						}
					}
					else {			/* same as above in other plane */
						if (G_partln.pos==(-1)) {
							c[item].pos.x=msex-WINX+(0-G_xpos);
						}
						else {
							c[item].points[G_partln.pos]=msex-WINX+(0-G_xpos);
						}
					}
					drcont(0,G_xpos,G_ypos,&(c[item]),0);
				}
				count=0;
				clearviewport();
				redraw(1);
			}
		}
	}
    mousecur(1);
}

/* Redraw selected - if PSD then don't allow down move */
void moving(int x,int y) {
	int j;
	int xx,yy;
	xx=msex-x;
	yy=msey-y;
	for (j=0;j<G_noselc;j++) {
		if ((lev[G_nowlev].G_elem[G_selected[j]].type>10)&&(lev[G_nowlev].G_elem[G_selected[j]].type<15)) {
			drelem(0,G_xpos+xx,G_ypos,&(lev[G_nowlev].G_elem[G_selected[j]]),0);
		}
		else {
			drelem(0,G_xpos+xx,G_ypos+yy,&(lev[G_nowlev].G_elem[G_selected[j]]),0);
		}
	}
}

/*  draw an XORed box */
void boxing(int x,int y) {
	int x1,x2,y1,y2;
	x1=x-WINX;
	x2=msex-WINX;
	y1=y-WINY;
	y2=msey-WINY;
	movto(0,x1,y1);
	linto(0,x2,y1);
	linto(0,x2,y2);
	linto(0,x1,y2);
	linto(0,x1,y1);
}

/* Heap big move function. Moves all boxes and adjust lines */
void moveumto(int stx,int sty) {
	int i,j,k,l;
	shape *e=lev[G_nowlev].G_elem;
	join *c=lev[G_nowlev].G_cont;
	int *s=G_selected;
	for (i=0;i<G_noselc;i++) {			/* For all selected */
		e[s[i]].xpos+=msex-stx;         /* Xpos += curr_msex-start_msex */
		if ((e[s[i]].type<11)||(e[s[i]].type>14)) {	/* only do y if not PSD */
			e[s[i]].ypos+=msey-sty;
		}
		else {
			setmouseyto(sty);
		}
		for (j=0;j<G_nocont[G_nowlev];j++) {      /* for all lines on this level */			l=0;
			for (k=0;k<G_noselc;k++) {			/* if both ends moved l=1 */
				if ((c[j].to==s[i])
				&&	(c[j].from==s[k])) {
					l=1;
				}
				if ((c[j].from==s[i])           /* Only move text/line once */
				&&	(c[j].to==s[k])) {
					c[j].pos.x+=msex-stx;       /* start pos */
					c[j].pos.y+=msey-sty;
					c[j].tpos.x+=msex-stx;      /*text pos */
					c[j].tpos.y+=msey-sty;
					if (c[j].flags.DIR==1) {     /* adjust bits HORIZ or VERT */
						for (l=0;l<c[j].flags.NOPNT;l++) {
							if (l&1) {
								c[j].points[l]+=msey-sty;
							}
							else {
								c[j].points[l]+=msex-stx;
							}
						}
					}
					else {
						for (l=0;l<c[j].flags.NOPNT;l++) {
							if (l&1) {
								c[j].points[l]+=msex-stx;
							}
							else {
								c[j].points[l]+=msey-sty;
							}
						}
					}
					l=1;
				}
			}
			if (!l) {		/* if one end not selected then move our end */
				if (c[j].from==s[i]) {		/* if from selected can modify start point */
					if (c[j].flags.NOPNT==1) {   /* if one point split line */
                    		  /* check they haven't just stretched line */
						if ((((msex-stx)!=0)&&(c[j].flags.DIR==0))
						||	(((msey-sty)!=0)&&(c[j].flags.DIR==1))) {
							c[j].points=(int far *)realloc(c[j].points,3*sizeof(int));
							c[j].flags.NOPNT=3;
							c[j].points[2]=c[j].points[0];
							if (c[j].flags.DIR==1) {
								c[j].points[0]=mid(c[j].points[2],c[j].pos.x);
								c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
								c[j].points[1]=c[j].pos.y;
							}
							else {
								c[j].points[0]=mid(c[j].points[2],c[j].pos.y);
								c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
								c[j].points[1]=c[j].pos.x;
							}
						}
					}
					c[j].pos.x+=msex-stx;
					c[j].pos.y+=msey-sty;
				}
				if (c[j].to==s[i]) { /* line to me. Must adjust bits of line */
						/* See if last coord = x */
					if ((c[j].flags.DIR==1)&&(c[j].flags.NOPNT&1)
					||	(c[j].flags.DIR==0)&&(!(c[j].flags.NOPNT&1))) {
						/* Check for single point line */
						if (c[j].flags.NOPNT==1) {
								/* Check for stretch */
							if ((((msex-stx)!=0)&&(c[j].flags.DIR==0))
							||	(((msey-sty)!=0)&&(c[j].flags.DIR==1))) {
									/* add extra points */
								c[j].points=(int far *)realloc(c[j].points,3*sizeof(int));
								c[j].flags.NOPNT=3;
								if (c[j].flags.DIR==1) {
									c[j].points[2]=c[j].points[0]+(msex-stx);
									c[j].points[0]=mid(c[j].points[2],c[j].pos.x);
									c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
									c[j].points[1]=c[j].pos.y+(msey-sty);
								}
								else {
									c[j].points[2]=c[j].points[0]+(msey-sty);
									c[j].points[0]=mid(c[j].points[2],c[j].pos.y);
									c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
									c[j].points[1]=c[j].pos.x+(msex-stx);
								}
							}
							else {
								if (c[j].flags.DIR==1) {
									c[j].points[0]+=(msex-stx);
								}
								else {
									c[j].points[0]+=(msey-sty);
								}
							}
						}
						else {
							c[j].points[c[j].flags.NOPNT-1]+=
								msex-stx;
							c[j].points[c[j].flags.NOPNT-2]+=
								msey-sty;
						}
					}
					else {		/* otherwise last point is y */
								/* See above for comments */
						if (c[j].flags.NOPNT==1) {
							if ((((msex-stx)!=0)&&(c[j].flags.DIR==0))
							||	(((msey-sty)!=0)&&(c[j].flags.DIR==1))) {
								c[j].points=(int far *)realloc(c[j].points,3*sizeof(int));
								c[j].flags.NOPNT=3;
								if (c[j].flags.DIR==1) {
									c[j].points[2]=c[j].points[0]+(msex-stx);
									c[j].points[0]=mid(c[j].points[2],c[j].pos.x);
									c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
									c[j].points[1]=c[j].pos.y+(msey-sty);
								}
								else {
									c[j].points[2]=c[j].points[0]+(msey-sty);
									c[j].points[0]=mid(c[j].points[2],c[j].pos.y);
									c[j].points[0]=(c[j].points[0]/G_snapto)*G_snapto;
									c[j].points[1]=c[j].pos.x+(msex-stx);
								}
							}
							else {
								if (c[j].flags.DIR==1) {
									c[j].points[0]+=(msex-stx);
								}
								else {
									c[j].points[0]+=(msey-sty);
								}
							}
						}
						else {
							c[j].points[c[j].flags.NOPNT-1]+=
								msey-sty;
							c[j].points[c[j].flags.NOPNT-2]+=
								msex-stx;
						}
					}
				}
			}
		}
	}
	clearviewport();
	redraw(1);
}

/* Change down a level :	item is current item, lt is new level type */
void changelev(int item,int lt) {
	int i;
	lev[G_nowlev].x=G_xpos;			/* Save current x/y */
	lev[G_nowlev].y=G_ypos;
			/* Deselect the world */
	for (i=0;i<G_noselc;i++) lev[G_nowlev].G_elem[G_selected[i]].colour^=0x11;
	G_noselc=0;

		/* If this is the first time i have visited this establishment */
	if (lev[G_nowlev].G_elem[item].level<0) {
		if (lt==5) {		/* If PSD (not DFD)*/
			if (lev[G_nowlev].G_elem[item].type==11) {	/* If normal PSD */
				for (i=0;i<G_noseqs;i++) {		/* Go find error seq */
					if (lev[G_nowlev].G_elem[item].ident==G_seqs[i].seq) {
						lev[G_nowlev].G_elem[item].level=G_seqs[i].seq; /*save for next time */
						break;
					}
				}
				/* If seq doesn't exist must be def err seq */
				if (i==G_noseqs) {	/* if DEF_ERR_SEQ sequence does exist */
					for (i=0;i<G_noseqs;i++) {
						if (!strncmp("LDEF_ERR_SEQ^Z",G_seqs[i].name,14)) {
							lev[G_nowlev].G_elem[item].level=G_seqs[i].seq;
							lev[G_nowlev].G_elem[item].ident=lev[G_nowlev].G_elem[item].level;
							break;
						}
					}
							/* else define DEF ERR SEQ */
					if (i==G_noseqs) {
						lev[G_nowlev].G_elem[item].level=addlev();
						lev[G_nowlev].G_elem[item].ident=lev[G_nowlev].G_elem[item].level;
						addseq("LDEF_ERR_SEQ^Z",lev[G_nowlev].G_elem[item].level);
					}
				}
			}		/* Not normal PSD. Going to non error type seq */
			else {
				for (i=0;i<G_noseqs;i++) {		/* If there set level */
					if (!strcmp(lev[G_nowlev].G_elem[item].text,G_seqs[i].name)) {
						lev[G_nowlev].G_elem[item].level=G_seqs[i].seq;
						break;
					}
				}
				if (i==G_noseqs) {		/* else add new one */
					lev[G_nowlev].G_elem[item].level=addlev();
					addseq(lev[G_nowlev].G_elem[item].text,lev[G_nowlev].G_elem[item].level);
				}
			}
		}
		else {		/* must be new level (Non PSD) so add it */
			lev[G_nowlev].G_elem[item].level=addlev();
		}
	}				/* Now have next level in dfggfsdgf.level */
	if (lev[G_nowlev].G_elem[item].level>0) {
		lev[lev[G_nowlev].G_elem[item].level].upper=G_nowlev;	/* set return pointer */
		setlevelto(lev[G_nowlev].G_elem[item].level);	/* goto level */
		G_xpos=lev[G_nowlev].x;		/* Get new bits and pieces */
		G_ypos=lev[G_nowlev].y;
		G_levtype=lt;
	}
	cls();
	markpoints();
	redraw(1);
}

/* sequence off a field name */
int fldseq(char *name) {
	int i,xit,imon=0,red=0,curlev,newlev;
	long fcl;
	curlev=G_nowlev;
	for (i=0;i<G_noseqs;i++) {					/* If sequence already defined*/
		if (!strcmp(G_seqs[i].name,name)) {
			newlev=G_seqs[i].seq;
			break;
		}
	}
	if (i==G_noseqs) {		/* No add one */
		newlev=addlev();
		addseq(name,newlev);
	}
	if (newlev>0) {                /* if got one then go for it */
		lev[newlev].upper=(-2);
		setlevelto(newlev);
	}
	else return(newlev);
	G_xpos=lev[G_nowlev].x;
	G_ypos=lev[G_nowlev].y;
	G_levtype=5;
	cls();
	markpoints();
	redraw(1);
	G_inform=1;
	mousecur(1);
	do {                /* repeat of main loop */
		settextjustify(1,2);
		if (G_dongin) { G_dongin=QD(); if (!G_dongin) fcl=corepr(); }
		if (fcl!=farcoreleft()) fcl=corepr();
		if (mousestat(G_snapto)) {
			imon=updatecur(imon);
			if (mseb==2) colmenu();
			if (mseb==1) chkmpos();
		}
		if (kbhit()) {
			xit=keychk();
			red=xit&2;
		}
		else {
			if (red) {
				red=0;
				mousecur(0);
				redraw(1);
				mousecur(1);
			}
		}
	} while (G_inform);
	G_levtype=3;                /* return to form */
	setlevelto(curlev);
	return(newlev);
}

/* calculate a field type. Mandatory optional .... */
int calcftype(char type) {
	int i;
	for (i=0;i<16;i++) if (G_fldtypes[i]==type) return(i);
	return(0);
}

/* Generate a tds after exit from form */
void gentds(shape *e,int item,int noflds)
{
	int i,j,k,l,w,x;
	char tmp[100],*g;
	shape *f;	/* elements on current level */
	join  joi;	/* lines on current level */

	changelev(item,4);     /* go to TDS  level */
    			/* increase undo level on all level */
	for (i=0;i<G_noelem[G_nowlev];i++) lev[G_nowlev].G_elem[i].deled++;
	for (i=0;i<G_nocont[G_nowlev];i++) lev[G_nowlev].G_cont[i].deled++;
	joi.text=malloc(4);
	strcpy(joi.text,"CR\n");
	joi.points=malloc(12);		/* always enough space */
	addelem();                  /* Add an element first box */
	w=textwidth("8");
	f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
	f->text=realloc(f->text,strlen(e[item].text)+1);
	strcpy(f->text,e[item].text);
	f->type=16;
	f->xpos=100;
	f->ypos=50;
	joi.from=G_noelem[G_nowlev]-1;        /* first line */
	joi.tpos.x=f->xpos+10;                /* text pos */
	joi.tpos.y=f->ypos+G_hgt[16]+5;
	joi.pos.x=f->xpos;                    /* start pos */
	joi.pos.y=f->ypos+G_hgt[16];
	joi.flags.TXTON=0;                    /* don't show text */
	joi.flags.TYPE=1;
	joi.flags.LCOL=G_lcol;
	joi.flags.TCOL=G_tcol;
	joi.flags.DIR=0;                      /* downwards */
	joi.flags.NOPNT=1;
	joi.points[0]=f->ypos+80;
	addcont(&joi);                        /* add it */
	j=0;
	for (i=0;i<noflds;i++) {              /* for all fields on form */
					   /* if simple or text Not table */
		if (G_fflds[i].type=='s' || G_fflds[i].type=='t') {
			addelem();
			f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
			if (G_fflds[i].type=='t')				/* texty bit */
			{	f->text=realloc(f->text,strlen(G_fflds[i].val)+3);
				sprintf(f->text,"%s\n",G_fflds[i].val);
			}
			else
			{	f->text=realloc(f->text,strlen(&G_fflds[i].val[2])+3);
				sprintf(f->text,"%s\n",&G_fflds[i].val[2]);
			}
			f->type=20;                     /* box types and pos */
			f->xpos=100+(((j+1)/5)*130);
			f->ypos=50+(((j+1)%5)*80);
			x=((G_fflds[i].xpos-17)/w);
			/* f->level contains 5|432109|87654|3210
								   xpos   ypos  field type		*/
			f->level=(x<<9)|((G_fflds[i].ypos&31)<<4)|calcftype('T');
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to=G_noelem[G_nowlev]-1;
			joi.from=G_noelem[G_nowlev]-1;         /* do line */
			joi.tpos.x=f->xpos+10;
			joi.tpos.y=f->ypos+G_hgt[16]+5;
			joi.pos.x=f->xpos;
			joi.pos.y=f->ypos+G_hgt[16];
			joi.flags.TXTON=0;
			joi.flags.TYPE=1;
			joi.flags.LCOL=G_lcol;
			joi.flags.TCOL=G_tcol;
			joi.flags.DIR=0;
			if ((j+2)%5) {
				joi.flags.NOPNT=1;
				joi.points[0]=f->ypos+80;
			}
			else {			/* a round the corner type line */
				joi.flags.NOPNT=5;
				joi.points[0]=f->ypos+80;
				joi.points[1]=f->xpos+65;
				joi.points[2]=30;
				joi.points[3]=f->xpos+130;
				joi.points[4]=50;
			}
			addcont(&joi);
			j++;
		}
/*		if (G_fflds[i].type=='t') {
			addelem();
			f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
			f->text=realloc(f->text,strlen(G_fflds[i].val)+3);
			sprintf(f->text,"%s\n",G_fflds[i].val);
			f->type=20;
			f->xpos=100+(((j+1)/5)*130);
			f->ypos=50+(((j+1)%5)*80);
			x=((G_fflds[i].xpos-17)/w);
			f->level=(x<<9)|((G_fflds[i].ypos&31)<<4)|calcftype('T');
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to=G_noelem[G_nowlev]-1;
			joi.from=G_noelem[G_nowlev]-1;
			joi.tpos.x=f->xpos+10;
			joi.tpos.y=f->ypos+G_hgt[16]+5;
			joi.pos.x=f->xpos;
			joi.pos.y=f->ypos+G_hgt[16];
			joi.flags.TXTON=0;
			joi.flags.TYPE=1;
			joi.flags.LCOL=G_lcol;
			joi.flags.TCOL=G_tcol;
			joi.flags.DIR=0;
			if ((j+2)%5) {
				joi.flags.NOPNT=1;
				joi.points[0]=f->ypos+80;
			}
			else {
				joi.flags.NOPNT=5;
				joi.points[0]=f->ypos+80;
				joi.points[1]=f->xpos+65;
				joi.points[2]=30;
				joi.points[3]=f->xpos+130;
				joi.points[4]=50;
			}
			addcont(&joi);
			j++;
		}       */
	}

	/* done the text. now do the accepty bits */
	for (i=0;i<noflds;i++) {
		if (G_fflds[i].type=='s') {		/* simple bits */
			addelem();
			f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
			f->text=realloc(f->text,
			strlen(G_file.cont[G_fflds[i].val[0]]->flds[G_fflds[i].val[1]]->name)
			+strlen(G_file.files[G_fflds[i].val[0]])+3);
			/* text is file.field */
			sprintf(f->text,"%s\n%s",G_file.files[G_fflds[i].val[0]],G_file.cont[G_fflds[i].val[0]]->flds[G_fflds[i].val[1]]->name);
			f->type=20;
			f->xpos=100+(((j+1)/5)*130);
			f->ypos=50+(((j+1)%5)*80);
			x=((G_fflds[i].xpos-17)/w)+strlen(G_file.files[G_fflds[i].val[0]])+1;
			f->level=(x<<9)|((G_fflds[i].ypos&31)<<4)|calcftype(G_fflds[i].ftype);
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to=G_noelem[G_nowlev]-1;
			joi.from=G_noelem[G_nowlev]-1;
			joi.tpos.x=f->xpos+10;
			joi.tpos.y=f->ypos+G_hgt[16]+5;
			joi.pos.x=f->xpos;
			joi.pos.y=f->ypos+G_hgt[16];
			joi.flags.TXTON=1;
			joi.flags.TYPE=1;
			joi.flags.LCOL=G_lcol;
			joi.flags.TCOL=G_tcol;
			joi.flags.DIR=0;
			if ((j+2)%5) {
				joi.flags.NOPNT=1;
				joi.points[0]=f->ypos+80;
			}
			else {
				joi.flags.NOPNT=5;
				joi.points[0]=f->ypos+80;
				joi.points[1]=f->xpos+65;
				joi.points[2]=30;
				joi.points[3]=f->xpos+130;
				joi.points[4]=50;
			}
			addcont(&joi);
			j++;
		}
		if (G_fflds[i].type=='b') {   /* table fields */
			k=0;
			strcpy(tmp,&G_fflds[i].val[2]);
			g=strtok(tmp,"\n");
			while (g!=(char *)NULL) {
				addelem();
				f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
				f->text=realloc(f->text,strlen(g)+3);
						/* text is list of table headings */
				sprintf(f->text,"%s\n",g);
				f->type=19;
				f->xpos=100+(((j+1)/5)*130);
				f->ypos=50+(((j+1)%5)*80);
				x=((G_fflds[i].xpos-17)/w)+strlen(G_file.files[G_fflds[i].val[0]])+1;
				f->level=(x<<9)|((G_fflds[i].ypos&31)<<4)|calcftype(G_tbltype[G_fflds[i].ftype][k]);
				lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to=G_noelem[G_nowlev]-1;
				joi.from=G_noelem[G_nowlev]-1;
				joi.tpos.x=f->xpos+10;
				joi.tpos.y=f->ypos+G_hgt[16]+5;
				joi.pos.x=f->xpos;
				joi.pos.y=f->ypos+G_hgt[16];
				joi.flags.TXTON=1;
				joi.flags.TYPE=1;
				joi.flags.LCOL=G_lcol;
				joi.flags.TCOL=G_tcol;
				joi.flags.DIR=0;
				if ((j+2)%5) {
					joi.flags.NOPNT=1;
					joi.points[0]=f->ypos+80;
				}
				else {
					joi.flags.NOPNT=5;
					joi.points[0]=f->ypos+80;
					joi.points[1]=f->xpos+65;
					joi.points[2]=30;
					joi.points[3]=f->xpos+130;
					joi.points[4]=50;
				}
				addcont(&joi);
				j++;
				k++;
				strcpy(tmp,&G_fflds[i].val[2]);
				g=strtok(tmp,"\n");
				for (l=0;l<k;l++) g=strtok((char *)NULL,"\n");
			}
		}
	}
	/* add end box */
	addelem();
	lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to=G_noelem[G_nowlev]-1;
	f=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]);
	f->text=realloc(f->text,6);
	strcpy(f->text,"END\n");
	f->type=18;
	f->xpos=100+(((j+1)/5)*130);
	f->ypos=50+(((j+1)%5)*80);
	free(joi.points);
	free(joi.text);
	uplev();
}