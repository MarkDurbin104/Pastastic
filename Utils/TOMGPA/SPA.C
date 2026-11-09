#include <dos.h>
#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <process.h>
#include "types.h"


typedef struct {
    ULONG  EDI,ESI,EBP,reserved,EBX,EDX,ECX,EAX;
    UINT16 flags,ES,DS,FS,GS,IP,CS,SP,SS;
} RM_REGS;
typedef union  REGS  REG;
typedef struct SREGS SREG;
int G_ctr=0;

INT alloc_callbk(void _far *f,RM_REGS _far *r,void _far **cb)
{
    REG pr;
    SREG s;
    void _far *p;
    segread(&s);
    pr.x.ax=0x0303;
    pr.x.si=FP_OFF(f);
    s.ds=FP_SEG(f);
    s.es=FP_SEG(r);
    pr.x.di=FP_OFF(r);
    int86x(0x31,&pr,&pr,&s);
    if (!pr.x.cflag) {
        FP_SEG(p)=pr.x.cx;
        FP_OFF(p)=pr.x.dx;
        *cb=p;
    }
    return pr.x.cflag;
}
INT free_callbk(void _far *p)
{
    REG r;
    r.x.ax=0x0304;
    r.x.cx=FP_SEG(p);
    r.x.dx=FP_OFF(p);
    int86(0x31,&r,&r);
    return r.x.cflag;
}
void mainrout(void)
{
    printf("I'm in the callback routine,\n");
    system("dir *.c /w");
    printf("Press a key.\n");
    printf("Pre0ss a key.\n");
    printf("Pre9ss a key.\n");
    printf("Pre8ss a key.\n");
    printf("Pre7ss a key.\n");
    printf("Pre6ss a key.\n");
    printf("Pre5ss a key.\n");
    printf("Pre4ss a key.\n");
    printf("Pre3ss a key.\n");
    printf("Pre2ss a key.\n");
    printf("Pre1ss a key.\n");
    getch();
}
void _far _interrupt callback(UINT bp,UINT di,UINT si,UINT ds,UINT es)
{
    RM_REGS _far *rmregs; // real mode registers
    UINT _far *stack;    // pointer to real mode stack
    FP_SEG(rmregs)=es;   // calculate pointer to registers
    FP_OFF(rmregs)=di;
    FP_SEG(stack )=ds;    // calculate pointer to real mode stack
    FP_OFF(stack )=si;
    mainrout();
    rmregs->CS=stack[1];
    rmregs->IP=stack[0];
    rmregs->SP+=4;
}
void setup(void)
{
    RM_REGS rmregs;
    char tmp[100];
    void _far *cb;
    printf("%d ",G_ctr);

    alloc_callbk(callback,&rmregs,&cb);

    sprintf(tmp,"%ld",(long)cb);
    spawnl(P_WAIT,"\\src\\gpa\\bit1632\\TESTSP.EXE","TESTSP.EXE",tmp,NULL);
    free_callbk(cb);

    printf(" %d",G_ctr);
}
INT main(void)
{
    G_ctr=0;
    printf("Here we go... ");
    setup();
    printf(" ... we're Back!\n");
    return(0);
}
