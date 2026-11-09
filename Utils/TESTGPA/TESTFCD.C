#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int isfcdcode(unsigned long code)
{
    int i,j=0,res=0;
    char tmp[9];

    if ((code<1000000L)||(code>=10000000L)) return(0);

    sprintf(tmp,"%ld",code);

    for (i=7;i>=2;i--) res+=i*(tmp[j++]-'0');
    j=tmp[j]-'0';
    res=11-(res%11);
    if (res==j) return(1);
    return(0);
}
int main(int argc,char *argv[])
{
    if (argc<2) {
        printf("TESTFCD CODE\n\n");
        return(1);
    }
    if (isfcdcode(atol(argv[1])))
        printf("%s is an FCD code.\n",argv[1]);
    else
        printf("%s is NOT an FCD code.\n",argv[1]);

    return(0);
}
