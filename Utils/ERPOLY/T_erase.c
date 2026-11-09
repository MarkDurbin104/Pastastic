/****************************************************************************/
/*  Module                                                                  */
/*   ERASEPLY.C                                                             */
/*                                                                          */
/*  Synopsys                                                                */
/*   Erase the area within an irregular polygon using rectangular regions.  */
/*                                                                          */
/*  Description                                                             */
/*   This module contains four methods for erasing polygons, each selected  */
/*   by setting the global variable G_erasetype to one of four values (0-3) */
/*   in general the best setting is 0 (RLE_ERASE)                           */
/*                                                                          */
/*   Certain sections of this module are included/excluded via the define   */
/*   DLL_BUILD these are for building the module as a callable DLL for      */
/*   testing under DOS/Windows.  If you are removing these sections please  */
/*   take care to check if they are included (#ifdef) of excluded (#ifndef) */
/*   before deleting the section.                                           */
/*                                                                          */
/*  Function List                                                           */
/*   AddRect           BetweenInterSections BQuadPolyErase  DoPolyErase     */
/*   EraseRect         erase_polygon        GetBoundingRect GetDistance     */
/*   GetPoint          NoPointsInRect       PointPolyErase  QuadPolyErase   */
/*   RecursiveMarkQuad RemoveJoiningRects   RlePolyErase    XAdjRect        */
/*   YAdjRect                                                               */
/*                                                                          */
/*  Author                                                                  */
/*   M.J.Durbin                                                             */
/*   Unisys Ltd.                                                            */
/*   22 Southwark Bridge Road                                               */
/*   London SE1 9HB                                                         */
/*                                                                          */
/*  Modification History                                                    */
/*   Release  Date     Who           Comment                                */
/*   0.00     26/01/96 MJD           Initial Release                        */
/*                                                                          */
/*                                                                          */
/****************************************************************************/





/****************************************************************************/
/*                         Includes Section                                 */
/****************************************************************************/
#include <stdio.h>   /* required for sprintf(), NULL                        */      
#include <stdlib.h>  /* required for atol()                                 */      
#include <string.h>  /* required for strcpy()                               */
#include <malloc.h>  /* required for malloc(), free()                       */
#include <math.h>    /* required for atan2(), sin(), cos(), sqrt(), M_PI    */

#include "epr_util.h" 

#ifdef DLL_BUILD
#include <time.h>    /* used for timing information */
#endif              

/****************************************************************************/
/*                      Defines/TypeDefs Section                            */
/****************************************************************************/
#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#define min(a,b) (((a)>(b))?(a):(b))
#endif

typedef long NUMB;       /* redefine to change number type used throughout  */
#define ATON atol        /* redefine to change number type used throughout  */

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


#define RLE_ERASE    0   /* defines for the four poly erase function types  */
#define QUAD_ERASE   1
#define BQUAD_ERASE  2
#define POINT_ERASE  3

#define INCREMENT    1   /* The smallest rectangular region width/height    */

#ifndef GMLI_MAX_PARM_SIZE     /* needed to test ANSI compile */
#define GMLI_MAX_PARM_SIZE 256
#endif

/****************************************************************************/
/*                            Prototypes Section                            */
/****************************************************************************/
extern BOOL    gmli_get_value  (char *paramblk);       /* needed to test ANSI compile */
extern BOOL    gmli_call_appl  (char *paramblk);       /* needed to test ANSI compile */
extern void    msg_issue       (char *err,char state); /* needed to test ANSI compile */

void     EraseRect           (PLIST *p);
XYPOINT *GetPoint            (NUMB distance,NUMB angle);
double   GetAngle            (NUMB x,NUMB y,XYPOINT *b);
NUMB     GetDistance         (XYPOINT *pa,XYPOINT *pb);
BOOL     BetweenInterSections(NUMB x,NUMB y,XYPOINT *poly,int numply);
PLIST *  AddRect             (PLIST *p,NUMB x,NUMB y,NUMB x1,NUMB y1);
BOOL     XAdjRect            (PLIST *p,PLIST *l);
BOOL     YAdjRect            (PLIST *p,PLIST *l);
void     GetBoundingRect     (NUMB *minX,NUMB *minY,NUMB *maxX,NUMB *maxY,XYPOINT *poly,int numply);
void     RemoveJoiningRects  (void);
BOOL     DoPolyErase         (XYPOINT *poly,int numply,int type);
BOOL     RlePolyErase        (XYPOINT *poly,int numply);
BOOL     NoPointsInRect      (NUMB x,NUMB y,NUMB x1,NUMB y1,XYPOINT *poly,int numply);
PLIST *  RecursiveMarkQuad   (XYPOINT *poly,int numply,NUMB x,NUMB y,NUMB x1,NUMB y1,PLIST *pnts);
BOOL     QuadPolyErase       (XYPOINT *poly,int numply);
BOOL     BQuadPolyErase      (XYPOINT *poly,int numply);
BOOL     PointPolyErase      (XYPOINT *poly,int numply);
BOOL     erase_polygon       (void);

/****************************************************************************/
/*                          Global Variables Section                        */
/****************************************************************************/
int      G_erasetype=RLE_ERASE; /* current polygon erase function type      */
PLIST  * G_firstp=NULL;         /* the first rectangle in the point list    */

#ifdef DLL_BUILD
 NUMB    G_numrect=0; /* used for statistics (number of rectangles)         */
 NUMB    G_aarect=0;  /* used for statistics (average area of rectangles)   */
 time_t  G_start,G_end;
#endif

typedef int (*QSPTR)(const void*, const void*);
#define NUMLOOK 127
char G_lookup[NUMLOOK];

/****************************************************************************/
/*                   Function Definition Section                            */
/****************************************************************************/


/*****************************************************************************
//F erase_polygon
//S erase a polygon using rectangular regions
//D This function is called repeatedly to collect arguments off the command
//D line from GMLI on the first call the two parameters "add" and the
//D number of polygons should be passed. On subsiquent calls the parameters
//D should be the X and Y co-ordinates of one point in the polygon.  When
//D all the points have been collected this function then calls DoPolyErase
//D to do the work and then it frees the memory allocated for the polygon
//D points and returns FALSE.  Any failure will also return FALSE
//R TRUE if more parameters are required else FALSE
//P*/
BOOL erase_polygon(void)
{
    char parameter[GMLI_MAX_PARM_SIZE];
    static int state=0;
    static XYPOINT *polypoint=NULL;
    static NUMB numpolypoint=0;
    static NUMB currentpolypoint;

    if (!gmli_get_value(parameter)) {
        msg_issue("erase_polygon: Failed to get parameter",'e');
        state=0;
        return(FALSE);
    }
    if (state==0) {
        if (strcmp(parameter,"add")) {
            msg_issue("erase_polygon: parameter out of sequence",'e');
            return(FALSE);
        }
        if (!gmli_get_value(parameter)) {
            msg_issue("erase_polygon: Failed to get parameter",'e');
            return(FALSE);
        }
        numpolypoint=ATON(parameter);
        if (numpolypoint<=0) {
            msg_issue("erase_polygon: Invalid number of poly points",'e');
            return(FALSE);
        }
        currentpolypoint=0;
        if (polypoint!=NULL) free(polypoint);
        polypoint=malloc((int)numpolypoint*sizeof(XYPOINT));
        if (polypoint==NULL) {
            msg_issue("erase_polygon: Insufficient Memory for this operation",'e');
            return(FALSE);
        }
        state++;
    } else {
        polypoint[(int)currentpolypoint].X=ATON(parameter);
        if (!gmli_get_value(parameter)) {
            state=0;
            msg_issue("erase_polygon: Failed to get parameter",'e');
            return(FALSE);
        }
        polypoint[(int)currentpolypoint].Y=ATON(parameter);
        currentpolypoint++;
        if (currentpolypoint==numpolypoint) {
            state=0;
            if (!DoPolyErase(polypoint,(int)numpolypoint,G_erasetype)) {
                msg_issue("erase_polygon: Erase Failed!",'e');
            }
            if (polypoint!=NULL) free(polypoint);
            polypoint=NULL;
            G_firstp=NULL;
            return(FALSE);
        }
    }
    return(TRUE);
}
/*****************************************************************************
//F GetBoundingRect
//S Get the bounding rectangle of the polygon
//D Get the bounding rectangle of the polygon by parsing all the polygon 
//D points to find the minimum and maximum X & Y co-ordinates
//P The address of returned top left X co-ordinate 
//P The address of returned top left Y co-ordinate
//P The address of returned bottom right X co-ordinate
//P The address of returned bottom right Y co-ordinate
//P The polygon points
//P The number of points in the polygon
//R */
void GetBoundingRect(NUMB *x,NUMB *y,NUMB *x1,NUMB *y1,XYPOINT *poly,int numply)
{
    NUMB minX,minY,maxX,maxY;
    NUMB tmpx,tmpy;
    XYPOINT *cp;
    int j;
    cp=poly;
    maxX=minX=cp->X;
    maxY=minY=cp->Y;
    for (j=1;j<numply;j++) {
        cp++;
//        tmpx=cp->X;
//        if (tmpx<minX) {
//            minX=tmpx;
//        } else if (tmpx>maxX) {
//            maxX=tmpx;
//        }
        tmpy=cp->Y;
        if (tmpy<minY) {
            minY=tmpy;
        } else if (tmpy>maxY) {
            maxY=tmpy;
        }
    }
    *x=minX;
    *y=minY;
    *x1=maxX;
    *y1=maxY;
}
/*****************************************************************************
//F DoPolyErase
//S Call the polygon erase function defined by 'type'
//D after all the polygon points have been collected  this function is called
//D erase the rectangular regions within it
//P The polygon points
//P The number of points in the polygon
//P The erase function type
//R FALSE on error                                                           */
BOOL DoPolyErase(XYPOINT *poly,int numply,int type)
{
    BOOL ret=FALSE;
#ifdef DLL_BUILD
 FILE *fp;
#endif
    switch (type) {
        case RLE_ERASE :
            ret=RlePolyErase(poly,numply);
            break;
        case QUAD_ERASE :
            ret=QuadPolyErase(poly,numply);
            break;
        case BQUAD_ERASE :
            ret=BQuadPolyErase(poly,numply);
            break;
        case POINT_ERASE :
            ret=PointPolyErase(poly,numply);
            break;
    }
#ifdef DLL_BUILD
 if ((fp=fopen("RESULTS.DAT","w"))==NULL) return(FALSE);
 fprintf(fp,"%ld Rectangles. Average area %ld. Time %ld seconds. Style %s\n",G_numrect,G_aarect,G_end-G_start,
     ((type==0)?"RlePolyErase":((type==1)?"QuadPolyErase":((type==2)?"BQuadPolyErase":((type==3)?"PointPolyErase":"Unknown")))));
 fclose(fp);                                                                                                              
#endif
    return(ret);
}
int Imcmp(NUMB *a,NUMB *b)
{
    if (*a==*b) return 0;
    if (*a>*b) return 1;
    return -1;
}
NUMB *GetPointsofIntersection(NUMB y,XYPOINT *poly,int numply)
{
    static NUMB *Imap=NULL;
    int i,iofs;
    NUMB angle;

    if (Imap==NULL) Imap=malloc(100*sizeof(NUMB));

    if (y<0) {          // -tive y - free used memory
        free(Imap);
        Imap=NULL;
        return(Imap);
    }

    iofs=0;
    for (i=0;i<numply-1;i++) {
        if (((poly->Y<y)&&((poly+1)->Y>=y))||((poly->Y>=y)&&((poly+1)->Y<y))) {
            angle=GetAngle(poly->X,poly->Y,poly+1);
            Imap[iofs++]=poly->X-tan(angle*(M_PI/180.0))*(y-poly->Y);
        }                
        poly++;
    }
    if (iofs) qsort(Imap,iofs,sizeof(NUMB),(QSPTR)Imcmp);
    Imap[iofs++]=(-1);
    Imap[iofs++]=(-1);
    return(Imap);
}

/*****************************************************************************
//F RlePolyErase
//S erase the polygon by passing over each point and joining adjacent points
//D erase the polygon by passing over each point in the polygon in the 
//D direction top to bottom and then moving right. If a point is found to be 
//D within the polygon it is either added to a list of rectangles or if the
//D rectangle above is within the polygon it's lower bound is increased
//D once the entire polygon has been covered, any adjacent rectangles of 
//D the same height are merged.
//P The polygon points
//P The number of points in the polygon
//R always TRUE                                                              */
BOOL RlePolyErase(XYPOINT *poly,int numply)
{
    NUMB minX,minY,maxX,maxY;
    NUMB tmpy;
    NUMB *imap;
    PLIST p;
    PLIST *pnts=&p;
    pnts->X =-1;

#ifdef DLL_BUILD
 G_start=time(NULL);
#endif
    GetBoundingRect(&minX,&minY,&maxX,&maxY,poly,numply);

    for (tmpy=minY;tmpy<maxY;tmpy+=INCREMENT) {
        imap=GetPointsofIntersection(tmpy,poly,numply);
        while ((imap!=NULL)&&(*imap>0)&&(*(imap+1)>0)) {
            if ((pnts=malloc(sizeof(PLIST)))==NULL) return(FALSE);
            pnts->X =*(imap++);
            pnts->Y =tmpy;
            pnts->X1=*(imap++);
            pnts->Y1=tmpy+INCREMENT;
            pnts->next=G_firstp;
            G_firstp=pnts;
        }
    }
    GetPointsofIntersection(-1,NULL,0); // free used memory
    pnts=G_firstp;
    while (pnts!=NULL) {
        YAdjRect(pnts,G_firstp);
        pnts=pnts->next;
    }
#ifdef DLL_BUILD
 G_end=time(NULL);
#endif
    EraseRect(G_firstp);
    return(TRUE);
}
/*****************************************************************************
//F NoPointsInRect
//S Check if any of the polygon points are within a rectangular region
//D Check if any of the polygon points are within a rectangular region
//P The region top left X co-ordinate
//P The region top left Y co-ordinate
//P The region bottom right X co-ordinate
//P The region bottom right Y co-ordinate
//P The polygon points
//P The number of points in the polygon
//R TRUE if there are No Poly Points In the Rectangle, otherwise FALSE      */
BOOL NoPointsInRect(NUMB x,NUMB y,NUMB x1,NUMB y1,XYPOINT *poly,int numply)
{
    NUMB tx,ty;
    XYPOINT *cp;
    int j;
    cp=poly;
    for (j=0;j<numply;j++) {
        tx=(int)cp->X;                 
        ty=(int)cp->Y;
        if ((tx>x)&&(ty>y)&&(tx<x1)&&(ty<y1)) return(FALSE);
        cp++;
    }
    return(TRUE);
}
/*****************************************************************************
//F RecursiveMarkQuad
//S Recursively mark regions as being within a polygon
//D Recursively mark regions as being within a polygon by starting with a 
//D rectangle that forms the bounding rectangle of the polygon if the 
//D rectangle's four corners are not within the polygon or there are points 
//D of the polygon within the rectangle then the rectangle is subdivided into
//D four parts and the function recurses for each part.
//P The polygon points
//P The number of points in the polygon
//P The region top left X co-ordinate
//P The region top left Y co-ordinate
//P The region bottom right X co-ordinate
//P The region bottom right Y co-ordinate
//P A list of regions within the polygon
//R The last element in the list of regions within the polygon               */
PLIST *RecursiveMarkQuad(XYPOINT *poly,int numply,NUMB x,NUMB y,NUMB x1,NUMB y1,PLIST *pnts)
{
    NUMB tx,ty;
    if ( (BetweenInterSections(x ,y ,poly,numply))
    &&   (BetweenInterSections(x ,y1,poly,numply))
    &&   (BetweenInterSections(x1,y ,poly,numply))
    &&   (BetweenInterSections(x1,y1,poly,numply))
    &&   (NoPointsInRect(x ,y ,x1,y1,poly,numply)) ) {
        pnts=AddRect(pnts,x,y,x1,y1);
    } else {
        tx=(x1-x)/2;
        if (tx<INCREMENT) return(pnts);
        tx+=x;
        ty=(y1-y)/2;
        if (ty<INCREMENT) return(pnts);
        ty+=y;
        pnts=RecursiveMarkQuad(poly,numply,x ,y ,tx,ty,pnts);
        pnts=RecursiveMarkQuad(poly,numply,tx,y ,x1,ty,pnts);
        pnts=RecursiveMarkQuad(poly,numply,x ,ty,tx,y1,pnts);
        pnts=RecursiveMarkQuad(poly,numply,tx,ty,x1,y1,pnts);
    }
    return(pnts);
}
/*****************************************************************************
//F QuadPolyErase
//S erase the polygon using the RecursiveMarkQuad function
//D erase the polygon using the RecursiveMarkQuad function
//P The polygon points
//P The number of points in the polygon
//R always TRUE                                                              */
BOOL QuadPolyErase(XYPOINT *poly,int numply)
{
    NUMB minX,minY,maxX,maxY;
    PLIST *pnts=NULL;

    GetBoundingRect(&minX,&minY,&maxX,&maxY,poly,numply);
    RecursiveMarkQuad(poly,numply,minX,minY,maxX,maxY,pnts);
    RemoveJoiningRects();
    EraseRect(G_firstp);
    return(TRUE);
}
/*****************************************************************************
//F BQuadPolyErase
//S Better (i.e. more acurate - And Slower) QuadPolyErase function
//D erase the polygon using the RecursiveMarkQuad function but first make a
//D polygon that contains all the posible points in it's perimiter
//P The polygon points
//P The number of points in the polygon
//R Return Value from QuadPolyErase                                         */
BOOL BQuadPolyErase(XYPOINT *poly,int numply)
{
    XYPOINT *fullpoly;
    XYPOINT *polyptr;
    XYPOINT *tmppoly;
    XYPOINT *tmpfpoly;
    int numfply=0;
    int i;
    NUMB j;
    NUMB dist;
    NUMB angle;
    BOOL result;

    polyptr=poly;
    for (i=0;i<numply-1;i++) {
        numfply+=(int)((GetDistance(polyptr,polyptr+1)/INCREMENT)+1);
        polyptr++;
    }
    fullpoly=malloc(numfply*sizeof(XYPOINT));
    if (fullpoly==NULL) return(FALSE);

    polyptr=poly;
    tmpfpoly=fullpoly;
    for (i=0;i<numply-1;i++) {
        dist=GetDistance(polyptr,polyptr+1);
        angle=GetAngle(polyptr->X,polyptr->Y,polyptr+1);
        for (j=0;j<=dist;j+=INCREMENT) {
            tmppoly=GetPoint(j,angle);
            tmpfpoly->X=polyptr->X+tmppoly->X;
            tmpfpoly->Y=polyptr->Y+tmppoly->Y;
            tmpfpoly++;
        }   
        polyptr++;
    }
    result=QuadPolyErase(fullpoly,numfply);
    free(fullpoly);
    return(result);
}
/*****************************************************************************
//F PointPolyErase
//S erase the polygon by passing over each point and joining adjacent points
//D Similar to RlePolyErase but the Y lengths are not joined on the first parse
//D and then X and Y adjcent rectangles are merged alternatly.
//P The polygon points
//P The number of points in the polygon
//R always TRUE                                                              */
BOOL PointPolyErase(XYPOINT *poly,int numply)
{
    NUMB minX,minY,maxX,maxY;
    NUMB tmpx,tmpy;
    PLIST *pnts=NULL;

    GetBoundingRect(&minX,&minY,&maxX,&maxY,poly,numply);

    for (tmpx=minX;tmpx<maxX;tmpx+=INCREMENT) {
        for (tmpy=minY;tmpy<maxY;tmpy+=INCREMENT) {
            if (BetweenInterSections(tmpx,tmpy,poly,numply)) {
                pnts=AddRect(pnts,tmpx,tmpy,tmpx+INCREMENT,tmpy+INCREMENT);
            }
        }
    }
    RemoveJoiningRects();
    EraseRect(G_firstp);
    return(TRUE);
}
/*****************************************************************************
//F RemoveJoiningRects
//S Merge all rectangles that have equal length touching sides
//D Merge all rectangles that have equal length touching sides
//R */
void RemoveJoiningRects(void)
{
    BOOL found;
    PLIST *pnts=NULL;
    do {
        found=FALSE;
        pnts=G_firstp;
        while (pnts!=NULL) {
            if (XAdjRect(pnts,G_firstp)) found=TRUE;
            if (YAdjRect(pnts,G_firstp)) found=TRUE;
            pnts=pnts->next;
        }
    } while (found);
}
#ifndef DLL_BUILD
/*****************************************************************************
//F EraseRect
//S Call the GMLI erase_region command for each rectangle in the list
//D Call the GMLI erase_region command for each rectangle in the list, as each
//D region is erased free the memory associated with the rectangle's list entry
//P The first element in the rectangle point list
//R */
void EraseRect(PLIST *p)
{
    PLIST *l;
    char command[GMLI_MAX_PARM_SIZE];
    while (p!=NULL) {
        sprintf(command,"erase area (%f,%f)(%f,%f)\n",(double)p->X,(double)p->Y,(double)p->X1,(double)p->Y);
        if (!gmli_call_appl(command)) {
            msg_issue("erase_polygon: erase area failed",'e');
            return;
        }
        l=p;
        p=p->next;
        free(l);
    }
}
#endif
/*****************************************************************************
//F GetPoint
//S Get an X/Y Co-ordinate from a distance and angle (based at 0,0)
//D Get an X/Y Co-ordinate from a distance and angle (based at 0,0)
//P The distance
//P The angle
//R Point structure containing the co-ordinates                              */
XYPOINT *GetPoint(NUMB distance,NUMB angle)
{
    static XYPOINT point;
    point.X=(sin(angle*(M_PI/180.0))*distance);
    point.Y=0-(cos(angle*(M_PI/180.0))*distance);
    return (&point);
}
/*****************************************************************************
//F GetDistance
//S Get the distance between two points
//D Get the distance between two points
//P The first point
//P The second point
//R The distance between the two points                                      */
NUMB GetDistance(XYPOINT *pa,XYPOINT *pb)
{
    double dx=pb->X-pa->X;
    double dy=pb->Y-pa->Y;
    return((NUMB)sqrt((dx*dx)+(dy*dy)));
}
/*****************************************************************************
//F GetAngle
//S Get the angle between two points
//D Get the angle between two points
//P The X cordinate of the first point
//P The Y cordinate of the first point
//P The second point
//R The angle between the two points                                         */
double GetAngle(NUMB x,NUMB y,XYPOINT *b)
{
    NUMB dx=b->X-x;
    NUMB dy=b->Y-y;
    if (dx==0) {
        if (dy<=0) return 0;
        return 180;
    }
    if (dy==0) {
        if (dx<=0) return 270;
        return 90;
    }
    return 180.0-(atan2(dx,dy)*(180.0/M_PI));
}
/*****************************************************************************
//F BetweenInterSections
//S Find if a point is within a polygon
//D Find if a point is within a polygon by seeing the number of times a
//D line projected from the point at 90 degrees dissects the 
//D polygon perimiter. If the number of dissections
//D is odd then the point is within the polygon
//P The X cordinate of the point
//P The Y cordinate of the point
//P The poly points
//P The number of poly points
//R TRUE if the point is within the polygon                                  */
BOOL BetweenInterSections(NUMB x,NUMB y,XYPOINT *poly,int numply)
{
    char r=0;
    int a1,a2;
    int i;

    for (i=0;i<numply-1;i++) {
        if ((poly->X>x)||((poly+1)->X>x)) {
            a1=GetAngle(x,y,poly);
            poly++;
            a2=GetAngle(x,y,poly);
            switch (a1/90) {
                case 0 :
                    switch (a2/90) {
                        case 1 : r++; break;
                        case 2 : if ((a1%90)>(a2%90)) r++; break;
                    }               
                    break;
                case 1 :
                    switch (a2/90) {
                        case 0 : r++; break;
                        case 3 : if ((a1%90)<(a2%90)) r++;break;
                    }               
                    break;
                case 2 :
                    switch (a2/90) {
                        case 0 : if ((a1%90)<(a2%90)) r++; break;
                    }               
                    break;
                case 3 :
                    switch (a2/90) {
                        case 1 : if ((a1%90)>(a2%90)) r++; break;
                    }               
                    break;
            }
        } else {
            poly++;
        }
    }
    return r&1;
}
/*****************************************************************************
//F AddRect
//S Add a rectangle to the linked list
//D Add a rectangle to the linked list
//P The last element in the list
//P The X cordinate of the top left point
//P The Y cordinate of the top left point
//P The X cordinate of the bottom right point
//P The Y cordinate of the bottom right point
//R the new last element in the list                                         */
PLIST * AddRect(PLIST *p,NUMB x,NUMB y,NUMB x1,NUMB y1)
{
    if (p==NULL) {
        if ((p=malloc(sizeof(PLIST)))==NULL) return(NULL);
        G_firstp=p;
        p->X =x;
        p->Y =y;
        p->X1=x1;
        p->Y1=y1;
        p->next=NULL;
    } else {
        if ((p->next=malloc(sizeof(PLIST)))==NULL) return(p);
        p=p->next;
        p->X =x;
        p->Y =y;
        p->X1=x1;
        p->Y1=y1;
        p->next=NULL;
    }
    return(p);
}
/*****************************************************************************
//F XAdjRect
//S Merge two adjacent rectangle of the same height
//D Merge two adjacent rectangle of the same height
//P The Current rectangle
//P The list of all rectangles
//R TRUE if the rectangle was merged with an adjacent one                    */
BOOL XAdjRect(PLIST *p,PLIST *l)
{
    PLIST *lastl;

    while (l!=NULL) {
        lastl=l;
        l=l->next;
        if (l!=NULL) {
            if ((l!=p)&&(l->Y==p->Y)&&(l->Y1==p->Y1)) {
                if ((l->X==p->X1)||(l->X==p->X1+1)) {
                    p->X1=l->X1;
                    lastl->next=l->next;
                    free(l);
                    return(TRUE);
                }
                if ((l->X1==p->X)||(l->X1+1==p->X)) {
                    p->X=l->X;
                    lastl->next=l->next;
                    free(l);
                    return(TRUE);
                }
            }    
            l=l->next;
        }
    }
    return (FALSE);
}
/*****************************************************************************
//F XAdjRect
//S Merge two adjacent rectangle of the same width
//D Merge two adjacent rectangle of the same width
//P The Current rectangle
//P The list of all rectangles
//R TRUE if the rectangle was merged with an adjacent one                    */
BOOL YAdjRect(PLIST *p,PLIST *l)
{
    PLIST *lastl;

    while (l!=NULL) {
        lastl=l;
        l=l->next;
        if (l!=NULL) {
            if ((l!=p)&&(l->X==p->X)&&(l->X1==p->X1)) {
                if ((l->Y==p->Y1)||(l->Y==p->Y1+1)) {
                    p->Y1=l->Y1;
                    lastl->next=l->next;
                    free(l);
                    return(TRUE);
                }
                if ((l->Y1==p->Y)||(l->Y1+1==p->Y)) {
                    p->Y=l->Y;
                    lastl->next=l->next;
                    free(l);
                    return(TRUE);
                }
            }    
            l=l->next;
        }
    }
    return (FALSE);
}
/****************************************************************************/
/*                               End of file                                */
/****************************************************************************/
