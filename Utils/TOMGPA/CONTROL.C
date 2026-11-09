/****************************************************************************
* Project     : GPA
* File        : control.c
* Description : Memory related functions - basically probably ok
*               but watch the assumed int == char
* 
* $Revision:   1.4  $  $Date:   Nov 01 1995 15:14:56  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/control.c_v  $
* 
*    Rev 1.4   Nov 01 1995 15:14:56   JGRAY
*  
* 
*    Rev 1.3   Oct 20 1995 15:10:50   JGRAY
*  
* 
****************************************************************************/
#define CONTROL_C

#include <io.h>
#include <malloc.h>
#include <alloc.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#ifndef max
#define max(a,b) ((a>b)?a:b)
#endif

#if ((!defined(__DPMI32__)) && defined(__TURBOC__))
#define STRICT
#include <windows.h>    
#include <dos.h>    
#else
#include <dos.h>    
#endif

#include "gpasizes.h"         // size of variables in structures etc.
#include "types.h"            // gpa structures
#include "control.h"          // definitions for this module

#define FALSE 0
#define TRUE 1

extern INT G_debon;

#if (M_DEBUG==1)

#define BASECHECK 0x200

ULONG G_basebuf[BASECHECK];

//************************************************************
//S debug routine preserves a local copy of the base 200 interrupt vectors
//D This non standard routine keeps a copy of the base vectors
//D only compiled if M_DEBUG is set
//D Only active if G_debon is non zero

void setbase(void)
{
    if (G_debon)
       {
       memcpy(G_basebuf,(CHAR *)(0L),sizeof(ULONG)*BASECHECK);
       }
}
//************************************************************
//S debug routine to report changes to the base int vectors
//D output is to a file GPADEBUG.DAT.  Each vector is checked
//D and although some are deliberately ignored any change to the 
//D others is reported.  Finally a fresh vector map is kept.
//D The report indicates the function, the current max depth, 
//D and the changed int vectors
//D only compiled if M_DEBUG is set.  
//D depends upon G_debon being non zero to be active.
//P integer indicating the function this was called in

void prchanges(INT n)
{
   INT i,fst;
   static FILE *fp=NULL;
   LONG *a,*b;
   if (G_debon)
      {
      if (memcmp(G_basebuf,(CHAR *)(0L),4*BASECHECK))
         {
         a=(LONG *)G_basebuf;
         b=(LONG *)(0L);
         fst=1;
         for (i=0;i<BASECHECK;i++)
            {
            if ((*a!=*b)&&(i!=0x110)&&(i!=0x11B)&&(i!=0x1C4)&&(i!=0x1C5)&&(i!=0x1C8)&&(i!=0x10B)&&(i!=0x107))
               {
               if (fp==NULL)
                  fp=fopen("GPADEBUG.DAT","w");
               if (fst)
                  fprintf(fp,"Function (%04d) Depth (%5d) Changed Vectors ",n,G_maxsdepth);
               if (*(a++)!=*(b++))
                  fprintf(fp,"%02X ",i);
               fst=0;
               }
            else
               {
               a++;
               b++;
               }
            }
         if (!fst)
            fprintf(fp,"\n");                      
         fflush(fp);
         memcpy(G_basebuf,(CHAR *)(0L),4*BASECHECK);
         }
     }
}

//************************************************************
//S debug routine to be called on function entry
//D keeps up to LENOFFUNCTIONSTACK records of nested function call.
//D only compiled if M_DEBUG is set
//D only active if G_debon is non zero
//D only prints to stdout detail if G_debon is 2
//P integer parameter indicating function called from

void funcentry(INT f)
{
    if (G_debon) {
       G_nstkf++;
       G_maxsdepth=G_nstkf;
       if (G_debon==2)
          printf("%4d:%04d ",G_nstkf,f);
       if ((G_nstkf>=LENOFFUNCTIONSTACK)||(G_nstkf<1))
          return;
       G_stkf[G_nstkf-1]=f;
    }
}

//************************************************************
//S debug routine to be called on function exit if funcentry was called
//D decrements list and checks for interrupt vector being reset
//D only compiled if M_DEBUG is set
//D only active if G_debon is non zero

void funcexit(void)
{
    if (G_debon) {
       G_nstkf--;
       prchanges(G_stkf[G_nstkf]);
    }
}

#endif 

#ifdef __TURBOC__
//************************************************************
//S low level character output
//D only compiled for turbo c version
//P integer address offset 
//P byte character

void OUTPB(INT16 a,CHAR b)
{
    _EDX=0;
    _EAX=0;
    _DX=a; // (INT16)
    _AL=b; // (CHAR )
    __emit__(0xEE);
}
//************************************************************
//S word version of low level char output - puts lo byte then hi byte
//D only compiled for turbo c version
//P 16 bit address offset
//P 16 bit word value

void OUTPW(INT16 a,INT16 b)
{
    OUTPB(a++,(CHAR)(b&0xFF));
    b>>=8;
    OUTPB(a,(CHAR)(b&0xFF));
}
#endif

//************************************************************
//S Memory allocation/free error routine - not :JGQ
//D prints to stdout supplied string and appends a crlf
//P address of null delim string message text.

void memerr(CHAR *e)
{
    printf("%s\n",e);
}

//************************************************************
//S check the signature of a malloced block 
//D determine whether a block address points exactly just past 
//D a preset signature.  This is a routine that attempts to 
//D determine whether memory overrun has cause corruption of this block
//P void pointer to a memory block.  Assumed to point past the sig.
//R BOOL integer reply: 1 (TRUE) is sig found ok, 0 (FALSE) is sig not found or null pointer.

INT memsig(void *buf)
{
    INT *tmp;
    if (buf==NULL) return(0);
    tmp=buf;
    tmp--;

    if (*tmp==MY_ALLOC) return(1);
    return(0);
}

#ifdef DEBUG
/* In debug mode memory allocations are monitored using a mechanism which
allocates memory blocks and stores information in them.  I can't help feeling
there's something circular about this ...... :-)                     */

static INT alloc_num=0;

typedef struct
{
    void    *next;
    INT     alloc_num;
    void    *address;
    INT     line;
    CHAR    file[10];
    INT     free;
} ALLOCLIST;

static ALLOCLIST *alloclist=NULL;

//************************************************************
//S debug routine to store information about memory allocations
//D Only compiled in debug mode
//P char string source code file name
//P integer code line number
//P integer allocation number
//P void address

void mylist(CHAR *file, INT line, INT alloc_num, void *addr)
{
    ALLOCLIST   *tmp;

    tmp=(ALLOCLIST *)calloc(1,sizeof(ALLOCLIST));
    if (tmp==NULL) {
        return;
    }

    tmp->next=alloclist;
    tmp->alloc_num = alloc_num;
    tmp->address = addr;
    tmp->line = line;
    strncpy (tmp->file, file, 8);
    tmp->free = FALSE;

    alloclist = tmp;
}

//************************************************************
//S debug routine to identify details of a memory block
//D Only compiled in debug mode
//D If the memory block details were recorded and a match is found
//D the details are printed to stdout
//P void address

void addrfind(void *addr)
{
    ALLOCLIST   *allocated;

    allocated = alloclist;
    while (allocated != NULL)
    {
        if (allocated->address == addr)
        {
            printf ("Num %u address %04X:%04X line %u file %s\n",
                        allocated->alloc_num,
                        FP_SEG(allocated->address),
                        FP_OFF(allocated->address),
                        allocated->line,
                        allocated->file);
        }
        allocated = (ALLOCLIST *)allocated->next;
    }
}

//************************************************************
//S debug routine to find and remove table entry for memory block
//D Only compiled in debug mode
//D If the memory block details were recorded and a match is found
//D the entry is removed from the list.
//D otherwise details are printed to stdout of the offending address.
//P integer source code line number
//P char string source code file name
//P void address

void myfreecheck(INT line, CHAR *file, void *addr)
{
    ALLOCLIST   *allocated;
    ALLOCLIST   *previous=NULL;
    INT found = FALSE;

    allocated = alloclist;
    while (allocated != NULL)
    {
        if ((allocated->address == addr) && (allocated->free == FALSE))
        {
            allocated->free = TRUE;
            found = TRUE;
            if (previous!=NULL) {
                previous->next=allocated->next;
                free(allocated);
            } else {
                alloclist=allocated->next;
                free(allocated);
            }
            break;
        }
        previous  = allocated;
        allocated = (ALLOCLIST *)allocated->next;
    }
    if (! found)
    {
        printf ("Free of address %04X:%04X failed. #%u %s\n",
                FP_SEG(addr),FP_OFF(addr), line, file);
        addrfind(addr);
    }
}

//************************************************************
//S routine to print a list of first 200 recorded mem alloc address details
//D output to stdout.
//D only compiled in debug mode.

void endcheck(void)
{
    ALLOCLIST   *allocated;
    INT     number=0;

    allocated = alloclist;
    while ((allocated != NULL) && (number < 200))
    {
        if (allocated->free == FALSE)
        {
            printf ("Num %u address %04X:%04X line %u file %s\n",
                    allocated->alloc_num,FP_SEG(allocated->address),
                    FP_OFF(allocated->address),
                    allocated->line,
                    allocated->file);
            number++;
        }
        allocated = (ALLOCLIST *)allocated->next;
    }
}
#endif

#ifdef DEBUG
//************************************************************
//S routine to release memory, checking whether the block has been corrupted
//D output to stdout if debug mode.
//D compiled in both debug and non debug mode.
//P integer source code line number - debug only
//P char string source code file name - debug only
//P address to be freed - both debug and non debug modes.

void myfree(INT line, CHAR *file, void *buf)
{
#else
void myfree(void *buf)
{
#endif
    UINT *tmp;
    UINT size;

    tmp=buf;
    tmp--;
#ifdef DEBUG
    myfreecheck(line, file, buf);
#endif
   if (*tmp==MY_ALLOC)
      {
      *tmp=0;
      tmp--;
      size=*tmp;
      if (*(((CHAR *)(tmp+2))+size)!=MY_BOUNDCHECK)
         { // check for overflow
#ifdef DEBUG
         printf("Bounds check error on FREE at line %d %s\n",line,file);
#endif
         }
      free(tmp);
      G_numfree++;
      }
   else
      {
      G_numfreeerr++;
//    memerr("FREE - NOT ALLOCATED");
      }
}

#ifdef DEBUG
//************************************************************
//S routine to allocate a block of memory using malloc
//D output, if not commented out, to stdout.
//D compiled in both debug and non debug mode.
//D actually allocates the spec. size + 5 to records size, and 2 signatures
//D if alloc is good both modes put the size and sig into the block,
//D and write a sig byte at the end of it.
//P integer source code line number - debug only
//P char string source code file name - debug only
//P size of block to allocate

void *mymalloc(INT line, CHAR *file, size_t size)
{
#else
void *mymalloc(size_t size)
{
#endif
   UINT *tmp;

#ifdef DEBUG
   alloc_num++;

// if ( (heapcheck()) < 0)
//    {
//    printf("Heap corrupt, mymalloc");
//    }

#endif
   // n.b. size of UINT and size of INT are considered by this code
   // to be synonymous. :JGQ
   tmp=malloc(size+sizeof(INT)*2+sizeof(CHAR));
   if (tmp==NULL)
      {
      G_nummallerr++;
//    memerr("MALLOC RESULT = NULL");
      return(NULL);
      }
   memset(tmp,0,size+sizeof(INT)*2+sizeof(CHAR));
   *(tmp++)=size;
   *(tmp++)=MY_ALLOC;
   *(((CHAR *)tmp)+size)=MY_BOUNDCHECK; // for bounds check
   G_maxblk=max(G_maxblk,((LONG)size));
   G_nummall++;

#ifdef DEBUG
   mylist(file, line, alloc_num,(void *)tmp);
#endif
   return((void *)tmp);
}

//************************************************************
//S routine to reallocate an existing block of memory using free/malloc
//D output, if not commented out, to stdout.
//D compiled in both debug and non debug mode.
//D uses the myalloc routines.
//P integer source code line number - debug only
//P char string source code file name - debug only
//P address of existing block
//P size of block to become allocated

#ifdef DEBUG
void *myrealloc(INT line, CHAR *file, void *buf,size_t size)
{
#else
void *myrealloc(void *buf,size_t size)
{
#endif
   UINT *tmp;                       // pointer for old existing block of mem
   UINT *tmp1;                      // pointer for new reallocated block
   UINT osize;                      // size of old existing block

   tmp=buf;                         // set pointer to existing block
   if (buf==NULL)                   // if that pointer is empty then stop now
      {
      G_numrealerr++;
//    memerr("REALLOC BUFFER = NULL");
      return(NULL);
      }
   else
      {                             // normally resume here because we have a valid block
      tmp--;                        // point to sig
      if (*tmp==MY_ALLOC)           // check whether sig is what we expect
         {                          // proceding on the basis that all is ok
         tmp--;                     // point to size
         osize=*tmp;                // get old existing block size
         if (size<osize)            // and if the size demanded is smaller
            osize=size;             // set the copy size to be smaller value
#ifdef DEBUG
         tmp1=mymalloc(line, file, size);
#else
         tmp1=mymalloc(size);       // normal route is to allocate a new block
#endif
         if (tmp1!=NULL)            // and if that new allocation is good we
            {                       // my alloc will have incremented this counter
            G_nummall--;            // copy the contents of the old block
            memcpy(tmp1,buf,osize); // to the new address, using the smaller
            }                       // of the two's sizes
         else
            {
            return(NULL);           // alloc failed so just dump a null reply
            }
#ifdef DEBUG                        // however only if the alloc succeeded 
         myfree(__LINE__,__FILE__,buf); // and the old block copied over
#else
         myfree(buf);               // do we release the old block
#endif
         G_numfree--;               // my free will have incremented this counter
         }
      else                          // now we see that if the old block sig. had been
         {                          // corrupted we (report the error and)
         G_numrealerr++;            // return a null address
//       memerr("REALLOC - BUFFER NOT ALLOCATED BY ME");
         return(NULL);              // without new allocation or old deallocation.
         }
      }
    G_numreal++;
    return(tmp1);                   // return new allocated address
}
//************************************************************
//S routine to allocate a block of memory and copy a string into it.
//D output, if not commented out, to stdout.
//D compiled in both debug and non debug mode.
//D and write a sig byte at the end of it.
//P integer source code line number - debug only
//P char string source code file name - debug only
//P address of string to duplicate
//R return the address of the new string
#ifdef DEBUG
CHAR *mystrdup(INT line, CHAR *file, const CHAR *s)
{
#else
CHAR *mystrdup(const CHAR *s)
{
#endif
    CHAR *tmp;
#ifdef DEBUG
   if ((tmp=mymalloc(line, file, strlen(s)+1))==NULL)
      {
#else
   if ((tmp=mymalloc(strlen(s)+1))==NULL)
      {
#endif
      G_numstrderr++;
//    memerr("STRDUP RESULT = NULL");
      }
   else
      {
      G_nummall--;         // remove the allocated block from the counter
      strcpy(tmp,s);       // because it is now treated as a string
      }
    G_numstrd++;
    return(tmp);
}

//************************************************************
//S exit from GPA via password at numeric field
//D affects contents of assumed integer array bd and string bm
//D uses a static local counter
//P integer parameter - no idea currently what it is

void bde(INT k)
{
   static INT bdc=0;             // offset into arrays bm & bd
// this code won't pass rigorous typecasting rules because bm and bd are null :JGQ
// delimited char strings but the contents is compared against INT k(+1) :JGQ
   if (bd[bdc]==k+1)
      {
      if ((++bdc)==strlen(bd))
         {
         bd[0]=(-1);
         }
      }
   else
      if (bm[bdc]==k+1)
         {
         if ((++bdc)==strlen(bm))
            {
            bd[0]=(-1);
            bm[0]=(-1);
            }
         }
      else
         {
         bdc=0;
         }
}

// **************************************************************************
// control.c <end-of-file>

