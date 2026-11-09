#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <alloc.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>
#include "types.h"
#include "gprim.h"

#define I asm

typedef void interrupt  (*ISRPTR)(void);
ISRPTR                  oldkeyb;

volatile  INT           G_hadkey=0;

// keyboard interrupt routine
void interrupt mykeyb(void)
{
    unsigned char stat;
    static int down=0;
    int k;

    disable();
    k=inp(0x60);
    if (k&0x80) {
        if (down) G_hadkey=1;
    } else {
        down=1;
    }
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);
    enable();
}
int main(int argc)
{
    oldkeyb=getvect(0x09);
    setvect(0x09,mykeyb);

	if (argc==2) grafix(0);
    setcol(15);
    moveto(0,100);
    lineto(100,100);
    tinyxy(15,10,10,"Hello World %ld",coreleft());
    while (!G_hadkey) {
        ;       // save screen code here
    }
    setvect(0x09,oldkeyb);
    if (argc==2) vidint(0x03);
    return 0;
}
