#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <dos.h>
#include <mem.h>
#include <alloc.h>
#include <fcntl.h>
#include <time.h>
#include <stdlib.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

unsigned char **G_sbuf;
unsigned char *G_wbuf;

void putlines(int wid,int len)
{
	unsigned char *d=(unsigned char *)0xA0000000L;
    int i,j,k;
    k=0;
    if (wid==80) {
        for (j=0;j<len;j+=len/4) {
            for (i=0;i<4;i++) {
                outp(0x3C4,2);
                outp(0x3C5,1<<i);
                memcpy(d,&G_sbuf[i][k],(unsigned)wid*(len/4));
            }
            d+=(unsigned)wid*(len/4);
            k+=(unsigned)wid*(len/4);
        }        
    }
    else {
        for (j=0;j<len;j++) {
            for (i=0;i<4;i++) {
                outp(0x3C4,2);
                outp(0x3C5,1<<i);
                memcpy(d,&G_sbuf[i][k],wid);
            }
            d+=80;
            k+=80;
        }
    }
}
int grafix(void)
{
    int gd = VGA;
	int gm = VGAHI;
    int err;

	err=registerfarbgidriver(EGAVGA_driver_far);
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
		return(0);
	}
    initgraph(&gd,&gm,"");
    err=graphresult();
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
	}
    return(1);
}
void unpack(int fd,unsigned int *buf)
{
    unsigned int i,j;
    unsigned int num;
    unsigned int cnt=0;

    read(fd,&num,sizeof(int));
    read(fd,G_wbuf,num);
    for (j=0;j<num;j+=3) {
        for (i=0;i<G_wbuf[j];i++) {
            buf[cnt++]=(G_wbuf[j+1]&0xFF)|(G_wbuf[j+2]<<8);
//            if (cnt>19200) return;
        }
    }
}
int getcol(int x,int y,int *f,int nf,int skip)
{
	int i;
	if (skip==(nf-1)) nf--;
	for (i=0;i<nf;i++) {
		if (i==skip) {
			f+=3;
		}
		if (*(f++)==x) {
			if (*(f++)==y) {
				return(*f);
			} else {
				f++;
			}
		} else {
			f+=2;
		}
	}
	return(getpixel(x,y));
}
void snow(int nf)
{
	int *f;
	int i;
	int c,x,y;
	f=malloc(nf*4);
	if (f==NULL) return;
	randomize();
	for (i=0;i<nf;i++) {
		x=f[i*3]=random(640);
		y=f[i*3+1]=random(480);
		f[i*3+2]=getpixel(x,y);
	}
	for (i=0;i<nf;i++) putpixel(f[i*3],f[i*3+1],15);
	while (!kbhit()) {
		for (i=0;i<nf;i++) {
			x=f[i*3];
			y=f[i*3+1];
			c=f[i*3+2];
			f[i*3]+=random(3)-1;
			if (f[i*3]<0) f[i*3]+=640;
			f[i*3]%=640;
			f[i*3+1]+=random(7);
			f[i*3+1]%=480;
			putpixel(x,y,c);
			f[i*3+2]=getcol(f[i*3],f[i*3+1],f,nf,i);
			putpixel(f[i*3],f[i*3+1],15);
		}
	}
	getch();
	free(f);
}
int main(int argc,char *argv[])
{
    int fd;
    int i,j;
    int wid,len;
    int sty;
    if (argc<2) {
        printf("CBMP filename\n");
        return(1);
    }

    fd=open(argv[1],O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        printf("Can't open %s\n",argv[1]);
        return(1);
    }

    read(fd,&sty,sizeof(int));
    if (sty!=0x55AA) {
        wid=sty;
        read(fd,&len,sizeof(int));
        if ((G_sbuf=malloc(4*sizeof(char *)))==NULL) return(0);
        for (i=0;i<4;i++) {
            if ((G_sbuf[i]=malloc(38400))==NULL) return(0);
            read(fd,G_sbuf[i],38400);
        }
    }
    else {
        read(fd,&wid,sizeof(int));
        read(fd,&len,sizeof(int));
        if ((G_wbuf=malloc(38400))==NULL) return(0);
        if ((G_sbuf=malloc(4*sizeof(char *)))==NULL) return(0);
        for (i=0;i<4;i++) {
            if ((G_sbuf[i]=malloc(38400))==NULL) return(0);
            unpack(fd,(unsigned int *)G_sbuf[i]);
        }
        free(G_wbuf);
    }

    close(fd);

    if (!grafix()) return(0);
    putlines(wid>>3,len);
    for (i=0;i<4;i++) free(G_sbuf[i]);
    free(G_sbuf);
    getch();
	snow(200);
    closegraph();
    return(0);
}

