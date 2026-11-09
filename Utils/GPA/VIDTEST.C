#include <dos.h>
#include <memory.h>
#include <stdio.h>
#include <conio.h>
#include <malloc.h>

// Assembly macros so bcc32 doesn't need to call tasm32 (I haven't got tasm32)
#define LAR_EAX_EBX  {__emit__ (0x0F); __emit__(0x02); __emit__(0xC3);}
#define LSL_EAX_EBX  {__emit__ (0x0F); __emit__(0x03); __emit__(0xC3);}
#define PUSH_BX      {__emit__ (0x53);}
#define POP_BX       {__emit__ (0x5B);}
#define OUT_DX_AL    {__emit__ (0xEE);}
#define OUT_DX_AX    {__emit__ (0xEF);}

typedef unsigned long  INT;
typedef unsigned short INT16;
typedef unsigned char  CHAR;

#define OUTPB(a,b) { _DX=(INT16)a; _AL=(CHAR )b; __emit__(0xEE);}
#define OUTPW(a,b) { _DX=(INT16)a; _AX=(INT16)b; __emit__(0xEF);}

#define BITMASK(a)     OUTPB(0x3CE,8); OUTPB(0x3CF,a)
#define MAPMASK(a)     OUTPB(0x3C4,2); OUTPB(0x3C5,a)
#define ESETRES(a)     OUTPB(0x3CE,1); OUTPB(0x3CF,a)
#define SETRES(a)      OUTPB(0x3CE,0); OUTPB(0x3CF,a)
#define SETMODE(a)     OUTPB(0x3CE,5); OUTPB(0x3CF,a)
#define WRITEPLANE(a)  OUTPB(0x3C4,2); OUTPB(0x3C5,(1<<a))
#define WRITEPLANES(a) OUTPB(0x3C4,2); OUTPB(0x3C5,a)
#define READPLANE(a)   OUTPB(0x3CE,4); OUTPB(0x3CF,a)

#define PAGESIZE 0x1000   // page size is always 4k

INT getlowmem(INT addr,INT np,INT *h)
{
    static INT ofs;
    static INT len;
    len=np*0x1000;

    _AX =0x0504;         // DPMI 0504h: Allocate Linear Memory Block
    _EBX=0;              // let DPMI pick the address
    _ECX=len;            // length in bytes
    _EDX=0;              // uncommitted
    geninterrupt(0x31);
    if (_FLAGS&1) {
        *h=0;
        return(0);
    }
    ofs=_EBX;            // DPMI returns the new linear address
    *h =_ESI;            // DPMI returns the handle to this memory block

    _AX=0x0508;          // DPMI 0508h: Map Device in Memory Block
                         // _ESI is already set to handle
    _EBX=0;              // start at offset 0 into our memory block
    _ECX=np;             // the number of pages to map
    _EDX=addr;           // the target address range to be mapped in
    geninterrupt(0x31);
    if (_FLAGS&1) {
        *h=0;
        return(0);
    }
    return(ofs);
}

INT getlimit(INT16 sel)
{
    _EBX=0;
    _BX=sel;
    LSL_EAX_EBX;
    return(_EAX);
}

void setlimit(INT16 sel,INT off)
{
    static INT16 h,l;
    h=(INT16)(off>>16);
    l=(INT16)(off&0xFFFF);
    _AX=8;                      // DPMI 0008h: Set Selector Limit
    _BX=sel;
    _CX=h;
    _DX=l;
    geninterrupt(0x31);
}

INT getbase(INT16 s)
{
    INT16 upr,lwr;

    PUSH_BX;
    _EBX=0;
    _EAX=0;
    _BX =s;
    _AX =6;                    // DPMI 0006h: Get Selector Base Address
    geninterrupt (0x31);
    POP_BX;
    if (_FLAGS&1) return(-1);
    upr=_CX;
    lwr=_DX;
    return(((INT)upr)*0x10000L+lwr);
}

void *makeptr(INT mem,INT len,INT *h)
{
    INT sel,length;
    length=(len+PAGESIZE-1)/PAGESIZE;
    sel=getlowmem(mem,length,h);               // Allocate and map memory.
    setlimit(_DS,getlimit(_DS)+(length*PAGESIZE)); // increase DS's limit
    return((void *)(sel-getbase(_DS)));
}

void freememhand(INT h)
{
    _ESI=h;
    _ESI=_ESI>>16;
    _EDI=h;                        // SI:DI gets 32-bit handle
    _AX =0x0502;                   // DPMI 0502h: Free Memory Block
    geninterrupt(0x31);
}

void test(CHAR *scr,short *text)
{
    INT j,k;
    short val;
    INT *s=malloc(80*25*2);
    memcpy(s,text,80*25*2);
    _EAX=0;
    _AX=0x12;           // 640*480*16 graphics mode
    geninterrupt(0x10);
    j=0;
    for (val=0;val<=16;val++) {
        WRITEPLANES(val);
        for (k=0;k<2400;k++) {
            scr[k+j]=0xFF;
        }
        j+=2400;
    }
    getch();
    _EAX=0;
    _AX=3;          // 80x25 text mode
    geninterrupt(0x10);
    memcpy(text,s,80*25*2);
    free(text);
}
#pragma argsused
int main (int argc, char *argv[])
{
    CHAR *p;
    CHAR  *graf;
    short *text;
    INT h,i;        // DPMI handle to the address space

    // This maps 128k of conventional memory from A0000 to BFFFF into our
    // processes address space so that it's addressable via DS.

    p=(CHAR *)makeptr(0x000A0000,0x00020000,&h);
    graf=(CHAR  *)p;
    text=(short *)(p+0x00018000);
    for (i=0;i<80*25;i++) text[i]=0x1500;

    printf("%X %X Press any key\n",graf,text);
    getch();

    test(graf,text);

    freememhand(h);         // clean up before leaving
    return(0);
}

