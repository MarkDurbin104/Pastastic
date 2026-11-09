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
#define SOMAP 0x56

typedef unsigned char uchar;
typedef unsigned int  uint;
typedef struct {
	uchar len;
	uchar type;
	uchar fc;
	uchar lc;
	union {
		long ofs;
		uchar far *f;
	} add;
} FMAP;
typedef struct {
	FMAP b;
	uchar len;
	uchar type;
	uchar fc;
	uchar lc;
} FMAP1;

FMAP  G_fonts[100];
FMAP1 G_bfont;
uchar G_fwid=16,G_fhgt=16,G_fbw=2;
uchar  G_nybbmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
void grafix(void) { I { mov ax,0x0012; int 0x10 } }
void closegraf(void) { I { mov ax,0x0003; int 0x10 } }
void cls(void) { I { mov ax,0xA000; mov es,ax; mov ax,0x0F02; mov dx,0x3C4; out dx,ax; mov ax,0; xor di,di; mov cx,19200; rep stosw } }

void putup(int x,int y,uchar *b,int nc)
{
	uint j;
	uchar *scr=(uchar *)0xA0000000L+(y*80)+(x>>3);
	outpw(0x3C4,0x0F02);
	for (j=0;j<G_fhgt;j++) {
		memcpy(scr,b,nc);
		b+=nc;
	    scr+=80;	
	}
}
void prln(int x,int y,uchar *s)
{
	uchar c;
	int ofs;
	x*=8;
	y*=G_fhgt;
	if ((y>(480-G_fhgt))||(x>(640-G_fwid))) return;

	while (*s) {
		if (*s>0xA0) {
			c=*(s++)-0xA1;
			if ((*s)&&(G_fonts[c].fc<=*s)&&(G_fonts[c].lc>=*s)) {
				ofs=(*s-0xA1)*(G_fbw*G_fhgt);
				putup(x,y,&(G_fonts[c].add.f[ofs]),G_fbw);
				x+=G_fwid;
			}
		} else {
			if (*s>31) {
				ofs=(*s*((G_fbw-1)*G_fhgt));
				putup(x,y,&(G_bfont.b.add.f[ofs]),G_fbw-1);
				x+=G_fwid-8;
			}
		}
		if (x>640-G_fwid) return;
		s++;
	}
}
void *mymalloc(size_t size)
{
    void *tmp;
	if (size==0) return(NULL);
    tmp=malloc(size);
    if (tmp==NULL) {
        printf("Memory Error\n");
		exit(-1);
    }
    memset(tmp,0,size);
    return(tmp);
}
void prch(unsigned char c)
{
	if (c==26) c=25; if (c==10) c=9;
	fprintf(stdprn,"%c",c);
}
void pr3(unsigned char a,unsigned char b,unsigned char c)
{
	prch(a);
	prch(b);
	prch(c);
}
unsigned int doub(unsigned char c)
{
I   mov ah,c
I   xor al,al
I   shr ax,4
I   shr al,4
I	mov si,offset G_nybbmap
I   xor bh,bh
I   mov bl,ah
I   mov dh,byte ptr ds:[si+bx]
I   mov bl,al
I   mov dl,byte ptr ds:[si+bx]
//I   xchg dl,dh
    return(_DX);
}

void pr3d(unsigned char a,unsigned char b,unsigned char c)
{
	unsigned int d;
	d=doub(a); prch(d>>8); prch(d&0xFF);
	d=doub(b); prch(d>>8); prch(d&0xFF);
	d=doub(c); prch(d>>8); prch(d&0xFF);
}
int main(int argc,char *argv[])
{
	int i,j,k,fd;
	FILE *fp;
	long l;
	uchar ch[24*3*16],tmp;
	
	if ((fd=open(argv[1],O_RDONLY|O_BINARY))==(-1)) return(0);
	G_fwid=24;
	G_fhgt=24;
	G_fbw=3;
	l=filelength(fd);
	i=(int)(l/(G_fhgt*G_fbw));
	i/=16;
	lseek(fd,0L,SEEK_SET);
	for (j=0;j<40;j++) {
		read(fd,ch,24*3*16);
		for (l=0;l<24;l++) {
			fprintf(stdprn,"%c",0x11);
			for (k=0;k<16;k++) {
				pr3(ch[k*72+l*3],ch[k*72+l*3+1],ch[k*72+l*3+2]);
			}
		}
	}
	fprintf(stdprn,"%c",0x16);
	lseek(fd,72L*12000L,SEEK_SET);
	for (j=0;j<20;j++) {
		read(fd,ch,24*3*8);
		for (l=0;l<24;l++) {
			fprintf(stdprn,"%c",0x11);
			for (k=0;k<8;k++) pr3d(ch[k*72+l*3],ch[k*72+l*3+1],ch[k*72+l*3+2]);
			fprintf(stdprn,"%c",0x11);
			for (k=0;k<8;k++) pr3d(ch[k*72+l*3],ch[k*72+l*3+1],ch[k*72+l*3+2]);
		}
	}
	close(fd);
	fprintf(stdprn,"%c",0x16);
	return(1);

}


