#include <stdio.h>
int main(int argc,char *argv[])
{
    FILE *fp;
    char s[100];
    if (argc<2) {
        fprintf(stderr,"%s filename\n",argv[0]);
        return 1;
    }
    if ((fp=fopen(argv[1],"r"))!=NULL) {
        while (fgets(s,99,fp)!=NULL) {
            printf("%s",s);
        }
        fclose(fp);
    }
    return 0;
}

