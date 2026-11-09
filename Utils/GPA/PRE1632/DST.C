#define DST_C

#include <stdio.h>
#include <string.h>
#include <search.h>
#include <fcntl.h>
#include <io.h>
#include <malloc.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "types.h"
#include "dst.h"
#include "control.h"
#include "config.h"
// RETURN the store number for 'name'
INT sncmp(NAMEBUFFER *a,NAMEBUFFER *b)
{
    return(strcmp(a->n,b->n));
}
INT snum(CHAR *name)
{
    INT i=(-1);
    static NAMEBUFFER *buf;
    NAMEBUFFER *r;
	ENTRY(1470);
    if (buf==NULL) {
        buf=malloc(G_nums*sizeof(NAMEBUFFER));
        if (buf!=NULL) {
            for (i=0;i<G_nums;i++) {
                strcpy(buf[i].n,G_store[i].name);
                buf[i].i=i;
            }
            qsort(buf,G_nums,sizeof(NAMEBUFFER),(QSPTR)sncmp);
        } else {
            RETURNV(-1);
        }
    }
    r=(NAMEBUFFER *)bsearch((NAMEBUFFER *)name,buf,G_nums,sizeof(NAMEBUFFER),(QSPTR)sncmp);
    if (r!=NULL) RETURNV(r->i);
    RETURNV(-1);
}
// RETURN the field number for field 'fname' in table 'name'
INT fnum(CHAR *name,CHAR *fname)
{
    INT i,s;
	ENTRY(1480);

    if ((s=snum(name))<0) RETURNV(-1);

    for (i=0;i<G_store[s].numitem;i++) {
        if (!strcmp(G_lib[G_store[s].li[i]].name,fname)) RETURNV(i);
    }
    RETURNV(-1);
}
// RETURN the key number for field 'fname' in table 'name'
INT knum(CHAR *name,CHAR *fname)
{
    INT f,s;
	ENTRY(1490);

    if ((s=snum(name))<0) RETURNV(0);
    if ((f=fnum(name,fname))<0) RETURNV(0);

    if ((G_store[s].skey&(0x80000000L>>f))!=0) RETURNV(f+1);

    RETURNV(0);
}
// read the datastore information from fd into s and set scnt to number of stores
INT readstores(INT fd,PSTORE s,INT *scnt)
{
	ENTRY(1500);
    if (read(fd,scnt,sizeof(INT))!=sizeof(INT)) RETURNV(0);
    if (read(fd,s,*scnt*sizeof(STORE))!=(*scnt*sizeof(STORE))) RETURNV(0);
    RETURNV(1);
}
// write the datastore information to fd from s where scnt is the number of stores
INT writestores(INT fd,PSTORE s,INT scnt)
{
	ENTRY(1510);
    if (write(fd,&scnt,sizeof(INT))!=sizeof(INT)) RETURNV(0);
    if (write(fd,s,scnt*sizeof(STORE))!=(scnt*sizeof(STORE))) RETURNV(0);
    RETURNV(1);
}
// read the library infomation (DATA DICTIONARY)
INT readlib(INT fd,PLSTOREF l,INT *icnt)
{
	ENTRY(1520);
    if (read(fd,icnt,sizeof(INT))!=sizeof(INT)) RETURNV(0);
    if (read(fd,l,*icnt*sizeof(LSTOREF))!=(*icnt*sizeof(LSTOREF))) RETURNV(0);
    RETURNV(1);
}
// write the library infomation (DATA DICTIONARY)
INT writelib(INT fd,PLSTOREF l,INT icnt)
{
	ENTRY(1530);
    if (write(fd,&icnt,sizeof(INT))!=sizeof(INT)) RETURNV(0);
    if (write(fd,l,icnt*sizeof(LSTOREF))!=(icnt*sizeof(LSTOREF))) RETURNV(0);
    RETURNV(1);
}
// load the datastore data into memory
INT loadsdata(CHAR *sys)
{
    INT fd,i;
    CHAR tmp[80];
	ENTRY(1540);

    sprintf(tmp,"%s%sD.DAT",G_config,sys);
    fd=open(tmp,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);

    if (read(fd,&i,sizeof(INT))!=sizeof(INT)) RETURNV(0);
	lseek(fd,-2L,SEEK_CUR);
    if (G_store!=NULL) FREE(G_store);
    G_store=MALLOC((i+5)*sizeof(STORE));
    if (G_store==NULL) RETURNV(0);
    if (!readstores(fd,G_store,&G_nums)) {
        close(fd);
        RETURNV(0);
    }

    if (read(fd,&i,sizeof(INT))!=sizeof(INT)) RETURNV(0);
	lseek(fd,-2L,SEEK_CUR);
    if (G_lib!=NULL) FREE(G_lib);
    G_lib=MALLOC(i*sizeof(LSTOREF));
    if (G_lib==NULL) RETURNV(0);
    if (!readlib(fd,G_lib,&G_numl)) {
        close(fd);
        RETURNV(0);
    }
    close(fd);
    doupdates();
    RETURNV(1);
}
// save the datastore data from memory
INT savesdata(CHAR *sys)
{
    INT fd;
    CHAR tmp[80];
	ENTRY(1550);
    sprintf(tmp,"%s%sD.DAT",G_config,sys);
    fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
    if (fd==(-1)) RETURNV(0);
    if (!writestores(fd,G_store,G_nums)) {
        close(fd);
        RETURNV(0);
    }
    if (!writelib(fd,G_lib,G_numl)) {
        close(fd);
        RETURNV(0);
    }
    close(fd);
    RETURNV(1);
}
// load the configuration information on FILE and RECORD updates into an array
void doupdates(void)
{
    CHAR tmp[160],*t;
    INT i;
	ENTRY(1560);

    memset(G_frupd,0,sizeof(G_frupd));
    strcpy(tmp,G_rupdate);
    t=strtok(tmp,", \t;");
    while (t!=NULL) {
        i=snum(t);
        if (i!=(-1)) G_frupd[i]=RECUPDATE;
        t=strtok(NULL,", \t;");
    }
    strcpy(tmp,G_fupdate);
    t=strtok(tmp,", \t;");
    while (t!=NULL) {
        i=snum(t);
        if (i!=(-1)) G_frupd[i]|=FILEUPDATE;
        t=strtok(NULL,", \t;");
    }
	RETURN;
}

