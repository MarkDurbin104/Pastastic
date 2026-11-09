//===========================================================================
// Module        : DEBALLOC.C
// Synopsys      : debug rountines for memory allocation
// Description   : replacement rountines for memory allocation
//               : include and define a level of debug to check
//               : missing frees bad frees allocs re-allocs and strdups
//               : and bounds on blocks
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th June 1993
//===========================================================================
// Functions     : debfree debmalloc debrealloc debstrdup
//               : endcheck boundscheck
//               : 
//===========================================================================
// Global Vars.  : G_freeerr, G_mallerr, G_realerr, G_strderr, G_bndserr
//               : G_debvalue, G_debexit, G_checkfreq 
//               : 
// static        : alloclist
//===========================================================================
// Date      Id   Modification history
//---------------------------------------------------------------------------
// 06/06/93  MJD  Initial entry
// 08/09/93  MJD  added bounds checking
// 10/09/93  MJD  added exit pragma to list errors
// 15/10/93  MJD  G_freqcheck to check for bounds errors during running
//===========================================================================
#define DEBALLOC_C

#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <dos.h>  

#include "types.h"
#include "deballoc.h"

#ifdef DEBUG

void boundscheck(int force)
{
    static unsigned int do_clock=0;
    ALLOCHDR   *blk;
    int founderr=0;
    if ((!force)&&(!G_checkfreq)) return;
    if ((force)||((do_clock%G_checkfreq)==0)) {
        blk=alloclist;
        while (blk!=NULL) {
            if (*(((char *)blk->addr)+blk->size)!=DEB_ENDSIG) { // check bounds
                G_bndserr++;
                if (G_debvalue>=2) {
                    fprintf(stderr,"Block bounds error - Alloc in %s #%u\n",blk->file,blk->line);
                }
                founderr=1;
            }
            blk=(ALLOCHDR *)blk->next;
        }
    }
    if ((founderr)&&(G_debvalue>=2)) {
        G_debexit=1;
        exit(1);
    }
    do_clock++;
}

int debptrcheck(int line,char *file,void *addr)
{
    ALLOCHDR   *blk=addr;
    boundscheck(0);
    blk--;
    if (blk->signature!=DEB_ALLOC) {
        if (G_debvalue>=2) {
            fprintf(stderr,"pointer check (NO SIGNATURE) failure in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return 0;
    }
    if (*(((char *)addr)+blk->size)!=DEB_ENDSIG) {
        if (G_debvalue>=2) {
            fprintf(stderr,"pointer check (BOUNDS) failure in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return 0;
    }
    if (blk->addr!=addr) {
        if (G_debvalue>=2) {
            fprintf(stderr,"pointer check (ADDRESS) failure in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return 0;
    }
    return 1;
}
void debfree(int line,char *file,void *addr)
{
    ALLOCHDR   *blk=addr;

    boundscheck(0);

    blk--;

    if (blk->signature!=DEB_ALLOC) { // check signature
        G_freeerr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"Free (NOT ALLOCED) failure in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return;
    }
    if (*(((char *)addr)+blk->size)!=DEB_ENDSIG) { // check bounds
        G_bndserr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"Block bounds error - Free in %s #%u - Alloc in %s #%u\n",file,line,blk->file,blk->line);
            G_debexit=1;
            exit(1);
        }
    }

    if (blk->addr!=addr) {
        G_freeerr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"Free (DIFFERENT ADDRESSES) failure in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return;
    }
    if (blk->prev==NULL) {
        if (blk->next==NULL) {
            alloclist=NULL;
        } else {
            alloclist=blk->next;
            alloclist->prev=NULL;
        }
    } else {
        if (blk->next==NULL) {
            ((ALLOCHDR *)(blk->prev))->next=NULL;
        } else {
            ((ALLOCHDR *)(blk->prev))->next=blk->next;
            ((ALLOCHDR *)(blk->next))->prev=blk->prev;
        }
    }
    free(blk);
}
// malloc a block of memory and place a signature on it
void *debmalloc(int line,char *file,size_t size)
{
    ALLOCHDR *blk;

    boundscheck(0);

    blk=calloc(1,size+sizeof(ALLOCHDR)+1);
    if (blk==NULL) {
        G_mallerr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"MALLOC failed in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return(blk);
    }
    blk->signature=DEB_ALLOC;
    blk->next=alloclist;
    blk->prev=NULL;
    if (alloclist!=NULL) alloclist->prev=blk;
    alloclist=blk;
    blk->size=size;
    blk->line=line;
    strncpy (blk->file,file,14);
    blk->addr=blk+1;
    blk++;
    *(((char *)blk)+size)=DEB_ENDSIG; // for bounds check
    return((void *)blk);
}
// realloc a block of memory and place a signature on it
void *debrealloc(int line,char *file,void *buf,size_t size)
{
    ALLOCHDR *blk=buf;
    unsigned int *tmp1;
    unsigned int osize;

    if (buf==NULL) {
        G_realerr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"REALLOC ptr==NULL failed in %s #%d\n",file,line);
            G_debexit=1;
            exit(1);
        }
        return(NULL);
    }
    else {
        blk--;
        if (blk->signature==DEB_ALLOC) { // check signature
            osize=blk->size;
            if (size<osize) osize=size;
            tmp1=debmalloc(line,file,size);
            if (tmp1!=NULL) {
                memcpy(tmp1,buf,osize);
            } else {
                G_realerr++;
                if (G_debvalue>=2) {
                    fprintf(stderr,"REALLOC failed in %s #%u\n",file,line);
                    G_debexit=1;
                    exit(1);
                }
                return(NULL);
            }
            debfree(__LINE__,__FILE__,buf);
        }
        else {
            G_realerr++;
            if (G_debvalue>=2) {
                fprintf(stderr,"REALLOC NOT ALLOC'ED failed in %s #%u\n",file,line);
                G_debexit=1;
                exit(1);
            }
            return(NULL);
        }
    }
    return(tmp1);
}
// malloc a block of memory and place a string in it
char *debstrdup(int line,char *file,const char *s)
{
    char *tmp;
    if ((tmp=debmalloc(line,file,strlen(s)+1))==NULL) {
        G_strderr++;
        if (G_debvalue>=2) {
            fprintf(stderr,"STRDUP failed in %s #%u\n",file,line);
            G_debexit=1;
            exit(1);
        }
    } else {
        strcpy(tmp,s);
    }
    return(tmp);
}

void endcheck(void)
{
   ALLOCHDR   *blk;
   int         number=0;

   if (!G_debexit) boundscheck(1);

   blk=alloclist;
   while (blk!=NULL) {
      if ((number<REPORTNUM)&&(!G_debexit)&&(G_debvalue>2)) {
         fprintf(stderr,"Block not freed in %s #%u\n",blk->file,blk->line);
      }
      blk=(ALLOCHDR *)blk->next;
      if ((blk!=NULL)&&(blk->prev!=NULL)) free(blk->prev);
      number++;
   }
   if ((number>=REPORTNUM)&&(!G_debexit))
        fprintf(stderr,"%d Blocks not freed\n",number);
   alloclist=NULL;

   if (!G_debexit) {
      if (G_freeerr) fprintf(stderr,"%ld free error(s)\n"   ,G_freeerr); 
      if (G_mallerr) fprintf(stderr,"%ld malloc error(s)\n" ,G_mallerr); 
      if (G_realerr) fprintf(stderr,"%ld realloc error(s)\n",G_realerr); 
      if (G_strderr) fprintf(stderr,"%ld strdup error(s)\n" ,G_strderr); 
      if (G_bndserr) fprintf(stderr,"%ld bounds error(s)\n" ,G_bndserr); 
   }
   G_debexit=1;
}

#endif // def DEBUG

