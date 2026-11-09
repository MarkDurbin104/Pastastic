#define VECTOR_C
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <memory.h>
#include <math.h>
#include <graphics.h>

#include "types.h"
#include "duct.h"
#include "feature.h"

#define EASYTEST

#ifdef EASYTEST
#define ZOOM 6
#define ORIGX (-50)
#define ORIGY (450)
#else
#define ZOOM 3
#define ORIGX (-550)
#define ORIGY (850)
#endif
//============================================================================
//F grafix
//S switch the screen into graphics mode
//D switch the screen into graphics mode using the borland 
//D graphics functions
void grafix(void)
{
    int GraphDriver = DETECT;                 /* Request auto-detection       */
    int GraphMode;
    int ErrorCode;
    initgraph( &GraphDriver, &GraphMode, "d:\\bc45\\bgi" );
    ErrorCode = graphresult();            /* Read result of initialization*/
    if( ErrorCode != grOk ){              /* Error occured during init    */
        printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
        exit( 1 );
    }
}
//===========================================================================
//F rect
//S draw a rotated rectangle
//D draw a rectangle rotated by a number of degrees
//P The X co-ord of one corner of the (unrotated) rectangle
//P The Y co-ord of one corner of the (unrotated) rectangle
//P The X co-ord of the opposite corner of the (unrotated) rectangle
//P The Y co-ord of the opposite corner of the (unrotated) rectangle
//P the number of degrees to rotate
void rect(NUMB x,NUMB y,NUMB x1,NUMB y1,NUMB angle)
{
    NUMB dx;      // centre to corner delta x and delta y
    NUMB dy; 
    NUMB cx;      // centre x and y co-ordinates
    NUMB cy; 
    NUMB dist;    // distance between center and corner
    NUMB cornang; // angle between center and corner

    if (x>x1) { dx=x; x=x1; x1=dx; } // make sure x,y is left,top
    if (y>y1) { dy=y; y=y1; y1=dy; } // and x1,y1 is right,bottom

    dx=(x1-x)/2;                // calc delta x
    dy=(y1-y)/2;                // calc delta y
    cx=x+dx;                    // calc centre x
    cy=y+dy;                    // calc centre y
    dist=sqrt((dx*dx)+(dy*dy)); // calc length from center to corner
    cornang=atan(dy/dx);        // calc angle (in radians) from center to corner

    angle*=(M_PI/180);          // convert angle to radians

    x=cos(angle-cornang)*dist;  // first corner
    y=sin(angle-cornang)*dist;
    moveto(cx+x,cy+y);
    lineto(cx+cos(angle+cornang)*dist,cy+sin(angle+cornang)*dist); // second
    angle+=M_PI;                                          // add 180 degrees
    lineto(cx+cos(angle-cornang)*dist,cy+sin(angle-cornang)*dist); // third
    lineto(cx+cos(angle+cornang)*dist,cy+sin(angle+cornang)*dist); // fourth
    lineto(cx+x,cy+y);                                     // back to first
}

//===========================================================================
//F drawfeats
//S draw features
//D draw the features and duct on the screen in graphics mode
//D multiply the co-ords by "ZOOM" and offset bu ORIGX and ORIGY
//P TRUE if bounds are to be drawn
void drawfeats(BOOL withbounds)
{
    INT i;
    char tmp[10];
    NUMB x,y,fidx,didx;
    COORD coord[2];
    // each feature
    for (fidx=0;fidx<NUMFEATURE;fidx++) {
        switch (FEATURETYPE(fidx)) { // get type
            case NAP_FEATURE :
                setcolor(14);
                x=FEATUREXCOORD(fidx);
                y=FEATUREYCOORD(fidx);
                rect(ORIGX+((x-3)*ZOOM),ORIGY-((y-2)*ZOOM),ORIGX+((x+3)*ZOOM),ORIGY-((y+2)*ZOOM),FEATUREANGLE(fidx));
                sprintf(tmp,"%d",FEATUREID(fidx));
                settextstyle(2,0,2);
                settextjustify(1,1);
                outtextxy(ORIGX+((x+FEATUREBOUND(fidx))*ZOOM),ORIGY-((y-FEATUREBOUND(fidx))*ZOOM),tmp);
                if (withbounds) {
                    setcolor(4);
                    circle(ORIGX+(x*ZOOM),ORIGY-(y*ZOOM),FEATUREBOUND(fidx)*ZOOM);
                }
                break;
            case LINE_FEATURE :
                setcolor(15);
                x=FEATUREXCOORD(fidx);
                y=FEATUREYCOORD(fidx);
                moveto(ORIGX+(x*ZOOM),ORIGY-(y*ZOOM));
                for (i=0;i<FEATURENUMC(fidx);i++) {
                    if (withbounds) setcolor((i%7)+8);
                    x=FEATURELXCOORD(fidx,i);
                    y=FEATURELYCOORD(fidx,i);
                    lineto(ORIGX+(x*ZOOM),ORIGY-(y*ZOOM));
                }
                break;
        }
    }
    // each duct
    for (didx=0;didx<NUMDUCT;didx++) {
        if (DUCTVISIB(didx)) {
            // draw it
            memcpy(&coord[0],get_feat_coords(DUCTFROM(didx),&x),sizeof(COORD));
            memcpy(&coord[1],get_feat_coords(DUCTTO  (didx),&x),sizeof(COORD));
            if (withbounds) {
                setcolor(4);
                line(ORIGX+((coord[0].x+DUCTBOUND(didx))*ZOOM),ORIGY-((coord[0].y+DUCTBOUND(didx))*ZOOM),ORIGX+((coord[1].x+DUCTBOUND(didx))*ZOOM),ORIGY-((coord[1].y+DUCTBOUND(didx))*ZOOM));
                line(ORIGX+((coord[0].x-DUCTBOUND(didx))*ZOOM),ORIGY-((coord[0].y-DUCTBOUND(didx))*ZOOM),ORIGX+((coord[1].x-DUCTBOUND(didx))*ZOOM),ORIGY-((coord[1].y-DUCTBOUND(didx))*ZOOM));
            }
            setcolor(11);
            line(ORIGX+(coord[0].x*ZOOM),ORIGY-(coord[0].y*ZOOM),ORIGX+(coord[1].x*ZOOM),ORIGY-(coord[1].y*ZOOM));
        }
    }
}
//===========================================================================
//F get_feature_info
//S get the feature information
//D collect the feature information from a flat file
void get_feature_info(void)
{
#ifdef EASYTEST
    G_numbfeature=9;
    G_features=malloc((G_numbfeature)*sizeof(FEATURE));
    G_features[0].fnum=1;
    G_features[0].coord.x=20;
    G_features[0].coord.y=20;
    G_features[0].type=NAP_FEATURE;
    G_features[0].bound=6;
    G_features[0].angle=0;

    G_features[1].fnum=2;
    G_features[1].coord.x=100;
    G_features[1].coord.y=20;
    G_features[1].type=NAP_FEATURE;
    G_features[1].bound=6;
    G_features[1].angle=0;

    G_features[2].fnum=3;
    G_features[2].coord.x=20;
    G_features[2].coord.y=40;
    G_features[2].type=NAP_FEATURE;
    G_features[2].bound=6;
    G_features[2].angle=0;

    G_features[3].fnum=4;
    G_features[3].coord.x=100;
    G_features[3].coord.y=40;
    G_features[3].type=NAP_FEATURE;
    G_features[3].bound=6;
    G_features[3].angle=0;

    G_features[4].fnum=5;
    G_features[4].coord.x=80;
    G_features[4].coord.y=30;
    G_features[4].type=NAP_FEATURE;
    G_features[4].bound=6;
    G_features[4].angle=0;

    G_features[5].fnum=6;
    G_features[5].coord.x=40;
    G_features[5].coord.y=30;
    G_features[5].type=NAP_FEATURE;
    G_features[5].bound=6;
    G_features[5].angle=0;

    G_features[6].fnum=7;
    G_features[6].coord.x=65;
    G_features[6].coord.y=38;
    G_features[6].type=NAP_FEATURE;
    G_features[6].bound=6;
    G_features[6].angle=0;

    G_features[7].fnum=8;
    G_features[7].coord.x=20;
    G_features[7].coord.y=30;
    G_features[7].type=NAP_FEATURE;
    G_features[7].bound=6;
    G_features[7].angle=0;

    G_features[8].fnum=9;
    G_features[8].coord.x=55;
    G_features[8].coord.y=38;
    G_features[8].type=NAP_FEATURE;
    G_features[8].bound=6;
    G_features[8].angle=0;
#else
    INT i,j;
    COORD pnts[5];
    G_numbfeature=90;
    G_features=malloc((G_numbfeature+10)*sizeof(FEATURE));
    for (j=0;j<G_numbfeature/9;j++) {
        for (i=0;i<9;i++) {
            G_features[i+j*9].fnum=i+j*9;
            G_features[i+j*9].coord.x=200+((j%5)*40)+(i%3)*6;
            G_features[i+j*9].coord.y=200+((j/5)*40)+(i/3)*6;
            G_features[i+j*9].type=NAP_FEATURE;
            G_features[i+j*9].bound=5;
            G_features[i+j*9].angle=0;
        }
    }
#endif
}
//===========================================================================
//F get_duct_info
//S get the duct information
//D collect the duct information from a flat file
void get_duct_info(void)
{
#ifdef EASYTEST
    G_numbducts=8;
    G_ducts=malloc(G_numbducts*sizeof(DUCT));
    G_ducts[0].from=1;
    G_ducts[0].to=2;
    G_ducts[0].bound=1;
    G_ducts[0].visib=TRUE; 
    G_ducts[1].from=3;
    G_ducts[1].to=4;
    G_ducts[1].bound=1;
    G_ducts[1].visib=TRUE; 
    G_ducts[2].from=4;
    G_ducts[2].to=5;
    G_ducts[2].bound=1;
    G_ducts[2].visib=TRUE; 
    G_ducts[3].from=2;
    G_ducts[3].to=3;
    G_ducts[3].bound=1; 
    G_ducts[3].visib=TRUE;
    G_ducts[4].from=1;
    G_ducts[4].to=6;
    G_ducts[4].bound=1; 
    G_ducts[4].visib=TRUE;
    G_ducts[5].from=5;
    G_ducts[5].to=7;
    G_ducts[5].bound=1; 
    G_ducts[5].visib=TRUE;
    G_ducts[6].from=6;
    G_ducts[6].to=8;
    G_ducts[6].bound=1; 
    G_ducts[6].visib=TRUE;
    G_ducts[7].from=7;
    G_ducts[7].to=9;
    G_ducts[7].bound=1; 
    G_ducts[7].visib=TRUE;
#else
    INT i;
    G_numbducts=G_numbfeature;
    G_ducts=malloc(G_numbducts*sizeof(DUCT));
    for (i=0;i<G_numbducts;i++) {
        G_ducts[i].from=i;
        G_ducts[i].to=i+1;
        G_ducts[i].bound=1;
        G_ducts[i].visib=TRUE; 
    }
    G_ducts[i-1].from=0;
    G_ducts[i-1].to  =1; 
    G_ducts[44].to   =89;
#endif
}
//****************************************************************************
int main(void)
{
    get_feature_info();
    get_duct_info();
    grafix();
    drawfeats(1);
    getch();
    resolve_nap_conflict();
    clearviewport();
    drawfeats(1);
    getch();
    resolve_duct_nap_conflicts();
    clearviewport();
    drawfeats(1);
    getch();
    set_feature_angles();
    clearviewport();
    drawfeats(1);
    getch();
    clearviewport();
    drawfeats(0);
    getch();
    closegraph();
    free(G_ducts);
    free(G_features);
    return 1;
}


//===========================================================================
//                           End of file
//===========================================================================
