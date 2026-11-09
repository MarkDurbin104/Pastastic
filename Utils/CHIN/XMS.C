#define XMS_C
#include <stdio.h>
#include "xms.h"

#define ENTRY(a)
#define RETURN      return
#define RETURNV(a)  return(a)

int XMSinstalled(void)
{
	ENTRY(320);
I	mov ax,0x4300
I   int 0x2F
	RETURNV((_AL&0x80)!=0);
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
