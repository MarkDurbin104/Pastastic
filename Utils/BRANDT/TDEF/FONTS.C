#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>
#include <conio.h>

void chkfont(void);
int twid(char *c);
long cngofs(char *c);
void outtxtxy(int x,int y,char *c);
int G_m,G_d;
unsigned char G_chardefs[1708];
unsigned int G_charofs[97];
main() {
	G_d=DETECT;
	initgraph(&G_m,&G_d,"");
	settextstyle(2,0,4);
	settextjustify(2,2);
	setcolor(14);
	outtextxy(100,40,"Hello There");
	setcolor(12);
	outtxtxy(100,40,"Hello There");
	return(1);
}
void chkfont(void) {
	int fd;
	if (G_chardefs[1707]!=170) {
		fd=open("litt.chr",O_RDONLY|O_BINARY);
		read(fd,G_chardefs,0x90); read(fd,G_charofs,192); read(fd,G_chardefs,96);
		G_charofs[96]=read(fd,G_chardefs,1706);
		close(fd);
		G_chardefs[1707]=170;
	}
}
int twid(char *c) {
	int x=0;
	unsigned char *t;
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-31]-4;
			if ((*t&127)>63) x+=(*t&127)-128; else x+=(*t&127);
		}
		c++;
	}
	return(x);
}
long cngofs(char *c) {
	long ret=0L;
	struct textsettingstype tt;
	gettextsettings(&tt);
	if (tt.horiz==1) ret=(twid(c)/2)-1;
	if (tt.horiz==2) ret=twid(c);
	ret<<=16; ret+=tt.vert*4; return(ret);
}
void outtxtxy(int x,int y,char *c) {
	int xp=0,yp;
	unsigned char *t;
	long ofs;
	chkfont();
	ofs=cngofs(c);
	x-=(int)(ofs>>16);
	y+=(int)(ofs&0xFFFF);
/*	y+=8;*/
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) moveto(x+xp,y-yp); else lineto(x+xp,y-yp);
				t+=2;
			}
		}
		c++;
	}
}
void outcxy(int x,int y,char c) {
	int xp,yp;
	char tmp[2];
	unsigned char *t;
	long ofs;
	chkfont();
	tmp[0]=c;
	tmp[1]=0;
	ofs=cngofs(tmp);
	x-=(int)(ofs>>16);
	y-=(int)(ofs&0xFFFF);
	if ((c>31)&&(c<=127)) {
		t=G_chardefs+G_charofs[c-32];
		while (t<G_chardefs+(G_charofs[c-31]-2)) {
			if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
			if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
			if (!(*(t+1)&128)) moveto(x+xp,y-yp); else lineto(x+xp,y-yp);
			t+=2;
		}
	}
}
void outixy(int x,int y,int i) {
	int xp=0,yp;
	char text[7],*c;
	unsigned char *t;
	long ofs;
	c=itoa(i,text,10);
	chkfont();
	ofs=cngofs(c);
	x-=(int)(ofs>>16);
	y-=(int)(ofs&0xFFFF);
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) moveto(x+xp,y-yp); else lineto(x+xp,y-yp);
				t+=2;
			}
		}
		c++;
	}
}
