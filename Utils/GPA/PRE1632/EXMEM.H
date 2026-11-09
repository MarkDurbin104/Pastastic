#ifndef EXMEM_H
#define EXMEM_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef EXMEM_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

typedef unsigned int  uint;
typedef unsigned long ulong;

PUBLIC int   EXMEMinstalled 	(void);
PUBLIC uint  EXMEMalloc 		(int nkb);
PUBLIC int   EXMEMfree		(int hand);
PUBLIC int   mem2exmem		(void *b,uint h,ulong ofs,ulong len);
PUBLIC int   exmem2mem		(void *b,uint h,ulong ofs,ulong len);

// PUBLIC SYMBOLS E

#ifdef EXMEM_C

#define I asm

typedef struct {
	ulong l;
	uint  shnd;
	ulong sofs;
	uint  dhnd;
	ulong dofs;
} EXMEMMS;

int   EXMEMmove(EXMEMMS *ms);

#endif // def EXMEM_C

#endif // ndef EXMEM_H

