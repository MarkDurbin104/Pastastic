#include <conio.h>
int main(void)
{
    int i;
    for (i=0;i<256;i++) {
        if ((i%16)==0) printf("\n");
        cprintf("%c",i&0xFF);
    }
    return 1;
}
