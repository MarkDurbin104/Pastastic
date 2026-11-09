#include <stdio.h>
#include <string.h>

#ifdef TURBOC
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#else
#define gotoxy(x,y);	fprintf(stdout,"%c[%d;%d"); fflush(stdout);
#define cprintf(a)		fprintf(stdout,a)
#endif

#define TABSTOP 4
#define CUT		0

struct link {		/* DOUBLE LINKED LIST STRUCTURE	*/
	struct link *p;	/* PREVIOUS LINK (NULL IF NONE)	*/
	struct link *n;	/* NEXT     LINK (NULL IF NONE)	*/
	char *ln;		/* STRING IN LINK				*/
};
struct link *c;		/*	CURRENT						*/
struct link *t;		/*	TOP							*/
struct link *b;		/*	BOTTOM						*/
int G_nolines;		/*	NUMBER OF LINES IN FILE		*/
int xpos,ypos;

#ifdef TURBOC
struct link *fstln(char *line);
int addln(struct link *l,char *line);
int insln(struct link *l,char *line);
int delln(struct link *l);
int remtabs(char *ln);
int prpage(struct link *c);
#endif

main(argc,argv)
int argc;
char ** argv; {
	FILE *fp;
	int i;
	char ext,k;
	char line[256];
	if (argc<2) {
		fprintf(stdout,"tedit filename\n");
		exit(-1);
	}
	if ((fp=fopen(argv[1],"r"))==NULL) {
		fprintf(stdout,"Can't Open %s\n",argv[1]);
		exit(-1);
	}
	i=0;
	ext=0;
	while (((fgets(line,255,fp))!=NULL)&&(ext==0)) {
		if (i==0) {
			if ((t=fstln(line))==(struct link *)NULL) {
				ext=1;
			}
			b=t;
		}
		else {
			if (!(addln(b,line))) {
				ext=1;
			}
			else {
				b=b->n;
			}
		}
		i++;
	}
	fclose(fp);
	G_nolines=i;
	if (G_nolines==0) exit(-1);
	c=t;
	prpage(c);
	ext=0;
	do {
		gotoxy((xpos%80)+1,(ypos+(xpos/80))+1);
		k=getch();
		switch(k) {
			case 0 : {
				k=getch();
				switch(k) {
					case 'G' : {
						c=t;
						prpage(c);
					} break;
					case 'O' : {
						c=b;
						for (i=0;i<23;i++) {
							if (c!=t) c=c->p;
						}
						prpage(c);
					} break;
					case 'Q' : {
						for (i=0;i<23;i++) {
							if (c!=b) c=c->n;
						}
						if (c==b) {
							for (i=0;i<23;i++) {
								if (c!=t) c=c->p;
							}
						}
						prpage(c);
					} break;
					case 'I' : {
						for (i=0;i<23;i++) {
							if (c!=t) c=c->p;
						}
						prpage(c);
					} break;
					case 'v' : {
						for (i=0;i<12;i++) {
							if (c!=b) c=c->n;
						}
						prpage(c);
					} break;
					case '„' : {
						for (i=0;i<12;i++) {
							if (c!=t) c=c->p;
						}
						prpage(c);
					} break;
					case 'P' : {
						ypos++;
						if (ypos>23) {
							if (c!=b) c=c->n;
							ypos=23;
							prpage(c);
						}
					} break;
					case 'H' : {
						ypos--;
						if (ypos<0) {
							if (c!=t) c=c->p;
							ypos=0;
							prpage(c);
						}
					} break;
				}
			} break;
			case 27 : {
				ext=1;
			} break;
		}
	} while(!(ext));
/*	b=b->p;
	while (b!=(struct link *)NULL) {
		delln(b->n);
		b=b->p;
	}
	delln(t);*/
	return(1);
}
struct link *fstln(line)
char *line; {
	struct link *l;
	l=(struct link *)farmalloc(sizeof(struct link));
	if (l==(struct link *)NULL) {
		return((struct link *)NULL);
	}
	l->ln=(char *)farmalloc(strlen(line)*2);
	if (l->ln==(char *)NULL) {
		farfree((struct link *)l);
		l=(struct link *)NULL;
		return((struct link *)NULL);
	}
	l->n=l->p=(struct link *)NULL;
	strcpy(l->ln,line);
	return(l);
}
addln(l,line) /* Passed Bottom Adds New After */
struct link* l;
char *line; {
	l->n=(struct link *)farmalloc(sizeof(struct link));
	if (l->n==(struct link *)NULL) {
		return(0);
	}
	l->n->ln=(char *)farmalloc(strlen(line)*2);
	if (l->n->ln==(char *)NULL) {
		farfree((struct link *)l->n);
		l->n=(struct link *)NULL;
		return(0);
	}
	l->n->p=l;
	l->n->n=(struct link *)NULL;
	strcpy(l->n->ln,line);
	return(1);
}
insln(l,line) /* ABOVE THIS LINK */
struct link* l;
char *line; {
	l->p->n=(struct link *)farmalloc(sizeof(struct link));
	if (l->p->n==(struct link *)NULL) {
		return(0);
	}
	l->p->n->ln=(char *)farmalloc(strlen(line)*2);
	if (l->p->n->ln==(char *)NULL) {
		farfree((struct link *)l->p);
		l->p->n=(struct link *)NULL;
		return(0);
	}
	l->p->n=l;
	l->p->p=(struct link *)NULL;
	strcpy(l->p->ln,line);
	return(1);
}
delln(l) /* THIS LINK */
struct link* l; {
	farfree((char *)l->ln);
	if (l->p!=(struct link *)NULL) l->p->n=l->n;
	if (l->n!=(struct link *)NULL) l->n->p=l->p;
	farfree((struct link *)l);
	return(1);
}
cngln(l,line)
struct link* l;
char *line; {
	l->ln=(char *)farrealloc(l->ln,strlen(line)*2);
	if (l->ln==(char *)NULL) {
		return(0);
	}
	strcpy(l->ln,line);
	return(1);
}
remtabs(ln)
char *ln; {
	char tmp[256];
	int i,j,k=0;
	for(i=0;i<strlen(ln);i++) {
		if (ln[i]=='\t') {
			for (j=k%TABSTOP;j<TABSTOP;j++) {
				tmp[k++]=' ';
			}
		}
		else {
			tmp[k++]=ln[i];
		}
	}
	tmp[k]=0;
	strcpy(ln,tmp);
	return(1);
}
prpage(c)
struct link *c; {
	int i;
	struct link *cur;
	char tmp[256];
	cur=c;
	clrscr();
	i=0;
	while (i<24) {
		gotoxy(1,i+1);
		strcpy(tmp,cur->ln);
		if (CUT) {
			tmp[80]=0;
			i++;
		}
		else {
			i+=(strlen(cur->ln)/80)+1;
		}
		remtabs(tmp);
		cprintf("%s",tmp);
		cur=cur->n;
		if (cur==(struct link *)NULL) i=24;
	}
	return(1);
}