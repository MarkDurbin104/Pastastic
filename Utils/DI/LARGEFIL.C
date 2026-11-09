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

char G_files[50][200];
long G_total=0L;
int findfile(char *path,char *name,int recurse)
{
    struct ffblk f;
    static int done;
    static int numfd=0;
    static char file[100];
    char dirpath[100];
    if (recurse>50) return numfd;
    sprintf(dirpath,"%s%s",path,name);
    done=findfirst(dirpath,&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            sprintf(G_files[recurse],"%s%s\\",path,f.ff_name);
            if (recurse) findfile(G_files[recurse],name,recurse+1);
        }
        done=findnext(&f);
    }
    done=findfirst(dirpath,&f,FILEATTR);
    while (done!=(-1)) {
        if (f.ff_fsize>1000000L) {
            sprintf(file,"%s%s",path,f.ff_name);
            printf("%-69s%10ld\n",file,f.ff_fsize);
            G_total+=f.ff_fsize;
        }
        done=findnext(&f);
    }
    return(numfd);
}

int main(void)
{
    findfile("\\","*.*",1);
    printf("%-69s%10ld\n","Total",G_total);
	return 0;
}
//===============================END OF FILE=================================
