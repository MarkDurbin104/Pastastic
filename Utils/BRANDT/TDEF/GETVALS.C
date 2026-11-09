#include <alloc.h>
#include <math.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "convhpgl.h"

void getints(char *curln) {
	char *t;
	char h;
	h=curln[0];
	argus.no=0;
	t=strtok(&curln[2],", ;\n\r");
	if ((h=='P')||(h=='C')) {
		do {
			argus.ag[argus.no++]=(int)(atol(t)/divisor);
			t=strtok(NULL,", ;\n\r");
		} while (t!=NULL);
	} else {
		do {
			argus.ag[argus.no++]=(int)atol(t);
			t=strtok(NULL,", ;\n\r");
		} while (t!=NULL);
	}
}
void getchrs(char *curln) {
	int i=2;
	argus.no=0;
    while (i<=strlen(curln)-1) {
	    while (isspace(curln[i])) i++;
	    while (!isascii(curln[i])) i++;
		argus.ag[argus.no]=curln[i];
		argus.no++;
		while ((curln[i]!=seperator) && (i<=strlen(curln)-1)) i++;
		i++;
	}
}
void gettxt(char *curln) {
	strcpy(argut,&curln[3]);
}
void getflts(char *curln) {
	int i=2;
	arguf.no=0;
    while (i<=strlen(curln)-1) {
	    while ((!isdigit(curln[i]))&&(curln[i]!='.')&&(curln[i]!='-')) i++;
		arguf.ag[arguf.no]=atof(&curln[i]);
		arguf.no++;
		while ((curln[i]!=seperator) && (i<=strlen(curln)-1)) i++;
	}
}
