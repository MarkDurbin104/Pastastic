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
#include "memory.h"
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
INT _cdecl ficmp(const void *a,const void *b)
{
	ENTRY(1300);
    RETURNV(strcmp(((FINDEX *)a)->name,((FINDEX *)b)->name));
}
LONG getformidx(CHAR *name)
{
    INT i=0,fd;
    LONG sod=0L;
    LONG ofs=0L;
	LONG len,tl,l1;
    CHAR tmp[80];

	ENTRY(1310);
    if (G_numidx==0) {
        sprintf(tmp,"%s%sN.DAT",G_config,G_system);
        if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) RETURNV(-1L);
		len=filelength(fd);
		if (G_formspace!=NULL) FREE(G_formspace);
    	G_formspace=MALLOC(10000);
		setupblk(G_system,len);
        tl=0;
        while (tl<len) {
           	l1=read(fd,G_formspace,10000);
            if (l1<=0) {
                tl=len;
            } else {
			    savepblk(G_system,G_formspace,tl,l1);
                tl+=l1;
            }
		}
		close(fd);
		if (G_formspace!=NULL) {
			FREE(G_formspace);
			G_formspace=NULL;
        	restpblk(G_system,&i,ofs,sizeof(INT));
        	if (i!=0x5A4B) {
            	G_formsize=25;
            	G_fieldsize=134;  
        	} else {
            	sod=(LONG)(sizeof(INT)*4);
	        	restpblk(G_system,&G_fversion ,ofs+2,sizeof(INT));
	        	restpblk(G_system,&G_formsize ,ofs+4,sizeof(INT));
	        	restpblk(G_system,&G_fieldsize,ofs+6,sizeof(INT));
        	}
			ofs=sod;
        	while (ofs<len) {
	        	restpblk(G_system,&G_newform,ofs,G_formsize);
				ofs+=G_formsize+(G_newform.numitem*G_fieldsize);
            	G_numidx++;
        	}
        	G_fid=MALLOC(G_numidx*sizeof(FINDEX));
        	if (G_fid==NULL) {
            	G_numidx=(-1);
            	RETURNV(-1L);
        	}
			ofs=sod;
        	G_numidx=0;
        	while (ofs<len) {
	        	restpblk(G_system,&G_newform,ofs,G_formsize);
            	strcpy(G_fid[G_numidx].name,G_newform.name);
            	G_fid[G_numidx].index=ofs;
				ofs+=G_formsize+(G_newform.numitem*G_fieldsize);
            	G_numidx++;
        	}
        	qsort(G_fid,G_numidx,sizeof(FINDEX),ficmp);
		} else {
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
        	while (read(fd,&G_newform,G_formsize)==G_formsize) {
				lseek(fd,G_newform.numitem*G_fieldsize,SEEK_CUR);
            	G_numidx++;
        	}
        	G_fid=MALLOC(G_numidx*sizeof(FINDEX));
        	if (G_fid==NULL) {
            	G_numidx=(-1);
            	close(fd);
            	RETURNV(-1L);
        	}
        	ofs=lseek(fd,sod,SEEK_SET);
        	G_numidx=0;
        	while (read(fd,&G_newform,G_formsize)==G_formsize) {
				lseek(fd,G_newform.numitem*G_fieldsize,SEEK_CUR);
            	strcpy(G_fid[G_numidx].name,G_newform.name);
            	G_fid[G_numidx].index=ofs;
            	ofs=lseek(fd,0L,SEEK_CUR);
            	G_numidx++;
        	}
        	close(fd);
        	qsort(G_fid,G_numidx,sizeof(FINDEX),ficmp);
		}
    }
    for (i=0;i<G_numidx;i++) 
        if (!strcmp(name,G_fid[i].name)) RETURNV(G_fid[i].index);
    RETURNV(-1L);
}
CHAR *fnameidx(LONG ofs)
{
	INT i;
	ENTRY(1320);
    for (i=0;i<G_numidx;i++)
		if (G_fid[i].index==ofs) RETURNV(G_fid[i].name);
	RETURNV(NULL);
}
// save the text information
INT savetext(CHAR *sys)
{
    FILE *fp;
    INT i;
    CHAR tmp[80];
	ENTRY(1330);

    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(tmp,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(tmp,G_textfile);

    fp=fopen(tmp,"w");
    if (fp==NULL) RETURNV(0);
    for (i=0;i<G_tcnt;i++) {
        fprintf(fp,"%s %s\n",G_tname[i],&(G_tname[i][9]));
    }
    fclose(fp);
    RETURNV(1);
}
// load the text information
INT loadtext(CHAR *sys)
{
    INT nt=0,hadtildi=0;
    FILE *fp;
	INT newt=0;
    CHAR tmp[100];
    CHAR buf[100];
	CHAR *t,*u;
	ENTRY(1340);
    G_nut=0;
    if (G_textfile[strlen(G_textfile)-1]=='\\')
        sprintf(G_lasttext,"%s%sT.DAT",G_textfile,sys);
    else
        strcpy(G_lasttext,G_textfile);

    if (G_tname!=NULL) freetext();

	if (isblk(G_lasttext)) {
		newt=0;
       	restpblk(G_lasttext,&nt,0L,(LONG)sizeof(INT));
       	restpblk(G_lasttext,&G_nut,2L,(LONG)sizeof(INT));
        hadtildi=1;
	} else {
        if ((fp=fopen(G_lasttext,"r"))!=NULL) {
            while (fgets(buf,160,fp)!=NULL) nt++;
            fclose(fp);
        }
       	setupblk(G_lasttext,(LONG)nt*100L+(LONG)sizeof(INT)*2);
        savepblk(G_lasttext,&nt,0L,(LONG)sizeof(INT));
		newt=1;
        nt=0;
        if ((fp=fopen(G_lasttext,"r"))!=NULL) {
            while (fgets(buf,160,fp)!=NULL) {
                buf[strlen(buf)-1]=0;
                buf[8]=0;
                savepblk(G_lasttext,buf,(LONG)nt*100L+(LONG)sizeof(INT)*2,100L);
                nt++;
                if (!hadtildi) {
                    if (buf[0]=='~') hadtildi=1;
                    G_nut++;
                }
            }
        }
	}
    if (!hadtildi) {
        G_nut=0;
    } else {
        G_tname=MALLOC(G_nut*sizeof(CHAR *));
        if (G_tname==NULL) RETURNV(0);
    }
    savepblk(G_lasttext,&G_nut,2L,(LONG)sizeof(INT));
	G_tcnt=0;
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
                    sendmsg("OUTPUT1",'TL',t);
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
                        sendmsg("OUTPUT1",'TL',u);
                        sendmsg("OUTPUT1",'TL',t+1);
					}
					break;
			}
		}
		G_tcnt++;
	}
    RETURNV(1);
}
CHAR *atextstr(INT i)
{
    static CHAR buf[100];
    restpblk(G_lasttext,buf,(LONG)i*100L+(LONG)sizeof(INT)*2,100L);
    return(&(buf[9]));
}
// free the text information buffers
void freetext(void)
{
    INT i;
	ENTRY(1350);
    if (G_tname!=NULL) {
        for (i=0;i<G_nut;i++) {
            if (G_tname[i]!=NULL) FREE(G_tname[i]);
        }
		FREE(G_tname);
	    G_tname=NULL;
    }
    G_tcnt=0;
    G_nut=0;
	RETURN;
}
LONG isform(CHAR *name)
{
	ENTRY(1360);
    RETURNV(getformidx(name));
}
INT getfedata(LONG ofs,PFORM sf)
{
    INT i;
	ENTRY(1370);
    if (!restpblk(G_system,sf,ofs,G_formsize)) RETURNV(0);
	ofs+=G_formsize;
    if ((sf->items=MALLOC(sf->numitem*sizeof(FORMF)))==NULL) RETURNV(0);
    memset(sf->items,0,sf->numitem*sizeof(FORMF));
    if (G_fieldsize!=sizeof(FORMF)) {
        for (i=0;i<sf->numitem;i++) {
		    if (!restpblk(G_system,&(sf->items[i]),ofs,G_fieldsize)) RETURNV(0);
			ofs+=G_fieldsize;
        }
    } else {
	    if (!restpblk(G_system,sf->items,ofs,sf->numitem*G_fieldsize)) RETURNV(0);
    } 
    RETURNV(1);
}
INT getfdata(INT fd,LONG ofs,PFORM sf)
{
    INT i;
	ENTRY(1380);
	lseek(fd,ofs,SEEK_SET);
    if ((read(fd,sf,G_formsize))!=G_formsize) RETURNV(0);
    if ((sf->items=MALLOC(sf->numitem*sizeof(FORMF)))==NULL) RETURNV(0);
    memset(sf->items,0,sf->numitem*sizeof(FORMF));
    if (G_fieldsize!=sizeof(FORMF)) {
        for (i=0;i<sf->numitem;i++) {
            if (read(fd,&(sf->items[i]),G_fieldsize)!=G_fieldsize) RETURNV(0);
        }
    } else {
        if (read(fd,sf->items,sf->numitem*G_fieldsize)
            !=sf->numitem*G_fieldsize) RETURNV(0);
    } 
    RETURNV(1);
}
INT loadformidx(PFORM sf,LONG ofs)
{
    CHAR tmp[80];
    INT fd;
	ENTRY(1390);
	if (isblk(G_system)) {
    	if (!getfedata(ofs,sf)) RETURNV(0);
	} else {
    	sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    	if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) RETURNV(0);
    	if (!getfdata(fd,ofs,sf)) {
        	close(fd);
        	RETURNV(0);
    	}
    	close(fd);
	}
    RETURNV(1);
}
INT  loadform(PFORM sf)
{
    CHAR tmp[80];
    INT fd;
    LONG ofs;
	ENTRY(1400);
    if ((ofs=isform(sf->name))==(-1L)) RETURNV(0);
	if (isblk(G_system)) {
    	if (!getfedata(ofs,sf)) RETURNV(0);
	} else {
    	sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    	if ((fd=open(tmp,O_RDWR|O_BINARY))==(-1)) RETURNV(0);

    	if (!getfdata(fd,ofs,sf)) {
        	close(fd);
        	RETURNV(0);
    	}

    	close(fd);
	}
    RETURNV(1);
}
void freeform(PFORM f)
{
	ENTRY(1410);
    if (f->items!=NULL) FREE(f->items);
    f->items=NULL;
	RETURN;
}
// Re-order form fields l->r t->b
INT _cdecl usort(const void *a,const void *b)
{
	ENTRY(1420);

    if (((PFORMF)a)->pos.y>((PFORMF)b)->pos.y) RETURNV(2);
    if (((PFORMF)a)->pos.y<((PFORMF)b)->pos.y) RETURNV(-2);
    if (((PFORMF)a)->pos.x>((PFORMF)b)->pos.x) RETURNV(1);
    if (((PFORMF)a)->pos.x<((PFORMF)b)->pos.x) RETURNV(-1);
    RETURNV(0);
}
// Re-order form fields t->b l->r
INT _cdecl fsort(const void *a,const void *b)
{
	ENTRY(1430);

    if (((PFORMF)a)->pos.x>((PFORMF)b)->pos.x) RETURNV(2);
    if (((PFORMF)a)->pos.x<((PFORMF)b)->pos.x) RETURNV(-2);
    if (((PFORMF)a)->pos.y>((PFORMF)b)->pos.y) RETURNV(1);
    if (((PFORMF)a)->pos.y<((PFORMF)b)->pos.y) RETURNV(-1);
    RETURNV(0);
}
// Re-order form fields given type
void orderform(PFORM f,INT type)
{
	ENTRY(1440);
	if ((f==NULL)||(f->items==NULL)) return;
    if (type==0)
        qsort(f->items,f->numitem,G_fieldsize,fsort);
    else
        qsort(f->items,f->numitem,G_fieldsize,usort);
	RETURN;
}
INT addformf(PFORM f,PFORMF fld)
{
    PFORMF tmp;
	ENTRY(1450);
    if (f->items!=NULL) {
        f->numitem++;
        tmp=f->items;
        f->items=MALLOC(f->numitem*sizeof(FORMF));
        if (f->items==NULL) {
            f->numitem--;
            f->items=tmp;
            RETURNV(0);
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
            RETURNV(0);
        }
        memcpy(f->items,fld,sizeof(FORMF));
    }
    RETURNV(1);
}
INT delformf(PFORM f,INT id)
{
    PFORMF tmp;
	ENTRY(1460);
    f->numitem--;
    if (f->numitem<=0) {
        f->numitem=0;
        if (f->items!=NULL) {
            FREE(f->items);
            f->items=NULL;
        }
        RETURNV(1);
    }
    tmp=f->items;
    f->items=MALLOC(f->numitem*sizeof(FORMF));
    if (f->items==NULL) {
        f->numitem++;
        f->items=tmp;
        RETURNV(0);
    }
    if (id>0) memcpy(f->items,tmp,sizeof(FORMF)*id);
    if (id<f->numitem) memcpy(&(f->items[id]),&tmp[id+1],sizeof(FORMF)*(f->numitem-id));
    FREE(tmp);
    RETURNV(1);
}
