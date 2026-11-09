#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include <memory.h>
#include <time.h>

//typedef double NUMB;
//#define ATON   atof
typedef int BOOL;
typedef long NUMB;
#define ATON atol
#define FALSE 0
#define TRUE  1
#define RIGHT 0
#define UPWARD 1

typedef struct { NUMB X; NUMB Y;} XYPOINT;
typedef struct Plist {
    NUMB X;
    NUMB Y;
    NUMB X1;
    NUMB Y1;
    struct Plist *next;
} PLIST;

BOOL  LoadPoints           (char *pfile,XYPOINT **p);
void ErasePoly            (XYPOINT *poly,int numply,int pass,HWND hwnd);
void SavePoints           (PLIST *p);
void clearlist            (PLIST *p);


//PLIST *FirstP=NULL;
PLIST *ExcludeP=NULL;
long G_increment;
#define INCREMENT 2
#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
  return 1;
}
#pragma warn +par
void FAR PASCAL _export ErasePoints(HWND hwnd,int pass)
{
//    time_t s,e;
//    char tmp[40];
    static int numpoly;
    static XYPOINT *poly=NULL;
//    sprintf(tmp,"Pass (%d)",pass);
//    MessageBox(hwnd,tmp,"Message",MB_OK|MB_ICONINFORMATION);
    if (pass==0) {
        if (poly!=NULL) free(poly);
        clearlist(ExcludeP);
        numpoly=LoadPoints("POLYLIST.DAT",&poly);
        if (numpoly==0) {
    	    MessageBox(hwnd,"No Points in Polygon","Message",MB_OK|MB_ICONINFORMATION);
            return;
        }
    }
    ErasePoly(poly,numpoly,pass,hwnd);
}

void clearlist(PLIST *p)
{
    PLIST *cp;
    while (p!=NULL) {
        cp=p;
        p=p->next;
        free(cp);
    }
}
BOOL LoadPoints(char *pfile,XYPOINT **p)
{
    FILE *fp;
    char tmp[100],*s;
    int i=0;

    if ((fp=fopen(pfile,"r"))==NULL) return 0;

    i=0; while (fgets(tmp,100,fp)!=NULL) i++;
    fseek(fp,0L,SEEK_SET);
    *p=malloc(i*sizeof(XYPOINT));

    if (*p==NULL) {
        fclose(fp);
        return 0;
    }

    i=0;
    while (fgets(tmp,100,fp)!=NULL) {
        s=strtok(tmp,", \r\n");
        if (s!=NULL) {
           (*p)[i].X=ATON(s);
           s=strtok(NULL,", \r\n");
           if (s!=NULL) {
              (*p)[i++].Y=ATON(s);
           }
        }
    }
    fclose(fp);

    return i;
}
double GetAngle(NUMB x,NUMB y,XYPOINT *b)
{
    double dx=b->X-x;
    double dy=b->Y-y;
    if ((dx==0)&&(dy==0)) return 0;
    return 180.0-(atan2(dx,dy)*(180.0/M_PI));
}
BOOL BetweenInterSections(NUMB x,NUMB y,XYPOINT *poly,int numply)
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
PLIST * addrect(PLIST *p,NUMB x,NUMB y,NUMB x1,NUMB y1)
{
    if (p==NULL) {
        p=malloc(sizeof(PLIST));
        if (p==NULL) return(NULL);
        ExcludeP=p;
        p->X =x;
        p->Y =y;
        p->X1=x1;
        p->Y1=y1;
        p->next=NULL;
    } else {
        p->next=malloc(sizeof(PLIST));
        if (p->next==NULL) return(p);
        p=p->next;
        p->X =x;
        p->Y =y;
        p->X1=x1;
        p->Y1=y1;
        p->next=NULL;
    }
    return(p);
}
void RemoveRectat(NUMB x,NUMB y)
{
    PLIST *p=ExcludeP;
    PLIST *l=NULL;

    while (p!=NULL) {
        if ((p->X==x)&&(p->Y==y)) {
            if (l==NULL) {
                ExcludeP=p->next;
                free(p);
            } else {
                l->next=p->next;
                free(p);
            }
            return;
        }
        l=p;
        p=p->next;
    }
}
BOOL InRect(NUMB px,NUMB py,NUMB x,NUMB y,NUMB x1,NUMB y1)
{
    return ( px>x && py>y && px<x1 && py<y1 );
}
BOOL Excluded(NUMB x,NUMB y,NUMB wid)
{
    PLIST *p=ExcludeP;

    while (p!=NULL) {
        if (InRect(x    ,y    ,p->X,p->Y,p->X1,p->Y1))  return TRUE;
        if (InRect(x    ,y+wid,p->X,p->Y,p->X1,p->Y1))  return TRUE;
        if (InRect(x+wid,y    ,p->X,p->Y,p->X1,p->Y1))  return TRUE;
        if (InRect(x+wid,y+wid,p->X,p->Y,p->X1,p->Y1))  return TRUE;
        p=p->next;
    }
    return(FALSE);
}
int XAdjRect(PLIST *p,PLIST *l)
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
int YAdjRect(PLIST *p,PLIST *l)
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
                    return(1);
                }
                if ((l->Y1==p->Y)||(l->Y1+1==p->Y)) {
                    p->Y=l->Y;
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
void PlaceRect(NUMB x,NUMB y,NUMB x1,NUMB y1,XYPOINT *poly,int numply)
{
    NUMB tmpx,tmpy;
    PLIST *p;
    for (tmpx=x;tmpx<x1;tmpx+=INCREMENT) {
        for (tmpy=y;tmpy<y1;tmpy+=INCREMENT) {
            if (!BetweenInterSections(tmpx,tmpy,poly,numply)) {
                return;
            }
            if (Excluded(tmpx,tmpy,INCREMENT)) return;
        }
    }
    if ((p=malloc(sizeof(PLIST)))==NULL) return;
    p->X=x;
    p->Y=y;
    p->X1=x1;
    p->Y1=y1;
    p->next=ExcludeP;
    ExcludeP=p;
}
void ErasePoly(XYPOINT *poly,int numply,int pass,HWND hwnd)
{
    static NUMB minX,minY,maxX,maxY,tmpx,tmpy,subinc;
    int j,found;
    XYPOINT *cp;
    static PLIST *pnts=NULL;
    if (pass==0) {
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
        G_increment=max((maxX-minX),(maxY-minY));
    }
    if (G_increment>INCREMENT) {
        G_increment/=2;
        G_increment=(G_increment/INCREMENT)*INCREMENT;
        if (G_increment<INCREMENT) G_increment=INCREMENT;
        subinc=INCREMENT;
        for (tmpx=minX;tmpx<maxX;tmpx+=subinc) {
            for (tmpy=minY;tmpy<maxY;tmpy+=subinc) {
                PlaceRect(tmpx,tmpy,tmpx+G_increment,tmpy+G_increment,poly,numply);
            }
        }
    } else {
        do {
            pnts=ExcludeP;
            found=0;
            while (pnts!=NULL) {
                if (XAdjRect(pnts,ExcludeP)) found++;
                if (YAdjRect(pnts,ExcludeP)) found++;
                pnts=pnts->next;
            }
        } while (found);
  	    MessageBox(hwnd,"Done!","Message",MB_OK|MB_ICONINFORMATION);
    }
    SavePoints(ExcludeP);
}
void SavePoints(PLIST *p)
{
    PLIST *tmp=p;
    FILE *fp;
    if ((fp=fopen("XPLIST.DAT","w"))!=NULL) {
        while (p!=NULL) {
            fprintf(fp,"%d\n%d\n",(int)p->X,(int)p->X1);
            p=p->next;
        }
        fclose(fp);
    }
    p=tmp;
    if ((fp=fopen("YPLIST.DAT","w"))!=NULL) {
        while (p!=NULL) {
            fprintf(fp,"%d\n%d\n",(int)p->Y,(int)p->Y1);
            p=p->next;
        }
        fclose(fp);
    }
}
