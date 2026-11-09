/****************************************************************************/
/*  Module                                                                  */
/*   ERASEPLY.C                                                             */
/*                                                                          */
/*  Synopsys                                                                */
/*   Erase the area within an irregular polygon using rectangular regions.  */
/*                                                                          */
/*  Description                                                             */
/*   This module contains the final method for erasing polygons,            */
/*   using RLE_ERASE optimised for speed                                    */
/*                                                                          */
/*   Certain sections of this module are included/excluded via the define   */
/*   DLL_BUILD these are for building the module as a callable DLL for      */
/*   testing under DOS/Windows.  If you are removing these sections please  */
/*   take care to check if they are included (#ifdef) of excluded (#ifndef) */
/*   before deleting the section.                                           */
/*                                                                          */
/*  Function List                                                           */
/*   DoPolyErase                                                            */
/*     Erase the polygon by rectangular region                              */
/*   EraseRect                                                              */
/*     Call the GMLI erase_region command for each rectangle in the list    */
/*   erase_polygon                                                          */
/*     Erase a polygon using rectangular regions called by GML              */
/*   GetAngle                                                               */
/*     Get the angle between two points                                     */
/*   GetPointsofIntersection                                                */
/*     Get all the points along a line that are interrsected by the polygon */
/*   GetUpLowBounds                                                         */
/*     Get the upper and lower bounds of the polygon                        */
/*   Imcmp                                                                  */
/*     Integer compare function for qsort()                                 */
/*   YAdjRect                                                               */
/*     Merge two adjacent rectangles of the same height                     */
/*                                                                          */
/*  Author                                                                  */
/*   M.J.Durbin                                                             */
/*   Unisys Ltd.                                                            */
/*   22 Southwark Bridge Road                                               */
/*   London SE1 9HB                                                         */
/*                                                                          */
/*  Modification History                                                    */
/*   Release  Date     Who           Comment                                */
/*   0.00     27/01/96 MJD           Initial Release                        */
/*                                                                          */
/*                                                                          */
/****************************************************************************/






/****************************************************************************/
/*       START - NEEDED TO TEST COMPILE ANSI CODE - YOU MAY REMOVE          */
/****************************************************************************/
#ifndef GMLI_MAX_PARM_SIZE                             /*                   */
#define GMLI_MAX_PARM_SIZE 256                         /*                   */
#endif                                                 /*                   */
extern int     gmli_get_value  (char *paramblk);       /*                   */
extern int     gmli_call_appl  (char *paramblk);       /*                   */
extern void    msg_issue       (char *err,char state); /*                   */
/****************************************************************************/
/*         END - NEEDED TO TEST COMPILE ANSI CODE - YOU MAY REMOVE          */
/****************************************************************************/






/****************************************************************************/
/*                         Includes Section                                 */
/****************************************************************************/
#include <stdio.h>   /* required for sprintf(), NULL                        */      
#include <stdlib.h>  /* required for atol(), atoi()                         */
#include <string.h>  /* required for strcpy()                               */
#include <malloc.h>  /* required for malloc(), free()                       */
#include <math.h>    /* required for atan2(), tan(), M_PI                   */

#include "epr_util.h"

/****************************************************************************/
/*                      Defines/TypeDefs Section                            */
/****************************************************************************/
//typedef long NUMB;       /* redefine to change number type used throughout  */
//#define ATON atol        /* redefine to change number type used throughout  */

typedef double NUMB;     /* redefine to change number type used throughout  */
#define ATON atof        /* redefine to change number type used throughout  */

typedef int (*QSPTR)(const void*, const void*);  /* compare prototype, qsort*/

typedef int BOOL;        /* return type TRUE or FALSE                       */
#define FALSE 0          /* BOOL type                                       */
#define TRUE  1          /* BOOL type                                       */

#ifndef DLL_BUILD
 typedef struct {        /* point structure for holding the polygon points  */
     NUMB X;             /* X co-ordinate                                   */
     NUMB Y;             /* Y co-ordinate                                   */
 } XYPOINT;

 typedef struct Plist {  /* linked list structure for rectangular regions   */
     NUMB X;             /* top left X co-ordinate                          */
     NUMB Y;             /* top left Y co-ordinate                          */
     NUMB X1;            /* bottom right X co-ordinate                      */
     NUMB Y1;            /* bottom right Y co-ordinate                      */
     struct Plist *next; /* pointer to next item in list or NULL            */
 } PLIST;
#endif


/****************************************************************************/
/*                            Prototypes Section                            */
/****************************************************************************/
void     EraseRect           (PLIST *p);
double   GetAngle            (NUMB x,NUMB y,XYPOINT *b);
BOOL     YAdjRect            (PLIST *p,PLIST *l);
void     GetUpLowBounds      (NUMB *y,NUMB *y1,XYPOINT *poly,int numply);
BOOL     DoPolyErase         (XYPOINT *poly,int numply,NUMB increment);
BOOL     erase_polygon       (void);

/****************************************************************************/
/*                          Global Variables Section                        */
/****************************************************************************/



/****************************************************************************/
/*                        Function Definition Section                       */
/****************************************************************************/

/*****************************************************************************
//F erase_polygon
//S erase a polygon using rectangular regions - called by GML
//D This function is called repeatedly to collect arguments off the command
//D line from GMLI on the first call the three parameters "add" the
//D number of polygons and the increment size should be passed. On subsequent 
//D calls the parameters should be the X and Y co-ordinates of one point in the
//D polygon.  When all the points have been collected this function then
//D calls DoPolyErase to do the work and then it frees the memory allocated 
//D for the polygon points and returns FALSE.
//D Any failure will also return FALSE
//R TRUE if more parameters are required else FALSE
/****************************************************************************/
BOOL erase_polygon(void)
{
    char parameter[GMLI_MAX_PARM_SIZE];  /* Space for parameter */
    static int state=0;                  /* current parameter state */
    static XYPOINT *polypoint=NULL;      /* Space for poly points */
    static NUMB increment=0.1;           /* increment size */
    static NUMB numpolypoint=0;          /* number of poly points */
    static NUMB currentpolypoint;        /* current poly point */

    if (!gmli_get_value(parameter)) {                     /* get a parameter */
        msg_issue("erase_polygon: Failed to get parameter",'e');
        state=0;
        return(FALSE);
    }
    if (state==0) {                                         /* initial state */
        if (strcmp(parameter,"add")) {                      /* must be "add" */
            msg_issue("erase_polygon: parameter out of sequence",'e');
            return(FALSE);
        }
        if (!gmli_get_value(parameter)) {                 /* get a parameter */
            msg_issue("erase_polygon: Failed to get parameter",'e');
            return(FALSE);
        }
        numpolypoint=ATON(parameter); /* set number of points to receive */
        if (numpolypoint<=0) {
            msg_issue("erase_polygon: Invalid number of poly points",'e');
            return(FALSE);
        }
        currentpolypoint=0;                          /* reset to start point */
        if (polypoint!=NULL) free(polypoint);        /* free if error before */
        polypoint=malloc((int)numpolypoint*sizeof(XYPOINT));
        if (polypoint==NULL) {
            msg_issue("erase_polygon: Insufficient Memory for this operation",'e');
            return(FALSE);
        }
        if (!gmli_get_value(parameter)) {                 /* get a parameter */
            msg_issue("erase_polygon: Failed to get parameter",'e');
            return(FALSE);
        }
        increment=ATON(parameter); /* set the increment value */
        state++;                                               /* next state */
    } else {
        polypoint[(int)currentpolypoint].X=ATON(parameter);     /* X Co-ord. */
        if (!gmli_get_value(parameter)) {
            state=0;
            msg_issue("erase_polygon: Failed to get parameter",'e');
            return(FALSE);
        }
        polypoint[(int)currentpolypoint].Y=ATON(parameter);     /* Y Co-ord. */
        currentpolypoint++;
        if (currentpolypoint==numpolypoint) {             /* reached maximum */
            state=0;                                          /* reset state */
            if (!DoPolyErase(polypoint,(int)numpolypoint,increment)) {
                msg_issue("erase_polygon: Erase Failed!",'e');
            }
            if (polypoint!=NULL) free(polypoint);         /* free used space */
            polypoint=NULL;
            return(FALSE);                               /* signal last call */
        }
    }
    return(TRUE);                             /* signal more points expected */
}
/*****************************************************************************
//F GetUpLowBounds
//S Get the upper and lower bounds of the polygon
//D Get the upper and lower bounds of the polygon
//P The address of returned top Y co-ordinate
//P The address of returned bottom Y co-ordinate
//P The polygon points
//P The number of points in the polygon
/****************************************************************************/
void GetUpLowBounds(NUMB *y,NUMB *y1,XYPOINT *poly,int numply)
{
    int counter;              /* index counter */
    *y1=*y=poly->Y;
    for (counter=1;counter<numply;counter++) {      /* all points in polygon */
        poly++;                                     
        if (poly->Y<*y) {                           
            *y=poly->Y;
        } else if (poly->Y>*y1) {
            *y1=poly->Y;
        }
    }
}
/*****************************************************************************
//F Imcmp
//S Integer compare function for qsort()
//D Integer compare function for qsort()
//P The address of the first integer
//P The address of the second integer
//R a<b - (-1) a==b - 0 a>b - 1
/*****************************************************************************/
int Imcmp(NUMB *a,NUMB *b)
{
    if (*a==*b) return 0;
    if (*a>*b) return 1;
    return -1;
}
/*****************************************************************************
//F GetPointsofIntersection
//S Get all the points along a line that are intersected by the polygon
//D Get all the points along a line that are intersected by the polygon,
//D returning a list sorted from left to right
//P The Y co-ordinate if the line
//P The polygon points
//P The number of points in the polygon
//R a sorted list of points, (-1) indicating the end of the list             
/*****************************************************************************/
NUMB *GetPointsofIntersection(NUMB y,XYPOINT *poly,int numply)
{
    static NUMB *Imap=NULL;     /* intersection mapping list */
    int i;                      /* index counter of poly points */
    int iofs;                   /* ofset in intersection mapping list */
    double angle;               /* angle of poly line */

    /* allocate room for 200 intersections */
    if (Imap==NULL) Imap=malloc(200*sizeof(NUMB)); 

    if (y<0) {          /* -tive y - free used memory */
        free(Imap);
        Imap=NULL;
        return(Imap);
    }

    iofs=0;                             
    for (i=0;i<numply-1;i++) {
        /* if polyline dissects line */
        if (((poly->Y<y)&&((poly+1)->Y>=y))||((poly->Y>=y)&&((poly+1)->Y<y))) {
            /* calculate intersection point */
            angle=GetAngle(poly->X,poly->Y,poly+1);
            Imap[iofs++]=poly->X-(tan(angle*(M_PI/180.0))*(y-poly->Y));
        }                
        poly++;
    }
    
    if (iofs)     /* re-order from left to right */
        qsort(Imap,iofs,sizeof(NUMB),(QSPTR)Imcmp);

    Imap[iofs++]=(-1);                                      /* end of list */
    return(Imap);
}

/*****************************************************************************
//F DoPolyErase
//S Erase the polygon by rectangular region
//D Erase the polygon by passing over each point in the polygon in the 
//D direction top to bottom and marking all the intersecting blocks for
//D deletion once the entire polygon has been covered,
//D any adjacent rectangles of the same width are merged.
//P The polygon points
//P The number of points in the polygon
//P The minimum height of each rectangle
//R always TRUE
/*****************************************************************************/
BOOL DoPolyErase(XYPOINT *poly,int numply,NUMB increment)
{
    NUMB minY,maxY;     /* upper and lower bounds */
    NUMB tmpy;          /* Y co-ordinate index counter */
    NUMB *imap;         /* intersection map */
    PLIST *pnts;        /* rectangle points structure */
    PLIST *firstp=NULL; /* first point in list of rectangle points */
    BOOL found;         /* flag to signify end of merge */

    GetUpLowBounds(&minY,&maxY,poly,numply);     /* get upper & lower bounds */

    for (tmpy=minY;tmpy<maxY;tmpy+=increment) {
        imap=GetPointsofIntersection(tmpy,poly,numply);
        while ((imap!=NULL)&&(*imap>=0)) {          /* list ok and not at end */
            if ((pnts=malloc(sizeof(PLIST)))==NULL) return(FALSE);
            pnts->X =*(imap++);
            pnts->Y =tmpy;
            pnts->X1=*(imap++);
            pnts->Y1=tmpy+increment;
            pnts->next=firstp;                                /* add to list */
            firstp=pnts;                              /* reset start of list */
        }
    }
    GetPointsofIntersection(-1,NULL,0);                  /* free used memory */
    do {
        pnts=firstp;
        found=FALSE;
        while (pnts!=NULL) {                     /* join adjacent rectangles */
            if (YAdjRect(pnts,firstp)) found=TRUE;
            pnts=pnts->next;
        }
    } while (found);
    EraseRect(firstp);                                       /* do the erase */
    return(TRUE);
}
/*****************************************************************************
//F GetAngle
//S Get the angle between two points
//D Get the angle between two points
//P The X coordinate of the first point
//P The Y coordinate of the first point
//P The second point
//R The angle between the two points
/*****************************************************************************/
double GetAngle(NUMB x,NUMB y,XYPOINT *b)
{
    double dx=b->X-x;   /* delta x */
    double dy=b->Y-y;   /* delta y */
    if ((dx==0)&&(dy==0)) return 0;         /* avoid domain error in atan2() */
    /* return angle so that top=0 right=90 bottom=180 left=270 degrees */
    return 180.0-(atan2(dx,dy)*(180.0/M_PI));
}
/*****************************************************************************
//F YAdjRect
//S Merge two adjacent rectangles of the same height
//D Merge two adjacent rectangles of the same height
//P The Current rectangle
//P The list of all rectangles
//R TRUE if the rectangle was merged with an adjacent one
/*****************************************************************************/
BOOL YAdjRect(PLIST *p,PLIST *l)
{
    PLIST *lastl;   /* previous point in list */

    while (l!=NULL) {
        lastl=l;
        l=l->next;
        if (l!=NULL) {
            /* rectangles same width and start pos */
            if ((l!=p)&&(l->X==p->X)&&(l->X1==p->X1)) {
                /* touching along bottom edge */
                if ((l->Y==p->Y1)||(l->Y==p->Y1+1)) { 
                    p->Y1=l->Y1;         /* adjust edge down */
                    lastl->next=l->next; /* remove rectangle form list */
                    free(l);
                    return(TRUE); /* found touching rectangle */
                }
                /* touching along top edge */
                if ((l->Y1==p->Y)||(l->Y1+1==p->Y)) {
                    p->Y=l->Y;           /* adjust edge up */
                    lastl->next=l->next; /* remove rectangle form list */
                    free(l);
                    return(TRUE); /* found touching rectangle */
                }
            }    
            l=l->next;
        }
    }
    return (FALSE); /* did not find touching rectangle */
}
#ifndef DLL_BUILD                         
/*****************************************************************************
//F EraseRect
//S Call the GMLI erase_region command for each rectangle in the list
//D Call the GMLI erase_region command for each rectangle in the list, as each
//D region is erased free the memory associated with the rectangle's list entry
//P The first element in the rectangle point list
/*****************************************************************************/
void EraseRect(PLIST *p)
{
    PLIST *prev;                      /* spare pointer for removing blocks */
    char command[GMLI_MAX_PARM_SIZE]; /* space for command block */
    while (p!=NULL) {

        /* call to GML to erase region */
        sprintf(command,"erase area (%f,%f)(%f,%f)\n",
            (double)p->X,(double)p->Y,(double)p->X1,(double)p->Y1);

        if (!gmli_call_appl(command)) { /* error in call */
            msg_issue("erase_polygon: erase area failed",'e');
            return; 
        }

        prev=p;
        p=p->next;
        free(prev);   /* free used block */
    }
}
#endif
/****************************************************************************/
/*                               End of file                                */
/****************************************************************************/

