#include <stdio.h>
#include <stdlib.h>

int mod11(unsigned long code)
{
    int res=0,cnt=2;
    while (code) {
        res+=(cnt++)*(code%10);
        code/=10;
    }
    return(11-(res%11));
}

int main(int argc,char *argv[])
{
    if (argc<2) return 0;

    printf("%d",mod11(atol(argv[1])));
    return 1;
}
