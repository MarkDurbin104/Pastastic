#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <mem.h>
#include <alloc.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

#include <dir.h>         // For mkdir()
#include <dos.h>         // For file attributes

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

unsigned int G_cnt=0;

unsigned char *G_line;
unsigned char G_buf[1920];
unsigned char **G_sbuf;
unsigned char G_wbuf[38400U];

int Exists(char *file)
{
    struct ffblk f;
    return (findfirst(file,&f,FILEATTR)!=(-1));
}

void putpix(int x,int y,int col)
{
    int j,k;
    j=x>>3;
    k=0x80>>(x&7);
    y*=80;

    if (col&1) G_sbuf[0][j+y]|=k;
    if (col&2) G_sbuf[1][j+y]|=k;
    if (col&4) G_sbuf[2][j+y]|=k;
    if (col&8) G_sbuf[3][j+y]|=k;
}
void putlines(void)
{
	unsigned char *d=(unsigned char *)0xA0000000L;
    int i;
    for (i=0;i<4;i++) {
        outp(0x3C4,2);
        outp(0x3C5,1<<i);
        memcpy(d,G_sbuf[i],38400U);
    }
}
int grafix(void)
{
    int gd = VGA;
	int gm = VGAHI;
    int err;

    initgraph(&gd,&gm,"");
    err=graphresult();
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
	}
    return(1);
}
void DoIt(void)
{
    int fd;
    int i,j;
    int c;
    long lng;

    fd=open("C:\\Screen.BMP",O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        printf("Can't Open Screen.bmp\n");
        return;
    }

    read(fd,G_buf,0x36);

    for (i=479;i>=0;i--) {
        read(fd,G_buf,640*3);
        G_line=G_buf;
        for (j=0;j<640;j++) {
            lng=((long)*(G_line++))<<16;
            lng|=((long)*(G_line++))<<8;
            lng|=((long)*(G_line++));
            switch (lng) {
                case 0x0L      : c=0;  break;
                case 0x000080L : c=4;  break;
                case 0x008000L : c=2;  break;
                case 0x008080L : c=6;  break;
                case 0x800000L : c=1;  break;
                case 0x800080L : c=5;  break;
                case 0x808000L : c=3;  break;
                case 0xC0C0C0L : c=7;  break;
                case 0x808080L : c=8;  break;
                case 0x0000FFL : c=12; break;
                case 0x00FF00L : c=10; break;
                case 0x00FFFFL : c=14; break;
                case 0xFF0000L : c=9;  break;
                case 0xFF00FFL : c=13; break;
                case 0xFFFF00L : c=11; break;
                case 0xFFFFFFL : c=15; break;
                default : c=8;
            }
            putpix(j,i,c);
        }
    }
    close(fd);

    putlines();
}
int main(void)
{
    int i;
    if ((G_sbuf=malloc(4*sizeof(char *)))==NULL) return(0);
    for (i=0;i<4;i++) {
        if ((G_sbuf[i]=malloc(38400U))==NULL) {
            printf("Out of memory\n");
            return(0);
        }
        memset(G_sbuf[i],0,38400U);
    }
    if (!grafix()) return(0);
    DoIt();
    for (i=0;i<4;i++) free(G_sbuf[i]);
    free(G_sbuf);
    return(0);
}


