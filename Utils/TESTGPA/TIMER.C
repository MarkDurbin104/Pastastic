
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <io.h>
#include <conio.h>
#include <memory.h>
#include <time.h>
#include <malloc.h>
#include <fcntl.h>
#include <ctype.h>

#include <sys\timeb.h>
#include <sys\types.h>
#include <sys\stat.h>

char *datestr(int type) 
{
    static char tmp[80],*s;
    static struct tm *t;
    static struct timeb tb;
	long l;
    int i,dd,dpy,tdpy,dd1,xit=0;
    int year,mon,day;
   	ftime(&tb);
	t=localtime(&tb.time);
    sprintf(tmp,"%02d:%02d",t->tm_hour,t->tm_min);
    return(tmp);
}
void siren(void)
{
    int i,j,k;
    while (!kbhit()) {
        for (i=5000;i>1000;i-=50) {
            sound(i);
            delay(10);
        }
        nosound();
        for (j=0;j<2;j++) {
        for (i=0;i<10;i++) {
            sound(1000);
            delay(100);
            nosound();
            delay(10);
        }
        delay(500);
        }
    }
}
int main(int argc,char *argv[])
{
    while (strcmp(datestr(9),argv[argc-1])) {
        printf("%s\r",datestr(9));
        if (kbhit()) break;
    }
    siren();
    return 1;
}
