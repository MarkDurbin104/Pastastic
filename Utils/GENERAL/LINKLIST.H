//=============================== LINKLIST.H =================================
#ifndef LINKLIST_H
#define LINKLIST_H

#ifndef NULL
#include <stdio.h>
#endif

#ifndef __MALLOC_H
#include <malloc.h>
#endif

#ifdef LINKLIST_C
#define PUBLIC 
#else
#define PUBLIC extern
#endif

//===============================GLOBAL DATA=================================
//#define DOUBLELINK      // remove for single linked list

typedef struct {
    void *next;
#ifdef DOUBLELINK
    void *prev;
#endif
    void *elem;
} LINK;

#ifndef BOOL
typedef int BOOL;
#define TRUE 1
#define FALSE 0
#endif  //BOOL

PUBLIC BOOL         link_setup       (LINK **l,void *e);
PUBLIC BOOL         link_reset       (LINK **l,BOOL freeelems);
PUBLIC BOOL         link_append      (LINK *l,void *e);
PUBLIC BOOL         link_delete      (LINK **l,void *e,BOOL freeelem);
PUBLIC BOOL         link_insert      (LINK *l,void *e);
PUBLIC LINK *       link_getnext     (LINK *l);
#ifdef DOUBLELINK
PUBLIC LINK *       link_getprev     (LINK *l);
#endif
PUBLIC void *       link_getelem     (LINK *l);
PUBLIC BOOL         link_setelem     (LINK *l,void *e,BOOL freeelem);
PUBLIC int          link_count       (LINK *l);

//===============================LOCAL DATA==================================
#ifdef LINKLIST_C

#ifndef MALLOC
#define MALLOC      malloc
#define FREE        free
#define REALLOC     realloc
#define STRDUP      strdup
#define IALLOCED(a) ((a)!=NULL)
#endif  //MALLOC

#endif  //LINKLIST_C

#endif  //LINKLIST_H
//===============================END OF FILE=================================
