//SYSDOC GPAMAIN.DOC
#define GPA_C

#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <mem.h>
#include <alloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>

#include "types.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "dst.h"
#include "menuproc.h"
#include "fldproc.h"
#include "formhand.h"
#include "translog.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "memory.h"
#include "arith.h"
#include "lang.h"
#include "instruct.h"

#define MAXSAVE 1000
extern unsigned char *G_buff;
extern int G_fieldsize;
extern int G_formsize;
extern unsigned long memleft(void);

typedef struct {
	char t;
	int a;
	long d;
} SAVEINFO;
char *G_xspand[MAXSAVE];
int G_numx=0;
char *G_atnlst[1000];
int G_deep=0;
int G_nal=0;
SAVEINFO G_ac[MAXSAVE];
int G_nac=0;
int G_cn=0;
int G_dontdown=0;
int G_wm=0;
char   *G_fclass[]   ={"MANDATORY","OPTIONAL","SEARCH","TEXT","MANDSRCH","MANDSECS","WAIT","DISPLAY","SECSRCH","TABLE",NULL};
char   *G_formtypes[]={"FORM","SERVE","PROMPT","MENU","REPORT","PPFORM"};
void checkform(char *name,int l);

void collect(unsigned char *p)
{
    int xit=0;
    int curly=0;
	long last=(-1);

	if (G_nac>=MAXSAVE) return;

    p++;
    while (!xit) {
        switch (*p) {
            case TCONSTANT : last=(long)(*((unsigned char *)(p+1))); p++;               break;
            case SCONSTANT : last=(long)(*((unsigned int  *)(p+1))); p+=sizeof(int);    break;
            case LCONSTANT : last=(long)(*((unsigned long *)(p+1))); p+=sizeof(long);   break;
            case DCONSTANT : last=(-1L); p+=sizeof(double); 							break;
            case CCONSTANT : last=(-1L); while (*(p+1)) p++; p++;     					break;

            case ACTIONN   : G_ac[G_nac].t=1; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case FORMNAME  : G_ac[G_nac].t=2; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case UFUNC     : G_ac[G_nac].t=3; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case CFUNC     : G_ac[G_nac].t=4; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
            case LOOKTAB   : G_ac[G_nac].t=5; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;

            case OCURLY    : curly++;                     								break;
            case CCURLY    : curly--; if (curly<1) xit=1; 								break;
        }
        p++;
    }
}
int checkx(char *name)
{
	int i;
	for (i=0;i<G_numx;i++) {
		if (!strcmp(G_xspand[i],name)) return(1);
	}
	if (G_numx>=MAXSAVE) return(1);
	G_xspand[G_numx++]=strdup(name);
	return(0);
}
void opt(char type,char *name,int done,int l)
{
	int j;
	static int ms=0;
    static char map[80];
	int d=G_deep;
	if (!ms) {
		memset(map,0,80);
		ms=1;
	}
    if (d>=80) return;
    if (l) map[d]=0; else map[d]=1;
	if (G_wm) {
    	for (j=0;j<d;j++) {
			if (map[j]) {
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"179\"\n");
				printf("Insert \"  \"\n");
			} else {
				printf("Insert \"   \"\n");
			}
		}
    	if (d) {
        	if (l) {
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"192\"\n");
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
			} else {														  
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"195\"\n");
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
				printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
			}
    	}
		switch (type) {
			case 'F' : printf("FormatFont .Color = 9, .Bold = 1\n");  break;
			case 'A' : printf("FormatFont .Color = 13, .Bold = 1\n"); break;
			case 'T' : printf("FormatFont .Color = 11, .Bold = 1\n"); break;
			case 'U' : printf("FormatFont .Color = 14, .Bold = 1\n"); break;
			case 'C' : printf("FormatFont .Color = 14, .Bold = 1\n"); break;
		}
	
		printf("Insert \"%s%s\"\n",name,done?"...":"");
		printf("FormatFont .Color = 0, .Bold = 0\nInsertPara\n");
	} else {
    	for (j=0;j<d;j++) printf("%c  ",((map[j])?'|':' '));
    	if (d) {
        	if (l) printf("+--"); else printf("|__");
    	}
		printf("%c %s%s\n",type,name,done?"...":"");
	} 
}
void checkaction(int idx,int l)
{
	int i,k;
	if (checkx(G_nbuf[idx].n)) {
		opt(((G_nbuf[idx].t==TABLE)?'T':'A'),G_nbuf[idx].n,1,l);
		return;
	} 
	k=(-1);
	for (i=0;i<G_nac;i++) {
		if (idx==G_ac[i].a) k=i;
	}
	if (k==(-1)) {
		opt(((G_nbuf[idx].t==TABLE)?'T':'A'),G_nbuf[idx].n,0,l);
	} else {
		opt(((G_nbuf[idx].t==TABLE)?'T':'A'),G_nbuf[idx].n,0,l);
		G_deep++;
		for (i=0;i<G_nac;i++) {
			if (idx==G_ac[i].a) {
				switch (G_ac[i].t) {
					case 1 :
 						checkaction(G_ac[i].d,k==i);
						break;
					case 2 :
						if (isform(fnameidx(G_ac[i].d))!=(-1L)) {
							if (G_dontdown) {
								opt('F',fnameidx(G_ac[i].d),0,k==i);
							} else {
								checkform(fnameidx(G_ac[i].d),k==i);
							}
						}
						break;
					case 3 :
						opt('U',G_ufunc[G_ac[i].d].name,0,k==i);
						break;
					case 4 :
						opt('C',G_actmap[G_ac[i].d].name,0,k==i);
						break; 
					case 5 :
						opt('T',G_nbuf[G_ac[i].d].n,0,k==i);
						break; 
				}
			}
		}
		G_deep--;
	}
}
void restform(char *name)
{
	freeform(&G_form);
    strcpy(G_form.name,name);
	if (!loadform(&G_form)) {
	    printf("Can't Load Form [%s]\n",name);
	} else {
		orderform(&G_form,((G_form.type==F_MENU)||(G_form.type==F_REPORT)));
	}
}
void checkform(char *name,int l)
{
	int i,j,k;
	char sname[9];
	strncpy(sname,name,9);
	if (checkx(sname)) {
		opt('F',sname,1,l);
		return;
	}
   	restform(sname);
	k=(-1);
    for (i=0;i<G_form.numitem;i++) {
    	if ((isaction(G_form.items[i].func)!=0    )
		 || (isform  (G_form.items[i].func)!=(-1L))) {
			k=i;
		}
	}
	if (k==(-1)) {
		opt('F',sname,0,l);
	} else {
		opt('F',sname,0,l);
		G_deep++;
    	for (i=0;i<G_form.numitem;i++) {
    		if ((j=isaction(G_form.items[i].func))!=0) {
       			if (j>0) {
           			if (j>999) {
						opt('U',G_form.items[i].func,0,k==i);
           			} else {
						opt('C',G_form.items[i].func,0,k==i);
           			}
       			} else {
 					checkaction((0-j)-1,k==i);
 			    	restform(sname);
       			}
			} else {
				if (isform(G_form.items[i].func)!=(-1L)) {
 					checkform(G_form.items[i].func,k==i);
 			    	restform(sname);
				}
			}
    	}
		G_deep--;
	}
}
// GPA runtime    Usage - "GPA system_name"
int _cdecl main(int argc,char *argv[]) 
{
	int i=0,j;
	char tmp[80];
	G_numidx=0;
	G_sstart=((_SS<<16)|_SP);
	if (argc<2) {
		printf("%s SYSTEM\n",argv[0]);
		return(1);
	}
	if (argc==3) {
		if (argv[2][0]=='1') {
			printf("FormatFont .Color = 0, .Bold = 1\nInsert \"Tree for GPA System %s\"\n",argv[1]);
			printf("InsertPara\nInsertPara\n");
			G_wm=1;
		} else {
			i=1;
		}
	}
	if (!readconfig(argv[1])) {
        printf("Error reading config file %s.cfg\n",argv[1]);
		cleanupblks(0);
		return(1);
	}
	for (G_lang=G_numlang-1;G_lang>=0;G_lang--) {
		readlang(G_langfiles[G_lang]);
    	freetext();
    	loadtext(G_system);
		addlangname(G_name);
	}
	G_lang=0;
   	freetext();
   	loadtext(G_system);

    loadactions(G_system);
    strcpy(G_form.name,"logon");
    G_form.items=NULL;
    if (!loadform(&G_form)) {
        printf("Can't load form logon for %s\n",G_system);
		cleanupblks(0);
		return(1);
    }
 	if (!initdevices()) {
        printf("Can't initialise devices (None Found!)\n");
		cleanupblks(0);
        RETURNV(1);
	}
	for (G_cn=0;G_cn<G_numn;G_cn++) collect(&G_buff[G_nbuf[G_cn].o]);
	sendmsg("OUTPUT1",'I');
	sendmsg("OUTPUT1",'F',G_fontfile);
	G_refson=1;
	for (j=0;j<G_numidx;j++) {
		strcpy(G_form.name,G_fid[j].name);
	    if (loadform(&G_form)) {
			if (initform(&G_form)) {
				restoreform();
				prdate();
				sprintf(tmp,"SCREENS\\%s.BMP",G_form.name);
				sendmsg("OUTPUT1",'SP',tmp);
//				getch();
			}
			clrform(&G_form);
		}
	}
	sendmsg("OUTPUT1",'E');
	if (i==0) {
		for (G_dontdown=1;G_dontdown>=0;G_dontdown--) {
			for (i=0;i<G_numidx;i++) {
				if (!checkx(G_fid[i].name)) {
					free(G_xspand[--G_numx]);
					checkform(G_fid[i].name,1);
				}
			}
			for (i=0;i<G_numn;i++) {
				if (!checkx(G_nbuf[i].n)&&(G_nbuf[i].t==ANAME)) {
					free(G_xspand[--G_numx]);
					checkaction(i,1);
				}
			}
		}
		j=0;
		for (i=0;i<G_numn;i++) {
			if ((G_nbuf[i].t==VARIABLE)) {
				if (j==0) {
					j=1;
					printf("Variables\n");
				}
				printf("    %s\n",G_nbuf[i].n);
			}
		}
	} else {
		G_dontdown=0;
		i=isaction(argv[2]);
   		if (i!=0) {
   			if (i<0) checkaction((0-i)-1,1);
		} else {
			checkform(argv[2],1);
		}
	}
 	closedevices();
	cleanupblks(0);
    return(0);
}
