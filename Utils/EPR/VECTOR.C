#define VECTOR_C
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include <memory.h>
#include <math.h>
#include <graphics.h>

#include "types.h"
#include "duct.h"
#include "feature.h"

#define EASYTEST

#ifdef EASYTEST
NUMB ZOOM=6;
NUMB ORIGX=(-50);
NUMB ORIGY=(450);
#else
#define ZOOM 3
#define ORIGX (-550)
#define ORIGY (850)
#endif
//============================================================================
//F grafix
//S switch the screen into graphics mode
//D switch the screen into graphics mode using the borland 
//D graphics functions
void grafix(void)
{
    int GraphDriver = DETECT;                 /* Request auto-detection       */
    int GraphMode;
    int ErrorCode;
    initgraph( &GraphDriver, &GraphMode, "d:\\bc45\\bgi" );
    ErrorCode = graphresult();            /* Read result of initialization*/
    if( ErrorCode != grOk ){              /* Error occured during init    */
        printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
        exit( 1 );
    }
}
//===========================================================================
//F rect
//S draw a rotated rectangle
//D draw a rectangle rotated by a number of degrees
//P The X co-ord of one corner of the (unrotated) rectangle
//P The Y co-ord of one corner of the (unrotated) rectangle
//P The X co-ord of the opposite corner of the (unrotated) rectangle
//P The Y co-ord of the opposite corner of the (unrotated) rectangle
//P the number of degrees to rotate
void rect(NUMB x,NUMB y,NUMB x1,NUMB y1,NUMB angle,BOOL fill)
{
    NUMB dx;      // centre to corner delta x and delta y
    NUMB dy; 
    NUMB cx;      // centre x and y co-ordinates
    NUMB cy; 
    NUMB dist;    // distance between center and corner
    NUMB cornang; // angle between center and corner

    if (x>x1) { dx=x; x=x1; x1=dx; } // make sure x,y is left,top
    if (y>y1) { dy=y; y=y1; y1=dy; } // and x1,y1 is right,bottom
    angle=(NUMB)((INT)(angle+0.5));  // round up to nearest degree
    angle*=(M_PI/180);               // convert angle to radians
    dx=(x1-x)/2;                // calc delta x
    dy=(y1-y)/2;                // calc delta y
    cx=x+dx;                    // calc centre x
    cy=y+dy;                    // calc centre y
    dist=sqrt((dx*dx)+(dy*dy)); // calc length from center to corner
    cornang=atan(dy/dx);        // calc angle (in radians) from center to corner

    x=cos(angle-cornang)*dist;  // first corner
    y=sin(angle-cornang)*dist;
    moveto(0.5+cx+x,0.5+cy+y);
    lineto(0.5+cx+cos(angle+cornang)*dist,0.5+cy+sin(angle+cornang)*dist); // second
    angle+=M_PI;                                          // add 180 degrees
    lineto(0.5+cx+cos(angle-cornang)*dist,0.5+cy+sin(angle-cornang)*dist); // third
    lineto(0.5+cx+cos(angle+cornang)*dist,0.5+cy+sin(angle+cornang)*dist); // fourth
    lineto(0.5+cx+x,0.5+cy+y);                                     // back to first
    if (fill) {
        setfillstyle(1,0);
        floodfill(0.5+cx,0.5+cy,fill);
    }
}
NUMB adjustx(NUMB x)
{
    return((x-ORIGX)*ZOOM);
}
NUMB adjusty(NUMB y)
{
    return(480-((y-ORIGY)*ZOOM));
}
//===========================================================================
//F drawfeats
//S draw features
//D draw the features and duct on the screen in graphics mode
//D multiply the co-ords by "ZOOM" and offset bu ORIGX and ORIGY
//P TRUE if bounds are to be drawn
void drawfeats(BOOL withbounds)
{
    INT i;
    char tmp[40];
    NUMB x,y,fidx,didx,fill;
    COORD coord[2];
    // each feature
    for (fidx=0;fidx<NUMFEATURE;fidx++) {
        if (FEATURETYPE(fidx)==LINE_FEATURE) {
            setcolor(15);
            x=FEATUREXCOORD(fidx);
            y=FEATUREYCOORD(fidx);
            moveto(adjustx(x),adjusty(y));
            for (i=0;i<FEATURENUMC(fidx);i++) {
                if (withbounds) setcolor((i%7L)+8L);
                x=FEATURELXCOORD(fidx,i);
                y=FEATURELYCOORD(fidx,i);
                lineto(adjustx(x),adjusty(y));
            }
        }
    }
    // each duct
    for (didx=0;didx<NUMDUCT;didx++) {
        if (DUCTVISIB(didx)) {
            // draw it
            memcpy(&coord[0],get_feat_coords(DUCTFROM(didx),&x),sizeof(COORD));
            memcpy(&coord[1],get_feat_coords(DUCTTO  (didx),&x),sizeof(COORD));
            if (withbounds) {
                setcolor(4);
                line(adjustx(coord[0].x+DUCTBOUND(didx)),adjusty(coord[0].y+DUCTBOUND(didx)),adjustx(coord[1].x+DUCTBOUND(didx)),adjusty(coord[1].y+DUCTBOUND(didx)));
                line(adjustx(coord[0].x-DUCTBOUND(didx)),adjusty(coord[0].y-DUCTBOUND(didx)),adjustx(coord[1].x-DUCTBOUND(didx)),adjusty(coord[1].y-DUCTBOUND(didx)));
            }
            setcolor(11);
            line(adjustx(coord[0].x),adjusty(coord[0].y),adjustx(coord[1].x),adjusty(coord[1].y));
        }
    }
    for (fidx=0;fidx<NUMFEATURE;fidx++) {
        if (FEATURETYPE(fidx)==NAP_FEATURE) {
            x=FEATUREXCOORD(fidx);
            y=FEATUREYCOORD(fidx);
            setcolor(14);
            if (FEATUREBOUND(fidx)>1)
                rect(adjustx(x-3.0),adjusty(y-2.0),adjustx(x+3.0),adjusty(y+2.0),FEATUREANGLE(fidx),(!withbounds)*14);
//            sprintf(tmp,"%ld %s %s %s",G_features[fidx].no,G_features[fidx].ftype,G_features[fidx].state,G_features[fidx].style);
//            G_features[fidx].hazard;
//            G_features[fidx].equip;
//            G_features[fidx].anti;
//            settextstyle(2,0,2);
//            settextjustify(1,1);
//            setcolor(11);
//            outtextxy(adjustx(x),adjusty(y+FEATUREBOUND(fidx)),tmp); // +FEATUREBOUND(fidx)
            if (withbounds) {
                setcolor(4);
                circle(adjustx(x),adjusty(y),FEATUREBOUND(fidx)*ZOOM);
            }
        }
    }
}
//===========================================================================
//F get_feature_info
//S get the feature information
//D collect the feature information from a flat file
void get_feature_info(FILE *fp)
{
    char s[160];
    char *d;
    INT fnum;
    COORD pos;
    COORD ang;
    INT fidx;
    INT fno;
    INT size;
    NUMB zoom;
    COORD minpos;
    COORD maxpos;
    NUMB widhgt;

    while (fgets(s,159,fp)!=NULL) {
//        printf("%s",s);
        d=strtok(s," \t\r\n");
        if (d!=NULL) {
            if (isdigit(*d)) {
                fno=-1;
                fnum=atol(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) pos.x=atof(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) pos.y=atof(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) ang.x=atof(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) ang.y=atof(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) fno=atol(d);
                if (fno<0) {
                    size=5;
                    fno=fnum;
                } else if (fno<6) {
                    size=fno;
                } else {
                    size=5;
                }
                fidx=add_feature(fnum,NAP_FEATURE,&pos,size,0,NULL);
                G_features[fidx].temp=FALSE;
                G_features[fidx].no=fno;
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].ftype =strdup(d); else G_features[fidx].ftype=strdup(" ");
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].state =strdup(d); else G_features[fidx].state=strdup(" ");
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].style =strdup(d); else G_features[fidx].style=strdup(" ");
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].hazard=(*d=='Y'||*d=='y'); else G_features[fidx].hazard=FALSE;
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].equip =(*d=='Y'||*d=='y'); else G_features[fidx].equip =FALSE;
                d=strtok(NULL," \t\r\n");
                if (d!=NULL) G_features[fidx].anti  =(*d=='Y'||*d=='y'); else G_features[fidx].anti  =FALSE;

                G_features[fidx].angle=angle(&pos,&ang)-90;
                if (fidx==0) {
                    memcpy(&minpos,&pos,sizeof(COORD));
                    memcpy(&maxpos,&pos,sizeof(COORD));
                } else {
                    maxpos.x=max(maxpos.x,pos.x);
                    maxpos.y=max(maxpos.y,pos.y);
                    minpos.x=min(minpos.x,pos.x);
                    minpos.y=min(minpos.y,pos.y);
                }
            } else {
                if (*d=='-') {
                    zoom=500.0/(maxpos.x-minpos.x);
                    ZOOM=min(zoom,(400.0/(maxpos.y-minpos.y)));
                    ORIGX=minpos.x;
                    ORIGY=minpos.y;
                    widhgt=(640-(adjustx(maxpos.x)-adjustx(minpos.x)))/2;
                    ORIGX-=widhgt/ZOOM;
                    widhgt=(480-(adjusty(minpos.y)-adjusty(maxpos.y)))/2;
                    ORIGY-=widhgt/ZOOM;
                    return;
                }
            }
        }
    }
    ORIGX=0-minpos.x;
    ORIGY=minpos.y+480;
    ZOOM=1;
}
//===========================================================================
//F get_duct_info
//S get the duct information
//D collect the duct information from a flat file
void get_duct_info(FILE *fp)
{
    char s[160];
    char *d;
//    INT dnum;
//    INT did;
    INT dfrom;
    INT dto;
    INT numd=0;
    long pos;

    pos=ftell(fp);
    while (fgets(s,159,fp)!=NULL) numd++;
    fseek(fp,pos,SEEK_SET);

    G_numbducts=0;
    G_ducts=malloc(numd*sizeof(DUCT));
    while (fgets(s,159,fp)!=NULL) {
        d=strtok(s," \t\r\n");
        if (d!=NULL) {
            if (isdigit(*d)) {
//                dnum=atol(d);
                d=strtok(NULL," \t\r\n"); // if (d!=NULL) did=atol(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) dfrom=atol(d);
                d=strtok(NULL," \t\r\n"); if (d!=NULL) dto  =atol(d);
                G_ducts[G_numbducts].from =dfrom;
                G_ducts[G_numbducts].to   =dto;
                G_ducts[G_numbducts].bound=2;
                G_ducts[G_numbducts++].visib=TRUE; 
            }
        }
    }
}
void list_features(void)
{
    int a,b;
    for (a=0;a<NUMFEATURE;a++) {
        if (FEATURETYPE(a)==NAP_FEATURE) {
            printf("NAP Feature %ld at %ld,%ld Angle %ld Bounds %ld\n",
                FEATUREID(a),
                (INT)(FEATUREXCOORD(a)+0.5),
                (INT)(FEATUREYCOORD(a)+0.5),
                (INT)(FEATUREANGLE(a)+0.5),
                (INT)(FEATUREBOUND(a)+0.5)    );
        } else {
            printf("Line Feature %ld at %ld,%ld Bounds %ld Group %ld With %ld points\n",
                FEATUREID(a),
                (INT)(FEATUREXCOORD(a)+0.5),
                (INT)(FEATUREYCOORD(a)+0.5),
                (INT)(FEATUREBOUND(a)+0.5),
                FEATUREGROUP(a),
                FEATURENUMC(a) );
        }
    }
}
//****************************************************************************
int main(int argc,char *argv[])
{
    FILE *fp;
    COORD c;
    char file[30];
    if (argc<2) {
        fprintf(stderr,"%s filename\n",argv[0]);
        return 1;
    }
    sprintf(file,"DATA\\%s",argv[1]);
    if ((fp=fopen(file,"r"))==NULL) {
        fprintf(stderr,"Can't open input file %s\n",file);
        return 1;
    }
    get_feature_info(fp);
    get_duct_info(fp);
    fclose(fp);
    grafix();
    drawfeats(1);
    getch();
    resolve_nap_conflict();
    drawfeats(1);
    getch();
    space_ducts();
    drawfeats(1);
    getch();

    c.x=100;
    c.y=80;
    move_point_in_line(4,&c,2,5);
    c.x=102;
    move_point_in_line(5,&c,2,4);
    move_point_in_line(6,&c,2,4);
    c.x=98;
    move_point_in_line(5,&c,2,6);
    move_point_in_line(6,&c,2,6);

    c.x=100;
    c.y=60;
    move_point_in_line(4,&c,-2,5);
    c.x=102;
    move_point_in_line(5,&c,-2,6);
    move_point_in_line(6,&c,-2,6);
    c.x=98;
    move_point_in_line(5,&c,-2,4);
    move_point_in_line(6,&c,-2,4);

    set_feature_angles();
    clearviewport();
    drawfeats(1);
    getch();
    clearviewport();
    drawfeats(0);
    getch();
    closegraph();
    free(G_ducts);
    free(G_features);
    list_features();
    return 1;
}


//===========================================================================
//                           End of file
//===========================================================================
