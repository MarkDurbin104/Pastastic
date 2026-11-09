#ifndef MEMORY_H
#define MEMORY_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef MEMORY_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC INT  		isblk(CHAR *name);
PUBLIC INT 			setupblk(CHAR *name,ULONG size);
PUBLIC INT  		restblk(CHAR *name,void *ptr);
PUBLIC INT 			restpblk(CHAR *name,void *ptr,ULONG ofs,ULONG len);
PUBLIC INT  		saveblk(CHAR *name,ULONG size,void *ptr);	 
PUBLIC INT 			savepblk(CHAR *name,void *ptr,ULONG ofs,ULONG len);
PUBLIC INT  		finblk(CHAR *name);
PUBLIC void 	    cleanupblks(INT show);
PUBLIC UINT blksize(CHAR *name);

// PUBLIC SYMBOLS E

#ifdef MEMORY_C

typedef struct {
	CHAR name[80];
	ULONG size;
	INT  stat;
	INT  hand;
	INT  err;
} MEMH;
typedef MEMH *PMEMH;

PMEMH *G_memh;
INT   G_numamh=0;
INT   G_nummh=0;

void geteblock(INT idx,void *ptr,ULONG ofs,ULONG len);
void seteblock(INT idx,void *ptr,ULONG ofs,ULONG len);

#endif // def MEMORY_C

#endif // ndef MEMORY_H


