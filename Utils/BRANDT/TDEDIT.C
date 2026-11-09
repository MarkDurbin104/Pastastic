#include <graphics.h>
#include <dos.h>
#include <conio.h>
#include <alloc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "tdef.h"


int tedit(int x,int y,int c,int l,int bcol,char *lns) {
	int i,noln,fcol,xit;
	int ch,cw,cp;
	char *t,**ln,*tmp,k;
	struct textsettingstype s;

	fcol=getcolor();
	gettextsettings(&s);
	settextjustify(s.horiz,2);
	tmp=malloc(strlen(lns)+1);
	strcpy(tmp,lns);
	ln=(char **)malloc(sizeof(char *));
	strcpy(tmp,lns);
	t=strtok(tmp,"\n");
	i=1;
	while (t!=(char *)NULL) {
		ln=realloc(ln,sizeof(char *)*i);
		ln[i-1]=malloc(strlen(t)+1);
		strcpy(ln[i-1],t);
		t=strtok((char *)NULL,"\n");
		i++;
	}
	free(tmp);
	noln=i-1;
	ch=textheight("8")+1;
	cw=textwidth("8");

	switch (s.horiz) {
		case 2  : {
			cp=x+(cw*c);
		} break;
		case 1  : {
			cp=x+((cw*c)/2);
		} break;
		default : {
			cp=x;
		}
	}
	disptext(x,y,c,l,ch,cw,cp,bcol,fcol,s.horiz,noln,ln);
	xit=0;
	G_sx=G_mx=G_sy=G_my=0;

	while (!xit) {
		mousetrap(G_snapto);
		if (inbox(x+WINX,y+WINY,x+(cw*c)+WINX+1,(y+(ch*l)+WINY)-1)) {
			if (mseb) {
				if ((G_sx!=0)||(G_sy!=0)||(G_mx!=0)||(G_my!=0)) {
					if (G_sy<=G_my) posibox(y,ch,cw,ln,s.horiz,cp,noln);
					else negibox(y,ch,cw,ln,s.horiz,cp);
				}
				G_mx=G_sx=x+((((msex-WINX)-x)/cw)*cw);
				G_my=G_sy=y+((((msey-WINY)-y)/ch)*ch);
				posibox(y,ch,cw,ln,s.horiz,cp,noln);
			}
			mousetrap(G_snapto);
			while (mseb) {
				if (mousestat(G_snapto)!=32) {
					if (G_sy<=G_my) posibox(y,ch,cw,ln,s.horiz,cp,noln);
					else negibox(y,ch,cw,ln,s.horiz,cp);
					mousetrap(G_snapto);
					G_mx=x+((((msex-WINX)-x)/cw)*cw);
					G_my=y+((((msey-WINY)-y)/ch)*ch);
					if (G_sy<=G_my) posibox(y,ch,cw,ln,s.horiz,cp,noln);
					else negibox(y,ch,cw,ln,s.horiz,cp);
				}
			}
		}
		if (kbhit()) {
			switch (k=getch()) {
				case 8 : {
					if (G_sy<=G_my) {
						if ((G_sx==G_mx)&&(G_sy==G_my)) {
							delchr(y,ch,ln,&noln);
						}
						else {
							pdeltext(y,ch,cw,ln,s.horiz,cp,&noln);
							G_mx=G_sx;
							G_my=G_sy;
						}
						disptext(x,y,c,l,ch,cw,cp,bcol,fcol,s.horiz,noln,ln);
					}
				} break;
				case 27 : {
					xit=1;
				} break;
				default : {
					if ((G_cpos!=(-1))&&((k>31)&&(k<127))) {
						pdeltext(y,ch,cw,ln,s.horiz,cp,&noln);
						inpchr(k,y,ch,ln,&noln);
						disptext(x,y,c,l,ch,cw,cp,bcol,fcol,s.horiz,noln,ln);
					}
				} break;
			}
		}
	}
	for (i=0;i<noln;i++) free(ln[i]);
	free(ln);
	return(1);
}
void disptext(int x,int y,int c,int l,int ch,int cw,int cp,int bcol,int fcol,int just,int noln,char **ln) {
	int i,j,m;
	char chr[2];
	chr[1]=0;
	setfillstyle(1,bcol);
	mousecur(0);
	bar(x,y,x+cw*c,y+ch*l+1);
	setcolor(fcol);
	m=0;
	for (i=0;i<noln;i++) {
		for(j=0;j<strlen(ln[i]);j++) {
			chr[0]=ln[i][j];
			switch (just) {
				case 2 : {
					outtxtxy(cp-((strlen(ln[i])+j)*cw),y+m*ch,chr);
				} break;
				case 1 : {
					outtxtxy((cp-(((strlen(ln[i])-1)*cw)/2))+(j*cw),y+m*ch,chr);
				} break;
				default : {
					outtxtxy(cp+(j*cw),y+m*ch,chr);
				}
			}
		}
/*		if (ln[i][0]!=0)*/ m++;
	}
	mousecur(1);
}
void posibox(int y,int ch,int cw,char **ln,int just,int cp,int l) {
	int i;
	int cx,cn;
	int stx,edx;
	mousecur(0);
	for (i=G_sy;i<=min(G_my,((l-1)*ch)+y);i+=ch) {
		switch (just) {
			case 2 : {
				cn=cp-(strlen(ln[(i-y)/ch])*cw);
				cx=cp;
			} break;
			case 1 : {
				cn=cp-((strlen(ln[(i-y)/ch])*cw)/2);
				cx=cp+((strlen(ln[(i-y)/ch])*cw)/2);
			} break;
			default : {
				cn=cp;
				cx=cp+(strlen(ln[(i-y)/ch])*cw);
			}
		}
		stx=max(G_sx,cn);
		edx=min(G_mx,cx);
		G_cpos=(stx-cn)/cw;
		if ((i==G_sy)&&(i==G_my)) {
			movto(0,stx,i+1);
			linto(0,edx,i+1);
			linto(0,edx,i+ch);
			linto(0,stx,i+ch);
			linto(0,stx,i+1);
		}
		else {
			if ((i==G_sy)&&(i!=G_my)) {
				movto(0,stx,i+1);
				linto(0,cx,i+1);
				linto(0,cx,i+ch);
				linto(0,stx,i+ch);
				linto(0,stx,i+1);
			}
			else {
				if ((i!=G_sy)&&(i==G_my)) {
					movto(0,cn,i+1);
					linto(0,edx,i+1);
					linto(0,edx,i+ch);
					linto(0,cn,i+ch);
					linto(0,cn,i+1);
				}
				else {
					movto(0,cn,i+1);
					linto(0,cx,i+1);
					linto(0,cx,i+ch);
					linto(0,cn,i+ch);
					linto(0,cn,i+1);
				}
			}
		}
	}
	mousecur(1);
}
void negibox(int y,int ch,int cw,char **ln,int just,int cp) {
	int i;
	int cx,cn;
	int stx,edx;
	mousecur(0);
	for (i=max(G_my,y);i<=G_sy;i+=ch) {
		switch (just) {
			case 2 : {
				cn=cp-(strlen(ln[(i-y)/ch])*cw);
				cx=cp;
			} break;
			case 1 : {
				cn=cp-((strlen(ln[(i-y)/ch])*cw)/2);
				cx=cp+((strlen(ln[(i-y)/ch])*cw)/2);
			} break;
			default : {
				cn=cp;
				cx=cp+(strlen(ln[(i-y)/ch])*cw);
			}
		}
		stx=max(G_mx,cn);
		edx=min(G_sx,cx);
		G_cpos=(stx-cn)/cw;
		if ((i==G_sy)&&(i==G_my)) {
			movto(0,stx,i+1);
			linto(0,edx,i+1);
			linto(0,edx,i+ch);
			linto(0,stx,i+ch);
			linto(0,stx,i+1);
		}
		else {
			if ((i!=G_sy)&&(i==G_my)) {
				movto(0,stx,i+1);
				linto(0,cx,i+1);
				linto(0,cx,i+ch);
				linto(0,stx,i+ch);
				linto(0,stx,i+1);
			}
			else {
				if ((i==G_sy)&&(i!=G_my)) {
					movto(0,cn,i+1);
					linto(0,edx,i+1);
					linto(0,edx,i+ch);
					linto(0,cn,i+ch);
					linto(0,cn,i+1);
				}
				else {
					movto(0,cn,i+1);
					linto(0,cx,i+1);
					linto(0,cx,i+ch);
					linto(0,cn,i+ch);
					linto(0,cn,i+1);
				}
			}
		}
	}
	mousecur(1);
}
/*void textelem(void) {
	int i,t,doit=1;
	int x,y,l,c;
	char tmp[20];
	if ((i=findelem())!=(-1)) {
		t=lev[G_nowlev].G_elem[i].type;
		switch (t) {
			case 1  :
			case 2  :
			case 3  : {
				x=(lev[G_nowlev].G_elem[i].xpos-G_wid[t]/2)+1;
				y=lev[G_nowlev].G_elem[i].ypos+25;
				l=5;
				c=18;
			} break;
			case 8  : {
				x=(lev[G_nowlev].G_elem[i].xpos-G_wid[t]/2)+10;
				y=lev[G_nowlev].G_elem[i].ypos+5;
				l=3;
				c=20;
			} break;
			case 9  : {
				x=lev[G_nowlev].G_elem[i].xpos-G_wid[t]/2;
				y=lev[G_nowlev].G_elem[i].ypos+10;
				l=5;
				c=20;
			} break;
			case 11 :
			case 12 :
			case 13 :
			case 14 : {
				x=lev[G_nowlev].G_elem[i].xpos-G_wid[t]/2;
				y=lev[G_nowlev].G_elem[i].ypos+7;
				l=5;
				c=20;
			} break;
			default : {
				doit=0;
			}
		}
		if (doit) tedit(x,y,c,l,0,lev[G_nowlev].G_elem[i].text);
	}
	else {
		if ((i=findtext())!=(-1)) {
			mousecur(0);
			drcont(0,G_xpos,G_ypos,&(lev[G_nowlev].G_cont[i]),0);
			mousecur(1);
			while (mseb) mousetrap(G_snapto);
			settextjustify(1,2);
			strcpy(tmp,lev[G_nowlev].G_cont[i].text);
			intextxy(lev[G_nowlev].G_cont[i].tpos.x,lev[G_nowlev].G_cont[i].tpos.y,tmp,14,0,lev[G_nowlev].G_cont[i].flags.TCOL);
			lev[G_nowlev].G_cont[i].text=realloc(lev[G_nowlev].G_cont[i].text,15);
			strcpy(lev[G_nowlev].G_cont[i].text,tmp);
			mousecur(0);
			drcont(1,G_xpos,G_ypos,&(lev[G_nowlev].G_cont[i]),1);
			mousecur(1);
		}
	}
}*/
int pdeltext(int y,int ch,int cw,char **ln,int just,int cp,int *l) {
	int i,j;
	int cx,cn,m;
	int stx,edx;
	char tmp[100];
	mousecur(0);
	for (i=G_sy;i<=min(G_my,((*l-1)*ch)+y);i+=ch) {
		switch (just) {
			case 2 : {
				cn=cp-(strlen(ln[(i-y)/ch])*cw);
				cx=cp;
			} break;
			case 1 : {
				cn=cp-((strlen(ln[(i-y)/ch])*cw)/2);
				cx=cp+((strlen(ln[(i-y)/ch])*cw)/2);
			} break;
			default : {
				cn=cp;
				cx=cp+(strlen(ln[(i-y)/ch])*cw);
			}
		}
		stx=((max(G_sx,cn))-cn)/cw;
		edx=((min(G_mx,cx))-cn)/cw;
		cx=(cx-cn)/cw;
		cn=0;
		if ((i==G_sy)&&(i==G_my)) {
			m=0;
			for (j=0;j<stx;j++) tmp[m++]=ln[(i-y)/ch][j];
			for (j=edx;j<cx;j++) tmp[m++]=ln[(i-y)/ch][j];
			tmp[m++]=0;
			ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
			strcpy(ln[(i-y)/ch],tmp);
		}
		else {
			if ((i==G_sy)&&(i!=G_my)) {
				m=0;
				for (j=0;j<stx;j++) tmp[m++]=ln[(i-y)/ch][j];
				tmp[m++]=0;
				ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
				strcpy(ln[(i-y)/ch],tmp);
			}
			else {
				if ((i!=G_sy)&&(i==G_my)) {
					m=0;
					for (j=edx;j<cx;j++) tmp[m++]=ln[(i-y)/ch][j];
					tmp[m++]=0;
					ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
					strcpy(ln[(i-y)/ch],tmp);
				}
				else {
					ln[(i-y)/ch]=realloc(ln[(i-y)/ch],1);
					ln[(i-y)/ch][0]=0;
				}
			}
		}
	}
	mousecur(1);
	return(stx);
}
void ndeltext(int y,int ch,int cw,char **ln,int just,int cp) {
	int i,j;
	int cx,cn,m;
	int stx,edx;
	char tmp[100];
	mousecur(0);
	for (i=max(G_my,0);i<=G_sy;i+=ch) {
		switch (just) {
			case 2 : {
				cn=cp-(strlen(ln[(i-y)/ch])*cw);
				cx=cp;
			} break;
			case 1 : {
				cn=cp-((strlen(ln[(i-y)/ch])*cw)/2);
				cx=cp+((strlen(ln[(i-y)/ch])*cw)/2);
			} break;
			default : {
				cn=cp;
				cx=cp+(strlen(ln[(i-y)/ch])*cw);
			}
		}
		stx=((max(G_sx,cn))-cn)/cw;
		edx=((min(G_mx,cx))-cn)/cw;
		cx=(cx-cn)/cw;
		cn=0;
		if ((i==G_sy)&&(i==G_my)) {
			m=0;
			for (j=0;j<stx;j++) tmp[m++]=ln[(i-y)/ch][j];
			for (j=edx;j<cx;j++) tmp[m++]=ln[(i-y)/ch][j];
			tmp[m++]=0;
			ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
			strcpy(ln[(i-y)/ch],tmp);
		}
		else {
			if ((i==G_sy)&&(i!=G_my)) {
				m=0;
				for (j=0;j<stx;j++) tmp[m++]=ln[(i-y)/ch][j];
				tmp[m++]=0;
				ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
				strcpy(ln[(i-y)/ch],tmp);
			}
			else {
				if ((i!=G_sy)&&(i==G_my)) {
					m=0;
					for (j=edx;j<cx;j++) tmp[m++]=ln[(i-y)/ch][j];
					tmp[m++]=0;
					ln[(i-y)/ch]=realloc(ln[(i-y)/ch],m);
					strcpy(ln[(i-y)/ch],tmp);
				}
				else {
					ln[(i-y)/ch]=realloc(ln[(i-y)/ch],1);
					ln[(i-y)/ch][0]=0;
				}
			}
		}
	}
	mousecur(1);
}
void inpchr(char k,int y,int ch,char **ln,int *noln) {
	int str;
	char tmp[100];
	str=*noln+1;
	str=(G_sy-y)/ch;
	strncpy(tmp,ln[str],G_cpos);
	tmp[G_cpos]=k;
	strcpy(&tmp[G_cpos+1],&ln[str][G_cpos]);
	ln[str]=realloc(ln[str],strlen(tmp)+1);
	strcpy(ln[str],tmp);
	G_cpos++;
}
void delchr(int y,int ch,char **ln,int *noln) {
	int str,i;
	char tmp[200];
	str=(G_sy-y)/ch;
	if (G_cpos>0) {
		strncpy(tmp,ln[str],G_cpos-1);
		strcpy(&tmp[G_cpos-1],&ln[str][G_cpos]);
		ln[str]=realloc(ln[str],strlen(tmp)+1);
		strcpy(ln[str],tmp);
		G_cpos--;
	}
	else {
		if (str>0) {
			G_cpos=strlen(ln[str-1]);
			ln[str-1]=realloc(ln[str-1],strlen(ln[str])+strlen(ln[str-1])+1);
			strcat(ln[str-1],ln[str]);
			free(ln[str]);
			for (i=str+1;i<*noln;i++) ln[i-1]=ln[i];
			*noln--;
/*			ln=realloc(ln,(*noln)*sizeof(char**));*/
			G_my=G_sy-=ch;
		}
	}
	for(i=0;i<*noln;i++) printf("*%s*\n",ln[i]);
}
void textelem(void) {
	int c,l,i,j,x,y,doit=1,t;
	char tmp[5][22],tmp1[200],*s;
	union {
		char *c;
		int  *i;
	} u;
	if ((i=findelem())!=(-1)) {
		switch (lev[G_nowlev].G_elem[i].type) {
			case 1  :
			case 2  :
			case 3  : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+25;
				c=5;
				l=18;
			} break;
			case 8  : {
				x=lev[G_nowlev].G_elem[i].xpos+10;
				y=lev[G_nowlev].G_elem[i].ypos+5;
				c=1;
				l=10;
			} break;
			case 9  : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+10;
				c=5;
				l=17;
			} break;
			case 11  : {
				l=0;
				if (lev[G_nowlev].G_elem[i].text[0]=='C') {
					u.c=&lev[G_nowlev].G_elem[i].text[1];
					if ((*u.i==0)||(*u.i==1)) l=*u.i+1;
				}
				if (!l) {
					while (mseb) mousetrap(G_snapto);
					x=lev[G_nowlev].G_elem[i].xpos;
					y=lev[G_nowlev].G_elem[i].ypos;
					for (j=0;j<G_noseqs;j++) {
						if (lev[G_nowlev].G_elem[i].ident==G_seqs[j].seq) {
							strcpy(tmp1,&G_seqs[j].name[1]);
							tmp1[strlen(tmp1)-2]=0;
							break;
						}
					}
					if (j==G_noseqs) {
						strcpy(tmp1,"DEF_ERR_SEQ");
					}
					if (intextxy(x+G_xpos+23,y+G_ypos+49,tmp1,14,0,lev[G_nowlev].G_elem[i].colour>>4)==4) {
						lev[G_nowlev].G_elem[i].level=0;
						lev[G_nowlev].G_elem[i].ident=lev[G_nowlev].G_elem[i].level;
					}
					else {
						sprintf(tmp[0],"L%s^Z",tmp1);
						for (j=0;j<G_noseqs;j++) {
							if (!strncmp(tmp[0],G_seqs[j].name,strlen(tmp[0]))) {
								lev[G_nowlev].G_elem[i].ident=G_seqs[j].seq;
								lev[G_nowlev].G_elem[i].level=G_seqs[j].seq;
								break;
							}
						}
						if (j==G_noseqs) {
							lev[G_nowlev].G_elem[i].level=addlev();
							lev[G_nowlev].G_elem[i].ident=lev[G_nowlev].G_elem[i].level;
							addseq(tmp[0],lev[G_nowlev].G_elem[i].level);
						}
					}
					mousecur(0);
					clearviewport();
					redraw(1);
					mousecur(1);
				}
				doit=0;
			} break;
			case 14  : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+7;
				c=1;
				l=14;
			} break;
			case 15 : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+20;
				c=3;
				l=17;
			} break;
			case 16 : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+20;
				c=3;
				l=18;
			} break;
			case 17 :
			case 18 : {
				x=lev[G_nowlev].G_elem[i].xpos;
				y=lev[G_nowlev].G_elem[i].ypos+5;
				c=1;
				l=12;
			} break;
			default : {
				doit=0;
			}
		}
		if (doit) {
			settextjustify(1,2);
			t=2;
			j=0;
			strcpy(tmp1,lev[G_nowlev].G_elem[i].text);
			if (lev[G_nowlev].G_elem[i].type==14) {
				strcpy(tmp[0],tpsdln(tmp1));
			}
			else {
				for (j=0;j<5;j++) tmp[j][0]=0;
				s=strtok(tmp1,"\n");
				while (s!=(char *)NULL) {
					strcpy(tmp[j],s);
					s=strtok((char *)NULL,"\n");
				}
			}
			j=0;
			while (mseb) mousetrap(1);
			while ((t==2)&&(j<c)) {
				t=intextxy(x+G_xpos,y+G_ypos+(j*10),tmp[j],l,0,lev[G_nowlev].G_elem[i].colour>>4);
				j++;
			}
			tmp1[0]=0;
			if (lev[G_nowlev].G_elem[i].type==14) {
				strcpy(tmp1,"L");
				strcat(tmp1,tmp[0]);
				strcat(tmp1,"^Z");
			}
			else {
				for (t=0;t<j;t++) {
					strcat(tmp1,tmp[t]);
					strcat(tmp1,"\n");
				}
			}
			lev[G_nowlev].G_elem[i].text=realloc(lev[G_nowlev].G_elem[i].text,strlen(tmp1)+1);
			strcpy(lev[G_nowlev].G_elem[i].text,tmp1);
			mousecur(0);
			clearviewport();
			redraw(1);
			mousecur(1);
		}
	}
	else {
		if ((i=findtext())!=(-1)) {
			mousecur(0);
			drcont(0,G_xpos,G_ypos,&(lev[G_nowlev].G_cont[i]),0);
			mousecur(1);
			while (mseb) mousetrap(G_snapto);
			settextjustify(1,2);
			strcpy(tmp1,lev[G_nowlev].G_cont[i].text);
			intextxy(lev[G_nowlev].G_cont[i].tpos.x+G_xpos,lev[G_nowlev].G_cont[i].tpos.y+G_ypos,tmp1,14,0,lev[G_nowlev].G_cont[i].flags.TCOL);
			lev[G_nowlev].G_cont[i].text=realloc(lev[G_nowlev].G_cont[i].text,15);
			strcpy(lev[G_nowlev].G_cont[i].text,tmp1);
			mousecur(0);
			drcont(1,G_xpos,G_ypos,&(lev[G_nowlev].G_cont[i]),1);
			mousecur(1);
		}
	}
}
