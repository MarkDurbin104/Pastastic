#include <graphics.h>
#include <string.h>
#include <alloc.h>
#include <stdio.h>
#include <time.h>
#include <dos.h>
#include <conio.h>
#include <ctype.h>
#include <stdlib.h>
#include "tdef.h"

#define DOTSP(a) fprintf(p,"%cA%c",27,a);

void	redrawln(file *t,int i);
void	dump(char *bcols);
void	calcofs(file *t);
void	markln(file *t,int i,int col);
void	reorderk(file *t,int i);
int		intcmp(int *a,int *b);
void	movefield(file *t);
void	cngftype(file *t);
void	cngfname(file *t,int item);
void	cngfdesc(file *t);
void	cngkey(file *t);
void	cngname(file *t);
void	cngtype(file *t);
void	cnglen(file *t);
void	cngofs(file *t);
void	cngdesc(file *t);
int		okbut(file *t);
void	canbut(file *t);
void	prdict(int pos);
void	chkdict(file *t);

int G_dictptr;
int G_fileptr;
char colmap[16][4]={{ 0, 0, 0, 0},
					{ 1, 2, 4, 8},
					{ 8, 4, 2, 1},
					{ 5, 0, 5, 0},
					{ 0, 5, 0, 5},
					{ 5, 5, 5, 5},
					{10,10,10,10},
					{ 9, 6, 9, 6},
					{ 6, 9, 6, 9},
					{10, 5,10, 5},
					{ 5,10, 5,10},
					{ 3,12, 3,12},
					{12, 3,12, 3},
					{ 7,14, 7,14},
					{14, 7,14, 7},
					{15,15,15,15}};
int G_storeid;
int G_modid;
void dstoredef(int item) {
	int xit;
	file *t;
	G_modid=0;
	mousecur(0);
	G_storeid=lev[G_nowlev].G_elem[item].ident-1;
	t=loadfile(G_cellname,G_storeid+1);
	if (t->name[0]==0) {
		if (strlen(lev[G_nowlev].G_elem[item].text)>14) {
			lev[G_nowlev].G_elem[item].text[14]=0;
			lev[G_nowlev].G_elem[item].text=
				realloc(lev[G_nowlev].G_elem[item].text,15);
		}
		strcpy(t->name,lev[G_nowlev].G_elem[item].text);
	}
	else {
		lev[G_nowlev].G_elem[item].text=realloc(lev[G_nowlev].G_elem[item].text,15);
		strcpy(lev[G_nowlev].G_elem[item].text,t->name);
	}
	G_dictptr=0;
	opendict();
	setupscr(t);
	mousecur(1);
	xit=0;
	while (!xit) {
		while ((!((mousetrap(1)>>5)&7))&&(!kbhit()));
		if (kbhit()) {
			if (getch()=='p') prscr();
		}
		else {
			if (mseb==2) movefield(t);
			if (mseb==1) {
				if (inbox(300,30+WINY,320,45+WINY)) cngftype(t);
				if (inbox(150,30+WINY,250,45+WINY)) cngfname(t,item);
				if (inbox(0,45+WINY,G_maxx,60+WINY)) cngfdesc(t);
				if (inbox(16,110+WINY,144,((G_maxy-46)/11)*11)) cngkey(t);
				if (inbox(144,110+WINY,244,((G_maxy-46)/11)*11)) cngname(t);
				if (inbox(244,110+WINY,272,((G_maxy-46)/11)*11)) cngtype(t);
				if (inbox(272,110+WINY,320,((G_maxy-46)/11)*11)) cnglen(t);
				if (inbox(320,110+WINY,364,((G_maxy-46)/11)*11)) cngofs(t);
				if (inbox(364,110+WINY,415,((G_maxy-46)/11)*11)) cngdesc(t);
				if (inbox(225,G_maxy-30,275,G_maxy-10)) xit=okbut(t);
				if (inbox(G_maxx-275,G_maxy-30,G_maxx-225,G_maxy-10)&&(!G_modid)) {
					canbut(t);
					xit=1;
				}
				chkdict(t);
			}
		}
	}
	closedict();
	mousecur(0);
}
void setupscr(file *t) {
	int i,j,xp,yp;
	char tmp[100];
	cleardevice();
	setcolor(14);
	setviewport(0,0,G_maxx,G_maxy,1);
	rectangle(0,0,G_maxx,G_maxy);
	setviewport(0,WINY,G_maxx,G_maxy,1);
	setfillstyle(1,1);
	bar(0,0,G_maxx,G_maxy-WINY);
	rectangle(0,0,G_maxx,G_maxy-WINY);
	line(0,24,G_maxx,24);
	settextstyle(2,0,5);
	sprintf(tmp,"PMA CDL    DATA STORE DEFINITION    CELL %s.",G_cellname);
	outtxtxy(G_maxx/2,2,tmp);
	sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
	outtxtxy(G_maxx/2,30,tmp);
	outtxtxy(G_maxx/2,45,t->desc);
	xp=(G_maxx-32)-176;
	yp=((G_maxy-46-WINY)/11)*11;
	outtxtxy((xp-32)/2,70,"DATA STORE");
	outtxtxy(xp+16+(((G_maxx-16)-(xp+16))/2),70,"DICTIONARY");
	setcolor(9);
	setfillstyle(1,0);
	bar(16,110,xp-16,yp);
	rectangle(16,90,xp-16,yp);
	for (i=110;i<yp;i+=11) line(16,i,xp-16,i);
	for (i=1;i<9;i++) line((i*16),100,(i*16),yp);
	line((i*16),90,(i*16),yp);
	line(16,100,i*16,100);
	line(244,90,244,yp);
	line(272,90,272,yp);
	line(320,90,320,yp);
	line(364,90,364,yp);
	setcolor(14);
	settextstyle(2,0,4);
	for (i=110;i<yp;i+=11) outtxtxy(8,i,itoa((i-110)/11,tmp,10));
	outtxtxy(80,90,"K E Y S");
	for (i=1;i<9;i++) outtxtxy((i*16)+8,100,itoa(i,tmp,10));
	outtxtxy(194,95,"FIELD NAME");
	outtxtxy(258,95,"TYPE");
	outtxtxy(296,95,"LENGTH");
	outtxtxy(342,95,"OFFSET");
	outtxtxy(389,95,"COMMENT");
	button(250,G_maxy-WINY-20,"OK",0,0);
	button(G_maxx-250,G_maxy-WINY-20,"CANCEL",0,0);
	for (i=0;i<t->nofld;i++) {
		if (getdict(t->flds[i]->name)) {
			t->flds[i]->type=G_dictent.type;
			t->flds[i]->len=G_dictent.len;
			strcpy(t->flds[i]->desc,G_dictent.desc);
		}
		else {
			strcpy(G_dictent.name,t->flds[i]->name);
			G_dictent.type=t->flds[i]->type;
			G_dictent.len=t->flds[i]->len;
			strcpy(G_dictent.desc,t->flds[i]->desc);
			putdict();
			prdict(G_dictptr);
		}
		tmp[0]=t->flds[i]->type;
		tmp[1]=0;
		outtxtxy(258,110+(i*11),tmp);
		outtxtxy(194,110+(i*11),t->flds[i]->name);
		outtxtxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
		strcpy(tmp,t->flds[i]->desc);
		tmp[7]=0;
		outtxtxy(389,110+(i*11),tmp);
	}
	calcofs(t);
	for (i=0;i<t->nofld;i++) outtxtxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	for (i=0;i<t->nokey;i++) {
		for (j=0;j<t->keys[i]->noparts;j++) {
			outtxtxy((i*16)+24,110+(t->keys[i]->keypts[j]->fld*11),itoa(t->keys[i]->keypts[j]->fldordr,tmp,10));
		}
	}
	prdict(G_dictptr);
}
void button(int x,int y,char *name,int onoff,int high) {
	struct textsettingstype t;
	int c;

	c=getcolor();
	gettextsettings(&t);
	mousecur(0);
	setcolor(14);
	setfillstyle(1,0);
	bar(x-25,y-10,x+25,y+10);
	arc(x-25,y,90,270,10);
	arc(x+25,y,270,90,10);
	line(x-25,y-10,x+25,y-10);
	line(x-25,y+10,x+25,y+10);
	if (high) {
		arc(x-26,y,90,270,12);
		arc(x+26,y,270,90,12);
		line(x-27,y-12,x+27,y-12);
		line(x-27,y+12,x+27,y+12);
	}
	if (onoff) {
		setfillstyle(1,0);
	}
	else {
		setfillstyle(1,8);
	}
	floodfill(x,y,14);
	settextjustify(1,1);
	settextstyle(0,0,1);
	outtxtxy(x,y,name);

	settextjustify(t.horiz,t.vert);
	settextstyle(t.font,t.direction,t.charsize);
	setcolor(c);
	mousecur(1);
	settextstyle(2,0,4);
}
int intextxy(int x,int y,char *ln,int nochrs,int bcol,int col) {
	char tmp[100];
	int wid,hgt,i,j;
	char k,xit=0;
	char modifyed=0;
	memset(tmp,'8',99);
	tmp[nochrs]=0;
	wid=textwidth(tmp);
	hgt=textheight(tmp);
	setfillstyle(1,bcol);
	setcolor(col);

	strcpy(tmp,ln);
	if (tmp[0]==0) {
		i=0;
	}
	else {
		mousecur(0);
		outtxtxy(x,y,tmp);
		mousecur(1);
		i=strlen(tmp);
	}
	do {
		mousecur(0);
		bar(x-(wid/2),y+2,x+(wid/2),y+hgt+2);
		outtxtxy(x,y,tmp);
		mousecur(1);
		j=x+(textwidth(tmp)/2);
		setcolor(col-2);
		mousecur(0);
		line(j+1,y+1,j+1,y+hgt+1);
		mousecur(1);
		while ((!kbhit())&&(!xit)) {
			if (mousetrap(1)) {
				if (mseb) {
					if (!inbox(x-((wid/2)+1),WINY+y+2,x+((wid/2)+1),WINY+y+hgt+2))
						xit=1;
				}
			}
		}
		mousetrap(G_snapto);
		setcolor(bcol);
		mousecur(0);
		line(j+1,y+1,j+1,y+hgt+1);
		mousecur(1);
		setcolor(col);
		if (!xit) {
			switch (k=getch()) {
				case 8 : {
					if (i>0) {
						tmp[--i]=0;
					}
					modifyed=1;
				} break;
				case 10 :
				case 13 : {
					xit=2;
				} break;
				case 0 : {
					switch (k=getch()) {
						case 'S' : {
							xit=4;
						} break;
					}
				} break;
				case 27 : {
					strcpy(tmp,ln);
					xit=3;
				} break;
				case 1 : {
					mousecur(0);
					dump("");
					mousecur(1);
				} break;
				default : {
					if (!(modifyed)) i=0;
					if (i<nochrs) {
						tmp[i++]=k;
						tmp[i]=0;
					}
					modifyed=1;
				}
			}
		}
	} while (!(xit));
	mousecur(0);
	bar(x-(wid/2),y+2,x+(wid/2),y+hgt+2);
	outtxtxy(x,y,tmp);
	mousecur(1);
	strcpy(ln,tmp);
	return(xit);
}
void dump(char *bcols) {
	int i,j,k,l,m,n,prbyte;
	FILE *printer;
	char col,setit,nocol;
	nocol=strlen(bcols)+1;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (i=0;i<G_maxy;i+=12) {
			fprintf(printer,"%c*%c%c%c",27,39,((G_maxx+1)*2)%256,((G_maxx+1)*2)/256);
			for (j=0;j<=G_maxx;j++) {
				for (n=0;n<2;n++) {
					for (m=0;m<12;m+=4) {
						prbyte=0;
						for (l=0;l<4;l++) {
							if ((j<G_maxx-WINX-11)&&((i+l+m)<G_maxy-WINY-11)) col=getpixel(j,i+l+m)&0x0F; else col=0;
							if (col==0) setit=0; else setit=3;
							for (k=0;k<=nocol;k++) if (col==bcols[k]) setit=0;
							prbyte|=(setit<<(6-(l*2)));
						}
						switch(prbyte) {
/*							case 26 : {
								fprintf(printer,"%c",24);
							} break;
							case 10 : {
								fprintf(printer,"%c",11);
							} break;*/
							default : {
								fprintf(printer,"%c",prbyte);
							}
						}
					}
				}
			}
			fprintf(printer,"\n");
			if (kbhit()) break;
		}
		if (kbhit()) getch();
		fprintf(printer,"%c",12);
		fclose(printer);
	}
}
void redrawln(file *t,int i) {
	int j,k;
	char tmp[99];
	mousecur(0);
	setfillstyle(1,0);
	bar(17,111+i*11,413,120+i*11);
	setcolor(9);
	line(144,111+i*11,144,121+i*11);
	line(244,111+i*11,244,121+i*11);
	line(272,111+i*11,272,121+i*11);
	line(320,111+i*11,320,121+i*11);
	line(364,111+i*11,364,121+i*11);
	for (j=1;j<10;j++) line(j*16,111+i*11,j*16,121+i*11);
	setcolor(14);
	outtxtxy(194,110+(i*11),t->flds[i]->name);
	tmp[0]=t->flds[i]->type;
	tmp[1]=0;
	outtxtxy(258,110+(i*11),tmp);
	outtxtxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
	outtxtxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	strcpy(tmp,t->flds[i]->desc);
	tmp[7]=0;
	outtxtxy(389,110+(i*11),tmp);
	for (k=0;k<t->nokey;k++) {
		for (j=0;j<t->keys[k]->noparts;j++) {
			if (t->keys[k]->keypts[j]->fld==i)
				outtxtxy((k*16)+24,110+(i*11),itoa(t->keys[k]->keypts[j]->fldordr,tmp,10));
		}
	}
	mousecur(1);
}
void calcofs(file *t) {
	int i,run=0;
	for (i=0;i<t->nofld;i++) {
		t->flds[i]->ofs=run;
		run+=t->flds[i]->len;
	}
	t->len=run;
}
void markkey(file *t,int i,int col) {
	int j,yp;
	char tmp[99];
	mousecur(0);
	setfillstyle(1,col);
	yp=((t->nofld*11)+110)-1;
	bar(17+i*16,111,31+i*16,yp);
	setcolor(9);
	for (j=110;j<yp;j+=11) line(16,j,144,j);
	setcolor(14);
	for (j=0;j<t->keys[i]->noparts;j++) {
		outtxtxy((i*16)+24 , 110+(t->keys[i]->keypts[j]->fld*11) ,
			itoa(t->keys[i]->keypts[j]->fldordr,tmp,10));
	}
	mousecur(1);
}

void markln(file *t,int i,int col) {
	int j,k;
	char tmp[99];
	mousecur(0);
	setfillstyle(1,col);
	bar(17,111+i*11,413,120+i*11);
	setcolor(9);
	line(144,111+i*11,144,121+i*11);
	line(244,111+i*11,244,121+i*11);
	line(272,111+i*11,272,121+i*11);
	line(320,111+i*11,320,121+i*11);
	line(364,111+i*11,364,121+i*11);
	for (j=1;j<10;j++) line(j*16,111+i*11,j*16,121+i*11);
	setcolor(14);
	outtxtxy(194,110+(i*11),t->flds[i]->name);
	tmp[0]=t->flds[i]->type;
	tmp[1]=0;
	outtxtxy(258,110+(i*11),tmp);
	outtxtxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
	outtxtxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	strcpy(tmp,t->flds[i]->desc);
	tmp[7]=0;
	outtxtxy(389,110+(i*11),tmp);
	for (k=0;k<t->nokey;k++) {
		for (j=0;j<t->keys[k]->noparts;j++) {
			if (t->keys[k]->keypts[j]->fld==i)
				outtxtxy((k*16)+24,110+(i*11),itoa(t->keys[k]->keypts[j]->fldordr,tmp,10));
		}
	}
	mousecur(1);
}
void reorderk(file *t,int i) {
	int j;
	int tmp[9];
	for (j=0;j<t->keys[i]->noparts;j++) tmp[j]=(t->keys[i]->keypts[j]->fldordr<<8)+j;
	qsort(t,t->keys[i]->noparts,sizeof(int),intcmp);
	for (j=0;j<t->keys[i]->noparts;j++) t->keys[i]->keypts[tmp[j]&0xFF]->fldordr=j+1;
}
int intcmp(int *a,int *b) {
	if (*a<*b) return(-1);
	if (*a>*b) return(1);
	return(0);
}
void movefield(file *t) {
	int cl,i,j,k,my;
	static int marked=(-1);
	struct field *tf;

	cl=(-1);
	if (inbox(16,110+WINY,414,((G_maxy-46)/11)*11)) {
		while (mseb==2) {
			my=msey;
			i=(((my-110)-WINY)/11);
			if (i!=cl) {
				cl=i;
				if (cl<t->nofld) {
					if (marked==(-1)) {
						markln(t,cl,12);
						marked=cl;
					}
					else {
						if (marked==cl) {
							redrawln(t,marked);
							marked=(-1);
						}
						else {
							redrawln(t,marked);
							markln(t,cl,12);
							marked=cl;
						}
					}
				}
			}
			mousetrap(G_snapto);
		}
		if (marked!=(-1)) {
			setcolor(12);
			mousecur(0);
			arrow(1,435,cl*11+110,415,cl*11+110);
			mousecur(1);
			while (mseb==0) {
				my=msey;
				i=(((my-110)-WINY)/11);
				if ((i<=t->nofld)&&(i>=0)&&(i!=cl)) {
					setcolor(1);
					mousecur(0);
					arrow(1,435,cl*11+110,415,cl*11+110);
					cl=i;
					setcolor(12);
					arrow(1,435,cl*11+110,415,cl*11+110);
					mousecur(1);
				}
				mousetrap(G_snapto);
			}
			setcolor(1);
			mousecur(0);
			arrow(1,435,cl*11+110,415,cl*11+110);
			mousecur(1);
		}
		if (mseb==2) {
			if (marked!=(-1)) {
				if (cl>marked) {
					tf=t->flds[marked];
					for (k=marked+1;k<cl;k++) {
						t->flds[k-1]=t->flds[k];
						swapflds(k-1,k);
						G_modid=1;
					}
					t->flds[cl-1]=tf;
					for(i=0;i<t->nokey;i++) {
						for (j=0;j<t->keys[i]->noparts;j++) {
							if (t->keys[i]->keypts[j]->fld==marked) {
								t->keys[i]->keypts[j]->fld=(-1);
							}
						}
					}
					for (k=marked+1;k<cl;k++) {
						for(i=0;i<t->nokey;i++) {
							for (j=0;j<t->keys[i]->noparts;j++) {
								if (t->keys[i]->keypts[j]->fld==k) {
									t->keys[i]->keypts[j]->fld=k-1;
								}
							}
						}
					}
					for(i=0;i<t->nokey;i++) {
						for (j=0;j<t->keys[i]->noparts;j++) {
							if (t->keys[i]->keypts[j]->fld==(-1)) {
								t->keys[i]->keypts[j]->fld=cl-1;
							}
						}
					}
				}
				else {
					if (marked>cl) {
						tf=t->flds[marked];
						for (k=marked-1;k>=cl;k--) {
							t->flds[k+1]=t->flds[k];
							swapflds(k+1,k);
							G_modid=1;
						}
						t->flds[cl]=tf;
						for(i=0;i<t->nokey;i++) {
							for (j=0;j<t->keys[i]->noparts;j++) {
								if (t->keys[i]->keypts[j]->fld==marked) {
									t->keys[i]->keypts[j]->fld=(-1);
								}
							}
						}
						for (k=marked-1;k>=cl;k--) {
							for(i=0;i<t->nokey;i++) {
								for (j=0;j<t->keys[i]->noparts;j++) {
									if (t->keys[i]->keypts[j]->fld==k) {
										t->keys[i]->keypts[j]->fld=k+1;
									}
								}
							}
						}
						for(i=0;i<t->nokey;i++) {
							for (j=0;j<t->keys[i]->noparts;j++) {
								if (t->keys[i]->keypts[j]->fld==(-1)) {
									t->keys[i]->keypts[j]->fld=cl;
								}
							}
						}
					}
				}
			}
			marked=(-1);
			mousecur(0);
			calcofs(t);
			for (i=0;i<t->nofld;i++) redrawln(t,i);
			mousecur(1);
		}
	}
}
void cngftype(file *t) {
	char tmp[99];
	settextstyle(2,0,5);
	tmp[0]=t->type;
	tmp[1]=0;
	intextxy(310,30,tmp,1,1,14);
	if ((tmp[0]=='c')||(tmp[0]=='C')||(tmp[0]=='s')||(tmp[0]=='S')) t->type=tmp[0];
	sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
	setfillstyle(1,1);
	setcolor(14);
	mousecur(0);
	bar(10,30,G_maxx-10,44);
	outtxtxy(G_maxx/2,30,tmp);
	mousecur(1);
	settextstyle(2,0,4);
}
void cngfname(file *t,int item) {
	char tmp[99];
	settextstyle(2,0,5);
	strcpy(tmp,t->name);
	intextxy(200,30,tmp,14,1,14);
	strcpy(t->name,tmp);
	lev[G_nowlev].G_elem[item].text=realloc(lev[G_nowlev].G_elem[item].text,strlen(tmp)+1);
	strcpy(lev[G_nowlev].G_elem[item].text,tmp);
	sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
	setfillstyle(1,1);
	setcolor(14);
	mousecur(0);
	bar(10,30,G_maxx-10,44);
	outtxtxy(G_maxx/2,30,tmp);
	mousecur(1);
	settextstyle(2,0,4);
}
void cngfdesc(file *t) {
	char tmp[99];
	settextstyle(2,0,5);
	strcpy(tmp,t->desc);
	intextxy(G_maxx/2,45,tmp,40,1,14);
	strcpy(t->desc,tmp);
	setfillstyle(1,1);
	setcolor(14);
	mousecur(0);
	bar(10,45,G_maxx-10,60);
	outtxtxy(G_maxx/2,45,tmp);
	mousecur(1);
	settextstyle(2,0,4);
}
void cngkey(file *t) {
	char tmp[99];
	int my,cl,i,j,k,mfldo,found,retv;
	my=msey;
	cl=(((my-110)-WINY)/11);
	mfldo=0;
	if (cl<t->nofld) {
		i=(msex-16)/16;
		if (i<t->nokey) {
			found=0;
			for (j=0;j<t->keys[i]->noparts;j++) {
				if (t->keys[i]->keypts[j]->fld==cl) {
					found=1;
					itoa(t->keys[i]->keypts[j]->fldordr,tmp,10);
					retv=intextxy((i*16)+24,110+(cl*11),tmp,2,0,14);
					t->keys[i]->keypts[j]->fldordr=atoi(tmp);
					if (t->keys[i]->keypts[j]->fldordr==0) {
						free(t->keys[i]->keypts[j]);
						for(k=j+1;k<t->keys[i]->noparts;k++) {
							t->keys[i]->keypts[k-1]=t->keys[i]->keypts[k];
						}
						t->keys[i]->noparts--;
						t->keys[i]->keypts=realloc(t->keys[i]->keypts,sizeof(struct keypt *)*(t->keys[i]->noparts));
					}
				}
				mfldo=max(mfldo,t->keys[i]->keypts[j]->fldordr);
			}
			if (!found) {
				if (mfldo<8) {
					t->keys[i]->noparts++;
					t->keys[i]->keypts=realloc(t->keys[i]->keypts,sizeof(struct keypt *)*(t->keys[i]->noparts));
					t->keys[i]->keypts[t->keys[i]->noparts-1]=malloc(sizeof(struct keypt));
					t->keys[i]->keypts[t->keys[i]->noparts-1]->fldordr=mfldo+1;
					t->keys[i]->keypts[t->keys[i]->noparts-1]->fld=cl;
					for (j=0;j<t->keys[i]->noparts;j++) {
						if (t->keys[i]->keypts[j]->fld==cl) {
							found=1;
							itoa(t->keys[i]->keypts[j]->fldordr,tmp,10);
							retv=intextxy((i*16)+24,110+(cl*11),tmp,2,0,14);
							t->keys[i]->keypts[j]->fldordr=atoi(tmp);
							if (t->keys[i]->keypts[j]->fldordr==0) {
								free(t->keys[i]->keypts[j]);
								for(k=j+1;k<t->keys[i]->noparts;k++) {
									t->keys[i]->keypts[k-1]=t->keys[i]->keypts[k];
								}
								t->keys[i]->noparts--;
								t->keys[i]->keypts=realloc(t->keys[i]->keypts,sizeof(struct keypt *)*(t->keys[i]->noparts));
							}
						}
					}
				}
			}
		}
		else {
			if (i==t->nokey) {
				t->nokey++;
				t->keys=realloc(t->keys,sizeof(struct key *)*(t->nokey));
				t->keys[i]=malloc(sizeof(struct key));
				t->keys[i]->noparts=1;
				t->keys[i]->keypts=malloc(sizeof(struct keypt *));
				t->keys[i]->keypts[0]=malloc(sizeof(struct keypt));
				t->keys[i]->keypts[0]->fldordr=mfldo+1;
				t->keys[i]->keypts[0]->fld=cl;
				for (j=0;j<t->keys[i]->noparts;j++) {
					if (t->keys[i]->keypts[j]->fld==cl) {
						found=1;
						itoa(t->keys[i]->keypts[j]->fldordr,tmp,10);
						retv=intextxy((i*16)+24,110+(cl*11),tmp,2,0,14);
						t->keys[i]->keypts[j]->fldordr=atoi(tmp);
						if (t->keys[i]->keypts[j]->fldordr==0) {
							free(t->keys[i]->keypts[j]);
							for(k=j+1;k<t->keys[i]->noparts;k++) {
								t->keys[i]->keypts[k-1]=t->keys[i]->keypts[k];
							}
							t->keys[i]->noparts--;
							t->keys[i]->keypts=realloc(t->keys[i]->keypts,sizeof(struct keypt *)*(t->keys[i]->noparts));
						}
					}
				}
			}
			else {
				sound(1000);
				for(j=0;j<4000;j++);
				nosound();
				retv=(-1);
			}
		}
	}
	else {
		sound(1000);
		for(j=0;j<4000;j++);
		nosound();
		retv=(-1);
	}
	if (retv==4) {
		markkey(t,i,11);
		k=getch();
		if ((k==0)&&(getch()=='S')) {
			for (j=0;j<t->keys[i]->noparts;j++)	free(t->keys[i]->keypts[j]);
			free(t->keys[i]->keypts);
			free(t->keys[i]);
			if (i!=(t->nokey-1)) for (j=i+1;j<t->nokey;j++) t->keys[j-1]=t->keys[j];
			t->nokey--;
			t->keys=realloc(t->keys,sizeof(struct key *)*(t->nokey));
			mousecur(0);
			setupscr(t);
			mousecur(1);
		}
		else {
			markkey(t,i,0);
		}
	}
}
void cngname(file *t) {
	char tmp[99];
	int my,cl,i,j,k,retv;
	my=msey;
	cl=(((my-110)-WINY)/11);
	if (cl<t->nofld) {
		strcpy(tmp,t->flds[cl]->name);
		retv=intextxy(194,cl*11+110,tmp,14,0,14);
		if (tmp[0]==0||tmp[0]==32||tmp[0]==13||tmp[0]==10) {
			sound(1000);
			for(j=0;j<4000;j++);
			nosound();
			return;
		}
		strcpy(t->flds[cl]->name,tmp);
		if (retv!=4) {
			if (getdict(t->flds[cl]->name)) {
				t->flds[cl]->type=G_dictent.type;
				t->flds[cl]->len=G_dictent.len;
				strcpy(t->flds[cl]->desc,G_dictent.desc);
				calcofs(t);
				for (i=0;i<t->nofld;i++) redrawln(t,i);
			}
			else {
				if (retv==2) {
					setmousexto(258);
					setmouseyto(my);
				}
				else {
					strcpy(G_dictent.name,t->flds[cl]->name);
					G_dictent.type=t->flds[cl]->type;
					G_dictent.len=t->flds[cl]->len;
					strcpy(G_dictent.desc,t->flds[cl]->desc);
					putdict();
					prdict(G_dictptr);
				}
			}
		}
		else {
			markln(t,cl,11);
			k=getch();
			if ((k==0)&&(getch()=='S')) {
				if (fldinuse(cl)) {
					sound(1000);
					for(j=0;j<4000;j++);
					nosound();
					redrawln(t,cl);
				}
				else {
					free(t->flds[cl]);
					if (cl!=(t->nofld-1)) {
						for (i=cl+1;i<t->nofld;i++) {
							t->flds[i-1]=t->flds[i];
							swapflds(i-1,i);
							G_modid=1;
						}
					}
					t->nofld--;
					t->flds=realloc(t->flds,sizeof(struct field *)*(t->nofld));
					for(i=0;i<t->nokey;i++) {
						for (j=0;j<t->keys[i]->noparts;j++) {
							if (t->keys[i]->keypts[j]->fld==cl) {
								free(t->keys[i]->keypts[j]);
								for (k=j+1;k<t->keys[i]->noparts;k++) t->keys[i]->keypts[k-1]=t->keys[i]->keypts[k];
								t->keys[i]->noparts--;
								t->keys[i]->keypts=realloc(t->keys[i]->keypts,sizeof(struct keypt *)*(t->keys[i]->noparts));
							}
						}
					}
					for (k=cl+1;k<=t->nofld;k++) {
						for(i=0;i<t->nokey;i++) {
							for (j=0;j<t->keys[i]->noparts;j++) {
								if (t->keys[i]->keypts[j]->fld==k) {
									t->keys[i]->keypts[j]->fld=k-1;
								}
							}
							reorderk(t,i);
						}
					}
					mousecur(0);
					calcofs(t);
					setupscr(t);
					mousecur(1);
				}
			}
			else {
				redrawln(t,cl);
			}
		}
	}
	else {
		if (cl==t->nofld) {
			t->nofld++;
			t->flds=realloc(t->flds,sizeof(struct field *)*(t->nofld));
			t->flds[cl]=malloc(sizeof(struct field));
			memset(t->flds[cl],0,sizeof(struct field));
			sprintf(t->flds[cl]->name,"Field_%02d",cl);
			t->flds[cl]->type='i';
			t->flds[cl]->len=2;
			strcpy(tmp,t->flds[cl]->name);
			retv=intextxy(194,cl*11+110,tmp,14,0,14);
			if (tmp[0]==0||tmp[0]==32||tmp[0]==13||tmp[0]==10) {
				sound(1000);
				for(j=0;j<4000;j++);
				nosound();
				return;
			}
			strcpy(t->flds[cl]->name,tmp);
			if (getdict(t->flds[cl]->name)) {
				t->flds[cl]->type=G_dictent.type;
				t->flds[cl]->len=G_dictent.len;
				strcpy(t->flds[cl]->desc,G_dictent.desc);
				calcofs(t);
				for (i=0;i<t->nofld;i++) redrawln(t,i);
			}
			else {
				if (retv==2) {
					setmousexto(258);
					setmouseyto(my);
				}
				else {
					strcpy(G_dictent.name,t->flds[cl]->name);
					G_dictent.type=t->flds[cl]->type;
					G_dictent.len=t->flds[cl]->len;
					strcpy(G_dictent.desc,t->flds[cl]->desc);
					putdict();
					prdict(G_dictptr);
				}
			}
		}
		else {
			sound(1000);
			for(j=0;j<4000;j++);
			nosound();
		}
	}
}
void cngtype(file *t) {
	char tmp[99];
	int my,cl,i,j,retv;
	my=msey;
	cl=(((my-110)-WINY)/11);
	if (cl<t->nofld) {
		tmp[0]=t->flds[cl]->type;
		tmp[1]=0;
		retv=intextxy(258,cl*11+110,tmp,1,0,14);
		switch (tmp[0]) {
			case 'C' :
			case 'c' : {
				t->flds[cl]->type='C';
				if (retv==2) {
					setmousexto(296);
					setmouseyto(my);
				}
				else {
					strcpy(G_dictent.name,t->flds[cl]->name);
					G_dictent.type=t->flds[cl]->type;
					G_dictent.len=t->flds[cl]->len;
					strcpy(G_dictent.desc,t->flds[cl]->desc);
					putdict();
					prdict(G_dictptr);
				}
			} break;
			case 'I' :
			case 'i' : {
				t->flds[cl]->type='i';
				t->flds[cl]->len=2;
				strcpy(G_dictent.name,t->flds[cl]->name);
				G_dictent.type=t->flds[cl]->type;
				G_dictent.len=t->flds[cl]->len;
				strcpy(G_dictent.desc,t->flds[cl]->desc);
				putdict();
				prdict(G_dictptr);
			} break;
			case 'F' :
			case 'f' : {
				t->flds[cl]->type='f';
				t->flds[cl]->len=6;
				strcpy(G_dictent.name,t->flds[cl]->name);
				G_dictent.type=t->flds[cl]->type;
				G_dictent.len=t->flds[cl]->len;
				strcpy(G_dictent.desc,t->flds[cl]->desc);
				putdict();
				prdict(G_dictptr);
			} break;
			case 'L' :
			case 'l' : {
				t->flds[cl]->type='l';
				t->flds[cl]->len=4;
				strcpy(G_dictent.name,t->flds[cl]->name);
				G_dictent.type=t->flds[cl]->type;
				G_dictent.len=t->flds[cl]->len;
				strcpy(G_dictent.desc,t->flds[cl]->desc);
				putdict();
				prdict(G_dictptr);
			} break;
			case 'D' :
			case 'd' : {
				t->flds[cl]->type='d';
				t->flds[cl]->len=6;
				strcpy(G_dictent.name,t->flds[cl]->name);
				G_dictent.type=t->flds[cl]->type;
				G_dictent.len=t->flds[cl]->len;
				strcpy(G_dictent.desc,t->flds[cl]->desc);
				putdict();
				prdict(G_dictptr);
			} break;
		}
		if (retv!=3) {
			calcofs(t);
			setfillstyle(1,1);
			bar(10,30,G_maxx-10,44);
			setcolor(14);
			settextstyle(2,0,5);
			sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
			outtxtxy(G_maxx/2,30,tmp);
			settextstyle(2,0,4);
			for (i=0;i<t->nofld;i++) redrawln(t,i);
		}
		else {
			redrawln(t,cl);
		}
	}
	else {
		sound(1000);
		for(j=0;j<4000;j++);
		nosound();
	}
}
void cnglen(file *t) {
	char tmp[99];
	int my,cl,i,j,retv;
	my=msey;
	cl=(((my-110)-WINY)/11);
	if (cl<t->nofld) {
		itoa(t->flds[cl]->len,tmp,10);
		retv=intextxy(296,cl*11+110,tmp,5,0,14);
		t->flds[cl]->len=atoi(tmp);
		strcpy(G_dictent.name,t->flds[cl]->name);
		G_dictent.type=t->flds[cl]->type;
		G_dictent.len=t->flds[cl]->len;
		strcpy(G_dictent.desc,t->flds[cl]->desc);
		putdict();
		prdict(G_dictptr);
		if (retv!=3) {
			calcofs(t);
			setfillstyle(1,1);
			bar(10,30,G_maxx-10,44);
			setcolor(14);
			settextstyle(2,0,5);
			sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
			outtxtxy(G_maxx/2,30,tmp);
			settextstyle(2,0,4);
			for (i=0;i<t->nofld;i++) redrawln(t,i);
		}
		else {
			redrawln(t,cl);
		}
	}
	else {
		sound(1000);
		for(j=0;j<4000;j++);
		nosound();
	}
}
void cngofs(file *t) {
	char tmp[99];
	int my,cl,j;
	my=msey;
	cl=(((my-110)-WINY)/11);
	if (cl<t->nofld) {
		itoa(t->flds[cl]->ofs,tmp,10);
		intextxy(342,cl*11+110,tmp,5,0,14);
		t->flds[cl]->ofs=atoi(tmp);
	}
	else {
		sound(1000);
		for(j=0;j<4000;j++);
		nosound();
	}
}
void cngdesc(file *t) {
	char tmp[99];
	int my,cl,j,retv;
	my=msey;
	cl=(((my-110)-WINY)/11);
	if (cl<t->nofld) {
		strcpy(tmp,t->flds[cl]->desc);
		setfillstyle(1,0);
		mousecur(0);
		bar(145,cl*11+111,413,cl*11+120);
		mousecur(1);
		retv=intextxy(280,cl*11+110,tmp,40,0,14);
		strcpy(t->flds[cl]->desc,tmp);
		mousecur(0);
		redrawln(t,cl);
		mousecur(1);
		if (retv!=3) {
			strcpy(G_dictent.name,t->flds[cl]->name);
			G_dictent.type=t->flds[cl]->type;
			G_dictent.len=t->flds[cl]->len;
			strcpy(G_dictent.desc,t->flds[cl]->desc);
			putdict();
			prdict(G_dictptr);
		}
	}
	else {
		sound(1000);
		for(j=0;j<4000;j++);
		nosound();
	}
}
int okbut(file *t) {
	int i,j;
	if ((t->nokey==0)||(t->nofld==0)) {
		sound(1000);
		for (i=0;i<1000;i++);
		nosound();
		return(0);
	}
	mousecur(0);
	button(250,G_maxy-WINY-20,"OK",1,1);
	mousecur(1);
	while (((mousetrap(G_snapto)>>5)&7));
	savefile(G_cellname,t);
	for (i=0;i<t->nofld;i++) {
		free(t->flds[i]);
	}
	free(t->flds);
	for (i=0;i<t->nokey;i++) {
		for(j=0;j<t->keys[i]->noparts;j++) {
			free(t->keys[i]->keypts[j]);
		}
		free(t->keys[i]);
	}
	free(t->keys);
	free(t);
	loadfiledat();
	return(1);
}
void canbut(file *t) {
	int i,j;
	mousecur(0);
	button(G_maxx-250,G_maxy-WINY-20,"CANCEL",1,1);
	mousecur(1);
	while (((mousetrap(G_snapto)>>5)&7));
	for (i=0;i<t->nofld;i++) {
		free(t->flds[i]);
	}
	free(t->flds);
	for (i=0;i<t->nokey;i++) {
		for(j=0;j<t->keys[i]->noparts;j++) {
			free(t->keys[i]->keypts[j]);
		}
		free(t->keys[i]->keypts);
		free(t->keys[i]);
	}
	free(t->keys);
	free(t);
}
void prdict(int pos) {
	int i,xp,yp,epos,spos,br;
	char tmp[16];
	xp=(G_maxx-32)-176;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*pos)/dictsize());
	epos=((br*(pos+27))/dictsize());
	setcolor(9);
	mousecur(0);
	setfillstyle(1,0);
	bar(xp+6,110,G_maxx-16,yp);
	rectangle(xp+16,90,G_maxx-16,yp);
	rectangle(xp+6,110,xp+16,yp);
	setfillstyle(11,9);
	bar(xp+7,121,xp+15,yp-11);
	setfillstyle(1,9);
	rectangle(xp+6,110,xp+16,120);
	rectangle(xp+6,yp-10,xp+16,yp);
	if (((epos+121)<(yp-11))||(spos!=0)) bar(xp+7,121+spos,xp+15,121+epos);
	for (i=110;i<yp;i+=11) line(xp+16,i,G_maxx-16,i);
	line(xp+144,90,xp+144,yp);
	line(xp+116,90,xp+116,yp);
	setcolor(14);
	settextstyle(2,0,4);
	outtxtxy(xp+66,95,"FIELD NAME");
	outtxtxy(xp+130,95,"TYPE");
	outtxtxy(xp+168,95,"LENGTH");
	retdict(pos);
	for (i=0;i<27;i++) {
		outtxtxy(xp+66,110+(i*11),G_dictent.name);
		tmp[1]=0;
		tmp[0]=G_dictent.type;
		outtxtxy(xp+130,110+(i*11),tmp);
		outtxtxy(xp+168,110+(i*11),itoa(G_dictent.len,tmp,10));
		if (!nextdict()) break;
	}
	mousecur(1);
}
void chkdict(file *t) {
	int i,xp,yp,epos,spos,br;
	xp=(G_maxx-32)-176;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*G_dictptr)/dictsize());
	epos=((br*(G_dictptr+27))/dictsize());
	if (((epos+121)<(yp-11))||(spos!=0)) {
		if (inbox(xp+6,WINY+110,xp+16,WINY+120)) {
			G_dictptr-=5;
			if (G_dictptr<0) G_dictptr=0;
			prdict(G_dictptr);
		}
		if (inbox(xp+6,WINY+(yp-10),xp+16,WINY+yp)) {
			G_dictptr+=5;
			if (G_dictptr>(dictsize()-27)) G_dictptr=dictsize()-27;
			prdict(G_dictptr);
		}
		if (inbox(xp+6,WINY+121,xp+16,WINY+(121+spos))) {
			G_dictptr-=26;
			if (G_dictptr<0) G_dictptr=0;
			prdict(G_dictptr);
		}
		if (inbox(xp+6,WINY+(121+epos),xp+16,WINY+(yp-11))) {
			G_dictptr+=26;
			if (G_dictptr>(dictsize()-27)) G_dictptr=dictsize()-27;
			prdict(G_dictptr);
		}
	}
	if (inbox(xp+17,WINY+110,G_maxx-17,WINY+yp)) {
		retdict(G_dictptr+(((msey-110)-WINY)/11));
		t->nofld++;
		t->flds=realloc(t->flds,sizeof(struct field *)*(t->nofld));
		t->flds[t->nofld-1]=malloc(sizeof(struct field));
		memset(t->flds[t->nofld-1],0,sizeof(struct field));
		strcpy(t->flds[t->nofld-1]->name,G_dictent.name);
		t->flds[t->nofld-1]->type=G_dictent.type;
		t->flds[t->nofld-1]->len=G_dictent.len;
		strcpy(t->flds[t->nofld-1]->desc,G_dictent.desc);
		calcofs(t);
		for (i=0;i<t->nofld;i++) redrawln(t,i);
		while (mseb) mousetrap(G_snapto);
	}
}
void prscr(void) {
	int i,j,fil;
	char tmp[200];
	FILE *prn;
	file *t;
	prn=fopen("opt.prn","w");
	for (fil=1;fil<=G_file.nofiles;fil++) {
		t=loadfile(G_cellname,fil);
		fprintf(prn,"SID\tTYPE\tNAME(10)\tRECLEN\tDESCRIPTION\n");
		fprintf(prn,"t%d\t%c\t\t%s\t\t%d\t\t%s\n",t->stid,t->type,t->name,t->len,t->desc);
		fprintf(prn,"FID\tSID\tOFS\tSIZE\tTYPE\tNAME\t\tDESCRIPTION\n");
		for (i=0;i<t->nofld;i++) {
			strcpy(tmp,t->flds[i]->name);
			for(j=0;j<strlen(tmp);j++) if (tmp[j]==' ') tmp[j]='_';
			fprintf(prn,"f%d\t%d\t%d\t%d\t\t%c\t\t%s\t%s\n",i,t->stid,t->flds[i]->ofs,t->flds[i]->len,t->flds[i]->type,tmp,t->flds[i]->desc);
		}
		fprintf(prn,"SID\tFID\tKID\tFIELDO\tNo.PARTS\n");
		for (i=0;i<t->nokey;i++) {
			for (j=0;j<t->keys[i]->noparts;j++) {
				fprintf(prn,"k%d\t%d\t%d\t%d\t\t%d\n",t->stid,t->keys[i]->keypts[j]->fld,i+1,t->keys[i]->keypts[j]->fldordr,t->keys[i]->noparts);
			}
		}
		fprintf(prn,"\n");
		for (i=0;i<t->nofld;i++) {
			free(t->flds[i]);
		}
		free(t->flds);
		for (i=0;i<t->nokey;i++) {
			for(j=0;j<t->keys[i]->noparts;j++) {
				free(t->keys[i]->keypts[j]);
			}
			free(t->keys[i]->keypts);
			free(t->keys[i]);
		}
		free(t->keys);
		free(t);
	}
	fprintf(prn,"PID DEVICE NAME (40 MAX)--------------- ESCAPE ------- Printer   (14)  TTY TYPE\n");
	for (fil=0;fil<G_noelem[0];fil++) {
		switch(lev[0].G_elem[fil].type) {
			case 1 :
			case 2 : {
				strcpy(tmp,lev[0].G_elem[fil].text);
				for(j=0;j<strlen(tmp);j++) {
					if (tmp[j]=='\n') tmp[j]='_';
					if (tmp[j]==' ') tmp[j]='_';
				}
				for (;j<36;j++) tmp[j]=' ';
				tmp[36]=0;
				fprintf(prn,"n%d\t%-36s C[][]\t\t\t/dev/tty1\t\tm303\n",lev[0].G_elem[fil].ident,tmp);
			} break;
		}
	}
	fprintf(prn,"\n");
	fclose(prn);
}
int prdiag(int mag,int dir) {
	int x=0,y=0,i,a=G_dpl/mag;
	FILE *p;
	shape *s;
	G_pwid=mag;
	G_ltype=dir;
	if ((p=fopen("PRN","w"))==NULL) return(0);
	for (i=0;i<G_noelem[G_nowlev];i++) {
		s=&lev[G_nowlev].G_elem[i];
		x=max(x,s->xpos+150);
		y=max(y,s->ypos+150);
	}
	G_szpbuf=3;
	for (i=0;i<G_szpbuf;i++) {
		if ((G_scr[i*3]=malloc(20000))==NULL) {
			if (i>0) {
				G_szpbuf=i+1;
				break;
			}
		}
		else {
			G_scr[i*3]=realloc(G_scr[i*3],G_dpl*3);
			G_scr[i*3+1]=G_scr[i*3]+G_dpl;
			G_scr[i*3+2]=G_scr[i*3]+G_dpl*2;
		}
	}
	if (G_szpbuf==0) {
		fprintf(p,"NOT ENOUGH MEMORY FOR PRINTOUT\n");
		fclose(p);
		return(0);
	}
	DOTSP(8);
	if (dir==1) {
		for (G_scx=0;G_scx<(((x/a)+1)*a);G_scx+=G_dpl/G_pwid) {
			for (G_scy=0;G_scy<y;G_scy+=(G_szpbuf*24)/G_pwid) {
				prlines(p);
				if (kbhit()) return(pnexit(p));
			}
			fprintf(p,"%c",12);
		}
	}
	else {
		for (G_scy=0;G_scy<(((y/a)+1)*a);G_scy+=G_dpl/G_pwid) {
			for (G_scx=0;G_scx<x;G_scx+=(G_szpbuf*24)/G_pwid) {
/*			for (G_scx=(((x/b)+1)*b);G_scx>0-(G_szpbuf*24)/G_pwid;G_scx-=(G_szpbuf*24)/G_pwid) {*/
				prlines(p);
				if (kbhit()) return(pnexit(p));
			}
			fprintf(p,"%c",12);
		}
	}
	DOTSP(10);
	fclose(p);
	G_ltype=0;
	for (i=0;i<G_szpbuf;i++) free(G_scr[i*3]);
	return(1);
}
