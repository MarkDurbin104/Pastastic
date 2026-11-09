#include "epr_util.h"

typedef long NUMB;
#define ATON atol

typedef int BOOL;
#define FALSE 0
#define TRUE  1

typedef struct {
    NUMB X;
    NUMB Y;
} XYPOINT;

typedef struct Plist {
    NUMB X;
    NUMB Y;
    NUMB X1;
    NUMB Y1;
    struct Plist *next;
} PLIST;

PLIST *G_firstp=NULL;

#define INCREMENT 2

BOOL    DoPolyErase     (XYPOINT *poly,int numply);
void    EraseRect       (PLIST *p);
void    ClearList       (PLIST *p);
double  GetAngle        (NUMB x,NUMB y,XYPOINT *b);
BOOL    BetweenInterSections(NUMB x,NUMB y,XYPOINT *poly,int numply);
PLIST * AddRect         (PLIST *p,NUMB x,NUMB y,NUMB x1,NUMB y1);
int     XAdjRect        (PLIST *p,PLIST *l);
BOOL    DoPolyErase     (XYPOINT *poly,int numply);
void    EraseRect       (PLIST *p);

BOOL    erase_polygon   (void);

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
        polypoint=malloc((int)numpolypoint*sizeof(XYPOINT));
        if (polypoint==NULL) {
            msg_issue("erase_polygon: Insuficent Memory for this operation",'e');
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
            if (!DoPolyErase(polypoint,(int)numpolypoint)) {
                msg_issue("erase_polygon: Erase Failed!",'e');
                return(FALSE);
            }
            return(FALSE);
        }
    }
    return(TRUE);
}
BOOL DoPolyErase(poly,numply)
XYPOINT *poly;
int numply;
{
    static NUMB minX,minY,maxX,maxY,tmpx,tmpy;
    int j,found;
    XYPOINT *cp;
    static PLIST *pnts=NULL;
    pnts=NULL;
    cp=poly;
    tmpx=(int)cp->X;
    tmpy=(int)cp->Y;
    minX=tmpx;
    minY=tmpy;
    maxX=tmpx;
    maxY=tmpy;
    for (j=1;j<numply;j++) {
        cp++;
        tmpx=(int)cp->X;                 
        tmpy=(int)cp->Y;
        minX=min(minX,tmpx);
        minY=min(minY,tmpy);
        maxX=max(maxX,tmpx);
        maxY=max(maxY,tmpy);
    }
    for (tmpx=minX;tmpx<maxX;tmpx+=INCREMENT) {
        for (tmpy=minY;tmpy<maxY;tmpy+=INCREMENT) {
            if (BetweenInterSections(tmpx,tmpy,poly,numply)) {
                if ((pnts!=NULL)&&(pnts->X==tmpx)&&(pnts->Y1==tmpy)) {
                    pnts->Y1=tmpy+INCREMENT;
                } else {
                    pnts=AddRect(pnts,tmpx,tmpy,tmpx+INCREMENT,tmpy+INCREMENT);
                }
            }
        }
    }
    pnts=G_firstp;
    found=0;
    while (pnts!=NULL) {
        if (XAdjRect(pnts,G_firstp)) found++;
        pnts=pnts->next;
    }
    EraseRect(G_firstp);
    return(TRUE);
}
void EraseRect(p)
PLIST *p;
{
    char command[GMLI_MAX_PARM_SIZE];
    while (p!=NULL) {
        sprintf(command,"erase area (%ld,%ld)(%ld,%ld)\n",p->X,p->Y,p->X1,p->Y);
        if (!gmli_call_appl(command)) {
            msg_issue("erase_polygon: erase area failed",'e');
            return;
        } 
        p=p->next;
    }
}

void ClearList(p)
PLIST *p;
{
    PLIST *cp;
    while (p!=NULL) {
        cp=p;
        p=p->next;
        free(cp);
    }
}
double GetAngle(x,y,b)
NUMB x;
NUMB y;
XYPOINT *b;
{
    double dx=b->X-x;
    double dy=b->Y-y;
    if ((dx==0)&&(dy==0)) return 0;
    return 180.0-(atan2(dx,dy)*(180.0/M_PI));
}
BOOL BetweenInterSections(x,y,poly,numply)
NUMB x;
NUMB y;
XYPOINT *poly;
int numply;
{
    char t=0,b=0,l=0,r=0;
    char p1q,p2q;
    int a1,a2;
    int i;

    a2=GetAngle(x,y,poly);
    p2q=a2/90;
    for (i=0;i<numply-1;i++) {
        poly++;                  
        a1=a2; p1q=p2q;
        a2=GetAngle(x,y,poly); p2q=a2/90; 
        switch (p1q) {
            case 0 :
                switch (p2q) {
                    case 1 : r++; break; case 3 : t++; break;
                    case 2 : if (a1%90>a2%90) { r++; b++; } else { l++; t++; } break;
                }               
                break;
            case 1 :
                switch (p2q) {
                    case 0 : r++; break; case 2 : b++; break;
                    case 3 : if (a1%90>a2%90) { l++; b++; } else { r++; t++; } break;
                }               
                break;
            case 2 :
                switch (p2q) {
                    case 1 : b++; break; case 3 : l++; break;
                    case 0 : if (a1%90>a2%90) { l++; t++; } else { r++; b++; } break;
                }               
                break;
            case 3 :
                switch (p2q) {
                    case 0 : t++; break; case 2 : l++; break;
                    case 1 : if (a1%90>a2%90) { r++; t++; } else { l++; b++; } break;
                }               
                break;
        }
    }
    return r&l&b&t&1;
}
PLIST * AddRect(p,x,y,x1,y1)
PLIST *p;
NUMB x;
NUMB y;
NUMB x1;
NUMB y1;
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
int XAdjRect(p,l)
PLIST *p;
PLIST *l;
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
                    return(1);
                }
                if ((l->X1==p->X)||(l->X1+1==p->X)) {
                    p->X=l->X;
                    lastl->next=l->next;
                    free(l);
                    return(1);
                }
            }    
            l=l->next;
        }
    }
    return (0);
}
