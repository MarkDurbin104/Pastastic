#include <stdio.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>

int main(int argc,char *argv[])
{
	int fd;
	char tmp[9]="________";

	if (argc<3) {
		printf("overload driver name\n");
		return(1);
	}
	if (strlen(argv[2])>7) {
		argv[2][7]=0;
	}
	memcpy(tmp+1,argv[2],strlen(argv[2]));
	printf("Device name %s                            \n",tmp);
	if ((fd=open(argv[1],O_RDWR|O_BINARY))==(-1)) {
		printf("Can't open %s\n",argv[1]);
		return(1);
	}
	lseek(fd,10,SEEK_SET);
	write(fd,tmp,8);
	close(fd);
	return(0);
}
