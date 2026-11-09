#define EXTRDPMI_C
#include <dos.h>
#include <memory.h>
#include <stdio.h>
#include <conio.h>
#include <malloc.h>
#include "types.h"
#include "extrdpmi.h"

INT getlowmem(INT addr,INT np,INT *h)
{
    static INT ofs;
    static INT len;
    len=np*PAGESIZE;

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

INT getlimit(UINT16 sel)
{
    _EBX=0;
    _BX=sel;
    LSL_EAX_EBX;
    return(_EAX);
}

void setlimit(UINT16 sel,INT off)
{
    static UINT16 h,l;
    h=(UINT16)(off>>16);
    l=(UINT16)(off&0xFFFF);
    _AX=8;                      // DPMI 0008h: Set Selector Limit
    _BX=sel;
    _CX=h;
    _DX=l;
    geninterrupt(0x31);
}

INT getbase(UINT16 s)
{
    UINT16 upr,lwr;

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
    if (!sel) return(NULL);
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
void *MK_FP(UINT16 seg,UINT16 ofs,INT len)
{
    void *p;
    UINT addr=0;
    addr|=(((UINT)seg<<4)|(UINT)ofs);
    addr&=0x000FFFFF;
    if (G_nummh>=MAXMEMHAND) return(NULL);
    p=makeptr(addr,len,&G_memh[G_nummh]);
    if (p==NULL) return(NULL);
    G_nummh++;
    return(p);
}
void freeblks(void)
{
    int i;
    for (i=0;i<G_nummh;i++) freememhand(G_memh[i]);
}
