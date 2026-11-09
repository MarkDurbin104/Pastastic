#ifndef XMS_H
#define XMS_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef XMS_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

typedef unsigned int  uint;
typedef unsigned long ulong;

PUBLIC int   XMSinstalled 	(void);
PUBLIC uint  XMSalloc 		(int nkb);
PUBLIC int   XMSfree		(int hand);
PUBLIC int   mem2xms		(void *b,uint h,ulong ofs,ulong len);
PUBLIC int   xms2mem		(void *b,uint h,ulong ofs,ulong len);

// PUBLIC SYMBOLS E

#ifdef XMS_C

#define I asm

typedef struct {
	ulong l;
	uint  shnd;
	ulong sofs;
	uint  dhnd;
	ulong dofs;
} XMSMS;

int   XMSmove(XMSMS *ms);

#endif // def XMS_C

#endif // ndef XMS_H

