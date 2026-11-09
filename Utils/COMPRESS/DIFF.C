#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define TRUE  1
#define FALSE 0

char *moveup(char *str,int dist)
{
    if (dist) return str+dist;
    return str; // ?????
}
int matchstr(char *str1,char *str2)
{
    return strcmp(str1,str2);
}
void compare(char *f1buf,char *f2buf,int f1len,int f2len)
{
    char *curpos1=f1buf;
    char *curpos2=f2buf;
    char *endpos1=f1buf+f1len;
    char *endpos2=f2buf+f2len;
    int comp;
    while (curpos1<endpos1) {
        comp=matchstr(curpos1,curpos2);
        if (!comp) {
            curpos1=moveup(curpos1,0);
            curpos2=moveup(curpos2,0);
        } else {
            if (comp>0) {
                curpos1=moveup(curpos1,comp);
            } else {
                curpos2=moveup(curpos2,0-comp);
            }
        }
    }
    moveup(curpos2,(int)(endpos2-curpos2));
}
int readfiles(char *file1,char *file2,int *f1len,int *f2len,char **f1buf,char **f2buf)
{
    FILE *f1,*f2;
    if ((f1=fopen(file1,"rb"))==NULL) {
        fprintf(stderr,"Can't open %s\n",file1);
        return FALSE;
    }
    if ((f2=fopen(file2,"rb"))==NULL) {
        fprintf(stderr,"Can't open %s\n",file2);
        fclose(f1);
        return FALSE;
    }

    fseek(f1,0,SEEK_END); *f1len=(int)ftell(f1); fseek(f1,0,SEEK_SET);
    fseek(f2,0,SEEK_END); *f2len=(int)ftell(f2); fseek(f2,0,SEEK_SET);

    if ((*f1buf=malloc(*f1len))==NULL) {
        fprintf(stderr,"Out of memory\n");
        fclose(f1);
        fclose(f2);
        return FALSE;
    }
    if ((*f2buf=malloc(*f2len))==NULL) {
        fprintf(stderr,"Out of memory\n");
        fclose(f1);
        fclose(f2);
        free(f1buf);
        return FALSE;
    }
    if (fread(*f1buf,1,*f1len,f1)!=*f1len) {
        fprintf(stderr,"Can't read %s\n",file1);
        fclose(f1);
        fclose(f2);
        free(f1buf);
        free(f2buf);
        return FALSE;
    }
    if (fread(*f2buf,1,*f2len,f2)!=*f2len) {
        fprintf(stderr,"Can't read %s\n",file2);
        fclose(f1);
        fclose(f2);
        free(f1buf);
        free(f2buf);
        return FALSE;
    }
    fclose(f1);
    fclose(f2);
    return TRUE;
}
int main(int argc,char *argv[])
{
    int f1len;
    int f2len;
    char *f1buf;
    char *f2buf;

    if (argc<3) {
        fprintf(stderr,"%s file1 file2\n",argv[0]);
        return 1;
    }
    if (!readfiles(argv[1],argv[2],&f1len,&f2len,&f1buf,&f2buf)) {
        return 1;
    }
    compare(f1buf,f2buf,f1len,f2len);
    return 0;
}
