#include <dos.h>
#include <stdio.h>
#include <mem.h>
#include <stdlib.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>

typedef unsigned char uchar;

void putbyte(int x,int y,uchar b)
{
	uchar *scr;
	scr=(uchar *)0xA0000000L+(y*80)+x;
	*scr=b;
}
void cls(void)
{
	outpw(0x3C4,0x0F02);
	outpw(0x3CE,0xFF08);
	outpw(0x3CE,0x0001);
	outpw(0x3CE,0x0003);
	memset((uchar *)0xA0000000L,0,38400U);
}
int main(int argc,char *argv[])
{
	int fd,wid,i,j;
	char tmp[81];
	if (argc<3) {
		printf("BITDUMP file width\n");
		return(0);
	}
	wid=atoi(argv[2]);
	if ((wid<1)||(wid>80)) {
		printf("width must be between 1 and 80\n");
		return(0);
	}
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) {
		printf("Can't Open %s\n",argv[1]);
		return(0);
	}
	asm mov ax,0x12
	asm int 0x10
	j=0;
	while (read(fd,tmp,wid)==wid) {
		for (i=0;i<wid;i++) putbyte(i,j,tmp[i]);
		if ((++j)==479) {
			j=0;
			cls();
			getch();
		}
	}
	if (j!=0) getch();
	asm mov ax,3
	asm int 0x10
	return(1);
}
