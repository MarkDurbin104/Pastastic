#ifdef TURBOC
#include <conio.h>
#include <alloc.h>
#include <stdlib.h>
#endif
#include <string.h>
#include <stdio.h>

int	NOSEQ=2;
int	NOPRC=2;
int	NOLIT=2;
int	NOMSG=2;
int	NODST=2;
int	NOFLD=2;
int	NOPDF=2;

union literals {
	int		ing;
	long	lng;
	float	flt;
	double	dbl;
	char	str[41];
} *lit;
struct process {
	int  ppid;
	int  mc;
	int  pid;
	int  seq;
	int  eseq;
	char cond[10];
} *proc;
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
	char v4[20];
} *seq;
struct datastore {
	int  stid;
	char typ[1];
	char name[11];
	int  recl;
} *dst;
struct fields {
	int  stid;
	int  fid;
	int  ofs;
	int  len;
	char typ[1];
	char name[15];
} *fld;
int *seqp;
int *fldp;
int *msgp;
char *msg[600];
short *mpart[600];
char *lits;
int G_seq=0,G_proc=0,G_msg=0,G_err=0,G_warn=0,G_dst,G_fld;
char G_bit[13];
char *stmap[50];
char G_ds[150];
char G_is[150];
char G_ss[150];
char G_inmsg=0;
int seqno;
char *seqnam[1000];

#ifdef TURBOC
int seqln(int i,char *ln);
int litln(char *ln);
int msgln(char *ln);
int prcln(char *ln);
int dstln(int i,char *ln);
int fldln(int i,char *ln);
int instr(char c,char *str);
int getbits(int s);
int getvar(int s,char typ,int vno);
int prvar(int a,int i);
int prseq(char stop,char i,int s);
int spaces(int i);
int prseql(int i,int a);
#else
#ifdef SUN
#define	clrscr()	printf("");
#else
#define	clrscr()	printf("");
#endif
#endif

main(argc,argv)
int argc;
char **argv; {
	int s,f,i;
	FILE *fptr;
	char currentln[200];
	char filename[40];
	G_seq=G_proc=G_msg=0;
	if (argc<2) {
		printf("Synseq filename\n");
		exit(-1);
	}
	for (i=0;i<600;i++) {
		msg[i]=malloc(80);
		mpart[i]=malloc(20);
	}
	for (i=0;i<1000;i++) {
		seqnam[i]=malloc(21);
	}
	for (i=0;i<50;i++) {
		stmap[i]=malloc(50);
	}
	for (i=0;i<1000;i++) seqnam[i][0]=0;
	if ((fptr=fopen("seqname.seq","r"))!=NULL) {
		while (fgets(currentln,40,fptr)!=NULL) {
			seqno=atoi(strtok(currentln," .,;:\t\n\r"));
			strcpy(filename,strtok((char *)NULL," .,;:\t\n\r"));
			filename[20]=0;
			strcpy(seqnam[seqno],filename);
		}
		fclose(fptr);
	}
	strcpy(filename,argv[1]);
	if ((fptr=fopen(filename,"r"))==NULL) {
		printf("Can't Open File %s\n",filename);
		exit(-1);
	}
	while (fgets(currentln,120,fptr)!=NULL) {
		switch (currentln[0]) {
			case 's' : {
				NOSEQ++;
			} break;
			case 'p' : {
				NOPRC++;
			} break;
			case 'l' : {
				NOLIT++;
			} break;
			case 't' : {
				NODST++;
			} break;
			case 'm' : {
				NOMSG++;
			} break;
			case 'n' : {
				NOPDF++;
			} break;
			case 'f' : {
				NOFLD++;
			} break;
		}
	}
	fclose(fptr);
	seq=(struct sequence *)malloc(NOSEQ*sizeof(struct sequence));
	if (seq==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	lits=(char *)malloc(NOLIT*sizeof(i));
	if (lits==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	lit=(union literals *)malloc(NOLIT*sizeof(union literals));
	if (lit==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	seqp=(int *)malloc(NOSEQ*sizeof(i));
	if (seqp==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	fldp=(int *)malloc(NOFLD*sizeof(i));
	if (fldp==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	msgp=(int *)malloc(NOMSG*sizeof(i));
	if (msgp==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	proc=(struct process *)malloc(NOPRC*sizeof(struct process));
	if (proc==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	dst=(struct datastore *)malloc(NODST*sizeof(struct datastore));
	if (dst==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	fld=(struct fields *)malloc(NOFLD*sizeof(struct fields));
	if (fld==NULL) {
		printf("Can't Malloc Enough Space \n");
		exit(-1);
	}
	for (s=0;s<NOSEQ;s++) seqp[s]=(-1);
	for (s=0;s<NOFLD;s++) fldp[s]=(-1);
	for (s=0;s<NOMSG;s++) msgp[s]=(-1);
	for (s=0;s<50;s++) for (f=0;f<50;f++) stmap[s][f]=5;
	for (s=0;s<150;s++) { G_ds[s]=0; G_is[s]=0; G_ss[s]=0; }
	i=1;
	clrscr();
	printf("Sequence Line Code Expander v0.1 (c) PMA Computer Consultants 1989.\n");
	printf("Expanding File %s\n",filename);
	if ((fptr=fopen(filename,"r"))==NULL) {
		printf("Can't Open File %s\n",filename);
		exit(-1);
	}
	while (fgets(currentln,120,fptr)!=NULL) {
		switch (currentln[0]) {
			case 's' : {
				if (G_seq<NOSEQ) {
					seqln(i,&currentln[1]);
					G_seq++;
				}
			} break;
			case 'p' : {
				if (G_proc<NOPRC) {
					prcln(&currentln[1]);
					G_proc++;
				}
			} break;
			case 'f' : {
				if (G_fld<NOFLD) {
					fldln(i,&currentln[1]);
					G_fld++;
				}
			} break;
			case 't' : {
				if (G_dst<NODST) {
					dstln(i,&currentln[1]);
					G_dst++;
				}
			} break;
			case 'm' : {
				if (G_msg<NOMSG) {
					msgln(&currentln[1]);
					G_msg++;
				}
			} break;
			case 'l' : {
				litln(&currentln[1]);
			} break;
		}
		i++;
	}
	fclose(fptr);
	if (argc>2) {
		if (argv[2][0]=='n') {
			printf("All Named Sequences.\n");
			for (s=2;s<1000;s++) {
				if (seqnam[s][0]!=0) {
					printf("\n     **********************************************************************\n");
					printf("%03d  %s {\n",s,seqnam[s]);
					prseq(1,3,s);
				}
			}
		}
		else {
			if (argv[2][0]=='-') {
				printf("All Sequences Defined Under Process %d\n",atoi(&argv[2][1]));
				for (s=0;s<NOPRC;s++) {
					for (f=0;f<150;f++) {
						G_ds[f]=0;
						G_is[f]=0;
						G_ss[f]=0;
					}
					if (proc[s].ppid==atoi(&argv[2][1])) {
						printf("\n     **********************************************************************\n");
						seqno=proc[s].seq;
						if (seqnam[seqno][0]!=0) {
							printf("%03d  %s {\n",seqno,seqnam[seqno]);
						}
						else {
							printf("%03d  Start {\n",seqno);
						}
						prseq(1,3,seqno);
					}
				}
			}
			else {
				for (s=2;s<argc;s++) {
					printf("\n     **********************************************************************\n");
					seqno=atoi(argv[s]);
					if (seqnam[seqno][0]!=0) {
						printf("%03d  %s {\n",seqno,seqnam[seqno]);
					}
					else {
						printf("%03d  Start {\n",seqno);
					}
					prseq(1,3,seqno);
				}
			}
		}
		printf("\n     **********************************************************************\n");
	}
	return(0);
}
seqln(i,ln)
int i;
char *ln; {
	char tmp[200],*t;
	int j;
	strcpy(tmp,ln);
	strtok(tmp," \t\n");
	for (j=0;j<8;j++) t=strtok((char *)NULL," \t\n");
	if (t==(char *)NULL) {
		G_warn++;
		printf("Error   %5d : Sequence Line Missing Fields\n",i);
		G_seq--;
		return(0);
	}
	seq[G_seq].sid=atoi(strtok(ln," \t\n"));
	strcpy(seq[G_seq].oper,strtok((char *)NULL," \t\n"));
	seq[G_seq].stid=atoi(strtok((char *)NULL," \t\n"));
	seq[G_seq].ppid=atoi(strtok((char *)NULL," \t\n"));
	seq[G_seq].eseq=atoi(strtok((char *)NULL," \t\n"));
	strcpy(seq[G_seq].op,strtok((char *)NULL," \t\n"));
	strcpy(seq[G_seq].v1,strtok((char *)NULL," \t\n"));
	strcpy(seq[G_seq].v2,strtok((char *)NULL," \t\n"));
	strcpy(seq[G_seq].v3,strtok((char *)NULL," \t\n"));
	strcpy(seq[G_seq].v4,strtok((char *)NULL," \t\n"));
	if (seqp[seq[G_seq].sid]==-1) seqp[seq[G_seq].sid]=G_seq;
	return(0);
}
fldln(i,ln)
int i;
char *ln; {
	char tmp[50];
	fld[G_fld].fid=atoi(strtok(ln," \t\n"));
	fld[G_fld].stid=atoi(strtok((char *)NULL," \t\n"));
	fld[G_fld].ofs=atoi(strtok((char *)NULL," \t\n"));
	fld[G_fld].len=atoi(strtok((char *)NULL," \t\n"));
	strcpy(fld[G_fld].typ,strtok((char *)NULL," \t\n"));
	strcpy(tmp,strtok((char *)NULL," \t\n"));
	if (strlen(tmp)>14) {
		tmp[10]=0;
	}
	strcpy(fld[G_fld].name,tmp);
	stmap[fld[G_fld].stid][fld[G_fld].fid]=fld[G_fld].typ[0];
	if (fldp[fld[G_fld].stid]==(-1)) fldp[fld[G_fld].stid]=G_fld;
	return(0);
}
dstln(i,ln)
int i;
char *ln; {
	char tmp[50];
	dst[G_dst].stid=atoi(strtok(ln," \t\n"));
	strcpy(dst[G_dst].typ,strtok((char *)NULL," \t\n"));
	strcpy(tmp,strtok((char *)NULL," \t\n"));
	if (strlen(tmp)>10) {
		tmp[10]=0;
	}
	strcpy(dst[G_dst].name,tmp);
	dst[G_dst].recl=atoi(strtok((char *)NULL," \t\n"));
	return(0);
}
litln(ln)
char *ln; {
	int liter;
	int i;
	char tmp[6][50];
	liter=atoi(strtok(ln," \t\n"));
	for (i=0;i<5;i++) strcpy(tmp[i],strtok((char *)NULL," \t\n"));
	strcpy(tmp[5],strtok((char *)NULL,"\t\n"));
	if (liter<NOLIT) {
		lits[liter]=tmp[0][0];
		switch (lits[liter]) {
			case 'C' : {
				strcpy(lit[liter].str,tmp[5]);
			} break;
			case 'i' : {
				lit[liter].ing=atoi(tmp[2]);
			} break;
			case 'l' : {
				lit[liter].lng=atol(tmp[1]);
			} break;
			case 'f' : {
				lit[liter].flt=atof(tmp[4]);
			} break;
			case 'd' : {
				lit[liter].dbl=atof(tmp[3]);
			} break;
		}
	}
	return(0);
}
msgln(ln)
char *ln; {
	int mc;
	char tmp[100];
	mc=atoi(strtok(ln," \t\n"));
	strtok((char *)NULL," \t\n");
	msgp[mc]++;
	mpart[mc][msgp[mc]]=G_msg;
	strcpy(tmp,strtok((char *)NULL,"\r\n"));
	tmp[39]=0;
	strcpy(msg[G_msg],tmp);
	return(0);
}
prcln(ln )
char *ln; {
	proc[G_proc].ppid  =atoi(strtok(ln          ," \t\n"));
	proc[G_proc].mc    =atoi(strtok((char *)NULL," \t\n"));
	proc[G_proc].pid   =atoi(strtok((char *)NULL," \t\n"));
	proc[G_proc].seq   =atoi(strtok((char *)NULL," \t\n"));
	proc[G_proc].eseq  =atoi(strtok((char *)NULL," \t\n"));
	strcpy(proc[G_proc].cond,strtok((char *)NULL," \t\n"));
	return(0);
}
getbits(s)
int s; {
	if (seq[s].stid==0) G_bit[0]=0; else G_bit[0]=1;
	if (seq[s].ppid==0) G_bit[1]=0; else G_bit[1]=1;
	if ((seq[s].eseq==0)||(seqp[seq[s].eseq]==(-1))) G_bit[2]=0; else G_bit[2]=1;
	if((instr(seq[s].op[0],"-*/%+=<>|&^!"))
	|| (instr(seq[s].op[0],"-*/%+=<>|&^!"))) G_bit[3]=1; else G_bit[3]=0;
	getvar(s,seq[s].v1[0],4);
	getvar(s,seq[s].v2[0],5);
	getvar(s,seq[s].v3[0],6);
	getvar(s,seq[s].v4[0],7);
	return(0);
}
instr(c,str)
char c;
char *str; {
	char *t;
	t=str;
	while (*t) if (*(t++)==c) return(1);
	return(0);
}
getvar(s,typ,vno)
int s;
char typ;
int vno; {
	switch (typ) {
		case '.' : {
			G_bit[vno]=0;
		} break;
		case 'i' :
		case 'O' :
		case 'e' :
		case 'H' :
		case 'r' :
		case 'S' : {
			G_bit[vno]=1;
		} break;
		case 'f' : {
			G_bit[vno]=2;
		} break;
		case 'd' : {
			G_bit[vno]=3;
		} break;
		case 'l' : {
			G_bit[vno]=4;
		} break;
		case 'F' : {
			G_bit[vno]=5;
			switch(vno) {
				case 4 : {
					switch(stmap[seq[s].stid][atoi(&seq[s].v1[1])]) {
						case 'C' : G_bit[vno]=9; break;
						case 'i' : G_bit[vno]=1; break;
						case 'f' : G_bit[vno]=2; break;
						case 'd' : G_bit[vno]=3; break;
						case 'l' : G_bit[vno]=4; break;
						default  : G_bit[vno]=5;
					}
				} break;
				case 5 : {
					switch(stmap[seq[s].stid][atoi(&seq[s].v2[1])]) {
						case 'C' : G_bit[vno]=9; break;
						case 'i' : G_bit[vno]=1; break;
						case 'f' : G_bit[vno]=2; break;
						case 'd' : G_bit[vno]=3; break;
						case 'l' : G_bit[vno]=4; break;
						default  : G_bit[vno]=5;
					}
				} break;
				case 6 : {
					switch(stmap[seq[s].stid][atoi(&seq[s].v3[1])]) {
						case 'C' : G_bit[vno]=9; break;
						case 'i' : G_bit[vno]=1; break;
						case 'f' : G_bit[vno]=2; break;
						case 'd' : G_bit[vno]=3; break;
						case 'l' : G_bit[vno]=4; break;
						default  : G_bit[vno]=5;
					}
				} break;
				case 7 : {
					switch(stmap[seq[s].stid][atoi(&seq[s].v4[1])]) {
						case 'C' : G_bit[vno]=9; break;
						case 'i' : G_bit[vno]=1; break;
						case 'f' : G_bit[vno]=2; break;
						case 'd' : G_bit[vno]=3; break;
						case 'l' : G_bit[vno]=4; break;
						default  : G_bit[vno]=5;
					}
				} break;
			}
		} break;
		case '0' :
		case '1' :
		case '2' :
		case '3' :
		case '4' :
		case '5' :
		case '6' :
		case '7' :
		case '8' :
		case '9' : {
			G_bit[vno]=8;
		} break;
		case 's' :
		case 'T' :
		case 'D' :
		case 'G' :
		case 'B' :
		case 'j' :
		case 'N' :
		case 'm' :
		case 'C' : {
			G_bit[vno]=9;
		} break;
		case 'L' : {
			switch (vno) {
				case 4 : {
					switch (lits[atoi(&seq[s].v1[1])]) {
						case 'i' : {
							G_bit[vno]=1;
						} break;
						case 'f' : {
							G_bit[vno]=2;
						} break;
						case 'd' : {
							G_bit[vno]=3;
						} break;
						case 'l' : {
							G_bit[vno]=4;
						} break;
						case 'C' : {
							G_bit[vno]=9;
						} break;
						default : {
							G_bit[vno]=10;
						}
					}
				} break;
				case 5 : {
					switch (lits[atoi(&seq[s].v2[1])]) {
						case 'i' : {
							G_bit[vno]=1;
						} break;
						case 'f' : {
							G_bit[vno]=2;
						} break;
						case 'd' : {
							G_bit[vno]=3;
						} break;
						case 'l' : {
							G_bit[vno]=4;
						} break;
						case 'C' : {
							G_bit[vno]=9;
						} break;
						default : {
							G_bit[vno]=10;
						}
					}
				} break;
				case 6 : {
					switch (lits[atoi(&seq[s].v3[1])]) {
						case 'i' : {
							G_bit[vno]=1;
						} break;
						case 'f' : {
							G_bit[vno]=2;
						} break;
						case 'd' : {
							G_bit[vno]=3;
						} break;
						case 'l' : {
							G_bit[vno]=4;
						} break;
						case 'C' : {
							G_bit[vno]=9;
						} break;
						default : {
							G_bit[vno]=10;
						}
					}
				} break;
				case 7 : {
					switch (lits[atoi(&seq[s].v4[1])]) {
					case 'i' : {
							G_bit[vno]=1;
						} break;
						case 'f' : {
							G_bit[vno]=2;
						} break;
						case 'd' : {
							G_bit[vno]=3;
						} break;
						case 'l' : {
							G_bit[vno]=4;
						} break;
						case 'C' : {
							G_bit[vno]=9;
						} break;
						default : {
							G_bit[vno]=10;
						}
					}
				} break;
			}
		} break;
		default : {
			G_bit[vno]=0;
		}
	}
	return(0);
}
prseq(stop,i,s)
char stop;
char i;
int s; {
	int a,b;
	union {
		short opno;
		char op[3];
	} ops;
	char ds[150];
	char is[150];
	char ss[150];
	a=seqp[s];
	while (seq[a].sid==s) {
		ops.op[0]=seq[a].oper[1];
		ops.op[1]=seq[a].oper[0];
		ops.op[2]=0;
		prseql(i,a);
		switch(ops.opno) {
			case 'EL' :
			case 'IF' : {
				if (seqnam[seq[a].eseq][0]!=0) {
					printf("%03d  ",seq[a].eseq);
					spaces(i+3);
					printf("%s();\n",seqnam[seq[a].eseq]);
					spaces(i+5);
					printf("}\n");
				}
				else {
					prseq(0,i+3,seq[a].eseq);
				}
			} break;
			case 'RT' : {
				i+=3;
			} break;
			case 'UT' : {
				i-=3;
			} break;
			case 'FR' :
			case 'FW' : {
				for (b=1;b<150;b++) { ds[b]=G_ds[b]; is[b]=G_is[b]; ss[b]=G_ss[b]; }
				if (seqnam[seq[a].eseq][0]!=0) {
					printf("%03d  ",seq[a].eseq);
					spaces(i+3);
					printf("%s();\n",seqnam[seq[a].eseq]);
					spaces(i+5);
					printf("}\n");
				}
				else {
					prseq(stop,i+3,seq[a].eseq);
				}
				for (b=1;b<150;b++) { G_ds[b]=ds[b]; G_is[b]=is[b]; G_ss[b]=ss[b]; }
				G_ds[seq[a].stid]++;
			} break;
			case 'FC' : {
				G_ds[seq[a].stid]=0;
				for (b=1;b<150;b++) { ds[b]=G_ds[b]; is[b]=G_is[b]; ss[b]=G_ss[b]; }
				if (seqnam[seq[a].eseq][0]!=0) {
					printf("%03d  ",seq[a].eseq);
					spaces(i+3);
					printf("%s();\n",seqnam[seq[a].eseq]);
					spaces(i+5);
					printf("}\n");
				}
				else {
					prseq(stop,i+3,seq[a].eseq);
				}
				for (b=1;b<150;b++) { G_ds[b]=ds[b]; G_is[b]=is[b]; G_ss[b]=ss[b]; }
			} break;
			case 'FA' :
			case 'IU' :
			case 'FD' :
			case 'AR' :
			case 'DR' :
			case 'RO' :
			case 'RW' :
			case 'FF' :
			case 'RF' :
			case 'RP' :
			case 'PS' :
			case 'PK' :
			case 'CP' :
			case 'RN' : {
				for (b=1;b<150;b++) { ds[b]=G_ds[b]; is[b]=G_is[b]; ss[b]=G_ss[b]; }
				if (seqnam[seq[a].eseq][0]!=0) {
					printf("%03d  ",seq[a].eseq);
					spaces(i+3);
					printf("%s();\n",seqnam[seq[a].eseq]);
					spaces(i+5);
					printf("}\n");
				}
				else {
					prseq(stop,i+3,seq[a].eseq);
				}
				for (b=1;b<150;b++) { G_ds[b]=ds[b]; G_is[b]=is[b]; G_ss[b]=ss[b]; }
			} break;
			default : {
			}
		}
		a++;
	}
	if (stop) {
		printf("     ");
		spaces(i);
		printf("Return;\n");
		spaces(i+2);
		printf("}\n");
	}
	else {
		printf("     ");
		spaces(i);
		printf("Break;\n");
		spaces(i+2);
		printf("}\n");
	}
	return(0);
}
spaces(i)
int i; {
	int j;
	for (j=0;j<i;j++) printf(" ");
	return(0);
}
prseql(i,a)
int i;
int a; {
	int st,pp,es,b;
	char *op,*v1,*v2,*v3,*v4;
	union {
#ifdef TURBOC
		int opno;
#else
		short opno;
#endif
		char op[3];
	} ops;
#ifdef TURBOC
	strcpy(ops.op,seq[a].oper);
#else
	ops.op[0]=seq[a].oper[1];
	ops.op[1]=seq[a].oper[0];
	ops.op[2]=0;
#endif
	getbits(a);
	st=seq[a].stid;
	pp=seq[a].ppid;
	es=seq[a].eseq;
	op=seq[a].op;
	v1=seq[a].v1;
	v2=seq[a].v2;
	v3=seq[a].v3;
	v4=seq[a].v4;
	if (!G_inmsg) {
		if ((ops.opno!='OR')
		&&  (ops.opno!='AN')
		&&  (ops.opno!='XO')
		&&  (ops.opno!='NO')) {
			printf("%03d  ",seq[a].sid);
			if (ops.opno=='UT') spaces(i-3); else spaces(i);
		}
	}
	switch(ops.opno) {
		case 'MV' : {
			printf("Move (");
			prvar(a,1);
			printf("->");
			prvar(a,2);
			printf(");\n");
		} break;
		case 'IU' : {
			printf("If Variable ");
			prvar(a,1);
			printf(" Has Not Been Used {\n");
		} break;
		case 'NA' : {
			prvar(a,3);
			printf("=(");
			prvar(a,1);
			printf("%s",op);
			prvar(a,2);
			printf(");\n");
		} break;
		case 'SN' : {
			printf("Convert (String ");
			prvar(a,1);
			printf(" To Number ");
			prvar(a,2);
			printf(");\n");
		} break;
		case 'SO' : {
			printf("String ");
			prvar(a,4);
			printf("=(");
			prvar(a,1);
			printf(" Over-Written With ");
			prvar(a,2);
			printf(" At Position ");
			prvar(a,3);
			printf(");\n");
		} break;
		case 'SI' : {
			printf("String ");
			prvar(a,4);
			printf("=(");
			prvar(a,1);
			printf(" With ");
			prvar(a,2);
			printf(" Inserted At Position ");
			prvar(a,3);
			printf(");\n");
		} break;
		case 'SL' : {
			printf("String ");
			prvar(a,3);
			printf("=(");
			prvar(a,1);
			printf("[0-");
			prvar(a,2);
			printf("]);\n");
		} break;
		case 'SR' : {
			printf("String ");
			prvar(a,3);
			printf("=(");
			prvar(a,1);
			printf("[");
			prvar(a,2);
			printf("-END]);\n");
		} break;
		case 'SC' : {
			printf("String ");
			prvar(a,4);
			printf("=(");
			prvar(a,1);
			printf("[");
			prvar(a,2);
			printf("-");
			prvar(a,3);
			printf("]);\n");
		} break;
		case 'SJ' : {
			printf("String ");
			prvar(a,3);
			printf("=(");
			prvar(a,1);
			printf("+");
			prvar(a,2);
			printf(");\n");
		} break;
		case 'NS' : {
			printf("Convert (Number ");
			prvar(a,1);
			printf(" To String ");
			prvar(a,2);
			printf(");\n");
		} break;
		case 'EX' : {
			printf("System (");
			prvar(a,1);
			printf(" ");
			prvar(a,2);
			printf(");\n");
		} break;
		case 'IF' : {
			printf("If   (");
			prvar(a,1);
			printf("%s",op);
			prvar(a,2);
			printf(")");
			b=a+1;
			while (((!(strcmp(seq[b].oper,"OR")))
			||      (!(strcmp(seq[b].oper,"AN")))
			||      (!(strcmp(seq[b].oper,"XO")))
			||      (!(strcmp(seq[b].oper,"NO"))))
			&&      (seq[a].sid==seq[b].sid)) {
				printf("\n");
				printf("%03d  ",seq[a].sid);
				spaces(i);
				switch (seq[b].oper[0]) {
					case 'O' : {
						printf("Or   (");
					} break;
					case 'A' : {
						printf("And  (");
					} break;
					case 'X' : {
						printf("Exor (");
					} break;
					case 'N' : {
						printf("Not  (");
					} break;
				}
				prvar(b,1);
				printf("%s",seq[b].op);
				prvar(b,2);
				printf(")");
				b++;
			}
			printf(" {\n");
		} break;
		case 'CP' : {
			printf("Compare (");
			prvar(a,1);
			printf("%s",op);
			prvar(a,2);
			printf(")");
			b=a+1;
			while (((!(strcmp(seq[b].oper,"OR")))
			||      (!(strcmp(seq[b].oper,"AN")))
			||      (!(strcmp(seq[b].oper,"XO")))
			||      (!(strcmp(seq[b].oper,"NO"))))
			&&      (seq[a].sid==seq[b].sid)) {
				printf("\n");
				printf("%03d  ",seq[a].sid);
				spaces(i);
				switch (seq[b].oper[0]) {
					case 'O' : {
						printf("Or      (");
					} break;
					case 'A' : {
						printf("And     (");
					} break;
					case 'X' : {
						printf("Exor    (");
					} break;
					case 'N' : {
						printf("Not     (");
					} break;
				}
				prvar(b,1);
				printf("%s",seq[b].op);
				prvar(b,2);
				printf(")");
				b++;
			}
			printf(" If TRUE {\n");
		} break;
		case 'PS' : {
			switch (op[0]) {
				case 'm' : {
					printf("Spawn MENU Process %d Else {\n",pp);
				} break;
				case 't' : {
					printf("Spawn PORT Process %d Else {\n",pp);
				} break;
				case 'P' : {
					printf("Spawn SEQUENCE Process %d Else {\n",pp);
				} break;
				case 'a' : {
					printf("Spawn ALARM Process %d Else {\n",pp);
				} break;
				case 'c' : {
					printf("Spawn CALANDER Process %d Else {\n",pp);
				} break;
				case 's' : {
					printf("Spawn SUPERVISOR Process %d Else {\n",pp);
				} break;
			}
		} break;
		case 'PK' : {
			switch (op[0]) {
				case 'm' : {
					printf("Kill MENU Process %d Else {\n",pp);
				} break;
				case 't' : {
					printf("Kill PORT Process %d Else {\n",pp);
				} break;
				case 'P' : {
					printf("Kill SEQUENCE Process %d Else {\n",pp);
				} break;
				case 'a' : {
					printf("Kill ALARM Process %d Else {\n",pp);
				} break;
				case 'c' : {
					printf("Kill CALANDER Process %d Else {\n",pp);
				} break;
				case 's' : {
					printf("Kill SUPERVISOR Process %d Else {\n",pp);
				} break;
			}
		} break;
		case 'FR' : {
			printf("Open (%s) For Reading Else {\n",dst[st-1].name);
		} break;
		case 'FW' : {
			printf("Open (%s) For Writing Else {\n",dst[st-1].name);
		} break;
		case 'FC' : {
			printf("Close (%s) Else {\n",dst[st-1].name);
		} break;
		case 'FA' : {
			printf("Create (%s) Else {\n",dst[st-1].name);
		} break;
		case 'FD' : {
			printf("Delete (%s) Else {\n",dst[st-1].name);
		} break;
		case 'RW' : {
			printf("Read First Record in (%s) Else {\n",dst[st-1].name);
		} break;
		case 'FF' : {
			printf("Read Last Record in (%s) Else {\n",dst[st-1].name);
		} break;
		case 'RO' : {
			printf("Over-Write Record in %s Else {\n",dst[st-1].name);
		} break;
		case 'AR' : {
			printf("Add Record to %s Else {\n",dst[st-1].name);
		} break;
		case 'DR' : {
			printf("Delete Record from %s Else {\n",dst[st-1].name);
		} break;
		case 'RF' : {
			printf("Find Record %s in %s Using Key %d Else {\n",op,dst[st-1].name,pp);
		} break;
		case 'RN' : {
			printf("Read Next Record in %s Else {\n",dst[st-1].name);
		} break;
		case 'RP' : {
			printf("Read Previous Record in %s Else {\n",dst[st-1].name);
		} break;
		case 'AN' :
		case 'OR' :
		case 'XO' :
		case 'NO' : {
		} break;
		case 'UT' : {
			printf("} Until (");
			prvar(a,1);
			printf("%s",op);
			prvar(a,2);
			printf(")");
			b=a+1;
			while (((!(strcmp(seq[b].oper,"OR")))
			||      (!(strcmp(seq[b].oper,"AN")))
			||      (!(strcmp(seq[b].oper,"XO")))
			||      (!(strcmp(seq[b].oper,"NO"))))
			&&      (seq[a].sid==seq[b].sid)) {
				printf("\n");
				printf("%03d  ",seq[a].sid);
				spaces(i-3);
				switch (seq[b].oper[0]) {
					case 'O' : {
						printf("  Or    (");
					} break;
					case 'A' : {
						printf("  And   (");
					} break;
					case 'X' : {
						printf("  Exor  (");
					} break;
					case 'N' : {
						printf("  Not   (");
					} break;
				}
				prvar(b,1);
				printf("%s",seq[b].op);
				prvar(b,2);
				printf(")");
				b++;
			}
			printf(";\n");
		} break;
		case 'RT' : {
			printf("Repeat {\n");
		} break;
		case 'EL' : {
			printf("Else {\n");
		} break;
		case 'MT' : {
			if (atoi(v2)==0) {
				printf("Send (%03d)(",atoi(v1));
				G_inmsg=1;
			}
			printf("%s",msg[mpart[atoi(v1)][atoi(v2)]]);
			if (atoi(v2)==msgp[atoi(v1)]) {
				G_inmsg=0;
				printf(")\n%03d  ",seq[a].sid);
				spaces(i);
				switch (pp) {
					case 0 : {
						printf("To   Self\n");
					} break;
					case 11111 : {
						printf("To   Sender\n");
					} break;
					case 11112 : {
						printf("To   Process ");
						prvar(a,3);
						printf("\n");
					} break;
					default : {
						printf("To   Process %d\n",pp);
					}
				}
			}
		} break;
		case 'MD' : {
			prvar(a,2);
		} break;
		default : {
			printf("%2s ",seq[a].oper);
			printf("%3d ",st);
			printf("%5d ",pp);
			printf("%3d ",es);
			printf("%2s ",op);
			printf("%5s ",v1);
			printf("%5s ",v2);
			printf("%4s ",v3);
			printf("%4s\n",v4);
		}
	}
	return(0);
}
prvar(a,i)
int a;
int i; {
	int st;
	char *v;
	getbits(a);
	st=seq[a].stid;
	i+=3;
	switch (i) {
		case 4 : {
			v=seq[a].v1;
		} break;
		case 5 : {
			v=seq[a].v2;
		} break;
		case 6 : {
			v=seq[a].v3;
		} break;
		case 7 : {
			v=seq[a].v4;
		} break;
	}
	switch (v[0]) {
		case 'b' : {
			printf("BLANK");
		} break;
		case 'N' : {
			printf("NULL");
		} break;
		case 'j' : {
			printf("Form_Return_String");
		} break;
		case 'C' : {
			printf("Current_Form_field");
		} break;
		case 'S' : {
			printf("Sender");
		} break;
		case 'r' : {
			printf("Return_To_Form");
		} break;
		case 'D' : {
			printf("Date");
		} break;
		case 'm' : {
			printf("Rx_Message_Part[%d]",atoi(&v[1]));
		} break;
		case 'T' : {
			printf("Form_Field[%d]",atoi(&v[1]));
		} break;
		case 'F' : {
			if (st>0) {
				printf("%s[%s]",dst[st-1].name,fld[fldp[st]+atoi(&v[1])].name);
			}
		} break;
		case 'L' : {
			switch (G_bit[i]) {
				case 1 : {
					printf("%d",lit[atoi(&v[1])].ing);
					printf("<%s>",v);
				} break;
				case 2 : {
					printf("%f",lit[atoi(&v[1])].flt);
					printf("<%s>",v);
				} break;
				case 3 : {
					printf("%f",lit[atoi(&v[1])].dbl);
					printf("<%s>",v);
				} break;
				case 4 : {
					printf("%ld",lit[atoi(&v[1])].lng);
					printf("<%s>",v);
				} break;
				case 9 : {
					printf("%c%s%c",34,lit[atoi(&v[1])].str,34);
					printf("<%s>",v);
				} break;
				default : {
					printf("%s",v);
				}
			}
		} break;
		default : {
			printf("%s",v);
		}
	}
	return(1);
}
