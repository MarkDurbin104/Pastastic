#include <graphics.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include "tdef.h"

void scrollvar(void);

int G_varpos;
eltab	*G_tab;
char	G_cmd[300];
char	G_nocmd;
char	G_currentfl;
char	G_comofs;
char	G_opofs;
char	G_comdused;
char	G_cmdtype;
int		G_lnptr;
int		G_noitems;
char	G_v;
int		G_i;
int		G_crntlev[32];
int		G_crntrep[32];
int		G_now=0;
cdll	cdl;
int G_doingut;
int G_inmsg;
int G_inprocess;
void psddef(int item) {
	int xit=0,pos,i,skip;
	char k,eding=(-1),inputstr[256],incntr=0;
	union {
		char *c;
		int  *i;
	} u;
	G_nocmd=G_lnptr=G_comofs=G_noitems=0;
	G_comdused=G_currentfl=G_inmsg=G_inprocess=0;
	G_opofs=8;
	setuppsd(item);
	while (!xit) {
		if (kbhit()) {
			switch (k=getch()) {
				case 8 : {
					if (eding==(-1)) {
						G_lnptr=findlast(G_cmd,G_lnptr);
						G_cmd[G_lnptr]='Z';
						prln();
					}
					else {
						if (incntr>0) {
							incntr--;
							G_lnptr--;
							G_cmd[G_lnptr-1]='^';
							G_cmd[G_lnptr]='Z';
						}
					}
				} break;
				case 10 : {
				} break;
				case 13 : {
					eding=(-1);
					inputstr[incntr]=0;
					for (i=0;i<G_varib.novar;i++) {
						if (!strcmp(G_varib.vars[i]->name,inputstr)) eding=i;
					}
					if (eding==(-1)) {
						skip=0;
						switch (valid(inputstr)) {/*0=ERR 1=INT 2=LONG 3=FLOAT 4=CHAR 5=VAR*/
							case 1 : {
								G_nolit++;
								G_lit=realloc(G_lit,G_nolit*sizeof(lits));
								G_lit[G_nolit-1].t='i';
								G_lit[G_nolit-1].v=malloc(sizeof(int));
								*((int *)G_lit[G_nolit-1].v)=atoi(inputstr);
							} break;
							case 2 : {
								G_nolit++;
								G_lit=realloc(G_lit,G_nolit*sizeof(lits));
								G_lit[G_nolit-1].t='l';
								G_lit[G_nolit-1].v=malloc(sizeof(long));
								*((long *)G_lit[G_nolit-1].v)=atol(inputstr);
							} break;
							case 3 : {
								G_nolit++;
								G_lit=realloc(G_lit,G_nolit*sizeof(lits));
								G_lit[G_nolit-1].t='f';
								G_lit[G_nolit-1].v=malloc(sizeof(float));
								*((float *)G_lit[G_nolit-1].v)=atof(inputstr);
							} break;
							case 4 : {
								G_nolit++;
								G_lit=realloc(G_lit,G_nolit*sizeof(lits));
								G_lit[G_nolit-1].t='C';
								G_lit[G_nolit-1].v=malloc(strlen(inputstr)+2);
								strcpy(G_lit[G_nolit-1].v,inputstr);
							} break;
							case 5 : {
								switch (popup(100,100,450,50,"Select A Type",0,"STRING.INT.FLOAT.DOUBLE.LONG.CANCEL")) {
									case 0 : {
										i=addvar(inputstr,'C',0);
									} break;
									case 1 : {
										i=addvar(inputstr,'i',2);
									} break;
									case 2 : {
										i=addvar(inputstr,'l',4);
									} break;
									case 3 : {
										i=addvar(inputstr,'f',6);
									} break;
									case 4 : {
										i=addvar(inputstr,'d',4);
									} break;
									case 5 : {
										G_lnptr=findlast(G_cmd,G_lnptr);
										G_cmd[G_lnptr]='Z';
										skip=1;
									} break;
								}
								if (!skip) {
									G_lnptr=findlast(G_cmd,G_lnptr);
									G_cmd[G_lnptr++]='V';
									u.c=&G_cmd[G_lnptr];
									*u.i=G_varib.vars[i]->ofs;
									G_lnptr+=sizeof(int);
									G_cmd[G_lnptr]='Z';
									mousecur(0);
									setuppsd(item);
									mousecur(1);
								}
							} break;
							default : {
								G_lnptr=findlast(G_cmd,G_lnptr);
								G_cmd[G_lnptr]='Z';
							}
						}
					}
					else {
						G_lnptr=findlast(G_cmd,G_lnptr);
						G_cmd[G_lnptr++]='V';
						u.c=&G_cmd[G_lnptr];
						*u.i=G_varib.vars[eding]->ofs;
						G_lnptr+=sizeof(int);
						G_cmd[G_lnptr]='Z';
					}
					eding=(-1);
					prln();
				} break;
				default : {
					if (eding!=(-1)) {
						G_cmd[G_lnptr-1]=k;
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
						inputstr[incntr++]=k;
						prln();
					}
					else {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]=k;
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
						inputstr[0]=k;
						incntr=1;
						eding=1;
						prln();
					}
				}
			}
		}
		if (mousetrap(1)) {
			if (mseb) {
				scrollvar();
				pos=(((msey-WINY)-110)/11);
				if (combox()) if ((xit=addto(1,pos))==1) buildln(item);
				if (oprbox()) if ((xit=addto(2,pos))==1) buildln(item);
				if (filbox()) if ((xit=addto(3,pos))==1) buildln(item);
				if (fldbox()) if ((xit=addto(4,pos))==1) buildln(item);
				if (inbox(75,G_maxy-30,125,G_maxy-10)) {
					okpbut();
					if (G_lnptr) buildln(item);
					xit=1;
				}
				if (inbox(290,G_maxy-30,340,G_maxy-10)) {
					canpbut();
					xit=1;
				}
			}
			while (mseb) mousetrap(1);
		}
	}
	mousecur(0);
}
void setuppsd(int item) {
	int i,yp;
	char tmp[100];
	union {
		char *c;
		int  *i;
	} u;
	cleardevice();
	setcolor(14);
    settextjustify(1,2);
	setviewport(0,0,G_maxx,G_maxy,1);
	rectangle(0,0,G_maxx,G_maxy);
	setviewport(0,WINY,G_maxx,G_maxy,1);
	setfillstyle(1,1);
	bar(0,0,G_maxx,G_maxy-WINY);
	rectangle(0,0,G_maxx,G_maxy-WINY);
	line(0,24,G_maxx,24);
	settextstyle(2,0,5);
	sprintf(tmp,"PMA CDL    PSD ITEM DEFINITION     CELL %s.",G_cellname);
	outtxtxy(G_maxx/2,2,tmp);
	sprintf(tmp,"PSD ITEM %d",item);
	outtxtxy(G_maxx/2,30,tmp);
	yp=((G_maxy-46-WINY)/11)*11;

	setcolor(9);
	setfillstyle(1,0);
	bar(16,110,166,yp);
	rectangle(16,90,166,yp);
	bar(180,110,286,320);
	rectangle(180,90,286,320);
	bar(300,110,400,yp);
	rectangle(300,90,400,yp);
	for (i=121;i<yp;i+=11) {
		line(16,i,166,i);
		line(300,i,400,i);
	}
	for (i=1;i<19;i++) line(180,i*11+110,286,i*11+110);
	setcolor(14);
	settextstyle(2,0,4);
	settextjustify(0,2);
	outtxtxy(26,95,"INSTRUCTION");
	for (i=0;i<27;i++) outtxtxy(26,i*11+110,command[i+G_comofs]);
	settextjustify(1,2);
	outtxtxy(233,95,"OPERATOR");
	for (i=0;i<18;i++) outtxtxy(233,i*11+110,operator[i+G_opofs]);
	outtxtxy(350,95,"FILE");
	outtxtxy(350,110,"VARIABLES");
	for (i=0;i<min(26,G_file.nofiles);i++) outtxtxy(350,(i+1)*11+110,G_file.files[i]);
	bar(170,347,300,407);
	rectangle(170,347,300,407);
	setfillstyle(1,0);
	bar(1,70,G_maxx-1,80);
	if (lev[G_nowlev].G_elem[item].type==11) {
		printpsdln(235,350,lev[G_nowlev].G_elem[item].text,14);
		outtxtxy(G_maxx/2,70,tpsdln(lev[G_nowlev].G_elem[item].text));
		G_doingut=0;
	}
	else {
		printpsdln(235,350,G_utl[lev[G_nowlev].G_elem[item].ident],14);
		outtxtxy(G_maxx/2,70,tpsdln(G_utl[lev[G_nowlev].G_elem[item].ident]));
		G_doingut=1;
		movto(1,293,349);
		linto(1,297,353);
		movto(1,297,349);
		linto(1,293,353);
		movto(1,295,349);
		linto(1,295,353);
		movto(1,297,351);
		linto(1,293,351);
		movto(1,170,354);
		linto(1,300,354);
		G_comdused=1;
		G_cmdtype=comtype[0];
		G_cmd[G_lnptr++]='C';
		u.c=&G_cmd[G_lnptr];
		*u.i=45;
		G_lnptr+=sizeof(int);
		G_cmd[G_lnptr]='Z';
		G_noitems++;
		G_opofs=0;
		setfillstyle(1,0);
		setcolor(14);
		settextstyle(2,0,4);
		settextjustify(1,2);
		for (i=0;i<18;i++) {
			bar(181,i*11+111,285,i*11+120);
			if (i<14) {
				outtxtxy(233,i*11+110,operator[i+G_opofs]);
			}
		}
	}
	arrow(1,235,330,235,347);
	button(100,G_maxy-WINY-20,"OK",0,0);
	button(315,G_maxy-WINY-20,"CANCEL",0,0);

	prvbox(0,(fldvar **)G_varib.vars,G_varib.novar);
}
void okpbut(void) {
	mousecur(0);
	button(100,G_maxy-WINY-20,"OK",1,1);
	mousecur(1);
	while (((mousetrap(G_snapto)>>5)&7));
}
void canpbut(void) {
	mousecur(0);
	button(315,G_maxy-WINY-20,"CANCEL",1,1);
	mousecur(1);
	while (((mousetrap(G_snapto)>>5)&7));
}
int combox(void) { return(inbox(16,120,166,418)); }
int oprbox(void) { return(inbox(180,120,286,320)); }
int filbox(void) { return(inbox(300,120,400,407)); }
int fldbox(void) { return(inbox(G_maxx-186,120,G_maxx-16,429)); }

int addto(int itype,int ypos) {
	int i,j,k,y;
	char first=0,tmp[200];
	file *t;
	union {
		char *c;
		int  *i;
	} u;
	switch(itype) {
		case 1 : {
			if (G_inmsg) {
				sprintf(&G_cmd[G_lnptr],"L%s^LTO^Z",G_msg[ypos].n);
				G_lnptr+=strlen(&G_cmd[G_lnptr])-1;
				mousecur(0);
				prln();
				mousecur(0);
				settextstyle(2,0,4);
				settextjustify(0,2);
				bar(17,111,165,120);
				outtxtxy(26,110,"SELF");
				bar(17,122,165,131);
				outtxtxy(26,121,"SENDER");
				j=2;
				for (i=0;i<G_noelem[0];i++) {
					if (lev[0].G_elem[i].type<8) {
						bar(17,j*11+111,165,j*11+120);
						strcpy(tmp,lev[0].G_elem[i].text);
						for (k=0;k<14;k++) if ((tmp[k]==10)||(tmp[k]==13)) tmp[k]=' ';
						tmp[14]=0;
						outtxtxy(26,j*11+110,tmp);
						j++;
						if (j==27) break;
					}
				}
				for (;j<27;j++) bar(17,j*11+111,165,j*11+120);
				mousecur(1);
				G_inprocess=1;
				G_inmsg=0;
				return(0);
			}
			if (G_inprocess) {
				switch(ypos) {
					case 0 : {
						strcpy(&G_cmd[G_lnptr-1],"œ0^Z");
						G_lnptr+=strlen(&G_cmd[G_lnptr])-1;
						return(1);
					}
					case 1 : {
						strcpy(&G_cmd[G_lnptr-1],"œ11111^Z");
						G_lnptr+=strlen(&G_cmd[G_lnptr])-1;
						return(1);
					}
					default : {
						j=2;
						for (i=0;i<G_noelem[0];i++) {
							if (lev[0].G_elem[i].type<8) {
								if (j==ypos) {
									sprintf(&G_cmd[G_lnptr-1],"œ%d^Z",lev[0].G_elem[i].ident);
									G_lnptr+=strlen(&G_cmd[G_lnptr])-1;
								}
								j++;
								if (j==27) break;
							}
						}
						return(1);
					}
				}
			}
			if (!G_comdused) {
				if (ypos+G_comofs<33) {
					G_comdused=1;
					G_cmdtype=comtype[ypos+G_comofs];
					G_cmd[G_lnptr++]='C';
					u.c=&G_cmd[G_lnptr];
					*u.i=ypos+G_comofs;
					G_lnptr+=sizeof(int);
					G_cmd[G_lnptr]='Z';
					prln();
					if (G_cmdtype==6) return(1);
					G_noitems++;
					if (comtype[ypos+G_comofs]==4) {
						mousecur(0);
						setfillstyle(1,0);
						setcolor(14);
						settextstyle(2,0,4);
						settextjustify(0,2);
						j=0;
						for (i=0;i<G_nomsg;i++) {
							if (G_msg[i].l!=(-1)) {
								bar(17,j*11+111,165,j*11+120);
								outtxtxy(26,j*11+110,G_msg[i].n);
								j++;
								if (j==27) break;
							}
						}
						for (;j<27;j++) bar(17,j*11+111,165,j*11+120);
						G_inmsg=1;
						mousecur(1);
					}
					if (ypos+G_comofs<2) {
						G_opofs=0;
						setfillstyle(1,0);
						setcolor(14);
						settextstyle(2,0,4);
						settextjustify(1,2);
						for (i=0;i<18;i++) {
							bar(181,i*11+111,285,i*11+120);
							if (i<14) {
								outtxtxy(233,i*11+110,operator[i+G_opofs]);
							}
						}
					}
					if (ypos+G_comofs==7) {
						G_opofs=0;
						setfillstyle(1,0);
						setcolor(14);
						settextstyle(2,0,4);
						settextjustify(1,2);
						for (i=0;i<18;i++) {
							bar(181,i*11+111,285,i*11+120);
							if (i<3) {
								outtxtxy(233,i*11+110,operator[i+G_opofs]);
							}
						}
					}
				}
			}
		} break;
		case 2 : {
			if (G_nocmd<25) {
				if (ypos+G_opofs<26) {
					G_cmd[G_lnptr++]='O';
					u.c=&G_cmd[G_lnptr];
					*u.i=ypos+G_opofs;
					G_lnptr+=sizeof(int);
					G_cmd[G_lnptr]='Z';
					prln();
					G_noitems++;
				}
			}
		} break;
		case 3 : {
			G_currentfl=ypos;
			if ((G_comdused)&&((G_cmdtype==3)||(G_cmdtype==9))) {
				if ((ypos>0)&&(ypos<=G_file.nofiles)) {
					G_cmd[G_lnptr++]='F';
					u.c=&G_cmd[G_lnptr];
					*u.i=ypos-1;
					G_lnptr+=sizeof(int);
					G_cmd[G_lnptr]='Z';
					if (G_cmdtype==3) {
						return(1);
					}
					else {
						G_cmd[G_lnptr++]='C';
						u.c=&G_cmd[G_lnptr];
						*u.i=26;
						G_lnptr+=sizeof(int);
						t=loadfile(G_cellname,ypos);
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]=prfile(t)+48;
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
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
				}
			}
			else {
				if (ypos==0) {
					prvbox(G_varpos,(fldvar **)G_varib.vars,G_varib.novar);
				}
				else {
					if (ypos<=G_file.nofiles) {
						prvbox(0,G_file.cont[ypos-1]->flds
							,G_file.cont[ypos-1]->nofld);
					}
				}
			}
		} break;
		case 4 : {
			if (G_inprocess) {
				strcpy(&G_cmd[G_lnptr-1],"œ11112^Z");
				G_lnptr+=strlen(&G_cmd[G_lnptr])-1;
			}
			if (G_nocmd<25) {
				if (G_lnptr==0) {
					G_comofs=28;
					first=1;
				}
				if ((G_comdused)&&(G_cmdtype==7)) {
					if (G_noitems==2) {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]='(';
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
					}
					if (G_noitems==3) {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]='+';
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
					}
				}
				if ((G_comdused)&&(G_cmdtype==10)) {
					if (G_noitems==3) {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]='F';
						G_cmd[G_lnptr++]='R';
						G_cmd[G_lnptr++]='O';
						G_cmd[G_lnptr++]='M';
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
					}
					if (G_noitems==4) {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]='T';
						G_cmd[G_lnptr++]='O';
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
					}
				}
				if ((G_comdused)&&(G_cmdtype==11)) {
					if (G_noitems==3) {
						G_cmd[G_lnptr++]='L';
						G_cmd[G_lnptr++]='A';
						G_cmd[G_lnptr++]='T';
						G_cmd[G_lnptr++]='^';
						G_cmd[G_lnptr]='Z';
					}
				}
				if (G_currentfl) {
					G_cmd[G_lnptr++]='E';
					u.c=&G_cmd[G_lnptr];
					*u.i=G_currentfl-1;
					G_lnptr+=sizeof(int);
					u.c=&G_cmd[G_lnptr];
					*u.i=ypos;
					G_lnptr+=sizeof(int);
					G_cmd[G_lnptr]='Z';
					prln();
					G_noitems++;
				}
				else {
					G_cmd[G_lnptr++]='V';
					u.c=&G_cmd[G_lnptr];
					y=ypos+G_varpos;
					*u.i=G_varib.vars[y]->ofs;
					G_lnptr+=sizeof(int);
					if (G_varib.vars[y]->ofs==4
					||	G_varib.vars[y]->ofs==7
					||	G_varib.vars[y]->ofs==8
					||	G_varib.vars[y]->ofs==15
					||	G_varib.vars[y]->ofs==17 ) getvalue();
					G_cmd[G_lnptr]='Z';
					prln();
					G_noitems++;
				}
				if (first) {
					G_cmd[G_lnptr++]='O';
					u.c=&G_cmd[G_lnptr];
					*u.i=0;
					G_lnptr+=sizeof(int);
					G_cmd[G_lnptr]='Z';
					setfillstyle(1,0);
					setcolor(14);
					settextstyle(2,0,4);
					settextjustify(0,2);
					for (i=0;i<27;i++) {
						bar(17,i*11+111,165,i*11+120);
						if (i+G_comofs<33) outtxtxy(26,i*11+110,command[i+G_comofs]);
					}
					prln();
				}
				if ((G_comdused)&&(G_cmdtype==10)&&(G_noitems==5)) return(1);
				if ((G_comdused)&&(G_cmdtype==11)&&(G_noitems==4)) return(1);
				if ((G_comdused)&&(G_cmdtype==12)&&(G_noitems==3)) return(1);
				if ((G_comdused)&&(G_cmdtype==7)&&(G_noitems==4)) {
					G_cmd[G_lnptr++]='L';
					G_cmd[G_lnptr++]=')';
					G_cmd[G_lnptr++]='^';
					G_cmd[G_lnptr]='Z';
					return(1);
				}
			}
			if (G_inprocess) {
				G_inprocess=0;
				return(1);
			}
		} break;
	}
	return(0);
}
void prln(void) {
	setfillstyle(1,0);
	bar(170,347,300,407);
	rectangle(170,347,300,407);
	printpsdln(235,350,G_cmd,14);
	setfillstyle(1,0);
	bar(1,70,G_maxx-1,80);
	setcolor(14);
	settextstyle(2,0,4);
	outtxtxy(G_maxx/2,70,tpsdln(G_cmd));
}
void buildln(int item) {
	if (G_doingut) {
		G_utl[lev[G_nowlev].G_elem[item].ident]=
		realloc(G_utl[lev[G_nowlev].G_elem[item].ident],G_lnptr+2);
		memcpy(G_utl[lev[G_nowlev].G_elem[item].ident],G_cmd,G_lnptr+2);
	}
	else {
		lev[G_nowlev].G_elem[item].text=
		realloc(lev[G_nowlev].G_elem[item].text,G_lnptr+2);
		memcpy(lev[G_nowlev].G_elem[item].text,G_cmd,G_lnptr+2);
	}
}
void printpsdln(int x,int y,char *text,int col) {
	int i;
	char tmp[500],*t,pln[40];
	strcpy(tmp,tpsdln(text));
	settextjustify(1,2);
	settextstyle(2,0,4);
	setcolor(col);
	t=strtok(tmp," ");
	pln[0]=0;
	i=7;
	while (t!=(char *)NULL) {
		if ((strlen(t)+strlen(pln))<20) {
			strcat(pln,t);
			strcat(pln," ");
		}
		else {
			outtxtxy(x,y+i,pln);
			i+=10;
			sprintf(pln,"%s ",t);
		}
		t=strtok((char *)NULL," ");
	}
	if (strlen(pln)) outtxtxy(x,y+i,pln);
}
void traversepsd(void) {
	int	i;
	for (i=0;i<G_noelem[G_nowlev];i++) {
		G_tab[i].i=i;
		G_tab[i].x=lev[G_nowlev].G_elem[i].xpos;
		G_tab[i].y=lev[G_nowlev].G_elem[i].ypos;
	}
	qsort(G_tab,G_noelem[G_nowlev],sizeof(eltab),chktab);
	getlegs(G_tab[0].i,1);
}
int getlegs(int item,int pos) {
	int	i,j=0,pofs=pos;
	eltab *tab;
	tab=malloc(sizeof(eltab));
	for (i=0;i<G_nocont[G_nowlev];i++) {
		if (lev[G_nowlev].G_cont[i].from==item) {
			j++;
			tab=realloc(tab,j*sizeof(eltab));
			tab[j-1].i=lev[G_nowlev].G_cont[i].to;
			tab[j-1].x=lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].xpos;
			tab[j-1].y=lev[G_nowlev].G_elem[lev[G_nowlev].G_cont[i].to].ypos;
		}
	}
	if (j==0) return(pofs);
	qsort(tab,j,sizeof(eltab),chktab);
	for (i=0;i<j;i++) {
		G_tab[pofs].i=tab[i].i;
		G_tab[pofs].x=tab[i].x;
		G_tab[pofs].y=tab[i].y;
		pofs=getlegs(G_tab[pofs].i,pofs+1);
	}
	free(tab);
	return(pofs);
}
int chktab(eltab *a,eltab *b) {
	if (a->y<b->y) return(-1);
	if (a->y>b->y) return(1);
	if (a->x<b->x) return(-1);
	if (a->x>b->x) return(1);
	return(0);
}
void prnpsd(char *text) {
	FILE *fp;
	char tmp[200];
	strcpy(tmp,tpsdln(text));
	fp=fopen("opt.prn","a+");
	fprintf(fp,"%s\n",tmp);
	fclose(fp);
}
char *tpsdln(char *text) {
	int i,j,xit,cmd;
	static char tmp[400];
	char *t,tmp1[50];
	union {
		char *c;
		int  *i;
	} u;
	tmp[0]=i=xit=cmd=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i++;
				u.c=&text[i];
				cmd=*u.i;
				if (*u.i==45) {
					strcat(tmp,command[33]);
				}
				else {
					strcat(tmp,command[*u.i]);
				}
				i+=sizeof(int);
			} break;
			case 'L' : {
				i++;
				j=0;
				t=&text[i];
				while (*(t++)!='^') {
					tmp1[j++]=text[i++];
				}
				tmp1[j++]=0;
				if (!strncmp(tmp1,"TOœ",3)) {
					sprintf(tmp1,"TO %s",getpname(atoi(&tmp1[3])));
					if (tmp1[3]==1) strcpy(tmp1,"TO UNKNOWN");
					if (tmp1[3]==2) strcpy(tmp1,"TO");
				}
				strcat(tmp,tmp1);
				i++;
			} break;
			case 'O' : {
				i++;
				u.c=&text[i];
				strcat(tmp,operator[*u.i]);
				i+=sizeof(int);
			} break;
			case 'F' : {
				i++;
				u.c=&text[i];
				if (*u.i<G_file.nofiles) {
					strcat(tmp,G_file.files[*u.i]);
				}
				else {
					sprintf(tmp1,"S(%d)",*u.i);
					strcat(tmp,tmp1);
				}
				i+=sizeof(int);
			} break;
			case 'E' : {
				i++;
				u.c=&text[i];
				if (*u.i<G_file.nofiles) {
					strcat(tmp,G_file.files[*u.i]);
					j=*u.i;
					strcat(tmp,".");
					i+=sizeof(int);
					u.c=&text[i];
					if (*u.i<G_file.cont[j]->nofld) {
						strcat(tmp,G_file.cont[j]->flds[*u.i]->name);
					}
					else {
						sprintf(tmp1,"F(%d)",*u.i);
						strcat(tmp,tmp1);
					}
					i+=sizeof(int);
				}
				else {
					sprintf(tmp1,"S(%d)",*u.i);
					strcat(tmp,tmp1);
					strcat(tmp,".");
					i+=sizeof(int);
					u.c=&text[i];
					sprintf(tmp1,"F(%d)",*u.i);
					strcat(tmp,tmp1);
					i+=sizeof(int);
				}
			} break;
			case 'V' : {
				i++;
				u.c=&text[i];
				if (cmd==15) {
					if (*u.i-20<G_nomsg) {
						strcat(tmp,G_msg[*u.i-20].n);
					}
					else {
						strcat(tmp,"NOMES");
					}
					cmd=99;
				}
				else {
					for (j=0;j<G_varib.novar;j++) {
						if (G_varib.vars[j]->ofs==*u.i) {
							if (*u.i==4 || *u.i==7 || *u.i==8 || *u.i==15 || *u.i==17) {
								strcat(tmp,G_varib.vars[j]->name);
								tmp[strlen(tmp)-2]=0;
								sprintf(tmp1,"[%d]",atoi(&text[i+sizeof(int)+1]));
								strcat(tmp,tmp1);
								i+=sizeof(int);
								while(text[i++]!='^');
								i-=sizeof(int);
							}
							else {
								strcat(tmp,G_varib.vars[j]->name);
							}
							break;
						}
					}
					if (j==G_varib.novar) {
						sprintf(tmp1,"VAR(%d)",*u.i);
						strcat(tmp,tmp1);
					}
				}
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				strcat(tmp,"*");
				xit=1;
			}
		}
		strcat(tmp," ");
	}
	tmp[strlen(tmp)-2]=0;
	return(tmp);
}
char prfile(file *t) {
	int i,j,yp;
	char tmp[100];
	if (t->nokey<2) return(1);
	mousecur(0);
	setcolor(14);
	yp=((G_maxy-46-WINY)/11)*11;
	setcolor(9);
	setfillstyle(1,1);
	bar(16,90,G_maxx-1,yp);
	setfillstyle(1,0);
	bar(16,110,244,yp);
	rectangle(16,90,244,yp);
	for (i=110;i<yp;i+=11) line(16,i,244,i);
	for (i=1;i<9;i++) line((i*16),100,(i*16),yp);
	line((i*16),90,(i*16),yp);
	line(16,100,i*16,100);
	setcolor(14);
	settextstyle(2,0,4);
	outtxtxy(130,70,"S E L E C T   A   K E Y   T O   U S E");
	outtxtxy(80,90,"K E Y S");
	for (i=1;i<9;i++) outtxtxy((i*16)+8,100,itoa(i,tmp,10));
	outtxtxy(194,95,"FIELD NAME");
	for (i=0;i<t->nofld;i++) outtxtxy(194,110+(i*11),t->flds[i]->name);
	for (i=0;i<t->nokey;i++) {
		for (j=0;j<t->keys[i]->noparts;j++) {
			outtxtxy((i*16)+24,110+(t->keys[i]->keypts[j]->fld*11),itoa(t->keys[i]->keypts[j]->fldordr,tmp,10));
		}
	}
	markkey(t,0,12);
	mousecur(1);
	while (1) {
		if (kbhit()) {
			getch();
			return(1);
		}
		if (mousetrap(1)) {
			if (mseb) {
				if (inbox(16,110+WINY,144,yp)) {
					if ((msex-16)/16<t->nokey) {
						markkey(t,0,0);
						markkey(t,(msex-16)/16,12);
						for (i=0;i<8000;i++);
						return(((msex-16)/16)+1);
					}
				}
			}
		}
	}
}
int valid(char *str) {/*RET VALS - 0=ERR 1=INT 2=LONG 3=FLOAT 4=CHAR 5=VAR*/
	int i=1;
	char *t=str;
	while (*t) {
		if (!isdigit(*t)&&(*t!='+')&&(*t!='-')) i=0;
		t++;
	}
	if (i) if (atol(str)<65536L) return(1); else return(2);
	i=1;
	t=str;
	while (*t) {
		if (!isdigit(*t)&&(*t!='.')&&(*t!='+')&&(*t!='-')) i=0;
		t++;
	}
	if (i) return(3);
	if ((str[0]=='"')&&(str[strlen(str)-1]=='"')) return(4);
	i=1;
	t=str;
	while (*t) {
		if (!isalnum(*t)&&(*t!='_')) i=0;
		t++;
	}
	if (i) return(5);
	return(0);
}
int findlast(char *str,int len) {
	int i,j=0,xit=0;
	char *t;
	while (!xit) {
		i=j;
		switch(str[i]) {
			case 'C' : {
				i++;
				i+=sizeof(int);
			} break;
			case 'L' : {
				i++;
				t=&str[i];
				while (*(t++)!='^') {
					i++;
				}
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
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
		if (i==len-1) return(j); else j=i;
	}
	return(0);
}
void scrollvar(void) {
	int xp,yp,epos,spos,br;
	xp=G_maxx-208;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*G_varpos)/G_varib.novar);
	epos=((br*(G_varpos+27))/G_varib.novar);
	if (((epos+121)<(yp-11))||(spos!=0)) {
		if (inbox(xp+6,WINY+110,xp+16,WINY+120)) {
			G_varpos-=5;
			if (G_varpos<0) G_varpos=0;
			prvbox(G_varpos,(fldvar **)G_varib.vars,G_varib.novar);
		}
		if (inbox(xp+6,WINY+(yp-10),xp+16,WINY+yp)) {
			G_varpos+=5;
			if (G_varpos>(G_varib.novar-27)) G_varpos=G_varib.novar-27;
			prvbox(G_varpos,(fldvar **)G_varib.vars,G_varib.novar);
		}
		if (inbox(xp+6,WINY+121,xp+16,WINY+(121+spos))) {
			G_varpos-=26;
			if (G_varpos<0) G_varpos=0;
			prvbox(G_varpos,(fldvar **)G_varib.vars,G_varib.novar);
		}
		if (inbox(xp+6,WINY+(121+epos),xp+16,WINY+(yp-11))) {
			G_varpos+=26;
			if (G_varpos>(G_varib.novar-27)) G_varpos=G_varib.novar-27;
			prvbox(G_varpos,(fldvar **)G_varib.vars,G_varib.novar);
		}
	}
}