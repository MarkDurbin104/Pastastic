#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>

main(int argc,char **argv) {
	int fi,fo;
	char buf;
	if (argc<3) exit(-1);
	if ((fi=open(argv[1],O_RDONLY|O_BINARY))==(-1)) {
		printf("Can't Open Input File %s\n",argv[1]);
		exit(-1);
	}
	if ((fo=open(argv[2],O_WRONLY|O_BINARY|O_TRUNC|O_CREAT,0777))==(-1)) {
		printf("Can't Open Output File %s\n",argv[1]);
		exit(-1);
	}
	while ((read(fi,&buf,1))!=0) {
		if ((buf!='\r')&&(buf!='\n')) {
			write(fo,&buf,1);
		}
	}
	close(fo);
	close(fi);
	return(0);
}
