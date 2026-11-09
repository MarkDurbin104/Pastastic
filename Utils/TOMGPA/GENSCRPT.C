#include <dos.h>
#include <time.h>
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <direct.h>
#include <process.h>
#include "keynames.h"
#include <stdlib.h>       
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <malloc.h>

char *keyname(int k)
{
    static char tmp[10];

    if (k<33) {
        strcpy(tmp,G_keyname[k+176]);
    }
    else {
        tmp[0]=(char)k;
        tmp[1]=0;
        if (k==127) strcpy(tmp,G_keyname[199]);
    }
    return(tmp);
}
int interp(char *file)
{
    char name[20];
    char tmp[200];
    int fd,i;
    int icount=0;
    if ((fd=open(file,O_RDONLY|O_BINARY))!=(-1)) {
        while (read(fd,&i,sizeof(int))==sizeof(int)) {
            strcpy(name,keyname(i));
            if (strlen(name)==1) {
                tmp[icount++]=name[0];    
            } else {
                if (icount) {
                    tmp[icount]=0;
                    if (icount==1) {
                        printf("'%s' ",tmp);
                    } else {
                        printf("\"%s\" ",tmp);
                    }
                    icount=0;
                }
                printf("<%s>\n",name);
            }
        }
    }
    return 0;
}
int main(int argc,char *argv[])
{
    if (argc<2) return 1;
    interp(argv[1]);
    return 0;
}

