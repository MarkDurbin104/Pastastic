#include <stdio.h>
#include <conio.h>

int main(void)
{
    unsigned char c;
    int k;
    int xit=0;
    FILE *fp;

    if ((stdin->flags&_F_TERM)==_F_TERM) {
        printf("keyboard");
        fp=fopen("TEST.KEY","wb");
        while (!xit) {
            if ((k=getch())==0) {
                k=0-getch();
            }
            fwrite(&k,2,1,fp);
            if (k==27) {
                xit=1;
            }
        }
        fclose(fp);
    } else {
        while (1) {
            fread(&c,1,1,stdin);
            if (c==1) break;
            printf("%02X ",c);
        }
    }
    return 1;
}
