#ifndef TESTING
#include <windows.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "types.h"
#include "interp.h"
#include "deballoc.h"

#define isident(a) ((G_chartab[a]==IDENT)||((G_chartab[a]==NUMBT)&&(a!='.')))
#define etype(a,b,c) (c->structs[a].elements[b].type)
#define ename(a,b,c) (c->structs[a].elements[b].name)
#define sname(a,c)   (c->structs[a].name)
#define numelem(a,c) (c->structs[a].numbelem)

typedef struct FCS {
    CHAR *f;
    CHAR *n;
    CHAR *s;
    CHAR *r;
    int np;
    CHAR *p[50];
    int nd;
    CHAR *d[50];
    LONG sl;
    LONG el;
    CHAR **l;
    CHAR *c;
    CHAR *u;
    struct FCS *next;
} FCSTRUCT;

CHAR *G_incpath="e:\\bc45\\include\\";
INT  G_inclevel=0;
INT  G_allow=1;
INT  G_includeblk[40];
BOOL G_setup=FALSE;
DSTRUCT *G_clib=NULL;
FCSTRUCT *G_fs=NULL;

INT loadfile(CHAR *name,DSTRUCT **ds);

void extract_tokens(CHAR *l,CHAR **lines)
{
    CHAR *curpos=l;        // current position in line
    CHAR *line;
    INT curline=0;

    line=lines[curline];
    *line=0;
    while (*curpos) {
        while (G_chartab[*curpos]==BLANK) curpos++;
        switch (G_chartab[*curpos]) {
            case 0 :
                break;
            case NUMBT :
                if ((*curpos=='0')&&((*(curpos+1)=='x')||(*(curpos+1)=='X'))) {
                    while ( (G_chartab[*curpos]==NUMBT)
                        ||  ((*curpos>='A')&&(*curpos<='F'))
                        ||  ((*curpos>='a')&&(*curpos<='f'))
                        ||  ((*curpos=='x')||(*curpos=='x')) ) {
                        *(line++)=*(curpos++);
                    }
                } else {
                    while (G_chartab[*curpos]==NUMBT) *(line++)=*(curpos++);
                }
                if ((*curpos=='U')||(*curpos=='L')) *(line++)=*(curpos++);
                break;
            case IDENT    :
                while (isident(*curpos)) *(line++)=*(curpos++);
                break;
            case ARITH    :
                if ((*curpos=='-')&&(*(curpos+1)=='>')) {
                    *(line++)=*(curpos++);
                    *(line++)=*(curpos++);
                } else {
                    while (G_chartab[*curpos]==ARITH) *(line++)=*(curpos++);
                }
                if ((*curpos=='=')&&(G_chartab[*(curpos-1)]==ARITH)) {
                    *(line++)=*(curpos++);
                }
                break;
            case BOOLT    :
                while (G_chartab[*curpos]==BOOLT) *(line++)=*(curpos++);
                if ((*curpos=='=')&&(G_chartab[*(curpos-1)]==BOOLT)) {
                    *(line++)=*(curpos++);
                }
                break;
            default       :
                if ((*curpos=='=')&&(*(curpos+1)=='=')) {
                    *(line++)=*(curpos++);
                    *(line++)=*(curpos++);
                } else if (*curpos=='"') {
                    *(line++)=*(curpos++);
                    while ((*curpos)&&(*curpos!='"')) {
                        if ((*curpos=='\\')) *(line++)=*(curpos++);
                        *(line++)=*(curpos++);
                    }
                    *(line++)=*(curpos++);
                } else if (*curpos=='\'') {
                    *(line++)=*(curpos++);
                    while ((*curpos)&&(*curpos!='\'')) {
                        if ((*curpos=='\\')) *(line++)=*(curpos++);
                        *(line++)=*(curpos++);
                    }
                    *(line++)=*(curpos++);
                } else {
                    *(line++)=*(curpos++);
                }
        }
        *line=0;
        curline++;
        line=lines[curline];
    }
    *line=0;
}

void rem_dtype(CHAR *name,DSTRUCT **ds)
{
    DSTRUCT *curds;
    DSTRUCT *tmp;

    curds=*ds;
    tmp=NULL;
    while (curds!=NULL) {
        if (!strcmp(curds->name,name)) {
            if (tmp==NULL) {
                tmp=curds;
                *ds=curds->next;
            } else {
                tmp->next=curds->next;
                tmp=curds;
            }
            FREE(tmp->name);
            FREE(tmp->value);
            FREE(tmp);
            return;
        }
        tmp=curds;
        curds=curds->next;
    }
}
//F add_dtype
//S add a new datatype to the list in ds
void add_dtype(CHAR *name,CHAR *value,DSTRUCT **ds)
{
    DSTRUCT *tmp;

    if ((tmp=MALLOC(sizeof(DSTRUCT)))==NULL) return;
    tmp->name=STRDUP(name);
    tmp->value=STRDUP(value);
    tmp->next=*ds;
    *ds=tmp;
}
DSTRUCT *append_dtype(CHAR *name,CHAR *value,DSTRUCT **ds)
{
    DSTRUCT *tmp;
    DSTRUCT *tmpds;

    if ((tmp=MALLOC(sizeof(DSTRUCT)))==NULL) return NULL;
    tmp->name=STRDUP(name);
    tmp->value=STRDUP(value);
    tmp->next=NULL;
    if (*ds==NULL) {
        *ds=tmp;
    } else {
        tmpds=*ds;
        while (tmpds->next!=NULL) tmpds=tmpds->next;
        tmpds->next=tmp;
    }
    return(tmp);
}
CHAR *find_dtype(CHAR *name,DSTRUCT *ds)
{
    while (ds!=NULL) {
        if (!strcmp(ds->name,name)) return ds->value;
        ds=ds->next;
    }
    return NULL;
}
void emptyds(DSTRUCT **ds)
{
    DSTRUCT *tmp;

    while (*ds!=NULL) {
        tmp=*ds;
        *ds=(*ds)->next;
        if (tmp->name!=NULL) FREE(tmp->name);
        if (tmp->value!=NULL) FREE(tmp->value);
        FREE(tmp);
    }
}
CHAR *ret_dname(INT idx,DSTRUCT *ds)
{
    int i=0;
    while (ds!=NULL) {
        if (i==idx) return(ds->name);
        ds=ds->next;
        i++;
    }
    return(" ");
}
void add_call(CHAR *name,DSTRUCT **ds,DSTRUCT *defs,DSTRUCT *pvars,DSTRUCT *lvars,CHAR *nexttok)
{
    DSTRUCT *tmp;
    CHAR *t;
    tmp=*ds;
    t=name;

    while ((*t)&&(G_chartab[*t]==NUMBT)) t++;
    if (!*t) return;

    if (find_dtype(name,G_clib)!=NULL) return;
    if (find_dtype(name,pvars)!=NULL) return;
    if (find_dtype(name,lvars)!=NULL) return;
    if (find_dtype(name,defs)!=NULL) return;

    while (tmp!=NULL) {
        if (!strcmp(tmp->name,name)) return;
        tmp=tmp->next;
    }

    if ((tmp=MALLOC(sizeof(DSTRUCT)))==NULL) return;
    tmp->name=STRDUP(name);
    if (*nexttok=='(')
        tmp->value=STRDUP("F");
    else
        tmp->value=NULL;
    tmp->next=*ds;
    *ds=tmp;
}
void getfblk(DSTRUCT *ds,FCSTRUCT *f)
{
    char *tmp;
    while (ds!=NULL) {
        tmp=ds->name;
        while ((tmp[strlen(tmp)-1]=='\r')||(tmp[strlen(tmp)-1]=='\n')||(tmp[strlen(tmp)-1]==' '))
            tmp[strlen(tmp)-1]=0;
        if ((*tmp=='\/')&&(*(tmp+1)=='\/')&&(*(tmp+3)==' ')) {
            tmp+=2;
            switch (*tmp) {
                case 'S' :
                    f->s=STRDUP(tmp+2);
                    break;
                case 'R' :
                    f->r=STRDUP(tmp+2);
                    break;
                case 'P' :
                    f->p[f->np++]=STRDUP(tmp+2);
                    break;
                case 'D' :
                    f->d[f->nd++]=STRDUP(tmp+2);
                    break;
                default:
                    return;
            }
        } else {
            if ((*tmp) && memcmp(tmp,"\/\/",2) && memcmp(tmp,"\/\*",2))
                return;
        }
        ds=ds->next;
    }
}
void genoutput(CHAR *func,DSTRUCT *pv,DSTRUCT *fl,DSTRUCT *cl,DSTRUCT *ol,CHAR *filename,INT sl,INT el)
{
    INT i,j;
    CHAR *t,tmp;
    CHAR buf[255];
    DSTRUCT *tmpds;
    FCSTRUCT *f;

    if ((f=MALLOC(sizeof(FCSTRUCT)))==NULL) return;
    f->n=STRDUP(func);
    f->f=STRDUP(filename);
    f->s=NULL;
    f->r=NULL;
    f->nd=0;
    f->np=0;
    getfblk(ol,f);

    if (!f->nd) {
        f->nd=1;
        if (f->s!=NULL) {
            f->d[0]=STRDUP(f->s);
        } else {
            f->d[0]=STRDUP("None Available");
        }
    }
    if (f->s==NULL) {
        f->s=STRDUP("None Available");
    }

    if (f->np) {
        for (i=f->np-1;i>=0;i--) {
            sprintf(buf,"(%s) %s\n",ret_dname(i,pv),f->p[i]);
            FREE(f->p[i]);
            f->p[i]=STRDUP(buf);
        }
    }
    t=strstr(fl->name,func);
    if (t!=NULL) {
        t--;
        while (*t==' ') t--;
        t++;
        tmp=*t;
        *t=0;
        if (f->r!=NULL) {
            sprintf(buf,"(%s) %s",fl->name,f->r);
            FREE(f->r);
            f->r=STRDUP(buf);
        } else {
            f->r=STRDUP(fl->name);
        }
        *t=tmp;
    }
    f->sl=(LONG)sl;
    f->el=(LONG)el;

    i=(el-sl)+1;
    if ((f->l=MALLOC(sizeof(CHAR *)*i))==NULL) return;
    tmpds=fl;
    i=0;
    while (tmpds!=NULL) {
        f->l[i]=STRDUP(tmpds->name);
        i++;
        tmpds=tmpds->next;
    }

    tmpds=cl;
    i=j=10;
    while (tmpds!=NULL) {
        if (tmpds->value!=NULL) {
            i+=strlen(tmpds->name)+2;
        } else {
            j+=strlen(tmpds->name)+2;
        }
        tmpds=tmpds->next;
    }
    if ((f->c=MALLOC(i))==NULL) return;
    f->c[0]=0;
    if ((f->u=MALLOC(j))==NULL) return;
    f->u[0]=0;
    tmpds=cl;
    while (tmpds!=NULL) {
        sprintf(buf,"%s,",tmpds->name);
        if (tmpds->value!=NULL) {
            strcat(f->c,buf);
        } else {
            strcat(f->u,buf);
        }
        tmpds=tmpds->next;
    }
    f->next=G_fs;
    G_fs=f;
}
void check_line(CHAR **line,INT lineno,CHAR *filename,char *l,DSTRUCT *defs)
{
    static DSTRUCT *otherl=NULL;
    static DSTRUCT *funcl=NULL;
    static DSTRUCT *calll=NULL;
    static DSTRUCT *lvarl=NULL;
    static DSTRUCT *pvarl=NULL;
    static DSTRUCT *tmp=NULL;
    static CHAR *funcname=NULL;
    static INT ccount=0;
    static INT sl;
    static BOOL incom=FALSE;
    static BOOL intypedef=FALSE;
    static BOOL infunc=FALSE;
    static INT pcount=0;
    CHAR *token;                     // token pointer
    INT pos,i;                         // the token position
    BOOL ret=FALSE;
    BOOL hads=FALSE,hadc=FALSE,lastline=FALSE;

    if ((infunc)&&isident(line[0][0])&&(ccount==1)
    &&  (isident(line[1][0])||( (line[1][0]=='*')&&isident(line[2][0]) ))) {
        pos=0;
        token=line[pos++];
        while (*token) {
            switch (*token) {
                case '*':
                case ',':
                case ';':
                    break;
                case '[':
                    pos++;
                    break;
                case ']':
                    break;
                default :
                    add_dtype(token,"",&lvarl);
            }
            token=line[pos++];
        }
    }
    pos=0;
    token=line[pos++];
    while (*token) {
        if ((*token=='\/')&&(line[pos][0]=='\*')) {
            incom=TRUE;
        }
        if (!incom) {
            if ((*token=='\/')&&(line[pos][0]=='\/')) break;
            switch (*token) {
                case ';':
                    hads=TRUE;
                    if ((intypedef)&&(ccount==0)&&(pos>1)) {
                        add_dtype(line[pos-2],"",&G_clib);
                        intypedef=FALSE;
                    }
                    break;
                case '{':
                    ccount++;
                    hadc=TRUE;
                    break;
                case '}':
                    ccount--;
                    hadc=TRUE;
                    if ((infunc)&&(!ccount)) lastline=TRUE;
                    break;
                case '(':
                    if ((!pcount)&&(!ccount)&&(pos>1)) {
                        if (funcname!=NULL) FREE(funcname);
                        funcname=STRDUP(line[pos-2]);
                        emptyds(&funcl);
                        emptyds(&lvarl);
                        emptyds(&pvarl);
                    }
                    pcount++;
                    break;
                case ')':
                    pcount--;
                    if ((!pcount)&&(!ccount)) ret=TRUE;
                    break;
                default :
                    if (!strcmp(token,"typedef")) {
                        intypedef=1;
                    } else {
                        if (isident(*token)&&(G_chartab[*token]!=NUMBT)&&(infunc==TRUE)) {
                            if ((pos<2)||((strcmp(line[pos-2],"->"))&&(strcmp(line[pos-2],".")))) 
                                add_call(token,&calll,defs,pvarl,lvarl,line[pos]);
                        }
                    }
            }
        }
        if ((*token=='\*')&&(line[pos][0]=='\/')) {
            incom=FALSE;
        }
        token=line[pos++];
    }
    if ((ret)&&(hads)&&(!hadc)) {
        ret=FALSE;
    }
    if (ret) {
        infunc=TRUE;
        sl=lineno;
        pos=1;
        token=line[0];
        i=0;
        while (*token) {
            switch (*token) {
                case '(':
                    i=1;
                    break;
                case ')':
                case ',':
                    if ((i)&&(pos>1)) {
                        i=pos-2;
                        while (i>0 && (!isident(line[i][0])) && (G_chartab[line[i][0]]!=NUMBT)) i--;
                        add_dtype(line[i],"",&pvarl);
                    }
                    break;
            }
            token=line[pos++];
        }
    }
    if (infunc) {
        if (tmp==NULL) {
            tmp=append_dtype(l," ",&funcl);
        } else {
            tmp=append_dtype(l," ",&tmp);
        }
    } else {
        add_dtype(l," ",&otherl);
    }
    if (lastline) {
        infunc=FALSE;
        tmp=NULL;
        emptyds(&lvarl);
        genoutput(funcname,pvarl,funcl,calll,otherl,filename,sl,lineno);
        emptyds(&otherl);
        emptyds(&calll);
        emptyds(&funcl);
        emptyds(&pvarl);
        if (funcname!=NULL) FREE(funcname);
        funcname=NULL;
    }
}
//F parse_directive
//S parse a line of source that started with a '#'
//D parse a line of source that started with a '#'
//P The line
//P The source buffer structure being used
//P the current line in the file
//P the current filename
//R TRUE if the directive continues on the next line
BOOL parse_directive(CHAR **line,DSTRUCT **ds)
{
    CHAR tmpbuf[255];
    CHAR *token;                     // token pointer
    int pos;                         // the current token
    int i;

    token=line[1];
    if (G_allow) {
        if (!strcmp("include",token)) {  // include a file
            token=line[2];
            if (*token=='"') {
                token[strlen(token)-1]=0;
                loadfile(token+1,ds);
                return(FALSE);
            }
        } else if (!strcmp("define",token)) {   // define a data type
            pos=3;
            tmpbuf[0]=0;
            while (line[pos][0]!=0) strcat(tmpbuf,line[pos++]);
            add_dtype(line[2],tmpbuf,ds);
            return(FALSE);
        } else if (!strcmp("undef",token)) {   // define a data type
            rem_dtype(line[2],ds);
            return(FALSE);
        } else if (!strcmp("pragma",token)) {   // define a data type
            return(FALSE);
        } else if (!strcmp("inline",token)) {   // define a data type
            return(FALSE);
        }
    }

    if (!strcmp("endif",token)) {
        G_inclevel--;
        G_allow=1;
        for (i=1;i<=G_inclevel;i++) {
            if (G_includeblk[i]==0) {
                G_allow=0;
                break;
            }
        }
        return(FALSE);
    }
    if ((!strcmp("ifdef",token))||((!strcmp("if",token))&&(!strcmp("defined",line[2])))) {
        G_inclevel++;
        if (find_dtype(line[2],*ds)!=NULL) {
            G_includeblk[G_inclevel]=1;
        } else {
            G_includeblk[G_inclevel]=0;
        }
        G_allow=1;
        for (i=1;i<=G_inclevel;i++) {
            if (G_includeblk[i]==0) {
                G_allow=0;
                break;
            }
        }
        return(FALSE);
    }
    if (!strcmp("else",token)) {
        G_includeblk[G_inclevel]^=1;
        G_allow=1;
        for (i=1;i<=G_inclevel;i++) {
            if (G_includeblk[i]==0) {
                G_allow=0;
                break;
            }
        }
        return(FALSE);
    }
    if ((!strcmp("ifndef",token))||((!strcmp("if",token))&&(!strcmp("!",line[2]))&&(!strcmp("defined",line[3])))) {
        G_inclevel++;
        if (find_dtype(line[2],*ds)!=NULL) {
            G_includeblk[G_inclevel]=0;
        } else {
            G_includeblk[G_inclevel]=1;
        }
        G_allow=1;
        for (i=1;i<=G_inclevel;i++) {
            if (G_includeblk[i]==0) {
                G_allow=0;
                break;
            }
        }
        return(FALSE);
    }
    return(FALSE);
}
//============================================================================
//F save_line
//S Save a line of source code.
//D Save a line of source code.
//P The line
//P The source buffer structure to fill
void save_line(CHAR *l,INT lineno,CHAR *filename,DSTRUCT **ds,CHAR **line)
{
    if (*l==0) return;      // invalid line !

    extract_tokens(l,line);
    if (**line=='#') {      // compiler directive
        parse_directive(line,ds);
    } else {
        if (G_allow) check_line(line,lineno,filename,l,*ds);
    }
}
//============================================================================
//F loadfile
//S Load a source file into memory
//D Load a source file into memory and include all it's 
//D local include files i.e. #include "foobar.h".
//P The file name
//R TRUE if file can be opened for read and sb is a valid structure
INT loadfile(CHAR *name,DSTRUCT **ds)
{
    CHAR filename[80];                          // buffer for filename
    static DSTRUCT *fs=NULL;
    static CHAR line[LINESIZE+1];               // buffer for each line
    CHAR **linetoks;                            // buffer for line as tokens
    INT lineno;                                 // the current file line number
    FILE *fp;                                   // input file pointer
    int i;

    if ((name==NULL)||(*name==0)) {
        emptyds(&fs);
        return FALSE; // invalid file name !
    }

    if (find_dtype(name,fs)!=NULL) return TRUE;

    add_dtype(name,"",&fs);
    if ((fp=fopen(name,"r"))!=NULL) {           // if the file opens for read
        linetoks=MALLOC(80*sizeof(CHAR *));
        for (i=0;i<80;i++) linetoks[i]=MALLOC(LINESIZE+1);
        strcpy(filename,name);
        lineno=1;
        while (fgets(line,LINESIZE,fp)!=NULL) { // read each line of the file
            save_line(line,lineno++,filename,ds,linetoks); // save line in the buffer
        }
        fclose(fp);                             // close the file
        for (i=0;i<80;i++) FREE(linetoks[i]);
        FREE(linetoks);
        return TRUE;                            // all OK
    }
    return FALSE;                               // file open failure !
}
void setup(void)
{
    int i;
    FCSTRUCT *fs;
    G_includeblk[0]=1;
    add_dtype("char","",&G_clib);
    add_dtype("int","",&G_clib);
    add_dtype("short","",&G_clib);
    add_dtype("long","",&G_clib);
    add_dtype("float","",&G_clib);
    add_dtype("double","",&G_clib);
    add_dtype("unsigned","",&G_clib);
    add_dtype("const","",&G_clib);
    add_dtype("interrupt","",&G_clib);
    add_dtype("extern","",&G_clib);
    add_dtype("far","",&G_clib);
    add_dtype("near","",&G_clib);
    add_dtype("static","",&G_clib);
    add_dtype("signed","",&G_clib);
    add_dtype("struct","",&G_clib);
    add_dtype("union","",&G_clib);
    add_dtype("void","",&G_clib);
    add_dtype("sizeof","",&G_clib);
    add_dtype("if","",&G_clib);
    add_dtype("else","",&G_clib);
    add_dtype("switch","",&G_clib);
    add_dtype("case","",&G_clib);
    add_dtype("default","",&G_clib);
    add_dtype("break","",&G_clib);
    add_dtype("do","",&G_clib);
    add_dtype("while","",&G_clib);
    add_dtype("return","",&G_clib);
    add_dtype("new","",&G_clib);
    add_dtype("delete","",&G_clib);
    add_dtype("asm","",&G_clib);
    add_dtype("auto","",&G_clib);
    add_dtype("cdecl","",&G_clib);
    add_dtype("typedef","",&G_clib);
    add_dtype("for","",&G_clib);
    add_dtype("volatile","",&G_clib);
    add_dtype("class","",&G_clib);
    add_dtype("enum","",&G_clib);
    add_dtype("NULL","",&G_clib);
    while (G_fs!=NULL) {
        fs=G_fs->next;
        FREE(G_fs->f);
        FREE(G_fs->n);
        FREE(G_fs->s);
        FREE(G_fs->r);
        FREE(G_fs->c);
        FREE(G_fs->u);
        for (i=0;i<G_fs->np;i++) FREE(G_fs->p[i]);
        for (i=0;i<G_fs->nd;i++) FREE(G_fs->d[i]);
        for (i=0;i<(G_fs->el-G_fs->sl)+1;i++) FREE(G_fs->l[i]);
        FREE(G_fs->l);
        FREE(G_fs);
        G_fs=fs;
    }
    G_setup=FALSE;
}
#ifdef TESTING
int main(int argc,char *argv[])
{
    int i;
    FCSTRUCT *fs;
    DSTRUCT *ds=NULL;
    setup();    
    G_checkfreq=1000U;
    if (argc<2) {
        fprintf(stderr,"Usage - %s FILENAME",argv[0]);
        return 1;
    }
    loadfile(argv[1],&ds);
    loadfile(NULL,&ds);
    emptyds(&ds);
    G_setup=TRUE;

    fs=G_fs;
    while (fs!=NULL) {
        printf("%s\n",fs->n);
        fs=fs->next;
    }
    fs=G_fs;
    while (fs!=NULL) {
        if (!strcmp("loadfile",fs->n)) {
            printf("?N %s\n",fs->n);
            printf("?S %s\n",fs->s);
            printf("?R %s\n",fs->r);
            printf("?C %s\n",fs->c);
            printf("?U %s\n",fs->u);
            for (i=0;i<fs->np;i++) printf("?P %s\n",fs->p[i]);
            for (i=0;i<fs->nd;i++) printf("?D %s\n",fs->d[i]);
            printf("?s %d\n",fs->sl);
            printf("?e %d\n",fs->el);
            for (i=0;i<(fs->el-fs->sl)+1;i++) {
                printf("%s",fs->l[i]);
            }
        }
        fs=fs->next;
    }
    setup();
    emptyds(&G_clib);
    return 0;
}

#else
#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
    return 1;
}
int FAR PASCAL WEP (int nParameter)
{
    int i;
    FCSTRUCT *fs;
    while (G_fs!=NULL) {
        fs=G_fs->next;
        FREE(G_fs->f);
        FREE(G_fs->n);
        FREE(G_fs->s);
        FREE(G_fs->r);
        FREE(G_fs->c);
        FREE(G_fs->u);
        for (i=0;i<G_fs->np;i++) FREE(G_fs->p[i]);
        for (i=0;i<G_fs->nd;i++) FREE(G_fs->d[i]);
        for (i=0;i<(G_fs->el-G_fs->sl)+1;i++) FREE(G_fs->l[i]);
        FREE(G_fs->l);
        FREE(G_fs);
        G_fs=fs;
    }
    G_setup=FALSE;
    return 1;
}
#pragma warn +par
void PasToCStr(CHAR *str)
{
    INT len,i;
    len=(INT)*str;

    for (i=0;i<len;i++) {
        *str=*(str+1);
        str++;
    }
    *str=0;
}
void FAR PASCAL _export FuncNames(CHAR *filename)
{
    int i;
    FILE *fp;
    DSTRUCT *ds=NULL;
    FCSTRUCT *fs;

    PasToCStr(filename);

    setup();

    loadfile(filename,&ds);
    loadfile(NULL,&ds);
    emptyds(&ds);
    emptyds(&G_clib);
    G_setup=TRUE;

    if ((fp=fopen("FuncLen.OPT","w"))==NULL) return;
    fs=G_fs;
    while (fs!=NULL) {
        fprintf(fp,"%s",fs->n);
        if (fs->next!=NULL) fprintf(fp,"\n");
        fs=fs->next;
    }
    fclose(fp);
}

void FAR PASCAL _export FuncCode(CHAR *func)
{
    int i;
    FILE *fp;
    FCSTRUCT *fs;

    PasToCStr(func);
    if (!G_setup) return;

    fs=G_fs;
    while (fs!=NULL) {
        if (!strcmp(func,fs->n)) {
            if ((fp=fopen("FuncLen.OPT","w"))==NULL) return;
            fprintf(fp,"?S %s\n",fs->s);
            fprintf(fp,"?R %s\n",fs->r);
            fprintf(fp,"?C %s\n",fs->c);
            fprintf(fp,"?U %s\n",fs->u);
            for (i=0;i<fs->np;i++) fprintf(fp,"?P %s",fs->p[i]);
            for (i=0;i<fs->nd;i++) fprintf(fp,"?D %s\n",fs->d[i]);
            for (i=0;i<(fs->el-fs->sl)+1;i++) {
                fprintf(fp,"%s",fs->l[i]);
            }
            fclose(fp);
            return;
        }
        fs=fs->next;
    }
}
#endif
