#include <math.h>
#include <alloc.h>
#include <stdlib.h>
#include "convhpgl.h"
void arcabs(int x,int y,int a,int tol) {
	int len,ang;
	double xpos,ypos;
	ypos=x-G_xcur;
	xpos=y-G_ycur;
	len=sqrt((xpos*xpos)+(ypos*ypos));
	ang=atan2(ypos,xpos)*(double)DEGREE;
	dpoly(0,G_xcur,G_ycur,len,len,360/tol,0,ang,ang+a,G_rotation,0);
}
void arcrel(int x,int y,int a,int tol) {
	double ang,len;
    double xpos,ypos;
	xpos=x;
	ypos=y;
	len=sqrt((xpos*xpos)+(ypos*ypos));
	ang=atan2(ypos,xpos)*(double)DEGREE;
	dpoly(0,G_xcur,G_ycur,len,len,360/tol,0,ang,ang+a,G_rotation,0);
}
void dpoly(int fill,int x,int y,int xr,int yr,int n,int rot,int st,int ed,int a,int z) {

	int i,j,k,ang,len;
	double xpos,ypos;
	struct polpts {
		int x;
		int y;
	} plpt[362];
	if (a!=0) {
		for (i=st+rot,j=0;i<=ed+rot+1;i+=360/n,j++) {
        	k=i;
			while(k<0) k+=360;
			while(k>=360) k-=360;
			xpos=yr*(xlook[k]);
			ypos=xr*(ylook[k]);
			len=sqrt((xpos*xpos)+(ypos*ypos));
			ang=(atan2(ypos,xpos)+M_PI)*DEGREE;
			while((ang)<0) ang+=360;
			while((ang)>=360) ang-=360;
			plpt[j].x=x-len*alook[ang];
			plpt[j].y=y+len*ylook[ang];
		}
		rotapoly(origx,origy,j,(int *)plpt,a,z);
		if (fill) {
			ddrawpoly(1,j,(void far *)plpt);
		}
		else {
			ddrawpoly(0,j,(void far *)plpt);
		}
	}
	else {
		for (i=st+rot,j=0;i<=ed+rot+1;i+=360/n,j++) {
			k=i;
			while(k<0) k+=360;
			while(k>=360) k-=360;
			plpt[j].x=x+xr*alook[k];
			plpt[j].y=y+yr*ylook[k];
		}
		rotapoly(origx,origy,j,(int *)plpt,a,z);
		if (fill) {
			ddrawpoly(1,j,(void far *)plpt);
		}
		else {
			ddrawpoly(0,j,(void far *)plpt);
		}
	}
}
void dslice(int fill,int x,int y,int xr,int yr,int n,int rot,int st,int ed,int a,int z) {

	int i,j,k,ang,len;
	double xpos,ypos;
	struct polpts {
		int x;
		int y;
	} plpt[362];
	plpt[0].x=x;
	plpt[0].y=y;
	if (a!=0) {
		for (i=st+rot,j=1;i<=ed+rot+1;i+=360/n,j++) {
        	k=i;
			while(k<0) k+=360;
			while(k>=360) k-=360;
			xpos=yr*(xlook[k]);
			ypos=xr*(ylook[k]);
			len=sqrt((xpos*xpos)+(ypos*ypos));
			ang=(atan2(ypos,xpos)+M_PI)*DEGREE;
			while((ang)<0) ang+=360;
			while((ang)>=360) ang-=360;
			plpt[j].x=x-len*alook[ang];
			plpt[j].y=y+len*ylook[ang];
		}
		plpt[j].x=x;
		plpt[j].y=y;
		rotapoly(origx,origy,j+1,(int *)plpt,a,z);
		if (fill) {
			ddrawpoly(1,j+1,(void far *)plpt);
		}
		else {
			ddrawpoly(0,j+1,(void far *)plpt);
		}
	}
	else {
		for (i=st+rot,j=1;i<=ed+rot+1;i+=360/n,j++) {
			k=i;
			while(k<0) k+=360;
			while(k>=360) k-=360;
			plpt[j].x=x+xr*alook[k];
			plpt[j].y=y+yr*ylook[k];
		}
		plpt[j].x=x;
		plpt[j].y=y;
		rotapoly(origx,origy,j+1,(int *)plpt,a,z);
		if (fill) {
			ddrawpoly(1,j+1,(void far *)plpt);
		}
		else {
			ddrawpoly(0,j+1,(void far *)plpt);
		}
	}
}
int rotapoly(int x,int y,int np,int *pp,double a,double z) {

	int j;
	double ang,len;
	double xpos,ypos;
	if ((a==0)&&(z==0)) return(1);
	for (j=0;j<np;j++) {
		if ((*(pp+(j*2)+0)!=x)||(*(pp+(j*2)+1)!=y)) {
			ypos=(double)((double)*(pp+(j*2)+0)-(double)x)/(double)aspect;
			xpos=(double)((double)*(pp+(j*2)+1))-(double)y;
			len=sqrt((xpos*xpos)+(ypos*ypos));
			ang=(int)((double)a+(atan2(ypos,xpos)+M_PI)*(double)DEGREE);
			while (ang<0) ang+=360;
			while (ang>=360) ang-=360;
			*(pp+(j*2)+0)=x-len*cos(((2.0*M_PI)/360.0)*(double)z)*alook[ang];
			*(pp+(j*2)+1)=y-len*ylook[ang];
		}
	}
    return(1);
}
void setuplook(void) {

	int i;
	double degree;
	alook=farmalloc(361*sizeof(degree));
	xlook=farmalloc(361*sizeof(degree));
	ylook=farmalloc(361*sizeof(degree));
	degree=(180.0/M_PI);
	for (i=0;i<90;i++) {
		xlook[i]=(double)sin((double)i/(double)degree);
		ylook[i]=(double)cos((double)i/(double)degree);
		xlook[i+90]=ylook[i];
		ylook[i+90]=0-xlook[i];
		xlook[i+180]=0-xlook[i];
		ylook[i+180]=0-ylook[i];
		xlook[i+270]=0-ylook[i];
		ylook[i+270]=xlook[i];
	}
	for (i=0;i<360;i++) alook[i]=xlook[i]*aspect;
}

int putfstr(int x,int y,int x1,int y1,int h,int w,int a,char *txt,int font,int rot) {
	int i,j;
	int xpos,ypos;
	int ycod;
	int width,height,chw;
	int xres,yres,carac;
	struct polypoints {
		int x;
		int y;
	} polyp[16];
	double degrot,degslt,sdeg,cdeg,sdes,cdes;
	int charofs;
	degslt=a*(M_PI/180.0);
	degrot=0;/*rot*(M_PI/180.0);*/
	sdeg=sin(degrot);
	cdeg=cos(degrot);
	sdes=sin(degslt);
	cdes=cos(degslt);
	height=y1-y;
	width=x1-x;
	j=0;
	while (txt[j]!=G_lterm) {
		charofs=*(txt+j)-32;
		chw=w*j*(G_lspace+1);
		xpos=(((chw%width)/w)*w);
		ypos=((chw/width)+1)*h*(G_llines+1);
		if (ypos>height) return(-1);
		for (i=0;i<charset[font].nopts[charofs];i++) {
			carac=charset[font].xy[charofs][i];
			ycod=((carac&0x0F)*h)/14;
			xres=xpos+(sdes*ycod)+(((carac>>4)*w)/10);
			yres=ypos-(cdes*ycod);
			polyp[i].x=x+((cdeg*xres)-(sdeg*yres));
			polyp[i].y=y+((sdeg*xres)+(cdeg*yres));
		}
		rotapoly(lorigx,lorigy,i,(int *)&polyp[0],rot,0);
		ddrawpoly(0,i,(int far *)&polyp[0]);
		j++;
	}
	G_xcur=chw+x;
	return(1);
}
int putvstr(int x,int y,int x1,int y1,int h,int w,int a,char *txt,int font,int rot) {
	int i,j;
	int xpos,ypos,xmove;
	int ycod;
	int width,height;
	int charw=0;
	int xres,yres,carac;
	struct polypoints {
		int x;
		int y;
	} polyp[16];
	double degrot,degslt,sdeg,cdeg,sdes,cdes;
	int charofs;
	degslt=a*(M_PI/180.0);
	degrot=0;/*rot*(M_PI/180.0);*/
	sdeg=sin(degrot);
	cdeg=cos(degrot);
	sdes=sin(degslt);
	cdes=cos(degslt);
	height=y1-y;
	width=x1-x;
	xmove=0;
	ypos=h;
	j=0;
	while (txt[j]!=G_lterm) {
		charofs=*(txt+j)-32;
		if (ypos!=(((xmove/width)+1)*h*(G_llines+1))) {
			xmove-=xmove%width;
		}
		xpos=(xmove%width);
		ypos=((xmove/width)+1)*h*(G_llines+1);
		if (ypos>height) return(-1);
		charw=0;
		for (i=0;i<charset[font].nopts[charofs];i++) {
			carac=charset[font].xy[charofs][i];
			charw=max(charw,(carac>>4));
			ycod=((carac&15)*h)/14;
			xres=xpos+(sdes*ycod)+(((carac>>4)*w)/10);
			yres=ypos-(cdes*ycod);
			polyp[i].x=x+((cdeg*xres)-(sdeg*yres));
			polyp[i].y=y+((sdeg*xres)+(cdeg*yres));
		}
		if (charw<5) xmove+=2;
		xmove+=(w*(charw*(G_lspace+1)))/8;
		rotapoly(lorigx,lorigy,i,(int *)&polyp[0],rot,0);
		ddrawpoly(0,i,(int far *)&polyp[0]);
		j++;
	}
	G_xcur=xmove+x;
	return(1);
}
