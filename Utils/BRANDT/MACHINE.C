#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>
#include <alloc.h>
#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "comms.h"

main () {
	int i;
	setbaud(9600,8,'n',1);
	setcomms();
	for (i=0;i<256;i++) {
		txchr(i);
		printf("Sending %d\n",i);
		getch();
	}
	restcomms();
	return(1);
}
