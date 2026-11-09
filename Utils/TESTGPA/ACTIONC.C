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

//************************************************************
//F actionofs
//S Return action offset
//P idx
LONG actionofs(INT idx)
{
    return(G_nbuf[idx].o);
}
//************************************************************
//F actiontype
//S Return action type
//P idx
UCHAR actiontype(INT idx)
{
    return(G_nbuf[idx].t);
}
//************************************************************
//F actiondeb
//S Return action debug
//P idx
UCHAR actiondeb(INT idx)
{
    return(G_nbuf[idx].d);
}
//************************************************************
//F actionname
//S Return action name
//P idx
CHAR *actionname(INT idx)
{
    return(G_nbuf[idx].n);
}
//************************************************************
//F actionbuf
//S Return action buffer pointer (token string or variable)
//P idx
UCHAR *actionbuf(INT idx)
{
    return(G_nbuf[idx].b);
}
//************************************************************
//F setactionbuf
//S Set action buffer pointer
//P idx
//P *s
void setactionbuf(INT idx,UCHAR *s)
{
    G_nbuf[idx].b=s;
}
//************************************************************
//F freeactions
//S free the token list from memory
//D free all the action buffer pointers then the actions in
//D the action name array: NAMEINDEX G_nbuf, and the index array
//D to the action names: NAMEBUFFER G_anamebuf.
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
//************************************************************
//F loadactions
//S load the token list into memory
//D Read the data from the actions file into memory
//P *sys
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

  	G_buffofs=lseek(fd,0L,SEEK_CUR);	// Save current file pos - name buffer offset
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
//************************************************************
//F ancmp
//S Name compare
//D strcmp two NAMEBUFFER names
//P *a
//P *b
INT ancmp(NAMEBUFFER *a,NAMEBUFFER *b)
{
    return(strcmp(a->n,b->n));
}
//************************************************************
//F findname
//S find the name of an action and RETURN it's number offset ( -1 = not found )
//D If G_anamebuf sorted list is not set up, set it up.  Binary search this
//D buffer and return the index to a name. If a sorted list cannot be set
//D up a simple sequential search occurs.
//P *name
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
//***********************************************************************
// End of file - ACTIONC.C
