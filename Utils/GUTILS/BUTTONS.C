#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <mem.h>
#include <alloc.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <graphics.h>

struct palettetype win={16,{0,4,2,6,1,0x3D,3,0x38,7,0x3C,0x3A,0x3E,0x39,5,0x3B,0x3F}};
struct palettetype blk={16,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};

typedef struct {
    char head[10];
    int  offset;
    char res1[6];
    int  wid;
    int  res2;
    int  len;
    char pallet[94];
} BMPH;
BMPH G_bhead;

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
#define ESETRES(a) outpw(0x3CE,((a)<<8)+1)
#define SETRES(a)  outpw(0x3CE,((a)<<8)+0)
#define BITMASK(a) outpw(0x3CE,((a)<<8)+8)
#define MAPMASK(a) outpw(0x3C4,((a)<<8)+2)


void doline(char *scr,char *buf,int nb)
{
asm {
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        PUSH di
        PUSH si
        PUSH ds
        PUSH es

        LDS  di,buf                     // DS:DI = BUF
        LES  si,scr                     // ES:SI = SCR
        MOV  cx,nb                      // CX    = NB
        XOR  bh,bh                      // BH    = MASK
        MOV  bl,ds:[di]; SHR bl,4       // BL    = COL

        MOV  dx,0x3CE  
        MOV  al,01     
        MOV  ah,15     
        OUT  dx,ax     
        JMP  esr15end
}
esr15end:               
asm {
        XOR  al,al     
        MOV  ah,bl     
        OUT  dx,ax     
        JMP  scend   
}
scend:               
asm {
        MOV  dh,0x80                    // DH    = BMASK
        XOR  dl,dl                      // DL    = LMASK
}
outer:
asm {
        PUSH cx
        MOV  cx,dx
        MOV  dx,0x3CE  
        MOV  al,ds:[di]
        SHR  al,4 
        CMP  al,bl 
        JE   colsame 
        MOV  bl,al 
        CMP  bh,cl 
        JE   masksame

        MOV  al, 8 
        MOV  ah,bh 
        OUT  dx,ax 
        JMP  nm1
}
nm1:
asm {
        MOV  cl,bh
}
masksame:
asm {
        MOV  al,es:[si]
        MOV  es:[si],al
        XOR  al,al 
        MOV  ah,bl 
        OUT  dx,ax 
        JMP  nc1
}
nc1:
asm {
        XOR  bh,bh
}
colsame:
asm {
        OR   bh,ch
        SHR  ch,1
        MOV  al,ds:[di] 
        AND  al,15 
        CMP  al,bl 
        JE   colsame1
        MOV  bl,al 
        CMP  bh,cl 
        JE   masksame1

        MOV  al, 8 
        MOV  ah,bh 
        OUT  dx,ax  
        JMP  nm2
}
nm2:
asm {
        MOV  cl,bh
}
masksame1:
asm {
        MOV  al,es:[si]
        MOV  es:[si],al
        XOR  al,al 
        MOV  ah,bl 
        OUT  dx,ax 
        JMP  nc2
}
nc2:
asm {
        XOR  bh,bh
}
colsame1:
asm {
        OR   bh,ch
        SHR  ch,1
        CMP  ch,0
        JNE  notdoneb
        CMP  bh,cl
        JE   masksame2
        MOV  al, 8 
        MOV  ah,bh 
        OUT  dx,ax  
        JMP  nm3
}
nm3:
asm {
        MOV  cl,bh
}
masksame2:
asm {
        MOV  al,es:[si] 
        MOV  es:[si],al
        INC  si 
        XOR  bh,bh 
        MOV  ch,0x80
}
notdoneb:
asm {
        INC  di
        MOV  dx,cx
        POP  cx        
        LOOP outer

        POP  es
        POP  ds
        POP  si
        POP  di
        POP  dx
        POP  cx
        POP  bx
        POP  ax
}
}
void upscr(char *name)
{
    unsigned char *scr=(unsigned char *)0xA00095B0L;
    unsigned char *a,*b,*c,*d,*s;
    int i,fd;

    fd=open(name,O_RDONLY|O_BINARY);
    read(fd,&G_bhead,sizeof(G_bhead));
    a=malloc(38400U);  read(fd,a,38400U);
    b=malloc(38400U);  read(fd,b,38400U);
    c=malloc(38400U);  read(fd,c,38400U);
    d=malloc(38400U);  read(fd,d,38400U);
    close(fd);
//    setallpalette(&blk);
    s=a; for (i=0;i<120;i++) { doline(scr,s,320); scr-=80; s+=320; } free(a);
    s=b; for (i=0;i<120;i++) { doline(scr,s,320); scr-=80; s+=320; } free(b);
    s=c; for (i=0;i<120;i++) { doline(scr,s,320); scr-=80; s+=320; } free(c);
    s=d; for (i=0;i<120;i++) { doline(scr,s,320); scr-=80; s+=320; } free(d);
    BITMASK(0xFF); ESETRES(0); MAPMASK(15);
    setallpalette(&win);
}
int main(int argc,char *argv[])
{
    int fd;
    grafix();
    upscr(argv[1]);
    getch();
    closegraph();
    return(0);
}

