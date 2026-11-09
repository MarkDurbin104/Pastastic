#ifndef TYPES_H
#define TYPES_H

//****************************************************************************

typedef int    INT;
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

    // USED BY NAP FEATURE
    NUMB  angle;        // the angle of the feature for drawing
    NUMB  bound;        // the radius of the bounding circle

    // USED BY LINE FEATURE 
    INT   numc;         // the number of co-ordinates in a line feature
    COORD *lcs;         // the co-ordinates of a line feature
    INT   from;         // the feature number from which it connects
    INT   to;           // the feature number which it connects to
} FEATURE;
//****************************************************************************
// DUCT structure
// A structure used to hold a duct
typedef struct {
    INT  from;          // the feature number from which it connects
    INT  to;            // the feature number which it connects to
    NUMB bound;         // the bounding clearance of the duct
    BOOL visib;         // the visibliity of the duct TRUE=visible
} DUCT;

#endif // ndef TYPES_H
