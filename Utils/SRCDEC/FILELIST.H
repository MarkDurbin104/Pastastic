//=============================== FILELIST.H =================================
#ifndef FILELIST_H
#define FILELIST_H

#ifdef PUBLIC
#undef PUBLIC 
#endif

#ifdef FILELIST_C
#define PUBLIC 
#else
#define PUBLIC extern
#endif

#ifndef __MALLOC_H
#include <malloc.h>
#endif

#ifndef LINKLIST_H
#include "linklist.h"
#endif

//===============================GLOBAL DATA=================================

PUBLIC int findfile(char *filespec,int fullpath,LINK **files);


//===============================LOCAL DATA==================================
#ifdef FILELIST_C
#define  FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

#ifndef MALLOC
#define MALLOC      malloc
#define FREE        free
#define REALLOC     realloc
#define STRDUP      strdup
#define IALLOCED(a) ((a)!=NULL)
#endif  //MALLOC

#endif  //FILELIST_C

#endif  //FILELIST_H
//===============================END OF FILE=================================
