#define CALC_C

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <mem.h>

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

double G_ctotal;
// truncate a numeric string at the decimal point
char *dottrc(char *s)
{
    char *t;
    t=s;
    while (*t) {
        if (*t=='.') *t=0;
        t++;
    }
    return(s);
}
// place the calculator on the screen over the log
void upcalc(void)
{
    int i,loglen=(G_larea[3]-G_larea[1])-1;
    static char first=1;
    char tmp[40];

    if (first) {
        memset(G_cline,0,sizeof(G_cline));
        G_ctotal=0.0;
        first=0;
    }
    for (i=loglen-1;i>0;i--) {
        sendmsg("OUTPUT1",'A',0);
        sendmsg("OUTPUT1",'S',1);
        sendmsg("OUTPUT1",'o',G_larea[0]+1,G_larea[1]+1+i,"%31.31s",G_cline[i]);
    }
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',3);
    sprintf(tmp,"%ld",G_ctotal);
    dottrc(tmp);
    sendmsg("OUTPUT1",'o',G_tarea[2]-2,G_tarea[1]+1," ");
    sendmsg("OUTPUT1",'o',G_tarea[0]+1,G_tarea[1]+1,"%17.17s",tmp);
    sendmsg("OUTPUT1",'S',1);
}
// remove the calculator from the log area
void downcalc(void)
{
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',3);
    sendmsg("OUTPUT1",'o',G_tarea[0]+1,G_tarea[1]+1,"%17.17s"," ");
    sendmsg("OUTPUT1",'S',1);
    sendmsg("OUTPUT1",'o',G_tarea[2]-1,G_tarea[1]+1," ");
    sendmsg("OUTPUT1",'o',G_tarea[2]-1,G_tarea[1]+2," ");
    displog(G_tindex);
}
// add a line to the calculator tally roll
void addline(int k,char *inputln)
{
    int i,loglen=(G_larea[3]-G_larea[1])-1;
    if (k==CR) k=' ';

    for (i=0;i<loglen-1;i++) strcpy(G_cline[i],G_cline[i+1]);
    sprintf(G_cline[loglen-1],"%c %15.15s",k,inputln);
    if (k=='=') {
        for (i=0;i<loglen-1;i++) strcpy(G_cline[i],G_cline[i+1]);
        strcpy(G_cline[loglen-1],"อออออออออออออออออออออออออออออออ");
    }

    for (i=loglen-1;i>0;i--) {
        sendmsg("OUTPUT1",'A',0);
        sendmsg("OUTPUT1",'S',1);
        sendmsg("OUTPUT1",'o',G_larea[0]+1,G_larea[1]+1+i,"%31.31s",G_cline[i]);
    }
}
// get the calculator tally roll total
void calctot(int lastop,char *inputln)
{
    double a,b;
    char ws[50];

    a=G_ctotal; // atof(&G_cline[loglen-2][2]);
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
}
// process all calculator operations
char *proccalc(void)
{
    int xit=0;
    int k;
    int lasttype=0;
    static int lastop=CR;
    char inputln[40];
    int pos=0;
    upcalc();
    sprintf(inputln,"%ld",G_ctotal);
    dottrc(inputln);
	prdate();
    sendmsg("INPUT1",'A',256,prdate);
    while (!xit) {
        switch(k=sendmsg("INPUT1",'i')) {
            case '+' :
            case '-' :
            case '*' :
            case '/' :
            case CR  :
                if (lasttype==1) {
                    lasttype=0;
                    addline(lastop,inputln);
                    calctot(lastop,inputln);
                    sendmsg("OUTPUT1",'A',0);
                    sendmsg("OUTPUT1",'S',3);
                    sendmsg("OUTPUT1",'o',G_tarea[0]+1,G_tarea[1]+1,"%17.17s",inputln);
                    sendmsg("OUTPUT1",'S',1);
                }
                if (k==CR) addline('=',inputln);
                if ((k==CR)&&(lastop==CR)) xit=1; else lastop=k;
                pos=0;
                break;
            case CALC :
                inputln[0]=0;
                xit=1;
                break;
            case BKSP :
                if (pos>0) {
                    inputln[--pos]=0;
                    sendmsg("OUTPUT1",'A',0);
                    sendmsg("OUTPUT1",'S',3);
                    sendmsg("OUTPUT1",'o',G_tarea[0]+1,G_tarea[1]+1,"%17.17s",inputln);
                    sendmsg("OUTPUT1",'S',1);
                }
                else {
                    beep();
                }
                break;
            case SPACE :
                memset(G_cline,0,sizeof(G_cline));
                G_ctotal=0.0;
                pos=0;
                lastop=CR;
                lasttype=0;
                upcalc();
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
                if (pos<15) {
                    inputln[pos++]=k;
                    inputln[pos]=0;
                    sendmsg("OUTPUT1",'A',0);
                    sendmsg("OUTPUT1",'S',3);
                    sendmsg("OUTPUT1",'o',G_tarea[0]+1,G_tarea[1]+1,"%17.17s",inputln);
                    sendmsg("OUTPUT1",'S',1);
                }
                else {
                    beep();
                }
                break;
            default :
                beep();
        }
    }
    sendmsg("INPUT1",'D',prdate);
    downcalc();
    return(inputln); 
}
