#include <string.h>
#include <stdio.h>
#include "types.h"

FILE *G_fp=NULL;
char tmp[1000];

void getpubs(char *file,int all)
{
    FILE *fp;
    char line[256];
    int togg=0,ot;
    char *e;
	strupr(file);

    fp=fopen(file,"r");
    if (fp==NULL) {
        fprintf(stderr,"Can't Open %s\n",file);
        return;
    }
    fprintf(G_fp,"// ------------------------------ %s START ------------------------------\n\n",file);

    while ((fgets(line,255,fp)!=NULL)) {
        if (!all) {
            if ((e=strstr(line,"INIT("))!=NULL) *e=0;
            if ((e=strstr(line,"INIT4("))!=NULL) *e=0;
            e=&line[strlen(line)-1];
            while (((*e=='\n')||(*e==' ')||(*e==';'))&&(e!=line)) *(e--)=0;
        }
        ot=togg;
        if (!strncmp(line,"// PUBLIC SYMBOLS",17)) togg^=1;
        if (togg) {
            if (all) {
                if (ot==togg) fprintf(G_fp,"%s",line);
            } else {
                if (!strncmp(line,"PUBLIC",6))  fprintf(G_fp,"extern %s;\n",&line[6]);
                if (!strncmp(line,"#define",7)) fprintf(G_fp,"%s\n",line);
            }
        }
    }

    fclose(fp);
    fprintf(G_fp,"\n// ------------------------------- %s END --------------------------------\n\n",file);
}
int _cdecl main(int argc,char *argv[])
{
	char *t;
	if (argc<2) {
		fprintf(stderr,"Must Supply Output file\n");
		return(1);
	}
	if ((G_fp=fopen(argv[1],"w"))==NULL) {
		fprintf(stderr,"Can't open file %s\n",argv[1]);
		return(1);
	}
	if (fgets(tmp,1000,stdin)==NULL) {
		fprintf(stderr,"No input stream\n");
		return(1);
	}
	fprintf(stderr,"Re-Building %s\n",argv[1]);

    getpubs("TYPES.H",1);
	t=strtok(tmp," \t\r\n");
	while (t!=NULL) {
		getpubs(t,0);
		t=strtok(NULL," \t\r\n");
	}
	fclose(G_fp);
	return(0);
}
/***********************************************************************/
