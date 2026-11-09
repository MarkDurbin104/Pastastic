#include <stdio.h>
int main(int argc,char *argv[])
{
    FILE *fp;
    char tmp[100],*s;

    if ((argc<2)||((fp=fopen(argv[1],"rb"))==NULL)) return 1;

    while (fgets(tmp,100,fp)) {
        s=tmp;
        while (*s) {
            if ((*s=='\r')||(*s=='\n')) *s=0;
            if (((*s&0x80)!=0)||(*s<32)) *s=32;
            s++;
        }
        fprintf(stdout,"%s\n",tmp);
    }
    fclose(fp);
    return 0;
}
