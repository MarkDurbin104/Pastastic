#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

char buf[40000];

int main(int argc,char *argv[])
{
	int fd,fdi;
	unsigned int len;
	if (argc<4) return(1);
	fd=open(argv[3],O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
	if (fd==(-1)) return(1);
	fdi=open(argv[1],O_RDONLY|O_BINARY);
	if (fdi==(-1)) { close(fd); return(1); }
	while (write(fd,buf,read(fdi,buf,32000))>0)	;
	close(fdi);
	fdi=open(argv[2],O_RDONLY|O_BINARY);
	while (write(fd,buf,read(fdi,buf,32000))>0)	;
	close(fdi);
	close(fd);
	return(0);
}
