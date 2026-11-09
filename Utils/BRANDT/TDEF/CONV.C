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
extern		int				oldvectseg;
extern		int				oldvectofs;
extern		char			buffer[bufend+1];
extern		char			*buf;
extern		int				point1,point2;
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
/*	char		 			textlns[4000];*/
	int						maxtext;
	int						coords[500][2];
    int						nocds;
	long					divisor;
	long					plotsize[5]={8L,4L,2L,1L,1L};
	struct pnts {
		unsigned	char	typacol;
		unsigned	char	ltafs;
		unsigned	int		nopts;
			int	far	*base;
	} far **polpy;
char fil1[14],fil2[14],fil3[14];

void drawdiag(int x,int y,int x1,int y1,int zoom);


main (int argc,char *argv[]) {
	int i,j;
	long tmp;
	int far *p;
	printf("P.M.A  HP-GL Plot file conversion utility\n");
	if (argc<2) {
		printf("SYNTAX :\n");
		printf("\nC:\>conv plotfile [plotter size A0 to A5]\n\n");
		printf("default plotter size = A1\n\n");
		exit(1);
	}
	if (argc==2) {
		printf("Converting File[%s.lst] Paper Size[A1]\n",argv[1]);
		divisor=plotsize[1];
	}
	else {
		printf("Converting File[%s.lst] Paper Size[A%c]\n",argv[1],argv[2][1]);
		divisor=plotsize[atoi(&argv[2][1])];
	}
	buf=buffer;
	point1=point2=0;
	setcomms();
	polpy=farmalloc(sizeof(*polpy)*10500);
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
/*	setuplook();*/
/*	setupchar();*/
	setdefaults();
	if (!(readinfile(fil1))) {
		printf("Can't open plotter file - %s\n",fil1);
		exit(-1);
	}
	for (i=0;i<nopolys;i++) {
		p=polpy[i]->base;
		for (j=0;j<(polpy[i]->nopts*2);j+=2) {
			maxcordx=max(maxcordx,p[j  ]);
			maxcordy=max(maxcordy,p[j+1]);
			mincordx=min(mincordx,p[j  ]);
			mincordy=min(mincordy,p[j+1]);
		}
	}
	for (i=0;i<nopolys;i++) {
		p=polpy[i]->base;
		for (j=0;j<(polpy[i]->nopts*2);j+=2) {
			tmp=(long)p[j];
			tmp-=(long)mincordx;
			if (tmp>32766) tmp=32766;
			if (tmp<-32766) tmp=-32766;
			p[j]=(int)tmp;
			tmp=0L-(long)p[j+1];
			tmp-=(long)mincordy;
			if (tmp>32766) tmp=32766;
			if (tmp<-32766) tmp=-32766;
			p[j+1]=(int)tmp;
		}
	}
	writeoutfile(fil3);
	printf("Conversion Complete Output Written to %s.opt.\n",argv[1]);
	restcomms();
	return(0);
}
int  readintext(char *filnam) {
	int fdes;
	char *temp=textlns;
	int  i=0;
	if ((fdes=open(filnam,O_RDONLY))==(-1)) {
		return(0);
	}
	maxtext=read(fdes,textlns,8000);
	for (i=0;i<maxtext;i++) if (*temp++=='\n') *(temp-1)=0;
	close(fdes);
	return(1);
}
int  writeoutfile(char *filnam) {
	int fdes,fd;
	int  i;
	long j=0L;
	for (i=0;i<nopolys;i++) {
		j+=(long)((sizeof(struct pnts)+2)+((2*polpy[i]->nopts*sizeof(i))+2));
	}
	if ((fdes=open(filnam,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,0777))==(-1)) {
		return(0);
	}
	if (write(fdes,&j,sizeof(j))==0) {
		close(fdes);
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
	if ((fd=open(fil2,O_RDONLY))==(-1)) {
		printf("No Text File %s\n",fil2);
		maxtext=0;
	}
	else {
		maxtext=read(fd,textlns,16000);
/*		for (i=0;i<16000;i++) printf("%c",textlns[i]);*/
		close(fd);
	}
	write(fdes,&maxtext,sizeof(maxtext));
	write(fdes,textlns,maxtext);
	close(fdes);
	return(1);
}
void ddrawpoly(int fill,unsigned int np,int far *polyp) {
	int i;
	struct pnts *p;
	if (nopolys<10499) {
		if ((polpy[nopolys]=farmalloc(sizeof(struct pnts)))!=NULL) {
			p=polpy[nopolys];
			if ((p->base=farmalloc(2*np*sizeof(i)))!=NULL) {
				p->typacol=(fill<<7)|0x10|(G_colour&0x0F);
				p->ltafs=(G_linetype<<4)|(G_fill&0x0F);
				p->nopts=np;
				for (i=0;i<(np*2);i+=2) {
					p->base[i  ]=polyp[i  ];
					p->base[i+1]=polyp[i+1];
				}
				nopolys++;
			}
			else {
				p->nopts=0;
				p->typacol=0;
			}
		}
	}
	else {
		printf(".");
	}
}
