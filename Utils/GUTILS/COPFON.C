#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <conio.h>
#include <memory.h>
#include <alloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#define FONTSIZE (32+14*256+16*256)
unsigned char   G_font[FONTSIZE];
unsigned char   G_addinfo[256];
unsigned char   G_cmap[768];

int readfont(char *file)
{
    int fd;
    fd=open(file,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    read(fd,G_font,FONTSIZE);
    read(fd,G_addinfo,256);
    read(fd,G_cmap,768);
    close(fd);
	if ((G_font[31]!='L')&&(G_font[31]!='R')) G_font[31]='L';
    return(1);
}
int writefont(char *file)
{
    int fd;
    fd=open(file,O_RDWR|O_CREAT|O_TRUNC|O_BINARY,S_IREAD|S_IWRITE);
    if (fd==(-1)) return(0);
    write(fd,G_font,FONTSIZE);
    write(fd,G_addinfo,256);
    write(fd,G_cmap,768);
    close(fd);
    return(1);
}
int main(int argc,char *argv[])
{
    unsigned char i,j;
	unsigned char *a,*b,*c,*d;
	memset(G_addinfo,0,256);
    if (argc<3) {
        printf("COPFON fontfile fonfile\n");
        return(0);
    }
    if (!readfont(argv[1])) {
        printf("Can't open fontfile %s\n",argv[1]);
        return(0);
    }
	for (i=0;i<26;i++) {
		a=&G_font[32+('a'+i)*16];
		b=&G_font[32+(1+i)*16];
		c=&G_font[32+(129+i)*16];
		d=&G_font[32+(225+i)*16];
		for (j=0;j<16;j++) {
			*(b+j)=*(a+j);
			*(c+j)=*(a+j);
			*(d+j)=*(a+j);
		}
		a=&G_font[32+16*256+('a'+i)*14];
		b=&G_font[32+16*256+(1+i)*14];
		c=&G_font[32+16*256+(129+i)*14];
		d=&G_font[32+16*256+(225+i)*14];
		for (j=0;j<14;j++) {
			*(b+j)=*(a+j);
			*(c+j)=*(a+j);
			*(d+j)=*(a+j);
		}
	}
    if (!writefont(argv[2])) {
        printf("Can't open fontfile %s\n",argv[2]);
	}
    return(1);
}
