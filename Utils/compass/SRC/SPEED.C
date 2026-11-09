#include <stdio.h>
#include <math.h>
#include <time.h>

typedef double NUMB;
typedef struct {
    NUMB x;
    NUMB y;
} COORD;

NUMB distance(COORD *a,COORD *b)
{
    NUMB dx=b->x-a->x;
    NUMB dy=b->y-a->y;
    return(sqrt((dx*dx)+(dy*dy)));
}
NUMB angle(COORD *a,COORD *b)
{
    NUMB dy=b->y-a->y;                          // calculate delta y
    NUMB angle;
    if (dy==0) return 90+((b->x-a->x)>0)*180;
    angle=atan((b->x-a->x)/dy)*180/M_PI;   // calculate the angle
    if (dy<0) angle+=180;
    if (angle<0) angle+=360;
    return(angle);
}
void move_point(COORD *sp,NUMB angl,NUMB dist,COORD *point)
{
    point->x=sp->x+(sin(angl*(M_PI/180))*dist);
    point->y=sp->y+(cos(angl*(M_PI/180))*dist);
}

int main(void)
{
    time_t s,e;
    COORD a,b;
    NUMB i,j,ang,d;

    s=time(NULL);
    b.x=110.0;
    b.y=110.0;
    for (i=0;i<10;i+=0.01) {
        for (j=0;j<10;j+=0.01) {
            a.x=i;
            a.y=j;
            d=distance(&a,&b);
            ang=angle(&a,&b);
//            move_point(&b,ang,d,&a);
        }
    }
    e=time(NULL);
    printf("%ld Seconds",e-s);
    return 1;
}
