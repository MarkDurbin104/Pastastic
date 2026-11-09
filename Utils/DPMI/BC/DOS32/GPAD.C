#define GPAD_C

#include <stdio.h>
#include <conio.h>
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

char   *G_usage="GPAD SYSTEM\n";

typedef struct {
    unsigned int sig  ;
    unsigned int flen ;
    unsigned int fhlen;
    unsigned int ni   ;
    unsigned int hlen ;
    unsigned int min  ;
    unsigned int max  ;
    unsigned int ss   ;
    unsigned int sp   ;
    unsigned int crc  ;
    unsigned int ip   ;
    unsigned int cs   ;
    unsigned int ofr  ;
    unsigned int ovr  ;
} EXEHEAD;

typedef struct {
    unsigned long str;
    unsigned long fun;
    unsigned int  scr;
    unsigned int  pri;
} ACTLIST;

char G_atype='A';

int faname(char *name)
{
    int i;
    for (i=0;i<G_numan;i++) if (!strncmp(G_anames[i],name,8)) return(i+1);
    return(0);
}
void addaname(char *name)
{
    char tmp[11];
    sprintf(tmp,"%-8.8s %c",name,G_atype);
    if (!faname(tmp)) G_anames[G_numan++]=strdup(tmp);
}
int getactmap(void)
{
	FILE *fp;
	unsigned char b[80],*t;

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

void loadactions(char *sys)
{
    char tmp[80],c;
    int fd,j,i,nn;
    long l;
    sprintf(tmp,"%s%sI.DAT",G_config,sys);

    if ((fd=open(tmp,O_RDONLY|O_BINARY))==(-1)) return;
    read(fd,&nn,sizeof(int));
    if (nn==0x5A5A) {
        read(fd,&nn,sizeof(int));
        for (i=0;i<nn;i++) {
            read(fd,&c,sizeof(char));
            read(fd,&c,sizeof(char));
            read(fd,&l,sizeof(long));
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
            read(fd,&c,sizeof(char));
            read(fd,&c,sizeof(char));
            read(fd,&j,sizeof(int));
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
    return(strcmp(*(char **)a,*(char **)b));
}
void loadallforms(void)
{
    int i;
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
void setup(char *name)
{
    int i,cnt1,cnt2;
    int fd;
    grafix();
    upscr();
    readconfig(name);

    strcpy(G_sysname,name);
    G_tcnt=0;
    memcpy(G_textfile,G_textfile2,80);
    loadtext(G_system);
    G_text2=MALLOC(1000*sizeof(char *));
    memcpy(G_text2,G_text,G_tcnt*sizeof(char *));
    G_tname2=MALLOC(1000*sizeof(char *));
    memcpy(G_tname2,G_tname,G_tcnt*sizeof(char *));
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

    G_anames=malloc(1000*sizeof(char *));
    G_numan=0;
    loadactions(G_system);
    getactmap();
    G_atype='F';
    loadallforms();

    G_anames=realloc(G_anames,G_numan*sizeof(char *));
    qsort(G_anames,G_numan,sizeof(char *),ancmp);

    settextstyle(0,0,0);
    G_sysfh=textheight("8g")+3;
    G_sysfw=textwidth("8");
    G_scrx=14;
    G_scry=G_maxy-(30+G_scrh*G_fnth);
    memcpy(&G_cform,0,sizeof(G_cform));
    G_cform.items=NULL;
//    G_pbuf=malloc(132*132*sizeof(int));
    G_pbuf=NULL;
//    if (G_pbuf==NULL) {
//        error("Cant get enough memory\n for print page.\nPrinting disabled!");
        G_mmopt[8].col=7;
        G_mmopt[8].type=0;
//    }
    fd=open("GPAD.but",O_RDONLY|O_BINARY);
    read(fd,&G_bmw,sizeof(int));
    read(fd,&G_bmh,sizeof(int));
    read(fd,&G_bis,sizeof(int));
    for (i=0;i<5;i++) {
        G_bm[i]=malloc(G_bis);
        read(fd,G_bm[i],G_bis);
    }
    close(fd);
    setupwin(G_maxx,G_maxy);
    downscr();
}
int shutdown(void)
{
    int i;
    windown();
    closegraph();
    for (i=0;i<G_numidx;i++) {
        if (G_forms[i]!=NULL) {
            freeform(G_forms[i]);
            FREE(G_forms[i]);
        }
    }
    freeformidx();
    return(0);
}
int main(int argc,char *argv[])
{
    if (argc<2) {
        printf("%s",G_usage);
        return(1);
    }
    setup(argv[1]);

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

    for (;;) poll();

    return(shutdown());
}
 
 
 

