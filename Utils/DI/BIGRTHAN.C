//=============================== FILELIST.C =================================
#define FILELIST_C

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <dir.h>

#define FILEATTR      0xFF // FA_DIREC|FA_HIDDEN|FA_RDONLY|FA_SYSTEM|FA_ARCH|FA_NORMAL|FA_LABEL
#define DIRATTR       0xFF

char G_files[50][512];
char G_files1[50][512];
long G_total=0L;
long G_bigfile=0L;
long G_numfiles=0L;
long G_numdirs=0L;

int findfile(char *path,char *name,int recurse)
{
    struct ffblk f;
    static int done;
    static int numfd=0;
    if (recurse>100) return numfd;
    sprintf(G_files1[recurse],"%s%s",path,name);
    done=findfirst(G_files1[recurse],&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            G_numdirs++;
            if (f.ff_fsize>G_bigfile) {
                printf("%10ld %s%s\n",f.ff_fsize,path,f.ff_name);
            }
            sprintf(G_files[recurse],"%s%s\\",path,f.ff_name);
            if (recurse) findfile(G_files[recurse],name,recurse+1);
        }
        done=findnext(&f);
    }
    done=findfirst(G_files1[recurse],&f,FILEATTR);
    while (done!=(-1)) {
        if (f.ff_fsize>G_bigfile) {
            G_numfiles++;
            printf("%10ld %s%s\n",f.ff_fsize,path,f.ff_name);
            G_total+=f.ff_fsize;
        }
        done=findnext(&f);
    }
    return(numfd);
}

int main(int argc,char *argv[])
{
    if (argc<2) {
        G_bigfile=1000000L;
    } else {
        G_bigfile=atol(argv[1]);
    }
    findfile("\\","*.*",1);
    printf("\n%10ld Total %ld in %ld Directories\n",G_total,G_numfiles,G_numdirs);
	return 0;
}
//===============================END OF FILE=================================
