					/* ICL OFFICE LANSING 0256-840192 */

#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
struct {
	char *s;
	int  i;
} G_seqn[1000];
typedef struct {
	int		stid;
	char	type;
	char	name[15];
	int		len;
	char	desc[41];
	char	nofld;
	struct field {
		int		ofs;
		int		len;
		char	type;
		char	name[15];
		char	desc[41];
	} **flds;
	char	nokey;
	struct key {
		char	noparts;
		struct keypt {
			char	fld;
			char	fldordr;
		} **keypts;
	} **keys;
} file;
file G_file[30];
int G_nofile;
int G_nonam;
int G_cnt;
int G_hadanmt=(-1);
int G_hadanif=0;
int G_seqnum[1000];
char 			comtype[33]={
	1,1,3,3,3,3,3,9,3,3,3,3,3,3,3,4,4,
	5,5,6,6,6,6,8,8,8,0,7,13,10,11,11,12	};
char 			*command[35]={
	"IF","COMPARE",
	"OPEN FILE","CLOSE FILE",
	"TRUNCATE FILE","CREATE FILE",
	"DELETE FILE","FIND RECORD IN",
	"GET NEXT RECORD FROM","GET PREV RECORD FROM",
	"GET FIRST RECORD FROM","GET LAST RECORD FROM",
	"WRITE RECORD TO","OVERWRITE RECORD IN",
	"DELETE RECORD FROM","TRANSMIT MESSAGE",
	"WAIT ON MESSAGE","OPEN ARRAY",
	"CLOSE ARRAY","START TRANSACTION",
	"END TRANSACTION","EXIT",
	"CLOSE FILES & EXIT","SPAWN PROCESS",
	"KILL PROCESS","SIGNAL",
	"USING KEY","SYSTEM",
	"STRING JOIN","STRING CUT",
	"STRING INSERT","STRING OVERWRITE",
	"STRING LENGTH","UNTIL",
	"REPEAT" };

char	*cmd[55]={ 	"IF","CP","FR","FC","FT","FA","FD","RF","RN","RP",
					"RW","FF","AR","RO","DR","MT","MR","DA","UA","MS",
					"ME","QU","QC","PS","PK","SE","SJ","SC","SL","SR",
					"SI","SO","LS","MV","NA","FW","MD","RT","UT","SN",
					"NS","EL","OR","AN","XO","NO","AF","CA","EX","GT",
					"IU","RC","RM","RR","TF" };

char 	*operator[26]= {
					"=",">",">=","==","!=","<","<=","<>","OR","AND",
					"EXOR","NOT","(",")","IS NOT IN USE","SHL","SHR",
					"+","-","*","/","=","(",")","DIV","MOD"	};
char 	*G_const[26]={
					"B","N","P","S","m?","R","e","p?","x?","E","a",
					"t","A","D","o","O","j","T?","r","C","H0","H1",
					"H2","H3","H4","M" };

typedef struct {
	int  sqn;
	char cmd;
	char fil;
	int key;
	int  seq;
	char oper[3];
	struct {
		char c;
		int i;
	} v[4];
} seqs;
typedef struct {
	int  l;
	char t;
	void *v;
} lits;
lits	*G_lit;
int		G_nolit;
typedef struct {
	int  m;
	char n[14];
	int  l;
	char *t;
} msgs;
msgs	*G_msg;
int		G_nomsg;

char			*G_ml[500];			/* message lines		*/
unsigned char	G_mn[500];			/* message number		*/
char			G_ms[500];			/* message seperator	*/
int 			G_nm;				/* No. message lines	*/


seqs	G_seq;
seqs	G_seqt[2];
char	G_seqln[1000];
int		G_fd;
void	stln(char *ln);
void	fldln(char *ln);
void	keyln(char *ln);
int  getseqln(char *ln);
char *tpsdln(char *text);
void convseqln(void);
void seqln(int isif);
void endln(int seq);
void addcmd(int cmd);
void addfile(void);
void addvar(int varno);
void addfield(int varno);
void litln(char *ln);
void msgln(char *ln);
int addmsgln(char *ln);
void prscr(char *fl);
int savefile(char *fil,file *rec);
int temprec(file *b,int fd);

main(int argc,char **argv) {
	FILE *fp;
	int j,sv,e,k,nowseq=(-1),q=0,l;
	char currentln[150],*t;
	if (argc<6) {
		printf("extract sfile dfile sseq eseq rseq [.tds file]\n");
		exit(-1);
	}
	sv=atoi(argv[3]);
	e=atoi(argv[4]);
	if ((fp=fopen("seqname.seq","r"))==NULL) {
		printf("Can't Open File seqname.seq\n");
		exit(-1);
	}
	G_lit=malloc(sizeof(lits));
	G_nolit=0;
	G_msg=malloc(sizeof(msgs));
	G_nomsg=0;
	G_nm=0;
	G_cnt=0;
	j=0;
	while (fgets(currentln,120,fp)!=NULL) {
		t=strtok(currentln," \t\r\n");
		G_seqn[j].i=atoi(t);
		t=strtok((char *)NULL," \t\n\r");
		G_seqn[j].s=malloc(strlen(t)+2);
		strcpy(G_seqn[j].s,t);
		for (k=0;k<strlen(G_seqn[j].s);k++) if (G_seqn[j].s[k]=='_') G_seqn[j].s[k]=' ';
		j++;
	}
	fclose(fp);
	G_nonam=j;
	j=0;
	if ((fp=fopen(argv[1],"r"))==NULL) {
		printf("Can't Open File %s\n",argv[1]);
		exit(-1);
	}
	while (fgets(currentln,120,fp)!=NULL) {
		j++;
		switch (currentln[0]) {
			case 't' : {
				stln(&currentln[1]);
			} break;
			case 'f' : {
				fldln(&currentln[1]);
			} break;
			case 'k' : {
				keyln(&currentln[1]);
			} break;
			case 's' : {
				if (nowseq!=atoi(&currentln[1])) {
					nowseq=atoi(&currentln[1]);
					G_seqnum[nowseq]=q++;
				}
			} break;
			case 'l' : {
				litln(&currentln[1]);
			} break;
			case 'm' : {
				msgln(&currentln[1]);
			} break;
		}
	}
	fclose(fp);
	if (argc==7) prscr(argv[6]);
	if ((G_fd=open(argv[2],O_WRONLY|O_TRUNC|O_CREAT|O_BINARY,0777))==(-1)) {
		printf("Can't Open File %s\n",argv[2]);
		exit(-1);
	}
	write(G_fd,&G_nolit,sizeof(int));
	for (j=0;j<G_nolit;j++) {
		write(G_fd,&G_lit[j].l,sizeof(int));
		write(G_fd,&G_lit[j].t,1);
		switch(G_lit[j].t) {
			case 'l' : {
				write(G_fd,G_lit[j].v,sizeof(long));
			} break;
			case 'i' : {
				write(G_fd,G_lit[j].v,sizeof(int));
			} break;
			case 'f' : {
				write(G_fd,G_lit[j].v,sizeof(float));
			} break;
			case 'd' : {
				write(G_fd,G_lit[j].v,sizeof(double));
			} break;
			case 'C' : {
				l=strlen((char *)G_lit[j].v)+2;
				write(G_fd,&l,sizeof(int));
				write(G_fd,G_lit[j].v,l);
			} break;
		}
	}
	write(G_fd,&G_seqnum[atoi(argv[5])],sizeof(int));
	j=0;
	if ((fp=fopen(argv[1],"r"))==NULL) {
		printf("Can't Open File %s\n",argv[1]);
		exit(-1);
	}
	while (fgets(currentln,120,fp)!=NULL) {
		j++;
		switch (currentln[0]) {
			case 's' : {
            	nowseq=atoi(&currentln[1]);
				if ((nowseq>=sv)&&(nowseq<=e)) {
					if (getseqln(&currentln[1])<9) {
						printf("Not Enough Fields %d Line %d\n",G_seq.sqn,j);
					}
					else {
						convseqln();
					}
				}
			} break;
		}
	}
	fclose(fp);
	j=4;
	write(G_fd,&j,sizeof(int));
	write(G_fd,&j,sizeof(int));
	write(G_fd,"END",j);
	write(G_fd,&j,sizeof(int));
	write(G_fd,&G_nomsg,sizeof(int));
	for (j=0;j<G_nomsg;j++) {
		write(G_fd,&G_msg[j].m,sizeof(int));
		write(G_fd,G_msg[j].n,14);
		write(G_fd,&G_msg[j].l,sizeof(int));
		write(G_fd,G_msg[j].t,G_msg[j].l);
	}
	close(G_fd);
	return(1);
}
int getseqln(char *ln) {
	char *t;
	int i,j,k;
	i=atoi(t=strtok(ln," \t\n\r"));
	if (i!=G_seq.sqn) {
		if (G_hadanif) {
			memcpy(&G_seqt[1],&G_seq,sizeof(seqs)); /* seq -> tmp */
			memcpy(&G_seq,&G_seqt[0],sizeof(seqs)); /* last -> seq */
			endln(0);
			if (G_hadanif==1) {
				strcpy(G_seqln,"LTRUE^Z");
				G_cnt=strlen(G_seqln);
				seqln(0);
				sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
				for (j=0;j<G_nonam;j++) {
					if (G_seqn[j].i==G_seq.seq) {
					sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
						break;
					}
				}
				G_cnt=strlen(G_seqln);
				seqln(0);
			}
			memcpy(&G_seq,&G_seqt[1],sizeof(seqs)); /* tmp -> seq */
			G_hadanif=0;
		}
		G_seq.sqn=i;
		sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.sqn);
		for (j=0;j<G_nonam;j++) {
			if (G_seqn[j].i==G_seq.sqn) {
				sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
				break;
			}
		}
		G_cnt=strlen(G_seqln);
		G_hadanmt=(-1);
		seqln(0);
		G_cnt=0;
	}
	memset(&G_seq,0,sizeof(seqs));
	G_seq.sqn=i;
	i=0;
	k=0;
	while (t!=(char *)NULL) {
		t=strtok((char *)NULL," \t\n\r");
		switch(i) {
			case 0 : {
				G_seq.seq=0;
				G_seq.cmd=99;
				for (j=0;j<55;j++) {
					if (!strcmp(t,cmd[j])) {
						G_seq.cmd=j;
						break;
					}
				}
				if (G_seq.cmd==15) k=1;
				if (G_seq.cmd==36) k=2;
			} break;
			case 1 : {
				G_seq.fil=atoi(t);
			} break;
			case 2 : {
				G_seq.key=atoi(t);
			} break;
			case 3 : {
				G_seq.seq=atoi(t);
			} break;
			case 4 : {
				strcpy(G_seq.oper,t);
			} break;
			case 5 : {
				if (k) {
					G_seq.v[i-5].c='M';
					G_seq.v[i-5].i=atoi(t);
				}
				else {
					G_seq.v[i-5].c=*t;
					G_seq.v[i-5].i=atoi(t+1);
				}
			} break;
			case 6 : {
				if (k==1) {
					G_seq.v[i-5].c='M';
					G_seq.v[i-5].i=atoi(t);
				}
				else {
					G_seq.v[i-5].c=*t;
					G_seq.v[i-5].i=atoi(t+1);
				}
			} break;
			case 7 :
			case 8 : {
				G_seq.v[i-5].c=*t;
				G_seq.v[i-5].i=atoi(t+1);
			} break;
			default : {
			}
		}
		i++;
	}
	return(i);
}
void litln(char *ln) {
	char *t;
	int i;
	G_nolit++;
	G_lit=realloc(G_lit,sizeof(lits)*G_nolit);
	G_lit[G_nolit-1].l=atoi(t=strtok(ln," \t\n\r"));
	t=strtok((char *)NULL," \t\n\r");
	G_lit[G_nolit-1].t=*t;
	i=0;
	while (t!=(char *)NULL) {
		if (i<4) {
			t=strtok((char *)NULL," \t\n\r");
		}
		else {
			t=strtok((char *)NULL,"\t\n\r");
		}
		switch(i) {
			case 0 : {
				if (G_lit[G_nolit-1].t=='l') {
					G_lit[G_nolit-1].v=malloc(sizeof(long));
					*((long *)G_lit[G_nolit-1].v)=atol(t);
				}
			} break;
			case 1 : {
				if (G_lit[G_nolit-1].t=='i') {
					G_lit[G_nolit-1].v=malloc(sizeof(int));
					*((int *)G_lit[G_nolit-1].v)=atoi(t);
				}
			} break;
			case 2 : {
				if (G_lit[G_nolit-1].t=='f') {
					G_lit[G_nolit-1].v=malloc(sizeof(float));
					*((float *)G_lit[G_nolit-1].v)=atof(t);
				}
			} break;
			case 3 : {
				if (G_lit[G_nolit-1].t=='d') {
					G_lit[G_nolit-1].v=malloc(sizeof(double));
					*((double *)G_lit[G_nolit-1].v)=atof(t);
				}
			} break;
			case 4 : {
				if (G_lit[G_nolit-1].t=='C') {
					G_lit[G_nolit-1].v=malloc(strlen(t)+2);
					strcpy((G_lit[G_nolit-1].v),t);
				}
			} break;
			default : {
			}
		}
		i++;
	}
/*	printf("Literal %3d type %c Value \"",G_lit[G_nolit-1].l,G_lit[G_nolit-1].t);
	switch(G_lit[G_nolit-1].t) {
		case 'l' : {
			printf("%ld\"\n",*((long *)G_lit[G_nolit-1].v));
		} break;
		case 'i' : {
			printf("%d\"\n",*((int *)G_lit[G_nolit-1].v));
		} break;
		case 'f' : {
			printf("%f\"\n",*((float *)G_lit[G_nolit-1].v));
		} break;
		case 'd' : {
			printf("%f\"\n",*((double *)G_lit[G_nolit-1].v));
		} break;
		case 'C' : {
			printf("%s\"\n",(char *)G_lit[G_nolit-1].v);
		} break;
	}*/
}
void msgln(char *ln) {
	char *t;
	G_mn[G_nm]=atoi(strtok(ln," \t\n\r"));
	G_ms[G_nm]=atoi(strtok((char *)NULL," \t\n\r"));
	t=strtok((char *)NULL,"\t\n\r");
	G_ml[G_nm]=malloc(strlen(t)+2);
	strcpy(G_ml[G_nm],t);
/*	printf("m%d %d %s\n",G_mn[G_nm],G_ms[G_nm],G_ml[G_nm]);*/
	G_nm++;
}
char *tpsdln(char *text) {
	int i,j,xit;
	static char tmp[200];
	char *t,tmp1[200];
	union {
		char *c;
		int  *i;
	} u;
	tmp[0]=0;
	i=0;
	xit=0;
	while (!xit) {
		switch(text[i]) {
			case 'C' : {
				i++;
				u.c=&text[i];
				strcat(tmp,command[*u.i]);
				i+=sizeof(int);
			} break;
			case 'L' : {
				i++;
				j=strlen(tmp);
				t=&text[i];
				while (*(t++)!='^') {
					tmp[j++]=text[i++];
				}
				tmp[j++]=0;
				i++;
			} break;
			case 'O' : {
				i++;
				u.c=&text[i];
				strcat(tmp,operator[*u.i]);
				i+=sizeof(int);
			} break;
			case 'F' : {
				i++;
				u.c=&text[i];
				sprintf(tmp1,"S(%d)",*u.i);
				strcat(tmp,tmp1);
				i+=sizeof(int);
			} break;
			case 'E' : {
				i++;
				u.c=&text[i];
				sprintf(tmp1,"S(%d).",*u.i);
				strcat(tmp,tmp1);
				i+=sizeof(int);
				u.c=&text[i];
				sprintf(tmp1,"(%d)",*u.i);
				strcat(tmp,tmp1);
				i+=sizeof(int);
			} break;
			case 'V' : {
				i++;
				u.c=&text[i];
				sprintf(tmp1,"V(%d)",*u.i);
				strcat(tmp,tmp1);
				i+=sizeof(int);
			} break;
			case 'Z' : {
				xit=1;
			} break;
			default : {
				xit=1;
			}
		}
		strcat(tmp," ");
	}
	tmp[strlen(tmp)-2]=0;
	return(tmp);
}
void convseqln(void) {
	int j;
	static int noln=0;
	char tmp[50];
	union {
		char *c;
		int *i;
	} u;
	if (((G_seq.cmd<42)||(G_seq.cmd>45))&&(G_seq.cmd>1)&&(G_hadanif)&&(G_seq.cmd!=38)) {
		memcpy(&G_seqt[1],&G_seq,sizeof(seqs)); /* seq -> tmp */
		memcpy(&G_seq,&G_seqt[0],sizeof(seqs)); /* last -> seq */
		endln(0);
		if (G_hadanif==1) {
			strcpy(G_seqln,"LTRUE^Z");
			G_cnt=strlen(G_seqln);
			seqln(0);
			sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
			for (j=0;j<G_nonam;j++) {
				if (G_seqn[j].i==G_seq.seq) {
					sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
					break;
				}
			}
			G_cnt=strlen(G_seqln);
			seqln(0);
		}
		G_hadanif=0;
		memcpy(&G_seq,&G_seqt[1],sizeof(seqs)); /* tmp -> seq */
	}
	switch(G_seq.cmd) {
		case 0 :
		case 1 : {
			if (G_hadanif) {
				memcpy(&G_seqt[1],&G_seq,sizeof(seqs)); /* seq -> tmp */
				memcpy(&G_seq,&G_seqt[0],sizeof(seqs)); /* last -> seq */
				endln(0);
				if (G_hadanif==1) {
					strcpy(G_seqln,"LTRUE^Z");
					G_cnt=strlen(G_seqln);
					seqln(0);
					sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
					for (j=0;j<G_nonam;j++) {
						if (G_seqn[j].i==G_seq.seq) {
							sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
							break;
						}
					}
					G_cnt=strlen(G_seqln);
					seqln(0);
				}
				memcpy(&G_seq,&G_seqt[1],sizeof(seqs)); /* tmp -> seq */
			}
			memcpy(&G_seqt[0],&G_seq,sizeof(seqs)); /* seq -> last */
			addcmd(G_seq.cmd);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			G_seqln[G_cnt++]='O';
			for (j=0;j<26;j++) {
				if (!strcmp(G_seq.oper,operator[j])) {
					u.c=&G_seqln[G_cnt];
					*u.i=j;
					G_cnt+=sizeof(int);
					break;
				}
			}
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			G_hadanif=1;
			G_hadanmt=(-1);
		} break;
		case 38 : {
			if (G_hadanif) {
				memcpy(&G_seqt[1],&G_seq,sizeof(seqs)); /* seq -> tmp */
				memcpy(&G_seq,&G_seqt[0],sizeof(seqs)); /* last -> seq */
				endln(0);
				if (G_hadanif==1) {
					strcpy(G_seqln,"LTRUE^Z");
					G_cnt=strlen(G_seqln);
					seqln(0);
					sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
					for (j=0;j<G_nonam;j++) {
						if (G_seqn[j].i==G_seq.seq) {
							sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
							break;
						}
					}
					G_cnt=strlen(G_seqln);
					seqln(0);
				}
				memcpy(&G_seq,&G_seqt[1],sizeof(seqs)); /* tmp -> seq */
			}
			memcpy(&G_seqt[0],&G_seq,sizeof(seqs)); /* seq -> last */
			addcmd(33);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			G_seqln[G_cnt++]='O';
			for (j=0;j<26;j++) {
				if (!strcmp(G_seq.oper,operator[j])) {
					u.c=&G_seqln[G_cnt];
					*u.i=j;
					G_cnt+=sizeof(int);
					break;
				}
			}
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			G_hadanif=2;
			G_hadanmt=(-1);
		} break;
		case 42 :
		case 43 :
		case 44 :
		case 45 : {
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=G_seq.cmd-34;
			G_cnt+=sizeof(int);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			G_seqln[G_cnt++]='O';
			for (j=0;j<26;j++) {
				if (!strcmp(G_seq.oper,operator[j])) {
					u.c=&G_seqln[G_cnt];
					*u.i=j;
					G_cnt+=sizeof(int);
					break;
				}
			}
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			G_hadanmt=(-1);
		} break;
		case 50 : {
			addcmd(1);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=14;
			G_cnt+=sizeof(int);
			endln(0);
			strcpy(G_seqln,"LTRUE^Z");
			G_cnt=strlen(G_seqln);
			seqln(0);
			sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
			for (j=0;j<G_nonam;j++) {
				if (G_seqn[j].i==G_seq.seq) {
					sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
					break;
				}
			}
			G_cnt=strlen(G_seqln);
			seqln(0);
			G_hadanmt=(-1);
		} break;
		case 2 :
		case 3 :
		case 4 :
		case 5 :
		case 6 :
		case 8 :
		case 9 :
		case 10 :
		case 11 :
		case 12 :
		case 13 :
		case 14 : {
			addcmd(G_seq.cmd);
			addfile();
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 15 : {
			if (G_hadanmt!=G_seq.v[0].i) {
				G_hadanmt=G_seq.v[0].i;
				addcmd(G_seq.cmd);
				addvar(0);
				for (j=0;j<G_nm;j++) {
					if (G_mn[j]==G_hadanmt) {
						noln=j;
						break;
					}
				}
			}
			sprintf(&G_seqln[G_cnt],"L%s^Z",G_ml[noln]);
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			noln++;
			if (G_mn[noln]!=G_hadanmt) {
				G_seqln[G_cnt]='Z';
				G_seqln[G_cnt+1]=0;
				G_seq.v[0].i=addmsgln(&G_seqln[3]);
				G_cnt=0;
				addcmd(G_seq.cmd);
				addvar(0);
				sprintf(&G_seqln[G_cnt],"LTOœ%d^Z",G_seq.key);
				G_cnt+=strlen(&G_seqln[G_cnt])-1;
				if (G_seq.key==11112) {
					if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
				}
				G_seqln[G_cnt]='Z';
				G_seqln[G_cnt+1]=0;
				endln(G_seqnum[G_seq.seq]);
				noln=0;
			}
		} break;
		case 36 : {
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
		} break;
		case 7 : {
			addcmd(G_seq.cmd);
			G_seqln[G_cnt++]='O';
			for (j=0;j<26;j++) {
				if (!strcmp(G_seq.oper,operator[j])) {
					u.c=&G_seqln[G_cnt];
					*u.i=j;
					G_cnt+=sizeof(int);
					break;
				}
			}
			addfile();
			addcmd(26);
			G_seqln[G_cnt++]='L';
			memset(tmp,0,49);
			itoa(G_seq.key,tmp,10);
			strcpy(&G_seqln[G_cnt],tmp);
			G_cnt+=strlen(tmp);
			G_seqln[G_cnt++]='^';
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 33 :
		case 39 :
		case 40 : {
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 48 : {
			addcmd(27);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
/*			G_seqln[G_cnt++]='Z';
			G_seqln[G_cnt]=0;
			printf("%s\n",tpsdln(G_seqln));
			printf("s%d %s %d %d %d %s %c%d %c%d %c%d %c%d\n",G_seq.sqn,
				cmd[G_seq.cmd],G_seq.fil,G_seq.key,G_seq.seq,G_seq.oper,
				G_seq.v[0].c,G_seq.v[0].i,
				G_seq.v[1].c,G_seq.v[1].i,
				G_seq.v[2].c,G_seq.v[2].i,
				G_seq.v[3].c,G_seq.v[3].i);*/
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 34 : {
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			G_seqln[G_cnt++]='O';
			for (j=0;j<26;j++) {
				if (!strcmp(G_seq.oper,operator[j])) {
					u.c=&G_seqln[G_cnt];
					*u.i=j;
					G_cnt+=sizeof(int);
					break;
				}
			}
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 35 : {
			addcmd(2);
			addfile();
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 37 : {
			addcmd(34);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 41 : {
			strcpy(G_seqln,"LFALSE^Z");
			G_cnt=strlen(G_seqln);
			seqln(0);
			sprintf(G_seqln,"LSEQ(%d)^Z",G_seq.seq);
			for (j=0;j<G_nonam;j++) {
				if (G_seqn[j].i==G_seq.seq) {
					sprintf(G_seqln,"L%s^Z",G_seqn[j].s);
					break;
				}
			}
			G_cnt=strlen(G_seqln);
			seqln(0);
			G_hadanmt=(-1);
		} break;
		case 30 :   /* SI */
		case 31 : { /* SO */
			if (G_seq.v[3].c=='F') addfield(3); else addvar(3);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			addcmd(G_seq.cmd);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			strcpy(&G_seqln[G_cnt],"LWITH^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			strcpy(&G_seqln[G_cnt],"LAT POS^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 27 : { /* SC */
			if (G_seq.v[3].c=='F') addfield(3); else addvar(3);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			addcmd(G_seq.cmd+2);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			strcpy(&G_seqln[G_cnt],"LFROM^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			strcpy(&G_seqln[G_cnt],"LTO^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 26 : { /* SJ */
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			addcmd(G_seq.cmd+2);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			strcpy(&G_seqln[G_cnt],"L+^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 29 : { /* SR */
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			addcmd(29);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			strcpy(&G_seqln[G_cnt],"LFROM^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			strcpy(&G_seqln[G_cnt],"LTO END^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			G_seqln[G_cnt++]='Z';
			G_seqln[G_cnt]=0;
			printf("%s\n",tpsdln(G_seqln));
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		case 28 : { /* SL */
			if (G_seq.v[2].c=='F') addfield(2); else addvar(2);
			G_seqln[G_cnt++]='O';
			u.c=&G_seqln[G_cnt];
			*u.i=0;
			G_cnt+=sizeof(int);
			addcmd(29);
			if (G_seq.v[0].c=='F') addfield(0); else addvar(0);
			strcpy(&G_seqln[G_cnt],"LFROM START TO^Z");
			G_cnt+=strlen(&G_seqln[G_cnt])-1;
			if (G_seq.v[1].c=='F') addfield(1); else addvar(1);
			G_seqln[G_cnt++]='Z';
			G_seqln[G_cnt]=0;
			printf("%s\n",tpsdln(G_seqln));
			endln(G_seqnum[G_seq.seq]);
			G_hadanmt=(-1);
		} break;
		default : {
			sound(1000);
			for(j=0;j<20000;j++);
			printf("s%d %s %d %d %d %s %c%d %c%d %c%d %c%d\n",G_seq.sqn,
				cmd[G_seq.cmd],G_seq.fil,G_seq.key,G_seq.seq,G_seq.oper,
				G_seq.v[0].c,G_seq.v[0].i,
				G_seq.v[1].c,G_seq.v[1].i,
				G_seq.v[2].c,G_seq.v[2].i,
				G_seq.v[3].c,G_seq.v[3].i);
			nosound();
		}
	}
}
void seqln(int isif) {
	int k;
	k=G_cnt+4;
	write(G_fd,&isif,sizeof(int));
	write(G_fd,&k,sizeof(int));
	write(G_fd,G_seqln,k);
/*	printf("%s\n",tpsdln(G_seqln));*/
	G_cnt=0;
	memset(G_seqln,0,999);
}
void addfield(int varno) {
	union {
		char *c;
		int *i;
	} u;
	G_seqln[G_cnt++]='E';
	u.c=&G_seqln[G_cnt];
	*u.i=G_seq.fil-1;
	G_cnt+=sizeof(int);
	u.c=&G_seqln[G_cnt];
	*u.i=G_seq.v[varno].i;
	G_cnt+=sizeof(int);
}
void addvar(int varno) {
	char tmp[50];
	union {
		char *c;
		int *i;
	} u;
	int j;
	if (G_seq.v[varno].c=='L') {
		for (j=0;j<G_nolit;j++) {
			if (G_lit[j].l==G_seq.v[varno].i) {
				G_seqln[G_cnt++]='L';
				switch(G_lit[j].t) {
					case 'C' : {
						sprintf(tmp,"\"%s\"",(char *)G_lit[j].v);
					} break;
					case 'i' : {
						sprintf(tmp,"%d",*((int *)G_lit[j].v));
					} break;
					case 'l' : {
						sprintf(tmp,"%ld",*((long *)G_lit[j].v));
					} break;
					case 'f' : {
						sprintf(tmp,"%f",*((float *)G_lit[j].v));
					} break;
					case 'd' : {
						sprintf(tmp,"%f",*((double *)G_lit[j].v));
					} break;
				}
				strcpy(&G_seqln[G_cnt],tmp);
				G_cnt+=strlen(tmp);
				G_seqln[G_cnt++]='^';
				break;
			}
		}
	}
	else {
		G_seqln[G_cnt++]='V';
		u.c=&G_seqln[G_cnt];
		switch(G_seq.v[varno].c) {
			case 's' : {
				*u.i=G_seq.v[varno].i+50;
			} break;
			case 'i' : {
				*u.i=G_seq.v[varno].i+200;
			} break;
			case 'M' : {
				*u.i=G_seq.v[varno].i+20;
			} break;
			case 'f' : {
				*u.i=G_seq.v[varno].i+600;
			} break;
			case 'd' : {
				*u.i=G_seq.v[varno].i+650;
			} break;
			case 'l' : {
				*u.i=G_seq.v[varno].i+700;
			} break;
			default : {
				for (j=0;j<26;j++) {
					if (G_seq.v[varno].c==G_const[j][0]) {
						*u.i=j;
						break;
					}
				}
			}
		}
		G_cnt+=sizeof(int);
	}
}
void addfile(void) {
	union {
		char *c;
		int *i;
	} u;
	G_seqln[G_cnt++]='F';
	u.c=&G_seqln[G_cnt];
	*u.i=G_seq.fil-1;
	G_cnt+=sizeof(int);
}
void addcmd(int cmd) {
	union {
		char *c;
		int *i;
	} u;
	G_seqln[G_cnt++]='C';
	u.c=&G_seqln[G_cnt];
	*u.i=cmd;
	G_cnt+=sizeof(int);
}
void endln(int seq) {
	G_seqln[G_cnt++]='Z';
	G_seqln[G_cnt]=0;
	seqln(seq);
}
int addmsgln(char *ln) {
	int i,j;
	char *a,*b;
	char tmp[300];
	for (i=0;i<=G_cnt;i++) {
		tmp[i]=ln[i];
	}
	a=strtok(tpsdln(tmp)," ");
	b=tmp+3;
	j=G_cnt-4;
	for (i=0;i<G_nomsg;i++) {
		if (!(memcmp(b,G_msg[i].t,max(j,G_msg[i].l)))) {
/*			printf("R %d %s %d %s\n",G_msg[i].m,G_msg[i].n,G_msg[i].l,tpsdln(G_msg[i].t));*/
			return(G_msg[i].m);
		}
	}
	G_nomsg++;
	G_msg=realloc(G_msg,sizeof(msgs)*G_nomsg);
	G_msg[G_nomsg-1].m=G_nomsg-1;
	strcpy(G_msg[G_nomsg-1].n,a);
	G_msg[G_nomsg-1].l=j;
	G_msg[G_nomsg-1].t=malloc(j);
	memcpy(G_msg[G_nomsg-1].t,b,j);
/*	printf("%d %s %d %s\n",G_msg[G_nomsg-1].m,G_msg[G_nomsg-1].n,G_msg[G_nomsg-1].l,tpsdln(G_msg[G_nomsg-1].t));*/
	return(G_nomsg-1);
}
void stln(char *ln) {
	char *t;
	int i;
	G_nofile++;
	i=atoi(strtok(ln," \t"));
	G_file[i-1].stid=i;
	i--;
	t=strtok((char *)NULL," \t");
	G_file[i].type=*t;
	strcpy(G_file[i].name,strtok((char *)NULL," \t"));
	G_file[i].len=atoi(t=strtok((char *)NULL," \t"));
	t=strtok((char *)NULL,"\t\r\n");
	if (t!=(char *)NULL) {
		if (strlen(t)>40) *(t+40)=0;
		strcpy(G_file[i].desc,t);
	}
	else {
		G_file[i].desc[0]=0;
	}
	G_file[i].nofld=0;
	G_file[i].flds=malloc(1);
	G_file[i].nokey=0;
	G_file[i].keys=malloc(1);
}
void fldln(char *ln) {
	int i;
	char *t;
	struct field *f;
	strtok(ln," \t");
	i=atoi(strtok((char *)NULL," \t"));
	i--;
	G_file[i].nofld++;
	G_file[i].flds=realloc(G_file[i].flds,sizeof(struct field *)*G_file[i].nofld);
	G_file[i].flds[G_file[i].nofld-1]=malloc(sizeof(struct field));
	f=G_file[i].flds[G_file[i].nofld-1];
	f->ofs=atoi(strtok((char *)NULL," \t"));
	f->len=atoi(strtok((char *)NULL," \t"));
	t=strtok((char *)NULL," \t");
	f->type=*t;
	strcpy(f->name,strtok((char *)NULL," \t\r\n"));
	f->name[14]=0;
	t=strtok((char *)NULL,"\t\r\n");
	if (t!=(char *)NULL) {
		if (strlen(t)>40) *(t+40)=0;
		strcpy(f->desc,t);
	}
	else {
		f->desc[0]=0;
	}
}
void keyln(char *ln) {
	int i[5];
	struct key *k;
	i[0]=atoi(strtok(ln," \t"));
	i[1]=atoi(strtok((char *)NULL," \t"));
	i[2]=atoi(strtok((char *)NULL," \t"));
	i[3]=atoi(strtok((char *)NULL," \t"));
	i[4]=atoi(strtok((char *)NULL," \t"));
	i[0]--;
	if (i[2]>G_file[i[0]].nokey) {
		G_file[i[0]].nokey=i[2];
		G_file[i[0]].keys=realloc(G_file[i[0]].keys,sizeof(struct key *)*G_file[i[0]].nokey);
		G_file[i[0]].keys[i[2]-1]=malloc(sizeof(struct key));
		k=G_file[i[0]].keys[i[2]-1];
		k->noparts=0;
		k->keypts=malloc(1);
	}
	k=G_file[i[0]].keys[i[2]-1];
	k->noparts++;
	k->keypts=realloc(k->keypts,sizeof(struct keypt *)*k->noparts);
	k->keypts[k->noparts-1]=malloc(sizeof(struct keypt));
	k->keypts[k->noparts-1]->fld=i[1];
	k->keypts[k->noparts-1]->fldordr=i[3];
}
void prscr(char *fl) {
	int i,j,fil;
	char tmp[200];
	file *t;
	for (fil=1;fil<=G_nofile;fil++) {
		t=&G_file[fil-1];
		savefile(fl,t);
		printf("SID\tTYPE\tNAME(10)\tRECLEN\tDESCRIPTION\n");
		printf("t%d\t%c\t\t%s\t\t%d\t\t%s\n",t->stid,t->type,t->name,t->len,t->desc);
		printf("FID\tSID\tOFS\tSIZE\tTYPE\tNAME\t\tDESCRIPTION\n");
		for (i=0;i<t->nofld;i++) {
			strcpy(tmp,t->flds[i]->name);
			for(j=0;j<strlen(tmp);j++) if (tmp[j]==' ') tmp[j]='_';
			printf("f%d\t%d\t%d\t%d\t\t%c\t\t%s\t%s\n",i,t->stid,t->flds[i]->ofs,t->flds[i]->len,t->flds[i]->type,tmp,t->flds[i]->desc);
		}
		printf("SID\tFID\tKID\tFIELDO\tNo.PARTS\n");
		for (i=0;i<t->nokey;i++) {
			for (j=0;j<t->keys[i]->noparts;j++) {
				printf("k%d\t%d\t%d\t%d\t\t%d\n",t->stid,t->keys[i]->keypts[j]->fld,i+1,t->keys[i]->keypts[j]->fldordr,t->keys[i]->noparts);
			}
		}
		printf("\n");
	}
}
int savefile(char *fil,file *rec) {
	int fd,tfd,i,j,xit=0,a;
	file *b;
	char filenam[50],tempnam[50];
	char *t;
	strcpy(tempnam,".\\");
	if ((tfd=creattemp(tempnam,0))==(-1)) return(0);
	close(tfd);
	tfd=open(tempnam,O_WRONLY|O_BINARY);
	if ((b=malloc(sizeof(file)))==(void *)NULL) return(0);
	b->stid=(-1);
	sprintf(filenam,"%s.tds",fil);
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
