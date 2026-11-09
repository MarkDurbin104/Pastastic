#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include <conio.h>
#include <stdio.h>

typedef void interrupt (*ISRPTR)(void);
ISRPTR                   oldtick;

void touchit(void)
{
    int fd;
    fd=open("c:\\touchhd.dat",O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
    if (fd!=(-1)) {
        write(fd,&fd,1);
        close(fd);
    }
}
void interrupt ticker(void)
{
    static long l=0;
    (oldtick)();
    l++;
    if (!(l%182L)) touchit();
}
int main(void)
{
    oldtick=getvect(0x1C);
    setvect(0x1C,ticker);
    while (!kbhit()) printf(".");
    asm {
	    mov ax,0x3100
		mov dx,800
		int 0x21
	}
    return(0);
}
