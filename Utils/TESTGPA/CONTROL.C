#define CONTROL_C

#include <io.h>
#include <malloc.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <memory.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#ifndef max
#define max(a,b) ((a>b)?a:b)
#endif

#if !defined(__DPMI32__) && defined(__TURBOC__)
#define STRICT
#include <windows.h>    
#include <dos.h>    
#endif

#include "types.h"
#include "control.h"

extern INT G_debon;

#if (M_DEBUG==1)

#define BASECHECK 0x200

ULONG G_basebuf[BASECHECK];

void setbase(void)
{
    if (G_debon) {
    	memcpy(G_basebuf,(CHAR *)(0L),4*BASECHECK);
    }
}
void prchanges(INT n)
{
	INT i,fst;
    static FILE *fp=NULL;
	LONG *a,*b;
    if (G_debon) {
	    if (memcmp(G_basebuf,(CHAR *)(0L),4*BASECHECK)) {
		    a=(LONG *)G_basebuf;
		    b=(LONG *)(0L);
            fst=1;
		    for (i=0;i<BASECHECK;i++) {
                if ((*a!=*b)&&(i!=0x110)&&(i!=0x11B)&&(i!=0x1C4)&&(i!=0x1C5)&&(i!=0x1C8)&&(i!=0x10B)&&(i!=0x107)) {
                    if (fp==NULL) fp=fopen("GPADEBUG.DAT","w");
        	        if (fst) fprintf(fp,"Function (%04d) Depth (%5d) Changed Vectors ",n,G_maxsdepth);
		 	        if (*(a++)!=*(b++)) fprintf(fp,"%02X ",i);
                    fst=0;
                } else {
                    a++; b++;
                }
		    }
     	    if (!fst) fprintf(fp,"\n");                      
    	    fflush(fp);
		    memcpy(G_basebuf,(CHAR *)(0L),4*BASECHECK);
	    }
	}
}
void funcentry(INT f)
{
    if (G_debon) {
        G_nstkf++;
        G_maxsdepth=G_nstkf;
        if (G_debon==2) printf("%4d:%04d ",G_nstkf,f);
	    if ((G_nstkf>=1000)||(G_nstkf<1)) return;
	    G_stkf[G_nstkf-1]=f;
    }
}
void funcexit(void)
{
    if (G_debon) {
    	G_nstkf--;
        prchanges(G_stkf[G_nstkf]);
    }
}

#endif 
#ifdef __TURBOC__
void OUTPB(INT16 a,CHAR b)
{
    _EDX=0;
    _EAX=0;
    _DX=a; // (INT16)
    _AL=b; // (CHAR )
    __emit__(0xEE);
}
void OUTPW(INT16 a,INT16 b)
{
    OUTPB(a++,(CHAR)(b&0xFF));
    b>>=8;
    OUTPB(a,(CHAR)(b&0xFF));
}
#endif

// Memory allocation/free error routine
void memerr(CHAR *e)
{
    printf("%s\n",e);
}
// check the signature of a malloced block
INT memsig(void *buf)
{
    INT *tmp;
    if (buf==NULL) return(0);
    tmp=buf;
    tmp--;

    if (*tmp==MY_ALLOC) return(1);
    return(0);
}

void myfree(void *buf)
{
    UINT *tmp;
    tmp=buf;
    tmp--;
	
    if (*tmp==MY_ALLOC) {
        *tmp=0;
        tmp--;
        free(tmp);
        G_numfree++;
    }
    else {
        G_numfreeerr++;
//        memerr("FREE - NOT ALLOCATED");
    }
}
// malloc a block of memory and place a signature on it
void *mymalloc(size_t size)
{
    UINT *tmp;
    
    tmp=malloc(size+sizeof(INT)*2);
    if (tmp==NULL) {
        G_nummallerr++;
//        memerr("MALLOC RESULT = NULL");
        return(NULL);
    }
    memset(tmp,0,size+sizeof(INT));
    *(tmp++)=size;
    *(tmp++)=MY_ALLOC;
	G_maxblk=max(G_maxblk,((LONG)size));
    G_nummall++;
    return((void *)tmp);
}
// realloc a block of memory and place a signature on it
void *myrealloc(void *buf,size_t size)
{
    UINT *tmp;
    UINT *tmp1;
    UINT osize;
    tmp=buf;

    if (buf==NULL) {
        G_numrealerr++;
//        memerr("REALLOC BUFFER = NULL");
        return(NULL);
    }
    else {
        tmp--;
        if (*tmp==MY_ALLOC) {
            tmp--;
            osize=*tmp;
            if (size<osize) osize=size;
            tmp1=mymalloc(size);
            if (tmp1!=NULL) {
                G_nummall--;
                memcpy(tmp1,buf,osize);
            } else {
                return(NULL);
            }
            myfree(buf);
            G_numfree--;
        }
        else {
            G_numrealerr++;
//            memerr("REALLOC - BUFFER NOT ALLOCATED BY ME");
            return(NULL);
        }
    }
    G_numreal++;
    return(tmp1);
}
// malloc a block of memory and place a string in it
CHAR *mystrdup(const CHAR *s)
{
    CHAR *tmp;
    if ((tmp=mymalloc(strlen(s)+1))==NULL) {
        G_numstrderr++;
//        memerr("STRDUP RESULT = NULL");
    }
    else {
        G_nummall--;
        strcpy(tmp,s);
    }
    G_numstrd++;
    return(tmp);
}

// exit from GPA via password at numeric field
void bde(INT k)
{
    static INT bdc=0;
    if (bd[bdc]==k+1) {
        if ((++bdc)==strlen(bd)) {
            bd[0]=(-1);
        }
    } else if (bm[bdc]==k+1) {
        if ((++bdc)==strlen(bm)) {
            bd[0]=(-1);
            bm[0]=(-1);
        }
    } else {
        bdc=0;
    }
}

