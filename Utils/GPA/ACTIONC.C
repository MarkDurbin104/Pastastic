//SYSDOC ACTIONC.CMT
#define ACTIONC_C

#include <malloc.h>
#include <string.h>
#include <stdio.h>
#include <search.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "control.h"
#include "config.h"
#include "actionc.h"
#include "instruct.h"

#ifndef max
#define max(a,b) (a>b?a:b)
#endif

// Return action offset
LONG actionofs(INT idx)
{
    return(G_nbuf[idx].o);
}
// Return action type
UCHAR actiontype(INT idx)
{
    return(G_nbuf[idx].t);
}
// Return action debug
UCHAR actiondeb(INT idx)
{
    return(G_nbuf[idx].d);
}
// Return action name
CHAR *actionname(INT idx)
{
    return(G_nbuf[idx].n);
}
// Return action buffer pointer (token string or variable)
UCHAR *actionbuf(INT idx)
{
    return(G_nbuf[idx].b);
}
// Set action buffer pointer
void setactionbuf(INT idx,UCHAR *s)
{
    G_nbuf[idx].b=s;
}
// free the token list from memory
void freeactions(void)
{
	INT i;
	ENTRY(1900);
    for (i=0;i<G_numn;i++) {
		if (actionbuf(i)!=NULL) FREE(actionbuf(i));
	}
    if (G_nbuf!=NULL) FREE(G_nbuf);
    G_nbuf=NULL;
    if (G_anamebuf!=NULL) FREE(G_anamebuf);
    G_anamebuf=NULL;
	RETURN;
}
// load the token list into memory
INT loadactions(CHAR *sys)
{
    LONG l;
    INT i,fd,bl;
    INT16 t;

	ENTRY(1890);
    freeactions();
//	memset(G_vars,0,sizeof(G_vars));
    sprintf(G_afilename,"%s%sI.DAT",G_config,sys);

    if ((fd=open(G_afilename,O_RDONLY|O_BINARY))==(-1)) RETURNV(0);
    read(fd,&t,sizeof(INT16));
    if (t!=0x5A5A) {
        printf("Old Actions must be re PP'ed\n");
        RETURNV(0);
    }
    read(fd,&t,sizeof(INT16));
    G_numn=(INT)t;
    G_nbuf=MALLOC(G_numn*sizeof(NAMEINDEX));
    for (i=0;i<G_numn;i++) {
        read(fd,&G_nbuf[i].d,sizeof(CHAR));
        read(fd,&G_nbuf[i].t,sizeof(CHAR));
        read(fd,&G_nbuf[i].o,sizeof(LONG));
        read(fd,&G_nbuf[i].n,9*sizeof(CHAR));
    }
    read(fd,&l,sizeof(LONG));

	G_buffofs=lseek(fd,0L,SEEK_CUR);
    for (i=0;i<G_numn;i++) {
        if (i+1==G_numn)
            bl=(INT)(l-G_nbuf[i].o);
        else
            bl=(INT)(G_nbuf[i+1].o-G_nbuf[i].o);
		if ((actiontype(i)==STATNAME)||(actiontype(i)==VARIABLE)) {
            G_nbuf[i].b=MALLOC(max(81,bl+1));
			lseek(fd,1,SEEK_CUR);
			read(fd,G_nbuf[i].b,bl-1);
		} else {
            G_nbuf[i].b=MALLOC(bl+1);
			lseek(fd,4,SEEK_CUR);
			read(fd,G_nbuf[i].b,bl-4);
        }
	}
	close(fd);
    RETURNV(1);
}
// Name compare
INT ancmp(NAMEBUFFER *a,NAMEBUFFER *b)
{
    return(strcmp(a->n,b->n));
}
// find the name of an action and RETURN it's number offset ( -1 = not found )
INT findname(CHAR *name)
{
    INT i;
    NAMEBUFFER t,*r;

	ENTRY(1870);
    if ((name==NULL)||(*name==0)||(strlen(name)>8)) RETURNV(-1);
    if (G_anamebuf==NULL) {
        G_anamebuf=MALLOC(G_numn*sizeof(NAMEBUFFER));
        if (G_anamebuf!=NULL) {
            for (i=0;i<G_numn;i++) {
                strcpy(G_anamebuf[i].n,actionname(i));
                G_anamebuf[i].i=i;
            }
            qsort(G_anamebuf,G_numn,sizeof(NAMEBUFFER),(QSPTR)ancmp);
        }
    }
    if (G_anamebuf!=NULL) {
        strcpy(t.n,name);
        r=(NAMEBUFFER *)bsearch(&t,G_anamebuf,G_numn,sizeof(NAMEBUFFER),(QSPTR)ancmp);
        if (r==NULL) RETURNV(-1);
        RETURNV(r->i);
    } else {
        for (i=0;i<G_numn;i++) {
            if (!strcmp(name,actionname(i))) RETURNV(i);
        }
    }
    RETURNV(-1);
}

