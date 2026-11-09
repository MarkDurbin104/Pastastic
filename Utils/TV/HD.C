#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <io.h>
#include <ctype.h>

main (argc,argv)
int  argc;
char **argv; {
	int  i,j;
	int  fd;
	int  brkchr;
	int  step;
	unsigned char buf[18];
	if (argc<2) {
		printf("File Name ??\n");
		exit(-1);
	}
	if (argc>2) {
		if (argv[2][0]=='c') {
			brkchr=atoi(&argv[2][1]);
			step=0;
		}
		else  {
			brkchr=(-1);
			step=atoi(argv[2]);
		}
	}
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) {
		fprintf(stderr,"Can't Open input file\n");
		exit(-1);
	}
	i=0;
	while (read(fd,&buf[i%16],1)) {
		if ((i%16)==0) fprintf(stdout,"%08X  ",i);
		fprintf(stdout,"%02X ",buf[i%16]&0xFF);
		fflush(stdout);
		if (brkchr==(-1)) {
			i++;
			if ((i%16)==0) {
				for (j=0;j<16;j++) {
					if (isprint(buf[j])) {
						fprintf(stdout,"%c",buf[j]);
					}
					else {
						fprintf(stdout,".");
					}
				}
				fprintf(stdout,"\n");
				fflush(stdout);
			}
			if ((i%step)==0) {
				i--;
				for (j=(i%16);j<15;j++) fprintf(stdout,"   ");
				for (j=0;j<(i%16);j++) {
					if (isprint(buf[j])) {
						fprintf(stdout,"%c",buf[j]);
					}
					else {
						fprintf(stdout,".");
					}
				}
				fprintf(stdout,"\n");
				i=0;
			}
		}
		else {
			if (buf[i%16]==brkchr) {
				for (j=(i%16);j<15;j++) fprintf(stdout,"   ");
				for (j=0;j<(i%16);j++) {
					if (isprint(buf[j])) {
						fprintf(stdout,"%c",buf[j]);
					}
					else {
						fprintf(stdout,".");
					}
				}
				fprintf(stdout,"\n");
				i=0;
			}
			else {
				i++;
				if ((i%16)==0) {
					for (j=0;j<16;j++) {
						if (isprint(buf[j])) {
							fprintf(stdout,"%c",buf[j]);
						}
						else {
							fprintf(stdout,".");
						}
					}
					fprintf(stdout,"\n");
				}
			}
		}
	}
	fprintf(stdout,"\n");
	close(fd);
	return(1);
}
