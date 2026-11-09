#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "types.h"
#include "interp.h"
#include "deballoc.h"

#define isident(a) ((G_chartab[a]==NUMBT||G_chartab[a]==IDENT))
#define etype(a,b,c) (c->structs[a].elements[b].type)
#define ename(a,b,c) (c->structs[a].elements[b].name)
#define sname(a,c)   (c->structs[a].name)
#define numelem(a,c) (c->structs[a].numbelem)

INT loadfile(CHAR *name,DSTRUCTS *ds);

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
void add_dtype(CHAR *name,INT type,CHAR *ename,DSTRUCTS *ds)
{
    INT i;
    if (ds->structs==NULL) {
        if ((ds->structs=MALLOC(sizeof(DSTRUCT)))==NULL) return;
        ds->numstruct=1;
        ds->structs[0].name=STRDUP(name);
        ds->structs[0].numbelem=1;
        if ((ds->structs[0].elements=MALLOC(sizeof(DELEM)))==NULL) return;
        ds->structs[0].elements[0].type=type;
        ds->structs[0].elements[0].name=STRDUP(ename);
        ds->structs[0].evsize=ds->structs[0].numbelem*sizeof(EVALUE);
        ds->structs[0].evalues=MALLOC(ds->structs[0].evsize);
        ds->structs[0].numbev=0;
        return;
    }
    for (i=0;i<ds->numstruct;i++) {
        if (!strcmp(ds->structs[i].name,name)) {
            if ((ds->structs[i].elements=REALLOC(ds->structs[i].elements,sizeof(DELEM)*(ds->structs[i].numbelem+1)))==NULL) return;
            ds->structs[i].elements[ds->structs[i].numbelem].type=type;
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
    if ((ds->structs[ds->numstruct].elements=MALLOC(sizeof(DELEM)))==NULL) return;
    ds->structs[ds->numstruct].elements[0].type=type;
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
        switch (etype(dtype,curelem,ds)) {
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
    token=line[1];
    if (!strcmp("include",token)) {  // include a file
        token=line[2];
        if (*token=='"') {
            token[strlen(token)-1]=0;
            loadfile(token+1,ds);
            return(FALSE);
        }
    }
    if (!strcmp("deftype",token)) {   // define a data type
        token=line[3];
        if (*token=='{') {
            strcpy(sname,line[2]);
            pos=4;
            token=line[pos];
            while ((*token)&&(*token!='}')) {
                pos++;
                switch (*token) {
                    case 'n' :
                    case 'N' :
                        add_dtype(sname,NUMBER,line[pos++],ds);
                        break;
                    case 's' :
                    case 'S' :
                        add_dtype(sname,STRING,line[pos++],ds);
                        break;
                    default  :
                        fprintf(stderr,"Error %s %d: unrecognised datatype %s\n",filename,lineno,token);
                        return (FALSE);
                }
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
        while (fgets(line,LINESIZE,fp)!=NULL) { // read each line of the file
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
                if (ds->structs[i].elements[j].type==STRING) {
                    FREE(ds->structs[i].evalues[k][j].str);
                    ds->structs[i].evalues[k][j].str=NULL;
                }
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
void listds(DSTRUCTS *ds,BOOL listvalues)
{
    INT i,j,k;

    for (i=0;i<ds->numstruct;i++) {
        if (ds->structs[i].numbev) {
            printf("struct %s {\n",ds->structs[i].name);
            for (j=0;j<ds->structs[i].numbelem;j++) {
                printf("    %s %s;\n",
                    ((ds->structs[i].elements[j].type==NUMBER)?"NUMBER":"STRING"),
                    ds->structs[i].elements[j].name);
            }
            printf("};\nSize %d Number of elements %d\n",ds->structs[i].evsize,ds->structs[i].numbev);
            if (listvalues) {
                for (k=0;k<ds->structs[i].numbev;k++) {
                    for (j=0;j<ds->structs[i].numbelem;j++) {
                        if (ds->structs[i].elements[j].type==NUMBER) {
                            printf("%.1lf ",ds->structs[i].evalues[k][j].numb);
                        } else {
                            printf("%s ",ds->structs[i].evalues[k][j].str);
                        }
                    }
                    printf("\n");
                }
            }
        }
    }
}
void gends(DSTRUCTS *ds)
{
    INT i,j;

    for (i=0;i<ds->numstruct;i++) {
        printf("%s {",ds->structs[i].name);
        for (j=0;j<ds->structs[i].numbelem;j++) {
            if (ds->structs[i].elements[j].type==NUMBER) {
                printf("%d.0",j);
            } else {
                printf("\"%s\"",ds->structs[i].elements[j].name);
            }
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
        fprintf(stderr,"Usage - %s FILENAME",argv[0]);
        return 1;
    }
    if (!loadfile(argv[1],&ds)) {
        fprintf(stderr,"Error reading file - %s\n",argv[1]);
        return 2;
    }
//    gends(&ds);
    listds(&ds,TRUE);
    emptyds(&ds);
    return 0;
}

