#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "gpa.h"
char **G_pstr;
int G_nump;
FILE *G_fp=NULL;

int process(char *s)
{
	int i;
	
	if (G_fp==NULL) {
		if ((G_fp=fopen("GPAPKZIP.LST","w"))==NULL) {
			G_fp=stdout;
		}
	}
	strupr(s);
	if (!G_nump) G_pstr=malloc(sizeof(char *));
	for (i=0;i<G_nump;i++) {
		if (!strcmp(G_pstr[i],s)) return(1);
	}
	G_pstr=realloc(G_pstr,sizeof(char *)*(G_nump+1));
	G_pstr[G_nump]=strdup(s);
	G_nump++;
	fprintf(G_fp,"%s\n",s);
	return(0);
}
int main(int argc,char *argv[])
{
	int i;
    char tmp[100],type;
	
    if (argc<2) {
		printf("BAKGPA SYSTEM [R|D|B]\n");
		return(1);
	}
    if (argc>2) type=toupper(argv[2][0]);
	if ((type!='R')&&(type!='D')&&(type!='B')) type='R';
	if (toupper(argv[2][0])=='L') type='B';

	readconfig(argv[1]);

	if (type!='D') {
		process("gpa.exe");
		process("gpastart.bmp");
		process("gpastarh.bmp");
		process("device.map");
		process(G_database);
		loadsdata(G_system);
	    for (i=0;i<G_nums;i++) {
		    sprintf(tmp,"%s%s.DB",G_database,G_store[i].name);  process(tmp);
		    sprintf(tmp,"%s%s.PX",G_database,G_store[i].name);  process(tmp);
		    sprintf(tmp,"%s%s.X??",G_database,G_store[i].name); process(tmp);
		    sprintf(tmp,"%s%s.Y??",G_database,G_store[i].name); process(tmp);
		}
		process(G_offdets);
	}
	if (type!='R') {
		process("BGPADEV.EXE");
		process("FD.EXE");
		process("FE.EXE");
		process("FMAP.EXE");
		process("GPA.EXE");
		process("GPAD.EXE");
		process("KD.EXE");
		process("PP.EXE");
		process("SD.EXE");
		process("DROPDEAD.EXE");
		process("OVERFONT.EXE");
		process("BAKGPA.EXE");
	}
	process(G_config);
    sprintf(tmp,"%s.CFG",argv[1]);				process(tmp);
    sprintf(tmp,"%s%sA.DAT",G_config,G_system); process(tmp);
    sprintf(tmp,"%s%sR.DAT",G_config,G_system); process(tmp);
    sprintf(tmp,"%s%sI.DAT",G_config,G_system);	process(tmp);
    sprintf(tmp,"%s%sN.DAT",G_config,G_system);	process(tmp);
    sprintf(tmp,"%s%sD.DAT",G_config,G_system);	process(tmp);
	for (i=0;i<G_numlang;i++) {
		process(G_langfiles[i]);
		readlang(G_langfiles[i]);
		process(G_textfile);
		process(G_fontfile);
		process(G_kbdfile);
	}

	cleanupblks(0);
	fclose(G_fp);

	sprintf(tmp,"PKZIP %s.ZIP -u -P @GPAPKZIP.LST",argv[1]);
	if (toupper(argv[2][0])!='L') system(tmp);
    return(0);
}
