#include <dos.h>
#include <process.h>
#include <stdio.h>
#include <conio.h>

typedef short INT16;
typedef unsigned short UINT16;
typedef int INT;
typedef unsigned int UINT;

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
UINT getcallback(UINT16 sel,UINT p)
{
    UINT addr;
    union REGS r;
    struct SREGS s;
    r.x.eax=0x0303;
    s.ds=sel;
    r.x.esi=p;
    s.es=_DS;
    r.x.edi=(UINT)&G_rmregs;
    int386x(0x31,&r,&r,&s);
    if (r.x.cflag) return(0);
    addr=s.cs;
    addr<<=16;
    addr|=r.x.edx;
    return(addr);
}
int releasecallback(UINT addr)
{
    union REGS r;
    struct SREGS s;
    INT16 seg,ofs;
    ofs=(INT16)(addr&0xFFFF);
    seg=(INT16)((addr>>16)&0xFFFF);
    r.x.eax=0x0304;
    r.x.edx=(INT)ofs;
    s.cs=seg;
    int386x(0x31,&r,&r,&s);
    if (r.x.cflag) return(0);
    return(1);
}
int main(void)
{
    char tmp[100];
    INT cba;
    printf("Getting Callback address\n");
    cba=getcallback(_CS,(UINT)startup);
    printf("The Callback address is %04X:%04X\n",(cba>>16)&0xFFFF,cba&0xFFFF);
    if (cba==0) return(1);
    sprintf(tmp,"%d",cba);
    printf("Here we go......\n");
    spawnl(P_NOWAIT,"\\src\\gpa","TESTSP.EXE",tmp,NULL);
    printf("..... We're Back!\n");
    printf("Press a key to exit\n");
    getch();
    return(0);
}
