#define WIN_C

#include <graphics.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <dos.h>

#include "mouse.h"
#include "win.h"
#include "keydef.h"
int G_hadinp=0;

void beep(void)
{
    sound(2000);
    delay(250);
    nosound();
}
void interrupt ttimer(void)
{
    unsigned char *s,i,j;
    (oldtimer)();
    G_cnt++;
    if ((G_cnt%5)) return;
    disable();
    G_cnt=0;
    if (G_tcursor) {
        G_tcursor^=2;
        for (i=0;i<4;i++) {
            s=G_scradd;
    		outp(0x3CE,4);
    		outp(0x3CF,i);
    		outp(0x3C4,2);
    		outp(0x3C5,1<<i);
            for (j=0;j<G_tcurlen;j++) {
                *s^=G_scrmask;
                s+=80;
            }
        }
    }
    enable();
}
void tcursor(int onoff,int x,int y,int l)
{
    static int lonoff=0;
    unsigned char *s,i,j;

    if (lonoff==onoff) return;
    lonoff=onoff;

    if (onoff) {
        if (x!=(-1)) {
            G_scradd=(unsigned char *)0xA0000000L+(y<<6)+(y<<4)+(x>>3);
            G_scrmask=0x80>>(x&7);
            G_tcurlen=l;
            G_cnt=8;
            G_tcurof=1;
        }
        G_tcursor=1;
        oldtimer=getvect(0x1C);
        setvect(0x1C,ttimer);
    } else {
        setvect(0x1C,oldtimer);
        if ((G_tcursor&2)==2) {
            for (i=0;i<4;i++) {
                s=G_scradd;
        		outp(0x3CE,4);
        		outp(0x3CF,i);
                outp(0x3C4,2);
                outp(0x3C5,1<<i);
                for (j=0;j<G_tcurlen;j++) {
                    *s^=G_scrmask;
                    s+=80;
                }
            }
        }
        if (x!=(-1)) G_tcurof=0;
        G_tcursor=0;
    }
}
/*
#pragma warn -par
int handler(int err,int ax,int bp,int si)
{
    static char tmp[80];
    if (G_critfail) {
        hardretn(FAIL);
        return(FAIL);
    }
    strcpy(tmp,G_dos_err[err]);
    switch(msgb("Device Error",tmp,REBUTT|CABUTT)) {
        case REBUTT :
        	hardretn(RETRY);
            return(RETRY);
    }
    G_critfail=1;
    hardretn(FAIL);
    return(FAIL);
}
#pragma warn +par
*/                 
int itemofs(int item)
{
    int i;
    for (i=0;i<G_numwn;i++) if (G_wn[i].id==item) return(i);
    for (i=0;i<G_numbt;i++) if (G_bt[i].id==item) return(i);
    for (i=0;i<G_numlb;i++) if (G_lb[i].id==item) return(i);
    for (i=0;i<G_numsb;i++) if (G_sb[i].id==item) return(i);
    for (i=0;i<G_nummn;i++) if (G_mn[i].id==item) return(i);
    for (i=0;i<G_numtb;i++) if (G_tb[i].id==item) return(i);
    return(-1);
}
int getitemid(int t)
{
    int i;
    t*=1000;
    for (i=t;i<t+1000;i++) if (itemofs(i)==(-1)) return(i);
    return(-1);
}
void delitem(int item)
{
    int i;
    int ofs=itemofs(item);

    if (ofs==(-1)) return;
    sendmsg(item,M_STOP);

    switch (item/1000) {
        case 0 :
            for (i=ofs+1;i<G_numwn;i++)
                memcpy(&G_wn[i-1],&G_wn[i],sizeof(G_wn[i]));
            G_numwn--;
            break;
        case 1 :
            for (i=ofs+1;i<G_numbt;i++)
                memcpy(&G_bt[i-1],&G_bt[i],sizeof(G_bt[i]));
            G_numbt--;
            break;
        case 2 :
            delitem(G_lb[ofs].sb);
            for (i=ofs+1;i<G_numlb;i++)
                memcpy(&G_lb[i-1],&G_lb[i],sizeof(G_lb[i]));
            G_numlb--;
            break;
        case 3 :
            for (i=ofs+1;i<G_numsb;i++)
                memcpy(&G_sb[i-1],&G_sb[i],sizeof(G_sb[i]));
            G_numsb--;
            break;
        case 4 :
            for (i=ofs+1;i<G_nummn;i++)
                memcpy(&G_mn[i-1],&G_mn[i],sizeof(G_mn[i]));
            G_nummn--;
            break;
        case 5 :
            for (i=ofs+1;i<G_numtb;i++)
                memcpy(&G_tb[i-1],&G_tb[i],sizeof(G_tb[i]));
            G_numtb--;
            break;
    }
}
void getbounds(int id,int *x,int *y,int *x1,int *y1)
{
    int o=itemofs(id);
    switch (id/1000) {
        case 0 : *x=G_wn[o].x; *y=G_wn[o].y; *x1=G_wn[o].x1; *y1=G_wn[o].y1; break;
        case 1 : *x=G_bt[o].x; *y=G_bt[o].y; *x1=G_bt[o].x1; *y1=G_bt[o].y1; break;
        case 2 : *x=G_lb[o].x; *y=G_lb[o].y; *x1=G_lb[o].x1; *y1=G_lb[o].y1; break;
        case 3 : *x=G_sb[o].x; *y=G_sb[o].y; *x1=G_sb[o].x1; *y1=G_sb[o].y1; break;
        case 4 : *x=G_mn[o].x; *y=G_mn[o].y; *x1=G_mn[o].x1; *y1=G_mn[o].y1; break;
        case 5 : *x=G_tb[o].x; *y=G_tb[o].y; *x1=G_tb[o].x1; *y1=G_tb[o].y1; break;
    }
}
int inbounds(int id)
{
    int o=itemofs(id);
    switch (id/1000) {
        case 0 : if (G_wn[o].v) return(mousein(G_wn[o].ax+1,G_wn[o].ay+1,G_wn[o].ax1-1,G_wn[o].ay1-1));
            break;
        case 1 : if (G_bt[o].v) return(mousein(G_bt[o].x+1,G_bt[o].y+1,G_bt[o].x1-1,G_bt[o].y1-1));
            break;
        case 2 : if (G_lb[o].v) return(mousein(G_lb[o].x+1,G_lb[o].y+1,G_lb[o].x1-1,G_lb[o].y1-1));
            break;
        case 3 : if (G_sb[o].v) return(mousein(G_sb[o].x+1,G_sb[o].y+1,G_sb[o].x1-1,G_sb[o].y1-1));
            break;
        case 5 : if (G_tb[o].v) return(mousein(G_tb[o].x+1,G_tb[o].y+1,G_tb[o].x1-1,G_tb[o].y1-1));
            break;
        case 4 : return(mousein(G_mn[o].x+1,G_mn[o].y+1,G_mn[o].x1-1,G_mn[o].y1-1));
    }
    return(0);
}
void sendmsg(int id,int m)
{
    if (m==M_DELETE) {
        if (id==10000) drdb(id,m); else delitem(id);
    }
    else {
        if (m==M_BUTT1) {
            if (G_inbox!=(-1)) sendmsg(G_inbox,M_KBEND);
            G_inbox=id;
        }
        switch (id/1000) {
            case 0 : drwn(id,m); break;
            case 1 : drbt(id,m); break;
            case 2 : drlb(id,m); break;
            case 3 : drsb(id,m); break;
            case 4 : drmn(id,m); break;
            case 5 : drtb(id,m); break;
        }
    }
}
void repaint(void)
{
    int i;
    for (i=0;i<G_numwn;i++) if (G_wn[i].v) sendmsg(G_wn[i].id,M_PAINT);
    for (i=0;i<G_numbt;i++) if (G_bt[i].v) sendmsg(G_bt[i].id,M_PAINT);
    for (i=0;i<G_numlb;i++) if (G_lb[i].v) sendmsg(G_lb[i].id,M_PAINT);
    for (i=0;i<G_numsb;i++) if (G_sb[i].v) sendmsg(G_sb[i].id,M_PAINT);
    for (i=0;i<G_numtb;i++) if (G_tb[i].v) sendmsg(G_tb[i].id,M_PAINT);
    for (i=0;i<G_nummn;i++) sendmsg(G_mn[i].id,M_PAINT);
}
void pbut(int x,int y,int x1,int y1,int h)
{
    setfillstyle(1,7);
    bar(x,y,x1,y1);
    setcolor(15);
    rectangle(x++,y++,x1--,y1--);
    while (h--) {
        setcolor(0);
        moveto(x,y1);
        lineto(x,y);
        lineto(x1,y);
        setcolor(8);
        lineto(x1,y1);
        lineto(x,y1);
        x++;
        y++;
        x1--;
        y1--;
    }
}
void nbut(int x,int y,int x1,int y1)
{
    setfillstyle(1,7);
    bar(x,y,x1,y1);
    setcolor(15);
    rectangle(x++,y++,x1--,y1--);
    setcolor(8);
    moveto(x,y1);
    lineto(x,y);
    lineto(x1,y);
}
void drbt(int b,int st)
{
//    static int ls=(-1);
    if ((b=itemofs(b))==(-1)) return;
//    if (ls==((b*200)+st)) return;
//    ls=((b*200)+st);
    switch (st) {
        case M_MOVOT :
        case M_MOVE  :
        case M_KBEND :
            return;
        case M_KBHIT :
            getkey();
            return;
        case M_MOVIN :
            G_curs=G_curp;
            G_curss=G_curpss;
            return;
        case M_BUTT1 :
            if (G_bt[b].sst)
                pbut(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1,2);
            else
                nbut(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1);
            if (G_bt[b].t==OWNDRAW) {
                if (G_bt[b].uf!=NULL)
                    ((ODBFPTR)G_bt[b].uf)(G_bt[b].id,G_bt[b].x,G_bt[b].y,!G_bt[b].sst);
            }
            else {
                settextstyle(0,0,0);
                settextjustify(CENTER_TEXT,CENTER_TEXT);
                setcolor(15);
                outtextxy(2+G_bt[b].x+(G_bt[b].x1-G_bt[b].x)/2,2+G_bt[b].y+(G_bt[b].y1-G_bt[b].y)/2,(char *)G_bt[b].uf);
            }
            cursor(G_msex,G_msey);
            while ((G_mseb)&&mousein(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1)) {
                if (mousetrap(1)) cursor(G_msex,G_msey);
            }
            cursor((-1),G_msey);
            if (!G_mseb) {
                if (G_bt[b].f!=NULL) (G_bt[b].f)(G_bt[b].id,!G_bt[b].sst);
                if (itemofs(G_bt[b].id)==(-1)) return;
            }
        case M_PAINT :
            G_bt[b].v=1;
        case M_START :
        case M_UPBUT :
            if (G_bt[b].sst)
                nbut(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1);
            else
                pbut(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1,2);
            if (G_bt[b].t==OWNDRAW) {
                if (G_bt[b].uf!=NULL)
                    ((ODBFPTR)G_bt[b].uf)(G_bt[b].id,G_bt[b].x,G_bt[b].y,G_bt[b].sst);
            }
            else {
                settextstyle(0,0,0);
                settextjustify(CENTER_TEXT,CENTER_TEXT);
                setcolor(15);
                outtextxy(G_bt[b].x+(G_bt[b].x1-G_bt[b].x)/2,G_bt[b].y+(G_bt[b].y1-G_bt[b].y)/2,(char *)G_bt[b].uf);
            }
            if (G_bt[b].f!=NULL) (G_bt[b].f)(G_bt[b].id,G_bt[b].sst);
            break;
        case M_STOP  :
            setfillstyle(1,0);
            bar(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1);
            if (G_bt[b].f!=NULL) (G_bt[b].f)(G_bt[b].id,M_STOP);
            break;
        case M_HIDE  :
            setfillstyle(1,0);
            bar(G_bt[b].x,G_bt[b].y,G_bt[b].x1,G_bt[b].y1);
            G_bt[b].v=0;
            return;
    }
}
void setbstate(int b,int s)
{
    if ((b=itemofs(b))==(-1)) return;
    if (G_bt[b].sst!=s) {
        G_bt[b].sst=s;
        sendmsg(G_bt[b].id,M_PAINT);
    }
}
int button(int x,int y,int x1,int y1,int t,void *uf,BFPTR f)
{
    int i=G_numbt;
    if (i>MAXBT) return(-1);
    G_bt[i].x =x ;
    G_bt[i].y =y ;
    G_bt[i].x1=x1;
    G_bt[i].y1=y1;
    G_bt[i].t =t ;
    G_bt[i].uf=uf;
    G_bt[i].f =f ;
    G_bt[i].sst=0;
    G_bt[i].id=getitemid(1);
    G_bt[i].v=1;
    G_numbt++;
    sendmsg(G_bt[i].id,0);
    return(G_bt[i].id);
}
void sbarrow(int x,int y,int d)
{
    setcolor(15);
    switch (d) {
        case 0 :  // LEFT
            line(x-3,y,x+3,y);
            line(x-2,y+1,x+3,y+1);
            line(x-2,y-1,x+3,y-1);
            line(x,y-3,x,y+3);
            line(x-1,y-2,x-1,y+2);
            break;
        case 1 :  // RIGHT
            line(x-3,y,x+3,y);
            line(x-3,y+1,x+2,y+1);
            line(x-3,y-1,x+2,y-1);
            line(x,y-3,x,y+3);
            line(x+1,y-2,x+1,y+2);
            break;
        case 2 :  // UP
            line(x,y-3,x,y+3);
            line(x+1,y-2,x+1,y+3);
            line(x-1,y-2,x-1,y+3);
            line(x-3,y,x+3,y);
            line(x-2,y-1,x+2,y-1);
            break;
        case 3 :  // DOWN
            line(x,y-3,x,y+3);
            line(x+1,y-3,x+1,y+2);
            line(x-1,y-3,x-1,y+2);
            line(x-3,y,x+3,y);
            line(x-2,y+1,x+2,y+1);
            break;
    }
}
void drsb(int s,uint sta)
{
    uint x,y,x1,y1,sbo,st,ed,p;

    s=itemofs(s);
    if (s==(-1)) return;
    x =G_sb[s].x ;
    y =G_sb[s].y ;
    x1=G_sb[s].x1;
    y1=G_sb[s].y1;

    switch (sta) {
        case M_MOVOT :
        case M_MOVE  :
        case M_KBEND :
            return;
        case M_KBHIT :
            getkey();
            return;
        case M_MOVIN :
            G_curs=G_curp;
            G_curss=G_curpss;
            return;
        case M_PAINT :
            G_sb[s].v=1;
        case M_START :
        case M_UPBUT :
             G_sb[s].b=0;
            break;
        case M_BUTT1 :
            if (*(G_sb[s].l)<=G_sb[s].pl) break;
            if (x==x1-SBWID) {
                st=y; ed=y1; p=G_msey;
            } else {
                st=x; ed=x1; p=G_msex;
            }                     
            sbo=st+SBWID+((((ed-st)-(SBWID*3))*G_sb[s].p)/(*(G_sb[s].l)-G_sb[s].pl));
            if (p<st+SBWID) {
                if (G_sb[s].p>0) {
                    G_sb[s].p--;
                    if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,SBLNUP,G_sb[s].p);
                }
                G_sb[s].b=1;
            } else if (p>ed-SBWID) {
                if (G_sb[s].p<*(G_sb[s].l)-G_sb[s].pl) {
                    G_sb[s].p++;
                    if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,SBLNDN,G_sb[s].p);
                }
                G_sb[s].b=2;
            } else if (p<sbo) {
                if (G_sb[s].p>0) {
                    G_sb[s].p-=G_sb[s].pl;
                    if (G_sb[s].p<0) G_sb[s].p=0;
                    if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,SBPGUP,G_sb[s].p);
                }
            } else if (p>sbo+SBWID) {
                if (G_sb[s].p<*(G_sb[s].l)-G_sb[s].pl) {
                    G_sb[s].p+=G_sb[s].pl;
                    if (G_sb[s].p>*(G_sb[s].l)-G_sb[s].pl) G_sb[s].p=*(G_sb[s].l)-G_sb[s].pl;
                    if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,SBPGDN,G_sb[s].p);
                }
            } else {
                if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,SBONCT,G_sb[s].p);
                G_sb[s].b=4;
            }
            break;
        case M_HIDE  :
            setfillstyle(1,0);
            bar(x,y,x1,y1);
            G_sb[s].v=0;
            return;
        case M_STOP  :
            setfillstyle(1,0);
            bar(x,y,x1,y1);
            if (G_sb[s].f!=NULL) (G_sb[s].f)(G_sb[s].id,M_STOP,G_sb[s].p);
            return;
    }
    if (x==x1-SBWID) {
        if (*(G_sb[s].l)<=G_sb[s].pl) {
            setfillstyle(1,7);
            setcolor(15);
            bar(x+1,y+SBWID+1,x1-1,y1-SBWID-1);
            rectangle(x,y,x1,y1);
            pbut(x,y,x+SBWID,y+SBWID,1);
            pbut(x,y1-SBWID,x+SBWID,y1,1);
        } else {
            setfillstyle(1,7);
            setcolor(15);
            sbo=y+SBWID+((((y1-y)-(SBWID*3))*G_sb[s].p)/(*(G_sb[s].l)-G_sb[s].pl));
            bar(x+1,y+SBWID+1,x1-1,sbo-1); bar(x+1,sbo+SBWID+1,x1-1,y1-SBWID-1);
            rectangle(x,y,x1,y1);
            if (G_sb[s].b&1) {
                nbut(x,y,x+SBWID,y+SBWID);
                sbarrow(x+SBWID/2+1,y+SBWID/2+1,2);
            } else {
                pbut(x,y,x+SBWID,y+SBWID,1);
                sbarrow(x+SBWID/2,y+SBWID/2,2);
            }
            if (G_sb[s].b&2) {
                nbut(x,y1-SBWID,x+SBWID,y1);
                sbarrow(x+SBWID/2+1,(y1-SBWID/2)+1,3);
            } else {
                pbut(x,y1-SBWID,x+SBWID,y1,1);
                sbarrow(x+SBWID/2,y1-SBWID/2,3);
            }
            if (G_sb[s].b&4) {
                nbut(x,sbo,x+SBWID,sbo+SBWID);
            } else {
                pbut(x,sbo,x+SBWID,sbo+SBWID,1);
            }
        }
    } else {
        if (*(G_sb[s].l)<=G_sb[s].pl) {
            setfillstyle(1,7);
            setcolor(15);
            bar(x+SBWID+1,y+1,x1-SBWID-1,y1-1);
            rectangle(x,y,x1,y1);
            pbut(x,y,x+SBWID,y+SBWID,1);     
            pbut(x1-SBWID,y,x1,y+SBWID,1);   
        } else {
            setfillstyle(1,7);
            setcolor(15);
            sbo=x+SBWID+((((x1-x)-(SBWID*3))*G_sb[s].p)/(*(G_sb[s].l)-G_sb[s].pl));
            bar(x+SBWID+1,y+1,sbo-1,y1-1); bar(sbo+SBWID+1,y+1,x1-SBWID-1,y1-1);
            rectangle(x,y,x1,y1);
            if (G_sb[s].b&1) {
                nbut(x,y,x+SBWID,y+SBWID);
                sbarrow(x+SBWID/2+1,y+SBWID/2+1,0);
            } else {
                pbut(x,y,x+SBWID,y+SBWID,1);     
                sbarrow(x+SBWID/2,y+SBWID/2,0);
            }
            if (G_sb[s].b&2) {
                nbut(x1-SBWID,y,x1,y+SBWID);
                sbarrow((x1-SBWID/2)+1,y+SBWID/2+1,1);
            } else {
                pbut(x1-SBWID,y,x1,y+SBWID,1);   
                sbarrow(x1-SBWID/2,y+SBWID/2,1);
            }
            if (G_sb[s].b&4) {
                nbut(sbo,y,sbo+SBWID,y+SBWID);
            } else {
                pbut(sbo,y,sbo+SBWID,y+SBWID,1); 
            }
        }
    }
}
int scrollbar(uint x,uint y,uint x1,uint y1,uint p,uint *l,uint pl,SBFPTR f)
{
    uint i=G_numsb;
    if (i>=MAXSB) return(-1);

    G_sb[i].x =x;
    G_sb[i].y =y;
    if (x==x1) {
        G_sb[i].x1=x+SBWID;
        G_sb[i].y1=y1;
    } else {
        G_sb[i].x1=x1;
        G_sb[i].y1=y+SBWID;
    }
    G_sb[i].p =p;
    G_sb[i].pl=pl;
    G_sb[i].l =l;
    G_sb[i].f =f;
    G_sb[i].b =0;
    G_sb[i].v =1;
    G_sb[i].id=getitemid(3);
    G_numsb++;
    sendmsg(G_sb[i].id,0);
    return(G_sb[i].id);
}
void drwn(int w,int st)
{
    int i;
    int x,y,x1,y1;
    w=itemofs(w);
    if (w==(-1)) return;
    x =G_wn[w].x ;
    y =G_wn[w].y ;
    x1=G_wn[w].x1;
    y1=G_wn[w].y1;

    switch (st) {
        case M_PAINT :
            G_wn[w].v=1;
        case M_START :
            switch (G_wn[w].t) {
                case INWIN :
                    setcolor(15); rectangle(x++,y++,x1--,y1--);
                    setcolor(7);  for (i=0;i<2;i++) rectangle(x++,y++,x1--,y1--);
                case OTWIN :
                    settextstyle(0,0,0);
                    setfillstyle(1,0);  bar(x  ,y+18,x1,y1);
                    setfillstyle(1,1);  bar(x  ,y,x1,y+18);
                    setfillstyle(1,7);  bar(x  ,y,x+18,y+18);
                    setfillstyle(1,0);  bar(x+4,y+8,x+14,y+10);
                    setcolor(15);
                    rectangle(x,y,x1,y1);  rectangle(x+4,y+8,x+14,y+10);
                    line(x,y+18,x1,y+18); line(x+18,y,x+18,y+18);
                    setcolor(0);
                    settextjustify(CENTER_TEXT,CENTER_TEXT);
                    outtextxy(x+((x1-x)/2)+18,y+9,G_wn[w].ti);
                    break;
            }
            if (G_wn[w].f!=NULL) (G_wn[w].f)(G_wn[w].id,M_PAINT);
            break;
        case M_HIDE  :
            setfillstyle(1,0);
            bar(x,y,x1,y1);
            G_wn[w].v=0;
            return;
        case M_STOP  :
            setfillstyle(1,0);
            bar(x,y,x1,y1);
            if (G_wn[w].f!=NULL) (G_wn[w].f)(G_wn[w].id,M_STOP);
            break;
        case M_KBHIT  :
            if (G_wn[w].f!=NULL) {
                (G_wn[w].f)(G_wn[w].id,M_KBHIT);
            } else {
                getkey();
            }
            break;
        case M_BUTT1  :
        case M_BUTT2  :
        case M_BUTT3  :
        case M_BUTT4  :
        case M_BUTT5  :
        case M_BUTT6  :
        case M_BUTT7  :
        case M_MOVIN  :
        case M_MOVE   :
        case M_MOVOT  :
            if (G_wn[w].f!=NULL) (G_wn[w].f)(G_wn[w].id,st);
            break;
        case M_UPBUT :
            if (G_wn[w].f!=NULL) (G_wn[w].f)(G_wn[w].id,0);
            break;
    }
}
void activate(int w)
{
    int i;
    for (i=0;i<G_numwn;i++) G_wn[i].act=0;
    G_wn[itemofs(w)].act=1;
}
int actwin(void)
{
    int i;
    for (i=0;i<G_numwn;i++) if (G_wn[i].act) return(G_wn[i].id);
    return(0);
}
int win(int x,int y,int x1,int y1,int t,char *ti,WFPTR f)
{
    int i=G_numwn;
    if (i>=MAXWN) return(-1);

    G_wn[i].x =x;
    G_wn[i].y =y;
    G_wn[i].x1=x1;
    G_wn[i].y1=y1;
    G_wn[i].t =t;
    G_wn[i].ti=ti;
    G_wn[i].f =f;
    G_wn[i].act=0;
    G_wn[i].id=getitemid(0);
    G_wn[i].v=1;
    switch (t) {
        case INWIN :
            G_wn[i].ax =x+3;
            G_wn[i].ay =y+21;
            G_wn[i].ax1=x1-3;
            G_wn[i].ay1=y1-3;
            break;
        case OTWIN :
            G_wn[i].ax =x;
            G_wn[i].ay =y+18;
            G_wn[i].ax1=x1;
            G_wn[i].ay1=y1;
            break;
    }
    G_numwn++;
    sendmsg(G_wn[i].id,0);
    return(G_wn[i].id);
}
void drlb(int l,int st)
{
    int i;
    static int len;
    l=itemofs(l);
    if (l==(-1)) return;
    switch (st) {
        case M_MOVIN :
            G_curs=G_curp;
            G_curss=G_curpss;
            return;
        case M_MOVOT :
        case M_MOVE  :
        case M_KBEND :
            return;
        case M_KBHIT :
            getkey();
            return;
        case M_START :
            setcolor(15);
            setfillstyle(1,0);
            bar(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            rectangle(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            len=*(G_lb[l].ni);
            break;
        case M_PAINT :
            if (len!=*(G_lb[l].ni)) sendmsg(G_lb[l].sb,M_PAINT);
            len=*(G_lb[l].ni);
            if (G_lb[l].v==0) sendmsg(G_lb[l].sb,M_PAINT);
            G_lb[l].v=1;
            G_lb[l].otp=(-1);
            setcolor(15);
            setfillstyle(1,0);
            bar(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            rectangle(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            break;
        case M_BUTT1 :
            if (mousein(G_lb[l].x+1,G_lb[l].y+1,G_lb[l].x1-1,G_lb[l].y1-1)) {
                G_lb[l].sp=((G_msey-G_lb[l].y+1)/G_sysfh)+G_lb[l].tp;
                if (G_lb[l].sp>*(G_lb[l].ni)) G_lb[l].sp=*(G_lb[l].ni)-1;
            }
            break;
        case M_UPBUT :
            return;
        case M_HIDE  :
            setfillstyle(1,0);
            bar(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            if (G_lb[l].v==1) sendmsg(G_lb[l].sb,M_HIDE);
            G_lb[l].v=0;
            return;
        case M_STOP  :
            setfillstyle(1,0);
            bar(G_lb[l].x,G_lb[l].y,G_lb[l].x1,G_lb[l].y1);
            if (G_lb[l].f!=NULL) (G_lb[l].f)(G_lb[l].id,G_lb[l].osp,M_STOP);
            return;
    }
    if ((G_lb[l].osp!=G_lb[l].sp)&&(G_lb[l].f!=NULL))
        (G_lb[l].f)(G_lb[l].id,G_lb[l].osp,G_lb[l].sp);

    if ((G_lb[l].osp!=G_lb[l].sp)||(G_lb[l].otp!=G_lb[l].tp)) {
        G_lb[l].osp=G_lb[l].sp;
        G_lb[l].otp=G_lb[l].tp;
        settextstyle(0,0,0);
        settextjustify(LEFT_TEXT,TOP_TEXT);
        for (i=G_lb[l].tp;i<(G_lb[l].l+G_lb[l].tp);i++) {
            setcolor    (  ((i==G_lb[l].sp)?SELFG:UNSFG));
            setfillstyle(1,((i==G_lb[l].sp)?SELBG:UNSBG));
            bar(G_lb[l].x+1,G_lb[l].y+1+(i-G_lb[l].tp)*G_sysfh,G_lb[l].x1-1,G_lb[l].y+1+((i-G_lb[l].tp)+1)*G_sysfh);
            if (i<*(G_lb[l].ni)) outtextxy(G_lb[l].x+2,G_lb[l].y+2+(i-G_lb[l].tp)*G_sysfh,(G_lb[l].nf)(i));
        }
    }
}
#pragma warn -par
void lbsbfunc(int s,int mv,int p)
{
    int i;
    if (p==M_STOP) return;

    for (i=0;i<G_numlb;i++) {
        if (G_lb[i].sb==s) {
            G_lb[i].tp=p;
            sendmsg(G_lb[i].id,M_BUTT1);
            return;
        }
    }
}
#pragma warn +par
int listbox(int x,int y,int l,int *ni,LBNFPTR nf,LBFPTR f,int item,int w)
{
    int i,x1=0,y1=y+l*G_sysfh+2;
    if (G_numlb>=MAXLB) return(-1);

    if (w) x1=w; else for (i=0;i<*ni;i++) x1=max(x1,strlen((nf)(i)));
    x1*=G_sysfw;
    x1+=x+2;

    i=G_numlb;

    G_lb[i].x =x ;
    G_lb[i].y =y ;
    G_lb[i].x1=x1;
    G_lb[i].y1=y1;
    G_lb[i].l =l ;
    G_lb[i].ni=ni;
    G_lb[i].f =f ;
    G_lb[i].nf=nf;
    G_lb[i].tp=0;
    G_lb[i].sp=item;
    G_lb[i].otp=(-1);
    G_lb[i].osp=(-1);
    G_lb[i].id=getitemid(2);
    G_lb[i].v=1;
    G_numlb++;
    G_lb[i].sb=scrollbar(x1,y,x1,y1,0,ni,l,lbsbfunc);
    sendmsg(G_lb[i].id,0);
    return(G_lb[i].id);
}
unsigned long swapbytes(unsigned long l)
{
      return(((l&0xFF000000L)>>24)
            |((l&0x00FF0000L)>> 8)
            |((l&0x0000FF00L)<< 8)
            |((l&0x000000FFL)<<24));
}
void cursor(int x,int y) 
{
	int i,j;
    static int ox=(-1),oy;
	unsigned char *scr=(unsigned char *)0xA0000000L; 
    char *s;
    if (G_tcurof) tcursor(0,-1,0,0);
    if (ox!=(-1)) {
	    for (i=0;i<4;i++) {
            s=scr+oy*80+(ox>>3);
		    outp(0x3CE,4);
		    outp(0x3CF,i);
		    outp(0x3C4,2);
		    outp(0x3C5,1<<i);
            for (j=0;j<32;j++) {
                *(unsigned long*)s=G_old[(i*32)+j];
                s+=80;
            }
	    }
    }
    if (x==(-1)) {
        ox=(-1);
        putpixel(0,0,getpixel(0,0));
        if (G_tcurof) tcursor(1,-1,0,0);
        return;
    }
    
    x-=G_curss>>8;
    y-=G_curss&0xFF;

    if ((ox!=x)||(oy!=y)) {
	    for (i=0;i<4;i++) {
            s=scr+y*80+(x>>3);
		    outp(0x3CE,4);
		    outp(0x3CF,i);
		    outp(0x3C4,2);
		    outp(0x3C5,1<<i);
            for (j=0;j<32;j++) {
                G_old[(i*32)+j]=*(unsigned long*)s;
                s+=80;
            }
	    }
        oy=y;
        ox=x;
    }
	for (i=0;i<4;i++) {
        s=scr+y*80+(x>>3);
		outp(0x3CE,4);
		outp(0x3CF,i);
		outp(0x3C4,2);
		outp(0x3C5,1<<i);
        for (j=0;j<32;j++) {
            *(unsigned long*)s&=swapbytes((G_curs[j   ]>>(x&7))|G_mask[x&7]);
            *(unsigned long*)s^=swapbytes((G_curs[j+32]>>(x&7)));
            s+=80;
        }
	}
    putpixel(0,0,getpixel(0,0));
    if (G_tcurof) tcursor(1,-1,0,0);
}
void settext(int t)
{
    if (G_tb[t].ins!=(-1)) return;
    G_tb[t].str=malloc(G_tb[t].l+4);
    if (G_tb[t].str==NULL) return;
    strcpy(G_tb[t].str,G_tb[t].t);
    G_tb[t].lt=strlen(G_tb[t].t);
    G_tb[t].cp=(G_msex-G_tb[t].x)/G_sysfw;
    G_tb[t].ins=1;
    tcursor(1,G_tb[t].x+G_sysfw*G_tb[t].cp,G_tb[t].y+1,G_sysfh);
}
void clrtext(int t)
{
    if (G_tb[t].ins==(-1)) return;
    strcpy(G_tb[t].t,G_tb[t].str);
    G_hadinp=0;
    free(G_tb[t].str);
    G_tb[t].lt=0;
    G_tb[t].cp=0;
    G_tb[t].ins=(-1);
    tcursor(0,0,0,0);
}
void inptext(int t)
{
    int i,k;
    if (G_tb[t].ins==(-1)) return;
    k=getkey();
    tcursor(0,0,0,0);
    switch (k) {
        case INS :
            G_tb[t].ins^=1;
            break;
        case BKSP :
            if (G_tb[t].cp>0) G_tb[t].cp--;
            for (i=G_tb[t].cp;i<G_tb[t].lt;i++) G_tb[t].str[i]=G_tb[t].str[i+1];
            G_hadinp=1;
            break;
        case DEL :
            for (i=G_tb[t].cp;i<G_tb[t].lt;i++) G_tb[t].str[i]=G_tb[t].str[i+1];
            G_hadinp=1;
            break;
        case LEFT :
            if (G_tb[t].cp>0) G_tb[t].cp--;
            break;
        case RGT :
            if (G_tb[t].cp<(G_tb[t].lt-1)) G_tb[t].cp++;
            break;
        case ENTER :
            G_hadinp=1;
            clrtext(t);
            sendmsg(G_tb[t].id,M_PAINT);
            if (G_tb[t].f!=NULL) (G_tb[t].f)(M_UPDATE);
            cursor(G_msex,G_msey);
            return;
        case ESC :
            free(G_tb[t].str);
            G_tb[t].lt=0;
            G_tb[t].cp=0;
            G_tb[t].ins=(-1);
            sendmsg(G_tb[t].id,M_PAINT);
            if (G_tb[t].f!=NULL) (G_tb[t].f)(M_CANCEL);
            return;
        default :
            if ((k<1)||(G_tb[t].lt>=G_tb[t].l)) {
                cursor(G_msex,G_msey);
                beep();
                cursor(-1,0);
                break;
            }
            G_hadinp=1;
            if (G_tb[t].ins) {
                for (i=G_tb[t].lt;i>=G_tb[t].cp;i--) {
                    G_tb[t].str[i+1]=G_tb[t].str[i];
                }
            }
            G_tb[t].str[G_tb[t].cp]=k;
            G_tb[t].cp++;
    }
    G_tb[t].lt=strlen(G_tb[t].str);
    setfillstyle(1,0);
    bar(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
    setcolor(15);
    rectangle(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
    settextstyle(0,0,0);
    settextjustify(LEFT_TEXT,TOP_TEXT);
    outtextxy(G_tb[t].x+2,G_tb[t].y+3,G_tb[t].str);
    tcursor(1,G_tb[t].x+G_sysfw*G_tb[t].cp,G_tb[t].y+1,G_sysfh);
}
void drtb(int t,int st)
{
    char tmp[160];
    if ((t=itemofs(t))==(-1)) return;
    switch (st) {
        case M_PAINT :
            G_tb[t].v=1;
        case M_START :
            if ((G_tb[t].f!=NULL)&&((G_tb[t].rw))) (G_tb[t].f)(M_PAINT);
            setfillstyle(1,0);
            bar(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
            setcolor(15);
            if (G_tb[t].rw) rectangle(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
            settextstyle(0,0,0);
            settextjustify(LEFT_TEXT,TOP_TEXT);
            sprintf(tmp,"%-*.*s",G_tb[t].l,G_tb[t].l,G_tb[t].t);
            outtextxy(G_tb[t].x+2,G_tb[t].y+3,tmp);
            break;
        case M_MOVOT :
            if (G_tb[t].rw) {
                G_curs=G_curp;
                G_curss=G_curpss;
            }
            break;
        case M_MOVIN :
            if (G_tb[t].rw) {
                G_curs=G_curt;
                G_curss=G_curtss;
            }
            break;
        case M_MOVE  :
        case M_UPBUT :
            break;
        case M_BUTT1 :
            if (G_tb[t].rw) settext(t);
            break;
        case M_KBEND  :
            if (G_tb[t].rw) {
                if ((G_tb[t].f!=NULL)&&(G_hadinp==1)) (G_tb[t].f)(M_UPDATE);
                clrtext(t);
            }
            break;
        case M_KBHIT  :
            if (G_tb[t].rw) inptext(t);
            break;
        case M_STOP  :
            setfillstyle(1,0);
            bar(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
            if (G_tb[t].f!=NULL) (G_tb[t].f)(M_STOP);
        case M_HIDE  :
            setfillstyle(1,0);
            bar(G_tb[t].x,G_tb[t].y,G_tb[t].x1,G_tb[t].y1);
            G_tb[t].v=0;
            return;
    }
}
int textbox(int x,int y,int l,int w,char *t,TBFPTR f,int rw)
{
    int i=G_numtb;
    if (i>MAXTB) return(-1);
    G_tb[i].x =x ;
    G_tb[i].y =y ;
    G_tb[i].x1=x+l*G_sysfw+4;
    G_tb[i].y1=y+w*G_sysfh+1;
    G_tb[i].l =l ;
    G_tb[i].w =w ;
    G_tb[i].t =t ;
    G_tb[i].f =f ;
    G_tb[i].id=getitemid(5);
    G_tb[i].v=1;
    G_tb[i].rw=rw;
    G_tb[i].ins=(-1);
    G_numtb++;
    sendmsg(G_tb[i].id,0);
    return(G_tb[i].id);
}
void setcursor(int s)
{
    switch (s) {
        case 0 :
            cursor(-1,G_msey);
            G_curs=G_curp;
            G_curss=G_curpss;
            cursor(G_msex,G_msey);
            break;
        case 1 :
            cursor(-1,G_msey);
            G_curs=G_curt;
            G_curss=G_curtss;
            cursor(G_msex,G_msey);
            break;
        case 2 :
            cursor(-1,G_msey);
            G_curs=G_curb;
            G_curss=G_curbss;
            cursor(G_msex,G_msey);
            break;
        case 3 :
            cursor(-1,G_msey);
            G_curs=G_curbw;
            G_curss=G_curbwss;
            cursor(G_msex,G_msey);
            break;
        case 4 :
            cursor(-1,G_msey);
            G_curs=G_curbh;
            G_curss=G_curbhss;
            cursor(G_msex,G_msey);
            break;
        case 5 :
            cursor(-1,G_msey);
            G_curs=G_curra;
            G_curss=G_currss;
            cursor(G_msex,G_msey);
            break;
        case 6 :
            cursor(-1,G_msey);
            G_curs=G_curda;
            G_curss=G_curdss;
            cursor(G_msex,G_msey);
            break;
    }
}
void setsnap(int w,int xs,int ys)
{
    if (w==(-1)) {
        G_msx=0;
        G_msy=0;
    }
    if ((w=itemofs(w))<0) return;
    G_mxo=G_wn[w].ax+1;
    G_myo=G_wn[w].ay+1;
    G_msx=xs;
    G_msy=ys;
}
int wnxpos(int w)
{
    if ((w=itemofs(w))<0) return(0);
    return(G_msex-G_wn[w].ax);
}
int wnypos(int w)
{
    if ((w=itemofs(w))<0) return(0);
    return(G_msey-G_wn[w].ay);
}
int outmopt(int x,int y,char *s)
{
    int i=0,j=(-1);
    char tmp[20];
    while (*s) {
        if (*s=='_') {
            j=i;
        }
        else {
            tmp[i++]=*s;
        }
        s++;
    }
    tmp[i]=0;
    settextstyle(0,0,0);
    settextjustify(LEFT_TEXT,TOP_TEXT);
    outtextxy(x,y+3,tmp);
    if (j>=0) {
        line(x+j*G_sysfw,y+G_sysfh,x+(j+1)*G_sysfw,y+G_sysfh);
    }
    return(strlen(tmp)*G_sysfw);
}
void pulldown(int mn,int idx)
{
    int i,ni=0,w=0;
    int x,x1,y1;
    unsigned char *tbuf;
    MENUITEM *m,*n=(MENUITEM *)G_mn[mn].f[idx].item;
    m=n;


    cursor((-1),G_msey);
    while (m->name[0]!='^') {
        w=max(w,strlen(m->name));
        m++;
        ni++;
    }
    m=n;
    x=G_mn[mn].f[idx].x;
    x1=x+(w+1)*G_sysfw;
    y1=37+(ni+1)*G_sysfh;
    tbuf=malloc(imagesize(x,37,x1,y1));
    if (tbuf!=NULL) getimage(x,37,x1,y1,tbuf);
    setfillstyle(1,0);
    bar(x,37,x1,y1);
    setcolor(15);
    rectangle(x,37,x1,y1);
    settextstyle(0,0,0);
    settextjustify(LEFT_TEXT,TOP_TEXT);
    m=n;
    for (i=0;i<ni;i++) {
        setcolor(m->col);
        if (m->name[0]!='~') {
            outmopt(x+G_sysfw,37+i*G_sysfh+G_sysfh/2-3,m->name);
        } else {
            line(x,37+i*G_sysfh+G_sysfh,x1,37+i*G_sysfh+G_sysfh);
        }
        m++;
    }
    cursor(G_msex,G_msey);
    i=(-1);
    while (mousein(x,19,G_mn[mn].f[idx].x1,37)||mousein(x,37,x1,y1)) {
        if (mousetrap(1)) {
            if (G_mseb) {
                if (mousein(x,19,G_mn[mn].f[idx].x1,37)&&(i!=(-1))) {
                    cursor((-1),G_msey);
                    m=n+i;
                    if (m->name[0]!='~') {
                        setcolor(m->col);
                        setfillstyle(1,0);
                        bar(x+1,35+i*G_sysfh+G_sysfh/2,x1-1,36+i*G_sysfh+G_sysfh/2+G_sysfh);
                        outmopt(x+G_sysfw,34+i*G_sysfh+G_sysfh/2,m->name);
                    }
                    setfillstyle(1,1);
                    setcolor(0);
                    bar(G_mn[mn].f[idx].x,19,G_mn[mn].f[idx].x1,35);
                    outmopt(G_mn[mn].f[idx].x,20,G_mn[mn].f[idx].name);
                    i=(-1);
                }
                if (mousein(x,37,x1,y1-G_sysfh)) {
                    if (i==(-1)) {
                        cursor((-1),G_msey);
                        setfillstyle(1,0);
                        setcolor(G_mn[mn].f[idx].col);
                        bar(G_mn[mn].f[idx].x,19,G_mn[mn].f[idx].x1,35);
                        outmopt(G_mn[mn].f[idx].x,20,G_mn[mn].f[idx].name);
                        i=((G_msey-37)-G_sysfh/2)/G_sysfh;
                        m=n+i;
                        if (m->name[0]!='~') {
                            setcolor(0);
                            setfillstyle(1,1);
                            bar(x+1,35+i*G_sysfh+G_sysfh/2,x1-1,36+i*G_sysfh+G_sysfh/2+G_sysfh);
                            outmopt(x+G_sysfw,34+i*G_sysfh+G_sysfh/2,m->name);
                        }
                    } else {
                        if (i!=((G_msey-37)-G_sysfh/2)/G_sysfh) {
                            cursor((-1),G_msey);
                            m=n+i;
                            if (m->name[0]!='~') {
                                setcolor(m->col);
                                setfillstyle(1,0);
                                bar(x+1,35+i*G_sysfh+G_sysfh/2,x1-1,36+i*G_sysfh+G_sysfh/2+G_sysfh);
                                outmopt(x+G_sysfw,34+i*G_sysfh+G_sysfh/2,m->name);
                            }
                            i=((G_msey-37)-G_sysfh/2)/G_sysfh;
                            m=n+i;
                            if (m->name[0]!='~') {
                                setcolor(0);
                                setfillstyle(1,1);
                                bar(x+1,35+i*G_sysfh+G_sysfh/2,x1-1,36+i*G_sysfh+G_sysfh/2+G_sysfh);
                                outmopt(x+G_sysfw,34+i*G_sysfh+G_sysfh/2,m->name);
                            }
                        }
                    }
                }
            }
            else {
                if (i!=(-1)) {
                    m=n+i;
                    if ((m->name[0]!='~')&&(m->item!=NULL)) {
                        switch (m->type) {
                            case 0 :
                            case 1 :
                                break;
                            case 2 :
                                cursor((-1),G_msey);
                                if (tbuf!=NULL) {
                                    putimage(x,37,tbuf,COPY_PUT);
                                    free(tbuf);
                                }
                                cursor(G_msex,G_msey);
                                ((MFPTR)m->item)();
                                return;
                            case 3 :
                                cursor((-1),G_msey);
                                if (tbuf!=NULL) {
                                    putimage(x,37,tbuf,COPY_PUT);
                                    free(tbuf);
                                }
                                cursor(G_msex,G_msey);
                                mbox((MBOXITEM *)m->item);
                                return;
                            case 4 :
                                cursor((-1),G_msey);
                                if (tbuf!=NULL) {
                                    putimage(x,37,tbuf,COPY_PUT);
                                    free(tbuf);
                                }
                                cursor(G_msex,G_msey);
                                dbox((DBOXITEM *)m->item);
                                return;
                        }
                    }
                }
            }
            cursor(G_msex,G_msey);
        }
    }
    if (tbuf!=NULL) {
        cursor((-1),G_msey);
        putimage(x,37,tbuf,COPY_PUT);
        free(tbuf);
        cursor(G_msex,G_msey);
    }
}
void drmn(int m,int st)
{
    int i=0,j=2;
    if ((m=itemofs(m))==(-1)) return;
    switch (st) {
        case M_MOVIN :
            G_curs=G_curp;
            G_curss=G_curpss;
            return;
        case M_MOVOT :
        case M_KBEND :
            return;
        case M_KBHIT :
            getkey();
            return;
        case M_PAINT :
        case M_START :
            setcolor(15);
            rectangle(G_mn[m].x,G_mn[m].y,G_mn[m].x1,G_mn[m].y1);
            while (G_mn[m].f[i].name[0]!='^') {
                setcolor(G_mn[m].f[i].col);
                G_mn[m].f[i].x=j-1;
                j+=outmopt(j,20,G_mn[m].f[i].name);
                G_mn[m].f[i].x1=j;
                j+=G_sysfw*3;
                i++;
            }
            break;
        case M_BUTT1 :
            while (G_mn[m].f[i].name[0]!='^') {
                if ((G_mn[m].f[i].col==15)
                    && (G_mn[m].f[i].x<G_msex)
                    && (G_mn[m].f[i].x1>G_msex)
                    && (G_mn[m].f[i].item!=NULL)) {
                    cursor((-1),G_msey);
                    setfillstyle(1,1);
                    setcolor(0);
                    bar(G_mn[m].f[i].x,19,G_mn[m].f[i].x1,35);
                    outmopt(G_mn[m].f[i].x,20,G_mn[m].f[i].name);
                    cursor(G_msex,G_msey);
                    switch (G_mn[m].f[i].type) {
                        case 1 :
                            pulldown(m,i);
                            break;
                        case 2 :
                            while (G_mseb) mousetrap(1);
                            if (mousein(G_mn[m].f[i].x,19,G_mn[m].f[i].x1,35))
                                ((MFPTR)G_mn[m].f[i].item)();
                            break;
                    }
                    cursor((-1),G_msey);
                    setfillstyle(1,0);
                    setcolor(15);
                    bar(G_mn[m].f[i].x,19,G_mn[m].f[i].x1,35);
                    outmopt(G_mn[m].f[i].x,20,G_mn[m].f[i].name);
                    cursor(G_msex,G_msey);
                    return;
                }
                i++;
            }
            break;
        case M_UPBUT :
            return;
        case M_STOP  :
            setfillstyle(1,0);
            bar(G_mn[m].x,G_mn[m].y,G_mn[m].x1,G_mn[m].y1);
            return;
    }
}
int menu(MENUITEM *mn,int w)
{
    int i=G_nummn;
    w=itemofs(w);
    if (w==(-1)) return(-1);
    G_mn[i].x =G_wn[w].x ;
    G_mn[i].y =G_wn[w].ay;
    G_mn[i].x1=G_wn[w].x1;
    G_mn[i].y1=G_wn[w].ay+18;
    G_mn[i].f =mn;
    G_mn[i].id=getitemid(4);
    G_nummn++;
    sendmsg(G_mn[i].id,0);
    return(G_mn[i].id);
}
void offmsg(int id,int m)
{
    cursor((-1),G_msey);
    sendmsg(id,m);
    cursor(G_msex,G_msey);
}
void poll(void)
{
    int i;
    static int lb=(-1),bstat=0,first=1;
    int aw=(-1);
    int id;
    kbpoll();
    if (first) cursor(G_msex,G_msey);
    first=0;

    for (i=0;i<G_numwn;i++) if (G_wn[i].act) aw=G_wn[i].id;
    if (aw==(-1)) return;

    if (!inbounds(aw)) {
        if (mousestat(1)) {
            mousetrap(1);
            cursor(G_msex,G_msey);
        }
        return;
    }

    if (mousestat(1)||G_mseb) {
        mousetrap(1);
        if (G_msx) {
            G_msex=G_mxo+((G_msex-G_mxo)/G_msx)*G_msx;
            G_msey=G_myo+((G_msey-G_myo)/G_msy)*G_msy;
        }
        if ((!G_mseb)&&(lb!=(-1))) sendmsg(lb,M_MOVE);
        if ((!G_mseb)&&(bstat)) bstat=8; else  bstat=G_mseb;

        if ((lb!=(-1))&&(!inbounds(lb))) {
            sendmsg(lb,M_MOVOT); lb=(-1);
        }
        for (i=G_numwn-1;i>=0;i--) {
            id=G_wn[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if (bstat)  offmsg(lb,bstat);
                break;
            }
        }
        for (i=0;i<G_numbt;i++) {
            id=G_bt[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if ((bstat)&&(bstat!=8)) offmsg(lb,bstat);
                break;
            }
        }
        for (i=0;i<G_numlb;i++) {
            id=G_lb[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if (bstat)  offmsg(lb,bstat);
                break;
            }
        }
        for (i=0;i<G_numsb;i++) {
            id=G_sb[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if (bstat)  offmsg(lb,bstat);
                break;
            }
        }
        for (i=0;i<G_nummn;i++) {
            id=G_mn[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if (bstat)  offmsg(lb,bstat);
                break;
            }
        }
        for (i=0;i<G_numtb;i++) {
            id=G_tb[i].id;
            if (inbounds(id)) {
                if (lb!=id) sendmsg(lb=id,M_MOVIN);
                if (bstat)  offmsg(lb,bstat);
                break;
            }
        }
        cursor(G_msex,G_msey);
        mousetrap(1);
    }
    if (bstat==8) bstat=0;
}
void mboxbdh(int b,int x,int y,int state)
{
    int i,j=(-1),nb=(-1);
    int o=itemofs(b);
    for (i=0;i<16;i++) {
        if ((G_mb.br&(0x8000>>i))!=0) nb++;
        if ((nb>=0)&&(G_mb.bt[nb]==b)) {
            j=i;
            break;
        }
    }
    if (j==(-1)) return;
    settextstyle(0,0,0);
    settextjustify(CENTER_TEXT,CENTER_TEXT);
    setcolor(15);
    outtextxy((2*state)+x+(G_bt[o].x1-x)/2,(2*state)+y+(G_bt[o].y1-y)/2,G_buttname[j]);
}
void mboxbh(int b,int state)
{
    int i,j=0,nb=(-1);
    switch (state) {
        case M_STOP  :
        case M_BUTT0 :
            return;
        case M_BUTT1 :
            for (i=0;i<16;i++) {
                if ((G_mb.br&(0x8000>>i))!=0) nb++;
                if ((nb>=0)&&(G_mb.bt[nb]==b)) {
                    j=0x8000>>i;
                    break;
                }
            }
            if (j) {
                for (i=0;i<G_mb.nb;i++) {
                    delitem(G_mb.bt[i]);
                }
                delitem(G_mb.wn);
                repaint();
                if (G_mb.f!=NULL) (G_mb.f)(j);
                activate(G_mb.aw);
            }
            break;
    }
}
int mbox(MBOXITEM *mb)
{
    char *n=mb->n;
    char *s=mb->s;
    unsigned int b=mb->b;
    int w=0,l=2,i,nb=0;
    int x,y;
    char *st,*ed;

    if ((!(*s))||(s==NULL)) return(0);

    if (!b) b=OKBUTT;
    memset(&G_mb,0,sizeof(G_mb));
    st=ed=s;
    while (*ed) {
        if (*ed=='\n') {
            l++;
            w=max(w,(ed-st)-1);
            st=ed+1;
        }
        ed++;
    }
    if (st!=ed) {
        l++;
        w=max(w,(ed-st)-1);
    }
    w*=G_sysfw;
    l*=G_sysfh;

    for (i=0;i<16;i++) if (b&(0x8000>>i)) nb++;
    w=max(w,nb*80);
    w+=G_sysfw*2+60;
    l+=69;
    x=(640-w)/2;
    y=80;
    G_mb.br=b;
    G_mb.nb=nb;
    G_mb.f=mb->f;
    G_mb.x =x;
    G_mb.y =y;
    G_mb.x1=x+w;
    G_mb.y1=y+l;
    cursor((-1),G_msey);
    G_mb.wn=win(x,y,x+w,y+l,1,n,NULL);

    settextstyle(0,0,0);
    settextjustify(CENTER_TEXT,TOP_TEXT);
    setcolor(15);
    y+=22;
    st=ed=s;
    while (*ed) {
        if (*ed=='\n') {
            *ed=0;
            y+=G_sysfh;
            outtextxy(x+w/2,y,st);
            *ed='\n';
            st=ed+1;
        }
        ed++;
    }
    if (st!=ed) {
        y+=G_sysfh;
        outtextxy(x+w/2,y,st);
    }
    y+=10+G_sysfh;
    x+=(w-(nb*80))/2;
    for (i=0;i<nb;i++) {
        G_mb.bt[i]=getitemid(1);
        button(x+5,y,x+75,y+25,OWNDRAW,mboxbdh,mboxbh);
        x+=80;
    }
    cursor(G_msex,G_msey);
    G_mb.aw=actwin();
    activate(G_mb.wn);
    return(1);
}
void dumpst(void)
{
    int i;
    printf("Windows\n");
    printf("name                  id   x   y  x1  y1  ax  ay ax1 ay1   t act\n");
    for (i=0;i<G_numwn;i++) {
        printf("%-20.20s ",G_wn[i].ti);
        printf("%3d " ,G_wn[i].id );
        printf("%3d " ,G_wn[i].x  );
        printf("%3d " ,G_wn[i].y  );
        printf("%3d " ,G_wn[i].x1 );
        printf("%3d " ,G_wn[i].y1 );
        printf("%3d " ,G_wn[i].ax );
        printf("%3d " ,G_wn[i].ay );
        printf("%3d " ,G_wn[i].ax1);
        printf("%3d " ,G_wn[i].ay1);
        printf("%3d " ,G_wn[i].t  );
        printf("%3d\n",G_wn[i].act);
    }                
    printf("Buttons\n");
    printf(" id   x   y  x1  y1   t sst\n");
    for (i=0;i<G_numbt;i++) {
        printf("%3d " ,G_bt[i].id  );
        printf("%3d " ,G_bt[i].x   );
        printf("%3d " ,G_bt[i].y   );
        printf("%3d " ,G_bt[i].x1  );
        printf("%3d " ,G_bt[i].y1  );
        printf("%3d " ,G_bt[i].t   );
        printf("%3d\n",G_bt[i].sst );
    }
    printf("Listboxes\n");
    printf(" id   x   y  x1   y   l  ni  tp  sp otp osp  sb\n");
    for (i=0;i<G_numlb;i++) {
        printf("%3d " ,G_lb[i].id );
        printf("%3d " ,G_lb[i].x  );
        printf("%3d " ,G_lb[i].y  );
        printf("%3d " ,G_lb[i].x1 );
        printf("%3d " ,G_lb[i].y1 );
        printf("%3d " ,G_lb[i].l  );
        printf("%3d " ,G_lb[i].ni );
        printf("%3d " ,G_lb[i].tp );
        printf("%3d " ,G_lb[i].sp );
        printf("%3d " ,G_lb[i].otp);
        printf("%3d " ,G_lb[i].osp);
        printf("%3d\n",G_lb[i].sb );
    }
    printf("Scrollbars\n");
    printf(" id   x   y  x1  y1   p   l  pl   b\n");
    for (i=0;i<G_numsb;i++) {
        printf("%3d " ,G_sb[i].id );
        printf("%3d " ,G_sb[i].x  );
        printf("%3d " ,G_sb[i].y  );
        printf("%3d " ,G_sb[i].x1 );
        printf("%3d " ,G_sb[i].y1 );
        printf("%3d " ,G_sb[i].p  );
        printf("%3d " ,G_sb[i].l  );
        printf("%3d " ,G_sb[i].pl );
        printf("%3d\n",G_sb[i].b  );
    }
    printf("TextBoxes\n");
    printf(" id   x   y  x1  y1   l   w\n");
    for (i=0;i<G_numtb;i++) {
        printf("%3d " ,G_tb[i].id );
        printf("%3d " ,G_tb[i].x  );
        printf("%3d " ,G_tb[i].y  );
        printf("%3d " ,G_tb[i].x1 );
        printf("%3d " ,G_tb[i].y1 );
        printf("%3d " ,G_tb[i].l  );
        printf("%3d\n",G_tb[i].w  );
    }
}
void error(char *s)
{
    MBOXITEM m;
    m.n="Error";
    m.s=s;
    m.b=OKBUTT;
    m.f=NULL;
    mbox(&m);
}
void setupwin(int maxx,int maxy)
{
    int i;
    G_curt[0]=0x11FFFFFFL;
    G_curt[32]=0xEE000000L;
    for (i=1;i<32;i++) {
        if (i<G_sysfh-1) {
            G_curt[i   ]=0xEFFFFFFFL;
            G_curt[i+32]=0x10000000L;
        } else if (i<G_sysfh) {
            G_curt[i   ]=0x11FFFFFFL;
            G_curt[i+32]=0xEE000000L;
        } else {
            G_curt[i   ]=0xFFFFFFFFL;
            G_curt[i+32]=0x00000000L;
        }
    }
    if (!setupmouse(maxx/2,maxy/2,0,maxx,0,maxy,0))
        error("No Mouse Connected\n");
}
void wind(WINDITEM *wn)
{
    *(wn->id)=win(wn->x,wn->y,wn->x1,wn->y1,wn->t,wn->ti,wn->f);
}
void butt(BUTTITEM *bt)
{
    *(bt->id)=button(bt->x,bt->y,bt->x1,bt->y1,bt->t,bt->uf,bt->f);
}
void lbox(LBOXITEM *lb)
{
    *(lb->id)=listbox(lb->x,lb->y,lb->l,lb->ni,lb->nf,lb->f,lb->item,lb->w);
}
void sbar(SBARITEM *sb)
{
    *(sb->id)=scrollbar(sb->x,sb->y,sb->x1,sb->y1,sb->p,sb->l,sb->pl,sb->f);
}
void tbox(TBOXITEM *tb)
{
    *(tb->id)=textbox(tb->x,tb->y,tb->l,tb->w,tb->t,tb->f,tb->rw);
}
void drdb(int d,int st)
{
    int i;
    if (d!=10000) return;
    switch (st) {
        case M_DELETE :
            for (i=0;i<G_numdbi;i++) sendmsg(G_dbidx[i],st);
            G_numdbi=0;
            repaint();
            activate(G_dbaw);
            break;
    }
}
int dbox(DBOXITEM *db)
{
    DBOXITEM *d=db,*w;

    if (G_numdbi) return(-1);
    while ((d->type!=DBOXLAST)&&(d->type!=DBOXWIND)) d++;

    if (d->type!=DBOXLAST) w=d; else return(-1);

    d=db;
    cursor(-1,0);
    wind((WINDITEM *)w->item);
    G_dbidx[G_numdbi++]=*(((WINDITEM *)w->item)->id);
    while (d->type!=DBOXLAST) {
        switch (d->type) {
            case DBOXLAST :
            case DBOXWIND :
                break;
            case DBOXBUTT :
                butt((BUTTITEM *)d->item);
                G_dbidx[G_numdbi++]=*(((BUTTITEM *)d->item)->id);
                break;
            case DBOXTBOX :
                tbox((TBOXITEM *)d->item);
                G_dbidx[G_numdbi++]=*(((TBOXITEM *)d->item)->id);
                break;
            case DBOXEBOX :
                tbox((TBOXITEM *)d->item);
                G_dbidx[G_numdbi++]=*(((TBOXITEM *)d->item)->id);
                break;
            case DBOXLBOX :
                lbox((LBOXITEM *)d->item);
                G_dbidx[G_numdbi++]=*(((LBOXITEM *)d->item)->id);
                break;
            case DBOXSBAR :
                sbar((SBARITEM *)d->item);
                G_dbidx[G_numdbi++]=*(((SBARITEM *)d->item)->id);
                break;
        }
        d++;
    }
    G_dbaw=actwin();
    activate(*(((WINDITEM *)w->item)->id));
    cursor(G_msex,G_msey);
    return(10000);
}
int getkey(void)
{
    int k=getch();
    if (!k) k-=getch();
    return(k);
}
void kbpoll(void)
{
    if (!kbhit()) return;
    if (G_inbox!=(-1)) offmsg(G_inbox,M_KBHIT);
}
void windown(void)
{
    tcursor(0,0,0,0);
}
void saveid(int id)
{
    sendmsg(id,M_HIDE);
    G_sid[G_numsid++]=id;
}
void hideall(void)
{
    int i;
    for (i=1;i<G_numwn;i++) if (G_wn[i].v) { saveid(G_wn[i].id); }
    for (i=0;i<G_numbt;i++) if (G_bt[i].v) { saveid(G_bt[i].id); }
    for (i=0;i<G_numlb;i++) if (G_lb[i].v) { saveid(G_lb[i].id); }
    for (i=0;i<G_numsb;i++) if (G_sb[i].v) { saveid(G_sb[i].id); }
    for (i=0;i<G_numtb;i++) if (G_tb[i].v) { saveid(G_tb[i].id); }
}
void restore(void)
{
    int i;
    for (i=0;i<G_numsid;i++) sendmsg(G_sid[i],M_PAINT);
    G_numsid=0;
}


