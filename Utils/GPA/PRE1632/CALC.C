#define CALC_C

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "types.h"
#include "keydef.h"
#include "config.h"
#include "message.h"
#include "control.h"
#include "formhand.h"
#include "fldproc.h"
#include "function.h"
#include "translog.h"
#include "calc.h"

#define LOGLEN 14
#define LOGWID 13
#define XOFS   3
#define YOFS   0
#define TOFS   1+LOGLEN

INT G_printcalc=0;

double G_ctotal;
// truncate a numeric string at the decimal point
CHAR *dottrc(CHAR *s)
{
    CHAR *t;
	ENTRY(2660);
    t=s;
    while (*t) {
        if (*t=='.') *t=0;
        t++;
    }
    RETURNV(s);
}
void prtotal(INT x,INT y,CHAR *t)
{
	ENTRY(2665);
	x+=XOFS+1;
	y+=TOFS+YOFS;
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',3);
    sendmsg("OUTPUT1",'o',x,y,"%*.*s",LOGWID,LOGWID,t);
    sendmsg("OUTPUT1",'S',1);
    RETURN;
}
void pronel(INT x,INT y,CHAR *t)
{
	ENTRY(2666);
	x+=XOFS;
	y+=YOFS;
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',1);
    sendmsg("OUTPUT1",'o',x,y,"%*.*s",(LOGWID*2)+1,(LOGWID*2)+1,t);
    RETURN;
}
// place the calculator on the screen over the log
void upcalc(INT x,INT y)
{
    INT i;
    static CHAR first=1;
    CHAR tmp[40];
	ENTRY(2670);
	sendmsg("INPUT1",'NL',1);
	sendmsg("OUTPUT1",'P',x,y,"CALC.BMP");
    if (first) {
		if (G_cline!=NULL) FREE(G_cline);
		G_cline=MALLOC(LOGLEN*sizeof(CHAR *));
		if (G_cline==NULL) RETURN;
		for (i=0;i<LOGLEN;i++) {
			G_cline[i]=MALLOC(LOGWID+4);
			if (G_cline[i]==NULL) RETURN;
	        memset(G_cline[i],0,LOGWID+4);
		}
        G_ctotal=0.0;
        first=0;
    }
    for (i=LOGLEN-1;i>0;i--) pronel(x,y+i,G_cline[i]);
    sprintf(tmp,"%ld",G_ctotal);
    dottrc(tmp);
	prtotal(x,y,tmp);
	RETURN;
}
// remove the calculator from the log area
void downcalc(void)
{
	ENTRY(2680);
	sendmsg("INPUT1",'NL',0);
	sendmsg("OUTPUT1",'ON');
	RETURN;
}
// add a line to the calculator tally roll
void addline(INT x,INT y,INT k,CHAR *inputln)
{
    INT i;
	ENTRY(2690);
    if (k==CR) k=' ';

    for (i=0;i<LOGLEN-1;i++) strcpy(G_cline[i],G_cline[i+1]);
    sprintf(G_cline[LOGLEN-1],"%c %*.*s",k,LOGWID-2,LOGWID-2,inputln);
    if (k=='=') {
        for (i=0;i<LOGLEN-1;i++) strcpy(G_cline[i],G_cline[i+1]);
        sprintf(G_cline[LOGLEN-1],"%*.*s",LOGWID,LOGWID,"อออออออออออออออออออออออออออออออ");
    }

    for (i=LOGLEN-1;i>0;i--) pronel(x,y+i,G_cline[i]);
	RETURN;
}
// get the calculator tally roll total
void calctot(INT lastop,CHAR *inputln)
{
    double a,b;
    CHAR ws[50];
	ENTRY(2700);

    a=G_ctotal;
    b=atof(inputln);
    switch (lastop) {
        case '+'  :
            sprintf(ws,"%f",a+b);
            strcpy(inputln,dottrc(ws));
            break;
        case '-'  :
            sprintf(ws,"%f",a-b);
            strcpy(inputln,dottrc(ws));
            break;
        case '*'  :
            sprintf(ws,"%f",a*b);
            strcpy(inputln,dottrc(ws));
            break;
        case '/'  :
            if (b!=0.0) {
                sprintf(ws,"%f",a/b);
                strcpy(inputln,dottrc(ws));
            }
            break;
    }
    G_ctotal=atof(inputln);
	RETURN;
}
// process all calculator operations
CHAR *proccalc(INT x,INT y)
{
    INT xit=0;
    INT k;
    INT lasttype=0;
    static INT lastop=CR;
    static CHAR inputln[LOGWID+1];
    CHAR *p;
    INT pos=0;
	ENTRY(2710);
	p=inputln;
    upcalc(x,y);
    sprintf(inputln,"%ld",G_ctotal);
    dottrc(inputln);
	prdate();
    while (!xit) {
        switch(k=sendmsg("INPUT1",'i')) {
            case '+' :
            case '-' :
            case '*' :
            case '/' :
            case CR  :
                if (lasttype==1) {
                    lasttype=0;
                    addline(x,y,lastop,inputln);
                    if (G_printcalc) sendmsg("OUTPUT2",'o',-1,0,"%c  %-15s\r\n",lastop,inputln);
                    calctot(lastop,inputln);
					prtotal(x,y,inputln);
                }
                if (k==CR) {
                    addline(x,y,'=',inputln);
                    if (G_printcalc)  {
                        sendmsg("OUTPUT2",'o',-1,0,"==================\r\n");
                        sendmsg("OUTPUT2",'o',-1,0,"%c  %-15s\r\n",lastop,inputln);
                        sendmsg("OUTPUT2",'o',-1,0,"==================\r\n\r\n\r\n");
                    }
                }
                if ((k==CR)&&(lastop==CR)) xit=1; else lastop=k;
                pos=0;
                break;
            case F10  :
            case ESC  :
            case CALC :
                inputln[0]=0;
                xit=1;
                break;
            case BKSP :
                if (pos>0) {
                    inputln[--pos]=0;
					prtotal(x,y,inputln);
                }
                else {
                    beep();
                }
                break;
            case ' ' :
                for (pos=0;pos<LOGLEN;pos++) memset(G_cline[pos],0,LOGWID+1);
                G_ctotal=0.0;
                pos=0;
                lastop=CR;
                lasttype=0;
                upcalc(x,y);
                break;

            case 'p' :
            case 'P' :
                beep();
                G_printcalc^=1;
                break;

            case '0' :
            case '1' :
            case '2' :
            case '3' :
            case '4' :
            case '5' :
            case '6' :
            case '7' :
            case '8' :
            case '9' :
                lasttype=1;
                if (pos<LOGWID) {
                    inputln[pos++]=k;
                    inputln[pos]=0;
					prtotal(x,y,inputln);
                }
                else {
                    beep();
                }
                break;
            default :
                beep();
        }
    }
    downcalc();
    RETURNV(p); 
}
void fincalc(void)
{
	INT i;
	if (G_cline==NULL) RETURN;
	for (i=0;i<LOGLEN;i++) if (G_cline[i]!=NULL) FREE(G_cline[i]);
	FREE(G_cline);
	G_cline=NULL;
}
