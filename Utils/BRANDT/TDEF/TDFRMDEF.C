#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <dos.h>
#include "tdef.h"
#include "tdfrm.h"

int  setupfrm(int item);
void drgrid(int onoff);
void drfld(int w,int j,int col,char xor);
void redrawscr(int w);
void vbox(int x,int y);
int  updfld(int fldno);
int  delfld(int fldno);
void allfld(int w);
void mvfld(int x,int y,int pos,int xp,int w);
int fld_found(char textmode,int xp,int pos,int w);
void not_fnd(char textmode,int xp,int pos,int w);
void edtxt(int x,int y,int xp,int pos,int curfld,int w);
void fld_off(void);
void fld_on(void);
int  diffscrn(int item,int w);
int  addscrn(void);
void freescrn(void);
int get_formid(void);

unsigned char G_clft,G_crgt,G_ctop,G_cbot,G_offset;
int  G_noflds,G_curfile,G_curfield,G_tblno;
char G_grid,G_nf,G_scrno,G_lnkno,G_tbltype[5][MAX_LINK];
/*static int  G_formid=0;*/ /* temporary until tracking of formids set up */
FILE *printer;

int frmdef(int item) {
	int xit=0,pos,i,w,xp;
	char textmode=0,tt;
	unsigned char *ks=MK_FP(0,0x417);

	printer = fopen("prn","a+");
	G_curfile = G_curfield = (-1);
	G_nf = G_grid = G_scrno = 0;
	settextstyle(2,0,4);
	w=textwidth("8");
	G_ident=lev[G_nowlev].G_elem[item].ident;
	if (lev[G_nowlev].G_elem[item].type==15) {
		return(mnudef(item));
	}
	else {
		if (!setupfrm(item)) {
			err_beep();
			freefrm(G_frm,1);
			return(0);
		}
	}
	while (!xit) {
		tt=textmode;
		if ((*ks)&3) textmode=1; else textmode=0;
		if (textmode!=tt) if (textmode) setmcurto(1); else setmcurto(0);
		if (kbhit()) {
			switch (getch()) {
				case 'a' : {  /* select all fields from current file */
					if (G_curfile!=(-1)) {
						allfld(w);
					}
				} break;
				case 8 : { /* backspace - delete field */
					df(w);
				} break;
                case 0 : {
					switch(getch()) {
						case 'C' : { /* use F9 to turn G_grid on/off */
							G_grid^=1;
							if (!G_grid) {
								mousecur(0);
								drgrid(G_grid);
								mousecur(1);
							}
							redrawscr(w);
						} break;
						case 'S' : { /* delete field */
							df(w);
						} break;
						case 'I' : { /* Page Up - previous screen */
							if (!G_scrno)
								err_beep();
							else {
								if (G_frm->scrn[G_scrno]->nofld<2) freescrn();
								G_scrno--;
								diffscrn(item,w);
							}
						} break;
						case 'Q' : { /* Page Down - next screen */
							if (G_frm->scrn[G_scrno]->nofld<2)
								err_beep();
							else {
								G_scrno++;
								if (!diffscrn(item,w)) G_scrno--;
							}
						} break;
					}
				}
			}
		}
		if (mousetrap(1)) {
			if (mseb==1) {
				pos=(((msey-WINY)-110)/11);
				if (inbox(520,120,620,407)) { /* file or field */
					if (G_curfile==(-1)) {
						if (pos<G_file.nofiles) { /* file list */
							G_curfile=pos;
							fld_off();
							mousecur(0);
							for (i=0;i<26;i++) {
								bar(521,i*11+111,619,i*11+120);
								if (i<G_file.cont[pos]->nofld) outtxtxy(570,i*11+110,G_file.cont[pos]->flds[i]->name);
							}
							mousecur(1);
						}
					}
					else {
						mousecur(0);
						if (pos<G_file.cont[G_curfile]->nofld) {   /* field list */
							fld_off();
							G_curfield=pos;
							fld_on();
						}
						mousecur(1);
					}
				}
				if (inbox(520,397+WINY,620,407+WINY)) {    /* new field */
					fld_off();
					G_nf=1;
					fld_on();
				}
				if (inbox(16,120,18+80*w,120+25*11)) { /* in form area */
					xp=(((msex-17)/w)*w)+17;
					if (!fld_found(textmode,xp,pos,w))
						not_fnd(textmode,xp,pos,w);  /* add new fld or mark area */
				}
				if (inbox(520,90,620,120)) {    /* reselect list of files */
					fld_off();
                	G_curfile=(-1);
					mousecur(0);
					for (i=0;i<26;i++) {
						bar(521,i*11+111,619,i*11+120);
						if (i<G_file.nofiles) outtxtxy(570,i*11+110,G_file.files[i]);
					}
					mousecur(1);
				}
				if (inbox(WINX,0,G_maxx,WINY)) {
					setviewport(WINX,WINY,G_maxx,G_maxy,1);
					fintitles(w);
					drawfrmbk(w);
				}
				if (inbox(75,G_maxy-30,125,G_maxy-10)) {
					okfbut();
					if (G_dongin) {
						if (!saveform(G_cellname,&G_dsp,0)) err_beep();
					}
					else err_beep();
					xit=1;
				}
				if (inbox(((18+80*w)-84)-25,G_maxy-30,((18+80*w)-84)+25,G_maxy-10)) {
					canfbut();
					xit=1;
				}
			}
			while (mseb) mousetrap(1);
		}
	}
	mousecur(0);
	setmcurto(0);
	freefrm(G_frm,1);
/*	if (!conv(G_cellname)) {
		err_beep();
		fprintf(printer,"convert - abnormal return\n");
	}*/
	fclose(printer);
	return(G_noflds);
}
int setupfrm(int item) {
	int i,yp,w;
	char tmp[100];

	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	headings(WINX,"File.Edit.Options.Dictionary.Report");
	setcolor(YELLOW);
	settextjustify(1,2);
	mousecur(0);
	rectangle(0,0,G_maxx,G_maxy);
	setviewport(0,WINY,G_maxx,G_maxy,1);
	setfillstyle(1,BLUE);
	bar(0,0,G_maxx,G_maxy-WINY);
	rectangle(0,0,G_maxx,G_maxy-WINY);
	line(0,24,G_maxx,24);
	settextstyle(2,0,5);
	sprintf(tmp,"PMA CDL    FORM DEFINITION     CELL %s.",G_cellname);
	outtextxy(G_maxx/2,2,tmp);
	sprintf(tmp,"DISPLAY NUMBER %d",G_ident);
	outtextxy(G_maxx/2-70,30,tmp);
	yp=((G_maxy-46-WINY)/11)*11;
	setcolor(LIGHTBLUE);
	setfillstyle(1,0);
	settextstyle(2,0,4);
	w=textwidth("8");
	bar(16,110,18+80*w,yp-33);
	rectangle(16,90,18+80*w,yp-33);
	bar(520,110,620,yp);
	rectangle(520,90,620,yp);
	for (i=121;i<yp;i+=11) line(520,i,620,i);
	setcolor(YELLOW);
	outtxtxy(570,95,"FILE");
	settextjustify(1,2);
	tmp[1]=0;
	for (i=0;i<80;i++) {
		tmp[0]=((i+1)%10)+'0';
		outcxy(17+w/2+i*w,95,tmp[0]);
	}
	for (i=0;i<24;i++) {
		tmp[0]=((i+1)%10)+'0';
		outcxy(8,110+i*11,tmp[0]);
	}
	for (i=0;i<min(25,G_file.nofiles);i++) outtxtxy(570,i*11+110,G_file.files[i]);
	outtxtxy(570,397,"New Field");
	button(100,G_maxy-WINY-20,"OK",0,0);
	button((18+80*w)-84,G_maxy-WINY-20,"CANCEL",0,0);
	G_frm=&G_dsp.ds.f;
	if ((loadform(G_cellname,G_ident))<0) return(0);
	sound(6); nosound(); /* doesnt always sound 1st time */
	setfillstyle(1,0);
	diffscrn(item,w);
	return(1);
}
void okfbut(void) {
	button(100,G_maxy-WINY-20,"OK",1,1);
	while (((mousetrap(G_snapto)>>5)&7));
}
void canfbut(void) {
	int w;
	settextstyle(2,0,4);
	w=textwidth("8");
	button((18+80*w)-84,G_maxy-WINY-20,"CANCEL",1,1);
	while (((mousetrap(G_snapto)>>5)&7));
}
void drgrid(int onoff) {
	int i,j,w;
	settextstyle(2,0,4);
	w=textwidth("8");
	for (i=1;i<80;i++) for (j=1;j<24;j++) putpixel(17+i*w,j*11+110,onoff*14);
}
void drfld(int w,int j,int col,char xor) {
	int i,clft,crgt,cbot,ctop,k;

	setcolor(col);
	setfillstyle(1,0);
	switch(G_fflds[j].type) {
		case 's': {
			for (i=0;i<strlen(&G_fflds[j].val[2]);i++) {
				if (xor) {
					xoutcxy(17+w/2+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+110,G_fflds[j].val[2+i]);
				}
				else {
					outcxy(17+w/2+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+110,G_fflds[j].val[2+i]);
				}
			}
			if (xor)
				xrectangle(w+17+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+111,w+17+((G_fflds[j].xpos+i+G_fflds[j].flen)*w),G_fflds[j].ypos*11+120);
			else
				rectangle(w+17+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+111,w+17+((G_fflds[j].xpos+i+G_fflds[j].flen)*w),G_fflds[j].ypos*11+120);
		} break;
		case 't': {
			for (i=0;i<strlen(G_fflds[j].val);i++) {
				if (xor) {
					xoutcxy(17+w/2+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+110,G_fflds[j].val[i]);
				}
				else {
					outcxy(17+w/2+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+110,G_fflds[j].val[i]);
				}
			}
		} break;
		case 'b': {
			clft=G_fflds[j].xpos;
			ctop=G_fflds[j].ypos;
			cbot=G_frm->scrn[G_scrno]->fld[j]->bottom;
			for (k=0;k<G_frm->scrn[G_scrno]->fld[j]->nocols;k++) { /* for each column */
				crgt=clft+strlen(&G_fflds[j].val[2]);
				if (!xor) {
					bar(clft*w+17,(ctop+11)*11,crgt*w+17,cbot*11+120);
					rectangle(clft*w+17,(ctop+11)*11,crgt*w+17,cbot*11+120);
				}
				else
					xrectangle(clft*w+17,(ctop+11)*11,crgt*w+17,cbot*11+120);
				for (i=2;i<=G_fflds[j].len;i++) {
					if (xor) {
						xoutcxy(17+w/2+(clft+i-2)*w,ctop*11+110,G_fflds[j].val[i]);
						if (G_fflds[j].val[i]=='\n') {
							movto(0,(clft+i-2)*w+17+w/2,(ctop+1)*11+110);
							linto(0,(clft+i-2)*w+17+w/2,cbot*11+120);
						}
					}
					else {
						outcxy(17+w/2+(clft+i-2)*w,ctop*11+110,G_fflds[j].val[i]);
						if (G_fflds[j].val[i]=='\n') {
							line((clft+i-2)*w+17+w/2,(ctop+1)*11+110,(clft+i-2)*w+17+w/2,cbot*11+120);
						}
					}
				}
				if ((G_lnkno!=(-1))&&(G_fflds[j].select)) {
					setfillstyle(INTERLEAVE_FILL,col);
					bar((clft+G_frm->scrn[G_scrno]->fld[j]->lnk[G_lnkno]->x_displace)*w+17,
						(ctop+11)*11+1,
						(clft+G_frm->scrn[G_scrno]->fld[j]->lnk[G_lnkno]->x_displace
							  +G_frm->scrn[G_scrno]->fld[j]->lnk[G_lnkno]->st_width)*w+17,
						cbot*11+119);
					setfillstyle(1,0);
				}
				clft=crgt+2;
			}
		}
	}
}

void redrawscr(int w) {
	int j;

	setfillstyle(1,0);
	mousecur(0);
	if (G_grid) drgrid(G_grid);
	G_clft=G_ctop=999;
	G_crgt=G_cbot=0;
	for (j=0;j<G_noflds;j++) {
		if (G_fflds[j].select==1) { /* find limits for selected flds */
			G_clft=min(G_clft,G_fflds[j].xpos);
			G_crgt=max(G_crgt,(G_fflds[j].xpos+G_fflds[j].len));
			G_ctop=min(G_ctop,G_fflds[j].ypos);
			G_cbot=max(G_cbot,G_fflds[j].ypos);
			drfld(w,j,LIGHTGREEN,0);
		}
		else
			drfld(w,j,YELLOW,0);
	}
	mousecur(1);
}

void drawfrmbk(int w) {
	int i,yp;
	char tmp[100];

	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	headings(WINX,"File.Edit.Options.Dictionary.Report");
	setcolor(YELLOW);
	settextjustify(1,2);
	mousecur(0);
	rectangle(0,0,G_maxx,G_maxy);
	setviewport(0,WINY,G_maxx,G_maxy,1);
	setfillstyle(1,BLUE);
	bar(0,0,G_maxx,G_maxy-WINY);
	rectangle(0,0,G_maxx,G_maxy-WINY);
	line(0,24,G_maxx,24);
	settextstyle(2,0,5);
	sprintf(tmp,"PMA CDL    FORM DEFINITION     CELL %s.",G_cellname);
	outtextxy(G_maxx/2,2,tmp);
	sprintf(tmp,"DISPLAY NUMBER %d",G_ident);
	outtextxy(G_maxx/2-70,30,tmp);
	yp=((G_maxy-46-WINY)/11)*11;
	setcolor(LIGHTBLUE);
	setfillstyle(1,0);
	settextstyle(2,0,4);
	w=textwidth("8");
	bar(16,110,18+80*w,yp-33);
	rectangle(16,90,18+80*w,yp-33);
	bar(520,110,620,yp);
	rectangle(520,90,620,yp);
	for (i=121;i<yp;i+=11) line(520,i,620,i);
	setcolor(YELLOW);
	outtxtxy(570,95,"FILE");
	settextjustify(1,2);
	tmp[1]=0;
	for (i=0;i<80;i++) {
		tmp[0]=((i+1)%10)+'0';
		outcxy(w/2+17+i*w,95,tmp[0]);
	}
	for (i=0;i<24;i++) {
		tmp[0]=((i+1)%10)+'0';
		outcxy(8,110+i*11,tmp[0]);
	}
	if (G_curfile==(-1))
		for (i=0;i<min(25,G_file.nofiles);i++) outtxtxy(570,i*11+110,G_file.files[i]);
	else {
		for (i=0;i<27;i++) {
			bar(521,i*11+111,619,i*11+120);
			if (i<G_file.cont[G_curfile]->nofld) outtxtxy(570,i*11+110,G_file.cont[G_curfile]->flds[i]->name);
		}
	}
	outtxtxy(570,397,"New Field");
	fld_on();
	button(100,G_maxy-WINY-20,"OK",0,0);
	button((18+80*w)-84,G_maxy-WINY-20,"CANCEL",0,0);
	redrawscr(w);
}

void vbox(int x,int y) {
	int x1,y2,y1;

	y1=y-WINY;
	x1=msex;
	y2=msey-WINY;
	movto(0,x,y1);
	linto(0,x1,y1);
	linto(0,x1,y2);
	linto(0,x,y2);
	linto(0,x,y1);
}

int  addfld(int fldno) {

	if (fldno>38) return(0);
	if ((G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*(fldno+1)))
			==(void *)NULL) return(0);
	if ((G_frm->scrn[G_scrno]->fld[fldno]=malloc(sizeof(field)))
			==(void *)NULL) {
		G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
		return(0);
	}
	memset(G_frm->scrn[G_scrno]->fld[fldno],'\0',sizeof(field));
	if ((G_frm->scrn[G_scrno]->fld[fldno]->lnk=malloc(1))
			==(void *)NULL) {
		free(G_frm->scrn[G_scrno]->fld[fldno]);
		G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
		return(0);
	}
	if ((G_frm->scrn[G_scrno]->fld[fldno]->eh=malloc(1))
			==(void *)NULL) {
		free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
		free(G_frm->scrn[G_scrno]->fld[fldno]);
		G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
		return(0);
	}
	G_frm->scrn[G_scrno]->nofld++;
	G_cursize+=sizeof(field);
	G_frm->scrn[G_scrno]->fld[fldno]->fldno=fldno+1;
	G_frm->scrn[G_scrno]->fld[fldno]->just='L';
	G_frm->scrn[G_scrno]->fld[fldno]->attr=0;
	switch(G_fflds[fldno].type) {
		case 't' : { /* text field */
			G_fflds[fldno].ftype=G_frm->scrn[G_scrno]->fld[fldno]->fldtype='T';
			G_frm->scrn[G_scrno]->fld[fldno]->top=G_frm->scrn[G_scrno]->fld[fldno]->bottom=G_fflds[fldno].ypos;
			G_frm->scrn[G_scrno]->fld[fldno]->width=G_fflds[fldno].len;
			if (G_fflds[fldno].len)
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=G_fflds[fldno].len+1;
			else
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=0;
			if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
				if ((G_frm->scrn[G_scrno]->fld[fldno]->text=malloc(G_frm->scrn[G_scrno]->fld[fldno]->textlen))
						==(void *)NULL)  {
					free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
					free(G_frm->scrn[G_scrno]->fld[fldno]);
					G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
					G_frm->scrn[G_scrno]->nofld--;
					G_cursize-=sizeof(field *)+sizeof(field);
					return(0);
				}
				G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,G_fflds[fldno].val);
			}
		} break;
		default : { /* other field */
			G_fflds[fldno].ftype=G_frm->scrn[G_scrno]->fld[fldno]->fldtype='O';
			G_frm->scrn[G_scrno]->fld[fldno]->top=G_frm->scrn[G_scrno]->fld[fldno]->bottom=G_fflds[fldno].ypos;
			G_frm->scrn[G_scrno]->fld[fldno]->width=G_fflds[fldno].flen;
			if (strlen(&G_fflds[fldno].val[2]))
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=strlen(&G_fflds[fldno].val[2])+1;
			else
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=0;
			if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
				if ((G_frm->scrn[G_scrno]->fld[fldno]->text=malloc(G_frm->scrn[G_scrno]->fld[fldno]->textlen))
						==(void *)NULL) {
					free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
					free(G_frm->scrn[G_scrno]->fld[fldno]);
					G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
					G_frm->scrn[G_scrno]->nofld--;
					G_cursize-=sizeof(field *)+sizeof(field);
					return(0);
				}
				G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,&G_fflds[fldno].val[2]);
			}
			if ((G_fflds[fldno].val[0])||(G_fflds[fldno].val[1]!=(-1))) { /* is this a linked field ? */
				if ( (G_frm->scrn[G_scrno]->fld[fldno]->lnk=realloc(G_frm->scrn[G_scrno]->fld[fldno]->lnk,1+sizeof(fldlink *)))
					==(void *)NULL ) {
					free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
					if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
						free(G_frm->scrn[G_scrno]->fld[fldno]->text);
						G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
					}
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
					free(G_frm->scrn[G_scrno]->fld[fldno]);
					G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
					G_frm->scrn[G_scrno]->nofld--;
					G_cursize-=sizeof(field *)+sizeof(field);
					return(0);
				}
				if ( (G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]=malloc(sizeof(fldlink)))
						==(void *)NULL ) {
					free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
					if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
						free(G_frm->scrn[G_scrno]->fld[fldno]->text);
						G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
					}
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
					free(G_frm->scrn[G_scrno]->fld[fldno]);
					G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
					G_frm->scrn[G_scrno]->nofld--;
					G_cursize-=sizeof(field *)+sizeof(field);
					return(0);
				}
				G_cursize+=sizeof(fldlink);
				memset(G_frm->scrn[G_scrno]->fld[fldno]->lnk[0],0,sizeof(fldlink));
				G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->storeid=G_fflds[fldno].val[0];
				G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->st_fldid=G_fflds[fldno].val[1];
				G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->st_key=1;
				G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->disp_type=G_frm->scrn[G_scrno]->fld[fldno]->fldtype;
				G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->st_width=G_fflds[fldno].flen;
				if ( (G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]->op=malloc(1))
						==(void *)NULL ) {
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[0]);
					G_cursize-=sizeof(fldlink);
					free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
					if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
						free(G_frm->scrn[G_scrno]->fld[fldno]->text);
						G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
					}
					free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
					free(G_frm->scrn[G_scrno]->fld[fldno]);
					G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*fldno);
					G_frm->scrn[G_scrno]->nofld--;
					G_cursize-=sizeof(field *)+sizeof(field);
					return(0);
				}
				G_frm->scrn[G_scrno]->fld[fldno]->nolnks=1;
				G_frm->scrn[G_scrno]->fld[fldno]->nocols=1;
			}
			G_frm->scrn[G_scrno]->fld[fldno]->offset=G_offset++;
		}
	}
	G_frm->scrn[G_scrno]->fld[fldno]->xpos=G_fflds[fldno].xpos;
	return(1);
}

int  updfld(int fldno) {

	if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
		free(G_frm->scrn[G_scrno]->fld[fldno]->text);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
	}
	switch(G_fflds[fldno].type) {
		case 't' : { /* text field */
			if (G_fflds[fldno].len)
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=G_fflds[fldno].len+1;
			else
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=0;
			if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
				if ((G_frm->scrn[G_scrno]->fld[fldno]->text=malloc(G_frm->scrn[G_scrno]->fld[fldno]->textlen))
						==(void *)NULL)  {
					return(0);
				}
				G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,G_fflds[fldno].val);
			}
			G_frm->scrn[G_scrno]->fld[fldno]->width=G_fflds[fldno].len;
			G_frm->scrn[G_scrno]->fld[fldno]->top=G_fflds[fldno].ypos;
		} break;
		case 'b' : { /* tablefield */
			if (strlen(&G_fflds[fldno].val[2]))
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=strlen(&G_fflds[fldno].val[2])+1;
			else
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=0;
			if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
				if ((G_frm->scrn[G_scrno]->fld[fldno]->text=malloc(G_frm->scrn[G_scrno]->fld[fldno]->textlen))
						==(void *)NULL) {
					return(0);
				}
				G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,&G_fflds[fldno].val[2]);
			}
			G_frm->scrn[G_scrno]->fld[fldno]->width=G_fflds[fldno].flen;
			G_frm->scrn[G_scrno]->fld[fldno]->top=G_fflds[fldno].ypos+2;
		} break;
		default : { /* other field */
			if (strlen(&G_fflds[fldno].val[2]))
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=strlen(&G_fflds[fldno].val[2])+1;
			else
				G_frm->scrn[G_scrno]->fld[fldno]->textlen=0;
			if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
				if ((G_frm->scrn[G_scrno]->fld[fldno]->text=malloc(G_frm->scrn[G_scrno]->fld[fldno]->textlen))
						==(void *)NULL) {
					return(0);
				}
				G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,&G_fflds[fldno].val[2]);
			}
			G_frm->scrn[G_scrno]->fld[fldno]->width=G_fflds[fldno].flen;
			G_frm->scrn[G_scrno]->fld[fldno]->top=G_fflds[fldno].ypos;
		}
	}
	G_frm->scrn[G_scrno]->fld[fldno]->xpos=G_fflds[fldno].xpos;
	return(1);
}

int  delfld(int fldno) {
	int fno,i,j;

	if (fldno>40) return(0);
	for (i=0;i<G_frm->scrn[G_scrno]->fld[fldno]->nolnks;i++) {
		if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val_ex) {
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->rflen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->rng_fmt);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->rflen;
			}
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->vflen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->vld_fmt);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->vflen;
			}
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->sflen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->scf_fmt);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->sflen;
			}
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->pflen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->prf_fmt);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->pflen;
			}
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->errlen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->errstr);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val->errlen;
			}
			free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->val);
			G_cursize-=sizeof(validation);
		}
		for(j=0;j<G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->numopt;j++) {
			if (G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->op[j]->textlen) {
				free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->op[j]->text);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->op[j]->textlen;
			}
			free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->op[j]);
			G_cursize-=sizeof(option);
		}
		free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->op);
		free(G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]);
		G_cursize-=sizeof(fldlink);
	}
	free(G_frm->scrn[G_scrno]->fld[fldno]->lnk);
	if (G_frm->scrn[G_scrno]->fld[fldno]->deflen) {
		free(G_frm->scrn[G_scrno]->fld[fldno]->deftext);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->deflen;
	}
	if (G_frm->scrn[G_scrno]->fld[fldno]->textlen) {
		free(G_frm->scrn[G_scrno]->fld[fldno]->text);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
	}
	for (i=0;i<G_frm->scrn[G_scrno]->fld[fldno]->nohelp;i++) {
		if (G_frm->scrn[G_scrno]->fld[fldno]->eh[i]->helplen) {
			free(G_frm->scrn[G_scrno]->fld[fldno]->eh[i]->help);
			G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->eh[i]->helplen;
		}
		free(G_frm->scrn[G_scrno]->fld[fldno]->eh[i]);
		G_cursize-=sizeof(entryhelp);
	}
	free(G_frm->scrn[G_scrno]->fld[fldno]->eh);
	free(G_frm->scrn[G_scrno]->fld[fldno]);
	G_cursize-=sizeof(field);
	for (fno=fldno;fno<(G_noflds-1);fno++) {
		G_frm->scrn[G_scrno]->fld[fno]=G_frm->scrn[G_scrno]->fld[fno+1];
		G_frm->scrn[G_scrno]->fld[fno]->fldno--;
	}
	G_frm->scrn[G_scrno]->fld=realloc(G_frm->scrn[G_scrno]->fld,1+sizeof(field *)*(G_noflds-1));
	G_frm->scrn[G_scrno]->nofld--;
	return(1);
}

void allfld(int w) {
	int i,rlim;

	mousecur(0);
	unselect_flds(w);
	rlim=80;
	for (i=0;(i<G_file.cont[G_curfile]->nofld) && (i<22);i++) {
		G_curfield=i;
		if ((strlen(G_file.cont[G_curfile]->flds[i]->name)+flfldlen()+1)<rlim) {
			G_fflds[G_noflds].xpos=1;
			G_fflds[G_noflds].ypos=i+3;
			G_fflds[G_noflds].type='s';
			G_fflds[G_noflds].flen=flfldlen();
			G_fflds[G_noflds].len=strlen(G_file.cont[G_curfile]->flds[i]->name)+G_fflds[G_noflds].flen+1;
			G_fflds[G_noflds].val[0]=G_curfile;
			G_fflds[G_noflds].val[1]=i;
			stcpy(&G_fflds[G_noflds].val[2],G_file.cont[G_fflds[G_noflds].val[0]]->flds[G_fflds[G_noflds].val[1]]->name);
			G_fflds[G_noflds].select=1;
			if (addfld(G_noflds))
				G_noflds++;
			else {
				memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
				err_beep();
				break;
			}
		}
		else err_beep();
	}
	redrawscr(w);
	G_curfield=(-1);
	mousecur(1);
}

void df(int w) {
int fno,i;

	for (fno=0;fno<G_noflds;fno++) {
		if (G_fflds[fno].select==1) {
			if (delfld(fno)) {
				mousecur(0);
				drfld(w,fno,0,0);
				mousecur(1);
				for (i=fno;i<(G_noflds-1);i++) {
					memcpy(&G_fflds[i],&G_fflds[i+1],sizeof(frmflds));
				}
				memset(&G_fflds[G_noflds--],'\0',sizeof(frmflds));
				fno--;
			}
			else {
				err_beep();
				break;
			}
		}
	}
	G_lnkno=(-1);
}

void mvfld(int x,int y,int pos,int xp,int w) {
	int orgx,orgy,newx,newy,fno,i,wid,mv,mh;

	mv=mh=0;
	if (mousestat(1)!=32) { /* move field */
		orgx=x*w+17+((((msex-17)/w)*w)+17)-xp;
		orgy=y+(((msey-WINY)-110)/11)-pos;
		G_clft=G_ctop=999;
		G_crgt=G_cbot=0;
		for (fno=0;fno<G_noflds;fno++) {
			if (G_fflds[fno].select==1) { /* find limits for selected flds */
				G_clft=min(G_clft,G_fflds[fno].xpos);
				if (!G_frm->scrn[G_scrno]->fld[fno]->nocols)
					wid=G_fflds[fno].xpos+G_fflds[fno].len;
				else {
					wid=G_fflds[fno].xpos;
					for (i=0;i<G_frm->scrn[G_scrno]->fld[fno]->nocols;i++)
						wid+=G_fflds[fno].len+1;
				}
				G_crgt=max(G_crgt,wid);
				G_ctop=min(G_ctop,G_fflds[fno].ypos);
				if (G_fflds[fno].type=='b')
					G_cbot=max(G_cbot,G_frm->scrn[G_scrno]->fld[fno]->bottom);
				else
					G_cbot=max(G_cbot,G_fflds[fno].ypos);
			}
		}
		mousetrap(1);
		newx=x*w+17+((((msex-17)/w)*w)+17)-xp;
		if (((newx-orgx)/w > ((-1)-G_clft))
		&&  ((newx-orgx)/w < (82-G_crgt))) {
			mh=1;
		}
		newy=y+(((msey-WINY)-110)/11)-pos;
		if  (((newy-orgy) > ((-1)-G_ctop))
		&&  ((newy-orgy) < (24-G_cbot))) {
			mv=1;
		}
		if (mv || mh) {
			for (fno=0;fno<G_noflds;fno++)
				if (G_fflds[fno].select==1) drfld(w,fno,0,0);
			for (fno=0;fno<G_noflds;fno++) {
				if (G_fflds[fno].select==1) {
					if (mh) {
						G_fflds[fno].xpos+=(newx-orgx)/w;
					}
					if (mv) {
						G_fflds[fno].ypos+=newy-orgy;
						G_frm->scrn[G_scrno]->fld[fno]->bottom+=newy-orgy;
					}
					drfld(w,fno,LIGHTGREEN,0);
					updfld(fno);
				}
			}
		}
	}
}

int fld_found(char textmode,int xp,int pos,int w) {
	char found=0,lfound=0;
	int i,j,x,y,count;

	for (j=0;j<G_noflds;j++) {
		if ((pos==G_fflds[j].ypos)
		&&	((xp-17)/w>=G_fflds[j].xpos)
		&&	 ((xp-17)/w<=G_fflds[j].len+G_fflds[j].xpos)
		&&  (G_fflds[j].type!='b')) {
			G_ctop=G_cbot=y=G_fflds[j].ypos;    /* field has been found on screen */
			G_clft=x=G_fflds[j].xpos;
			G_crgt=x+G_fflds[j].len;
			found=1;
			if (textmode) {
				edtxt(x,y,xp,pos,j,w); /* edit fld text */
				mousecur(0);
				if (G_fflds[j].select==1) drfld(w,j,LIGHTGREEN,0);
				else                      drfld(w,j,YELLOW,0);
				mousecur(1);
			}
			else {
				mousecur(0);
				if (G_fflds[j].select==0) {
					unselect_flds(w);
					G_fflds[j].select=1;
					drfld(w,j,LIGHTGREEN,0);
				}
				mousetrap(1);
				while (mseb==1)  mvfld(x,y,pos,xp,w); /* move fld */
				drfld(w,j,LIGHTGREEN,0);
				count=0;
				while ((((mousestat(1)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
				if (count!=CLICKRATE) {
					if (G_frm->scrn[G_scrno]->fld[j]->nolnks) G_lnkno=0;
					fld_attr();
					drawfrmbk(w);
					return(found);
				}
				mousecur(1);
			}
			if (G_frm->scrn[G_scrno]->fld[j]->nolnks) G_lnkno=0;
			redrawscr(w);
		}
		if ( (G_fflds[j].type=='b')
		&&  (pos>=G_fflds[j].ypos)
		&&  (pos<=G_frm->scrn[G_scrno]->fld[j]->bottom)
		&&	((xp-17)/w>=G_fflds[j].xpos)
		&&	 ((xp-17)/w<=G_fflds[j].len+G_fflds[j].xpos)) { /* tablefield field has been found */
			G_ctop=y=G_fflds[j].ypos;
			G_cbot=G_frm->scrn[G_scrno]->fld[j]->bottom;
			G_clft=x=G_fflds[j].xpos;
			G_crgt=x+G_fflds[j].len;
			found=1;
			if (textmode) {
				edtxt(x,y,xp,pos,j,w); /* edit fld text */
				G_lnkno=(-1);
			}
			else {
				if (G_fflds[j].select==0) {
					mousecur(0);
					unselect_flds(w);
					G_fflds[j].select=1;
					drfld(w,j,LIGHTGREEN,0);
					mousecur(1);
				}
				else {
					for (i=0;i<G_frm->scrn[G_scrno]->fld[j]->nolnks;i++) {
						if (((xp-17)/w>=G_fflds[j].xpos+G_frm->scrn[G_scrno]->fld[j]->lnk[i]->x_displace)
						&&  ((xp-17)/w<=G_fflds[j].xpos+G_frm->scrn[G_scrno]->fld[j]->lnk[i]->x_displace
										+G_frm->scrn[G_scrno]->fld[j]->lnk[i]->st_width)) {
							lfound=1;
							break;
						}
					}
				}
				mousetrap(1);
				mousecur(0);
				G_lnkno=(-1);
				while (mseb==1)  mvfld(x,y,pos,xp,w); /* move fld */
				if (!lfound) G_lnkno=(-1);
				else         G_lnkno=i;
				drfld(w,j,LIGHTGREEN,0);
				count=0;
				while ((((mousestat(1)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
				if (count!=CLICKRATE) {
					fld_attr();
					drawfrmbk(w);
					return(found);
				}
				mousecur(1);
			}
			redrawscr(w);
		}
	}
	return(found);
}

void not_fnd(char textmode,int xp,int pos,int w) {
	int  rlim,fno,x,y,newx,j,end,xit=0;
	char selected;
	frmflds newfld;

	G_clft=G_crgt=G_ctop=G_cbot=0;
	if (G_curfield==(-1)) {
		if (G_nf) {     /* set up and unselect new field */
			G_fflds[G_noflds].xpos=(xp-17)/w;
			G_fflds[G_noflds].ypos=pos;
			G_fflds[G_noflds].type='s';
			G_fflds[G_noflds].len=16;
			G_fflds[G_noflds].flen=6;
			G_fflds[G_noflds].val[0]=0;
			G_fflds[G_noflds].val[1]=-1;
			G_fflds[G_noflds].select=0;
			strcpy(&G_fflds[G_noflds].val[2],"new field");
				/* field too close to side or top */
			if ((G_fflds[G_noflds].xpos>(80-G_fflds[G_noflds].len))||(G_fflds[G_noflds].ypos<2)||(!addfld(G_noflds))) {
				memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
				err_beep();
			}
			else {
				mousecur(0);
				drfld(w,G_noflds++,YELLOW,0);
				mousecur(1);
				fld_off();
			}
		}
		else if (textmode) { /* add text field */
			selected=0;
			rlim=80;
			for (fno=0;fno<G_noflds;fno++) {
				if (G_fflds[fno].select==1) selected=1;
				else {
					if ((G_fflds[fno].ypos==pos)
						&&(G_fflds[fno].xpos>(xp-17)/w)) {
						rlim=min(rlim,G_fflds[fno].xpos-1);
					}
					if ( (G_fflds[fno].type=='b')
					&& (G_fflds[fno].ypos<=pos)
					&& (G_frm->scrn[G_scrno]->fld[fno]->bottom>=pos)
					&& (G_fflds[fno].xpos>(xp-17)/w) ) {
						rlim=min(rlim,G_fflds[fno].xpos-1);
					}
				}
			}
			if (!selected) {
				memset(&newfld,'\0',sizeof(frmflds));
				while ((!xit)
				&&(pos<23)) {
					if ((edtextxy(xp+w/2,pos*11+110,newfld.val,rlim-((xp-17)/w),0,LIGHTGREEN,w)<3)
					&& (newfld.val[0]!=0)) {
						newfld.ypos=pos;
						newfld.xpos=(xp-17)/w;
						newfld.type='t';
						newfld.len=strlen(newfld.val)+1;
						newfld.flen=0;
						memcpy(&G_fflds[G_noflds],&newfld,sizeof(frmflds));
						mousecur(0);
						if (addfld(G_noflds)) {
							drfld(w,G_noflds++,YELLOW,0);
						}
						else {
							drfld(w,G_noflds,0,0);
							memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
							err_beep();
						}
						mousecur(1);
						pos++;
						memset(&newfld,'\0',sizeof(frmflds));
						rlim=80;
						for (fno=0;fno<G_noflds;fno++) {
							end=G_fflds[fno].xpos+G_fflds[fno].len;
							if ((G_fflds[fno].ypos==pos)
								&&(G_fflds[fno].xpos<(xp-17)/w)
								&&(end>(xp-17)/w)) {
								xit=1;
								break;
							}
							if ((G_fflds[fno].ypos==pos)
								&&(G_fflds[fno].xpos>(xp-17)/w)) {
								rlim=min(rlim,G_fflds[fno].xpos-1);
							}
							if ( (G_fflds[fno].type=='b')
							&& (G_fflds[fno].ypos<=pos)
							&& (G_frm->scrn[G_scrno]->fld[fno]->bottom>=pos)
							&& (G_fflds[fno].xpos>(xp-17)/w) ) {
								rlim=min(rlim,G_fflds[fno].xpos-1);
							}
						}
					}
					else
						xit=1;
				}
				redrawscr(w);
			}
		}
		else { /* draw marker box */
			mousecur(0);
			unselect_flds(w);
			x=msex;
			y=msey;
			vbox(x,y);
			while (((mousestat(G_snapto)>>5)&&7)==1) {
				if (mousestat(G_snapto)&0x0F) { /* move marker box */
					vbox(x,y);
					mousetrap(G_snapto);
					vbox(x,y);
				}
			}
			vbox(x,y);
			G_clft=min((x-17)/w,(msex-17)/w);
			G_crgt=max((x-17)/w,(msex-17)/w);
			G_ctop=min((y-110-WINY)/11,(msey-110-WINY)/11);
			G_cbot=max((y-110-WINY)/11,(msey-110-WINY)/11);
			for (j=0;j<G_noflds;j++) { /* check for fields within box */
				if ((G_fflds[j].xpos>=G_clft)
				&& ((G_fflds[j].xpos+G_fflds[j].len)<=G_crgt)
				&& (G_fflds[j].ypos>G_ctop)
				&& (G_fflds[j].ypos<G_cbot) ) {
					G_fflds[j].select=1;
					drfld(w,j,LIGHTGREEN,0);
				}
			}
			mousecur(1);
/*			redrawscr(w);*/
		}
	}
	else { /* use current field */
		G_fflds[G_noflds].xpos=(xp-17)/w;
		G_fflds[G_noflds].ypos=pos;
		G_fflds[G_noflds].type='s';
		G_fflds[G_noflds].flen=flfldlen();
		G_fflds[G_noflds].len=strlen(G_file.cont[G_curfile]->flds[G_curfield]->name)+G_fflds[G_noflds].flen+1;
		G_fflds[G_noflds].val[0]=G_curfile;
		G_fflds[G_noflds].val[1]=G_curfield;
		stcpy(&G_fflds[G_noflds].val[2],G_file.cont[G_fflds[G_noflds].val[0]]->flds[G_fflds[G_noflds].val[1]]->name);
		newx=G_fflds[G_noflds].xpos*w+17+((((msex-17)/w)*w)+17)-xp;
		if ((newx>(18+(80-G_fflds[G_noflds].len)*w))||(pos<2)) { /* field too long */
			memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
			err_beep();
		}
		else {
			if (!addfld(G_noflds)) { /* check malloc worked for G_frm */
				memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
				err_beep();
			}
			else {
				mousecur(0);
				drfld(w,G_noflds++,YELLOW,0);
				mousecur(1);
				fld_off();
			}
		}
	}
}

void edtxt(int x,int y,int xp,int pos,int curfld,int w) {
	int rlim,fno,tlen;

	while (mseb==1) mousetrap(1);
	rlim=80;
	for (fno=0;fno<G_noflds;fno++) {
		if (G_fflds[fno].select==0) {
			if ((G_fflds[fno].ypos==pos)&&(G_fflds[fno].xpos>(xp-17)/w)) {
				rlim=min(rlim,G_fflds[fno].xpos-1);
			}
			if ( (G_fflds[fno].type=='b')
			&& (G_fflds[fno].ypos<=pos)
			&& (G_frm->scrn[G_scrno]->fld[fno]->bottom>=pos)
			&& (G_fflds[fno].xpos>(xp-17)/w) ) {
				rlim=min(rlim,G_fflds[fno].xpos-1);
			}
		}
	}
	mousecur(0);
	bar(x*w+17,(y*11)+109,17+((x+G_fflds[curfld].len-1)*w),(y*11)+120);
	switch(G_fflds[curfld].type) {
		case 's': {
			tlen=strlen(&G_fflds[curfld].val[2]);
			bar(17+(x+tlen)*w,y+11+110,17+(x+tlen+G_fflds[curfld].flen+1)*w,y*11+120);
			edtextxy(x*w+17+w/2,y*11+110,&G_fflds[curfld].val[2],rlim-x,0,LIGHTGREEN,w);
			mousecur(0);
			bar(17+x*w,y+11+110,17+(x+max(tlen,strlen(&G_fflds[curfld].val[2])))*w,y*11+120);
			G_fflds[curfld].len+=strlen(&G_fflds[curfld].val[2])-tlen;
			if (G_fflds[curfld].xpos+G_fflds[curfld].len>80)
				G_fflds[curfld].xpos=80-G_fflds[curfld].len;
		} break;
		case 'b': {
/*			tlen=strlen(&G_fflds[curfld].val[2]);
			edtextxy(x*w+17+w/2,y*11+110,&G_fflds[curfld].val[2],rlim-x,0,LIGHTGREEN,w);
			if (strlen(&G_fflds[curfld].val[2])>tlen)
				G_fflds[curfld].len+=strlen(&G_fflds[curfld].val[2])-tlen;
			if (G_fflds[curfld].xpos+G_fflds[curfld].len>80)
				G_fflds[curfld].xpos=80-G_fflds[curfld].len;*/
		} break;
		case 't': {
			printf("rlim - %d, x - %d\n",rlim,x);
			edtextxy(x*w+17+w/2,y*11+110,G_fflds[curfld].val,rlim-x,0,LIGHTGREEN,w);
			mousecur(0);
			bar(17+x*w,y+11+110,17+(x+strlen(G_fflds[curfld].val))*w,y*11+120);
			G_fflds[curfld].len=strlen(G_fflds[curfld].val)+1;
			if (G_fflds[curfld].xpos+G_fflds[curfld].len>80)
				G_fflds[curfld].xpos=80-G_fflds[curfld].len;
		} break;
	}
	updfld(curfld);
	mousecur(1);
}

void fld_off(void) {

	setfillstyle(1,0);
	setcolor(YELLOW);
	mousecur(0);
	if (G_curfield!=(-1)) {
		bar(521,G_curfield*11+111,619,G_curfield*11+120);
		outtxtxy(570,G_curfield*11+110,G_file.cont[G_curfile]->flds[G_curfield]->name);
		G_curfield=(-1);
	}
	if (G_nf) {     /* unselect new field */
		G_nf=0;
		bar(521,397,619,406);
		outtxtxy(570,397,"New Field");
	}
	mousecur(1);
}

void fld_on(void) {

	setfillstyle(1,GREEN);
	setcolor(YELLOW);
	mousecur(0);
	if (G_curfield!=(-1)) {
		bar(521,G_curfield*11+111,619,G_curfield*11+120);
		outtxtxy(570,G_curfield*11+110,G_file.cont[G_curfile]->flds[G_curfield]->name);
	}
	if (G_nf) {     /* select new field */
		bar(521,397,619,406);
		outtxtxy(570,397,"New Field");
	}
	mousecur(1);
}

int diffscrn(int item,int w) {
	int yp,i,fsave,fdiff,fno;
	char fldsize_chg;

	fsave=G_curfile;
	yp=((G_maxy-46-WINY)/11)*11;
	mousecur(0);
	bar(17,110,17+80*w,yp-34);
	memset(&G_fflds[0],0,sizeof(frmflds)*40);
	memset(&G_tbltype[0][0],0,(MAX_LINK+1)*5);
	G_tblno=0;
	fno=G_noflds=G_offset=0;
	G_lnkno=(-1);
	if (G_frm->noscrn > G_scrno) { /* screen exists */
		G_noflds=G_frm->scrn[G_scrno]->nofld;
		for (fno=0;fno<G_noflds;fno++) {
			G_fflds[fno].xpos=G_frm->scrn[G_scrno]->fld[fno]->xpos;
			G_fflds[fno].ftype=G_frm->scrn[G_scrno]->fld[fno]->fldtype;
			if (G_frm->scrn[G_scrno]->fld[fno]->fldtype=='T') {
				G_fflds[fno].type='t';
				strcpy(G_fflds[fno].val,G_frm->scrn[G_scrno]->fld[fno]->text);
				G_fflds[fno].flen=0;
				G_fflds[fno].ypos=G_frm->scrn[G_scrno]->fld[fno]->top;
				G_fflds[fno].len=G_frm->scrn[G_scrno]->fld[fno]->textlen;
			}
			else {
				G_fflds[fno].type='s';
				G_offset++;
				strcpy(&G_fflds[fno].val[2],G_frm->scrn[G_scrno]->fld[fno]->text);
				G_fflds[fno].flen=G_frm->scrn[G_scrno]->fld[fno]->width;
				fldsize_chg=0;
				if (G_frm->scrn[G_scrno]->fld[fno]->nolnks>0) {   /* linked field */
					for (i=0;i<G_frm->scrn[G_scrno]->fld[fno]->nolnks;i++) {
						G_curfile=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->storeid;
						G_curfield=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->st_fldid;
						fdiff=flfldlen()-G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->st_width;
						if (fdiff!=0) {
							fldsize_chg=1;
							G_fflds[fno].flen+=fdiff;
							G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->st_width+=fdiff;
						}
					}
					if (G_frm->scrn[G_scrno]->fld[fno]->nolnks>1) { /* table field */
						G_fflds[fno].type='b';
						if (fldsize_chg) {
							G_fflds[fno].select=1;
								if (!redrawtbl(fno)) {
									G_fflds[fno].ypos=G_frm->scrn[G_scrno]->fld[fno]->top-2;
									G_fflds[fno].xpos=0;
									delete_table(w);
									fno=0;
									err_beep();
									continue;
								}
							G_fflds[fno].xpos=G_frm->scrn[G_scrno]->fld[fno]->xpos=(80-G_fflds[fno].flen)/2;
							G_fflds[fno].select=0;
						}
						G_fflds[fno].len=G_fflds[fno].flen;
						G_fflds[fno].ypos=G_frm->scrn[G_scrno]->fld[fno]->top-2;
						if (G_tbltype[G_tblno][0]!=0) G_tblno++;
						G_fflds[fno].ftype=G_tblno;
						for (i=0;i<G_frm->scrn[G_scrno]->fld[fno]->nolnks;i++) {
							G_tbltype[G_tblno][i]=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->disp_type;
						}
					}
					else { /* single fld with link */
						G_frm->scrn[G_scrno]->fld[fno]->width=G_frm->scrn[G_scrno]->fld[fno]->lnk[0]->st_width;
						G_fflds[fno].len=G_frm->scrn[G_scrno]->fld[fno]->textlen+G_fflds[fno].flen;
						G_fflds[fno].ypos=G_frm->scrn[G_scrno]->fld[fno]->top;
					}
					G_fflds[fno].val[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[0]->storeid;
					G_fflds[fno].val[1]=G_frm->scrn[G_scrno]->fld[fno]->lnk[0]->st_fldid;
				}
				else { /* fld without link */
					G_fflds[fno].val[0]=0;
					G_fflds[fno].val[1]=(-1);
					G_fflds[fno].len=G_frm->scrn[G_scrno]->fld[fno]->textlen+G_fflds[fno].flen;
					G_fflds[fno].ypos=G_frm->scrn[G_scrno]->fld[fno]->top;
				}
			}
		}
/*		G_noflds=fno;*/
	}
	else { /* new screen */
		if (!addscrn()) return(0);
		strcpy(G_fflds[0].val,lev[G_nowlev].G_elem[item].text);
		G_fflds[0].xpos=40-(strlen(G_fflds[0].val)/2);
		G_fflds[0].ypos=1;
		G_fflds[0].type='t';
		G_fflds[0].len=strlen(G_fflds[0].val)+1;
		G_fflds[0].flen=0;
		if (addfld(0))
			G_noflds++;
		else {
			memset(&G_fflds[0],'\0',sizeof(frmflds));
			err_beep();
		}
	}
	for (fno=0;fno<G_noflds;fno++) { /* for debug */
		if ((G_fflds[fno].xpos>80) || (G_frm->scrn[G_scrno]->fld[fno]->xpos>80))
			G_fflds[fno].select=1;
	}
	df(8);
	G_grid=0;
	redrawscr(w);
	G_clft=G_crgt=G_ctop=G_cbot=0;
	G_curfield=(-1);
	G_curfile=fsave;
	return(1);
}

int addscrn(void) {

	if (G_frm->noscrn==0) { /* create screen */
		if ((G_frm->scrn=malloc(sizeof(screen *)))
				==(void *)NULL) return(0);
	}
	else {
		if ((G_frm->scrn=realloc(G_frm->scrn,sizeof(screen *)*(G_scrno+1)))
				==(void *)NULL) return(0);
	}
	G_frm->noscrn++;
	if ((G_frm->scrn[G_scrno]=malloc(sizeof(screen)))
			==(void *)NULL) {
		G_frm->scrn=realloc(G_frm->scrn,1+sizeof(screen *)*G_scrno);
		return(0);
	}
	memset(G_frm->scrn[G_scrno],0,sizeof(screen));
	G_cursize+=sizeof(screen);
	G_frm->scrn[G_scrno]->scrnseq=G_scrno;
	G_frm->scrn[G_scrno]->formid=get_formid();
	if ((G_frm->scrn[G_scrno]->fld=malloc(1))
			==(void *)NULL) {
		G_frm->noscrn=0;
		free(G_frm->scrn[G_scrno]);
		free(G_frm->scrn);
		return(0);
	}
	return(1);
}

void freescrn(void) {
	int i;

	for (i=0;i<G_frm->scrn[G_scrno]->nofld;i++) delfld(i);
	free(G_frm->scrn[G_scrno]->fld);
	free(G_frm->scrn[G_scrno]);
	G_cursize-=sizeof(screen);
	G_frm->scrn=realloc(G_frm->scrn,sizeof(screen *)*G_scrno);
	G_frm->noscrn--;
}

int get_formid(void) {
	return(G_dsp.dispno+(G_scrno*100));
}

void unselect_flds(int w) {
	int fno;

	for (fno=0;fno<G_noflds;fno++) {
		G_fflds[fno].select=0;
		drfld(w,fno,YELLOW,0);
	}
	G_lnkno=(-1);
}

