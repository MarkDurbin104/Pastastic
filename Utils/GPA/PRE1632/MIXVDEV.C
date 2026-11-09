#define VFONDEV_C
//___________________________________________________________________________

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <stdarg.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include "gprim.h"
#include "types.h"
#include "control.h"
#include "config.h"
#include "memory.h"
#include "message.h"
#include "keydef.h"

#pragma option -p-
#include "vfondev.h"

#define CMAPOFS (32+(16*256)+(14*256))

#define DCARE	0x01
#define NREFL	0x02
#define SREFL	0x04
#define DREFL	0x08
#define DDREFL	0x10
#define DNREFL	0x20
#define DCNOMV	0x40




unsigned char    *G_contspace=NULL;
int 			  G_vgahand=(-1);
int 			  G_vlsp=19;
int               G_vfontwide=8;
int               G_vfonthigh=16;
unsigned char    *G_vfontspace=NULL;
int               G_vfontaw=8;
int               G_vfontah=16;
int		          G_backoneng=0;
int				  G_onoff=1;

int G_entry=1;
int G_newscr=0;
unsigned char G_palette[17]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
                             0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,1};
int G_lights=0;
unsigned long slights[7][2];
unsigned char G_smaps[5][7]={
    {0x1C,0x63,0x63,0x7F,0x63,0x63,0x63}, // 'A'
    {0x63,0x73,0x7B,0x7F,0x6F,0x67,0x63}, // 'N'
    {0x3E,0x63,0x60,0x60,0x60,0x63,0x3E}, // 'C'
    {0x3E,0x60,0x60,0x3E,0x03,0x03,0x3E}, // 'S'
    {0x7E,0x18,0x18,0x18,0x18,0x18,0x7E}  // 'I'
};
unsigned char spos[8]={4,3,1,2,0,2,3,3};

// draw the unisys logo on the screen
void drawlogo(int x,int y,int col)
{
	int i,j,k;
	unsigned char *s,*t=(unsigned char *)0xA0000000L;
	ENTRY(3870);
    y*=19;
	BITMASK(255); ESETRES(0); MAPMASK(15);
    for (k=0;k<38;k++) {  
        for (j=0;j<17;j++) {  
	        for (i=0;i<4;i++) {
		        outportb(0x3CE,4);
		        outportb(0x3CF,i);
		        outportb(0x3C4,2);
		        outportb(0x3C5,1<<i);
  	            s=t+x+j+((y+k)*80);
		        if (col&(1<<i)) *s=G_logo[k][j]; else *s=0;
	        }
        }
    }
	BITMASK(255); ESETRES(0); MAPMASK(15);
//	setcol(0);
	setcol(G_screen.attr);
	RETURN;
}
// set the shift status lights 
void setlights(void)
{
	unsigned long *t=(unsigned long *)0xA0000000L;
    int i,j;
	ENTRY(3880);

    for (j=0;j<7;j++) {
        slights[j][0]=0L;
        slights[j][1]=0L;
    }

    for (i=0;i<4;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][0]|=(((long)G_smaps[spos[i]][j])<<((3-i)*8));
            }
        }
    }
    for (i=4;i<8;i++) {
        if (((0x80>>i)&G_lights)!=0) {
            for (j=0;j<7;j++) {
                slights[j][1]|=(((long)G_smaps[spos[i]][j])<<((7-i)*8));
            }
        }
    }
    t+=(471*20)+17;
	BITMASK(255); ESETRES(0); MAPMASK(15);
    for (i=0;i<4;i++) {
		outportb(0x3CE,4);
		outportb(0x3CF,i);
		outportb(0x3C4,2);
		outportb(0x3C5,1<<i);
        for (j=0;j<7;j++) {
      		*(t++)=(slights[j][0]*(i==2));
      		*t=(slights[j][1]*(i==2));
            t+=19;
        }
        t-=140;
    }
	BITMASK(255); ESETRES(0); MAPMASK(15);
	setcol(0);
	setcol(G_screen.attr);
	RETURN;
}
// draw a box on the screen
void vfdbox(int x,int y,int x1,int y1)
{
    int xs,xe,ys,ye;
	ENTRY(3890);

    setcol(8);

    xs=x *G_vfontwide +(G_vfontwide >>1);
    ys=y *G_vlsp+(G_vlsp>>1);
    xe=x1*G_vfontwide +(G_vfontwide >>1);
    ye=y1*G_vlsp+(G_vlsp>>1);

    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys); lineto(xe,ys);
    setcol(8);
    lineto(xe,ye); lineto(xs,ye);
    xs--; ys--; xe++; ye++;
    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys); lineto(xe,ys);
    setcol(8);
    lineto(xe,ye); lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
#pragma warn +pro
// draw a line on the screen
void vfdline(int x,int y,int x1,int y1)
{
	ENTRY(3900);
    setcol(8);
    line(x*G_vfontwide+(G_vfontwide/2),
            y*G_vlsp+(G_vlsp/2),
            x1*G_vfontwide+(G_vfontwide/2),
            y1*G_vlsp+(G_vlsp/2));

    setcol(15);
    line(x*G_vfontwide+(G_vfontwide/2)+1,
            y*G_vlsp+(G_vlsp/2)+1,
            x1*G_vfontwide+(G_vfontwide/2)+1,
            y1*G_vlsp+(G_vlsp/2)+1);
	setcol(G_screen.attr);
	RETURN;
}
//___________________________________________________________________________
// draw a cursor of length 'num' on the screen
void cursor(int x,int y,int num)
{
	ENTRY(3910);
	setcol(2);
	setwmode(XOR_WM);
	bar(x,y,(x+num*(G_vfontaw-G_backoneng))-1,(y+G_vfontah)-1);
	setwmode(NORM_WM);
	setcol(G_screen.attr);
	RETURN;
}
// blank an area of length 'num' on the screen
void blank(int x,int y,int num)
{
	ENTRY(3910);
	setcol(0);
	setwmode(XOR_WM);
	bar(x,y,x+(num*G_vfontaw),y+G_vfontah);
	setwmode(NORM_WM);
	setcol(G_screen.attr);
	RETURN;
}
// sink a field on the screen
void vfsink(int x,int y,int len)
{
    int xs,xe,ys,ye;
	ENTRY(3920);

    xs=x*G_vfontwide-1;
    ys=y*G_vlsp-1;
    xe=xs+(G_vfontaw-G_backoneng)*len+2;
    ye=ys+G_vfontah+2;

    moveto(xs,ye);
    setcol(8);
    lineto(xs,ys);
    lineto(xe,ys);
    setcol(15);
    lineto(xe,ye);
    lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
// raise a field on the screen
void vfraise(int x,int y,int len)
{
    int xs,xe,ys,ye;
	ENTRY(3930);

    xs=x*G_vfontwide-1;
    ys=y*G_vlsp-1;
    xe=xs+G_vfontwide*len+2;
    ye=ys+G_vfonthigh+2;

    moveto(xs,ye);
    setcol(15);
    lineto(xs,ys);
    lineto(xe,ys);
    setcol(8);
    lineto(xe,ye);
    lineto(xs,ye);
	setcol(G_screen.attr);
	RETURN;
}
// screen reset routine
int scr_reset(void)
{
	IMAGE *img;
	ENTRY(3940);
    if (G_entry) {
        setborder(7);
    }
    G_entry=0;
	G_newscr=1;
	cls();
	if ((img=getbmp(G_wallpaper))!=NULL) {
		putimage(0,0,img);
		freeimg(img);
	}
    RETURNV(1);
} 
// read the font information into memory
char *readfont(char *fontfile)
{
	char tmp[40];
	ENTRY(3960);
	sprintf(tmp,"V%s",fontfile);
	G_backoneng=0;
	if (tmp[strlen(tmp)-1]=='2') {
   		if (G_vfontspace==NULL) {
			G_vfontspace=MALLOC(strlen(fontfile)+1);
		} else {
			G_vfontspace=REALLOC(G_vfontspace,strlen(fontfile)+1);
		}
		strcpy((char *)G_vfontspace,fontfile);
		if (!isblk((char *)G_vfontspace)) loadlfont((char *)G_vfontspace,1);
		if (!attachfont(G_vfontspace,201,16,16)) RETURNV(NULL);
		G_vfontaw=16;
		G_vfontah=16;
		selectfont(G_screen.size-1);
	} else if (tmp[strlen(tmp)-1]=='3') {
   		if (G_vfontspace==NULL) {
			G_vfontspace=MALLOC(strlen(fontfile)+1);
		} else {
			G_vfontspace=REALLOC(G_vfontspace,strlen(fontfile)+1);
		}
		strcpy((char *)G_vfontspace,fontfile);
		if (!isblk((char *)G_vfontspace)) loadlfont((char *)G_vfontspace,2);
		if (!attachfont(G_vfontspace,202,24,24)) RETURNV(NULL);
		G_vfontaw=24;
		G_vfontah=24;
		G_backoneng=8;
		selectfont(G_screen.size-1);
	} else {
		if (isblk(tmp)) {
    		if (G_vfontspace==NULL) {
				G_vfontspace=MALLOC(16*256+2);
			} else {
				G_vfontspace=REALLOC(G_vfontspace,16*256+2);
			}
    		if (G_vfontspace!=NULL) {
        		restblk(tmp,G_vfontspace);
    		}
		} else {
	    	if (G_vfontspace!=NULL) FREE(G_vfontspace);
	    	G_vfontspace=loadffont(fontfile);
       		saveblk(tmp,16*256,G_vfontspace);
		}
		if (!attachfont(G_vfontspace,1,16,8)) RETURNV(NULL);
		G_vfontaw=8;
		G_vfontah=16;
		selectfont(G_screen.size-1);
	}
    RETURNV((char *)G_vfontspace);
}
// screen startup routine
int scr_startup(void)
{
	IMAGE *img;
	ENTRY(3970);

    G_entry=1;
	G_newscr=1;
    G_screen.size=1;
    G_screen.xor=0;

    G_screen.attr=G_hattr[1];
//    G_screen.attr=0x07;
    G_vlsp=19;
    G_vfonthigh=16;
    G_vfontwide=8;
	G_vgahand=grafix(0);
	if (G_vgahand<0) RETURNV(0);
	usegdev(G_vgahand);
    G_maxx=79;
    G_maxy=24;
    setpalette(2,0);
    setpalette(7,2);
	if ((img=getbmp("GPASTART.BMP"))!=NULL) {
	    setpalette(0,7);
		putimage(0,0,img);
		freeimg(img);
	} else {
        setrgbpalette(0,57,51,38);
        setrgbpalette(7,0,0,15);
	    setpalette(0,7);
	}
    RETURNV(1);
}
// screen re-startup routine
int scr_restartup(void)
{
	restart(G_vgahand);
    setpalette(2,0);
    setpalette(7,2);
    setpalette(0,7);
    RETURNV(1);
}
// screen shutdown routine
int scr_shutdown(void)
{
	ENTRY(3950);
	if (G_contspace!=NULL) FREE(G_contspace);
    if (G_vfontspace!=NULL) FREE(G_vfontspace);
    setborder(0);
	closegraf();
    RETURNV(1);                 
}
// screen shutdown routine
int scr_tmpshutdown(void)
{
    setborder(0);
	monomode();
    RETURNV(1);                 
}
int isnew(void)
{
	ENTRY(3980);
	if (G_newscr) {
		G_newscr=0;
		RETURNV(1);
	}
	RETURNV(0);
}
int intlen(unsigned int *s)
{
	int i=0;
	ENTRY(3990);
	while ((*s&0xFF)!=0) {
		s++;
		i++;
		if (i>80) RETURNV(80);
	}
	RETURNV(i);
}
void intcpy(unsigned int *d,unsigned int *s)
{
	int i=intlen(s);
	ENTRY(4000);
	if (i) memcpy(d,s,i*2);
}
int state(unsigned int c)
{
	c&=0xFF;
	ENTRY(4010);
	if (c==0) RETURNV(0);
	if (G_contspace==NULL) RETURNV(2);

	switch (*(G_contspace+c)&0x0F) {
		case 1 : RETURNV(NREFL);			// NON REFLECTED  english left anchored
		case 2 :
		case 7 : RETURNV(SREFL);			// SINGLE REFLECT farsi text
		case 3 : RETURNV(DREFL);			// DOUBLE REFLECT farsi numbers
		case 4 : RETURNV(DDREFL);		// DOUBLE REFLECT english text right anchored
		case 5 : RETURNV(DNREFL); 		// DOUBLE REFLECT farsi number puctuation
		case 6 : RETURNV(DCNOMV); 		// DON'T CARE DONT MOVE diacritical marks
	}
	RETURNV(DCARE);						// DON'T CARE	  punctuation
}
unsigned int *normal(unsigned int *s,unsigned int *d,int mask,int backup)
{
	unsigned int *t=s;
	ENTRY(4020);
	d+=intlen(d);
	while ((state(*s)&mask)!=0) {
		*(d++)=*(s++);
	}
	if (backup) {
		while ((state(*s)==DCARE)&&(s>t)) {
			s--;
		}
	}
	RETURNV(s);
}
unsigned int *reflect(unsigned int *s,unsigned int *d,int mask,int backup)
{
	unsigned int tmp[160];
	unsigned int *t=&tmp[158];
	ENTRY(4030);
	tmp[159]=0;
	d+=intlen(d);
	while ((state(*s)&mask)!=0) {
		*(t--)=*(s++);
	}
	t++;
	if (backup) {
		while (state(*t)==DCARE) {
			t++;
			s--;
		}
	}
	intcpy(d,t);
	RETURNV(s);
}
unsigned int *convint(unsigned int *p)
{
	unsigned int tmp[160];
	unsigned int *s=p;
	ENTRY(4040);
	memset(tmp,0,sizeof(tmp));
	while ((*s&0xFF)!=0) {
		switch (state(*s)) {
			case DCARE :
			case NREFL :
			case DCNOMV :
				s=normal(s,tmp,DCARE|NREFL|DCNOMV,0);
				break;
			default :										
				s=reflect(s,tmp,DCARE|SREFL|DREFL|DDREFL|DNREFL|DCNOMV,0);	
		}													
	}														
	s=p;													
	intcpy(s,tmp);
	memset(tmp,0,sizeof(tmp));
	while ((*s&0xFF)!=0) {
		switch (state(*s)) {
			case DCARE :
			case NREFL :
			case SREFL :
			case DCNOMV :
				s=normal(s,tmp,DCARE|NREFL|SREFL|DCNOMV,0); //farsi
				break;
			case DREFL :
			case DNREFL :
				s=reflect(s,tmp,DREFL|DNREFL,0);            //farsi numbers
			default :
				s=reflect(s,tmp,DCARE|DDREFL|DCNOMV,1);     //english
		}
	}
	s=p;
	intcpy(s,tmp);
	RETURNV(s);
}
unsigned int cofs(int a,int b,int c,unsigned char ch)
{
	unsigned int r=(unsigned int)ch;
	unsigned char *f=G_contspace+256+ch;
	ENTRY(4050);
	if (b<2) RETURNV(r);
	if (!a) a=1; if (!b) b=1; if (!c) c=1;
	if ((b!=a)&&(b!=c)) RETURNV(r);
	if ((b!=a)&&(b==c)&&(*f!=0)) RETURNV((unsigned int)*f);
	f+=256;
	if ((b==a)&&(b==c)&&(*f!=0)) RETURNV((unsigned int)*f);
	f+=256;
	if ((b==a)&&(b!=c)&&(*f!=0)) RETURNV((unsigned int)*f);
	RETURNV(r);
}
int fixterm(unsigned char ch)
{
	ENTRY(4060);
	RETURNV((*(G_contspace+ch)&0x0F)==7);
}
unsigned int contanal(unsigned char *p,int o)
{
	unsigned int a,b,c;
	ENTRY(4070);

	if (o==0) {
		a=1;
	} else if (fixterm(*(p-1))) {
 		a=1;
	} else {
		a=state((unsigned int)*(p-1));
	}
	b=state((unsigned int)*p);
	c=state((unsigned int)*(p+1));
	RETURNV(cofs(a,b,c,*p));
}
void remhard(unsigned char *p,int *cp)
{
	unsigned char tmp[81],*t,*s;
	int i;
	ENTRY(4080);
	t=tmp;
	s=p;
	memset(tmp,0,81);
	i=0;
	while (*s) {
		if (*s!=0xFF) {
			*(t++)=*s;
		} else {
			if (i<*cp) (*cp)--;
		}
		s++;
		i++;
	}
	strcpy((char *)p,(char *)tmp);
	RETURN;
}
unsigned char *convstr(unsigned char *p,int *cp)
{
	int i,l;
	static unsigned int iarr[160];
	ENTRY(4090);
	if (*cp<0) *cp=0;
	if (*cp>159) *cp=159;
	l=strlen((char *)p);
	memset(iarr,0,sizeof(iarr));
	for (i=0;i<l;i++) iarr[i]=contanal(p+i,i);
	for (i=0;i<l;i++) iarr[i]|=(i<<8);
	convint(iarr);
	for (i=0;i<l;i++) {
		p[i]=(unsigned char)(iarr[i]&0xFF);
	}
	for (i=0;i<l;i++) {
		if ((iarr[i]>>8)==*cp) {
			*cp=i;
			break;
		}
	}
	remhard(p,cp);
	RETURNV(p);
}
int cpos(unsigned char *p,int cp,int np)
{
	int i,l;
	static unsigned int iarr[160];
	ENTRY(4100);
	l=strlen((char *)p)+1;
	memset(iarr,0,sizeof(iarr));
	for (i=0;i<l;i++) iarr[i]=((i+1)<<8)|contanal(p+i,i);
	convint(iarr);
	for (i=0;i<l;i++) {
		if ((iarr[i]>>8)==(cp+1)) {
			if ((iarr[i+np]>>8)!=0) RETURNV((iarr[i+np]>>8)-1);
			RETURNV(cp);
		}
	}
	RETURNV(cp+np);
}
void loadcont(char *f)
{
	int fd;
	char tmp[16];
	ENTRY(4110);
	sprintf(tmp,"F%s",f);
	if (isblk(tmp)) {
    	if (G_contspace==NULL) G_contspace=MALLOC(1024);
    	if (G_contspace!=NULL) {
        	restblk(tmp,G_contspace);
    	}
	} else {
    	if (G_contspace==NULL) G_contspace=MALLOC(1024);
    	if (G_contspace!=NULL) {
			if ((fd=open(f,O_RDONLY|O_BINARY))==(-1)) RETURN;
			lseek(fd,CMAPOFS,SEEK_SET);
			read(fd,G_contspace,1024);
			close(fd);
       		saveblk(tmp,1024,G_contspace);
		}
	}
	RETURN;
}
// screen control routine
int vfscr_control(int type,va_list ap)
{
	IMAGE *img,*img2;
    char tmp[160],*f,*s,**ff;
    int x,y,x1,y1,num,c;
    unsigned char *pal;
    int retval=1;
	ENTRY(4120);

	if (G_vgahand>=0) usegdev(G_vgahand);
	if (!G_onoff) {
	    switch (type) {
	        case 'E' :
	        case 'ON' :
	        case 'RI' :
	        case 'TE' :
	        case 'I' :
				break;
			default :
				return(1);
		}
	} 
    switch (type) {
		case 'i' :
			retval=(int)G_screen.size;
			break;
		case 'o' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=sendmsg("INPUT3",'MI',x*G_vfontwide,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
			if (c) sendmsg("INPUT3",'C',0);
			prln(x*G_vfontwide,y*G_vlsp,"%s",tmp);
			if (c) sendmsg("INPUT3",'C',-1);
			retval=1;
			break;

		case 'od' :
            x=va_arg(ap,int);
            x1=va_arg(ap,int);
            y=va_arg(ap,int);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=sendmsg("INPUT3",'MI',x*G_vfontaw,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
			if (c) sendmsg("INPUT3",'C',0);
			prln((x*G_vfontwide)+(x1*G_vfontaw),y*G_vlsp,"%s",tmp);
			if (c) sendmsg("INPUT3",'C',-1);
			retval=1;
			break;

		case 'tt' :
            x1=va_arg(ap,int);
            x=va_arg(ap,int);
            y=va_arg(ap,int);
			if (x>80||x<0||y>30||y<0) RETURNV(1);
			c=sendmsg("INPUT3",'MI',x*G_vfontwide,y*G_vlsp,640,(y+2)*G_vlsp);
            f=va_arg(ap,char *);
		    vsprintf(tmp,f,ap);
			if (c) sendmsg("INPUT3",'C',0);
			tinyxy(x1,x*G_vfontwide,y*G_vlsp,"%s",tmp);
			if (c) sendmsg("INPUT3",'C',-1);
			retval=1;
			break;

		case 'R' :
			sendmsg("INPUT3",'C',0);
			retval=scr_reset();
			sendmsg("INPUT3",'C',1);
			break;
        case 'A' :
            c=va_arg(ap,int)&0xFF;
			if (c<4) {
				G_screen.attr=G_hattr[c];
			} else {
				G_screen.attr=c-3;
			}
			setcol(G_screen.attr);
            break;

        case 'AA' :
            G_screen.attr=va_arg(ap,int)&0xFF;
			setcol(G_screen.attr);
            break;

        case 'C' :
            x=va_arg(ap,int);
			x1=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			c=sendmsg("INPUT3",'MI',(x+x1)*G_vfontwide,y*G_vlsp,(x+x1+num)*G_vfontwide,(y+2)*G_vlsp);
			if (c) sendmsg("INPUT3",'C',0);
            cursor((x*G_vfontwide)+(x1*(G_vfontaw-G_backoneng)),y*G_vlsp,num);
			if (c) sendmsg("INPUT3",'C',-1);
            break;

        case 'Bl' :
            x=va_arg(ap,int);
			x1=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			c=sendmsg("INPUT3",'MI',(x+x1)*G_vfontwide,y*G_vlsp,(x+x1+num)*G_vfontwide,(y+2)*G_vlsp);
			if (c) sendmsg("INPUT3",'C',0);
            blank((x*G_vfontwide)+(x1*G_vfontaw),y*G_vlsp,num);
			if (c) sendmsg("INPUT3",'C',-1);
            break;

        case 'B' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            x1=va_arg(ap,int);
            y1=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            vfdbox(x,y,x1,y1);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'b' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            x1=va_arg(ap,int);
            y1=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            bar(x,y,x1,y1);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'L' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            x1=va_arg(ap,int);
            y1=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            vfdline(x,y,x1,y1);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'X' :
            G_screen.xor=va_arg(ap,int)&0xFF;
            break;


        case 'S' :
            G_screen.size=(va_arg(ap,int)%4);
            if (G_screen.size<1) G_screen.size=1;
			selectfont(G_screen.size-1);
            break;

        case 'l' :
            G_lights=va_arg(ap,int)&0xFF;
//		    setlights();
            break;

        case 'I' :
			sendmsg("INPUT3",'C',0);
            retval=scr_startup();
			G_onoff=1;
			sendmsg("INPUT3",'C',-1);
            break;
        case 'RI' :
			sendmsg("INPUT3",'C',0);
            retval=scr_restartup();
			sendmsg("INPUT3",'C',-1);
            break;

        case 'E' :
			G_onoff=0;
			sendmsg("INPUT3",'C',0);
            scr_shutdown();
            break;
        case 'TE' :
			sendmsg("INPUT3",'C',0);
            scr_tmpshutdown();
            break;

        case 'D' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            drawlogo(x,y,4);
			sendmsg("INPUT3",'C',-1);
            break;

        case 's' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            vfsink(x,y,num);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'r' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			sendmsg("INPUT3",'C',0);
            vfraise(x,y,num);
			sendmsg("INPUT3",'C',-1);
            break;
        case 'p' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
			retval=x+y;
			break;

        case 'SB' :
            f=va_arg(ap,char *);
			retval=savebmp(f);
			break;

        case 'P' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            f=va_arg(ap,char *);
			retval=0;
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",'C',0);
				putimage(x,y,img);
				sendmsg("INPUT3",'C',-1);
				freeimg(img);
				retval=1;
			} else {
				prln(x,y,"!%s!",f);
			}
			break;

        case '3' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            x1=va_arg(ap,int)*G_vfontwide;
            y1=va_arg(ap,int)*G_vlsp;
			sendmsg("INPUT3",'C',0);
            bezel(x,y,x1-1,y1-1,1);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'BT' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            x1=va_arg(ap,int)*G_vfontwide;
            y1=va_arg(ap,int)*G_vlsp;
            num=va_arg(ap,int);
            f=va_arg(ap,char *);
			sendmsg("INPUT3",'C',0);
            button(x+G_vfontwide/2,y+G_vlsp/2,x1-G_vfontwide/2,y1-G_vlsp/2,4,num,f,0);
			sendmsg("INPUT3",'C',-1);
            break;

        case 'AN' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            x1=va_arg(ap,int)*G_vlsp;
            y1=va_arg(ap,int);
            f=va_arg(ap,char *);
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",'C',0);
	            animimage(x,y,x1,y1,img);
				sendmsg("INPUT3",'C',-1);
				retval=1;
			} else {
				sendmsg("INPUT3",'C',0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!",f);
				sendmsg("INPUT3",'C',-1);
			}
            break;

        case 'DA' :
            f=va_arg(ap,char *);
            delfromanim(f);
    		retval=1;
            break;

        case 'TL' :
            f=va_arg(ap,char *);
			if ((img=getbmp(f))!=NULL) {
				freeimg(img);
            }
            retval=1;
            break;
        case 'RO' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            x1=va_arg(ap,int);
            f=va_arg(ap,char *);
            s=va_arg(ap,char *);
			retval=0;
			if ((img=getbmp(f))!=NULL) {
				if ((img2=getbmp(s))!=NULL) {
					sendmsg("INPUT3",'C',0);
		            flipimages(x,y,x1,img,img2);
					sendmsg("INPUT3",'C',-1);
					retval=1;
				}
			}
			if (!retval) {
				sendmsg("INPUT3",'C',0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!%s!",f,s);
				sendmsg("INPUT3",'C',-1);
			}
            break;

        case 'SC' :
            x=va_arg(ap,int)*G_vfontwide;
            y=va_arg(ap,int)*G_vlsp;
            x1=va_arg(ap,int)*G_vlsp;
            num=va_arg(ap,int);
            y1=va_arg(ap,int);
            f=va_arg(ap,char *);
			if ((img=getbmp(f))!=NULL) {
				sendmsg("INPUT3",'C',0);
	            rotimage(x,y,x1,num,y1,img);
				sendmsg("INPUT3",'C',-1);
				retval=1;
			} else {
				sendmsg("INPUT3",'C',0);
				prln(x*G_vfontwide,y*G_vlsp,"!%s!",f);
				sendmsg("INPUT3",'C',-1);
			}
            break;

        case 'F' :
            f=va_arg(ap,char *);
			readfont(f);
			retval=1;
			break;

        case 'f' :
            ff=va_arg(ap,char **);
			*ff=(char *)G_vfontspace;
			if (G_vfontspace==NULL) retval=0; 
			break;

        case 'N' :
			retval=isnew();
			break;
		case 'T' :					// TRANSLATE
            retval=strlen(va_arg(ap,char *));
			break;
			
		case 'K' :					// DIRECTION KEY PRESS
            retval=va_arg(ap,int);
			break;
		case 'OF' :
			G_onoff=0;
			retval=1;
			break;
		case 'ON' :
			G_onoff=1;
			retval=1;
			break;

        case 'SP' :
            pal=va_arg(ap,unsigned char *);
            for (x=0;x<16;x++) setrgbpalette(x,pal[x*3],pal[x*3+1],pal[x*3+2]);
            retval=1;
            break;

        case 'GP' :
            pal=va_arg(ap,unsigned char *);
			setcol(7);
            for (x=0;x<16;x++) getrgbpalette(x,pal+x*3,pal+x*3+1,pal+x*3+2);
            retval=1;
            break;

    }
    RETURNV(retval);
}
//___________________________________________________________________________
// screen control routine
int fscr_control(int type,va_list ap)
{
    unsigned char tmp[160],*f,**ff;
    int x,y,x1,y1,num;
    int retval=1;
	ENTRY(4130);
    switch (type) {
        case 'E' :
			retval=sendmsg("SCREEN",type);
			break;
        case 'D' :
			x=G_maxx-(va_arg(ap,int)+17);
            y=va_arg(ap,int);
			retval=sendmsg("SCREEN",type,x,y);
			break;

        case 'I' :
        case '1' :
        case '0' :
		case 'R' :
		case 'i' :
        case 'N' :
			retval=sendmsg("SCREEN",type);
			break;

        case 'S' :
            G_screen.size=(va_arg(ap,int)%4);
			retval=sendmsg("SCREEN",type,G_screen.size);
            break;

        case 'A' :
        case 'l' :
        case 'X' :
			num=va_arg(ap,int);
			retval=sendmsg("SCREEN",type,num);
            break;

        case 'b' :
            x=(G_maxx*8)-(va_arg(ap,int));
            y=va_arg(ap,int);
            x1=(G_maxx*8)-(va_arg(ap,int));
            y1=va_arg(ap,int);
            retval=sendmsg("SCREEN",type,x,y,x1,y1);
            break;
        case 'B' :
        case 'L' :
            x=G_maxx-(va_arg(ap,int));
            y=va_arg(ap,int);
            x1=G_maxx-(va_arg(ap,int));
            y1=va_arg(ap,int);
            retval=sendmsg("SCREEN",type,x,y,x1,y1);
            break;

        case 'C' :
            x=va_arg(ap,int);
			x1=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			if (num!=1) {
				x+=x1;
				x=G_maxx-(x+(num-1));
    	        retval=sendmsg("SCREEN",type,x,0,y,num);
			} else {
				retval=1;
			}
            break;

        case 'c' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            (char *)f=va_arg(ap,char *);
			strcpy((char *)tmp,(char *)f);
			if (tmp[0]==0) {
				x=G_maxx-x;
            	retval=sendmsg("SCREEN",'C',x,0,y,1);
			} else {
            	num=va_arg(ap,int);
				x1=0;
				if (num==strlen((char *)tmp)) { num--; x1=1; }
				convstr(tmp,&num);
				num=strlen((char *)tmp)-num;
				x=G_maxx-(x+(num-1));
            	retval=sendmsg("SCREEN",'C',x,0,y,1);
			}
            break;

        case 's' :
        case 'r' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            num=va_arg(ap,int);
			x=G_maxx-(x+(num-1));
            retval=sendmsg("SCREEN",type,x,y,num);
            break;

		case 'o' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            (char *)f=va_arg(ap,char *);
		    vsprintf((char *)tmp,(char *)f,ap);
            retval=1;
			if (tmp[0]!=0) {
				num=0;
				convstr(tmp,&num);
				num=strlen((char *)tmp)*(1+(G_screen.size>1));
				x=G_maxx-(x+(num-1)); 
				retval=sendmsg("SCREEN",type,x,y,"%s",tmp);
			}
			break;

        case 'p' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            (char *)f=va_arg(ap,char *);
			retval=cpos(f,x,y);
			break;

        case 'P' :
            x=va_arg(ap,int);
            y=va_arg(ap,int);
            (char *)f=va_arg(ap,char *);
			x1=(int)(getbmpsiz((char *)f)>>16);
			x=(G_maxx*8)-(x+x1);
			retval=sendmsg("SCREEN",type,x,y,f);
			break;

		case 'F' :
            (char *)f=va_arg(ap,char *);
			retval=sendmsg("SCREEN",type,f);
			loadcont((char *)f);
			break;

		case 'T' :					// TRANSLATE
            (char *)f=va_arg(ap,char *);
			strcpy((char *)tmp,(char *)f);
            retval=0;
			if (tmp[0]!=0) {
				num=0;
				convstr(tmp,&num);
				retval=strlen((char *)tmp);
				strcpy((char *)f,(char *)tmp);
			}
			break;

        case 'f' :
            ff=va_arg(ap,unsigned char **);
			*ff=G_contspace;
			if (G_contspace==NULL) retval=0; 
			break;

		case 'K' :					// DIRECTION KEY PRESS
			x=va_arg(ap,int);
            if (x==RGT) retval=LEFT;
				else if (x==LEFT) retval=RGT;
					else retval=x;
			break;
    }
    RETURNV(retval);
} 
#pragma option -p.

