#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <stdlib.h>

int main(int argc,char *argv[])
{
    int fd;
    if (argc<3) return(1);
    if ((fd=open(argv[1],O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==(-1)) return(0);
    lseek(fd,atol(argv[2])-1L,SEEK_SET);
    write(fd,&fd,1);
    close(fd);
    return(0);
}
