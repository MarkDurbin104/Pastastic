#include <dos.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <conio.h>
#include <alloc.h>
#include <stdlib.h>
#include <string.h>
#include <graphics.h>
#include "tdef.h"
#include "tdmouse.h"
#include "tdicon.h"
#include "tdvars.h"

int				G_driver;
int				G_mode;
int				G_maxx;
int				G_maxy;
linpts			G_line;
int				G_selected[300];
int				G_sx;
int				G_sy;
int				G_mx;
int				G_my;
int				G_cpos=(-1);
char			*G_lused;
int				*G_noelem;
int				*G_nocont;
int				*G_nowelem;
int				*G_nowcont;
level 			*lev;
pad				G_ubuf[NOUNDOS];
int				G_noulev=0;
int				G_nowlev;
int				G_nolev;
int				G_xpos;
int				G_ypos;
int				G_xtos;
int				G_ytos;
int				G_xbos;
int				G_ybos;
int				G_elemt;
int				G_ident;
int				G_sident;
int				G_lsel=(-1);
int				G_inpsd;
int				G_tcol;
int				G_lcol;
int				G_snapto;
int				G_noselc;
marker			G_partln;
char			G_cellname[8];
int				msex,msey,mseb;
int				G_curarray[32];
char			G_buf[3250];
int				G_dictfd;
dict			G_dictent;
fldata			G_file;
int				QG=DONGLE;
int				G_dongin;
vardata			G_varib;
seqs			*G_seqs;
int				G_noseqs;
frmflds			G_fflds[MAX_FIELD];
int				G_scx,G_scy,G_pwid,G_ltype;
unsigned char	*G_scr[85];
int				G_szpbuf;
int				G_dpl=1440;
int				G_dpp=1050;
int				G_sGinc;
int				G_sLinc;
int				G_sinc;
int				G_iGinc;
int				G_iLinc;
int				G_iinc;
int				G_dGinc;
int				G_dLinc;
int				G_dinc;
int				G_fGinc;
int				G_fLinc;
int				G_finc;
int				G_lGinc;
int				G_lLinc;
int				G_linc;
int				G_vn[1000];
lits			*G_lit;
int				G_nolit;
msgs			*G_msg;
int				G_nomsg;
cflow			*G_cpm;
int				G_nocpm;
int				G_upl;
int				G_upe;
char			**G_utl;
int				G_noutl;
int				G_inform;


main (int argc,char **argv) {
	int imon=0,red=0,xit;
	long fcl=0L;
	G_dongin=QD();
	if (argc<3) pnxit("tdef cellname msgq",0);
	strcpy(G_cellname,argv[1]);
	startup();
	xit=0;
	do {
		settextjustify(1,2);
		if (G_dongin) { G_dongin=QD(); if (!G_dongin) fcl=corepr(); }
		if (fcl!=farcoreleft()) fcl=corepr();
		if (mousestat(G_snapto)) {
			imon=updatecur(imon);		/* imon tells us if we are currently drawing a box on the screen */
			if (mseb==2) colmenu();
			if (mseb==1) chkmpos();
		}
		if (kbhit()) {
			xit=keychk();
			red=xit&2;
			xit&=1;
		}
		else {
			if (red) {
				red=0;
				mousecur(0);
				redraw(1);
				mousecur(1);
			}
		}
	} while (!xit);
	shutdown();
	return(1);
}

/*  add level */
int addlev(void) {
	checkifput();
	G_lused[G_nolev]=0;			/* is PSD or DFD flag */
	lev[G_nolev].G_elem=(shape *)malloc(sizeof(shape)); /* grab a shape and a line */
	if (lev[G_nolev].G_elem==(shape *)NULL) return(-1);
	lev[G_nolev].G_cont=(join *)malloc(sizeof(join));
	if (lev[G_nolev].G_cont==(join *)NULL) return(-1);
	G_noelem[G_nolev]=G_nocont[G_nolev]=0;
	G_nowelem[G_nolev]=G_nowcont[G_nolev]=1;
	lev[G_nolev].upper=0;
	lev[G_nolev].modified=(-1);
	lev[G_nolev].x=0;					/* current x/y */
	lev[G_nolev].y=0;
	lev[G_nolev].old=0;                 /* how old level is */
	lev[G_nolev].ofs=(-1L);
	lev[G_nolev].inout=0;
	G_nolev++;
	return(G_nolev-1);
}

/*  set the mouse cursor to a shape - if allowed */
int setcur(void) {
	int cur,i,j,f;
	union {
		char *c;
		int  *i;
	} u;
	switch(cur=selelem(-1)) {
		case (-1) : {
		} break;
		case 0 :                      /* ptr */
		case 1 :                      /* text */
		case 2 :                      /* + */
		case 3 : {                    /* Paste */
			setmcurto(cur);
			G_elemt=0;
		} break;
		case 4 : {                    /* cut */
			clearviewport();
			redraw(1);
			cur=selelem(0);           /* nulled */
			setmcurto(cur);
			G_elemt=0;
		} break;
		case 5 : {                    /* doppy flisk */
			savediag(G_cellname);
			cur=selelem(0);
			setmcurto(cur);
			G_elemt=0;
		} break;
		case 6 : {                    /* bin (shopping) */
			if (G_lsel!=(-1)) {       /* inc all del levels */
				for (i=0;i<G_nocont[G_nowlev];i++) {
					if (lev[G_nowlev].G_cont[i].deled!=0) lev[G_nowlev].G_cont[i].deled++;
					if (lev[G_nowlev].G_cont[i].deled==50) delcont(i--);
				}
				lev[G_nowlev].G_cont[G_lsel].deled=1;
				lev[G_nowlev].G_cont[G_lsel].flags.LCOL^=1;
				G_lsel=(-1);
				mousecur(0);
				clearviewport();
				redraw(1);
				mousecur(1);
			}
			else {
				if (G_noselc!=0) {
					for (i=0;i<G_noelem[G_nowlev];i++) {
						if (lev[G_nowlev].G_elem[i].deled!=0) lev[G_nowlev].G_elem[i].deled++;
						if (lev[G_nowlev].G_elem[i].deled==50) delelem(i--);
					}
					for (i=0;i<G_nocont[G_nowlev];i++) {
						if (lev[G_nowlev].G_cont[i].deled!=0) lev[G_nowlev].G_cont[i].deled++;
						if (lev[G_nowlev].G_cont[i].deled==50) delcont(i--);
					}
					for (i=0;i<G_noselc;i++) {
						lev[G_nowlev].G_elem[G_selected[i]].deled=1;
						lev[G_nowlev].G_elem[G_selected[i]].colour^=0x11;
						for (j=0;j<G_nocont[G_nowlev];j++) {
							if ((lev[G_nowlev].G_cont[j].from==G_selected[i])
							||	(lev[G_nowlev].G_cont[j].to==G_selected[i])) {
								if (lev[G_nowlev].G_cont[j].deled==0) lev[G_nowlev].G_cont[j].deled=1;
							}
						}
					}
					G_noselc=0;
					mousecur(0);
					clearviewport();
					redraw(1);
					mousecur(1);
				}
				else {
					sound(1000);
					for (i=0;i<8000;i++);
					nosound();
				}
			}
			cur=selelem(0);
			setmcurto(cur);
			G_elemt=0;
		} break;
		case 7 : {			/* undo */
			undo();
			mousecur(0);
			redraw(1);
			mousecur(1);
			cur=selelem(0);
			setmcurto(cur);
			G_elemt=0;
		} break;
		case 8 : {           /* Exit */
			switch(popup(50,150,300,70,"Do You Wish To Save First"
							,1,"NO.YES.CANCEL")) {
				case 0 : {
					cleardevice();
					closegraph();
					pnxit("Finished",1);
				}
				case 1 : {
					selelem(5);
					savediag(G_cellname);
					cleardevice();
					closegraph();
					pnxit("Finished",1);
				}
				default : {
					mousecur(0);
					clearviewport();
					redraw(1);
					cur=selelem(0);
					setmcurto(cur);
					mousecur(1);
					G_elemt=0;
				}
			}
		} break;
		case 9 : {           /* top item second line */
			if ((G_levtype==2)||(G_levtype==5)) {   /* PSD / DFD */
				if ((G_noelem[G_nowlev]!=0)&&(lev[G_nowlev].G_elem[0].type!=1)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
				}
			}
			else {
				G_elemt=G_iconselc[G_levtype-1][cur-9];
			}
		} break;
		case 10 : {
			if ((G_levtype==2)||(G_levtype==5)) {
				if (G_noelem[G_nowlev]==0) {     /* if first time around then */
					getuplev();                  /* put down top PSD */
					tpsdelem(G_upl,G_upe);
					G_noselc=1;                  /* and select it */
					G_selected[0]=0;
					lev[G_nowlev].G_elem[0].colour^=0x11;
					redraw(1);
				}
					/* if top item not PSD sub or no selected or
						wrong type selected then no can do */
				if ((lev[G_nowlev].G_elem[0].type!=14)||(G_noselc!=1)
                ||	(lev[G_nowlev].G_elem[G_selected[0]].type==11)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
					G_lused[G_nowlev]=1;
					G_inpsd=1;
				}
			}
			else {  /* not PSD / DFD so just select */
				G_elemt=G_iconselc[G_levtype-1][cur-9];
			}
		} break;
		case 11: {	/* PSD OR box */
			if ((G_levtype==2)||(G_levtype==5)) { /* see above */
				if (G_noelem[G_nowlev]==0) {
					getuplev();
					tpsdelem(G_upl,G_upe);
					G_noselc=1;
					G_selected[0]=G_noelem[G_nowlev]-1;
					lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].colour^=0x11;
					redraw(1);
				}
				if ((lev[G_nowlev].G_elem[0].type!=14)||(G_noselc!=1)
				||	(lev[G_nowlev].G_elem[G_selected[0]].type!=11)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					j=(-1);
					for (i=0;i<G_nocont[G_nowlev];i++) {
						if ((lev[G_nowlev].G_cont[i].from==G_selected[0])&&(!(lev[G_nowlev].G_cont[i].deled))) {
								/* decide whether to put down TRUE/FALSE/Nothing */
							if (j==(-1)) {
								j=(lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].text[1]=='T');
							}
							else {
								j=2;
								break;
							}
						}
					}
					if (lev[G_nowlev].G_elem[G_selected[0]].text[0]=='C') {
						u.c=&lev[G_nowlev].G_elem[G_selected[0]].text[1];
						if ((*u.i==0)||(*u.i==1)) f=*u.i+1; else f=0;
					}
					if (((f==1)&&(j!=2))||((f==2)&&(j==(-1)))) { /* wecan select it */
						G_elemt=G_iconselc[G_levtype-1][cur-9];
						G_lused[G_nowlev]=1;
						G_inpsd=1;
					}
					else {
						cur=selelem(0);
						setmcurto(cur);
						G_elemt=0;
					}
				}
			}
			else {
				G_elemt=G_iconselc[G_levtype-1][cur-9];
			}
		} break;
		case 12 : {		/* Loop box Same as normal box*/
			if ((G_levtype==2)||(G_levtype==5)) {
				if (G_noelem[G_nowlev]==0) {
					getuplev();
					tpsdelem(G_upl,G_upe);
					G_noselc=1;
					G_selected[0]=G_noelem[G_nowlev]-1;
					lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].colour^=0x11;
					redraw(1);
				}
				if ((lev[G_nowlev].G_elem[0].type!=14)||(G_noselc!=1)
				||	(lev[G_nowlev].G_elem[G_selected[0]].type==11)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
					G_lused[G_nowlev]=1;
					G_inpsd=1;
				}
			}
			else {
				if ((G_levtype==1)&&(G_used[cur-12])) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
				}
			}
		} break;
		case 13 : {		/* subroutine */
			if ((G_levtype==2)||(G_levtype==5)) {
				if (G_noelem[G_nowlev]==0) {
					getuplev();
					tpsdelem(G_upl,G_upe);
					G_noselc=1;
					G_selected[0]=G_noelem[G_nowlev]-1;
					lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].colour^=0x11;
					redraw(1);
				}
				if ((lev[G_nowlev].G_elem[0].type!=14)||(G_noselc!=1)
                ||	(lev[G_nowlev].G_elem[G_selected[0]].type==11)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
					G_lused[G_nowlev]=1;
					G_inpsd=1;
				}
			}
			else {
				if (G_used[cur-12]) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
				}
			}
		} break;
		case 14 : {         /* Imported flow */
			if ((G_levtype==2)||(G_levtype==5)) {
				if ((G_noelem[G_nowlev]!=0)&&(lev[G_nowlev].G_elem[0].type!=1)) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
					G_lused[G_nowlev]=(-1);
				}
			}
			else {
				if (G_used[cur-12]) {
					cur=selelem(0);
					setmcurto(cur);
					G_elemt=0;
				}
				else {
					G_elemt=G_iconselc[G_levtype-1][cur-9];
				}
			}
		} break;
		case 15 : {
			if (G_used[cur-12]) {
				cur=selelem(0);
				setmcurto(cur);
				G_elemt=0;
			}
			else {
				G_elemt=G_iconselc[G_levtype-1][cur-9];
			}
		} break;
		case 16 :
		case 17 : {
			G_elemt=G_iconselc[G_levtype-1][cur-9];
		} break;
		default : {
			cur=selelem(0);
			setmcurto(cur);
			G_elemt=0;
		}
	}
	return(cur);
}

/* box size of element selected */
void imbox(int x,int y,int item) {
	movto(0,x,y);
	linto(0,x+G_wid[item],y);
	linto(0,x+G_wid[item],y+G_hgt[item]);
	linto(0,x,y+G_hgt[item]);
	linto(0,x,y);
}


int updatecur(int imon) {
	if (inbox(	WINX,WINY,	/* box is all on screen */
				G_maxx-G_wid[G_elemt]-11,G_maxy-G_hgt[G_elemt]-11)) {
		if (G_elemt==0) {               /* if no cursor selected */
			mousecur(1);
			mousetrap(G_snapto);
		}
		else {
			mousecur(0);
			if (imon) {                /* wipe it */
				if ((G_elemt>10)&&(G_elemt<15)) {   /*PSD ignores y pos */
					imbox(msex-WINX,G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90),G_elemt);
				}
				else {
					imbox(msex-WINX,msey-WINY,G_elemt);
				}
			}
			mousetrap(G_snapto);                /* put it back */
			if ((G_elemt>10)&&(G_elemt<15)) {
				imbox(msex-WINX,G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90),G_elemt);
			}
			else {
				imbox(msex-WINX,msey-WINY,G_elemt);
			}
			imon=1;
		}
	}
	else {
		if (imon) {		/* if image is on wipe it */
			if ((G_elemt>10)&&(G_elemt<15)) {
				imbox(msex-WINX,G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90),G_elemt);
			}
			else {
				imbox(msex-WINX,msey-WINY,G_elemt);
			}
			imon=0;
		}
		mousecur(1);                 /* turn cursor on */
		mousetrap(G_snapto);
	}
	return(imon);			/* return new imon value */
}

/* mouse button has been pressed. What do we do */
int curfunc(int cur) {
	int i,j,f,c;
	union {
		char *c;
		int  *i;
	} u;
	c=cur;
	if (G_elemt==0) {    	/* switch on current cursor type */
		switch (cur) {
			case 0 : moveelem();	break;        /* pointer */
			case 1 : textelem();	break;        /* text */
			case 2 : drawline();	break;        /* + */
			case 3 : paste();		break;        /* paste */
		}
	}
	else {			/* if on screen */
		if (inbox(WINX,WINY,G_maxx-G_wid[G_elemt]-11,G_maxy-G_hgt[G_elemt]-11)) {
				/* wipe box */
			if ((G_elemt>10)&&(G_elemt<15)) {	/* if PSD ignore ypos*/
				imbox(msex-WINX,G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90),G_elemt);
			}
			else {
				imbox(msex-WINX,msey-WINY,G_elemt);
			}
				/* if R/P/C-A/S */
			if ((G_elemt>3)&&(G_elemt<8)) {
				if (!G_used[G_elemt-4])	{	/* if not already used do it */
					addelem();
				}
			}
			else {
				if ((G_elemt>10)&&(G_elemt<15)) {	/* if PSD */
						/* allign mouse with y pos */
					setmouseyto(G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90+WINY));
				}
				addelem();
					/* if PSD add auto line */
				if ((G_elemt>10)&&(G_elemt<15)) addpsdln(G_selected[0],G_noelem[G_nowlev]-1);
					/* if Normal then define box */
				if (G_elemt==11) {
					psddef(G_noelem[G_nowlev]-1);
					cls();
					markpoints();
					c=selelem(cur);
					redraw(1);
				}
				if (G_elemt==12) {   /* OR box */
					j=1;
					/* j=1 - nothing 2- True 3 - False */
					for (i=0;i<G_nocont[G_nowlev];i++) {
						if ((lev[G_nowlev].G_cont[i].from==G_selected[0])&&(!(lev[G_nowlev].G_cont[i].deled))) {
							if (lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].text[1]=='T') {
								j=2;
								break;
							}
							if (lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].text[1]=='F') {
								j=3;
								break;
							}
						}
					}
					if (lev[G_nowlev].G_elem[G_selected[0]].text[0]=='C') {
						u.c=&lev[G_nowlev].G_elem[G_selected[0]].text[1];
						if ((*u.i==0)||(*u.i==1)) f=*u.i+1; else f=0;
						/* f=0 for nothing 1 - IF 2 - CP */
					}
					if (f==1) {
						switch (j) {
							case 1 :
							case 3 : {	/* IF  with nothing or False */
								lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text=realloc(
									lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,6);
								strcpy(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,"LTRUE^Z");
								if (j==3) {		/* if false then switch cursor back */
									c=selelem(0);
									setmcurto(c);
									G_elemt=0;
								}
							} break;
							case 2 : {		/* IF & TRUE put down false */
								lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text=realloc(
									lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,6);
								strcpy(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,"LFALSE^Z");
								c=selelem(0);
								setmcurto(c);
								G_elemt=0;
							} break;
						}
					}
					else {
						if ((j==1)&&(f==2)) {	/* CP & nothing put down TRUE */
							lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text=realloc(
								lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,6);
							strcpy(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,"LTRUE^Z");
						}
						c=selelem(0);
						setmcurto(c);
						G_elemt=0;
					}
					clearviewport();
					redraw(1);
				}
				if (G_elemt==21) {	/* if imported flow then do one */
					importdef(G_noelem[G_nowlev]-1);
					cls();
					markpoints();
					c=selelem(cur);
					redraw(1);
				}
			}
			mousetrap(G_snapto);
			if ((G_elemt>10)&&(G_elemt<15)) {     /* put shadow cursor back on */
				imbox(msex-WINX,G_ypos+(lev[G_nowlev].G_elem[G_selected[0]].ypos+90),G_elemt);
			}
			else {
				imbox(msex-WINX,msey-WINY,G_elemt);
			}
		}
		else {
				/* not on completly on screen. scroll screen left */
			if (inbox(G_maxx-G_wid[G_elemt]-11,WINY,G_maxx-11,G_maxy-11)) {
				movecurr((G_maxx-WINX-11)/4);
				mousecur(0);
				redraw(1);
				mousecur(1);
			}
		}
	}
	return(c);
}
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
/******************************************************************/
void uplev(void) {
	int i;

	mousecur(0);
	if (G_inform) {
		if (lev[G_nowlev].upper==(-2)) {
			G_inform=0;
			return;
		}
	}
	if (G_nowlev>0) {
		lev[G_nowlev].x=G_xpos;
		lev[G_nowlev].y=G_ypos;
		for (i=0;i<G_noselc;i++) lev[G_nowlev].G_elem[G_selected[i]].colour^=0x11;
		G_noselc=0;
		setlevelto(i=getuplev());
		G_xpos=lev[i].x;
		G_ypos=lev[i].y;
		if (G_nowlev==0) {
			G_levtype=1;
			cls();
		}
		if (G_levtype==4) {
			G_levtype=3;
			cls();
		}
		markpoints();
		clearviewport();
		redraw(1);
		while (mseb==1) mousetrap(G_snapto);
		mousecur(1);
	}
	else {
		setlevelto(0);
	}
}
void undo(void){
	int i;
	for (i=0;i<G_noelem[G_nowlev];i++) {
		if (lev[G_nowlev].G_elem[i].deled!=0) lev[G_nowlev].G_elem[i].deled--;
	}
	for (i=0;i<G_nocont[G_nowlev];i++) {
		if (lev[G_nowlev].G_cont[i].deled!=0) lev[G_nowlev].G_cont[i].deled--;
	}
}
void setupfldvar(void) {
	G_file.nofiles=0;
	G_file.files=malloc(sizeof(char *));
	if (G_file.files==(void *)NULL) pnxit("Cant Get Room For Files",-1);
	G_file.cont=malloc(sizeof(flddata *));
	if (G_file.cont==(void *)NULL) pnxit("Cant Get Room For Fields",-1);
	G_varib.novar=0;
	G_varib.vars=malloc(sizeof(fldvar *));
	if (G_varib.vars==(void *)NULL) pnxit("Cant Get Room For Fields",-1);
}
void loadfiledat(void) {
	int k,i,j,item=1,xit=0;
	static int a=0;
	file *b;
	if (a) {
		for (k=0;k<G_file.nofiles;k++) {
			for (j=0;j<G_file.cont[k]->nofld;j++) {
				free(G_file.cont[k]->flds[j]);
			}
			free(G_file.cont[k]->flds);
			free(G_file.cont[k]);
			free(G_file.files[k]);
		}
		free(G_file.cont);
		free(G_file.files);
		G_file.cont=malloc(1);
		G_file.files=malloc(1);
		G_file.nofiles=0;
	}
	a=1;
	while (xit<3) {
		b=loadfile(G_cellname,item);
		if (b->name[0]==0) {
/*			G_file.nofiles++;
			k=G_file.nofiles-1;
			G_file.files=realloc(G_file.files,(k+1)*sizeof(char *));
			G_file.files[k]=malloc(15);
			sprintf(G_file.files[k],"Store(%02d)",k+1);
			G_file.cont=realloc(G_file.cont,(k+1)*sizeof(flddata *));
			G_file.cont[k]=malloc(sizeof(flddata));
			G_file.cont[k]->nofld=0;
			item++;*/
			xit++;
		}
		else {
			G_file.nofiles++;
			k=G_file.nofiles-1;
			G_file.files=realloc(G_file.files,(k+1)*sizeof(char *));
			G_file.files[k]=malloc(strlen(b->name)+1);
			strcpy(G_file.files[k],b->name);
			G_file.cont=realloc(G_file.cont,(k+1)*sizeof(flddata *));
			G_file.cont[k]=malloc(sizeof(flddata));
			G_file.cont[k]->nofld=b->nofld;
			G_file.cont[k]->flds=malloc(b->nofld*sizeof(fldvar *));
			for (j=0;j<b->nofld;j++) {
				G_file.cont[k]->flds[j]=malloc(sizeof(fldvar));
				strcpy(G_file.cont[k]->flds[j]->name,b->flds[j]->name);
				G_file.cont[k]->flds[j]->type=b->flds[j]->type;
				G_file.cont[k]->flds[j]->len=b->flds[j]->len;
			}
			for (i=0;i<b->nofld;i++) {
				free(b->flds[i]);
			}
			free(b->flds);
			for (i=0;i<b->nokey;i++) {
				for(j=0;j<b->keys[i]->noparts;j++) {
					free(b->keys[i]->keypts[j]);
				}
				free(b->keys[i]->keypts);
				free(b->keys[i]);
			}
			free(b->keys);
			free(b);
			item++;
		}
	}
}
int QD(void){QI(1);}/*int B,I,J,L,M,W,R;char T[12];W=R=0x80*4;W+=W/2;R=W;W-=4;R-=2;IQ
(W,3);IQ(W,2);IQ(W,3);QZ(L=0;L<1;L++)QZ(M=0;M<1;M++);QZ(I=0;I<4159-((QG-1)*
2089);I++){IQ(W,1);B=(((OQ(R))>>7)&1);IQ(W,3);}QZ(J=0;J<10;J++){T[J]=0;QZ(I=
0;I<7;I++){IQ(W,1);B=(((OQ(R))>>7)&1);IQ(W,3);T[J]|=B<<I;}}T[9]=0;ZQ(!(QG))QI
(1);ZQ(QG==1)ZQ(!(QQ(T,"BCAFDBKMG")))QI(1);ZQ(QG==2)ZQ(!(QQ(T,"9A9KCJ]D_")))
QI(1);QI(0);}*/

int keychk(void) {
	int xit=0,red=0,i,j;
	FILE *fp;
	shape *t;
	unsigned char *ks=MK_FP(0x0000,0x0417);
	switch(getch()) {
		case 0 : {
			switch(getch()) {
				case ';' : { /*F1*/
					unlink("opt.prn");
					prscr();
					outseqs();
				} break;
				case '<' : { /*F2*/
					readin();
				} break;
				case '=' : { /*F3*/
					conv(G_cellname);
				} break;
				case 'C' : { /*F9*/
					for (i=0;i<G_maxx-WINX-11;i+=G_snapto) {
						for (j=0;j<G_maxy-WINY-11;j+=G_snapto) if (getpixel(i,j)==0) putpixel(i,j,8);
					}
				} break;
				case 'H' : { /*UP*/
					mousecur(0);
					if (*ks&3) red=movecuru(G_maxy-WINY-11); else red=movecuru((G_maxy-WINY-11)/4);
					mousecur(1);
				} break;
				case 'P' : { /*DOWN*/
					mousecur(0);
					if (*ks&3) red=movecurd(G_maxy-WINY-11); else red=movecurd((G_maxy-WINY-11)/4);
					mousecur(1);
				} break;
				case 'K' : { /*LEFT*/
					mousecur(0);
					if (*ks&3) red=movecurl(G_maxx-WINX-11); else red=movecurl((G_maxx-WINX-11)/4);
					mousecur(1);
				} break;
				case 'M' : { /*RIGHT*/
					mousecur(0);
					if (*ks&3) red=movecurr(G_maxx-WINX-11); else red=movecurr((G_maxx-WINX-11)/4);
					mousecur(1);
				} break;
			}
		} break;
		case '8' : { /*S_UP*/
			if (*ks&3) {
				mousecur(0);
				red=movecuru(G_maxy-WINY-11);
				mousecur(1);
			}
		} break;
		case '2' : { /*S_DOWN*/
			if (*ks&3) {
				mousecur(0);
				red=movecurd(G_maxy-WINY-11);
				mousecur(1);
			}
		} break;
		case '4' : { /*S_LEFT*/
			if (*ks&3) {
				mousecur(0);
				red=movecurl(G_maxx-WINX-11);
				mousecur(1);
			}
		} break;
		case '6' : { /*S_RIGHT*/
			if (*ks&3) {
				mousecur(0);
				red=movecurr(G_maxx-WINX-11);
				mousecur(1);
			}
		} break;
		case 1 : {
			if (G_lsel!=(-1)) {
				lev[G_nowlev].G_cont[G_lsel].flags.LCOL^=1;
				G_lsel=(-1);
			}
			if (G_noselc!=0) {
				for (i=0;i<G_noselc;i++) {
					lev[G_nowlev].G_elem[G_selected[i]].colour^=0x11;
				}
			}
			for (i=0;i<G_noelem[G_nowlev];i++) {
				lev[G_nowlev].G_elem[i].colour^=0x11;
				G_selected[i]=i;
			}
			G_noselc=i;
			mousecur(0);
			redraw(1);
			mousecur(1);
		} break;
		case 'a' : {
			alignprn();
		} break;
		case 'b' : {
			setcolor(14);
			for (i=0;i<10;i++) {
				line(i*720+G_xpos,0,i*720+G_xpos,G_maxy);
				line(0,i*1050+G_ypos,G_maxx,i*1050+G_ypos);
			}
		} break;
		case 'd' : {
			prdiag(1,1);
		} break;
		case 'D' : {
			prdiag(2,2);
		} break;
		case 'r' : {
			prdiag(1,2);
		} break;
		case 'R' : {
			prdiag(2,2);
		} break;
		case 'f' : {
			prdiag(4,1);
		} break;
		case 'v' : {
			j=G_nowlev;
			for (i=j;i<G_nolev;i++) {
				setlevelto(i);
				if (G_noelem[i]>0) if (!prdiag(1,2)) break;
			}
			setlevelto(j);
		} break;
		case 'V' : {
			j=G_nowlev;
			for (i=j;i<G_nolev;i++) {
				setlevelto(i);
				if (G_noelem[i]>0) if (!prdiag(2,2)) break;
			}
			setlevelto(j);
		} break;
		case 'p' : {
			j=G_nowlev;
			for (i=0;i<G_nolev;i++) {
				setlevelto(i);
				if (G_noelem[i]>0) if (!prdiag(1,1)) break;
			}
			setlevelto(j);
		} break;
		case 'P' : {
			j=G_nowlev;
			for (i=0;i<G_nolev;i++) {
				setlevelto(i);
				if (G_noelem[i]>0) if (!prdiag(2,1)) break;
			}
			setlevelto(j);
		} break;
		case 26 : {
			mousecur(0);
			clearviewport();
			for (i=0;i<G_noelem[G_nowlev];i++) {
				t=&(lev[G_nowlev].G_elem[i]);
				setcolor(t->colour&15);
				rectangle(	t->xpos/WID-(G_wid[t->type]/(WID*2)),
							t->ypos/HGT,
							t->xpos/WID+(G_wid[t->type]/(WID*2)),
							t->ypos/HGT+(G_hgt[t->type]/HGT));
			}
			mousecur(1);
			while (!mseb) mousetrap(G_snapto);
			mousecur(0);
			if (inbox(WINX,WINY,G_maxx-11,G_maxy-11)) {
				G_xpos=0-((msex-WINX)*WID);
				G_ypos=0-((msey-WINY)*HGT);
				markpoints();
			}
			clearviewport();
			redraw(1);
			mousecur(1);
		} break;
		case '' : {
			addelem();
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].xpos=200;
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].ypos=0;
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].type=22;
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text=realloc(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,9);
			strcpy(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text,"CONTEXT");
			getuplev();
			free(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text);
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].text=lev[G_upl].G_elem[G_upe].text;
		}
		case 't' : {
			if (G_lsel!=(-1)) {
				lev[G_nowlev].G_cont[G_lsel].flags.TXTON^=1;
				mousecur(0);
				clearviewport();
				redraw(1);
				mousecur(1);
			}
		} break;
		case 'e' : {
			fp=fopen("prn","w");
			for (j=0;j<G_noseqs;j++) {
				fprintf(fp,"%3d %s\n",G_seqs[j].seq,tpsdln(G_seqs[j].name));
			}
			fprintf(fp,"\n");
			for (j=0;j<G_varib.novar;j++) {
				fprintf(fp,"o=%3d n=%3d l=%3d t=%c %s\n",G_varib.vars[j]->ofs,G_varib.vars[j]->no,G_varib.vars[j]->len,G_varib.vars[j]->type,G_varib.vars[j]->name);
			}
			fprintf(fp,"\n");
			fclose(fp);
		} break;
		case 8 : {
			markfordel();
		} break;
		case 'c' : {
			cutit();
			markfordel();
		} break;
	}
	return((red<<1)+xit);
}
long corepr(void) {
	char tmp[200];
	long fcl;
	fcl=farcoreleft();
	setviewport(0,0,G_maxx,G_maxy,1);
	setfillstyle(1,0);
	mousecur(0);
	settextjustify(0,2);
	settextstyle(2,0,4);
	if (G_dongin) sprintf(tmp,"%ld Bytes Free",fcl);
	else sprintf(tmp,"DEMO %ld Bytes Free",fcl);
	bar(G_maxx-(textwidth(tmp)+20),1,G_maxx-1,12);
	setcolor(11);
	rectangle(G_maxx-(textwidth(tmp)+12),1,G_maxx-8,12);
	outtxtxy(G_maxx-(textwidth(tmp)+10),1,tmp);
	mousecur(1);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	return(fcl);
}
void colmenu(void) {
	int i,j;
	i=colmen("LINES","TEXT");
	G_lcol=i>>4;
	G_tcol=i&15;
	if (G_lsel!=(-1)) {
		lev[G_nowlev].G_cont[G_lsel].flags.TCOL=G_tcol;
		lev[G_nowlev].G_cont[G_lsel].flags.LCOL=G_lcol^1;
	}
	for (j=0;j<G_noselc;j++) {
		lev[G_nowlev].G_elem[G_selected[j]].colour=((G_tcol<<4)+G_lcol)^0x11;
		for (i=0;i<G_nocont[G_nowlev];i++) {
/*			if ((lev[G_nowlev].G_cont[i].from==G_selected[j])
			||	(lev[G_nowlev].G_cont[i].to==G_selected[j])) {*/
			if (lev[G_nowlev].G_cont[i].from==G_selected[j]) {
				lev[G_nowlev].G_cont[i].flags.TCOL=G_tcol;
				lev[G_nowlev].G_cont[i].flags.LCOL=G_lcol;
			}
		}
	}
	if ((G_lsel!=(-1))||(G_noselc)) redraw(1);
}
void chkmpos(void) {
	static int cur=0;
	int i;
	if (inbox(WINX,WINY,G_maxx-11,G_maxy-11)) {
		cur=curfunc(cur);
	}
	else {
		if (inbox(1,WINY+405,WINX-1,G_maxy-1)) {
			uplev();
		}
		else {
			if (!movecur()) {
				if ((i=setcur())!=(-1)) {
					cur=i;
					while(mseb) mousetrap(G_snapto);
				}
				else {
					intitles();
				}
			}
		}
	}
}
int addpsdelem(int x,int y,int type,char *text,int len,int root,int id) {
	shape *t;
	if (G_nowelem[G_nowlev]<=G_noelem[G_nowlev]) {
		G_nowelem[G_nowlev]+=10;
		lev[G_nowlev].G_elem=(shape *)
			realloc(lev[G_nowlev].G_elem,sizeof(shape)*G_nowelem[G_nowlev]);
		if (lev[G_nowlev].G_elem==(shape *)NULL) {
			G_nowelem[G_nowlev]-=10;
			return(1);
		}
	}
	t=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]]);
	t->xpos=(x/G_snapto)*G_snapto;
	t->ypos=(y/G_snapto)*G_snapto;
	t->type=type;
	t->deled=0;
	t->text=malloc(len);
	memcpy(t->text,text,len);
	t->colour=((G_tcol<<4)+G_lcol);
	t->level=(-1);
	t->ident=id;
	if (root>(-1)) addpsdln(root,G_noelem[G_nowlev]);
	drelem(1,G_xpos,G_ypos,&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]]),1);
	G_noelem[G_nowlev]++;
	corepr();
	if (type==11) addnewvars(t->text);
	return(0);
}
void readin(void) {
	int i,j,k,d[20],p,fd,m,id,t,r[20],c[20];
	int curfunk,xt,root,gonedown,newlev,replev=0;
	char tmp[200];
	union {
		char	*c;
		int		*i;
	} u;
	fd=open("tmp.seq",O_RDONLY|O_BINARY);
	r[0]=0;
	xt=0;
	i=0;
	j=0;
	curfunk=0;
	root=r[replev];
	gonedown=0;
	read(fd,&G_nolit,sizeof(int));
	G_lit=realloc(G_lit,G_nolit*sizeof(lits));
	for (j=0;j<G_nolit;j++) {
		read(fd,&G_lit[j].l,sizeof(int));
		read(fd,&G_lit[j].t,1);
		switch(G_lit[j].t) {
			case 'l' : {
				G_lit[j].v=malloc(sizeof(long));
				read(fd,G_lit[j].v,sizeof(long));
			} break;
			case 'i' : {
				G_lit[j].v=malloc(sizeof(int));
				read(fd,G_lit[j].v,sizeof(int));
			} break;
			case 'f' : {
				G_lit[j].v=malloc(sizeof(float));
				read(fd,G_lit[j].v,sizeof(float));
			} break;
			case 'd' : {
				G_lit[j].v=malloc(sizeof(double));
				read(fd,G_lit[j].v,sizeof(double));
			} break;
			case 'C' : {
				read(fd,&i,sizeof(int));
				G_lit[j].v=malloc(i);
				read(fd,G_lit[j].v,i);
			} break;
		}
	}
	read(fd,&newlev,sizeof(int));
	lev[G_nowlev].G_elem[0].level=newlev;
	while ((read(fd,&id,sizeof(int))>0)&&(!xt)) {
		read(fd,&k,sizeof(int));
		read(fd,tmp,k);
		if (!strcmp(tmp,"END")) {
			xt=1;
		}
		else {
			if (!strcmp(tpsdln(tmp),"TRUE")) {
				j++;
				i--;
				curfunk=1;
				xt=addpsdelem(i*70+70,100+j*90,12,tmp,k,G_noelem[G_nowlev]-1,(-1));
				gonedown=1;
			}
			else {
				if (!strcmp(tpsdln(tmp),"FALSE")) {
					j++;
					i++;
					curfunk=2;
					xt=addpsdelem(i*70+70,100+j*90,12,tmp,k,G_noelem[G_nowlev]-3,(-1));
					gonedown=1;
				}
				else {
					if (tmp[0]=='L') {
						if (curfunk) {
							j++;
							root=G_noelem[G_nowlev]-1;
						}
						else {
							i+=2;
							root=r[replev];
						}
						if (!gonedown) {
							clearviewport();
							lev[G_nowlev].G_elem[0].xpos=i*35+70;
							for (m=0;m<G_nocont[G_nowlev];m++) {
								if (lev[G_nowlev].G_cont[m].from==0) {
									lev[G_nowlev].G_cont[m].pos.x=i*35+70;
								}
							}
							setlevelto(addlev());
							addseq(tmp,G_nowlev);
							xt=addpsdelem(G_maxx/2,10,14,tmp,k,-1,(-1));
							replev=0;
							i=0;j=0;
						}
						else {
							gonedown=0;
							xt=addpsdelem(i*70+70,100+j*90,14,tmp,k,root,(-1));
							root=r[replev];
							if (curfunk==1) {
								j-=2;
								i++;
								curfunk=0;
							}
							if (curfunk==2) {
								j-=2;
								i--;
								curfunk=0;
							}
						}
					}
					else {
						u.c=&tmp[1];
						if (*u.i==34) {
							i+=2;
							strcpy(tmp,"LREPEAT^Z");
							xt=addpsdelem(i*70+70,100+j*90,13,tmp,11,root,id);
							j+=3;
							replev++;
							r[replev]=root=G_noelem[G_nowlev]-1;
							c[replev]=G_nocont[G_nowlev];
							d[replev]=i;
						}
						else {
							if (*u.i==33) {
								j-=3;
								t=(i-d[replev])/2;
								for(p=root+1;p<G_noelem[G_nowlev];p++) {
									lev[G_nowlev].G_elem[p].xpos-=t*70;
								}
								for (p=c[replev];p<G_nocont[G_nowlev];p++) {
									lev[G_nowlev].G_cont[p].points[1]-=t*70;
									if (lev[G_nowlev].G_cont[p].from!=root) {
										lev[G_nowlev].G_cont[p].pos.x-=t*70;
									}
								}
								lev[G_nowlev].G_elem[root].ident=addutln(tmp,k);
								i=d[replev];
								replev--;
								root=r[replev];
							}
							else {
								i+=2;
								xt=addpsdelem(i*70+70,100+j*90,11,tmp,k,root,id);
							}
						}
					}
				}
			}
		}
	}
	read(fd,&G_nomsg,sizeof(int));
	G_msg=realloc(G_msg,G_nomsg*sizeof(msgs));
	for (j=0;j<G_nomsg;j++) {
		read(fd,&G_msg[j].m,sizeof(int));
		read(fd,G_msg[j].n,14);
		read(fd,&G_msg[j].l,sizeof(int));
		G_msg[j].t=malloc(G_msg[j].l);
		read(fd,G_msg[j].t,G_msg[j].l);
		addnewvars(G_msg[j].t);
	}
	close(fd);
	setlevelto(0);
	clearviewport();
	redraw(1);
}
void addnewvars(char *text) {
	int i,xit,j;
	char *t,tmp1[30],k;
	union {
		char *c;
		int  *i;
	} u;
	i=0;
	xit=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i++;
				i+=sizeof(int);
			} break;
			case 'L' : {
				i++;
				t=&text[i];
				while (*(t++)!='^') i++;
				i++;
			} break;
		case 'O' : {
				i++;
				i+=sizeof(int);
			} break;
			case 'F' : {
				i++;
				i+=sizeof(int);
			} break;
			case 'E' : {
				i++;
				i+=sizeof(int);
				i+=sizeof(int);
			} break;
			case 'V' : {
				i++;
				u.c=&text[i];
				if (G_vn[*u.i]) {
					*u.i=G_vn[*u.i];
				}
				else {
					for (j=0;j<G_varib.novar;j++) {
						if (G_varib.vars[j]->ofs==*u.i) break;
					}
					if (j==G_varib.novar) {
						k='L';
						if ((*u.i> 49)&&(*u.i<200)) k='C';
						if ((*u.i>199)&&(*u.i<400)) k='i';
						if ((*u.i>599)&&(*u.i<650)) k='f';
						if ((*u.i>649)&&(*u.i<700)) k='d';
						if  (*u.i>699)           	k='l';
						sprintf(tmp1,"VAR(%d)",*u.i);
						addvar(tmp1,k,0);
						G_vn[*u.i]=G_varib.novar-1;
						*u.i=G_vn[*u.i];
					}
				}
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
	}
}
void setlevelto(int newlev) {
	int i;
	if (newlev==G_nowlev) return;
	for (i=0;i<G_nolev;i++) lev[i].old++;
	if (lev[newlev].inout==1) {
		checkifput();
		getlevin(newlev);
	}
	G_nowlev=newlev;
}
void getlevin(int newlev) {
	int j,fd;
	int k;
	char filename[15];
	sprintf(filename,"%s.tmp",G_cellname);
	fd=open(filename,O_RDONLY|O_BINARY);
	printf("Getting %d old=%d mod=%d io=%d ofs=%ld\n",newlev,lev[newlev].old,lev[newlev].modified,lev[newlev].inout,lev[newlev].ofs);
	if (fd!=(-1)) {
		lev[newlev].old=0;
		lseek(fd,lev[newlev].ofs,SEEK_SET);
		lev[newlev].G_elem=(shape *)malloc(sizeof(shape)*G_noelem[newlev]);
		lev[newlev].G_cont=(join *)malloc(sizeof(join)*G_nocont[newlev]);
		read(fd,lev[newlev].G_elem,sizeof(shape)*G_noelem[newlev]);
		read(fd,lev[newlev].G_cont,sizeof(join)*G_nocont[newlev]);
		for (j=0;j<G_noelem[newlev];j++) {
			read(fd,&k,sizeof(int));
			lev[newlev].G_elem[j].text=malloc(k+1);
			read(fd,lev[newlev].G_elem[j].text,k);
		}
		for (j=0;j<G_nocont[newlev];j++) {
			read(fd,&k,sizeof(int));
			lev[newlev].G_cont[j].text=malloc(k+1);
			read(fd,lev[newlev].G_cont[j].text,k);
			read(fd,&k,sizeof(int));
			lev[newlev].G_cont[j].points=malloc(k*sizeof(int));
			read(fd,lev[newlev].G_cont[j].points,k*sizeof(int));
		}
		close(fd);
		lev[newlev].inout=0;
	}
}
void putlevout(int newlev) {
	int j=0,xit,fd;
	int k;
	char *t;
	char filename[15];
	sprintf(filename,"%s.tmp",G_cellname);
	fd=open(filename,O_WRONLY|O_BINARY);
	if (fd!=(-1)) {
		lev[newlev].old=0;
		lev[newlev].inout=1;
		lev[newlev].ofs=lseek(fd,0L,SEEK_END);
		write(fd,lev[newlev].G_elem,sizeof(shape)*G_noelem[newlev]);
		write(fd,lev[newlev].G_cont,sizeof(join)*G_nocont[newlev]);
		for (j=0;j<G_noelem[newlev];j++) {
			if ((lev[newlev].G_elem[j].type>10)&&(lev[newlev].G_elem[j].type<15)) {
				k=0;
				xit=0;
				while(!xit) {
					switch(lev[newlev].G_elem[j].text[k]) {
						case 'O' :
						case 'F' :
						case 'V' :
						case 'C' : {
							k+=sizeof(int)+1;
						} break;
						case 'L' : {
							k++;
							t=&lev[newlev].G_elem[j].text[k];
							while (*(t++)!='^') {
								k++;
							}
							k++;
						} break;
						case 'E' : {
							k+=2*sizeof(int)+1;
						} break;
						default : {
							xit=1;
						}
					}
				}
				k++;
			}
			else {
				k=strlen(lev[newlev].G_elem[j].text)+1;
			}
			write(fd,&k,sizeof(int));
			write(fd,lev[newlev].G_elem[j].text,k);
			free(lev[newlev].G_elem[j].text);
		}
		for (j=0;j<G_nocont[newlev];j++) {
			k=strlen(lev[newlev].G_cont[j].text)+1;
			write(fd,&k,sizeof(int));
			write(fd,lev[newlev].G_cont[j].text,k);
			k=lev[newlev].G_cont[j].flags.NOPNT+1;
			write(fd,&k,sizeof(int));
			write(fd,lev[newlev].G_cont[j].points,k*sizeof(int));
			free(lev[newlev].G_cont[j].text);
			free(lev[newlev].G_cont[j].points);
		}
		free(lev[newlev].G_elem);
		free(lev[newlev].G_cont);
	}
	close(fd);
}
int getuplev(void) {
	int j,k;
	k=G_nowlev;
	setlevelto(lev[G_nowlev].upper);
	for (j=0;j<G_noelem[G_nowlev];j++) {
		if (lev[G_nowlev].G_elem[j].level==k) {
			G_upl=G_nowlev;
			G_upe=j;
			setlevelto(k);
			return(lev[G_nowlev].upper);
		}
	}
	if (k!=G_nowlev) setlevelto(k);
	G_upl=k;
	G_upe=0;
	return(k);
}
void checkifput(void) {
	int i,j=0;
	static int ondisk=0;
	if ((ondisk)||(farcoreleft()<50000L)) {
		ondisk=1;
		for(i=0;i<G_nolev;i++) if (lev[i].inout==0) j=max(lev[i].old,j);
		for(i=0;i<G_nolev;i++) {
			if ((lev[i].inout==0)&&(j==lev[i].old)) {
				if (lev[i].modified!=0) {
					printf("Putting %d old=%d mod=%d io=%d ofs=%ld\n",i,lev[i].old,lev[i].modified,lev[i].inout,lev[i].ofs);
					putlevout(i);
					lev[i].modified=0;
				}
				else {
					printf("Skiping %d old=%d mod=%d io=%d ofs=%ld\n",i,lev[i].old,lev[i].modified,lev[i].inout,lev[i].ofs);
					lev[i].old=0;
					lev[i].inout=1;
					for (j=0;j<G_noelem[i];j++) {
						free(lev[i].G_elem[j].text);
					}
					for (j=0;j<G_nocont[i];j++) {
						free(lev[i].G_cont[j].text);
						free(lev[i].G_cont[j].points);
					}
					free(lev[i].G_elem);
					free(lev[i].G_cont);
				}
				break;
			}
		}
		if (i==G_nolev) {
			printf("Cant Find Level\n");
		}
	}
}
int addutln(char *ln,int len) {
	G_noutl++;
	G_utl=realloc(G_utl,G_noutl*sizeof(char *));
	G_utl[G_noutl-1]=malloc(len+2);
	memcpy(G_utl[G_noutl-1],ln,len);
	return(G_noutl-1);
}