/****************************************************************************
* Project     : GPA
* File        : temppass.c
* Description : program to work out the password given date and time
* 
* $Revision:   1.1  $  $Date:   Nov 03 1995 11:33:12  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/temppass.c_v  $
* 
*    Rev 1.1   Nov 03 1995 11:33:12   JGRAY
* Annotations
* 
****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <string.h>

#include "gpasizes.h"
#include "types.h"

CHAR G_gdpm[13]={""};
#define GREGYEAR    1980
#define GREGSTART   0
CHAR *b62nums="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ?"; // base 62 number lookup
CHAR *tpassnums= "QWERTYUIOPASDFGHJKLZXCVBNM0132457698mnbvcxzlkjhgfdsapoiuytrewq ?"; // base 62 number lookup for temp password
CHAR *mtpassnums="5qwert4yuiop3lkjhg2fdsaz7xcvbn0m1ASDFGHJKL2POIUYTREWQ8ZXCV9BNM ?"; // base 62 number lookup for managers temp password !!

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
LONG pdnum(CHAR *date,CHAR *time)
{
    LONG d;
    d=(LONG)datetonum(date)*144L;
    d+=(LONG)((((time[0]-'0')*10)+(time[1]-'0'))*6)+(time[2]-'0');
    return(d);
}
//S Convert number(LONG) to a base 62 string
//P the number to convert
//P 1=Manager 2=Temp or 0=Normal conversion
//R Converted base 62 string
CHAR *numtob62(LONG n,INT mtn)
{
    INT i,j;
    static CHAR ret[5];
    for (i=3;i>=0;i--) {
        j=(INT)(n%62L);
        n/=62;
        switch (mtn) { // ManagerTempNormal
            case 1 :    // Manager
                ret[i]=mtpassnums[j];
                break;
            case 2 :    // Temp
                ret[i]=tpassnums[j];
                break;
            case 0 :    // Normal
            default:
                ret[i]=b62nums[j];
                break;
        }
    }
    ret[4]=0;
    return(ret);
}
//S return the offset of a symbol in an array 
//P Symbol
//P list of symbols
//R offset
INT symbolofs(CHAR s,CHAR *l)
{
    CHAR *t;
    t=strchr(l,s);
    if (t==NULL) return(0);
    return((INT)(t-l));
}
//S Conver base 62 string to a long
//P String to convert
//P 1=Manager 2=Temp or 0=Normal conversion
//R Converted number
LONG b62tonum(CHAR *n,INT mtn)
{
    static CHAR tmp[5];
    LONG ret=0;
    strcpy(tmp,n);
    n=tmp;
    while (*n) {
        ret*=62L;
        switch (mtn) { // ManagerTempNormal
            case 1 :    // Manager
                ret+=(LONG)symbolofs(*n,mtpassnums);
                break;
            case 2 :    // Temp
                ret+=(LONG)symbolofs(*n,tpassnums);
                break;
            case 0 :    // Normal
            default:
                ret+=(LONG)symbolofs(*n,b62nums);
                break;
        }
        n++;
    }
    return(ret);
}
void input(CHAR *p,CHAR *b,INT len,CHAR sep)
{
    INT xit=0;
    INT i=0,k;
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
CHAR *pword(CHAR *p)
{
    static CHAR tmp[80];
    CHAR tmp1[10];
    INT i;
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
INT main(void)
{
    CHAR d[10],t[10];
    INT tim;
    INT m,h,nh,nm;
    LONG dn;
    clrscr();
    textattr(0x0C);
    cprintf("This version of TEMPPASS is for G.P.A. CAPTURE Version 5 or above.\r\n");
    textattr(0x0F);
//    cprintf("Tell the User to bring up their logon or Manager's Logon screen,\r\n");
//    cprintf("then, ask them to tell you the system date and time (From the top\r\n");
//    cprintf("right corner of the screen)\r\n\r\n");
    cprintf("Tell the User to bring up their logon or Change Manager's Password\r\n");
    cprintf("screen, then ask them to tell you the system date and time (From\r\n");
    cprintf("the top right corner of the screen)\r\n\r\n");
    textattr(0x07);
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
    cprintf("\r\nEither tell them they may use the password:\r\n\r\n Logon:     ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn  ,2)));
    textattr(0x07);
    cprintf("\r\n Manager's: ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn  ,1)));
    textattr(0x07);
    cprintf(" From %02d:%d0:00 To %02d:%d9:59\r\n\r\n", h, m, h, m);
    cprintf("OR if the system time is about to change to %02d:%d0\r\n",nh,nm);
    cprintf("   tell them they may use the password:\r\n\r\n Logon:     ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn+1,2)));
    textattr(0x07);
    cprintf("\r\n Manager's: ");
    textattr(0x1E);
    cprintf(" %s",pword(numtob62(dn+1,1)));
    textattr(0x07);
    cprintf(" From %02d:%d0:00 To %02d:%d9:59\r\n\r\n",nh,nm,nh,nm);
    textattr(0x0F);
    cprintf("Remind the user that they will have to setup a NEW password ");
    textattr(0x0C);
    cprintf("NOW!\r\n\r\n");
    textattr(0x07);
    return(0);
}
// **************************************************************************
// temppass.c <end-of-file>

