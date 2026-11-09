//SYSDOC docu.txt
#include <dos.h>
#include <conio.h>
#include <ctype.h>
#include <alloc.h>
#include <string.h>
#include <search.h>
#include <dir.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "keydef.h"

int arecomments(char *file,char *func);
int getcomments(char *file,int idx);

#define GLOBCOMFILE "COMMENT.ALL"
#define FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR     FA_DIREC

#ifndef max
#define max(a,b) (a>b?a:b)
#endif // ndef max

int G_recurse=0;

char *G_ctypes[]={
    "char","int","short","long","float","double","unsigned","*","const","interrupt","extern","far","near","static","signed","struct","union","void","#"
};

char *G_cnames[]={
    "+","-","/","%",">",">=","<","<=","==","!=","++","--","&","|","^","<<",
    ">>","~","=","+=","-=","*=","/=","%=","&=","|=","^=","<<=",">>=",
    "?",":","!","[","]","->","{","}","sizeof","//","/*",
    "if","else","switch","case","default","break","do","while","return",
    "new","delete","asm","auto","cdecl","typedef","RETURN",
    "for","volatile","class","enum","#"
};
#define NUMFUNC 2000
typedef struct {
    char  *n;       // name
    char  *p;       // prototype
    char  *s;       // synopsys
    int   *c;       // calls (func number | 0x4000*external)
    int   nc;       // number of calls
    int   fn;       // file number
    int   sl;       // start line number
    int   el;       // end line number
    char  *m;       // modified globals
    char  ac;       // TRUE if there are comments for this function
} FUNCDATA;

FUNCDATA *G_fn;

char *G_str;
char *G_fname[100];
char *G_ftname[100];
int  G_numn=0;
int  G_numf=0;
char G_rstr[256];
char G_lstr[256];
int G_lcalls[200];
char G_lvars[50][30];
int  G_numlvars=0;
char G_mvars[50][30];
int  G_nummvars=0;
char G_function[30];
char G_workspace[4000];
char G_retln[80];
char G_passln[20][80];
char G_descln[30][80];
int G_np=0;
int G_nd=0;

char *G_last20lines[20];
int G_numinlast20=0;
FILE *comfile=NULL;
//S Add current line to list of last 20 lines
//D Add current line to list of last 20 lines for comments above functions
//P string to add 
void addlinetolist(char *s)
{
    int i;
    if (G_numinlast20<20) {
        G_last20lines[G_numinlast20++]=strdup(s);
    } else {
        free(G_last20lines[0]);
        for (i=0;i<19;i++) G_last20lines[i]=G_last20lines[i+1];
        G_last20lines[19]=strdup(s);
    }
}
//S print last 20 lines 
void prlast20com(int idx)
{
    int i,printit=0;
    for (i=G_numinlast20-2;i>=0;i--) {
        if (G_last20lines[i][0]!='\/') break;
    }
    i++;
    if (comfile==NULL) {
        comfile=fopen(GLOBCOMFILE,"a+");
        if (comfile==NULL) {
            comfile=stdout;
        }
    }
    if (i<G_numinlast20-1) {
        printit=1;
        fprintf(comfile,"M %s\n",G_fname[G_fn[idx].fn]);
        fprintf(comfile,"F %s\n",G_fn[idx].n);
    }
    for (;i<G_numinlast20-1;i++) {
        if (strlen(G_last20lines[i])>3) {
            switch (G_last20lines[i][2]) {
                case 'D' :
                    fprintf(comfile,"D %s\n",&(G_last20lines[i][4]));
                    break;
                case 'R' :
                    fprintf(comfile,"R %s\n",&(G_last20lines[i][4]));
                    break;
                case 'P' :
                    fprintf(comfile,"P %s\n",&(G_last20lines[i][4]));
                    break;
                case 'S' :
                    fprintf(comfile,"S %s\n",&(G_last20lines[i][4]));
                    break;
                case 'F' :
                    break;
                default :
                    if ((strncmp(&(G_last20lines[i][4]),"********************",20))
                    &&  (strncmp(&(G_last20lines[i][4]),"--------------------",20))
                    &&  (strncmp(&(G_last20lines[i][4]),"____________________",20))
                    &&  (strlen(G_last20lines[i])>4))
                        fprintf(comfile,"S %s\n",&(G_last20lines[i][3]));
            }
        }
    }
    for (i=G_numinlast20-2;i>=0;i--) {
        free(G_last20lines[i]);
    }
    if (printit) fprintf(comfile,"\n");
    G_numinlast20=0;
}
// Write variable length block to file
void writevar(int fd,void *p,int size)
{
	if (p==NULL) {
		size=0;
		write(fd,&size,sizeof(size));
	} else {
		write(fd,&size,sizeof(size));
		write(fd,p,size);
	}
}

// Read variable length block from file
int readvar(int fd,char **p)
{
	int size=0;
	read(fd,&size,sizeof(size));
	if (size==0) {
		*p=NULL;
	} else {
		*p=malloc(size);
		if (*p!=NULL)
			read(fd,*p,size);
		else
			size=0;
	}
	return(size);
}
// Save the collected data in binary format
void save(char *file)
{
	int fd;
	int i;
	if ((fd=open(file,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE))==(-1)) return;
	write(fd,&G_numf,sizeof(int));
	for (i=0;i<G_numf;i++) {
		writevar(fd,G_fname[i],strlen(G_fname[i])+1);
		writevar(fd,G_ftname[i],strlen(G_ftname[i])+1);
	}
	write(fd,&G_numn,sizeof(int));
	for (i=0;i<G_numn;i++) {
		writevar(fd,G_fn[i].n,strlen(G_fn[i].n)+1);
		writevar(fd,G_fn[i].p,strlen(G_fn[i].p)+1);
		writevar(fd,G_fn[i].s,strlen(G_fn[i].s)+1);
		writevar(fd,G_fn[i].m,strlen(G_fn[i].m)+1);
		writevar(fd,G_fn[i].c,G_fn[i].nc*sizeof(int));
		write(fd,&(G_fn[i].fn),sizeof(int));
		write(fd,&(G_fn[i].sl),sizeof(int));
		write(fd,&(G_fn[i].el),sizeof(int));
		write(fd,&(G_fn[i].ac),sizeof(char));
	}
	close(fd);
}
// Load the collected data in binary format
void load(char *file)
{
	int fd;
	int i;
	if ((fd=open(file,O_RDONLY|O_BINARY))==(-1)) return;
	read(fd,&G_numf,sizeof(int));
	for (i=0;i<G_numf;i++) {
		readvar(fd,&(G_fname[i] ));
		readvar(fd,&(G_ftname[i]));
	}
	read(fd,&G_numn,sizeof(int));
	for (i=0;i<G_numn;i++) {
		readvar(fd,&(G_fn[i].n));
		readvar(fd,&(G_fn[i].p));
		readvar(fd,&(G_fn[i].s));
		readvar(fd,&(G_fn[i].m));
		G_fn[i].nc=readvar(fd,(char **)&(G_fn[i].c))/sizeof(int);
		read(fd,&(G_fn[i].fn),sizeof(int));
		read(fd,&(G_fn[i].sl),sizeof(int));
		read(fd,&(G_fn[i].el),sizeof(int));
		read(fd,&(G_fn[i].ac),sizeof(char));
	}
	close(fd);
}
// Returns true if G_str points to a valid word.
int isvalword(void)
{
    char *p;
    while (isspace(*G_str)) G_str++;
    p=G_str;
    while ((*p)&&(isalnum(*p)||(*p=='*')||(*p=='_'))) p++;
    if (p==G_str) return(0);
    G_str=p;
    return(1);
}
// Returns true if G_str points to t
int match(char *t)  
{                   
    char *p;        
    int len=strlen(t);
                    
    while (isspace(*G_str)) G_str++;
    p=G_str;
    while ((*t)&&(*t==*(p++))) t++;
    if (*t==0) {
        G_str+=len;
        return(1);
    }
    return(0);
}
// Returns true if G_str points to a reserved word.
int iscword(void)
{
    int i=0;
    while (G_cnames[i][0]!='#') {
        if (match(G_cnames[i])) return(i+1);
        i++;
    }
    return(0);
}
// Returns true if G_str points to a reserved type.
int isctype(void)
{
    int i=0;
    while (G_ctypes[i][0]!='#') {
        if (match(G_ctypes[i])) return(i+1);
        i++;
    }
    return(0);
}
// Counts curly the braces in s = '{' = +1   '}' = -1
int cntcurly(char *s)
{
    int ret=0;
	int ignore=0;
    while (*s) {
		if ((*s=='\"')&&((*(s-1)!='\\')||((*(s-2)=='\\')&&(*(s-1)=='\\')))) ignore^=1;
		if ((*s=='\'')&&((*(s-1)!='\\')||((*(s-2)=='\\')&&(*(s-1)=='\\')))) ignore^=2;
		if (!ignore) {
        	if (*s=='{') ret++;
        	if (*s=='}') ret--;
		}
        s++;
    }
    return(ret);
}
// Strip the leading space from G_str
void stripspace(void)
{
    while ((*G_str)&&isspace(*G_str)) G_str++;
}
// Save the local variable information
void savelvars(char *str)
{
    char tmp[256];
    char *s,*a;

    G_str=str;
    stripspace();
    isvalword();
    while (isctype());
    strcpy(tmp,G_str);
    s=strtok(tmp,",;*");
    while (s!=NULL) {
        if (*s&&(*s!='=')&&(*s!='[')) {
            a=s;
            while (*s&&(*s!='=')&&(*s!='[')) s++;
            memcpy(G_lvars[G_numlvars],a,(int)(s-a));
            G_lvars[G_numlvars++][(int)(s-a)]=0;
        }
        s=strtok(NULL,",;*");
    }
}
// Save the Global variable modification information
void savegmod(char *str)
{
    int i;
    char *s;
    G_str=str;
    stripspace();
    while ((*G_str)&&(*G_str=='*')) G_str++;
    for (i=0;i<G_numlvars;i++) {
        if (!strncmp(G_lvars[i],G_str,strlen(G_lvars[i]))) return;
    }
    s=G_str;
    isvalword();
    memcpy(G_mvars[G_nummvars],s,(int)(G_str-s));
    G_mvars[G_nummvars][(int)(G_str-s)]=0;
    for (i=0;i<G_nummvars;i++) {
        if (!strcmp(G_mvars[G_nummvars],G_mvars[i])) return;
    }
    G_nummvars++;
}
// Remove all 'C' comments from a line
char *remcom(char *g)
{
    int xit=0;
    static char tmp[256];
    char *p;

    while ((*g)&&isspace(*g)) g++;
    p=tmp;

    while ((*g)&&(!xit)) {
        if (*g=='/') {
            if (*(g+1)=='/') {
                xit=1;
            } else {
                if (*(g+1)=='*') {
                    g+=2;
                    while ((*g)&&((*g)!='*')&&(*(g+1)!='/')) {
                        g++;
                    }
                    if (*g) g+=2;
                } else {
                    *(p++)=*(g++);
                }
            }
        } else {
            *(p++)=*(g++);
        }
    }
    *p=0;
    while (isspace(*(p-1))&&(p>tmp)) p--;
    *p=0;
    return(tmp);
}
// Returns the function name from a prototype
char *getfname(char *prot)
{
    char *p;
    static char tmp[80];
    int i=0;
    p=prot;
    while ((*p)&&(*p!='(')) p++;
    if ((!*p)||(p==prot)) return(prot);
    G_str=p;
    p--;
    while ((p!=prot)&&isspace(*p)) p--;
    while ((p!=prot)&&(!isspace(*p))&&(*p!='*')) { i++; p--; }
    p++;
    strncpy(tmp,p,i);
    tmp[i]=0;
    return(tmp);
}
// Find all functions in a file.
void funcfind(char *name)
{
    FILE *fp;
    char r[256],*t;
//    char sname[40];
    int i,lc=0;
    int v=0;
    int infunc=0;
    int curly=0;

    G_lstr[0]=0;

    fp=fopen(name,"r");
    if (fp==NULL) {
        fprintf(stderr,"Can't open %-15s               \r",name);
        return;
    }
    fprintf(stderr,"Building Function list from %-15s :\r",name);
    if ((name[0]=='.')&&(name[1]=='\\')) 
        G_fname[G_numf++]=strdup(&name[2]);
    else 
        G_fname[G_numf++]=strdup(name);

    while (fgets(G_rstr,255,fp)!=NULL) {
        G_rstr[strlen(G_rstr)-1]=0;
        addlinetolist(G_rstr);
        if ((G_rstr[0]!='#')&&(G_rstr[0]!='/')) {
            strcpy(G_rstr,remcom(G_rstr));
            curly+=cntcurly(G_rstr);
            i=strlen(G_rstr)-1;
            while (isspace(G_rstr[i])&&(i>0)) i--;
            G_rstr[i+1]=0;
            G_str=G_rstr;
            if (!iscword()) {
                while (isvalword());
                if ((*G_str=='(')&&((G_rstr[i]==')')||(G_rstr[i]=='{')||(G_rstr[i]=='}'))) {
                    if ((G_rstr[i]=='{')&&(G_rstr[i]!='}')) G_rstr[i]=0;
                    G_str=G_rstr;
                    while ((*G_str)&&isspace(*G_str)) G_str++;
                    G_fn[G_numn].p=strdup(G_str);
                    G_fn[G_numn].s=strdup(G_lstr);
                    G_fn[G_numn].n=strdup(getfname(G_str));
				    fprintf(stderr,"Building Function list from %-15s : %d %s            \r",name,G_numn,G_fn[G_numn].n);
                    G_fn[G_numn].fn=G_numf-1;
                    prlast20com(G_numn);
                    G_fn[G_numn].sl=lc;
                    if (G_fn[G_numn].n!=NULL) {
						G_fn[G_numn].ac=arecomments(G_ftname[G_numf-1],G_fn[G_numn].n);
						G_numn++;
					}
                    infunc=1;
                    curly=cntcurly(G_rstr);
                }
            }
            if ((infunc==1)&&(curly==1)) {
                infunc=2;
                G_numlvars=0;
                G_nummvars=0;
            }
            if ((infunc==2)&&(curly==0)) {
                infunc=0;
                if (G_nummvars) {
                    r[0]=0;
                    for (i=0;i<G_nummvars;i++) {
                        sprintf(&r[strlen(r)],"%s ",G_mvars[i]);
                    }
                    G_fn[G_numn-1].m=strdup(r);
                } else {
                    G_fn[G_numn-1].m=strdup("*");
                }
                G_fn[G_numn-1].el=lc;
            }
            if (infunc==2) {
                G_str=G_rstr;
                if (!iscword()) {
                    v=0;
                    if (isvalword()) if (isspace(*G_str)) if (isvalword()) v=1;
                    if ((*G_str!='(')&&(G_rstr[i]==';')&&(v)) {
                        savelvars(G_rstr);
                    }
                }
                G_str=G_rstr;
                if (!iscword()) {
                    while (isvalword());
                    if ((*G_str)&&(*G_str!='(')&&(!v)) {
                        savegmod(G_rstr);
                    }
                }
            }
        }
        lc++;
        if (G_rstr[0]!=0) {
            strcpy(G_lstr,G_rstr);
			if (!strncmp(G_rstr,"//SYSDOC",8)) {
				t=strtok(&G_rstr[9]," \t\r\n");
				if (t!=NULL) G_ftname[G_numf-1]=strdup(t);
			}
		} else {
            strcpy(G_lstr,"--");
		}
    }
    fclose(fp);
}
// Recursivly search [sub-]directorys for files
void getfiles(char *path,char *search,int depth)
{
    struct ffblk *fi;                              /* file information     */
    char *curpath;                                  /* local strings        */
    char *newpath;
    char *dirpath;

    curpath=malloc(strlen(path)+strlen(search)+2);  /* get space            */
    newpath=malloc(strlen(path)+16);
    dirpath=malloc(strlen(path)+5);
    fi=malloc(sizeof(struct ffblk));

    sprintf(curpath,"%s%s",path,search);            /* set search path      */
    sprintf(dirpath,"%s%s",path,"*.*");             /* directory not limited*/

    findfirst(dirpath,fi,DIRATTR);             /* ignore .             */
    if (strcmp(fi->ff_name,".")) {                     /* check for root dir   */
        sprintf(newpath,"%s%s\\",path,fi->ff_name);    /* concat dir name      */
        if (G_recurse) getfiles(newpath,search,depth+1);           /* recurse              */
    }
    else {
        findnext(fi);                          /* ignore ..            */
    }
    while (findnext(fi)==0) {                  /* do all directorys    */
        if (fi->ff_attrib&DIRATTR)  {                  /* make sure it's a dir */
            sprintf(newpath,"%s%s\\",path,fi->ff_name);/* concat dir name      */
            if (G_recurse) getfiles(newpath,search,depth+1);       /* recurse              */
        }
    }

    if (findfirst(curpath,fi,FILEATTR)==0) {   /* get the first file   */
        do {                                      
            sprintf(newpath,"%s%s",path,fi->ff_name);  /* concat path & file   */
            funcfind(newpath);
        } while (findnext(fi)==0);             /* get the next file    */
    }

    path[strlen(path)-1]=0;                         /* take the '\' off     */

    free(fi);                                       /* clean up             */
    free(dirpath);
    free(newpath);
    free(curpath);
}
// Returns true if on the function start line number in a file
int findfuncln(int func,int file,int ln)
{
    return((G_fn[func].fn==file)&&(G_fn[func].sl==ln));
}
// Returns +tive value if a line contains a known function
int contfunc(char *str)
{
    static int i=0;
    char *t;

    if (!*str) {
        i=0;
        return(-1);
    }

    for (;i<G_numn;i++) {
        t=strstr(str,G_fn[i].n);
        if (t!=NULL) {
            if (((!isalnum(*(t-1)))||(t==str))&&(*(t-1)!='_')&&(*(t-1)!='\"')) {
                t+=strlen(G_fn[i].n);
                while ((*t)&&(isspace(*t))) t++;
                if (!isalnum(*t)&&(*t!='_')&&(*t!='\"')) return(i++);
            }
        }
    }

    i=0;
    return(-1);
}
// Get call map for all functions
void cmap(void)
{
    FILE *fp;
    char str[256];
    int i,j,k;
    int lc,fnum,numc;
    int *calls;

    for (i=0;i<NUMFUNC;i++) G_fn[i].nc=0;
    calls=malloc(1000*sizeof(int));

    for (i=0;i<G_numf;i++) {
        fp=fopen(G_fname[i],"r");
        if (fp==NULL) {
            fprintf(stderr,"Can't open %-15s               \r",G_fname[i]);
        }
        else {
            fprintf(stderr,"Analysing functions in %-15s :\r",G_fname[i]);
            lc=0;
            while (fgets(str,255,fp)!=NULL) {
                if ((str[0]!='#')&&(str[0]!='/')) {
                    str[strlen(str)-1]=0;
                    for (j=0;j<G_numn;j++) {
                        if (findfuncln(j,i,lc)) {
				            fprintf(stderr,"Analysing functions in %-15s : %s                \r",G_fname[i],G_fn[j].n);
                            numc=0;
                            while ((lc<G_fn[j].el)&&(fgets(str,255,fp)!=NULL)) {
                                if ((str[0]!='#')&&(str[0]!='/')) {
                                    str[strlen(str)-1]=0;
                                    while ((fnum=contfunc(str))!=(-1)) {
                                        for (k=0;k<numc;k++) {
                                            if ((calls[k]&0x3FFF)==fnum) k=2000;
                                        }
                                        if (k<2000) {
											if (G_fn[fnum].fn!=i) 
	                                            calls[numc++]=fnum|0x4000;
											else
	                                            calls[numc++]=fnum;
                                        }
                                    }
                                }
                                lc++;
                            }
                            if (numc) {
                                G_fn[j].c=malloc(numc*sizeof(int));
                                G_fn[j].nc=numc;
                                memcpy(G_fn[j].c,calls,(numc*sizeof(int)));
                                numc=0;
                            }
                        }
                    }
                }
                lc++;
            }
            fclose(fp);
        }
    }
    free(calls);
}
// Print a line in the box seperating at spaces 
void prline(char *name,char *data,char *sep,char end)
{
    char *t;
    int sl=strlen(sep);
    int m=0,j;

    strcpy(G_workspace,data);
    t=strtok(G_workspace," ");

    while (t!=NULL) {
        if (!m) {
            m++;
            printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
            printf("บ %12.12s บ %s",name,t);
            j=strlen(t)+17+sl;
        }
        else {
            m++;
            if ((j+strlen(t)+sl)>78) {
                printf("%s%*.*sบ\nบ              บ %s",sep,78-j,78-j,"",t);
                j=strlen(t)+17+sl;
            }
            else {
                printf("%s%s",sep,t);
                j+=strlen(t)+sl;
            }
        }
        t=strtok(NULL," ");
    }
    if (m) printf("%c%*.*sบ\n",end,(77+sl)-j,(77+sl)-j,"");
}
// Print one page of output on stdout in boxes.
void prpage(int index)
{
    char tmp[40];
    char ret[40];
    char name[40];
    char prot[150];
    char tmpln[150];
    char *t;
    int i=0;
    int j=0;
    int k=0;
    int l,m;

    sprintf(prot,"%s;",G_fn[index].p);
    strcpy(name,G_fn[index].n);

    if ((G_function[0]!=0)&&(strcmp(G_function,name))) return;

    t=strstr(prot,name);
    memcpy(ret,prot,(int)(t-prot));
    ret[(int)(t-prot)]=0;

    if (G_fn[index].ac) {
        getcomments(G_ftname[G_fn[index].fn],index);
    } else {
        getcomments(GLOBCOMFILE,index);
    }
    strcpy(G_lstr,G_fn[index].s);

    if ((ret[0]==' ')||(ret[0]==0)) {
        sprintf(prot,"int %s;",G_fn[index].p);
        strcpy(ret,"int");
    }
    t=&ret[strlen(ret)-1];
    while (isspace(*t)) t--;
    *(t+1)=0;
    printf("ษออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป\n");
    printf("บ     Function บ %-60.60s บ\n",name);
    if ((G_lstr[0]=='/')&&(G_lstr[1]=='/')) {
        t=&G_lstr[2];
        while ((*t)&&isspace(*t)) t++;
        prline("Synopsys",t," ",' ');
    }
    else {
        printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
        printf("บ     Synopsys บ                                                              บ\n");
    }
    prline("Prototype",prot," ",' ');
    prline("Module",G_fname[G_fn[index].fn]," ",' ');
    G_workspace[0]=0;
    for (i=0;i<G_nd;i++) { strcat(G_workspace,G_descln[i]); strcat(G_workspace," "); }
    prline("Description",G_workspace," ",' ');
    printf("บ              บ                                                              บ\n");
    printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
    G_str=strstr(prot,name);
    G_str+=strlen(name);
    i=0;
    while ((*G_str)&&(*G_str!=')')) {
        if (isspace(*G_str)||(*G_str=='(')||(*G_str==',')) {
            G_str++;
        } else {
            t=tmp;
            while ((*G_str)&&(*G_str!=')')&&(*G_str!=',')) *(t++)=*(G_str++);
            *t=0;
            t--;
            while (isspace(*t)) t--;
            *(t+1)=0;
            if (strcmp(tmp,"void")) {
                sprintf(tmpln,"%s %s",tmp,G_passln[i]);
                printf("บ       %s บ %-60.60s บ\n",((i==0)?"Passed":"      "),tmpln);
                i++;
            }
        }
    }
    if (i) printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
    if (strcmp(ret,"void")) {
        sprintf(tmpln,"%s %s",ret,G_retln);
        printf("บ Return Value บ %-60.60s บ\n",tmpln);
    }
    else {
        sprintf(tmpln,"None");
        printf("บ Return Value บ %-60.60s บ\n",tmpln);
    }
    m=0;
    if (G_fn[index].m[0]!='*') prline("Modifies",G_fn[index].m,", ",'.');
    l=0;
    for (j=0;j<G_numn;j++) {
        for (k=0;k<G_fn[j].nc;k++) {
            if ((G_fn[j].c[k]&0x3FFF)==index) {
                for (m=0;m<l;m++) if ((G_lcalls[m]&0x3FFF)==j) break;
                if (m==l) {
                    G_lcalls[l++]=j;
                    if ((G_fn[j].c[k]&0x4000)!=0) G_lcalls[l-1]|=0x4000;
                }
            }
        }
    }
    if (l) {
        for (m=0;m<l;m++) {
            t=G_fn[G_lcalls[m]&0x3FFF].n;
            if ((G_lcalls[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
                printf("บ    Called By บ %s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf(",%*.*sบ\nบ              บ %s",79-j,79-j,"",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".%*.*sบ\n",79-j,79-j,"");
    }
    if (G_fn[index].nc) {
        for (m=0;m<G_fn[index].nc;m++) {
            t=G_fn[G_fn[index].c[m]&0x3FFF].n;
            if ((G_fn[index].c[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
                printf("บ        Calls บ %s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf(",%*.*sบ\nบ              บ %s",79-j,79-j,"",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".%*.*sบ\n",79-j,79-j,"");
    }
    k=0;
    for (i=0;i<G_numn;i++) {
        if ((G_fn[i].fn==G_fn[index].fn)&&(i!=index)) {
            if (!k) {
                printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
                printf("บ     See Also บ %s",G_fn[i].n);
                j=strlen(G_fn[i].n)+19;
            }
            else {
                if ((j+strlen(G_fn[i].n)+2)>78) {
                    printf(",%*.*sบ\nบ              บ %s",79-j,79-j,"",G_fn[i].n);
                    j=strlen(G_fn[i].n)+19;
                }
                else {
                    printf(", %s",G_fn[i].n);
                    j+=strlen(G_fn[i].n)+2;
                }
            }
            k++;
        }
    }
    if (k) printf(".%*.*sบ\n",79-j,79-j,"");
    printf("ศออออออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ\n%c\n",12);
}
// Print a line seperating at spaces 
void prlinen(char *name,char *data,char *sep,char end)
{
    char *t;
    int sl=strlen(sep);
    int m=0,j;

    strcpy(G_workspace,data);
    t=strtok(G_workspace," ");

    while (t!=NULL) {
        if (!m) {
            m++;
            printf("\n %12.12s   %s",name,t);
            j=strlen(t)+17+sl;
        }
        else {
            m++;
            if ((j+strlen(t)+sl)>78) {
                printf("%s\n                %s",sep,t);
                j=strlen(t)+17+sl;
            }
            else {
                printf("%s%s",sep,t);
                j+=strlen(t)+sl;
            }
        }
        t=strtok(NULL," ");
    }
    if (m) printf("%c\n",end);
}
// Print one page of output on stdout.
void prpagen(int index)
{
    char tmp[40];
    char ret[40];
    char name[40];
    char prot[150];
    char tmpln[150];
    char *t;
    int i=0;
    int j=0;
    int k=0;
    int l,m;

    sprintf(prot,"%s;",G_fn[index].p);
    strcpy(name,G_fn[index].n);
    if (G_fn[index].ac) {
        getcomments(G_ftname[G_fn[index].fn],index);
    } else {
        getcomments(GLOBCOMFILE,index);
    }
    strcpy(G_lstr,G_fn[index].s);

    if ((G_function[0]!=0)&&(strcmp(G_function,name))) return;

    t=strstr(prot,name);
    memcpy(ret,prot,(int)(t-prot));
    ret[(int)(t-prot)]=0;

    if ((ret[0]==' ')||(ret[0]==0)) {
        sprintf(prot,"int %s;",G_fn[index].p);
        strcpy(ret,"int");
    }
    t=&ret[strlen(ret)-1];
    while (isspace(*t)) t--;
    *(t+1)=0;
    printf("\n     Function   %-s\n",name);
    if ((G_lstr[0]=='/')&&(G_lstr[1]=='/')) {
        t=&G_lstr[2];
        while ((*t)&&isspace(*t)) t++;
        prlinen("Synopsys",t," ",' ');
    }
    else {
        printf("\n     Synopsys\n");
    }
    prlinen("Prototype",prot," ",' ');
    prlinen("Module",G_fname[G_fn[index].fn]," ",' ');
    G_workspace[0]=0;
    for (i=0;i<G_nd;i++) { strcat(G_workspace,G_descln[i]); strcat(G_workspace," "); }
    prlinen("Description",G_workspace," ",' ');
    printf("\n\n");
    G_str=strstr(prot,name);
    G_str+=strlen(name);
    i=0;
    while ((*G_str)&&(*G_str!=')')) {
        if (isspace(*G_str)||(*G_str=='(')||(*G_str==',')) {
            G_str++;
        } else {
            t=tmp;
            while ((*G_str)&&(*G_str!=')')&&(*G_str!=',')) *(t++)=*(G_str++);
            *t=0;
            t--;
            while (isspace(*t)) t--;
            *(t+1)=0;
            if (strcmp(tmp,"void")) {
                sprintf(tmpln,"%s %s",tmp,G_passln[i]);
                printf("       %s   %-s\n",((i==0)?"Passed":"      "),tmpln);
                i++;
            }
        }
    }
    if (i) printf("\n");
    if (strcmp(ret,"void")) {
        sprintf(tmpln,"%s %s",ret,G_retln);
    }
    else {
        sprintf(tmpln,"None");
    }
    printf(" Return Value   %-s\n",tmpln);
    m=0;
    if (G_fn[index].m[0]!='*') {
        prlinen("Modifies",G_fn[index].m,", ",'.');
    }
    l=0;
    for (j=0;j<G_numn;j++) {
        for (k=0;k<G_fn[j].nc;k++) {
            if ((G_fn[j].c[k]&0x3FFF)==index) {
                for (m=0;m<l;m++) if ((G_lcalls[m]&0x3FFF)==j) break;
                if (m==l) {
                    G_lcalls[l++]=j;
                    if ((G_fn[j].c[k]&0x4000)!=0) G_lcalls[l-1]|=0x4000;
                }
            }
        }
    }
    if (l) {
        for (m=0;m<l;m++) {
            t=G_fn[G_lcalls[m]&0x3FFF].n;
            if ((G_lcalls[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("\n    Called By   %s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf("\n                %s",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".\n");
    }
    if (G_fn[index].nc) {
        for (m=0;m<G_fn[index].nc;m++) {
            t=G_fn[G_fn[index].c[m]&0x3FFF].n;
            if ((G_fn[index].c[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("\n        Calls   %s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf(", \n                %s",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".\n");
    }
    k=0;
    for (i=0;i<G_numn;i++) {
        if ((G_fn[i].fn==G_fn[index].fn)&&(i!=index)) {
            if (!k) {
                printf("\n     See Also   %s",G_fn[i].n);
                j=strlen(G_fn[i].n)+19;
            }
            else {
                if ((j+strlen(G_fn[i].n)+2)>78) {
                    printf(",\n                %s",G_fn[i].n);
                    j=strlen(G_fn[i].n)+19;
                }
                else {
                    printf(", %s",G_fn[i].n);
                    j+=strlen(G_fn[i].n)+2;
                }
            }
            k++;
        }
    }
    if (k) printf(".\n");
    printf("\n%c\n",12);
}
// Print one page of output on stdout with no textfile spacing for wp.
void prpagewp(int index)
{
    char tmp[40];
    char ret[40];
    char name[40];
    char prot[150];
    char tmpln[150];
    char *t;
    int i=0;
    int j=0;
    int k=0;
    int l,m;

    sprintf(prot,"%s;",G_fn[index].p);
    strcpy(name,G_fn[index].n);

    if ((G_function[0]!=0)&&(strcmp(G_function,name))) return;

    t=strstr(prot,name);
    memcpy(ret,prot,(int)(t-prot));
    ret[(int)(t-prot)]=0;

    if (G_fn[index].ac) {
        getcomments(G_ftname[G_fn[index].fn],index);
    } else {
        getcomments(GLOBCOMFILE,index);
    }
    strcpy(G_lstr,G_fn[index].s);

    if ((ret[0]==' ')||(ret[0]==0)) {
        sprintf(prot,"int %s;",G_fn[index].p);
        strcpy(ret,"int");
    }
    t=&ret[strlen(ret)-1];
    while (isspace(*t)) t--;
    *(t+1)=0;
    printf("Function\t%-s\n\n",name);
    if ((G_lstr[0]=='/')&&(G_lstr[1]=='/')) {
        t=&G_lstr[2];
        while ((*t)&&isspace(*t)) t++;
        printf("Synopsys\t%s",t);
    }
    else {
        printf("Synopsys");
    }
    printf("\n\n");
    printf("Prototype\t%s\n\n",prot);
    printf("Module\t%s\n\n",G_fname[G_fn[index].fn]);
    G_workspace[0]=0;
    for (i=0;i<G_nd;i++) { strcat(G_workspace,G_descln[i]); strcat(G_workspace," "); }
    printf("Description\t%s\n\n",G_workspace);
    G_str=strstr(prot,name);
    G_str+=strlen(name);
    i=0;
    while ((*G_str)&&(*G_str!=')')) {
        if (isspace(*G_str)||(*G_str=='(')||(*G_str==',')) {
            G_str++;
        } else {
            t=tmp;
            while ((*G_str)&&(*G_str!=')')&&(*G_str!=',')) *(t++)=*(G_str++);
            *t=0;
            t--;
            while (isspace(*t)) t--;
            *(t+1)=0;
            if (strcmp(tmp,"void")) {
                sprintf(tmpln,"%s %s",tmp,G_passln[i]);
                printf("%s\t%-s\n",((i==0)?"Passed":""),tmpln);
                i++;
            }
        }
    }
    if (i) printf("\n");
    if (strcmp(ret,"void")) {
        sprintf(tmpln,"%s %s",ret,G_retln);
    }
    else {
        sprintf(tmpln,"None");
    }
    printf("Return Value\t%-s\n\n",tmpln);
    m=0;
    if (G_fn[index].m[0]!='*') {
        printf("Modifies\t%s\n\n",G_fn[index].m);
    }
    l=0;
    for (j=0;j<G_numn;j++) {
        for (k=0;k<G_fn[j].nc;k++) {
            if ((G_fn[j].c[k]&0x3FFF)==index) {
                for (m=0;m<l;m++) if ((G_lcalls[m]&0x3FFF)==j) break;
                if (m==l) {
                    G_lcalls[l++]=j;
                    if ((G_fn[j].c[k]&0x4000)!=0) G_lcalls[l-1]|=0x4000;
                }
            }
        }
    }
    if (l) {
        for (m=0;m<l;m++) {
            t=G_fn[G_lcalls[m]&0x3FFF].n;
            if ((G_lcalls[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("Called By\t%s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf(", %s",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".\n\n");
    }
    if (G_fn[index].nc) {
        for (m=0;m<G_fn[index].nc;m++) {
            t=G_fn[G_fn[index].c[m]&0x3FFF].n;
            if ((G_fn[index].c[m]&0x4000)!=0) {
                sprintf(tmp,"[%s]",t);
                t=tmp;
            }
            if (m==0) {
                printf("Calls\t%s",t);
                j=strlen(t)+19;
            }
            else {
                if ((j+strlen(t)+2)>78) {
                    printf(", %s",t);
                    j=strlen(t)+19;
                }
                else {
                    printf(", %s",t);
                    j+=strlen(t)+2;
                }
            }
        }
        printf(".\n\n");
    }
    k=0;
    for (i=0;i<G_numn;i++) {
        if ((G_fn[i].fn==G_fn[index].fn)&&(i!=index)) {
            if (!k) {
                printf("See Also\t%s",G_fn[i].n);
                j=strlen(G_fn[i].n)+19;
            }
            else {
                if ((j+strlen(G_fn[i].n)+2)>78) {
                    printf(", %s",G_fn[i].n);
                    j=strlen(G_fn[i].n)+19;
                }
                else {
                    printf(", %s",G_fn[i].n);
                    j+=strlen(G_fn[i].n)+2;
                }
            }
            k++;
        }
    }
    if (k) printf(".\n");
    printf("\n%c\n",12);
}
// Return a key press +tive if normal key -tive if extended key
int getkey(void)
{
	int k;
	if (!(k=getch())) k=0-getch();
	return(k);
}
// display a pick list of functions for selection
void disppick(int w,int idx)
{
	int i,j;
	int ni=(80/w)*24;
	int ofs;
	int attr;

	if (idx>G_numn) idx=G_numn-1;
	if (idx>=ni) ofs=idx-(ni-1); else ofs=0;

	for (i=0;i<80;i+=w) {
		for (j=0;j<24;j++) {
			if (ofs==idx) attr=0x10; else attr=0;
			if (G_fn[ofs].ac) textattr(15|attr); else textattr(12|attr);
			gotoxy(i+1,j+1);
			cprintf("%-*.*s",w,w,((ofs<G_numn)?G_fn[ofs].n:""));
			ofs++;
		}
	}
}
// Return true if a function has been commented
int arecomments(char *file,char *func)
{
	FILE *fp;
	char tmp[100];
    if ((file==NULL)||(*file==0)||(func==NULL)||(*func==0)) return(0);

	fp=fopen(file,"r");
	if (fp==NULL) return(0);

	while (fgets(tmp,80,fp)!=NULL) {
		if (tmp[0]=='F') {
			if (!strncmp(func,&tmp[2],strlen(func))) {
				fclose(fp);
				return(1);
			}
		}
	}

	fclose(fp);
	return(0);
}
// Return true if a function has been commented and collect those comments
int getcomments(char *file,int idx)
{
	FILE *fp;
	int f;
	char *func=G_fn[idx].n;
	char tmp[100];
	
	G_retln[0]=0;
	for (f=0;f<20;f++) G_passln[f][0]=0;
	for (f=0;f<30;f++) G_descln[f][0]=0;
	G_np=0;
	G_nd=0;
    
	if ((strcmp(file,GLOBCOMFILE))&&(!G_fn[idx].ac)) return(0);
	fp=fopen(file,"r");
	if (fp==NULL) return(0);

	f=0;
	while (fgets(tmp,80,fp)!=NULL) {
		if (!f) {
			if (tmp[0]=='F') {
				if (!strncmp(func,&tmp[2],strlen(func))) f=1;
			}
		} else {
			switch (tmp[0]) {
				case 'R' :
					tmp[strlen(tmp)-1]=0;
					sprintf(G_retln," - %s",&tmp[2]);
					break;
				case 'P' :
					tmp[strlen(tmp)-1]=0;
					sprintf(G_passln[G_np++]," - %s",&tmp[2]);
					break;
				case 'D' :
					tmp[strlen(tmp)-1]=0;
					sprintf(G_descln[G_nd++],"%s",&tmp[2]);
					break;
				case 'S' :
					tmp[strlen(tmp)-1]=0;
                    tmp[0]='\/';
                    tmp[1]='\/';
                    if (G_fn[idx].s!=NULL) free(G_fn[idx].s);
                    G_fn[idx].s=strdup(tmp);
					break;
				default :
					fclose(fp);
					return(f);
			}
		}
	}
	fclose(fp);
	return(f);
}
// Edit the function comments
void editfunc(int index)
{
    char tmp[40],ret[40],name[40],prot[150],dfile[15],*t;
    int i=0,j=0,k=0,l=0,m;

	if (G_ftname[G_fn[index].fn]!=NULL) {
		strcpy(dfile,G_ftname[G_fn[index].fn]);
	} else {
		strcpy(dfile,"None");
	}
	l=getcomments(dfile,index);
    sprintf(prot,"%s;",G_fn[index].p);
    strcpy(name,G_fn[index].n);
    strcpy(G_lstr,G_fn[index].s);

    t=strstr(prot,name);
    memcpy(ret,prot,(int)(t-prot));
    ret[(int)(t-prot)]=0;

    if ((ret[0]==' ')||(ret[0]==0)) {
        sprintf(prot,"int %s;",G_fn[index].p);
        strcpy(ret,"int");
    }
    t=&ret[strlen(ret)-1];
    while (isspace(*t)) t--;
    *(t+1)=0;
	textattr(0x0F);
	clrscr();
	gotoxy(1,1);
    cprintf("Function:     %-s",name);
	gotoxy(1,2);
    cprintf("Synopsys:     ");
	textattr(0x1E);
    if ((G_lstr[0]=='/')&&(G_lstr[1]=='/')) {
        t=&G_lstr[2];
        while ((*t)&&isspace(*t)) t++;
	    cprintf("%-66.66s",t);
    }
    else {
	    cprintf("%-66.66s","");
    }
	textattr(0x0F);
	gotoxy(1,3);
    cprintf("Prototype:    %s",prot);
	gotoxy(1,4);
    cprintf("Module:       %s (Comments in - %s %d)",G_fname[G_fn[index].fn],dfile,l);
    G_str=strstr(prot,name);
    G_str+=strlen(name);
	i=0;
	j=strlen(ret);
    while ((*G_str)&&(*G_str!=')')) {
        if (isspace(*G_str)||(*G_str=='(')||(*G_str==',')) {
            G_str++;
        } else {
            t=tmp;
            while ((*G_str)&&(*G_str!=')')&&(*G_str!=',')) *(t++)=*(G_str++);
            *t=0;
            t--;
            while (isspace(*t)) t--;
            *(t+1)=0;
            if (strcmp(tmp,"void")) {
				gotoxy(1,i+5);
				textattr(0x0F);
                cprintf("%s%-s",((i==0)?"Passed:       ":"              "),tmp);
				j=max(j,strlen(tmp));
                i++;
            }
        }
    }
	textattr(0x1E);
	for (k=0;k<i;k++) {
		gotoxy(16+j,k+5);
		cprintf("%-*.*s",65-j,65-j,G_passln[k]);
	}
	gotoxy(1,i+5);
	textattr(0x0F);
    if (strcmp(ret,"void")) {
	    cprintf("Return Value: %-s ",ret);
		textattr(0x1E);
		gotoxy(16+j,i+5);
		cprintf("%-*.*s",65-j,65-j,G_retln);
    }
    else {
        printf("Return Value: None");
    }
	textattr(0x0F);
	gotoxy(1,i+7);
    cprintf("Description:  ");
	textattr(0x1E);
	gotoxy(1,i+8);
	m=24-(i+8);
	if (m>10) m=10;
	for (k=0;k<m;k++) cprintf("%-80.80s",G_descln[k]);
	getch();
	textattr(0x0F);
	clrscr();
}
// select a function from a list and edit it
void editcoms(void)
{
    int i,xit=0;
	clrscr();
	i=0;
	while (!xit) {
		disppick(20,i);
		switch (getkey()) {
			case ESC :
				xit=1;
				break;
			case UP :
				if (i>0) i--;
				break;
			case DOWN :
				if (i<G_numn-1) i++;
				break;
			case RGT :
				i+=24;
				if (i>G_numn-1) i%=24;
				break;
			case LEFT :
				i-=24;
				if (i<0) i=G_numn+i;
				if (i>G_numn-1) i=G_numn-1;
				break;
			case CR :
			case LF :
				editfunc(i);
				clrscr();
				break;
		}
	}
	textattr(0x07);
	clrscr();
}
// Compare two functions for sorting
int fcmp(const void *a,const void *b)
{
    char tmpa[80];
    char tmpb[80];
    strcpy(tmpa,((FUNCDATA *)a)->n);
    strupr(tmpa);
    strcpy(tmpb,((FUNCDATA *)b)->n);
    strupr(tmpb);
    return(strcmp(tmpa,tmpb));
}
// recursively draw sub tree structures
void subtree(int idx,int d,int l)
{
    int i,j;
	static int ms=0;
    static char map[80];
	if (!ms) {
		memset(map,0,80);
		ms=1;
	}
    if (d>=80) return;
    if (l) map[d]=0; else map[d]=1;
    for (j=0;j<d;j++) printf("%c  ",((map[j])?'บ':' '));
    if (d) {
        if (l) printf("ศออ"); else printf("ฬออ");
    } else {
        printf("   ");
    }
    printf("%s\n",G_fn[idx&0x3FFF].n);
    if (G_fn[idx&0x3FFF].sl==(-1)) return;
    G_fn[idx&0x3FFF].sl=(-1);
    for (i=0;i<G_fn[idx&0x3FFF].nc;i++) 
        subtree(G_fn[idx&0x3FFF].c[i],d+1,i==(G_fn[idx&0x3FFF].nc-1));
}
// print a tree structure
void prtree(void)
{
    int i,j,k,l;
    if (G_function[0]==0) {
        for (i=0;i<G_numn;i++) {
            if (!strcmp(G_fn[i].n,"main")) {
                subtree(i,0,1);
                i=G_numn;
            }
        }
        for (i=0;i<G_numn;i++) {
            if (G_fn[i].sl!=(-1)) {
                l=0;
                for (j=0;j<G_numn;j++) {
                    for (k=0;k<G_fn[j].nc;k++) {
                        if ((G_fn[j].c[k]&0x3FFF)==i) {
                            l++;
                        }
                    }
                }
                if (!l) subtree(i,0,1);
            }
        }
    }
    else {
        for (i=0;i<G_numn;i++) {
            if (!strcmp(G_fn[i].n,G_function)) {
                subtree(i,0,1);
                i=G_numn;
            }
        }
    }
}
// Document System - "DOCU file(s)"  Exmpl. - SYSDOC *.c, SYSDOC @file.lst
int main(int argc,char *argv[])
{
    int i,j,k,e,nl,rl;
    int an=1;
    char otype='n';
    char sort='s';
    FILE *fp;
    char filename[100];
    char *dir;                                      /* holding string       */
    char *file;                                     /* holding string       */
    char ret[40];
    char *t;
    G_function[0]=0;
    if ((G_fn=malloc(NUMFUNC*sizeof(FUNCDATA)))==NULL) {
        fprintf(stderr,"Not Enough Memory\n");
        return(1);
    }

    for (i=0;i<NUMFUNC;i++) G_fn[i].fn=0;
    for (i=0;i<100;i++) G_ftname[i]=NULL;

    fprintf(stderr,"'C' System Documentation generator Copyright (c) 1993 Cykor Systems.\n");
    if (argc<2) {
        fprintf(stderr,"docu [-u|w|b|n|N|p|P|e|E|t|x|s,s|u] file [function]\n");
        fprintf(stderr,"options:  -u   Programmers manual Unix style (Text)\n");
        fprintf(stderr,"          -w   Programmers manual Unix style (WP)\n");
        fprintf(stderr,"          -b   Programmers manual boxed pages\n");
        fprintf(stderr," default  -n   list function names\n");
        fprintf(stderr,"          -N   list function Names by module\n");
        fprintf(stderr,"          -p   list function prototypes\n");
        fprintf(stderr,"          -P   list function prototypes spaced\n");
        fprintf(stderr,"          -e   list function prototypes spaced with externs\n");
        fprintf(stderr,"          -E   Edit comments\n");
        fprintf(stderr,"          -x   function x-reference\n");
        fprintf(stderr,"          -t   function tree\n");
        fprintf(stderr,"          -ssfile save sorted in 'file'\n");
        fprintf(stderr,"          -sufile save unsorted in 'file'\n");
        fprintf(stderr," default  -*s  sort by function name\n");
        fprintf(stderr,"          -*u  don't sort by function name\n");
        fprintf(stderr,"file:     @filename - list file\n");
        fprintf(stderr,"          #filename - saved file\n");
        fprintf(stderr,"          *.c ???.c - wild card matching\n");
        fprintf(stderr,"          file.c    - single file\n");
        fprintf(stderr,"function: generate documentation for one function\n");
        fprintf(stderr,"Generates documentation on stdout, all other output goes through stderr");
        return(1);
    }
    if (argv[an][0]=='-') {
        otype=argv[an][1];
        if (strlen(argv[an])>2) sort=argv[an][2];
        an++;
    }
    if (argc==(an+2)) strcpy(G_function,argv[an+1]);
    G_recurse=0;
    if (argv[an][0]=='#') {
		load(&argv[an][1]);
	} else {
        unlink(GLOBCOMFILE);
    	if (argv[an][0]=='@') {
        	fp=fopen(&argv[an][1],"r");
        	if (fp==NULL) {
            	fprintf(stderr,"Can't Open %s\n",&argv[an][1]);
            	return(1);
        	}
        	while (fgets(filename,99,fp)!=NULL) {
            	filename[strlen(filename)-1]=0;
            	if ((filename[0]!=0)&&(filename[0]!=' ')) funcfind(filename);
        	}
        	fclose(fp);
    	}
    	else {
        	dir=malloc(strlen(argv[an])+2);                  /* get space for path */
        	file=malloc(strlen(argv[an])+2);                 /* get space for file */

        	for (i=strlen(argv[an])-1;i>=0;i--) {
            	if (argv[an][i]=='\\') {
                	strcpy(dir,argv[an]);
                	strcpy(file,&argv[an][i+1]);
                	dir[i+1]=0;
                	break;
            	}
        	}
        	if (i==(-1)) {
            	strcpy(file,argv[an]);
            	strcpy(dir,".\\");
        	}
        	strupr(dir);                                    /* change to uppercase  */
        	strupr(file);                                   /* change to uppercase  */

        	getfiles(dir,file,0);                           /* do the work          */

        	free(dir);
        	free(file);
    	}
        if ((comfile!=NULL)&&(comfile!=stdout)) {
            fclose(comfile);
        }
        if (otype=='c') return(0);
    	if (sort=='s') qsort(G_fn,G_numn,sizeof(FUNCDATA),fcmp);

    	fprintf(stderr,"\n");
        cmap();
    	fprintf(stderr,"\n");
	}
    fprintf(stderr,"\n%d Function%sfound in %d file%c\n",G_numn,(G_numn==1?" ":"s "),G_numf,(G_numf==1?' ':'s'));

    switch (otype) {
        case 'b':
            for (i=0;i<G_numn;i++) prpage(i);
            break;
        case 'n':
            for (i=0;i<G_numn;i++) printf("%s\n",G_fn[i].n);
            break;
        case 'N':
            nl=0;
            rl=0;
            for (i=0;i<G_numn;i++) {
                nl=max(nl,strlen(G_fn[i].n));
                t=strstr(G_fn[i].p,G_fn[i].n);
                rl=max(rl,(int)(t-G_fn[i].p));
            }
			for (j=0;j<G_numf;j++) {
            	printf("%s\n",G_fname[j]);
            	for (i=0;i<G_numn;i++) {
					if (G_fn[i].fn==j) {
                		t=strstr(G_fn[i].p,G_fn[i].n);
                		memcpy(ret,G_fn[i].p,(int)(t-G_fn[i].p));
                		ret[(int)(t-G_fn[i].p)]=0;
                		t=G_fn[i].p;
                		while ((*t)&&(*t!='(')) t++;
                		printf(" %-*.*s %-*.*s %-s;\n",rl,rl,ret,nl,nl,G_fn[i].n,t);
					}
            	}
            	printf("\n");
			}
            break;
        case 'p':
            for (i=0;i<G_numn;i++) printf("%s\n",G_fn[i].p);
            break;
        case 'P':
            nl=0;
            rl=0;
            for (i=0;i<G_numn;i++) {
                nl=max(nl,strlen(G_fn[i].n));
                t=strstr(G_fn[i].p,G_fn[i].n);
                rl=max(rl,(int)(t-G_fn[i].p));
            }
            for (i=0;i<G_numn;i++) {
                t=strstr(G_fn[i].p,G_fn[i].n);
                memcpy(ret,G_fn[i].p,(int)(t-G_fn[i].p));
                ret[(int)(t-G_fn[i].p)]=0;
                t=G_fn[i].p;
                while ((*t)&&(*t!='(')) t++;
                printf("%-*.*s %-*.*s %-s;\n",rl,rl,ret,nl,nl,G_fn[i].n,t);
            }
            break;
        case 'e':
            nl=0;
            rl=0;
            for (i=0;i<G_numn;i++) {
                nl=max(nl,strlen(G_fn[i].n));
                t=strstr(G_fn[i].p,G_fn[i].n);
                rl=max(rl,(int)(t-G_fn[i].p));
            }

            for (i=0;i<G_numn;i++) {
                e=0;
                for (j=0;j<G_numn;j++) {
                    for (k=0;k<G_fn[j].nc;k++) {
                        if ((G_fn[j].c[k]&0x3FFF)==i) {
                            if (G_fn[j].fn!=G_fn[i].fn) e=1;
                        }
                    }
                }
                t=strstr(G_fn[i].p,G_fn[i].n);
                memcpy(ret,G_fn[i].p,(int)(t-G_fn[i].p));
                ret[(int)(t-G_fn[i].p)]=0;
                t=G_fn[i].p;
                while ((*t)&&(*t!='(')) t++;
                printf("%s ",(e?"extern":"      "));
                printf("%-*.*s %-*.*s %-s;\n",rl,rl,ret,nl,nl,G_fn[i].n,t);
            }
            break;
        case 'x':
            t=malloc(G_numn);
            nl=0;
            for (i=0;i<G_numn;i++) nl=max(nl,strlen(G_fn[i].n));

            printf("ษ"); for (i=0;i<nl;i++) printf("อ"); printf("ห"); for (i=0;i<G_numn;i++) printf("ออ"); printf("ป\n");
            for (j=0;j<nl;j++) {
                printf("บ%*.*sบ",nl,nl,"");
                for (i=0;i<G_numn;i++) {
                    if (strlen(G_fn[i].n)>j) {
                        printf("%c ",G_fn[i].n[j]);
                    } else {
                        printf("  ");
                    }
                }
                printf("บ\n");
            }
            printf("ฬ"); for (i=0;i<nl;i++) printf("อ"); printf("ฮ"); for (i=0;i<G_numn;i++) printf("ออ"); printf("น\n");
            for (i=0;i<G_numn;i++) {
                printf("บ%-*.*sบ",nl,nl,G_fn[i].n);
                for (j=0;j<G_numn;j++) {
                    t[j]='๚';
                    for (k=0;k<G_fn[j].nc;k++) {
                        if ((G_fn[j].c[k]&0x3FFF)==i) t[j]='Û';
                    }
                }
                for (j=0;j<G_numn;j++) printf("%c ",t[j]);
                printf("บ\n");
            }
            printf("ศ"); for (i=0;i<nl;i++) printf("อ"); printf("ส"); for (i=0;i<G_numn;i++) printf("ออ"); printf("ผ\n");
            free(t);
            break;
        case 'E':
			editcoms();
            break;
        case 't':
            prtree();
            break;
        case 'w':
            printf("\n");
            for (i=0;i<G_numn;i++) prpagewp(i);
            break;
        case 's':
			printf("Saving %s\n",&argv[1][3]);
			save(&argv[1][3]);
            break;
        default :
            for (i=0;i<G_numn;i++) prpagen(i);
    }

    for (i=0;i<G_numn;i++) {
        free(G_fn[i].p);
        free(G_fn[i].n);
        free(G_fn[i].s);
        free(G_fn[i].m);
        if (G_fn[i].nc) free(G_fn[i].c);
    }
    G_numn=0;

    for (i=0;i<G_numf;i++) free(G_fname[i]);
    for (i=0;i<G_numf;i++) if (G_ftname[i]!=NULL) free(G_ftname[i]);
    G_numf=0;

    return(0);                                      /* return OK            */
}

