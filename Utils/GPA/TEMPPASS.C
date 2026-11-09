#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <string.h>
#include "types.h"

CHAR G_gdpm[13]={""};
#define GREGYEAR	1980
#define GREGSTART   0
CHAR *b62nums="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

INT getday(CHAR *dt)
{
    return(((dt[4]-'0')*10)+(dt[5]-'0'));
}
INT getmon(CHAR *dt)
{
    return(((dt[2]-'0')*10)+(dt[3]-'0'));
}
INT getyear(CHAR *dt)
{
    return(((dt[0]-'0')*10)+(dt[1]-'0'));
}
UINT datetonum(CHAR *dt)
{
    INT i;
    UINT dd;
    INT d,m,y,dpy;
    
    y=getday (dt);
    m=getmon (dt);
    d=getyear(dt);

	dpy=365;
	dd=GREGSTART;
    if (y<50) y+=100;
    y-=GREGYEAR%100;
    dd=(dpy*y);
    dd+=y/4;
    if (((y%4)==0)&&(m<3)) dd--;
    for (i=0;i<m-1;i++) dd+=G_gdpm[i];
    dd+=d;

	return(dd);
}
void flipround(CHAR *s)
{
    CHAR t;
    t=s[0]; s[0]=s[3]; s[3]=t;
    t=s[1]; s[1]=s[2]; s[2]=t;
}
LONG pdnum(CHAR *date,CHAR *time)
{
    LONG d;
    d=(LONG)datetonum(date)*144L;
    d+=(LONG)((((time[0]-'0')*10)+(time[1]-'0'))*6)+(time[2]-'0');
    return(d);
}
CHAR *numtob62(LONG n)
{
    INT i,j;
    static CHAR ret[5];
    for (i=3;i>=0;i--) {
        j=(INT)(n%62L);
        n/=62;
        ret[i]=b62nums[j];
    }
    ret[4]=0;
    flipround(ret);
    return(ret);
}
LONG b62tonum(CHAR *n)
{
    INT j;
    static CHAR tmp[5];
    LONG ret=0;
    strcpy(tmp,n);
    n=tmp;
    flipround(tmp);
    while (*n) {
        ret*=62L;
        if ((*n>='0')&&(*n<='9')) {
            j=*n-'0';
        } else if ((*n>='A')&&(*n<='Z')) {
            j=(*n-'A')+10;
        } else if ((*n>='a')&&(*n<='z')) {
            j=(*n-'a')+36;
        }
        ret+=(LONG)j;
        n++;
    }
    return(ret);
}
void input(char *p,char *b,int len,char sep)
{
    int xit=0;
    int i=0,k;
    printf("%s",p);
    while (!xit) {
        k=getch();
        switch (k) {
            case '0' : case '1' : case '2' : case '3' : case '4' :
            case '5' : case '6' : case '7' : case '8' : case '9' :
                b[i++]=k;
                b[i]=0;
                printf("%c",k);
                if (((i==2)||(i==4))&&(i!=len)) printf("%c",sep);
                break;
            case 8 :
                if ((i==2)||(i==4)) printf("%c %c",k,k);
                if (i) i--;
                b[i]=0;
                printf("%c %c",k,k);
                break;
        }
        if (i==len) xit=1;
    }
    printf("\n");
}
char *pword(char *p)
{
    static char tmp[80];
    char tmp1[10];
    int i;
    tmp[0]=0;
    for (i=0;i<4;i++) {
        if (islower(*p)) {
            sprintf(tmp1,"ALT_%c ",toupper(*p));
        } else {
            sprintf(tmp1,"%c ",*p);
        }
        p++;
        strcat(tmp,tmp1);
    }
    return(tmp);
}
int main(void)
{
    char d[10],t[10];
    int tim;
    int m,h,nh,nm;
    LONG dn;
    clrscr();
    textattr(0x07);
    printf("Tell the User to bring up their logon screen, then, ask them\n");
    printf("to tell you the system date and time (From the top right\n");
    printf("corner of the screen)\n\n");
    input("Enter the User's System Date               : (DD/MM/YY) ",d,6,'/');
    input("\nEnter the User's System Time 24 Hour Clock : (HH:MM)    ",t,4,':');
    tim=atoi(t);
    nh=h=tim/100;
    m=((tim%100)/10);
    nm=m+1;
    if (nm==6) { nh++; nm=0; }
    if (nh==24) nh=0;
    dn=pdnum(d,t);
    textattr(0x07);
    cprintf("\r\n\r\nEither tell them they may use the password:\r\n\r\n    ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn  )));
    textattr(0x07);
    cprintf(" From %02d:%d0:00 To %02d:%d9:59\r\n\r\n", h, m, h, m);
    cprintf("OR if the system time is about to change to %02d:%d0\r\n",nh,nm);
    cprintf("   tell them they may use the password:\r\n\r\n    ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn+1)));
    textattr(0x07);
    cprintf(" From %02d:%d0:00 To %02d:%d9:59\r\n\r\n",nh,nm,nh,nm);
    cprintf("Remind the user that they will have to setup a NEW password ");
    textattr(0x0C);
    cprintf("NOW!\r\n\r\n");
    textattr(0x07);
    return(0);
}
