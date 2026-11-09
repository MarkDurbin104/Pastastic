#include <stdio.h>
#include <dos.h>
#include <stdlib.h>
#include <conio.h>

typedef void (*CBPTR)(void);
void callcb(CBPTR cb)
{
    char *t=(char *)cb;
    int i;
    printf("dump %Fp\n",cb);
    for (i=0;i<10;i++) printf("%02X ",((*t++)&0xFF));
    printf("\nGoing to callback\n");
    (cb)();
    printf("Back from callback\n");
}
int main(int argc,char *argv[])
{
    int i;
    unsigned int s,o;
    unsigned long l;
    printf("Running 16bit real mode app.\nArgs = ");
    for (i=0;i<argc;i++) printf("%s ",argv[i]);
    l=atol(argv[1]);
    s=(unsigned int)((l>>16L)&0xFFFFL);
    o=(unsigned int)(l&0xFFFFL);
    printf("\ncallback address %04X:%04X %Fp\n",s,o,MK_FP(s,o));
    printf("Ready to try call back ?  Then press a key. (ESC - quit)");
    if (getch()==27) return(2);
    printf("\n");
    if (!l) {
        printf("Bad callback address!!!!!\nPress a key to exit");
        getch();
        printf("\n");
        return(1);
    }
    callcb((CBPTR)MK_FP(s,o));
    printf("Back in 16bit app.\n press a key to exit");
    getch();
    printf("\n");
    return(0);
}
