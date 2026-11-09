#define ACTIONS_C

#include <string.h>
#include <mem.h>
#include <stdio.h>
#include <stdlib.h>
#include <alloc.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <dos.h>

#include "types.h"
#include "keydef.h"
#include "config.h"
#include "scrdev.h"
#include "kbddev.h"
#include "formproc.h"
#include "menuproc.h"
#include "formhand.h"
#include "menuproc.h"
#include "function.h"
#include "actions.h"
#include "control.h"
#include "instruct.h"

int loadnewform(char *name,long index);

// Push a value onto the DATA stack
void push(long l)
{
    G_stack[G_sp++]=l;
}
// Pop a value from the DATA stack
long pop(void)
{
    return(G_stack[--G_sp]);
}
// Push a value onto the CALL stack
void cpush(char *c)
{
    G_cstack[G_csp++]=c;
}
// Pop a value from the CALL stack
char *cpop(void)
{
    return(G_cstack[--G_csp]);
}
// replacement cprintf command (only writes to top half of screen)
void mprintf(char *fmt, ... )
{
    unsigned char *scr=(unsigned char *)0xB8000000L;
    unsigned char str[140],*s;
    va_list ap;
    static int x=0;
    static int y=0;

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    if ((unsigned char)(str[0])=='þ') { x=0; y=0; return; }

    s=str;
    while (*s) {
        *(scr+x*2+y*160)=*s;
        *(scr+x*2+y*160+1)=G_attr;
        s++;
        x++;
        if (x==80) {
            y++;
            x=0;
        }
        if (y==10) {
            y--;
            memcpy(scr,scr+160,1600);
        }
    }
}
// prints all the stack and variable information
void pstack(void)
{
    int i,j;
    textattr(9);
    gotoxy(1,13);
    cprintf("  DATA  ");
    gotoxy(11,13);
    cprintf("  CALL  ");
    gotoxy(30,13);
    cprintf(" VARIABLES ");
    gotoxy(60,13);
    cprintf(" FORM VARS ");
    textattr(7);
    for (i=G_sp-1,j=14;j<25;i--,j++) {
        gotoxy(1,j);
        if (i>=0)
            cprintf("%9ld",G_stack[i]);
        else 
            cprintf("         ");
    }
    textattr(8);
    for (i=G_csp-1,j=14;j<25;i--,j++) {
        gotoxy(11,j);
        if (i>=0)
            cprintf("%9ld",G_cstack[i]);
        else 
            cprintf("         ");
    }
    textattr(11);
    for (i=0;i<3;i++) {
        for (j=14;j<24;j++) {
            gotoxy(20+i*10,j);
            cprintf("%9ld",G_vars[i*10+j-14]);
        }
    }
    for (i=0;i<3;i++) {
        for (j=14;j<24;j++) {
            gotoxy(50+i*10,j);
            if ((i*10+j-14)==G_form.curitem) textattr(12); else textattr(10);
            cprintf("%9ld",G_fvars[i*10+j-14]);
        }
    }
}

// print the name of token p 
void ptok(unsigned char *p)
{
    switch (*p) {
        case TCONSTANT : mprintf("%d ",*((unsigned char *)(p+1)));  break;
        case SCONSTANT : mprintf("%d ",*((unsigned int *)(p+1)));   break;
        case LCONSTANT : mprintf("%ld ",*((unsigned long *)(p+1))); break;
        case DCONSTANT : mprintf("%f ",*((double *)(p+1)));         break;
        case TABLE     : mprintf("TABLE ");                         break;
        case ANAME     : mprintf("ACTION ");                        break;
        case EQUAL     : mprintf("= ");                             break;
        case LOGIC_AND : mprintf("&& ");                            break;
        case LOGIC_OR  : mprintf("|| ");                            break;
        case LOGIC_NOT : mprintf("! ");                             break;
        case LESSEQUAL : mprintf("<= ");                            break;
        case LESS      : mprintf("< ");                             break;
        case GREATEQUAL: mprintf(">= ");                            break;
        case GREAT     : mprintf("> ");                             break;
        case EQUALITY  : mprintf("== ");                            break;
        case NOTEQUAL  : mprintf("!= ");                            break;
        case PLUS      : mprintf("+ ");                             break;
        case MINUS     : mprintf("- ");                             break;
        case MULTIPLY  : mprintf("* ");                             break;
        case MODULUS   : mprintf("% ");                             break;
        case DEVIDE    : mprintf("/ ");                             break;
        case NEGATE    : mprintf("N ");                             break;
        case OCURLY    : mprintf("{ ");                             break;
        case CCURLY    : mprintf("} ");                             break;
        case FORMVAR   : mprintf("F ");                             break;
        case VARIABLE  : mprintf("V ");                             break;
        case ABS       : mprintf("ABS ");                           break;
        case ACOS      : mprintf("ACOS ");                          break;
        case ASIN      : mprintf("ASIN ");                          break;
        case ATAN      : mprintf("ATAN ");                          break;
        case COSH      : mprintf("COSH ");                          break;
        case COS       : mprintf("COS ");                           break;
        case EXP       : mprintf("EXP ");                           break;
        case LOG10     : mprintf("LOG10 ");                         break;
        case LOGAR     : mprintf("LOG ");                           break;
        case ROUND     : mprintf("ROUND ");                         break;
        case POW10     : mprintf("POW10 ");                         break;
        case SINH      : mprintf("SINH ");                          break;
        case SIN       : mprintf("SIN ");                           break;
        case SQRT      : mprintf("SQRT ");                          break;
        case SQR       : mprintf("SQR ");                           break;
        case TANH      : mprintf("TANH ");                          break;
        case TAN       : mprintf("TAN ");                           break;
        case TRUNC     : mprintf("TRUNC ");                         break;
        case GOTOXY    : mprintf("XY ");                            break;
        case MARKER    : mprintf("*** ");                           break;
        case WHILE     : mprintf("WH ");                            break;
        case IF        : mprintf("IF ");                            break;
        case ELSE      : mprintf("EL ");                            break;
        case SETFMVAR  : mprintf("@F ");                            break;
        case SETVARIAB : mprintf("@V ");                            break;
        case ACTIONN   : mprintf("ACT ");                           break;
        case RANGE     : mprintf("<-> ");                           break;
        case RESULT    : mprintf("ð ");                             break;
        case LOOKUP    : mprintf("LOOK ");                          break;
        case LOOKTAB   : mprintf("INTAB ");                         break;
        case PASSEDVAL : mprintf("PASSED ");                        break;
        case LOGQNTY   : mprintf("LQ ");                            break;
        case LOGVALUE  : mprintf("LV ");                            break;
        case LOGNAME   : mprintf("LN ");                            break;
        case DATASTORE : mprintf("DS ");                            break;
        case DSNAME    : mprintf("FILE ");                          break;
        case SETDATAST : mprintf("@DS ");                           break;
        case ADDTOLOG  : mprintf("A2L ");                           break;
        case CURFIELD  : mprintf("CF ");                            break;
        case FORMNAME  : mprintf("FORM ");                          break;
        case UFUNC     : mprintf("USERFUNC ");                      break;
        case CFUNC     : mprintf("CFUNC ");                         break;
        case USING     : mprintf("USING ");                         break;
        case UPDATE    : mprintf("UPDATE ");                        break;
        case ACCESSL   : mprintf("ALEVEL ");                        break;
        default        : mprintf("Error Unknown Instruction %d ",*p);
    }
}    
// skip the token buffer until the matching '}' 
char * skip(unsigned char *p)
{
    int xit=0;
    unsigned char *s;
    int curly=0;
    G_attr=8;
    p++;
    while (!xit) {
        s=p;
        switch (*p) {
            case TCONSTANT : p++;                         break;
            case SCONSTANT : p+=sizeof(int);              break;
            case LCONSTANT : p+=sizeof(long);             break;
            case DCONSTANT : p+=sizeof(double);           break;
            case OCURLY    : curly++;                     break;
            case CCURLY    : curly--; if (curly<1) xit=1; break;
        }
        if (G_run<2) if (!xit) ptok(s);
        p++;
    }
    G_attr=10;
    return(p);
}
// return the  CALL stack tos as a long (passed value)
long psd(void)
{
    return((long)G_cstack[G_csp-1]);
}
// interpret the tokens at address p
int inttok(unsigned char *p,int depth)
{
    unsigned char *s;
    unsigned char xit=0;
    unsigned char curly=0;
    unsigned char anum=G_ca;
    long l,m;
    char k;
    int ret;

    G_attr=10;


    while (!xit) {
        if (G_run<2) {
            textattr(9);
            gotoxy(1,12);
            cprintf("DEPTH [%d]   %s [%s]     ",depth,(G_nbuf[anum].t==ANAME?"ACTION":" TABLE"),G_nbuf[anum].n);
            ptok(p);
        }
        switch (*p) {
            case TCONSTANT : push((long)*((unsigned char *)(p+1)));  p++;               break;
            case SCONSTANT : push((long)*((unsigned int *)(p+1)));   p+=sizeof(int);    break;
            case LCONSTANT : push((long)*((unsigned long *)(p+1)));  p+=sizeof(long);   break;
            case DCONSTANT : push((long)((*((double *)(p+1)))*100)); p+=sizeof(double); break;
            case TABLE     : pop();                                                     break;
            case ANAME     : pop();                                                     break;
            case LOGIC_AND : push(pop()&&pop());                                        break;
            case LOGIC_OR  : push(pop()||pop());                                        break;
            case LOGIC_NOT : push(!pop());                                              break;
            case PLUS      : push(pop()+pop());                                         break;
            case NEGATE    : push(-pop());                                              break;
            case EQUAL     : l=pop(); *((unsigned long *)pop())=l;                      break;
            case LESSEQUAL : l=pop(); push(pop()<=l);                                   break;
            case LESS      : l=pop(); push(pop()<l);                                    break;
            case GREATEQUAL: l=pop(); push(pop()>=l);                                   break;
            case GREAT     : l=pop(); push(pop()>l);                                    break;
            case EQUALITY  : l=pop(); push(pop()==l);                                   break;
            case NOTEQUAL  : l=pop(); push(pop()!=l);                                   break;
            case MINUS     : l=pop(); push(pop()-l);                                    break;
            case MULTIPLY  : l=pop(); push(pop()*l);                                    break;
            case MODULUS   : l=pop(); push(pop()%l);                                    break;
            case DEVIDE    : l=pop(); if (l!=0) push(pop()/l);                          break;
            case OCURLY    : curly++;                                                   break;
            case CCURLY    : curly--;   if (curly==0) xit=1;                            break;
            case ELSE      : p=skip(p)-1;                                               break;
            case MARKER    : cpush(p);                                                  break;
            case ABS       : push(abs(pop()));                                          break;
            case ACOS      : push(acos(pop()));                                         break;
            case ASIN      : push(asin(pop()));                                         break;
            case ATAN      : push(atan(pop()));                                         break;
            case COSH      : push(cosh(pop()));                                         break;
            case COS       : push(cos(pop()));                                          break;
            case EXP       : push(exp(pop()));                                          break;
            case LOG10     : push(log10(pop()));                                        break;
            case LOGAR     : push(log(pop()));                                          break;
            case ROUND     : push(((pop()+50)/100)*100);                                break;
            case POW10     : push(pow10(pop()));                                        break;
            case SINH      : push(sinh(pop()));                                         break;
            case SIN       : push(sin(pop()));                                          break;
            case SQRT      : push(sqrt(pop()));                                         break;
            case SQR       : l=pop(); push(l*l);                                        break;
            case TANH      : push(tanh(pop()));                                         break;
            case TAN       : push(tan(pop()));                                          break;
            case TRUNC     : push((pop()/100)*100);                                     break;
            case FORMVAR   : push(G_fvars[pop()]);                                      break;
            case VARIABLE  : push(G_vars[pop()]);                                       break;
            case CURFIELD  : push((long)G_form.curitem);                                     break;
            case SETFMVAR  : push((long)&G_fvars[pop()]);                               break;
            case SETVARIAB : push((long)&G_vars[pop()]);                                break;
            case GOTOXY    : l=pop(); gotoxy(pop(),l);                                  break;
            case ACTIONN   : inttok(&G_buff[G_nbuf[G_ca=pop()].o],depth+1);             break;
            case ACCESSL   : if (G_access<pop()) xit=2;                                 break;
            case LOOKUP    : cpush((unsigned char *)pop());                             break;
            case LOOKTAB   : inttok(&G_buff[G_nbuf[G_ca=pop()].o],depth+1);             break;
            case PASSEDVAL : push(psd());                                               break;
            case RANGE     :
                l=pop();
                m=pop();
                if (l==0x7FFFFFFFL) {
                    if (psd()>=m) push(1); else push(0);
                }
                else {
                    if ((psd()<=l)&&(psd()>=m)) push(1); else push(0);
                }
                break;
            case RESULT    :
                l=pop();
                if (pop()) {
                    cpop();
                    push(l);
                    p=skip(p)-2;
                }
                break;
            case IF        :
                s=skip(p);
                if (*s==ELSE) {
                    if (!pop()) p=s;
                } else {
                    if (!pop()) p=s-1;
                }
                break;
            case WHILE     :
                if (pop()) {
                    inttok(p+1,depth+1);
                    p=cpop()-1;
                }
                else {
                    cpop();
                    p=skip(p)-1;
                }
                break;
            case LOGQNTY   : break;
            case LOGVALUE  : break;
            case LOGNAME   : break;
            case DATASTORE : break;
            case DSNAME    : break;
            case SETDATAST : break;
            case ADDTOLOG  : break;
            case FORMNAME  : 
                if (G_debug) {
                    SCONTROL('I');
                    SRESET();
                    KCONTROL('I');
                }
                ret=loadnewform(NULL,pop());
                if (G_debug) {
                    SCONTROL('E');
                    KCONTROL('E');
                }
                if (!ret) xit=2;
                break;
            case UFUNC     : 
                l=pop();
                if (G_ufunc[l].savescr) {
                    if (G_debug) {
                        SCONTROL('I');
                        SRESET();
                        KCONTROL('I');
                    }
                }
                ret=subaction(G_ufunc[l].name,0);
                if (G_ufunc[l].savescr) {
                    if (G_debug) {
                        SCONTROL('E');
                        KCONTROL('E');
                    }
                }
                if (!ret) xit=2;
                break;
            case CFUNC     :
                l=pop();
                if (G_actmap[l].savescr) {
                    if (G_debug) {
                        SCONTROL('I');
                        SRESET();
                        KCONTROL('I');
                    }
                }
                ret=subaction(G_actmap[l].name,0);
                if (G_actmap[l].savescr) {
                    if (G_debug) {
                        SCONTROL('E');
                        KCONTROL('E');
                    }
                }
                if (!ret) xit=2;
                break;
            case USING     : break;
            case UPDATE    : break;
        }
        p++;
        if (G_run<2) pstack();
        if (!xit) {
            if (G_run) {
                if (kbhit()) {
                    G_run=0;
                    getch();
                }
            }
            else {
                k=getch();
                if (k==27) xit=1;
                if (k=='r') G_run=1;
                if (k=='s') G_run=2;
            }
        }
    }
    if (xit==2) return(0);
    return(1);
}
// find the name of an action and return it's number offset ( -1 = not found )
int findname(char *name)
{
    int i=0;

    for (i=0;i<G_numn;i++) {
        if (!strcmp(name,G_nbuf[i].n)) return(i);
    }
    return(-1);
}
// run the tokens associated with name
int runtokens(char *name)
{
    int ret;

    if ((G_ca=findname(name))==(-1)) return(0);

    if (G_debug) {
        G_run=0;
        SCONTROL('E');
        KCONTROL('E');
        textattr(0x07);
        for (ret=0;ret<G_numn;ret++) {
            gotoxy(1,ret+1); cprintf("%s %d",G_nbuf[ret].n,G_nbuf[ret].o);
        }
        getch();
        clrscr();
        ret=inttok(&G_buff[G_nbuf[G_ca].o],0);
        pstack();
        textattr(0x1F);
        gotoxy(1,12);
        cprintf("                        COMPLETE  -  PRESS SPACE                                ");
        gotoxy(79,25);
        while (getch()!=32);
        SCONTROL('I');
        SRESET();
        KCONTROL('I');
    } else {
        G_run=2;
        ret=inttok(&G_buff[G_nbuf[G_ca].o],0);
    }
    return(ret);
}
// load the token list into memory
int loadactions(char *sys)
{
    char tmp[80];
    int i,fd;

    sprintf(tmp,"%s%sI.DAT",G_config,sys);

    if ((fd=open(tmp,O_RDONLY|O_BINARY))==(-1)) return(0);
    read(fd,&G_numn,sizeof(int));
    for (i=0;i<G_numn;i++) {
        read(fd,&G_nbuf[i].t,sizeof(char));
        read(fd,&G_nbuf[i].o,sizeof(int));
        read(fd,&G_nbuf[i].n,9);
    }
    read(fd,&i,sizeof(int));
    G_buff=MALLOC(i);
    if (G_buff==NULL) {
        close(fd);
        return(0);
    }
    read(fd,G_buff,i);
    close(fd);
    return(1);
}
// free the token list from memory
void freeactions(void)
{
    if (G_buff!=NULL) FREE(G_buff);
}
// dump the state of the previosly loaded forms ( Critical memory error )
void dumpstate(int from)
{
    int i;
    SCONTROL('E');
    KCONTROL('E');
    printf("Critical Error - Exit point %d\n",from);
    for (i=0;i<G_numsf;i++) printf("%-10s",G_savedf[i].name);
    printf("\n");
    exit(0);
}
// save the state of the previosly loaded form
int savestate(char *name)
{
    int i;

    if (G_numsf==MAXRECURSE) return(0);

    i=isaction(name);

    if ((i==0)&&(isform(G_system,name)==(-1L))) return(1);
    if ((i>0)&&(i<1000)&&(!G_actmap[i-1].savescr)) return(1);
    if ((i>999)&&(!G_ufunc[i-1000].savescr)) return(1);

    strcpy(G_savedf[G_numsf].name,G_form.name);
    G_savedf[G_numsf].item=G_form.curitem;
    G_savedf[G_numsf].vars=G_formvars;
    G_formvars=NULL;
    G_numsf++;
    freeform(&G_form);
    return(1);
}
// restore the state of the previosly loaded form
int reststate(char *name)
{
    int i;


    i=isaction(name);

    if ((i==0)&&(isform(G_system,name)==(-1L))) return(1);
    if ((i>0)&&(i<1000)&&(!G_actmap[i-1].savescr)) return(1);
    if ((i>999)&&(!G_ufunc[i-1000].savescr)) return(1);

    if (G_numsf==0) return(0);

    G_numsf--;

    clrform(&G_form);
    freeform(&G_form);
    strcpy(G_form.name,G_savedf[G_numsf].name);

    if (!loadform(G_system,&G_form)) return(0);
    if (G_form.type==F_MENU) {
        orderform(&G_form,1);
        drawmenu();
    }
    else {
        orderform(&G_form,0);
        redrawform();
    }
    G_form.curitem=G_savedf[G_numsf].item;
    G_formvars=G_savedf[G_numsf].vars;

    return(1);
}
// load a new form to the screen.  Saving the old
int loadnewform(char *name,long index)
{
    clrform(&G_form);
    freeform(&G_form);
    if (index>(-1L)) {
        if (!loadformidx(G_system,&G_form,index)) return(0);
    }
    else {
        strcpy(G_form.name,name);
        if (!loadform(G_system,&G_form)) return(0);
    }
    if (G_form.access<=G_access) {
    
        if (G_form.type==F_MENU) {
            orderform(&G_form,1);
            runmenu();
        }
        else {
            orderform(&G_form,0);
            if (!initform(&G_form)) {
                clrform(&G_form);
                freeform(&G_form);
                return(0);
            }
            runform(1);
            clrform(&G_form);
        }
    }
    else {
        errorline(G_noacc,1);
    }
    freeform(&G_form);
    return(1);
}
// save the state if the screen will be modified and then run an action 
void runaction(char *name)
{
    char newname[9];
    LOG('E',M_ACTIONS,3);

    strcpy(newname,name);
    name=newname;

    if (!strcmp(name,"NONE    ")) return;

    if (!savestate(name)) dumpstate(0);

    subaction(name,0);

    if (!reststate(name)) dumpstate(1);
}
// returns true if name is an action <0 token list, >0 cfunc, >1000 ufunc.
int isaction(char *name)
{
    int i=0;
    LOG('E',M_ACTIONS,4);
    while (G_actmap[i].name!=NULL) {
        if (!strcmp(name,G_actmap[i].name)) {
            RETURN(i+1);
        }
        i++;
    }
    i=0;
    while (G_ufunc[i].name!=NULL) {
        if (!strcmp(name,G_ufunc[i].name)) {
            RETURN(i+1000);
        }
        i++;
    }
    if ((i=findname(name))!=(-1)) {
        RETURN(0-(i+1));
    }
    RETURN(0);
}
#pragma warn -pro
// called to run any action ( FORM CFUNC UFUNC ACTION )
int subaction(char *name,int depth)
{
    int i,j;
    LOG('E',M_ACTIONS,5);

    if (depth==MAXRECURSE) {
        beep();
        SOUTPUT(0,23,"Tried to run action \"%s\" - recurse too deep!",name);
        SOUTPUT(0,24,"Press Any Key");
        KINPUT();
        return(0);
    }
    if (!strcmp(name,"NONE    ")) return(0);

    if (((i=isaction(name))==0)&&(isform(G_system,name)==(-1L))) return(0);

    if (i==0) {
        if (!loadnewform(name,(-1L))) {
            beep();
            SOUTPUT(0,23,"Tried to run form \"%s\" - Non-existent!",name);
            SOUTPUT(0,24,"Press Any Key");
            KINPUT();
        }
    }
    else {
        if (i>0) {
            if (i>999) {
                if (G_ufunc[i-1000].access<=G_access) {
                    if ((G_ufunc[i-1000].func)()==0) return(0);
                }
                else {
                    errorline(G_noacc,1);
                    return(0);
                }
            }
            else {
                if (G_actmap[i-1].access<=G_access) {
                    if ((G_actmap[i-1].func)()==0) return(0);
                }
                else {
                    errorline(G_noacc,1);
                    return(0);
                }
            }
        }
        else {
            if (!runtokens(name)) errorline(G_noacc,1);
        }
    }
    return(1);
}
#pragma warn +pro
