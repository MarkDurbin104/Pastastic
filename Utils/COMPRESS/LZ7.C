#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define IDSTR      "LZ701"
#define LINELENGTH 0x300

#define FLAGCHAR   1
#define NUMTOKENS  118
#define ENDOFLINE  (NUMTOKENS+3)
#define JUSTATOK   (NUMTOKENS+4)
#define TRUE       1
#define FALSE      0

void output(char token)
{
    if (token>=10) token++;  // LF
    if (token>=13) token++;  // CR+LF
    if (token>=26) token++;  // EOF+CR+LF
    printf("%c",token);
}
char input(char token)
{
    if (token>=27) token--;  // EOF+CR+LF
    if (token>=14) token--;  // CR+LF
    if (token>=11) token--;  // LF
    token-=2;
    return token;
}

char findtok(char *str,int *toklen)
{
    int i;
    char tokfound;
    static char *tokens[NUMTOKENS];
    static int firstin=TRUE;
    static int numtoks=0;
    static int newtok=0;

    if (firstin) {
        firstin=FALSE;
        for (i=0;i<NUMTOKENS;i++) {
            tokens[i]=NULL;
        }
    }

    if (*toklen>strlen(str)) return(0);

    for (i=0;i<numtoks;i++) {
        if (!strncmp(tokens[i],str,*toklen)) {
            if (*toklen==strlen(str)) {
                output(JUSTATOK+2);
                output((char)(i+2));
//                printf("\n");
                return 0;
            }
            (*toklen)++;
            newtok=0;
            tokfound=findtok(str,toklen);
            if ((tokfound)&&(newtok)) {
                output((char)(i+2));
                newtok=0;
            }
            return tokfound;
        }
    }
    if (numtoks<NUMTOKENS) {
        if (tokens[numtoks]!=NULL) free(tokens[numtoks]);
        tokens[numtoks]=malloc(*toklen+1);
        memcpy(tokens[numtoks],str,*toklen);
        tokens[numtoks][*toklen]=0;
        numtoks++;
        newtok=1;
        return numtoks;
    }
    for (i=0;i<NUMTOKENS;i++) {
        if (tokens[i]!=NULL) free(tokens[i]);
        tokens[i]=NULL;
    }
    numtoks=1;
    *toklen=1;
    tokens[0]=malloc(2);
    tokens[0][0]=*str;
    tokens[0][1]=0;
    output(FLAGCHAR);
    return 1;
}
void comp(char *str)
{
    char *s=str;
    int  toklen;
    char token=1;

    while (*s) { (*s)-=8; s++; }
    s=str;
    while (*s) {
        toklen=1;
        token=findtok(s,&toklen);
        if (token) {
            output(token+1);
            output((*(s+toklen-1))+2);
        }
        if (toklen<strlen(s)) {
            s+=toklen;
        } else {
            s+=strlen(s);
        }
    }
    if (token) {
        printf("\n");
    }
}
void decomp(char *str)
{
    static char *tokens[NUMTOKENS+5];
    static int firstin=TRUE;
    char *s=str;
    int i;

    if (firstin) {
        firstin=FALSE;
        for (i=0;i<NUMTOKENS+5;i++) {
            tokens[i]=NULL;
        }
    }
    while (*s) {
        if (*s==FLAGCHAR) {
            for (i=0;i<NUMTOKENS+5;i++) {
                if (tokens[i]!=NULL) free(tokens[i]);
                tokens[i]=NULL;
            }
        } else if (input(*s)==JUSTATOK) {
            s++;
            if (tokens[*s]==NULL) {
                fprintf(stderr,"Error Repeat Non Existing token\n");
            } else {
                printf("%s\n",tokens[*s]);
            }
        } else {
            if ((*s>=(NUMTOKENS+5))||(*s<1)) {
                fprintf(stderr,"Error token out of range - %d\n",*s);
            }
            if (tokens[*s]==NULL) {
                tokens[*s]=malloc(2);
                tokens[*s][0]=input(*(s+1))+8;
                tokens[*s][1]=0;
                printf("%s",tokens[*s]);
                s++;
            } else {
                if (*(s+1)) {
                    if ((*(s+1)>=(NUMTOKENS+5))||(*(s+1)<1)) {
                        fprintf(stderr,"Error token1 out of range - %d\n",*(s+1));
                    }
                    tokens[*(s+1)]=malloc(strlen(tokens[*s])+2);
                    memcpy(tokens[*(s+1)],tokens[*s],strlen(tokens[*s]));
                    tokens[*(s+1)][strlen(tokens[*s])]=input(*(s+2))+8;
                    tokens[*(s+1)][strlen(tokens[*s])+1]=0;
                    printf("%s",tokens[*(s+1)]);
                    s++;
                } else {
                    printf("%s",tokens[*s]);
                }
                s++;
            }
        }
        s++;
    }
    printf("\n");
}
void remcrlf(char *line)
{
    char *end=line;
    if ((line==NULL)||(*line==0)) return;
    end+=strlen(line)-1;
    while ((*end)&&((*end=='\n')||(*end=='\r'))) *(end--)=0;
}
//============================================================================
//F loadfile
//S Load a source file into memory
//D Load a source file into memory and include all it's 
//D local include files i.e. #include "foobar.h".
//P The file name
//R TRUE if file can be opened for read and sb is a valid structure
int loadfile(char *name)
{
    static char line[LINELENGTH+1];             // buffer for each line
    int lineno=0;                               // current line number
    FILE *fp;                                   // input file pointer
    int decompress;                             // TRUE if decompressing

    if ((name==NULL)||(*name==0)) return FALSE; // invalid file name !

    if ((fp=fopen(name,"r"))!=NULL) {           // if the file opens for read
        while (fgets(line,LINELENGTH,fp)!=NULL) {  // read each line
            remcrlf(line);
            lineno++;
            if (lineno==1) {
                if (!strncmp(line,IDSTR,5)) {
                    decomp(&line[5]);
                    decompress=TRUE;
                } else {
                    decompress=FALSE;
                    printf(IDSTR);
                    comp(line);
                }
            } else {
                if (decompress) {
                    decomp(line);
                } else {
                    comp(line);
                }
            }
        }
        fclose(fp);                             // close the file
        return TRUE;                            // all OK
    }
    return FALSE;                               // file open failure !
}
int main(int argc,char *argv[])
{
    if (argc<2) {
        fprintf(stderr,"Usage - %s FILENAME",argv[0]);
        return 1;
    }
    if (!loadfile(argv[1])) {
        fprintf(stderr,"Error reading file - %s\n",argv[1]);
        return 2;
    }
    return 0;
}

