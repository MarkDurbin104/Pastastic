#include <conio.h>
#include <dos.h>


int main(void)
{
    int i,j;
    clrscr();
    textattr(0x9E);
    cprintf("TOM - There is a new update TOM0709.ZIP - Mark\r\n");
    textattr(0x07);
    cprintf("\r\n");
    while (!kbhit()) {
        for (i=0;i<100;i++) {
            sound(1000+i*20);
            delay(5);
        }
        nosound();
            for (i=0;i<60;i++) {
                if (kbhit()) break;
                delay(1000);
            }
            if (kbhit()) break;
    }
    getch();
    return(0);
}
