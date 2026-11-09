/****************************************************************************
* Project     : GPA
* File        : calc.c
* Description : functions process and print the hotkey calculator
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:58  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/calc.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:58   JGRAY
*  
* 
****************************************************************************/
#define CALC_C

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "gpasizes.h"
#include "types.h"
#include "keydef.h"
#include "config.h"
#include "message.h"
#include "control.h"
#include "formhand.h"
#include "fldproc.h"
#include "function.h"
#include "translog.h"
#include "money.h"
#include "calc.h"

//*************************************************************************
//S reset the buffer containing the addlist and the total box

void resetaddlist(void)
{
    INT i;
    strcpy(G_ctotal,"0");
    if (G_cline==NULL) {
        G_numcl=0;
        return;
    }
    if (G_numcl!=0) for (i=0;i<G_numcl;i++) FREE(G_cline[i]);
    G_numallcl=0;
    FREE(G_cline);
    G_cline=NULL;
    G_numcl=0;
}
//*************************************************************************
//S print the total in the total box
//P integer x coord
//P integer y coord
//P char string total 

void prtotal(INT x,INT y,CHAR *total)
{
    x+=XOFS+1;
    y+=TOFS+YOFS;
    output(x,y,total,LOGWID,"M",3,0);
}

//*************************************************************************
//S display addlist
//P x co-ord
//P y co-ord
//P the offset form the bottom of the list
//P total
//R the offset 

INT dispaddlist(INT x,INT y,INT ofs,CHAR *total)
{
    INT i,j;
    x+=XOFS;
    y+=YOFS;
    j=G_numcl-1;
    if (G_numcl<(LOGLEN-2)) ofs=0; // Not enough lines to scroll

    if (ofs<0) ofs=0;   // off the bottom
    if (ofs) {          // adjust for over top of list
        if (ofs>(j-(LOGLEN-2))) {
            ofs=(j-(LOGLEN-2));
        }
        j-=ofs;
    }
    for (i=LOGLEN-1;i>0;i--) {
        if ((j>=0)&&(G_numcl!=0)&&(j<G_numcl)) {
            if (G_cline[j][0]!='Í') {
                output(x,y+i,&G_cline[j][1],ADDWID,"M",1,0);
                output(x,y+i,G_cline[j],1,"X",1,0);
            } else {
                output(x,y+i,G_cline[j],ADDWID,"X",1,0);
            }
        } else {
            output(x,y+i," ",ADDWID,"X",1,0);
        }
        j--;
    }
    prtotal(x-XOFS,y-YOFS,total);
    return ofs;
}

//***************************************************************************
//S add new line to addlist (just allocate space for new line)
//R new line offset in G_cline

INT addnewline(void)
{
    if (G_cline==NULL) {
        G_numallcl=ADDLISTINC;
        G_cline=MALLOC(G_numallcl*sizeof(CHAR *));
        G_numcl=1;
        if (G_cline==NULL) return(-1);
    } else {
        if (G_numcl>=G_numallcl-1) {
            G_numallcl+=ADDLISTINC;
            G_cline=REALLOC(G_cline,G_numallcl*sizeof(CHAR *));
            if (G_cline==NULL) {
                G_numcl=0;
                return(-1);
            }
        }
        G_numcl++;
    }
    return G_numcl-1;
}

//************************************************************
//S add floating point value to string Global ctotal
//P float value

void addon(double val)
{
    sprintf(G_ctotal,"%*.0f",ADDWID,atof(G_ctotal)+val);
}

//************************************************************
//S sub floating point value from string Global ctotal
//P float value

void takeoff(double val)
{
    sprintf(G_ctotal,"%*.0f",ADDWID,atof(G_ctotal)-val);
}

//************************************************************
//S multiply string Global ctotal by float value AND DIVIDE BY 100
//P float value

void mulby(double val)
{
    sprintf(G_ctotal,"%*.0f",ADDWID,(atof(G_ctotal)*val)/100.0);
}

//************************************************************
//S MULTIPLY string Global ctotal by 100 then divide by float value 
//P float value

void divby(double val)
{
    if (val) sprintf(G_ctotal,"%*.0f",ADDWID,(atof(G_ctotal)*100.0)/val);
}

//************************************************************
//S Add new line to addlist complete with displayed output
// n.b. update previous operator with current one
//P integer x coord
//P integer y coord
//P integer current operator
//P address of integer previous operator
//P existing line

void addline(INT x,INT y,INT k,INT *prevoperator,CHAR *inln)
{
    double val;
    CHAR tt[LOGWID+1];
    CHAR ln[LOGWID+1];
    INT i;

    strcpy(ln,inln);

    val=atof(ln);
    if (val) {
        switch (*prevoperator) {
            case '='  : sprintf(ln,"=%s",G_ctotal); break;
            case '+'  : addon(val);                 break;
            case '-'  : takeoff(val);               break;
            case '*'  : mulby(val);                 break;
            case '/'  : divby(val);                 break;
            default   :
                if (atof(G_ctotal) == 0) {
                    addon(val);         // First line simply place in buffer
                }
                break;          // 0 - no operator
        }
    }
    if (k!='=')
        {
        if (*prevoperator)
            {
            sprintf(tt,"%c%s",*prevoperator,ln);
            }
        else
            {
            sprintf(tt," %s",ln);
            }
        strcpy(ln,tt);
        *prevoperator=k;
        }
    else
        {
        sprintf(ln,"=%s",G_ctotal);
        *prevoperator = 0;              // clear 
        }
    i=addnewline();
    if (i>=0) G_cline[i]=STRDUP(ln);
    dispaddlist(x,y,0,G_ctotal);
}

//*************************************************************************
//S add the total bars "=============================" to the log
//P integer x coord
//P integer y coord

void addtotln(INT x,INT y)
{
    INT i;
    CHAR tt[ADDWID+1];
    memset(tt,'Í',ADDWID);
    tt[ADDWID]=0;
    i=addnewline();
    if (i>=0) G_cline[i]=STRDUP(tt);
    dispaddlist(x,y,0,"0");
}

//*************************************************************************
//S display the help list text - in english :JGQ 24/10
//P integer x coord
//P integer y coord

void helplist(INT x,INT y)
{
    
    x+=XOFS;
    y+=YOFS+1;
    output(x,y++,"{F5}        Print Addlist"  ,ADDWID,"X",1,0);
    output(x,y++,"{F10}       Post Result"    ,ADDWID,"X",1,0);
    output(x,y++,"0-9         Numeric Keys"   ,ADDWID,"X",1,0);
    output(x,y++,"+-*\/        Arithmetic Keys",ADDWID,"X",1,0);
    output(x,y++,"ENTER       Acts as \"=\""  ,ADDWID,"X",1,0);
    output(x,y++,"SPACE or C  Clear Addlist"  ,ADDWID,"X",1,0);
    output(x,y++,"BACKSPACE   Delete Digit"   ,ADDWID,"X",1,0);
    output(x,y++,"PAGE UP     Up 1 Page"      ,ADDWID,"X",1,0);
    output(x,y++,"PAGE DOWN   Down 1 Page"    ,ADDWID,"X",1,0);
    output(x,y++,"UP          Up 1 Line"      ,ADDWID,"X",1,0);
    output(x,y++,"DOWN        Down 1 Line"    ,ADDWID,"X",1,0);
    output(x,y++," "                          ,ADDWID,"X",1,0);
    output(x,y++,"PRESS A KEY"                ,ADDWID,"X",1,0);
    sendmsg("INPUT1",MESSAGE_i);
}

//************************************************************
//S Send add list to output2 i.e. print it
//P string to print at tail of page

void printaddlist(CHAR *t)
{
    INT i;
    CHAR tmp[ADDWID+2];

    if (!G_numcl) return;
    sendmsg("OUTPUT2",MESSAGE_S,1);
    sendmsg("OUTPUT2",MESSAGE_A,0);
    for (i=0;i<G_numcl;i++) {
        if (G_cline[i][0]!='Í') {
            strcpy(tmp,mstr(&(G_cline[i][1]),ADDWID));
            sendmsg("OUTPUT2",MESSAGE_o,0,i,"%s",tmp);
            sendmsg("OUTPUT2",MESSAGE_o,0,i,"%c",G_cline[i][0]);
        } else {
            sendmsg("OUTPUT2",MESSAGE_o,0,i,"%s",G_cline[i]);
        }
    }
    sendmsg("OUTPUT2",MESSAGE_S,3);
    sendmsg("OUTPUT2",MESSAGE_o,0,i+1,"%s",t);
    sendmsg("OUTPUT2",MESSAGE_F);
    sendmsg("OUTPUT2",MESSAGE_SP,0,1);
}
//************************************************************************
//S process the calculator (Entry point)
//P integer x coord
//P integer y coord
//R return post value or enpty string for no Post

CHAR *proccalc(INT x,INT y)
{
    static CHAR inputln[LOGWID+1];
    CHAR tmpln[LOGWID+1];
    INT numpressed=0;   // flag to say last key press was a number
    INT xit=0;
    INT pos=0;          // current input position in the string
    INT viewofs=0;      // current ofset in the log for PGUP DN etc.
    INT needredraw=0;   // TRUE if PGUP DN etc pressed
    INT k;
    INT postkey=G_lasthotkey; // key used to Enter and Post
    INT prevoperator=0;     // last operator key pressed. 0 for none
    INT totalshowing=0;     // flag indicating if a total (= result) is
                            // displayed and also in G_catotal
    INT printscron=G_printscron;     // entry state of G_printscron
    G_hotkeys=0;        // turn off hotkeys      in calculator
    G_finredraw=1;      // turn off table redraw in calculator
    G_printscron=0;     // turn off print screen in calculator
    G_incalc=1;
    sendmsg("INPUT1",MESSAGE_NL,1); // Numlock ON
    sendmsg("OUTPUT1",MESSAGE_P,x,y,"CALC.BMP");
    resetaddlist();
    inputln[0]=0;
    G_ctempformtype=G_form.type;
    G_form.type=F_NORM;
    while (!xit) {
        while (sendmsg("INPUT1",MESSAGE_H)==0) {
            if (G_calcredraw) {
                sendmsg("INPUT1",MESSAGE_NL,1); // Numlock ON
                sendmsg("OUTPUT1",MESSAGE_P,x,y,"CALC.BMP");
                dispaddlist(x,y,viewofs,inputln);
                G_calcredraw=0;
            }
        }
        k=(INT)sendmsg("INPUT1",MESSAGE_i);
        sprintf(tmpln,"%.0f",atof(G_ctotal));
        if ((strlen(tmpln)>10)&&(k!='C')&&(k!=CR)&&(k!=' ')&&(k!=ESC)&&(k!=F10)&&(k!=postkey)) {
            beep();
        } else {
            switch(k) {
                case F01 :
                    helplist(x,y);
                    break;
                case CF11 :
                case '+' :
                case '-' :
                case '*' :
                case '/' :
                    if (k==CF11) k='+'; //CAPTURE numeric keypad +. Treat and display as a plus
                    if (numpressed>0) {
                        addline(x,y,k,&prevoperator,inputln);
                    } else if (prevoperator==0) {
                        addline(x,y,k,&prevoperator,inputln);
                    } else {
                        prevoperator=k;
                    }
                    pos=0;
                    numpressed=0;
                    totalshowing=0;     // clear flag
                    break;
                case CR  :  // =
                    if (numpressed>0) {
                        addline(x,y,'+',&prevoperator,inputln);
                        numpressed=0;
                    }
                    if (numpressed==0) {
                        addtotln(x,y);
                        prevoperator=0;
                        addline(x,y,'=',&prevoperator,inputln);
                        addtotln(x,y);
                        totalshowing=1;     // set flag
                    }
                    inputln[0]=0;
                    sprintf(inputln,"%.0f",atof(G_ctotal));  // strip spaces
                    strcpy(G_ctotal,inputln);
                    prtotal(x,y,inputln);
                    numpressed=(-1); // stop CR CR entering two bars
                    break;
                case F05  :
                    printaddlist(inputln);
                    break;
                case F10  :
                case ESC  :
                    inputln[0]=0;
                    //NO break;
//                case CALC : done by postkey
                    resetaddlist();
                    xit=1;
                    break;
                case BKSP :
                    if (pos>0) {
                        inputln[--pos]=0;
                        prtotal(x,y,inputln);
                    } else beep();
                    break;
                case 'C' :
                case ' ' :
                    resetaddlist();
                    pos=0;
                    inputln[0]=0;
                    prtotal(x,y,inputln);
                    prevoperator=0;
                    break;

                case '.' :
                    if (totalshowing) {
                        inputln[0]=0;           // clear line
                        pos=0;
                        strcpy(G_ctotal,"0");   // clear total
                        totalshowing=0;
                    }
                    if (pos<10) {
                        inputln[pos++]='0';
                        if (pos<10) inputln[pos++]='0';
                        inputln[pos]=0;
                        prtotal(x,y,inputln);
                    }
                    numpressed=1;
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
                    if (totalshowing) {
                        inputln[0]=0;           // clear line
                        pos=0;
                        strcpy(G_ctotal,"0");   // clear total
                        totalshowing=0;
                    }
                    if (pos<10) {
                        inputln[pos++]=(CHAR)k;
                        inputln[pos]=0;
                        prtotal(x,y,inputln);
                    }
                    else {
                        beep();
                    }
                    numpressed=1;
                    break;
                case PGUP :
                    viewofs=dispaddlist(x,y,viewofs+LOGLEN,inputln);
                    break;
                case PGDN :
                    viewofs=dispaddlist(x,y,viewofs-LOGLEN,inputln);
                    break;
                case UP   :
                    viewofs=dispaddlist(x,y,viewofs+1,inputln);
                    break;
                case DOWN :
                    viewofs=dispaddlist(x,y,viewofs-1,inputln);
                    break;
                default :
                    if (k==postkey) {
                        sprintf(inputln,"%.0f",atof(inputln));  // strip spaces
                        resetaddlist();
                        xit=1;
                    } else {
                        beep();
                    }
            }
            switch (k) {
                case PGUP :
                case PGDN :
                case UP   :
                case DOWN :
                    needredraw=1;
                    break;
                case 'C'  :
                case ' '  :
                case F01  :
                    dispaddlist(x,y,viewofs,inputln);
                    needredraw=0;
                    break;
                default   :
                    if (needredraw) {
                        dispaddlist(x,y,viewofs,inputln);
                        needredraw=0;
                    }
                    viewofs=0;
            }
        }
    }
    G_incalc=0;
    G_form.type=G_ctempformtype;
    G_ctempformtype=0;
    G_formloaded++;  // increment to force the form that ran proccalc to redraw
    G_hotkeys=1;
    G_printscron=printscron; // reset print screen to entry value
    return(inputln); 
}

// **************************************************************************
// calc.c <end-of-file>
