#include <stdio.h>
#include <ctype.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <alloc.h>
#include <fcntl.h>
#include <io.h>
#include "\tc\tv.h"

int  loadfiles(char *filnam) {
	int i,a;
	char currentln[81];
	char filename[50];
/*	char fil2[14];*/
	FILE *fptr;
	a=strlen(filnam);
	for (i=0;i<a;i++) if (isalpha(filnam[i])) filnam[i]&=0xDF;
	if ((filnam[a-3]=='O')&&(filnam[a-2]=='P')&&(filnam[a-1]=='T')) {
		G_numbparts[1][0]=G_numbparts[0][0]=1;
		strcpy(G_partnumb[0],filnam);
		a=readindata(0,filnam);
		nofiles=1;
		if (a<1) {
			if (a!=(-6)) {
				nofiles=0;
				return(0);
			}
		}
		return(1);
	}
	i=(-1);
	if ((fptr=fopen(filnam,"r"))==NULL) {
		printf("Can't Open %s.\n",filnam);
		exit(0);
	}
	while ((fgets(currentln,80,fptr)!=NULL)&&(i<65)) {
		i++;
		strcpy(filename,strtok(currentln,SEPERATORS));
		G_numbparts[1][i]=G_numbparts[0][i]=atoi(strtok(NULL,SEPERATORS));
		strcpy(G_partnumb[i],strtok(NULL,SEPERATORS));
/*		strcpy(fil2,"conv ");
		strcat(fil2,filename);
		strcat(fil2," A1");
		system(fil2);*/
		strcat(filename,".opt");
		a=readindata(i,filename);
		if (a<1) {
			if (a!=(-6)) {
				nofiles=i;
				fclose(fptr);
				return(0);
			}
		}
	}
	nofiles=i+1;
	fclose(fptr);
	return(1);
}
int  readindata(int diagno,char *filnam) {
	int fdes;
	int i,j;
	long k;
	int maxcx=-32766,maxcy=-32766,mincx=32766,mincy=32766;
	struct ffblk list;
	findfirst(filnam,&list,FA_RDONLY|FA_HIDDEN);
/*	printf("CORE %ld  FILE %ld\n",farcoreleft(),list.ff_fsize);*/
/*	if (farcoreleft()>(list.ff_fsize+16384L)) {*/
		if ((fdes=open(filnam,O_RDONLY|O_BINARY))==(-1)) {
			printf("Can't Open %s.\n",filnam);
			return(-1);
		}
		if (read(fdes,&k,sizeof(k))==0) {
			if (farcoreleft()<(k+16384L)) {
				close(fdes);
				return(-2);
			}
		}
		if (read(fdes,&nopolys[diagno],sizeof(nopolys[diagno]))==0) {
			printf("Can't Read %s.\n",filnam);
			close(fdes);
			return(-3);
		}
		if ((polp[diagno]=malloc(sizeof(*polp[diagno])*nopolys[diagno]+2))==NULL) {
			printf("Can't Allocate for %s.\n",filnam);
			close(fdes);
			return(-4);
		}
		if (farcoreleft()<list.ff_fsize+16384L) {
			printf("Can't Allocate for %s.\n",filnam);
			close(fdes);
			return(-5);
		}
		for (i=0;i<nopolys[diagno];i++) {
			if ((polp[diagno][i]=malloc(sizeof(struct pnts)+2))!=NULL) {
				if (farcoreleft()<list.ff_fsize+16384L) {
					printf("Can't Allocate for %s.\n",filnam);
					close(fdes);
					nopolys[diagno]=i-1;
					for (i=0;i<nopolys[diagno];i++) {
						maxpoints[diagno]=max(maxpoints[diagno],polp[diagno][i]->nopts);
						for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
							mincx=min(mincx,polp[diagno][i]->base[j]);
							mincy=min(mincy,polp[diagno][i]->base[j+1]);
							maxcx=max(maxcx,polp[diagno][i]->base[j]);
							maxcy=max(maxcy,polp[diagno][i]->base[j+1]);
						}
					}
					difx[diagno]=maxcx-mincx;
					dify[diagno]=maxcy-mincy;
					minx[diagno]=mincx;
					miny[diagno]=mincy;
					maxnopps=max(maxnopps,maxpoints[diagno]);
					return(-6);
				}
				if (read(fdes,&polp[diagno][i]->typacol,sizeof(struct pnts)+2)==0) {
					printf("Can't Read %s.\n",filnam);
					close(fdes);
					nopolys[diagno]=i-1;
					for (i=0;i<nopolys[diagno];i++) {
						maxpoints[diagno]=max(maxpoints[diagno],polp[diagno][i]->nopts);
						for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
							mincx=min(mincx,polp[diagno][i]->base[j]);
							mincy=min(mincy,polp[diagno][i]->base[j+1]);
							maxcx=max(maxcx,polp[diagno][i]->base[j]);
							maxcy=max(maxcy,polp[diagno][i]->base[j+1]);
						}
					}
					difx[diagno]=maxcx-mincx;
					dify[diagno]=maxcy-mincy;
					minx[diagno]=mincx;
					miny[diagno]=mincy;
					maxnopps=max(maxnopps,maxpoints[diagno]);
					return(-6);
				}
			}
			if ((polp[diagno][i]->base=malloc(4*polp[diagno][i]->nopts+2))!=NULL) {
				if (farcoreleft()<list.ff_fsize+16384L) {
					printf("Can't Allocate for %s.\n",filnam);
					close(fdes);
					nopolys[diagno]=i-1;
					for (i=0;i<nopolys[diagno];i++) {
						maxpoints[diagno]=max(maxpoints[diagno],polp[diagno][i]->nopts);
						for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
							mincx=min(mincx,polp[diagno][i]->base[j]);
							mincy=min(mincy,polp[diagno][i]->base[j+1]);
							maxcx=max(maxcx,polp[diagno][i]->base[j]);
							maxcy=max(maxcy,polp[diagno][i]->base[j+1]);
						}
					}
					difx[diagno]=maxcx-mincx;
					dify[diagno]=maxcy-mincy;
					minx[diagno]=mincx;
					miny[diagno]=mincy;
					maxnopps=max(maxnopps,maxpoints[diagno]);
					return(-6);
				}
				if (read(fdes,polp[diagno][i]->base,4*polp[diagno][i]->nopts+2)==0) {
					printf("Can't Read %s.\n",filnam);
					close(fdes);
					nopolys[diagno]=i-1;
					for (i=0;i<nopolys[diagno];i++) {
						maxpoints[diagno]=max(maxpoints[diagno],polp[diagno][i]->nopts);
						for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
							mincx=min(mincx,polp[diagno][i]->base[j]);
							mincy=min(mincy,polp[diagno][i]->base[j+1]);
							maxcx=max(maxcx,polp[diagno][i]->base[j]);
							maxcy=max(maxcy,polp[diagno][i]->base[j+1]);
						}
					}
					difx[diagno]=maxcx-mincx;
					dify[diagno]=maxcy-mincy;
					minx[diagno]=mincx;
					miny[diagno]=mincy;
					maxnopps=max(maxnopps,maxpoints[diagno]);
					return(-6);
				}
			}
/*			printf("CORE %ld,%d,%d\n",farcoreleft(),nopolys[diagno],polp[diagno][i]->nopts);
			getch();*/
		}
		read(fdes,&maxtext[diagno],sizeof(maxtext[diagno]));
		if (maxtext[diagno]>0) {
			if ((textlns[diagno]=farmalloc(maxtext[diagno]+20))!=NULL) {
				if (read(fdes,textlns[diagno],maxtext[diagno])==0) {
					printf("Can't Read Text\n");
				}
				for (i=0;i<maxtext[diagno];i++) {
                    if (textlns[diagno][i]=='\n') textlns[diagno][i]=0;
					if (textlns[diagno][i]=='\r') textlns[diagno][i]=32;
                }
				for (i=maxtext[diagno];i<maxtext[diagno]+20;i++) textlns[diagno][i]=0;
			}
		}
		close(fdes);
		for (i=0;i<nopolys[diagno];i++) {
			maxpoints[diagno]=max(maxpoints[diagno],polp[diagno][i]->nopts);
			for (j=0;j<polp[diagno][i]->nopts*2;j+=2) {
				mincx=min(mincx,polp[diagno][i]->base[j]);
				mincy=min(mincy,polp[diagno][i]->base[j+1]);
				maxcx=max(maxcx,polp[diagno][i]->base[j]);
				maxcy=max(maxcy,polp[diagno][i]->base[j+1]);
			}
		}
		difx[diagno]=maxcx-mincx;
		dify[diagno]=maxcy-mincy;
		minx[diagno]=mincx;
		miny[diagno]=mincy;
		maxnopps=max(maxnopps,maxpoints[diagno]);
		return(1);
/*	}
	else {
		return(-6);
	}*/
}
int selafile(char *path) {
	int i,j,k;
	static int cur=0,st=0;
	char charpos=0;
	char key,findst[13];
	struct ffblk name;
	char names[200][13];
	i=0;
	if ((findfirst(path,&name,FA_RDONLY|FA_HIDDEN))==(-1)) return(0);
	strcpy(names[i++],name.ff_name);
	while ((i<200)&&(!(findnext(&name)))) {
		strcpy(names[i++],name.ff_name);
	}
	G_notosel=i;
	if (G_notosel==1) {
		strcpy(G_filename,names[0]);
		return(1);
	}
	qsort(names,i,13,strcmp);
	textbackground(1);
	clrscr();
	textcolor(14);
	gotoxy(18,1);
	cprintf("Select A File With Letters And Cursor Keys");
	for (j=1;j<80;j++) {
		gotoxy(j,2); cprintf("%c",205);
		gotoxy(j,25); cprintf("%c",205);
	}
	for (j=3;j<25;j++) {
		for (k=0;k<7;k++) {
			gotoxy(1+(k*13),j); cprintf("%c",186);
		}
	}
	for (k=1;k<6;k++) {
		gotoxy(1+(k*13),2); cprintf("%c",203);
		gotoxy(1+(k*13),25); cprintf("%c",202);
	}
	gotoxy(1,2); cprintf("%c",201);
	gotoxy(1,25); cprintf("%c",200);
	gotoxy(79,2); cprintf("%c",187);
	gotoxy(79,25); cprintf("%c",188);
	textcolor(11);
	for (j=0;j<min(i,132);j++) {
		gotoxy(((j/22)*13)+2,(j%22)+3);
		cprintf("%-12s",names[j]);
	}
	do {
		textbackground(4);
		gotoxy((((cur-st)/22)*13)+2,((cur-st)%22)+3);
		cprintf("%-12s",names[cur]);
		key=getch();
		textbackground(1);
		gotoxy((((cur-st)/22)*13)+2,((cur-st)%22)+3);
		cprintf("%-12s",names[cur]);
		switch(key) {
			case 0 : {
				charpos=0;
				key=getch();
				switch(key) {
					case 'P' : {
						if (cur<i-1) {
							cur++;
							if (cur>st+131) {
								st++;
								for (j=st;j<st+132;j++) {
									gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
									cprintf("%-12s",names[j]);
								}
							}
						}
					} break;
					case 'H' : {
						if (cur>0) {
							cur--;
							if (cur<st) {
								st--;
								for (j=st;j<st+132;j++) {
									gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
									cprintf("%-12s",names[j]);
								}
							}
						}
					} break;
					case 'M' : {
						if (cur<(i-21)) cur+=22; else cur=i-1;
						if (cur>st+131) {
							st+=22;
							if (st>i-132) st=i-132;
							for (j=st;j<st+132;j++) {
								gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
								if (j<i) {
									cprintf("%-12s",names[j]);
								}
								else {
								cprintf("            ");
								}
							}
						}
					} break;
					case 'S' : {
						key=13;
					} break;
					case 'K' : {
						if (cur>21) cur-=22; else cur=0;
						if (cur<st) {
							st-=22;
							if (st<0) st=0;
							for (j=st;j<st+132;j++) {
								gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
								if (j<i) {
									cprintf("%-12s",names[j]);
								}
								else {
									cprintf("            ");
								}
							}
						}
					} break;
				}
			} break;
			case 13 : {
			} break;
			case 27 : {
			} break;
			default : {
				if (isalpha(key)) key&=0xDF;
				findst[charpos]=key;
				findst[charpos+1]=0;
				for (j=0;j<i;j++) {
					if (strcmp(names[j],findst)>=0) {
						cur=j;
						charpos++;
						if (charpos>12) charpos=0;
						break;
					}
				}
				if ((cur<st)||(cur>(st+131))) {
					st=(cur-64);
					if (st<0) st=0;
					for (j=st;j<st+132;j++) {
						gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
						if (j<i) {
							cprintf("%-12s",names[j]);
						}
						else {
							cprintf("            ");
						}
					}
				}
			}
		}
	} while ((key!=27)&&(key!=13));
	if (key==27) {
		reset();
		exit(1);
	}
	strcpy(G_filename,names[cur]);
	return(1);
}
void farfreepolys(void) {
	int i,j;
	for (i=0;i<nofiles;i++) {
		for (j=0;j<nopolys[i];j++) {
			free((int far *)polp[i][j]->base);
			free((struct pnts far *)polp[i][j]);
		}
		free((struct pnts far *)polp[i]);
	}
}