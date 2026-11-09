#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>
#include <conio.h>
#include "tdchars.h"
extern	void	linto(int type,int x,int y);
extern	void	movto(int type,int x,int y);

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
long chkofs(char *c) {
	long ret=0L;
	struct textsettingstype tt;
	gettextsettings(&tt);
	if (tt.horiz==1) ret=(twid(c)/2)-1;
	if (tt.horiz==2) ret=twid(c);
	ret<<=16;
	ret+=(tt.charsize/4)*0x100;
	ret+=tt.vert*4; return(ret);
}
void outtxtxy(int x,int y,char *c) {
	int xp=0,yp,mul;
	unsigned char *t;
	long ofs;
	ofs=chkofs(c);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp*mul;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) movto(1,x+(xp*mul),y-(yp*mul)); else linto(1,x+(xp*mul),y-(yp*mul));
				t+=2;
			}
		}
		c++;
	}
}
void outcxy(int x,int y,char c) {
	int xp,yp,mul;
	char tmp[2];
	unsigned char *t;
	long ofs;
	tmp[0]=c;
	tmp[1]=0;
	ofs=chkofs(tmp);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	if ((c>31)&&(c<=127)) {
		t=G_chardefs+G_charofs[c-32];
		while (t<G_chardefs+(G_charofs[c-31]-2)) {
			if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
			if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
			if (!(*(t+1)&128)) movto(1,x+(xp*mul),y-(yp*mul)); else linto(1,x+(xp*mul),y-(yp*mul));
			t+=2;
		}
	}
}
void outixy(int x,int y,int i) {
	int xp=0,yp,mul;
	char text[7],*c;
	unsigned char *t;
	long ofs;
	c=itoa(i,text,10);
	ofs=chkofs(c);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp*mul;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) movto(1,x+(xp*mul),y-(yp*mul)); else linto(1,x+(xp*mul),y-(yp*mul));
				t+=2;
			}
		}
		c++;
	}
}
void xouttxtxy(int x,int y,char *c) {
	int xp=0,yp,mul;
	unsigned char *t;
	long ofs;
	ofs=chkofs(c);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp*mul;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) movto(0,x+(xp*mul),y-(yp*mul)); else linto(0,x+(xp*mul),y-(yp*mul));
				t+=2;
			}
		}
		c++;
	}
}
void xoutcxy(int x,int y,char c) {
	int xp,yp,mul;
	char tmp[2];
	unsigned char *t;
	long ofs;
	tmp[0]=c;
	tmp[1]=0;
	ofs=chkofs(tmp);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	if ((c>31)&&(c<=127)) {
		t=G_chardefs+G_charofs[c-32];
		while (t<G_chardefs+(G_charofs[c-31]-2)) {
			if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
			if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
			if (!(*(t+1)&128)) movto(0,x+(xp*mul),y-(yp*mul)); else linto(0,x+(xp*mul),y-(yp*mul));
			t+=2;
		}
	}
}
void xoutixy(int x,int y,int i) {
	int xp=0,yp,mul;
	char text[7],*c;
	unsigned char *t;
	long ofs;
	c=itoa(i,text,10);
	ofs=chkofs(c);
	mul=(int)((ofs&0xFF00)>>8);
	if (!mul) mul=1;
	x-=((int)(ofs>>16)*mul);
	y+=((int)(ofs&0x00FF)*mul);
	while (*c) {
		if ((*c>31)&&(*c<=127)) {
			t=G_chardefs+G_charofs[*c-32];
			x+=xp*mul;
			while (t<G_chardefs+(G_charofs[*c-31]-2)) {
				if ((*t&127)>63) xp=(*t&127)-128; else xp=(*t&127);
				if ((*(t+1)&127)>63) yp=(*(t+1)&127)-128; else yp=(*(t+1)&127);
				if (!(*(t+1)&128)) movto(0,x+(xp*mul),y-(yp*mul)); else linto(0,x+(xp*mul),y-(yp*mul));
				t+=2;
			}
		}
		c++;
	}
}
void xrectangle(int lft,int top,int rgt,int bot) {

	movto(0,lft,top);
	linto(0,rgt,top);
	linto(0,rgt,bot);
	linto(0,lft,bot);
	linto(0,lft,top);
}