#include <io.h>
#include <stdio.h>
#include <string.h>
#include "types.h"

CHAR tmp[1000];
INT _cdecl main(INT argc,CHAR *argv[])
{
	FILE *fp;
	CHAR *t;
	INT pm=1;
	INT  i=0;
	if (argc<2) {
		printf("Must Supply Output file\n");
		return(1);
	}
	if (argc==3) {
		if (access(argv[2],0)) pm=0;
	}
	if ((fp=fopen(argv[1],"w"))==NULL) {
		printf("Can't open file %s\n",argv[1]);
		return(1);
	}
	if (fgets(tmp,1000,stdin)==NULL) {
		printf("No input stream\n");
		return(1);
	}
	t=strtok(tmp," \t\r\n");
	while (t!=NULL) {
		if (pm) fprintf(fp,"-+%-13s",t); else fprintf(fp,"+%-14s",t);
		i++;
		t=strtok(NULL," \t\r\n");
		if ((i%5==0)&&(t!=NULL)) fprintf(fp,"&\n");
	}
	fprintf(fp,"\n");
	fclose(fp);
	return(0);
}
