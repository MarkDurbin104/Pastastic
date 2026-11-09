#include <stdio.h>
#include <ctype.h>
int main(int argc,char *argv[])
{
    FILE *fp;
    int ch,i;
    if (argc<2) {
        fprintf(stderr,"Usage %s FILE\n",argv[0]);
        return 0;
    }
    if ((fp=fopen(argv[1],"rb"))==NULL) {
        fprintf(stderr,"Can't open %s\n",argv[1]);
        return 0;
    }
    if ((ch=fgetc(fp))!=0xFF) { fprintf(stderr,"Error 1\n"); fclose(fp); return 1; }
    i=fgetc(fp);
    while (--i) {
        ch=fgetc(fp);
        if (isprint(ch))
            putc(ch,stdout);
        else
            fprintf(stdout,"<%02X>",ch);
    }
    putc('\n',stdout);
    for (i=0;i<4;i++) {
        fprintf(stdout,"<%02X>",fgetc(fp));
    }
    putc('\n',stdout);
    for (i=0;i<18;i++) {
        ch=fgetc(fp);
        if (isprint(ch))
            putc(ch,stdout);
        else
            fprintf(stdout,"<%02X>",ch);
    }
    putc('\n',stdout);
    while ((i=fgetc(fp))!=EOF) {
        while (!i) {
            while (!i) i=fgetc(fp);
            if (i==EOF) break;
            printf("\nObject ",i);
            while (i--) {
                ch=fgetc(fp);
                if (isprint(ch))
                    putc(ch,stdout);
                else
                    fprintf(stdout,"<%02X>",ch);
            }
            i=fgetc(fp);
            printf(" Name ",i);
            while (i--) {
                ch=fgetc(fp);
                if (isprint(ch))
                    putc(ch,stdout);
                else
                    fprintf(stdout,"<%02X>",ch);
            }
            printf("\n",i);
            i=fgetc(fp);
        }
        if (i==EOF) break;
        printf("",i);
        while (i--) {
            ch=fgetc(fp);
            if (isprint(ch))
                putc(ch,stdout);
            else
                fprintf(stdout,"<%02X>",ch);
        }
        printf(" ");
        i=fgetc(fp);
        switch (i) {
            case 11 :
            case 2 :
                fprintf(stdout,"%d\n",fgetc(fp));
                break;
            case 3 :
                i=fgetc(fp);
                i|=(fgetc(fp)<<8);
                fprintf(stdout,"%d\n",i);
                break;
            case 6 :
            case 7 :
                i=fgetc(fp);
                while (i--) {
                    ch=fgetc(fp);
                    if (isprint(ch))
                        putc(ch,stdout);
                    else
                        fprintf(stdout,"<%02X>",ch);
                }
                printf("\n");
                break;
            default:
                putc('?',stdout);
                while (--i) {
                    ch=fgetc(fp);
                    if (isprint(ch))
                        putc(ch,stdout);
                    else
                        fprintf(stdout,"<%02X>",ch);
                }
                printf("\n");
        }
    }
    fclose(fp);
    return 1;
}
