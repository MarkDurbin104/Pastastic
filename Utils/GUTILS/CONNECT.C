#include <graphics.h>
#include <dos.h>
#include <mem.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "mouse.h"
int G_maxx,G_maxy;

char G_cols[9][7];

int grafix(void)
{
    int gd = VGA;
	int gm = VGAHI;
    int err;

	err=registerfarbgidriver(EGAVGA_driver_far);
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
		return(0);
	}
    initgraph(&gd,&gm,"");
    err=graphresult();
	if (err<0) {
		printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
	}
    G_maxx=getmaxx();
    G_maxy=getmaxy();
    return(1);
}
int place(int cs,int col)
{
    int i,j=G_msex/cs,k;
    if (G_cols[j][6]!=0) return(0);
    for (i=0;i<7;i++) {
        if (G_cols[j][i]==0) {
            G_cols[j][i]=col;
            setfillstyle(1,col);
            floodfill(j*cs+cs/2,cs+cs/2,15);
            delay(5);
            for (k=1;k<(8-i);k++) {
                setfillstyle(1,0);
                floodfill(j*cs+cs/2,(k-1)*cs+cs/2,15);
                setfillstyle(1,col);
                floodfill(j*cs+cs/2,k*cs+cs/2,15);
                sound(8000);
                delay(2);
                nosound();
                delay(10);
            }
            return(1);
        }
    }
    return(0);
}
void cursor(int cs,int col)
{
    if (!col) {
        setcolor(col);
        setfillstyle(1,col);
        circle(G_msex+cs,G_msey+cs,cs-2);
        floodfill(G_msex+cs,G_msey+cs,col);
    }
    else {
        setcolor(15);
        setfillstyle(1,col);
        circle(G_msex+cs,G_msey+cs,cs-2);
        floodfill(G_msex+cs,G_msey+cs,15);
    }
}
void win(int i)
{
    sound(500+i*2500);
    delay(5+i*15);
}
int checkh(int x,int y)
{
    char c;
    int cs,i;
    if ((G_cols[x][y]==0)||(x>5)) return(0);
    c=G_cols[x][y];
    if (G_cols[x+1][y]!=c) return(0);
    if (G_cols[x+2][y]!=c) return(0);
    if (G_cols[x+3][y]!=c) return(0);
    cs=G_maxy/8;
    i=0;
    while (!kbhit()) {
        setfillstyle(1,c&7+i);
        floodfill( x   *cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill((x+1)*cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill((x+2)*cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill((x+3)*cs+cs/2,(7-y)*cs+cs/2,15);
        i^=8;
        win(i==8);
    }
    return(1);
}
int checkv(int x,int y)
{
    char c;
    int cs,i;
    if ((G_cols[x][y]==0)||(y>3)) return(0);
    c=G_cols[x][y];
    if (G_cols[x][y+1]!=c) return(0);
    if (G_cols[x][y+2]!=c) return(0);
    if (G_cols[x][y+3]!=c) return(0);
    cs=G_maxy/8;
    i=0;
    while (!kbhit()) {
        setfillstyle(1,c&7+i);
        floodfill(x*cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill(x*cs+cs/2,(6-y)*cs+cs/2,15);
        floodfill(x*cs+cs/2,(5-y)*cs+cs/2,15);
        floodfill(x*cs+cs/2,(4-y)*cs+cs/2,15);
        i^=8;
        win(i==8);
    }
    return(1);
}
int checkdu(int x,int y)
{
    char c;
    int cs,i;
    if ((G_cols[x][y]==0)||(y>3)||(x>5)) return(0);
    c=G_cols[x][y];
    if (G_cols[x+1][y+1]!=c) return(0);
    if (G_cols[x+2][y+2]!=c) return(0);
    if (G_cols[x+3][y+3]!=c) return(0);
    cs=G_maxy/8;
    i=0;
    while (!kbhit()) {
        setfillstyle(1,c&7+i);
        floodfill( x   *cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill((x+1)*cs+cs/2,(6-y)*cs+cs/2,15);
        floodfill((x+2)*cs+cs/2,(5-y)*cs+cs/2,15);
        floodfill((x+3)*cs+cs/2,(4-y)*cs+cs/2,15);
        i^=8;
        win(i==8);
    }
    return(1);
}
int checkdd(int x,int y)
{
    char c;
    int cs,i;
    if ((G_cols[x][y]==0)||(y<3)||(x>5)) return(0);
    c=G_cols[x][y];
    if (G_cols[x+1][y-1]!=c) return(0);
    if (G_cols[x+2][y-2]!=c) return(0);
    if (G_cols[x+3][y-3]!=c) return(0);
    cs=G_maxy/8;
    i=0;
    while (!kbhit()) {
        setfillstyle(1,c&7+i);
        floodfill( x   *cs+cs/2,(7-y)*cs+cs/2,15);
        floodfill((x+1)*cs+cs/2,(8-y)*cs+cs/2,15);
        floodfill((x+2)*cs+cs/2,(9-y)*cs+cs/2,15);
        floodfill((x+3)*cs+cs/2,(10-y)*cs+cs/2,15);
        i^=8;
        win(i==8);
    }
    return(1);
}
int checkwin(void)
{
    int i,j;
    for (i=0;i<9;i++) {
        for (j=0;j<7;j++) {
            if (checkh(i,j)) return(1);
            if (checkv(i,j)) return(1);
            if (checkdu(i,j)) return(1);
            if (checkdd(i,j)) return(1);
        }
    }
    return(0);
}
int main(void)
{
    int cs,i,j;
    int col,xit;
    int count;

    grafix();
    cs=G_maxy/8;
    setupmouse(0,0,0,cs*8,0,1,0);
    do {
        xit=0;
        count=0;
        cleardevice();
        col=12;
        memset(G_cols,0,sizeof(G_cols));
        setfillstyle(1,1);
        setcolor(15);
        bar(0,cs,cs*9,G_maxy);
        rectangle(0,cs,cs*9,G_maxy);
        setfillstyle(1,0);
        for (i=0;i<9;i++) {
            for (j=1;j<8;j++) {
                circle(i*cs+cs/2,j*cs+cs/2,(cs*3)/8);
                floodfill(i*cs+cs/2,j*cs+cs/2,15);
            }
        }
        cursor(cs/2,col);
        while ((!kbhit())&&(!xit)) {
            if (mousestat(cs)) {
                cursor(cs/2,0);
                mousetrap(cs);
                if (G_mseb) {
                    if (place(cs,col)) {
                        if (col==12) col=14; else col=12;
                        count++;
                    }
                    if (checkwin()) {
                        xit=1;
                    } else {
                        if (count==63) {
                            win(0);
                            while (!kbhit());
                        }
                    }
                }
                cursor(cs/2,col);
            }
        }
        nosound();
    } while (getch()!=27);
    closegraph();
    return(0);
}

