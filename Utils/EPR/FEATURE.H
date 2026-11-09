//===========================================================================
// Module        : FEATURE.H (declairations for FEATURE.C)
// Synopsys      : resolve conflicts between features
// Description   : This module is used by the generated graphics sub-system
//               : To resolve any conflict between nodes that have been
//               : placed too close together on a diagram for easy reading
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th August 1995
//===========================================================================
// Date      Id   Modification history
//===========================================================================
// 06/08/95  MJD  Initial entry
//===========================================================================

#ifndef FEATURE_H
#define FEATURE_H

//===========================================================================
//                             Definitions
//===========================================================================

#ifdef INIT
#undef INIT
#endif
#ifdef EXTERN
#undef EXTERN
#endif

#ifdef FEATURE_C        
#define INIT(a) =a      // initialise if included from feature.c
#define EXTERN          // set as internal if included from feature.c
#else
#define INIT(a)         // don't initialise if not included from feature.c
#define EXTERN extern   // set as external if not included from feature.c
#endif

#define TRUE  1         // Used by BOOL vars
#define FALSE 0         // Used by BOOL vars

#define NAP_FEATURE  1  // Feature type for NAP's
#define LINE_FEATURE 2  // Feature type for Lines

//===========================================================================
//                        Global variables
//===========================================================================

EXTERN FEATURE *    G_features    INIT( NULL ); // an array of features
EXTERN CONFGROUP *  G_conflicts   INIT( NULL ); // an array of conflicting groups of features
EXTERN INT          G_numbfeature INIT( 0    ); // the number of features in the array
EXTERN INT          G_numconf     INIT( 0    ); // the number of conflicting groups in the array
EXTERN NUMB         node_vic_fact INIT( 1.5  ); // the node vicinity factor (the space by which a node must "clear" it's bounding circle)

//===========================================================================
//                           Macros
//===========================================================================

#define NUMFEATURE       (G_numbfeature)         // macro to access the number of features
#define FEATUREXCOORD(a) (G_features[a].coord.x) // macro to access the feature x co-ordinate
#define FEATUREYCOORD(a) (G_features[a].coord.y) // macro to access the feature y co-ordinate
#define FEATURECOORD(a)  (G_features[a].coord)   // macro to access the feature y co-ordinate
#define FEATUREBOUND(a)  (G_features[a].bound)   // macro to access the feature bounding parameter
#define FEATUREANGLE(a)  (G_features[a].angle)   // macro to access the feature drawing angle
#define FEATUREID(a)     (G_features[a].fnum)    // macro to access the feature number
#define FEATURETYPE(a)   (G_features[a].type)    // macro to access the feature type
#define FEATURENUMC(a)      (G_features[a].numc)     // macro to access the number of feature points
#define FEATURELXCOORD(a,b) (G_features[a].lcs[b].x) // macro to access the feature point x
#define FEATURELYCOORD(a,b) (G_features[a].lcs[b].y) // macro to access the feature point y
#define FEATURELCOORD(a,b)  (G_features[a].lcs[b])   // macro to access the feature point x/y
#define FEATUREFROM(a)      (G_features[a].from)     // macro to access the line feature's from feature
#define FEATURETO(a)        (G_features[a].to)       // macro to access the line feature's to feature
#define FEATUREGROUP(a)     (G_features[a].group)    // macro to access the line feature's group id

//===========================================================================
//                           Fuction prototypes
// See FEATURES.C for descriptions
//===========================================================================
EXTERN void   calc_centre           (INT group);
EXTERN void   add_feat_to_group     (INT group,INT feat);
EXTERN void   free_conf_groups      (void);
EXTERN void   add_conf_to_group     (INT f1,INT f2);
EXTERN NUMB   get_diff              (NUMB dx,NUMB dy,NUMB *angle);
EXTERN COORD *get_feat_coords       (NUMB feat,NUMB *featidx);
EXTERN NUMB   get_feat_angle        (COORD c,NUMB feat,NUMB *fid,
                                     BOOL oncenter);
EXTERN NUMB   get_feat_diff         (NUMB feat1,NUMB feat2,NUMB *angle,
                                     NUMB *mindiff);
EXTERN void   move_feature          (INT fidx,NUMB angle,NUMB dist);
EXTERN void   move_naps_in_group    (INT group);
EXTERN BOOL   build_conf_groups     (void);
EXTERN BOOL   build_duct_conf_groups(void);
EXTERN void   resolve_nap_conflict  (void);
EXTERN INT    get_free_fnum         (void);
EXTERN INT    add_feature           (INT fnum,INT type,COORD *pos,INT bound,
                                     INT nump,COORD *pnts);
EXTERN void   set_feature_angles    (void);

#endif // ndef FEATURE_H

//===========================================================================
//                           End of file
//===========================================================================
