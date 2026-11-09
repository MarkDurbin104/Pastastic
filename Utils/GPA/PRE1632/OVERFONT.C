#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <string.h>
#include <mem.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "keydef.h"

#define FONTSIZE (32+14*256+16*256)

unsigned char G_buf[1024];

int main(int argc,char *argv[])
{
	int fdi,fdo;
	if (argc<3) {
		printf("Can't you read simple instructions? I SAID\n");
		printf("     OVERFONT myfontfile yourfontfile\n\n");
		printf("Formatting hard disk please panic ");
		for (argc=0;argc<40;argc++) { printf("."); delay(200); }
		printf("\nNot Really.\n");
		return(1);
	}
	if ((fdi=open(argv[1],O_RDONLY|O_BINARY))==(-1)) {
		printf("Can't Open %s\n",argv[1]);
		return(1);
	}
	if ((fdo=open(argv[2],O_RDWR|O_BINARY))==(-1)) {
		printf("Can't Open %s\n",argv[2]);
		return(1);
	}
	lseek(fdo,FONTSIZE,SEEK_SET);
	lseek(fdi,FONTSIZE,SEEK_SET);
	if (read(fdi,G_buf,1024)<1024) {
		printf("Error reading %s\n",argv[1]);
		return(1);
	}
	if (write(fdo,G_buf,1024)<1024) {
		printf("Error writting %s\n",argv[2]);
		return(1);
	}
	close(fdi);
	close(fdo);
	printf("All done! (Amazing speed wasn't it)\n",argv[2]);
	return(0);
}
