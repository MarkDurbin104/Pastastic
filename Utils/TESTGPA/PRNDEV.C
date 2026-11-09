#define PRNDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#include <malloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <ctype.h>
#include "types.h"
#include "message.h"
#include "control.h"
#include "memory.h"
#include "prndev.h"
#include "config.h"

UCHAR G_doubmap[16]={0x00,0x03,0x0C,0x0F,0x30,0x33,0x3C,0x3F,0xC0,0xC3,0xCC,0xCF,0xF0,0xF3,0xFC,0xFF};
FILE *G_printer;
INT   G_prerror=0;

void prch(UCHAR c)
{
	if (c==26) c=25; if (c==10) c=9;
	fputc(c,G_printer);
}
// printer character output routine
void ppoutch(INT x,INT y,INT c)
{
    c&=0xFF;

    if ((x>G_ppmaxx)||(y>G_ppmaxy)||(x<0)||(y<0)) return;
    if (G_prn==NULL) return;

    G_prn[x+G_ppmaxx*y]=c;

    G_ppcurx=x+1;
    G_ppcury=y;
    if (G_ppcurx>G_ppmaxx) {
        G_ppcurx=0;
        G_ppcury++;
    }
}
LONG getfofs(UCHAR **s,INT hgt,INT wid)
{
	LONG ret=0L;
	LONG sw=hgt*(wid-1);
	LONG lw=hgt*wid;
	UCHAR *t=*s,a;

	(*s)++;

	a=*t;
	if (a<0x80) return(a*sw);
								 ret=256L*sw;
	if       (a<0xA4)			 ret+=(157L*(a-0xA1))*lw;
	else if  (a<0xC7) 			 ret+=(157L*(a-0xA4))*lw+(408L*lw);
	else if ((a>0xC8)&&(a<0xFA)) ret+=(157L*(a-0xC9))*lw+(5809L*lw);
	else return(-1L);

	a=*(++t); (*s)++;
	if ((a<0x40)||((a>0x7F)&&(a<0xa1))) return(-1L);
	a-=0x40; if (a>0x3F) a-=0x22;
	lw*=a;
	return(ret+lw);
}
void prgln(UCHAR *str,INT len)
{
 	char huge *font=NULL;
	LONG base=0;
	UCHAR tmp[24*3];
	INT i=0,j=0,k=0,m=0;
	UCHAR *s=str,*t=NULL;

 	sendmsg("VGA",MESSAGE_f,&font);
 	for (i=0;i<24;i++) {
		str=s;
		prch(0x11);
		m=0;
		for (k=0;k<len;k++) {
			t=str;
			if ((base=getfofs(&str,24,3))>=0) {
				if (str==t+2) k++;
				j=3;
				if (base<=(256L*48)) j--;
				_fmemcpy(tmp,font+base,24*j);
				prch(tmp[i*j]);
				prch(tmp[i*j+1]);
				if (j>2) prch(tmp[i*j+2]);
				m+=j;
			}
		}
		for (k=m;k<48;k++) prch(0);
	}
}
void preol(void)
{
	prch('\n');
}
void preop(void)
{
	prch(0x16);
}
INT outputform(void)
{
    INT x,y,w;
	UCHAR str[255];
	UCHAR *font;
    if (G_prn==NULL) return(0);
	sendmsg("OUTPUT1",MESSAGE_f,&font);
    for (y=0;y<G_ppmaxy;y++) {
       	for (w=G_ppmaxx-1;w>=0;w--) {
			if ((G_prn[w+(y*G_ppmaxx)]&0xFF)!=0) break;
		}
	  	for (x=0;x<w+1;x++) str[x]=G_prn[x+(y*G_ppmaxx)]&0xFF;
		prgln(str,x);
		if (sendmsg("INPUT1",MESSAGE_H)) sendmsg("INPUT1",MESSAGE_i);
	}
	preop();
	return(1);
}
// printer reset routine
INT prn_reset(void)
{
    G_ppcury=G_ppcurx=0;
    if (G_prn!=NULL) memset(G_prn,0,G_ppmaxx*G_ppmaxy*sizeof(int));
	return(1);
} 
// printer output routine
INT prn_output(INT x,INT y,UCHAR *str)
{
 	while (*str) ppoutch(x++,y,*(str++));
    return(1);
}
// printer startup routine
INT prn_startup(INT type)
{
    if (type==0) return(0);
    G_printer=stdprn;					
    if (G_prn!=NULL) FREE(G_prn);
    G_prn=MALLOC(G_ppmaxx*G_ppmaxy*sizeof(int)*2);
    if (G_prn==NULL) {
		G_ppmaxx=1;
		G_ppmaxy=1;
	    return(0);
	}
    prn_reset();
    return(1);
}
// printer shutdown routine
INT prn_shutdown(void)
{
	G_printer=NULL;
    if (G_prn!=NULL) FREE(G_prn);
    G_prn=NULL;
    return(1);                 
}

LONG prn_control(INT type,va_list ap)
{
    INT retval=1;
    INT a,b;
	char *f,tmp[80];
	char e;

	asm mov ax,0x0200
	asm mov dx,0x0000
	asm INT 0x17
	asm mov e,ah
	if ((e&0xF9)!=0xD0) {
		G_prerror=1;
	} else {
		G_prerror=0;
	}
	G_printer=stdprn;

	switch (type) {
        case MESSAGE_R :
			retval=prn_reset();
			break;

        case MESSAGE_o :
			if (!G_prerror) {
            	a=va_arg(ap,int);
            	b=va_arg(ap,int);
            	f=va_arg(ap,char *);
		    	vsprintf(tmp,f,ap);
				retval=prn_output(a,b,(UCHAR *)tmp);
			}
			break;

        case MESSAGE_I :
            prn_startup(1);
            break;

        case MESSAGE_E :
            prn_shutdown();
            break;

        case MESSAGE_F :
			retval=0;
			if (!G_prerror) retval=outputform(); 
       		prn_reset();
            break;

        case MESSAGE_b :
            G_ppmaxx=va_arg(ap,int);
            G_ppmaxy=va_arg(ap,int);
            G_prn=REALLOC(G_prn,G_ppmaxx*G_ppmaxy*sizeof(int)*2);
            prn_reset();
            break;

        case MESSAGE_GS :
            retval=G_prerror;
            break;
    }
    return((LONG)retval);
}
//___________________________________________________________________________

