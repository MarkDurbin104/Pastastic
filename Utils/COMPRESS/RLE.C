#include <stdio.h>
#include <string.h>

#define LINELENGTH 0x100
#define MAXCOUNT   0x7F
#define FLAGCHAR   1

#define TRUE       1
#define FALSE      0

char *comp(char *str)
{
    static char buildln[LINELENGTH+1];      // storage for return val
    char lastchr;                           // the last character read
    char count=1;                           // the current run length
    char *inspoint=buildln;                 // the current insertion point
    char *s=str;                            // current character pointer

    lastchr=*(s++);                         // setup last character read
    while (*s) {                            // work through length of string
        if (*s==lastchr) {                  // same again
            if (count<MAXCOUNT) {           // just inc count
                count++;
            } else {                        // max count reached
                *(inspoint++)=FLAGCHAR;
                *(inspoint++)=count;
                *(inspoint++)=lastchr;
                count=1;
            }
        } else {
            if (count>2) {
                *(inspoint++)=FLAGCHAR;
                *(inspoint++)=count;
                *(inspoint++)=lastchr;
                count=1;
            } else {
                while (count--) *(inspoint++)=lastchr;
                count=1;
            }
        }
        lastchr=*(s++);
    }
    if (count>2) {
        *(inspoint++)=FLAGCHAR;
        *(inspoint++)=count;
        *(inspoint++)=lastchr;
        count=1;
    } else {
        while (count--) *(inspoint++)=lastchr;
        count=1;
    }
    *inspoint=0;
    return buildln;
}
char *decomp(char *str)
{
    static char buildln[LINELENGTH+1];      // storage for return val
    char *inspoint=buildln;                 // the current insertion point
    int  count;                             // character count
    char *s=str;                            // current character pointer

    while (*s) {                            // work through length of string
        if (*s==FLAGCHAR) {
            s++;
            count=*(s++);
            while (count--) *(inspoint++)=*s;
        } else {
            *(inspoint++)=*s;
        }
        s++;
    }
    *inspoint=0;
    return buildln;
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
            lineno++;
            if (lineno==1) {
                if (!strncmp(line,"RLE01",5)) {
                    printf("%s",decomp(&line[5]));
                    decompress=TRUE;
                } else {
                    decompress=FALSE;
                    printf("RLE01");
                    printf("%s",comp(line));
                }
            } else {
                if (decompress) {
                    printf("%s",decomp(line));
                } else {
                    printf("%s",comp(line));
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
