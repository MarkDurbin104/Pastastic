#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <ctype.h>
#include <dos.h>
#include <dir.h>
#include <io.h>
#include <fcntl.h>

#define FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR     FA_DIREC

char *G_files[]={
    "*.h","*.bat","*.c","*.cfg","*.fnt","*.kbd","*.off","*.lst",
    "makefile","gpa.scr","gpa.psr","psr.doc",NULL
};

char *G_ofiles[512];
int G_numof;
int G_recurse=0;
unsigned long G_ft;

extern int archive(int nf,char *files[]);
void addstr(char *file)
{
    int fd;
    unsigned long ft;

    fd=open(file,O_RDONLY);
    if (fd==(-1)) return;
    getftime(fd,(struct ftime *)&ft);
    close(fd);
    if (ft>G_ft) G_ofiles[G_numof++]=strdup(file);
}
void getfiles(char *path,char *search,int depth)
{
    struct ffblk *fi;                              
    char *curpath;                                  
    char *newpath;
    char *dirpath;

    curpath=malloc(strlen(path)+strlen(search)+2);  
    newpath=malloc(strlen(path)+16);
    dirpath=malloc(strlen(path)+5);
    fi=malloc(sizeof(struct ffblk));

    sprintf(curpath,"%s%s",path,search);            
    sprintf(dirpath,"%s%s",path,"*.*");             

    findfirst(dirpath,fi,DIRATTR);             
    if (strcmp(fi->ff_name,".")) {                     
        sprintf(newpath,"%s%s\\",path,fi->ff_name);    
        if (G_recurse) getfiles(newpath,search,depth+1);           
    }
    else {
        findnext(fi);                          
    }
    while (findnext(fi)==0) {                  
        if (fi->ff_attrib&DIRATTR)  {                  
            sprintf(newpath,"%s%s\\",path,fi->ff_name);
            if (G_recurse) getfiles(newpath,search,depth+1);       
        }
    }

    if (findfirst(curpath,fi,FILEATTR)==0) {   
        do {                                      
            sprintf(newpath,"%s%s",path,fi->ff_name);
            if ((newpath[0]=='.')&&(newpath[1]=='\\'))
                addstr(&newpath[2]);
            else
                addstr(newpath);
        } while (findnext(fi)==0);             
    }

    if (depth) path[strlen(path)-1]=0;                         

    free(fi);                                       
    free(dirpath);
    free(newpath);
    free(curpath);
}

int tcmp(const void *a,const void *b)
{
    return(strcmp(*(char **)a,*(char **)b));
}
int main(void)
{
    int i=0;
    char dir[80];                                      
    char file[80];

    G_ofiles[0]="MD1";
    G_ofiles[1]="A";
    G_ofiles[2]="GPA.PAC";
    G_numof=3;

    memset(&G_ft,0,sizeof(G_ft));
    i=open(G_ofiles[2],O_RDONLY);
    if (i!=(-1)) {
        getftime(i,(struct ftime *)&G_ft);
        close(i);
    }
    i=0;
    while (G_files[i]!=NULL) {
        getfiles("",G_files[i],0);
        i++;
    }
    if (G_numof>3) {
        qsort(&G_ofiles[3],G_numof-3,sizeof(char *),tcmp);
        archive(G_numof,G_ofiles);
    }
    printf("Operation Complete\n");
    return(1);
}
