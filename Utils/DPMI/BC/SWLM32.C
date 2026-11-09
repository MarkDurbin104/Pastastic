
#pragma inline

/*
	This program is NOT copyrighted. Version 1.0 of 7/8/94.
	By Bob Salita of Softworks Limited, Chicago, IL.

	This program is an improved version of the lowmem32.c program
	distributed by Borland. See \bc4\examples\dpmi\lowmem directory
	for missing details.
	
	Improvements are:
	1) faster, more compact code for 8,16, and 32-bit accesses.
	2) doesn't care whether addresses are low memory or high memory.
	   It will properly read/write to either.
	3) selector/offset arguments used in lowmem32.c are eliminated.

	examples of use:

		{
		UINT16 u16, *p = 0xb8000; /- screen memory address -/
		UINT8 m;

		u16 = getLowMemUINT16(p); /- get screen memory word -/
		setLowMemUINT16(++p,u16); /- put into next screen mem word -/
		setLowMemUINT16(&u16,0x0f20); /- you can also use high mem -/

		m = getLowMemUINT8(0x449);/- get video mode from low memory -/
		}

	I am not an 86 assembler programmer so use at your own risk!
	Feel free to rehack and post improvements.
*/

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef unsigned long UINT32;
typedef unsigned BYTES;

#if !defined(__BC__) || !defined(__DPMI32__)
/* if not Borland C or not DOS 32, just use C macros to get/set */
#define getLowMemUINT8(src) (*(UINT8 *)(src))
#define getLowMemUINT16(src) (*(UINT16 *)(src))
#define getLowMemUINT32(src) (*(UINT32 *)(src))
#define setLowMemUINT8(dst,src) (*(UINT8 *)(dst) = (UINT8)(src))
#define setLowMemUINT16(dst,src) (*(UINT16 *)(dst) = (UINT16)(src))
#define setLowMemUINT32(dst,src) (*(UINT32 *)(dst) = (UINT32)(src))
#else
/* we are using Borland C using DOS 32, declare func headers */
UINT8 getLowMemUINT8 (UINT8 *src);
UINT8 setLowMemUINT8 (UINT8 *dst, UINT8 src);
UINT16 getLowMemUINT16 (UINT16 *src);
UINT16 setLowMemUINT16 (UINT16 *dst, UINT16 src);
UINT32 getLowMemUINT32 (UINT32 *src);
UINT32 setLowMemUINT32 (UINT32 *dst, UINT32 src);

static UINT16 lowMemSel;        /* 1M selector mapping conventional memory */

UINT8 getLowMemUINT8 (UINT8 *src)
	{
	if ((BYTES)src >= 0x100000)
		return(*src);
	asm     {
		mov  esi, src
		push ds
		mov  ds, lowMemSel
		mov  al, ds:[esi]
		pop  ds
		}
	}

UINT8 setLowMemUINT8 (UINT8 *dst, UINT8 src)
	{
	if ((BYTES)dst >= 0x100000)
		return(*dst = src);
	asm     {
		mov  edi, dst
		mov  al, src
		push es
		mov  es, lowMemSel
		mov  es:[edi], al
		pop  es
		}
	}

UINT16 getLowMemUINT16 (UINT16 *src)
	{
	if ((BYTES)src >= 0x100000)
		return(*src);
	asm     {
		mov  esi, src
		push ds
		mov  ds, lowMemSel
		mov  ax, ds:[esi]
		pop  ds
		}
	}

UINT16 setLowMemUINT16 (UINT16 *dst, UINT16 src)
	{
	if ((BYTES)dst >= 0x100000)
		return(*dst = src);
	asm     {
		mov  edi, dst
		mov  ax, src
		push es
		mov  es, lowMemSel
		mov  es:[edi], ax
		pop  es
		}
	}

UINT32 getLowMemUINT32 (UINT32 *src)
	{
	if ((BYTES)src >= 0x100000)
		return(*src);
	asm     {
		mov  esi, src
		push ds
		mov  ds, lowMemSel
		mov  eax, ds:[esi]
		pop  ds
		}
	}

UINT32 setLowMemUINT32 (UINT32 *dst, UINT32 src)
	{
	if ((BYTES)dst >= 0x100000)
		return(*dst = src);
	asm     {
		mov  edi, dst
		mov  eax, src
		push es
		mov  es, lowMemSel
		mov  es:[edi], eax
		pop  es
		}
	}

/*
	These functions are from Borland's lowmem32.c example
	Function getSel()
	Function freeSel()

	The startup and cleanup functions will get a selector from DPMI to be
	used for low memory access requests. The selector is set up to map the
	whole first megabyte.  The freeSel function     will free the selector at
	termination time.
*/


static void getSel(void)
	{
	asm
		{
		mov  cx, 1
		mov  ax, 0000h          ;; DPMI Allocate Selector
		int  31h
		mov  lowMemSel, ax

		mov  bx, ax             
		lar  cx, bx
		shr  ecx, 8
		or   cx, 4000h          ;; make it 'big'
		mov  ax, 0009h          ;; DPMI Set Descriptor Access Rights
		int  31h

		mov  bx, lowMemSel
		mov  dx, 0FFFFh
		mov  cx, 0000Fh         ;; map 1M
		mov  ax, 0008h          ;; DPMI Set Segment Limit
		int  31h

	xor  dx, dx
	xor  cx, cx
		mov  bx, lowMemSel
		mov  ax, 0007h          ;; DPMI Set Segment Base Address
		int  31h
		}
	}


static void freeSel(void)
	{
	asm
		{
		mov     bx, lowMemSel
		mov     ax, 0001h               ;; DPMI Free Selector
		int     31h
		}
	}

#pragma startup getSel
#pragma exit freeSel
#endif

