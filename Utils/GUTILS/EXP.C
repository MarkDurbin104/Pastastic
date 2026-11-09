#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <alloc.h>
#include <conio.h>
#include <memory.h>
#include <io.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "keydef.h"
#include "standard.h"

#define VAT 175L

unsigned int ofs[25]={374,34,34,33,33,34,34,34,34,33,33,33,34,34,34,34,34,66,34,34,33,34,34,34,34};
char G_ltype[6][102]={
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        XXXXXXX    XXXXXXXXXXXXX           XXXXX   XXXXXXXX  XX XX XX XX",
"               XXXXXXXXX  XXXXXXXXX  XXXXXXXXX XXXXXXXXX  XXXXXXXXX  XXXXXXXXX  XXXXXXXXX  XXXXXXXXXX ",
"                                          XXXX                                             XXXXXX  XX ",
"               XXXX  XX   XXXX  XX   XXXX  XX  XXXX  XX   XXXX  XX   XXXX  XX   XXXX  XX   XXXXXX  XX ",
"XXXXXXXXXXXXX  XXXX  XX   XXXX  XX   XXXX  XX  XXXX  XX   XXXX  XX   XXXX  XX   XXXX  XX   XXXXXX  XX ",
"                                                                                           XXXXXX  XX "
};
typedef struct {
    char route[4][10];
    int  dai;
    long mon[14];
} DAILY;
typedef struct {
    char name[31];
    char emp[8];
    char loc[14];
    char pro[6];
    int  day;
    int  mnth;
    int  year;
    char res;
    char ppm;
    char ext1[16];
    char ext2[16];
} OUTER;
typedef struct {
    OUTER ot;
    DAILY dd[7];
} EXPEN;

EXPEN *G_exp;
char G_vals[103][25];
char  *G_buf;
int G_numb=0;
int G_cbuf=0;

char G_dpm[12]="";

char cp[3][6]={
    { 8,50,69, 8,27,54},
    { 0, 0, 0, 1, 1, 1},
    {30, 6, 5, 8,10, 3}
};

void beep(void)
{
    sound(1000);
    delay(100);
    nosound();
}
void nextdate(int *day,int *mnth,int *year)
{
    *day+=7;
    if ((*year)%4==0) G_dpm[1]=29;
    if (*day>G_dpm[(*mnth)-1]) {
        (*day)-=G_dpm[(*mnth)-1];
        (*mnth)++;
        if (*mnth>12) {
            *mnth=1;
            (*year)++;
        }
    }
    G_dpm[1]=28;
}
void prevdate(int *day,int *mnth,int *year)
{
    *day-=7;
    if ((*year)%4==0) G_dpm[1]=29;
    if (*day<1) {
        (*mnth)--;
        if (*mnth<1) {
            *mnth=12;
            (*year)--;
        }
        (*day)+=G_dpm[(*mnth)-1];
    }
    G_dpm[1]=28;
}
int isvalid(int x,int y)
{
    switch (y) {
        case 24 :
            if (G_ltype[0][x]==' ') return(0); else return(1);
        case 23 :
            return(0);
        case 22 :
        case 21 :
        case 20 :
        case 19 :
        case 18 :
            if (G_ltype[1][x]==' ') return(0); else return(1);
        case 17 :
            if (G_ltype[2][x]==' ') return(0); else return(1);
        case 16 :
            return(0);
        case 5 :
            if (G_ltype[4][x]==' ') return(0); else return(1);
        case 1 :
            if (G_ltype[5][x]==' ') return(0); else return(1);
    }
    if (G_ltype[3][x]==' ') return(0);
    return(1);
}
unsigned int dublit(char a)
{
    unsigned int ret=0,i;
    for (i=0;i<8;i++) {
        if ((a&(0x80>>i))!=0) ret|=(0xC000>>(i*2));
    }
    return(ret);
}
void prchar(int x,int y,unsigned char *b)
{
    unsigned int j,a;
    if ((G_vals[x][y]==32)||(G_vals[x][y]==0)) return;
    for (j=0;j<14;j++) {
        a=dublit(font[G_vals[x][y]*14+(13-j)]);
        *(b++)=a>>8;
        *(b++)=a&0xFF;
        *(b++)=0;
        *(b++)=a>>8;
        *(b++)=a&0xFF;
        *(b++)=0;
    }
}
void prexpform(void)
{
    int i,j,k,nb=0,l,f;
    unsigned char *buf;
    int lofs[25];

    fprintf(stdprn,"%cA%c",27,6);
    for (i=0;i<25;i++) {
        nb+=ofs[i];
        lofs[i]=nb;
    }
    buf=malloc(3*nb);
    for (k=0;k<102;k++) {
        memset(buf,0,3*nb);
        for (i=1;i<25;i++) {
            if (isvalid(k,i)) prchar(k,i,&buf[lofs[i-1]*3]);
        }
        f=0; l=0;
        for (i=0;i<nb*3;i++) {
            if (buf[i]) {
                if (!f) f=i;
                l=i;
            }
        }
        if ((f!=0)||(l!=0)) {
            f/=3;
            l=(l/3)+1;
            fprintf(stdprn,"%c%c%c%c",27,92,(f%256),(f/256));
            fprintf(stdprn,"%c%c%c%c%c",27,'*',39,((l-f)%256),((l-f)/256));
            for (j=(f*3);j<(l*3);j++) fputc(buf[j],stdprn);
        }
        fputc('\n',stdprn);
    }
    free(buf);
}
void prat(int x,int y,int col,char *str)
{
    unsigned int *s=(unsigned int *)0xB8000000L+x+y*80;
    while (*str) *(s++)=(col<<8)|*(str++);
}
char *ress(void)
{
    switch (G_exp->ot.res) {
        case 1 :
            return("TRAVEL    ");
        case 2 :
            return("RELOCATION");
        case 3 :
            return("TRAINING  ");
    }
    return("O/S TRAVEL");
}
char *pens(void)
{
    static char tmp[4];
    sprintf(tmp,"%02d.%1dp",G_exp->ot.ppm/10,G_exp->ot.ppm%10);
    return(tmp);
}
char *miles(int i)
{
    static char tmp[5];
    sprintf(tmp,"%04d",G_exp->dd[i].dai);
    return(tmp);
}
char *milestot(void)
{
    static char tmp[5];
    int i,j=0;
    for (i=0;i<7;i++) j+=G_exp->dd[i].dai;
    sprintf(tmp,"%04d",j);
    return(tmp);
}
long milesm(void)
{
    int i;
	long j=0;
    for (i=0;i<7;i++) j+=G_exp->dd[i].dai;
    j*=G_exp->ot.ppm;
    j/=10;
    return(j);
}
char *milesmoney(void)
{
    static char tmp[8];
    long j=milesm();
    sprintf(tmp,"%04ld.%02d",j/100L,(int)(j%100L));
    return(tmp);
}
char *money(int i,int j)
{
    static char tmp[8];
    sprintf(tmp,"%04ld.%02ld",G_exp->dd[j].mon[i]/100L,G_exp->dd[j].mon[i]%100L);
    return(tmp);
}
long monrt(int l)
{
    int i;
    long j=0L;
    for (i=0;i<7;i++) j+=G_exp->dd[i].mon[l];
    return(j);
}
long monct(int l)
{
    int i;
    long j=0L;
    for (i=0;i<14;i++) j+=G_exp->dd[l].mon[i];
    return(j);
}
long gtot(void)
{
    int i,l;
    long j=0L;
    for (i=0;i<7;i++) j+=G_exp->dd[i].dai;
    j*=G_exp->ot.ppm;
    j/=10;
    for (l=0;l<14;l++) for (i=0;i<7;i++) j+=G_exp->dd[i].mon[l];
    return(j);
}
char *moneyrt(int l)
{
    static char tmp[8];
    long j=monrt(l);
    sprintf(tmp,"%04ld.%02ld",j/100L,j%100L);
    return(tmp);
}
char *moneyct(int l)
{
    static char tmp[8];
    long j=monct(l);
    sprintf(tmp,"%04ld.%02ld",j/100L,j%100L);
    return(tmp);
}
char *grandtot(void)
{
    static char tmp[8];
    long j=gtot();
    sprintf(tmp,"%04ld.%02ld",j/100L,j%100L);
    return(tmp);
}
long vaton(long m)
{
    return(((m*VAT)+500L)/1000L);
}
char *datestr(int d,int m,int y)
{
    static char tmp[9];
    sprintf(tmp,"%02d/%02d/%02d",d,m,y%100);
    return(tmp);
}
char *daynum(int i)
{
    static char tmp[5];
    int day=G_exp->ot.day;
    int mnth=G_exp->ot.mnth;

    day-=(6-i);
    if (G_exp->ot.year%4==0) G_dpm[1]=29;
    if (day<1) {
        mnth--;
        if (mnth<1) mnth=12;
        day+=G_dpm[mnth-1];
    }
    G_dpm[1]=28;
    switch (day) {
        case 1 :
        case 21 :
        case 31 :
            sprintf(tmp,"%2dst",day);
            break;
        case 2 :
        case 22 :
            sprintf(tmp,"%2dnd",day);
            break;
        case 3 :
        case 23 :
            sprintf(tmp,"%2drd",day);
            break;
        default :
            sprintf(tmp,"%2dth",day);
    }
    return(tmp);
}
void bgup(void)
{
    int i,k;
    textattr(7);
    clrscr();
    prat(0, 0,9,"Name:                                   Emp. No.:          Pro. No.:");
    prat(0, 1,9,"Week:              Reason:                Pence/Mile:");
    prat(0, 3,9,"        Sun      Mon      Tue      Wed      Thu      Fri      Sat       Total");
    prat(0, 4,9,"Miles:");
    prat(0, 5,9,"From:");
    prat(0, 6,9,"To At:");
    prat(0, 7,9,"To At:");
    prat(0, 8,9,"To At:");
    prat(0, 9,9,"Flight:");
    prat(0,10,9,"Rail:");
    prat(0,11,9,"Taxi:");
    prat(0,12,9,"Hotel:");
    prat(0,13,9,"Break:");
    prat(0,14,9,"Lunch:");
    prat(0,15,9,"Dinner:");
    prat(0,16,9,"Tips:");
    prat(0,17,9,"Tele:");
    prat(0,18,9,"Other1:");
    prat(0,19,9,"Other2:");
    prat(0,20,9,"VAT Fuel");
    prat(0,21,9,"V.A.T:");
    prat(0,22,9,"Entert:");
    prat(0,23,9,"Total:");
    prat(0,24,9,"Other1 - Reason:                  Other2 - Reason:");
    prat( 8, 0,3,G_exp->ot.name);
    prat(50, 0,3,G_exp->ot.emp);
    prat(69, 0,3,G_exp->ot.pro);
    prat( 8, 1,3,datestr(G_exp->ot.day,G_exp->ot.mnth,G_exp->ot.year));
    prat(27, 1,3,ress());
    prat(54, 1,3,pens());
    for (i=0;i<8;i++) {
        if (i!=7) {
            prat(12+(i*9),3,9,daynum(i));
            prat(10+(i*9),4,3,miles(i));
            for (k=0;k<4;k++)  prat(8+(i*9),5+k,3,G_exp->dd[i].route[k]);
            for (k=0;k<14;k++) prat(9+(i*9),9+k,3,money(k,i));
            prat( 9+(i*9),20,11,money(11,i));
            prat( 9+(i*9),23,11,moneyct(i));
        }
        else {
            prat(10+(i*9), 4,15,milestot());
            prat( 9+(i*9), 8,11,milesmoney());
            for (k=0;k<14;k++) prat( 9+(i*9),9+k,11,moneyrt(k));
            prat( 9+(i*9),23,15,grandtot());
        }
    }
    prat(17,24,3,G_exp->ot.ext1);
    prat(51,24,3,G_exp->ot.ext2);
}
void getexp(char *file)
{
    int fd;
    long fl;

    G_numb=0;
    fd=open(file,O_RDONLY|O_BINARY);
    fl=filelength(fd);
    if (fl!=(-1)) {
        G_buf=malloc((unsigned int)fl);
        if (G_buf==NULL) {
            close(fd);
            return;
        }
        memset(G_buf,0,(unsigned int)fl);
        G_numb=(fl/sizeof(EXPEN));
        read(fd,G_buf,fl);
        G_cbuf=G_numb-1;
        G_exp=(EXPEN *)(&G_buf[G_cbuf*sizeof(EXPEN)]);
        close(fd);
    }
    else {
        G_buf=malloc(sizeof(EXPEN));
        if (G_buf==NULL) return;
        memset(G_buf,0,sizeof(EXPEN));
        G_exp=(EXPEN *)G_buf;
        G_numb=1;
        strcpy(G_exp->ot.name,"MARK DURBIN");
        strcpy(G_exp->ot.emp,"64570");
        strcpy(G_exp->ot.loc,"CITYGATE");
        strcpy(G_exp->ot.pro,"179");
        G_exp->ot.day=4;
        G_exp->ot.mnth=1;
        G_exp->ot.year=1992;
        G_exp->ot.res=1;
        G_exp->ot.ppm=74;
    }
}
void putexp(char *file)
{
    int fd;

    fd=open(file,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
    if (fd==(-1)) return;
    write(fd,G_buf,G_numb*sizeof(EXPEN));
    close(fd);
}
int getkey(void)
{
    int k=getch();
    if (k==0) return(0-getch());
    return(k);
}
void setcur(int x,int y,int len)
{
    unsigned int *s=(unsigned int *)0xB8000000L+x+y*80;
    while (len>0) {
        *(s++)^=0x7F00;
        len--;
    }
}
void cursor(int curpos)
{
    
    if (curpos<6) {
        setcur(cp[0][curpos],cp[1][curpos],cp[2][curpos]);
    }
    else {
        if (curpos<13) {
            setcur(10+(((curpos-6)%7)*9),4+((curpos-6)/7),4);
        }
        else {
            if (curpos<41) {
                setcur(8+(((curpos-6)%7)*9),4+((curpos-6)/7),9);
            }
            else {
                setcur(9+(((curpos-6)%7)*9),4+((curpos-6)/7),7);
            }
        }
    }
}
void inputstr(char *s,int curpos,int type,int k)
{
    int x,y,len;    
    int i,xit=0;
    if (curpos<6) {
        x=cp[0][curpos];
        y=cp[1][curpos];
        len=cp[2][curpos];
    }
    else {
        if (curpos<13) {
            x=10+(((curpos-6)%7)*9);
            y=4+((curpos-6)/7);
            len=4;
        }
        else {
            if (curpos<41) {
                x=8+(((curpos-6)%7)*9);
                y=4+((curpos-6)/7);
                len=9;
            }
            else {
                x=9+(((curpos-6)%7)*9);
                y=4+((curpos-6)/7);
                len=7;
            }
        }
    }
    s[0]=toupper(k);
    s[1]=0;
    i=1;
    while (!xit) {
        gotoxy(x+1,y+1);
        cprintf("%s%*.*s",s,len-i,len-i," ");
        gotoxy(x+i+1,y+1);
        switch (k=getkey()) {
            case CR :
                xit=1;
                break;
            case BKSP :
                if (i>0) s[--i]=0; else beep();
                break;
            default :
                if ((k<127)&&(k>31)) {
                    s[i++]=toupper(k);
                    s[i]=0;
                    if (i>=len) xit=1;
                }
                else {
                    xit=1;
                }
        }
    }
}
void putinval(int x,int y,char *s,int l)
{
    if (!l) l=strlen(s);
    while (l--) G_vals[x++][y]=*(s++);
}
void keyloop(char *file)
{
    int xit=0;
    int k,i,j;
    int curpos=0;
    char tmp[40];
    long l,m;

    cursor(curpos);
    while (!xit) {
        if (kbhit()) {
            cursor(curpos);
            switch (k=getkey()) {
                case F01 :
                    memset(G_vals,' ',sizeof(G_vals));
                    putinval( 0,24,G_exp->ot.name,30);
                    putinval(38,24,G_exp->ot.emp , 6);
                    putinval(73,24,G_exp->ot.pro , 5);
                    putinval(49,24,"CITYGATE"    , 8);
                    strcpy(tmp,datestr(G_exp->ot.day,G_exp->ot.mnth,G_exp->ot.year));
                    putinval(81,24,tmp           , 0);
                    putinval(91+(G_exp->ot.res*3),24,"XX",0);
                    for (i=0;i<4;i++)
                        for (j=0;j<7;j++)
                            putinval((j*11+15)-(j>2),22-i,G_exp->dd[j].route[i],9);
                    for (j=0;j<7;j++) {
                        if (G_exp->dd[j].dai!=0) {
                            sprintf(tmp,"%4d",G_exp->dd[j].dai);
                            putinval((j*11+15)-(j>2),18,tmp,4);
                        }
                    }
                    strcpy(tmp,milestot());
                    for (k=0;k<strlen(tmp);k++) if (tmp[k]=='0') tmp[k]=' '; else k=5;
                    putinval(93,18,tmp,0);
                    for (j=0;j<7;j++) {
                        for (i=0;i<11;i++) {
                            if (G_exp->dd[j].mon[i]!=0L) {
                                sprintf(tmp,"%4ld  %02ld",G_exp->dd[j].mon[i]/100L,G_exp->dd[j].mon[i]%100L);
                                putinval((j*11+15)-(j>2),15-i,tmp,0);
                            }
                        }
                    }
                    for (i=0;i<11;i++) {
                        if (monrt(i)) {
                            sprintf(tmp,"%4ld  %02ld",monrt(i)/100L,monrt(i)%100L);
                            putinval(93,15-i,tmp,0);
                        }
                    }
                    m=milesm();
                    for (j=0;j<7;j++) {
                        l=monct(j)-G_exp->dd[j].mon[11];
                        if (l) {
                            sprintf(tmp,"%4ld  %02ld",l/100L,l%100L);
                            putinval((j*11+15)-(j>2),4,tmp,0);
                            m+=l;
                        }
                    }
                    if (m) {
                        sprintf(tmp,"%4ld  %02ld",m/100L,m%100L);
                        putinval(93,4,tmp,0);
                    }
                    for (j=0;j<7;j++) {
                        l=G_exp->dd[j].mon[11];
                        if (l) {
                            sprintf(tmp,"%4ld  %02ld",l/100L,l%100L);
                            putinval((j*11+15)-(j>2),2,tmp,0);
                        }
                    }
                    if (monrt(11)) {
                        sprintf(tmp,"%4ld  %02ld",monrt(11)/100L,monrt(11)%100L);
                        putinval(93,2,tmp,0);
                    }
                    sprintf(tmp,"%4ld  %02ld",gtot()/100L,gtot()%100L);
                    putinval(93,1,tmp,0);
                    sprintf(tmp,"%4ld  %02ld",milesm()/100L,milesm()%100L);
                    putinval(93,17,tmp,0);
                    sprintf(tmp,"%d.%dp",G_exp->ot.ppm/10,G_exp->ot.ppm%10);
                    putinval(42,17,tmp,0);
                    prexpform();
                    break;
                case ESC :
                    xit=1;
                    break;

                case F10 :
                    putexp(file);
                    xit=1;
                    break;

                case LEFT :
                    switch (curpos) {
                        case 0 :
                            beep();
                            break;
                        case 1 :
                        case 2 :
                        case 3 :
                        case 4 :
                        case 5 :
                            curpos--;
                            break;
                        default :
                            if (!((curpos-6)%7)) {
                                beep();
                            }
                            else {
                                curpos--;
                            }
                    }
                    break;

                case UP :
                    switch (curpos) {
                        case 0 :
                        case 1 :
                        case 2 :
                            beep();
                            break;
                        case 3 :
                            prevdate(&G_exp->ot.day,&G_exp->ot.mnth,&G_exp->ot.year);
                            prat( 8, 1,3,datestr(G_exp->ot.day,G_exp->ot.mnth,G_exp->ot.year));
                            for (i=0;i<7;i++) prat(12+(i*9),3,9,daynum(i));
                            break;
                        case 4 :
                            G_exp->ot.res--;
                            if (G_exp->ot.res<0) G_exp->ot.res=3;
                            prat(27, 1,3,ress());
                            break;
                        case 5 :
                            curpos-=3;
                            break;
                        case 6 :
                        case 7 :
                        case 8 :
                        case 9 :
                        case 10 :
                        case 11 :
                        case 12 :
                            curpos=5;
                            break;
                        default :
                            curpos-=7;
                            if ((curpos>117)&&(curpos<125)) curpos-=7;
                    }
                    break;

                case RGT :
                    switch (curpos) {
                        case 0 :
                        case 1 :
                        case 2 :
                        case 3 :
                        case 4 :
                        case 5 :
                            curpos++;
                            break;
                        default :
                            if (((curpos-6)%7)==6) {
                                beep();
                            }
                            else {
                                curpos++;
                            }
                    }
                    break;

                case DOWN :
                    switch (curpos) {
                        case 0 :
                        case 1 :
                        case 2 :
                            curpos+=3;
                            break;
                        case 3 :
                            nextdate(&G_exp->ot.day,&G_exp->ot.mnth,&G_exp->ot.year);
                            prat( 8, 1,3,datestr(G_exp->ot.day,G_exp->ot.mnth,G_exp->ot.year));
                            for (i=0;i<7;i++) prat(12+(i*9),3,9,daynum(i));
                            break;
                        case 4 :
                            G_exp->ot.res++;
                            if (G_exp->ot.res>3) G_exp->ot.res=0;
                            prat(27, 1,3,ress());
                            break;
                        case 5 :
                            curpos=6;
                            break;
                        default :
                            if (curpos>131) {
                                beep();
                            }
                            else {
                                curpos+=7;
                                if ((curpos>117)&&(curpos<125)) curpos+=7;
                            }
                    }
                    break;


                case PGUP :
                    if (G_cbuf>0) {
                        G_cbuf--;
                        G_exp--;
                        bgup();
                    }
                    break;

                case PGDN :
                    if (G_cbuf<G_numb-1) {
                        G_cbuf++;
                        G_exp++;
//                        G_exp=(EXPEN *)(&G_buf[G_cbuf*sizeof(EXPEN)]);
                    }
                    else {
                        if (G_numb>52) {
                            beep();
                        }
                        else {
                            G_buf=realloc(G_buf,(G_numb+1)*sizeof(EXPEN));
                            if (G_buf==NULL) {
                                xit=1;
                            }
                            else {
                                G_cbuf++;
                                G_numb++;
                                G_exp=(EXPEN *)(&G_buf[G_cbuf*sizeof(EXPEN)]);
                                memset(G_exp,0,sizeof(EXPEN));
                                memcpy(G_exp,G_exp-1,sizeof(OUTER));
                                nextdate(&G_exp->ot.day,&G_exp->ot.mnth,&G_exp->ot.year);
                            }
                        }
                    }
                    bgup();
                    break;
                default :
                    if ((k>31)&&(k<127)) {
                        switch (curpos) {
                            case 0 :
                                inputstr(tmp,curpos,'A',k);
                                strcpy(G_exp->ot.name,tmp);
                                break;
                            case 1 :
                                inputstr(tmp,curpos,'9',k);
                                strcpy(G_exp->ot.emp,tmp);
                                break;
                            case 2 :
                                inputstr(tmp,curpos,'9',k);
                                strcpy(G_exp->ot.pro,tmp);
                                break;
                            case 3 :
                            case 4 :
                                beep();
                                break;
                            case 5 :
                                inputstr(tmp,curpos,'9',k);
                                G_exp->ot.ppm=atoi(tmp);
                                for (i=0;i<7;i++) G_exp->dd[i].mon[11]=vaton((G_exp->dd[i].dai*G_exp->ot.ppm)/10);
                                bgup();
                                break;
                            default :
                                if ((curpos>5)&&(curpos<13)) {
                                    inputstr(tmp,curpos,'9',k);
                                    G_exp->dd[((curpos-6)%7)].dai=atoi(tmp);
                                    G_exp->dd[((curpos-6)%7)].mon[11]=vaton((G_exp->dd[((curpos-6)%7)].dai*G_exp->ot.ppm)/10);
                                    bgup();
                                }
                                else {
                                    if ((curpos>12)&&(curpos<40)) {
                                        inputstr(tmp,curpos,'A',k);
                                        strcpy(G_exp->dd[((curpos-13)%7)].route[(curpos-13)/7],tmp);
                                        bgup();
                                    }
                                    else {
                                        inputstr(tmp,curpos,'9',k);
                                        G_exp->dd[((curpos-41)%7)].mon[((curpos-41)/7)]=atol(tmp);
                                        bgup();
                                    }
                                }
                        }
                    }
                    else {
                        beep();
                    }
            }
            cursor(curpos);
        }
    }
    cursor(curpos);
}
int main(int argc,char *argv[])
{
    int i,j;

    if (argc<2) {
        printf("exp filename\n");
        return(0);
    }
    getexp(argv[1]);
    if (G_numb==0) {
        printf("Not enough memory\n");
        return(0);
    }
    bgup();
    keyloop(argv[1]);
    clrscr();
    return(1);
}
