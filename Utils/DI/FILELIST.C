//=============================== FILELIST.C =================================
#define FILELIST_C

#include <malloc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <dir.h>
#include <io.h>
#include <fcntl.h>
#include <time.h>
#include <sys\timeb.h>
#include <sys\types.h>
#include <sys\stat.h>

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC
#define _HARDERR_FAIL 3

char *G_files[50];
int G_nump=0;
typedef struct {
    char          *name;
    unsigned int  numf;
    char          *ff_name [1024];
    unsigned short ff_ftime[1024];
    unsigned short ff_fdate[1024];
    unsigned long  ff_fsize[1024];
} fblk;
fblk *G_path[1024];
int G_numpath=0;
int G_fdo=0;
int G_maxdepth=0;
char G_curdir[100];
char G_argv1 [20];
char G_argv2 [20];
char G_ofile [20];
char G_datestr[20];
int G_lastdate=0;
int G_force=0;
char G_drive='C';
FILE *G_fp;
#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif
#pragma warn -par
int handler(int err,int ax,int bp,int si)
{
    return(_HARDERR_FAIL);
}
#pragma warn +par
void rotate(void)
{
    static char *rot="/-\\|";
    static int rpos=0;
    fprintf(stderr,"\r%c",rot[rpos++]);
    rpos%=4;
}
void optfile(char *state,char *path,struct ffblk *f,int i,int j)
{
    unsigned short l;
    static char lastp[3000];
    static char cmdstr[3000];

    if (strcmp(lastp,path)) {
        l=(short)(strlen(path)+1);
        l|=0xF000;
        write(G_fdo,&l,sizeof(short));
        write(G_fdo,path,strlen(path)+1);
        strcpy(lastp,path);
    }
    write(G_fdo,&(f->ff_ftime),sizeof(short));
    write(G_fdo,&(f->ff_fdate),sizeof(short));
    write(G_fdo,&(f->ff_fsize),sizeof(long));
    l=(short)(strlen(f->ff_name)+1);
    write(G_fdo,&l,sizeof(short));
    write(G_fdo,f->ff_name,l);
    if (state!=NULL) {
        fprintf(G_fp,"%s %s%s\n",state,path,f->ff_name);
        if (state[0]!='D') {
            sprintf(cmdstr,"copy \"%s%s\" %s /Y > nul",path,f->ff_name,G_datestr);
//            sprintf(cmdstr,"pkzip %c_%s %s%s -r -P > nul",G_drive,G_datestr,path,f->ff_name);
            if (!G_force) system(cmdstr);
        }
    }
    if (i>=0) {
        free(G_path[i]->ff_name[j]);
        G_path[i]->ff_name[j]=NULL;
    }
}
int compfile(char *path,struct ffblk *f)
{
    int j;
    static int li=0;
    int i;
    static char lastp[3000];

    if ((!strcmp(f->ff_name,"WIN386.SWP"))
    ||  (!strcmp(f->ff_name,G_argv1))
    ||  (!strcmp(f->ff_name,G_argv2))) {
        optfile(NULL,path,f,-1,0);
        return 0;
    }
    if (!strcmp(lastp,path)) {
        for (j=0;j<G_path[li]->numf;j++) {
            if ((G_path[li]->ff_name[j]!=NULL)&&(!strcmp(G_path[li]->ff_name[j],f->ff_name))) {
                if ((G_path[li]->ff_ftime[j]!=f->ff_ftime)
                ||  (G_path[li]->ff_fdate[j]!=f->ff_fdate)
                ||  (G_path[li]->ff_fsize[j]!=f->ff_fsize)) {
                    optfile("Modified",path,f,li,j);
                    return(1);
                }
                optfile(NULL,path,f,li,j);
                return(0);
            }
        }
        optfile("Added",path,f,-1,0);
        return(1);
    } else {
        li=0;
        strcpy(lastp,path);
    }
    for (i=0;i<=G_nump;i++) {
        li=i;
        if (!strcmp(G_path[i]->name,path)) {
            for (j=0;j<G_path[i]->numf;j++) {
                if ((G_path[i]->ff_name[j]!=NULL)&&(!strcmp(G_path[i]->ff_name[j],f->ff_name))) {
                    if ((G_path[i]->ff_ftime[j]!=f->ff_ftime)
                    ||  (G_path[i]->ff_fdate[j]!=f->ff_fdate)
                    ||  (G_path[i]->ff_fsize[j]!=f->ff_fsize)) {
                        optfile("Modified",path,f,i,j);
                        return(1);
                    }
                    optfile(NULL,path,f,i,j);
                    return(0);
                }
            }
            optfile("Added",path,f,-1,0);
            return(1);
        }
    }
    li=0;
    lastp[0]=0;
    optfile("Added",path,f,-1,0);
    return(1);
}
void findmiss(void)
{
    int i,j;
    for (i=0;i<=G_nump;i++) {
        for (j=0;j<G_path[i]->numf;j++) {
            if (G_path[i]->ff_name[j]!=NULL) {
                fprintf(G_fp,"Deleted %s%s\n",G_path[i]->name,G_path[i]->ff_name[j]);
            }
        }
    }
}
int findfile(char *path,char *name,int recurse)
{
    struct ffblk f;
    static int done;
    static int numfd=0;
    static char dirpath[3000];
    if (recurse>50) return numfd;
    sprintf(dirpath,"%s%s",path,name);
    done=findfirst(dirpath,&f,DIRATTR);
    while (done!=(-1)) {
        if (G_files[recurse]!=NULL) {
            free(G_files[recurse]);
        }
        G_files[recurse]=malloc(strlen(path)+260);
        if (G_files[recurse]==NULL) return numfd;
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            memset(G_files[recurse],0,strlen(path)+260);
            sprintf(G_files[recurse],"%s%s\\",path,f.ff_name);
            if (recurse) findfile(G_files[recurse],name,recurse+1);
            G_numpath++;
            G_maxdepth=max(G_maxdepth,recurse+1);
        }
        done=findnext(&f);
    }
    sprintf(dirpath,"%s%s",path,name);
    done=findfirst(dirpath,&f,FILEATTR);
    rotate();
    while (done!=(-1)) {
        if ( (strcmp(G_curdir,path))
        ||   ( (strcmp(G_argv1,f.ff_name))
         &&    (strcmp(G_ofile,f.ff_name))
         &&    (strcmp(G_argv2,f.ff_name)) ) ) {
            compfile(path,&f);
        }
        done=findnext(&f);
        numfd++;
    }
    if (G_files[recurse]!=NULL) {
        free(G_files[recurse]);
        G_files[recurse]=NULL;
    }
    return(numfd);
}

void add_file(char *path,struct ffblk *f)
{
    static int li=0;
    int i;
    static char lastp[3000];

    if (!strcmp(lastp,path)) {
        if (G_path[li]->numf<1023) {
            G_path[li]->ff_name [G_path[li]->numf]  =strdup(f->ff_name);
            G_path[li]->ff_ftime[G_path[li]->numf]  =f->ff_ftime;
            G_path[li]->ff_fdate[G_path[li]->numf]  =f->ff_fdate;
            G_path[li]->ff_fsize[G_path[li]->numf++]=f->ff_fsize;
        }
        return;
    } else {
        li=0;
        strcpy(lastp,path);
    }
    for (i=0;i<G_nump;i++) {
        li=i;
        if (!strcmp(G_path[i]->name,path)) {
            if (G_path[i]->numf<255) {
                G_path[i]->ff_name [G_path[i]->numf]  =strdup(f->ff_name);
                G_path[i]->ff_ftime[G_path[i]->numf]  =f->ff_ftime;
                G_path[i]->ff_fdate[G_path[i]->numf]  =f->ff_fdate;
                G_path[i]->ff_fsize[G_path[i]->numf++]=f->ff_fsize;
            }
            return;
        }
    }
    if (G_nump<1023) {
        if ((G_path[G_nump+1]=malloc(sizeof(fblk)))!=NULL) {
            G_nump++;
            G_path[G_nump]->name=strdup(path);
            G_path[G_nump]->numf=1;
            G_path[G_nump]->ff_name [0]  =strdup(f->ff_name);
            G_path[G_nump]->ff_ftime[0]  =f->ff_ftime;
            G_path[G_nump]->ff_fdate[0]  =f->ff_fdate;
            G_path[G_nump]->ff_fsize[0]=f->ff_fsize;
            li=G_nump;
        }
    }
}
int timeval(void)
{
    static struct tm *t;
    static struct timeb tb;
    static int retval=0;
    if (!retval) {
   	    ftime(&tb);
	    t=localtime(&tb.time);
        sprintf(G_ofile,"%02d__%04d.FLO",t->tm_mon+1,t->tm_year+1900);
        sprintf(G_datestr,"md %c_%02d%02d%02d > nul",G_drive,t->tm_mday,t->tm_mon+1,t->tm_year);
        if (!G_force) system(G_datestr);
        sprintf(G_datestr,"%c_%02d%02d%02d",G_drive,t->tm_mday,t->tm_mon+1,t->tm_year);
	    retval=((t->tm_year-80)*365+t->tm_yday);
    }
	return(retval);
}
int readfile(int fd)
{
    unsigned short l;
    struct ffblk f;
    static char path[3000];
    path[0]=0;
    read(fd,&G_lastdate,sizeof(int));
    timeval();
    if ((G_fp=fopen(G_ofile,"a"))==NULL) G_fp=stdout;
    fprintf(G_fp,"------------- Changes Between day %3d year %4d and %3d year %4d ------------\n",
        G_lastdate%365,(G_lastdate/365)+1980,timeval()%365,(timeval()/365)+1980);
    G_lastdate=timeval();
    while (read(fd,&l,sizeof(short))==sizeof(short)) {
        if (l>0xEFFF) {
            read(fd,path,l&0x0FFF);
            path[l&0x0FFF]=0;
        } else {
            f.ff_ftime=l;
            read(fd,&(f.ff_fdate),sizeof(short));
            read(fd,&(f.ff_fsize),sizeof(long)); 
            read(fd,&l,sizeof(short));
            read(fd,f.ff_name,l);
            add_file(path,&f);
        }
    }
    return(1);
}
int main(int argc,char *argv[])
{
    int i,fd;
    char path[4];

    G_force=0;
    if (argc==4) G_force=1;
    strcpy(G_argv1,"BCAKSET$.001");
    strcpy(G_argv2,"BCAKSET$.002");
    G_nump=-1;
    strupr(G_argv1);
    strupr(G_argv2);
    for (i=0;i<50;i++) G_files[i]=NULL;
    if ((fd=open(G_argv1,O_RDONLY|O_BINARY))!=(-1)) {
        G_curdir[0]=(char)(getdisk()+'A');
        G_curdir[1]=':';
        G_curdir[2]='\\';
       	getcurdir(0,&G_curdir[3]);
       	strcat(G_curdir,"\\");
        G_force=(argc>3);
        i=readfile(fd);
        close(fd);
    } else {
        G_force=1;
        G_lastdate=timeval();
        if ((G_fp=fopen(G_ofile,"a"))==NULL) G_fp=stdout;
        fprintf(G_fp,"------------- Initial Setup For %s ------------\n",
            G_datestr);
        i=1;
    }
    if (!i) return 0;

    if ((G_fdo=open(G_argv2,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==(-1)) {
        return 1;
    }
    write(G_fdo,&G_lastdate,sizeof(int));
//    harderr(handler);
    for (i=0;i<7;i++) {
//        if (i!=3) {
            G_drive=(char)(i+'C');
//            G_drive=(char)(i+'J');
            sprintf(path,"%c:\\",G_drive);
            findfile(path,"*.*",1);
//        }
    }
    close(G_fdo);
    findmiss();
    unlink(G_argv1);
    rename(G_argv2,G_argv1);
    fclose(G_fp);
	return 0;
}
//===============================END OF FILE=================================
