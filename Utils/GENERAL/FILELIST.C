//=============================== FILELIST.C =================================
#define FILELIST_C
//#define TESTING_FILE_LIST

#include <string.h>
#include <stdio.h>
#include <dos.h>
#include <dir.h>
#include "linklist.h"
#include "filelist.h"

int findfile(char *filespec,int fullpath,LINK **files)
{
    struct ffblk f;
    int done;
    int numfd=0;
    char *nptr;
    static char path[100];
    static char name[100];
    static char tmp[100];
    static char opt[100];
    nptr=strrchr(filespec,'\\');
    if (nptr==NULL) {
        strcpy(name,filespec);
        strcpy(path,".\\");
    } else {
        strcpy(name,nptr+1);
        *nptr=0;
        sprintf(path,"%s\\",filespec);
        *nptr='\\';
    }
    sprintf(tmp,"%s%s",path,name);
    done=findfirst(tmp,&f,FILEATTR);
    while (done!=(-1)) {
        if (fullpath)
            sprintf(opt,"%s%s",path,f.ff_name);
        else {
            strcpy(opt,f.ff_name);
        }
        strupr(opt);
        if (*files==NULL) {
            link_setup(files,STRDUP(opt));
        } else {
            link_append(*files,STRDUP(opt));
        }
        done=findnext(&f);
        numfd++;
    }
    return(numfd);
}
#ifdef TESTING_FILE_LIST
int main(int argc,char *argv[])
{
    LINK *files=NULL;
    LINK *fileiter;
    int i;
    if (argc<2) {
        fprintf(stderr,"Usage FILELIST filespec [filespec...]\n");
        return 1;
    }
    for (i=1;i<argc;i++) {
        findfile(argv[i],1,&files);
    }
    fileiter=files;
    while (fileiter!=NULL) {
        if (link_getelem(fileiter)) printf("%s\n",link_getelem(fileiter));
        fileiter=link_getnext(fileiter);
    }
    link_reset(&files,TRUE);
	return 0;
}
#endif // TESTING_FILE_LIST
//===============================END OF FILE=================================
