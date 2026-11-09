#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>

#define YEARSPOT 0x000A
#define MONSPOT	 0x0011
#define DAYSPOT	 0x0010

int main(int argc,char *argv[])
{
	char d,m;
	int y,fd;

	if (argc<5) {
		printf("dropdead DD MM YYYY FILE\n");
		return(1);
	}
	d=atoi(argv[1]);
	m=atoi(argv[2]);
	y=atoi(argv[3]);
	fd=open(argv[4],O_RDWR|O_BINARY);
	if (fd==(-1)) {
		printf("can't open %s\n",argv[4]);
		return(1);
	}
	lseek(fd,YEARSPOT,SEEK_SET);
	write(fd,&y,sizeof(int));
	lseek(fd,DAYSPOT,SEEK_SET);
	write(fd,&d,sizeof(char));
	lseek(fd,MONSPOT,SEEK_SET);
	write(fd,&m,sizeof(char));
	close(fd);

	return(0);
}
