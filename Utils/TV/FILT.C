#include <fcntl.h>
#include <io.h>
#include <stdio.h>
main(int argc,char **argv) {
	int f1,f2;
	char k;
	if (argc<3) {
		printf("filt fil1 fil2\n");
		return(-1);
	}
	f1=open(argv[1],O_RDONLY|O_BINARY);
	f2=open(argv[2],O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,0777);
	while (read(f1,&k,1)>0) if (k!=13) write(f2,&k,1);
	close(f1);
	close(f2);
	return(1);
}