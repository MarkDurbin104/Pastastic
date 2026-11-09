#define MEMORY_C
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include "types.h"
#include "extmem.h"
#include "memory.h"
#include "control.h"

void geteblock(INT idx,void *ptr,ULONG ofs,ULONG len)
{
	ENTRY(380);
	if (ptr==NULL) RETURN;
	G_memh[idx]->stat=0;
	if (len==0L) len=G_memh[idx]->size;
	if ((G_memh[idx]->err=exmem2mem(ptr,G_memh[idx]->hand,ofs,len))==1) {
		G_memh[idx]->stat=1;
	}
	if (!G_memh[idx]->stat) { fprintf(stdout,"GETE %02X %s\n",G_memh[idx]->err,G_memh[idx]->name); fflush(stdout); }
	RETURN;
}
void seteblock(INT idx,void *ptr,ULONG ofs,ULONG len)
{
	ENTRY(390);
	if (ptr==NULL) RETURN;
	G_memh[idx]->stat=0;
	if (len==0) len=G_memh[idx]->size;
	if ((G_memh[idx]->err=mem2exmem(ptr,G_memh[idx]->hand,ofs,len))==1) {
		G_memh[idx]->stat=1;
	}
	if (!G_memh[idx]->stat) { fprintf(stdout,"SETE %02X %s\n",G_memh[idx]->err,G_memh[idx]->name); fflush(stdout); }
	RETURN;
}
INT isblk(CHAR *name)
{
	INT i;
	static INT j=0;
	static CHAR n[80];
	ENTRY(400);

	if (!strcmp(n,name)) RETURNV(j);
	if (!EXMEMinstalled()) RETURNV(0);
	for (i=0;i<G_nummh;i++) {
		if (!strcmp(name,G_memh[i]->name)) {
			strcpy(n,name);
			j=i+1;
			RETURNV(j);
		}
	}
	RETURNV(0);
}
INT setupblk(CHAR *name,ULONG size)
{
	INT i;
	ENTRY(410);
	if (!EXMEMinstalled()) RETURNV(0);
	if (isblk(name)) RETURNV(1);
	if (G_numamh==0) {
	 	G_numamh+=50;
		G_memh=MALLOC(G_numamh*sizeof(PMEMH));
		if (G_memh==NULL) RETURNV(0);
		for (i=G_numamh-50;i<G_numamh;i++) G_memh[i]=NULL;
	} else if (G_nummh==G_numamh) {
	 	G_numamh+=50;
		G_memh=REALLOC(G_memh,G_numamh*sizeof(PMEMH));
		if (G_memh==NULL) RETURNV(0);
		for (i=G_numamh-50;i<G_numamh;i++) G_memh[i]=NULL;
	}
	G_memh[G_nummh]=MALLOC(sizeof(MEMH));
	if (G_memh[G_nummh]==NULL) RETURNV(0);
	if (strlen(name)>79) name[79]=0;
	strcpy(G_memh[G_nummh]->name,name);
	size+=size%2;
	G_memh[G_nummh]->size=size;
	G_memh[G_nummh]->hand=EXMEMalloc(size);
	if (!G_memh[G_nummh]->hand) {
		FREE(G_memh[G_nummh]);
		RETURNV(0);
	}
	G_nummh++;
	RETURNV(1);
}
INT finblk(CHAR *name)
{
	INT i;
	UINT h;
	ENTRY(420);
	if ((i=isblk(name))==0) RETURNV(0);
	i--;
	G_memh[i]->name[0]=0;
	h=G_memh[i]->hand;
	G_memh[i]->hand=0;
	RETURNV(EXMEMfree(h));
}
void cleanupblks(INT show)
{
	INT i;
	ULONG j=0;
	
	ENTRY(430);
	for (i=0;i<G_nummh;i++) {
		if (show) printf("\n%10lu (%4luK) %u %u %04X %-35.35s",G_memh[i]->size,((G_memh[i]->size+1023L)/1024L),G_memh[i]->hand,G_memh[i]->stat,G_memh[i]->err,G_memh[i]->name);
		j+=((G_memh[i]->size+1023)/1024);
		if (G_memh[i]->hand!=0) EXMEMfree(G_memh[i]->hand);
		FREE(G_memh[i]);
	}
	if (show) printf("\n           (%4uK)\n",j);
	FREE(G_memh);
	RETURN;
}
UINT blksize(CHAR *name)
{
	INT i;
	ENTRY(440);
	if ((i=isblk(name))==0) RETURNV(0);
	i--;
	RETURNV((UINT)G_memh[i]->size);
}
INT restpblk(CHAR *name,void *ptr,ULONG ofs,ULONG len)
{
	INT i;
	CHAR tmp[2];
	ENTRY(450);
	if ((i=isblk(name))==0) RETURNV(0);
	i--;
	if ((len&1L)==1L) {
		len--;
		geteblock(i,ptr,ofs,len);
		geteblock(i,tmp,ofs+len,2);
        if (len<65536L) *(((CHAR *)ptr)+(INT)len)=tmp[0];
	} else {
		geteblock(i,ptr,ofs,len);
	}
	RETURNV(G_memh[i]->stat);
}
INT restblk(CHAR *name,void *ptr)
{
	ENTRY(460);
	RETURNV(restpblk(name,ptr,0L,0));
}
INT savepblk(CHAR *name,void *ptr,ULONG ofs,ULONG len)
{
	INT i;
	ENTRY(470);
	len+=len&1;
	if ((i=isblk(name))!=0) {
		i--;
		seteblock(i,ptr,ofs,len);
		RETURNV(G_memh[i]->stat);
	}
	RETURNV(0);
}
INT saveblk(CHAR *name,ULONG size,void *ptr)
{
	ENTRY(480);
	size+=size&1;
	if (!setupblk(name,size)) RETURNV(0);
	RETURNV(savepblk(name,ptr,0L,size));
}

