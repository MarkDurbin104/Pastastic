#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

unsigned char *G_font;
unsigned char G_run[32]={0x55,0x8B,0xEC,0xB8,0x00,0x2A,0xCD,0x21,
						 0x81,0xF9,0xC9,0x07,0x7C,0x0B,0x81,0xFA,
						 0x0B,0x0B,0x7C,0x05,0xB8,0x00,0x4C,0xCD,
						 0x21,0xB8,0x01,0x00,0x5D,0xCB,0x10,0x0E};

int getfont(int type)
{
    struct REGPACK r;
    r.r_ax=0x1130;
    r.r_bx=type<<8;
    intr(0x10,&r);
    G_font=(unsigned char *)MK_FP(r.r_es,r.r_bp);
	return(r.r_dx&0xFF);
}
int main(int argc,char *argv[])
{
    int fd,i,j,a;
	char tmp[15];
    if (argc<2) {
        printf("GETFONT FONTFILE\n");
        return(0);
    }
	if (strlen(argv[1])>7) argv[1][7]=0;
	sprintf(tmp,"%s.fnt",argv[1]);
    fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		printf("Couldn't open %s\n",tmp);
	} else {
    	write(fd,G_run,32);
		getfont(6); // 6
		write(fd,G_font,256*16);
		getfont(2); // 2
		write(fd,G_font,256*14);
    	close(fd);
	}
	return(1);
}

