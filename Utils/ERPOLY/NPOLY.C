#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>
#include <memory.h>
#include <time.h>

typedef double NUMB;
#define ATON   atof

typedef struct { NUMB X; NUMB Y; char Del;} XYPOINT;

int  LoadPoints           (char *xfile,char *yfile,XYPOINT **p);
void ErasePoly            (XYPOINT *points,int nump,XYPOINT *poly,int numply);
int  ResolveStraightLines (XYPOINT *poly,int numply);
void SavePoints           (XYPOINT *points,int nump);

#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
  return 1;
}
#pragma warn +par
void FAR PASCAL _export ErasePoints(HWND hwnd,int LinesFlag)
{
    int nump,numpoly;
    time_t s,e;
    char tmp[40];
    XYPOINT *points=NULL;
    XYPOINT *poly=NULL;

    numpoly=LoadPoints("XLIST.DAT","YLIST.DAT",&poly);
    if (numpoly==0) {
    	MessageBox(hwnd,"No Points in Polygon","Message",MB_OK|MB_ICONINFORMATION);
        return;
    }
    numpoly=ResolveStraightLines(poly,numpoly);

    nump=LoadPoints("XPLIST.DAT","YPLIST.DAT",&points);
    if (nump>0) {
        time(&s);
        ErasePoly(points,nump,poly,numpoly);
        if (LinesFlag) MoveInnerPoints(points,nump,poly,numpoly);
        time(&e);
        SavePoints(points,nump);
        sprintf(tmp,"Erase Took %ld Seconds",e-s);
    	MessageBox(hwnd,tmp,"Message",MB_OK|MB_ICONINFORMATION);
    } else {
    	MessageBox(hwnd,"No Points Inside Polygon ","Message",MB_OK|MB_ICONINFORMATION);
    }
    if (poly  !=NULL) free(poly);
    if (points!=NULL) free(points);
}


int LoadPoints(char *xfile,char *yfile,XYPOINT **p)
{
    FILE *fp;
    char tmp[100];
    int i=0;

    if ((fp=fopen(xfile,"r"))==NULL) return 0;

    i=0; while (fgets(tmp,100,fp)!=NULL) i++;
    fseek(fp,0L,SEEK_SET);
    *p=malloc(i*sizeof(XYPOINT));

    if (*p==NULL) {
        fclose(fp);
        return 0;
    }

    i=0; while (fgets(tmp,100,fp)!=NULL) {
        (*p)[i].X=ATON(tmp);
        (*p)[i++].Del=0;
    }
    fclose(fp);

    if ((fp=fopen(yfile,"r"))==NULL) {
        free(*p);
        return 0;
    }
    i=0; while (fgets(tmp,100,fp)!=NULL) (*p)[i++].Y=ATON(tmp);
    fclose(fp);
    return i;
}
double GetAngle(XYPOINT *a,XYPOINT *b)
{
    double dx=b->X-a->X;
    double dy=b->Y-a->Y;
    if ((dx==0)&&(dy==0)) return 0;
    return 180.0-(atan2(dx,dy)*(180.0/M_PI));
}
int BetweenInterSections(XYPOINT *point,XYPOINT *poly,int numply)
{
    char t=0,b=0,l=0,r=0;
    char p1q,p2q;
    int a1,a2;
    int i;
    a2=GetAngle(point,poly);
    p2q=a2/90;
    for (i=0;i<numply-1;i++) {
        poly++;                  
        while (poly->Del) { poly++; i++; }
        a1=a2; p1q=p2q;
        a2=GetAngle(point,poly); p2q=a2/90; 
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
int ResolveStraightLines(XYPOINT *poly,int numply)
{
    int i,tmpnumply;
    NUMB curang=GetAngle(poly,poly+1);
    XYPOINT *lastpoly=poly,*p=poly;
    p++;
    for (i=0;i<numply-2;i++) {
        if (curang==GetAngle(lastpoly,p+1)) {
            p->Del=1;
        } else {
            lastpoly=p;
        }
        p++;
        curang=GetAngle(lastpoly,p);
    }       
//    tmpnumply=numply-1;
//    while (tmpnumply) {
//        if (poly->Del) {
//            memcpy(poly,poly+1,tmpnumply*sizeof(XYPOINT));
//            numply--;
//        } else {
//            poly++;
//        }
//        tmpnumply--;
//    }
    return numply;
}
void ErasePoly(XYPOINT *pnt,int nump,XYPOINT *poly,int numply)
{
    int minX,minY,maxX,maxY,tmpx,tmpy;
    int j;
    XYPOINT *cp;
    cp=poly;
    tmpx=(int)cp->X;
    tmpy=(int)cp->Y;
    minX=tmpx;
    minY=tmpy;
    maxX=tmpx;
    maxY=tmpy;
    for (j=1;j<numply;j++) {
        cp++;
        while (cp->Del) { cp++; j++; }
        tmpx=(int)cp->X;
        tmpy=(int)cp->Y;
        minX=min(minX,tmpx);
        minY=min(minY,tmpy);
        maxX=max(maxX,tmpx);
        maxY=max(maxY,tmpy);
    }
    for (j=0;j<nump;j++) {
        tmpx=(int)pnt->X;
        tmpy=(int)pnt->Y;
        if ((tmpx>minX)&&(tmpy>minY)&&(tmpx<maxX)&&(tmpy<maxY)) {
            pnt->Del=BetweenInterSections(pnt,poly,numply);
        } 
        pnt++;
    }
}
void SavePoints(XYPOINT *points,int nump)
{
    FILE *fp;
    XYPOINT *cp;
    int j,k=0;
    if ((fp=fopen("XPLIST.DAT","w"))!=NULL) {
        cp=points;
        for (j=0;j<nump;j++) {
            if (!cp->Del) {
                fprintf(fp,"%d\n",(int)cp->X);
                k++;
            }
            cp++;
        }
        fclose(fp);
    }
    if ((fp=fopen("YPLIST.DAT","w"))!=NULL) {
        cp=points;
        for (j=0;j<nump;j++) {
            if (!cp->Del) fprintf(fp,"%d\n",(int)cp->Y);
            cp++;
        }
        fclose(fp);
    }
}
