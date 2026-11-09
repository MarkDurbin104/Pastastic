#define EXMEM_C
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include "control.h"
#include "exmem.h"

int G_memtype=0;

int EXMEMinstalled(void)
{
	long tmp;
	ENTRY(320);
	if (G_memtype) return(1);
I	mov ax,0x4300
I   int 0x2F
	if ((_AL&0x80)!=0) {
		G_memtype=1;
		RETURNV(1);
	} else {
		(void *)tmp=getvect(0x67);
		tmp&=0xFFFF0000L;
		tmp|=0x0000000AL;
		if (!strncmp((char *)tmp,"EMMXXXX0",8)) {
			G_memtype=2;
			RETURNV(1);
		}
	}
	RETURNV(0);
}
unsigned int XMSalloc(int nkb)
{
	unsigned long tmp;
	unsigned int retval;
	ENTRY(330);
I   mov ax,0x4310
I   int 0x2F
I   mov dx,nkb
I   mov ah,0x09
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I	call [tmp]
I   mov retval,dx
    if (_AX) RETURNV(retval);
	fprintf(stdout,"ALLOC ERR %02X\n",_BL); fflush(stdout);
	RETURNV(0);
}
int XMSfree(int hand)
{
	unsigned long tmp;
	ENTRY(340);
I   mov ax,0x4310
I   int 0x2F
I   mov dx,hand
I   mov ah,0x0A
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I	call [tmp]
	RETURNV(_AX);
}
int XMSmove(XMSMS *ms)
{
	unsigned long tmp;
	ENTRY(350);
I   push ds
I   push es
I   mov ax,0x4310
I   int 0x2F
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I   xor bx,bx
I   mov ax,0x0B00
I   lds si,ms
I	call [tmp]
I   pop es
I   pop ds
	if (_AX) RETURNV(1);
    RETURNV((int)_BL);
}
int mem2xms(void *b,unsigned int h,unsigned long ofs,unsigned long len)
{
	XMSMS ms;
	ENTRY(360);
	ms.l=len;
	ms.shnd=0;
	ms.sofs=(unsigned long)b;
	ms.dhnd=h;
	ms.dofs=ofs;
	RETURNV(XMSmove(&ms));
}
int xms2mem(void *b,unsigned int h,unsigned long ofs,unsigned long len)
{
	XMSMS ms;
	ENTRY(370);
	ms.l=len;
	ms.shnd=h;
	ms.sofs=ofs;
	ms.dhnd=0;
	ms.dofs=(unsigned long)b;
	RETURNV(XMSmove(&ms));
}
unsigned int EXMEMalloc(long size)
{
	if (!G_memtype) return(0);
	switch (G_memtype) {
		case 1 :
			return(XMSalloc((unsigned int)((size+1023L)/1024L)));
		case 2 :
			return(EMSalloc((unsigned int)((size+16383L)/16384L)));
	}
	return(0);
}
