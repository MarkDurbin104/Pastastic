#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <search.h>
#include <alloc.h>
#include <ctype.h>

typedef int (*fptr)(const void*, const void*);
typedef struct {
	char *e;
	int   t;
} ELEM;
ELEM **G_lib;
int G_numl=0;
typedef struct {
	unsigned  e0  :10;
	unsigned  e1  :10;
	unsigned  e2  :10;
	unsigned  e3  :10;
	unsigned  e4  :10;
	unsigned  e5  :10;
	unsigned  e6  :10;
	unsigned  e7  :10;
} TOKS;
TOKS G_toks[5000];
unsigned int G_numt=0;

int lfnd(char *a,ELEM **b)
{
	return(strcmp(a,(*b)->e));
}
int lcmp(ELEM **a,ELEM **b)
{
	return(strcmp((*a)->e,(*b)->e));
}
int findtok(char *s)
{
	ELEM **t;
	t=bsearch(s,G_lib,G_numl,sizeof(ELEM *),(fptr)lfnd);
	if (t==NULL) {
		G_lib=realloc(G_lib,(G_numl+1)*sizeof(ELEM *));
		if (G_lib!=NULL) {
			G_lib[G_numl]=malloc(sizeof(ELEM));
			if (G_lib[G_numl]!=NULL) {
				G_lib[G_numl]->e=strdup(s);
				G_lib[G_numl]->t=G_numl+1;
//				printf("New %d %s\n",G_numl+1,s);
				G_numl++;
				qsort(G_lib,G_numl,sizeof(ELEM *),(fptr)lcmp);
			}
		}
		t=bsearch(s,G_lib,G_numl,sizeof(ELEM *),(fptr)lfnd);
		if (t==NULL) return(0);
	}
	return((*t)->t);
}
int icmp(ELEM **a,ELEM **b)
{
	return((*a)->t-(*b)->t);
}
void reorder(void)
{
	qsort(G_lib,G_numl,sizeof(ELEM *),(fptr)icmp);
}
char *untoken(int a)
{
	return(G_lib[a-1]->e);
}
char *extract(char *s)
{
	static char *cp;
	static char last;
	char *sp;
	if (s!=NULL) {
		cp=s;
	} else {
		*cp=last;
	}
	if (*cp==0) return(NULL);
	sp=cp;
	while ((*cp)&&isspace(*cp)) cp++;
	if (sp!=cp) { last=*cp; *cp=0; return(sp); }
	while ((*cp)&&(!isalnum(*cp))&&(!isspace(*cp))) cp++;
	if (sp!=cp) { last=*cp; *cp=0; return(sp); }
	while ((*cp)&&isalnum(*cp)&&(!isspace(*cp))) cp++;
	if (sp!=cp) { last=*cp; *cp=0; return(sp); }
	last=*cp;
	return(sp);
}
void addval(int v)
{
	switch (G_numt&7) {
		case 0 : G_toks[G_numt>>3].e0=v; break;
		case 1 : G_toks[G_numt>>3].e1=v; break;
		case 2 : G_toks[G_numt>>3].e2=v; break;
		case 3 : G_toks[G_numt>>3].e3=v; break;
		case 4 : G_toks[G_numt>>3].e4=v; break;
		case 5 : G_toks[G_numt>>3].e5=v; break;
		case 6 : G_toks[G_numt>>3].e6=v; break;
		case 7 : G_toks[G_numt>>3].e7=v; break;
	}
	G_numt++;
	if (G_numt>=40000) exit(-1);
}
int tokenize(char *s)
{
	char *t;
	int ret=G_numt;
	t=extract(s);
	while (t!=NULL) {
		addval(findtok(t));
		t=extract(NULL);
	}
	return(G_numt-ret);
}
char *binary(unsigned long c,int len)
{
	static char tmp[17];
	unsigned int i;
	unsigned long m=1L<<(len-1);
	for (i=0;i<len;i++) {
		tmp[i]='0'+((c&m)!=0);
		m>>=1;
	}
	tmp[i]=0;
	return(tmp);
}
int main(int argc,char*argv[])
{
	char tmp[160];
	unsigned long *c;
	FILE *fp;
	int i;
	if (argc<2) return(0);
	G_lib=malloc(sizeof(ELEM *));
	fp=fopen(argv[1],"r");
	if (fp==NULL) return(0);
	while (fgets(tmp,160,fp)!=NULL) tokenize(tmp);
	fclose(fp);
	reorder();
/*	for (i=0;i<G_numt/4;i++) {
		printf("%s",untoken(G_toks[i].e0));
		printf("%s",untoken(G_toks[i].e1));
		printf("%s",untoken(G_toks[i].e2));
		printf("%s",untoken(G_toks[i].e3));
		printf("%s",untoken(G_toks[i].e4));
		printf("%s",untoken(G_toks[i].e5));
		printf("%s",untoken(G_toks[i].e6));
		printf("%s",untoken(G_toks[i].e7));
	}*/
	printf("G_numt=%d\n",G_numt);
	i=0;
	printf("%s",binary(G_toks[i].e0,10));
	printf("%s",binary(G_toks[i].e1,10));
	printf("%s",binary(G_toks[i].e2,10));
	printf("%s",binary(G_toks[i].e3,10));
	printf("%s",binary(G_toks[i].e4,10));
	printf("%s",binary(G_toks[i].e5,10));
	printf("%s",binary(G_toks[i].e6,10));
	printf("%s",binary(G_toks[i].e7,10));
	printf("\n");
	c=(unsigned long *)G_toks;
	for (i=0;i<2;i++) {
		printf("%s",binary(*(c++),32));
	}
	printf("\n");
	return(1);
}
