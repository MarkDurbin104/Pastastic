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
#include <sys\types.h>
#include <sys\stat.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#include "gpa.h"

unsigned char pcx_header[128]= {
    0x0A, 0x05, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
    0x7F, 0x02, 0xDF, 0x01, 0x96, 0x00, 0x96, 0x00,
    0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x50, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

#define MAXSAVE     2000

#define MENU_BIT    0x01
#define FORM_BIT    0x02
#define REPO_BIT    0x04
#define ACTI_BIT    0x08
#define STOR_BIT    0x10
#define FUNC_BIT    0x20

#define TOFORM_BIT  0x03
#define TOREPO_BIT  0x07
#define TOACTI_BIT  0x0F
#define TOSTOR_BIT  0x1F
#define TOFUNC_BIT  0x3F

extern int G_fieldsize;
extern int G_formsize;
extern unsigned long memleft(void);

char **G_ufunclst;
char **G_actmaplst;
typedef struct {
	char t;
	int a;
	long d;
} SAVEINFO;
char **G_xspand=NULL;
int G_numx=0;
char **G_atnlst=NULL;
int G_deep=0;
int G_nal=0;
SAVEINFO *G_ac=NULL;
int G_nac=0;
int G_cn=0;
int G_dontdown=0;
int G_wm=0;
char   *G_fclass[]   ={"MANDATORY","OPTIONAL","SEARCH","TEXT","MANDSRCH","MANDSECS","WAIT","DISPLAY","SECSRCH","TABLE",NULL};
char   *G_formtypes[]={"FORM","SERVE","PROMPT","MENU","REPORT","PPFORM"};
UCHAR   G_travtype=0x7F;
void checkform      (char *name,int l);
void checkaction    (int idx,int l);
void opt            (char type,char *name,int done,int l);

INT isaction(CHAR *name)
{
    INT i=0;
    CHAR *e;

    e=&name[strlen(name)-1];
    while ((e!=name)&&(isspace(*e))) e--;
    if (e!=name) *(e+1)=0;

    if ((i=findname(name))!=(-1)) {
        return(0-(i+1));
    }
    i=0;
    while (G_actmaplst[i]!=NULL) {
        if (!strcmp(name,G_actmaplst[i])) {
            return(i+1);
        }
        i++;
    }
    i=0;
    while (G_ufunclst[i]!=NULL) {
        if (!strcmp(name,G_ufunclst[i])) {
            return(i+1000);
        }
        i++;
    }
    return(0);
}
void collect(unsigned char *p)
{
    int xit=0;
    int curly=1;
    int t,ac;
    char tmp[80];
    char store,field;
	long pblast=(-1);
	long blast=(-1);
	long last=(-1);

	if (G_nac>=MAXSAVE) return;

    p++;
    while (!xit) {
        switch (*p) {
            case TCONSTANT :
                pblast=blast; blast=last;
                last=(long)(gettiny(p+1)); p++;
                break;
            case SCONSTANT :
                pblast=blast; blast=last;
                last=(long)(getint (p+1)); p+=sizeof(INT16);
                break;
            case LCONSTANT :
                pblast=blast; blast=last;
                last=(long)(getlong(p+1)); p+=sizeof(LONG);
                break;
            case DCONSTANT :
                pblast=blast; blast=last;
                last=(-1L); p+=sizeof(double);
                break;
            case CCONSTANT :
                pblast=blast; blast=last;
                strcpy(tmp,(CHAR *)getstrg(p+1));
                while (gettiny(p+1)) p++; p++;
                last=(-1L);
                if ((ac=isaction(tmp))>0) {
                    if (ac>1000) { last=ac-1000; t=3; } else { last=ac-1; t=4; }
                } else if (ac<0) {
                    last=(0-ac)-1; t=1;
                } else {
                    if ((ac=isform(tmp))>=0) { last=ac; t=2; }
                }
                break;

            case DATASTORE :
                t=6;
                store=(char)blast; // G_store[(INT)blast].name;
                field=(char)last;  // G_lib[G_store[(INT)last].li[(INT)blast]].name;
                break;

            case RUNSRCH   :
            case RUN       :
                G_ac[G_nac].t=t;
                G_ac[G_nac].a=G_cn;
                if (t!=6) {
                    G_ac[G_nac++].d=last;
                } else {
                    G_ac[G_nac].d=store;
                    G_ac[G_nac].d<<=8;
                    G_ac[G_nac++].d|=field;
                }
                break;
            case RUNCOPY   :
                G_ac[G_nac].t=t;
                G_ac[G_nac].a=G_cn;
                if (t!=6) {
                    G_ac[G_nac++].d=pblast;
                } else {
                    G_ac[G_nac].d=store;
                    G_ac[G_nac].d<<=8;
                    G_ac[G_nac++].d|=field;
                }
                break;

            case ACTIONN   : G_ac[G_nac].t=1; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
            case RUNFORM   : G_ac[G_nac].t=2; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case FORMNAME  : G_ac[G_nac].t=2; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case UFUNC     : G_ac[G_nac].t=3; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
	        case CFUNC     : G_ac[G_nac].t=4; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;
            case LOOKTAB   : G_ac[G_nac].t=5; G_ac[G_nac].a=G_cn; G_ac[G_nac++].d=last; break;

            case OCURLY    : curly++;                     								break;
            case CCURLY    : curly--; if (curly<1) xit=1; 								break;
        }
        p++;
        if (kbhit()) exit(0);
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
void expanddbm(char *name,char *field,int l)
{
	int j,i;
    char tmp[80];
    long rn;
    char **t;
    int nt=0;

    if ((name ==NULL)||(*name ==0)||(snum(name      )<0)) return;
    if ((field==NULL)||(*field==0)||(fnum(name,field)<0)) return;

    t=malloc(1000*sizeof(char *));
    if (t==NULL) return;

    sprintf(tmp,"%s.%s",name,field);
	opt('S',tmp,0,l);
    rn=1;
    G_deep++;
    while (sendmsg("DBM",MESSAGE_r,name,rn)) {
        sendmsg("DBM",MESSAGE_g,name,field,tmp);
        for (i=0;i<nt;i++) if (!strcmp(t[i],tmp)) break;
        if (i==nt) {
            if ((j=isaction(tmp))!=0) {
                if (j>0) {
                    if (j>999) opt('U',tmp,0,-1); else opt('C',tmp,0,-1);
                } else {
                    checkaction((0-j)-1,-1);
                }
            } else {
                if ((*tmp!=0)&&(isform(tmp)!=(-1L))) checkform(tmp,-1);
            }
            t[nt++]=strdup(tmp);
        }
        rn++;
    }
    G_deep--;
    for (i=0;i<nt;i++) if (t[i]!=NULL) free(t[i]);
    free(t);
}
void prmap(char *map,int d,int l)
{
    int j;
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
            if (l==1) {
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"192\"\n");
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
		    } else {														  
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"195\"\n");
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
			    printf("InsertSymbol .Font = \"MS LineDraw\", .CharNum = \"196\"\n");
		    }
        }
    } else {
        for (j=0;j<d;j++) printf("%c  ",((map[j])?'³':' '));
        if (d) {
            if (l==1) {
                printf("ÀÄÄ");
            } else if (l==0) {
                printf("ÃÄÄ");
            } else {
                printf("ÈÍÍ");
            }
        }
    }
}
void opt(char type,char *name,int done,int l)
{
	static int ms=0;
    static char map[80];
	int d=G_deep;
	if (!ms) { memset(map,0,80); ms=1; }
    if (d>=80) return;
	if (G_wm) { 
		switch (type) {
			case 'F' :
                switch (G_fid[isform(name)]->type) {
                    case F_MENU :
                        if ((G_travtype&MENU_BIT)!=0) {
                            prmap(map,d,l);
                            printf("FormatFont .Color = 9, .Bold = 1\n");
                        }
                        break;
                    case F_SERVE :
                    case F_NORM :
                    case F_PROMPT :
                        if ((G_travtype&FORM_BIT)!=0) {
                            prmap(map,d,l);
                            printf("FormatFont .Color = 9, .Bold = 1\n");
                        }
                        break;
                    case F_REPORT :
                    case F_PPFORM :
                        if ((G_travtype&REPO_BIT)!=0) {
                            prmap(map,d,l);
                            printf("FormatFont .Color = 10, .Bold = 1\n");
                        }
                        break;
                }
                break;
			case 'A' :
                if ((G_travtype&ACTI_BIT)!=0) {
                    prmap(map,d,l);
                    printf("FormatFont .Color = 13, .Bold = 1\n");
                }
                break;
			case 'T' :
                if ((G_travtype&ACTI_BIT)!=0) {
                    prmap(map,d,l);
                    printf("FormatFont .Color = 11, .Bold = 1\n");
                }
                break;
			case 'U' :
                if ((G_travtype&FUNC_BIT)!=0) {
                    prmap(map,d,l);
                    printf("FormatFont .Color = 14, .Bold = 1\n");
                }
                break;
			case 'C' :
                if ((G_travtype&FUNC_BIT)!=0) {
                    prmap(map,d,l);
                    printf("FormatFont .Color = 14, .Bold = 1\n");
                }
                break;
			case 'S' :
                if ((G_travtype&STOR_BIT)!=0) {
                    prmap(map,d,l);
                    printf("FormatFont .Color = 0 , .Bold = 1\n");
                }
                break;
		}
	
		printf("Insert \"%s%s\"\n",name,done?"...":"");
		printf("FormatFont .Color = 0, .Bold = 0\nInsertPara\n");
	} else {    
        if (((G_travtype&FUNC_BIT)!=0)&&(type=='C')&&(!strcmp(name,"PRODUCT"))&&(!done)) {
            expanddbm("product","action",l);
        } else {
            switch (type) {
                case 'F' :
                    switch (G_fid[isform(name)]->type) {
                        case F_MENU :
              		        if ((G_travtype&MENU_BIT)!=0) {
                                prmap(map,d,l);
                                printf("M %s%s\n",name,done?"...":"");
                            }
                            break;
                        case F_SERVE :
                        case F_NORM :
                        case F_PROMPT :
              		        if ((G_travtype&FORM_BIT)!=0) {
                                prmap(map,d,l);
                                printf("F %s%s\n",name,done?"...":"");
                            }
                            break;
                        case F_REPORT :
                        case F_PPFORM :
              		        if ((G_travtype&REPO_BIT)!=0) {
                                prmap(map,d,l);
                                printf("R %s%s\n",name,done?"...":"");
                            }
                            break;
                    }
                    break;
                case 'A' :
                case 'T' :
        	        if ((G_travtype&ACTI_BIT)!=0) {
                        prmap(map,d,l);
                        printf("%c %s%s\n",type,name,done?"...":"");
                    }
                    break;
                case 'S' :
        	        if ((G_travtype&STOR_BIT)!=0) {
                        prmap(map,d,l);
                        printf("%c %s%s\n",type,name,done?"...":"");
                    }
                    break;
                case 'U' :
                case 'C' :
        	        if ((G_travtype&FUNC_BIT)!=0) {
                        prmap(map,d,l);
                        printf("%c %s%s\n",type,name,done?"...":"");
                    }
                    break;
            }
        }
	} 
}
char *fnameidx(int idx)
{
    if ((idx>0)&&(idx<G_numidx))
        return(G_fid[idx]->name);

    return("NONE");
}
void checkaction(int idx,int l)
{
	int i,k,last,a;
    if ((actiontype(idx)==VARIABLE)||(actiontype(idx)==STATNAME)) {
		return;
    }
	if (checkx(actionname(idx))) {
		opt(((actiontype(idx)==TABLE)?'T':'A'),actionname(idx),1,l);
		return;
	} 
	last=k=(-1);
	for (i=G_nac-1;i>=0;i--) {
        if (idx==G_ac[i].a) {
            if (k==(-1)) k=i;
			switch (G_ac[i].t) {
				case 1 :
				case 5 :
                    if ((G_travtype&(ACTI_BIT))!=0) last=i;
					break;
				case 2 :
                    if ((a=isform(fnameidx((int)G_ac[i].d)))!=(-1)) {
                        switch (G_fid[a]->type) {
                            case F_MENU :
                                if ((G_travtype&(MENU_BIT))!=0) last=i;
                                break;
                            case F_NORM :
                            case F_SERVE :
                            case F_PROMPT :
                                if ((G_travtype&(FORM_BIT))!=0) last=i;
                                break;
                            case F_REPORT :
                            case F_PPFORM :
                                if ((G_travtype&(REPO_BIT))!=0) last=i;
                                break;
                        }
                    }
					break;
				case 3 :
				case 4 :
                    if ((G_travtype&(FUNC_BIT))!=0) last=i;
					break; 
				case 6 :
                    if ((G_travtype&(STOR_BIT))!=0) last=i;
					break;
            }
            if (last!=(-1)) break;
        }
    }

    opt(((actiontype(idx)==TABLE)?'T':'A'),actionname(idx),0,l);
	if (k!=(-1)) {
        if ((G_travtype&ACTI_BIT)!=0) G_deep++;
		for (i=0;i<=k;i++) {
			if (idx==G_ac[i].a) {
				switch (G_ac[i].t) {
					case 1 :
 						checkaction((int)G_ac[i].d,i==last);
						break;
					case 2 :
						if ((isform(fnameidx((int)G_ac[i].d)))!=(-1L)) {
							if (G_dontdown) {
								opt('F',fnameidx((int)G_ac[i].d),0,i==last);
							} else {
								checkform(fnameidx((int)G_ac[i].d),i==last);
							}
						}
						break;
					case 3 :
						opt('U',G_ufunclst[(int)G_ac[i].d],0,i==last);
						break;
					case 4 :
						opt('C',G_actmaplst[(int)G_ac[i].d],0,i==last);
						break; 
					case 5 :
						opt('T',actionname((int)G_ac[i].d),0,i==last);
						break; 
					case 6 :
                        expanddbm(G_store[(INT)(G_ac[i].d>>8)].name,G_lib[G_store[(INT)(G_ac[i].d>>8)].li[(INT)(G_ac[i].d&0xFF)]].name,i==last);
						break; 
				}
			}
		}
		if ((G_travtype&ACTI_BIT)!=0) G_deep--;
	}
}
void restform(char *name)
{
	freeform(&G_form);
    strcpy(G_form.name,name);
	if (!loadform(&G_form)) {
	    printf("Can't Load Form [%s]\n",name);
	} else {
		orderform(&G_form,( (G_form.type==F_MENU   )
                          ||(G_form.type==F_REPORT )
                          ||(G_form.type==F_PPFORM )) );
	}
}
void checkform(char *name,int l)
{
	int i,j,k,a,last;
	char sname[9],*s;
	strncpy(sname,name,9);
	if (checkx(sname)) {
		opt('F',sname,1,l);
		return;
	}
   	restform(sname);
	last=k=(-1);
    for (i=G_form.numitem-1;i>=0;i--) {
        s=G_form.items[i].func;
        if ((s!=NULL)&&(*s!=0)) {
            if ((a=isaction(s))!=0) {
                if (a<0) {
                    if ((G_travtype&(ACTI_BIT))!=0) last=i;
                } else {
                    if ((G_travtype&(FUNC_BIT))!=0) last=i;
                }
                if (k==(-1)) k=i;
            } else if ((a=isform(s))!=(-1L)) {
                switch (G_fid[a]->type) {
                    case F_MENU :
                        if ((G_travtype&(MENU_BIT))!=0) last=i;
                        break;
                    case F_NORM :
                    case F_SERVE :
                    case F_PROMPT :
                        if ((G_travtype&(FORM_BIT))!=0) last=i;
                        break;
                    case F_REPORT :
                    case F_PPFORM :
                        if ((G_travtype&(REPO_BIT))!=0) last=i;
                        break;
                }
                if (k==(-1)) k=i;
            }
			if (last!=(-1)) break;
		}
	}
    opt('F',sname,0,l);
	if (k!=(-1)) {
		if ((G_travtype&(FORM_BIT|MENU_BIT|REPO_BIT))!=0) G_deep++;
    	for (i=0;i<=k;i++) {
            s=G_form.items[i].func;
    		if ((j=isaction(s))!=0) {
       			if (j>0) {
           			if (j>999) opt('U',s,0,i==last); else opt('C',s,0,i==last);
       			} else {
 					checkaction((0-j)-1,i==last);
 			    	restform(sname);
       			}
			} else {
                if ((s!=NULL)&&(*s!=0)&&(isform(s)!=(-1L))) {
 					checkform(s,i==last);
  			    	restform(sname);
				}
			}
    	}
		if ((G_travtype&(FORM_BIT|MENU_BIT|REPO_BIT))!=0) G_deep--;
	}
}
void readcfuncs(void)
{
    FILE *fp;
    CHAR tmp[256];
    int i,j;
    fp=fopen("GPAFUNC.LST","r");
    if (fp==NULL) {
        G_actmaplst=malloc(sizeof(CHAR *));
        G_actmaplst[0]=NULL;
        G_ufunclst=malloc(sizeof(CHAR *));
        G_ufunclst[0]=NULL;
    } else {
        G_actmaplst=malloc(sizeof(CHAR *)*0x1000);
        G_ufunclst=malloc(sizeof(CHAR *)*0x1000);
        i=j=0;
        while (fgets(tmp,255,fp)!=NULL) {
            while ((tmp[strlen(tmp)-1]==10)||(tmp[strlen(tmp)-1]==13)) tmp[strlen(tmp)-1]=0;
            if (tmp[0]=='G') {
                G_actmaplst[i++]=strdup(&tmp[2]);
            } else if (tmp[0]=='U') {
                G_ufunclst[j++]=strdup(&tmp[2]);
            }
        }
        fclose(fp);
        G_actmaplst[i++]=NULL;
        G_ufunclst[j++]=NULL;
        G_actmaplst=realloc(G_actmaplst,sizeof(CHAR *)*i);
        G_ufunclst =realloc(G_ufunclst ,sizeof(CHAR *)*j);
    }
}
unsigned char getpix(int x,int y)
{
	UCHAR *scr;
	INT ret,i;
    scr=(UCHAR *)(COLVIDMEM+(INT)((LONG)y*80L)+x);
	ret=0;
 	for (i=0;i<4;i++) {
        OUTPB(0x3CE,4);
        OUTPB(0x3CF,(CHAR)i);
        OUTPB(0x3C4,2);
		OUTPB(0x3C5,(CHAR)(1<<i));
        ret|=*scr;
	}
	return(~ret);
}
void dumppcx(char *name)
{
    int fd,k,l;
    unsigned char next,current,count;
    char tmp[20];
    sprintf(tmp,"%s.PCX",name);
    if ((fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))!=(-1)) {
    	if ((write(fd,pcx_header,128))==(-1)) {
            close(fd);
            return;
		}
        for (k=0;k<480;k++) {
            count=0;
            current=getpix(0,k);
	        for (l=0;l<80;l++) {
                next=getpix(l,k);
	            if ((next==current)&&(count<63)) {
    			    count++;
                } else {
			        count|=0xc0;
			        if ((write(fd,&count,1))==(-1)) {
                        close(fd);
                        return;
			        }
			        if ((write(fd,&current,1))==(-1)) {
                        close(fd);
                        return;
			        }
			        current=next;
			        count=1;
	            }
            }
			count|=0xc0;
			if ((write(fd,&count,1))==(-1)) {
                close(fd);
                return;
			}
			if ((write(fd,&current,1))==(-1)) {
                close(fd);
                return;
	        }
        }
    }
    close(fd);
}
// GPA runtime    Usage - "GPA system_name"
int _cdecl main(int argc,char *argv[]) 
{
	int i=0,j,a;
	G_numidx=0;
	G_sstart=((_SS<<16)|_SP);

    COLVIDMEM=MK_FP(__SegA000,0x0000);
    COLVIDSEG=__SegA000;
    MONOVIDMEM=MK_FP(__SegB000,0x0000);
    TEXTVIDMEM=MK_FP(__SegB800,0x0000);

    G_xspand=malloc(MAXSAVE*sizeof(char *));
    G_atnlst=malloc(MAXSAVE*sizeof(char *));
    G_ac    =malloc(MAXSAVE*sizeof(SAVEINFO));

    G_travtype=FORM_BIT|MENU_BIT|REPO_BIT|ACTI_BIT|FUNC_BIT|STOR_BIT;

	if (argc<2) {
		fprintf(stderr,"%s [-m|f|r|a|s|c|M|F|R|A|S|C|P] SYSTEM [form|action]\n",argv[0]);
		return(1);
	}
    a=3;
    if (argv[1][0]=='-') {
        switch (argv[1][1]) {
            case 'M' : G_wm=1; case 'm' : G_travtype=MENU_BIT;   a=4; break;
            case 'F' : G_wm=1; case 'f' : G_travtype=TOFORM_BIT; a=4; break;
            case 'R' : G_wm=1; case 'r' : G_travtype=TOREPO_BIT; a=4; break;
            case 'A' : G_wm=1; case 'a' : G_travtype=TOACTI_BIT; a=4; break;
            case 'S' : G_wm=1; case 's' : G_travtype=TOSTOR_BIT; a=4; break;
            case 'C' : G_wm=1; case 'c' : G_travtype=TOFUNC_BIT; a=4; break;
            case 'P' : G_wm=2; a=4; break;
        }
    }
    if (argc<a) i=0; else i=1;
    fprintf(stderr,"Initialising Devices\n");
 	if (!initdevices()) {
        fprintf(stderr,"Can't initialise devices (None Found!)\n");
        return(1);
	}
    fprintf(stderr,"Reading Config\n");
	if (!readconfig(argv[a-2])) {
        fprintf(stderr,"Error reading config file %s.cfg\n",argv[1]);
		return(1);
	}
    fprintf(stderr,"Starting Database Module\n");
    if (!sendmsg("DBM",MESSAGE_I,G_system)) {
        fprintf(stderr,"Can't initialise Datastores for %s %d\n",G_system,G_sstat[0].err);
		return(1);
    }
	G_lang=0;
   	freetext();
    fprintf(stderr,"Loading Text\n");
   	loadtext(G_system);
    fprintf(stderr,"Loading 3GL Actions\n");
    readcfuncs();
    fprintf(stderr,"Loading 4GL Actions\n");
    loadactions(G_system);
    strcpy(G_form.name,"logon");
    G_form.items=NULL;
    fprintf(stderr,"Loading Forms\n");
    if (!loadform(&G_form)) {
        fprintf(stderr,"Can't load form logon for %s\n",G_system);
		return(1);
    }
    if (G_wm==2) {
        sendmsg("OUTPUT1",MESSAGE_I);
        sendmsg("OUTPUT1",MESSAGE_F,G_fontfile);
        if (i==0) {
            for (i=0;i<G_numidx;i++) {
                clrform(&G_form);
                freeform(&G_form);
                strcpy(G_form.name,G_fid[i]->name);
                if (loadform(&G_form)) restoreform();
//                fillfields(&G_form);
                getch();
            }
        } else {
            clrform(&G_form);
            freeform(&G_form);
            strcpy(G_form.name,argv[a-1]);
            if (loadform(&G_form)) restoreform();
            dumppcx(G_form.name);
//            fillfields(&G_form);
            getch();
        }
        sendmsg("OUTPUT1",MESSAGE_E);
    } else {
        fprintf(stderr,"Parsing Actions\n");
	    for (G_cn=0;G_cn<G_numn;G_cn++) {
            if ((actiontype(G_cn)==TABLE)||(actiontype(G_cn)==ANAME)) {
                fprintf(stderr,"%-10.10s\r",actionname(G_cn));
                collect(actionbuf(G_cn));
            }
        }
        fprintf(stderr,"           \n");
	    if (i==0) {
            G_dontdown=0;
            checkform("logon",1);
		    for (G_dontdown=1;G_dontdown>=0;G_dontdown--) {
			    for (i=0;i<G_numidx;i++) {
				    if (!checkx(G_fid[i]->name)) {
					    free(G_xspand[--G_numx]);
					    checkform(G_fid[i]->name,1);
				    }
			    }
			    for (i=0;i<G_numn;i++) {
				    if (!checkx(actionname(i))&&(actiontype(i)==ANAME)) {
					    free(G_xspand[--G_numx]);
					    checkaction(i,1);
				    }
			    }
		    }
		    j=0;
		    for (i=0;i<G_numn;i++) {
			    if ((actiontype(i)==STATNAME)) {
				    if (j==0) {
					    j=1;
					    printf("Statics\n");
				    }
				    printf("%-10.10s",actionname(i));
			    }
		    }
		    if (j==1) printf("\n");
		    j=0;
		    for (i=0;i<G_numn;i++) {
			    if ((actiontype(i)==VARIABLE)) {
				    if (j==0) {
					    j=1;
					    printf("Variables\n");
				    }
				    printf("%-10.10s",actionname(i));
			    }
		    }
		    if (j==1) printf("\n");
	    } else {
		    G_dontdown=0;
		    i=isaction(argv[a-1]);
   		    if (i!=0) {
   			    if (i<0) checkaction((0-i)-1,1);
		    } else {
			    checkform(argv[a-1],1);
		    }
	    }
    }
    sendmsg("DBM",MESSAGE_E,G_system);
    return(0);
}
