#include <dos.h>
#include <conio.h>
#include <ctype.h>
#include <alloc.h>
#include <string.h>
#include <search.h>
#include <dir.h>
#include <stdio.h>

#define FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR     FA_DIREC

int G_recurse=0;

char *G_ctypes[]={
    "char","int","short","long","float","double","unsigned","*","const","interrupt","extern","far","near","static","signed","struct","union","void","#"
};

char *G_cnames[]={
    "+","-","/","%",">",">=","<","<=","==","!=","++","--","&","|","^","<<",
    ">>","~","=","+=","-=","*=","/=","%=","&=","|=","^=","<<=",">>=",
    "?",":","!","[","]","->","{","}","sizeof","//","/*",
    "if","else","switch","case","default","break","do","while","return",
    "new","delete","asm","auto","cdecl","typedef",
    "for","volatile","class","enum","#"
};
#define NUMFUNC 1000
typedef struct {
    char  *n;       // name
    char  *p;       // prototype
    char  *s;       // synopsys
    int   *c;       // calls (func number | 0x4000*external)
    int   nc;       // number of calls
    char  *m;       // modified globals
    int   fn;       // file number
    int   sl;       // start line number
    int   el;       // end line number
} FUNCDATA;

FUNCDATA G_fn[NUMFUNC];

char *G_str;
char *G_fname[100];
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
    while (*s) {
        if (*s=='{') ret++;
        if (*s=='}') ret--;
        s++;
    }
    return(ret);
}
// Strip the leading space from G_str
void stripspace(void)
{
    while ((*G_str)&&isspace(*G_str)) G_str++;
}
// print the function name
void printfunc(char *str)
{
    G_str=str;
    stripspace();
    printf("%s;\n",G_str);
}
// Save the local variable information
void printvar(char *str)
{
    char tmp[120];
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
            memcpy(G_lvars[G_numlvars],a,s-a);
            G_lvars[G_numlvars++][s-a]=0;
        }
        s=strtok(NULL,",;*");
    }
}
// Save the Global variable modification information
void printmod(char *str)
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
    memcpy(G_mvars[G_nummvars],s,G_str-s);
    G_mvars[G_nummvars][G_str-s]=0;
    for (i=0;i<G_nummvars;i++) {
        if (!strcmp(G_mvars[G_nummvars],G_mvars[i])) return;
    }
    G_nummvars++;
}
// Remove all 'C' comments from a line
char *remcom(char *g)
{
    int xit=0;
    static char tmp[256];               // dwfdsf 
    char *p;                                   /* local strings        */
    p=tmp;

    while ((*g)&&isspace(*g)) g++;

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
    char r[256];
    char sname[80],*t;
    int i,lc=0,cc,in;
    int v=0;
    int infunc=0;
    int curly=0;
    fpos_t fpos1,fpos2,rto;


    G_lstr[0]=0;

    fp=fopen(name,"r");
    if (fp==NULL) {
        fprintf(stderr,"Can't open %-15s               \r",name);
        return;
    }
//    fprintf(stderr,"Building Function list from %-15s :\r",name);
    if ((name[0]=='.')&&(name[1]=='\\')) 
        G_fname[G_numf++]=strdup(&name[2]);
    else 
        G_fname[G_numf++]=strdup(name);

    while (fgets(G_rstr,255,fp)!=NULL) {
        G_rstr[strlen(G_rstr)-1]=0;
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
                    G_str=G_rstr;
                    while ((*G_str)&&isspace(*G_str)) G_str++;
                    clrscr();
                    fgetpos(fp,&rto);
                    fsetpos(fp,&fpos2);
                    cc=0;
                    in=1;
                    for (i=0;i<25;i++) {
                        gotoxy(1,i+1);
                        fgets(sname,80,fp);
                        sname[strlen(sname)-1]=0;
                        if ((i>0)&&(in)) {
                            cc+=cntcurly(sname);
                            if (cc==1) in=2;
                            if ((in==2)&&(!cc)) {
                                in=0;
                                cprintf("%s",sname);
                            }
                        }
                        if (in) {
                            cprintf("%s",sname);
                        }
                    }
                    getch();
                    fsetpos(fp,&rto);
                    G_fn[G_numn].p=strdup(G_str);
                    G_fn[G_numn].s=strdup(G_lstr);
                    G_fn[G_numn].n=strdup(getfname(G_str));
                    G_fn[G_numn].fn=G_numf-1;
                    G_fn[G_numn].sl=lc;
                    if (G_fn[G_numn].n!=NULL) G_numn++;
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
                        printvar(G_rstr);
                    }
                }
                G_str=G_rstr;
                if (!iscword()) {
                    while (isvalword());
                    if ((*G_str)&&(*G_str!='(')&&(!v)) {
                        printmod(G_rstr);
                    }
                }
            }
        }
        lc++;
        memcpy(&fpos2,&fpos1,sizeof(fpos_t));
        fgetpos(fp,&fpos1);
        if (G_rstr[0]!=0)
            strcpy(G_lstr,G_rstr);
        else
            strcpy(G_lstr,"--");
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
// Returns true if a line contains a known function
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
            t+=strlen(G_fn[i].n);
            if ((!isalnum(*t))&&(*t!='_')) return(i++);
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
//            fprintf(stderr,"Analysing functions in %-15s :\r",G_fname[i]);
            lc=0;
            while (fgets(str,255,fp)!=NULL) {
                if ((str[0]!='#')&&(str[0]!='/')) {
                    str[strlen(str)-1]=0;
                    for (j=0;j<G_numn;j++) {
                        if (findfuncln(j,i,lc)) {
                            numc=0;
                            while ((lc<G_fn[j].el)&&(fgets(str,255,fp)!=NULL)) {
                                if ((str[0]!='#')&&(str[0]!='/')) {
                                    str[strlen(str)-1]=0;
                                    while ((fnum=contfunc(str))!=(-1)) {
                                        for (k=0;k<numc;k++) {
                                            if ((calls[k]&0x3FFF)==fnum) k=2000;
                                        }
                                        if (k<2000) {
                                            calls[numc++]=fnum;
                                            if (G_fn[fnum].fn!=i) calls[numc-1]|=0x4000;
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
// Print one page of output on stdout.
void prpage(int index)
{
    char tmp[40];
    char ret[40];
    char name[40];
    char prot[150];
    char *t;
    int i=0;
    int j=0;
    int k=0;
    int l,m;

    sprintf(prot,"%s;",G_fn[index].p);
    strcpy(name,G_fn[index].n);
    strcpy(G_lstr,G_fn[index].s);

    if ((G_function[0]!=0)&&(strcmp(G_function,name))) return;

    t=strstr(prot,name);
    memcpy(ret,prot,t-prot);
    ret[t-prot]=0;

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
    prline("Description",name," ",' ');
    printf("บ              บ                                                              บ\n");
    printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
    G_str=strstr(prot,name);
    G_str+=strlen(name);
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
                printf("บ       %s บ %-60.60s บ\n",((i==0)?"Passed":"      "),tmp);
                i++;
            }
        }
    }
    if (i) printf("ฬออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน\n");
    if (strcmp(ret,"void")) {
        printf("บ Return Value บ %-60.60s บ\n",ret);
    }
    else {
        printf("บ Return Value บ None.                                                        บ\n");
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
// Compare two functions for sorting
int fcmp(const void *a,const void *b)
{
    return(strcmp(((FUNCDATA *)a)->n,((FUNCDATA *)b)->n));
}
// Document System - "SYSDOC file(s)"  Exmpl. - SYSDOC *.c, SYSDOC @file.lst
int main(int argc,char *argv[])
{
    int i;
    FILE *fp;
    char filename[16];
    char *dir;                                      /* holding string       */
    char *file;                                     /* holding string       */

    for (i=0;i<NUMFUNC;i++) G_fn[i].fn=0;

    if (argc<2) return(1);                          /* no parameters FAIL   */
    if (argc==3) strcpy(G_function,argv[2]);
    G_recurse=0;
    if (argv[1][0]=='@') {
        fp=fopen(&argv[1][1],"r");
        if (fp==NULL) {
            fprintf(stderr,"Can't Open %s\n",&argv[1][1]);
            return(1);
        }
        while (fgets(filename,15,fp)!=NULL) {
            filename[strlen(filename)-1]=0;
            if ((filename[0]!=0)&&(filename[0]!=' ')) funcfind(filename);
        }
        fclose(fp);
    }
    else {
        dir=malloc(strlen(argv[1])+2);                  /* get space for path */
        file=malloc(strlen(argv[1])+2);                 /* get space for file */

        for (i=strlen(argv[1])-1;i>=0;i--) {
            if (argv[1][i]=='\\') {
                strcpy(dir,argv[1]);
                strcpy(file,&argv[1][i+1]);
                dir[i+1]=0;
                break;
            }
        }
        if (i==(-1)) {
            strcpy(file,argv[1]);
            strcpy(dir,".\\");
        }
        strupr(dir);                                    /* change to uppercase  */
        strupr(file);                                   /* change to uppercase  */

        getfiles(dir,file,0);                           /* do the work          */

        free(dir);
        free(file);
    }
//    qsort(G_fn,G_numn,sizeof(FUNCDATA),fcmp);

//    fprintf(stderr,"\n");
//    cmap();
//    fprintf(stderr,"\n");

//    fprintf(stderr,"\n%d Functions found in %d files\n",G_numn,G_numf);


//    for (i=0;i<G_numn;i++) prpage(i);
    for (i=0;i<G_numn;i++) {
        free(G_fn[i].p);
        free(G_fn[i].n);
        free(G_fn[i].s);
        free(G_fn[i].m);
//        if (G_fn[i].nc) free(G_fn[i].c);
    }
    G_numn=0;

    for (i=0;i<G_numf;i++) free(G_fname[i]);
    G_numf=0;

    return(0);                                      /* return OK            */
}
