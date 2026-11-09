#include <stdio.h>
#include <stdarg.h>
#include <conio.h>
#include "tintext.h"
#include "gprim.h"

#define max(a,b) ((a>b)?a:b)

void tinyxy(int x,int y,char *fmt,...) {
	int xp,yp,i,mx;
	unsigned char *t,tmp[160],*s;
	va_list ap;
	va_start(ap,fmt);
	vsprintf(tmp,fmt,ap);
	va_end(ap);
	s=tmp;
	while (*s) {
		mx=0;
		if ((*s>31)&&(*s<=127)) {
			i=G_charofs[*s-32];
			t=G_chardefs+i;
			i=((G_charofs[*s-31]-i)/2)-1;
			while (i--) {
				xp=(*t&0x3F)-(64*((*(t++)&0x40)!=0));
				yp=(*t&0x3F)-(64*((*(t  )&0x40)!=0));
				if (!(*(t)&0x80)) {
					moveto(x+xp,y-yp);
				} else {
					lineto(x+xp,y-yp);
				}
			  	mx=max(mx,x+xp);
				t++;
			}
		}
		s++;
		x=mx;
	}
}
int main(void)
{
	grafix(0);
	tinyxy(0,100,"%s","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,?~`!@#$%^&*()_+-=[]{}:\"|<>\/\\");
	tinyxy(0,200,"%s","012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567");
	getch();
	closegraf();
	return(0);
}
