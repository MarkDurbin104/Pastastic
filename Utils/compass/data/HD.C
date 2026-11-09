#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <malloc.h>
#include <ctype.h>

#include "keydef.h"

int GetKey(void)
{
    int k;
    if (!(k=getch())) k=0-getch();
    return k;
}

void pagehd(char *buf,int len)
{
    int ofs=0;
    int xit=0;
    int i,j,k;

    clrscr();
    while (!xit) {
        for (i=0;i<24;i++) {
            gotoxy(1,i+1);
            textattr(0x0E);
            cprintf("%08X",i*16+ofs);
            textattr(0x0B);
            for (j=i*16+ofs,k=0;j<i*16+ofs+16;j++,k++) {
                gotoxy(10+k*3,i+1);
                if (j<len)
                    cprintf("%02X",buf[j]&0xFF);
                else
                    cprintf("  ");
            }
            textattr(0x0C);
            for (j=i*16+ofs,k=0;j<i*16+ofs+16;j++,k++) {
                gotoxy(60+k,i+1);
                if (j<len)
                    cprintf("%c",(isprint(buf[j]))?buf[j]:' ');
                else
                    cprintf(" ");
            }
        }
        switch (GetKey()) {
            case 27 :
                xit=1;
                break;
            case UP :
                if (ofs>16) ofs-=16; else ofs=0;
                break;
            case DOWN :
                if (ofs<len) ofs+=16; else ofs=len;
                break;
            case PGUP :
                if (ofs>24*16) ofs-=24*16; else ofs=0;
                break;
            case PGDN :
                if (ofs<len) ofs+=24*16; else ofs=len;
                break;
        }
    }
}
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
    if (isatty(stdout->fd)) {
        pagehd(buf,fl);
    } else {
        for (i=0;i<fl;i+=16) {
            printf("%08X  ",i);
            for (j=i;j<i+16;j++) {
                if (j<fl)
                    printf("%02X ",buf[j]&0xFF);
                else
                    printf("   ");
            }
            for (j=i;j<i+16;j++) {
                if (j<fl)
                    printf("%c",(isprint(buf[j]))?buf[j]:' ');
                else
                    printf(" ");
            }
            printf("\n");
        }
    }
    return 0;
}



