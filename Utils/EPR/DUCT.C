//===========================================================================
// Module        : DUCT.C
// Synopsys      : resolve conflicts between features
// Description   : This module is used by the generated graphics sub-system
//               : To resolve any conflict between nodes that have been
//               : placed too close together on a diagram for easy reading
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th August 1995
//===========================================================================
// Functions     : 
//               : 
//===========================================================================
// Global Vars.  : G_ducts      G_numbducts
//               : 
//===========================================================================
// Date      Id   Modification history
//---------------------------------------------------------------------------
// 06/08/95  MJD  Initial entry
//===========================================================================

#define DUCT_C
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

#include <graphics.h>
#include <conio.h>

#include "types.h"
#include "duct.h"
#include "feature.h"

extern NUMB adjustx(NUMB x);
extern NUMB adjusty(NUMB y);
extern void drawfeats(BOOL withbounds);

//===========================================================================
//F add_duct_feature
//S place a line feature in the diagram that replaces a duct
//D place a line feature in the diagram that replaces a duct
//P index into G_ducts array
void add_duct_feature(INT didx)
{
    COORD startp;    // the line feature start point
    COORD endp;      // the line feature end point
    INT fidx;        // feature index
    NUMB dummy;
    memcpy(&startp,get_feat_coords(DUCTFROM(didx),&dummy),sizeof(COORD));
    memcpy(&endp  ,get_feat_coords(DUCTTO(didx)  ,&dummy),sizeof(COORD));
    fidx=add_feature((-1),LINE_FEATURE,&startp,DUCTBOUND(didx),1,&endp);
    FEATUREFROM(fidx)=DUCTFROM(didx);
    FEATURETO  (fidx)=DUCTTO(didx)  ;
    DUCTVISIB(didx)=FALSE;
}
NUMB distance(COORD *a,COORD *b)
{
    NUMB dx=b->x-a->x;
    NUMB dy=b->y-a->y;
    return(sqrt((dx*dx)+(dy*dy)));
}
NUMB angle(COORD *a,COORD *b)
{
    NUMB dy=b->y-a->y;                          // calculate delta y
    NUMB angle=atan((b->x-a->x)/dy)*180/M_PI;   // calculate the angle
    if (dy<0) angle+=180;
    if (angle<0) angle+=360;
    return(angle);
}
void move_point(COORD *sp,NUMB angl,NUMB dist,COORD *point)
{
    point->x=sp->x+(sin(angl*(M_PI/180))*dist);
    point->y=sp->y+(cos(angl*(M_PI/180))*dist);
}
//===========================================================================
//F resolve_duct_nap_conflicts
//S resolve duct to NAP conflicts
//D resolve duct conflicts with NAP's by moving lines that fall
//D within the bounding circles of NAP's
void resolve_duct_nap_conflicts(void)
{
}
void move_duct_centre(INT didx,INT offset)
{
    COORD interp;       // intermediate point
    COORD startp;       // start point
    COORD endp;         // end point
    COORD ductpnts[3];  // the duct x & y co-ordinates
    NUMB dangle;        // the duct angle
    NUMB f1;            // the feature index ( duct from ) 
    NUMB f2;            // the feature index ( duct to )
    NUMB dx;            // delta x
    NUMB dy;            // delta y

    memcpy(&startp,get_feat_coords(DUCTFROM(didx),&f1),sizeof(COORD));
    memcpy(&ductpnts[2],get_feat_coords(DUCTTO(didx),&f2),sizeof(COORD));
    dangle=angle(&startp,&ductpnts[2]);
    move_point(&startp,dangle,FEATUREBOUND(f1),&interp);
    move_point(&interp,dangle+90,DUCTBOUND(didx)*offset,&ductpnts[0]);
    move_point(&ductpnts[2],dangle+180,FEATUREBOUND(f2),&interp);
    move_point(&interp,dangle+90,DUCTBOUND(didx)*offset,&ductpnts[1]);

    f1=add_feature((-1),LINE_FEATURE,&startp,DUCTBOUND(didx),3,ductpnts);
    FEATUREFROM(f1)   =DUCTFROM(didx);
    FEATURETO  (f1)   =DUCTTO  (didx);
    DUCTVISIB(didx)=FALSE;
}
void space_ducts(void)
{
    INT from;
    INT to;
    INT duct;
    INT curofs=0;
    INT curdir=1;
    INT ductgroup=0;
    for (from=0;from<NUMFEATURE;from++) {
        for (to=0;to<NUMFEATURE;to++) {
            curofs=0;
            curdir=1;
            for (duct=0;duct<NUMDUCT;duct++) {
                if (DUCTVISIB(duct)
                && (((DUCTFROM(duct)==FEATUREID(from))&&(DUCTTO(duct)==FEATUREID(to)  ))
                ||  ((DUCTFROM(duct)==FEATUREID(to)  )&&(DUCTTO(duct)==FEATUREID(from)))) ) {
                    if (curofs) {
                        move_duct_centre(duct,curofs*curdir);
                    } else {
                        add_duct_feature(duct);
                        ductgroup++;
                    }
                    FEATUREGROUP(NUMFEATURE-1)=ductgroup;
                    if (curdir>0) {
                        curdir=(-1);
                        curofs++;
                    } else {
                        curdir=1;
                    }
                }
            }
        }
    }
}
//===========================================================================
//F move_point_in_line
//S move a point in a line
//D move a point in a line
//P the index of the line feature
//P the point along the line
//P the amount to move the point
//P the length of line (either side of the point) to move
void move_point_in_line(INT lidx,COORD *point,NUMB offset,NUMB range)
{
    INT i;
    INT j;
    INT nump=FEATURENUMC(lidx)+1;
    NUMB ang1,ang2;
    NUMB dangle;
    COORD *points;
    COORD interp;

    points=malloc((FEATURENUMC(lidx)+5)*sizeof(COORD));
    if (points==NULL) return;
    memcpy(points,&FEATURECOORD(lidx),sizeof(COORD));
    memcpy(&points[1],&FEATURELCOORD(lidx,0),sizeof(COORD)*FEATURENUMC(lidx));
    for (i=0;i<nump-1;i++) {
        ang1=angle(&points[i],point);
        ang2=angle(point,&points[i+1]);
        if (ang1==ang2) {
            for (j=nump-1;j>i;j--) {  // move the points up
                memcpy(&points[j+4],&points[j],sizeof(COORD));
            }
            dangle=angle(points,&points[nump-1]);
            i++;
            if (offset>0) {
                move_point(point,dangle,0-range,&points[i  ]);
                move_point(point,dangle,  range,&points[i+3]);
                move_point(&points[i  ],dangle+45 ,offset*1.414,&points[i+1]);
                move_point(&points[i+3],dangle+135,offset*1.414,&points[i+2]);
            } else {
                move_point(point,dangle,0-range,&points[i  ]);
                move_point(point,dangle,  range,&points[i+3]);
                move_point(&points[i  ],dangle+135,offset*1.414,&points[i+1]);
                move_point(&points[i+3],dangle+45 ,offset*1.414,&points[i+2]);
            }
            free(G_features[lidx].lcs);
            G_features[lidx].numc+=4;
            G_features[lidx].lcs=malloc((FEATURENUMC(lidx))*sizeof(COORD));
            memcpy(G_features[lidx].lcs,&points[1],(FEATURENUMC(lidx))*sizeof(COORD));
            return;
        }
    }
    free(points);
}
//===========================================================================
//                           End of file
//===========================================================================

