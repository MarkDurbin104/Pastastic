#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <alloc.h>
#include <fcntl.h>
#include <io.h>
#include <stdlib.h>
#include <graphics.h>
#include <dos.h>
#include "tdef.h"

int					G_dictpos;
level				G_cutbuf;
int					G_nocutelem;
int					G_nocutcont;
int					scrs[2000];
int					*scr=MK_FP(0xB800,0x0000);
struct text_info	te;

void deldict(void);
void startdict(void);
void modyfldinfo(char *from,int len,char type,char *name,char *desc);

int opendict(void) {
	char tmp[80];
	sprintf(tmp,"%s.%s",G_cellname,DICT_EXT);
	G_dictfd=open(tmp,O_RDWR|O_CREAT|O_BINARY,0777);
	if (G_dictfd==(-1)) return(0);
	return(1);
}
void closedict(void) {
	close(G_dictfd);
}
int getdict(char *name) {
	int a,norec;
	dict *d,*r;
	d=malloc(100*sizeof(dict));
	a=1;
	lseek(G_dictfd,0L,SEEK_SET);
	while (a>0) {
		a=read(G_dictfd,d,sizeof(dict)*100);
		if (a>0) {
			norec=a/sizeof(dict);
			r=lfind(name,d,(size_t *)&norec,sizeof(dict),strcmp);
			if (r!=(void *)NULL) {
				memcpy(&G_dictent,r,sizeof(dict));
				free(d);
				return(1);
			}
		}
	}
	free(d);
	return(0);
}
void putdict(void) {
	int fd,a,don,b;
	dict d;
	char filenam[50],*t,tmp[80];
	don=0;
	if (G_dongin) G_dongin=QD();
	if (!G_dongin) return;
	strcpy(filenam,".\\");
	fd=creattemp(filenam,0);
	close(fd);
	fd=open(filenam,O_WRONLY|O_TRUNC|O_CREAT|O_BINARY,0777);
	if (fd!=(-1)) {
		lseek(G_dictfd,0L,SEEK_SET);
		while((a=read(G_dictfd,&d,sizeof(dict)))>0) {
			if (!don) {
				if ((b=strcmp(d.name,G_dictent.name))==0) {
					write(fd,&G_dictent,sizeof(dict));
					don=1;
				}
				else {
					if (b>0) {
						write(fd,&G_dictent,sizeof(dict));
						write(fd,&d,sizeof(dict));
						don=1;
					}
					else {
						write(fd,&d,sizeof(dict));
					}
				}
			}
			else {
				write(fd,&d,sizeof(dict));
			}
		}
		if (!don) write(fd,&G_dictent,sizeof(dict));
		close(fd);
		fd=open(filenam,O_RDONLY|O_BINARY);
		if (fd!=(-1)) {
			closedict();
			sprintf(tmp,"%s.%s",G_cellname,DICT_EXT);
			unlink(tmp);
			t=malloc(16384);
			if (t!=(void *)NULL) {
				opendict();
				a=1;
				while ((a=read(fd,t,16384))>0) {
					write(G_dictfd,t,a);
				}
				close(fd);
				unlink(filenam);
				free(t);
			}
			else {
				opendict();
				a=1;
				while ((a=read(fd,tmp,80))>0) {
					write(G_dictfd,tmp,a);
				}
				close(fd);
				unlink(filenam);
			}
		}
	}
}
void deldict(void) {
	int fd,a,don;
	dict d;
	char filenam[50],*t,tmp[80];
	don=0;
	if (G_dongin) G_dongin=QD();
	if (!G_dongin) return;
	strcpy(filenam,".\\");
	fd=creattemp(filenam,0);
	close(fd);
	fd=open(filenam,O_WRONLY|O_TRUNC|O_CREAT|O_BINARY,0777);
	if (fd!=(-1)) {
		lseek(G_dictfd,0L,SEEK_SET);
		while((a=read(G_dictfd,&d,sizeof(dict)))>0) {
			if (!don) {
				if (strcmp(d.name,G_dictent.name)==0) {
					don=1;
				}
				else {
					write(fd,&d,sizeof(dict));
				}
			}
			else {
				write(fd,&d,sizeof(dict));
			}
		}
		close(fd);
		fd=open(filenam,O_RDONLY|O_BINARY);
		if (fd!=(-1)) {
			closedict();
			sprintf(tmp,"%s.%s",G_cellname,DICT_EXT);
			unlink(tmp);
			t=malloc(16384);
			if (t!=(void *)NULL) {
				opendict();
				a=1;
				while ((a=read(fd,t,16384))>0) {
					write(G_dictfd,t,a);
				}
				close(fd);
				unlink(filenam);
				free(t);
			}
			else {
				opendict();
				a=1;
				while ((a=read(fd,tmp,80))>0) {
					write(G_dictfd,tmp,a);
				}
				close(fd);
				unlink(filenam);
			}
		}
	}
}
int retdict(int pos) {
	lseek(G_dictfd,(long)(pos*sizeof(dict)),SEEK_SET);
	if ((read(G_dictfd,&G_dictent,sizeof(dict)))>0) return(1); else return(0);
}
int firstdict(void) {
	lseek(G_dictfd,0L,SEEK_SET);
	if ((read(G_dictfd,&G_dictent,sizeof(dict)))>0) return(1); else return(0);
}
int lastdict(void) {
	lseek(G_dictfd,(long)(sizeof(dict)*(-1)),SEEK_END);
	if ((read(G_dictfd,&G_dictent,sizeof(dict)))>0) return(1); else return(0);
}
int nextdict(void) {
	if ((read(G_dictfd,&G_dictent,sizeof(dict)))>0) return(1); else return(0);
}
int prevdict(void) {
	lseek(G_dictfd,(long)(sizeof(dict)*(-2)),SEEK_CUR);
	if ((read(G_dictfd,&G_dictent,sizeof(dict)))>0) return(1); else return(0);
}
int dictsize(void) {
	int b;
	b=(int)(filelength(G_dictfd)/(long)sizeof(dict));
	if (b<1) return(1);
	return(b);
}

void markfordel(void) {
	int i,j;
	if (G_lsel!=(-1)) {
		for (i=0;i<G_nocont[G_nowlev];i++) {
			if (lev[G_nowlev].G_cont[i].deled!=0) lev[G_nowlev].G_cont[i].deled++;
			if (lev[G_nowlev].G_cont[i].deled==50) delcont(i--);
		}
		lev[G_nowlev].G_cont[G_lsel].deled=1;
		lev[G_nowlev].G_cont[G_lsel].flags.LCOL^=1;
		G_lsel=(-1);
		mousecur(0);
		clearviewport();
		redraw(1);
		mousecur(1);
	}
	else {
		if (G_noselc!=0) {
			for (i=0;i<G_noelem[G_nowlev];i++) {
				if (lev[G_nowlev].G_elem[i].deled!=0) lev[G_nowlev].G_elem[i].deled++;
				if (lev[G_nowlev].G_elem[i].deled==50) delelem(i--);
			}
			for (i=0;i<G_nocont[G_nowlev];i++) {
				if (lev[G_nowlev].G_cont[i].deled!=0) lev[G_nowlev].G_cont[i].deled++;
				if (lev[G_nowlev].G_cont[i].deled==50) delcont(i--);
			}
			for (i=0;i<G_noselc;i++) {
				lev[G_nowlev].G_elem[G_selected[i]].deled=1;
				lev[G_nowlev].G_elem[G_selected[i]].colour^=0x11;
				for (j=0;j<G_nocont[G_nowlev];j++) {
					if ((lev[G_nowlev].G_cont[j].from==G_selected[i])
					||	(lev[G_nowlev].G_cont[j].to==G_selected[i])) {
						if (lev[G_nowlev].G_cont[j].deled==0) lev[G_nowlev].G_cont[j].deled=1;
					}
				}
			}
			G_noselc=0;
			mousecur(0);
			clearviewport();
			redraw(1);
			mousecur(1);
		}
		else {
			sound(1000);
			for (i=0;i<8000;i++);
			nosound();
		}
	}
}
void cutit(void) {
	int i,j,k,lx=32766,ly=32766,ok;
	G_nocutelem=G_noselc;
	G_cutbuf.G_elem=(shape *)realloc(G_cutbuf.G_elem,sizeof(shape)*G_noselc);
	G_nocutcont=0;
	if (G_noselc!=0) {
		for (i=0;i<G_noselc;i++) {
			memcpy(&(G_cutbuf.G_elem[i]),&(lev[G_nowlev].G_elem[G_selected[i]]),sizeof(shape));
			G_cutbuf.G_elem[i].ident=G_selected[i];
			for (j=0;j<G_nocont[G_nowlev];j++) {
				ok=0;
				if (lev[G_nowlev].G_cont[j].from==G_selected[i]) {
					for (k=0;k<G_noselc;k++) {
						if (lev[G_nowlev].G_cont[j].to==G_selected[k]) ok=1;
					}
				}
				if (lev[G_nowlev].G_cont[j].to==G_selected[i]) {
					for (k=0;k<G_noselc;k++) {
						if (lev[G_nowlev].G_cont[j].from==G_selected[k]) ok=1;
					}
				}
				if (ok) {
					if (lev[G_nowlev].G_cont[j].deled==0) {
						G_nocutcont++;
						G_cutbuf.G_cont=(join *)realloc(G_cutbuf.G_cont,sizeof(join)*G_nocutcont);
						memcpy(&(G_cutbuf.G_cont[G_nocutcont-1]),&(lev[G_nowlev].G_cont[j]),sizeof(join));
					}
				}
			}
		}
		for (i=0;i<G_nocutelem;i++) {
			lx=min(G_cutbuf.G_elem[i].xpos,lx);
			ly=min(G_cutbuf.G_elem[i].ypos,ly);
		}
		for (i=0;i<G_nocutcont;i++) {
			lx=min(G_cutbuf.G_cont[i].pos.x,lx);
			ly=min(G_cutbuf.G_cont[i].pos.y,ly);
			lx=min(G_cutbuf.G_cont[i].tpos.x,lx);
			ly=min(G_cutbuf.G_cont[i].tpos.y,ly);
			for (j=0;j<G_cutbuf.G_cont[i].flags.NOPNT;j++) {
				if (G_cutbuf.G_cont[i].flags.DIR==1) {
					if (j&1) ly=min(G_cutbuf.G_cont[i].points[j],ly);
					else lx=min(G_cutbuf.G_cont[i].points[j],lx);
				}
				else {
					if (j&1) lx=min(G_cutbuf.G_cont[i].points[j],lx);
					else ly=min(G_cutbuf.G_cont[i].points[j],ly);
				}
			}
		}
		for (i=0;i<G_nocutelem;i++) {
			G_cutbuf.G_elem[i].xpos-=lx;
			G_cutbuf.G_elem[i].ypos-=ly;
		}
		for (i=0;i<G_nocutcont;i++) {
			G_cutbuf.G_cont[i].pos.x-=lx;
			G_cutbuf.G_cont[i].pos.y-=ly;
			G_cutbuf.G_cont[i].tpos.x-=lx;
			G_cutbuf.G_cont[i].tpos.y-=ly;
			for (j=0;j<G_cutbuf.G_cont[i].flags.NOPNT;j++) {
				if (G_cutbuf.G_cont[i].flags.DIR==1) {
					if (j&1) G_cutbuf.G_cont[i].points[j]-=ly;
					else G_cutbuf.G_cont[i].points[j]-=lx;
				}
				else {
					if (j&1) G_cutbuf.G_cont[i].points[j]-=lx;
					else G_cutbuf.G_cont[i].points[j]-=ly;
				}
			}
		}
		for (i=0;i<G_nocutelem;i++) {
			for (j=0;j<G_nocutcont;j++) {
				if (G_cutbuf.G_cont[j].from==G_cutbuf.G_elem[i].ident) G_cutbuf.G_cont[j].from=(-1)-i;
				if (G_cutbuf.G_cont[j].to  ==G_cutbuf.G_elem[i].ident) G_cutbuf.G_cont[j].to  =(-1)-i;
			}
		}
	}
	else {
		sound(1000);
		for (i=0;i<8000;i++);
		nosound();
	}
}
void paste(void) {
	int i,j;
	if (G_nocutelem) {
		for (i=0;i<G_nocutelem;i++) {
			addelem();
			memcpy(&(lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1]),&(G_cutbuf.G_elem[i]),sizeof(shape));
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].xpos+=(msex-WINX)+(0-G_xpos);
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].ypos+=(msey-WINY)+(0-G_ypos);
			lev[G_nowlev].G_elem[G_noelem[G_nowlev]-1].ident=G_ident-1;
		}
		for (i=0;i<G_nocutcont;i++) {
			addcont(&(G_cutbuf.G_cont[i]));
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].pos.x+=(msex-WINX)+(0-G_xpos);
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].pos.y+=(msey-WINY)+(0-G_ypos);
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].tpos.x+=(msex-WINX)+(0-G_xpos);
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].tpos.y+=(msey-WINY)+(0-G_ypos);
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].from+=G_nocont[G_nowlev];
			lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].to  +=G_nocont[G_nowlev];
			for (j=0;j<lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].flags.NOPNT;j++) {
				if (lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].flags.DIR==1) {
					if (j&1) lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].points[j]+=(msey-WINY)+(0-G_ypos);
					else lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].points[j]+=(msex-WINX)+(0-G_xpos);
				}
				else {
					if (j&1) lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].points[j]+=(msex-WINX)+(0-G_xpos);
					else lev[G_nowlev].G_cont[G_nocont[G_nowlev]-1].points[j]+=(msey-WINY)+(0-G_ypos);
				}
			}
		}
		mousecur(0);
		redraw(1);
		mousecur(1);
	}
	else {
		sound(1000);
		for (i=0;i<8000;i++);
		nosound();
	}
}
int saveit(void) {
	char k;
	closegraph();
	clrscr();
	printf("Save Y/N ? ");
	if (((k=getch())=='y')||(k=='Y')) savediag(G_cellname);
	return(0);
}
void startup(void) {
	char filename[15];
	sprintf(filename,"%s.tmp",G_cellname);
	close(open(filename,O_RDWR|O_CREAT|O_TRUNC|O_BINARY,0777));
	G_dongin=QD();
	setupfldvar();
	G_inform=0;
	G_sGinc=G_iGinc=G_dGinc=G_fGinc=G_lGinc=100;
	G_sLinc=G_iLinc=G_dLinc=G_fLinc=G_lLinc=0;
	G_sinc=G_iinc=G_dinc=G_finc=G_linc=10;
	memset(G_vn,0,1000*sizeof(int));
	G_lused=(char *)malloc(NOLEV*sizeof(char));
	if (G_lused==(char *)NULL) exit(-1);
	G_noelem=(int *)malloc(NOLEV*sizeof(int));
	if (G_noelem==(int *)NULL) exit(-1);
	G_nocont=(int *)malloc(NOLEV*sizeof(int));
	if (G_nocont==(int *)NULL) exit(-1);
	G_nowelem=(int *)malloc(NOLEV*sizeof(int));
	if (G_nowelem==(int *)NULL) exit(-1);
	G_nowcont=(int *)malloc(NOLEV*sizeof(int));
	if (G_nowcont==(int *)NULL) exit(-1);
	lev=(level *)malloc(NOLEV*sizeof(level));
	if (lev==(level *)NULL) exit(-1);
	G_lused[0]=0;
	G_noelem[0]=G_nocont[0]=0;
	G_nowelem[0]=G_nowcont[0]=1;
	setlevelto(0);
	G_nolev=1;
	G_snapto=5;
	lev[0].modified=(-1);
	lev[0].old=0;
	lev[0].ofs=(-1L);
	lev[0].inout=0;
	lev[0].x=0;
	lev[0].y=0;
	G_ubuf[0].elem=malloc(1);
	G_ubuf[0].cont=malloc(1);
	G_ubuf[0].ne=G_ubuf[0].nc=0;
	lev[0].G_elem=(shape *)malloc(sizeof(shape));
	if (lev[0].G_elem==(shape *)NULL) pnxit("Cant Get Room For Elements",-1);
	lev[0].G_cont=(join *)malloc(sizeof(join));
	if (lev[0].G_cont==(join *)NULL) pnxit("Cant Get Room For Connections",-1);
	G_cutbuf.G_elem=(shape *)malloc(1);
	G_cutbuf.G_cont=(join *)malloc(1);
	G_seqs=(seqs *)malloc(sizeof(seqs));
	if (G_seqs==(seqs *)NULL) pnxit("Cant Get Room For Sequence Names",-1);
	G_noseqs=0;
	G_tcol=14;
	G_lcol=11;
	G_ident=10;
	G_sident=1;
	G_msg=malloc(sizeof(msgs));
	G_nomsg=0;
	G_lit=malloc(sizeof(lits));
	G_nolit=0;
	G_cpm=malloc(sizeof(cflow));
	G_nocpm=0;
	G_utl=malloc(sizeof(char *));
	G_noutl=0;
	ctrlbrk(saveit);
/*	system("tdstart");*/
	G_noselc=G_elemt=0;
	G_xpos=G_ypos=0;
	memcpy(scrs,scr,4000);
	gettextinfo(&te);
	grafix();
	if (!setupmouse(0,0,0,G_maxx,0,G_maxy)) pnxit("No Mouse Available !",-1);
	setmcurto(0);
	cls();
	markpoints();
	loaddiag(G_cellname);
	if (G_varib.novar<25) {
		addvar("SPACE"          ,'C' ,1);
		addvar("NULL"           ,'C' ,1);
		addvar("PROCESS_ID"     ,'i' ,2);
		addvar("MES_SENDER"     ,'i' ,2);
		addvar("MES_PART[]"     ,'C' ,0);
		addvar("LOCKED"         ,'i' ,2);
		addvar("END_OF_FILE"    ,'i' ,2);
		addvar("PASSED[]"       ,'V' ,0);
		addvar("RETURNED[]"     ,'V' ,0);
		addvar("DEF_ERROR_SEQ"  ,'i' ,2);
		addvar("SYS_EXIT_CODE"  ,'i' ,2);
		addvar("TIME"           ,'C' ,17);
		addvar("LAST_OP_STR"    ,'C' ,0);
		addvar("LAST_DAT_STR"   ,'i' ,2);
		addvar("LAST_OP_INT"    ,'i' ,2);
		addvar("FORM_NUMBER[]"  ,'i' ,2);
		addvar("FORM_ERR_STR"   ,'C' ,0);
		addvar("FORM_VAR[]"     ,'C' ,0);
		addvar("FORM_RET"       ,'i' ,0);
		addvar("CURRENT_F_VAR"  ,'C' ,0);
		addvar("HOT_KEY_1_SEQ"  ,'i' ,2);
		addvar("HOT_KEY_2_SEQ"  ,'i' ,2);
		addvar("HOT_KEY_3_SEQ"  ,'i' ,2);
		addvar("HOT_KEY_4_SEQ"  ,'i' ,2);
		addvar("HOT_KEY_5_SEQ"  ,'i' ,2);
		addvar("NO_MSG_LINES"   ,'i' ,2);
	}
	loadfiledat();
	redraw(1);
}
void pnxit(char *s,int code) {
	closegraph();
	printf("%s\n",s);
	exit(code);
}
int addvar(char *name,char type,int len) {
	int i;
	G_varib.novar++;
	G_varib.vars=realloc(G_varib.vars,sizeof(fldvar *)*G_varib.novar);
	G_varib.vars[G_varib.novar-1]=malloc(sizeof(fldvar));
	strcpy(G_varib.vars[G_varib.novar-1]->name,name);
	G_varib.vars[G_varib.novar-1]->type=type;
	G_varib.vars[G_varib.novar-1]->len=len;
	G_varib.vars[G_varib.novar-1]->ofs=G_varib.novar-1;
	if (G_varib.novar<27) {
		G_varib.vars[G_varib.novar-1]->no=0;
	}
	else {
		switch(type) {
			case 'C' : {
				switch(name[0]) {
					case 'G' : {
						G_varib.vars[G_varib.novar-1]->no=G_sGinc++;
					} break;
					case 'L' : {
						G_varib.vars[G_varib.novar-1]->no=G_sLinc++;
					} break;
					default : {
						G_varib.vars[G_varib.novar-1]->no=G_sinc++;
					}
				}
			} break;
			case 'i' : {
				switch(name[0]) {
					case 'G' : {
						G_varib.vars[G_varib.novar-1]->no=G_iGinc++;
					} break;
					case 'L' : {
						G_varib.vars[G_varib.novar-1]->no=G_iLinc++;
					} break;
					default : {
						G_varib.vars[G_varib.novar-1]->no=G_iinc++;
					}
				}
			} break;
			case 'l' : {
				switch(name[0]) {
					case 'G' : {
						G_varib.vars[G_varib.novar-1]->no=G_lGinc++;
					} break;
					case 'L' : {
						G_varib.vars[G_varib.novar-1]->no=G_lLinc++;
					} break;
					default : {
						G_varib.vars[G_varib.novar-1]->no=G_linc++;
					}
				}
			} break;
			case 'f' : {
				switch(name[0]) {
					case 'G' : {
						G_varib.vars[G_varib.novar-1]->no=G_fGinc++;
					} break;
					case 'L' : {
						G_varib.vars[G_varib.novar-1]->no=G_fLinc++;
					} break;
					default : {
						G_varib.vars[G_varib.novar-1]->no=G_finc++;
					}
				}
			} break;
			case 'd' : {
				switch(name[0]) {
					case 'G' : {
						G_varib.vars[G_varib.novar-1]->no=G_dGinc++;
					} break;
					case 'L' : {
						G_varib.vars[G_varib.novar-1]->no=G_dLinc++;
					} break;
					default : {
						G_varib.vars[G_varib.novar-1]->no=G_dinc++;
					}
				}
			} break;
			default : {
				G_varib.vars[G_varib.novar-1]->no=(-1);
			}
		}
	}
	qsort(G_varib.vars,G_varib.novar,sizeof(fldvar *),varcmp);
	for (i=0;i<G_varib.novar;i++) {
		if (G_varib.vars[i]->ofs==G_varib.novar-1) return(i);
	}
	return(-1);
}
int varcmp(char **a,char **b) {
	return(strcmp(*a,*b));
}
int seqcmp(seqs *a,seqs *b) {
	return(strcmp(a->name,b->name));
}
int addseq(char *name,int seqno) {
	int i;
	G_noseqs++;
	G_seqs=realloc(G_seqs,sizeof(seqs)*G_noseqs);
	G_seqs[G_noseqs-1].name=malloc(strlen(name)+1);
	strcpy(G_seqs[G_noseqs-1].name,name);
	G_seqs[G_noseqs-1].seq=seqno;
	qsort(G_seqs,G_noseqs,sizeof(seqs),seqcmp);
	for (i=0;i<G_noseqs;i++) {
		if (G_seqs[i].seq==seqno) return(i);
	}
	return(-1);
}
void shutdown(void) {
	char filename[15];
	sprintf(filename,"%s.tmp",G_cellname);
	unlink(filename);
	closegraph();
	clrscr();
	memcpy(scr,scrs,4000);
	textattr(te.attribute);
	gotoxy(te.curx,te.cury);
}
void drdict(int pos) {
	int i,xp,yp,epos,spos,br;
	char tmp[16];
	xp=50;
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
	line(xp+192,90,xp+192,yp);
	line(xp+144,90,xp+144,yp);
	line(xp+116,90,xp+116,yp);
	setcolor(14);
	settextstyle(2,0,4);
	outtxtxy(xp+66,95,"FIELD NAME");
	outtxtxy(xp+130,95,"TYPE");
	outtxtxy(xp+168,95,"LENGTH");
	outtxtxy(xp+383,95,"DICTONARY");
	retdict(pos);
	for (i=0;i<27;i++) {
		outtxtxy(xp+66,110+(i*11),G_dictent.name);
		tmp[1]=0;
		tmp[0]=G_dictent.type;
		outtxtxy(xp+130,110+(i*11),tmp);
		outtxtxy(xp+168,110+(i*11),itoa(G_dictent.len,tmp,10));
		outtxtxy(xp+383,110+(i*11),G_dictent.desc);
		if (!nextdict()) break;
	}
	mousecur(1);
}
void fetchdict(void) {
	int xp,yp,epos,spos,br,i;
	char tmp[41];
	xp=50;
	yp=((G_maxy-46-WINY)/11)*11;
	br=yp-132;
	spos=((br*G_dictpos)/dictsize());
	epos=((br*(G_dictpos+27))/dictsize());
	if (((epos+121)<(yp-11))||(spos!=0)) {
		if (inbox(xp+6,WINY+110,xp+16,WINY+120)) {
			G_dictpos-=5;
			if (G_dictpos<0) G_dictpos=0;
			drdict(G_dictpos);
		}
		if (inbox(xp+6,WINY+(yp-10),xp+16,WINY+yp)) {
			G_dictpos+=5;
			if (G_dictpos>(dictsize()-27)) G_dictpos=dictsize()-27;
			drdict(G_dictpos);
		}
		if (inbox(xp+6,WINY+121,xp+16,WINY+(121+spos))) {
			G_dictpos-=26;
			if (G_dictpos<0) G_dictpos=0;
			drdict(G_dictpos);
		}
		if (inbox(xp+6,WINY+(121+epos),xp+16,WINY+(yp-11))) {
			G_dictpos+=26;
			if (G_dictpos>(dictsize()-27)) G_dictpos=dictsize()-27;
			drdict(G_dictpos);
		}
	}
	if (inbox(xp+17,WINY+110,G_maxx-17,WINY+yp)) {
		i=((msey-110)-WINY)/11;
		retdict(G_dictpos+i);
		if (inbox(xp+17,WINY+110,xp+115,WINY+yp)) {
			strcpy(tmp,G_dictent.name);
			if (intextxy(xp+66,110+i*11,tmp,14,0,14)==4) {
				deldict();
				drdict(G_dictpos);
			}
			else {
				if (strcmp(tmp,G_dictent.name)) {
					deldict();
					modyfldinfo(G_dictent.name,G_dictent.len,G_dictent.type,tmp,G_dictent.desc);
					strcpy(G_dictent.name,tmp);
					putdict();
					drdict(G_dictpos);
				}
			}
		}
		if (inbox(xp+117,WINY+110,xp+143,WINY+yp)) {
			tmp[0]=G_dictent.type;
			tmp[1]=0;
			if (intextxy(xp+130,110+i*11,tmp,1,0,14)==4) {
				deldict();
			}
			else {
				if (tmp[0]!=G_dictent.type) {
					G_dictent.type=tmp[0];
					switch(tmp[0]) {
						case 'C' :
						case 'c' : {
							deldict();
							modyfldinfo(G_dictent.name,G_dictent.len,tmp[0],G_dictent.name,G_dictent.desc);
							G_dictent.type='C';
							putdict();
						} break;
						case 'I' :
						case 'i' : {
							deldict();
							modyfldinfo(G_dictent.name,G_dictent.len,tmp[0],G_dictent.name,G_dictent.desc);
							G_dictent.type='i';
							putdict();
						} break;
						case 'L' :
						case 'l' : {
							deldict();
							modyfldinfo(G_dictent.name,G_dictent.len,tmp[0],G_dictent.name,G_dictent.desc);
							G_dictent.type='l';
							putdict();
						} break;
						case 'F' :
						case 'f' : {
							deldict();
							modyfldinfo(G_dictent.name,G_dictent.len,tmp[0],G_dictent.name,G_dictent.desc);
							G_dictent.type='f';
							putdict();
						} break;
						case 'D' :
						case 'd' : {
							deldict();
							modyfldinfo(G_dictent.name,G_dictent.len,tmp[0],G_dictent.name,G_dictent.desc);
							G_dictent.type='d';
							putdict();
						} break;
					}
				}
			}
		}
		if (inbox(xp+145,WINY+110,xp+191,WINY+yp)) {
			strcpy(tmp,itoa(G_dictent.len,tmp,10));
			if (intextxy(xp+168,110+i*11,tmp,5,0,14)==4) {
				deldict();
			}
			else {
				if (atoi(tmp)!=G_dictent.len) {
					deldict();
					modyfldinfo(G_dictent.name,atoi(tmp),G_dictent.type,G_dictent.name,G_dictent.desc);
					G_dictent.len=atoi(tmp);
					putdict();
				}
			}
		}
		if (inbox(xp+193,WINY+110,G_maxx-17,WINY+yp)) {
			strcpy(tmp,G_dictent.desc);
			if (intextxy(xp+383,110+i*11,tmp,40,0,14)==4) {
				deldict();
			}
			else {
				if (strcmp(tmp,G_dictent.desc)) {
					deldict();
					modyfldinfo(G_dictent.name,G_dictent.len,G_dictent.type,G_dictent.name,tmp);
					strcpy(G_dictent.desc,tmp);
					putdict();
				}
			}
		}
		while (mseb) mousetrap(G_snapto);
	}
}
void eddict(void) {
	int xit=0;
	G_dictpos=0;
	opendict();
	startdict();
	while (!xit) {
		if (mousetrap(1)>>5) {
			fetchdict();
			if (inbox(225,G_maxy-30,275,G_maxy-10)) {
				mousecur(0);
				button(250,G_maxy-WINY-20,"OK",1,1);
				mousecur(1);
				while (((mousetrap(G_snapto)>>5)&7));
				xit=1;
			}
		}
		if (kbhit()) {
			getch();
			xit=1;
		}
	}
	closedict();
}
void startdict(void) {
	char tmp[100];
	mousecur(0);
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
	sprintf(tmp,"PMA CDL    DATA DICTONARY EDITOR    CELL %s.",G_cellname);
	outtxtxy(G_maxx/2,2,tmp);
	button(250,G_maxy-WINY-20,"OK",0,0);
	drdict(G_dictpos);
}
void modyfldinfo(char *from,int len,char type,char *name,char *desc) {
	int i,j,k,l;
	file *b;
	for (i=0;i<G_file.nofiles;i++) {
		for (j=0;j<G_file.cont[i]->nofld;j++) {
			if (!strcmp(G_file.cont[i]->flds[j]->name,from)) {
				b=loadfile(G_cellname,i+1);
				if (b->name[0]==0) {
					free(b);
				}
				else {
/*					printf("Found in S%d F%d %s %s\n",i,j,b->flds[j]->name,G_file.cont[i]->flds[j]->name);*/
					strcpy(b->flds[j]->name,name);
					b->flds[j]->len=len;
					b->flds[j]->type=type;
					strcpy(b->flds[j]->desc,desc);
					savefile(G_cellname,b);
					for (k=0;k<b->nofld;k++) {
						free(b->flds[k]);
					}
					free(b->flds);
					for (k=0;k<b->nokey;k++) {
						for(l=0;l<b->keys[k]->noparts;l++) {
							free(b->keys[k]->keypts[l]);
						}
						free(b->keys[k]->keypts);
						free(b->keys[k]);
					}
					free(b->keys);
					free(b);
				}
				break;
			}
		}
	}
	loadfiledat();
}
