#include <conio.h>
#include <ctype.h>
#include <dos.h>
#include <alloc.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
char	G_statcol=0x0C;
char	G_headcol=0x0F;
char	G_textcol=0x0E;
char	G_tabstop=4;
char	**G_tbuf;
int		G_noln;
int		G_cln;
int		G_ccl;
int	far	*G_scr=MK_FP(0xB800,0x0000);
int		G_x;
int		G_sx;
int		G_y;
int		G_modified;
int		G_insover;
int		G_modl;
char	G_modln[260];
char	G_getbuf[260];
int		G_ssave[2000];
int		G_malln;

void	loadfile(char *file);
void	savefile(char *file);
void	cleartbuf(void);
void	prscr(void);
void	prln(int lnno);
int		strpos(int i,char *st);
int		scrpos(int i,char *st);
void	bkspace(void);
void	cup(void);
void	cdown(void);
void	cleft(void);
void	cright(void);
void	cc_left(void);
void	cc_right(void);
void	chome(void);
void	cend(void);
void	cpgup(void);
void	cpgdn(void);
void	cc_pgup(void);
void	cc_pgdn(void);
void	cinst(void);
void	undo(void);
void	modyln(void);
void	beeper(int tp);
void	insln(void);
void	delln(void);
void	head(char *file);
void	sys(char *sysln);
void	runsystem(void);
void putbuf(void);
void getbuf(void);

main(int argc,char **argv) {
	int xit=0,i,s;
	char k,tmp[260];
	struct text_info t;
	if (argc<2) {
		printf("filename ?\n");
		exit(-1);
	}
	gettextinfo(&t);
	G_malln=G_noln=G_cln=G_sx=G_x=G_y=G_ccl=G_modified=0;
	G_modl=(-1);
	for (i=0;i<2000;i++) G_ssave[i]=*(G_scr+i);
	head(argv[1]);
	cinst();
	G_tbuf=malloc(sizeof(char *));
	loadfile(argv[1]);
	textattr(G_textcol);
	prscr();
	while (!xit) {
		switch(k=getch()) {
			case 0 : {
				switch(k=getch()) {
					case ';' : 	sprintf(tmp,"tcc %s",argv[1]); sys(tmp);
								head(argv[1]);			break;
					case 'H' : cup();					break;
					case 'P' : cdown();					break;
					case 'K' : cleft();					break;
					case 'M' : cright();				break;
					case 's' : cc_left();				break;
					case 't' : cc_right();				break;
					case 'G' : chome();					break;
					case 'O' : cend();					break;
					case 'I' : cpgup();					break;
					case 'Q' : cpgdn();					break;
					case '' : cc_pgup();				break;
					case 'v' : cc_pgdn();				break;
					case '-' : xit=1;					break; /* ALT-X */
					case 'R' : cinst();					break;
					case 'S' : cright(); bkspace(); 	break;
					default  : beeper(8000);
				}
			} break;
			case 8   : bkspace();						break;
			case '' : cleartbuf();	loadfile(argv[1]);	break;
			case '' : cleartbuf();						break;
			case '' : getbuf();						break;
			case '' : putbuf();						break;
			case '' : savefile(argv[1]);				break;
			case '' : runsystem();	head(argv[1]);		break;
			case '' : undo();							break;
			case '' : delln();							break;
			case 13  : insln();							break;
			default : {
				if (((k&0x7F)<32)&&(k!=9)) {
					beeper(8000);
					break;
				}
				modyln();
				if (strlen(G_tbuf[G_cln+G_y])<=G_sx) {
					G_tbuf[G_cln+G_y]=realloc(G_tbuf[G_cln+G_y],G_sx+2);
					for (i=strlen(G_tbuf[G_cln+G_y]);i<=G_sx;i++) G_tbuf[G_cln+G_y][i]=32;
					G_tbuf[G_cln+G_y][i]=0;
				}
				if (G_insover) {
					G_tbuf[G_cln+G_y]=realloc(G_tbuf[G_cln+G_y],strlen(G_tbuf[G_cln+G_y])+2);
					strcpy(tmp,&G_tbuf[G_cln+G_y][G_sx]);
					strcpy(&G_tbuf[G_cln+G_y][G_sx+1],tmp);
				}
				G_tbuf[G_cln+G_y][G_sx]=k;
				if (++G_sx>255) G_sx=255;
				s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
				if ((s-G_ccl)>78) {
					G_x=78;
					G_ccl=s-78;
				}
				else {
					G_x=s-G_ccl;
				}
			}
		}
		prscr();
	}
	for (i=0;i<2000;i++) *(G_scr+i)=G_ssave[i];
	textattr(t.attribute);
	gotoxy(t.curx,t.cury);
	return(1);
}
void loadfile(char *file) {
	FILE *fp;
	char tmp[256];
	textattr(G_statcol);
	gotoxy(1,25);
	cprintf("LOADING \"%s\"",file);
	if ((fp=fopen(file,"r"))!=NULL) {
		while (fgets(tmp,255,fp)!=NULL) {
			G_noln++;
			if (G_noln>=G_malln) {
				G_malln+=50;
				G_tbuf=realloc(G_tbuf,sizeof(char *)*G_malln);
			}
			tmp[strlen(tmp)-1]=0;
			G_tbuf[G_noln-1]=malloc(strlen(tmp)+2);
			strcpy(G_tbuf[G_noln-1],tmp);
		}
	}
	fclose(fp);
	gotoxy(1,25);
	cprintf("        \"%s\"",file);
	textattr(G_textcol);
	G_modified=0;
}
void savefile(char *file) {
	int i;
	FILE *fp;
	if (G_modified) {
		textattr(G_statcol);
		gotoxy(1,25);
		cprintf("SAVEING \"%s\"",file);
		if ((fp=fopen(file,"w"))!=NULL) {
			for (i=0;i<G_noln;i++) {
				fprintf(fp,"%s\n",G_tbuf[i]);
			}
		}
		fclose(fp);
		gotoxy(1,25);
		cprintf("        \"%s\"",file);
		textattr(G_textcol);
	}
	G_modified=0;
}
void cleartbuf(void) {
	int i;
	G_modified=1;
	for (i=0;i<G_noln;i++) {
		free(G_tbuf[i]);
	}
	G_tbuf=realloc(G_tbuf,sizeof(char *));
	G_noln=0;
	cc_pgup();
}
void prscr(void) {
	int i;
	for (i=0;i<22;i++) prln(i);
	gotoxy(G_x+2,G_y+2);
}
void prln(int lnno) {
	int s,j,k,l;
	char c;
	struct text_info t;
	gettextinfo(&t);
	if (lnno<G_noln-G_cln) {
		s=strlen(G_tbuf[lnno+G_cln])-G_ccl;
		j=k=0;
		while(k<78) {
			if (j<s) {
				c=G_tbuf[lnno+G_cln][j+G_ccl];
				switch(c) {
					case 10 : {
					} break;
					case 9 : {
						for (l=k;l<((k/G_tabstop+1)*G_tabstop);l++) {
							*(G_scr+lnno*80+l+81)=t.attribute<<8;
						}
						k=l;
					} break;
					default : {
						if ((c<32)&&(c>0)) {
							*(G_scr+lnno*80+k+81)=((t.attribute^2)<<8)|(c+'@');
						}
						else {
							*(G_scr+lnno*80+k+81)=(t.attribute<<8)+c;
						}
						k++;
					}
				}
			}
			else {
				*(G_scr+lnno*80+k+81)=t.attribute<<8;
				k++;
			}
			j++;
		}
	}
	else {
		for (k=0;k<78;k++) *(G_scr+lnno*80+k+81)=t.attribute<<8;
	}
}
int strpos(int i,char *st) {
	int j=0,k=0;
	while (j<i) {
		if (k>=strlen(st)) {
			j++;
		}
		else {
			if (st[k]==9) j=(j/G_tabstop+1)*G_tabstop; else j++;
		}
		k++;
	}
	return(k);
}
int scrpos(int i,char *st) {
	int j=0,k=0;
	while (k<i) {
		if (k>=strlen(st)) {
			j++;
		}
		else {
			if (st[k]==9) j=(j/G_tabstop+1)*G_tabstop; else j++;
		}
		k++;
	}
	return(j);
}
void bkspace(void) {
	char tmp[260];
	modyln();
	if (strlen(G_tbuf[G_cln+G_y])>=G_sx) {
		if (G_sx>0) {
			strcpy(tmp,&G_tbuf[G_cln+G_y][G_sx]);
			strcpy(&G_tbuf[G_cln+G_y][G_sx-1],tmp);
		}
	}
	cleft();
}
void cc_left(void) {
	int s;
	s=G_sx;
	while (isalnum(G_tbuf[G_cln+G_y][s])) s--;
	while (!isalnum(G_tbuf[G_cln+G_y][s])) s--;
	G_sx=s;
	if (G_sx<0) G_sx=0;
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)<0) {
		G_x=0;
		G_ccl=s;
	}
	else {
		G_x=s-G_ccl;
	}
}
void cleft(void) {
	int s;
	if (--G_sx<0) G_sx=0;
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)<0) {
		G_x=0;
		G_ccl=s;
	}
	else {
		G_x=s-G_ccl;
	}
}
void cright(void) {
	int s;
	if (++G_sx>255) G_sx=255;
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)>78) {
		G_x=78;
		G_ccl=s-78;
	}
	else {
		G_x=s-G_ccl;
	}
}
void cc_right(void) {
	int s;
	s=G_sx;
	while (isalnum(G_tbuf[G_cln+G_y][s])) s++;
	while (!isalnum(G_tbuf[G_cln+G_y][s])) s++;
	G_sx=s-1;
	if (++G_sx>255) G_sx=255;
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)>78) {
		G_x=78;
		G_ccl=s-78;
	}
	else {
		G_x=s-G_ccl;
	}
}
void cup(void) {
	int s;
	G_y--;
	if (G_y<1) {
		G_y=0;
		G_cln--;
		if (G_cln<0) G_cln=0;
	}
	G_sx=strpos(G_x+G_ccl,G_tbuf[G_y+G_cln]);
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)<0) {
		G_x=0;
		G_ccl=s;
	}
	else {
		G_x=s-G_ccl;
	}
}
void cdown(void) {
	int s;
	G_y++;
	if (G_y>21) {
		G_y=21;
		G_cln++;
		if (G_cln>G_noln-22) G_cln=G_noln-22;
		if (G_cln<0) G_cln=0;
	}
	if (G_y>=G_noln) G_y=G_noln-1;
	G_sx=strpos(G_x+G_ccl,G_tbuf[G_y+G_cln]);
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if ((s-G_ccl)<0) {
		G_x=0;
		G_ccl=s;
	}
	else {
		G_x=s-G_ccl;
	}
}
void chome(void) {
	G_x=0;
	G_sx=0;
	G_ccl=0;
}
void cend(void) {
	int s;
	G_sx=strlen(G_tbuf[G_y+G_cln]);
	s=scrpos(G_sx,G_tbuf[G_y+G_cln]);
	if (s<G_ccl) {
		G_ccl=s;
		G_x=0;
	}
	else {
		if ((s-G_ccl)>78) {
			G_ccl=s-78;
			G_x=strpos(strlen(&G_tbuf[G_y+G_cln][G_ccl]),&G_tbuf[G_y+G_cln][G_ccl]);
		}
		else {
			G_x=s-G_ccl;
		}
	}
}
void cpgup(void) {
	G_cln-=21;
	if (G_cln<0) cc_pgup();
}
void cpgdn(void) {
	G_cln+=21;
	if (G_cln>G_noln-22) cc_pgdn();
}
void cc_pgup(void) {
	G_cln=0;
	G_y=0;
	chome();
}
void cc_pgdn(void) {
	G_cln=G_noln-22;
	G_y=21;
	if (G_cln<0) {
		G_cln=0;
		G_y=G_noln-1;
	}
	cend();
}
void cinst(void) {
	unsigned char far *ks=MK_FP(0x0000,0x0417);
	G_insover=(*ks>>7);
	textattr(G_statcol);
	gotoxy(25,25);
	if (G_insover) cprintf(" INSERT "); else cprintf("OVERTYPE");
	textattr(G_textcol);
}
void modyln(void) {
	G_modified=1;
	if (G_modl!=G_cln+G_y) {
		G_modl=G_cln+G_y;
		strcpy(G_modln,G_tbuf[G_modl]);
	}
}
void undo(void) {
	char tmp[260];
	if (G_modl==(-1)) return;
	strcpy(tmp,G_tbuf[G_modl]);
	G_tbuf[G_modl]=realloc(G_tbuf[G_modl],strlen(G_tbuf[G_modl])+2);
	strcpy(G_tbuf[G_modl],G_modln);
	strcpy(G_modln,tmp);
	if (G_modl<G_cln) {
		G_cln=G_modl;
		G_y=0;
		return;
	}
	if (G_modl>G_cln+21) {
		G_cln=G_modl-21;
		G_y=21;
		return;
	}
	G_y=G_modl-G_cln;
}
void beeper(int tp) {
	int i,j;
	for (j=0;j<20;j++) {
		nosound();
		sound(tp);
		for (i=0;i<1000;i++);
	}
	for (i=0;i<20000;i++);
	for (i=0;i<20000;i++);
	for (j=0;j<40;j++) {
		sound(tp);
		for (i=0;i<1000;i++);
		nosound();
		for (i=0;i<j;i++);
	}
}
void insln(void) {
	G_modified=1;
	G_noln++;
	G_tbuf=realloc(G_tbuf,sizeof(char *)*G_noln);
	memmove(&G_tbuf[G_y+G_cln+2],&G_tbuf[G_y+G_cln+1],sizeof(char *)*(G_noln-G_y+G_cln+1));
	G_tbuf[G_y+G_cln+1]=malloc(1);
	G_tbuf[G_y+G_cln+1][0]=0;
	cdown();
}
void delln(void) {
	G_modified=1;
	free(G_tbuf[G_cln+G_y]);
	memcpy(&G_tbuf[G_y+G_cln],&G_tbuf[G_y+G_cln+1],sizeof(char *)*(G_noln-G_y+G_cln));
	G_noln--;
}
void head(char *file) {
	int i;
	textattr(G_headcol);
	clrscr();
	for (i=0;i<80;i++) *(G_scr+24*80+i)=(G_statcol<<8);
	gotoxy(1,1);
	cprintf("ษอออออออออออออออออTDEDITOR (c) P.M.A. Computer Consultants 1990ออออออออออออออออป");
	for (i=2;i<24;i++) {
		gotoxy(1,i);
		cprintf("บ                                                                              บ");
	}
	gotoxy(1,24);
		cprintf("ศอออออออออออออออออTDEDITOR (c) P.M.A. Computer Consultants 1990ออออออออออออออออผ");
	textattr(G_statcol);
	gotoxy(25,25);
	if (G_insover) cprintf(" INSERT "); else cprintf("OVERTYPE");
	textattr(G_statcol);
	gotoxy(1,25);
	cprintf("        \"%s\"",file);
	textattr(G_textcol);
}
void runsystem(void) {
	textattr(G_headcol);
	gotoxy(1,25);
	cprintf("                                                                            ");
	gotoxy(1,25);
	cprintf("COMMAND[%s] Press Enter",G_tbuf[G_cln+G_y]);
	if (getch()==13) sys(G_tbuf[G_cln+G_y]);
}
void sys(char *sysln) {
	clrscr();
	cprintf("%s",sysln);
	system(sysln);
	textattr(G_statcol);
	cprintf("PRESS ANY KEY");
	getch();
}
void getbuf(void) {
	strcpy(G_getbuf,G_tbuf[G_cln+G_y]);
}
void putbuf(void) {
	insln();
	G_tbuf[G_cln+G_y]=realloc(G_tbuf[G_cln+G_y],strlen(G_getbuf)+2);
	strcpy(G_tbuf[G_cln+G_y],G_getbuf);
}

