/****************************************************************************
* Project     : GPA
* File        : Control.h
* Description : public function proforma for module control.c which is memory related
* 
* $Revision:   1.4  $  $Date:   Nov 01 1995 16:06:44  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/control.h_v  $
 * 
 *    Rev 1.4   Nov 01 1995 16:06:44   JGRAY
 *  
 * 
 *    Rev 1.3   Oct 20 1995 15:16:40   JGRAY
 * Annotations
* 
****************************************************************************/

#ifndef CONTROL_H
#define CONTROL_H
// PUBLIC SYMBOLS S

#define  MY_ALLOC      0x5AA5
#define  MY_BOUNDCHECK  0x55
// PUBLIC SYMBOLS E

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef CONTROL_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

// PUBLIC SYMBOLS S

#ifdef __TURBOC__
PUBLIC void  OUTPB          (INT16 a,CHAR b);
PUBLIC void  OUTPW          (INT16 a,INT16 b);
#else
#define OUTPB outportb
#define OUTPw outportw
#endif

//#define DEBUG       // define to activate increased memory debugging
                    // Note - if defined manual editing of this file is
                    // is necessary because of "BGPAHEAD GPA.H"

#ifdef DEBUG
//PUBLIC void  myfree         (INT line, CHAR *file, void *buf);
//PUBLIC void  *mymalloc      (INT line, CHAR *file, size_t size);
//PUBLIC void  *myrealloc     (INT line, CHAR *file, void *block,size_t size);
//PUBLIC CHAR  *mystrdup      (INT line, CHAR *file, const CHAR *s);
//PUBLIC void  endcheck       (void);
#else
PUBLIC void  myfree           (void *buf);
PUBLIC void  *mymalloc        (size_t size);
PUBLIC void  *myrealloc       (void *block,size_t size);
PUBLIC CHAR  *mystrdup        (const CHAR *s);
#endif
PUBLIC void  memerr           (CHAR *e);
PUBLIC INT   memsig           (void *buf);
PUBLIC void  bde              (INT k);
PUBLIC void  funcentry        (INT f);
PUBLIC void  funcexit         (void);   

PUBLIC ULONG G_curmem  INIT(0L);    // not set anywhere :JGQ
PUBLIC ULONG G_maxblk  INIT(0L);    // Maximum size of any one block allocated
PUBLIC ULONG G_maxmem  INIT(0L);    // not set anywhere :JGQ
PUBLIC ULONG G_numfree INIT(0L);    // Number of frees
PUBLIC ULONG G_nummall INIT(0L);    // Number of good malloc allocations 
PUBLIC ULONG G_numreal INIT(0L);    // Number of good realloc allocations
PUBLIC ULONG G_numstrd INIT(0L);    // Number of string dup allocations
PUBLIC ULONG G_numfreeerr INIT(0L); // count of sig not found when freeing a block
PUBLIC ULONG G_nummallerr INIT(0L); // count of malloc errors
PUBLIC ULONG G_numrealerr INIT(0L); // count of bat block addr, or corrupt sigs on reallocation
PUBLIC ULONG G_numstrderr INIT(0L); // count of str dup failures (included in G_nummallerr)
// the following strings are for a backdoor exit routine.
// my guess is that when the exact string has been typed in the first byte
// is set to -1 signifying a flag to close. :JGQ
PUBLIC CHAR *bd INIT("ofxnpojd");
PUBLIC CHAR *bm INIT("mfunfjonzobnfjtspdlzevscjo");

// PUBLIC SYMBOLS E
#if (M_DEBUG==1)
PUBLIC INT G_stkf  [LENOFFUNCTIONSTACK];
PUBLIC INT G_nstkf INIT(0);
PUBLIC INT G_maxsdepth INIT(0);
#define ENTRY(a)   funcentry(a)
#define RETURN     { funcexit(); return; }
#define RETURNV(a) { funcexit(); return(a); }
#else
// PUBLIC SYMBOLS S
// PUBLIC UINT G_funclog[1000]; 
//#define ENTRY(a)    G_funclog[a/10]++
#define ENTRY(a)    
#define RETURN      return
#define RETURNV(a)  return(a)
// PUBLIC SYMBOLS E
#endif

// PUBLIC SYMBOLS S

#define FREE    free
#define MALLOC  malloc
#define REALLOC realloc
#define STRDUP  strdup



#ifdef DEBUG
//#define FREE(a)    myfree(__LINE__,__FILE__,a)
//#define MALLOC(a)  mymalloc(__LINE__,__FILE__,a)
//#define REALLOC(a,b)  myrealloc(__LINE__,__FILE__,a,b)
//#define STRDUP(a)  mystrdup(__LINE__,__FILE__,a)
#else
//#define FREE    myfree
//#define MALLOC  mymalloc
//#define REALLOC myrealloc
//#define STRDUP  mystrdup
#endif

#define FARMALLOC farmalloc
#define FARFREE farfree

// PUBLIC SYMBOLS E

#endif  //  ndef CONTROL_H

// **************************************************************************
// control.h <end-of-file>

