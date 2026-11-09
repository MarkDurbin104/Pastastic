#define EXTMEM_C
#include <conio.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include "types.h"
#include "extmem.h"

UINT XMSalloc(UINT nkb)
{
	ULONG tmp;
	UINT  retval;
	UINT  r;
I   mov ax,0x4310
I   INT 0x2F
I   mov dx,nkb
I   mov ah,0x09
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I	call [tmp]
I   mov retval,dx
I   mov r,ax
    if (r) return(retval);
	return(0);
}
UINT XMSfree(UINT hand)
{
	ULONG tmp;
    INT a;
I   mov ax,0x4310
I   INT 0x2F
I   mov dx,hand
I   mov ah,0x0A
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I	call [tmp]
I   mov a,ax
	return(a);
}
UINT XMSmove(XMSMS *ms)
{
	ULONG tmp;
    INT a;
    CHAR b;
I   push ds
I   push es
I   mov ax,0x4310
I   INT 0x2F
I   mov word ptr [tmp  ],bx
I   mov word ptr [tmp+2],es
I   xor bx,bx
I   mov ax,0x0B00
I   lds si,ms
I	call [tmp]
I   pop es
I   pop ds
I   mov a,ax
I   mov b,bl
	if (a) return(1);
    return((INT)b);
}
UINT EMSalloc(UINT npg)
{
	UINT  retval;
    CHAR a;
I   mov ah,0x43
I   mov bx,npg
I   INT 0x67
I   mov retval,dx
I   mov a,ah
	if (a) return(0);
	return(retval);
}
UINT EMSfree(UINT h)
{
I   mov ah,0x45
I   mov dx,h
I   INT 0x67
	return(1);
}
void *EMSbase(void)
{
	UINT segadd;
	static void *base=NULL;
	if (base!=NULL) {
		return(base);
	}
I	mov ah,0x41
I	INT 0x67
I   mov segadd,bx
I   or ah,ah
I   jz cont
	return(NULL);
cont:
	return(base=MK_FP(segadd,0));
}
INT EMSpg(UINT h,UINT lp)
{
	UCHAR retval;
I	mov dx,h				// handle
I	mov bx,lp				// logical page
I	mov ax,0x4400    		// phisical page 0
I	INT 0x67
I	mov retval,ah
	return(retval==0);
}
INT moveblk(CHAR *b,UINT h,ULONG o,ULONG l,UINT ofs,UINT ft)
{
	UCHAR *pg;
	pg=EMSbase();
	pg+=ofs;
	if (EMSpg(h,(INT)(o/16384))) {
		if (ft) {
			memcpy(b,pg,(INT)l);
		} else {
			memcpy(pg,b,(INT)l);
		}
		return(1);
	}
	return(0);
}
UINT EMSmove(CHAR *b,UINT h,ULONG o,ULONG l,UINT ft)
{
	ULONG i,j;
	if (o!=0) {
		i=o%16384L;
		if ((i+l)>16384) j=16384L-i; else j=l;
		if (!moveblk(b,h,o,j,(INT)i,ft)) return(0);
		b+=(INT)j;
		o+=j;
		j=l-j;
	} else {
		j=l;
	}
	i=o;
	while (j>16384) {
		if (!moveblk(b,h,i,16384,0,ft)) return(0);
		b+=16384;
		j-=16384;
		i+=16384;
	}
	if (j) if (!moveblk(b,h,i,j,0,ft)) return(0);
	return(1);
}
UINT EXMEMinstalled(void)
{
    CHAR a;
	if (G_memtype) return(1);
I	mov ax,0x4300
I   INT 0x2F
I	mov a,al
	if ((a&0x80)!=0) {
		G_memtype=1;
		return(1);
	}
I	mov ah,0x40
I   INT 0x67
I	mov a,ah
	if (a==0) {
		G_memtype=2;
		return(1);
	}
	return(0);
}
HANDLE EXTalloc(ULONG size)
{
	HANDLE r=0;
	switch (G_memtype) {
		case 1 :
			r=XMSalloc((UINT)((size+1023L)/1024L));
			break;
		case 2 :
			r=EMSalloc((UINT)((size+16383L)/16384L));
			break;
	}
	return(r);
}
UINT EXTfree(UINT h)
{
	INT i;
	UINT rv=0;
	switch (G_memtype) {
		case 1 :
			rv=XMSfree(G_blktype[h].h);
			break;
		case 2 :
			rv=EMSfree(G_blktype[h].h);
			break;
		default :
			return(0);
	}
	for (i=h;i<G_numbt-1;i++) memcpy(&(G_blktype[i]),&(G_blktype[i+1]),sizeof(G_blktype[i]));
	for (i=0;i<MAXMEMBLK;i++) if (G_memblk[i].h>h) G_memblk[i].h--;
	G_numbt--;
	return(rv);
}
UINT EXTget(void *b,UINT h,ULONG o,ULONG l)
{
	UINT r=0;
	XMSMS ms;
	switch (G_memtype) {
		case 1 :
			ms.l=l;
			ms.shnd=G_blktype[h].h;
			ms.sofs=o;
			ms.dhnd=0;
			ms.dofs=(ULONG)b;
			r=XMSmove(&ms);
			break;
		case 2 :
			r=EMSmove(b,G_blktype[h].h,o,l,1);
			break;
	}
	return(r);
}
UINT EXTput(void *b,UINT h,ULONG o,ULONG l)
{
	UINT r=0;
	XMSMS ms;
	switch (G_memtype) {
		case 1 :
			ms.l=l;
			ms.shnd=0;
			ms.sofs=(ULONG)b;
			ms.dhnd=G_blktype[h].h;
			ms.dofs=o;
			r=XMSmove(&ms);
			break;
		case 2 :
			r=EMSmove(b,G_blktype[h].h,o,l,0);
			break;
	}
	return(r);
}
UINT getfreeh(void)
{
	INT i;
	static INT start=1;
	if (start) {
		start=0;
		memset(G_memblk,0,sizeof(G_memblk));
		memset(G_blktype,0,sizeof(G_blktype));
	}
	for (i=0;i<MAXMEMBLK;i++) {
		if (!(G_memblk[i].iu)) return(i+1);
	}
	return(0);
}
UINT EXMEMalloc(LONG size)
{
	UINT h;
	INT i;
	UINT s;
	if (!EXMEMinstalled) return(0);
	if ((h=getfreeh())==0) return(0);
	if (size<16384L) {
		s=(UINT)size;
		for (i=1;i<G_numbt;i++) {
			if (G_blktype[i].f>=s) {
				G_memblk[h-1].o=G_blktype[i].o;
				G_memblk[h-1].h=i;
				G_memblk[h-1].iu=1;
				G_memblk[h-1].l=s;
				G_blktype[i].o+=s;
				G_blktype[i].f-=s;
				return(h);
			}
		}
		if (G_numbt<MAXMEMBLK) {
			if ((G_blktype[G_numbt].h=EXTalloc(16384L))==0) return(0);
			G_memblk[h-1].o=0;
			G_memblk[h-1].h=G_numbt;
			G_memblk[h-1].iu=1;
			G_memblk[h-1].l=s;
			G_blktype[G_numbt].o=s;
			G_blktype[G_numbt].f=16384U-s;
			G_numbt++;
			return(h);
		}
	} else {
		if (G_numbt<MAXMEMBLK) {
			if ((G_blktype[G_numbt].h=EXTalloc(size))==0) return(0);
			G_blktype[G_numbt].f=0;
			G_blktype[G_numbt].o=0;
			G_memblk[h-1].o=0;
			G_memblk[h-1].h=G_numbt;
			G_memblk[h-1].iu=1;
			G_memblk[h-1].l=size;
			G_numbt++;
			return(h);
		}
	}
	return(0);
}
UINT EXMEMfree(UINT h)
{
	UINT oh,i;
	if (!h) return(0);
	oh=G_memblk[h-1].h;
	G_memblk[h-1].o=0;
	G_memblk[h-1].iu=0;
	G_memblk[h-1].l=0;
	G_memblk[h-1].h=0;
	for (i=0;i<MAXMEMBLK;i++) if ((G_memblk[i].h==oh)) break;
	if (i==MAXMEMBLK) {
		return(EXTfree(oh));
	}
	return(0);
}
INT mem2exmem (void *b,UINT h,ULONG ofs,ULONG len)
{
	if (!h) return(0);
	return(EXTput(b,G_memblk[h-1].h,G_memblk[h-1].o+ofs,len));
}
INT exmem2mem (void *b,UINT h,ULONG ofs,ULONG len)
{
	if (!h) return(0);
	return(EXTget(b,G_memblk[h-1].h,G_memblk[h-1].o+ofs,len));
}
