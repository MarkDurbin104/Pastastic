//=============================== BFTELEM.C =================================
#define BFTELEM_C

#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <graphics.h>

#include "bftelem.h"
#include "tintext.h"

#ifndef max
#define max(a,b) ((a>b)?a:b)
#endif  // ndef max

//*****************************************************
//F tinyxy
//S
//P
void tinyxy(int c,int x,int y,int mag,int div,int dir,char *fmt,...)
{
	int xp,yp,i,mx,x1=x;
	unsigned char *t,tmp[160],*s;
	va_list ap;
	va_start(ap,fmt);
	vsprintf((char *)tmp,fmt,ap);
	va_end(ap);
	s=tmp;
	setcolor(c);
	while (*s) {
		mx=0;
		if ((*s>31)&&(*s<=127)) {
			i=G_charofs[*s-32];
			t=G_chardefs+i;
			i=((G_charofs[*s-31]-i)/2)-1;
			while (i--) {
				xp=(((*t&0x3F)-(64*((*(t++)&0x40)!=0)))*mag)/div;
				yp=(((*t&0x3F)-(64*((*(t  )&0x40)!=0)))*mag)/div;
			  	mx=max(mx,x+xp);
				t++;
			}      
		}
		s++;
		x=mx;
	}
	s=tmp;
	setcolor(c);
    switch (dir) {
        case 0 :
            x=(x1-((x-x1)/2))+(mag/div);
            y+=(3*mag)/div;
	        while (*s) {
		        mx=0;
		        if ((*s>31)&&(*s<=127)) {
			        i=G_charofs[*s-32];
			        t=G_chardefs+i;
			        i=((G_charofs[*s-31]-i)/2)-1;
			        while (i--) {
				        xp=(((*t&0x3F)-(64*((*(t++)&0x40)!=0)))*mag)/div;
				        yp=(((*t&0x3F)-(64*((*(t  )&0x40)!=0)))*mag)/div;
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
            break;
        case 1 :
            y=(y-((x-x1)/2))+(mag/div);
            x=x1-(3*mag)/div;
	        while (*s) {
		        mx=0;
		        if ((*s>31)&&(*s<=127)) {
			        i=G_charofs[*s-32];
			        t=G_chardefs+i;
			        i=((G_charofs[*s-31]-i)/2)-1;
			        while (i--) {
				        xp=(((*t&0x3F)-(64*((*(t++)&0x40)!=0)))*mag)/div;
				        yp=(((*t&0x3F)-(64*((*(t  )&0x40)!=0)))*mag)/div;
				        if (!(*(t)&0x80)) {
					        moveto(x+yp,y+xp);
				        } else {
					        lineto(x+yp,y+xp);
				        }
			  	        mx=max(mx,y+xp);
				        t++;
			        }      
		        }
		        s++;
		        y=mx;
	        }
            break;
    }
}
//============================================================================
//F grafix
//S switch the screen into graphics mode
//D switch the screen into graphics mode using the borland 
//D graphics functions
//R TRUE is OK
int grafix(void)
{
    int GraphDriver = DETECT;                 /* Request auto-detection       */
    int GraphMode;
    int ErrorCode;
    initgraph( &GraphDriver, &GraphMode, "d:\\bc45\\bgi" );
    ErrorCode = graphresult();            /* Read result of initialization*/
    if( ErrorCode != grOk ){              /* Error occured during init    */
        printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
        return 0;
    }
    return 1;
}
void draw_yunit(int x,int y,int size,int dir,char *text)
{
    switch (dir) {
        case 1 :
        case 3 :
            moveto(x-size,y-size*2);
            lineto(x-size,y+size*2);
            lineto(x     ,y+size*3);
            lineto(x+size,y+size*2);
            lineto(x+size,y-size*2);
            lineto(x     ,y-size*3);
            lineto(x-size,y-size*2);
            break;
        case 0 :
        case 2 :
        default:
            moveto(x-size*2,y-size);
            lineto(x+size*2,y-size);
            lineto(x+size*3,y);
            lineto(x+size*2,y+size);
            lineto(x-size*2,y+size);
            lineto(x-size*3,y);
            lineto(x-size*2,y-size);
            break;
    }
    tinyxy(15,x,y,size,10,dir,"%s",text);
}
int main(void)
{
    if (grafix()) {
        draw_yunit(60,60,10,0,"YABCDE");
        draw_yunit(160,160,10,1,"YABCDE");
        getch();
        closegraph();
    }
	return 0;
}
//===============================END OF FILE=================================
