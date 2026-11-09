#include <graphics.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include "tdef.h"

void cdlln(char *text,int type,int item) {
	int i,j,k,start,xit,vcnt=0,b/*,l*/;
	static int hadanif=0;
	FILE *fp;
	char tmp[200],*t,a,tmp1[50];
	char typ[5];
	union {
		char *c;
		int  *i;
	} u;
	if (type==0) {
		fp=fopen("opt.prn","a+");
		fprintf(fp,"\n SEQUENCE \"%s\"\n",tpsdln(text));
		fclose(fp);
	}
	else {
		if ((G_now!=0)&&(G_crntlev[G_now]==lev[G_nowlev].G_elem[type].ypos)) {
			sepoutut(G_utl[lev[G_nowlev].G_elem[G_crntrep[G_now]].ident]);
			fp=fopen("opt.prn","a+");
			fprintf(fp,"s%-5d UT .     .     .     .  .      .      .      .        UNTIL\n",G_nowlev);
			fclose(fp);
			G_now--;
		}
		if (lev[G_nowlev].G_elem[type].type==12) {
			if (!strcmp(tpsdln(text),"FALSE")) hadanif=3;
		}
		if (lev[G_nowlev].G_elem[type].type==13) {
			fp=fopen("opt.prn","a+");
			fprintf(fp,"s%-5d RT .     .     .     .  .      .      .      .        REPEAT\n",G_nowlev);
			fclose(fp);
			G_crntrep[G_now]=type;
			G_crntlev[++G_now]=lev[G_nowlev].G_elem[type].ypos;
		}
		if (lev[G_nowlev].G_elem[type].type==14) {
			for (i=0;i<G_noseqs;i++) {
				sprintf(tmp,"L%s^Z",tpsdln(text));
				if (!(strcmp(tmp,G_seqs[i].name))) {
					fp=fopen("opt.prn","a+");
					switch (hadanif) {
						case 0 : {
							fprintf(fp,"s%-5d CA .     .     %-5d .  .      .      .      .       ",G_nowlev,G_seqs[i].seq);
						} break;
						case 3 : {
							fprintf(fp,"s%-5d EL .     .     %-5d .  .      .      .      .        ELSE",G_nowlev,G_seqs[i].seq);
						} break;
					}
					if (hadanif==2) {
						fprintf(fp," GOTO \"%s\"\n",tpsdln(text));
					}
					else {
						fprintf(fp," CALL \"%s\"\n",tpsdln(text));
					}
					hadanif=0;
					fclose(fp);
					break;
				}
			}
			if (i==G_noseqs) {
				fp=fopen("opt.prn","a+");
				if (hadanif==2) {
					fprintf(fp," GOTO \"NO SEQUENCE\"\n");
				}
				else {
					fprintf(fp," CALL \"NO SEQUENCE\"\n");
				}
				hadanif=0;
				fclose(fp);
			}
		}
		if (lev[G_nowlev].G_elem[type].type==11) {
			cdl.cmd=33;
			cdl.fil=0;
			cdl.key=0;
			cdl.seq=0;
			strcpy(cdl.oper," ");
			for (i=0;i<4;i++) {
				cdl.vc[i]=' ';
				cdl.vi[i]=0;
			}
			tmp[0]=0;
			i=0;
			xit=0;
			while (!xit) {
				switch(text[i]) {
					case 'C' : {
						i++;
						u.c=&text[i];
						cdl.cmd=*u.i;
						i+=sizeof(int);
					} break;
					case 'L' : {
						i++;
						j=0;
						t=&text[i];
						while (*(t++)!='^') {
							tmp[j++]=text[i++];
						}
						tmp[j++]=0;
						i++;
						if ((cdl.cmd==15)&&(vcnt==1)) {
							cdl.key=atoi(&tmp[3]);
							cdl.vc[vcnt]='M';
							typ[vcnt]='M';
							cdl.vi[vcnt++]=0;
						}
						else {
							for (j=0;j<G_nolit;j++) {
								switch (G_lit[j].t) {
									case 'l' : {
										sprintf(tmp1,"%ld",*((long *)G_lit[j].v));
									} break;
									case 'i' : {
										sprintf(tmp1,"%i",*((int *)G_lit[j].v));
									} break;
									case 'f' : {
										sprintf(tmp1,"%f",*((float *)G_lit[j].v));
									} break;
									case 'd' : {
										sprintf(tmp1,"%f",*((double *)G_lit[j].v));
									} break;
									case 'C' : {
										sprintf(tmp1,"\"%s\"",(char *)G_lit[j].v);
									} break;
								}
								if (!strcmp(tmp1,tmp)) {
									cdl.vc[vcnt]='L';
									typ[vcnt]=G_lit[j].t;
									cdl.vi[vcnt++]=j;
									break;
								}
							}
							if (j==G_nolit) {
								cdl.vc[vcnt]='?';
								typ[vcnt]='B';
								cdl.vi[vcnt++]=0;
							}
						}
					} break;
					case 'O' : {
						i++;
						u.c=&text[i];
						strcpy(cdl.oper,operator[*u.i]);
						i+=sizeof(int);
					} break;
					case 'F' : {
						i++;
						u.c=&text[i];
						cdl.fil=*u.i+1;
						i+=sizeof(int);
					} break;
					case 'E' : {
						i++;
						u.c=&text[i];
						cdl.fil=*u.i+1;
						j=*u.i;
						i+=sizeof(int);
						u.c=&text[i];
						cdl.vc[vcnt]='F';
						typ[vcnt]=G_file.cont[cdl.fil]->flds[*u.i]->type;
						cdl.vi[vcnt++]=*u.i;
						i+=sizeof(int);
					} break;
					case 'V' : {
						i++;
						u.c=&text[i];
						if ((cdl.cmd==15)&&(vcnt<1)) {
							if (vcnt==0) {
								cdl.vc[vcnt]='M';
								typ[vcnt]='M';
								cdl.vi[vcnt++]=*u.i;
							}
						}
						else {
							for (j=0;j<G_varib.novar;j++) {
								if (G_varib.vars[j]->ofs==*u.i) {
									if (j>=26) {
										if (G_varib.vars[j]->type=='C') {
											cdl.vc[vcnt]='s';
										}
										else {
											cdl.vc[vcnt]=G_varib.vars[j]->type;
										}
										typ[vcnt]=G_varib.vars[j]->type;
										cdl.vi[vcnt++]=G_varib.vars[j]->no;
									}
									else {
										if (j==4 || j==6 || j==16 || j==20 || j==22) {
											cdl.vc[vcnt]=G_const[G_varib.vars[j]->ofs][0];
											typ[vcnt]=G_varib.vars[j]->type;
											cdl.vi[vcnt++]=atoi(&text[i+sizeof(int)+1]);
											i+=sizeof(int);
											while(text[i++]!='^');
											i-=sizeof(int);
										}
										else {
											cdl.vc[vcnt]='';
											typ[vcnt]=G_varib.vars[j]->type;
											cdl.vi[vcnt++]=G_varib.vars[j]->ofs;
										}
									}
									break;
								}
							}
							if (j==G_varib.novar) {
								cdl.vc[vcnt]='?';
								typ[vcnt]='L';
								cdl.vi[vcnt++]=0;
							}
						}
						i+=sizeof(int);
					} break;
					case 'Z' : {
						xit=1;
					} break;
					default : {
						xit=1;
					}
				}
				strcat(tmp," ");
			}
			cdl.seq=lev[G_nowlev].G_elem[type].ident;
			if (cdl.seq==(-1)) {
				for (i=0;i<G_noseqs;i++) {
					if (!strncmp(G_seqs[i].name,"LDEF_ERR_SEQ^Z",14)) {
						cdl.seq=G_seqs[i].seq;
						break;
					}
				}
			}
			if ((cdl.cmd==0)||(cdl.cmd==1)) {
				for (i=item;i<G_noelem[G_nowlev];i++) {
					if (!(strcmp(tpsdln(lev[G_nowlev].G_elem[G_tab[i].i].text),"TRUE"))) {
						sprintf(tmp,"L%s^Z",tpsdln(lev[G_nowlev].G_elem[G_tab[i+1].i].text));
						for (j=0;j<G_noseqs;j++) {
							if (!(strcmp(tmp,G_seqs[j].name))) {
								cdl.seq=G_seqs[j].seq;
								hadanif=cdl.cmd+1;
								break;
							}
						}
					}
					if (hadanif) break;
				}
				hadanif=cdl.cmd+1;
			}
			if (cdl.cmd==2) {
				start=0;
				for (k=item;k<G_noelem[G_nowlev];k++) {
					if (lev[G_nowlev].G_elem[G_tab[k].i].type==14) {
						if (lev[G_nowlev].G_elem[G_tab[k].i].level<0) {
							for (i=0;i<G_noseqs;i++) {
								if (!strcmp(lev[G_nowlev].G_elem[G_tab[k].i].text,G_seqs[i].name)) {
									lev[G_nowlev].G_elem[G_tab[k].i].level=G_seqs[i].seq;
									break;
								}
							}
							if (i!=G_noseqs) {
								if ((start=findifRorW(lev[G_nowlev].G_elem[G_tab[k].i].level,cdl.fil))==1) break;
							}
						}
						else {
							if ((start=findifRorW(lev[G_nowlev].G_elem[G_tab[k].i].level,cdl.fil))==1) break;
						}
					}
					else {
						if (lev[G_nowlev].G_elem[G_tab[k].i].text[0]=='C') {
							u.c=&lev[G_nowlev].G_elem[G_tab[k].i].text[4];
							if (*u.i==cdl.fil-1) {
								u.c=&lev[G_nowlev].G_elem[G_tab[k].i].text[1];
								if ((*u.i>11)&&(*u.i<15)) {
									start=1;
									break;
								}
								if (*u.i==3) break;
							}
						}
					}
				}
				if (start) {
					cdl.cmd=35;
				}
			}
			if (cdl.cmd==26) {
				cdl.cmd=7;
				cdl.key=atoi(tmp);
				if (cdl.oper[0]==' ') strcpy(cdl.oper,"=");
				cdl.vc[0]=' ';
				cdl.vi[0]='0';
			}
			if (cdl.cmd==27) {
				cdl.cmd=40;
			}
			if (cdl.cmd==33) {
				a=cdl.vc[0];
				b=cdl.vi[0];
				cdl.vc[0]=cdl.vc[1];
				cdl.vi[0]=cdl.vi[1];
				cdl.vc[1]=a;
				cdl.vi[1]=b;
				if ((cdl.oper[0]!=' ')&&(cdl.oper[0]!='=')) {
					cdl.cmd++;
					a=cdl.vc[1];
					b=cdl.vi[1];
					cdl.vc[1]=cdl.vc[2];
					cdl.vi[1]=cdl.vi[2];
					cdl.vc[2]=a;
					cdl.vi[2]=b;
				}
				else {
					if ((typ[0]=='C')&&(typ[1]=='i')) {
						cdl.cmd=37;
					}
					if ((typ[0]=='i')&&(typ[1]=='C')) {
						cdl.cmd=36;
					}
					strcpy(cdl.oper,".");
				}
			}
			if (!strcmp(cdl.oper,"IS NOT IN USE")) {
				strcpy(cdl.oper,".");
				cdl.cmd=38;
				hadanif=2;
			}
			if (cdl.oper[0]==' ') strcpy(cdl.oper,".");
			if (cdl.cmd==15) {
				fp=fopen("opt.prn","a+");
				prmsgln(fp,text);
				fclose(fp);
			}
			else {
				fp=fopen("opt.prn","a+");
				prseqln(fp,text);
				if (!hadanif) fprintf(fp,"\n");
				fclose(fp);
			}
		}
	}
}
void outseqs(void) {
	int i,j,l,m,first;
	FILE *fp;
	char tmp[50];
	union {
		char *c;
		int  *i;
	} u;
	fp=fopen("opt.prn","a+");
	for (i=0;i<G_nolev;i++) fprintf(fp,"%d mod=%d old=%d ofs=%ld inout=%d\n",i,lev[i].modified,lev[i].old,lev[i].ofs,lev[i].inout);
	fprintf(fp,"\n_______________________________________________________________________________\n");
	for (j=0;j<G_nomsg;j++) {
		i=0;
		do {
			strcpy(tmp,extractlit(G_msg[j].t,i));
			if (tmp[0]!=1) {
				fprintf(fp,"m%-3d 32 %s\n",G_msg[j].m+20,tmp);
			}
			i++;
		} while (tmp[0]!=1);
	}
	fclose(fp);
	j=G_nowlev;
	first=1;
	fp=fopen("opt.prn","a+");
	fprintf(fp,"\n_______________________________________________________________________________\n");
	fclose(fp);
	for (l=0;l<G_nolev;l++) {
		setlevelto(l);
		if ((lev[l].G_elem[0].type==14)&&(!(lev[l].G_elem[0].deled))) {
			if (first) {
				first=0;
				fp=fopen("opn.prn","a+");
				fprintf(fp,"%d  %s\n",l,tpsdln(lev[l].G_elem[0].text));
				for (m=0;m<G_noseqs;m++) {
					fprintf(fp,"%d  %s \n",G_seqs[m].seq,tpsdln(G_seqs[m].name));
				}
				fclose(fp);
			}
			G_tab=malloc(G_noelem[l]*sizeof(eltab));
			traversepsd();
/*			fp=fopen("opt.prn","a+");
			for (i=0;i<G_noelem[l];i++) {
				if (!lev[l].G_elem[G_tab[i].i].deled) {
					fprintf(fp,"%d  %s   =   %d\n",l,tpsdln(lev[l].G_elem[G_tab[i].i].text),lev[l].G_elem[G_tab[i].i].type);
				}
			}
			fclose(fp);*/
			for (i=0;i<G_noelem[l];i++) {
				corepr();
				if (!lev[l].G_elem[G_tab[i].i].deled) {
					u.c=&lev[l].G_elem[G_tab[i].i].text[1];
					if (*u.i<2) {
						sepoutif(lev[l].G_elem[G_tab[i].i].text,G_tab[i].i,i);
					}
					else {
						cdlln(lev[l].G_elem[G_tab[i].i].text,G_tab[i].i,i);
					}
				}
			}
			while (G_now!=0) {
				utlln(G_utl[lev[G_nowlev].G_elem[G_crntrep[G_now]].ident]);
				fp=fopen("opt.prn","a+");
				fprintf(fp,"s%-5d UT .     .     .     .  .      .      .      .        UNTIL\n",G_nowlev);
				fclose(fp);
				G_now--;
			}
			free(G_tab);
		}
	}
	setlevelto(j);
	fp=fopen("opt.prn","a+");
	fprintf(fp,"\n_______________________________________________________________________________\n");
	for (j=0;j<G_nolit;j++) {
		fprintf(fp,"l%-5d %c ",j,G_lit[j].t);
		switch(G_lit[j].t) {
			case 'C' : {
				fprintf(fp,".        .        .        .        %s\n",(char *)G_lit[j].v);
			} break;
			case 'i' : {
				fprintf(fp,".        %-5d    .        .        .\n",*((int *)G_lit[j].v));
			} break;
			case 'l' : {
				fprintf(fp,"%5ld    .       .        .        .\n",*((long *)G_lit[j].v));
			} break;
			case 'f' : {
				fprintf(fp,".        .       %f .        .\n",*((float *)G_lit[j].v));
			} break;
			case 'd' : {
				fprintf(fp,".        .       %f .        .\n",*((double *)G_lit[j].v));
			} break;
		}
	}
	fclose(fp);
}
char *extractlit(char *text,int no) {
	int i,xit,j,lno;
	char *t;
	static char tmp[50];
	i=xit=lno=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i+=sizeof(int)+1;
			} break;
			case 'L' : {
				i++;
				j=0;
				t=&text[i];
				while (*(t++)!='^') {
					tmp[j++]=text[i++];
				}
				tmp[j]=0;
				if (lno==no) return(tmp);
				lno++;
				i++;
			} break;
			case 'O' : {
				i+=sizeof(int)+1;
			} break;
			case 'F' : {
				i+=sizeof(int)+1;
			} break;
			case 'E' : {
				i+=2*sizeof(int)+1;
			} break;
			case 'V' : {
				i+=sizeof(int)+1;
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
	}
	tmp[0]='';
	tmp[1]=0;
	return(tmp);
}
char *extractelm(char *text,int no) {
	int i,xit,j,lno;
	char *t;
	static char tmp[50];
	char tmp1[50];
	union {
		char *c;
		int  *i;
	} u;
	i=xit=lno=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i+=sizeof(int)+1;
			} break;
			case 'L' : {
				i++;
				j=0;
				t=&text[i];
				while (*(t++)!='^') {
					tmp[j++]=text[i++];
				}
				tmp[j]=0;
				if (lno==no) return(tmp);
				lno++;
				i++;
			} break;
			case 'O' : {
				i+=sizeof(int)+1;
			} break;
			case 'F' : {
				i+=sizeof(int)+1;
			} break;
			case 'E' : {
				i++;
				u.c=&text[i];
				if (*u.i<G_file.nofiles) {
					strcpy(tmp,G_file.files[*u.i]);
					j=*u.i;
					strcat(tmp,".");
					i+=sizeof(int);
					u.c=&text[i];
					G_i=*u.i;
					G_v='F';
					if (*u.i<G_file.cont[j]->nofld) {
						strcat(tmp,G_file.cont[j]->flds[*u.i]->name);
					}
					else {
						sprintf(tmp1,"F(%d)",*u.i);
						strcpy(tmp,tmp1);
					}
				}
				else {
					sprintf(tmp1,"S(%d)",*u.i);
					strcpy(tmp,tmp1);
					strcat(tmp,".");
					i+=sizeof(int);
					u.c=&text[i];
					G_i=*u.i;
					G_v='F';
					sprintf(tmp1,"F(%d)",*u.i);
					strcat(tmp,tmp1);
				}
				if (lno==no) return(tmp);
				lno++;
				i+=sizeof(int);
			} break;
			case 'V' : {
				i++;
				u.c=&text[i];
				for (j=0;j<G_varib.novar;j++) {
					if (G_varib.vars[j]->ofs==*u.i) {
						strcpy(tmp,G_varib.vars[j]->name);
						if (j>=26) {
							if (G_varib.vars[j]->type=='C') {
								G_v='s';
							}
							else {
								G_v=G_varib.vars[j]->type;
							}
							G_i=G_varib.vars[j]->no;
						}
						else {
							G_v='';
							G_i=G_varib.vars[j]->ofs;
						}
						break;
					}
				}
				if (j==G_varib.novar) {
					sprintf(tmp1,"VAR(%d)",*u.i);
					strcpy(tmp,tmp1);
					G_v='?';
					G_i=0;
				}
				if (lno==no) return(tmp);
				lno++;
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
	}
	tmp[0]='';
	tmp[1]=0;
	return(tmp);
}
void prseqln(FILE *fp,char *text) {
	int i;
	fprintf(fp,"s%-5d %-2s %-5d %-5d %-5d %-2s ",G_nowlev,cmd[cdl.cmd],cdl.fil,cdl.key,cdl.seq,cdl.oper);
	for (i=0;i<4;i++) {
		switch (cdl.vc[i]) {
			case '' : {
				if (strlen(G_const[cdl.vi[i]])==1) {
					fprintf(fp,"%s      ",G_const[cdl.vi[i]]);
				}
				else {
					fprintf(fp,"%s     ",G_const[cdl.vi[i]]);
				}
			} break;
			case 'M' :  {
				fprintf(fp,"%-5d  ",cdl.vi[i]);
			} break;
			case ' ' :  {
				fprintf(fp,".      ");
			} break;
			default : {
				fprintf(fp,"%c%-5d ",cdl.vc[i],cdl.vi[i]);
			}
		}
	}
	fprintf(fp,"  %s",tpsdln(text));
}
void prmsgln(FILE *fp,char *text) {
	int i;
	char tmp1[300];
	char tmp[50];
	memcpy(tmp1,G_msg[cdl.vi[0]-20].t,G_msg[cdl.vi[0]-20].l);
	fprintf(fp,"                                                             %s\n",tpsdln(text));
	i=0;
	do {
		sprintf(tmp,"L%s^Z",extractelm(tmp1,i));
		if (tmp[1]!=1) {
			if (!(i&1)) {
				cdl.cmd=15;
				cdl.vc[1]='M';
				cdl.vi[1]=i/2;
				prseqln(fp,tmp);
				fprintf(fp,"\n");
			}
			else {
				cdl.cmd=39;
				cdl.vc[1]=G_v;
				cdl.vi[1]=G_i;
				prseqln(fp,tmp);
				fprintf(fp,"\n");
			}
			i++;
		}
	} while (tmp[1]!=1);
}
char *getpname(int pid) {
	int i,j,l;
	switch (pid) {
		case 0 : return("SELF");
		case 1 : return("SUPERVISOR");
		case 2 : return("CAL/ALARM");
		case 3 : return("REPORT");
		case 5 : return("PRINTER");
		case 11111 : return("SENDER");
		case 11112 : return("");
		default : {
			l=G_nowlev;
			for (i=0;i<G_nolev;i++) {
				setlevelto(i);
				for (j=0;j<G_noelem[i];j++) {
					if (lev[i].G_elem[j].type==1) {
						if (lev[i].G_elem[j].ident==pid) {
							setlevelto(l);
							return(lev[i].G_elem[j].text);
						}
					}
				}
			}
		}
	}
	setlevelto(l);
	return("");
}
int findifRorW(int levl,int stid) {
	int i,k,start=0;
	union {
		char *c;
		int  *i;
	} u;
	for (k=0;k<G_noelem[levl];k++) {
		if (lev[levl].G_elem[k].type==14) {
			if (lev[levl].G_elem[k].level<0) {
				for (i=0;i<G_noseqs;i++) {
					if (!strcmp(lev[levl].G_elem[k].text,G_seqs[i].name)) {
						lev[levl].G_elem[k].level=G_seqs[i].seq;
						break;
					}
				}
				if (i!=G_noseqs) {
					if ((start=findifRorW(lev[levl].G_elem[k].level,stid))==1) break;
				}
			}
		}
		else {
			if (lev[levl].G_elem[k].text[0]=='C') {
				u.c=&lev[levl].G_elem[k].text[4];
				if (*u.i==stid-1) {
					u.c=&lev[levl].G_elem[k].text[1];
					if ((*u.i>11)&&(*u.i<15)) {
						start=1;
						break;
					}
				}
			}
		}
	}
	return(start);
}
/*	if (lev[G_nowlev].G_elem[item].type==11) {
		for (i=0;i<G_noseqs;i++) {
			if (lev[G_nowlev].G_elem[item].ident==G_seqs[i].seq) {
				lev[G_nowlev].G_elem[item].level=G_seqs[i].seq;
				break;
			}
		}
		if (i==G_noseqs) {
			for (i=0;i<G_noseqs;i++) {
				if (!strncmp("LDEF_ERR_SEQ^Z",G_seqs[i].name,14)) {
					lev[G_nowlev].G_elem[item].level=G_seqs[i].seq;
					lev[G_nowlev].G_elem[item].ident=lev[G_nowlev].G_elem[item].level;
					break;
				}
			}
			if (i==G_noseqs) {
				lev[G_nowlev].G_elem[item].level=addlev();
				lev[G_nowlev].G_elem[item].ident=lev[G_nowlev].G_elem[item].level;
				addseq("LDEF_ERR_SEQ^Z",lev[G_nowlev].G_elem[item].level);
			}
		}
	}
*/
void sepoutif(char *text,int item,int pos) {
	int i,j;
	FILE *fp;
	union {
		char *c;
		int  *i;
	} u;
	char tmp[500],*t;
	memcpy(tmp,text,i=psdlen(text));
	t=psdotok(tmp,i);
    cdlln(t,item,pos);
	while((t=psdotok((char *)NULL,i))!=(char *)NULL) {
		u.c=t+1;
		if ((*u.i>7)&&(*u.i<12)) {
			j=*u.i;
			*t='C';
			*u.i+=33;
			fp=fopen("opt.prn","a+");
			fprintf(fp,"\n");
			fclose(fp);
			cdlln(t,item,pos);
			*u.i=j;
			*t='O';
		}
	}
}
char *psdotok(char *text,int len) {
	static int i,start,done=0;
	static char save,buf[500];
	union {
		char *c;
		int  *i;
	} u;
	if (done) {
		done=0;
		return((char *)NULL);
	}
	if (text!=(char *)NULL) {
		memcpy(buf,text,len);
		i=0;
	}
	else {
		buf[i]=save;
	}
	start=i;
	while (i<len) {
		switch(buf[i]) {
			case 'C':
			case 'F':
			case 'V': i+=sizeof(int)+1;				break;
			case 'E': i+=sizeof(int)*2+1;			break;
			case 'L': while (buf[++i]!='^'); i++;	break;
			case 'O': {
				if (i==start) {
					i++;
				}
				else {
					i++;
					u.c=&buf[i];
					if ((*u.i>7)&&(*u.i<12)) {
						i--;
						save=buf[i];
						buf[i]='Z';
						return(&buf[start]);
					}
				}
				i+=sizeof(int);
			} break;
			case 'Z' : {
				done=1;
				return(&buf[start]);
			}
			default : {
				return((char *)NULL);
			}
		}
	}
	return((char *)NULL);
}
void sepoutut(char *text) {
	int i,j;
	FILE *fp;
	union {
		char *c;
		int  *i;
	} u;
	char tmp[500],*t;
	memcpy(tmp,text,i=psdlen(text));
	t=psdotok(tmp,i);
	utlln(t);
	while((t=psdotok((char *)NULL,i))!=(char *)NULL) {
		u.c=t+1;
		if ((*u.i>7)&&(*u.i<12)) {
			j=*u.i;
			*t='C';
			*u.i+=33;
			fp=fopen("opt.prn","a+");
			fprintf(fp,"\n");
			fclose(fp);
			utlln(t);
			*u.i=j;
			*t='O';
		}
	}
}
void utlln(char *text) {
	int i,xit,vcnt=0,j;
	FILE *fp;
	char tmp[200],*t,tmp1[50];
	char typ[5];
	union {
		char *c;
		int  *i;
	} u;
	printf("%s\n",tpsdln(text));
	cdl.cmd=35;
	cdl.fil=0;
	cdl.key=0;
	cdl.seq=0;
	strcpy(cdl.oper," ");
	for (i=0;i<4;i++) {
		cdl.vc[i]=' ';
		cdl.vi[i]=0;
	}
	tmp[0]=0;
	i=0;
	xit=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i++;
				u.c=&text[i];
				cdl.cmd=*u.i;
				i+=sizeof(int);
			} break;
			case 'L' : {
				i++;
				j=0;
				t=&text[i];
				while (*(t++)!='^') {
					tmp[j++]=text[i++];
				}
				tmp[j++]=0;
				i++;
				if ((cdl.cmd==15)&&(vcnt==1)) {
					cdl.key=atoi(&tmp[3]);
					cdl.vc[vcnt]='M';
					typ[vcnt]='M';
					cdl.vi[vcnt++]=0;
				}
				else {
					for (j=0;j<G_nolit;j++) {
						switch (G_lit[j].t) {
							case 'l' : {
								sprintf(tmp1,"%ld",*((long *)G_lit[j].v));
							} break;
							case 'i' : {
								sprintf(tmp1,"%i",*((int *)G_lit[j].v));
							} break;
							case 'f' : {
								sprintf(tmp1,"%f",*((float *)G_lit[j].v));
							} break;
							case 'd' : {
								sprintf(tmp1,"%f",*((double *)G_lit[j].v));
							} break;
							case 'C' : {
								sprintf(tmp1,"\"%s\"",(char *)G_lit[j].v);
							} break;
						}
						if (!strcmp(tmp1,tmp)) {
							cdl.vc[vcnt]='L';
							typ[vcnt]=G_lit[j].t;
							cdl.vi[vcnt++]=j;
							break;
						}
					}
					if (j==G_nolit) {
						cdl.vc[vcnt]='?';
						typ[vcnt]='B';
						cdl.vi[vcnt++]=0;
					}
				}
			} break;
			case 'O' : {
				i++;
				u.c=&text[i];
				strcpy(cdl.oper,operator[*u.i]);
				i+=sizeof(int);
			} break;
			case 'F' : {
				i++;
				u.c=&text[i];
				cdl.fil=*u.i+1;
				i+=sizeof(int);
			} break;
			case 'E' : {
				i++;
				u.c=&text[i];
				cdl.fil=*u.i+1;
				j=*u.i;
				i+=sizeof(int);
				u.c=&text[i];
				cdl.vc[vcnt]='F';
				typ[vcnt]=G_file.cont[cdl.fil]->flds[*u.i]->type;
				cdl.vi[vcnt++]=*u.i;
				i+=sizeof(int);
			} break;
			case 'V' : {
				i++;
				u.c=&text[i];
				if ((cdl.cmd==15)&&(vcnt<1)) {
					if (vcnt==0) {
						cdl.vc[vcnt]='M';
						typ[vcnt]='M';
						cdl.vi[vcnt++]=*u.i;
					}
				}
				else {
					for (j=0;j<G_varib.novar;j++) {
						if (G_varib.vars[j]->ofs==*u.i) {
							if (j>=26) {
								if (G_varib.vars[j]->type=='C') {
									cdl.vc[vcnt]='s';
								}
								else {
									cdl.vc[vcnt]=G_varib.vars[j]->type;
								}
								typ[vcnt]=G_varib.vars[j]->type;
								cdl.vi[vcnt++]=G_varib.vars[j]->no;
							}
							else {
								cdl.vc[vcnt]='';
								typ[vcnt]=G_varib.vars[j]->type;
								cdl.vi[vcnt++]=G_varib.vars[j]->ofs;
							}
							break;
						}
					}
					if (j==G_varib.novar) {
						cdl.vc[vcnt]='?';
						typ[vcnt]='L';
						cdl.vi[vcnt++]=0;
					}
				}
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
		strcat(tmp," ");
	}
	cdl.seq=0;
	fp=fopen("opt.prn","a+");
	prseqln(fp,text);
	fprintf(fp,"\n");
	fclose(fp);
}
void getvalue(void) {
	char k;
	int i;
	i=0;
	sound(1000);
	while ((k=getch())!=13) {
		nosound();
		if ((k>='0')&&(k<='9')) {
			if (i==0) {
				i=1;
				G_cmd[G_lnptr++]='L';
				G_cmd[G_lnptr++]=k;
				G_cmd[G_lnptr++]='^';
				G_cmd[G_lnptr]='Z';
			}
			else {
				G_cmd[G_lnptr-1]=k;
				G_cmd[G_lnptr++]='^';
				G_cmd[G_lnptr]='Z';
			}
		}
	}
	nosound();
}
