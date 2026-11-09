#include <dos.h>

#include "driver.h"

#define BIOSSEG 0x40
#define KB_HEAD  0x041A
#define KB_TAIL  0x041C

char G_eflag;

int drvinit(INITBLK far *ibp);

char kbread(void)
{
    register int ch;
    for (;;) {
        if (G_eflag) {
            ch=G_eflag;
            G_eflag='\0';
            return(ch&0xFF);
        }
        _AX=0;
        geninterrupt(0x16);
        if ((ch=_AX)!=0) break;
    }
    if (ch==0x7200) ch+=0x10;
    if (!(ch&0xFF)) G_eflag=ch>>8;
    return(ch&0xFF);
}
int drvread(IOBLK far *iobp)
{
    register int cnt;
    register char far *fcb;
    fcb=iobp->buf;
    cnt=iobp->cnt;
    while (cnt--) *fcb++ = kbread();
    return(0);
}
int drvwrite(IOBLK far *iobp)
{
    register int cnt;
    register char far *fcb;
    fcb=iobp->buf;
    cnt=iobp->cnt;
    while (cnt--) {
        _AL=*fcb++;
        geninterrupt(0x29);
    }
    return(0);
}
int drvlh(char far *fcb)
{
    int ch,head,tail;
    for (;;) {
        if (G_eflag) {
            *fcb=G_eflag;
            return(0);
        }
        head=peek(BIOSSEG,KB_HEAD);
        tail=peek(BIOSSEG,KB_HEAD);
        if (head==tail) return(BUSY);
        ch=peek(BIOSSEG,head);
        if (ch) {
            if (ch==0x7200) ch+=0x10;
            *fcb=ch&0xFF;
            return(0);
        }
        _AX=0;
        geninterrupt(0x16);
    }
}
void print(char *s)
{
    while (*s) {
        asm {
            MOV  bx,7
            MOV  si,s
            INC  s
            MOV  al,ds:[si]
            MOV  ah,0x0E
            PUSH bp
            INT  0x10
            POP  bp
        }
    }
}
void pascal drventry(REQBLK far *req)
{
    int res;
    char far *info=(char far *)(req+1);
    switch (req->cmd) {
        case INIT  :
            res=drvinit((INITBLK far *)info);
            break;
        case INPUT :
            res=drvread((IOBLK far *)info);
            break;
        case OUTPUT :
        case OPVERI :
            res=drvwrite((IOBLK far *)info);
            break;
        case IPFLSH :
            pokeb(BIOSSEG,KB_HEAD,0x1E);
            pokeb(BIOSSEG,KB_TAIL,0x1E);
            G_eflag=0;
            res=0;
            break;
        case IPSTAT :
        case OPSTAT :
            res=0;
            break;
        case IPNOWT :
            res=drvlh(info);
            break;
        default:
            res=0;
    }
    req->stat=res|DONE;
}

int drvinit(INITBLK far *ibp)
{
    ibp->brk[0]=0x800;
    ibp->brk[1]=_CS;
    print("\r\n");
    print("==============================\r\n");
    print("=      Driver installed      =\r\n");
    print("==============================\r\n");
	kbread();
    return(0);
}
