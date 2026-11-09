#include <dos.h>
#include <errno.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <graphics.h>
#include "convhpgl.h"


/*-----------------------------Variables----------------------------------*/
	int						oldvectseg;
	int						oldvectofs;
	char					buffer[bufend+1];
	char					*buf;
	int						point1,point2;
	int						GraphDriver,GraphMode;
	double	far 			*ylook;
	double	far 			*xlook;
	double	far 			*alook;
	double					aspect;
	int						maxx,maxy;
	int						G_xcur,G_ycur;
	int						G_chord_tol;
	int						G_chawid;
	int						G_chahgt;
	char	far 			*G_labbuf;
	int						G_charslnt;
	int						G_font;
	int						G_fill;
	int						G_onechar;
	int						G_pmask;
	int						G_emask;
	int						G_smask;
	int						G_afont;
	int						G_cfont;
	int						G_labwid;
	char					G_lterm;
	int						G_labhgt;
	int						G_labdir;
	int						G_lspace;
	int						G_llines;
	int						G_rotation;
	int						origx,origy;
	int						lorigx,lorigy;
	int						G_p1x;
	int						G_p1y;
	int						G_p2x;
	int						G_p2y;
	int						G_w1x;
	int						G_w2y;
	int						G_w1x;
	int						G_w2y;
	int						G_colour;
	int						G_linetype;
	int						penup;
	int						maxcordx=-32766;
	int						mincordx=32766;
	int						maxcordy=-32766;
	int						mincordy=32766;
	int						rxpos=0,rypos=0;
	int						nolines=0;
	int						nopolys;
	struct	arguments 		argus;
	struct	farguments 		arguf;
	char	far 			*argut;
	char					seperator;
	char					terminator1;
	char					terminator2;
	int						txpos;
	int						typos;
	int						wwidth;
	int						wlength;
	char	far 			*textlns;
	int						maxtext;
	int						coords[500][2];
    int						nocds;

	struct pnts {
		unsigned	char	typacol;
		unsigned	char	ltafs;
		unsigned	int		nopts;
			int	far	*base;
	} far **polpy;

void drawdiag(int x,int y,int x1,int y1,int zoom);


main (int argc,char *argv[]) {
	int i,j;
	long tmp;
	char fil1[14],fil2[14],fil3[14];
	if (argc<2) exit(1);
	buf=buffer;
	point1=point2=0;
	setcomms();
	polpy=farmalloc(sizeof(*polpy)*1000);
	nopolys=0;
	argut=farmalloc(256);
	G_labbuf=farmalloc(200);
	textlns=farmalloc(16000);
	strcpy(fil1,argv[1]);
	strcat(fil1,".lst");
	strcpy(fil2,argv[1]);
	strcat(fil2,".txt");
	strcpy(fil3,argv[1]);
	strcat(fil3,".opt");
	setuplook();
	setupchar();
	setdefaults();
/*	printf("%ld,",farcoreleft());*/
	if (!(readinfile(fil1))) {
		printf("Can't open plotter file - %s\n",fil1);
	}
	printf("No-polys = %d\n",nopolys);
	for (i=0;i<nopolys;i++) {
		for (j=0;j<polpy[i]->nopts;j++) {
			maxcordx=max(maxcordx,polpy[i]->base[(j*2)  ]);
			maxcordy=max(maxcordy,polpy[i]->base[(j*2)+1]);
			mincordx=min(mincordx,polpy[i]->base[(j*2)  ]);
			mincordy=min(mincordy,polpy[i]->base[(j*2)+1]);
		}
	}
/*	printf("%d,%d,%d,%d\n",mincordx,maxcordx,mincordy,maxcordy);
	getch();
	grafix();
	closegraph();*/
	for (i=0;i<nopolys;i++) {
		for (j=0;j<polpy[i]->nopts;j++) {
/*			printf("%d-%d=",polpy[i]->base[(j*2)],mincordx);*/
			tmp=(long)polpy[i]->base[(j*2)];
			tmp-=(long)mincordx;
			if (tmp>32766) tmp=32766;
			if (tmp<-32766) tmp=-32766;
			polpy[i]->base[(j*2)  ]=(int)tmp;
/*			printf("%d\n",polpy[i]->base[(j*2)]);
			getch();*/
			tmp=0L-(long)polpy[i]->base[(j*2)+1];
			tmp-=(long)mincordy;
			if (tmp>32766) tmp=32766;
			if (tmp<-32766) tmp=-32766;
			polpy[i]->base[(j*2)+1]=(int)tmp;
		}
	}
	printf("Write -%d\n",writeoutfile(fil3));
/*	printf("Finished.\n");
	printf("Read -%d\n",readindata("test.opt"));*/
    grafix();
	drawdiag(10,10,500,300,6);
	getch();
	closegraph();
	restcomms();
	return(0);
}

void grafix(void) {
	int ErrorCode;
	GraphDriver = DETECT;
	initgraph( &GraphDriver, &GraphMode, "" );
	ErrorCode = graphresult();
	if( ErrorCode != grOk ){
		printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
		exit(1);
	}
	maxx=getmaxx();
	maxy=getmaxy();
	aspect=(double)(maxx/4)/(double)(maxy/3);
}
int  readintext(char *filnam) {
	int fdes;
	char *temp=textlns;
	int  i=0;
	if ((fdes=open(filnam,O_RDONLY))==(-1)) {
		return(0);
	}
	maxtext=read(fdes,textlns,32000);
	for (i=0;i<maxtext;i++) if (*temp++=='\n') *(temp-1)=0;
	close(fdes);
	return(1);
}
int  writeoutfile(char *filnam) {
	int fdes;
	int  i;
	if ((fdes=open(filnam,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,0777))==(-1)) {
		return(0);
	}
	if (write(fdes,&nopolys,sizeof(nopolys))==0) {
		close(fdes);
		return(0);
	}
	for (i=0;i<nopolys;i++) {
		if (write(fdes,&polpy[i]->typacol,sizeof(struct pnts)+2)==0) {
			close(fdes);
			return(0);
		}
		if (write(fdes,polpy[i]->base,(2*polpy[i]->nopts*sizeof(i))+2)==0) {
			close(fdes);
			return(0);
		}
	}
	close(fdes);
	return(1);
}
int  readindata(char *filnam) {
	int fdes;
	int  i;
	if ((fdes=open(filnam,O_RDONLY|O_BINARY))==(-1)) {
		return(0);
	}
	polpy=farmalloc(sizeof(*polpy)*1000);
	if (read(fdes,&nopolys,sizeof(nopolys))==0) {
		perror("Read nopolys");
		close(fdes);
		return(0);
	}
	for (i=0;i<nopolys;i++) {
		if ((polpy[i]=farmalloc(sizeof(struct pnts)+2))==NULL) {
			perror("Malloc structure");
			close(fdes);
			return(-1);
		}
		if (read(fdes,&polpy[i]->typacol,sizeof(struct pnts)+2)==0) {
			perror("Read structure");
			close(fdes);
			return(-2);
		}
		if ((polpy[i]->base=farmalloc(4*polpy[i]->nopts+2))==NULL) {
			perror("Malloc points");
			close(fdes);
			return(-3);
		}
		if (read(fdes,polpy[i]->base,4*polpy[i]->nopts+2)==0) {
			perror("Read points");
			close(fdes);
			return(-4);
		}
	}
	close(fdes);
	return(1);
}
void ddrawpoly(int fill,unsigned int np,int far *polyp) {
	int i;
	if ((polpy[nopolys]=farmalloc(sizeof(struct pnts)))!=NULL) {
		if ((polpy[nopolys]->base=farmalloc(2*np*sizeof(i)))!=NULL) {
			polpy[nopolys]->typacol=(fill<<7)|0x10|(G_colour&0x0F);
			polpy[nopolys]->ltafs=(G_linetype<<4)|(G_fill&0x0F);
			polpy[nopolys]->nopts=np;
           	for (i=0;i<np;i++) {
				polpy[nopolys]->base[(i*2)  ]=polyp[(i*2)  ];
				polpy[nopolys]->base[(i*2)+1]=polyp[(i*2)+1];
			}
			nopolys++;
		}
		else {
			polpy[nopolys]->nopts=0;
			polpy[nopolys]->typacol=0;
		}
	}
}
void drect(int fill,int x,int y,int x1,int y1) {
	if ((polpy[nopolys]=farmalloc(sizeof(struct pnts)))!=NULL) {
		if ((polpy[nopolys]->base=farmalloc(4*sizeof(x)))!=NULL) {
			polpy[nopolys]->typacol=(fill<<7)|0x20|(G_colour&0x0F);
			polpy[nopolys]->ltafs=(G_linetype<<4)|(G_fill&0x0F);
			polpy[nopolys]->nopts=2;
			polpy[nopolys]->base[0]=x;
			polpy[nopolys]->base[1]=y;
			polpy[nopolys]->base[2]=x1;
			polpy[nopolys]->base[3]=y1;
			nopolys++;
		}
		else {
			polpy[nopolys]->nopts=0;
			polpy[nopolys]->typacol=0;
		}
	}
}
void drawdiag(int x,int y,int x1,int y1,int zoom) {
	int i,j;
	unsigned int pp[300];
    int mag[21]={1024,512,256,128,64,32,16,8,4,2,1,2,4,8,16,32,64,128,256,512,1024};

/*	rectangle(x,y,x1,y1);*/
	setviewport(x,y,x1,y1,0);
	if (graphresult()!=(-11)) {
		for (i=0;i<nopolys;i++) {
			setlinestyle(polpy[i]->ltafs>>4,0,0);
			setcolor(polpy[i]->typacol&0x0F);
/*			setcolor(15);*/
			switch(polpy[i]->typacol>>4) {
				case 1 : {
					if (zoom<10) {
						for (j=0;j<=polpy[i]->nopts*2;j+=2) {
							pp[j]=polpy[i]->base[j]/mag[zoom];
							pp[j+1]=polpy[i]->base[j+1]/mag[zoom];
						}
					}
					else {
						for (j=0;j<=polpy[i]->nopts*2;j+=2) {
							pp[j]=polpy[i]->base[j]*mag[zoom]*aspect;
							pp[j+1]=polpy[i]->base[j+1]*mag[zoom];
						}
					}
					drawpoly(polpy[i]->nopts,(int far *)pp);
				} break;
				case 2 : {
					rectangle(polpy[i]->base[0],polpy[i]->base[1],polpy[i]->base[2],polpy[i]->base[3]);
				} break;
				case 9 : {
					setfillstyle(polpy[i]->ltafs&0x0F,polpy[i]->typacol&0x0F);
					fillpoly(polpy[i]->nopts,(int far *)polpy[i]->base);
				} break;
				case 10 : {
					setfillstyle(polpy[i]->ltafs&0x0F,polpy[i]->typacol&0x0F);
					bar(polpy[i]->base[0],polpy[i]->base[1],polpy[i]->base[2],polpy[i]->base[3]);
					rectangle(polpy[i]->base[0],polpy[i]->base[1],polpy[i]->base[2],polpy[i]->base[3]);
				} break;
				default : {
				}
			}
		}
	}
	setviewport(0,0,maxx,maxy,1);
}