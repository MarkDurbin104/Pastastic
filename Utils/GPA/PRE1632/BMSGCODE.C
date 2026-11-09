#include <string.h>
#include <stdio.h>

char *G_stendstr="//~~~~~~~DO NOT REMOVE THIS LINE";
char tmp[1000];
char tmp1[1000];
int _cdecl main(int argc,char *argv[])
{
	FILE *fpi,*fpo;
	char line[256],*t,*e;
	int stage=0;
	if (argc<3) {
		printf("bmsgcode infile tmpfile < list of devs");
		return(1);
	}
	if (fgets(tmp,1000,stdin)==NULL) {
		printf("No input stream\n");
		return(1);
	}
	strlwr(tmp);
	if ((fpi=fopen(argv[1],"r"))==NULL) {
		printf("bmsgcode infile tmpfile < list of devs");
		return(1);
	}
	if ((fpo=fopen(argv[2],"w"))==NULL) {
		printf("bmsgcode infile tmpfile < list of devs");
		return(1);
	}
	printf("Rebuilding %s\n",argv[1]);
    while ((fgets(line,255,fpi)!=NULL)) {
		if (!strncmp(line,G_stendstr,strlen(G_stendstr))) {
			stage++;
			fputs(line,fpo);
			switch (stage) {
				case 2 :
				case 4 :
					break;
				case 1 :
					strcpy(tmp1,tmp);
					t=strtok(tmp1," \t\n");
					e=t+(strlen(t)-5); *e=0;
					while (t!=NULL) {
						fprintf(fpo,"#include \"%sdev.h\"\n",t);
						t=strtok(NULL," \t\n");
						e=t+(strlen(t)-5); *e=0;
						if (!strcmp(t,"bmsgcod")) t=NULL;
					}
					break;
				case 3 :
					strcpy(tmp1,tmp);
					t=strtok(tmp1," \t\n");
					e=t+(strlen(t)-5); *e=0;
					while (t!=NULL) {
						fprintf(fpo,"\tdev_%s.name[0]=dev_%s.name[0];\n",t,t);
						t=strtok(NULL," \t\n");
						e=t+(strlen(t)-5); *e=0;
						if (!strcmp(t,"bmsgcod")) t=NULL;
					}
					break;
			}
		} else {
			if ((stage&1)==0) fputs(line,fpo);
		}
	}
	fclose(fpi);
	fclose(fpo);
	strcpy(tmp1,argv[1]);
	t=strtok(tmp1,".");
	sprintf(line,"%s.OLD",t);
	unlink(line);
	rename(argv[1],line);
	rename(argv[2],argv[1]);
	return(0);
}
