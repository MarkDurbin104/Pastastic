//===========================================================================
// Module        : FEATURE.C
// Synopsys      : resolve conflicts between features
// Description   : This module is used by the generated graphics sub-system
//               : To resolve any conflict between nodes that have been
//               : placed too close together on a diagram for easy reading
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th August 1995
//===========================================================================
// Functions     : calc_centre           add_feat_to_group     
//               : free_conf_groups      add_conf_to_group     
//               : get_diff              get_feat_coords       
//               : get_feat_angle        get_feat_diff         
//               : move_feature          move_naps_in_group    
//               : build_conf_groups     build_duct_conf_groups
//               : resolve_nap_conflict  get_free_fnum
//               : add_feature           set_feature_angles
//===========================================================================
// Global Vars.  : G_features   G_ducts      G_conflicts  G_numbfeature
//               : G_numbducts  G_numconf    node_vic_fact
//===========================================================================
// Date      Id   Modification history
//---------------------------------------------------------------------------
// 06/08/95  MJD  Initial entry
//===========================================================================

#define FEATURE_C
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

#include "types.h"
#include "duct.h"
#include "feature.h"

//===========================================================================
//F calc_centre
//S Calculate the centre of a group
//D Calculate the centre of a group by placing a bounding rectangle
//D arround all the features in the group and then finding it's centre
//P The index into the G_conflicts array
void calc_centre(INT group)
{
    COORD coord;   // struct for co-ordinates
    NUMB r,l,t,b;  // left right top and bottom of the bounding rectangle
    NUMB dummy;    // dummy for discarded return value
    INT i;         // index counter

    // get the co-ordinates of the first feature
    memcpy(&coord,get_feat_coords(G_conflicts[group].features[0],&dummy),sizeof(COORD));
    r=l=coord.x; // setup the left and right max co-ord.
    t=b=coord.y; // setup the top and bottom max co-ord.
    // for each item in the group
    for (i=1;i<G_conflicts[group].numf;i++) {
        // get the co-ordinates of the feature
        memcpy(&coord,get_feat_coords(G_conflicts[group].features[i],&dummy),sizeof(COORD));
        r=max(r,coord.x); // set the right position
        l=min(l,coord.x); // set the left position
        b=max(b,coord.y); // set the top position
        t=min(t,coord.y); // set the bottom position
    }
    if (l>10) {  // if the group centre x co-ord. is on the diagram
        G_conflicts[group].centre.x=l+((r-l)/2);
    } else {     // if the group centre is off the diagram i.e x < 0
        G_conflicts[group].centre.x=(r-l)/2;
    }

    if (t>10) {  // if the group centre y co-ord. is on the diagram
        G_conflicts[group].centre.y=t+((b-t)/2);
    } else {     // if the group centre is off the diagram i.e y < 0
        G_conflicts[group].centre.y=(b-t)/2;
    }

}
//===========================================================================
//F add_feat_to_group
//S Add a feature to a conflict group array
//D Add a feature to a conflict group if it is not already in the group
//D extend the features array to hold it and increment the number of 
//D features counter.
//P The index into the G_conflicts array
//P The feature number
void add_feat_to_group(INT group,INT feat)
{
    int j;                // index counter

    // check array bounds
    if ((group<0)||(group>G_numconf)) return;

    // go througth features in the group
    for (j=0;j<G_conflicts[group].numf;j++) {
        // return if it is in group
        if (G_conflicts[group].features[j]==feat) return; 
    }
    // if the array is empty allocate space otherwise re-allocate
    if (G_conflicts[group].numf) {
        G_conflicts[group].features=realloc(G_conflicts[group].features,(G_conflicts[group].numf+1)*sizeof(INT));
    } else {
        G_conflicts[group].features=malloc((G_conflicts[group].numf+1)*sizeof(INT));
    }
    // add the feature to the end of the array
    G_conflicts[group].features[G_conflicts[group].numf]=feat;
    // resize
    G_conflicts[group].numf++;
}
//===========================================================================
//F free_conf_groups
//S Free the conflict group arrays
//D Free the memory used by the array "G_conflicts" and all it's associated
//D data.  Set G_numconfs to 0 and G_conflicts to NULL
void free_conf_groups(void)
{
    int i;                   // index counter
    if (G_conflicts==NULL) { // none to free
        G_numconf=0;         // zero count
        return;
    }
    // each group
    for (i=0;i<G_numconf;i++) {
        // if there are any features
        if ((G_conflicts[i].numf)&&(G_conflicts[i].features!=NULL)) {
            // free them up
            free(G_conflicts[i].features);
        }
    }
    free(G_conflicts);       // free the array
    G_conflicts=NULL;        // mark as empty
    G_numconf=0;             // zero count
}
//===========================================================================
//F add_conf_to_group
//S Add the conflict between two features into a conflict group
//D Add the conflict between two features into a conflict group
//P The first feature
//P The second feature
void add_conf_to_group(INT f1,INT f2)
{
    int i,j;
    // each conflict group
    for (i=0;i<G_numconf;i++) {
        // each item in the conflict group
        for (j=0;j<G_conflicts[i].numf;j++) {
            // if feature 1 is in the group - add feature 2
            if (G_conflicts[i].features[j]==f1) {
                add_feat_to_group(i,f2);
                return;
            }
            // if feature 2 is in the group - add feature 1
            if (G_conflicts[i].features[j]==f2) {
                add_feat_to_group(i,f1);
                return;
            }
        }
    }
    // not found so add new group
    // if this is the first group allocate a block otherwise re-allocate
    if (!G_numconf) {
        G_conflicts=malloc(sizeof(CONFGROUP));
    } else {
        G_conflicts=realloc(G_conflicts,(G_numconf+1)*sizeof(CONFGROUP));
    }
    // setup group
    G_conflicts[G_numconf].features=NULL;
    G_conflicts[G_numconf].numf=0;
    // extend the list
    G_numconf++;
    // add the features to the last group
    add_feat_to_group(G_numconf-1,f1);
    add_feat_to_group(G_numconf-1,f2);
}
//===========================================================================
//F get_diff
//S Find the distance and angle for a given delta x and delta y
//D Find the distance and angle between 0 and a point given the
//D delta x and delta y.  The assumption made is that under VISION, the
//D angle 0 degrees is straight up and that 90 degrees is right.
//P delta x
//P delta y
//P pointer to returned angle
//R distance between 0,0 and dx,dy
NUMB get_diff(NUMB dx,NUMB dy,NUMB *angle)
{
    if (dx==0) {            // line vertical
        if (dy>0) {         // line positive vertical
            *angle=0;
            return(dy);
        } else if (dy<0) {  // line negative vertical
            *angle=180;
            return(0-dy);
        } else {            // no line i.e. dx,dy==0,0
            *angle=0;
            return(0);
        }
    }
    if (dy==0) {            // line horizontal
        if (dx>0) {         // line positive horizontal
            *angle=90;
            return(dx);
        } else {            // line negative horizontal
            *angle=270;
            return(0-dx);
        }                   
    }
    if (dx>0) {             
        if (dy>0) {         // line in first quadrant
            *angle=0+atan(dx/dy)*(180.0/M_PI);
        } else {            // line in second quadrant
            *angle=90+atan((0-dy)/dx)*(180.0/M_PI);
        }
    } else {
        if (dy>0) {         // line in fourth quadrant
            *angle=270+atan(dy/(0-dx))*(180.0/M_PI);
        } else {            // line in third quadrant
            *angle=180+atan((0-dx)/(0-dy))*(180.0/M_PI);
        }
    }
    // calculate and return length of hypotenuse
    return(sqrt((dx*dx)+(dy*dy)));    
}
//===========================================================================
//F get_feat_coords
//S Get a feature's co-ordinates
//D Go through each feature in the list and find the
//D correct feature number.  When found pass the x and y
//D co-ordinates to a static internal structure "c"
//D and place the index of the feature in the passed
//D variable "featidx" for future reference.
//D If not found set the internal structure "c" to co-ord 0,0.
//D Then return the co-ordinates.
//P The feature number to find
//P Returned index of found feature
//R The internal co-ord structure.
COORD *get_feat_coords(NUMB feat,NUMB *featidx)
{
    static COORD c;
    INT i;
    // each feature
    for (i=0;i<NUMFEATURE;i++) {
        // if this is the feature specified
        if (FEATUREID(i)==feat) {
            c.x=FEATUREXCOORD(i);   // get co-ordinates
            c.y=FEATUREYCOORD(i);
            *featidx=i;             // set index for future reference
            return(&c);             // return co-ordinates
        }
    }
    c.x=c.y=(NUMB)0;                // NOT FOUND ! - set some resonable value
    return(&c);
}
//===========================================================================
//F get_feat_angle
//S Find the angle between a point and a feature
//D Find the angle between the point at the centre of a conflict group
//D and a feature if "oncentre" is true and the feature is on the point
//D return -1 as the angle
//P The co-ordinate of the centre point
//P The feature number
//P A return index into the feature array
//P The centre resolution flag
//R The angle 
NUMB get_feat_angle(COORD c,NUMB feat,NUMB *fid,BOOL oncentre)
{
    COORD coord;        // The co-ordinates of the two features
    NUMB dx,dy;         // The delta x and delta y of the two features
    NUMB angle;

    // get a copy of the co-odinates for the feature
    memcpy(&coord,get_feat_coords(feat,fid),sizeof(COORD));

    dx=coord.x-c.x; // calculate delta x
    dy=coord.y-c.y; // calculate delta y

    // if oncentre is true and the feature is on 
    // the centre point return -1 degrees
    if ((oncentre)&&(dx==0)&&(dy==0)) return(-1);

    // calculate the angle
    get_diff(dx,dy,&angle);
    return(angle);
}
//===========================================================================
//F get_feat_diff
//S Find the angle and distance between two features
//D Find the angle and distance between two features and the minimum
//D distance that should be between them
//P The first feature number
//P The second feature number
//P A return pointer for the angle
//P A return pointer for the minimim distance
//R The actual distance between the features
NUMB get_feat_diff(NUMB feat1,NUMB feat2,NUMB *angle,NUMB *mindiff)
{
    COORD coord[2];     // The co-ordinates of the two features
    NUMB dx,dy;         // The delta x and delta y of the two features
    NUMB fid[2];        // The feature identifiers of the two features
    NUMB length;        // The distance between the two features

    // get local copies of the feature's co-ordinates
    memcpy(&coord[0],get_feat_coords(feat1,&(fid[0])),sizeof(COORD));
    memcpy(&coord[1],get_feat_coords(feat2,&(fid[1])),sizeof(COORD));

    dx=coord[1].x-coord[0].x; // calculate delta x
    dy=coord[1].y-coord[0].y; // calculate delta y

    // calculate the angle and length
    length=get_diff(dx,dy,angle);

    // set the minimum distance the features should be appart
    *mindiff=FEATUREBOUND(fid[0])+FEATUREBOUND(fid[1])+node_vic_fact;
    return(length);
}
//===========================================================================
//F move_feature
//S move a feature
//D change the X ang Y co-ordinates of a feature by moving the point 
//D referenced by the given angle and distance
//P The INDEX in the feature array (not the feature number)
//P the angle of adjustment
//P the distance to move along the angle
void move_feature(INT fidx,NUMB angle,NUMB dist)
{
    NUMB newcoord;

    newcoord=FEATUREXCOORD(fidx)+(sin(angle*(M_PI/180))*dist);
    // if the new X co-ordinate leaves the feature in view i.e. > 0
    if (newcoord>FEATUREBOUND(fidx)) FEATUREXCOORD(fidx)=newcoord;

    newcoord=FEATUREYCOORD(fidx)+(cos(angle*(M_PI/180))*dist);
    // if the new Y co-ordinate leaves the feature in view i.e. > 0
    if (newcoord>FEATUREBOUND(fidx)) FEATUREYCOORD(fidx)=newcoord;
}
//===========================================================================
//F move_naps_in_group
//S move the naps in a conflict group out from the centre
//D move the naps in a conflict group out from the centre by a distance
//D of 1. This function will be called until all conflicts are resolved.
//P the group index
void move_naps_in_group(INT group)
{
    INT i;          // index counter
    NUMB angle;     // the angle between the centre and a feature
    NUMB fid;       // the index in the feature array
    BOOL oc=TRUE;   // the on center flag

    // each feature in the conflict group
    for (i=0;i<G_conflicts[group].numf;i++) {
        // find the angle
        angle=get_feat_angle(G_conflicts[group].centre,G_conflicts[group].features[i],&fid,oc);

        // if it's on the centre leave it there 
        // but move any other features on the centre
        if (angle<0) { // found one feature on the centre - move any others
            oc=FALSE;
        } else {
            move_feature(fid,angle,1);  // move the feature by a distance of 1
        }
    }
}
//===========================================================================
//F build_conf_groups
//S Build conflict groups
//D Build groups of features that conflict with eachother
//R TRUE if a conflict was found
BOOL build_conf_groups(void)
{
    INT i,j;                    // index counters
    BOOL foundconf=FALSE;       // return value
    NUMB angle;                 // the angle of the line between two features
    NUMB mindist;               // the minimum distance between two features
    NUMB length;                // the length of the line between two features

    // clear previous groups if there are any
    free_conf_groups();

    // each feature
    for (i=0;i<NUMFEATURE;i++) {
        if (FEATURETYPE(i)==NAP_FEATURE) {
            // each feature not already compared with feature(i)
            for (j=i+1;j<NUMFEATURE;j++) {
                if (FEATURETYPE(j)==NAP_FEATURE) {
                    // get the distance between the features
                    length=get_feat_diff(FEATUREID(i),FEATUREID(j),&angle,&mindist);
                    // if it's to close
                    if (length<mindist) {
                        foundconf=TRUE;
                        add_conf_to_group(FEATUREID(i),FEATUREID(j));
                    }
                }
            }
        }
    }
    // go through all the groups found and calculate the center
    for (i=0;i<G_numconf;i++) calc_centre(i); 
    return(foundconf); 
}
//===========================================================================
//F build_duct_conf_groups
//S build duct conflict groups
//D build conflict groups that are connected via ducts
//R TRUE if a conflict was found
BOOL build_duct_conf_groups(void)
{
    INT i;                      // index counter
    BOOL foundconf=FALSE;       // return value
    NUMB angle;                 // the angle of the line between two features
    NUMB mindist;               // the minimum distance between two features
    NUMB length;                // the length of the line between two features

    // clear previous groups if there are any
    free_conf_groups();

    // each duct
    for (i=0;i<NUMDUCT;i++) {
        // get the distance between the features connected via a duct
        length=get_feat_diff(DUCTFROM(i),DUCTTO(i),&angle,&mindist);
        // if it's to close
        if (length<mindist) {
            foundconf=TRUE;
            add_conf_to_group(DUCTFROM(i),DUCTTO(i));
        }
    }
    // go through all the groups found and calculate the center
    for (i=0;i<G_numconf;i++) calc_centre(i); 
    return(foundconf);
}
//===========================================================================
//F resolve_nap_conflict
//S resolve NAP conflicts
//D resolve the conflicts between NAP's that are closer then the bounding
//D circle (plus node_vic_fact) by fisrt moving all NAP's that are connected
//D via duct to a suitable distance and then moving any other NAP's that
//D are still too close.
//D The method used to move the NAP's, is to find a centre point between the 
//D conflicting NAP's and move each NAP out from the centre until there are
//D no more conflicts.
void resolve_nap_conflict(void)
{
    INT i;                      // index counter
    BOOL still_conflict=TRUE;   // True while conflict remains
    INT not_jammed=300;         // decremented on each loop to stop lockup
    
    // while there is still conflict
    while ((still_conflict)&&(not_jammed)) {
        // build the groups
        build_duct_conf_groups();
        // each group
        for (i=0;i<G_numconf;i++) {
            // move the NAP's
            move_naps_in_group(i);
        }
        // if there are no more conflicts set exit condition
        if (!G_numconf) still_conflict=FALSE;
        // decrement the safety exit condition
        not_jammed--;
    }
    still_conflict=TRUE; // reset flags
    not_jammed=300;
    while ((still_conflict)&&(not_jammed)) {
        // build the groups
        build_conf_groups();
        // each group
        for (i=0;i<G_numconf;i++) {
            // move the NAP's
            move_naps_in_group(i);
        }
        // if there are no more conflicts set exit condition
        if (!G_numconf) still_conflict=FALSE;
        // decrement the safety exit condition
        not_jammed--;
    }
}
//===========================================================================
//F set_feature_angles
//S set the feature drawing angles
//D change the drawing angle of each feature to suit the ducts that are
//D attached to it
void set_feature_angles(void)
{
    INT i,j;        // index counters
    INT numangles;  // the number of angles
    NUMB aveangle;  // average angle
    NUMB angle;     // returned angle of duct
    NUMB dummy;     // discarded return min distance
    // each feature
    for (i=0;i<NUMFEATURE;i++) {
        if (FEATURETYPE(i)==NAP_FEATURE) {
            numangles=0;
            aveangle=0;
            // each duct
            for (j=0;j<NUMDUCT;j++) {
                if (DUCTVISIB(j)) {
                    if (DUCTFROM(j)==FEATUREID(i)) {
                        get_feat_diff(DUCTFROM(j),DUCTTO(j),&angle,&dummy);
                        aveangle+=(int)angle%180;
                        numangles++;
                    } else if (DUCTTO(j)==FEATUREID(i)) {
                        get_feat_diff(DUCTTO(j),DUCTFROM(j),&angle,&dummy);
                        aveangle+=(int)angle%180;
                        numangles++;
                    }
                }
            }
            for (j=0;j<NUMFEATURE;j++) {
                if (FEATURETYPE(j)==LINE_FEATURE) {
                    if (FEATUREFROM(j)==FEATUREID(i)) {
                        angle=get_feat_angle(FEATURELCOORD(j,0),FEATUREFROM(j),&dummy,FALSE)+180;
                        aveangle+=(int)angle%180;
                        numangles++;
                    } else if (FEATURETO(j)==FEATUREID(i)) {
                        if (FEATURENUMC(j)==1) {
                            angle=get_feat_angle(FEATURECOORD(j),FEATURETO(j),&dummy,FALSE)+180;
                        } else {
                            angle=get_feat_angle(FEATURELCOORD(j,FEATURENUMC(j)-2),FEATURETO(j),&dummy,FALSE)+180;
                        }
                        aveangle+=(int)angle%180;
                        numangles++;
                    }
                }
            }
            if (numangles) {
                aveangle/=numangles;
                FEATUREANGLE(i)=aveangle-90;
            } else {
                FEATUREANGLE(i)=0;
            }
        }
    }
}
//===========================================================================
//F get_free_fnum
//S Get the next available feature number
//D Get the next available feature number by searching through and comparing
//D with a count value 
INT get_free_fnum(void)
{
    INT i,j;
    for (i=0;i<32760;i++) {
        for (j=0;j<NUMFEATURE;j++) {
            if (i==FEATUREID(j)) break;
        }
        if (j==NUMFEATURE) return(i);
    }
    return(-1);
}
//===========================================================================
//F add_feature
//S Add a feature to the list
//D Add a feature to the list
//P Feature number (negative for next available)
//P Feature type
//P The x/y co-ordinate
//P The bounding parameter (NAP FEATURE)
//P The number of points   (LINE FEATURE)
//P The points             (LINE FEATURE)
//R the index of the added feature
INT add_feature(INT fnum,INT type,COORD *pos,INT bound,INT nump,COORD *pnts)
{
    if ((G_features==NULL)||(G_numbfeature==0)) {
        G_features=malloc(sizeof(FEATURE));
    } else {
        G_features=realloc(G_features,(G_numbfeature+1)*sizeof(FEATURE));
    }
    if (G_features==NULL) return(-1);

    if (fnum<0) fnum=get_free_fnum();
    G_features[G_numbfeature].fnum=fnum;
    G_features[G_numbfeature].coord.x=pos->x;
    G_features[G_numbfeature].coord.y=pos->y;
    G_features[G_numbfeature].type=type;
    switch (type) {
        case NAP_FEATURE :
            G_features[G_numbfeature].angle=0;
            G_features[G_numbfeature].bound=bound;
            break;
        case LINE_FEATURE :
            G_features[G_numbfeature].from=0;
            G_features[G_numbfeature].to  =0;
            G_features[G_numbfeature].numc=nump;
            G_features[G_numbfeature].lcs=NULL;
            if (!nump) return(G_numbfeature);
            G_features[G_numbfeature].lcs=malloc(nump*sizeof(COORD));
            memcpy(G_features[G_numbfeature].lcs,pnts,nump*sizeof(COORD));
            break;
        default :
            return(-1);
    }
    G_numbfeature++;
    return(G_numbfeature-1);
}
//==========================================================================
//                           End of file
//===========================================================================

