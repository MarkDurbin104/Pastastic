#define MESSAGE_C
#include <dos.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include "types.h"
#include "config.h"
#include "control.h"
#include "lang.h"
#include "actions.h"
#include "message.h"
#include "formhand.h"
#include "formproc.h"
//~~~~~~~DO NOT REMOVE THIS LINE
//~~~~~~~DO NOT REMOVE THIS LINE

extern CHAR *G_keyname[];
INT G_dontsendonoff=0;
// #define MAXNUMBK 50 // Taiwan
#define MAXNUMBK 1
typedef struct {
	INT k ;
	INT x ;
	INT y ;
	INT x1;
	INT y1;
	CHAR s[40];
	CHAR st;
} BUTKEY;
BUTKEY G_butkey[MAXNUMBK];
INT G_numbk=0;
CHAR G_tline[80];

INT actatpos(INT x,INT y)
{
	INT i;
    PFORMF f;
	ENTRY(2510);
	for (i=0;i<G_form.numitem;i++) {
        f=&(G_form.items[i]);
		if (((x==f->pos.x)&&(y==f->pos.y))) {
			RETURNV(i);
		}
	}
	RETURNV(-1);
}
INT finddg(CHAR *name,CHAR *group)
{
	INT i;
	ENTRY(2520);
	for (i=0;i<NUMDEV;i++) {
		if (G_device[i].iu) {
			if (!strcmp(group,G_device[i].g)) {
				if (!strcmp(name,G_device[i].n)) RETURNV(i);
			}
		}
	}
	RETURNV(-1);
}
INT finddev(CHAR *name,INT idx)
{
	INT i;
	ENTRY(2530);
	for (i=idx+1;i<NUMDEV;i++) {
		if (G_device[i].iu) {
			if (!strcmp(name,G_device[i].g)) RETURNV(i);
		}
	}
	for (i=idx+1;i<NUMDEV;i++) {
		if (G_device[i].iu) {
			if (!strcmp(name,G_device[i].n)) RETURNV(i);
		}
	}
	RETURNV(-1);
}
INT devinlist(CHAR *name)
{
	INT i;
	ENTRY(2540);
	for (i=0;i<G_numdt;i++) {
		if (!strcmp(name,G_devtab[i]->name)) RETURNV(i+1);
	}
	RETURNV(0);
}
INT adddev(CHAR *name,CHAR *group,INT ofs)
{
	INT i;
	ENTRY(2550);
	for (i=0;i<NUMDEV;i++) {
		if (!G_device[i].iu) {
			G_device[i].iu=1;
			strcpy(G_device[i].g,group);
			strcpy(G_device[i].n,name);
			G_device[i].d=G_devtab[ofs];
			RETURNV(i);
		}
	}
	RETURNV(-1);
}
INT asigndev(CHAR *name,CHAR *group,CHAR mode)
{
	INT i,j;
	ENTRY(2560);
	if ((i=devinlist(name))==0) RETURNV(i);
	i--;
	adddevname(name);
	switch (mode) {
		case '+' :
			if (finddg(name,group)>=0) RETURNV(0);
			adddev(name,group,i);
			break;
		case '-' :
			if ((j=finddg(name,group))<0) RETURNV(0);
			G_device[j].iu=0;
			break;
		case 's' :
		case 'S' :
			j=(-1);
			while ((j=finddev(group,j))>=0) G_device[j].iu=0;
			adddev(name,group,i);
			break;
	}
	RETURNV(1);
}
INT passon(INT i,INT mtype,...)
{
	INT r=0;
	va_list ap;
	ENTRY(2575);
	va_start(ap,mtype);
	r=((G_device[i].d->control)(mtype,ap));
	va_end(ap);
	RETURNV(r);
}
void addbkey(INT k,INT x,INT y,INT x1,INT y1,CHAR *s,INT st)
{
	ENTRY(2580);
	if (G_numbk>=MAXNUMBK) RETURN;
	G_butkey[G_numbk].k =k ;
	G_butkey[G_numbk].x =x ;
	G_butkey[G_numbk].y =y ;
	G_butkey[G_numbk].x1=x1;
	G_butkey[G_numbk].y1=y1;
	G_butkey[G_numbk].st=st;
	strcpy(G_butkey[G_numbk].s,s);
	G_numbk++;
	sendmsg("INPUT3",'A',x,y,x+x1,y+y1,k);
	RETURN;
}
void runbact(INT k)
{
	INT i,x,y,x1,y1,idx,tcf;
	ENTRY(2590);
	for (i=0;i<G_numbk;i++) {
		if (G_butkey[i].k==k) {
			x =G_butkey[i].x;
			y =G_butkey[i].y;
			idx=actatpos(x,y);
			if ((isaction(G_form.items[idx].func)==0)
			&&  (isform  (G_form.items[idx].func)==(-1L))) RETURN;
			x1=G_butkey[i].x1;
			y1=G_butkey[i].y1;
			if (idx!=(-1)) {
				G_formvars[idx][0]^=1;
		        sendmsg("OUTPUT1",'A',G_form.items[idx].attrib);
		        sendmsg("OUTPUT1",'S',G_form.items[idx].size);
				sendmsg("OUTPUT1",'BT',x,y,x1+x,y1+y,(G_formvars[idx][0]&1)^1,G_butkey[i].s);
				G_keybutt=k;
				tcf=G_form.curitem;
				G_form.curitem=idx;
				runaction(G_form.items[idx].func);
				if (G_form.curitem==idx) G_form.curitem=tcf;
				G_keybutt=0;
				for (i=0;i<G_numbk;i++) {
					x =G_butkey[i].x;
					y =G_butkey[i].y;
					idx=actatpos(x,y);
					if (idx!=(-1)) {
//						if (G_butkey[i].st!=((G_formvars[idx][0]&1)^1)) {
							G_butkey[i].st=(G_formvars[idx][0]&1)^1;
							x1=G_butkey[i].x1;
							y1=G_butkey[i].y1;
			        		sendmsg("OUTPUT1",'A',G_form.items[idx].attrib);
			        		sendmsg("OUTPUT1",'S',G_form.items[idx].size);
							sendmsg("OUTPUT1",'BT',x,y,x1+x,y1+y,G_butkey[i].st,G_butkey[i].s);
//						}
					}
				}
			}
			RETURN;
		}
	}
	RETURN;
}
void near graphic(INT i,INT x,INT y,CHAR *s)
{
	INT x1,y1,num,l,k;
	CHAR *t;
	s++;
	ENTRY(2595);
	switch (*s) {
		case 'D' :
			if (G_tflds!=NULL) FREE(G_tflds);
			G_tflds=STRDUP(s+1);
			break;
		case 'P' :
			passon(i,'P',x,y,s+1);
			break;
		case 'R' :
			s++;
			x1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			strcpy(G_tline,s);
			s=t=G_tline;
			while ((*s)&&(*s!=',')) s++;
			if (*s==',') {
				*s=0;
				passon(i,'RO',x,y,x1,t,s+1);
			}
			break;
		case 'A' :
			s++;
			x1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			y1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			passon(i,'AN',x,y,x1,y1,s);
			break;
		case 'S' :
			s++;
			x1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			num=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			y1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			passon(i,'SC',x,y,x1,num,y1,s);
			break;
		case 'G' :
			s++;
			x1=atoi(s);
			while (isdigit(*s)) s++;
			y1=atoi(s+1);
			passon(i,'3',x,y,x1+x,y1+y);
			break;
		case 'B' :
			s++;
			x1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			y1=atoi(s);
			while (isdigit(*s)) s++;
			s++;
			strcpy(G_tline,s);
			t=G_tline;
			while ((*s)&&(*s!=',')) { s++; t++; }
			if (*s) {
				*t=0;
				s++;
				l=(G_formvars[actatpos(x,y)][0]&1)^1;
				passon(i,'BT',x,y,x1+x,y1+y,l,G_tline);
				num=strlen(s);
				if (num==1) {
					sendmsg("INPUT1",'K',*s,"~B",G_tline);
					addbkey(*s,x,y,x1,y1,G_tline,l);
				} else {
					k=0;
					while ((G_keyname[k]!=NULL)&&(k<10000)) {
						if (!strncmp(s,G_keyname[k],num)) {
							sendmsg("INPUT1",'K',k-176,"~B",G_tline);
							addbkey(k-176,x,y,x1,y1,G_tline,l);
							k=10000;
						}
						k++;
					}
				}
			} else {
				l=(G_formvars[actatpos(x,y)][0]&1)^1;
				passon(i,'BT',x,y,x1+x,y1+y,l,G_tline);
			}
			break;
		default :
			passon(i,'o',x,y,"%s",s-1);
	}
    RETURN;
}
INT sendmsg(CHAR *group,INT mtype,...)
{
	INT i=(-1),r=0,x,y;
	CHAR *s;
	va_list ap;
	ENTRY(2600);
	if (!strcmp(group,"REMHOT")) {
		sendmsg("INPUT3",'r');
		G_numbk=0;
		RETURNV(1);
	} else if (!strcmp(group,"HOTKEY")) {
		va_start(ap,mtype);
        s=va_arg(ap,CHAR *);
		va_end(ap);
		if ((*s=='~')&&(*(s+1)=='B')) {
			runbact(mtype);
		} else {
			runaction(s);
		}
		RETURNV(1);
	} else if (!strcmp(group,"SWAPLANG")) {
		swaplang();
		RETURNV(1);
	}
//	if ((G_dontsendonoff==1)&&((mtype=='0')||(mtype=='1'))) RETURNV(1);

	if (mtype=='?') {
		va_start(ap,mtype);
        s=va_arg(ap,CHAR *);
		va_end(ap);
		s=langstr(G_device[finddev(group,i)].n,s);
		RETURNV((*s!='~')&&(*(s+1)!='B'));
	} else if (mtype=='@') {
		va_start(ap,mtype);
        x=va_arg(ap,INT);
        y=va_arg(ap,INT);
        s=va_arg(ap,CHAR *);
		va_end(ap);
		mtype='o';
		while ((i=finddev(group,i))>=0) {
			s=langstr(G_device[i].n,s);
			if (*s=='~') {
				graphic(i,x,y,s);
			} else {
			 	passon(i,'o',x,y,"%s",s);
			}
		}
	} else {
		while ((i=finddev(group,i))>=0) {
			va_start(ap,mtype);
			r=((G_device[i].d->control)(mtype,ap));
			va_end(ap);
		}
		if (mtype=='ON') {
//            G_formloaded++;
			restoreform();
		}
	}
	RETURNV(r);
}
INT initdevices(void)
{
	FILE *fp;
	DEVHEADER *d;
	UINT i,j;
	CHAR s[81],tmp[20];
	CHAR *t;
	ENTRY(2610);
__asm { push ds
    pop  ax
    mov i,ax
}
	t=MK_FP(i,0);
	for (i=0;i<(65535U-sizeof(DEVHEADER));i++) {
		d=(DEVHEADER *)t;
		if ((d->sig1==DEVSIG)&&(d->sig2==DEVSIG)) {
			for (j=0;j<G_numdt;j++)
				if (!strcmp(d->name,G_devtab[j]->name)) break;
			if ((j==G_numdt)&&(G_numdt<29)) G_devtab[G_numdt++]=d;
		}
		t++;
	}
	if (!G_numdt) RETURNV(0);
	G_device=MALLOC(NUMDEV*sizeof(DEVTABLE));
	if (G_device==NULL) RETURNV(0);
	memset(G_device,0,NUMDEV*sizeof(DEVTABLE));
	fp=fopen("device.map","r");
	if (fp==NULL) {
		asigndev("VGA"     ,"OUTPUT1",'S');
		asigndev("PRN"     ,"OUTPUT2",'S');
		asigndev("KBD"     ,"INPUT1" ,'S');
		asigndev("DISK"    ,"DISK"   ,'S');
		asigndev("NETBIOS" ,"LAN"    ,'S');
		asigndev("PARADOX" ,"DBM"    ,'S');
	} else {
		while ((fgets(s,80,fp))!=NULL) {
			t=strtok(s," \n\t,");
			if (t!=NULL) {
				strcpy(tmp,t);
				tmp[9]=0;
				if (strcmp(tmp,"NO_CUSTD")) {
					t=strtok(NULL," \n\t,");
					*(t+9)=0;
					asigndev(tmp,t,'+');
				} else {
					G_dontsendonoff=1;
				}
			}
		}
		fclose(fp);
	}
	if (finddev("OUTPUT1",-1)<0) asigndev("VGA"     ,"OUTPUT1",'S');
	if (finddev("INPUT1" ,-1)<0) asigndev("KBD"     ,"INPUT1" ,'S');
	if (finddev("DBM"    ,-1)<0) asigndev("PARADOX" ,"DBM"    ,'S');
	if (finddev("DISK"   ,-1)<0) asigndev("DISK"    ,"DISK"   ,'S');
	RETURNV(1);
}
void prdevlist(void)
{
	INT i;
	ENTRY(2620);
	for (i=0;i<G_numdt;i++) {
		printf("\n%-8.8s %s",G_devtab[i]->name,G_devtab[i]->ownership);
	}
	printf("\nDEVICES USED\n");

	for (i=0;i<NUMDEV;i++) {
		if (G_device[i].iu) {
			printf("%-8.8s %-8.8s\n",G_device[i].n,G_device[i].g);
		}
	}
	RETURN;
}
void savedevices(void)
{
	INT i;
	ENTRY(2630);
	if (G_sdevice!=NULL) FREE(G_sdevice);
	G_sdevice=MALLOC(NUMDEV*sizeof(DEVTABLE));
	if (G_sdevice==NULL) RETURN;
	memset(G_sdevice,0,NUMDEV*sizeof(DEVTABLE));
	for (i=0;i<NUMDEV;i++) {
		G_sdevice[i].iu=G_device[i].iu;
		strcpy(G_sdevice[i].g,G_device[i].g);
		strcpy(G_sdevice[i].n,G_device[i].n);
		G_sdevice[i].d=G_device[i].d;
	}
	G_devsaved=1;
	RETURN;
}
void restdevices(void)
{
	INT i;
	ENTRY(2640);

	if (!G_devsaved) RETURN;

	if (G_sdevice==NULL) RETURN;
	for (i=0;i<NUMDEV;i++) {
		G_device[i].iu=G_sdevice[i].iu;
		strcpy(G_device[i].g,G_sdevice[i].g);
		strcpy(G_device[i].n,G_sdevice[i].n);
		G_device[i].d=G_sdevice[i].d;
	}
	FREE(G_sdevice);
	G_sdevice=NULL;
	RETURN;
}
void closedevices(void)
{
	ENTRY(2650);
	if (G_device!=NULL)  { FREE(G_device);  G_device=NULL;  }
	if (G_sdevice!=NULL) { FREE(G_sdevice); G_sdevice=NULL; }
//  known internal devices for optimised linker 
//	otherwise it doesn't include the device obj's in the exe
//	no such problems for user added devices !
//~~~~~~~DO NOT REMOVE THIS LINE
//~~~~~~~DO NOT REMOVE THIS LINE
	RETURN;
}

