#define CONTROL_C

#include <io.h>
#include <alloc.h>
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <memory.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "control.h"
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
void logerr(CHAR type,CHAR sys,CHAR func)
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
    tmp[0]=type;
    tmp[1]=sys;
    tmp[2]=func;
    write(fd,tmp,3);
}
// Memory allocation/free error routine
void memerr(CHAR type,CHAR sys,CHAR func)
{
    sound(2000);
    delay(1000);
    nosound();
    logerr(type,sys,func);
}
// replacement for free
void myfree(void *buf)
{
    INT *tmp;
    tmp=buf;
    tmp--;

    if (*tmp==MY_ALLOC) {
        *tmp=0;
        free(tmp);
        G_numfree++;
    }
    else {
        memerr('F','R','E');
    }
}
// check the signature of a malloced block
INT memsig(void *buf)
{
    INT *tmp;
    tmp=buf;
    tmp--;

    if (*tmp==MY_ALLOC) return(1);
    return(0);
}
// malloc a block of memory and place a signature on it
void *mymalloc(size_t size)
{
    INT *tmp;

    tmp=malloc(size+sizeof(INT));
    if (tmp==NULL) {
        memerr('N','U','L');
        return(NULL);
    }
    memset(tmp,0,size+sizeof(INT));
    *tmp=MY_ALLOC;
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
        memerr('R','E','0');
        return(NULL);
    }
    else {
        tmp--;

        if (*tmp==MY_ALLOC) {
            tmp1=mymalloc(size);
            if (tmp1!=NULL) {
                G_nummall--;
                memcpy(tmp1,buf,size);
            }
            else {
                memerr('R','E','1');
                return(NULL);
            }
            myfree(buf);
            G_numfree--;
        }
        else {
            memerr('R','E','2');
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
        memerr('S','T','D');
    }
    else {
        G_nummall--;
        strcpy(tmp,s);
    }
    G_numstrd++;
    return(tmp);
}
// exit from GPA via password at numeric field
void bde(CHAR k)
{
    static INT bdc=0;
    if (bd[bdc]==k+1) {
        if ((++bdc)==strlen(bd)) {
            bd[0]=(-1);
        }
    }
    else {
        bdc=0;
    }
}

