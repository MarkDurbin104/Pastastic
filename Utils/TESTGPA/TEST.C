#include <stdio.h>
#include <malloc.h>
#include <fcntl.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>

long csumcore(int fd,long *buf)
{
    int i,j;
    long ret=0x55A55AAAL;
    i=read(fd,buf,4096);
//    while ((i=read(fd,buf,4096))>0) {
        for (j=0;j<i/4;j++) {
            ret^=buf[j];
        }
//    }
    return(ret);
}

int main(void)
{
    int fd;
    long l;
    char *buf;
    buf=malloc(4096);
    fd=open("TEST.C",O_RDONLY);
    l=csumcore(fd,(long*)buf);
    close(fd);
	return 0;
}
