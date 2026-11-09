#define SD_C

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mem.h>
#include <ctype.h>
#include <dos.h>
#include <graphics.h>

#include "types.h"
#include "mouse.h"
#include "keydef.h"
#include "gscracc.h"
#include "dst.h"
#include "control.h"
#include "config.h"

#define ON  1
#define OFF (-1)
char  *G_title="Data Store Designer Version 0.1  Copyright (c) Unisys 1992";

int             G_cds=0;
LSTOREF         G_tlib[NUMLIBITEM];
int             G_toplib=0;
int             G_saved=0;
LSTOREF         *G_slib;
STORE           *G_sstore;
int             G_numss=0;
int             G_numsl=0;
// FIELDHANDLE     G_fhs[20]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};

void dumps(void)
{
    int i,j,tot;
    FILE *fp;
    
    fp=fopen("DATASTOR.LST","w");
    for (i=0;i<G_nums;i++) {
        fprintf(fp,"Data store %d - \"%s\"   containing %d fields\n",i+1,G_store[i].name,G_store[i].numitem);
        fprintf(fp,"         P S NAME      T    LEN\n");
        tot=0;
        for (j=0;j<G_store[i].numitem;j++) {
            fprintf(fp,"Field %02d %c %c %-8s  %c    %02d\n",j+1,
            ((G_store[i].key&(0x80000000L>>j))?'':' '),
            ((G_store[i].skey&(0x80000000L>>j))?'':' '),
            G_lib[G_store[i].li[j]].name,
            G_lib[G_store[i].li[j]].type,
            G_lib[G_store[i].li[j]].len);
            tot+=G_lib[G_store[i].li[j]].len;
        }
        fprintf(fp,"Record length              %3d\n\n",tot);
    }
    fclose(fp);
}
void beep(void)
{
    sound(500);
    delay(100);
    nosound();
}
void libdrawbg(int x,int y)
{
    int i;
    pratc(x+6,y,14,"Library");
    pratc(x+2,y+1,11,"Name   Type Length");
    setcolor(14);
    rectangle(x*8-4,y*16-8,(x+20)*8+4,(y+23)*16+8);
    line(x*8-4,(y+2)*16+8,(x+20)*8+4,(y+2)*16+8);
}
void scrollbar(int x,int y)
{
    int t=(y+1)*16+((320*G_toplib)/G_numl)+1;
    int b=t+(5760/G_numl)-1;
    if (b>(y+19)*16-1) b=(y+19)*16-1;

    setcolor(14);
    pratc(x,y   ,12,"%c",'');
    pratc(x,y+19,12,"%c",'');
    rectangle(x*8,y*16,(x+1)*8,(y+20)*16);
    line(x*8,(y+1)*16,(x+1)*8,(y+1)*16);
    line(x*8,(y+19)*16,(x+1)*8,(y+19)*16);
    setfillstyle(CLOSE_DOT_FILL,14);
    bar(x*8+1,(y+1)*16+1,(x+1)*8-1,(y+19)*16-1);
    setfillstyle(1,12);
    bar(x*8+1,t,(x+1)*8-1,b);
    setcolor(4);
    rectangle(x*8+1,t,(x+1)*8-1,b);
}
int lcmp(const void *l1,const void *l2)
{
    return(strcmp(((PLSTOREF)l1)->name,((PLSTOREF)l2)->name));
}
void libfill(int x,int y)
{
    int i,j;
    memcpy(G_tlib,G_lib,sizeof(LSTOREF)*G_numl);
    qsort(G_tlib,G_numl,sizeof(LSTOREF),lcmp);
    for (i=0,j=G_toplib;((j<G_numl)&&(i<20));i++,j++) 
        pratc(x+1,y+3+i,11,"%-8s  %c    %02d",
        G_tlib[j].name,G_tlib[j].type,G_tlib[j].len);
    for (;i<20;i++) pratc(x+1,y+3+i,8,"XXXXXXXX  X    XX");
    if (G_numl>20) scrollbar(x+21,y+3);
    else for (i=0;i<21;i++) prat(x+21,y+3+i,"  ");
}
int inlib(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if ((G_numl<20)&&(mousein((x+1)*8,(y+3)*8,(x+17)*8,(y+3+G_numl)*8))) {
        return((G_msey/8)-(y+2));
    }
    else {
        if (mousein((x+1)*8,(y+3)*8,(x+17)*8,(y+23)*8)) 
            return(((G_msey/8)-(y+2))+G_toplib);
    }
    return(0);
}
void flddrawbg(int x,int y)
{
    int i;
    pratc(x+3,y,14,"Field Information");
    pratc(x+1,y+1,11,"P S  Name   Type Length");
    setcolor(14);
    rectangle(x*8-4,y*16-8,(x+24)*8+4,(y+23)*16+8);
    line(x*8-4,(y+2)*16+8,(x+24)*8+4,(y+2)*16+8);
}
void fldfill(int x,int y)
{
    int i;
    for (i=0;i<G_store[G_cds].numitem;i++) 
        pratc(x+1,y+3+i,11,"%c %c %-8s  %c    %02d",
        ((G_store[G_cds].key&(0x80000000L>>i))?'':' '),
        ((G_store[G_cds].skey&(0x80000000L>>i))?'':' '),
        G_lib[G_store[G_cds].li[i]].name,
        G_lib[G_store[G_cds].li[i]].type,
        G_lib[G_store[G_cds].li[i]].len);
    for (;i<20;i++) pratc(x+1,y+3+i,8,"X X XXXXXXXX  X    XX");
}
int inpkey(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein(x*8,(y+3)*8,(x+1)*8,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
int inskey(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein((x+2)*8,(y+3)*8,(x+4)*8-1,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
int infield(int x,int y)
{   
    if (G_msey/8>25) return(0);
    if (mousein((x+5)*8,(y+3)*8,(x+12)*8,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
int intype(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein((x+15)*8,(y+3)*8,(x+16)*8,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
int inlen(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein((x+20)*8,(y+3)*8,(x+22)*8,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
int inffield(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein((x+1)*8,(y+3)*8,(x+21)*8,(y+3+G_store[G_cds].numitem)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
void dsdrawbg(int x,int y)
{
    pratc(x,y,14,"Data Store");
    pratc(x+3,y+1,11,"Name");
    setcolor(14);
    rectangle(x*8-4,y*16-8,(x+10)*8+4,(y+23)*16+8);
    line(x*8-4,(y+2)*16+8,(x+10)*8+4,(y+2)*16+8);
}
void dsfill(int x,int y)
{
    int i;
    for (i=0;i<G_nums;i++) pratc(x+1,y+3+i,11+(G_cds==i),"%-8s",G_store[i].name);
    for (;i<20;i++) pratc(x+1,y+3+i,8,"XXXXXXXX");
}
int indstore(int x,int y)
{                             
    if (G_msey/8>25) return(0);
    if (mousein((x+1)*8,(y+3)*8,(x+8)*8,(y+3+G_nums)*8))
        return((G_msey/8)-(y+2));
    return(0);
}
void bgup(void)
{
    pratc(0,0,9,"%s   System -",G_title);
    pratc(70,0,12,G_system);
    dsdrawbg (6 ,3);
    flddrawbg(23,3);
    libdrawbg(54,3);
    G.size=2;
    prat(21,28,"SAVE       EXIT");
    G.size=1;
}
void getdsval(int i)
{
    char s[9];
    int j;

    i--;
    if (i==G_nums) s[0]=0; else strcpy(s,G_store[i].name);
    if (inputstr(7,G_msey/8,s,8,'Z')) {
        for (j=0;j<i;j++) if (!strcmp(G_store[j].name,s)) break;
        if (j==i) {
            strcpy(G_store[i].name,s);
            if (i==G_nums) {
                G_nums++;
                G_store[i].numitem=0;
                G_store[i].key=0L;
                G_store[i].skey=0L;
            }
        }
        else {
            beep();
        }
        if (G_nums==1) G_cds=0;
        dsfill(6,3);
    }
}
int libindex(char *s)
{
    int i;
    for (i=0;i<G_numl;i++) if (!strcmp(G_lib[i].name,s)) return(i);
    strcpy(G_lib[i].name,s);
    G_lib[i].type='9';
    G_lib[i].len=4;
    G_numl++;
    if (G_numl>20) G_toplib++;
    libfill(54,3);
    return(i);
}
void getfldval(int i)
{
    char s[9];
    int j;

    if (G_nums==0) {
        getkey();
        beep();
        return;
    }
    if (i>G_store[G_cds].numitem) 
        s[0]=0; 
    else 
        strcpy(s,G_lib[G_store[G_cds].li[i-1]].name);

    if (inputstr(28,G_msey/8,s,8,'Z')) {
        if (i==(G_store[G_cds].numitem+1)) {
            for (j=0;j<G_numl;j++) {
                if (!strcmp(G_lib[j].name,s)) {
                    beep();
                    break;
                }
            }
            if (j==G_numl) {
                G_store[G_cds].li[i-1]=libindex(s);
                G_store[G_cds].numitem++;
            }
        }
        else {
            for (j=0;j<G_numl;j++) {
                if (!strcmp(G_lib[j].name,s)) {
                    beep();
                    break;
                }
            }
            if (j==G_numl) {
                strcpy(G_lib[G_store[G_cds].li[i-1]].name,s);
                libfill(54,3);
            }
        }
    }
    fldfill(23,3);
    setmousexto(38*8);
}
void gettypeval(int i)
{
    char s[2];

    if (i>G_store[G_cds].numitem) {
        getkey();
        beep();
        return;
    }

    i--;
    s[0]=G_lib[G_store[G_cds].li[i]].type;
    s[1]=0;

    if (inputstr(38,G_msey/8,s,1,'F')) {
        s[0]=toupper(s[0]);
        G_lib[G_store[G_cds].li[i]].type=s[0];
        fldfill(23,3);
        libfill(54,3);
    }
    if ((s[0]=='D')||(s[0]=='T')) {
        G_lib[G_store[G_cds].li[i]].len=8-(3*(s[0]=='T'));
        setmousexto(28*8);
        setmouseyto(G_msey+8);
    }
    else {
        setmousexto(43*8);
    }
}
void getlenval(int i)
{
    char s[3];
    int j;

    if (i>G_store[G_cds].numitem) {
        getkey();
        beep();
        return;
    }

    i--;
    sprintf(s,"%02d",G_lib[G_store[G_cds].li[i]].len);
    if (inputstr(43,G_msey/8,s,2,'9')) {
        G_lib[G_store[G_cds].li[i]].len=atoi(s);
        fldfill(23,3);
        libfill(54,3);
    }
    setmousexto(28*8);
    setmouseyto(G_msey+8);
}
void delstore(int i)
{
    int j;
    if (i<=G_nums) {
        i--;
        if (G_store[i].numitem==0) {
            for (j=i;j<G_nums;j++) 
                memcpy(&G_store[j],&G_store[j+1],sizeof(STORE));
            G_nums--;
            if (G_cds>i) G_cds--;
            dsfill(6,3);
            if (G_cds==G_nums) {
                G_cds--;
                fldfill(23,3);
            }
            if (G_cds==i) fldfill(23,3);
        }
        else {
            beep();
        }
    }
}
void delfld(int i)
{
    int j,k;
    unsigned long tmpl;

    if (i<=G_store[G_cds].numitem) {
        i--;
        tmpl=G_store[G_cds].key;
        G_store[G_cds].key=0L;
        k=0;
        for (j=0;j<G_store[G_cds].numitem;j++) {
            if (j!=i) {
                if (tmpl&(0x80000000L>>j)) 
                    G_store[G_cds].key|=(0x80000000L>>k);
                k++;
            }
        }
        tmpl=G_store[G_cds].skey;
        G_store[G_cds].skey=0L;
        k=0;
        for (j=0;j<G_store[G_cds].numitem;j++) {
            if (j!=i) {
                if (tmpl&(0x80000000L>>j)) 
                    G_store[G_cds].skey|=(0x80000000L>>k);
                k++;
            }
        }
        for (j=i;j<G_store[G_cds].numitem;j++) 
            G_store[G_cds].li[j]=G_store[G_cds].li[j+1];
        G_store[G_cds].numitem--;
        fldfill(23,3);
    }
}
void dellib(int i)
{
    int j,k;
    if (i<=G_numl) {
        i=libindex(G_tlib[i-1].name);
        for (j=0;j<G_nums;j++) {
            for (k=0;k<G_store[j].numitem;k++) {
                if (G_store[j].li[k]==i) break;
            }
            if (k!=G_store[j].numitem) break;
        }
        if (j!=G_nums) {
            G_cds=j;
            beep();
            dsfill(6,3);
            fldfill(23,3);
        }
        else {
            for (k=0;k<G_nums;k++) {
                for (j=0;j<G_store[k].numitem;j++) {
                    if (G_store[k].li[j]>i)
                        G_store[k].li[j]--;
                }
            }
            for (j=i;j<G_numl;j++) {
                memcpy(&G_lib[j],&G_lib[j+1],sizeof(LSTOREF));
            }
            G_numl--;
            if (G_toplib>(G_numl-20)) G_toplib=G_numl-20;
            if (G_toplib<0) G_toplib=0;
            libfill(54,3);
        }
    }
}
void chkdel(void)
{
    int i;
    if ((i=indstore(6,3))!=0) delstore(i);
    if ((i=inlib(54,3))!=0) dellib(i);
    if ((i=inffield(23,3))!=0) delfld(i);
}
/*
int tmpcreate(PSTORE st)
{
    char *tf[NUMFIELDS];
    char *nf[NUMFIELDS];
    int i,s,len;
    char tmp[80];

    LOG('E',M_DBM,6);

    sprintf(tmp,"%s%s",G_database,st->name);
    if (PXTblExist(tmp,&i)!=PXSUCCESS) RETURN(0);
    if (i) RETURN(1);

    for (i=0;i<st->numitem;i++) {
        len=G_slib[st->li[i]].len;
        nf[i]=G_slib[st->li[i]].name;
        tf[i]=STRDUP("     ");
        switch(G_slib[st->li[i]].type) {
            case 'K' :
                strcpy(tf[i],"S");
                break;
            case 'M' :
            case 'W' :
            case '9' :
                if (len<5) {
                    strcpy(tf[i],"S");
                }
                else {
                    if (len<16) {
                        strcpy(tf[i],"N");
                    }
                    else {
                        sprintf(tf[i],"A%d",len);
                    }
                }
                break;
            case 'D' :
            case 'A' :
            case 'X' :
            case 'U' :
            case 'L' :
            case 'T' :
            case 'P' :
                sprintf(tf[i],"A%d",len);
                break;
            default :
                RETURN(0);
        }
    }
    if ((PXTblCreate(tmp,st->numitem,nf,tf))!=PXSUCCESS) RETURN(0);
    for (i=0;i<st->numitem;i++) FREE(tf[i]);

    for (i=0;i<st->numitem;i++) {
        if (!(st->key&(0x80000000L>>i))) break;
    }
    if (i<1) RETURN(1);
    if ((PXKeyAdd(tmp,i,G_fhs,PRIMARY))!=PXSUCCESS) RETURN(0);
    for (i=0;i<st->numitem;i++) {
        if (st->skey&(0x80000000L>>i)) {
            if ((PXKeyAdd(tmp,1,&G_fhs[i],INCSECONDARY))!=PXSUCCESS) RETURN(0);
        }
    }
    
    RETURN(1);
}
void copydbm(PSTORE a,PSTORE b)
{
    int i,j;
    
    b->name[0]='~';
    for (i=0;i<b->numitem;i++) {
        ;
    }
}
*/
int checkmod(void)
{
    if (!G_saved) return(0);
    if (memcmp(G_sstore,G_store,NUMSTORES*sizeof(STORE))) return(1);
    if (memcmp(G_slib,G_lib,NUMLIBITEM*sizeof(LSTOREF))) return(1);
    return(0);
}
void moddata(void)
{
    int i,j;
    for (i=0;i<G_numss;i++) {
        if (memcmp(&G_sstore[i],&G_store[i],sizeof(STORE))) {
            if (!strcmp(G_store[i].name,G_sstore[i].name)) {
                printf("Update %s Y/N ?",G_store[i].name);
                i=toupper(getkey());
                printf("\n");
                if (i=='Y') {
//                    copydbm(&G_store[i],&G_sstore[i]);
                }
            }
        }
    }
}
int main(int argc,char *argv[])
{
    int xit=0,kused=0;
    char s[9];
    int i,j;
    G_sstore=MALLOC(NUMSTORES*sizeof(STORE));
    if (G_sstore==NULL) RETURN(0);
    G_slib=MALLOC(NUMLIBITEM*sizeof(LSTOREF));
    if (G_slib==NULL) RETURN(0);
    
    if (argc<2) readconfig("GPA"); else readconfig(argv[1]);
    strupr(G_system);
    if (!setupmouse(320,100,0,632,0,232,0)) {
        printf("No Mouse Connected\n");
        return(0);
    }
    getfont();
    if (!grafix()) return(1);

    G.attr=0x0B00;
    G.size=1;
    loadsdata(G_system);
    memcpy(G_sstore,G_store,NUMSTORES*sizeof(STORE));
    memcpy(G_slib,G_lib,NUMLIBITEM*sizeof(LSTOREF));
    G_numss=G_nums;
    G_numsl=G_numl;

    cleardevice();
    bgup();
    dsfill(6,3);
    fldfill(23,3);
    libfill(54,3);
    cursor(G_msex/8,G_msey/8,1,ON);
    while (!xit) {
        if (mousestat(8)) {
            cursor(G_msex/8,G_msey/8,1,OFF);
            mousetrap(8);
            switch (G_mseb) {
                case 1 :
                    if (mousein(21*8,28*8,28*8,29*8)) { savesdata(G_system); G_saved=1; }
                    if (mousein(43*8,28*8,50*8,29*8)) xit=1;
                    if (G_numl>20) {
                        if (mousein(75*8,5*8,76*8,6*8)) {
                            G_toplib-=19;
                            if (G_toplib<0) G_toplib=0;
                            libfill(54,3);
                        }
                        if (mousein(75*8,24*8,76*8,25*8)) {
                            G_toplib+=19;
                            if (G_toplib>(G_numl-20)) G_toplib=G_numl-20;
                            libfill(54,3);
                        }
                    }
                    if ((i=indstore(6,3))!=0) {
                        if ((i<=G_nums)&&(i!=G_cds+1)) {
                            G_cds=i-1;
                            dsfill(6,3);
                            fldfill(23,3);
                        }
                    }
                    if ((i=inpkey(23,3))!=0) {
                        if (i<=G_store[G_cds].numitem) {
                            G_store[G_cds].key^=(0x80000000L>>(i-1));
                            prat(24,G_msey/8,"%c",((G_store[G_cds].key&(0x80000000L>>(i-1)))?'':' '));
                        }
                    }
                    if ((i=inskey(23,3))!=0) {
                        if (i<=G_store[G_cds].numitem) {
                            G_store[G_cds].skey^=(0x80000000L>>(i-1));
                            prat(26,G_msey/8,"%c",((G_store[G_cds].skey&(0x80000000L>>(i-1)))?'':' '));
                        }
                    }
                    if ((G_store[G_cds].numitem<20)&&((i=inlib(54,3))!=0)) {
                        if (i<=G_numl) {
                            i=libindex(G_tlib[i-1].name);
                            for (j=0;j<G_store[G_cds].numitem;j++) {
                                if (G_store[G_cds].li[j]==i) break;
                            }
                            if (j==G_store[G_cds].numitem) {
                                G_store[G_cds].li[G_store[G_cds].numitem]=i;
                                G_store[G_cds].numitem++;
                                fldfill(23,3);
                            }
                            else {
                                beep();
                            }
                        }
                    }
                    break;
                case 2 :
                    chkdel();
                    break;
            }
            cursor(G_msex/8,G_msey/8,1,ON);
        }
        if (keyhit()) {
            cursor(G_msex/8,G_msey/8,1,OFF);
            switch (peekkey()) {
                case UP :
                    getkey();
                    if (G_msey>0) setmouseyto(G_msey-8);
                    break;

                case DOWN :
                    getkey();
                    if (G_msey<479) setmouseyto(G_msey+8);
                    break;

                case LEFT :
                    getkey();
                    if (G_msex>0) setmousexto(G_msex-8);
                    break;

                case RGT :
                    getkey();
                    if (G_msex<639) setmousexto(G_msex+8);
                    break;

                case HOME :
                    getkey();
                    setmousebto(1);
                    break;

                case PGUP :
                    getkey();
                    setmousebto(2);
                    break;

                case DEL :
                    getkey();
                    chkdel();
                    break;

                case F01 :
                    dumps();
                    break;

                default :
                    kused=0;
                    if ((i=indstore(6,3))!=0) {
                        getdsval(i);
                        kused=1;
                    }
                    if ((!kused)&&((i=infield(23,3))!=0)) {
                        getfldval(i);
                        kused=1;
                    }
                    if ((!kused)&&((i=intype(23,3))!=0)) {
                        gettypeval(i);
                        kused=1;
                    }
                    if ((!kused)&&((i=inlen(23,3))!=0)) {
                        getlenval(i);
                        kused=1;
                    }
                    if (!kused) getkey();
            }
            cursor(G_msex/8,G_msey/8,1,ON);
        }
    }
    cursor(G_msex/8,G_msey/8,1,OFF);
    closegraph();
    if (checkmod()) {
        printf("The Data in the database needs to be changed to reflect the changes\n");
        printf("made to the data stores.\n");
        printf("Do you wish to proceed with the data update Y/N ?");
        i=toupper(getkey());
        printf("\n");
        if (i=='Y') moddata();
    }
    return(1);
}


