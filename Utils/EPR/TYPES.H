#ifndef TYPES_H
#define TYPES_H

//****************************************************************************

typedef long   INT;
typedef double NUMB;
typedef int    BOOL;

//****************************************************************************
// CO-ORDinate structure
// An x and y co-ordinate
typedef struct {
    NUMB x;             // x co-ordinate
    NUMB y;             // y co-ordinate
} COORD;
//****************************************************************************
// CONFlict GROUP structure
// A structure used to hold a group of features that conflict with each other
// and the centre of all the points used to resolve the conflict
typedef struct {
    COORD centre;       // the co-ordinate of the centre
    INT   numf;         // the number of features in the group
    INT   *features;    // an array of the features
} CONFGROUP;
//****************************************************************************
// FEATURE structure
// A structure used to hold a feature
typedef struct {
    INT   fnum;         // the feature number (unique identifier)
    COORD coord;        // the co-ordinate of the centre
    INT   type;         // the feature type
    INT   no;           // the feature number printed on the diagram

    // USED BY NAP FEATURE
    NUMB  angle;        // the angle of the feature for drawing
    NUMB  bound;        // the radius of the bounding circle
    char *ftype;        // the feature type printed on the diagram
    char *state;        // the feature state printed on the diagram
    char *style;        // the feature style printed on the diagram
    BOOL  hazard;       // TRUE if the feature as a hazard indicator
    BOOL  equip;        // TRUE if the feature as an equipment indicator
    BOOL  anti;         // TRUE if the feature as an anti???? indicator
    BOOL  temp;         // flag to indicate if the feature is temporary (i.e. to be deleted)

    // USED BY LINE FEATURE 
    INT   numc;         // the number of co-ordinates in a line feature
    COORD *lcs;         // the co-ordinates of a line feature
    INT   from;         // the feature number from which it connects
    INT   to;           // the feature number which it connects to
    INT   length;       // the duct length printed on the diagram
    INT   group;        // ident used for all lines between the same NAP's
} FEATURE;
//****************************************************************************
// DUCT structure
// A structure used to hold a duct
typedef struct {
    INT  from;          // the feature number from which it connects
    INT  to;            // the feature number which it connects to
    NUMB bound;         // the bounding clearance of the duct
    BOOL visib;         // the visibliity of the duct TRUE=visible
    INT  group;         // ident used for all ducts between the same NAP's
} DUCT;

#endif // ndef TYPES_H
