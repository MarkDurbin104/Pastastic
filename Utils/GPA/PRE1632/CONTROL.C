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

/*   These dummy routines are for sysdoc
// macro for myfree
void FREE(void *buf)
{
    myfree(buf);
}
// macro for mymalloc
void  *MALLOC(size_t size)
{
    mymalloc(size);
}
// macro for myrealloc
void  *REALLOC(void *buf,size_t size)
{
    myrealloc(buf,size);
}
// macro for mystrdup
CHAR  *STRDUP(const CHAR *s)
{
    mystrdup(s);
}
*/
// log an error to the disk
void logerr(CHAR *e,INT l)
{
    CHAR tmp[15];
    INT i=0;
    static INT fd=(-1);

    if (fd==(-1)) {
        do {
            sprintf(tmp,"DEBUG%03d.DAT",i);
            if ((fd=open(tmp,O_RDONLY))!=(-1)) {
                close(fd);
                fd=(-1);
            }
            else {
                fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
            }
            i++;
        } while (fd==(-1));
    }
    write(fd,e,l);
    close(fd);
    fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
}
// Memory allocation/free error routine
void memerr(CHAR *e,INT l)
{
#ifdef __TURBOC__
    sound(2000);
    delay(100);
    nosound();
#endif
    logerr(e,l);
}
// replacement for free
void myfree(void *buf)
{
    UINT *tmp;
#if (M_DEBUG==1)
	UINT l;
#endif
    tmp=buf;
#if (M_DEBUG==1)
    tmp--;
	l=*tmp;
#endif
    tmp--;
	
    if (*tmp==MY_ALLOC) {
#if (M_DEBUG==1)
		G_curmem-=l;
#endif
        *tmp=0;
        free(tmp);
        G_numfree++;
    }
    else {
        memerr("MYFREE",6);
    }
}
// check the signature of a malloced block
INT memsig(void *buf)
{
    INT *tmp;
    tmp=buf;
#if (M_DEBUG==1)
    tmp--;
#endif
    tmp--;

    if (*tmp==MY_ALLOC) return(1);
    return(0);
}
// malloc a block of memory and place a signature on it
void *mymalloc(size_t size)
{
    UINT *tmp;

#if (M_DEBUG==1)
    tmp=malloc(size+sizeof(INT)*2);
#else
    tmp=malloc(size+sizeof(INT));
#endif
    if (tmp==NULL) {
        memerr("MYMALLOC = NULL",15);
        return(NULL);
    }
#if (M_DEBUG==1)
    memset(tmp,0,size+sizeof(INT)*2);
    *tmp=MY_ALLOC;
    tmp++;
    *tmp=size;
	G_curmem+=(LONG)size;
	G_maxmem=max(G_maxmem,G_curmem);
#else
    memset(tmp,0,size+sizeof(INT));
    *tmp=MY_ALLOC;
#endif
	G_maxblk=max(G_maxblk,((LONG)size));
    tmp++;
    G_nummall++;
    return((void *)tmp);
}
// realloc a block of memory and place a signature on it
void *myrealloc(void *buf,size_t size)
{
    INT *tmp;
    INT *tmp1;
    tmp=buf;

    if (tmp==NULL) {
        memerr("MYREALLOC = NULL",16);
        return(NULL);
    }
    else {
#if (M_DEBUG==1)
        tmp--;
#endif
        tmp--;

        if (*tmp==MY_ALLOC) {
            tmp1=mymalloc(size);
            if (tmp1!=NULL) {
                G_nummall--;
                memcpy(tmp1,buf,size);
            }
            else {
		        memerr("MYREALLOC2= NULL",16);
                return(NULL);
            }
            myfree(buf);
            G_numfree--;
        }
        else {
	        memerr("MYREALLO3 = NULL",16);
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
        memerr("MYSTRDUP = NULL",15);
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
#ifdef __TURBOC__
			sound(1000);
			delay(50);
			sound(5000);
			delay(50);
			sound(2000);
			delay(200);
			nosound();
#endif
        }
    } else {
        bdc=0;
    }
}
