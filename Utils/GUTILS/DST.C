#define DST_C

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "types.h"
#include "dst.h"
#include "control.h"
#include "config.h"
// return the store number for 'name'
int snum(char *name)
{
    static int i=(-1);
    static char tmp[10];

    if (!strcmp(tmp,name)) RETURN(i);

    strcpy(tmp,name);

    for (i=0;i<G_nums;i++) if (!strcmp(G_store[i].name,name)) RETURN(i);

    i=(-1);

    RETURN(i);
}
// return the field number for field 'fname' in table 'name'
int fnum(char *name,char *fname)
{
    int i,s;
    LOG('E',M_DST,2);

    if ((s=snum(name))<0) RETURN(-1);

    for (i=0;i<G_store[s].numitem;i++) {
        if (!strcmp(G_lib[G_store[s].li[i]].name,fname)) RETURN(i);
    }
    RETURN(-1);
}
// return the key number for field 'fname' in table 'name'
int knum(char *name,char *fname)
{
    int f,i,s,mask;
    LOG('E',M_DST,3);

    if ((s=snum(name))<0) RETURN(0);
    if ((f=fnum(name,fname))<0) RETURN(0);

    if ((G_store[s].skey&(0x80000000L>>f))!=0) RETURN(f+1);

    RETURN(0);
}
// read the datastore information from fd into s and set scnt to number of stores
int readstores(int fd,PSTORE s,int *scnt)
{
    LOG('E',M_DST,4);
    if (read(fd,scnt,sizeof(int))!=sizeof(int)) RETURN(0);
    if (read(fd,s,*scnt*sizeof(STORE))!=(*scnt*sizeof(STORE))) RETURN(0);
    RETURN(1);
}
// write the datastore information to fd from s where scnt is the number of stores
int writestores(int fd,PSTORE s,int scnt)
{
    LOG('E',M_DST,5);
    if (write(fd,&scnt,sizeof(int))!=sizeof(int)) RETURN(0);
    if (write(fd,s,scnt*sizeof(STORE))!=(scnt*sizeof(STORE))) RETURN(0);
    RETURN(1);
}
// read the library infomation (DATA DICTIONARY)
int readlib(int fd,PLSTOREF l,int *icnt)
{
    LOG('E',M_DST,6);
    if (read(fd,icnt,sizeof(int))!=sizeof(int)) RETURN(0);
    if (read(fd,l,*icnt*sizeof(LSTOREF))!=(*icnt*sizeof(LSTOREF))) RETURN(0);
    RETURN(1);
}
// write the library infomation (DATA DICTIONARY)
int writelib(int fd,PLSTOREF l,int icnt)
{
    LOG('E',M_DST,7);
    if (write(fd,&icnt,sizeof(int))!=sizeof(int)) RETURN(0);
    if (write(fd,l,icnt*sizeof(LSTOREF))!=(icnt*sizeof(LSTOREF))) RETURN(0);
    RETURN(1);
}
// load the datastore data into memory
int loadsdata(char *sys)
{
    int fd;
    char tmp[80];
    LOG('E',M_DST,8);

    sprintf(tmp,"%s%sD.DAT",G_config,sys);
    fd=open(tmp,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURN(0);
    if (!readstores(fd,G_store,&G_nums)) {
        close(fd);
        RETURN(0);
    }
    if (!readlib(fd,G_lib,&G_numl)) {
        close(fd);
        RETURN(0);
    }
    close(fd);
    doupdates();
    RETURN(1);
}
// save the datastore data from memory
int savesdata(char *sys)
{
    int fd;
    char tmp[80];
    LOG('E',M_DST,9);
    sprintf(tmp,"%s%sD.DAT",G_config,sys);
    fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
    if (fd==(-1)) RETURN(0);
    if (!writestores(fd,G_store,G_nums)) {
        close(fd);
        RETURN(0);
    }
    if (!writelib(fd,G_lib,G_numl)) {
        close(fd);
        RETURN(0);
    }
    close(fd);
    RETURN(1);
}
// load the configuration information on FILE and RECORD updates into an array
void doupdates(void)
{
    char tmp[90],*t;
    int i;

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
}

