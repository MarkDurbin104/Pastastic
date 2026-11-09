#define SCRDEV_C
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdarg.h>
#include "types.h"
#include "config.h"
#include "scrdev.h"
CHAR  G_boxchars[22]={'Ú','¿','À','Ù','³','Ä','Á','Â','Ã','´','Å',
                     'É','»','È','¼','º','Í','Ê','Ë','Ì','¹','Î'};
void prat(int x,int y,char *fmt,...)
{
    char tmp[100],*s,*scr,*end;
    va_list ap;
    s=tmp;
    va_start(ap,fmt);
    vsprintf(tmp,fmt,ap);
    va_end(ap);
    scr=TEXTVIDMEM+y*160+x*2;
    end=TEXTVIDMEM+(y+1)*160;
    while ((*s)&&(scr<end)) {
        *scr++=*s++;
        if (G_screen.attr!=G_hattr[0]) *scr=G_screen.attr;
        scr++;
    }
}
void dbox(INT x,INT y,INT x1,INT y1)
{
    int i;
    if (x==x1) {
        for (i=y+1;i<y1;i++) {
            prat(x ,i,"%c",G_boxchars[15]);
            prat(x1,i,"%c",G_boxchars[15]);
        }
        prat(x ,y ,"%c",G_boxchars[18]);
        prat(x ,y1,"%c",G_boxchars[17]);
    } else if (y==y1) {
        for (i=x+1;i<x1;i++) {
            prat(i,y ,"%c",G_boxchars[16]);
            prat(i,y1,"%c",G_boxchars[16]);
        }
        prat(x ,y ,"%c",G_boxchars[19]);
        prat(x1,y ,"%c",G_boxchars[20]);
    } else {
        for (i=x+1;i<x1;i++) {
            prat(i,y ,"%c",G_boxchars[16]);
            prat(i,y1,"%c",G_boxchars[16]);
        }
        for (i=y+1;i<y1;i++) {
            prat(x ,i,"%c",G_boxchars[15]);
            prat(x1,i,"%c",G_boxchars[15]);
        }
        prat(x ,y ,"%c",G_boxchars[11]);
        prat(x1,y ,"%c",G_boxchars[12]);
        prat(x ,y1,"%c",G_boxchars[13]);
        prat(x1,y1,"%c",G_boxchars[14]);
    }
}
void cursor(INT x,INT y,INT num)
{
    int i;
    UCHAR c; 
    for (i=0;i<num;i++) {
        c=*(TEXTVIDMEM+y*160+((x+i)*2+1));
        c=(c>>4)|(c<<4);
        *(TEXTVIDMEM+y*160+((x+i)*2+1))=c;
    }
}
void cls(void)
{
    G_newscr=1; textattr(G_hattr[0]); clrscr(); gotoxy(80,25);
}
INT isnew(void)
{
	if (G_newscr) { G_newscr=0; return(1); }
	return(0);
}
// screen control routine
LONG scr_control(INT type,va_list ap)
{
    CHAR tmp[160],*f;
    INT x=0,y,x1,y1,num,c;
    LONG retval=1L;

    switch (type) {

		case MESSAGE_od :
            x=va_arg(ap,INT);
		case MESSAGE_o :
            x+=va_arg(ap,INT);
            y=va_arg(ap,INT);
            f=va_arg(ap,CHAR *);
            vsprintf(tmp,f,ap);
		    prat(x,y,"%s",tmp);
		    retval=1L;
			break;

        case MESSAGE_C :
            x=va_arg(ap,INT);
        case MESSAGE_s :
            x+=va_arg(ap,INT);
            y=va_arg(ap,INT);
            num=va_arg(ap,INT);
            cursor(x,y,num);
			retval=1L;
            break;

        case MESSAGE_AA : case MESSAGE_A :
            c=va_arg(ap,INT)&0xFF;
			if (c<4) {
				G_screen.attr=G_hattr[c];
			} else {
                if ((c-3)<16)
    				G_screen.attr=0x70+(CHAR)(c-3);
                else
    				G_screen.attr=0x07+(CHAR)(c-3);
			}
			retval=1L;
            break;

        case MESSAGE_3 : case MESSAGE_B : case MESSAGE_L :
            x=va_arg(ap,INT);
            y=va_arg(ap,INT);
            x1=va_arg(ap,INT);
            y1=va_arg(ap,INT);
            dbox(x,y,x1,y1);
            break;

		case MESSAGE_R  : case MESSAGE_I  : case MESSAGE_RI : cls();  break;
        case MESSAGE_TE : case MESSAGE_E  : textattr(0x07); clrscr(); break;
        case MESSAGE_p  : retval=(LONG)(va_arg(ap,INT)+va_arg(ap,INT)); break;
        case MESSAGE_N  : retval=(LONG)isnew(); break;
		case MESSAGE_T  : retval=(LONG)strlen(va_arg(ap,CHAR *)); break;
		case MESSAGE_K  : retval=(LONG)va_arg(ap,INT); break;
    }
    return(retval);
}

