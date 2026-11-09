#include <stdio.h>
#include <math.h>
#include <time.h>

#define NUMLOOK 10000
char G_lookup[NUMLOOK];

int GetAngle(int x,int y,int x1,int y1)
{
    int dx,dy;

    if ((x==x1)&&(y==y1)) return 0;
    dx=x1-x;
    dy=y1-y;
    return 180-(int)(atan2(dx,dy)*(180.0/M_PI));
}
int NewGetAngle(int x,int y,int x1,int y1)
{
    int dx,dy;
    int ax,ay;
    dx=x1-x; if (dx<0) ax=0-dx; else ax=dx;
    dy=y1-y; if (dy<0) ay=0-dy; else ay=dy;
    if (!dx) {
        if (dy<=0) {
            return 0;
        } else {
            return 180;
        }
    } else if (dx<0) {
        if (!dy) {
            return 270;
        } else if (dy<0) {
            if (ax<ay) {
                return 360-G_lookup[(ax*NUMLOOK)/ay];
            } else {
                return 270+G_lookup[(ay*NUMLOOK)/ax];
            }
        } else {
            if (ax>ay) {
                return 270-G_lookup[(ay*NUMLOOK)/ax];
            } else {
                return 180+G_lookup[(ax*NUMLOOK)/ay];
            }
        }
    } else {
        if (!dy) {
            return 90;
        } else if (dy>0) {
            if (ax<ay) {
                return 180-G_lookup[(ax*NUMLOOK)/ay];
            } else {
                return 90+G_lookup[(ay*NUMLOOK)/ax];
            }
        } else {
            if (ax>ay) {
                return 90-G_lookup[(ay*NUMLOOK)/ax];
            } else {
                return 0+G_lookup[(ax*NUMLOOK)/ay];
            }
        }
    }
}

int main(void)
{
    time_t s,e1,e2;
    int i=0,a,j;
    for (i=0;i<NUMLOOK;i++) {
        G_lookup[i]=(char)(atan2((double)i,(double)NUMLOOK)*(180.0/M_PI));
    }
    i=0;
    s=time(NULL);
    for (i=0;i<32000;i++) {
        for (j=0;j<200;j++) NewGetAngle(100,100,j,0);
    }
    e1=time(NULL);
    for (i=0;i<32000;i++) {
        for (j=0;j<200;j++) GetAngle(100,100,j,0);
    }
    e2=time(NULL);
    printf("Time NewGetAngle %ld  GetAngle %ld\n",e1-s,e2-e1);
    return 1;
}
