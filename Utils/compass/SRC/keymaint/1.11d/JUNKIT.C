#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <malloc.h>
#include <ctype.h>

int main(int argc,char *argv[])
{
    FILE *fp;
    int fl;
    int i,j;
    char *buf;
    if (argc<2) return 1;
    if ((fp=fopen(argv[1],"rb"))==NULL) return 2;
    fl=(int)filelength(fp->fd);
    if ((buf=malloc(fl))==NULL) {
        fclose(fp);
        return 3;
    }
    fread(buf,fl,1,fp);
    fclose(fp);
    for (i=50;i<fl;i++) buf[i]^=buf[i-49];
    if ((fp=fopen(argv[1],"wb"))==NULL) return 2;
    fwrite(buf,fl,1,fp);
    fclose(fp);
    free(buf);
    return 0;
}




