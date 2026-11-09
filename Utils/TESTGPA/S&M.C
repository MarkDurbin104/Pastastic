#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <io.h>
#include <stdarg.h>

char *Usage="\nUsage:\n      S&M FILE SWAPFILE [Oops]\n";
FILE *G_fi,*G_fo;
char G_ofname[80];
char G_ip[1024];
char G_op[1024];
char *G_slist[2][1000];
void snr(char *s,char *ss,char *rs)
{
	char *pos;
	int ofs;
	int slen=strlen(s);
	int sslen=strlen(ss);
	int rslen=strlen(rs);

	memset(G_ip,0,sizeof(G_ip));
	while ((pos=strstr(s,ss))!=NULL) {
		ofs=pos-s;
	 	memcpy(G_ip,s,ofs);
	 	memcpy(G_ip+ofs,rs,rslen);
	 	memcpy(G_ip+ofs+rslen,pos+sslen,(slen-(ofs+sslen))+1);
		memcpy(s,G_ip,strlen(G_ip)+1);
		s=pos+rslen;
	}
}

void error(int retval,char *fmt,...)
{
	va_list ap;
	va_start(ap,fmt);
	vprintf(fmt,ap);
	va_end(ap);
	if (retval<0) {
		fclose(G_fo);
		fclose(G_fi);
		unlink(G_ofname);
		exit(0-retval);
	}
	exit(retval);
}
int main(int argc,char *argv[])
{
	int i=0,nums=0;
	int o1=0,o2=1;
	int fp;
	char tmp[80],tmp1[80],*s;
	char *swap[500];

	printf("Search and Modify.   Copyright (c) Cykor Systems 1994\n");
	if (argc<3) error(1,Usage);
	if (argc>3) {
		strupr(argv[3]);
		if (!strcmp(argv[3],"OOPS")) {
			o1=1; o2=0;
			printf("Reversing operation (Silly Billy)...\n");
		}
	}
	if ((G_fi=fopen(argv[2],"r"))==NULL)  error(1,"Can't open input file %s",argv[2]);
	while (fgets(G_op,256,G_fi)!=NULL) {
		s=strtok(G_op,"\r\n");
		if (s!=NULL) swap[nums++]=strdup(s);
	}
	fclose(G_fi);
	if ((nums&1)==1) error(1,"uneven number of params in input file %s",argv[2]);

	strcpy(tmp,argv[1]);
	s=&tmp[strlen(tmp)-1];
	while ((s!=tmp)&&(*s!='\\')) s--;
	if (s==tmp) *s=0; else *(s+1)=0;
	do sprintf(G_ofname,"%sS&M~TEMP.%03d",tmp,i++); while (!access(G_ofname,0));
	
	if ((G_fo=fopen(G_ofname,"w"))==NULL) error(1,"Can't open temp file %s\n",G_ofname);
	if ((G_fi=fopen(argv[1],"r"))==NULL)  error(-1,"Can't open input file %s",argv[1]);
	while (fgets(G_op,256,G_fi)!=NULL) {
		for (i=0;i<nums;i+=2) snr(G_op,swap[i+o1],swap[i+o2]);
		if (fputs(G_op,G_fo)==EOF) error(-2,"Can't write to temp file\n");
	}
	fclose(G_fi);
	fclose(G_fo);
	strcpy(tmp,argv[1]);
	s=tmp;
	while ((*s)&&(*s!='.')) s++;
	*s=0;
	i=0;
	do sprintf(tmp1,"%s.%03d",tmp,i++); while (!access(tmp1,0));
	if (rename(argv[1],tmp1))     error(2,"Can't rename %s to %s - output in %s\n",argv[1],tmp1,G_ofname);
	if (rename(G_ofname,argv[1])) error(2,"Can't rename %s to %s\n",G_ofname,argv[1]);
	return(0);
}
