#include <graphics.h>
#include <alloc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "tdef.h"
int getnext(int typ);

/* add an element to the current level */
int addelem(void) {
	char tmp[40],tmp1[5];
	shape *t;
	if ((G_elemt>3)&&(G_elemt<8)) {      		/* if report/super etc */
		if (getnext(G_elemt)!=10) return(-1);   /* get next free ident */
	}
	if (G_nowelem[G_nowlev]<=G_noelem[G_nowlev]) {  /* grab another lump if needed */
		G_nowelem[G_nowlev]+=10;
		lev[G_nowlev].G_elem=(shape *)
			realloc(lev[G_nowlev].G_elem,sizeof(shape)*G_nowelem[G_nowlev]);
		if (lev[G_nowlev].G_elem==(shape *)NULL) {
			G_nowelem[G_nowlev]-=10;
			return(0);
		}
	}
	t=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]]);		/* next elem this level */
	t->xpos=(0-G_xpos)+(msex-WINX)+(G_wid[G_elemt]/2);
	t->ypos=((0-G_ypos)+(msey-WINY));
	t->type=G_elemt;
	t->deled=0;
	switch (G_elemt) {
		case 1 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Menu System (%d)\n",t->ident);
		} break;
		case 2 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Process (%d)\n",t->ident);
		} break;
		case 3 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Port (%d)\n",t->ident);
		} break;
		case 4 : {
			t->ident=getnext(G_elemt);
			G_used[0]=1;
			strcpy(tmp,"SUPERVISOR PROCESS");
		} break;
		case 5 : {
			t->ident=getnext(G_elemt);
			G_used[1]=1;
			strcpy(tmp,"CAL/ALARM PROCESS");
		} break;
		case 6 : {
			t->ident=getnext(G_elemt);
			G_used[2]=1;
			strcpy(tmp,"REPORT PROCESS");
		} break;
        case 7 : {
			t->ident=getnext(G_elemt);
			G_used[3]=1;
			strcpy(tmp,"PRINTER PROCESS");
		} break;
		case 8 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Store (%d)\n",t->ident);
		} break;
		case 9 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Entity (%d)\n",t->ident);
		} break;
		case 11 :
		case 12 :
		case 14 : {
			t->ident=(-1);
			strcpy(tmp,"LUNDEFINED^Z");
		} break;
		case 13 : {
			strcpy(tmp,"LREPEAT^Z");
			tmp1[0]='C';
			tmp1[1]=45;
			tmp1[2]=0;
			tmp1[3]='Z';
			t->ident=addutln(tmp1,4);
		} break;
		case 15 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Menu (%d)\n",t->ident);
		} break;
		case 16 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Form (%d)\n",t->ident);
		} break;
		case 19 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Text Item %d\n",t->ident);
		} break;
		case 20 : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"Sub Form (%d)\n",t->ident);
		} break;
		default : {
			t->ident=getnext(G_elemt);
			sprintf(tmp,"(%d)\n",t->ident);
		}
	}
	t->text=malloc(strlen(tmp)+1);
	strcpy(t->text,tmp);
	t->colour=((G_tcol<<4)+G_lcol);
	t->level=(-1);
	drelem(1,G_xpos,G_ypos,t,1);
	G_noelem[G_nowlev]++;
	return(1);
}

/* find the element under the cursor or -1 */
int findelem(void) {
	static int i=0,lastlev=-1;
	int start;
	shape *t;

	start=i;
	if (lastlev!=G_nowlev) start=0;
	for (i=start+1;i!=start;i++) {
		if (i==G_noelem[G_nowlev]) i=0;
		t=&(lev[G_nowlev].G_elem[i]);
		if((t->xpos+(G_wid[t->type]/2)>((0-G_xpos)+(msex-WINX)))
		&& (t->xpos-(G_wid[t->type]/2)<((0-G_xpos)+(msex-WINX)))
		&& (t->ypos<((0-G_ypos)+(msey-WINY)))
		&& (t->ypos+G_hgt[t->type]>((0-G_ypos)+(msey-WINY)))) {
			if (t->deled==0) return(i);
		}
		if (i==start) return (-1);
	}
	return(-1);
}

/*	add a line (exciting isn't it) */
int addcont(join *t) {
	int i;
	join *u;
	if (G_nowcont[G_nowlev]<=G_nocont[G_nowlev]) {
		G_nowcont[G_nowlev]+=10;
		lev[G_nowlev].G_cont=(join *)
			realloc(lev[G_nowlev].G_cont,sizeof(join)*G_nowcont[G_nowlev]);
		if (lev[G_nowlev].G_cont==(join *)NULL) {
			G_nowcont[G_nowlev]-=10;
			return(0);
		}
	}
	u=&(lev[G_nowlev].G_cont[G_nocont[G_nowlev]]);	/* set up all stuff */
	u->from=t->from;
	u->to=t->to;
	u->text=malloc(strlen(t->text)+1);
	strcpy(u->text,t->text);
	u->tpos.x=t->tpos.x;
	u->tpos.y=t->tpos.y;
	u->pos.x=t->pos.x;
	u->pos.y=t->pos.y;
	u->flags=t->flags;
	u->points=(int far *)malloc(t->flags.NOPNT*sizeof(int));
	for (i=0;i<t->flags.NOPNT;i++) {
		u->points[i]=t->points[i];
	}
	u->deled=0;
	u->ident=(-1);
	drcont(1,G_xpos,G_ypos,u,1);
	G_nocont[G_nowlev]++;
	return(1);
}

/* find a conection */
int findcont(void) {
	int item,i,lp;
	int x1,x2,y1,y2;
	join *e;
	for (item=0;item<G_nocont[G_nowlev];item++) {	/* while lines */
		e=&(lev[G_nowlev].G_cont[item]);            /* e = current */
			/* if not a PSD (Can't move them stupid) */
		if ((lev[G_nowlev].G_elem[e->from].type<11)||(lev[G_nowlev].G_elem[e->from].type>14)) {
			x1=G_xpos+e->pos.x;
			y1=G_ypos+e->pos.y;
				/* move allong the line. Checking to see if it's ever
					within G_snapto/2 of the cursor position */
			if (e->flags.DIR) {							/* RIGHT/LEFT */
				lp=e->pos.y;
				for(i=0;i<e->flags.NOPNT;i++) {
					if (i&1) { 							/* VERT */
						x2=G_xpos+lp;
						y2=G_ypos+e->points[i];
						if ((min(y1,y2)<msey-WINY)
						&&	(max(y1,y2)>msey-WINY)
						&&	(x1+(G_snapto/2)>msex-WINX)
						&&	(x1-(G_snapto/2)<msex-WINX)) {
							G_partln.pos=i-1;
							G_partln.dir=1;
							if (e->deled==0) return(item);
						}
						x1=x2;
						y1=y2;
						lp=e->points[i];
					}
					else {								/* HORIZ */
						x2=G_xpos+e->points[i];
						y2=G_ypos+lp;
						if ((min(x1,x2)<msex-WINX)
						&&	(max(x1,x2)>msex-WINX)
						&&	(y1+G_snapto>msey-WINY)
						&&	(y1-G_snapto<msey-WINY)) {
							G_partln.pos=i-1;
							G_partln.dir=0;
							if (e->deled==0) return(item);
						}
						x1=x2;
						y1=y2;
						lp=e->points[i];
					}
				}
			}
			else {										/* UP/DOWN */
				lp=e->pos.x;
				for(i=0;i<e->flags.NOPNT;i++) {
					if (i&1) {							/* HORIZ */
						x2=G_xpos+e->points[i];
						y2=G_ypos+lp;
						if ((min(x1,x2)<msex-WINX)
						&&	(max(x1,x2)>msex-WINX)
						&&	(y1+G_snapto>msey-WINY)
						&&	(y1-G_snapto<msey-WINY)) {
							G_partln.pos=i-1;
							G_partln.dir=0;
							if (e->deled==0) return(item);
						}
						x1=x2;
						y1=y2;
						lp=e->points[i];
					}
					else {		 						/* VERT */
						x2=G_xpos+lp;
						y2=G_ypos+e->points[i];
						if ((min(y1,y2)<msey-WINY)
						&&	(max(y1,y2)>msey-WINY)
						&&	(x1+(G_snapto/2)>msex-WINX)
						&&	(x1-(G_snapto/2)<msex-WINX)) {
							G_partln.pos=i-1;
							G_partln.dir=1;
							if (e->deled==0) return(item);
						}
						x1=x2;
						y1=y2;
						lp=e->points[i];
					}
				}
			}
		}
	}
	return(-1);
}

/* find a lump of text as I live and breathe */
/* find text on line within G_snapto/2 of cursor pos */
int findtext(void) {
	int i,w,h,x,y;
	join *e;
	for (i=0;i<G_nocont[G_nowlev];i++) {
		e=&(lev[G_nowlev].G_cont[i]);
		x=G_xpos+e->tpos.x;
		y=G_ypos+e->tpos.y;
		w=textwidth(e->text)/2;
		h=textheight(e->text);
		if (((msex-WINX)+(G_snapto/2)>(x-w))&&((msex-WINX)-(G_snapto/2)<(x+w))
		&&	((msey-WINY)-(G_snapto/2)<(y+h))&&((msey-WINY)+(G_snapto/2)>y)) {
			if (e->deled==0) return(i);
		}
	}
	return(-1);
}

/* really delete a line */
void delcont(int item) {
	int i;
	for (i=item+1;i<G_nocont[G_nowlev];i++) {
		memcpy(&(lev[G_nowlev].G_cont[i-1]),&(lev[G_nowlev].G_cont[i]),sizeof(join));
	}
	G_nocont[G_nowlev]--;
}

/* really delete an element */
void delelem(int item) {
	int i;
	/* delete the element */
	for (i=item+1;i<G_noelem[G_nowlev];i++) {
		memcpy(&(lev[G_nowlev].G_elem[i-1]),&(lev[G_nowlev].G_elem[i]),sizeof(shape));
	}
	G_noelem[G_nowlev]--;
	/* delete all lines from/to element deleted */
	for (i=0;i<G_nocont[G_nowlev];i++) {
		if ((lev[G_nowlev].G_cont[i].from==item)
		||	(lev[G_nowlev].G_cont[i].to==item)) {
			delcont(i--);
		}
	}
	/* change numbering on remaining lines cos weve just deleted one */
	for (i=0;i<G_nocont[G_nowlev];i++) {
		if (lev[G_nowlev].G_cont[i].from>item) {
			lev[G_nowlev].G_cont[i].from--;
		}
		if (lev[G_nowlev].G_cont[i].to>item) {
			lev[G_nowlev].G_cont[i].to--;
		}
	}
}

/* Top PSD element. Dumps top PSD when first selected on PSD/DFD level*/
int tpsdelem(int level,int item) {
	int i;
	shape *t;
	char txt[200],*tx;

	if (G_noelem[G_nowlev]!=0) return(1);

	if (G_inform) {
		for(i=0;i<G_noseqs;i++) {			/* get name from level info created from form */
			if (G_nowlev==G_seqs[i].seq) {
				strcpy(txt,G_seqs[i].name);
				break;
			}
		}
	}
	else {
		if (lev[level].G_elem[item].type==11) {		/* Normal PSD - error seq */
			for(i=0;i<G_noseqs;i++) {               /* look at bottom line */
				if (lev[level].G_elem[item].ident==G_seqs[i].seq) {
					strcpy(txt,G_seqs[i].name);
					break;
				}
			}
		}
		else {
			strcpy(txt,lev[level].G_elem[item].text);	/* else get text */
		}
	}

	if (G_nowelem[G_nowlev]<=G_noelem[G_nowlev]) { /* grab space */
		G_nowelem[G_nowlev]+=10;
		lev[G_nowlev].G_elem=(shape *)
			realloc(lev[G_nowlev].G_elem,sizeof(shape)*G_nowelem[G_nowlev]);
		if (lev[G_nowlev].G_elem==(shape *)NULL) {
			G_nowelem[G_nowlev]-=10;
			return(0);
		}
	}
	t=&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]]);       /* t = new one */
	t->xpos=(((G_maxx-WINX-11)/2)/G_snapto)*G_snapto;
	t->ypos=10;
	t->type=14;
	t->deled=0;
	tx=txt;
	if (txt[0]=='L') {				/* strip leading L and trailing ^ or Z */
		for (i=0;i<strlen(txt);i++) {
			if ((txt[i]=='^')&&(txt[i+1]=='Z')) {
				txt[i]=0;
				tx++;
				break;
			}
		}
	}
	for (i=0;i<strlen(tx);i++) if (txt[i]=='\n') txt[i]=' ';
	t->text=malloc(strlen(tx)+5);
	sprintf(t->text,"L%s^Z",tx);
	t->colour=((G_tcol<<4)+G_lcol);
	t->level=(-1);
	G_noelem[G_nowlev]++;
	return(1);
}

/* add a psd conection */
void addpsdln(int from,int to) {
	join t;
	t.from=from;
	t.to=to;
	t.text=malloc(1);
	t.text[0]=0;
	t.tpos.x=0;
	t.tpos.y=0;
	t.pos.x=lev[G_nowlev].G_elem[from].xpos;
	t.pos.y=lev[G_nowlev].G_elem[from].ypos+G_hgt[lev[G_nowlev].G_elem[from].type];
	t.flags.TXTON=0;
	t.flags.TYPE=1;
	t.flags.LCOL=G_lcol;
	t.flags.TCOL=G_tcol;
	t.flags.DIR=0;
	t.flags.NOPNT=3;
	t.points=(int far *)malloc(3*sizeof(int));
	t.points[0]=lev[G_nowlev].G_elem[to].ypos-15;
/*	t.points[0]=mid(lev[G_nowlev].G_elem[to].ypos,t.pos.y);*/
	t.points[1]=lev[G_nowlev].G_elem[to].xpos;
	t.points[2]=lev[G_nowlev].G_elem[to].ypos;
	addcont(&t);
	free(t.points);
	free(t.text);
}

/*  icon just selected. highlight it and normalise the other one*/
int selelem(int res) {
	int m;
	static int pos=0;
	if (res==(-1)) {  /* select one from mouse pos */
		if (pos==((msey-WINY)/45)+(9*(msex>(WINX/2)))) return(pos);
		if (msey>WINY+405) return(-1);
		if (msex>WINX) return(-1);
		if (G_icontype[G_levtype*(msex>(WINX/2))][((msey-WINY)/45)]==(-1)) return(-1);
	}
	if ((m=mousecur(3))==1) mousecur(0);
	setviewport(0,0,G_maxx,G_maxy,1);
	setfillstyle(1,0);
		/* turn off old one */
	bar(((WINX/2)*(pos>8))+1,((pos%9)*45)+WINY+1,(WINX-(((WINX/2)-1)*(pos<9)))-2,(((pos%9)+1)*45)+WINY-1);
	puticon(10+((pos/9)*(WINX/2)),WINY+5+((pos%9)*45),G_icontype[G_levtype*(pos>8)][pos%9],0,11);
	if (res==(-1)) pos=((msey-WINY)/45)+(9*(msex>(WINX/2))); else pos=res;
	setfillstyle(1,11);
	bar(((WINX/2)*(pos>8))+1,((pos%9)*45)+WINY+1,(WINX-(((WINX/2)-1)*(pos<9)))-2,(((pos%9)+1)*45)+WINY-1);
	puticon(10+((pos/9)*(WINX/2)),WINY+5+((pos%9)*45),G_icontype[G_levtype*(pos>8)][pos%9],1,11);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	if (m) mousecur(1);
	return(pos);
}

/* get subsiduary select */
void getsubsels(int item) {
	int i;
	G_noselc++;
	G_selected[G_noselc-1]=item;
	lev[G_nowlev].G_elem[item].colour^=0x11;
	drelem(1,G_xpos,G_ypos,&(lev[G_nowlev].G_elem[item]),1);
	for (i=0;i<G_nocont[G_nowlev];i++) {
		if (lev[G_nowlev].G_cont[i].from==item) {
			getsubsels(lev[G_nowlev].G_cont[i].to);
		}
	}
}

/* get side cells and sub cells */
void getsidsels(int item) {
	int i;
	for (i=0;i<G_noelem[G_nowlev];i++) {
		if (lev[G_nowlev].G_elem[i].ypos==lev[G_nowlev].G_elem[item].ypos) {
			getsubsels(i);
		}
	}
}

/* get right side cells and sub cells */
void getrsidsels(int item) {
	int i;
	for (i=0;i<G_noelem[G_nowlev];i++) {
		if (   (lev[G_nowlev].G_elem[i].ypos==lev[G_nowlev].G_elem[item].ypos)
			&& (lev[G_nowlev].G_elem[i].xpos>=lev[G_nowlev].G_elem[item].xpos)) {
				getsubsels(i);
		}
	}
}
/* imported flows. Mark has yet to fix this. Please thank you. Kind man grovel */
void importdef(int item) {
	item++;
/*	int i,j,xp,yp,epos,spos,br;
	int pos=0,noln=0,*lnnos;
	int xit=0;
	char tmp[200];
	lnnos=malloc(1);
	mousecur(1);
	getuplev()

	for (i=0;i<G_nocont[G_upl];i++) {
		if (lev[G_upl].G_cont[i].to==G_upe) {
			noln++;
			lnnos=realloc(lnnos,noln*sizeof(int));
			lnnos[noln-1]=lev[ablev].G_cont[i].from;
		}
		if (lev[G_upl].G_cont[i].from==G_upe) {
			noln++;
			lnnos=realloc(lnnos,noln*sizeof(int));
			lnnos[noln-1]=lev[ablev].G_cont[i].to;
		}
	}
	xp=4;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*pos)/(noln+1));
	epos=((br*(pos+27))/(noln+1));
	setcolor(9);
	mousecur(0);
	setfillstyle(1,0);
	bar(xp+6,110,120,yp);
	rectangle(xp+16,90,120,yp);
	rectangle(xp+6,110,xp+16,yp);
	setfillstyle(11,9);
	bar(xp+7,121,xp+15,yp-11);
	setfillstyle(1,9);
	rectangle(xp+6,110,xp+16,120);
	rectangle(xp+6,yp-10,xp+16,yp);
	if (((epos+121)<(yp-11))||(spos!=0)) bar(xp+7,121+spos,xp+15,121+epos);
	for (i=110;i<yp;i+=11) line(xp+16,i,120,i);
	setcolor(14);
	settextstyle(2,0,4);
	settextjustify(0,2);
	outtxtxy(xp+25,95,"EXTERNAL");
	for (i=0;i<min(26,noln);i++) {
		strcpy(tmp,lev[G_upl].G_elem[lnnos[i]].text);
		tmp[15]=0;
		outtxtxy(xp+20,110+(i*11),tmp);
	}
	mousecur(1);
	while (!xit) {
		if (mousetrap(1)) {
			if (mseb==1) {
				if (inbox(WINX+20,WINY+110,WINX+120,WINY+110+(min(26,noln)*11))) {
					free(lev[G_nowlev].G_elem[item].text);
					lev[G_nowlev].G_elem[item].text=
						lev[ablev].G_elem[lnnos[((msey-WINY-110)/11)]].text;
					lev[G_nowlev].G_elem[item].ident=
						lnnos[((msey-WINY-110)/11)];
					xit=1;
				}
			}
		}
	}
	while (mseb) mousetrap(G_snapto);
	free(lnnos);
	mousecur(0);*/
}

/* printer alignment */
void alignprn(void) {
	FILE *printer;
	int i,j;

	if ((printer=fopen("prn","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		fprintf(printer,"%c*%c%c%c%c%c%c",27,39,G_dpl%256,G_dpl/256,255,255,255);
		for (j=0;j<100;j++) fprintf(printer,"%c%c%c",128,0,0);
		for (j=0;j<G_dpl-202;j++) fprintf(printer,"%c%c%c",0,0,0);
		for (j=0;j<100;j++) fprintf(printer,"%c%c%c",128,0,0);
		fprintf(printer,"%c%c%c\n",255,255,255);
		for (i=0;i<(G_dpp-16)/8;i++) {
			fprintf(printer,"\n");
		}
		fprintf(printer,"%cA%c\n",27,G_dpp%8);
		fprintf(printer,"%cA%c",27,8);
		fprintf(printer,"%c*%c%c%c%c%c%c",27,39,G_dpl%256,G_dpl/256,255,255,255);
		for (j=0;j<100;j++) fprintf(printer,"%c%c%c",0,0,1);
		for (j=0;j<G_dpl-202;j++) fprintf(printer,"%c%c%c",0,0,0);
		for (j=0;j<100;j++) fprintf(printer,"%c%c%c",0,0,1);
		fprintf(printer,"%c%c%c\n",255,255,255);
		fprintf(printer,"%c",12);
		fclose(printer);
	}
}

/* get next free element number of this type on current level */
int getnext(int typ) {
	int i,j=0,xit=0;

	if (typ!=8) j=9;     		/* not store starts at 10 */
	while (!xit) {
		j++;
		if ((typ==15)||(typ==16)) {
			for (i=0;i<G_noelem[G_nowlev];i++) {
				if (((lev[G_nowlev].G_elem[i].type==15)
				||	 (lev[G_nowlev].G_elem[i].type==16))
				&&	(!lev[G_nowlev].G_elem[i].deled)
				&&	(lev[G_nowlev].G_elem[i].ident==j)) break;
			}
		}
		else {                 /* needs mod to seperate process ids */
			for (i=0;i<G_noelem[G_nowlev];i++) {
				if ((lev[G_nowlev].G_elem[i].type==typ)
				&&	(!lev[G_nowlev].G_elem[i].deled)
				&&	(lev[G_nowlev].G_elem[i].ident==j)) break;
			}
		}
		if (i==G_noelem[G_nowlev]) xit=j;
	}
	return(xit);
}
