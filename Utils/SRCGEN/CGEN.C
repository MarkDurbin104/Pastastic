#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <time.h>
#include "types.h"
#include "cgen.h"
#include "deballoc.h"

#define isident(a) ((G_chartab[a]==NUMBT)||(G_chartab[a]==IDENT)||(a=='œ')||(a=='*'))
#define etype(a,b,c) (c->structs[a].elements[b].type)
#define ename(a,b,c) (c->structs[a].elements[b].name)
#define sname(a,c)   (c->structs[a].name)
#define numelem(a,c) (c->structs[a].numbelem)

#define DECLAREFUNC  1
#define DEFINEFUNC   2

#define PUBLICFUNC   1
#define PRIVATEFUNC  2
#define IGNORETYPE   3

#define SAVEFUNC 1
#define LOADFUNC 2
#define PRNTFUNC 3
#define FREEFUNC 4
#define APNDFUNC 5
#define INSTFUNC 6
#define DELTFUNC 7
#define NEWFUNC  8

INT loadfile(CHAR *name,DSTRUCTS *ds);

#define NUMBTYPE 11
CHAR *G_types[NUMBTYPE]= {
    "char",
    "short",
    "int",
    "long",
    "unsigned char",
    "unsigned short",
    "unsigned int",
    "unsigned long",
    "float",
    "double",
    "long double"
};
CHAR G_modulename[100];
CHAR G_deffile[100];
CHAR *G_copyright[10]= {                        
    "Unisys Limited","22 Southwark Bridge Road",
    "London SE1 9HB","","","","","","",""       
};
INT G_numcopy=3;
CHAR *G_user="MJD";
CHAR *G_descript[10]={ "","","","","","","","","","" };
INT G_numdesc=0;
INT G_debug=0;
BOOL isvowel(CHAR c)
{
    CHAR a=toupper(c);
    return ((a=='A')||(a=='E')||(a=='I')||(a=='O')||(a=='U'));
}
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
                while (G_chartab[*curpos]==NUMBT) *(line++)=*(curpos++);
                break;
            case IDENT    :
                while (isident(*curpos)) *(line++)=*(curpos++);
                break;
            case ARITH    :
                while (G_chartab[*curpos]==ARITH) *(line++)=*(curpos++);
                break;
            case BOOLT    :
                while (G_chartab[*curpos]==BOOLT) *(line++)=*(curpos++);
                break;
            default       :
                if (*curpos=='"') {
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
}
//F add_dtype
//S add a new datatype to the list in ds
void add_dtype(CHAR *name,CHAR *type,CHAR *ename,DSTRUCTS *ds,char dtype)
{
    INT i;
    CHAR *t=type;
    while (*t++) if (*t=='œ') *t=' ';
    if (ds->structs==NULL) {
        if ((ds->structs=MALLOC(sizeof(DSTRUCT)))==NULL) return;
        ds->numstruct=1;
        ds->structs[0].name=STRDUP(name);
        ds->structs[0].numbelem=1;
        ds->structs[0].dtype=dtype;
        if ((ds->structs[0].elements=MALLOC(sizeof(DELEM)))==NULL) return;
        ds->structs[0].elements[0].type=STRDUP(type);
        ds->structs[0].elements[0].name=STRDUP(ename);
        ds->structs[0].evsize=ds->structs[0].numbelem*sizeof(EVALUE);
        ds->structs[0].evalues=MALLOC(ds->structs[0].evsize);
        ds->structs[0].numbev=0;
        return;
    }
    for (i=0;i<ds->numstruct;i++) {
        if ((!strcmp(ds->structs[i].name,name))&&(ds->structs[i].dtype==dtype)) {
            if ((ds->structs[i].elements=REALLOC(ds->structs[i].elements,sizeof(DELEM)*(ds->structs[i].numbelem+1)))==NULL) return;
            ds->structs[i].elements[ds->structs[i].numbelem].type=STRDUP(type);
            ds->structs[i].elements[ds->structs[i].numbelem].name=STRDUP(ename);
            ds->structs[i].numbelem++;
            ds->structs[i].evsize=ds->structs[i].numbelem*sizeof(EVALUE);
            ds->structs[i].evalues=REALLOC(ds->structs[i].evalues,ds->structs[i].evsize);
            ds->structs[i].numbev=0;
            return;
        }
    }
    if ((ds->structs=REALLOC(ds->structs,sizeof(DSTRUCT)*(ds->numstruct+1)))==NULL) return;
    ds->structs[ds->numstruct].name=STRDUP(name);
    ds->structs[ds->numstruct].numbelem=1;
    ds->structs[ds->numstruct].dtype=dtype;
    if ((ds->structs[ds->numstruct].elements=MALLOC(sizeof(DELEM)))==NULL) return;
    ds->structs[ds->numstruct].elements[0].type=STRDUP(type);
    ds->structs[ds->numstruct].elements[0].name=STRDUP(ename);
    ds->structs[ds->numstruct].evsize=ds->structs[ds->numstruct].numbelem*sizeof(EVALUE);
    ds->structs[ds->numstruct].evalues=MALLOC(ds->structs[ds->numstruct].evsize);
    ds->structs[ds->numstruct].numbev=0;
    ds->numstruct++;
    return;
}
INT find_dtype(CHAR *name,DSTRUCTS *ds)
{
    INT i;
    for (i=0;i<ds->numstruct;i++) {
        if (!strcmp(ds->structs[i].name,name)) {
            return i+1;
        }
    }
    return 0;
}
void fill_structure(CHAR **line,DSTRUCTS *ds,EVALUE *newev)
{
    INT dtype;     // the data type of the line
    INT msize;     // the size of the alloced array

    dtype=find_dtype(line[0],ds)-1;
    ds->structs[dtype].numbev++;
    if (ds->structs[dtype].numbev%1000==1) {
        msize=(ds->structs[dtype].numbev+1000)*sizeof(EVALUE *);
        ds->structs[dtype].evalues=REALLOC(ds->structs[dtype].evalues,msize);
//        printf("%s Actual Size = %d - %d elements\n",sname(dtype,ds),msize,ds->structs[dtype].numbev);
    }
    ds->structs[dtype].evalues[ds->structs[dtype].numbev-1]=newev;
}
EVALUE *check_line(CHAR **line,INT lineno,CHAR *filename,DSTRUCTS *ds)
{
    CHAR *token;                     // token pointer
    INT pos;                         // the token position
    INT dtype;                       // the data type of the line
    INT curelem=0;
    EVALUE *eptr;
    EVALUE *newev;
    token=line[0];
    if (!*token) return(NULL);
    dtype=find_dtype(token,ds);
    if (!dtype) {
        fprintf(stderr,"Error %s %d: unrecognised data type %s\n",filename,lineno,line[0]);
        return(NULL);
    }
    dtype--;
    token=line[1];
    if (*token!='{') {
        fprintf(stderr,"Error %s %d: expecting '{' found %s\n",filename,lineno,token);
        return(NULL);
    }
    pos=2;
    newev=MALLOC(ds->structs[dtype].evsize);
    eptr=newev;
    token=line[pos];
    while ((*token)&&(*token!='}')) {
        switch (etype(dtype,curelem,ds)[0]) {
            case STRING :
                if (*token!='"') {
                    fprintf(stderr,"Error %s %d: parameter %s.%s (%s) should be a String\n",filename,lineno,sname(dtype,ds),ename(dtype,curelem,ds),line[pos]);
                    return(NULL);
                } else {
                    eptr->str=STRDUP(token+1);
                    *(eptr->str+(strlen(eptr->str)-1))=0;
                }
                break;
            case NUMBER :
                if (G_chartab[*token]!=NUMBT) {
                    fprintf(stderr,"Error %s %d: parameter %s.%s (%s) should be a Number\n",filename,lineno,sname(dtype,ds),ename(dtype,curelem,ds),line[pos]);
                    return(NULL);
                } else {
                    eptr->numb=atof(token);
                }
                break;
        }
        curelem++;
        eptr++;
        pos++;
        token=line[pos];
        if (curelem==numelem(dtype,ds)) {
            if (*token!='}') {
                fprintf(stderr,"Error %s %d: expecting '}' found %s\n",filename,lineno,token);
                return (NULL);
            }
        } else {
            if (*token==',') {
                token=line[++pos];
            } else {
                fprintf(stderr,"Error %s %d: expecting ',' found %s\n",filename,lineno,token);
                return (NULL);
            }
        }
    }
    if (curelem==numelem(dtype,ds)) return(newev);
    return(NULL);
}
//F parse_directive
//S parse a line of source that started with a '#'
//D parse a line of source that started with a '#'
//P The line
//P The source buffer structure being used
//P the current line in the file
//P the current filename
//R TRUE if the directive continues on the next line
BOOL parse_directive(CHAR **line,INT lineno,CHAR *filename,DSTRUCTS *ds)
{
    static CHAR sname[LINESIZE+1];   // local buffer
    CHAR *token;                     // token pointer
    INT pos;                         // the token position
    INT pcount;                      // parameter count
    token=line[1];
    if (!strcmp("include",token)) {  // include a file
        token=line[2];
        if (*token=='"') {
            token[strlen(token)-1]=0;
            loadfile(token+1,ds);
            return(FALSE);
        }
    }
    if (!strcmp("name",token)) {   // module name
        strcpy(G_modulename,line[2]);
        return(FALSE);
    }
    if (!strcmp("deftype",token)) {   // define a data type
        token=line[3];
        if (*token=='{') {
            strcpy(sname,line[2]);
            pos=4;
            token=line[pos];
            while ((*token)&&(*token!='}')) {
                pos++;
                add_dtype(sname,token,line[pos++],ds,'d');
                token=line[pos];
                if (*token==',') {
                    token=line[++pos];
                } else {
                    if (*token!='}') {
                        fprintf(stderr,"Error %s %d: expecting ',' or '}' found %s\n",filename,lineno,token);
                        return (FALSE);
                    }
                }
            }
        }
        return(FALSE);
    }
    if (!strcmp("deflen",token)) {   // define a data length
        add_dtype(line[2],line[4],line[5],ds,'l');
        return(FALSE);
    }
    if (!strcmp("genfunc",token)) {   // define generation options
        add_dtype(line[2],line[4],line[5],ds,'g');
        return(FALSE);
    }
    if (!strcmp("setinit",token)) {   // define a initial value
        add_dtype(line[2],line[4],line[5],ds,'s');
        return(FALSE);
    }
    if (!strcmp("imodule",token)) {   // define a initial value
        line[3][strlen(line[3])-1]=0;
        add_dtype(line[2],line[2],&(line[3][1]),ds,'I');
        return(FALSE);
    }
    if (!strcmp("deffind",token)) {   // define a initial value
        pos=4;
        strcpy(sname,line[pos]);
        if (line[pos][0]=='#') pcount=1; else pcount=0;
        pos++;
        while (line[pos][0]) {
            strcat(sname,line[pos]);
            if (line[pos][0]=='#') pcount++;
            pos++;
        }
        if (pcount==2) {
            add_dtype(line[2],sname,line[3],ds,'F');
        } else {
            fprintf(stderr,"Error %s %d: %s requires 2 #'s \n",filename,lineno,token);
        }
        return(FALSE);
    }
    if (!strcmp("defvar",token)) {   // define a global variable
        pos=5;
        strcpy(sname,line[pos]);
        pos++;
        while (line[pos][0]!='}') {
            strcat(sname," ");
            strcat(sname,line[pos]);
            pos++;
        }
        add_dtype(line[2],line[4],sname,ds,'v');
        return(FALSE);
    }
    if (!strcmp("define",token)) {   // define
        pos=3;
        strcpy(sname,line[pos]);
        pos++;
        while (line[pos][0]) {
            strcat(sname," ");
            strcat(sname,line[pos]);
            pos++;
        }
        add_dtype(line[2],line[2],sname,ds,'f');
        return(FALSE);
    }
    if (!strcmp("comment",token)) {   // define comment
        if (line[3][0]=='"') {
            line[3][strlen(line[3])-1]=0;
            add_dtype(line[2],line[2],&(line[3][1]),ds,'C');
        } else if (line[4][0]=='"') {
            line[4][strlen(line[4])-1]=0;
            add_dtype(line[2],line[3],&(line[4][1]),ds,'c');
        } else {
            fprintf(stderr,"Error %s %d: Comment should be in quotes #%s\n",filename,lineno,line[2]);
        }
        return(FALSE);
    }
    if (!strcmp("copy",token)) {   // copyright
        pos=2;
        G_numcopy=0;
        while ((G_numcopy<10)&&(line[pos][0])) {
            line[pos][strlen(line[pos])-1]=0;
            G_copyright[G_numcopy++]=STRDUP(&(line[pos][1]));
            pos++;
        }
        return(FALSE);
    }
    if (!strcmp("user",token)) {   // user initials
        G_user=STRDUP(line[2]);
        return(FALSE);
    }
    if (!strcmp("desc",token)) {   // module desctiption
        pos=2;
        G_numdesc=0;
        while ((G_numdesc<10)&&(line[pos][0])) {
            line[pos][strlen(line[pos])-1]=0;
            G_descript[G_numdesc++]=STRDUP(&(line[pos][1]));
            pos++;
        }
        return(FALSE);
    }
    fprintf(stderr,"Error %s %d: Unknown Directive #%s\n",filename,lineno,token);
    return(FALSE);
}
//============================================================================
//F save_line
//S Save a line of source code.
//D Save a line of source code.
//P The line
//P The source buffer structure to fill
void save_line(CHAR *l,INT lineno,CHAR *filename,DSTRUCTS *ds,CHAR **line)
{
    EVALUE *newev;
    if (*l==0) return;      // invalid line !

    extract_tokens(l,line);
    if (**line=='#') {      // compiler directive
        parse_directive(line,lineno,filename,ds);
    } else {
        if ((newev=check_line(line,lineno,filename,ds))!=NULL)
            fill_structure(line,ds,newev);
    }
}
//============================================================================
//F loadfile
//S Load a source file into memory
//D Load a source file into memory and include all it's 
//D local include files i.e. #include "foobar.h".
//P The file name
//R TRUE if file can be opened for read and sb is a valid structure
INT loadfile(CHAR *name,DSTRUCTS *ds)
{
    CHAR filename[80];                          // buffer for filename
    static CHAR line[LINESIZE+1];               // buffer for each line
    CHAR **linetoks;                            // buffer for line as tokens
    INT lineno;                                 // the current file line number
    FILE *fp;                                   // input file pointer
    int i;

    if ((name==NULL)||(*name==0)) return FALSE; // invalid file name !

    if ((fp=fopen(name,"r"))!=NULL) {           // if the file opens for read
        linetoks=MALLOC(80*sizeof(CHAR *));
        for (i=0;i<80;i++) linetoks[i]=MALLOC(LINESIZE+1);
        strcpy(filename,name);
        lineno=1;
        while (fgets(line,255,fp)!=NULL) {      // read each line of the file
            save_line(line,lineno++,filename,ds,linetoks); // save line in the buffer
        }
        fclose(fp);                             // close the file
        for (i=0;i<80;i++) FREE(linetoks[i]);
        FREE(linetoks);
        return TRUE;                            // all OK
    }
    fprintf(stderr,"Can't open %s\n",name);     // report error
    return FALSE;                               // file open failure !
}
void emptyds(DSTRUCTS *ds)
{
    INT i,j,k;

    if ((ds==NULL)||(ds->structs==NULL)||(ds->numstruct==0)) return;

    for (i=0;i<ds->numstruct;i++) {
        for (k=0;k<ds->structs[i].numbev;k++) {
            for (j=0;j<ds->structs[i].numbelem;j++) {
                FREE(ds->structs[i].evalues[k][j].str);
                ds->structs[i].evalues[k][j].str=NULL;
            }
            FREE(ds->structs[i].evalues[k]);
            ds->structs[i].evalues[k]=NULL;
        }
        FREE(ds->structs[i].evalues);
        ds->structs[i].evalues=NULL;
        for (j=0;j<ds->structs[i].numbelem;j++) {
            FREE(ds->structs[i].elements[j].name);
            ds->structs[i].elements[j].name=NULL;
        }
        ds->structs[i].numbelem=0;
        ds->structs[i].numbev=0;
        FREE(ds->structs[i].elements);
        ds->structs[i].elements=NULL;
        FREE(ds->structs[i].name);
        ds->structs[i].name=NULL;
    }
    FREE(ds->structs);
    ds->structs=NULL;
    ds->numstruct=0;
}
CHAR *resolve_type(CHAR *type,DSTRUCTS *ds)
{
    static CHAR stbuf[50];
    INT i,ptr=0;
    CHAR tbuf[50];
    DSTRUCT *d;
    strcpy(tbuf,type);
    while (tbuf[strlen(tbuf)-1]=='*') {
        ptr++;
        tbuf[strlen(tbuf)-1]=0;
        while (tbuf[strlen(tbuf)-1]==' ') tbuf[strlen(tbuf)-1]=0;;
    }
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if (d->numbelem==1) {
            if (!strcmp(tbuf,d->elements[0].name)) {
                strcpy(tbuf,resolve_type(d->elements[0].type,ds));
                strcpy(stbuf,tbuf);
                while (ptr) { strcat(stbuf," *"); ptr--; }
                return(stbuf);
            }
        }
    }
    return(type);
}
CHAR *resolve_ptrtype(CHAR *type,DSTRUCTS *ds)
{
    CHAR *tbuf;
    CHAR *etbuf;
    tbuf=resolve_type(type,ds);
    etbuf=tbuf+strlen(tbuf)-1;
    while (*etbuf=='*') {
        *(etbuf--)=0;
        while (*etbuf==' ') *(etbuf--)=0;
    }
    return(tbuf);
}
CHAR *resolve_length(CHAR *name,CHAR *type,DSTRUCTS *ds)
{
    INT i,ptr=0;
    static CHAR tbuf[50];

    strcpy(tbuf,resolve_type(type,ds));
    while (tbuf[strlen(tbuf)-1]=='*') {
        ptr++;
        tbuf[strlen(tbuf)-1]=0;
        while (tbuf[strlen(tbuf)-1]==' ') tbuf[strlen(tbuf)-1]=0;;
    }
    for (i=0;i<NUMBTYPE;i++) {
        if (!strcmp(G_types[i],tbuf)) {
            if ((i==0)&&(ptr==1)) { // char *
                sprintf(tbuf,"strlen(%s)",name);
            } else {
                if (ptr) return(NULL);
                sprintf(tbuf,"sizeof(%s)",type);
            }
            return(tbuf);
        }
    }
    return NULL;
}
CHAR *resolve_vlength(CHAR *sname,CHAR *name,CHAR *vname,DSTRUCTS *ds)
{
    INT i,j;
    static CHAR tbuf[50];
    DSTRUCT *d;

    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='l')&&(!strcmp(d->name,sname))) {
            for (j=0;j<d->numbelem;j++) {
                if (!strcmp(d->elements[j].type,name)) {
                    sprintf(tbuf,"%s->%s",vname,d->elements[j].name);
                    return tbuf;
                }
            }
        }
    }
    return NULL;
}
void filehead(FILE *fp,CHAR *name)
{
    INT i;
    struct tm *tim;
    time_t t;
    time(&t);
    tim=gmtime(&t);

    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/ Module        | %s\n",name);
    for (i=0;i<G_numdesc;i++) {
        if (!i) fprintf(fp,"\/\/ Description   | "); else fprintf(fp,"\/\/               | ");
        fprintf(fp,"%s\n",G_descript[i]);
    }
    fprintf(fp,"\/\/               | \n");
    fprintf(fp,"\/\/ Author        | Automatically generated from %s by CGEN\n",G_deffile);
    for (i=0;i<G_numcopy;i++) {
        if (!i) fprintf(fp,"\/\/ Copyright (c) | "); else fprintf(fp,"\/\/               | ");
        fprintf(fp,"%s\n",G_copyright[i]);
    }
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/ Mod History   | By  | Modifications Made\n");
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/ %02d\/%02d\/%4d    | %s | Initial Version\n",tim->tm_mday,tim->tm_mon+1,tim->tm_year+1900,G_user);
    fprintf(fp,"\/\/============================================================================\n");

}
void blockheader(FILE *fp,char *t)
{
    INT lo=(76-strlen(t))/2;
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/%*.*s%s%*.*s\n",lo,lo,"",t,lo,lo,"");
    fprintf(fp,"\/\/============================================================================\n");
}
CHAR *getcomment(CHAR *sname,CHAR *name,DSTRUCTS *ds)
{
    INT i,j;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if (name==NULL) {
            if ((d->dtype=='C')&&(!strcmp(sname,d->name))) {
                return d->elements[0].name;
            }
        } else {
            if ((d->dtype=='c')&&(!strcmp(sname,d->name))) {
                for (j=0;j<d->numbelem;j++) {
                    if (!strcmp(name,d->elements[j].type))
                        return d->elements[j].name;
                }
            }
        }
    }
    return "";
}
void genvars(FILE *fp,DSTRUCTS *ds)
{
    INT i,nwid=0,twid=0,inwid=0,w;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='v')&&(d->numbelem==1)) {
            nwid=max(nwid,strlen(d->name));
            twid=max(twid,strlen(d->elements[0].type));
            inwid=max(inwid,strlen(d->elements[0].name));
        }
    }
    blockheader(fp,"GLOBAL VARIABLES");
    fprintf(fp,"\n");
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='v')&&(d->numbelem==1)) {
            w=inwid-strlen(d->elements[0].name);
            fprintf(fp,"PUBLIC %-*.*s %-*.*s INIT(%s);%*.*s \/\/ %s\n",
                twid,twid,d->elements[0].type,nwid,nwid,d->name,
                d->elements[0].name,w,w,"",getcomment(d->name,NULL,ds));
        }
    }
    fprintf(fp,"\n");
}
void gendefs(FILE *fp,DSTRUCTS *ds)
{
    INT i,nwid=0,vwid=0;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='f')&&(d->numbelem==1)) {
            nwid=max(nwid,strlen(d->name));
            vwid=max(vwid,strlen(d->elements[0].name));
        }
    }
    blockheader(fp,"DEFINITIONS");
    fprintf(fp,"\n");
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='f')&&(d->numbelem==1)) {
            fprintf(fp,"#define %-*.*s %-*.*s \/\/ %s\n",
                nwid,nwid,d->name,vwid,vwid,d->elements[0].name,getcomment(d->name,NULL,ds));
        }
    }
    fprintf(fp,"\n");
}
CHAR *setinit(CHAR *sname,CHAR *name,DSTRUCTS *ds)
{
    INT i,j;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='s')&&(!strcmp(sname,d->name))) {
            for (j=0;j<d->numbelem;j++) {
                if (!strcmp(name,d->elements[j].type))
                    return d->elements[j].name;
            }
        }
    }
    return NULL;
}
void imodule(FILE *fp,CHAR *itype,DSTRUCTS *ds)
{
    CHAR line[LINESIZE+1];   // local buffer
    INT i,j;
    FILE *ifp;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='I')&&(!strcmp(itype,d->name))) {
            for (j=0;j<d->numbelem;j++) {
                if ((ifp=fopen(d->elements[j].name,"r"))!=NULL) {
                    while (fgets(line,LINESIZE,ifp)!=NULL) {
                        fprintf(fp,"%s",line);
                    }
                    fclose(ifp);
                } else {
                    printf("Can't open include module %s\n",d->elements[j].name);
                }
            }
        }
    }
}
CHAR *gettype(CHAR *sname,CHAR *ename,DSTRUCTS *ds)
{
    INT i,j;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='d')&&(d->numbelem>1)&&(!strcmp(d->name,sname))) {
            for (j=0;j<d->numbelem;j++) {
                if (!strcmp(d->elements[j].name,ename))
                    return(d->elements[j].type);
            }
        }
    }
    return "";
}
void outfindfunc(FILE *fp,DSTRUCTS *ds,INT i,INT j,INT k,INT l,INT btype,CHAR *name)
{
    CHAR pbuf[100];
    CHAR uname[100];
    CHAR vname[5];
    DSTRUCT *d;
    DSTRUCT *s;
    CHAR *p1,*p2,*p3;

    s=&(ds->structs[i]);
    d=&(ds->structs[j]);
    if ((strcmp(resolve_ptrtype(d->elements[k].type,ds),name))
    ||  (resolve_length(d->elements[k].name,d->elements[k].type,ds)!=NULL)
    ||  (!resolve_vlength(d->name,d->elements[k].name,"",ds)!=NULL)) {
        return;
    }
    strcpy(uname,d->name); strlwr(uname);
    sprintf(vname,"%cs",uname[0]);
    strcpy(pbuf,s->elements[l].type);
    p1=strtok(pbuf,"#"); if (p1==NULL) p1="";
    p2=strtok(NULL,"#"); if (p2==NULL) p2="";
    p3=strtok(NULL,"#"); if (p3==NULL) p3="";

    if (btype==DECLAREFUNC) {
        fprintf(fp,"PUBLIC INT %s_%s_idx(%s *%s,%s %s);\n",
            uname,d->elements[k].name,d->name,vname,
            gettype(d->name,s->elements[l].name,ds),s->elements[l].name);
        fprintf(fp,"PUBLIC %s %s_%s(%s *%s,%s %s);\n",
            d->elements[k].type,uname,d->elements[k].name,
            d->name,vname,
            gettype(d->name,s->elements[l].name,ds),s->elements[l].name);
    } else {
        fprintf(fp,"\/\/============================================================================\n");
        fprintf(fp,"\/\/F %s_%s_idx\n",uname,d->elements[k].name);
        fprintf(fp,"\/\/S Find %s %s in the %s structure\n",isvowel(*resolve_ptrtype(d->elements[k].type,ds))?"an":"a",resolve_ptrtype(d->elements[k].type,ds),d->name);
        fprintf(fp,"\/\/D Find %s %s in the %s structure using the %s %s\n",isvowel(*resolve_ptrtype(d->elements[k].type,ds))?"an":"a",resolve_ptrtype(d->elements[k].type,ds),d->name,d->elements[k].name,s->elements[l].name);
        fprintf(fp,"\/\/P the %s structure to search\n",d->name);
        fprintf(fp,"\/\/P the %s element to use as a key\n",s->elements[l].name);
        fprintf(fp,"\/\/R the index of the %s structure found or -1 on error\n",resolve_ptrtype(d->elements[k].type,ds));
        fprintf(fp,"INT %s_%s_idx(%s *%s,%s %s)\n",
            uname,d->elements[k].name,d->name,vname,
            gettype(d->name,s->elements[l].name,ds),s->elements[l].name);
        fprintf(fp,"{\n    COUNTER count;\n");
        fprintf(fp,"    for (count=0;count<%s;count++) {\n",resolve_vlength(d->name,d->elements[k].name,vname,ds));
        fprintf(fp,"        if (%s%s->%s[count].%s%s%s%s) {\n",p1,vname,d->elements[k].name,s->elements[l].name,p2,s->elements[l].name,p3);
        fprintf(fp,"            return count;\n");
        fprintf(fp,"        }\n");
        fprintf(fp,"    }\n");
        fprintf(fp,"    return -1;\n");
        fprintf(fp,"}\n");

        fprintf(fp,"\/\/============================================================================\n");
        fprintf(fp,"\/\/F %s_%s\n",uname,d->elements[k].name);
        fprintf(fp,"\/\/S Find %s %s in the %s structure\n",isvowel(*resolve_ptrtype(d->elements[k].type,ds))?"an":"a",resolve_ptrtype(d->elements[k].type,ds),d->name);
        fprintf(fp,"\/\/D Find %s %s in the %s structure using the %s %s\n",isvowel(*resolve_ptrtype(d->elements[k].type,ds))?"an":"a",resolve_ptrtype(d->elements[k].type,ds),d->name,d->elements[k].name,s->elements[l].name);
        fprintf(fp,"\/\/P the %s structure to search\n",d->name);
        fprintf(fp,"\/\/P the %s element to use as a key\n",s->elements[l].name);
        fprintf(fp,"\/\/R a pointer to the %s structure found or NULL on error\n",resolve_ptrtype(d->elements[k].type,ds));
        fprintf(fp,"%s %s_%s(%s *%s,%s %s)\n",
            d->elements[k].type,uname,d->elements[k].name,
            d->name,vname,
            gettype(d->name,s->elements[l].name,ds),s->elements[l].name);
        fprintf(fp,"{\n    COUNTER count;\n");
        fprintf(fp,"    count=%s_%s_idx(%s,%s);\n",uname,d->elements[k].name,vname,s->elements[l].name);
        fprintf(fp,"    if (count!=(-1)) {\n");
        fprintf(fp,"        return (%s->%s)+count;\n",vname,d->elements[k].name);
        fprintf(fp,"    }\n");
        fprintf(fp,"    return NULL;\n");
        fprintf(fp,"}\n");
    }
}
void genfindfuncs(FILE *fp,DSTRUCTS *ds,INT btype)
{
    INT i,j,k,l;
    CHAR name[100];
    DSTRUCT *d;
    DSTRUCT *s;
    for (i=0;i<ds->numstruct;i++) {
        s=&(ds->structs[i]);
        if (s->dtype=='F') {
            for (l=0;l<s->numbelem;l++) {
                strcpy(name,resolve_ptrtype(s->name,ds));
                for (j=0;j<ds->numstruct;j++) {
                    d=&(ds->structs[j]);
                    if ((d->dtype=='d')&&(d->numbelem>1)) {
                        for (k=0;k<d->numbelem;k++) {
                            outfindfunc(fp,ds,i,j,k,l,btype,name);
                        }
                    }
                }
            }
        }
    }
    fprintf(fp,"\/\/============================================================================\n\n");
}
BOOL shouldgen(CHAR *sname,INT ftype,INT btype,DSTRUCTS *ds)
{
    INT i,j;
    DSTRUCT *d;
    for (i=0;i<ds->numstruct;i++) {
        d=&(ds->structs[i]);
        if ((d->dtype=='g')&&(!strcmp(sname,d->name))&&(d->numbelem==1)) {
            strupr(d->elements[0].type);
            strupr(d->elements[0].name);
            for (j=0;j<strlen(d->elements[0].type);j++) {
                switch (d->elements[0].type[j]) {
                    case 'S':
                        if (ftype==SAVEFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'L':
                        if (ftype==LOADFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'P':
                        if (ftype==PRNTFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'F':
                        if (ftype==FREEFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'A':
                        if (ftype==APNDFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'I':
                        if (ftype==INSTFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'D':
                        if (ftype==DELTFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                    case 'N':
                        if (ftype==NEWFUNC) {
                            if (btype==IGNORETYPE) return TRUE;
                            if (d->elements[0].name[j]=='I') {
                                return (btype==PRIVATEFUNC);
                            }
                            return (btype==PUBLICFUNC);
                        }
                        break;
                }
            }
            return FALSE;
        }
    }
    return (btype==PUBLICFUNC);
}
void genfunc(FILE *fp,DSTRUCTS *ds,INT idx,INT wid,INT func,INT ftype,int btype)
{
    CHAR vname[20];
    CHAR name[100];
    CHAR uname[100];
    DSTRUCT *d;
    INT j;
    d=&(ds->structs[idx]);
    if ((d->dtype!='d')||(d->numbelem<2)) return;
    if (!shouldgen(d->name,func,ftype==DECLAREFUNC?btype:IGNORETYPE,ds)) return;
    strcpy(name,d->name);
    strlwr(name);
    if (ftype==DECLAREFUNC) {
        switch (func) {
            case SAVEFUNC :
                fprintf(fp,"%sBOOL save_%-*.*s(FILE *fp,%s *%cs);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,d->name,name[0]);
                break;
            case LOADFUNC :
                fprintf(fp,"%sBOOL load_%-*.*s(FILE *fp,%s *%cs);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,d->name,name[0]);
                break;
            case PRNTFUNC :
                fprintf(fp,"%svoid prnt_%-*.*s(%s *%cs,INT depth);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,d->name,name[0]);
                break;
            case FREEFUNC :
                fprintf(fp,"%svoid free_%-*.*s(%s *%cs);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,d->name,name[0]);
                break;
            case APNDFUNC :
                fprintf(fp,"%sBOOL apnd_%-*.*s(%s **%c_base,UINT *numelem,%s *new_%c);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,
                    d->name,name[0],d->name,name[0]);
                break;
            case INSTFUNC :
                fprintf(fp,"%sBOOL inst_%-*.*s(%s **%c_base,UINT *numelem,%s *new_%c,UINT offset);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,
                    d->name,name[0],d->name,name[0]);
                break;
            case DELTFUNC :
                fprintf(fp,"%sBOOL delt_%-*.*s(%s **%c_base,UINT *numelem,UINT offset);\n",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,name,d->name,name[0]);
                break;
            case NEWFUNC  :
                wid-=3;
                fprintf(fp,"%s%-*.*s *new_%-*.*s(",
                    ((btype==PUBLICFUNC)?"PUBLIC ":""),wid,wid,d->name,wid,wid,name);
                for (j=0;j<d->numbelem;j++) {
                    fprintf(fp,"%s new_%s",d->elements[j].type,d->elements[j].name);
                    if (j<(d->numbelem-1)) fprintf(fp,",");
                }
                fprintf(fp,");\n");
                break;
            
        }
    } else {
        sprintf(vname,"%cs",name[0]);
        fprintf(fp,"\/\/============================================================================\n");
        switch (func) {
            case SAVEFUNC :
                fprintf(fp,"\/\/F save_%s\n",name);
                fprintf(fp,"\/\/S save %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D save %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the file pointer\n");
                fprintf(fp,"\/\/P the %s structure to save\n",d->name);
                fprintf(fp,"\/\/R TRUE if saved, otherwise FALSE\n");
                fprintf(fp,"BOOL save_%s(FILE *fp,%s *%s)\n",name,d->name,vname);
                fprintf(fp,"{\n");
                for (j=0;j<d->numbelem;j++) {
                    if (!resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    COUNTER count;\n");
                            break;
                        }
                    }
                }
                fprintf(fp,"    if ((fp==NULL)||(%s==NULL)) return FALSE;\n",vname);
                for (j=0;j<d->numbelem;j++) {
                    if (resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        strcpy(name,resolve_length(d->elements[j].name,d->elements[j].type,ds));
                        if (!strncmp("strlen",name,6)) {
                            fprintf(fp,"    if (!write_varib(fp,%s->%s)) return(FALSE);\n",vname,d->elements[j].name);
                        } else {
                            fprintf(fp,"    if (!write_fixed(fp,&(%s->%s),%s)) return(FALSE);\n",vname,d->elements[j].name,name);
                        }
                    } else {
                        strcpy(name,resolve_ptrtype(d->elements[j].type,ds)); strlwr(name);
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    for (count=0;count<%s;count++) {\n",resolve_vlength(d->name,d->elements[j].name,vname,ds));
                            fprintf(fp,"        if (!save_%s(fp,&(%s->%s[count]))) return(FALSE);\n",name,vname,d->elements[j].name);
                            fprintf(fp,"    }\n");
                        }
                    }
                }
                fprintf(fp,"    return(TRUE);\n}\n");
                break;
            case LOADFUNC :
                fprintf(fp,"\/\/F load_%s\n",name);
                fprintf(fp,"\/\/S load %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D load %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the file pointer\n");
                fprintf(fp,"\/\/P the %s structure to load into\n",d->name);
                fprintf(fp,"\/\/R TRUE if loaded, otherwise FALSE\n");
                fprintf(fp,"BOOL load_%s(FILE *fp,%s *%s)\n",name,d->name,vname);
                fprintf(fp,"{\n");
                for (j=0;j<d->numbelem;j++) {
                    if (!resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    COUNTER count;\n");
                            break;
                        }
                    }
                }
                fprintf(fp,"    if ((fp==NULL)||(%s==NULL)) return FALSE;\n",vname);
                for (j=0;j<d->numbelem;j++) {
                    if (resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        strcpy(name,resolve_length(d->elements[j].name,d->elements[j].type,ds));
                        if (!strncmp("strlen",name,6)) {
                            fprintf(fp,"    if (!read_varib(fp,&(%s->%s))) return(FALSE);\n",vname,d->elements[j].name);
                        } else {
                            fprintf(fp,"    if (!read_fixed(fp,&(%s->%s),%s)) return(FALSE);\n",vname,d->elements[j].name,name);
                        }
                    } else {
                        strcpy(uname,resolve_ptrtype(d->elements[j].type,ds));
                        strcpy(name,uname);
                        strlwr(name);
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    %s->%s=MALLOC(%s*sizeof(%s));\n",vname,d->elements[j].name,resolve_vlength(d->name,d->elements[j].name,vname,ds),uname);
                            fprintf(fp,"    if (%s->%s==NULL) return(FALSE);\n",vname,d->elements[j].name);
                            fprintf(fp,"    for (count=0;count<%s;count++) {\n",resolve_vlength(d->name,d->elements[j].name,vname,ds));
                            fprintf(fp,"        if (!load_%s(fp,&(%s->%s[count]))) return(FALSE);\n",name,vname,d->elements[j].name);
                            fprintf(fp,"    }\n");
                        } else {
                            if (setinit(d->name,d->elements[j].name,ds)!=NULL) {
                                fprintf(fp,"    %s->%s=%s;\n",vname,d->elements[j].name,setinit(d->name,d->elements[j].name,ds));
                            } else {
                                fprintf(fp,"    \/\/ %s->%s Length Unknown assumed to be 1\n",vname,d->elements[j].name);
                                fprintf(fp,"    %s->%s=MALLOC(sizeof(%s));\n",vname,d->elements[j].name,uname);
                                fprintf(fp,"    if (%s->%s==NULL) return(FALSE);\n",vname,d->elements[j].name);
                                fprintf(fp,"    if (!load_%s(fp,%s->%s)) return(FALSE);\n",name,vname,d->elements[j].name);
                            }
                        }
                    }
                }
                fprintf(fp,"    return(TRUE);\n}\n");
                break;
            case PRNTFUNC :
                fprintf(fp,"\/\/F prnt_%s\n",name);
                fprintf(fp,"\/\/S print %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D print %s %s structure on stdout\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the %s structure to print\n",d->name);
                fprintf(fp,"\/\/P the indent depth\n");
                fprintf(fp,"void prnt_%s(%s *%s,INT depth)\n",name,d->name,vname);
                fprintf(fp,"{\n");
                for (j=0;j<d->numbelem;j++) {
                    if (!resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    COUNTER count;\n");
                            break;
                        }
                    }
                }
                fprintf(fp,"    if (%s==NULL) return;\n",vname);
                fprintf(fp,"    printf(\"%%*.*s%s structure\\n\",depth,depth,\"\");\n",d->name);
                for (j=0;j<d->numbelem;j++) {
                    if (resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        strcpy(name,resolve_length(d->elements[j].name,d->elements[j].type,ds));
                        if (!strncmp("strlen",name,6)) {
                            fprintf(fp,"    if (PTRCHECK(%s->%s))\n",vname,d->elements[j].name);
                            fprintf(fp,"        printf(\"%%*.*s%s  %%s\\n\",depth,depth,\"\",%s->%s);\n",d->elements[j].name,vname,d->elements[j].name);
                        } else {
                            fprintf(fp,"    printf(\"%%*.*s%s  %%d\\n\",depth,depth,\"\",%s->%s);\n",d->elements[j].name,vname,d->elements[j].name);
                        }
                    } else {
                        strcpy(name,resolve_ptrtype(d->elements[j].type,ds)); strlwr(name);
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    for (count=0;count<%s;count++) {\n",resolve_vlength(d->name,d->elements[j].name,vname,ds));
                            fprintf(fp,"        prnt_%s(&(%s->%s[count]),depth+4);\n",name,vname,d->elements[j].name);
                            fprintf(fp,"    }\n");
                        } else {
                            fprintf(fp,"    \/\/ %s->%s Length Unknown assumed to be 1\n",vname,d->elements[j].name);
                            fprintf(fp,"    prnt_%s(%s->%s,depth+4);\n",name,vname,d->elements[j].name);
                        }
                    }
                }
                fprintf(fp,"}\n");
                break;
            case FREEFUNC :
                fprintf(fp,"\/\/F free_%s\n",name);
                fprintf(fp,"\/\/S free %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D free %s %s structure and all it's sub-structures\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the %s structure to free\n",d->name);
                fprintf(fp,"void free_%s(%s *%cs)\n",name,d->name,name[0]);
                fprintf(fp,"{\n");
                for (j=0;j<d->numbelem;j++) {
                    if (!resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    COUNTER count;\n");
                            break;
                        }
                    }
                }
                fprintf(fp,"    if (%s==NULL) return;\n",vname);
                for (j=0;j<d->numbelem;j++) {
                    if (resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        strcpy(name,resolve_length(d->elements[j].name,d->elements[j].type,ds));
                        if (!strncmp("strlen",name,6)) {
                            fprintf(fp,"    if (PTRCHECK(%s->%s)) { ",vname,d->elements[j].name);
                            fprintf(fp,"FREE(%s->%s); ",vname,d->elements[j].name);
                            fprintf(fp,"%s->%s=NULL; ",vname,d->elements[j].name);
                            fprintf(fp,"}\n");
                        }
                    } else {
                        strcpy(name,resolve_ptrtype(d->elements[j].type,ds));
                        strlwr(name);
                        if (resolve_vlength(d->name,d->elements[j].name,vname,ds)!=NULL) {
                            fprintf(fp,"    for (count=0;count<%s;count++) {\n",resolve_vlength(d->name,d->elements[j].name,vname,ds));
                            fprintf(fp,"        free_%s(&(%s->%s[count]));\n",name,vname,d->elements[j].name);
                            fprintf(fp,"    }\n    %s=0;\n",resolve_vlength(d->name,d->elements[j].name,vname,ds));
                            fprintf(fp,"    if (PTRCHECK(%s->%s)) { ",vname,d->elements[j].name);
                            fprintf(fp,"FREE(%s->%s); ",vname,d->elements[j].name);
                            fprintf(fp,"%s->%s=NULL; ",vname,d->elements[j].name);
                            fprintf(fp,"}\n");
                        } else {
                            fprintf(fp,"    %s->%s=NULL; ",vname,d->elements[j].name);
                        }
                    }
                }
                fprintf(fp,"}\n");
                break;
            case APNDFUNC :
                fprintf(fp,"\/\/F apnd_%s\n",name);
                fprintf(fp,"\/\/S append %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D append %s %s structure to an array of structures\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the base %s structure\n",d->name);
                fprintf(fp,"\/\/P the number of elements in the base %s structure array\n",d->name);
                fprintf(fp,"\/\/P the new %s structure to add\n",d->name);
                fprintf(fp,"\/\/R TRUE if the new structure appended, otherwise FALSE\n",d->name);
                fprintf(fp,"BOOL apnd_%s(%s **%c_base,UINT *numelem,%s *new_%c)\n",
                    name,d->name,name[0],d->name,name[0]);
                fprintf(fp,"{\n");
                fprintf(fp,"    if ((%c_base==NULL)||(new_%c==NULL)) return FALSE;\n",name[0],name[0]);
                fprintf(fp,"    if (*%c_base==NULL) {\n",name[0]);
                fprintf(fp,"        *%c_base=MALLOC(sizeof(%s));\n",name[0],d->name);
                fprintf(fp,"    } else {\n");
                fprintf(fp,"        *%c_base=REALLOC(*%c_base,(*numelem+1)*sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    }\n");
                fprintf(fp,"    if (*%c_base==NULL) return FALSE;\n",name[0]);
                fprintf(fp,"    memcpy((*%c_base)+*numelem,new_%c,sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    (*numelem)++;\n");
                fprintf(fp,"    return TRUE;\n}\n");
                break;
            case INSTFUNC :
                fprintf(fp,"\/\/F inst_%s\n",name);
                fprintf(fp,"\/\/S insert %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D insert %s %s structure to an array of structures\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the pointer to the base %s structure\n",d->name);
                fprintf(fp,"\/\/P the number of elements in the base %s structure array\n",d->name);
                fprintf(fp,"\/\/P the new %s structure to insert\n",d->name);
                fprintf(fp,"\/\/P the insertion offset\n");
                fprintf(fp,"\/\/R TRUE if the new structure inserted, otherwise FALSE\n",d->name);
                fprintf(fp,"BOOL inst_%s(%s **%c_base,UINT *numelem,%s *new_%c,UINT offset)\n",
                    name,d->name,name[0],d->name,name[0]);
                fprintf(fp,"{\n");
                fprintf(fp,"    COUNTER count;\n");
                fprintf(fp,"    if ((%c_base==NULL)||(new_%c==NULL)||(offset>=*numelem)) return FALSE;\n",name[0],name[0]);
                fprintf(fp,"    if (*%c_base==NULL) {\n",name[0]);
                fprintf(fp,"        *%c_base=MALLOC(sizeof(%s));\n",name[0],d->name);
                fprintf(fp,"    } else {\n");
                fprintf(fp,"        *%c_base=REALLOC(*%c_base,(*numelem+1)*sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    }\n");
                fprintf(fp,"    if (*%c_base==NULL) return FALSE;\n",name[0]);
                fprintf(fp,"    for (count=*numelem;count>offset;count--) {\n");
                fprintf(fp,"        memcpy((*%c_base)+count,(*%c_base)+count-1,sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    }\n");
                fprintf(fp,"    memcpy((*%c_base)+offset,new_%c,sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    (*numelem)++;\n");
                fprintf(fp,"    return TRUE;\n}\n");
                break;
            case DELTFUNC :
                fprintf(fp,"\/\/F delt_%s\n",name);
                fprintf(fp,"\/\/S delete %s %s structure\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/D delete %s %s structure from an array of structures\n",isvowel(d->name[0])?"an":"a",d->name);
                fprintf(fp,"\/\/P the base %s structure\n",d->name);
                fprintf(fp,"\/\/P the number of elements in the base %s structure array\n",d->name);
                fprintf(fp,"\/\/P the deletion offset\n");
                fprintf(fp,"\/\/R TRUE if the new structure deleted, otherwise FALSE\n",d->name);
                fprintf(fp,"BOOL delt_%s(%s **%c_base,UINT *numelem,UINT offset)\n",
                    name,d->name,name[0]);
                fprintf(fp,"{\n");
                fprintf(fp,"    COUNTER count;\n");
                fprintf(fp,"    if ((%c_base==NULL)||(offset>=*numelem)) return FALSE;\n",name[0],name[0]);
                fprintf(fp,"    if (*%c_base==NULL) return FALSE;\n",name[0]);
                fprintf(fp,"    free_%s((*%c_base)+offset);\n",name,name[0]);
                fprintf(fp,"    for (count=offset;count<((*numelem)-1);count++) {\n");
                fprintf(fp,"        memcpy((*%c_base)+count,(*%c_base)+count+1,sizeof(%s));\n",name[0],name[0],d->name);
                fprintf(fp,"    }\n");
                fprintf(fp,"    if (*numelem==1) {\n");
                fprintf(fp,"        FREE(*%c_base);\n",name[0]);
                fprintf(fp,"        *%c_base=NULL;\n",name[0]);
                fprintf(fp,"    }\n");
                fprintf(fp,"    (*numelem)--;\n");
                fprintf(fp,"    return TRUE;\n}\n");
                break;
            case NEWFUNC  :
                fprintf(fp,"\/\/F new_%s\n",name);
                fprintf(fp,"\/\/S creat a new %s structure\n",d->name);
                fprintf(fp,"\/\/D creat a new %s structure\n",d->name);
                for (j=0;j<d->numbelem;j++) {
                    fprintf(fp,"\/\/P %s\n",getcomment(d->name,d->elements[j].name,ds));
                }
                fprintf(fp,"\/\/R the new structure or NULL on error\n");
                fprintf(fp,"%s *new_%s(",d->name,name);
                for (j=0;j<d->numbelem;j++) {
                    fprintf(fp,"%s new_%s",d->elements[j].type,d->elements[j].name);
                    if (j<(d->numbelem-1)) fprintf(fp,",");
                }
                fprintf(fp,")\n");
                sprintf(vname,"ret_%cs",name[0]);
                fprintf(fp,"{\n    static %s *%s;\n",d->name,vname);
                fprintf(fp,"    %s=MALLOC(sizeof(%s));\n",vname,d->name);
                fprintf(fp,"    if (%s!=NULL) {\n",vname);
                for (j=0;j<d->numbelem;j++) {
                    if (resolve_length(d->elements[j].name,d->elements[j].type,ds)!=NULL) {
                        strcpy(name,resolve_length(d->elements[j].name,d->elements[j].type,ds));
                        if (!strncmp("strlen",name,6)) {
                            fprintf(fp,"        if ((%s->%s=STRDUP(new_%s))==NULL) return(NULL);\n",vname,d->elements[j].name,d->elements[j].name);
                        } else {
                            fprintf(fp,"        %s->%s=new_%s;\n",vname,d->elements[j].name,d->elements[j].name);
                        }
                    } else {
                        fprintf(fp,"        %s->%s=new_%s;\n",vname,d->elements[j].name,d->elements[j].name);
                    }
                }
                fprintf(fp,"    }\n");
                fprintf(fp,"    return %s;\n}\n",vname);
                break;
        }
    }
}
void genfuncs(FILE *fp,DSTRUCTS *ds,INT wid,INT ftype,int btype)
{
    INT i,nums;
    nums=ds->numstruct;
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,SAVEFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,LOADFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,PRNTFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,FREEFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,APNDFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,INSTFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,DELTFUNC,ftype,btype);
    for (i=0;i<nums;i++) genfunc(fp,ds,i,wid,NEWFUNC ,ftype,btype);
}
void gentypedef(FILE *fp,DSTRUCT *d,DSTRUCTS *ds)
{
    INT typewid=0;
    INT namewid=0;
    INT j,n;
    if (d->dtype=='d') {
        if (d->numbelem==1) {
            fprintf(fp,"\/\/============================================================================\n");
            fprintf(fp,"\/\/ %s type definition - %s\n",d->elements[0].name,getcomment(d->elements[0].name,NULL,ds));
            fprintf(fp,"typedef %s %s;\n",d->elements[0].type,d->elements[0].name);
        } else {
            fprintf(fp,"\/\/============================================================================\n");
            fprintf(fp,"\/\/ %s type definition - %s\n",d->name,getcomment(d->name,NULL,ds));
            fprintf(fp,"typedef struct {\n");
            typewid=0;
            namewid=0;
            for (j=0;j<d->numbelem;j++) {
                typewid=max(typewid,strlen(d->elements[j].type));
                namewid=max(namewid,strlen(d->elements[j].name));
            }
            typewid+=2;
            namewid+=2;
            for (j=0;j<d->numbelem;j++) {
                n=namewid-strlen(d->elements[j].name);
                fprintf(fp,"    %-*.*s %s;%*.*s\/\/ %s\n",
                    typewid,typewid,d->elements[j].type,
                    d->elements[j].name,n,n,"",getcomment(d->name,d->elements[j].name,ds));
            }
            fprintf(fp,"} %s;\n",d->name);
        }
    }
}
void genhfile(DSTRUCTS *ds)
{
    CHAR name[100];
    INT i,wid=0;
    FILE *fp;

    sprintf(name,"%s.H",G_modulename);
    if ((fp=fopen(name,"w"))==NULL) fp=stdout;
    filehead(fp,name);

    sprintf(name,"%s_H",G_modulename);
    fprintf(fp,"#ifndef %s \/\/ entry sentry\n#define %s\n\n",name,name);
    imodule(fp,"HS",ds);
    sprintf(name,"%s_C",G_modulename);
    fprintf(fp,"#ifdef INIT\n# undef INIT\n#endif\n");
    fprintf(fp,"#ifdef PUBLIC\n# undef PUBLIC\n#endif\n\n");
    fprintf(fp,"#ifdef %s\n# define INIT(a) =a\n# define PUBLIC\n",name);
    fprintf(fp,"#else\n# define INIT(a)\n# define PUBLIC extern\n");
    fprintf(fp,"#endif \/\/ %s\n\n",name);
    if (!G_debug) {
        fprintf(fp,"#ifndef MALLOC\n");
        fprintf(fp,"#define FREE    free\n");
        fprintf(fp,"#define MALLOC  malloc\n");
        fprintf(fp,"#define REALLOC realloc\n");
        fprintf(fp,"#define STRDUP  strdup\n");
        fprintf(fp,"#define PTRCHECK(a) (a!=NULL)\n");
        fprintf(fp,"#endif // MALLOC\n");
    }
    gendefs(fp,ds);

    blockheader(fp,"TYPE DEFINITIONS");
    for (i=0;i<ds->numstruct;i++) gentypedef(fp,ds->structs+i,ds);

    for (i=0;i<ds->numstruct;i++) wid=max(wid,(strlen(ds->structs[i].name)-1));

    blockheader(fp,"PUBLIC PROTOTYPES");
    fprintf(fp,"\n");
    genfuncs(fp,ds,wid,DECLAREFUNC,PUBLICFUNC);
    genfindfuncs(fp,ds,DECLAREFUNC);
    fprintf(fp,"\n");
    blockheader(fp,"PRIVATE PROTOTYPES");
    fprintf(fp,"\n#ifdef %s\n\n",name);
    fprintf(fp,"BOOL write_fixed(FILE *fp,void *buf,INT len);\n");
    fprintf(fp,"BOOL write_varib(FILE *fp,CHAR *s);\n");
    fprintf(fp,"BOOL read_fixed(FILE *fp,void *buf,INT len);\n");
    fprintf(fp,"BOOL read_varib(FILE *fp,CHAR **s);\n");
    genfuncs(fp,ds,wid,DECLAREFUNC,PRIVATEFUNC);
    fprintf(fp,"\n#endif\n\n");

    genvars(fp,ds);

    imodule(fp,"HE",ds);
    sprintf(name,"%s_H",G_modulename);
    fprintf(fp,"\n#endif \/\/%s\n",name);
    blockheader(fp,"END OF FILE");

    fflush(fp);
    if (fp!=stdout) fclose(fp);
}
void stdrdwrfuncs(FILE *fp)
{
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/F write_fixed\n");
    fprintf(fp,"\/\/S write a fixed length block to a file\n");
    fprintf(fp,"\/\/D write a fixed length block to a file\n");
    fprintf(fp,"\/\/P the file pointer\n");
    fprintf(fp,"\/\/P the block pointer\n");
    fprintf(fp,"\/\/P the length of the block\n");
    fprintf(fp,"\/\/R TRUE if ok, otherwise FALSE\n");
    fprintf(fp,"BOOL write_fixed(FILE *fp,void *buf,INT len)\n");
    fprintf(fp,"{\n");
    fprintf(fp,"    if (fwrite(buf,1,len,fp)!=len) return(FALSE);\n");
    fprintf(fp,"    return(TRUE);\n}\n");
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/F write_varib\n");
    fprintf(fp,"\/\/S write a variable length string to a file\n");
    fprintf(fp,"\/\/D write a variable length string to a file\n");
    fprintf(fp,"\/\/P the file pointer\n");
    fprintf(fp,"\/\/P the string pointer\n");
    fprintf(fp,"\/\/R TRUE if ok, otherwise FALSE\n");
    fprintf(fp,"BOOL write_varib(FILE *fp,CHAR *s)\n");
    fprintf(fp,"{\n");
    fprintf(fp,"    INT len=strlen(s);\n");
    fprintf(fp,"    if (fwrite(&len,1,sizeof(INT),fp)!=sizeof(INT)) return(FALSE);\n");
    fprintf(fp,"    if (len==0) return(TRUE);\n");
    fprintf(fp,"    return(write_fixed(fp,s,len));\n}\n");
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/F read_fixed\n");
    fprintf(fp,"\/\/S read a fixed length block from a file\n");
    fprintf(fp,"\/\/D read a fixed length block from a file\n");
    fprintf(fp,"\/\/P the file pointer\n");
    fprintf(fp,"\/\/P the block pointer\n");
    fprintf(fp,"\/\/P the length of the block\n");
    fprintf(fp,"\/\/R TRUE if ok, otherwise FALSE\n");
    fprintf(fp,"BOOL read_fixed(FILE *fp,void *buf,INT len)\n");
    fprintf(fp,"{\n");
    fprintf(fp,"    if (fread(buf,1,len,fp)!=len) return(FALSE);\n");
    fprintf(fp,"    return(TRUE);\n}\n");
    fprintf(fp,"\/\/============================================================================\n");
    fprintf(fp,"\/\/F read_varib\n");
    fprintf(fp,"\/\/S read a variable length string from a file\n");
    fprintf(fp,"\/\/D read a variable length string from a file\n");
    fprintf(fp,"\/\/P the file pointer\n");
    fprintf(fp,"\/\/P the pointer to the string pointer\n");
    fprintf(fp,"\/\/R TRUE if ok, otherwise FALSE\n");
    fprintf(fp,"BOOL read_varib(FILE *fp,CHAR **s)\n");
    fprintf(fp,"{\n");
    fprintf(fp,"    INT len;\n");
    fprintf(fp,"    if (fread(&len,1,sizeof(INT),fp)!=sizeof(INT)) return(FALSE);\n");
    fprintf(fp,"    if (len==0) {\n        *s=NULL;\n        return(TRUE);\n    }\n");
    fprintf(fp,"    if ((*s=MALLOC(len+1))==NULL) return(FALSE);\n");
    fprintf(fp,"    if (!read_fixed(fp,*s,len)) return(FALSE);\n");
    fprintf(fp,"    *((*s)+len)=0;\n");
    fprintf(fp,"    return(TRUE);\n}\n");
}
void gencfile(DSTRUCTS *ds)
{
    CHAR name[100];
    FILE *fp;

    sprintf(name,"%s.C",G_modulename);
    if ((fp=fopen(name,"w"))==NULL) fp=stdout;
    filehead(fp,name);

    sprintf(name,"%s_C",G_modulename);
    fprintf(fp,"#define %s\n\n",name);
    sprintf(name,"%s.H",G_modulename);
    strlwr(name);
    fprintf(fp,"#include <stdio.h>  \/\/ FILE printf fread fwrite etc.\n");
    fprintf(fp,"#include <string.h> \/\/ strlen\n");
    fprintf(fp,"#include <malloc.h> \/\/ malloc free\n");
    fprintf(fp,"\n#include \"%s\"\n\n",name);
    if (G_debug) fprintf(fp,"#include \"deballoc.h\"\n");

    blockheader(fp,"DEFINITIONS");
    imodule(fp,"CS",ds);
    stdrdwrfuncs(fp);
    genfuncs(fp,ds,0,DEFINEFUNC,PUBLICFUNC);
    genfindfuncs(fp,ds,DEFINEFUNC);

    imodule(fp,"CE",ds);
    blockheader(fp,"END OF FILE");
    fflush(fp);
    if (fp!=stdout) fclose(fp);
}
void gends(DSTRUCTS *ds)
{
    INT i,j;

    for (i=0;i<ds->numstruct;i++) {
        printf("%s {",ds->structs[i].name);
        for (j=0;j<ds->structs[i].numbelem;j++) {
            printf("\"%s\"",ds->structs[i].elements[j].name);
            if (j<ds->structs[i].numbelem-1) printf(","); else printf("}\n");
        }
    }
}

int main(int argc,char *argv[])
{
    DSTRUCTS ds;

    ds.numstruct=0;
    ds.structs=NULL;

    G_checkfreq=1000U;
    if (argc<2) {
        fprintf(stderr,"Usage - %s DEF_FILE [DEBUG]",argv[0]);
        return 1;
    }
    if (argc==3) G_debug=1;
    strcpy(G_deffile,argv[1]);
    if (!loadfile(G_deffile,&ds)) {
        fprintf(stderr,"Error reading file - %s\n",G_deffile);
        return 2;
    }
//    gends(&ds);
    genhfile(&ds);
    gencfile(&ds);
    emptyds(&ds);
    return 0;
}
