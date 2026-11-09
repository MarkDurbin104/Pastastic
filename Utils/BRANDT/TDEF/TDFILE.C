#include <fcntl.h>
#include <io.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include "tdef.h"


void savediag(char *fil) {
	int fd,i,j,m,k,l;
	char filenam[50];
	if (G_dongin) G_dongin=QD();			/* only if dongle */
	if (G_dongin) {
		l=G_nowlev;
		for (k=0;k<G_nolev;k++) {           /* for every level */
			setlevelto(k);                  /* make sure in mem */
			for (j=0;j<G_noelem[k];j++) {   /* for every element */
				if (lev[k].G_elem[j].deled) {   /* if deleted delete it */
					delelem(j--);
				}
			}
			for (j=0;j<G_nocont[k];j++) {     /* same for lines */
				if (lev[k].G_cont[j].deled) {
					delcont(j--);
				}
			}
		}
		sprintf(filenam,"%s.%s",fil,OUTPUT_EXT);
		fd=open(filenam,O_RDWR|O_CREAT|O_TRUNC|O_BINARY,0777);
		if (fd!=(-1)) {
			write(fd,&G_nolev,sizeof(G_nolev));
			for (i=0;i<G_nolev;i++) {
				setlevelto(i);
				write(fd,&G_noelem[i],sizeof(G_noelem[i]));
				write(fd,&G_nocont[i],sizeof(G_nocont[i]));
				write(fd,lev[i].G_elem,sizeof(shape)*G_noelem[i]);
				write(fd,lev[i].G_cont,sizeof(join)*G_nocont[i]);
				for (j=0;j<G_noelem[i];j++) {
					if ((lev[i].G_elem[j].type>10)&&(lev[i].G_elem[j].type<15)) {
						k=psdlen(lev[i].G_elem[j].text);
					}
					else {
						k=strlen(lev[i].G_elem[j].text)+1;
					}
					write(fd,&k,sizeof(int));
					write(fd,lev[i].G_elem[j].text,k);
				}
				for (j=0;j<G_nocont[i];j++) {
					k=strlen(lev[i].G_cont[j].text)+1;
					write(fd,&k,sizeof(int));
					write(fd,lev[i].G_cont[j].text,k);
					k=lev[i].G_cont[j].flags.NOPNT+1;
					write(fd,&k,sizeof(int));
					write(fd,lev[i].G_cont[j].points,k*sizeof(int));
				}
			}
			write(fd,&G_noseqs,sizeof(int));
			for (j=0;j<G_noseqs;j++) {
				write(fd,&G_seqs[j].seq,sizeof(int));
				m=strlen(G_seqs[j].name)+1;
				write(fd,&m,sizeof(int));
				write(fd,G_seqs[j].name,m);
			}
			write(fd,&G_nomsg,sizeof(int));
			for (j=0;j<G_nomsg;j++) {
				write(fd,&G_msg[j].m,sizeof(int));
				write(fd,G_msg[j].n,14);
				write(fd,&G_msg[j].l,sizeof(int));
				if (G_msg[j].l!=(-1)) write(fd,G_msg[j].t,G_msg[j].l);
			}
			write(fd,&G_nolit,sizeof(int));
			for (j=0;j<G_nolit;j++) {
				write(fd,&G_lit[j].l,sizeof(int));
				write(fd,&G_lit[j].t,1);
				switch(G_lit[j].t) {
					case 'l' : {
						write(fd,G_lit[j].v,sizeof(long));
					} break;
					case 'i' : {
						write(fd,G_lit[j].v,sizeof(int));
					} break;
					case 'f' : {
						write(fd,G_lit[j].v,sizeof(float));
					} break;
					case 'd' : {
						write(fd,G_lit[j].v,sizeof(double));
					} break;
					case 'C' : {
						m=strlen(G_lit[j].v)+2;
						write(fd,G_lit[j].v,m);
					} break;
				}
			}
			write(fd,&G_varib.novar,sizeof(int));
			for (j=0;j<G_varib.novar;j++) {
				write(fd,G_varib.vars[j]->name,sizeof(vartype));
			}
			write(fd,&G_nocpm,sizeof(int));
			for (j=0;j<G_nocpm;j++) {
				write(fd,&G_cpm[j].mno,sizeof(int));
				write(fd,&G_cpm[j].noms,sizeof(int));
				write(fd,G_cpm[j].msgs,sizeof(int)*G_cpm[j].noms);
			}
/*			write(fd,&G_noutl,sizeof(int));
			for (j=0;j<G_noutl;j++) {
				write(fd,&G_utl[j].mno,sizeof(int));
				write(fd,&G_utl[j].noms,sizeof(int));
				write(fd,G_utl[j].msgs,sizeof(int)*G_utl[j].noms);
			}*/
			close(fd);
		}
		setlevelto(l);
	}
}

void loaddiag(char *fil) {
	int fd,i,j,l,sti,m,k;
	char filenam[50];
	char str[50];
	sprintf(filenam,"%s.%s",fil,OUTPUT_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	if (fd!=(-1)) {
		read(fd,&l,sizeof(G_nowlev));
		for (i=0;i<l;i++) addlev();
		for (i=0;i<G_nolev-1;i++) {
			setlevelto(i);
			read(fd,&G_noelem[i],sizeof(G_noelem[i]));
			read(fd,&G_nocont[i],sizeof(G_nocont[i]));
			G_nowelem[i]=G_noelem[i];
			G_nowcont[i]=G_nocont[i];
			lev[i].G_elem=(shape *)realloc(lev[i].G_elem,sizeof(shape)*G_noelem[i]);
			lev[i].G_cont=(join *)realloc(lev[i].G_cont,sizeof(join)*G_nocont[i]);
			read(fd,lev[i].G_elem,sizeof(shape)*G_noelem[i]);
			read(fd,lev[i].G_cont,sizeof(join)*G_nocont[i]);
			for (j=0;j<G_noelem[i];j++) {
				read(fd,&k,sizeof(int));
				lev[i].G_elem[j].text=malloc(k+1);
				read(fd,lev[i].G_elem[j].text,k);
			}
			for (j=0;j<G_nocont[i];j++) {
				read(fd,&k,sizeof(int));
				lev[i].G_cont[j].text=malloc(k+1);
				read(fd,lev[i].G_cont[j].text,k);
				read(fd,&k,sizeof(int));
				lev[i].G_cont[j].points=malloc(k*sizeof(int));
				read(fd,lev[i].G_cont[j].points,k*sizeof(int));
			}
		}
		read(fd,&m,sizeof(int));
		for (j=0;j<m;j++) {
			read(fd,&sti,sizeof(int));
			read(fd,&l,sizeof(int));
			read(fd,str,l);
			addseq(str,sti);
		}
		read(fd,&G_nomsg,sizeof(int));
		G_msg=realloc(G_msg,G_nomsg*sizeof(msgs));
		for (j=0;j<G_nomsg;j++) {
			read(fd,&G_msg[j].m,sizeof(int));
			read(fd,G_msg[j].n,14);
			read(fd,&G_msg[j].l,sizeof(int));
			if (G_msg[j].l==(-1)) {
				G_msg[j].t=malloc(1);
			}
			else {
				G_msg[j].t=malloc(G_msg[j].l);
				read(fd,G_msg[j].t,G_msg[j].l);
			}
		}
		read(fd,&G_nolit,sizeof(int));
		G_lit=realloc(G_lit,G_nolit*sizeof(lits));
		for (j=0;j<G_nolit;j++) {
			read(fd,&G_lit[j].l,sizeof(int));
			read(fd,&G_lit[j].t,1);
			switch(G_lit[j].t) {
				case 'l' : {
					G_lit[j].v=malloc(sizeof(long));
					read(fd,G_lit[j].v,sizeof(long));
				} break;
				case 'i' : {
					G_lit[j].v=malloc(sizeof(int));
					read(fd,G_lit[j].v,sizeof(int));
				} break;
				case 'f' : {
					G_lit[j].v=malloc(sizeof(float));
					read(fd,G_lit[j].v,sizeof(float));
				} break;
				case 'd' : {
					G_lit[j].v=malloc(sizeof(double));
					read(fd,G_lit[j].v,sizeof(double));
				} break;
				case 'C' : {
					read(fd,&m,sizeof(int));
					G_lit[j].v=malloc(m);
					read(fd,G_lit[j].v,m);
				} break;
			}
		}
		read(fd,&G_varib.novar,sizeof(int));
		G_varib.vars=realloc(G_varib.vars,sizeof(vartype *)*G_varib.novar+1);
		for (j=0;j<G_varib.novar;j++) {
			G_varib.vars[j]=malloc(sizeof(vartype));
			read(fd,G_varib.vars[j]->name,sizeof(vartype));
		}
		read(fd,&G_nocpm,sizeof(int));
		G_cpm=realloc(G_cpm,G_nocpm*sizeof(cflow));
		for (j=0;j<G_nocpm;j++) {
			read(fd,&G_cpm[j].mno,sizeof(int));
			read(fd,&G_cpm[j].noms,sizeof(int));
			G_cpm[j].msgs=malloc(sizeof(int)*G_cpm[j].noms);
			read(fd,G_cpm[j].msgs,sizeof(int)*G_cpm[j].noms);
		}
		close(fd);
		G_nolev--;
		setlevelto(0);
	}
}

file *loadfile(char *fil,int stno) {
	int fd,i,j;
	file *b;
	char filenam[50];
	if ((b=malloc(sizeof(file)))==(void *)NULL) return(b);
	b->stid=(-1);
	sprintf(filenam,"%s.%s",fil,STORE_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	while (read(fd,b,sizeof(file))>0) {
		if ((b->flds=malloc(sizeof(struct field *)*(b->nofld)))
			==(void *)NULL) return(b);
		for (i=0;i<b->nofld;i++) {
			if ((b->flds[i]=malloc(sizeof(struct field)))
				==(void *)NULL) return(b);
			read(fd,b->flds[i],sizeof(struct field));
		}
		if ((b->keys=malloc(sizeof(struct key *)*(b->nokey)))
			==(void *)NULL) return(b);
		for (i=0;i<b->nokey;i++) {
			if ((b->keys[i]=malloc(sizeof(struct key)))
				==(void *)NULL) return(b);
			read(fd,b->keys[i],sizeof(struct key));
			if ((b->keys[i]->keypts=malloc(sizeof(struct keypt *)*(b->keys[i]->noparts)+1))
				==(void *)NULL) return(b);
			for (j=0;j<b->keys[i]->noparts;j++) {
				if ((b->keys[i]->keypts[j]=malloc(sizeof(struct keypt)))
					==(void *)NULL) return(b);
				read(fd,b->keys[i]->keypts[j],sizeof(struct keypt));
			}
		}
		if (b->stid==stno) {
			close(fd);
			return(b);
		}
		else {
			for (i=0;i<b->nofld;i++) {
				free(b->flds[i]);
			}
			free(b->flds);
			for (i=0;i<b->nokey;i++) {
				for(j=0;j<b->keys[i]->noparts;j++) {
					free(b->keys[i]->keypts[j]);
				}
				free(b->keys[i]->keypts);
				free(b->keys[i]);
			}
			free(b->keys);
		}
	}
	close(fd);
	memset(b,0,sizeof(file));
	b->stid=stno;
	b->type='C';
	return(b);
}

/* will add or overwrite the file to be saved */
int savefile(char *fil,file *rec) {
	int fd,tfd,i,j,xit=0,a;
	file *b;
	char filenam[50],tempnam[50];
	char *t;
	if (G_dongin) G_dongin=QD();
	if (!G_dongin) return(1);
	strcpy(tempnam,".\\");
	if ((tfd=creattemp(tempnam,0))==(-1)) return(0);
	close(tfd);
	tfd=open(tempnam,O_WRONLY|O_BINARY);
	if ((b=malloc(sizeof(file)))==(void *)NULL) return(0);
	b->stid=(-1);
	sprintf(filenam,"%s.%s",fil,STORE_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	while (read(fd,b,sizeof(file))>0) {
		if ((b->flds=malloc(sizeof(struct field *)*b->nofld))
			==(void *)NULL) return(0);
		for (i=0;i<b->nofld;i++) {
			if ((b->flds[i]=malloc(sizeof(struct field)))
				==(void *)NULL) return(0);
			read(fd,b->flds[i],sizeof(struct field));
		}
		if ((b->keys=malloc(sizeof(struct key *)*b->nokey))
			==(void *)NULL) return(0);
		for (i=0;i<b->nokey;i++) {
			if ((b->keys[i]=malloc(sizeof(struct key)))
				==(void *)NULL) return(0);
			read(fd,b->keys[i],sizeof(struct key));
			if ((b->keys[i]->keypts=malloc(sizeof(struct keypt *)*b->keys[i]->noparts))
				==(void *)NULL) return(0);
			for (j=0;j<b->keys[i]->noparts;j++) {
				if ((b->keys[i]->keypts[j]=malloc(sizeof(struct keypt)))
					==(void *)NULL) return(0);
				read(fd,b->keys[i]->keypts[j],sizeof(struct keypt));
			}
		}
		if (b->stid==rec->stid) {
			if (!temprec(rec,tfd)) {
				for (i=0;i<b->nofld;i++) {
					free(b->flds[i]);
				}
				free(b->flds);
				for (i=0;i<b->nokey;i++) {
					for(j=0;j<b->keys[i]->noparts;j++) {
						free(b->keys[i]->keypts[j]);
					}
					free(b->keys[i]->keypts);
					free(b->keys[i]);
				}
				free(b->keys);
				free(b);
				close(fd);
				close(tfd);
				unlink(tempnam);
				return(0);
			}
			xit=1;
		}
		else {
			if (!temprec(b,tfd)) {
				for (i=0;i<b->nofld;i++) {
					free(b->flds[i]);
				}
				free(b->flds);
				for (i=0;i<b->nokey;i++) {
					for(j=0;j<b->keys[i]->noparts;j++) {
						free(b->keys[i]->keypts[j]);
					}
					free(b->keys[i]->keypts);
					free(b->keys[i]);
				}
				free(b->keys);
				free(b);
				close(fd);
				close(tfd);
				unlink(tempnam);
				return(0);
			}
		}
		for (i=0;i<b->nofld;i++) {
			free(b->flds[i]);
		}
		free(b->flds);
		for (i=0;i<b->nokey;i++) {
			for(j=0;j<b->keys[i]->noparts;j++) {
				free(b->keys[i]->keypts[j]);
			}
			free(b->keys[i]->keypts);
			free(b->keys[i]);
		}
		free(b->keys);
	}
	if (!xit) temprec(rec,tfd);
	free(b);
	close(fd);
	close(tfd);
	t=malloc(16384);
	if (t!=(void *)NULL) {
		unlink(filenam);
		if ((tfd=open(tempnam,O_RDONLY|O_BINARY))==(-1)) return(0);
		if ((fd=open(filenam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
		while ((a=read(tfd,t,16384))>0) write(fd,t,a);
		close(fd);
		close(tfd);
		unlink(tempnam);
		free(t);
	}
	else {
		unlink(filenam);
		if ((tfd=open(tempnam,O_RDONLY|O_BINARY))==(-1)) return(0);
		if ((fd=open(filenam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
		while ((a=read(tfd,filenam,50))>0) write(fd,filenam,a);
		close(fd);
		close(tfd);
		unlink(tempnam);
	}
	return(1);
}
/*  write a datastore to the temporary file */
int temprec(file *b,int fd) {
	int i,j;

	if (write(fd,b,sizeof(file))==(-1)) return(0);
	for (i=0;i<b->nofld;i++) {
		if (write(fd,b->flds[i],sizeof(struct field))==(-1)) return(0);
	}
	for (i=0;i<b->nokey;i++) {
		if (write(fd,b->keys[i],sizeof(struct key))==(-1)) return(0);
		for(j=0;j<b->keys[i]->noparts;j++) {
			if (write(fd,b->keys[i]->keypts[j],sizeof(struct keypt))==(-1)) return(0);
		}
	}
	return(1);
}

/*
char *filename(int stno) {
	int fd,i,j,xit=0;
	file *b;
	char filenam[50],filnam[15];
	filnam[0]=0;
	if ((b=malloc(sizeof(file)))==(void *)NULL) return(filnam);
	b->stid=(-1);
	sprintf(filenam,"%s.%s",G_cellname,STORE_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	while ((read(fd,b,sizeof(file))>0)&&(!xit)) {
		if ((b->flds=malloc(sizeof(struct field *)*(b->nofld)))
			==(void *)NULL) xit=1;
		for (i=0;i<b->nofld;i++) {
			if ((b->flds[i]=malloc(sizeof(struct field)))
				==(void *)NULL) xit=1;
			read(fd,b->flds[i],sizeof(struct field));
		}
		if ((b->keys=malloc(sizeof(struct key *)*(b->nokey)))
			==(void *)NULL) xit=1;
		for (i=0;i<b->nokey;i++) {
			if ((b->keys[i]=malloc(sizeof(struct key)))
				==(void *)NULL) xit=1;
			read(fd,b->keys[i],sizeof(struct key));
			if ((b->keys[i]->keypts=malloc(sizeof(struct keypt *)*b->keys[i]->noparts))
				==(void *)NULL) xit=1;
			for (j=0;j<b->keys[i]->noparts;j++) {
				if ((b->keys[i]->keypts[j]=malloc(sizeof(struct keypt)))
					==(void *)NULL) xit=1;
				read(fd,b->keys[i]->keypts[j],sizeof(struct keypt));
			}
		}
		if (b->stid==stno) {
			xit=1;
			strcpy(filnam,b->name);
		}
		for (i=0;i<b->nofld;i++) {
			free(b->flds[i]);
		}
		free(b->flds);
		for (i=0;i<b->nokey;i++) {
			for(j=0;j<b->keys[i]->noparts;j++) {
				free(b->keys[i]->keypts[j]);
			}
			free(b->keys[i]->keypts);
			free(b->keys[i]);
		}
		free(b->keys);
		free(b);
	}
	close(fd);
	free(b);
	return(filnam);
}*/

/* calculate the length of PSD line */
int psdlen(char *ln) {
	int xit,k;
	char *t;
	k=0;
	xit=0;
	while(!xit) {
		switch(ln[k]) {
			case 'O' :                /* oper */
			case 'F' :                /* File */
			case 'V' :                /* var */
			case 'C' : {              /* Command */
				k+=sizeof(int)+1;     /* Letter + int */
			} break;
			case 'L' : {              /* Literals */
				k++;
				t=&ln[k];
				while (*(t++)!='^') {  /* ^ terminated */
					k++;
				}
				k++;
			} break;
			case 'E' : {              /* File element fno.ffield */
				k+=2*sizeof(int)+1;
			} break;
			default : {               /* corrupt or Z */
				xit=1;
			}
		}
	}
	k++;
	return(k);
}

/* called when key is hit during print */
int pnexit(FILE *printer) {
	int i;
	getch();
	G_ltype=0;
	fprintf(printer,"%cA%c%c",27,10,12);
	fclose(printer);
	for (i=0;i<G_szpbuf;i++) free(G_scr[i*3]);
	return(0);
}

/*  print all the lines in current buffer */
void prlines(FILE *p) {
	int j,k,w;
	unsigned char *t;
	for (k=0;k<G_szpbuf*3;k+=3) memset(G_scr[k],0,G_dpl*3); /*clr buffer */
	redraw(1);
	for (k=0;k<G_szpbuf*3;k+=3) {	/* for each buffer avail 24 bit line */
		w=0; t=G_scr[k];
		while (!*(t++)&&(w<G_dpl*3)) w++;   /* check to see if anything to print */
		if (w<G_dpl*3) {				/* found something (damn) */
			w--; t--;
			while (w<G_dpl*3) {
				if (*t==26) *t=22; else if (*t==10) *t=9; /* fix epson error */
				t++; w++;
			}
			fprintf(p,"%c*%c%c%c",27,39,G_dpl%256,G_dpl/256); /* out it goes */
			for (j=0;j<G_dpl;j++) {
				fputc(G_scr[k  ][j],p);
				fputc(G_scr[k+1][j],p);
				fputc(G_scr[k+2][j],p);
			}
		}
		fprintf(p,"\n");
		if (kbhit()) return;	/* check if exit stuff */
	}
}

/*	swap two fields in current file */
void swapflds(int f1,int f2) {
	int i,j;
	for (i=0;i<G_nolev;i++) {
		for (j=0;j<G_noelem[i];j++) {		/* PSD lines */
			if (lev[i].G_elem[j].type==11) modyfldinln(lev[i].G_elem[j].text,f1,f2);
		}
	}
	for (j=0;j<G_nomsg;j++) modyfldinln(G_msg[j].t,f1,f2);  /*Msg lines */
	for (j=0;j<G_noutl;j++) modyfldinln(G_utl[j],f1,f2);    /* Until lines */
	swapfflds(f1,f2);					/* swap fields in forms */
	swaprflds(f1,f2); 					/* swap fields in reports */
}

/* swap f1 and f2 fields in a PSD line */
void modyfldinln(char *buf,int f1,int f2) {
	int k,xit=0;
	union {
		char *c;
		int  *i;
	} u;
	k=0;
	while (!xit) {
		switch(buf[k]) {       /* if not interested then pass over */
			case 'C' :
			case 'F' :
			case 'V' :
			case 'O' :	k+=sizeof(int)+1;				break;
			case 'L' :	while (buf[++k]!='^'); k++; 	break;
			case 'E' :                    /* if file ref */
						k++;
						u.c=&buf[k];
						k+=sizeof(int);
						if (*u.i==G_storeid) {     /* if correct store */
							u.c=&buf[k];
							if (*u.i==f1) {        /* swap fields */
								*u.i=f2;
							}
							else {
								if (*u.i==f2) {
									*u.i=f1;
								}
							}
						}
						k+=sizeof(int);
						break;
			default  :	xit=1;
		}
	}
}

/* check to see if a field is in use anywhere */
int fldinuse(int f) {
	int i,j;
	for (i=0;i<G_nolev;i++) {                   /* PSD's */
		for (j=0;j<G_noelem[i];j++) {
			if (lev[i].G_elem[j].type==11) {
				if (findfld(lev[i].G_elem[j].text,f)) {
					return(1);
				}
			}
		}
	}
	for (j=0;j<G_nomsg;j++) {                  /* Messages */
		if (findfld(G_msg[j].t,f)) {
			return(1);
		}
	}
	for (j=0;j<G_noutl;j++) {                 /* Until lines */
		if (findfld(G_utl[j],f)) {
			return(1);
		}
	}
/*	if (findffld(f)) return(1);				/* find field in forms */
	if (findrfld(f)) return(1); 			/* find field in reports */
	return(0);
}

/* Find a field in a PSD  - see modyfldinln */
int findfld(char *buf,int f) {
	int k,xit=0;
	union {
		char *c;
		int  *i;
	} u;
	k=0;
	while (!xit) {
		switch(buf[k]) {
			case 'C' :
			case 'F' :
			case 'V' :
			case 'O' :	k+=sizeof(int)+1;				break;
			case 'L' :	while (buf[++k]!='^'); k++; 	break;
			case 'E' :
						k++;
						u.c=&buf[k];
						k+=sizeof(int);
						if (*u.i==G_storeid) {
							u.c=&buf[k];
							if (*u.i==f) {
								return(1);
							}
						}
						k+=sizeof(int);
						break;
			default  :	xit=1;
		}
	}
	return(0);
}
