//=============================== FILELIST.C =================================
#define FILELIST_C

#include <malloc.h>
#include <string.h>
#include <stdio.h>
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

char G_files[50][200];
int G_nump=0;
typedef struct {
    char          *name;
    unsigned int  numf;
    char          *ff_name [1024];
    unsigned int   ff_ftime[1024];
    unsigned int   ff_fdate[1024];
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
int G_lastdate=0;
FILE *G_fp;
#define max(a,b) (((a)>(b))?(a):(b))
char G_findstring[100];
char *G_memblk;
void rotate(void)
{
    static char *rot="/-\\|";
    static int rpos=0;
    fprintf(stderr,"\r%c",rot[rpos++]);
    rpos%=4;
}
void compfile(char *path)
{
    int fd,i,s;
    char *tmp1,*tmp2;
    if ((fd=open(path,O_RDONLY|O_BINARY))==(-1)) return;
    while ((s=read(fd,G_memblk,16383))>0) {
        tmp1=G_memblk;
        tmp2=G_memblk+s;
        while (tmp1!=tmp2) { if (*tmp1==0) *tmp1=1; tmp1++; }
        *tmp2=0;
        strupr(G_memblk);
        if (strstr(G_memblk,G_findstring)!=NULL) {
            close(fd);
            printf("%s\n",path);
            return;
        }
    }
    close(fd);
}
int findfile(char *path,char *name,int recurse)
{
    struct ffblk f;
    static int done;
    static int numfd=0;
    char dirpath[100];
    if (recurse>50) return numfd;
    sprintf(dirpath,"%s%s",path,name);
    done=findfirst(dirpath,&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            sprintf(G_files[recurse],"%s%s\\",path,f.ff_name);
            if (recurse) findfile(G_files[recurse],name,recurse+1);
            G_numpath++;
            G_maxdepth=max(G_maxdepth,recurse+1);
        }
        done=findnext(&f);
    }
    done=findfirst(dirpath,&f,FILEATTR);
    while (done!=(-1)) {
        sprintf(G_files[recurse],"%s%s",path,f.ff_name);
        compfile(G_files[recurse]);
        rotate();
        done=findnext(&f);
    }
    return(numfd);
}

void add_file(char *path,struct ffblk *f)
{
    static int li=0;
    int i;
    static char lastp[100];

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
   	ftime(&tb);
	t=localtime(&tb.time);
    sprintf(G_ofile,"%02d__%04d.FLO",t->tm_mon+1,t->tm_year+1900);
	return((t->tm_year-80)*365+t->tm_yday);
}
int readfile(int fd,int force)
{
    unsigned int l;
    struct ffblk f;
    char path[100];
    path[0]=0;
    read(fd,&G_lastdate,sizeof(int));
    if ((!force)&&(G_lastdate==timeval())) return(0);
    timeval();
    if ((G_fp=fopen(G_ofile,"a"))==NULL) G_fp=stdout;
    fprintf(G_fp,"------------- Changes Between day %3d year %4d and %3d year %4d ------------\n",
        G_lastdate%365,(G_lastdate/365)+1980,timeval()%365,(timeval()/365)+1980);
    G_lastdate=timeval();
    while (read(fd,&l,sizeof(int))==sizeof(int)) {
        if (l>0xEFFF) {
            read(fd,path,l&0x00FF);
            path[l&0x00FF]=0;
        } else {
            f.ff_ftime=l;
            read(fd,&(f.ff_fdate),20-sizeof(int));
            *(((char *)&(f.ff_fdate))+20-sizeof(int))=0;
//            if (!strcmp(path,G_curdir)) {
//                if ((strcmp(f.ff_name,G_argv1))&&(strcmp(f.ff_name,G_argv2))) {
//                    add_file(path,&f);
//                }
//            } else {
                add_file(path,&f);
//            }
        }
    }
    return(1);
}
int main(int argc,char *argv[])
{
    if (argc<2) return 1;
    G_memblk=malloc(16384);
    if (G_memblk==NULL) return(0);
    strcpy(G_findstring,argv[1]);
    strupr(G_findstring);
    findfile(".\\","*.*",1);
	return 0;
}
//===============================END OF FILE=================================
