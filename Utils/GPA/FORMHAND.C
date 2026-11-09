#define FORMHAND_C

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <stdlib.h>
#include <ctype.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "formproc.h"
#include "formhand.h"
#include "control.h"
#include "config.h"
#include "message.h"

FORM G_newform;
CHAR  G_lasttext[100];
void freeformidx(void)
{
	ENTRY(1290);
    if (G_fid!=NULL) {
        FREE(G_fid);
        G_fid=NULL;
    }
	if (G_formspace!=NULL) {
		FREE(G_formspace);
		G_formspace=NULL;
	}
    G_numidx=0;
	RETURN;
}
INT ficmp(PFORM a,PFORM b)
{
	ENTRY(1300);
    RETURNV(strcmp(a->name,b->name));
}
INT getformidx(CHAR *name)
{
    INT i,fd;
    INT16 *base;
    LONG ofs;
	LONG len;
    CHAR tmp[80];

	ENTRY(1310);
    if (G_numidx==0) {
        sprintf(tmp,"%s%sN.DAT",G_config,G_system);
        if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) RETURNV(-1);
		len=filelength(fd);
        read(fd,tmp,(sizeof(INT16)*4));
        base=(INT16*)tmp;
        if (*base!=0x5A4B) RETURNV(-1);
        base++;
        G_fversion =*(base++);
	    G_formsize =*(base++);
	    G_fieldsize=*(base);
        ofs=(LONG)(sizeof(INT16)*4);
        G_fid=MALLOC(0x3000*sizeof(PFORM));
        while (ofs<len) {
            G_fid[G_numidx]=MALLOC(sizeof(FORM));
            read(fd,G_fid[G_numidx],G_formsize);
			ofs+=G_formsize;
            G_fid[G_numidx]->items=MALLOC(G_fid[G_numidx]->numitem*sizeof(FORMF));
            read(fd,G_fid[G_numidx]->items,(G_fid[G_numidx]->numitem*G_fieldsize));

            // Fix a bug in GPAD -- This code should be removed
            for (i=0;i<G_fid[G_numidx]->numitem;i++) {
                if (G_fid[G_numidx]->items[i].class==FF_TABL) {
                    strcpy(G_fid[G_numidx]->items[i].name,"NONE    ");
                    G_fid[G_numidx]->items[i].type[0]=0;
                }
            }


			ofs+=(G_fid[G_numidx]->numitem*G_fieldsize);
            G_numidx++;
        }
        G_fid=REALLOC(G_fid,G_numidx*sizeof(PFORM));
    	close(fd);
//        qsort(G_fid,G_numidx,sizeof(PFORM),(QSPTR)ficmp);
    }
    for (i=0;i<G_numidx;i++) 
        if (!strcmp(name,G_fid[i]->name)) RETURNV(i);
    RETURNV(-1);
}
INT isform(CHAR *name)
{
	ENTRY(1360);
    RETURNV(getformidx(name));
}
INT getfedata(INT ofs,PFORM sf)
{
	ENTRY(1370);
    if ((ofs<0)||(ofs>G_numidx)) RETURNV(0);
    memcpy(sf,G_fid[ofs],sizeof(FORM));
    if ((sf->items=MALLOC(sf->numitem*sizeof(FORMF)))==NULL) RETURNV(0);
    memcpy(sf->items,G_fid[ofs]->items,sf->numitem*sizeof(FORMF));
    RETURNV(1);
}
INT loadformidx(PFORM sf,INT ofs)
{
	ENTRY(1390);
  	RETURNV(getfedata(ofs,sf));
}
INT loadform(PFORM sf)
{
	ENTRY(1400);
  	RETURNV(getfedata(isform(sf->name),sf));
}
void freeform(PFORM f)
{
	ENTRY(1410);
    if (f->items!=NULL) FREE(f->items);
    f->items=NULL;
	RETURN;
}
// Re-order form fields l->r t->b
INT usort(PFORMF a,PFORMF b)
{
	ENTRY(1420);

    if (a->pos.y>b->pos.y) RETURNV(2);
    if (a->pos.y<b->pos.y) RETURNV(-2);
    if (a->pos.x>b->pos.x) RETURNV(1);
    if (a->pos.x<b->pos.x) RETURNV(-1);
    RETURNV(0);
}
// Re-order form fields t->b l->r
INT fsort(PFORMF a,PFORMF b)
{
	ENTRY(1430);

    if (a->pos.x>b->pos.x) RETURNV(2);
    if (a->pos.x<b->pos.x) RETURNV(-2);
    if (a->pos.y>b->pos.y) RETURNV(1);
    if (a->pos.y<b->pos.y) RETURNV(-1);
    RETURNV(0);
}
// Re-order form fields given type
void orderform(PFORM f,INT type)
{
	ENTRY(1440);
	if ((f==NULL)||(f->items==NULL)) return;
    if (type==0)
        qsort(f->items,f->numitem,G_fieldsize,(QSPTR)fsort);
    else
        qsort(f->items,f->numitem,G_fieldsize,(QSPTR)usort);
	RETURN;
}

//********************************* TEXT ****************************
// load the text information
INT loadtext(CHAR *sys)
{
    INT hadtildi=0;
    FILE *fp;
    CHAR buf[100];
	ENTRY(1340);
    G_nut=0;
    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(G_lasttext,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(G_lasttext,G_textfile);

    if (G_tname!=NULL) freetext();          // language switch, free up old text
    G_tname=MALLOC(0x3000*sizeof(CHAR *));
	G_tcnt=0;
    if (G_tname==NULL) RETURNV(0);
    if ((fp=fopen(G_lasttext,"r"))!=NULL) {
        while (fgets(buf,160,fp)!=NULL) {
            buf[strlen(buf)-1]=0;
            G_tname[G_tcnt]=STRDUP(buf);
            G_tname[G_tcnt][8]=0;
            G_tcnt++;
            if (!hadtildi) {
                if (buf[0]=='~') hadtildi=1;
                G_nut++;
            }
        }
	}
    if (!hadtildi) {
        G_nut=0;
    }
    G_tname=REALLOC(G_tname,G_tcnt*sizeof(CHAR *));
/*
	while (G_tcnt<nt) {
        restpblk(G_lasttext,buf,(LONG)G_tcnt*100L+(LONG)sizeof(INT)*2,100L);
		if (G_tcnt<G_nut) {
            G_tname[G_tcnt]=STRDUP(buf);
            if (G_tname[G_tcnt]==NULL) RETURNV(0);
        }
		if ((newt)&&(buf[9]=='~')) {
			t=&(buf[10]);
			switch (*t) {
				case 'P':
				case 'S':
				case 'A':
					t++;
					while (!isalpha(*t)&&(*t)) t++;
                    sendmsg("OUTPUT1",MESSAGE_TL,t);
					break;
				case 'R':
					strcpy(tmp,t);
					t=tmp;
					t++;
					while (!isalpha(*t)&&(*t)) t++;
					u=t;
					while ((*t!=',')&&(*t)) t++;
					if (*t) {
						*t=0;
                        sendmsg("OUTPUT1",MESSAGE_TL,u);
                        sendmsg("OUTPUT1",MESSAGE_TL,t+1);
					}
					break;
			}
		}
		G_tcnt++;
	}
*/
    RETURNV(1);
}
CHAR *atextstr(INT i)
{
    return(&(G_tname[i][9]));
}
// free the text information buffers
void freetext(void)
{
    INT i;
	ENTRY(1350);
    if (G_tname!=NULL) {
        for (i=0;i<G_tcnt;i++) {
            if (G_tname[i]!=NULL) FREE(G_tname[i]);
        }
		FREE(G_tname);
	    G_tname=NULL;
    }
    G_tcnt=0;
    G_nut=0;
	RETURN;
}
