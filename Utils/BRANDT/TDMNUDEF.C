#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <dos.h>
#include "tdef.h"
#include "tdfrm.h"

void drml(int w,int j,int col);
void redrawmnu(int w,int scrnfld);
void drawmnubk(int ident,int w,int scrnfld);
int  setupmnu(int item);
int  addhdr(int hno);
int  updhdr(int hno);
int  delhdr(int hno,int w);
int  addln(void);
int  updln(int hno);
int  delln(int hno);
int dmf(int scrnfld,int w);
int swapml(int one,int two,int w,char flag);
int swapmh(int j,int w);

int G_nohdr;   /* no of menu header lines */
extern FILE *printer;

int mnudef(int item) {
	int xit=0,pos,j,k,w,textmode=0,xp,found,x,y,newx,newy,scrnfld=(-1),ident,count;
	char mne[2],tt;
	frmflds newline;
	unsigned char *ks=MK_FP(0,0x417);

	memset(mne,0,2);
	settextstyle(2,0,4);
	w=textwidth("8");
	if (!setupmnu(item)) {
		err_beep();
		freemnu(G_mnu,1);
		return(0);
	}
	ident=lev[G_nowlev].G_elem[item].ident;
	while (!xit) {
		tt=textmode;
		if ((*ks)&3) textmode=1; else textmode=0;
		if (textmode!=tt) if (textmode) setmcurto(1); else setmcurto(0);
		if (kbhit()) {
			switch (getch()) {
				case 0 : {
					switch(getch()) {
						case 'S' : { /* delete field */
							if (scrnfld!=(-1)) {
								if (!dmf(scrnfld,w)) err_beep();
								else scrnfld=(-1);
							}
						} break;
					}
				}
			}
		}
		if (mousetrap(1)) {
			if (mseb==1) {
				pos=(((msey-WINY)-110)/11);
				if (inbox(16,120,18+80*w,120+3*11)) {    /* in menu heading area */
					xp=(((msex-17)/w)*w)+17;
					found=0;
					if (scrnfld!=(-1)) {    /* unselect field */
						drml(w,scrnfld,YELLOW);
						scrnfld=(-1);
					}
					for (j=0;j<G_nohdr;j++) {
						if (pos==G_fflds[j].ypos) {
							y=G_fflds[j].ypos;        /* mhdr has been found on screen */
							x=G_fflds[j].xpos;
							scrnfld=j;
							found=1;
							drml(w,j,LIGHTGREEN);
							if (textmode) {
								while (mseb==1) mousetrap(1);
								mousecur(0);
								edtextxy(x*w+17,(y*11)+110,G_fflds[j].val,80-x,0,LIGHTGREEN,w);
								G_fflds[j].len=strlen(G_fflds[j].val);
								if (!updhdr(j)) err_beep();
								drml(w,j,YELLOW);
								mousecur(1);
							}
							else {
								while (mseb==1)  {
									if (mousestat(1)!=32) { /* move menuheader */
										drml(w,j,0);
										mousetrap(1);
										newy=y+(((msey-WINY)-110)/11)-pos;
										if ((G_nohdr==2)&&(pos==scrnfld)){
											if (((newy>0)&&(pos==0))
											||  ((newy<1)&&(pos==1))) {
												swapmh(j,w);
												j^=1;
											}
										}
										newx=x*w+17+((((msex-17)/w)*w)+17)-xp;
										if ((newx>17)&&(newx<(17+(80-G_fflds[j].len)*w)))
											G_fflds[j].xpos=(newx-17)/w;
										scrnfld=j;
										drml(w,j,LIGHTGREEN);
										if (!updhdr(j)) err_beep();
									}
								}
							}
							redrawmnu(w,scrnfld);
							break;
						}
					}
					if (!found) {       /* no field selected - add new header */
						for (j=0;j<2;j++) {
							if (pos==G_fflds[j].ypos)
								found=1;
						}
						if ((textmode)&&(scrnfld==(-1))&&(!found)) {
							memset(&newline,'\0',sizeof(frmflds));
							edtextxy(xp,pos*11+110,newline.val,80-((xp-17)/w),0,LIGHTGREEN,w);
							if (newline.val[0]!=0) {
								newline.ypos=pos;
								newline.xpos=(xp-17)/w;
								newline.type='h';
								newline.len=strlen(newline.val);
								for (j=0;j<G_noflds;j++) {
									if ( newline.ypos<G_fflds[j].ypos)
										break;
								}
								if (addhdr(G_nohdr)) {
									if (j<G_noflds) {
										for (k=G_noflds;k>j;k--) {
											memcpy(&G_fflds[k],&G_fflds[k-1],sizeof(frmflds));
											if (G_fflds[k-1].type=='h') {
												G_mnu->mh[k]=G_mnu->mh[k-1];
												G_mnu->mh[k]->mh_line++;
											}
										}
									}
									memcpy(&G_fflds[j],&newline,sizeof(frmflds));
									if (!updhdr(j)) err_beep();
									scrnfld=j;
									G_noflds++;
								}
								else err_beep();
							}
						}
					}
				}
				else if (inbox(16,120+4*11,18+80*w,120+25*11)) { /* in menu line area */
					xp=(((msex-17)/w)*w)+17;
					found=0;
					if (scrnfld!=(-1)) {
						drml(w,scrnfld,YELLOW);
						scrnfld=(-1);
					}
					for (j=0;j<G_noflds;j++) {
						if ((pos==G_fflds[j].ypos)
						&&	((xp-17)/w>=G_fflds[j].xpos-6)
						&&	 ((xp-17)/w<=G_fflds[j].len+G_fflds[j].xpos)) {
							y=G_fflds[j].ypos;    /* mline has been found on screen */
							x=G_fflds[j].xpos;
							scrnfld=j;
							found=1;
							drml(w,j,LIGHTGREEN);
							if (textmode) {
								while (mseb==1) mousetrap(1);
								mousecur(0);
								if ((xp-17)/w<G_fflds[j].xpos-2) { /* mnemonic */
									mne[0]=G_fflds[j].val[0];
									edtextxy((x-5)*w+17,(y*11)+110,mne,1,0,LIGHTGREEN,w);
									G_fflds[j].val[0]=mne[0];
								}
								else { /* text */
									edtextxy(x*w+17,(y*11)+110,&G_fflds[j].val[1],40,0,LIGHTGREEN,w);
									G_fflds[j].len=strlen(&G_fflds[j].val[1]);
								}
								drml(w,j,YELLOW);
								if (!updln(j-G_nohdr)) err_beep();
								mousecur(1);
							}
							else {
								while (mseb==1)  {
									if (mousestat(1)!=32) { /* move menuline */
										mousetrap(1);
										newy=y+(((msey-WINY)-110)/11)-pos;
										if (G_fflds[j].type=='l') {
											if ((newy>2)&&(newy<24)) {
												if (newy>G_fflds[j].ypos) { /* move down */
													drml(w,j,0);
													if (j==(G_noflds-1)) { /* bottom menu line */
														G_fflds[j].ypos=newy;
													}
													else {
														if (newy>=G_fflds[j+1].ypos) {
															swapml(j+1,j,w,1);
															scrnfld=++j;
															drml(w,j-1,YELLOW);
															if (!updln(j-1-G_nohdr)) err_beep();
														}
														else {
															G_fflds[j].ypos=newy;
														}
													}
													drml(w,j,LIGHTGREEN);
													if (!updln(j-G_nohdr)) err_beep();
												}
												else if (newy<G_fflds[j].ypos) { /* move up */
													drml(w,j,0);
													if (G_fflds[j-1].type=='h') { /* top menuline */
														G_fflds[j].ypos=newy;
													}
													else {
														if (newy<=G_fflds[j-1].ypos) {
															swapml(j-1,j,w,1);
															scrnfld=--j;
															drml(w,j+1,YELLOW);
															if (!updln(j+1-G_nohdr)) err_beep();
														}
														else {
															G_fflds[j].ypos=newy;
														}
													}
													drml(w,j,LIGHTGREEN);
													if (!updln(j-G_nohdr)) err_beep();
												}
												memset(&G_fflds[G_noflds+1],'\0',sizeof(frmflds));
											}
										}
									}
								}
								count=0;
								while ((((mousestat(1)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
								if (count!=CLICKRATE) {
									ml_opt(scrnfld);
									drawmnubk(ident,w,scrnfld);
								}
							}
							redrawmnu(w,scrnfld);
							break;
						}
					}
				}
				if (inbox(WINX,0,G_maxx,WINY)) {
					setviewport(WINX,WINY,G_maxx,G_maxy,1);
					mintitles(scrnfld);
					drawmnubk(ident,w,scrnfld);
				}
				if (inbox(75,G_maxy-30,125,G_maxy-10)) {
					okfbut();
					if (G_dongin) {
						if (!savemenu(G_cellname,&G_dsp,0)) err_beep();
					}
					else
						err_beep();
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
	freemnu(G_mnu,1);
	fclose(printer);
	return(G_noflds);
}

int setupmnu(int item) {
	int i,yp,w,fno,ident;
	char tmp[100];

	ident=lev[G_nowlev].G_elem[item].ident;
	memset(&G_fflds[0],0,sizeof(frmflds)*40);
	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	headings(WINX,"File.Edit.Options");
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
	sprintf(tmp,"PMA CDL    MENU DEFINITION     CELL %s.",G_cellname);
	outtextxy(G_maxx/2,2,tmp);
	sprintf(tmp,"DISPLAY NUMBER %d",ident);
	outtextxy(G_maxx/2,30,tmp);
	yp=((G_maxy-46-WINY)/11)*11;
	setcolor(LIGHTBLUE);
	setfillstyle(1,0);
	settextstyle(2,0,4);
	w=textwidth("8");
	bar(16,110,18+80*w,yp-33);
	rectangle(16,90,18+80*w,yp-33);
	setcolor(YELLOW);
	settextjustify(1,2);
	tmp[1]=0;
	for (i=0;i<80;i++) {
		tmp[0]=((i+1)%10)+'0';
		outtxtxy((w/2)+17+i*w,95,tmp);
	}
	for (i=0;i<24;i++) {
		tmp[0]=((i+1)%10)+'0';
		outtxtxy(8,110+i*11,tmp);
	}
	sound(6); nosound();
	settextjustify(1,2);
	G_mnu=&G_dsp.ds.m;
	if ((loadmenu(G_cellname,ident))<0) return(0);
	G_noflds=G_nohdr=0;
	if ((G_mnu->nummh==0)&&(G_mnu->numml==0)) { /* menu not found */
		if ((G_mnu->mh=malloc(1))==(void *)NULL) return(0);
		strcpy(G_fflds[0].val,lev[G_nowlev].G_elem[item].text);  /* menu header */
		G_fflds[0].xpos=40-(strlen(G_fflds[0].val)/2);
		G_fflds[0].ypos=0;
		G_fflds[0].type='h';
		G_fflds[0].len=strlen(G_fflds[0].val);
		if (!addhdr(0)) return(0);
		drml(w,0,YELLOW);
		G_noflds=1;   /* now do menu lines */
		if ((G_mnu->ml=malloc(1))==(void *)NULL) return(0);
		for (i=0;i<G_nocont[G_nowlev];i++) {
			if ((lev[G_nowlev].G_cont[i].from==item)&&(!(lev[G_nowlev].G_cont[i].deled))) {
				G_fflds[G_noflds].xpos=20;
				G_fflds[G_noflds].ypos=G_noflds+3;
				G_fflds[G_noflds].type='l';
				G_fflds[G_noflds].val[0]=tmp[0]=lev[G_nowlev].G_cont[i].text[0];
				strcpy(&G_fflds[G_noflds].val[1],lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].text);
				G_fflds[G_noflds].len=strlen(&G_fflds[G_noflds].val[1]);
				if (addln()) {
					G_mnu->ml[G_noflds-G_nohdr]->chain_to=lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].ident;
				}
				else return(0);
				drml(w,G_noflds++,YELLOW);
			}
		}
	}
	else { /* set up screen - menu data */
		for (fno=0;fno<G_mnu->nummh;fno++) {
			G_fflds[G_noflds].type='h';
			G_fflds[G_noflds].xpos=G_mnu->mh[fno]->xpos;
			G_fflds[G_noflds].ypos=G_mnu->mh[fno]->mh_line-1;
			G_fflds[G_noflds].len=G_mnu->mh[fno]->textlen;
			strcpy(G_fflds[G_noflds].val,G_mnu->mh[fno]->text);
			G_noflds++;
			G_nohdr++;
		}
		for (fno=0;fno<G_mnu->numml;fno++) {
			G_fflds[G_noflds].type='l';
			G_fflds[G_noflds].xpos=20;
			G_fflds[G_noflds].ypos=G_mnu->ml[fno]->ypos;
			G_fflds[G_noflds].len=G_mnu->ml[fno]->textlen;
			G_fflds[G_noflds].val[0]=G_mnu->ml[fno]->mne;
			strcpy(&G_fflds[G_noflds].val[1],G_mnu->ml[fno]->text);
			G_noflds++;
		}
	}
	redrawmnu(w,(-1));
	button(100,G_maxy-WINY-20,"OK",0,0);
	button((18+80*w)-84,G_maxy-WINY-20,"CANCEL",0,0);
	mousecur(1);
	return(1);
}

void drml(int w,int j,int col) {
	int i;

	mousecur(0);
	setcolor(col);
	setfillstyle(1,0);
	switch(G_fflds[j].type) {
		case 'l': {
			bar(17+15*w,G_fflds[j].ypos*11+111,17+70*w,G_fflds[j].ypos*11+120);
			outcxy(17+15*w,G_fflds[j].ypos*11+110,G_fflds[j].val[0]);
			for (i=0;i<strlen(&G_fflds[j].val[1]);i++) {
				outcxy(17+((20+i)*w),G_fflds[j].ypos*11+110,G_fflds[j].val[i+1]);
			}
		} break;
		case 'h': {
			for (i=0;i<strlen(G_fflds[j].val);i++) {
				bar(17+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+111,17+(G_fflds[j].xpos+i+1)*w,G_fflds[j].ypos*11+120);
				outcxy(17+(G_fflds[j].xpos+i)*w,G_fflds[j].ypos*11+110,G_fflds[j].val[i]);
			}
		} break;
	}
	mousecur(1);
}

int swapmh(int j,int w) {
	menuhdr *tempmh;
	frmflds newline;

	tempmh=G_mnu->mh[1];
	memcpy(&newline,&G_fflds[1],sizeof(frmflds));
	G_mnu->mh[1]=G_mnu->mh[0];
	memcpy(&G_fflds[1],&G_fflds[0],sizeof(frmflds));
	G_mnu->mh[0]=tempmh;
	memcpy(&G_fflds[0],&newline,sizeof(frmflds));
	drml(w,j,0);
	G_fflds[0].ypos=0;
	G_fflds[1].ypos=1;
	if (!updhdr(j)) err_beep();
	drml(w,j,YELLOW);
	return(1);
}

int swapml(int one,int two,int w,char flag) {
	int ty;
	menuln *tempml;

	if (flag) drml(w,one,0);
	ty=G_fflds[one].ypos;
	G_fflds[one].ypos=G_fflds[two].ypos;
	G_fflds[two].ypos=ty;
	memcpy(&G_fflds[G_noflds+1],&G_fflds[two],sizeof(frmflds));
	tempml=G_mnu->ml[two-G_nohdr];
	memcpy(&G_fflds[two],&G_fflds[one],sizeof(frmflds));
	G_mnu->ml[two-G_nohdr]=G_mnu->ml[one-G_nohdr];
	memcpy(&G_fflds[one],&G_fflds[G_noflds+1],sizeof(frmflds));
	G_mnu->ml[one-G_nohdr]=tempml;
/*	if (flag) swap2men(one,two);   to swap boxes about at tds level */
	return(1);
}

void redrawmnu(int w,int scrnfld) {
	int j;

	setfillstyle(1,0);
	mousecur(0);
	bar(17,111,17+80*w,407-34);
	for (j=0;j<G_noflds;j++) {
		if (scrnfld==j) drml(w,j,LIGHTGREEN);
		else            drml(w,j,YELLOW);
	}
	mousecur(1);
}

void drawmnubk(int ident,int w,int scrnfld) {
	int i,yp;
	char tmp[100];

	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	headings(WINX,"File.Edit.Options");
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
	sprintf(tmp,"PMA CDL    MENU DEFINITION     CELL %s.",G_cellname);
	outtextxy(G_maxx/2,2,tmp);
	sprintf(tmp,"DISPLAY NUMBER %d",ident);
	outtextxy(G_maxx/2,30,tmp);
	yp=((G_maxy-46-WINY)/11)*11;
	setcolor(LIGHTBLUE);
	setfillstyle(1,0);
	settextstyle(2,0,4);
	w=textwidth("8");
	bar(16,110,18+80*w,yp-33);
	rectangle(16,90,18+80*w,yp-33);
	setcolor(YELLOW);
	settextjustify(1,2);
	tmp[1]=0;
	for (i=0;i<80;i++) {
		tmp[0]=((i+1)%10)+'0';
		outtxtxy((w/2)+17+i*w,95,tmp);
	}
	for (i=0;i<24;i++) {
		tmp[0]=((i+1)%10)+'0';
		outtxtxy(8,110+i*11,tmp);
	}
	button(100,G_maxy-WINY-20,"OK",0,0);
	button((18+80*w)-84,G_maxy-WINY-20,"CANCEL",0,0);
	redrawmnu(w,scrnfld);
	mousecur(1);
}

int  addhdr(int hno) {

	if (hno>1) return(0);
	if ((G_mnu->mh=realloc(G_mnu->mh,1+sizeof(menuhdr *)*(G_nohdr+1)))
			==(void *)NULL) return(0);
	if ((G_mnu->mh[hno]=malloc(sizeof(menuhdr)))
			==(void *)NULL) return(0);
	memset(G_mnu->mh[hno],0,sizeof(menuhdr));
	G_cursize+=sizeof(menuhdr);
	G_mnu->nummh++;
	G_mnu->mh[hno]->mh_line=G_fflds[hno].ypos+1;
	G_mnu->mh[hno]->xpos=G_fflds[hno].xpos;
	G_mnu->mh[hno]->textlen=G_fflds[hno].len+1;
	if ((G_mnu->mh[hno]->text=malloc(G_mnu->mh[hno]->textlen))
			==(void *)NULL) {
		free(G_mnu->mh[hno]);
		G_mnu->mh=realloc(G_mnu->mh,1+sizeof(menuhdr *)*hno);
		G_cursize-=sizeof(menuhdr);
		G_mnu->nummh--;
		return(0);
	}
	G_cursize+=G_mnu->mh[hno]->textlen;
	strcpy(G_mnu->mh[hno]->text,G_fflds[hno].val);
	G_nohdr++;
	return(1);
}

int  updhdr(int hno) {

	if (G_mnu->mh[hno]->textlen) {
		free(G_mnu->mh[hno]->text);
		G_cursize-=G_mnu->mh[hno]->textlen;
	}
	if (G_fflds[hno].len) {
		G_mnu->mh[hno]->textlen=G_fflds[hno].len+1;
		if ((G_mnu->mh[hno]->text=malloc(G_mnu->mh[hno]->textlen))
				==(void *)NULL)  {
			return(0);
		}
		G_cursize+=G_mnu->mh[hno]->textlen;
		strcpy(G_mnu->mh[hno]->text,G_fflds[hno].val);
	}
	else
		G_mnu->mh[hno]->textlen=0;
	G_mnu->mh[hno]->xpos=G_fflds[hno].xpos;
	G_mnu->mh[hno]->mh_line=G_fflds[hno].ypos+1;
	return(1);
}

int  delhdr(int hno,int w) {

	if (hno>1) return(0);
	if (G_mnu->mh[hno]->textlen) {
		free(G_mnu->mh[hno]->text);
		G_cursize-=G_mnu->mh[hno]->textlen;
	}
	free(G_mnu->mh[hno]);
	G_cursize-=sizeof(menuhdr);

	if ((hno==0)&&(G_nohdr==2)) {
		G_mnu->mh[hno]=G_mnu->mh[hno+1];
		drml(w,hno+1,0);
		G_mnu->mh[hno]->mh_line=1;
		G_fflds[hno+1].ypos=0;
		drml(w,hno+1,YELLOW);
	}
	G_nohdr--;
	G_mnu->mh=realloc(G_mnu->mh,1+sizeof(menuhdr *)*G_nohdr);
	G_mnu->nummh--;
	return(1);
}

int  addln(void) {
	int lno;

	lno=G_mnu->numml;
	if ((G_mnu->ml=realloc(G_mnu->ml,1+sizeof(menuln *)*(lno+1)))
			==(void *)NULL) return(0);
	if ((G_mnu->ml[lno]=malloc(sizeof(menuln)))
			==(void *)NULL) return(0);
	memset(G_mnu->ml[lno],0,sizeof(menuln));
	G_cursize+=sizeof(menuln);
	G_mnu->numml++;
	G_mnu->ml[lno]->ml_line=lno+1;
	G_mnu->ml[lno]->ypos=G_fflds[G_noflds].ypos;
	G_mnu->ml[lno]->mne=G_fflds[G_noflds].val[0];
	G_mnu->ml[lno]->textlen=G_fflds[G_noflds].len+1;
	if ((G_mnu->ml[lno]->text=malloc(G_mnu->ml[lno]->textlen))
			==(void *)NULL) {
		free(G_mnu->ml[lno]);
		G_mnu->ml=realloc(G_mnu->ml,1+sizeof(menuln *)*lno);
		G_cursize-=sizeof(menuln);
		G_mnu->numml--;
		return(0);
	}
	G_cursize+=G_mnu->ml[lno]->textlen;
	strcpy(G_mnu->ml[lno]->text,&G_fflds[G_noflds].val[1]);
	return(1);
}

int  updln(int lno) {

	if (G_mnu->ml[lno]->textlen) {
		free(G_mnu->ml[lno]->text);
		G_cursize-=G_mnu->ml[lno]->textlen;
	}
	if (G_fflds[lno+G_nohdr].len) {
		G_mnu->ml[lno]->textlen=G_fflds[lno+G_nohdr].len+1;
		if ((G_mnu->ml[lno]->text=malloc(G_mnu->ml[lno]->textlen))
				==(void *)NULL)  {
			return(0);
		}
		G_cursize+=G_mnu->ml[lno]->textlen;
		strcpy(G_mnu->ml[lno]->text,&G_fflds[lno+G_nohdr].val[1]);
	}
	else
		G_mnu->ml[lno]->textlen=0;
	G_mnu->ml[lno]->ml_line=lno+1;
	G_mnu->ml[lno]->ypos=G_fflds[lno+G_nohdr].ypos;
	G_mnu->ml[lno]->mne=G_fflds[lno+G_nohdr].val[0];
	return(1);
}

int  delln(int lno) {
	int fno;

	if (G_mnu->ml[lno]->textlen) {
		free(G_mnu->ml[lno]->text);
		G_cursize-=G_mnu->ml[lno]->textlen;
	}
	if (G_mnu->ml[lno]->promptlen) {
		free(G_mnu->ml[lno]->prompt);
		G_cursize-=G_mnu->ml[lno]->promptlen;
	}
	if (G_mnu->ml[lno]->helplen) {
		free(G_mnu->ml[lno]->help);
		G_cursize-=G_mnu->ml[lno]->helplen;
	}
	free(G_mnu->ml[lno]);
	G_cursize-=sizeof(menuln);
	for (fno=lno;fno<1;fno++) {
		G_mnu->ml[fno]=G_mnu->ml[fno+1];
		G_mnu->ml[fno]->ml_line--;
	}
	G_mnu->ml=realloc(G_mnu->ml,1+sizeof(menuln *)*(G_noflds-G_nohdr-1));
	G_mnu->numml--;
	return(1);
}

int dmf(int scrnfld,int w) {
	int i;

	switch(G_fflds[scrnfld].type) {
		case 'h' : {
			drml(w,scrnfld,0);
			if (!delhdr(scrnfld,w)) return(0);
		} break;
		default : {
			return(0);
		}
	}
	for (i=scrnfld;i<(G_noflds-1);i++) {
		memcpy(&G_fflds[i],&G_fflds[i+1],sizeof(frmflds));
	}
	G_noflds--;
	memset(&G_fflds[G_noflds],'\0',sizeof(frmflds));
	redrawmnu(w,(-1));
	return(1);
}

int addidsml(int item,int mlno) {
	int i;

	memset(&G_fflds[0],0,sizeof(frmflds)*40);
	G_mnu=&G_dsp.ds.m;
	if (!loadmenu(G_cellname,lev[G_nowlev].G_elem[item].ident)) return(0);
	G_noflds=G_mnu->nummh+G_mnu->numml;
	G_fflds[G_noflds].ypos=G_mnu->nummh+G_mnu->numml+1;
	G_fflds[G_noflds].val[0]=lev[G_nowlev].G_cont[mlno].text[0];
	G_fflds[G_noflds].len=strlen(lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[mlno].to].text);
	strcpy(&G_fflds[G_noflds].val[1],lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[mlno].to].text);
	if (!addln()) {
		freemnu(G_mnu,1);
		return(-1);
	}
	G_mnu->ml[G_noflds-G_mnu->nummh-1]->chain_to=lev[G_nowlev].G_cont[mlno].to;
	for (i=G_noflds;i>mlno;i--) { /* shuffle lines down */
		swapml(i,i-1,0,0);
	}
	if (!savemenu(G_cellname,&G_dsp,0)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	freemnu(G_mnu,1);

	return(1);
}

int delidsml(int item,int mlno) {

	G_mnu=&G_dsp.ds.m;
	if (!loadmenu(G_cellname,lev[G_nowlev].G_elem[item].ident)) return(0);
	if (!delln(mlno)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	if (!savemenu(G_cellname,&G_dsp,0)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	freemnu(G_mnu,1);
	return(1);
}

int updidsml(int item,int mlno) {
	int i;

	G_mnu=&G_dsp.ds.m;
	if (!loadmenu(G_cellname,lev[G_nowlev].G_elem[item].ident)) return(0);
	i=mlno+G_mnu->nummh-1;
	G_fflds[i].ypos=G_mnu->ml[mlno]->ypos;
	G_fflds[i].val[0]=lev[G_nowlev].G_cont[mlno].text[0];
	strcpy(&G_fflds[i].val[1],lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[mlno].to].text);
	G_fflds[i].len=strlen(&G_fflds[i].val[1]);
	if (!updln(mlno)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	if (!savemenu(G_cellname,&G_dsp,0)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	freemnu(G_mnu,1);
	return(1);
}

int delidsmenu(int item) {

	G_mnu=&G_dsp.ds.m;
	if (!loadmenu(G_cellname,lev[G_nowlev].G_elem[item].ident)) return(0);
	if (!savemenu(G_cellname,&G_dsp,1)) {
		freemnu(G_mnu,1);
		return(-1);
	}
	freemnu(G_mnu,1);
	return(1);
}
