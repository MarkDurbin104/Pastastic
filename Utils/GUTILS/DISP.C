#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <string.h>

#include "gprim.h"
#include "stand16.h"
int getkey(void)
{
	int k=getch();
	if (!k) k-=getch();
	return(k);
}
void output(int x,int y,int s,int c,char *str)
{
	setcol(c);
	selectfont(s);
	prln(x,y,str);
}
int interp(char *s)
{
	int p[4],i,t,w;
	IMAGE *img;

	t=*(s++);
	for (i=0;i<4;i++) { p[i]=atoi(s); s+=4; }
	w=strlen(s)*(1+(p[0]>0));
	switch (t) {
		case 'K' : getkey();                                        break;
		case 'F' : cls();                                           break;
		case 'C' : output((40-w/2)*8,p[3]*16,p[0],p[1],s);          break;
		case 'O' : output(p[2]*8,p[3]*16,p[0],p[1],s);              break;
		case 'L' : setcol(atoi(s)); line(p[0],p[1],p[2],p[3]);      break;
		case 'R' : setcol(atoi(s)); rectangle(p[0],p[1],p[2],p[3]); break;
		case 'B' : setcol(atoi(s)); bar(p[0],p[1],p[2],p[3]);       break;
		case 'I' :
			if ((img=getbmp(s))!=NULL) { putimage(p[0],p[1],img); freeimg(img); }
			break;
		case 'P' : setborder(p[0]); setpalette(0,p[0]); setpalette(p[0],0); break;
		case 'E' : return(1);
	}
	return(0);
}
int main(int argc,char *argv[])
{
	FILE *fp;
	int vga,xit=0;
	char tmp[90],*s;
/*	IMAGE *imgv;

	if ((imgv=getbmp("GPASTART.BMP"))==NULL) return 1;
	if ((vga=grafix(0))<0) return 1;

	usegdev(vga);
	putimage(0,0,imgv);
	freeimg(imgv);
	getch();
*/
	if (argc>1) {
		if ((vga=grafix(0))<0) return 1;
		usegdev(vga);
		if (!attachfont(G_font,1,16,8)) return 1;
		selectfont(0);
		if ((fp=fopen(argv[1],"r"))!=NULL) {
	    	while ((fgets(tmp,80,fp)!=NULL)&&(!xit)) {
				s=&(tmp[strlen(tmp)-1]);
				while ((s!=tmp)&&(!isprint(*s))) s--;
				*(++s)=0;
				xit=interp(tmp);
			}
			fclose(fp);
		}
		closegraf();
	}

	return 0;
} 
