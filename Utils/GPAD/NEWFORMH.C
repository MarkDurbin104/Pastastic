#define FORMHAND_C

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <alloc.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "formproc.h"
#include "formhand.h"
#include "control.h"
#include "config.h"

void freeformidx(void)
{
    if (G_fid!=NULL) {
        FREE(G_fid);
        G_fid=NULL;
    }
    G_numidx=0;
}
int ficmp(const void *a,const void *b)
{
    return(strcmp(((FINDEX *)a)->name,((FINDEX *)b)->name));
}
LONG getformidx(CHAR *name)
{
    INT i=0,fd;
    LONG sod=0L;
    FORM nf;
    LONG ofs=0L;
    CHAR tmp[80];

    if (G_numidx==0) {
        sprintf(tmp,"%s%sN.DAT",G_config,G_system);
        if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) return(-1L);
        read(fd,&i,sizeof(INT));
        if (i!=0x5A4B) {
            lseek(fd,0,SEEK_SET);
            G_formsize=25;
            G_fieldsize=134;  
        } else {
            sod=(LONG)(sizeof(INT)*4);
            read(fd,&G_fversion,sizeof(INT));
            read(fd,&G_formsize,sizeof(INT));
            read(fd,&G_fieldsize,sizeof(INT));
        }
        while (read(fd,&nf,G_formsize)==G_formsize) {
            nf.items=MALLOC(nf.numitem*sizeof(FORMF));
            read(fd,nf.items,nf.numitem*G_fieldsize);
            FREE(nf.items);
            G_numidx++;
        }
        G_fid=MALLOC(G_numidx*sizeof(FINDEX));
        if (G_fid==NULL) {
            G_numidx=(-1);
            close(fd);
            return(-1L);
        }
        ofs=lseek(fd,sod,SEEK_SET);
        G_numidx=0;
        while (read(fd,&nf,G_formsize)==G_formsize) {
            nf.items=MALLOC(nf.numitem*sizeof(FORMF));
            read(fd,nf.items,nf.numitem*G_fieldsize);
            FREE(nf.items);
            strcpy(G_fid[G_numidx].name,nf.name);
            G_fid[G_numidx].index=ofs;
            ofs=lseek(fd,0L,SEEK_CUR);
            G_numidx++;
        }
        close(fd);
        qsort(G_fid,G_numidx,sizeof(FINDEX),ficmp);
    }
    for (i=0;i<G_numidx;i++) 
        if (!strcmp(name,G_fid[i].name)) return(G_fid[i].index);
    return(-1L);
}
// save the text information
INT savetext(CHAR *sys)
{
    FILE *fp;
    INT i;
    CHAR tmp[80];
    LOG('E',M_FORMHAND,1);

    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(tmp,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(tmp,G_textfile);

    fp=fopen(tmp,"w");
    if (fp==NULL) RETURN(0);
    for (i=0;i<G_tcnt;i++) {
        fprintf(fp,"%s %s\n",G_tname[i],G_text[i]);
    }
    fclose(fp);
    RETURN(1);
}
// load the text information
INT loadtext(CHAR *sys)
{
    FILE *fp;
	 INT xit=0;
    CHAR tmp[80],instr[161];
    LOG('E',M_FORMHAND,2);

    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(tmp,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(tmp,G_textfile);

    fp=fopen(tmp,"r");
    if (fp==NULL) RETURN(0);

    while ((!xit)&&(fgets(instr,160,fp)!=NULL)) {
		if (*instr=='~') xit=1;
	}
	if (!xit) {
	    fseek(fp,0L,SEEK_SET);
	}
    while (fgets(instr,160,fp)!=NULL) {
        if (strlen(instr)>8) {
            instr[strlen(instr)-1]=0;
            instr[8]=0;
            G_tname[G_tcnt]=STRDUP(instr);
            G_text[G_tcnt]=STRDUP(&instr[9]);
            G_tcnt++;
        }
    }
    fclose(fp);
    RETURN(1);
}
// free the text information buffers
void freetext(void)
{
    INT i;
    for (i=0;i<G_tcnt;i++) {
        if (G_tname[i]!=NULL) {
            FREE(G_tname[i]);
            G_tname[i]=NULL;
        }
        if (G_text[i]!=NULL) {
            FREE(G_text[i]);
            G_text[i]=NULL;
        }
    }
    G_tcnt=0;
}
LONG isform(CHAR *name)
{
    return(getformidx(name));
}
INT getfdata(INT fd,LONG ofs,PFORM sf)
{
    INT i;
    lseek(fd,ofs,SEEK_SET);
    if ((read(fd,sf,G_formsize))!=G_formsize) return(0);
    if ((sf->items=MALLOC(sf->numitem*sizeof(FORMF)))==NULL) return(0);
    memset(sf->items,0,sf->numitem*sizeof(FORMF));
    if (G_fieldsize!=sizeof(FORMF)) {
        for (i=0;i<sf->numitem;i++) {
            if (read(fd,&(sf->items[i]),G_fieldsize)!=G_fieldsize) return(0);
        }
    } else {
        if (read(fd,sf->items,sf->numitem*G_fieldsize)
            !=sf->numitem*G_fieldsize) return(0);
    } 
    return(1);
}
INT loadformidx(PFORM sf,LONG ofs)
{
    CHAR tmp[80];
    INT fd;
    sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) return(0);
    if (!getfdata(fd,ofs,sf)) {
        close(fd);
        return(0);
    }
    close(fd);
    return(1);
}
INT  loadform(PFORM sf)
{
    CHAR tmp[80];
    INT fd;
    LONG ofs;
    if ((ofs=isform(sf->name))==(-1L)) return(0);

    sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) return(0);

    if (!getfdata(fd,ofs,sf)) {
        close(fd);
        return(0);
    }

    close(fd);
    return(1);
}
void freeform(PFORM f)
{
    if (f->items!=NULL) FREE(f->items);
    f->items=NULL;
}
// Re-order form fields l->r t->b
int usort(const void *a,const void *b)
{
    LOG('E',M_FORMHAND,13);

    if (((PFORMF)a)->pos.y>((PFORMF)b)->pos.y) RETURN(2);
    if (((PFORMF)a)->pos.y<((PFORMF)b)->pos.y) RETURN(-2);
    if (((PFORMF)a)->pos.x>((PFORMF)b)->pos.x) RETURN(1);
    if (((PFORMF)a)->pos.x<((PFORMF)b)->pos.x) RETURN(-1);
    RETURN(0);
}
// Re-order form fields t->b l->r
int fsort(const void *a,const void *b)
{
	LOG('E',M_FORMHAND,13);

    if (((PFORMF)a)->pos.x>((PFORMF)b)->pos.x) RETURN(2);
    if (((PFORMF)a)->pos.x<((PFORMF)b)->pos.x) RETURN(-2);
    if (((PFORMF)a)->pos.y>((PFORMF)b)->pos.y) RETURN(1);
    if (((PFORMF)a)->pos.y<((PFORMF)b)->pos.y) RETURN(-1);
    RETURN(0);
}
// Re-order form fields given type
void orderform(PFORM f,INT type)
{
    LOG('E',M_FORMHAND,14);
    if (type==0)
		qsort(f->items,f->numitem,sizeof(FORMF),fsort);
    else
        qsort(f->items,f->numitem,sizeof(FORMF),usort);
}
INT addformf(PFORM f,PFORMF fld)
{
    PFORMF tmp;
    if (f->items!=NULL) {
        f->numitem++;
        tmp=f->items;
        f->items=MALLOC(f->numitem*sizeof(FORMF));
        if (f->items==NULL) {
            f->numitem--;
            f->items=tmp;
            return(0);
        }
        memcpy(f->items,tmp,(f->numitem-1)*sizeof(FORMF));
        FREE(tmp);
        memcpy(&(f->items[f->numitem-1]),fld,sizeof(FORMF));
    }
    else {
        f->numitem=1;
        f->items=MALLOC(sizeof(FORMF));
        if (f->items==NULL) {
            f->numitem=0;
            return(0);
        }
        memcpy(f->items,fld,sizeof(FORMF));
    }
    return(1);
}
INT delformf(PFORM f,INT id)
{
    PFORMF tmp;
    f->numitem--;
    if (f->numitem<=0) {
        f->numitem=0;
        if (f->items!=NULL) {
            FREE(f->items);
            f->items=NULL;
        }
        return(1);
    }
    tmp=f->items;
    f->items=MALLOC(f->numitem*sizeof(FORMF));
    if (f->items==NULL) {
        f->numitem++;
        f->items=tmp;
        return(0);
    }
    if (id>0) memcpy(f->items,tmp,sizeof(FORMF)*id);
    if (id<f->numitem) memcpy(&(f->items[id]),&tmp[id+1],sizeof(FORMF)*(f->numitem-id));
    FREE(tmp);
    return(1);
}


