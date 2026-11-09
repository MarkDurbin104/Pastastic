#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys\timeb.h>

char *datestr(int dt) 
{
    static char dtmp[20];
    static char ttmp[20];
    struct tm *t;
    struct timeb tb;
    ftime(&tb);
    t=localtime(&tb.time);
    if (dt) {
        sprintf(dtmp,"%02d/%02d/%02d",t->tm_mday,t->tm_mon+1,t->tm_year);
        return(dtmp);
    }
    sprintf(ttmp,"%02d:%02d:%02d",t->tm_hour,t->tm_min,t->tm_sec);
    return(ttmp);
}
void compfiles(char *n1,char *n2)
{
    FILE *fp1,*fp2;
    char ln1[260];
    char ln2[260];
    int i,rl,t;
    fpos_t fo,fn;
    unsigned fc1=0,s=0;

    fp2=fopen(n2,"r");
    fp1=fopen(n1,"r");
    printf("%s %s %s %s\n",n1,n2,datestr(1),datestr(0));
    while (fgets(ln1,256,fp1)!=NULL) {
        fc1++;
        fgetpos(fp2,&fo);
        if (fgets(ln2,256,fp2)!=NULL) {
            if (strcmp(ln1,ln2)) {
                i=1;
                rl=0;
                fgetpos(fp2,&fn);
                while ((fgets(ln2,256,fp2)!=NULL)&&(!rl)) {
                    if (!strcmp(ln1,ln2)) {
                        fseek(fp2,fn,SEEK_SET);
                        if (fc1!=s) {
                            if (((fc1-1)-s)!=0) printf("t%d\n",(fc1-1)-s);
                            s=fc1-1;
                        }
                        printf("s%d\n",i);
                        rl=1;
                    }
                    i++;
                    fgetpos(fp2,&fn);
                }
                if (!rl) {
                    if (fc1!=s) {
                        if (((fc1-1)-s)!=0) printf("t%d\n",(fc1-1)-s);
                        s=fc1;
                    }
                    printf("i%s",ln1);
                    fseek(fp2,fo,SEEK_SET);
                }
            }
        }
        else {
            if (fc1!=s) {
                if (((fc1-1)-s)>0) printf("t%d\n",(fc1-1)-s);
                s=fc1;
            }
            printf("i%s",ln1);
        }
    }
    i=0;
    while (fgets(ln2,256,fp2)!=NULL) i++;
    if (i!=0) printf("s%d\n",i);
    if (fc1!=s) printf("t%d\n",fc1-s);

    fclose(fp1);
    fclose(fp2);
}

int main(int argc,char *argv[])
{
    FILE *fp1,*fp2;

    if (argc<3) {
        fprintf(stderr,"acomp new-file1 old-file2\n");
        return(1);
    }

    compfiles(argv[1],argv[2]);

    return(0);
}
