#include <graphics.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include <alloc.h>
#include "tv.h"

/*extern  void  setmousexto(int newx);
extern  void  setmouseyto(int newy);
extern  void  mousecur(int onoff);
extern  void  setupmouse(int x,int y,int xmin,int xmax,int ymin,int ymax);
extern  int   mousetrap(void);*/
extern  int   mousestat(void);

void negipic(int np,struct pnts **p,int divr,int interp,int x,int y,int a);
void posipic(int np,struct pnts **p,int mult,int interp,int x,int y,int a);

int mousestat(void){ return(0); }

void adjdiag(int diagno,int xp,int yp,int zoom) {
	float prasp=0.75;
	int i,j;
	int x1,y1;
	int x2,y2;
	int nops,*bas,np;
	int mult,divr;
	struct pnts *p;
	divr=1<<(G_swap[diagno]-zoom);
	x1=maxx/2-xp/divr;
	y1=(maxy/2-yp/divr)*prasp;
	mult=1<<(zoom-G_swap[diagno]);
	x2=maxx/2-xp*mult;
	y2=(maxy/2-yp*mult)*prasp;
	np=nopolys[diagno]-1;
	i=(-1);
	if (zoom<G_swap[diagno]) {
		while (i++<np) {
			p=polp[diagno][i];
			if (G_onlylev==0) {
				if ((p->typacol&0x0F)!=G_omitlev) {
					setlinestyle(p->ltafs>>4,0,0);
					setcolor(colours[p->typacol&0x0F]);
					nops=p->nopts*2;
					bas=p->base;
					moveto(x1+(bas[0]-minx[diagno])/divr,y1+((bas[1]-miny[diagno])/divr)*prasp);
					j=0;
					while ((j+=2)<nops) lineto(x1+(bas[j]-minx[diagno])/divr,y1+((bas[j+1]-miny[diagno])/divr)*prasp);
				}
			}
			else {
				if ((p->typacol&0x0F)==G_onlylev) {
					setlinestyle(p->ltafs>>4,0,0);
					setcolor(colours[p->typacol&0x0F]);
					nops=p->nopts*2;
					bas=p->base;
					moveto(x1+(bas[0]-minx[diagno])/divr,y1+((bas[1]-miny[diagno])/divr)*prasp);
					j=0;
					while ((j+=2)<nops) lineto(x1+(bas[j]-minx[diagno])/divr,y1+((bas[j+1]-miny[diagno])/divr)*prasp);
				}
			}
		}
	}
	else {
		while (i++<np) {
			p=polp[diagno][i];
			if (G_onlylev==0) {
				if ((p->typacol&0x0F)!=G_omitlev) {
					setlinestyle(p->ltafs>>4,0,0);
					setcolor(colours[p->typacol&0x0F]);
					nops=p->nopts*2;
					bas=p->base;
					moveto(x2+(bas[0]-minx[diagno])*mult,y2+((bas[1]-miny[diagno])*mult)*prasp);
					j=0;
					while((j+=2)<nops) lineto(x2+(bas[j]-minx[diagno])*mult,y2+((bas[j+1]-miny[diagno])*mult)*prasp);
				}
			}
			else {
				if ((p->typacol&0x0F)==G_onlylev) {
					setlinestyle(p->ltafs>>4,0,0);
					setcolor(colours[p->typacol&0x0F]);
					nops=p->nopts*2;
					bas=p->base;
					moveto(x2+(bas[0]-minx[diagno])*mult,y2+((bas[1]-miny[diagno])*mult)*prasp);
					j=0;
					while((j+=2)<nops) lineto(x2+(bas[j]-minx[diagno])*mult,y2+((bas[j+1]-miny[diagno])*mult)*prasp);
				}
			}
		}
	}
}
void drawdiag(int diagno,int xp,int yp,int zoom,int interp) {
	int i,j,k,l;
	int x1,y1,mx,my,mox,moy;
	int x2,y2;
	int np;
	int mult,divr;
	struct pnts **p;
	char tmpln[150];

	mx=minx[diagno]+xp;
	my=miny[diagno]+yp;
	mox=maxx/2;
	moy=maxy/2;
	divr=1<<(G_swap[diagno]-zoom);
	x1=mox-mx/divr;
	y1=moy-my/divr;
	mult=1<<(zoom-G_swap[diagno]);
	x2=mox-mx*mult;
	y2=moy-my*mult;
	np=nopolys[diagno]-1;
	p=polp[diagno];
	i=(-1);
	if (!G_onlylev) {
		if (!G_omitlev) {
			if (!G_steplev) {
				if (zoom<G_swap[diagno]) {
					negipic(np,p,divr,interp,x1,y1,0);
				}
				else {
					posipic(np,p,mult,interp,x2,y2,0);
				}
			}
			else {
				if (zoom<G_swap[diagno]) {
					negipic(np,p,divr,interp,x1,y1,1);
				}
				else {
					posipic(np,p,mult,interp,x2,y2,1);
				}
			}
		}
		else {
			if (zoom<G_swap[diagno]) {
				negipic(np,p,divr,interp,x1,y1,3);
			}
			else {
				posipic(np,p,mult,interp,x2,y2,3);
			}
		}
	}
	else {
		if (zoom<G_swap[diagno]) {
			negipic(np,p,divr,interp,x1,y1,2);
		}
		else {
			posipic(np,p,mult,interp,x2,y2,2);
		}
	}
    if (G_tno) {
		settextstyle(2,0,4);
		setfillstyle(1,0);
		setcolor(textcol);
		if (!(overtext)) {
			bar(G_winpos[((G_tno-1)*4)],G_winpos[((G_tno-1)*4)+1],G_winpos[((G_tno-1)*4)+2],G_winpos[((G_tno-1)*4)+3]);
			rectangle(G_winpos[((G_tno-1)*4)],G_winpos[((G_tno-1)*4)+1],G_winpos[((G_tno-1)*4)+2],G_winpos[((G_tno-1)*4)+3]);
		}
		setviewport(G_winpos[((G_tno-1)*4)],G_winpos[((G_tno-1)*4)+1],G_winpos[((G_tno-1)*4)+2],G_winpos[((G_tno-1)*4)+3],1);
		j=textpos[diagno];
		i=2;
		tmpln[1]=0;
		while(i<G_winpos[((G_tno-1)*4)+3]-G_winpos[((G_tno-1)*4)+1]) {
			l=0;
			for (k=0;k<strlen(&textlns[diagno][j]);k++) {
				if ((textlns[diagno][j+k]<16)&&(textlns[diagno][j+k]>0)) {
					setcolor(textlns[diagno][j+k]);
				}
				else {
					tmpln[0]=textlns[diagno][j+k];
					outtextxy(2+l*6,i,tmpln);
					l++;
					if (((l+1)*6)>G_winpos[((G_tno-1)*4)+2]-G_winpos[((G_tno-1)*4)]) {
						i+=8;
						l=0;
					}
				}
			}
            i+=8;
			while(textlns[diagno][j++]!=0);
		}
		setviewport(0,0,maxx,maxy,1);
	}
	if (G_hno) {
		settextstyle(2,0,4);
		setfillstyle(1,0);
		setcolor(helpcol);
		if (!(overhelp)) {
			bar(G_winpos[((G_hno-1)*4)],G_winpos[((G_hno-1)*4)+1],G_winpos[((G_hno-1)*4)+2],G_winpos[((G_hno-1)*4)+3]);
			rectangle(G_winpos[((G_hno-1)*4)],G_winpos[((G_hno-1)*4)+1],G_winpos[((G_hno-1)*4)+2],G_winpos[((G_hno-1)*4)+3]);
		}
		setviewport(G_winpos[((G_hno-1)*4)],G_winpos[((G_hno-1)*4)+1],G_winpos[((G_hno-1)*4)+2],G_winpos[((G_hno-1)*4)+3],1);
		j=helppos;
		i=2;
		tmpln[1]=0;
		while(i<G_winpos[((G_hno-1)*4)+3]-G_winpos[((G_hno-1)*4)+1]) {
			l=0;
			for (k=0;k<strlen(&helplns[j]);k++) {
				if (helplns[j+k]<16) {
					setcolor(helplns[j+k]);
				}
				else {
					tmpln[0]=helplns[j+k];
					outtextxy(2+l*6,i,tmpln);
					l++;
				}
			}
			i+=8;
			while(helplns[j++]!=0);
		}
		setviewport(0,0,maxx,maxy,1);
	}
}

void drawmini(int diagno,int crbdn) {
	int i,j;
	int far *pp;
	int x,y;
	int xc,yc;
	char tmpstr[6];
	maxlevel[diagno]=0;
	i=max(dify[diagno],difx[diagno]);
	G_swap[diagno]=0;
	if (i>maxy) {
		while ((i>>=1)>maxy/2) G_swap[diagno]++;
	}
	else {
		if (i>0) {
			while ((i<<=1)<maxy/2) G_swap[diagno]--;
		}
	}
	if (G_swap[diagno]>=0) {
		xc=((diagno%crbdn)*(maxx/crbdn))+(maxx/(2*crbdn));
		yc=((diagno/crbdn)*(maxy/crbdn))+(maxy/(2*crbdn));
		x=xc-((difx[diagno]/2)>>G_swap[diagno])/crbdn;
		y=yc-((dify[diagno]/2)>>G_swap[diagno])/crbdn;
		setcolor(BACKCOL);
		setlinestyle(0,0,0);
		rectangle(xc-(maxx/(2*crbdn)),yc-(maxy/(2*crbdn)),xc+(maxx/(2*crbdn)),yc+(maxy/(2*crbdn)));
		pp=farmalloc(maxpoints[diagno]*4);
		for (i=0;i<nopolys[diagno];i++) {
			maxlevel[diagno]=max(maxlevel[diagno],polp[diagno][i]->typacol&0x0F);
			if ((polp[diagno][i]->typacol&0x0F)==G_level1) {
				if (G_numbparts[1][diagno]==0) {
					setcolor(colours[polp[diagno][i]->typacol&0x0F]-1);
				}
				else {
					setcolor(colours[polp[diagno][i]->typacol&0x0F]);
				}
				for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
					pp[j  ]=x+(((polp[diagno][i]->base[j  ]-minx[diagno])/(1<<G_swap[diagno]))/crbdn);
					pp[j+1]=y+(((polp[diagno][i]->base[j+1]-miny[diagno])/(1<<G_swap[diagno]))/crbdn);
				}
				drawpoly(polp[diagno][i]->nopts,pp);
			}
		}
		farfree(pp);
	}
	else {
		xc=((diagno%crbdn)*(maxx/crbdn))+(maxx/(2*crbdn));
		yc=((diagno/crbdn)*(maxy/crbdn))+(maxy/(2*crbdn));
		x=xc-((difx[diagno]/2)<<(0-G_swap[diagno]))/crbdn;
		y=yc-((dify[diagno]/2)<<(0-G_swap[diagno]))/crbdn;
		setcolor(15);
		setlinestyle(0,0,0);
		rectangle(xc-(maxx/(2*crbdn)),yc-(maxy/(2*crbdn)),xc+(maxx/(2*crbdn)),yc+(maxy/(2*crbdn)));
		pp=farmalloc(maxpoints[diagno]*4);
		for (i=0;i<nopolys[diagno];i++) {
			if ((polp[diagno][i]->typacol&0x0F)==G_level1) {
				setcolor(colours[polp[diagno][i]->typacol&0x0F]);
				for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
					pp[j  ]=x+(((polp[diagno][i]->base[j  ]-minx[diagno])*(1<<G_swap[diagno]))/crbdn);
					pp[j+1]=y+(((polp[diagno][i]->base[j+1]-miny[diagno])*(1<<G_swap[diagno]))/crbdn);
				}
				drawpoly(polp[diagno][i]->nopts+2,pp);
			}
		}
		farfree(pp);
	}
	itoa(G_numbparts[1][diagno],tmpstr,10);
#ifdef WPNPE   /*	print number of parts expected on window	*/
	outtextxy(xc-(maxx/(2*crbdn))+2,yc-(maxy/(2*crbdn))+2,tmpstr);
#endif
}
void negipic(np,p,divr,interp,x,y,a)
int np;
struct pnts **p;
int divr;
int interp;
int x;
int y;
int a; {
	int i,dot=0,colr;
	int xpos,ypos;
	int nops,*bas;
	struct pnts *pp;
	i=(-1);
	while (i++<np) {
		if (interp==2) if (kbhit()||mousestat()) dot=2;
		if (interp==1) {
			if (kbhit()||mousestat()) {
				i=np;
				dot=1;
			}
		}
		pp=p[i];
		nops=pp->nopts;
		nops--;
		bas=pp->base;
		xpos=x+*(bas++)/divr;
		ypos=y+*(bas++)/divr;
		colr=pp->typacol&0x0F;
		switch (a) {
			case 1 : {
				if (colr<=G_steplev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			case 2 : {
				if (colr==G_onlylev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			case 3 : {
				if (colr!=G_omitlev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			default : {
				setcolor(colours[colr]);
				colr=(-1);
			}
		}
		if (colr==(-1)) {
			moveto(xpos,ypos);
			while (nops--) {
				xpos=x+*(bas++)/divr;
				ypos=y+*(bas++)/divr;
				lineto(xpos,ypos);
			}
		}
	}
}
void posipic(np,p,mult,interp,x,y,a)
int np;
struct pnts **p;
int mult;
int interp;
int x;
int y;
int a; {
	int i,dot=0,colr;
	int xpos,ypos;
	int nops,*bas;
	struct pnts *pp;
	i=(-1);
	while (i++<np) {
		if (interp==2) if (kbhit()||mousestat()) dot=2;
		if (interp==1) {
			if (kbhit()||mousestat()) {
				i=np;
				dot=1;
			}
		}
		pp=p[i];
		nops=pp->nopts;
		nops--;
		bas=pp->base;
		xpos=x+*(bas++)*mult;
		ypos=y+*(bas++)*mult;
		colr=pp->typacol&0x0F;
		switch (a) {
			case 1 : {
				if (colr<=G_steplev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			case 2 : {
				if (colr==G_onlylev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			case 3 : {
				if (colr!=G_omitlev) {
					setcolor(colours[colr]);
					colr=(-1);
				}
			} break;
			default : {
				setcolor(colours[colr]);
				colr=(-1);
			}
		}
		if (colr==(-1)) {
			moveto(xpos,ypos);
			while (nops--) {
				xpos=x+*(bas++)*mult;
				ypos=y+*(bas++)*mult;
				lineto(xpos,ypos);
			}
		}
	}
}
