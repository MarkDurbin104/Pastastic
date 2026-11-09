#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>

#include "types.h"
#include "linklist.h"
#include "filelist.h"
#include "srcdec.h"

BOOL included(CHAR *f)
{
    static CHAR *flist=NULL;
    static CHAR file[100];
    int n;

    if (f==NULL) return FALSE;

    strcpy(file,f);
    strcat(file,",");
    if ((flist==NULL)||(strstr(flist,file)==NULL)) {
        addtolist(file,&flist,&n);
        return FALSE;
    }
    return TRUE;
}
BOOL isresword(CHAR *word)
{
    INT i=0;
    while (G_reswords[i]!=NULL) {
        if (!strcmp(G_reswords[i],word)) return TRUE;
        i++;
    }
    return FALSE;
}
BOOL isfunction(CHAR *word,LINK *funcs)
{
    while (funcs!=NULL) {
        if (link_getelem(funcs)!=NULL) {
            if (!strcmp(link_getelem(funcs),word)) return TRUE;
        }
        funcs=link_getnext(funcs);
    }
    return FALSE;
}

BOOL isident(CHAR c)
{
    return (isalnum(c)||(c=='_'));
}
BOOL isarith(CHAR c)
{
    return ((c=='+')||(c=='-')||(c=='*')||(c=='\\'));
}
BOOL isboolean(CHAR c)
{
    return (  (c=='>')||(c=='<')||(c=='!')||(c=='|')
            ||(c=='&')||(c=='^')||(c=='=')          );
}
CHAR *gettoken(CHAR *l,INT toknum)
{
    static CHAR line[LINESIZE+1]; // local buffer
    static CHAR error_ret=0;
    CHAR *retval;

    if (l==NULL) return &error_ret;
    strcpy(line,l);
    retval=strtok(line,"þ");
    while ((retval!=NULL)&&(toknum)) {
        retval=strtok(NULL,"þ");
        toknum--;
    }
    if (retval==NULL) return &error_ret;
    return retval;
}
CHAR *extract_token(CHAR *l)
{
    static CHAR line[LINESIZE+1]; // local buffer
    static CHAR *start;           // current position in line
    static CHAR *endoftok;        // end of token in line
    static CHAR temphold;         // temp buffer for char at terminating pos
    if (l!=NULL) {                // a new line
        strcpy(line,l);
        start=line;
    } else {
        start=endoftok;
        *start=temphold;
    }
    while ((*start)&&isspace(*start)) start++;
    if (!(*start)) {
        line[0]=0;
        start=NULL;
        endoftok=line;
        temphold=0;
    } else {
        endoftok=start;
        if (isident(*endoftok)) {
            while ((*endoftok)&&( isident(*endoftok))) endoftok++;
        } else if (isarith(*endoftok)) {
            while ((*endoftok)&&(isarith(*endoftok))) endoftok++;
            if (*endoftok=='=') endoftok++;
            if ((*(endoftok-1)=='-')&&(*endoftok=='>')) endoftok++;
        } else if (isboolean(*endoftok)) {
            while ((*endoftok)&&(isboolean(*endoftok))) endoftok++;
        } else if (*endoftok=='"') {
            endoftok++;
            while ((*endoftok)&&(*endoftok!='"')) {
                if ((*endoftok=='\\')) endoftok++;
                endoftok++;
            }
            endoftok++;
        } else if (*endoftok=='\'') {
            endoftok++;
            while ((*endoftok)&&(*endoftok!='\'')) {
                if ((*endoftok=='\\')) endoftok++;
                endoftok++;
            }
            endoftok++;
        } else {
            endoftok++;
        }
        temphold=*endoftok;
        *endoftok=0;
    }
    return start;
}
//============================================================================
//F parse_line
//S Parse a line of source code.
//D Parse a line of source code.
//P The line array ( must be of size LINESIZE +1 ) 
void parse_line(CHAR l[])
{
    static CHAR line[LINESIZE+1]; // local buffer
    static BOOL incomment=FALSE;  // flag for block comments
    CHAR *start=line;             // the start of the line
    CHAR *scan;                   // scan pointer
    CHAR *end;                    // the end of the line
    strcpy(line,l);               // make local copy
    end=start+strlen(l)-1;        // move to end of line

    // remove trailing CR/LF
    while ((end>=start)&&((*end=='\r')||(*end=='\n'))) *(end--)=0;

    if (incomment) {
        while ((*start)&&(incomment)) {
            if ((*start=='*')&&(*(start+1)=='\/')) {
                start++;
                incomment=FALSE;
            }
            start++;
        }
    } else {
        scan=start;
        while (*scan) {
            if ((*scan=='\/')&&(*(scan+1)=='\/')) {
                *scan=0;
            } else if ((*scan=='\/')&&(*(scan+1)=='*')) {
                incomment=TRUE;
                *scan=' ';
                *(scan+1)=' ';
                scan+=2;
                while (*scan) {
                    if ((*scan=='*')&&(*(scan+1)=='\/')) {
                        *scan=' ';
                        *(scan+1)=' ';
                        incomment=FALSE;
                    } else {
                        *scan=' ';
                    }
                    scan++;
                }
            } else {
                scan++;
            }
        }    
    }
    l[0]=0;
    scan=extract_token(start);
    while (scan!=NULL) {
        strcat(l,scan);
        scan=extract_token(NULL);
        if (scan!=NULL) strcat(l,"þ");
    }
    end=l+strlen(l)-1;
    // remove trailing SPACE
    while ((end>=l)&&(isspace(*end))) *(end--)=0;
}
//============================================================================
//F save_line
//S Save a line of source code.
//D Save a line of source code.
//P The line
//P The source buffer structure to fill
void save_line(CHAR *line,SRCBUF *sb)
{
    LINE *lbuf;                      // local line buffer
    CHAR *token;                     // token pointer

    sb->numblines++;               // adjust number of lines
    if (*line==0) return;          // invalid line !

    parse_line(line);              // parse the line
    if (*line==0) return;          // empty line !
    token=gettoken(line,0);        // get the first token
    if (*token=='#') {             // compiler directive
        if (!strcmp("include",gettoken(line,1))) {   // include a file
            token=gettoken(line,2);
            if (*token=='"') {
                token[strlen(token)-1]=0;
                if (!included(token+1)) loadfile(token+1,sb,1);
                return;
            }
        }
    }
    lbuf=MALLOC(sizeof(LINE));     // get a line buffer
    if (lbuf==NULL) return;        // allocation error !
    lbuf->line=STRDUP(line);       // copy line
    if (lbuf->line==NULL) return;  // allocation error !
    lbuf->next=NULL;               // set to the last line

    if (sb->firstline==NULL) {     // first line in buffer
        lbuf->prev=NULL;           // set NO previous lines
        sb->lastline =lbuf;        // set last line to this
        sb->firstline=lbuf;        // set first line to this
    } else {
        lbuf->prev=sb->lastline;   // set this line's prev to last line
        sb->lastline->next=lbuf;   // set the last line's next to this
        sb->lastline =lbuf;        // make this the last line in buffer
    }
}
//============================================================================
//F loadfile
//S Load a source file into memory
//D Load a source file into memory and include all it's 
//D local include files i.e. #include "foobar.h".
//P The file name
//P The source buffer structure that will hold the file
//P TRUE if it is a local include file
//R TRUE if file can be opened for read and sb is a valid structure
INT loadfile(CHAR *name,SRCBUF *sb,BOOL incfile)
{
    static CHAR line[LINESIZE+1];               // buffer for each line
    FILE *fp;                                   // input file pointer

    if (sb==NULL) return FALSE;                 // invalid structure !
    if ((name==NULL)||(*name==0)) return FALSE; // invalid file name !

    if ((fp=fopen(name,"r"))!=NULL) {           // if the file opens for read
        if (!incfile) {                         // newfile - setup line buffer
            sb->filename=STRDUP(name);          // set the file name
            sb->firstline=NULL;                 // reset first line
            sb->lastline=NULL;                  // reset last line
            sb->numblines=0;                    // reset number of lines
        }
        while (fgets(line,255,fp)!=NULL) {      // read each line of the file
            save_line(line,sb);                 // save line in the buffer
        }
        fclose(fp);                             // close the file
        return TRUE;                            // all OK
    }
    return FALSE;                               // file open failure !
}
//===========================================================================
CHAR *next_token(SRCBUF *sb)
{
    static CHAR line[LINESIZE+1]; // local buffer
    static LINE *lbuf=NULL;
    static INT state=0;
    static CHAR *token=NULL;

    if (sb==NULL) return NULL;
    if (state==0) lbuf=sb->firstline;

    while (lbuf!=NULL) {
        if (state!=1) {
            strcpy(line,lbuf->line);
            token=strtok(line,"þ");
        }
        while (token!=NULL) {
            if (state!=1) {
                state=1;
                return token;
            }
            token=strtok(NULL,"þ");
            state=2;
        }
        state=2;
        lbuf=lbuf->next;
    }
    state=0;
    return token;
}
void freefilebuf(SRCBUF *sb)
{
    LINE *lbuf;
    if (sb==NULL) return;

    lbuf=sb->firstline;
    while (lbuf!=NULL) {
        FREE(lbuf->line);
        if (lbuf->next!=NULL) {
            lbuf=lbuf->next;
            FREE(lbuf->prev);
        } else {
            FREE(lbuf);
            lbuf=NULL;
        }
    }
    FREE(sb->filename);
    sb->filename =NULL;
    sb->firstline=NULL;
    sb->lastline =NULL;
    sb->numblines=0;
}
void listfile(SRCBUF *sb)
{
    LINE *lbuf;
    if (sb==NULL) return;

    printf("Source file - \"%s\"\n\n",sb->filename);
    lbuf=sb->firstline;
    while (lbuf!=NULL) {
        printf("%s\n",lbuf->line);           
        lbuf=lbuf->next;
    }
    printf("%d Lines\n",sb->numblines);
}
INT tokentype(CHAR *token)
{
    if (isalnum(*token))                  return IDENT;
    if (!strcmp(token,"="))               return ASSIGN;
    if ((*token=='+')&&(*(token+1)=='+')) return AASSIGN;
    if ((*token=='-')&&(*(token+1)=='-')) return AASSIGN;
    if (*token=='{')                      return OCURLY;
    if (*token=='}')                      return CCURLY;
    if (*token=='(')                      return OPAREN;
    if (*token==')')                      return CPAREN;
    if (isboolean(*token))                return BOOLT;
    if (isarith(*token))  {
        if (*(token+1)=='=')              return AASSIGN;
        return ARITH;
    }
    if (*token==';')                      return ENDOFST;

    return PUNCT;                      // Must be punctuation !
}
void collect_funcnames(SRCBUF *s,LINK **funcs)
{
    static CHAR lastfuncname[LINESIZE+1];
    static CHAR lasttoken[LINESIZE+1];
    INT  lasttoktype=0;
    INT  toktype;
    INT  depth=0;
    CHAR *token;
    lastfuncname[0]=0;
    while ((token=next_token(s))!=NULL) {
        toktype=tokentype(token);
        switch (toktype) {
            case ENDOFST :
                lastfuncname[0]=0;
                break;
            case OCURLY :
                if ((depth==0)&&(lastfuncname[0]!=0)) {
                    if (*funcs==NULL) {
                        link_setup(funcs,STRDUP(lastfuncname));
                    } else {
                        link_append(*funcs,STRDUP(lastfuncname));
                    }
                }
                lastfuncname[0]=0;
                depth++;
                break;
            case CCURLY :
                lastfuncname[0]=0;
                depth--;
                break;
            case OPAREN :
                if ((lasttoktype==IDENT)&&(depth==0)) {
                    strcpy(lastfuncname,lasttoken);
                } else {
                    lastfuncname[0]=0;
                }
                break;
        }
        lasttoktype=toktype;
        strcpy(lasttoken,token);
    }
}
void addtolist(CHAR *str,CHAR **list,INT *numitem)
{
    if (*list==NULL) {
        *list=MALLOC(strlen(str)+2);
        if (*list==NULL) return;
        strcpy(*list,str);
        strcat(*list,",");
        (*numitem)++;
    } else {
        if (strstr(*list,str)==NULL) {
            *list=REALLOC(*list,strlen(*list)+strlen(str)+2);
            strcat(*list,str);
            strcat(*list,",");
            (*numitem)++;
        }
    }
}
void printlist(char *type,char *list,int numl)
{
    char *t;
    if (numl) {
        printf("%s :-\n",type);
        t=strtok(list,",");
        while (t!=NULL) {
            printf("%s",t);
            if (--numl) printf(",");
            t=strtok(NULL,",");
        }
        printf("\n");
    }
}
void parse_tokens(SRCBUF *s,LINK *funcs)
{
    static CHAR lasttoken[LINESIZE+1];
    static CHAR currentfunc[LINESIZE+1];
    INT  lasttoktype=0;
    INT  toktype;
    INT  depth=0;
    CHAR *token;
    CHAR *modlist=NULL;
    CHAR *calllist=NULL;
    INT  numcalls=0;
    INT  nummods=0;


    currentfunc[0]=0;
    while ((token=next_token(s))!=NULL) {
        toktype=tokentype(token);
        switch (toktype) {
            case ENDOFST :
                currentfunc[0]=0;
                break;
            case OCURLY :
                if ((depth==0)&&(currentfunc[0]!=0)) {
                    printf("%s()\n",currentfunc);
                }
                currentfunc[0]=0;
                depth++;
                break;
            case CCURLY :
                currentfunc[0]=0;
                depth--;
                if (!depth) {
                    if (numcalls) {
                        printlist("Calls",calllist,numcalls);
                        FREE(calllist);
                        calllist=NULL;
                        numcalls=0;
                    }
                    if (nummods) {
                        printlist("Modifies",modlist,nummods);
                        FREE(modlist);
                        modlist=NULL;
                        nummods=0;
                    }
                }
                break;
            case IDENT :
                break;
            case ASSIGN :
            case AASSIGN :
                if ((lasttoktype==IDENT)&&(depth)) {
                    addtolist(lasttoken,&modlist,&nummods);
                }
                break;
            case OPAREN :
                if (lasttoktype==IDENT) {
                    if (depth==0) {
                        strcpy(currentfunc,lasttoken);
                    } else {
                        currentfunc[0]=0;
                        if ((!isresword(lasttoken))&&(isfunction(lasttoken,funcs))) {
                            addtolist(lasttoken,&calllist,&numcalls);
                        }
                    }
                }
                break;
            case CPAREN :
                break;
        }
        lasttoktype=toktype;
        strcpy(lasttoken,token);
    }
}
int main(int argc,char *argv[])
{
    SRCBUF *s;
    LINK *funcs=NULL;
    LINK *funciter;
    LINK *files=NULL;
    LINK *fileiter;
    int i;
    long j;

    if (argc<2) {
        fprintf(stderr,"Usage - %s FILESPEC",argv[0]);
        return 1;
    }
    for (i=1;i<argc;i++) findfile(argv[i],1,&files);
    if (link_count(files)==0) {
        fprintf(stderr,"No valid files specified\n");
        return 2;
    }
    s=MALLOC(link_count(files)*sizeof(SRCBUF));
    if (s==NULL) {
        fprintf(stderr,"Out of memory\n");
        return 3;
    }
    fileiter=files;
    i=0;
    while (fileiter!=NULL) {
        if (link_getelem(fileiter)) {
           if (!loadfile(link_getelem(fileiter),&(s[i]),0)) {
                fprintf(stderr,"Error reading file - %s\n",link_getelem(fileiter));
                return 4;
            }
        }
        collect_funcnames(&(s[i]),&funcs);
        i++;
        fileiter=link_getnext(fileiter);
    }
    funciter=funcs;
    while (funciter!=NULL) {
        if (link_getelem(funciter)) printf("%-40.40s",link_getelem(funciter));
        funciter=link_getnext(funciter);
    }
    printf("\n%d Functions\n",link_count(funcs));
    j=0L;
    for (i=0;i<link_count(files);i++) {
        printf("File %s - %ld Lines\n",s[i].filename,s[i].numblines);
        j+=(long)s[i].numblines;
    }
    printf("%d Files - %ld Lines\n",link_count(files),j);

//    listfile(s);

//    parse_tokens(&s,funcs);

    for (i=0;i<link_count(files);i++) freefilebuf(&s[i]);
    FREE(s);

    link_reset(&funcs,TRUE);
    link_reset(&files,TRUE);
    return 0;
}
