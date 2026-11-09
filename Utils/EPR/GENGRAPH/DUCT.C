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

//#include <conio.h>
//#include <graphics.h>

#include "types.h"
#include "duct.h"
#include "feature.h"

//===========================================================================
//F route_duct
//S re-route a duct
//D re-route via all the conflict clearance points
//P index into G_ducts array
//P clearance points
//P number of clearance points
void route_duct(INT didx,INT numcp,COORD *cp)
{
    COORD startp;    // the line feature start point
    INT fidx;        // feature index
    NUMB dummy;
    memcpy(&startp   ,get_feat_coords(DUCTFROM(didx),&dummy),sizeof(COORD));
    memcpy(&cp[numcp],get_feat_coords(DUCTTO(didx)  ,&dummy),sizeof(COORD));
    fidx=add_feature((-1),LINE_FEATURE,&startp,DUCTBOUND(didx),numcp+1,cp);
    FEATUREFROM(fidx)=DUCTFROM(didx);
    FEATURETO  (fidx)=DUCTTO(didx)  ;
    DUCTVISIB(didx)=FALSE;
}
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
//===========================================================================
//F inboundrect
//S return TRUE if point p is within rectangle r
//P the two co-ordinates of a rectangle
//P a point co-ordinates
//R TRUE if within else FALSE
BOOL inboundrect(COORD *r,COORD *p)
{
    NUMB x,y,x1,y1;
    if (r[0].x>r[1].x) {
        x=r[1].x;
        x1=r[0].x;
    } else {
        x=r[0].x;
        x1=r[1].x;
    }
    if (r[0].y>r[1].y) {
        y=r[1].y;
        y1=r[0].y;
    } else {
        y=r[0].y;
        y1=r[1].y;
    }
//    setcolor(8);
//    rectangle(-50+x*6,450-y*6,-50+x1*6,450-y1*6);
//    getch();
//    setcolor(0);
//    rectangle(-50+x*6,450-y*6,-50+x1*6,450-y1*6);

    return(((p->x>=x)&&(p->x<=x1))&&((p->y>=y)&&(p->y<=y1)));
}
//===========================================================================
//F adjust_bound_rect
//S move the duct bounding rectangle out to fir the feature bounds
//P the two co-ordinates of a rectangle
//P the minimum clearance around the features
void adjust_bound_rect(COORD *r,INT mindist,INT which)
{
    if (r[0].x>r[1].x) {
        if ((which==2)||(which==0)) r[0].x+=mindist;
        if ((which==2)||(which==1)) r[1].x-=mindist;
    } else {
        if ((which==2)||(which==0)) r[0].x-=mindist;
        if ((which==2)||(which==1)) r[1].x+=mindist;
    }
    if (r[0].y>r[1].y) {
        if ((which==2)||(which==0)) r[0].y+=mindist;
        if ((which==2)||(which==1)) r[1].y-=mindist;
    } else {
        if ((which==2)||(which==0)) r[0].y-=mindist;
        if ((which==2)||(which==1)) r[1].y+=mindist;
    }
}
NUMB distance(COORD *a,COORD *b)
{
    NUMB dx=b->x-a->x;
    NUMB dy=b->y-a->y;
    return(sqrt((dx*dx)+(dy*dy)));
}
NUMB angle(COORD *a,COORD *b)
{
    NUMB dx=b->x-a->x;
    NUMB dy=b->y-a->y;
    return(atan(dy/dx)/(M_PI/180));
}
INT add_clearance_point(NUMB x,NUMB y,INT numcp,COORD **cp)
{
    if (numcp==0) {
        *cp=malloc(sizeof(COORD)*2);
    } else {
        *cp=realloc(*cp,(numcp+2)*sizeof(COORD));
    }
    (*cp)[numcp].x=x;
    (*cp)[numcp].y=y;
    numcp++;
    return(numcp);
}
void offset_coord(COORD *c,NUMB angle,NUMB dist)
{
    c->x+=sin(angle*(M_PI/180))*dist;
    c->y+=cos(angle*(M_PI/180))*dist;
}
INT add_conflict_line_point(NUMB a,COORD *ductsp,NUMB mind,COORD *featcp,INT numcp,COORD **cp)
{
    NUMB fangle;    // the angle of feature in relation to the duct start point
    NUMB flength;   // the distance between of feature and the duct start point
    NUMB ftoddist;  // feature to duct distance
    NUMB x;
    NUMB y;

    // get the distance and angle of feature from duct start point
    flength=distance(featcp,ductsp);
    fangle=angle(ductsp,featcp);

    ftoddist=sin((fangle-a)*(M_PI/180))*flength;
    if (fabs(ftoddist)<mind) {
        x=sin((a-90)*(M_PI/180))*mind;
        y=cos((a-90)*(M_PI/180))*mind;
        if (ftoddist>0) {
            numcp=add_clearance_point(featcp->x-x,featcp->y-y,numcp,cp);
        } else {
            numcp=add_clearance_point(featcp->x+x,featcp->y+y,numcp,cp);
        }
    }
    return(numcp);
}
INT add_conflict_point(NUMB a,COORD *ductsp,INT fidx,NUMB mind,INT numcp,COORD **cp)
{
    NUMB fangle;    // the angle of feature in relation to the duct start point
    NUMB flength;   // the distance between of feature and the duct start point
    NUMB ftoddist;  // feature to duct distance
    COORD featcp;   // the feature centre point
    NUMB dummy;
    NUMB x;
    NUMB y;

    // get the distance and angle of feature from duct start point
    memcpy(&featcp,get_feat_coords(FEATUREID(fidx),&dummy),sizeof(COORD));
    flength=distance(&featcp,ductsp);
    fangle=get_feat_angle(*ductsp,FEATUREID(fidx),&dummy,FALSE)+180;
    if (fangle>=360) fangle-=360;

    ftoddist=sin((fangle-a)*(M_PI/180))*flength;
    if (fabs(ftoddist)<mind) {
        x=sin((a-90)*(M_PI/180))*(mind+0.1);
        y=cos((a-90)*(M_PI/180))*(mind+0.1);
        if (ftoddist>0) {
            numcp=add_clearance_point(featcp.x-x,featcp.y-y,numcp,cp);
        } else {
            numcp=add_clearance_point(featcp.x+x,featcp.y+y,numcp,cp);
        }
    }
    return(numcp);
}
COORD *closestpoint(COORD *p,INT nump,COORD *pnts)
{
    INT i;                      // index counter
    INT lowestidx;              // the index of the closest feature
    NUMB mindist;               // the shortest distance
    NUMB curdist;               // the current distance

    mindist=distance(p,&pnts[0]);
    lowestidx=0;
    for (i=1;i<nump;i++) {
        curdist=distance(p,&pnts[i]);
        if (curdist<mindist) {
            mindist=curdist;
            lowestidx=i;
        }
    }
    return(&pnts[lowestidx]);
}
//===========================================================================
//F resolve_between_points
//S resolv all conflicts between two points
//P the two points
//P the address of a list to fill with clearance points
//P the minimum distance around the bounding rectangle
//R the number of clearance points found
int resolve_between_points(COORD *bound,COORD *startp,INT numcp,COORD **cp,INT didx)
{
    INT j;              // index counter
    NUMB dang;          // the angle of the duct
    NUMB fang;          // the angle of the first point on a line feature
    NUMB dummy;         // the feature index ( discarded ) 
    COORD fcoords;      // feature co-ordinates
    COORD *loccp;       // local list of clearance points
    INT numlcp;         // number of local clearance points
    INT mind;           // minimum distance between a duct and a feature

    // get the angle of the duct
    dang=get_feat_angle(*startp,DUCTTO(didx),&dummy,FALSE)+180;
    if (dang>=360) dang-=360;

    // reset number of conflicts
    numlcp=0;
    // each feature
    for (j=0;j<NUMFEATURE;j++) {
        // if the feature is a NAP 
        if (FEATURETYPE(j)==NAP_FEATURE) {
            // get the feature co-ordinates
            memcpy(&fcoords,get_feat_coords(FEATUREID(j),&dummy),sizeof(COORD));

            // get the minimum distance between the duct and the feature
            mind=FEATUREBOUND(j)+DUCTBOUND(didx);

            // if the featuren is not connected to the duct
            // and it is within the bounding rectangle of the duct
            if ((FEATUREID(j)!=DUCTFROM(didx))
            &&  (FEATUREID(j)!=DUCTTO(didx)  )
            &&  (inboundrect(bound,&fcoords)) ) {
                // add the conflict to the list
                numlcp=add_conflict_point(dang,startp,j,mind,numlcp,&loccp);
            }
        // if the feature is a LINE
//        } else if (FEATURETYPE(j)==LINE_FEATURE) {
//            // get the feature co-ordinates
//            memcpy(&fcoords,get_feat_coords(FEATUREID(j),&dummy),sizeof(COORD));
//            fang=get_feat_angle(FEATURELCOORD(j,0),FEATUREID(j),&dummy,FALSE)+180;
//            if (fang>=360) fang-=360;
//            // move the co-ord to the outer bound along the line feature
//            offset_coord(&fcoords,fang,FEATUREBOUND(j));
//            mind=DUCTBOUND(didx);
//            // if it is within the bounding rectangle of the duct
//            if (inboundrect(bound,&fcoords)) {
//                // add the conflict to the list
//                numlcp=add_conflict_line_point(dang,startp,mind,&fcoords,numlcp,&loccp);
//            }
        }
    }
    if (numlcp) {
        memcpy(&bound[0],closestpoint(&bound[0],numlcp,loccp),sizeof(COORD));
        memcpy(startp,&bound[0],sizeof(COORD));
        adjust_bound_rect(bound,mind,0);
        free(loccp);
        loccp=NULL;
        numlcp=0;
        numcp=add_clearance_point(startp->x,startp->y,numcp,cp);
        numcp=resolve_between_points(bound,startp,numcp,cp,didx);
    }
    return(numcp);
}
//===========================================================================
//F resolve_duct_nap_conflicts
//S resolve duct to NAP conflicts
//D resolve duct conflicts with NAP's by moving lines that fall
//D within the bounding circles of NAP's
void resolve_duct_nap_conflicts(void)
{
    INT i;           // index counter
    NUMB fid1;         // the feature index ( duct from ) 
    NUMB fid2;         // the feature index ( duct to )
    NUMB mind;         // feature to duct minimum distance
    COORD dbound[2];   // bounding rectangle
    COORD startp;      // bounding rectangle
    COORD *cp=NULL;    // list of conflict points
    INT numcp=0;       // count of conflict points

    // each duct
    for (i=0;i<NUMDUCT;i++) {
        // calculate the bounding rectangle
        memcpy(&dbound[0],get_feat_coords(DUCTFROM(i),&fid1),sizeof(COORD));
        memcpy(&startp,&dbound[0],sizeof(COORD));
        memcpy(&dbound[1],get_feat_coords(DUCTTO(i)  ,&fid2),sizeof(COORD));
        mind=max(FEATUREBOUND(fid1),FEATUREBOUND(fid2))+DUCTBOUND(i);
        adjust_bound_rect(dbound,mind,2);
        numcp=resolve_between_points(dbound,&startp,numcp,&cp,i);
        // if there are conflicts
        if (numcp) {
            // re-route the duct
            route_duct(i,numcp,cp);
            // cleanup conflict points array
            free(cp);
            cp=NULL;
            numcp=0;
        } else {
            add_duct_feature(i);
        }
    }
}
//===========================================================================
//                           End of file
//===========================================================================

