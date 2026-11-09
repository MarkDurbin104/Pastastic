#include <graphics.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include "tdef.h"

void	redrawln(file *t,int i);
void	dump(char *bcols);
void	calcofs(file *t);
void	markkey(file *t,int i,int col);
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

void dstoredef(int item) {
	int xit;
	file *t;
	mousecur(0);
	t=loadfile(G_cellname,lev[G_nowlev].G_elem[item].ident);
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
		while (!((mousetrap(1)>>5)&7));
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
			if (inbox(G_maxx-275,G_maxy-30,G_maxx-225,G_maxy-10)) {
				canbut(t);
				xit=1;
			}
			chkdict(t);
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
	outtextxy(G_maxx/2,2,tmp);
	sprintf(tmp,"STORE NAME %-9s TYPE %-c NUMBER %2d RECORD LENGTH %3d",t->name,t->type,t->stid,t->len);
	outtextxy(G_maxx/2,30,tmp);
	outtextxy(G_maxx/2,45,t->desc);
	xp=(G_maxx-32)-176;
	yp=((G_maxy-46-WINY)/11)*11;
	outtextxy((xp-32)/2,70,"DATA STORE");
	outtextxy(xp+16+(((G_maxx-16)-(xp+16))/2),70,"DICTIONARY");
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
	for (i=110;i<yp;i+=11) outtextxy(8,i,itoa((i-110)/11,tmp,10));
	outtextxy(80,90,"K E Y S");
	for (i=1;i<9;i++) outtextxy((i*16)+8,100,itoa(i,tmp,10));
	outtextxy(194,95,"FIELD NAME");
	outtextxy(258,95,"TYPE");
	outtextxy(296,95,"LENGTH");
	outtextxy(342,95,"OFFSET");
	outtextxy(389,95,"COMMENT");
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
		outtextxy(258,110+(i*11),tmp);
		outtextxy(194,110+(i*11),t->flds[i]->name);
		outtextxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
		strcpy(tmp,t->flds[i]->desc);
		tmp[7]=0;
		outtextxy(389,110+(i*11),tmp);
	}
	calcofs(t);
	for (i=0;i<t->nofld;i++) outtextxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	for (i=0;i<t->nokey;i++) {
		for (j=0;j<t->keys[i]->noparts;j++) {
			outtextxy((i*16)+24,110+(t->keys[i]->keypts[j]->fld*11),itoa(t->keys[i]->keypts[j]->fldordr,tmp,10));
		}
	}
	prdict(G_dictptr);
}
void button(int x,int y,char *name,int onoff,int high) {
	struct textsettingstype t;
	int c;

	c=getcolor();
	gettextsettings(&t);

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
	outtextxy(x,y,name);

	settextjustify(t.horiz,t.vert);
	settextstyle(t.font,t.direction,t.charsize);
	setcolor(c);
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
		outtextxy(x,y,tmp);
		mousecur(1);
		i=strlen(tmp);
	}
	do {
		mousecur(0);
		bar(x-(wid/2),y+2,x+(wid/2),y+hgt+2);
		outtextxy(x,y,tmp);
		mousecur(1);
		j=x+(textwidth(tmp)/2);
		setcolor(col-2);
		mousecur(0);
		line(j+1,y+1,j+1,y+hgt+1);
		mousecur(1);
		while ((!kbhit())&&(!xit)) {
			if (mousetrap(G_snapto)) {
				if (mseb) {
					if (!inbox(x-((wid/2)+1),WINY+y+2,x+((wid/2)+1),WINY+y+hgt+2))
						xit=1;
				}
			}
		}
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
	outtextxy(x,y,tmp);
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
	outtextxy(194,110+(i*11),t->flds[i]->name);
	tmp[0]=t->flds[i]->type;
	tmp[1]=0;
	outtextxy(258,110+(i*11),tmp);
	outtextxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
	outtextxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	strcpy(tmp,t->flds[i]->desc);
	tmp[7]=0;
	outtextxy(389,110+(i*11),tmp);
	for (k=0;k<t->nokey;k++) {
		for (j=0;j<t->keys[k]->noparts;j++) {
			if (t->keys[k]->keypts[j]->fld==i)
				outtextxy((k*16)+24,110+(i*11),itoa(t->keys[k]->keypts[j]->fldordr,tmp,10));
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
		outtextxy((i*16)+24 , 110+(t->keys[i]->keypts[j]->fld*11) ,
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
	outtextxy(194,110+(i*11),t->flds[i]->name);
	tmp[0]=t->flds[i]->type;
	tmp[1]=0;
	outtextxy(258,110+(i*11),tmp);
	outtextxy(296,110+(i*11),itoa(t->flds[i]->len,tmp,10));
	outtextxy(342,110+(i*11),itoa(t->flds[i]->ofs,tmp,10));
	strcpy(tmp,t->flds[i]->desc);
	tmp[7]=0;
	outtextxy(389,110+(i*11),tmp);
	for (k=0;k<t->nokey;k++) {
		for (j=0;j<t->keys[k]->noparts;j++) {
			if (t->keys[k]->keypts[j]->fld==i)
				outtextxy((k*16)+24,110+(i*11),itoa(t->keys[k]->keypts[j]->fldordr,tmp,10));
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
					for (k=marked+1;k<cl;k++) t->flds[k-1]=t->flds[k];
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
						for (k=marked-1;k>=cl;k--) t->flds[k+1]=t->flds[k];
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
	outtextxy(G_maxx/2,30,tmp);
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
	outtextxy(G_maxx/2,30,tmp);
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
	outtextxy(G_maxx/2,45,tmp);
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
				free(t->flds[cl]);
				if (cl!=(t->nofld-1)) for (i=cl+1;i<t->nofld;i++) t->flds[i-1]=t->flds[i];
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
			outtextxy(G_maxx/2,30,tmp);
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
			outtextxy(G_maxx/2,30,tmp);
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
	addfile(t);
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
	outtextxy(xp+66,95,"FIELD NAME");
	outtextxy(xp+130,95,"TYPE");
	outtextxy(xp+168,95,"LENGTH");
	retdict(pos);
	for (i=0;i<27;i++) {
		outtextxy(xp+66,110+(i*11),G_dictent.name);
		tmp[1]=0;
		tmp[0]=G_dictent.type;
		outtextxy(xp+130,110+(i*11),tmp);
		outtextxy(xp+168,110+(i*11),itoa(G_dictent.len,tmp,10));
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
void prdiag(void) {
	int i,j,l,m,n,o,p,prbyte;
	int x,y,mx=0,my=0;
	FILE *printer;
	char col,setit;
	setviewport(WINX,WINY,WINX+500,WINY+200,1);
	for (i=0;i<G_noelem[G_nowlev];i++) {
		mx=max(mx,lev[G_nowlev].G_elem[i].xpos);
		my=max(my,lev[G_nowlev].G_elem[i].ypos);
	}
	mx=((((mx+100)/720)+1)*720);
	my+=100;
	x=G_xpos;y=G_ypos;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (p=0;p<mx;p+=720) {
			for (i=0;i<my;i+=12) {
				fprintf(printer,"%c*%c%c%c",27,39,1440%256,1440/256);
				for (j=0;j<720;j+=360) {
					G_xpos=40-j-p;
					G_ypos=100-i;
					clearviewport();
					redraw(1);
					for (o=0;o<360;o++) {
						for (n=0;n<2;n++) {
							for (m=0;m<12;m+=4) {
								prbyte=0;
								for (l=0;l<4;l++) {
									col=getpixel(40+o,100+l+m)&0x0F;
									if (col==0) setit=0; else setit=3;
									prbyte|=(setit<<(6-(l*2)));
								}
								switch(prbyte) {
									case 26 : {
										fprintf(printer,"%c",22+n*2);
									} break;
									case 10 : {
										fprintf(printer,"%c",9+n*2);
									} break;
									default : {
										fprintf(printer,"%c",prbyte);
									}
								}
							}
						}
					}
				}
				fprintf(printer,"\n");
				if (kbhit()) break;
			}
		fprintf(printer,"%c",12);
		}
		if (kbhit()) getch();
		fclose(printer);
	}
	setviewport(WINX,WINY,G_maxx-WINX-11,G_maxy-WINY-11,1);
	G_xpos=x;
	G_ypos=y;
	cls();
	markpoints();
	redraw(1);
}
void prhdiag(void) {
	int i,j,l,m,o,p,prbyte;
	int x,y,mx=0,my=0;
	FILE *printer;
	char col,setit;
	setviewport(WINX,WINY,WINX+500,WINY+200,1);
	for (i=0;i<G_noelem[G_nowlev];i++) {
		mx=max(mx,lev[G_nowlev].G_elem[i].xpos);
		my=max(my,lev[G_nowlev].G_elem[i].ypos);
	}
	mx=((((mx+100)/1140)+1)*1140);
	my+=100;
	x=G_xpos;y=G_ypos;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (p=0;p<mx;p+=1440) {
			for (i=0;i<my;i+=24) {
				fprintf(printer,"%c*%c%c%c",27,39,1440%256,1440/256);
				for (j=0;j<1440;j+=360) {
					G_xpos=40-j-p;
					G_ypos=100-i;
					clearviewport();
					redraw(1);
					for (o=0;o<360;o++) {
						for (m=0;m<24;m+=8) {
							prbyte=0;
							for (l=0;l<8;l++) {
								col=getpixel(40+o,100+l+m)&0x0F;
								if (col==0) setit=0; else setit=1;
								prbyte|=(setit<<(7-l));
							}
							switch(prbyte) {
								case 26 : {
									fprintf(printer,"%c",22);
								} break;
								case 10 : {
									fprintf(printer,"%c",9);
								} break;
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
			fprintf(printer,"%c",12);
		}
		if (kbhit()) getch();
		fclose(printer);
	}
	setviewport(WINX,WINY,G_maxx-WINX-11,G_maxy-WINY-11,1);
	G_xpos=x;
	G_ypos=y;
	cls();
	markpoints();
	redraw(1);
}
void prfdiag(void) {
	int i,j,l,m,n,o,p,prbyte;
	int x,y,mx=0,my=0;
	FILE *printer;
	char col,setit;
	setviewport(WINX,WINY,WINX+500,WINY+200,1);
	for (i=0;i<G_noelem[G_nowlev];i++) {
		mx=max(mx,lev[G_nowlev].G_elem[i].xpos);
		my=max(my,lev[G_nowlev].G_elem[i].ypos);
	}
	mx=((((mx+100)/360)+1)*360);
	my+=100;
	x=G_xpos;y=G_ypos;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (p=0;p<mx;p+=360) {
			for (i=0;i<my;i+=6) {
				fprintf(printer,"%c*%c%c%c",27,39,1440%256,1440/256);
				for (j=0;j<360;j+=360) {
					G_xpos=40-j-p;
					G_ypos=100-i;
					clearviewport();
					redraw(1);
					for (o=0;o<360;o++) {
						for (n=0;n<4;n++) {
							for (m=0;m<6;m+=2) {
								prbyte=0;
								for (l=0;l<2;l++) {
									col=getpixel(40+o,100+l+m)&0x0F;
									if (col==0) setit=0; else setit=colmap[col][n];
									prbyte|=(setit<<(4-(l*4)));
								}
								switch(prbyte) {
									case 26 : {
										fprintf(printer,"%c",22+(n&1)*2);
									} break;
									case 10 : {
										fprintf(printer,"%c",9+(n&1)*2);
									} break;
									default : {
										fprintf(printer,"%c",prbyte);
									}
								}
							}
						}
					}
				}
				fprintf(printer,"\n");
				if (kbhit()) break;
			}
		fprintf(printer,"%c",12);
		}
		if (kbhit()) getch();
		fclose(printer);
	}
	setviewport(WINX,WINY,G_maxx-WINX-11,G_maxy-WINY-11,1);
	G_xpos=x;
	G_ypos=y;
	cls();
	markpoints();
	redraw(1);
}
