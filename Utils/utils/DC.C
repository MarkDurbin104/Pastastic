#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <memory.h>
#include <dir.h>
#include <dos.h>

char *G_dirs[20];

void ReadHome(void)
{
    FILE *fp;
    char s[100];
    int line=0;
    if ((fp=fopen("C:\\HOME.LST","r"))==NULL) return;
    while (fgets(s,80,fp)!=NULL) {
        s[strlen(s)-1]=0;
        G_dirs[line++]=strdup(s);
    }
    fclose(fp);
}
int main(int argc,char *argv[])
{
    char scrbuf[4000];
    struct text_info t;
    int i=0;

    gettextinfo(&t);

    memset(G_dirs,0,20*sizeof(char *));
    ReadHome();

    if (argc<2) {
        memcpy(scrbuf,((char far *)0xB8000000L),4000);
        textattr(0x1F);
        while (G_dirs[i]!=NULL) {
            gotoxy(1,i+1);
            cprintf("%d %-77.77s",i,G_dirs[i]);
            i++;
        }
        if (i) {
            i=getch();
            i-='0';
        	chdir(G_dirs[i]);
        }
        memcpy(((char far *)0xB8000000L),scrbuf,4000);
    } else {
      	chdir(G_dirs[atoi(argv[1])]);
    }
    gotoxy(t.curx,t.cury-1);
    printf("%79.79s","");
    gotoxy(t.curx,t.cury-2);
    return 1;
}
