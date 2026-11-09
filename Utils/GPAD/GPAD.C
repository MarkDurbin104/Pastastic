#define GPAD_C

#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <alloc.h>
#include <graphics.h>
#include <mem.h>
#include <io.h>
#include <fcntl.h>

#include "types.h"
#include "control.h"
#include "formhand.h"
#include "dst.h"
#include "config.h"
#include "win.h"
#include "frdwin.h"
#include "frdgfx.h"
#include "frdscr.h"

#define TABLE      56
#define ANAME      51
#define STATNAME   125
#define VARIABLE   25

INT shutdown(void);

CHAR   *G_usage="GPAD SYSTEM\n";

typedef struct {
    UINT sig  ;
    UINT flen ;
    UINT fhlen;
    UINT ni   ;
    UINT hlen ;
    UINT min  ;
    UINT max  ;
    UINT ss   ;
    UINT sp   ;
    UINT crc  ;
    UINT ip   ;
    UINT cs   ;
    UINT ofr  ;
    UINT ovr  ;
} EXEHEAD;

typedef struct {
    ULONG str;
    ULONG fun;
    UINT  scr;
    UINT  pri;
} ACTLIST;

CHAR G_atype='A';

INT faname(CHAR *name)
{
    INT i;
    for (i=0;i<G_numan;i++) if (!strncmp(G_anames[i],name,8)) return(i+1);
    return(0);
}
void addaname(CHAR *name)
{
    CHAR tmp[11];
    sprintf(tmp,"%-8.8s %c",name,G_atype);
    if (!faname(tmp)) G_anames[G_numan++]=strdup(tmp);
}
INT getactmap(void)
{
	FILE *fp;
	CHAR b[80];
	CHAR *t;

    G_atype='C';
	if ((fp=fopen("GPAFUNC.LST","r"))!=NULL) {
		while (fgets(b,80,fp)!=NULL) {
			t=&(b[strlen(b)-1]);
			while ((*t=='\n')||(*t=='\r')) *(t--)=0;
        	addaname(&(b[2]));
		}
		fclose(fp);
	}
	return(1);
}

void loadactions(CHAR *sys)
{
    CHAR tmp[80],c;
    INT fd,j,i,nn;
    LONG l;
    sprintf(tmp,"%s%sI.DAT",G_config,sys);

    if ((fd=open(tmp,O_RDONLY|O_BINARY))==(-1)) return;
    read(fd,&nn,sizeof(INT));
    if (nn==0x5A5A) {
        read(fd,&nn,sizeof(INT));
        for (i=0;i<nn;i++) {
            read(fd,&c,sizeof(CHAR));
            read(fd,&c,sizeof(CHAR));
            read(fd,&l,sizeof(LONG));
            read(fd,tmp,9);
            if (c==ANAME) {
		        G_atype='A';
			    addaname(tmp);
		    } else if ((c==STATNAME)||(c==VARIABLE)) {
		        G_atype='V';
			    addaname(tmp);
		    }
        }
    } else {
        for (i=0;i<nn;i++) {
            read(fd,&c,sizeof(CHAR));
            read(fd,&c,sizeof(CHAR));
            read(fd,&j,sizeof(INT));
            read(fd,tmp,9);
            if (c==ANAME) {
		        G_atype='A';
			    addaname(tmp);
		    } else if ((c==STATNAME)||(c==VARIABLE)) {
		        G_atype='V';
			    addaname(tmp);
		    }
        }
    }
    close(fd);
}
int ancmp(const void *a,const void *b)
{
    return(strcmp(*(CHAR **)a,*(CHAR **)b));
}
void loadallforms(void)
{
    INT i;
    getformidx("logon");
    for (i=0;i<G_numidx;i++) {
        G_forms[i]=MALLOC(sizeof(FORM));
        if (G_forms[i]!=NULL) {
            strcpy(G_forms[i]->name,G_fid[i].name);
            loadform(G_forms[i]);
            addaname(G_fid[i].name);
        }
    }
}
INT setup(CHAR *name)
{
	INT i,cnt1,cnt2;
	INT fd, retval = 0;
	grafix();
	upscr();
	readconfig(name);

	strcpy(G_sysname,name);
	G_tcnt=0;
	memcpy(G_textfile,G_textfile2,80);
	loadtext(G_system);
	G_text2=MALLOC(5000*sizeof(CHAR *));
    memcpy(G_text2,G_text,G_tcnt*sizeof(CHAR *));
    G_tname2=MALLOC(5000*sizeof(CHAR *));
    memcpy(G_tname2,G_tname,G_tcnt*sizeof(CHAR *));
    cnt2=G_tcnt;

	G_tcnt=0;
    memcpy(G_textfile,G_textfile1,80);
    loadtext(G_system);
	G_text1=G_text;
    G_tname1=G_tname;
    cnt1=G_tcnt;

    if (cnt1!=cnt2) {
        if (cnt1<cnt2) {
            for (i=cnt1;i<cnt2;i++) {
                G_tname1[i]=STRDUP(G_tname2[i]);
                G_text1 [i]=STRDUP(G_text2 [i]);
            }
            G_tcnt=cnt2;
        } else {
            for (i=cnt2;i<cnt1;i++) {
                G_tname2[i]=STRDUP(G_tname1[i]);
				G_text2 [i]=STRDUP(G_text1 [i]);
			}
            G_tcnt=cnt1;
        }
	}
    
    G_tno=0;
    G_langname=&G_textfile[strlen(G_textfile)+1];

    loadsdata(G_system);

    G_anames=malloc(1500*sizeof(CHAR *));
    G_numan=0;
    loadactions(G_system);
    getactmap();
    G_atype='F';
    loadallforms();

	G_anames=realloc(G_anames,G_numan*sizeof(CHAR *));
	qsort(G_anames,G_numan,sizeof(CHAR *),ancmp);

    settextstyle(0,0,0);
	G_sysfh=textheight("8g")+3;
    G_sysfw=textwidth("8");
    G_scrx=14;
    G_scry=G_maxy-(30+G_scrh*G_fnth);
    memset(&G_cform,0,sizeof(G_cform));
    G_cform.items=NULL;
//    G_pbuf=malloc(132*132*sizeof(INT));
    G_pbuf=NULL;
//    if (G_pbuf==NULL) {
//        error("Cant get enough memory\n for print page.\nPrinting disabled!");
        G_mmopt[8].col=7;
        G_mmopt[8].type=0;
//    }
    fd=open("GPAD.but",O_RDONLY|O_BINARY);
	if (fd > 0)
	{
		read(fd,&G_bmw,sizeof(INT));
		read(fd,&G_bmh,sizeof(INT));
		read(fd,&G_bis,sizeof(INT));
		for (i=0;i<5;i++) {
			G_bm[i]=malloc(G_bis);
			read(fd,G_bm[i],G_bis);
		}
		close(fd);
	}
	else
	{
		printf ("GPAD.BUT missing! Cannot run");
		retval = 1;
	}
	setupwin(G_maxx,G_maxy);
	downscr();
    printf("retval=%d",retval);
	return (retval);
}
INT shutdown(void)
{
	INT i;
	windown();
	closegraph();
	for (i=0;i<G_numidx;i++) {
		  if (G_forms[i]!=NULL) {
				freeform(G_forms[i]);
				FREE(G_forms[i]);
		  }
	}
	freeformidx();
	MEMcloseSwapFile(1);
	return(0);
}
INT main(INT argc,CHAR *argv[])
{
	if (argc<2) {
		  printf("%s",G_usage);
		  return(1);
	}
	if (setup(argv[1]))
	{
		return(shutdown());
	}

		// Set up a 4 Mbyte swap file
	MEMinitSwapFile("SWAPFILE.GPA",0x400000L);

	 wind(&G_wni[0]);
	 menu(G_mmopt,G_mainw);
	 lbox(&G_lbi[0]);
	 butt(&G_bti[0]);
	 butt(&G_bti[1]);
	 butt(&G_bti[2]);
	 butt(&G_bti[3]);
	 tbox(&G_tbi[0]);
	 tbox(&G_tbi[1]);
	 tbox(&G_tbi[2]);
	 tbox(&G_tbi[3]);
	 activate(G_mainw);

	 for (;;)		poll();

	 return(shutdown());
}
 
 
 




