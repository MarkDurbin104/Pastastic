#ifdef DOS_MODE
#include <graphics.h>
#else
int G_x=0;
int G_y=0;
void rectangle(int x,int y,int x1,int y1) {
    printf("1%05d%05d%05d%05d\n",x,y,x1,y1);
}
void line(int x,int y,int x1,int y1) {
    printf("2%05d%05d%05d%05d\n",x,y,x1,y1);
}
void outtextxy(int x,int y,char *s) {
    printf("3%05d%05d%s\n",x,y,s);
}
void moveto(int x,int y) {
    G_x=x;
    G_y=y;
}
void lineto(int x,int y) {
    line(G_x,G_y,x,y);
    G_x=x;
    G_y=y;
}
void circle(int x,int y,int r) {
    printf("4%05d%05d%05d\n",x,y,r);
}
void arc(int x,int y,int sa,int ea,int r) {
    if (sa==270) {
        printf("5%05d%05d%05d%05d%05d%05d%05d%05d\n",x-r,y-r,x+r,y+r,x,y+r,x,y-r);
    } else {
        printf("5%05d%05d%05d%05d%05d%05d%05d%05d\n",x-r,y-r,x+r,y+r,x,y-r,x,y+r);
    }
}
void setcolor(int c) {
    printf("6%05d\n",c);
}
#endif
