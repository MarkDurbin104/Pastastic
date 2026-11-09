#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include "tdef.h"

void addtomsgln(char type,char *txt);
void delmsg(int item);
void addmsg(int item,char *G_curln,char *name);
void prmsg(void);
int  getmsg(int item);
int  findmsg(char *name);
int  findimsg(int item);
void drcompo(void);
int  incompbox(void);
int  infilebox(void);
int  invarbox(void);
int  inmainbox(void);
int  inokbox(void);
int  infvbox(void);
void selcompo(int id);

int  G_compsel;
char G_msgln[400];
int  G_msgp;
int  G_curln;
int  G_compo[200];
int  G_nocompo;
int  G_composite;

void msgdef(int item) {
	int i,xit=0,yp,filselc=0,curfile=0,mesno;
	char tmp[50],yps,mes;
	char *t=MK_FP(0x0000,0x0417);
	union {
		char *c;
		int  *i;
	} u;
	yp=((G_maxy-46-WINY)/11)*11;
	G_compsel=(-1);
    G_nocompo=0;
	mesno=0;
	setupmsg(item);
	if (lev[G_nowlev].G_cont[item].ident==(-1)) {
		for (i=0;i<G_nomsg;i++) mesno=max(G_msg[i].m,mesno);
		mesno++;
		lev[G_nowlev].G_cont[item].ident=mesno;
	}
	else {
		mesno=lev[G_nowlev].G_cont[item].ident;
	}
	getmsg(mesno);
	prmsg();
	if (G_composite) {
		drcompo();
		selcompo(0);
		printf("%d %d\n",G_compo[0],mesno);
	}
	while (!xit) {
		if (mousetrap(1)) {
			if (mseb) {
				if (G_composite) {
					if (incompbox()) {
						while (mseb) mousetrap(1);
						yps=(msey-WINY-110)/11;
						if (*t&3) {
							if (yps<=G_nocompo) {
								if (yps!=G_nocompo) strcpy(tmp,G_msg[G_compo[yps]].n); else tmp[0]=0;
								if (G_compsel==yps) {
									setfillstyle(1,0);
									bar(18,G_compsel*11+111,114,G_compsel*11+120);
								}
								intextxy(66,((msey-WINY)/11)*11,tmp,14,0,14);
								if ((i=findmsg(tmp))!=(-1)) {
									G_compo[yps]=i;
								}
								else {
									mes=0;
									for (i=0;i<G_nomsg;i++) mes=max(G_msg[i].m,mes);
									mes++;
									G_composite=0;
									addmsg(mes,"",tmp);
									G_composite=1;
									G_compo[yps]=findimsg(mes);
								}
								if (G_compsel==yps) {
									setfillstyle(1,11);
									bar(18,G_compsel*11+111,114,G_compsel*11+120);
									setcolor(1);
									outtextxy(66,G_compsel*11+110,G_msg[G_compo[G_compsel]].n);
								}
							}
						}
						else {
							if (yps==G_nocompo) {
								tmp[0]=0;
								intextxy(66,((msey-WINY)/11)*11,tmp,14,0,14);
								if ((i=findmsg(tmp))!=(-1)) {
									G_compo[G_nocompo]=i;
									G_nocompo++;
								}
								else {
									mes=0;
									for (i=0;i<G_nomsg;i++) mes=max(G_msg[i].m,mes);
									mes++;
									G_composite=0;
									addmsg(mes,"",tmp);
									G_composite=1;
									G_compo[G_nocompo]=findimsg(mes);
									G_nocompo++;
								}
							}
							else {
								if (yps<G_nocompo) selcompo(yps);
							}
						}
					}
				}
				if (infilebox()) {
					filselc=1;
					setfillstyle(1,0);
					setcolor(14);
					settextstyle(2,0,4);
					settextjustify(0,2);
					for (i=0;i<27;i++) {
						bar(449,i*11+111,G_maxx-17,i*11+120);
						if (i<G_file.nofiles) outtxtxy(457,110+(i*11),G_file.files[i]);
					}
				}
				if (invarbox()) {
					filselc=0;
					prvbox(0,(fldvar **)G_varib.vars,G_varib.novar);
				}
				if (!(G_curln&1)) {
					if (inmainbox()) {
						tmp[0]=0;
						while (mseb) mousetrap(1);
						intextxy(292,G_curln*11+110,tmp,40,0,14);
						if (tmp[0]!=0) {
							addtomsgln('L',tmp);
							prmsg();
							G_curln++;
						}
					}
				}
				else {
					if (inokbox()) {
						if (G_curln>0) {
/*							if (G_composite) {
								if ((i=findimsg(mesno))!=(-1)) {
									if (G_msg[i].l==(-1)) {
										addmsg(mesno,G_msgln,lev[G_nowlev].G_cont[item].text);
									}
									else {
										mes=0;
										for (i=0;i<G_nomsg;i++) mes=max(G_msg[i].m,mes);
										mes++;
										addmsg(mes,G_msgln,lev[G_nowlev].G_cont[item].text);
									}
								}
								else {
									mes=0;
									for (i=0;i<G_nomsg;i++) mes=max(G_msg[i].m,mes);
									mes++;
									addmsg(mes,G_msgln,lev[G_nowlev].G_cont[item].text);
								}
							}
							else {*/
								addmsg(mesno,G_msgln,lev[G_nowlev].G_cont[item].text);
/*							}*/
							prmsg();
						}
						okmbut();
						xit=1;
					}
					if (infvbox()) {
						switch(filselc) {
							case 0 : {
								u.c=tmp;
								*u.i=((msey-WINY-110)/11);
								addtomsgln('V',tmp);
								prmsg();
								G_curln++;
							} break;
							case 1 : {
								filselc=2;
								curfile=((msey-WINY-110)/11);
								prvbox(0,G_file.cont[curfile]->flds,G_file.cont[curfile]->nofld);
							} break;
							case 2 : {
								u.c=tmp;
								*u.i=curfile;
								u.c=&tmp[2];
								*u.i=((msey-WINY-110)/11);
								addtomsgln('E',tmp);
								prmsg();
								G_curln++;
							} break;
						}
						while (mseb) mousetrap(1);
					}
				}
				if (inbox(182,G_maxy-30,232,G_maxy-10)) {
					if (!((G_nocompo)&&(G_composite))) {
						G_composite^=1;
						if (G_composite) {
							drcompo();
						}
						else {
							button(207,G_maxy-WINY-20,"REGULAR",0,0);
							mousecur(0);
							setcolor(0);
							for (i=121;i<yp;i+=11) line(16,i,165,i);
							setcolor(1);
							rectangle(16,90,165,yp);
							settextstyle(2,0,4);
							outtxtxy(66,95,"FLOW NAME");
							outtxtxy(140,95,"COMMENT");
							line(116,90,116,yp);
							mousecur(1);
						}
						while ((mousetrap(G_snapto)>>5)&7);
					}
				}
			}
		}
	}
}
void setupmsg(int item) {
	int i,xp,yp;
	char tmp[100]/*,tproc[80],fproc[80]*/;
	mousecur(0);
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
	sprintf(tmp,"PMA CDL    DATA FLOW DEFINITION     CELL %s.",G_cellname);
	outtxtxy(G_maxx/2,2,tmp);
	sprintf(tmp,"DATA FLOW %d     NAME %s",item,lev[G_nowlev].G_cont[item].text);
	outtxtxy(G_maxx/2,30,tmp);
	xp=(G_maxx-32)-176;
	yp=((G_maxy-46-WINY)/11)*11;
	outtxtxy((xp-32)/2,70,"DATA FLOW");

	setfillstyle(1,0);
	bar(16,110,165,yp);
	setcolor(1);
	rectangle(16,90,165,yp);
	line(116,90,116,yp);

	setcolor(9);
	setfillstyle(1,0);
	bar(170,110,414,yp);
	rectangle(170,90,414,yp);
	for (i=121;i<yp;i+=11) line(170,i,414,i);
	setcolor(14);
	settextstyle(2,0,4);
	outtxtxy(292,95,"ELEMENT");

	button(100,G_maxy-WINY-20,"OK",0,0);
	button(207,G_maxy-WINY-20,"REGULAR",0,0);
	button(492,G_maxy-WINY-20,"FILE",0,0);
	button(580,G_maxy-WINY-20,"VAR",0,0);

	prvbox(0,(fldvar **)G_varib.vars,G_varib.novar);
}
void prvbox(int pos,fldvar **fv,int noln) {
	int i,xp,yp,epos,spos,br;
	char tmp[15];
	xp=G_maxx-208;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*pos)/(noln+1));
	epos=((br*(pos+27))/(noln+1));
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
	settextjustify(0,2);
	outtxtxy(xp+25,95,"NAME");
	for (i=pos;i<min(pos+27,noln);i++) outtxtxy(xp+25,110+((i-pos)*11),fv[i]->name);
	settextjustify(1,2);
	outtxtxy(xp+130,95,"TYPE");
	outtxtxy(xp+168,95,"LENGTH");
	for (i=pos;i<min(pos+27,noln);i++) {
		tmp[1]=0;
		tmp[0]=fv[i]->type;
		outtxtxy(xp+130,110+((i-pos)*11),tmp);
		if (fv[i]->len==0) {
			outtxtxy(xp+168,110+((i-pos)*11),"VARIABLE");
		}
		else {
			outtxtxy(xp+168,110+((i-pos)*11),itoa(fv[i]->len,tmp,10));
		}
	}
	mousecur(1);
}
void okmbut(void) {
	button(100,G_maxy-WINY-20,"OK",1,1);
	while (((mousetrap(G_snapto)>>5)&7));
}
void addtomsgln(char type,char *txt) {
	union {
		char *c;
		int  *i;
	} u;
	int i;
	switch(type) {
		case 'L' : {
			sprintf(&G_msgln[G_msgp],"L%s^Z",txt);
			G_msgp+=strlen(&G_msgln[G_msgp])-1;
		} break;
		case 'V' : {
			G_msgln[G_msgp++]=type;
			u.c=txt;
			i=*u.i;
			u.c=&G_msgln[G_msgp];
			*u.i=G_varib.vars[i]->ofs;
			G_msgp+=sizeof(int);
		} break;
		case 'E' : {
			G_msgln[G_msgp++]=type;
			u.c=txt;
			i=*u.i;
			u.c=&G_msgln[G_msgp];
			*u.i=i;
			G_msgp+=sizeof(int);
			u.c=&txt[2];
			i=*u.i;
			u.c=&G_msgln[G_msgp];
			*u.i=i;
			G_msgp+=sizeof(int);
		} break;
	}
}
void addmsg(int item,char *curln,char *name) {
	int i,j,k;
	if (G_composite) {
		if ((i=findimsg(item))==(-1)) {
			G_nomsg++;
			G_msg=realloc(G_msg,G_nomsg*sizeof(msgs));
			G_msg[G_nomsg-1].m=item;
			strcpy(G_msg[G_nomsg-1].n,name);
			G_msg[G_nomsg-1].l=(-1);
			G_nocpm++;
			G_cpm=realloc(G_cpm,G_nocpm*sizeof(cflow));
			G_cpm[G_nocpm-1].mno=item;
			G_cpm[G_nocpm-1].noms=G_nocompo;
			G_cpm[G_nocpm-1].msgs=malloc(sizeof(int)*G_nocompo);
			for (j=0;j<G_nocompo;j++) {
				G_cpm[G_nocpm-1].msgs[j]=G_compo[j];
			}
		}
		else {
			G_msg[i].l=(-1);
			for (k=0;k<G_nocpm;k++) {
				if (G_cpm[k].mno==item) {
					G_cpm[k].noms=G_nocompo;
					G_cpm[k].msgs=realloc(G_cpm[k].msgs,sizeof(int)*G_nocompo);
					for (j=0;j<G_nocompo;j++) {
						G_cpm[k].msgs[j]=G_compo[j];
					}
					break;
				}
			}
			if (k==G_nocpm) {
				G_nocpm++;
				G_cpm=realloc(G_cpm,G_nocpm*sizeof(cflow));
				G_cpm[G_nocpm-1].mno=item;
				G_cpm[G_nocpm-1].noms=G_nocompo;
				G_cpm[G_nocpm-1].msgs=malloc(sizeof(int)*G_nocompo);
				for (j=0;j<G_nocompo;j++) {
					G_cpm[G_nocpm-1].msgs[j]=G_compo[j];
				}
			}
		}
	}
	else {
		if ((i=findimsg(item))!=(-1)) {
			G_msg[i].m=item;
			strcpy(G_msg[i].n,name);
			G_msg[i].l=psdlen(curln);
			G_msg[i].t=realloc(G_msg[i].t,G_msg[i].l+2);
			memcpy(G_msg[i].t,curln,G_msg[i].l);
		}
		else {
			G_nomsg++;
			G_msg=realloc(G_msg,G_nomsg*sizeof(msgs));
			G_msg[G_nomsg-1].m=item;
			strcpy(G_msg[G_nomsg-1].n,name);
			G_msg[G_nomsg-1].l=psdlen(curln);
			G_msg[G_nomsg-1].t=malloc(G_msg[G_nomsg-1].l+2);
			memcpy(G_msg[G_nomsg-1].t,curln,G_msg[G_nomsg-1].l);
		}
	}
}
void delmsg(int item) {
	int i,j,k;
	if ((i=findimsg(item))!=(-1)) {
		if (G_msg[i].l==(-1)) {
			for (k=0;k<G_nocpm;k++) {
				if (G_cpm[k].mno==item) {
					free(G_cpm[k].msgs);
					G_nocpm--;
					for (j=k;j<G_nocpm;j++)	memcpy(&G_cpm[j],&G_cpm[j+1],sizeof(cflow));
					G_cpm=realloc(G_cpm,G_nocpm*sizeof(cflow));
					break;
				}
			}
		}
		free(G_msg[i].t);
		G_nomsg--;
		for (j=i;j<G_nomsg;j++)	memcpy(&G_msg[j],&G_msg[j+1],sizeof(msgs));
		G_msg=realloc(G_msg,G_nomsg*sizeof(msgs));
	}
}
void prmsg(void) {
	int i;
	char *t;
	char tmp[400],k;
	mousecur(0);
	setfillstyle(1,1);
	strcpy(tmp,tpsdln(G_msgln));
	bar(1,40,638,60);
	if (strlen(tmp)>100) {
		k=tmp[104];
		tmp[104]=0;
		outtextxy(320,40,tmp);
		tmp[104]=k;
		outtextxy(320,50,&tmp[104]);
	}
	else {
		outtextxy(320,40,tmp);
	}
	i=0;
	t=psdtok(G_msgln);
	setfillstyle(1,0);
	while (t!=(char *)NULL) {
		bar(171,111+i*11,413,120+i*11);
		outtextxy(292,110+i*11,tpsdln(t));
		t=psdtok((char *)NULL);
		i++;
	}
	for (;i<27;i++) bar(171,111+i*11,413,120+i*11);
	mousecur(1);
}
int getmsg(int item) {
	int i,j,k;
	char *t;
	G_msgp=G_curln=G_composite=0;
	memset(G_msgln,0,400);
	if ((i=findimsg(item))!=(-1)) {
		if (G_msg[i].l==(-1)) {
			G_composite=1;
			for (j=0;j<G_nocpm;j++) {
				if (G_cpm[j].mno==item) {
					for (k=0;k<G_cpm[j].noms;k++) {
						G_compo[k]=G_cpm[j].msgs[k];
					}
					G_nocompo=G_cpm[j].noms;
					break;
				}
			}
		}
		else {
			G_composite=0;
			memcpy(G_msgln,G_msg[i].t,G_msg[i].l);
			G_msgp=psdlen(G_msg[i].t)-1;
			t=psdtok(G_msgln);
			while (t!=(char *)NULL) {
				G_curln++;
				t=psdtok((char *)NULL);
			}
			G_curln--;
			if (G_curln<0) G_curln=0;
		}
	}
	return(i);
}
int findmsg(char *name) {
	int j;
	for (j=0;j<G_nomsg;j++) if (!strcmp(G_msg[j].n,name)) return(j);
	return(-1);
}
int findimsg(int item) {
	int j;
	for (j=0;j<G_nomsg;j++) if (G_msg[j].m==item) return(j);
	return(-1);
}
void drcompo(void) {
	int i,yp;
	yp=((G_maxy-46-WINY)/11)*11;
	mousecur(0);
	setfillstyle(1,1);
	bar(172,(G_maxy-30)-WINY,242,(G_maxy-10)-WINY);
	button(207,G_maxy-WINY-20,"COMPOSIT",0,0);
	mousecur(0);
	setcolor(9);
	rectangle(16,90,165,yp);
	line(116,90,116,yp);
	for (i=121;i<yp;i+=11) line(16,i,165,i);
	setcolor(14);
	settextstyle(2,0,4);
	for (i=0;i<min(G_nocompo,26);i++) outtxtxy(66,i*11+110,G_msg[G_compo[i]].n);
	outtxtxy(66,95,"FLOW NAME");
	outtxtxy(140,95,"COMMENT");
	mousecur(1);
}
char *psdtok(char *text) {
	static int i,start,done=0; static char save,buf[500];
	if (done) { done=0; return((char *)NULL); }
	if (text!=(char *)NULL) { memcpy(buf,text,psdlen(text)); i=0; }
	else buf[i]=save;
	start=i;
	switch(buf[i]) {
		case 'C' : case 'F' : case 'V' : case 'O' :	i+=sizeof(int)+1; break;
		case 'E' :	i+=sizeof(int)*2+1;	break;
		case 'L' :	while (buf[++i]!='^'); i++; break;
		case 'Z' :	done=1; return(&buf[start]);
		default  :	done=1; return((char *)NULL);
	}
	save=buf[i]; buf[i]='Z'; return(&buf[start]);
}
void selcompo(int id) {
	int i;
	mousecur(0);
	if (G_compsel!=(-1)) {
		setfillstyle(1,0);
		bar(18,G_compsel*11+111,114,G_compsel*11+120);
		setcolor(14);
		outtextxy(66,G_compsel*11+110,G_msg[G_compo[G_compsel]].n);
		G_composite=0;
		i=G_msg[G_compo[G_compsel]].m;
		addmsg(i,G_msgln,G_msg[G_compo[G_compsel]].n);
		G_composite=1;
	}
	setfillstyle(1,11);
	bar(18,id*11+111,114,id*11+120);
	setcolor(1);
	outtextxy(66,id*11+110,G_msg[G_compo[id]].n);
	setcolor(14);
	mousecur(1);
	G_compsel=id;
	G_composite=0;
	getmsg(G_msg[G_compo[G_compsel]].m);
	prmsg();
	G_composite=1;
}
int incompbox(void) { return(inbox(17,WINY+110,115,WINY+308+110)); }
int infilebox(void) { return(inbox(492-25,G_maxy-30,492+25,G_maxy-10)); }
int invarbox(void)  { return(inbox(580-25,G_maxy-30,580+25,G_maxy-10)); }
int inmainbox(void) { return(inbox(170,WINY+G_curln*11+110,414,WINY+G_curln*11+121)); }
int inokbox(void)   { return(inbox(75,G_maxy-30,125,G_maxy-10)); }
int infvbox(void)   { return(inbox(449,110,G_maxx-17,406)); }
