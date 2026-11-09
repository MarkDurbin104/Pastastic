#define FLDPROC_C

//___________________________________________________________________________

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <dos.h>
#include <memory.h>
#include <stdlib.h>

#include "types.h"
#include "keydef.h"
#include "keynames.h"
#include "config.h"
#include "scaledev.h"
#include "message.h"
#include "formproc.h"
#include "formhand.h"
#include "fldproc.h"
#include "money.h"
#include "function.h"
#include "control.h"
#include "calc.h"

INT     G_wx;
INT     G_wy;
INT     G_wcurpos;
INT     G_wl;
CHAR    G_wt;
INT     G_winsert;
INT     G_wsize;
CHAR   *G_wtmp;
#ifndef DESIGNER
// print the system date and time in local language in the top right corner of the screen
INT prdate(void)
{
	static CHAR tmp[40];
    INT size;
	INT df=0;
	ENTRY(3030);
	if ((G_dateorder[3]>='0')&&(G_dateorder[3]<='9')) {
		df=atoi(&(G_dateorder[3]));
	}
	if (df==14) RETURNV(1);
	if ((strcmp(tmp,datestr(df)))||(sendmsg("OUTPUT1",'N'))) {
		strcpy(tmp,datestr(df));
	    size=sendmsg("OUTPUT1",'i');
	    sendmsg("OUTPUT1",'A',0);
	    sendmsg("OUTPUT1",'S',1);
	    sendmsg("OUTPUT1",'o',46,0,"%-33s",tmp);
	    sendmsg("OUTPUT1",'S',size);
	}
    RETURNV(1);
}
#endif
// check the input character against the input format
INT chkfmt(CHAR t,INT k)
{
	ENTRY(3040);
    if (t=='K') RETURNV(1);
    if (k<32) RETURNV(0);                // control/graphics CHAR

    switch(toupper(t)) {
        case 'F' :                      // Format 
            k=toupper(k);
            if (k=='D') RETURNV(1);
            if (k=='K') RETURNV(1);
            if (k=='P') RETURNV(1);
            if (k=='T') RETURNV(1);
            if (k=='A') RETURNV(1);
            if (k=='X') RETURNV(1);
            if (k=='Z') RETURNV(1);
            if (k=='U') RETURNV(1);
            if (k=='L') RETURNV(1);
            if (k=='M') RETURNV(1);
            if (k=='W') RETURNV(1);
            if (k=='9') RETURNV(1);
            break;
        case 'A' :                      // Alpha
            if (isalpha(k)) RETURNV(1);
            if (k==' ') RETURNV(1);
            break;
        case 'P' :                      // Password
        case 'X' :                      // Alpha-Numeric with spaces
            RETURNV(1);
        case 'Z' :                      // Alpha-Numeric without spaces
            if (isalnum(k)) RETURNV(1);
            break;
        case 'U' :                      // Uppercase with spaces
            if (isupper(k)) RETURNV(1);
            if (k==' ') RETURNV(1);
            break;
        case 'L' :                      // Lowercase with spaces
            if (islower(k)) RETURNV(1);
            if (k==' ') RETURNV(1);
            break;
        case 'M' :                      // Money
        case 'W' :                      // Weight
        case '9' :                      // Numeric
            if (isdigit(k)) RETURNV(1);
            break;
        case 'T' :                      // Time
            if (isdigit(k)) RETURNV(1);
            break;
        case 'D' :                      // Date
            if (isdigit(k)) RETURNV(1);
            break;
    }
    bde(k);
    RETURNV(0);
}
CHAR *applyformat(CHAR *s,CHAR *fmt,INT rl)
{
	INT i,j,l,m;
	static CHAR tmp[80];
	ENTRY(3041);
	memset(tmp,0,80);
    if (*fmt=='R') {
        fmt++;
        rl=2;
    } else if (*fmt=='r') {
        fmt++;
        rl=3;
    }
	l=strlen(fmt);
	m=strlen(s);
    if (rl>1) {
	    j=m-1;
	    for (i=l-1;i>=0;i--) {
		    if (chkfmt('F',fmt[i])) {
			    if (j>=0) {
				    tmp[i]=s[j--];
			    } else {
       			    tmp[i]=' ';
			    }
		    } else {
                if (rl==2) {
    			    if (j>=0) {
	        		    tmp[i]=fmt[i];
                    } else {
           			    tmp[i]=' ';
                    }
                } else {
    			    tmp[i]=fmt[i];
                }
		    }
	    }
    } else {
	    j=0;
	    for (i=0;i<l;i++) {
		    if (chkfmt('F',fmt[i])) {
			    if (j<m) {
				    tmp[i]=s[j++];
			    } else {
                    if (rl==0) {
    				    RETURNV(tmp);
                    } else {
        			    tmp[i]=' ';
                    }
			    }
		    } else {
			    tmp[i]=fmt[i];
		    }
	    }
    }
	RETURNV(tmp);
}
// place the cursor on the screen
void putcur(INT x,INT y,INT curpos,INT l,CHAR *fmt,INT insert,INT size,CHAR *s)
{
    INT i,j;
	INT t;
	ENTRY(3050);
	if (l==0) {
		l=strlen(fmt);
		t=fmt[0];
		for (i=1;i<l;i++) if (t!=fmt[i]) { t='Q'; break; }
	} else {
		t=fmt[0];
	}
    sendmsg("OUTPUT1",'c',x,y,s,curpos);
    switch (t) {
        case 'W' :
            for (i=strlen(G_weightf)-1,j=1;i>=0;i--,j++) 
                if ((G_weightf[i]=='9')||(G_weightf[i]=='~')) break;
            sendmsg("OUTPUT1",'C',x,((l-j)*(1+(size>1))),y,1,insert);
            break;
        case 'M' :
            for (i=strlen(G_moneyf)-1,j=1;i>=0;i--,j++)
                if ((G_moneyf[i]=='9')||(G_moneyf[i]=='~')) break;
            sendmsg("OUTPUT1",'C',x,((l-j)*(1+(size>1))),y,1,insert);
            break;
        case 'T' :
        case 'D' :
            i=0;
            if (curpos>1) i++;
            if (curpos>3) i++;
            sendmsg("OUTPUT1",'C',x,(i+curpos*(1+(size>1))),y,1,insert);
            break;
        case 'Q' :
			i=strlen(s);
			j=strlen(applyformat(s,fmt,0));
			curpos+=(j-i);
            // NO break;

        default :
            sendmsg("OUTPUT1",'C',x,curpos*(1+(size>1)),y,1,insert);
    }
	RETURN;
}
// get a two digit group for date and time display
CHAR *twodig(CHAR *s)
{
    static CHAR tmp[3];
	ENTRY(3060);

    if (*s) tmp[0]=*s; else tmp[0]=' ';
    s++;
    if (*s) tmp[1]=*s; else tmp[1]=' ';
    tmp[2]=0;
    RETURNV(tmp);
}
// RETURN a date string
CHAR *dstr(CHAR *s,INT l)
{
    CHAR instr[20];
    static CHAR opstr[20];
	ENTRY(3070);

    memset(instr,0,20);
    if (strlen(s)>19) s[19]=0;
    strcpy(instr,s);
    s=instr;

    switch (l) {
        case 2 :
      		strcpy(opstr,twodig(s));
            break;
        case 5 :
            strcpy(opstr,twodig(s));
            strcat(opstr,"-");
            strcat(opstr,twodig(s+2));
            break;
        case 8 :
            strcpy(opstr,twodig(s));
            strcat(opstr,"-");
            strcat(opstr,twodig(s+2));
            strcat(opstr,"-");
            strcat(opstr,twodig(s+4));
            break;
        case 10 :
            strcpy(opstr,twodig(s));
            strcat(opstr,"-");
            strcat(opstr,twodig(s+2));
            strcat(opstr,"-");
            strcat(opstr,s+4);
            break;
        default :
            strcpy(opstr,twodig(s));
            strcat(opstr,"-");
            strcat(opstr,twodig(s+2));
            strcat(opstr,"-");
            strcat(opstr,s+4);
            opstr[l]=0;
    }
    RETURNV(opstr);
}
// RETURN a time string
CHAR *tstr(CHAR *s,INT l)
{
    CHAR instr[20];
    static CHAR opstr[20];
	ENTRY(3080);

    memset(instr,0,20);
    strcpy(instr,s);
    s=instr;

    switch (l) {
        case 2 :
            strcpy(opstr,twodig(s));
            break;
        case 5 :
            strcpy(opstr,twodig(s));
            strcat(opstr,":");
            strcat(opstr,twodig(s+2));
            break;
        case 8 :
            strcpy(opstr,twodig(s));
            strcat(opstr,":");
            strcat(opstr,twodig(s+2));
            strcat(opstr,":");
            strcat(opstr,twodig(s+4));
            break;
        case 11 :
            strcpy(opstr,twodig(s));
            strcat(opstr,":");
            strcat(opstr,twodig(s+2));
            strcat(opstr,":");
            strcat(opstr,twodig(s+4));
            strcat(opstr,".");
            strcat(opstr,twodig(s+6));
            break;
        default :
            strcpy(opstr,twodig(s));
            strcat(opstr,":");
            strcat(opstr,twodig(s+2));
            strcat(opstr,":");
            strcat(opstr,twodig(s+4));
            strcat(opstr,".");
            strcat(opstr,twodig(s+6));
            opstr[l]=0;
    }
    RETURNV(opstr);
}
// RETURN a the name of a key on the keyboard given the keypress value
CHAR *keyname(INT k)
{
    static CHAR tmp[10];
	ENTRY(3090);

    if (k<33) {
        strcpy(tmp,G_keyname[k+176]);
    }
    else {
        tmp[0]=k;
        tmp[1]=0;
        if (k==127) strcpy(tmp,G_keyname[199]);
    }
    RETURNV(tmp);
}
// output a field on tha screen 
void output(INT x,INT y,CHAR *s,INT l,CHAR *fmt,INT size)
{

    CHAR tmp[80];
    INT largedisp=0;
    INT i,r,al,t;
	ENTRY(3100);

	if (l==0) {
		l=strlen(fmt);
		t=fmt[0];
		for (i=1;i<l;i++) if (t!=fmt[i]) { t='Q'; break; }
	} else {
		t=fmt[0];
	}
    if ((G_form.type==F_SERVE)||(G_form.type==F_PROMPT)) largedisp=1;

    sendmsg("OUTPUT1",'S',size);
    switch (t) {
        case 'K' :
			strcpy(tmp,keyname(atoi(s)));
			if (strlen(tmp)>l) tmp[l]=0;
			al=strlen(tmp);
			r=l-al;
            sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
            if (r>0) sendmsg("OUTPUT1",'o',x+(al*(1+(size>1))),y,"%*.*s",r,r,"");
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s",tmp);
                if (al<38) sendmsg("OUTPUT1",'o',G_parea[0]+1+al*2,G_parea[1]+1,"%*.*s",38-al,38-al,"");
            }
            break;

        case 'D' :
			strcpy(tmp,dstr(s,l));
			if (strlen(tmp)>l) tmp[l]=0;
            sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s%*.*s",tmp,38-l,38-l,"");
            }
            break;

        case 'T' :
			strcpy(tmp,tstr(s,l));
			if (strlen(tmp)>l) tmp[l]=0;
            sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s%*.*s",tmp,38-l,38-l,"");
            }
            break;

        case 'W' :
            if (G_scaleact) {
                i=sendmsg("SCALE",'i');
                if (i>=0) {
                    sprintf(tmp,"%d",i);
                }
                else {      
                    strcpy(tmp,s);
                }
            }
            else {      
                strcpy(tmp,s);
            }
			strcpy(tmp,formatstr(tmp,G_weightf,l));
			if (strlen(tmp)>l) tmp[l]=0;
            sendmsg("OUTPUT1",'o',x,y,tmp);
            if (largedisp) {
				al=strlen(G_weights)*2;
				if (al<4) al=4;
				l+=al;
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%*.*s",al,al,G_weights);
                sendmsg("OUTPUT1",'o',G_parea[0]+3+al,G_parea[1]+1," ");
                sendmsg("OUTPUT1",'o',G_parea[0]+5+al,G_parea[1]+1,"%s%*.*s",tmp,36-l,36-l,"");
            }
            break;

        case 'M' :
			strcpy(tmp,mstr(s,l));
			if (strlen(tmp)>l) tmp[l]=0;
            sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%2.2s",G_moneys);
                sendmsg("OUTPUT1",'o',G_parea[0]+5,G_parea[1]+1," ");
                sendmsg("OUTPUT1",'o',G_parea[0]+7,G_parea[1]+1,"%s%*.*s",tmp,34-l,34-l,"");
            }
            break;

        case 'Q' :
			strcpy(tmp,applyformat(s,fmt,0));
			if (strlen(tmp)>l) tmp[l]=0;
			al=sendmsg("OUTPUT1",'T',tmp);
			r=l-al;
            if (r>0) {
				sendmsg("OUTPUT1",'o',x,y,"%s%*.*s",tmp,r,r,"");
			} else {
            	sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
			}
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s",tmp);
                if (al<38) sendmsg("OUTPUT1",'o',G_parea[0]+1+al*2,G_parea[1]+1,"%*.*s",38-al,38-al,"");
            }
            break;

        case 'P' :
            for (i=0;i<strlen(s);i++) tmp[i]='*';
            tmp[i]=0;
			al=i;
			r=l-al;
			if (strlen(tmp)>l) tmp[l]=0;
// FARSI            sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
// FARSI            if (r>0) sendmsg("OUTPUT1",'o',x+(al*(1+(size>1))),y,"%*.*s",r,r,"");
            sendmsg("OUTPUT1",'o',x,y,"%s%*.*s",tmp,r,r,"");
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s",tmp);
                if (al<38) sendmsg("OUTPUT1",'o',G_parea[0]+1+al*2,G_parea[1]+1,"%*.*s",38-al,38-al,"");
            }
            break;

        default :
			strcpy(tmp,s);
			al=sendmsg("OUTPUT1",'T',tmp);
			r=l-al;
			strcpy(tmp,s);
			if (strlen(tmp)>l) tmp[l]=0;
// FARSI    sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
// FARSI    if (r>0) sendmsg("OUTPUT1",'od',x,(al*(1+(size>1))),y,"%*.*s",r,r,"");
            if (r>0) {
				sendmsg("OUTPUT1",'o',x,y,"%s%*.*s",tmp,r,r,"");
			} else {
            	sendmsg("OUTPUT1",'o',x,y,"%s",tmp);
			}
            if (largedisp) {
                sendmsg("OUTPUT1",'S',3);
                sendmsg("OUTPUT1",'A',0);
                sendmsg("OUTPUT1",'o',G_parea[0]+1,G_parea[1]+1,"%s",tmp);
                if (al<38) sendmsg("OUTPUT1",'o',G_parea[0]+1+al*2,G_parea[1]+1,"%*.*s",38-al,38-al,"");
            }
    }
    sendmsg("OUTPUT1",'S',size);
	RETURN;
}
// check the length of the inputed field
INT chklen(CHAR *s,INT l,CHAR *fmt)
{
	INT t,i;
	ENTRY(3110);
	if (l==0) {
		l=strlen(fmt);
		t=fmt[0];
		for (i=1;i<l;i++) if (t!=fmt[i]) { t='Q'; break; }
	} else {
		t=fmt[0];
	}
    switch (t) {
        case 'M' :
            if (*(mstr(s,l)+1)!=' ') RETURNV(1);
            break;
        case 'D' :
        case 'T' :
            if ((strlen(s)+strlen(s)/2)>l) RETURNV(1);
            break;
        case 'W' :
            if ((strlen(s)+1)>=l) RETURNV(1);
            break;
        case 'Q' :
            if ((strlen(applyformat(s,fmt,0)))>=l) RETURNV(1);
			break;
        default :
            if (strlen(s)>=l) RETURNV(1);
    }
    RETURNV(0);
}
// output the weight information
INT prweight(void)
{
	ENTRY(3120);
    if ((G_wt=='W')&&(G_scaleact)) {
        putcur(G_wx,G_wy,G_wcurpos,G_wl,&G_wt,(-1),G_wsize,G_wtmp);
        output(G_wx,G_wy,G_wtmp,G_wl,&G_wt,G_wsize);
        putcur(G_wx,G_wy,G_wcurpos,G_wl,&G_wt,G_winsert,G_wsize,G_wtmp);
    }
    RETURNV(1);
}
// input a string
INT inputstr(INT x,INT y,CHAR *s,CHAR *fmt,INT kp)
{
    INT curpos;
    INT size;
    INT l,ci=G_form.curitem;
    INT xit=0,changed=0;
    INT moved=0;           
    INT i,j,m;
    INT k;
    CHAR t;
	CHAR *tmp,*calcv,*afmt;
    static insert=1;
	ENTRY(3130);
	tmp=MALLOC(243);
	if (tmp==NULL) RETURNV(0);
	memset(tmp,0,243);
	calcv=tmp+81;
	afmt=tmp+162;
	strcpy(afmt,fmt);

    G_exitkey=0;
    l=strlen(fmt);
	t=afmt[0];
	for (i=0;i<l;i++) if (fmt[i]!=t) break;
	if (i!=l) {
		j=0;
		for (i=0;i<l;i++) if (chkfmt('F',fmt[i])) afmt[j++]=fmt[i];
		afmt[j]=0;
	}
    curpos=strlen(s);
    if (afmt[curpos]==0) t=afmt[curpos-1]; else t=afmt[curpos];
    strcpy(G_lastval,s);
    strcpy(tmp,s);
    if (l>80) l=80;
    if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) insert=1;

    size=sendmsg("OUTPUT1",'i');
	output(x,y,tmp,0,fmt,size);
    putcur(x,y,curpos,0,fmt,insert,size,tmp);
	prdate();
//    sendmsg("INPUT1",'A',9,prdate);
    sendmsg("INPUT1",'A',9,prweight);
    while (!xit) {
        if (afmt[curpos]==0) t=afmt[curpos-1]; else t=afmt[curpos];
        G_wx=x; G_wy=y; G_wcurpos=curpos; G_wl=l; G_wt=t; G_winsert=insert;
        G_wsize=size; G_wtmp=tmp;
        if (kp) {
			k=kp;
			kp=0;
		} else {
			k=sendmsg("INPUT1",'i');
		}
        putcur(x,y,curpos,0,fmt,(-1),size,tmp);
        switch(k) {
            case CALC :
                if (G_calcon) strcpy(calcv,proccalc(G_calcxpos,G_calcypos));
                if (calcv[0]!=0) {
                    if (!chklen(calcv,0,fmt)) {
                        strcpy(tmp,calcv);
                        curpos=strlen(tmp);
                        changed=1;
                        moved=1;
		                xit=1;
                    }
                    else {
                        beep();
                    }
                }
				break;

            case LEFT :
                if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) {
				    curpos=sendmsg("OUTPUT1",'p',curpos,-1,tmp);
                    if (curpos<0) curpos=0;
                    if (curpos>strlen(tmp)) curpos=strlen(tmp);
                    moved=1;
                }
                break;

            case RGT :
                if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) {
				    curpos=sendmsg("OUTPUT1",'p',curpos,1,tmp);
                    if (curpos<0) curpos=0;
                    if (curpos>strlen(tmp)) curpos=strlen(tmp);
                    moved=1;
                }
                break;

            case HOME :
                if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) {
                    curpos=0;
                    moved=1;
                }
                break;

            case END :
                if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) {
                    curpos=strlen(tmp);
                    moved=1;
                }
                break;

            case CF11 :
                if (t=='W') sendmsg("SCALE",'R');
                break;

            case INS :
                if ((t!='M')&&(t!='W')&&(t!='T')&&(t!='D')) {
                    insert^=1;
                    moved=1;
                }
                break;

            case UP :
                upfunc();
                xit=1;
                break;

            case EXIT_K :
                G_exitkey=EXIT_K;
                exitform();
                xit=1;
                break;

            case DOWN :
            case CR :
            case LF :
                xit=1;
                break;

            case ESC :
                changed=0;
                G_form.curitem--;
                curpos=strlen(s);
                strcpy(tmp,s);
                xit=1;
                break;

            case DEL :
                if (curpos<strlen(tmp)) {
                    for (i=curpos+1;i<=strlen(tmp);i++)
                        tmp[i-1]=tmp[i];
                    changed=1;
                    moved=1;
                }
                break;

            case BKSP :
                if (t=='K') {
                    curpos=0;
                    tmp[0]=0;
                    changed=1;
                    xit=1;
                }
                else {
                    if (curpos>0) {
                        curpos--;
                        if ((insert)||(curpos==strlen(tmp))) {
                            for (i=curpos+1;i<=strlen(tmp);i++)
                                tmp[i-1]=tmp[i];
                        }
                        else {
                            tmp[curpos]=' ';
                        }
                        changed=1;
                        moved=1;
                    }
                }
                break;

            case TAB :
                if (chkfmt(t,' ')) {
                    if (!moved) {
                        tmp[0]=0;
                        curpos=0;
                        moved=1;
                    }
                    k=' ';
                    m=TABSTOP-(curpos%TABSTOP);
                    for (j=0;j<m;j++) {
                        if (insert) {
                            for (i=strlen(tmp);i>=curpos;i--) tmp[i+1]=tmp[i];
                            tmp[curpos]=k;
                            if (chklen(tmp,0,fmt)) {
                                xit=1;
                                j=m;
                            }
                        }
                        else {
                            if (curpos==strlen(tmp)) {
                                tmp[curpos++]=k;
                                tmp[curpos]=0;
                                if (curpos>=l) {
                                    xit=1;
                                    j=m;
                                }
                            }
                            else {
                                tmp[curpos++]=k;
                            }
                        }
                        changed=1;
                    }
                }
                break;
            case LANGSWITCH : 
				if (G_form.numitem==G_form.curitem) {
	                G_exitkey=EXIT_K;
	                xit=1;
				}
				break;

            default :
                if (t=='U') k=toupper(k);
                if (t=='L') k=tolower(k);
                if (t=='K')  {
                    sprintf(tmp,"%d",k);
                    changed=1;
                    xit=1;
                }
                else {
                    if (t=='W') G_scaleact=0;
                    if (chkfmt(t,k)) {
                        if (!moved) {
                            tmp[0]=0;
                            curpos=0;
                            moved=1;
                        }
                        if (insert) {
                            for (i=strlen(tmp);i>=curpos;i--) tmp[i+1]=tmp[i];
                            tmp[curpos]=k;
                            curpos++;
                            if (chklen(tmp,0,fmt)) xit=1;
                        }
                        else {
                            if (curpos==strlen(tmp)) {
                                tmp[curpos++]=k;
                                tmp[curpos]=0;
                                if (curpos>=l) xit=1;
                            }
                            else {
                                tmp[curpos++]=k;
                            }
                        }
                        changed=1;
                    }
                    else {
#ifdef __TURBOC__
                        sound(750);
                        delay(150);
                        nosound();
#endif
                    }
                }
        }
		output(x,y,tmp,0,fmt,size);
        putcur(x,y,curpos,0,fmt,insert,size,tmp);
		if (ci!=G_form.curitem) xit=1;
		if ((G_exit2top)||(G_exit2mrk)) {
			G_form.curitem=G_form.numitem;
            G_exitkey=EXIT_K;
            xit=1;
		}
    }
    sendmsg("INPUT1",'D',prweight);
	prdate();
//    sendmsg("INPUT1",'D',prdate);
    putcur(x,y,curpos,0,fmt,(-1),size,tmp);

    if ((t=='W')&&(G_scaleact)) {
        i=sendmsg("SCALE",'i');
        if (i>0) {
            sprintf(tmp,"%d",i);
			l=strlen(tmp);
            changed=1;
            G_scaleact=0;
        }
    }
    if (changed) {
        tmp[l]=0;
        strcpy(s,tmp);
		if (tmp!=NULL) FREE(tmp);
        RETURNV(k);
    }
	if (tmp!=NULL) FREE(tmp);
    RETURNV(0);
}
