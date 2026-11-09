#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <mem.h>

typedef unsigned int UINT;

UINT *G_scr=(unsigned int *)0xB8000000L;

void interrupt (*oldmirq)(void);
void interrupt (*newmirq)(void);

void interrupt mymirq(UINT bp,UINT di,UINT si,UINT ds,UINT es,UINT dx,UINT cx,UINT bx,UINT ax,UINT ip,UINT cs,UINT flags,...)
{
    char tmp[80],*t;
    UINT *s=G_scr;
    disable();
    sprintf(tmp,"%04X %04X %04X %04X %04X %04X %04X %04X %04X %04X %04X %04X",bp,di,si,ds,es,dx,cx,bx,ax,ip,cs,flags);
    t=tmp;
    while (*t) *(s++)=0x0C00|*(t++);
    enable();
    (oldmirq)();
}
int main(void)
{
    clrscr();
    newmirq=mymirq;
    oldmirq=getvect(0x13);
    setvect(0x13,newmirq);
    system("dir a:");
    setvect(0x13,oldmirq);
    return(1);
}
