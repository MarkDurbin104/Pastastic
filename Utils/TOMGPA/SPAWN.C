#include <memory.h>
#include <dos.h>
#include <process.h>
#include <stdio.h>
#include <conio.h>

typedef short INT16;
typedef unsigned short UINT16;
typedef int INT;
typedef unsigned int UINT;

#define PUSH_DS { __emit__(0x1E); }
#define POP_DS  { __emit__(0x1F); }
#define PUSH_CS { __emit__(0x0E); }
#define POP_CS  { __emit__(0x0F); }

typedef struct {
    INT  edi;    
    INT  esi;    
    INT  ebp;    
    INT  res;    
    INT  ebx;    
    INT  edx;    
    INT  ecx;    
    INT  eax;    
    INT16 flags;    
    INT16 es;    
    INT16 ds;    
    INT16 fs_res;    
    INT16 gs_res;    
    INT16 ip;    
    INT16 cs;    
    INT16 sp;    
    INT16 ss;    
} RMREGS;
RMREGS G_rmregs;

void startup(void)
{

    printf("I'm in the 32bit app start section...\n");
    printf("Press a key.\n");
    getch();
}
UINT getcallback(UINT16 selp,UINT p,INT16 sels,UINT s)
{
    UINT addr;

    PUSH_DS
    _ES=sels;
    _EDI=s;
    _DS=selp;
    _ESI=p;
    _EAX=0;
    _AX=0x0303;
    geninterrupt (0x31);
    POP_DS
    if (_FLAGS&1) return(0);
    addr=_ECX;
    addr<<=16;
    addr|=_EDX;
    return(addr);
}
int releasecallback(UINT addr)
{
    _EAX=0;
    _AX=0x0304;
    _EDX=addr;
    geninterrupt (0x31);
    return(1);
}
int main(void)
{
    char tmp[100];
    INT cba;
    printf("Getting Callback address\n");
    cba=getcallback(_CS,(UINT)startup,_DS,(UINT)&G_rmregs);
    printf("The Callback address is %04X:%04X\n",(cba>>16)&0xFFFF,cba&0xFFFF);
    if (cba==0) return(1);
    sprintf(tmp,"%d",cba);
    printf("Here we go......\n");

    spawnl(P_NOWAIT,"d:\\src\\gpa\\bit1632\\TESTSP.EXE","TESTSP.EXE",tmp,NULL);

    perror("SPAWN");
    printf("..... We're Back!\n");
    printf("Press a key to exit\n");
    getch();
    _AX=1000;
    geninterrupt(0x62);
    _AX=0xA55A;
    geninterrupt(0x62);
    return(0);
}
