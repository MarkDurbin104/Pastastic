
#ifdef TURBOC
#include <stdlib.h>
#include <conio.h>
#endif
#include <string.h>
#include <stdio.h>

int fseqno,tseqno;
struct sequence {
	int  sid;
	char oper[3];
	int  stid;
	int  ppid;
	int  eseq;
	char op[3];
	char v1[5];
	char v2[5];
	char v3[4];
	char v4[4];
} seq;
FILE *iptr;
FILE *optr;

#ifdef TURBOC
int seqln(char *ln);
#endif

main(argc,argv)
int argc;
char **argv; {
	long i;
	char *j;
	char currentln[256];
	if (argc<5) {
		printf("cngseq sfilename dfilename seqno seqno\n");
		exit(-1);
	}
	fseqno=atoi(argv[3]);
	tseqno=atoi(argv[4]);
	if ((iptr=fopen(argv[1],"r"))==NULL) {
		printf("Can't Open File %s\n",argv[1]);
		exit(-1);
	}
	if ((optr=fopen(argv[2],"w"))==NULL) {
		printf("Can't Open File %s\n",argv[2]);
		exit(-1);
	}
	i=0;
	while ((j=fgets(currentln,255,iptr))!=NULL) {
		clrscr();
		cprintf("%d  %ld",j[0],i++);
		switch (currentln[0]) {
			case 's' : {
				seqln(currentln);
			} break;
			default : {
				fputs(currentln,optr);
				fflush(optr);
			}
		}
	}
	clrscr();
	cprintf("%d  %ld",j[0],i++);
	fclose(iptr);
	fclose(optr);
	return(1);
}
seqln(ln)
char *ln; {
	char tmp[256],*t,*r;
	int j;
	strcpy(tmp,&ln[1]);
	r=strtok(tmp," \t\n");
	for (j=0;j<8;j++) t=strtok((char *)NULL," \t\n");
	if (t==(char *)NULL) {
		printf("Error Sequence [%d] Line Missing Fields\n",atoi(r));
		return(0);
	}
	strcpy(tmp,&ln[1]);
	seq.sid=atoi(strtok(tmp," \t\n"));
	strcpy(seq.oper,strtok((char *)NULL," \t\n"));
	seq.stid=atoi(strtok((char *)NULL," \t\n"));
	seq.ppid=atoi(strtok((char *)NULL," \t\n"));
	seq.eseq=atoi(strtok((char *)NULL," \t\n"));
	strcpy(seq.op,strtok((char *)NULL," \t\n"));
	strcpy(seq.v1,strtok((char *)NULL," \t\n"));
	strcpy(seq.v2,strtok((char *)NULL," \t\n"));
	strcpy(seq.v3,strtok((char *)NULL," \t\n"));
	strcpy(seq.v4,strtok((char *)NULL," \t\n"));
	if ((seq.sid!=fseqno)&&(seq.eseq!=fseqno)) {
		fputs(ln,optr);
		fflush(optr);
		return(0);
	}
	if (seq.sid==fseqno) {
		fprintf(optr,"s%d",tseqno);
		if (tseqno<100) fprintf(optr,"		"); else fprintf(optr,"	");
	}
	else {
		fprintf(optr,"s%d",seq.sid);
		if (seq.sid<100) fprintf(optr,"		"); else fprintf(optr,"	");
	}
	fprintf(optr,"%s		",seq.oper);
	if (seq.stid==0) fprintf(optr,".		"); else fprintf(optr,"%d		",seq.stid);
	if (seq.ppid==0) fprintf(optr,".		"); else fprintf(optr,"%d		",seq.ppid);
	if (seq.eseq==fseqno) {
		fprintf(optr,"%d		",tseqno);
	}
	else {
		if (seq.eseq==0) fprintf(optr,".		"); else fprintf(optr,"%d		",seq.eseq);
	}
	fprintf(optr,"%s		%s		%s		%s	%s\n",seq.op,seq.v1,seq.v2,seq.v3,seq.v4);
	fflush(optr);
	return(0);
}
