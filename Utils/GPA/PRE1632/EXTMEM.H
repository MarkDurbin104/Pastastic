#ifndef EXTMEM_H
#define EXTMEM_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef EXTMEM_C
#define PUBLIC 
#define INIT(a) =a
#else
#define PUBLIC extern
#define INIT(a)
#endif

// PUBLIC SYMBOLS S

typedef UINT HANDLE;

PUBLIC UINT EXMEMinstalled(void);
PUBLIC UINT EXMEMalloc(LONG size);
PUBLIC UINT EXMEMfree(UINT h);
PUBLIC INT  mem2exmem (void *b,UINT h,ULONG ofs,ULONG len);
PUBLIC INT  exmem2mem (void *b,UINT h,ULONG ofs,ULONG len);

PUBLIC UINT EMSalloc(UINT npg);
PUBLIC UINT EMSfree(UINT h);
PUBLIC UINT EMSmove(CHAR *b,UINT h,ULONG o,ULONG l,UINT ft);
PUBLIC void *EMSbase(void);
PUBLIC INT  EMSpg(UINT h,UINT lp);
PUBLIC INT  moveblk(CHAR *b,UINT h,ULONG o,ULONG l,UINT ofs,UINT ft);

// PUBLIC SYMBOLS E

#ifdef EXTMEM_C


typedef struct {
	HANDLE  h;		// ext/exp mem handle
	UINT  o;	    // free space offest in block
	UINT  f;	    // free space left in block
} BLKTYPE;
typedef struct {
	UCHAR iu;		// in use
	UCHAR h;		// index to blktype struct
	LONG  o;		// offset in block
	LONG  l;		// length of block
} MEMBLK;
typedef struct {
	ULONG l;
	UINT  shnd;
	ULONG sofs;
	UINT  dhnd;
	ULONG dofs;
} XMSMS;

#define MAXMEMBLK 64
#ifdef __TURBOC__
#define I asm
#else
#define I __asm
#endif

BLKTYPE  G_blktype [MAXMEMBLK];
INT      G_numbt   INIT(1);
MEMBLK   G_memblk  [MAXMEMBLK];
INT 	 G_memtype INIT(0);

UINT XMSalloc(UINT nkb);
UINT XMSfree(UINT hand);
UINT XMSmove(XMSMS *ms);
HANDLE EXTalloc(ULONG size);
UINT EXTfree(UINT h);
UINT EXTget(void *b,UINT h,ULONG o,ULONG l);
UINT EXTput(void *b,UINT h,ULONG o,ULONG l);
UINT getfreeh(void);

#endif // def EXTMEM_C

#endif // ndef EXTMEM_H


