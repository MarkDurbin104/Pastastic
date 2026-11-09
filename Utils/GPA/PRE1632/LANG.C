#define LANG_C
#include <string.h>
#include <stdlib.h>
//#include <search.h>
#include "types.h"
#include "config.h"
#include "control.h"
#include "message.h"
#include "formhand.h"
#include "formproc.h"
#include "menuproc.h"
#include "tabproc.h"
#include "keydef.h"
//#include "gprim.h"
#include "lang.h"

INT G_swaplang=0;

INT justbutt(PFORM form)
{
	INT i,b=0;
	PFORMF f;
	CHAR *s;
	ENTRY(2420);
    for (i=0;i<form->numitem;i++) {
		f=&(form->items[i]);
		if (f->class==FF_TEXT) {
			s=langstr("OUTPUT1",f->item);
			if ((*s=='~')&&(*(s+1)=='B')) b=1;
		} else {
			if (f->class!=FF_DISP) RETURNV(0);
		}
	}
	RETURNV(b);
}
void adddevname(CHAR *n)
{
	INT i;
	ENTRY(2430);
	for (i=0;i<G_numdn;i++) if (!strcmp(G_devs[i],n)) RETURN;
	strcpy(G_devs[G_numdn++],n);
	RETURN;
}
void addlangname(CHAR *n)
{
	ENTRY(2440);
	strcpy(G_langs[G_lang],n);
	RETURN;
}
void setuplmap(CHAR *n,INT l,CHAR *t,CHAR *f)
{
	INT i;
	ENTRY(2450);
	if (G_numlm==0) {
		G_numlm=10;
		for (i=0;i<G_numlm;i++) G_langmaps[i].n=(-1);
	}
	for (i=0;i<G_numlm;i++) {
		if (!strcmp(n,G_langmaps[i].d)) {
			G_langmaps[i].n=l;
			strcpy(G_langmaps[i].t,t);
			strcpy(G_langmaps[i].f,f);
			RETURN;
		}
	}
	for (i=0;i<G_numlm;i++) {
		if (G_langmaps[i].n==(-1)) {
			strcpy(G_langmaps[i].d,n);
			strcpy(G_langmaps[i].t,t);
			strcpy(G_langmaps[i].f,f);
			G_langmaps[i].n=l;
			RETURN;
		}
	}
	RETURN;
}
void setoplang(CHAR *n)
{
	INT i;
	static CHAR tmp[10];
	ENTRY(2460);

	if (!strcmp(n,tmp)) RETURN;
	strcpy(tmp,n);

	for (i=0;i<G_numlm;i++) {
		if (!strcmp(n,G_langmaps[i].d)) {
//			if (G_textfile!=NULL) FREE(G_textfile);
//			G_textfile=STRDUP(G_langmaps[i].t);
			strcpy(G_textfile,G_langmaps[i].t);

//			if (G_fontfile!=NULL) FREE(G_fontfile);
//			G_fontfile=STRDUP(G_langmaps[i].f);
			strcpy(G_fontfile,G_langmaps[i].f);

	    	freetext();
	    	loadtext(G_system);
			sendmsg(n,'F',G_fontfile);
			RETURN;
		}
	}
	RETURN;
}
void restoreform(void)
{
	ENTRY(2470);
    if (G_form.type==F_MENU) {
		menucur();
        drawmenu();
		menucur();
    }
    else {
    	if ((G_form.type==F_SERVE)||(G_form.type==F_PROMPT)||(G_form.type==F_NORM)) {
            redrawform();
//          if ((G_intable)&&(G_swaplang==1))
			    G_finredraw=(-1);
            if (!strcmp(G_form.name,"logon")) sendmsg("OUTPUT1",'D',1,23);
        }
    }
	RETURN;
}
// swap to next language
void swaplang(void)
{
	INT i;
	ENTRY(2480);
    if (!G_canswitch) RETURN;

	if (G_lang<(G_numlang-1)) G_lang++; else G_lang=0;

	readlang(G_langfiles[G_lang]);
    freetext();
    loadtext(G_system);
	sendmsg("OUTPUT1",'F',G_fontfile);
	G_scanmap=readkeys();

	addlangname(G_name);

	for (i=0;i<G_numlm;i++) G_langmaps[i].n=(-1);
	setuplmap(G_scrname,G_lang,G_textfile,G_fontfile);
	G_swaplang=1;
	restoreform();
	G_swaplang=0;
	RETURN;
}
// Used by textstr to find string name
INT _cdecl scmp(const void *a,const void *b)
{
	ENTRY(2740);
    RETURNV(strcmp(*((CHAR **)a),*((CHAR **)b)));
}
CHAR *langtext(INT idx)
{
	ENTRY(2490);
    idx+=G_nut;
	RETURNV(atextstr(idx));
}
CHAR *langstr(CHAR *name,CHAR *s)
{
    INT j=0;
	ENTRY(2500);
 	setoplang(name);
    if (*(s+4)=='_') j=atoi(s+5); else j=atoi(s+4);
    if (j>(G_tcnt-G_nut)) RETURNV(s);
	RETURNV(langtext(j));
}
