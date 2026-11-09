//=============================== QDIAG.C =================================
#define QDIAG_C

#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <values.h>
#include <graphics.h>

#include "qdiag.h"

//============================================================================
//F grafix
//S switch the screen into graphics mode
//D switch the screen into graphics mode using the borland 
//D graphics functions
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

POINT asignp(long x,long y)
{
    POINT a;
    XVAL(a)=x;
    YVAL(a)=y;
    return a;
}
double sine(int angle)
{
    double sval;
    while (angle<0) angle+=360;
    while (angle>=360) angle-=360;
    if ((angle%180)>=90)
        sval=((double)(G_sintab[90-(angle%90)])/SINMULT);
    else
        sval=((double)(G_sintab[angle%90])/SINMULT);
    if (angle<180) return sval;
    return -sval;
}
double cosine(int angle)
{
    return sine(angle+90);
}
long distance(POINT a,POINT b)
{
    long dx;
    long dy;
    dx=XDIFF(a,b);
    dy=YDIFF(a,b);
    if ((dx==0)&&(dy==0)) return 0;
    return(sqrt((dx*dx)+(dy*dy)));
}
int angle(POINT a,POINT b)
{
    long dx;
    long dy;
    double ang;
    dx=XDIFF(a,b);
    dy=YDIFF(a,b);
    if (dy!=0) {
        ang=(atan((double)dx/(double)dy)*180.0)/M_PI;
        if (dy<0) ang+=180;
        if (ang<0) ang+=360;
    } else {
        ang=90+180*(dx<0);
    }
    return(ang);
}
POINT rotate(POINT a,POINT rel,int rot)
{
    POINT b;
    double dist;
    double ang;
    dist=distance(rel,a);
    ang=angle(rel,a);
    XVAL(b)=XVAL(rel)+  sine(ang+rot)*dist;
    YVAL(b)=YVAL(rel)+cosine(ang+rot)*dist;
    return b;
}
POINT move(POINT a,long dist,int ang)
{
    POINT b;
    XVAL(b)=XVAL(a)+  sine(ang)*dist;
    YVAL(b)=YVAL(a)+cosine(ang)*dist;
    return b;
}
void putpoly(POINT *pnts,int nump)
{
    POINT s;
    if (nump<2) return;
    s=*pnts;
    moveto(XVAL((*pnts)),YVAL((*pnts)));
    nump--;
    while (nump) {
        nump--;
        pnts++;
        lineto(XVAL((*pnts)),YVAL((*pnts)));
    }
    lineto(XVAL(s),YVAL(s));
}
void rotpoly(POINT *pnts,int nump,POINT c,int rot)
{
    POINT s,p;
    if (nump<2) return;
    s=p=rotate(*pnts,c,rot);
    moveto(XVAL(p),YVAL(p));
    nump--;
    while (nump) {
        nump--;
        pnts++;
        p=rotate(*pnts,c,rot);
        lineto(XVAL(p),YVAL(p));
    }
    lineto(XVAL(s),YVAL(s));
}
void movpoly(POINT *pnts,int nump,long dist,int ang)
{
    POINT s,p;
    if (nump<2) return;
    s=p=move(*pnts,dist,ang);
    moveto(XVAL(p),YVAL(p));
    nump--;
    while (nump) {
        nump--;
        pnts++;
        p=move(*pnts,dist,ang);
        lineto(XVAL(p),YVAL(p));
    }
    lineto(XVAL(s),YVAL(s));
}
int main(void)
{
    POINT c;
    POINT pnts[4];
    int i,j,k=0;
    pnts[0]=asignp(300,220);
    pnts[1]=asignp(340,220);
    pnts[2]=asignp(340,260);
    if (grafix()) {
        while (!kbhit()) {
            k++;
            for (j=0;j<720;j++) {
                c=asignp(j*2,240-sine(j/2)*140);
                for (i=0;i<360;i++) { setcolor(((i/22+k)%15)+1); rotpoly(pnts,2,c,i+j*4); }
                if (kbhit()) break;
            }
            for (j=0;j<1440;j++) {
                c=asignp(320+cosine(j)*320,j/2);
                for (i=0;i<360;i++) { setcolor(((i/45+k)%15)+1); rotpoly(pnts,2,c,-(i+j*4)); }
                if (kbhit()) break;
            }
        }
        getch();
        closegraph();
    }
	return 0;
}
//===============================END OF FILE=================================
