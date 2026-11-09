#include <stdio.h>
#include <time.h>
#include <mem.h>
#include <dos.h>
#include "keydef.h"
#include "scancode.h"

typedef void (far *FPTR)(void);

void interrupt (*oldkeyb)();

#define PC          0
#define CT          1
#define ENDOFBUF    0x80
#define DATTR       0x0C
#define UATTR       0x0A

volatile unsigned char  G_shiftstat=0;
volatile int            G_extnext=0;
unsigned char  			G_keybuf[ENDOFBUF+1];
volatile unsigned int   G_kpstart=0;
volatile unsigned int   G_kpend=0;
volatile int            G_keypress=0;
int                     *G_scanmap;
int                     Location;
int                     G_hadcrdn=0;
unsigned int			G_ofs;
unsigned int			G_seg;

unsigned char G_tl[]=" ษอAอหอBอหอCอหอDอหอEอหอFอหอGอหอHอหอIอหอJอหอKอหอLอหอMอหอNอหอOอป ";
unsigned char G_m1[]=" บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ   บ ";
unsigned char G_m2[]=" ฬอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออฮอออน ";
unsigned char G_bl[]=" ศอออสอออสอออสอออสอออสอออสอออสอออสอออสอออสอออสอออสอออสอออสอออผ ";

unsigned char G_scanlyt[7][15]={
 {0x3C,0x0C,0x0D,0x35,0x36,0x54,0x55,0x56,0x57,0x42,0x43,0x44,0x3A,0x45,0x46},
 {0x0F,0x29,0x58,0x2B,0x59,0x1A,0x1B,0x27,0x5A,0x5B,0x28,0x5C,0x5D,0x47,0x49},
 {0x5E,0x5F,0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x4A,0x4E,0x4F,0x51},
 {0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x3F,0x08,0x09,0x0A,0x41},
 {0x3B,0x1E,0x1F,0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x3E,0x05,0x06,0x07,0x40},
 {0x01,0x2C,0x2D,0x2E,0x2F,0x30,0x31,0x32,0x33,0x34,0x3D,0x02,0x03,0x04,0x00},
 {0x2A,0x1D,0x38,0x00,0x39,0x00,0x48,0x50,0x4B,0x4D,0x0E,0x53,0x0B,0x52,0x1C}
};
unsigned char G_scanpos[105]={
0x5E,0x50,0x5B,0x5C,0x5D,0x4B,0x4C,0x4D,0x3B,0x3C,0x3D,0x6C,0x01,0x02,0x6A,
0x10,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x15,0x16,0x6E,0x61,
0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x17,0x1A,0x11,0x60,0x13,0x51,
0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x03,0x04,0x00,0x62,0x64,0x0C,0x40,
0x00,0x5A,0x4A,0x3A,0x4E,0x3E,0x09,0x0A,0x0B,0x0D,0x0E,0x1D,0x66,0x1E,0x2B,
0x68,0x69,0x2C,0x2D,0x67,0x2E,0x6D,0x6B,0x05,0x06,0x07,0x08,0x12,0x14,0x18,
0x19,0x1B,0x1C,0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x00};

unsigned char G_keystat[7][15];

#define LSHIFT      0x01
#define RSHIFT      0x02
#define CTRL        0x04
#define ALT         0x08
#define CAPSL       0x10
#define NUML        0x20
#define SCROLLL     0x40
#define INSL        0x80

#define EXTENDED    0xE0

void prline(int x,int y,unsigned char *str)
{
    unsigned int far *s;
    unsigned int attr;

    if (Location==CT) {
        s=(unsigned int far *)0xB0000000L;
    } else {
        s=(unsigned int far *)0xB8000000L;
    }
    s+=x+y*80;
    attr=0x0700;

    while (*str) *(s++)=attr|*(str++);
}
// buffer a keypress
// keyboard interrupt routine
unsigned int findkey(int k)
{
	int i,j;
	for (i=0;i<7;i++) {
		for (j=0;j<15;j++) {
			if (G_scanlyt[i][j]==k) return(((i<<8)|j)|0x80);
		}
	}
	return(0);
}
void markkey(int x,int y,int s,int k)
{
	if (k==SPACE) {
		if (s==1) {
			prline(6+x*4,5+y*2,"ÜÜÜÜÜÜÜÜÜÜÜ");
		} else {
			prline(6+x*4,5+y*2,"ÛÛÛÛÛÛÛÛÛÛÛ");
		}
	} else if (k==CR) {
		if (s==1) {
			prline(10+x*4,3+y*2,"   ");
			prline(10+x*4,4+y*2,"ÜÜÜ");
			prline(10+x*4,5+y*2,"ÛÛÛ");
		} else {
			prline(10+x*4,3+y*2,"ÛÛÛ");
			prline(10+x*4,4+y*2,"ÛÛÛ");
			prline(10+x*4,5+y*2,"ÛÛÛ");
		}
	} else {
		if (s==1) {
			prline(10+x*4,5+y*2,"ÜÜÜ");
		} else {
			prline(10+x*4,5+y*2,"ÛÛÛ");
		}
	}
    G_keystat[y][x]=s;
}
void interrupt mykeyb(void)
{
	asm {
		CLI
		MOV BX,OFFSET G_keybuf
		ADD BX,G_kpend
		MOV DX,0x60
		IN  AL,DX
		MOV DS:[BX],AL
		INC G_kpend
		CMP G_kpend,ENDOFBUF
		JLE	dontloop
		MOV G_kpend,0
	}
dontloop:
	asm {
		MOV DX,0x61
		IN  AL,DX
		OR  AL,0x80
		OUT DX,AL
		AND AL,0x7F
		OUT DX,AL
		MOV DX,0x20
		MOV AL,DL
		OUT DX,AL
		STI
	}
}
void far prockey(void)
{
	asm {
		PUSH DS
		PUSH CS
		POP  DS
		MOV BX,OFFSET G_keybuf
		ADD BX,G_kpend
		MOV CS:[BX],AL
		INC G_kpend
		CMP G_kpend,ENDOFBUF
		JLE	dontloop
		MOV G_kpend,0
	}
dontloop:
	asm {
		POP DS
		MOV AX,-1
		MOV BX,AX
		XOR DX,DX
	}
}
int ismos (void)
{
    union REGS regs;
    int ax;

    regs.x.dx=regs.x.cx=regs.x.bx=regs.x.ax=0x3000;
    intdos(&regs,&regs);
    ax=regs.x.ax;
    regs.x.ax=0x30ff;             /* Make AX different */
    intdos(&regs,&regs);

    return(ax!=regs.x.ax);       /* If different, then MOS, else DOS */
}
int getscan(void)
{
	int k;
	int kpress,mappos;

    if (G_kpstart==G_kpend) return(0);
    k=G_keybuf[G_kpstart++];
    if (G_kpstart>ENDOFBUF) G_kpstart=0;

    kpress=G_scanmap[((k&0x7F)*5)+0];
    mappos=findkey((k&0x7F));
    if (k&0x80) {       // release code
        if ((kpress==CR)&&(!G_hadcrdn)) mappos=0;
        if (mappos) markkey(mappos&0x7F,mappos>>8,2,kpress);
        if ((kpress==CR)&&(G_hadcrdn)) return(1);
    }
    else {                  // press code
        if (mappos) markkey(mappos&0x7F,mappos>>8,1,kpress);
        if (kpress==CR) G_hadcrdn=1;
        G_keypress=1;
    }
	return(0);
}
int kbd_startup(void)
{
	if (!ismos()) {
	    oldkeyb=getvect(0x09);
	    setvect(0x09,mykeyb);
	} else {
		asm mov ah,2
		asm int 0xD4
		asm mov AX,word ptr es:[bx+0x02b2]
		asm mov G_ofs,AX
		asm mov AX,word ptr es:[bx+0x02b4]
		asm mov G_seg,AX
		asm mov word ptr es:[bx+0x02b2],offset prockey
		asm mov word ptr es:[bx+0x02b4],cs
	}
    G_scanmap=scanmap;
    return(1);
}
// keyboard shutdown routine
int kbd_shutdown(void)
{
	if (!ismos()) {
	    setvect(0x09,oldkeyb);
	} else {
		asm mov ah,2
		asm int 0xD4
		asm mov AX,G_ofs
		asm mov word ptr es:[bx+0x02b2],AX
		asm mov AX,G_seg
		asm mov word ptr es:[bx+0x02b4],AX
	}
    return(1);
}
void displaykbd(void)
{
    int i,j;
    char tmp[20];
    prline(8,4,G_tl);
    G_m1[1]='1';
    prline(8,5,G_m1);
    for (i=0;i<6;i++) {
        prline(8,6+i*2,G_m2);
        G_m1[1]='2'+i;
        prline(8,7+i*2,G_m1);
    }
    prline(8,6+i*2,G_bl);
    prline(25,4+i*2,"สอออส");
    prline(25,5+i*2,"     ");
    prline(25,6+i*2,"อออออ");
    prline(65,4+i*2,"น   บ");
}
int main(int argc)
{
    int i,j,err=0;
    FILE *fp;
    time_t stop,start;

    if (argc<2) Location=PC; else Location=CT;
    memset(G_keystat,0,sizeof(G_keystat));
    G_keystat[6][3]=2;
    G_keystat[6][5]=2;
    G_keystat[5][14]=2;
    kbd_startup();
    displaykbd();
    time(&start);
    while ((!getscan())&&(!err)) {
        time(&stop);
        if ((stop-start)>=20) err=1;
        if (G_keypress) {
            G_keypress=0;
            time(&start);
        }
    }
    kbd_shutdown();
    unlink("KBDERR.LOG");
    fp=fopen("KBDERR.LOG","w");
    if (fp==NULL) return(0);
    if (err) {
        fprintf(fp,"Skipped\n");
        fclose(fp);
        return(1);
    }
    for (i=0;i<7;i++) {
        for (j=0;j<15;j++) {
            switch (G_keystat[i][j]) {
                case 0 :
                    fprintf(fp,"Error KEY [%c%c]\n",'1'+i,'A'+j);
                    err=1;
                    break;
                case 1 :
                    fprintf(fp,"Error KEY [%c%c] Stuck\n",'1'+i,'A'+j);
                    err=1;
                    break;
            }
        }
    }
    if (!err) fprintf(fp,"Passed\n");
    fclose(fp);
    return(1);
}
