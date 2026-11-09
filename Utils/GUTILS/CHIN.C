#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <conio.h>
#include <sys\types.h>
#include <sys\stat.h>

#define I asm
#define NUMP 3
int G_pn[NUMP]={0,1,2};
char G_buf[38000];
int  G_map[10000];
int G_numm=0;
void grafix(void)
{
I	mov ax,0x0012
I	int 0x10
}
void closegraf(void)
{
I	mov ax,0x0003
I	int 0x10
}
void cls(void)
{
I	mov ax,0xA000
I	mov es,ax
I   mov ax,0x0F02
I   mov dx,0x3C4
I   out dx,ax
I	mov ax,0xFFFF
I	xor di,di
I	mov cx,19200
I	rep stosw
}
void putup(int x,int y,unsigned char *b,int nc,int h,unsigned char ch)
{
	unsigned int j;
	unsigned char *scr=(unsigned char *)0xA0000000L+(y*80)+(x>>3);
	if (ch==1) outpw(0x3C4,0x0F02); else outpw(0x3C4,0x0C02);
	for (j=0;j<h;j++) {
		memcpy(scr,b,nc);
		b+=nc;
	    scr+=80;	
	}
}
int main(int argc,char *argv[])
{
	unsigned int w,i,j,pn=0;
	int ofs,fdo,fd,fst=0;
	int cnt=0;
	unsigned char ch;
	unsigned char tmp[100];
	
	w=24;
	if ((fdo=open("fnt.map",O_RDONLY|O_BINARY))!=(-1)) {
		read(fdo,&G_numm,sizeof(int));
		read(fdo,G_map,G_numm*sizeof(int));
    	close(fdo);
	}
	for (i=218;i<G_numm;i++) G_map[i-1]=G_map[i];
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	lseek(fd,0x352,SEEK_SET);
	if (w==24) lseek(fd,0x383,SEEK_SET);
	grafix();
	while (read(fd,&ch,1)==1) {
		j=w*(w/8);
		if (ch<128) j-=w;
		if (G_map[fst]!=cnt) {
			read(fd,tmp,j);
		} else {
			memset(tmp,0,100);
			read(fd,tmp,j);
			for (i=0;i<j;i++) tmp[i]=~tmp[i];
			if (!(fst%300)) cls();
			ch-=0xA1;
			putup(((fst%300)%20)*32,((fst%300)/20)*32,tmp,j/w,w,ch);
			memcpy(G_buf+ch*32,tmp,32);
			if ((fst%300)==299) if (getch()==27) close(fd);
			fst++;
		}
		cnt++;
	}
	getch();
    close(fd);
	closegraf();
	printf("%d",pn);
	return(1);
}


