#include <stdio.h>
#include <string.h>
#include <mem.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

unsigned char ibuf[30000];
char obuf[30000];

int main(int argc,char *argv[])
{
    int fd,od;
    int i,a,nb;
    unsigned char lb;
    if (argc<3) {
        printf("Usage :\n        conv infile outfile\n");
        return(1);
    }

    fd=open(argv[1],O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        printf("Can't open file %s\n",argv[1]);
        return(1);
    }
    od=open(argv[2],O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
    if (od==(-1)) {
        close(fd);
        printf("Can't open file %s\n",argv[2]);
        return(1);
    }
    read(fd,ibuf,4);
    ibuf[4]=0;
    lb=0;
    if (strcmp(ibuf,"CV10")) {
        lseek(fd,0L,SEEK_SET);
        write(od,"CV10",4);
        while ((nb=read(fd,ibuf,30000))>0) {
            for (i=0;i<nb;i++) {
                a=ibuf[i]-lb;
                if (a>127) a-=256;
                obuf[i]=(char)(a&0xFF);
                lb=ibuf[i];
            }
            write(od,obuf,nb);
        }
    }
    else {
        while ((nb=read(fd,ibuf,30000))>0) {
            for (i=0;i<nb;i++) {
                a=ibuf[i];
                if (a<0) a+=256;
                a+=lb;
                obuf[i]=(char)(a&0xFF);
                lb=a;
            }
            write(od,obuf,nb);
        }
    }
    close(fd);
    close(od);
    return(0);
}
