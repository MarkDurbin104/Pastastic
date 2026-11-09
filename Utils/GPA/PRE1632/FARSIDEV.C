#define FARSIDEV_C
//___________________________________________________________________________

#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include <alloc.h>
#include <io.h>
#include <dos.h>
#include <fcntl.h>
#include "types.h"
#include "memory.h"
#include "message.h"
#include "farsidev.h"

unsigned char *G_contspace=NULL;
#define CMAPOFS (32+(16*256)+(14*256))
int intlen(unsigned int *s)
{
	int i=0;
	while ((*s&0xFF)!=0) {
		s++;
		i++;
		if (i>80) return(80);
	}
	return(i);
}
void intcpy(unsigned int *d,unsigned int *s)
{
	int i=intlen(s);
	if (i) memcpy(d,s,i*2);
}
int state(unsigned int c)
{
	c&=0xFF;
	if (c==0) return(0);
	if (G_contspace==NULL) return(2);

	switch (*(G_contspace+c)&0x0F) {
		case 1 : return(2);
		case 2 : return(4);
		case 3 : return(8);
		case 4 : return(16);
	}
	return(1);
}
unsigned int *normal(unsigned int *s,unsigned int *d,int mask)
{
	d+=intlen(d);
	while ((state(*s)&mask)!=0) {
		*(d++)=*(s++);
	}
	return(s);
}
unsigned int *reflect(unsigned int *s,unsigned int *d,int mask)
{
	unsigned int tmp[160];
	unsigned int *t=&tmp[158];
	tmp[159]=0;
	d+=intlen(d);
	while ((state(*s)&mask)!=0) {
		*(t--)=*(s++);
	}
	t++;
	if (state(*s)) {
		while (state(*t)==1) {
			t++;
			s--;
		}
	}
	intcpy(d,t);
	return(s);
}
unsigned int *convint(unsigned int *p)
{
	unsigned int tmp[160];
	unsigned int *s=p;
	memset(tmp,0,sizeof(tmp));
	while ((*s&0xFF)!=0) {
		switch (state(*s)) {
			case 1 :
			case 2 :
				s=normal(s,tmp,0x03);
				break;
			default :
				s=reflect(s,tmp,0x1D);
		}
	}
	s=p;
	intcpy(s,tmp);
	memset(tmp,0,sizeof(tmp));
	while ((*s&0xFF)!=0) {
		switch (state(*s)) {
			case 1 :
			case 2 :
			case 4 :
				s=normal(s,tmp,0x07);
				break;
			case 8 :
				s=reflect(s,tmp,0x09);
			default :
				s=reflect(s,tmp,0x11);
		}
	}
	s=p;
	intcpy(s,tmp);
	return(s);
}
unsigned int cofs(int a,int b,int c,unsigned char ch)
{
	unsigned int r=(unsigned int)ch;
	unsigned char *f=G_contspace+256+ch;
	if (b<2) return(r);
	if (!a) a=1; if (!b) b=1; if (!c) c=1;
	if ((b!=a)&&(b!=c)) return(r);
	if ((b!=a)&&(b==c)&&(*f!=0)) return((unsigned int)*f);
	f+=256;
	if ((b==a)&&(b==c)&&(*f!=0)) return((unsigned int)*f);
	f+=256;
	if ((b==a)&&(b!=c)&&(*f!=0)) return((unsigned int)*f);
	return(r);
}
unsigned int contanal(unsigned char *p,int o)
{
	unsigned int a,b,c;

	if (o==0) a=1; else a=state((unsigned int)*(p-1));
	b=state((unsigned int)*p);
	c=state((unsigned int)*(p+1));
	return(cofs(a,b,c,*p));
}
unsigned char *convstr(unsigned char *p,int *cp)
{
	int i,l;
	static unsigned int iarr[160];
	if (*cp<0) *cp=0;
	if (*cp>159) *cp=159;
	l=strlen(p);
	memset(iarr,0,sizeof(iarr));
	for (i=0;i<l;i++) iarr[i]=(i<<8)|contanal(p+i,i);
	convint(iarr);
	for (i=0;i<l;i++) {
		p[i]=(unsigned char)(iarr[i]&0xFF);
	}
	for (i=0;i<l;i++) {
		if ((iarr[i]>>8)==*cp) {
			*cp=i;
			break;
		}
	}
	return(p);
}
int cpos(unsigned char *p,int cp,int np)
{
	int i,l;
	static unsigned int iarr[160];
	l=strlen(p)+1;
	memset(iarr,0,sizeof(iarr));
	for (i=0;i<l;i++) iarr[i]=((i+1)<<8)|contanal(p+i,i);
	convint(iarr);
	for (i=0;i<l;i++) {
		if ((iarr[i]>>8)==(cp+1)) {
			if ((iarr[i+np]>>8)!=0) return((iarr[i+np]>>8)-1);
			return(cp);
		}
	}
	return(cp+np);
}
void loadcont(char *f)
{
	int fd;
	char tmp[16];
	sprintf(tmp,"F%s",f);
	if (isblk(tmp)) {
    	if (G_contspace==NULL) G_contspace=malloc(1024);
    	if (G_contspace!=NULL) {
        	restblk(tmp,G_contspace);
    	}
	} else {
    	if (G_contspace==NULL) G_contspace=malloc(1024);
    	if (G_contspace!=NULL) {
			if ((fd=open(f,O_RDONLY|O_BINARY))==(-1)) return;
			lseek(fd,CMAPOFS,SEEK_SET);
			read(fd,G_contspace,1024);
			close(fd);
       		saveblk(tmp,1024,G_contspace);
		}
	}
}
// screen control routine
int fscr_control(int type,va_list ap)
{
    unsigned char tmp[160],*f,**ff;
    int x,y,x1,y1,num;
    int retval=1;

    switch (type) {
        case 'E' :
			if (G_contspace!=NULL) free(G_contspace);
			retval=sendmsg("SCREEN",type);
			break;
        case 'D' :
			x=G_maxx-(va_arg(ap,int)+17);
            y=va_arg(ap,int);
			retval=sendmsg("SCREEN",type,x,y);
			break;

        case 'I' :
        case '1' :
        case '0' :
		case 'R' :
		case 'i' :
        case 'N' :
			retval=sendmsg("SCREEN",type);
			break;

        case 'S' :
            G_size=(va_arg(ap,int)%4);
			retval=sendmsg("SCREEN",type,G_size);
            break;

        case 'A' :
        case 'l' :
        case 'X' :
			num=va_arg(ap,int);
			retval=sendmsg("SCREEN",type,num);
            break;

        case 'B' :
        case 'L' :
            x=G_maxx-(va_arg(ap,int));
            y=va_arg(ap,int);
            x1=G_maxx-(va_arg(ap,int));
            y1=va_arg(ap,int);
            retval=sendmsg("SCREEN",type,x,y,x1,y1);
            break;

        case 'C' :
            x=va_arg(ap,int);
			x1=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			if (num!=1) {
				x+=x1;
				x=G_maxx-(x+(num-1));
    	        retval=sendmsg("SCREEN",type,x,0,y,num);
			} else {
				retval=1;
			}
            break;

        case 'c' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            f=va_arg(ap,char *);
			strcpy(tmp,f);
			if (tmp[0]==0) {
				x=G_maxx-x;
            	retval=sendmsg("SCREEN",'C',x,0,y,1);
			} else {
            	num=va_arg(ap,int);
				x1=0;
				if (num==strlen(tmp)) { num--; x1=1; }
				convstr(tmp,&num);
				num=strlen(tmp)-num;
				x=G_maxx-(x+(num-1));
            	retval=sendmsg("SCREEN",'C',x,0,y,1);
			}
            break;

        case 's' :
        case 'r' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			x=G_maxx-(x+(num-1));
            retval=sendmsg("SCREEN",type,x,y,num);
            break;

		case 'o' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
            retval=1;
			if (tmp[0]!=0) {
				num=0;
				convstr(tmp,&num);
				num=strlen(tmp)*(1+(G_size>1));
				x=G_maxx-(x+(num-1));
				retval=sendmsg("SCREEN",type,x,y,"%s",tmp);
			}
			break;

        case 'p' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            f=va_arg(ap,char *);
			retval=cpos(f,x,y);
			break;

		case 'F' :
            f=va_arg(ap,char *);
			retval=sendmsg("SCREEN",type,f);
			loadcont(f);
			break;

		case 'T' :					// TRANSLATE
            f=va_arg(ap,char *);
            retval=0;
			if (tmp[0]!=0) {
				num=0;
				convstr(f,&num);
				retval=strlen(f);
			}
			break;

        case 'f' :
            ff=va_arg(ap,unsigned char **);
			*ff=G_contspace;
			if (G_contspace==NULL) retval=0; 
			break;

    }
    return(retval);
} 
//___________________________________________________________________________

