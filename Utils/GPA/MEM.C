#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <search.h>

#ifdef CTOS
#define AllocMemorySL     @
#define DeallocMemorySL   @
#define GetSegmentLength  @

#include <ctos.lib.h>
#endif

extern void errorline (char *e,int type);


static unsigned long int TotalAllocs=0, CurrentAllocs=0, MaxAllocs=0;
static unsigned long CurrentMemAllocated=0L, MaxMemAllocated=0L;

#ifdef MEM_DEBUG
#define MAX_POINTERS 0x4000
typedef void *voidptr;
static voidptr _huge ValidPointers[MAX_POINTERS];
static int MemWatch=1;
#endif

void *malloc (size_t s)
{
void *m;
unsigned int erc, u;

#ifdef CTOS

erc=AllocMemorySL (s, &m);
if (erc) {
//    printf ("Could not satisfy malloc request for %n bytes\n", s);
    return NULL;
    }
else {
    erc = GetSegmentLength (m, &u);
    if (!erc)
	MaxMemAllocated=(CurrentMemAllocated+=u)>MaxMemAllocated?CurrentMemAllocated:MaxMemAllocated;
    }

#else

if((m=_fmalloc(s))==NULL) {
//    printf ("Could not satisfy malloc request for %n bytes\n", s);
    return NULL;
    }

#endif

TotalAllocs++; MaxAllocs=++CurrentAllocs>MaxAllocs?CurrentAllocs:MaxAllocs;

#ifdef MEM_DEBUG
if (MemWatch)
    if (CurrentAllocs>MAX_POINTERS)
	MemWatch=0;
    else
	ValidPointers[(unsigned int)(MAX_POINTERS-CurrentAllocs)]=m;
#endif

return (m);

}


void free (void *m)

{
unsigned int erc, u;
#ifdef MEM_DEBUG
voidptr _huge *ptr;
#endif

#ifdef MEM_DEBUG
if (m == NULL) {
    printf("Trying to free invalid pointer %p\n",m);
    return;
    }
if (MemWatch) {
    for (ptr=ValidPointers+(unsigned int)(MAX_POINTERS-CurrentAllocs);
	 ptr<ValidPointers+MAX_POINTERS && *ptr!=m;
	 ptr++)
	;
    if (ptr==ValidPointers+MAX_POINTERS) {
   errorline("Trying to free invalid pointer",1);
//	printf("Trying to free invalid pointer %p\n",m);
	return;
	}
    else
	*ptr=ValidPointers[(unsigned int)(MAX_POINTERS-CurrentAllocs)];
    }
#endif

#ifdef CTOS

erc = GetSegmentLength (m, &u);
if (erc)
    DeallocMemorySL (m, 0xffff);
else {
    DeallocMemorySL (m, u);
    CurrentMemAllocated-=u;
    }

#else

_ffree (m);

#endif

CurrentAllocs--;

}


void *realloc (void *m, size_t s)
{
unsigned int erc, u;
void *n;
voidptr _huge *ptr;

#ifdef MEM_DEBUG
if (MemWatch) {
    for (ptr=ValidPointers+(unsigned int)(MAX_POINTERS-CurrentAllocs);
	 ptr<ValidPointers+MAX_POINTERS && *ptr!=m;
	 ptr++)
	;
    if (ptr==ValidPointers+MAX_POINTERS) {
    printf("Trying to realloc invalid pointer %p\n",m);
    ptr=NULL;
    }
}
#endif

#ifdef CTOS

if (m==NULL)
    return (malloc (s));
free (m);
n = malloc (s);
if (n==m)
    return m;
if (n!=NULL && s!=0)
    memcpy (n, m, s);
return (n);

#else

if ((n=_frealloc(m,s))==NULL && ptr != NULL) {
    *ptr=ValidPointers[(unsigned int)(MAX_POINTERS-CurrentAllocs)];
    CurrentAllocs--;
    }

return n;

#endif
}
 
