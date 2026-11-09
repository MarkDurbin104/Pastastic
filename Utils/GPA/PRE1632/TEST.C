#include <stdio.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <malloc.h>

#define GREGYEAR	1980
#define GREGSTART   0
char G_gdpm[13]="";
char *b62nums="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

int getday(char *dt)
{
    return(((dt[4]-'0')*10)+(dt[5]-'0'));
}
int getmon(char *dt)
{
    return(((dt[2]-'0')*10)+(dt[3]-'0'));
}
int getyear(char *dt)
{
    return(((dt[0]-'0')*10)+(dt[1]-'0'));
}
unsigned int datetonum(char *dt)
{
    int i;
    unsigned int dd;
    int d,m,y,dpy;
    
    d=getday (dt);
    m=getmon (dt);
    y=getyear(dt);

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
long pdnum(char *date,char *time)
{
    long d;
    d=(long)datetonum(date)*144L;
    d+=(long)((((time[0]-'0')*10)+(time[1]-'0'))*6)+(time[2]-'0');
    return(d);
}
char *numtob62(long n)
{
    int i,j;
    static char ret[5];
    for (i=3;i>=0;i--) {
        j=(int)(n%62L);
        n/=62;
        ret[i]=b62nums[j];
    }
    ret[4]=0;
    return(ret);
}
long b62tonum(char *n)
{
    int j;
    long ret=0;
    while (*n) {
        ret*=62L;
        if ((*n>='0')&&(*n<='9')) {
            j=*n-'0';
        } else if ((*n>='A')&&(*n<='Z')) {
            j=(*n-'A')+10;
        } else if ((*n>='a')&&(*n<='z')) {
            j=(*n-'a')+36;
        }
        ret+=(long)j;
        n++;
    }
    return(ret);
}
int main(void)
{
    char d[10],t[10];
    int i;
    printf("0000=%ld=%s ", b62tonum("0000"),numtob62(b62tonum("0000")));
    printf("0009=%ld=%s ", b62tonum("0009"),numtob62(b62tonum("0009")));
    printf("000A=%ld=%s ", b62tonum("000A"),numtob62(b62tonum("000A")));
    printf("000Z=%ld=%s ", b62tonum("000Z"),numtob62(b62tonum("000Z")));
    printf("000a=%ld=%s ", b62tonum("000a"),numtob62(b62tonum("000a")));
    printf("000z=%ld=%s\n",b62tonum("000z"),numtob62(b62tonum("000z")));
    printf("0000=%ld=%s ", b62tonum("0000"),numtob62(b62tonum("0000")));
    printf("0090=%ld=%s ", b62tonum("0090"),numtob62(b62tonum("0090")));
    printf("00A0=%ld=%s ", b62tonum("00A0"),numtob62(b62tonum("00A0")));
    printf("00Z0=%ld=%s ", b62tonum("00Z0"),numtob62(b62tonum("00Z0")));
    printf("00a0=%ld=%s ", b62tonum("00a0"),numtob62(b62tonum("00a0")));
    printf("00z0=%ld=%s\n",b62tonum("00z0"),numtob62(b62tonum("00z0")));
    printf("000z=%ld=%s\n",b62tonum("000z"),numtob62(b62tonum("000z")));
    printf("0000=%ld=%s ", b62tonum("0000"),numtob62(b62tonum("0000")));
    printf("0900=%ld=%s ", b62tonum("0900"),numtob62(b62tonum("0900")));
    printf("0A00=%ld=%s ", b62tonum("0A00"),numtob62(b62tonum("0A00")));
    printf("0Z00=%ld=%s ", b62tonum("0Z00"),numtob62(b62tonum("0Z00")));
    printf("0a00=%ld=%s ", b62tonum("0a00"),numtob62(b62tonum("0a00")));
    printf("0z00=%ld=%s\n",b62tonum("0z00"),numtob62(b62tonum("0z00")));
    printf("000z=%ld=%s\n",b62tonum("000z"),numtob62(b62tonum("000z")));
    printf("0000=%ld=%s ", b62tonum("0000"),numtob62(b62tonum("0000")));
    printf("9000=%ld=%s ", b62tonum("9000"),numtob62(b62tonum("9000")));
    printf("A000=%ld=%s ", b62tonum("A000"),numtob62(b62tonum("A000")));
    printf("Z000=%ld=%s ", b62tonum("Z000"),numtob62(b62tonum("Z000")));
    printf("a000=%ld=%s ", b62tonum("a000"),numtob62(b62tonum("a000")));
    printf("z000=%ld=%s\n",b62tonum("z000"),numtob62(b62tonum("z000")));
    printf("zzzz=%ld=%s\n",b62tonum("zzzz"),numtob62(b62tonum("zzzz")));

    for (i=0;i<60;i++) {
        strcpy(d,"940811");
        sprintf(t,"16%02d00",i); 
        printf("%c%c/%c%c/%c%c %c%c:%c%c:%c%c=%ld",d[0],d[1],d[2],d[3],d[4],d[5],t[0],t[1],t[2],t[3],t[4],t[5],pdnum(d,t));
        printf("=%s=",numtob62(pdnum(d,t)));
        printf("=%ld\n",b62tonum(numtob62(pdnum(d,t))));
    }
    
    return(0);
}
