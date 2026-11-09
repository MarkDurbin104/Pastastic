#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <dir.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <malloc.h>
#include <time.h>
#include <memory.h>
#include <dos.h>
#include <stdlib.h>

typedef int (*QSPTR)(const void*, const void*);

typedef struct {
    long  o;
    char  l;
    char  t;
    char *n;
} FILEINFO;

#define FILEATTR FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

FILEINFO  *G_filesfd;
int       G_numfd=0;
int fncmp(FILEINFO *a,FILEINFO *b)
{
    return(strcmp(a->n,b->n));
}
int findfile(char *name)
{
    struct ffblk f;
    int done=0;
    char tmp[100],*t;
    char opt[100];
    strcpy(tmp,name);

	t=strrchr(tmp,'\\');
	if (t!=NULL) {
		*(t+1)=0;
	} else {
        tmp[0]=0;
    }

    G_numfd=0;
    done=findfirst(name,&f,FILEATTR);
    while (done!=(-1)) {
        G_numfd++;
        done=findnext(&f);
    }
    G_filesfd=malloc(sizeof(FILEINFO)*G_numfd);
    G_numfd=0;
    if (G_filesfd!=NULL) {
        done=findfirst(name,&f,FILEATTR);
        while (done!=(-1)) {
            sprintf(opt,"%s%s",tmp,f.ff_name);
            strupr(opt);
            G_filesfd[G_numfd].n=strdup(opt);
            if (G_filesfd[G_numfd].n==NULL) break;
            G_filesfd[G_numfd].l=strlen(opt);
            G_filesfd[G_numfd].t=0;
            G_numfd++;
            done=findnext(&f);
        }
        qsort(G_filesfd,G_numfd,sizeof(FILEINFO),(QSPTR)fncmp);
    }
    return(G_numfd);
}
int main(int argc,char *argv[])
{
    int i,fd,j,k;
    unsigned long res;
    unsigned long *buf,*t;
    buf=malloc(30000);
    findfile(argv[1]);
    if (G_numfd!=0) {
        for (i=0;i<G_numfd;i++) {
            res=0L;
            if ((fd=open(G_filesfd[i].n,O_RDONLY|O_BINARY))==(-1)) {
                printf("Can't open %s\n",G_filesfd[i].n);
            } else {
                while ((k=read(fd,buf,30000))>0) {
                    t=buf;
                    for (j=0;j<k/4;j++) {
                        res+=*(t++);
                    }
                }
                printf("%-40.40s %08lX\n",G_filesfd[i].n,res);
            }
            close(fd);
        }
    }
    free(buf);
    return(0);
}
