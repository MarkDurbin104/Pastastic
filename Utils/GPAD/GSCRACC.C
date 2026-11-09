#define GSCRACC_C

#include <conio.h>
#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <memory.h>
#include <dos.h>
#include <graphics.h>

#include "types.h"
#include "mouse.h"
#include "keydef.h"
#include "config.h"
#include "gscracc.h"

UINT dublit(UCHAR c)
{
    UINT res=0;
    INT i;

    for (i=0;i<8;i++) 
        if (c&(0x80>>i)) 
            res|=(0xC000>>(i<<1));

    return((res>>8)|(res<<8));
}
//___________________________________________________________________________
void getfont(void)
{
//    struct REGPACK r;
	G_font=readfont();
//	if ((G_font=readfont())==NULL) {
//        r.r_ax=0x1130;
//        r.r_bx=0x0600;
//        intr(0x10,&r);
//		G_font=(UCHAR *)MK_FP(r.r_es,r.r_bp);
//    }
	G_fonthigh=16;
	G_fontwide=8;
}

//int grafix(void)
//{
//    int gd = VGA;
//	int gm = VGAHI;
//    int err;
//
//	err=registerfarbgidriver(EGAVGA_driver_far);
//	if (err<0) {
//		printf("graphics System Error: %s\n",grapherrormsg(err));
//		return(0);
//	}
//    initgraph(&gd,&gm,"");
//    err=graphresult();
//	if (err<0) {
//		printf("graphics System Error: %s\n",grapherrormsg(err));
//        return(0);
//	}
//    G_maxx=80;
//    G_maxy=29;
//    G_linespace=16;
//    memset(G_scrc[0],' ',(80*30));
//    memset(G_scrc[1],0,(80*30));
//    memset(G_scrc[2],1,(80*30));
//    return(1);
//}
void cls(void)
{
    memset(G_scrc[0],' ',(80*30));
    memset(G_scrc[1],0,(80*30));
    memset(G_scrc[2],1,(80*30));
    cleardevice();
}
INT scrsetto(INT x,INT y,INT c,INT col,INT size)
{
    INT i,j;
    for (i=0;i<1+(size>1);i++) {
        for (j=0;j<1+(size==3);j++) {
            if (G_scrc[0][x+i][y+j]!=c) return(0);
            if (G_scrc[2][x+i][y+j]!=size) return(0);
            if (c!=' ') {
                if (G_scrc[1][x+i][y+j]!=col) return(0);
            }
        }
    }
    return(1);
}
void setscrto(INT x,INT y,INT c,INT col,INT size)
{
    INT i,j;
    for (i=0;i<1+(size>1);i++) {
        for (j=0;j<1+(size==3);j++) {
            G_scrc[0][x+i][y+j]=c;
            G_scrc[1][x+i][y+j]=col;
            G_scrc[2][x+i][y+j]=size;
        }
    }
}
void outch(INT x,INT y,UCHAR c,INT col) 
{
	INT i,j;
	UCHAR *t=(UCHAR *)MK_FP(__SegA000,0000); 
    CHAR *s;
    UCHAR mask;
    UINT tmp;
    INT cpos,flip=0;;
    
	 if ((x>G_maxx)||(y>G_maxy)||(x<0)||(y<0)) return;

    col>>=8;
    if ((col&0x77)==0x22) flip=1;
    col&=0x0F;

    if (!G_xor) {
        if (scrsetto(x,y,c,col,G.size)) return;
    }
    setscrto(x,y,c,col,G.size);


	cpos=c*G_fonthigh+((G_font==G_fontspace)*32);
//    cpos=(c*G_fonthigh);
    y*=G_linespace;
//    y+=2;
	for (i=0;i<4;i++) {
		outportb(0x3CE,4);   /*set read plane */
		outportb(0x3CF,i); /* 0,1,2,3 */
		outportb(0x3C4,2);   /* set write plane */
		outportb(0x3C5,1<<i); /* 1,2,4,8 */
		if (col&(1<<i)) {		/* for each bit in colour */
            switch (G.size) {
                case 1 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
        			for (j=0;j<G_fonthigh;j++) {    /* if set */
						if (flip) mask=G_font[cpos+j]^0xFF; else mask=G_font[cpos+j];
							if (G_xor) *s^=mask; else *s=mask;
                        s+=G_maxx;
        			}
                    break;
                case 2 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
    			    for (j=0;j<G_fonthigh;j++) {    /* if set */
						if (flip) mask=G_font[cpos+j]^0xFF; else mask=G_font[cpos+j];
                        tmp=dublit(mask);
             			if (G_xor) *((INT *)s)^=tmp; else *((INT *)s)=tmp;	
                        s+=G_maxx;
    			    }
                    break;
                case 3 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
    			    for (j=0;j<G_fonthigh;j++) {    /* if set */
						if (flip) mask=G_font[cpos+j]^0xFF; else mask=G_font[cpos+j];
                        tmp=dublit(mask);
          				if (G_xor) {
                            *((INT *)s)^=tmp;	
                            s+=G_maxx;
                            *((INT *)s)^=tmp;	
                        }
                        else {
                            *((INT *)s)=tmp;	
                            s+=G_maxx;
                            *((INT *)s)=tmp;	
                        }
                        s+=G_maxx;
    			    }
                    break;
            }
		}
		else {
            switch (G.size) {
                case 1 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
        			for (j=0;j<G_fonthigh;j++) {    /* if set */
         				*s=0;
                        s+=G_maxx;
        			}
                    break;
                case 2 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
        			for (j=0;j<G_fonthigh;j++) {    /* if set */
         				*((INT *)s)=0;
                        s+=G_maxx;
        			}
                    break;
                case 3 :
					s=t+x+(y*G_maxx);			/* get pos on screen */
        			for (j=0;j<G_fonthigh*2;j++) {    /* if set */
         				*((INT *)s)=0;
                        s+=G_maxx;
        			}
                    break;
			}
		}
	}
	i=getpixel(0,0);
	putpixel(0,0,col);
	putpixel(0,0,i);
}
//__________________________________________________________________________
void prat(INT x,INT y,CHAR *fmt, ... )
{
    UCHAR str[140],*s;
    va_list ap;

    va_start(ap,fmt);
	 vsprintf(str,fmt,ap);
    va_end(ap);

    s=str;
    while (*s) {
        outch(x,y,*(s++),G.attr);
		if (G.size==1) x++; else x+=2;
    }
}
void pratc(INT x,INT y,INT col,CHAR *fmt, ... )
{
    UCHAR str[140],*s;
    va_list ap;
    UCHAR ts=G.size;

    va_start(ap,fmt);
	 vsprintf(str,fmt,ap);
    va_end(ap);

    s=str;
    if (y>24) G.size=1;
    while (*s) {
		outch(x,y,*(s++),col<<8);
		if (G.size==1) x++; else x+=2;
    }
    G.size=ts;
}
//___________________________________________________________________________
void flipattr(INT x,INT y,INT num)
{
    INT ta=G.attr;

    G.attr&=0x0700;

	y*=2;
    if (y<400) {
        setwritemode(1);
        setcolor(14);
        rectangle(x,y,(x+num*8*((G.size>1)+1))-1,y+(16*((G.size==3)+1))-1);
        setwritemode(0);
        if (G_coordson) {
            pratc(53,29,11,"%02d",G_msex/8+1);
            pratc(63,29,11,"%02d",G_msey/8+1);
        }
    }
    else {
        setwritemode(1);
        setcolor(14);
        rectangle(x,y,x+7,y+15);
        setwritemode(0);
        if (G_coordson) {
            pratc(53,29,11,"  ");
            pratc(63,29,11,"  ");
        }
    }
    G.attr=ta;
}
//___________________________________________________________________________
CHAR *inputln(void)
{
    INT xit=0,oldxpos=G_msex;
    INT k;
    INT i,j;
    static CHAR inbuf[81];
	INT x=(G_msex/8);
	INT y=(G_msey/8);
    INT curpos=0;
    INT ta;

    G.attr|=0x0800;
    flipattr(G_msex,G_msey,1);
    while (!xit) {
        flipattr(G_msex,G_msey,1);
        if (keyhit()) {
            switch(k=getkey()) {  
                case LEFT :
					if (G.size==1) setmousexto(G_msex-8); else setmousexto(G_msex-16);
                    break;
                case RGT :
					if (G.size==1) setmousexto(G_msex+8); else setmousexto(G_msex+16);
                    break;
                case BKSP :
                    if (curpos>0) {
                        if (G.size==1) setmousexto(G_msex-8); else setmousexto(G_msex-16);
                        ta=G.attr;
                        G.attr=0;
                        prat(G_msex/8,G_msey/8," ");
                        G.attr=ta;
                        curpos--;
                    }
                    break; 
                case ESC :
                    setmousexto(x*8);
                    setmouseyto(y*8);
                    ta=G.attr;
                    G.attr=0;
                    for (i=0;i<curpos;i++) prat(x+i,y," ");
                    G.attr=ta;
                    xit=2;
                    break;
                case LF :
                case CR :
                    if (G.size<3) setmouseyto(G_msey+8); else setmouseyto(G_msey+16);
                    setmousexto(oldxpos);
                    xit=1;
                    break;
                default :
                    if ((k>31)&&(k<=127)) {
                        inbuf[curpos++]=k;
                        prat(G_msex/8,G_msey/8,"%c",k);
                        if (G.size==1) setmousexto(G_msex+8); else setmousexto(G_msex+16);
                    }
            }
        }
        if (mousestat(8)) xit=1;
        flipattr(G_msex,G_msey,1);
    }
    flipattr(G_msex,G_msey,1);
    inbuf[curpos]=0;
    if ((xit==1)&&(curpos>0)) return(inbuf);
    return(NULL);
}
//void cursor(INT x,INT y,INT num,INT type)
//{
//	 static INT onoff=(-1);
//    if (onoff==type) return;
//
//    setwritemode(1);
//    switch (type) {
//        case (-1) :
//            setcolor(11+onoff);
//            rectangle(x*8,y*16,((num+x+((G.size>1)))*8)-1,((y+((G.size==3)+1))*16)-1);
//            onoff=type;
//            break;
//        case 0 :
//            if (onoff==1) {
//                setcolor(11+onoff);
//                rectangle(x*8,y*16,((num+x+((G.size>1)))*8)-1,((y+((G.size==3)+1))*16)-1);
//            }
//            onoff=type;
//            setcolor(11+onoff);
//            rectangle(x*8,y*16,((num+x+((G.size>1)))*8)-1,((y+((G.size==3)+1))*16)-1);
//            break;
//        default :
//            type=1;
//            if (onoff==0) {
//                setcolor(11+onoff);
//                rectangle(x*8,y*16,((num+x+((G.size>1)))*8)-1,((y+((G.size==3)+1))*16)-1);
//            }
//            onoff=type;
//            setcolor(11+onoff);
//            rectangle(x*8,y*16,((num+x+((G.size>1)))*8)-1,((y+((G.size==3)+1))*16)-1);
//            break;
//    }
//    setwritemode(0);
//}
INT keyhit(void) 
{
    return(kbhit()||G_kpeek);
}
//INT getkey(void) 
//{
//    INT k;
//    if (G_kpeek) {
//        k=G_kpeek;
//        G_kpeek=0;
//        return(k);
//    }
//    if (!(k=getch())) k=0-getch();
//    return(k);
//}
INT peekkey(void) 
{
    INT k;
    if (!(k=getch())) k=0-getch();
    G_kpeek=k;
    return(k);
}
INT chkfmt(CHAR t,CHAR k)
{
    if (t=='K') return(1);
    if (k<32) return(0);
    switch(toupper(t)) {
        case 'F' :                      // Format type
            k=toupper(k);
            if (k=='A') return(1);
            if (k=='K') return(1);
            if (k=='P') return(1);
            if (k=='X') return(1);
            if (k=='Z') return(1);
            if (k=='U') return(1);
            if (k=='L') return(1);
            if (k=='M') return(1);
            if (k=='W') return(1);
            if (k=='D') return(1);
            if (k=='T') return(1);
            if (k=='9') return(1);
            break;
        case 'A' :                      // Alpha
            if (isalpha(k)) return(1);
            if (k==' ') return(1);
            break;
        case 'P' :                      // Password
        case 'X' :                      // Alpha-Numeric with spaces
            if (isalnum(k)) return(1);
            if (ispunct(k)) return(1);
            if (k==' ') return(1);
            break;
        case 'Z' :                      // Alpha-Numeric without spaces
            if (isalnum(k)) return(1);
            break;
        case 'U' :                      // Uppercase with spaces
            if (isupper(k)) return(1);
            if (k==' ') return(1);
            break;
        case 'L' :                      // Lowercase with spaces
            if (islower(k)) return(1);
            if (k==' ') return(1);
            break;
        case '9' :                      // Numeric
            if (isdigit(k)) return(1);
            break;
        case 'W' :                      // Weight
            if (isdigit(k)) return(1);
            break;
        case 'M' :                      // Money
            if (isdigit(k)) return(1);
            break;
        case 'D' :                      // Date
            if (isdigit(k)) return(1);
            if (k=='-') return(1);
            if (k=='/') return(1);
            break;
        case 'T' :                      // Time
            if (isdigit(k)) return(1);
            if (k==':') return(1);
            break;
    }
    return(0);
}
INT inputstr(INT x,INT y,CHAR *s,INT l,CHAR t)
{
    CHAR tmp[81];
    INT curpos;
    INT xit=0,changed=0;
    INT moved=0;
    INT i,j,m;
    CHAR k;
    static insert=0;

    curpos=strlen(s);
    strcpy(tmp,s);
    if (l>80)l=80;
    
    cursor(x+curpos,y,1,insert);
    while (!xit) {
        if (keyhit()) {
            cursor(x+curpos,y,1,(-1));
            switch(k=getkey()) {
                case LEFT :
                    if (curpos>0) curpos--;
                    moved=1;
                    break;

                case RGT :
                    if (curpos<strlen(tmp)) curpos++;
                    moved=1;
                    break;

                case HOME :
                    curpos=0;
                    moved=1;
                    break;

                case END :
                    curpos=strlen(tmp);
                    moved=1;
                    break;

                case INS :
                    insert^=1;
                    moved=1;
                    break;

                case UP :
                    xit=1;
                    break;

                case DOWN :
                case CR :
                case LF :
                    xit=1;
                    break;

                case ESC :
                    changed=0;
                    curpos=strlen(s);
                    strcpy(tmp,s);
                    xit=1;
                    break;

                case DEL :
                    if (curpos<strlen(tmp)) {
                        for (i=curpos+1;i<=strlen(tmp);i++)
                            tmp[i-1]=tmp[i];
                        changed=1;
                        moved=1;
                    }
                    break;

                case BKSP :
                    if (curpos>0) {
                        curpos--;
                        if (insert) {
                            for (i=curpos+1;i<=strlen(tmp);i++)
                                tmp[i-1]=tmp[i];
                        }
                        else {
                            tmp[curpos]=' ';
                        }
                        changed=1;
                        moved=1;
                    }
                    break;

                case TAB :
                    if (chkfmt(t,' ')) {
                        if (!moved) {
                            tmp[0]=0;
                            curpos=0;
                            moved=1;
                        }
                        k=' ';
                        m=TABSTOP-(curpos%TABSTOP);
                        for (j=0;j<m;j++) {
                            if (insert) {
                                for (i=strlen(tmp);i>=curpos;i--) tmp[i+1]=tmp[i];
                                tmp[curpos]=k;
                                if (strlen(tmp)==l) {
                                    xit=1;
                                    j=m;
                                }
                            }
                            else {
                                if (curpos==strlen(tmp)) {
                                    tmp[curpos++]=k;
                                    tmp[curpos]=0;
                                    if (curpos==l) {
                                        xit=1;
                                        j=m;
                                    }
                                }
                                else {
                                    tmp[curpos++]=k;
                                }
                            }
                            changed=1;
                        }
                    }
                    break;

                default :
                    if (chkfmt(t,k)) {
                        if (!moved) {
                            tmp[0]=0;
                            curpos=0;
                            moved=1;
                        }
                        if (insert) {
                            for (i=strlen(tmp);i>=curpos;i--) tmp[i+1]=tmp[i];
                            tmp[curpos]=k;
                            curpos++;
                            if (strlen(tmp)==l) xit=1;
                        }
                        else {
                            if (curpos==strlen(tmp)) {
                                tmp[curpos++]=k;
                                tmp[curpos]=0;
                                if (curpos==l) xit=1;
                            }
                            else {
                                tmp[curpos++]=k;
                            }
                        }
                        changed=1;
                    }
                    else {
                        sound(500);
                        delay(100);
                        nosound();
                    }
            }
            if (t!='P') {
                prat(x,y,"%-*.*s",l,l,tmp);
            }
            else {
                for (i=0;i<l;i++) prat(x+i,y,"*");
            }
            cursor(x+curpos,y,1,insert);
        }
        if (mousestat(8)) {
            xit=1;
        }
    }
    cursor(x+curpos,y,1,(-1));
    if (changed) {
        strcpy(s,tmp);
        return(1);
    }
    return(0);
}



