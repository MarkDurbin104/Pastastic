#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>

#define TOPLEFTX      0
#define TOPLEFTY      0
#define BOTRIGHTX     79
#define BOTRIGHTY     24
#define DTOPLEFTX     10
#define DTOPLEFTY     10
#define DBOTRIGHTX    69
#define DBOTRIGHTY    19
#define HTOPLEFTX     10
#define HTOPLEFTY     2
#define HBOTRIGHTX    69
#define HBOTRIGHTY    8
#define WHITEONBLUE   0x1F
#define BLACKONGREY   0x70

#define ESC   27
#define CR    13
#define BKSP   8

char  *TEXTVIDMEM;
char  G_boxchars[22]={'Ú','¿','À','Ù','³','Ä','Á','Â','Ã','´','Å',
                     'É','»','È','¼','º','Í','Ê','Ë','Ì','¹','Î'};
char G_scrattr=0x07;

void prat(int x,int y,char *fmt,...)
{
    char tmp[100],*s,*scr,*end;
    va_list ap;
    s=tmp;
    va_start(ap,fmt);
    vsprintf(tmp,fmt,ap);
    va_end(ap);
    scr=TEXTVIDMEM+y*160+x*2;
    end=TEXTVIDMEM+(y+1)*160;
    while ((*s)&&(scr<end)) {
        *scr++=*s++;
        *scr++=G_scrattr;
    }
}
void dbox(int x,int y,int x1,int y1)
{
    int i;
    if (x==x1) {
        for (i=y+1;i<y1;i++) {
            prat(x ,i,"%c",G_boxchars[15]);
            prat(x1,i,"%c",G_boxchars[15]);
        }
        prat(x ,y ,"%c",G_boxchars[18]);
        prat(x ,y1,"%c",G_boxchars[17]);
    } else if (y==y1) {
        for (i=x+1;i<x1;i++) {
            prat(i,y ,"%c",G_boxchars[16]);
            prat(i,y1,"%c",G_boxchars[16]);
        }
        prat(x ,y ,"%c",G_boxchars[19]);
        prat(x1,y ,"%c",G_boxchars[20]);
    } else {
        for (i=x+1;i<x1;i++) {
            prat(i,y ,"%c",G_boxchars[16]);
            prat(i,y1,"%c",G_boxchars[16]);
        }
        for (i=y+1;i<y1;i++) {
            prat(x ,i,"%c",G_boxchars[15]);
            prat(x1,i,"%c",G_boxchars[15]);
        }
        prat(x ,y ,"%c",G_boxchars[11]);
        prat(x1,y ,"%c",G_boxchars[12]);
        prat(x ,y1,"%c",G_boxchars[13]);
        prat(x1,y1,"%c",G_boxchars[14]);
    }
}
void bar(int x,int y,int x1,int y1)
{
    char tmp[133];
    int i;
    memset(tmp,' ',133);
    tmp[x1-x]=0;
    for (i=y;i<=y1;i++) prat(x,i,tmp);
}
void Window(char *title,int x,int y,int x1,int y1,char col)
{
    G_scrattr=col;
    bar(x,y,x1,y1);
    dbox(x,y,x1,y1);
    prat(x+(((x1-x)-strlen(title))/2),y,"%s",title);
}
int getkey(void)
{
    int k;
    if (!(k=getch())) k=0-getch();
    return(k);
}
void beep(void)
{
    sound(1000);
    delay(200);
    nosound();
}
char *input(int x,int y,char *s,int len,int col)
{
    int i,k,xit=0;
    static char tmp[100];
    int modified=0;
    G_scrattr=col;

    if ((s!=NULL)&&(*s)) strcpy(tmp,s); else tmp[0]=0;
    i=strlen(tmp);

    while (!xit) {
        bar(x,y,x+len+1,y);
        prat(x,y,"%s",tmp);
        gotoxy(x+i+1,y+1);
        switch (k=getkey()) {
            case ESC :
                if ((s!=NULL)&&(*s)) strcpy(tmp,s); else tmp[0]=0;
                i=strlen(tmp);
                modified=0;
                break;
            case CR:
                xit=1;
                break;
            case BKSP :
                if (i>0) {
                    modified=1;
                    tmp[--i]=0;
                } else {
                    beep();
                }
                break;
            default :
                if (((k>='0')&&(k<='9'))
                ||  ((k>='a')&&(k<='z'))
                ||  ((k>='A')&&(k<='Z'))) {
                    if (!modified) i=0;
                    modified=1;
                    if (i<len) {
                        tmp[i++]=(char)k;
                        tmp[i]=0;
                    } else {
                        beep();
                    }
                } else {
                    beep();
                }
        }
    }
    strupr(tmp);
    return(tmp);
}
int main(int argc,char *argv[])
{
    int i;
    char drive[2],directory[15],tmp[20];
    TEXTVIDMEM=MK_FP(__SegB800,0x0000);
    do {
        do {
            Window(" GPA installation ",TOPLEFTX,TOPLEFTY,BOTRIGHTX,BOTRIGHTY,WHITEONBLUE);
            prat(10,3,"Please enter the drive letter [C,D,E or F] that");
            prat(10,4,"Capture will be installed to:");
            prat(10,5,"i.e. C for C:, D for D:  etc...");
            prat(10,7,"To accept the default drive, just press [ENTER].");
            prat(10,8,"If you don't understand the question, just press [ENTER].");
            Window(" Please enter the Destination Drive ",DTOPLEFTX,DTOPLEFTY,DBOTRIGHTX,DBOTRIGHTY,BLACKONGREY);
            strcpy(drive,input(38,15,"C",1,WHITEONBLUE));
        } while ((drive[0]<'C')||(drive[0]>'F'));

        do {
            Window(" GPA installation ",TOPLEFTX,TOPLEFTY,BOTRIGHTX,BOTRIGHTY,WHITEONBLUE);
            prat(10,3,"Please enter the directory name that");
            prat(10,4,"Capture will be installed to.");
            prat(10,5,"i.e. CAPTURE");
            prat(10,7,"To accept the default directory, just press [ENTER].");
            prat(10,8,"If you don't understand the question, just press [ENTER].");
            Window(" Please enter the Destination Drive ",DTOPLEFTX,DTOPLEFTY,DBOTRIGHTX,DBOTRIGHTY,BLACKONGREY);
            strcpy(directory,input(36,15,"CAPTURE",8,WHITEONBLUE));
        } while (strlen(directory)<1);

        Window(" GPA installation ",TOPLEFTX,TOPLEFTY,BOTRIGHTX,BOTRIGHTY,WHITEONBLUE);
        Window(" Capture will be installed to ",DTOPLEFTX,DTOPLEFTY,DBOTRIGHTX,DBOTRIGHTY,BLACKONGREY);

        i=strlen(directory)/2+1;
        prat(40-i,15,"%s:\\%s",drive,directory);
        prat(25,17,"Is this correct (Y)es or (N)o");
        strcpy(tmp,input(56,17,"Y",1,WHITEONBLUE));
    } while (tmp[0]=='N');
    Window(" GPA installation ",TOPLEFTX,TOPLEFTY,BOTRIGHTX,BOTRIGHTY,WHITEONBLUE);
    strcpy(tmp,input(56,17,"Y",1,WHITEONBLUE));
    clrscr();
    return(0);
}
