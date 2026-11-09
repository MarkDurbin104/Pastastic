/****************************************************************************
* Project     : GPA
* File        : actionc.c
* Description : Routines related to the action buffers - read, set up and
*               utility.  Does not actually process them.
* 
* $Revision:   1.2  $  $Date:   Nov 01 1995 15:13:46  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/actionc.c_v  $
* 
*    Rev 1.2   Nov 01 1995 15:13:46   JGRAY
*  
* 
*    Rev 1.1   Oct 20 1995 15:10:38   JGRAY
* Annotation.
* 
****************************************************************************/
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

#include "gpasizes.h"
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
//D n.b. reply should properly be ULONG not LONG :JGQ
//P integer idx
//R long integer value of offset in buffer
 
LONG actionofs(INT idx)
{
    return(G_nbuf[idx].o);
}

//************************************************************
//S Return action type
//D n.b. reply should properly be signed not unsigned :JGQ
//P integer idx
//R U char type i.e. table, action , variable or static 

UCHAR actiontype(INT idx)
{
    return(G_nbuf[idx].t);
}

//************************************************************
//S Return action debug flag
//D n.b. reply should properly be signed not unsigned :JGQ
//P integer idx
//R U char value of debug flag

UCHAR actiondeb(INT idx)
{
   return(G_nbuf[idx].d);
}

//************************************************************
//S Return action name
//D note the size of the string pointed to is a maximum inc. delim of LENOFACTNAME
//P integer idx
//R char ptr address of the name string.

CHAR *actionname(INT idx)
{
   return(G_nbuf[idx].n);
}

//************************************************************
//S Return action buffer pointer (token string or variable)
//P integer idx
//R address of buffer.  Properly I guess this should be cast as void ?:JGQ

UCHAR *actionbuf(INT idx)
{
    return(G_nbuf[idx].b);
}

//************************************************************
//S Set action buffer pointer to the supplied address
//P integer idx
//P U char ptr 

void setactionbuf(INT idx,UCHAR *s)
{
    G_nbuf[idx].b=s;
}
//************************************************************
//S free the token list from memory
//D free all the action buffer pointers then the actions in
//D the action name array: NAMEINDEX G_nbuf, and the index array
//D to the action names: NAMEBUFFER G_anamebuf.

void freeactions(void)
{
    INT i;
    ENTRY(1900);
    for (i=0;i<G_numn;i++)
      {
        if (actionbuf(i)!=NULL)
         FREE(actionbuf(i));
       }
    if (G_nbuf!=NULL)
      FREE(G_nbuf);
    G_nbuf=NULL;
    if (G_anamebuf!=NULL)
      FREE(G_anamebuf);
    G_anamebuf=NULL;
    RETURN;
}
//************************************************************
//S load the token list into memory
//D 1) Clears old action array
//D 2) Read the data from the actions file into memory
//P char string system name
//R BOOL integer FALSE (0) means failed, TRUE (1) means ok

INT loadactions(CHAR *sys)
{
   LONG l;
   INT i,fd,bl;
   INT16 t;

    ENTRY(1890);
   freeactions();
// memset(G_vars,0,sizeof(G_vars));
   sprintf(G_afilename,"%s%sI.DAT",G_config,sys);

   if ((fd=open(G_afilename,O_RDONLY|O_BINARY))==(-1))
      RETURNV(0);
   read(fd,&t,sizeof(INT16)); // No check on read failure :JGQ
   if (t!=0x5A5A)
      {
      printf("Old Actions must be re PP'ed\n");
      RETURNV(0);       // This hasn't closed the file :JGQ
      }
   read(fd,&t,sizeof(INT16)); // No check on read failure :JGQ
   G_numn=(INT)t;
   G_nbuf=MALLOC(G_numn*sizeof(NAMEINDEX));
   for (i=0;i<G_numn;i++)
      {
      read(fd,&G_nbuf[i].d,sizeof(CHAR));    // No read failure check here either :JGQ
      read(fd,&G_nbuf[i].t,sizeof(CHAR));
      read(fd,&G_nbuf[i].o,sizeof(LONG));
      read(fd,&G_nbuf[i].n,LENOFACTNAME*sizeof(CHAR));
      }
   read(fd,&l,sizeof(LONG));        // total block size

      G_buffofs=lseek(fd,0L,SEEK_CUR);    // Save current file pos - name buffer offset
   for (i=0;i<G_numn;i++)
      {
      if (i+1==G_numn)     // i.e. this is the last of them
         bl=(INT)(l-G_nbuf[i].o);      // block length is size - offset
      else
         bl=(INT)(G_nbuf[i+1].o-G_nbuf[i].o); // block length = start of next block - start of this block
        if ((actiontype(i)==STATNAME)||(actiontype(i)==VARIABLE))
            {
            G_nbuf[i].b=MALLOC(max(MINIXBQ,bl+1));   // malloc space of 81 or bl+1
            lseek(fd,1,SEEK_CUR);               // skip 1
            read(fd,G_nbuf[i].b,bl-1);          // read block
           }
      else
         {
         G_nbuf[i].b=MALLOC(bl+1);
            lseek(fd,4,SEEK_CUR);               // skip 4
            read(fd,G_nbuf[i].b,bl-4);          // read block
         }
       }
    close(fd);
   RETURNV(1);
}

//************************************************************
//S Name compare function for use by qsort and bsearch
//D strcmp two NAMEBUFFER names
//P NAMEBUFFER address a
//P NAMEBUFFER address b
//R integer reply of strcmp type based on the names in each of the supplied buffers

INT ancmp(NAMEBUFFER *a,NAMEBUFFER *b)
{
    return(strcmp(a->n,b->n));
}
//************************************************************
//S find the name of an action and RETURN it's number offset ( -1 = not found )
//D If G_anamebuf sorted list is not set up, set it up.  Binary search this
//D buffer and return the index to a name. If a sorted list cannot be set
//D up a simple sequential search occurs.
//P char string action name to look for
//R integer item number or -1 if not found

INT findname(CHAR *name)
{
   INT i;
   NAMEBUFFER t,*r;

    ENTRY(1870);
   if ((name==NULL)||(*name==0)||(strlen(name)>8))
      RETURNV(-1);      // This is the first time I've seen str length validation! :JGQ
   if (G_anamebuf==NULL)
      {
      G_anamebuf=MALLOC(G_numn*sizeof(NAMEBUFFER));
      if (G_anamebuf!=NULL)
         {
         for (i=0;i<G_numn;i++)
            {
            strcpy(G_anamebuf[i].n,actionname(i));
            G_anamebuf[i].i=i;
            }
         qsort(G_anamebuf,G_numn,sizeof(NAMEBUFFER),(QSPTR)ancmp);
         }
      }
   if (G_anamebuf!=NULL)
      {
      strcpy(t.n,name);
      r=(NAMEBUFFER *)bsearch(&t,G_anamebuf,G_numn,sizeof(NAMEBUFFER),(QSPTR)ancmp);
      if (r==NULL)
         RETURNV(-1);
      RETURNV(r->i);
      }
   else
      {
      for (i=0;i<G_numn;i++)
         {
         if (!strcmp(name,actionname(i)))
            RETURNV(i);
         }
      }
   RETURNV(-1);
}
// **************************************************************************
// actionc.c <end-of-file>

