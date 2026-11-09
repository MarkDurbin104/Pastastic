#include <stdio.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "stand16.h"

unsigned char G_font[4096];

int main(int argc,char *argv[])
{
    int fd,i,j;
    struct REGPACK r;
    if (argc<2) {
        printf("GETFONT FONTFILE\n");
        return(0);
    }
    fd=open(argv[1],O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        printf("Can't Open %s\n",argv[1]);
        return(0);
    }

    read(fd,G_font,32);
    read(fd,G_font,4096);
    close(fd);

    r.r_es=FP_SEG(G_font);
    r.r_bp=FP_OFF(G_font);
    r.r_cx=0x100;
    r.r_dx=0;
    r.r_bx=0x1000;
    r.r_ax=0x1100;
    intr(0x10,&r);

    return(1);
}


