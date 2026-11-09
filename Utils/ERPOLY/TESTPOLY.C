//#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include <memory.h>
#include <time.h>
#include <dos.h>

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
void ErasePoly            (XYPOINT *poly,int numply);
void SavePoints           (PLIST *p);


PLIST *FirstP;
int main(void)
{
    PLIST *CurrentP;

    int numpoly;
    XYPOINT *poly=NULL;

    numpoly=LoadPoints("POLYLIST.DAT",&poly);
    if (numpoly==0) {
//    	MessageBox(hwnd,"No Points in Polygon","Message",MB_OK|MB_ICONINFORMATION);
        return 0;
    }
    ErasePoly(poly,numpoly);
    if (poly!=NULL) free(poly);
    while (FirstP!=NULL) {
        CurrentP=FirstP;
        FirstP=FirstP->next;
        free(CurrentP);
    }
    return 0;
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
PLIST *FirstP=NULL;
#define INCREMENT 2
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
PLIST * addrect(PLIST *p,NUMB x,NUMB y,NUMB x1,NUMB y1)
{
    if (p==NULL) {
        p=malloc(sizeof(PLIST));
        if (p==NULL) return(NULL);
        FirstP=p;
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
int numberP(void)
{
    PLIST *p=FirstP;
    int ret=0;
    while (p!=NULL) {
        ret++;
        p=p->next;
    }
    return ret;
}
void RemoveRectat(NUMB x,NUMB y)
{
    PLIST *p=FirstP;
    PLIST *l=NULL;

    while (p!=NULL) {
        printf("Try (%ld %ld) (%ld %ld)",x,y,p->X,p->Y);
        if ((p->X==x)&&(p->Y==y)) {
            if (l==NULL) {
                FirstP=p->next;
                free(p);
            } else {
                l->next=p->next;
                free(p);
            }
            printf(" Deleted\n");
            return;
        }
        l=p;
        p=p->next;
    }
    printf(" Not Deleted\n");
}
int RectAtPoint(NUMB x,NUMB y)
{
    PLIST *p=FirstP;
    while (p!=NULL) {
        if ((p->X==x)&&(p->Y==y)&&(p->X1==x+INCREMENT)&&(p->Y1==y+INCREMENT))
            return(TRUE);
        p=p->next;
    }
    return(FALSE);
}
int move(PLIST *p,NUMB length,NUMB offset,NUMB direction)
{
    NUMB i;
    if (direction==RIGHT) {
        for (i=0;i<length;i+=INCREMENT)
            if (!RectAtPoint(p->X+offset,p->Y+i)) return(FALSE);
    } else {
        for (i=0;i<length;i+=INCREMENT)
            if (!RectAtPoint(p->X+i,p->Y+offset)) return(FALSE);
    }
    return(TRUE);
}
void LargestArea(PLIST *p,NUMB *area,NUMB *width,NUMB *height,PLIST **res)
{
    int h1=INCREMENT,w1=INCREMENT,moving;
    int h2=INCREMENT,w2=INCREMENT;
    NUMB a1,a2;
    if (p!=NULL) {
        do {
            moving=0;
            if (move(p,h1,w1,RIGHT)) {
                w1+=INCREMENT;
                moving++;
                if (move(p,w1,h1,UPWARD)) {
                    h1+=INCREMENT;
                    moving++;
                }
            } else {
                while (move(p,w1,h1,UPWARD)) {
                    h1+=INCREMENT;
                    moving++;
                }
            }
        } while (moving);
        a1=h1*w1;
        h2=INCREMENT;
        w2=INCREMENT;
        do {
            moving=0;
            if (move(p,w2,h2,UPWARD)) {
                h2+=INCREMENT;
                moving++;
                if (move(p,h2,w2,RIGHT)) {
                    w2+=INCREMENT;
                    moving++;
                }
            } else {
                while (move(p,h2,w2,RIGHT)) {
                    w2+=INCREMENT;
                    moving++;
                }
            }
        } while (moving);
        a2=h2*w2;
        if (a1>a2) {
            if (*area<a1) {
                *res=p;
                *width=w1;
                *height=h1;
                *area=a1;
            }
        } else {
            if (*area<a2) {
                *res=p;
                *width=w2;
                *height=h2;
                *area=a2;
            }
        }
    }
}
void ErasePoly(XYPOINT *poly,int numply)
{
    NUMB minX,minY,maxX,maxY,tmpx,tmpy;
    int j;
    XYPOINT *cp;
    PLIST *pnts=NULL,*tmp;
    NUMB area,w,h;
  
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
                pnts=addrect(pnts,tmpx,tmpy,tmpx+INCREMENT,tmpy+INCREMENT);
            }
        }
    }
    do {
        w=h=INCREMENT;
        area=INCREMENT*INCREMENT;
        tmp=FirstP;
        while (tmp!=NULL) {
            LargestArea(tmp,&area,&w,&h,&pnts);
            tmp=tmp->next;
        }
        printf("%d %ld (%ld*%ld)\n",numberP(),area,w,h);
        if (area>INCREMENT*INCREMENT) {
            minX=pnts->X;//-INCREMENT
            minY=pnts->Y;//-INCREMENT
            maxX=pnts->X+w;
            maxY=pnts->Y+h;
            printf("%ld %ld %ld %ld\n",minX,minY,maxX,maxY);
            for (tmpx=minX;tmpx<maxX;tmpx+=INCREMENT) {
                for (tmpy=minY;tmpy<maxY;tmpy+=INCREMENT) {
                    RemoveRectat(tmpx,tmpy);
//                    MessageBeep(-1);
                }
            }
            printf("%d %ld (%ld*%ld)\n",numberP(),area,w,h);
              if (getch()==27) return;
            pnts=malloc(sizeof(PLIST));
            if (pnts==NULL) return;
            pnts->X=minX;
            pnts->Y=minY;
            pnts->X1=minX+tmpx;
            pnts->Y1=minY+tmpy;
            pnts->next=FirstP;
            FirstP=pnts;
        }
//        while (pnts!=NULL) {
//            if (XAdjRect(pnts,FirstP)) found++;
//            if (YAdjRect(pnts,FirstP)) found++;
//            pnts=pnts->next;
//        }
//        pnts=FirstP->next;
    } while (area>INCREMENT*INCREMENT);
    SavePoints(FirstP);
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
